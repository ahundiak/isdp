/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include <math.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "madef.h"
#include "gr.h"
#include "go.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emssfint.h"
#include "emsmacros_c.h"
#include "emserr.h"
#include "matypemx.h"
#include "maoptsxfo.h"
#include "maidmx.h"
#include "bssfarrevn.h"
#include "bspt_in_plg.h"
#include "bspartofcv.h"
#include "bscvarrev0.h"
#include "bscv_copy.h"
#include "bsalloccv.h"

#define INSIDE 1

/*
    History

          RC     05/05/88     Creation Date
          RC     03/06/89     cv_org_poles was not being intialized
                              for case num_bdrys = 0.
       	  NP 	 10/05/92     Memory for "in_cv_geom->poles" was overridden by
                              making it point to "tr_cv_poles", a locally 
                              allocated memory, which was later freed in this
			      function. Obviously, BSfreecv() complained in the
			      calling function.Now the poles are COPIED over to
			      "in_cv_geom->poles" using OM_BLOCK_MOVE().
	 SM	 06/29/93     The above fix introduced a bug because the
	                      OM_BLOCK_MOVE was reversed. Fixed it.
         Sudha   07/08/93     Modified for BSprototypes ansification

*/

void EFtrim_cv_to_non_sp_plane (
   in_cv_geom,
   sf_geom,
   bas_tol,
   num_out_cvs,
   out_cvs_geom,
   is_crv_clipped,
   EMmsg)

struct IGRbsp_curve           *in_cv_geom;
struct IGRbsp_surface         *sf_geom;
IGRlong                       *num_out_cvs;
struct IGRbsp_curve           ***out_cvs_geom;
IGRdouble                     bas_tol;
IGRboolean                    *is_crv_clipped;
IGRlong                       *EMmsg;

{
  struct  EMSpypoint  *addatstart, *addatstop, *rematstart, *rematstop,
                      *int_pts, *bdrys_ptr;

  struct IGRbsp_curve wcv, *out_cv_ptr;

  IGRdouble           u, v, sf_org[3], sf_nrml[3], module_mat[4][4],
                      xmat[4][4], invxmat[4][4],  
                      *tr_sf_poles, *tr_cv_poles, *wpoly_pnts, 
                      *wcv_knots, *cv_org_poles,
                      knot_increment, *cpoly_pnts = NULL, beg_par,
                      mid_par, end_par;

  IGRlong             rc, num_poles, num_sf_poles, num_cv_poles;

  IGRint              num_wpoly_pnts, up_left,
                      low_right, up_right, num_cpoly_pnts = 0, i, j, k,
                      num_int_pts, num_bdrys, num_doubles_per_pole;

  IGRshort            modmat_type, xmat_type, invxmat_type;

  IGRboolean          status, in_cv_polyline = TRUE, extract_cvs = FALSE;

extern IGRboolean EM2dpycutint() ;

extern void EMtoplnxform() , EMsortpypts() , 
EMmkpybdrys() ;


  *EMmsg = EMS_S_Success;
  *num_out_cvs = NULL;
  *out_cvs_geom = NULL;

  addatstart = addatstop = rematstart = rematstop = NULL;
  int_pts = NULL;
  num_int_pts = NULL;
  tr_sf_poles = NULL;
  wpoly_pnts = NULL;
  wcv_knots = NULL;
  tr_cv_poles = NULL;
  num_bdrys = NULL;

  cv_org_poles = in_cv_geom->poles;

  /*
   * check if the surface is a non_special plane or not
   */

  if (sf_geom->u_order != 2 || sf_geom->v_order != 2 ||
      sf_geom->rational || !sf_geom->planar)
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }

  /*
   * Evaluate the surface and its normal at a point,
   * say uv = (0,0)
   */

  u = v = 0.;
  BSsfarrevn (&rc, sf_geom, 1, &u, 1, &v, sf_org, sf_nrml);
  EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

  /*
   * Align the surface normal at uv = (0,0) along the model space +z_axis
   * with origin at uv = (0,0)
   */

  status = MAidmx (&rc, &module_mat[0][0]);
  modmat_type = MAIDMX;

  EMtoplnxform (&rc, sf_org, sf_nrml, &modmat_type, module_mat,
                &xmat_type, xmat, &invxmat_type, invxmat, &bas_tol);
  EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

  status = MAtypemx (&rc, &xmat[0][0], &xmat_type);
  EMerr_hndlr (!status || !(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  status = MAtypemx (&rc, &invxmat[0][0], &invxmat_type);
  EMerr_hndlr (!status || !(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  /*
   * Transform the surface poles and the curve poles to the
   * local system
   */

  num_sf_poles = sf_geom->u_num_poles * sf_geom->v_num_poles;

  tr_sf_poles = (IGRdouble *) om$malloc (size = num_sf_poles * 3 *
                                           sizeof(IGRdouble));
  EMerr_hndlr (!tr_sf_poles,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

  status = MAoptsxform (&rc, &num_sf_poles, &xmat_type, &xmat[0][0],
                        sf_geom->poles, tr_sf_poles);
  EMerr_hndlr (!status || !(1&rc),*EMmsg,EMS_E_Fail,wrapup);

  num_cv_poles = in_cv_geom->num_poles;

  tr_cv_poles = (IGRdouble *) om$malloc (size = num_cv_poles * 3 *
                                         sizeof(IGRdouble));
  EMerr_hndlr (!tr_cv_poles,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

  if(in_cv_geom->rational)
    for (i = 0; i < num_cv_poles; i++)
      for (j = 0; j < 3; j++)
        in_cv_geom->poles[3*i+j] /= in_cv_geom->weights[i];

  status = MAoptsxform (&rc, &num_cv_poles, &xmat_type, &xmat[0][0],
                        in_cv_geom->poles, tr_cv_poles);
  EMerr_hndlr (!status || !(1&rc),*EMmsg,EMS_E_Fail,wrapup);

  if (in_cv_geom->rational)
  {
    for (i = 0; i < num_cv_poles; i++)
    {
      for (j = 0; j < 3; j++)
      {
        in_cv_geom->poles[3*i+j] *= in_cv_geom->weights[i];
        tr_cv_poles[3*i+j] *= in_cv_geom->weights[i];
      }
    }
  }

  /*
   * The incoming curve may be of the surface. In such a case, 
   * the tr_poles may have some z-values after transformation.
   * Make these z_values to 0. This will provide, normal
   * projection of the curve on to the surface.
   */

    for (i = 0; i < num_cv_poles; i++)
      tr_cv_poles[3*i+2] = 0;
  
  /*
   * If the incoming curve is a line_string, make poly line
   * corresponding to the natural boundary of the surface.
   * On the other hand, if it is not a line-string, make a curve
   * corresponding to the natural boundary of the surface.
   */

  if (in_cv_geom->order != 2 || in_cv_geom->periodic ||
      in_cv_geom->non_uniform || in_cv_geom->rational)
    in_cv_polyline = FALSE;
  
  if (in_cv_polyline) num_doubles_per_pole = 2;
  else num_doubles_per_pole = 3;

  num_wpoly_pnts = sf_geom->u_num_poles * 2 +
                   (sf_geom->v_num_poles - 2 ) * 2 + 1;

  wpoly_pnts = (IGRdouble *) om$malloc (size = num_wpoly_pnts * 
                          3 * sizeof (IGRdouble));
  EMerr_hndlr (!wpoly_pnts,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

  up_left = sf_geom->u_num_poles * (sf_geom->v_num_poles - 1);
  low_right = sf_geom->u_num_poles - 1;
  up_right = up_left + low_right;

  /*
   * fill EDGEU0
   */

  j = 0;

  for (i = 0; i < up_left; i = i+sf_geom->u_num_poles)
     for (k = 0; k < num_doubles_per_pole; k++, j++)
        wpoly_pnts[j] = tr_sf_poles[3*i+k];

  /*
   * fill EDGEV1
   */

  for (i = up_left; i < up_right; i++)
    for (k = 0; k < num_doubles_per_pole; k++, j++)
      wpoly_pnts[j] = tr_sf_poles[3*i+k];

  /*
   * fill EDGEU1
   */

  for ( i = up_right; i > low_right; i = i-sf_geom->u_num_poles)
    for (k = 0; k < num_doubles_per_pole; k++, j++)
      wpoly_pnts[j] = tr_sf_poles[3*i+k];
  
  /*
   * fill EDGEV0
   */

  for ( i = low_right; i >=0; i--)
    for (k = 0; k < num_doubles_per_pole; k++, j++)
      wpoly_pnts[j] = tr_sf_poles[3*i+k];
   
  if (!in_cv_polyline)
  {
     wcv.order = 2;
     wcv.periodic = FALSE;
     wcv.non_uniform = FALSE;
     wcv.num_poles = num_wpoly_pnts;
     wcv.num_knots = num_wpoly_pnts + 2;
     wcv.rational = FALSE;
     wcv.planar = TRUE;
     wcv.phy_closed = TRUE;
     wcv.num_boundaries = 0;

     wcv.poles = wpoly_pnts;

     wcv_knots = (IGRdouble *) om$malloc (size = wcv.num_knots *
                                           sizeof(IGRdouble));
     EMerr_hndlr (!wcv_knots,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

     wcv.knots = wcv_knots;
     wcv.knots[0] = wcv.knots[1] = 0.;
     wcv.knots[wcv.num_poles] = wcv.knots[wcv.num_poles+1] = 1.0;

     knot_increment = 1.0 / (wcv.num_poles - 1);

     for ( i = 2; i < wcv.num_poles; i++)
       wcv.knots[i] = wcv.knots[i-1] + knot_increment;

     wcv.weights = NULL;
     wcv.bdrys = NULL;

  } /* if (!in_cv_polyline) */

  /*
   * If the incoming curve is line-string, convert it into a polyline
   * format.
   */

  if (in_cv_polyline)
  {
    cpoly_pnts = tr_cv_poles;
    num_cpoly_pnts = num_cv_poles;

    /*
     * Make it 2-D polyline
     */

    k = 2;
    for (i = 1; i < num_cpoly_pnts; i++)
       for (j = 0; j < 2; k++, j++)
         cpoly_pnts[k] = cpoly_pnts[3*i+j];
 
  } /* if (in_cv_polyline) */

  else
  {
     /*
      * replace the curve poles by its transformed poles
      */

     OM_BLOCK_MOVE (tr_cv_poles, in_cv_geom->poles,
                 (sizeof(IGRdouble)*3*num_cv_poles)) ;

  } /* else for if (in_cv_polyline) */

  /*
   * trim the incoming curve against the natural boundary
   * of the surface.
   */

  if (in_cv_polyline)
  {
    IGRushort wprops, options;

    wprops = NULL;
    options = EMS_INTER_CUTTING | EMS_INTER_ONEOFTWO;
    status = EM2dpycutint (&rc, num_wpoly_pnts, wpoly_pnts, wprops, NULL, 
                           num_cpoly_pnts, cpoly_pnts, NULL, options, 
                           bas_tol, NULL, NULL, NULL_OBJID, NULL, 
                           &num_int_pts, NULL, &int_pts);

    EMerr_hndlr (!(1&rc), *EMmsg,EMS_E_Fail, wrapup);

  } /* if (in_cv_polyline) */

  else
  {
    IGRushort options;

    options = EMS_INTER_CUTTING | EMS_INTER_ONEOFTWO;
    status = EMtrim_bspline_against_bspline (&rc, options, in_cv_geom, 
               &wcv, bas_tol, NULL, NULL, FALSE, NULL, NULL, NULL, 
               &num_int_pts, NULL, &int_pts);
    EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
 
  } /* else for if (in_cv_polyline) */

  /*
   * If there are no intersections reuturned, the incoming
   * curve may be totally in area or in whole.
   */

  if (!num_int_pts)
  {
    struct IGRpolyline  wpoly_line;
    IGRdouble           beg_pt[3];
    IGRboolean          pos_orient = FALSE;    
    IGRint              location_ind;

    wpoly_line.num_points = num_wpoly_pnts;
    wpoly_line.points = wpoly_pnts;

    if (in_cv_polyline)
    {
      for (i = 0; i < 2; i++)
       beg_pt[i] = cpoly_pnts[i];
      beg_pt[2] = 0;
    }
    else
    {
      beg_par = 0;
      BScvarrev0 (&rc, in_cv_geom, &beg_par, 1, beg_pt);
      EMerr_hndlr (BSERROR(rc), *EMmsg,EMS_E_BSerror,wrapup);
    }

    /*
     * If the incoming curve is a polyline, wpoly has the 2-D
     * points. Convert them to 3_D points
     */

    if (in_cv_polyline)
    {
      for ( i = num_wpoly_pnts -1; i >= 0; i--)
      {
        wpoly_pnts[3*i+2] = 0.;
        wpoly_pnts[3*i+1] = wpoly_pnts[2*i+1];
        wpoly_pnts[3*i] = wpoly_pnts[2*i];

      } /* for ( i = num_wpoly_pnts -1; i >= 0; i--) */

    } /* if (in_cv_polyline) */

    BSpt_in_plg (wpoly_line, beg_pt, TRUE, &pos_orient, &location_ind,
                 &rc);
    EMerr_hndlr (BSERROR(rc), *EMmsg,EMS_E_BSerror,wrapup);

    if (location_ind == INSIDE)
    {
      *num_out_cvs = 1;
      extract_cvs = FALSE;
      num_bdrys = 1;
    }

  } /* if (!num_int_pts) */

  else
  {
    struct EMSdataselect    indata;
    struct IGRpolyline      cpoly_line;

     /*
      * sort the intersection points in the ascending order of
      * parameterization
      */

     EMsortpypts (&rc, &int_pts, (in_cv_polyline ? 2: 3), NULL, &bas_tol);
     EMerr_hndlr (!(1&rc), *EMmsg,EMS_E_Fail,wrapup);
      
     /*
      * Make the boundaries corresponding to the above
      * sorted intersection points. If the end points of the
      * incoming geometry is in area, add intersection pts
      */
      
     if (in_cv_polyline)
     {
       indata.datatype = EMSdata_poly2d;
       indata.data.poly = &cpoly_line;
       cpoly_line.num_points = num_cpoly_pnts;
       cpoly_line.points = cpoly_pnts;
     }
     else
     {
       indata.datatype = EMSdata_curve3d;
       indata.data.curve = in_cv_geom;
     }

     EMmkpybdrys (&rc, &indata, &int_pts, &num_bdrys, &addatstart,
                  &addatstop, &rematstart, &rematstop);
     EMerr_hndlr (!num_bdrys || rematstart || rematstop, *EMmsg, 
                  EMS_E_Intersect, wrapup);
     EMerr_hndlr (!(1&rc),*EMmsg,rc,wrapup);

     extract_cvs = TRUE;
     *num_out_cvs = num_bdrys;

  } /* else for if (!num_int_pts) */

  
  /*
   * Now, the boundaries on the incoming geometry corresponding
   * to the area region of the surface are available. Extract these
   * portions.
   */


  if (num_bdrys)
  {

    /*
     * the incoming curve will be used for 
     * extraction of partial curves. Put its poles in the
     * local coordinate system if poly_line_poly_line trimming
     * was performed.
     */

    if (in_cv_polyline)
    {
      for (i = in_cv_geom->num_poles - 1; i >= 0; i--)
      {
        tr_cv_poles[3*i+2] = 0;
        tr_cv_poles[3*i+1] = tr_cv_poles[2*i+1];
        tr_cv_poles[3*i] = tr_cv_poles[2*i];
      }

      in_cv_geom->poles = tr_cv_poles;

    } /* if (in_cv_polyline) */

    *out_cvs_geom = (struct IGRbsp_curve **) om$malloc (size = num_bdrys *
                        sizeof(struct IGRbsp_curve *));
    EMerr_hndlr (!(*out_cvs_geom),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

    if (num_bdrys == 1 && !extract_cvs)
    {
      BSalloccv (in_cv_geom->order, in_cv_geom->num_poles, 
                 in_cv_geom->rational, 0, *out_cvs_geom, &rc);
      EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

      status = BScv_copy (&rc, in_cv_geom, **out_cvs_geom);
      EMerr_hndlr (!status || BSERROR(rc), *EMmsg, EMS_E_BSerror,wrapup);

    } /* if (num_bdrys == 1 && !extract_cvs) */

    else
    {
      num_poles = in_cv_geom->num_poles + 2 * in_cv_geom->order - 1;
      bdrys_ptr = int_pts;

      for (i = 0; i < num_bdrys; i++)
      {
        BSalloccv(in_cv_geom->order, num_poles, in_cv_geom->rational, 0,
                  &(*out_cvs_geom)[i], &rc);
        EMerr_hndlr (BSERROR(rc),*EMmsg,EMS_E_BSerror,wrapup);

        beg_par = bdrys_ptr[0].param;
        end_par = bdrys_ptr[0].next[0].param;

        if (in_cv_polyline)
        {
           IGRdouble beg_knot, end_knot;
           IGRlong    span_inx;

           span_inx = bdrys_ptr[0].span_inx;
           beg_knot = in_cv_geom->knots[span_inx + 1];
           end_knot = in_cv_geom->knots[span_inx + 2];
           beg_par = beg_knot + beg_par * (end_knot - beg_knot);

           span_inx = bdrys_ptr[0].next[0].span_inx;
           beg_knot = in_cv_geom->knots[span_inx + 1];
           end_knot = in_cv_geom->knots[span_inx + 2];
           end_par = beg_knot + end_par * (end_knot - beg_knot);

        }
        
        if (in_cv_geom->phy_closed)
          mid_par = (beg_par < end_par) ? ((beg_par + end_par)/2.) : 0.;
        else mid_par = 0;
  
        status = BSpartofcv (&rc, in_cv_geom, beg_par, mid_par, end_par,
                             (*out_cvs_geom)[i] );
        EMerr_hndlr (!status || BSERROR(rc),*EMmsg,EMS_E_BSerror,wrapup);

        bdrys_ptr = bdrys_ptr->next->next;

      } /* for (i = 0; i < num_bdrys; i++) */
                
    } /* else for if (num_bdrys == 1 && !extract_cvs) */

    /*
     * The portions of the incoming geometry have been extracted.
     * They correspond to the local coordinate system. Bring them
     * back to world coordinate system.
     */

    if ( invxmat_type != MAIDMX)
    {
       for (i = 0; i < num_bdrys; i++)
       {
         out_cv_ptr = (*out_cvs_geom)[i]; 

         if (out_cv_ptr->rational)
          for (j = 0; j < out_cv_ptr->num_poles; j++)
            for (k = 0; k < 3; k++)
              out_cv_ptr->poles[3*j+k] /= out_cv_ptr->weights[j];

         status = MAoptsxform (&rc, &out_cv_ptr->num_poles, &invxmat_type,
                     &invxmat[0][0], out_cv_ptr->poles, out_cv_ptr->poles);
         EMerr_hndlr (!status || !(1&rc),*EMmsg,EMS_E_Fail,wrapup);

         if (out_cv_ptr->rational)
          for (j = 0; j < out_cv_ptr->num_poles; j++)
           for (k = 0; k < 3; k++)
             out_cv_ptr->poles[3*j+k] *= out_cv_ptr->weights[j];

       } /* for (i = 0; i < num_bdrys; i++) */

    } /* if ( invxmat_type != MAIDMX) */

  } /* if (num_bdrys) */

  /*
   * put back the original curve poles
   */

  in_cv_geom->poles = cv_org_poles;
  

wrapup:

*is_crv_clipped = extract_cvs ? TRUE : FALSE;

if (int_pts) EMpypoint_free (int_pts, MAXINT);
if (tr_sf_poles) om$dealloc (ptr = tr_sf_poles);
if (wpoly_pnts) om$dealloc (ptr = wpoly_pnts);
if (wcv_knots) om$dealloc (ptr = wcv_knots);
if (tr_cv_poles) om$dealloc (ptr = tr_cv_poles);

return;

} /* end EFtrim_cv_to_non_sp_plane */
