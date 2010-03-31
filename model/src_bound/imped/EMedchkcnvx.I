/*
  DESCRIPTION
 
    This method checks the convexity/concavity of the edge. If this edge
    is netral (w.r.t to a specifed tolerance), it returns this piece of
    information too. An EMS-wide zero-angle tolerance of EMS_ZEROANGLE_DEG
    is recommended (emsdef.h).

    It can optionally return an angle measure between 0 and 4 which is
    monotonically increasing (but non-linearly) with the included angle 
    bounding the volume at this edge. 0 to 2 indicates a convex edge 
    and 2 to 4 indicates a concave edge. This computation can be turned off by
    specifying a NULL for the output arguement.

  NOTES
  
    If this edge does not have a common edge, the error code returned is
    EMS_I_NotFound, and the edges is characterized as concave with a 4.0
    angle measure.
    
  OPTIONS

    Options supported are listed in EMSopt.h:
    EMSchkconvex_global		- This bit when set requests that the method
                                  perform a more global lookup for the
                                  convexity/concavity when a tangency is
                                  encountered. That is look in the neighborhood
                                  to determine this fact.
    EMSchkconvex_nextgeomsf     - This bit when set will disregard the
                                  topologically adjacent surface IF the
                                  surface is degenerate at the point of
                                  consideration. It will travel outward to find
                                  the next "geometric" non-degenerate surface
                                  to use in the computation.
    EMSchkconvex_geometric	- When set it ignores the property EMED_TANGENT
                                  on the edge. The default behaviour is to
                                  return this edge as neutral if this property
                                  is set on the edge. But the angle-measure
                                  will be computed geometrically, regardless.

  HISTORY

    SS  :  04/08/91  :  Creation. Modified the chkedconvex code in 
                        EMedsfintdat.I
    Inasu : 05/06/91 :  Fixed a small bug of parameter passing to BSmdstptcv().

    Inasu : 10/17/91 :  Moved out the "tolbas" initialisation out of the
                        first "while" loop.
    Sudha   06/04/93    modified to include BSprototype header files

    Aditya : 06/05/95 :  Added the static function get_tangent() to evaluate
                        curve tangent at a parameter even if that span is
                        degenerate. Reaction to TR# 119525764.

    Ramana  08/16/95    Added emsdef.h as bsvalues.h is changed and removed 
			values.h.
*/

class implementation EMSedge;

%safe
#include <math.h>
%endsafe

#include "OMmacros.h"
#include "emsoffptdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bssfarrevn.h"
#include "bsnorvec.h"
#include "bsmdstptcv.h"
#include "bsdotp.h"
#include "bscveval.h"
#include "bscrossp.h"
#include "bsvalues.h"   
#include "bsextrcvspn.h"   
#include "bscvndegspn.h"   
#include "bsfindspn.h"   
#include "bststcvdegn.h"   
#include "emsdef.h"

#define U 0
#define V 1

/*
 * The angle measure of an included angle ranges from 0 to 4, indicating
 * a monotonically increasing scale corresponding to 0-deg to 360-deg.
 * The map is non-linear, but at the four nodal points [0(360), 90, 180 and
 * 270] it corresponds to [0(4), 1, 2 and 3]. With zero-tolerance an angle
 * measure less than 2.0 indicates a convex edge and otherwise a concave
 * edge.
 */

#define HALF_ANGLE_MEASURE 2.0
#define FULL_ANGLE_MEASURE 4.0
#define FLAT_ANGLE_MEASURE 2.0

#define MAX_ITER 5
#define OFFSET_FACTOR 0.0001
#define ORDER_OF_MAGNITUDE 10

%safe
static void get_tangent();
%endsafe

from EMSsubbs import EMpratmpt, EMsftanorm, EMgetbsdef;

method EMchkconvex (IGRlong *msg; IGRushort opts;
                    IGRshort *mattyp; IGRmatrix mat;
                    IGRdouble neutral_angle_tol;
                    IGRboolean *convex, *neutral;
                    IGRdouble *angmeas)
{
  IGRboolean into_vol, good_uvpt_found, this_pos_orient, other_pos_orient;
  IGRboolean loc_neutral;
  IGRushort offpt_options;
  IGRint i, num_iter;
  OMuint count;
  IGRlong msg_loc, stat_OM;
  IGRdouble lentol, dottol, dotp;
  IGRdouble upar, uvpt[2], mdist, offdist, urange, vrange, prange;
  IGRpoint xyzpt, dumpt, tanpt[2], normpt[2];
  IGRvector xyztan, xyznor;
  IGRvector this_outtan, this_orntnor, other_orntnor, new_other_orntnor;
  IGRvector orig_other_orntnor;
  GRobjid this_uvedge, other_uvedge, this_srfid, other_srfid, coinced, tmpobj;
  struct EMSpartolbasis tolbas;
  struct IGRbsp_surface *srf=NULL, *this_srf=NULL, *other_srf=NULL;
  struct IGRbsp_curve xyzcrv;
  struct GRmdenv_info mdenv;
  struct IGRbsp_surface sfdef;
  OM_S_CHANSELECT chan_to_common;
  OM_S_OBJECT_LINKAGE objlist;
  extern void EMavgsfnorm();
  extern IGRlong EMinternalpt(), EMgetabsg();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  xyzcrv.poles = NULL;
  xyzcrv.knots = NULL;
  xyzcrv.weights = NULL;

  /* initialize partol structure */

  tolbas.mat = mat;
  tolbas.mattyp = mattyp;
  tolbas.is_valid = FALSE;
  tolbas.in_world = TRUE;
  
  /*
   * Check to see if this edge has a common edge. If it does not,
   * return an informational message and values that sort of make
   * sense.
   */

  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);

  loc_neutral = FALSE;
  if(!neutral) neutral = &loc_neutral;
  count = 0;
  this_uvedge = my_id;
  om$get_channel_objects (objid = this_uvedge, p_chanselect = &chan_to_common,
   list = &objlist, size = 1, count = &count);
  if (!count)
    {
    *convex = FALSE;
    *neutral = FALSE;
    if(angmeas)
      *angmeas = FULL_ANGLE_MEASURE;
    *msg = EMS_I_NotFound;
    goto ret_end;
    }
  other_uvedge = objlist.S_objid;

  /*
   * There are two surfaces involved - one that corresponds to this edge
   * and the other that corresponds to the common-edge. Make sure that the
   * following logic looks at "this" surface as the one which is planar,
   * if either of them is planar. In other words, a flip of this_uvedge with
   * other_uvedge may be warranted if other_uvedge corresponds to a planar
   * surface and this_uedge does not. This ensures simplicity to the code,
   * specifically when the search for the convexity/concavity is to be
   * "global".
   */

  om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc, &tmpobj,
   NULL), targetid = this_uvedge);
  sfdef.planar = FALSE;
  om$send (msg = message EMSsubbs.EMgetbsdef (&msg_loc, &sfdef),
   targetid = tmpobj);
  if (!sfdef.planar)
    EMswapmem (&this_uvedge, &other_uvedge, sizeof (GRobjid));

  /*
   * Initialize some environment constants
   */

  dottol = cos ((90.0 - neutral_angle_tol) * (M_PI/180.0));
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);

  /*
   * Obtain an internal model-space point on this edge (xyzpt). Also obtain the
   * surface natural normal (xyznor) and the natural tangent to the model-space
   * counterpart of this edge (xyztan).
   */

  stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
             &this_srfid, NULL), targetid = this_uvedge);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

  stat_OM = EMgetabsg (&msg_loc, mattyp, mat, OM_Gw_current_OS, this_srfid,
             &this_srf);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);
  this_pos_orient = this_srf->pos_orient;

  stat_OM = om$send (msg = message EMSedge.EMinternalpt (&msg_loc, 1, NULL,
             uvpt, NULL, NULL), targetid = this_uvedge);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

  BSsfarrevn (&msg_loc, this_srf, 1, &uvpt[U], 1, &uvpt[V], xyzpt, xyznor);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  if (! (mdenv.matrix_type = *mattyp) == MAIDMX)
    OM_BLOCK_MOVE (mat, mdenv.matrix, sizeof (IGRmatrix));

  stat_OM = om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc, &mdenv,
             NULL, this_srf, 0, MAXINT, FALSE, NULL, &xyzcrv),
             targetid = this_uvedge);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

  BSmdstptcv (&xyzcrv, xyzpt, &upar, dumpt, &mdist, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

/*****
  Replaced by call to get_tangent().

  BScveval (&xyzcrv, upar, 1, tanpt, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  OM_BLOCK_MOVE (tanpt[1], xyztan, sizeof (IGRvector));
  BSnorvec (&msg_loc, xyztan);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
*****/

  get_tangent( &msg_loc, &xyzcrv, upar, tanpt);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  OM_BLOCK_MOVE (tanpt[1], xyztan, sizeof (IGRvector));

  /*
   * Find the normal to this model-space edge such that it points out of the 
   * area of which the edge is a boundary. This is the cross product
   * between the natural normal to the surface at this point and the tangent 
   * computed above (this, because clockwise direction skirts an area).
   */

  BScrossp (&msg_loc, xyznor, xyztan, this_outtan);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  BSnorvec (&msg_loc, this_outtan);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  /*
   * Obtain the oriented normal (pointing toward volume) of the other
   * surface at the internal point obtained above. The "geometric"
   * "other surface" may not be the same as the topological "other surface".
   * A case in point is when the input "other surface" is a degenerate
   * one. If the option is set to search for the "geometric next", then
   * conduct the appropriate search.
   *
   * To prevent this while loop from becoming an infinite one under this
   * option, put in a check to not iterate more than MAX_ITER. This number is
   * an indication of the maximum number of "degenerate" loops that can be
   * topologically adjacent to one another. Theoretically, it would seem that
   * this loop should never become infinite, even without this check.
   */

  stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
             &other_srfid, NULL), targetid = other_uvedge);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

  num_iter = 0;
  good_uvpt_found = FALSE;
  while (!good_uvpt_found && num_iter <= MAX_ITER)
    {
    num_iter++;
    stat_OM = om$send (msg = message EMSsubbs.EMpratmpt (&msg_loc, 
               mattyp, mat, 1, xyzpt, uvpt, NULL, NULL), 
               targetid = other_srfid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError,
     ret_end);

    if (opts & EMSchkconvex_nextgeomsf)
      {
      /*
       * If this this_uvedge and the other_uvedge are seam-edges on the same
       * surface (inferred by xyzedge_srf and other_srf being one and the
       * same), there is no need to search for another geometrically adjacent
       * surface, because, none can exist in this situation. So break out of
       * the loop the moment the uv-point is obtained. Else, look to see
       * if the other_uvedge belongs to a degenerate loop.
       */

      if (IF_EQ_OBJID (this_srfid, other_srfid))
        break;

      stat_OM = om$send (msg = message EMSedge.EMptcoinc (&msg_loc, uvpt,
                 &coinced, NULL, NULL, NULL, &tolbas),
                 targetid = other_uvedge);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
       ret_end);

      if (msg_loc == EMS_I_Found)
        {
        count = 0;
        om$get_channel_objects (objid = coinced,
         p_chanselect = &chan_to_common, list = &objlist, size = 1,
         count = &count);

        /*
         * If the coincident edge does not have a common edge, the search
         * stops. The uvpt and the other_srfid obtained so far is good.
         */

        if (!count)
          break;

        other_uvedge = objlist.S_objid;
        stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info
                   (&msg_loc, &other_srfid, NULL), targetid = other_uvedge);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
         ret_end);
        }
      else
        good_uvpt_found = TRUE;
      }
    else
      good_uvpt_found = TRUE;
    }

  /*
   * Compute the oriented normal to the other surface at the uv-point 
   * determined above.
   *
   * Optionally, the point at which the normal is computed for this
   * "other surface" is slightly away from the edge in the non-planar surface
   * case, considering the probability of having tangential-surface conditions
   * right along an edge. This latter technique sometimes provides a more
   * useful picture of how the other surface is behaving at this edge. 
   * 
   * But save the original normal that was obtained at the original
   * uv-point (without any offsets). This would be used to determine whether
   * this was a "neutral" edge or not.
   */

  stat_OM = EMgetabsg (&msg_loc, mattyp, mat, OM_Gw_current_OS, other_srfid,
             &other_srf);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);
  other_pos_orient = other_srf->pos_orient;

  EMavgsfnorm (&msg_loc, other_srf, uvpt[U], uvpt[V], dumpt, other_orntnor);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
  OM_BLOCK_MOVE (other_orntnor, orig_other_orntnor, sizeof (IGRvector));

  if (opts & EMSchkconvex_global && !other_srf->planar)
    {
    /*
     * If the surface is non-planar the point at which to determine
     * the normal might involve tangency (statistically speaking,
     * the chances for tangency-conditions to occur are greater at the
     * edges). So take a point slightly offset from the edge for this 
     * purpose. This will enable a more workable normal to be obtained.
     * Of course, the problem is to determine the amount of offset.
     * OFFSET_FACTOR times the smallest parametric range (either in u or
     * v direction) of the surface is used. If the normal now computed
     * does not differ from the previously computed one by atleast
     * the tolerance amount, the offset distance is increased by an order
     * of magnitude. This procedure is followed until the offset distance
     * exceeds the parametric range; at which point the normal so obtained
     * is itself used.
     */

    srf = other_srf;
    urange = srf->u_knots[srf->u_num_poles] - srf->u_knots[srf->u_order-1];
    vrange = srf->v_knots[srf->v_num_poles] - srf->v_knots[srf->v_order-1];
    if (urange < vrange)
      prange = urange;
    else
      prange = vrange;
    offdist = prange * OFFSET_FACTOR;

    good_uvpt_found = FALSE;
    offpt_options = EMSoffpt_Scalar | EMSoffpt_NoTravel | EMSoffpt_OffDistUv;
    while (!good_uvpt_found && offdist < prange)
      {
      stat_OM = om$send(msg = message EMSedge.EMoffpoint(&msg_loc, NULL, uvpt, 
		 NULL, offdist, NULL, srf, NULL, &tolbas, NULL, NULL, NULL, 
		 offpt_options, uvpt, NULL, NULL), targetid = other_uvedge);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
       ret_end);

      stat_OM = om$send (msg = message EMSsubbs.EMsftanorm (&msg_loc, mattyp,
                 mat, NULL, 1, &uvpt[U], 1, &uvpt[V], 1.0, NULL, FALSE, TRUE,
                 (IGRdouble *)normpt, NULL), targetid = other_srfid);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError,
       ret_end);
      for (i=X; i<=Z; i++)
        new_other_orntnor[i] = normpt[1][i] - normpt[0][i];

      dotp = BSdotp (&msg_loc, new_other_orntnor, other_orntnor);
      if (1.0 - dotp > dottol)
        {
        OM_BLOCK_MOVE (new_other_orntnor, other_orntnor, sizeof (IGRvector));
        good_uvpt_found = TRUE;
        }
      offdist *= ORDER_OF_MAGNITUDE;
      }
    }

  if (!other_pos_orient)
    {
    other_orntnor[X] = -other_orntnor[X];
    other_orntnor[Y] = -other_orntnor[Y];
    other_orntnor[Z] = -other_orntnor[Z];

    orig_other_orntnor[X] = -orig_other_orntnor[X];
    orig_other_orntnor[Y] = -orig_other_orntnor[Y];
    orig_other_orntnor[Z] = -orig_other_orntnor[Z];
    }

  /*
   * If the dot product between the outward-tangent on this_srf and the
   * inward-normal on the other_srf is negative, the edge is convex. If it is
   * positive, the edge is concave. If the abs-value of the product is within
   * tolerance, the edge is neutral. In this latter case, the edge is treated
   * as convex. A caveat to the geometric checks exists - if the edge is
   * marked as tangent then the characterization will always be neutral, 
   * regardless of the tolerance. This property look-up is inhibited if a
   * specific option is used (EMSchkconvex_geometric).
   *
   * The tolerance is applied on the angle subtended by these two
   * vectors. Knowing that the vectors are normalized, the dot-product
   * tolerance then is the cosine of the zero-angle.
   */

  dotp = BSdotp (&msg_loc, this_outtan, other_orntnor);

  if (dotp > dottol)
    *convex = FALSE;
  else 
    *convex = TRUE;

  if (fabs (BSdotp (&msg_loc, this_outtan, orig_other_orntnor)) < dottol)
    *neutral = TRUE;
  else
    *neutral = FALSE;

  if (ME.EMSedge->ed_props & EMED_TANGENT &&
      !(opts & EMSchkconvex_geometric))
    *neutral = TRUE;

  if (angmeas)
    {
    /*
     * If the angle-measure of the included volume at this edge is required,
     * the value of the dot-product can be manipulated to be a measure of this
     * included angle.
     *
     * To begin with, the raw value of the dot-product is not monotonically 
     * increasing with increasing angle. For the same value of the dot-product,
     * two different positions of the other surface are possible - one on 
     * either side of this surface. The dot-product values for a convex edge go
     * from 0 to -1 to 0 with increasing included angle. Similarly, for a
     * concave edge it goes from 0 to 1 to 0 with increasing included angle. 
     *
     * To derive the ang-measure of the included angle the dot-product is
     * doctored as follows:- First "this_orntnor" is obtained. This gives
     * the feel for the volume side of this-surface. The sign of the dot-
     * product between "this_orntnor" and "other_orntnor" tells whether 
     * "other_orntnor" points out of the this-surface's volume region or into
     * it. The sign tells whether the dot-product computed above has crossed 
     * the half-way mark or not. Now, the value of the dot-product can be 
     * easily transformed to read monotonically increasing from 0 to 2 with 
     * increasing included angle.
     *
     * Further, the angle-measure to be output for the edge is transformed
     * to value ranging from 0 to 4. Values less than 2 imply a convex vertex
     * and values greater than 2 imply a concave vertex.
     */

    OM_BLOCK_MOVE (xyznor, this_orntnor, sizeof (IGRvector));
    if (!this_pos_orient)
      {
      this_orntnor[X] = -this_orntnor[X];
      this_orntnor[Y] = -this_orntnor[Y];
      this_orntnor[Z] = -this_orntnor[Z];
      }

    if (BSdotp (&msg_loc, this_orntnor, other_orntnor) > 0.0)
      into_vol = TRUE;
    else
      into_vol = FALSE;

    dotp = fabs (dotp);
    if (into_vol)
      *angmeas = HALF_ANGLE_MEASURE - dotp;
    else
      *angmeas = dotp;

    if (!*convex)
      *angmeas = FULL_ANGLE_MEASURE - *angmeas;
    }

ret_end:
  if (xyzcrv.poles)
    om$dealloc (ptr = xyzcrv.poles);
  if (xyzcrv.knots)
    om$dealloc (ptr = xyzcrv.knots);
  if (xyzcrv.weights && xyzcrv.rational)
    om$dealloc (ptr = xyzcrv.weights);

  EMWRAPUP (*msg, stat_OM, "EMSedge.EMchkconvex");
  return (stat_OM);
}

/*
* Evaluates the tangent to a curve and ensures that the tangent is
 * not degenerate even if the span at the parameter is degenerate.
 */

static void get_tangent(msg, curve, param, tangent)
IGRlong *msg;
struct IGRbsp_curve *curve;
IGRdouble param;
IGRpoint tangent[2];
{
  IGRlong msg_loc;
  IGRpoint tanpt[2];
  IGRint i;
  IGRboolean degen = FALSE;
  
  msg_loc = BSSUCC;

  /** Error out if the whole curve is degenerate. **/
  BStstcvdegn(curve, &degen, &msg_loc);
  if(degen) EMerr_hndlr (TRUE, *msg, EMS_E_BSerror, ret_end);

  BScveval (curve, param, 1, tanpt, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  OM_BLOCK_MOVE (tanpt[0], tangent[0], sizeof (IGRpoint));
  OM_BLOCK_MOVE (tanpt[1], tangent[1], sizeof (IGRpoint));
  BSnorvec (&msg_loc, tangent[1]);

  /** Go ahead only if the vector is degenerate. **/
  if(msg_loc == BSDGENRAT)
    {
    IGRboolean is_degen = TRUE;
    IGRint spn_index=0, num_spans, next, prev;
    struct IGRbsp_curve *span_cur=NULL;


    /** Find the span in which the parameter lies **/
    BSfindspn(&msg_loc, &(curve->order), &(curve->num_poles), 
              curve->knots, &param, &spn_index);

    num_spans = (curve->num_poles - curve->order + 1);

    /* If the span is degenerate the tangent will also be degenerate,
     * therefore extract the next span (or previous span) and
     * evaluate the curve at u=0 (or u=1) respectively to find the 
     * tangent at the parameter. Continue until a span is found,
     * either before or after the tested degenerate spans, which
     * gives a non-degenerate tangent vector.
     */

    next = prev = -1;
    if((spn_index+1)<=num_spans) next = spn_index+1;
    if((spn_index-1)>=1) prev = spn_index-1;

    span_cur = (struct IGRbsp_curve *)om$malloc(size = sizeof(struct IGRbsp_curve));
    span_cur->num_poles = curve->order;
    span_cur->order = curve->order;
    span_cur->rational = curve->rational;
    span_cur->poles = (IGRdouble *)om$malloc(size=3 * span_cur->num_poles * sizeof(IGRdouble));

    /* As num_poles == order, num_knots = 2 * order */
    span_cur->knots = (IGRdouble *)om$malloc(size=2 * span_cur->num_poles * sizeof(IGRdouble));
    if(span_cur->rational)
       span_cur->weights = (IGRdouble *)om$malloc(size= span_cur->num_poles * sizeof(IGRdouble));

    for(i=0;i<num_spans && is_degen;i++)
      {
       IGRboolean planar, closed;
       if(prev != -1)
         {
          BSextrcvspn(&msg_loc, &prev , curve, span_cur, &planar, &closed);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

          BScveval (span_cur, 1.0, 1, tanpt, &msg_loc);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

          OM_BLOCK_MOVE(tanpt[0],tangent[0],sizeof(IGRvector));
          OM_BLOCK_MOVE(tanpt[1],tangent[1],sizeof(IGRvector));
          BSnorvec (&msg_loc,tangent[1]);
          if(msg_loc != BSDGENRAT)
            {
             is_degen = FALSE;
             if((prev-1)>=1) prev--; 
            }
         }
       if(next != -1 && is_degen)
         {
          BSextrcvspn(&msg_loc, &next , curve, span_cur, &planar, &closed);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

          BScveval (span_cur, 0.0, 1, tanpt, &msg_loc);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

          OM_BLOCK_MOVE(tanpt[0],tangent[0],sizeof(IGRvector));
          OM_BLOCK_MOVE(tanpt[1],tangent[1],sizeof(IGRvector));
          BSnorvec (&msg_loc, tangent[1]);
          if(msg_loc != BSDGENRAT)
            {
             is_degen = FALSE;
             if((next+1)<=num_spans) next++;
            }
         }
      }
    if(is_degen) msg_loc = BSDGENRAT;
    if(span_cur)
      {
       om$dealloc(ptr = span_cur->poles);
       om$dealloc(ptr = span_cur->knots);
       om$dealloc(ptr = span_cur->weights);
       om$dealloc(ptr = span_cur);
      }
    }

ret_end:
  *msg = msg_loc;
}

end implementation EMSedge;
