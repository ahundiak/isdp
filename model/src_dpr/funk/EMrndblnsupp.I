/*
  DESCRIPTION

    This file containes support functions for the general blend solution
    in EMrndgenbln.I.
*/

class implementation EMSsfrndbool;

#include <math.h>

#include "maerr.h"
#include "madef.h"
#include "bsparameters.h"
#include "bserr.h"
#include "bsgeom_cvsf.h"
#include "bstypes.h"
#include "bscvcvint.h"
#include "bsconstprcv.h"
#include "bsprptonsf.h"
#include "bscveval.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bssfarrevn.h"
#include "bsmdistptsf.h"
#include "bsiarcln.h"
#include "bssfarrev1.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bschgdeppar.h"
#include "bschangepar.h"
#include "bsrev_cv.h"
#include "bsblndcvosf.h"
#include "bsblncvosf2.h"
#include "OMmacros.h"
#include "emssfintdef.h"
#include "emsinter.h"
#include "emsinterdef.h"
#include "EMSrnd.h"
/*
#include "EMSrndprotyp.h"
*/

from EMSboundary import EMgetsurface_info;
from EMSedge    import  EMget_edge_length, EMget_bcxyz_geom,
                        EMptproject, EMget_props,
                        EMendpts, EMxyz_endpt;
from EMSloopset	import	EMlsparttrim;

#define	FIRST	0
#define	SECOND	1

#define U	0
#define	V	1

#define U0	0
#define	V1	1
#define U1	2
#define V0	3

#define CONST_U	1
#define CONST_V	2

#define RND_ED  	0
#define RND_COM_ED 	1

#define FILLET_U0	0
#define FILLET_U1	1

#define PARAM_V0	0.0
#define PARAM_V1	1.0

#define REAL_VALUE_ACCURACY	0.0001
#define DELTA_V			0.001

#define SETBACK_FRACTION_1	0.1
#define SETBACK_FRACTION_2	0.4
#define SETBACK_FRACTION_3	0.2

#define UPPER_ANG_BOUND		PI*25.0/180.0
#define LIMITING_INC_ANG  PI/180.0*15.0

#define MAX_TO_STACK_ALLOC	8

typedef IGRdouble point2d[2];


/*
  DESCRIPTION

  Given two neighboring edges such that one has a fillet, and the other may
  or may not have a fillet, this function determine,

  . if both edges have fillets.
    Determine whether the appropriate iso edges of the two fillets intersect.

  . One edge has a fillet, and the other does not, determine whether the
    appropriate iso edge of the fillet (u0 or u1) intersects the edge that
    has no fillet.

  . Return the intersection information if any.

  ARGUMENTS

    ed1_with_fillet   - Input  : If the edge is rounded, edge information,
                                 else NULL.
    ed2_with_fillet   - Input  : If the edge is rounded, edge information,
                                 else NULL.

    ed_bln_info       - Input/Output : Set back point information.

    found             - Output : If an intersection was found then TRUE, else
                                  FALSE
    All memory must be managed by the caller.

  HISTORY:
    Janaka : 05/13/93 : Original.
    KNAP   : 20 Sep'94: Re-write. The intersections are now computed in
                        UV-space.
*/
#argsused

IGRlong  EMget_ed1_ed2_int_info (IGRlong *EMmsg, IGRushort options,
           struct GRmd_env                *md_env,
           struct EMSedge_rnd_info        *ed1_with_fillet,
           struct EMSedge_rnd_info        *ed2_with_fillet,
           IGRboolean                     *found,
           struct EMSedge_blend_info      **ed_bln_info)
{
  IGRboolean    loc_found, fillet_fillet_case;
  IGRint        i, fill_inx, edge_inx;
  IGRlong	stat, msg_loc;
  IGRdouble	edge_par, f_par[2][2], cht_tol;
  IGRpoint      int_point, other_end_pt, beg_xyz_pt, end_xyz_pt;
  GRspacenum    os;
  struct EMSedge_rnd_info  *ed_infos[2];
  extern IGRdouble EMget_fillet_int_data();

  stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  loc_found = FALSE;
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);
  os = md_env->md_id.osnum;
 
  ed_infos[FIRST]  = ed1_with_fillet;
  ed_infos[SECOND] = ed2_with_fillet;

  EMerr_hndlr (!ed_infos[FIRST] && !ed_infos[SECOND], *EMmsg, EMS_E_InvalidArg,
               wrapup);

  if (ed_infos[FIRST] && ed_infos[SECOND])
    fillet_fillet_case = TRUE;
  else
    fillet_fillet_case = FALSE;

  /*
   * Get the included data between the two interacting fillets.
   * This includes the intersection point of the two respective iso's
   * on the included surface.
   */

  if (fillet_fillet_case)
    {
    EMget_rnd_included_data (&msg_loc, ed_infos[FIRST], ed_infos[SECOND],
      ed_bln_info[FIRST]->rnd_end_vtx[FIRST], NULL, NULL, NULL, f_par, NULL,
      int_point);
    EMerr_hndlr ((EMSerror(msg_loc)), *EMmsg, EMS_E_NoIntersection, wrapup);
    }
  else
    {
    /*
     * Get the intersection between the fillet and the edge with which
     * the fillet is interacting.
     */

    fill_inx = ed_infos[FIRST] ? FIRST : SECOND;
    edge_inx = ed_infos[FIRST] ? SECOND : FIRST;
    f_par[fill_inx][V] = EMget_fillet_int_data (&msg_loc, ed_infos[fill_inx], 
                           ed_bln_info[edge_inx]->ed_ids[edge_inx], os,
                           ed_bln_info[edge_inx]->rnd_end_stop[edge_inx],
                           NULL, NULL, NULL, &edge_par, int_point);
    EMerr_hndlr ((EMSerror(msg_loc)), *EMmsg, msg_loc, wrapup);
    }

  /*
   * The following piece of code is weed out such intersections
   * which occur at the non-vertex end of the edge. viz.. the
   * iso's intersect at the non-vertex end.  Theoritically, the iso-iso
   * intersections will be neighbouring the round vertex.
   * Such situations arise when two cylinders are unioned. Treat such 
   * intersections as invalid. --  KNAP
   */

  if (fillet_fillet_case)
    {
    OM_BLOCK_MOVE (ed_infos[FIRST]->start_vtx->vtx_pt, beg_xyz_pt,
                   sizeof (IGRpoint));
    OM_BLOCK_MOVE (ed_infos[FIRST]->stop_vtx->vtx_pt, end_xyz_pt,
                   sizeof (IGRpoint));
    if (EMis_geomequal_3dpt (beg_xyz_pt, ed_bln_info[FIRST]->rnd_end_vtx[FIRST],
                             2 * cht_tol))
      OM_BLOCK_MOVE (end_xyz_pt, other_end_pt, sizeof(IGRpoint));
    else
      OM_BLOCK_MOVE (beg_xyz_pt, other_end_pt, sizeof(IGRpoint));
    EMerr_hndlr (EMis_geomequal_3dpt (int_point, other_end_pt, 2*cht_tol),
                 *EMmsg, EMS_E_OutOfBounds, wrapup);
    }
  loc_found = TRUE;

  for (i=FIRST; i<=SECOND; i++)
    {
    OM_BLOCK_MOVE (int_point, ed_bln_info[i]->setback_pts_xyz[i],
                   sizeof(IGRpoint));
    if (ed_infos[i])
      {
      ed_bln_info[i]->setback_pts_uv[i][U] = ed_bln_info[i]->fillet_int_iso[i];
      ed_bln_info[i]->setback_pts_uv[i][V] = f_par[i][V];
      }
    else
        ed_bln_info[i]->setback_pts_uv[i][U] = edge_par;
    }

wrapup:
  *found = loc_found;
  EMWRAPUP (*EMmsg, stat, "EMget_ed1_ed2_int_info");
  return (stat);
}


/*
  DESCRIPTION

    Given a fillet, the edge on which the fillet is on, and a set back
    distance along the edge (relative to round vertex), determine the two
    end points at the end of the fillet iso at that set back distance along
    the edge.

  ARGUMENTS

    ed_info        - Input        : Edge round information.
    ed_bln_info    - Input/Output : Set back points for the fillet isos.


  ALGORITHM
    Determine an xyz point at a distance of setback_dist along the edge.
    Project that point onto the fillet (this will definitely yeild a unique
    point on fillet).  The required points are those at the two ends of the
    fillet iso at the set back point.

  HISTORY
    Janaka : 05-14-93 : Original.
    KNAP   : 20 Sep'94: Re-write, cleaned up the code.
*/

#argsused

IGRlong EMget_setback_pts_on_fillet_along_ed (IGRlong *EMmsg,
                 IGRushort                      options,
                 struct GRmd_env                *md_env,
                 struct EMSedge_rnd_info        *ed_info,
                 struct EMSedge_blend_info      *ed_bln_info)
{
  IGRlong        msg_loc, stat;
  IGRdouble      min_dist, normals[6], u_params[2], v_param, min_param,
                 max_param, from_param, dir_param, param_at_def_dist;
  IGRpoint       setback_pt_on_ed, pts_xyz[2];
  GRspacenum     os;

  struct GRmdenv_info   *mdenv_info;
  struct IGRbsp_surface *fill_surf;
  struct IGRbsp_curve   ed_geom;

  *EMmsg = EMS_S_Success;
  stat = OM_S_SUCCESS;
  mdenv_info = &md_env->md_env;
  os = md_env->md_id.osnum;
  ed_geom.poles = NULL;
  ed_geom.knots = NULL;
  ed_geom.weights = NULL;
 
  fill_surf = ed_info->fill_surf;
 
  /*
   * Determine the xyz point that is a distance of default set back
   * distance along the logical edge.
   * Project that point onto fillet surface. Let the point on the fillet be p1.
   * Determine the two end points of the v-constant fillet iso at p1 as the 
   * required points.
   */

  stat = om$send (msg = message EMSedge.EMget_bcxyz_geom
                                (&msg_loc, &md_env->md_env, NULL, NULL,
                                (IGRint) 0, MAXINT, FALSE, NULL, &ed_geom),
 		        senderid = NULL_OBJID,
		        targetid = ed_bln_info->ed_ids[FIRST],
                        targetos = os);
  EMerr_hndlr (!(msg_loc & stat & 1), *EMmsg, EMS_E_EdgeError, wrapup);

  min_param = ed_geom.knots[ed_geom.order-1];
  max_param = ed_geom.knots[ed_geom.num_poles];
  from_param = ed_bln_info->rnd_end_stop[FIRST] == TRUE ? max_param : min_param;
  dir_param = ed_bln_info->rnd_end_stop[FIRST] == TRUE ? min_param : max_param;

  BSiarcln (&msg_loc, &ed_geom, &from_param, &ed_bln_info->default_setback,
            &dir_param, &param_at_def_dist);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  BScveval (&ed_geom, param_at_def_dist, (IGRint)0, &setback_pt_on_ed, 
            &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  BSmdistptsf (&msg_loc, fill_surf, setback_pt_on_ed, &u_params[0], &v_param, 
               pts_xyz[1], &min_dist);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  /*
   * Evaluate the two xyz points on the fillet at (0.0, v_param),
   * (1.0, v_param).
   */
  u_params[0] = 0.0;
  u_params[1] = 1.0;
  BSsfarrevn (&msg_loc, fill_surf, (IGRint)2, u_params, (IGRint)1, &v_param,
              &pts_xyz[0][0], normals);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  /*
   * Format the output. Here, FIRST refers to iso that is in the cyclic
   * order defined by vertex edges, and SECOND to the other.
   */
  if (ed_bln_info->FIRST_is_dominant)
    {
    ed_bln_info->setback_pts_uv[FIRST][U] = 0.0;
    ed_bln_info->setback_pts_uv[SECOND][U] = 1.0;
    ed_bln_info->fillet_int_iso[FIRST] = FILLET_U0;
    ed_bln_info->fillet_int_iso[SECOND] = FILLET_U1;
    OM_BLOCK_MOVE (pts_xyz, ed_bln_info->setback_pts_xyz, 2*sizeof(IGRpoint));
    }
  else
    {
    ed_bln_info->setback_pts_uv[FIRST][U] = 1.0;
    ed_bln_info->setback_pts_uv[SECOND][U] = 0.0;
    ed_bln_info->fillet_int_iso[FIRST] = FILLET_U1;
    ed_bln_info->fillet_int_iso[SECOND] = FILLET_U0;
    OM_BLOCK_MOVE (pts_xyz[SECOND], ed_bln_info->setback_pts_xyz[FIRST],
                   sizeof (IGRpoint));      
    OM_BLOCK_MOVE (pts_xyz[FIRST], ed_bln_info->setback_pts_xyz[SECOND],
                     sizeof (IGRpoint));
    }

  ed_bln_info->setback_pts_uv[FIRST][V] =
  ed_bln_info->setback_pts_uv[SECOND][V] = v_param;
  ed_bln_info->setback_pt_stat[FIRST] =
  ed_bln_info->setback_pt_stat[SECOND] = setback_pt_defined;
  ed_bln_info->blend_cv_type = blend_curve_iso;

wrapup:
  if (ed_geom.poles)     om$dealloc (ptr = ed_geom.poles);
  if (ed_geom.knots)     om$dealloc (ptr = ed_geom.knots);
  if (ed_geom.weights)   om$dealloc (ptr = ed_geom.weights);
 
  EMWRAPUP (*EMmsg, stat, "EMget_setback_pts_on_fillet_along_ed");
  return (stat);
}

/*
  DESCRIPTION

    Given information on a fillet (that is on some edge), a reference point,
    and a v-value on the fillet that corresponds to a setback point on the
    fillet, determine whether that setback point is legal.

  ARGUMENTS

    ed_info   - Input : Fillet information
    ref_pt    - Input : The reference point with respect to which the legality 
                        of v_value is determined.
    is_stop   - Input : The logical placement of the edge end point w.r.t. 
                        'ref_pt'.
    v_value   - Input : The v value on fillet representing some setback point.

    is_legal  - Output: TRUE if 'v_value' is acceptable, else FALSE.

  ALGORITHM
    Project 'ref_pt' onto the fillet.  If the projected point is further
    inside the fillet than the the point indicated by 'v_value' then
    'v_value' is unacceptable.  Else 'v_value' is valid.

  HISTORY
    Janaka : 05-18/93 : Original.
    KNAP   : 20 Sep'94: Re-write, cleaned up the code.
*/

#argsused

IGRlong EMvalidate_int (IGRlong *EMmsg, IGRushort options,
               struct EMSedge_rnd_info *ed_info,
               IGRpoint ref_pt,
               IGRboolean is_stop,
               IGRdouble v_value,
               IGRboolean *is_legal)
{
  IGRboolean    loc_is_legal;
  IGRlong       msg_loc, stat;
  IGRint        processing_stop_end;
  IGRdouble     params[2], min_dist, bas_tol;
  IGRpoint      dum_pt;
  struct IGRbsp_surface *fill_surf;

  stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bas_tol);

  fill_surf = ed_info->fill_surf;
  processing_stop_end = is_stop == TRUE ? 1 : 0;
  loc_is_legal = TRUE;

  /*
   * Project 'ref_pt' onto fillet and obtain the projected points v_value
   * on the fillet (the projection should accommodate possibly a v-closed
   * fillet).  Compare v(projected point ) with that of 'v_value' to determine
   * whether latter is legal.
   */
  BSmdistptsf (&msg_loc, fill_surf, ref_pt, &params[U], &params[V],
               dum_pt, &min_dist);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

  /*
   * Correction for possibly v-closed fillet.  Here, a projected point
   * that lies within a tolerance band of 2*DELTA_V (where the tolerance
   * band is centered about V0/V1 of fillet) is considered to be on either
   * V0 or V1.
   */
  if (fill_surf->v_phy_closed == TRUE)
    if (params[V] < DELTA_V || ( 1.0 /* V1 */ - params[V] ) < DELTA_V)
      if ((ed_info->props & EMSfillet_v0_closeto_start_end ? 1 : 0)
           ^ processing_stop_end)
        params[V] = 0.0;
      else
        params[V] = 1.0;

  if ((ed_info->props & EMSfillet_v0_closeto_start_end ? 1 : 0)
       ^ processing_stop_end)
    {
    /* 
     * V0 is close to the processing end of round edge.
     */
    if (fabs (v_value - params[V]) < bas_tol)
      loc_is_legal = FALSE;
    else if (v_value < params[V])
      loc_is_legal = FALSE;
    }
  else 
    {
    /*
     * V1 is close to the processing end of round edge.
     */
    if (fabs (v_value - params[V]) < bas_tol)
      loc_is_legal = FALSE;
    else if( v_value > params[V] )
      loc_is_legal = FALSE;
    }

  *is_legal = loc_is_legal;
     
wrapup:
  EMWRAPUP (*EMmsg, stat, "validate_int");
  return (stat);
}

/* 
  DESCRIPTION

    Given an edge with possibly, zero, one, or two set back points, determine
    the final set back point on that edge.

  ARGUMENTS

    ed_blend_info    - Input/Output : Pre-determined set back point information
                       on the edge, which might require adjustment.

  ALGORITHM

    In case there exists two setback points, pick the one that is
    furthest from the round vertex. If there is only one, then pick that
    one.  Let that point be p1.  Let d1 be the edge length from the round
    vertex to point p1.  Let d2 be the edge length from p1 to the other end
    of the edge.  Then, the set back distance from point p1 is:
    SETBACK_FRACTION_2 * [smaller of( d1. d2 )].

    In case there were no pre-determined set back points, then determine
    the final set back point as a point along the edge, at a distance of
    default set back from the round vertex.

  HISTORY
    Janaka : 05-23-93 : Original.
    KNAP   : 20 Sep'94: Re-write, cleaned up the function.
             27 Dec'94: Added code for usage of extracted iso as
                        blend curve.
*/

#argsused

IGRlong EMfix_setback_on_edge (IGRlong *EMmsg,
                 struct GRmd_env                *md_env,
                 struct EMSedge_blend_info      *ed_bln_info)
{
  IGRlong       msg_loc, stat;
  IGRint        i, inx;
  IGRdouble     setback_dist, other_dist, dist_along_ed[2], min_dist,
                eds_end_param[2], eds_other_end_param[2], u_params[2];
  IGRpoint      pt_xyz[2], dum_pt;
  GRspacenum    os;
  struct IGRbsp_curve   ed_geom[2];

  *EMmsg = EMS_S_Success;
  stat = OM_S_SUCCESS;
  os = md_env->md_id.osnum;

  for (i=FIRST; i<=SECOND; i++)
    {
    ed_geom[i].poles = NULL;
    ed_geom[i].knots = NULL;
    ed_geom[i].weights = NULL;
    }

 if ((ed_bln_info->bln_cv_props[FIRST] &
       EMSrnd_bln_trans_cv_extracted_iso_curve) ||
     (ed_bln_info->bln_cv_props[SECOND] &
       EMSrnd_bln_trans_cv_extracted_iso_curve))
   {
   if (ed_bln_info->setback_pt_stat[FIRST] == setback_pt_defined)
     inx = FIRST;
   else if (ed_bln_info->setback_pt_stat[SECOND] ==setback_pt_defined)
     inx = SECOND;
   else
     inx = UNDEFINED;

   if (inx != UNDEFINED)
     {
     for( i = FIRST; i <= SECOND; i++ )
       {
       stat = om$send( msg = message EMSedge.EMget_bcxyz_geom
                                 ( &msg_loc, &md_env->md_env, NULL, NULL,
                         ( IGRint ) 0, MAXINT, FALSE, NULL, &ed_geom[i] ),
                         senderid = NULL_OBJID,
                         targetid = ed_bln_info->ed_ids[i],
                         targetos = os );
       EMerr_hndlr( !( msg_loc & stat & 1 ), *EMmsg, EMS_E_EdgeError, wrapup );
       BSmdstptcv (&ed_geom[i], ed_bln_info->setback_pts_xyz[inx],
                   &ed_bln_info->setback_pts_uv[i][U], dum_pt, &min_dist, 
                   &msg_loc);
       EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
       if (i !=inx)
         OM_BLOCK_MOVE (ed_bln_info->setback_pts_xyz[inx],
                        ed_bln_info->setback_pts_xyz[i], sizeof (IGRpoint));
       }
     ed_bln_info->setback_pt_stat[FIRST] =
       ed_bln_info->setback_pt_stat[SECOND] = setback_pt_defined;
     goto wrapup;
     }
   }

  /*
   * Determine the correct edge end parameters at the round vertex.
   */
  for (i=FIRST; i<=SECOND; i++)
    {
    eds_end_param[i] = 0.0;
    eds_other_end_param[i] = 1.0;
    if (ed_bln_info->rnd_end_stop[i] == TRUE)
      {
      eds_end_param[i] = 1.0;
      eds_other_end_param[i] = 0.0;
      }
    }
 
  setback_dist = ed_bln_info->default_setback;

  /* 
   * Modify the set back distance based on pre-determined set back
   * point values (if available).
   */
  inx = UNDEFINED;
  for (i=FIRST; i<=SECOND; i++)
    {
    dist_along_ed[i] = 0.0;
    if (ed_bln_info->setback_pt_stat[i] == setback_pt_defined)
      {
      stat = om$send (msg = message EMSedge.EMget_edge_length (&msg_loc,
                                    (IGRushort)0, &md_env->md_env,
                                    &eds_end_param[i],
                                    &ed_bln_info->setback_pts_uv[i][U],
                                    NULL, &dist_along_ed[i] ),
                            senderid = NULL_OBJID,
                            targetid = ed_bln_info->ed_ids[i],
                            targetos = os);
      EMerr_hndlr (!( 1 & stat & msg_loc ), *EMmsg, EMS_E_EdgeError, wrapup);
      inx = i;
      if (i==SECOND) /* Both distances were calculated */ 
       if (dist_along_ed[FIRST] > dist_along_ed[SECOND])
         inx = FIRST;
      }
    }

    if (inx != UNDEFINED)
      {
      /*
       * There was at least one pre-defined set back point. Use it to find
       * the new set back point along the edge.
       */
      other_dist = 0.0;
      stat = om$send (msg = message EMSedge.EMget_edge_length( &msg_loc,
                                    (IGRushort)0, &md_env->md_env,
                                    &ed_bln_info->setback_pts_uv[inx][U],
                                    &eds_other_end_param[inx],
                                    NULL, &other_dist),
                            senderid = NULL_OBJID,
                            targetos = os,
                            targetid = ed_bln_info->ed_ids[inx]);
      EMerr_hndlr (!(1 & stat &msg_loc ), *EMmsg, EMS_E_EdgeError, wrapup);

      setback_dist = dist_along_ed[inx] + dist_along_ed[inx]*
                                           SETBACK_FRACTION_2;
      if (other_dist < dist_along_ed[inx])
        setback_dist = dist_along_ed[inx] + other_dist * SETBACK_FRACTION_2;
      }

    /* 
     * Determine the final set back point along the edge, using the setback 
     * distance.
     */
    for (i=FIRST; i<=SECOND; i++)
      {
      stat = om$send (msg = message EMSedge.EMget_bcxyz_geom
                                    (&msg_loc, &md_env->md_env, NULL, NULL,
		                    (IGRint)0, MAXINT, FALSE, NULL,
                                    &ed_geom[i]),
 	                    senderid = NULL_OBJID,
	                    targetid = ed_bln_info->ed_ids[i],
                            targetos = os);
      EMerr_hndlr (!(msg_loc & stat & 1), *EMmsg, EMS_E_EdgeError, wrapup);

      BSiarcln (&msg_loc, &ed_geom[i], &eds_end_param[i], &setback_dist,
                &eds_other_end_param[i], &u_params[i]);
      EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      BScveval (&ed_geom[i], u_params[i], ( IGRint ) 0, &pt_xyz[i], &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
      }

    for (i=FIRST; i<=SECOND; i++)
      {
      ed_bln_info->setback_pts_uv[i][U] = u_params[i]; 
      OM_BLOCK_MOVE (pt_xyz[i], ed_bln_info->setback_pts_xyz[i],
                     sizeof (IGRpoint));
      }
    ed_bln_info->setback_pt_stat[FIRST] =
    ed_bln_info->setback_pt_stat[SECOND] = setback_pt_defined;

wrapup:

  for (i=FIRST; i<=SECOND; i++)
    {
    if (ed_geom[i].poles)   om$dealloc (ptr = ed_geom[i].poles);
    if (ed_geom[i].knots)   om$dealloc (ptr = ed_geom[i].knots);
    if (ed_geom[i].weights) om$dealloc (ptr = ed_geom[i].weights);
    }
  EMWRAPUP (*EMmsg, stat, "EMfix_setback_on_edge");
  return (stat);
}

/*
  DESCRIPTION

    Given an edge fillet with zero, one, or two setback points, finalize
    the set back points.

  ARGUMENTS
    ed_rnd_infos      - Input : Edge round information for the entire round 
                                vertex.
    setback_infos     - Input/Output : Setback information for the fillet.
    ed_inx            - Input : Index into the processing member, in above
                                arrays.
    vtx_rnd_info      - Input : Vertex round information.

  ALGORITHM
    If zero set back points are on it, generate a pair by simply stepping
    back a distance of default set back along the current edge.
    If only a single set back point is present, construct another at the end
    of the v-constant iso edge derived at that single point.

  HISTORY:
    Janaka : 05-25-93 : Original.
    KNAP   : 20 Sep'94: Re-write.
*/

#argsused

IGRlong EMfix_setback_on_fillet (EMmsg, md_env, ed_rnd_infos, setback_infos,
                                 vtx_rnd_info, ed_inx, def_setback)
IGRlong                   *EMmsg;
struct GRmd_env           *md_env;
struct EMSedge_rnd_info   **ed_rnd_infos;
struct EMSedge_blend_info *setback_infos;
struct EMSvtx_rnd_info    *vtx_rnd_info;
IGRint                    ed_inx;
IGRdouble                 def_setback;
{
  IGRlong	msg_loc, stat;
  IGRint	def_inx, undef_inx;
  IGRdouble     v1, v2, vpar, mdist, tpar;
  IGRpoint      dumpt;
 
  struct EMSedge_rnd_info	*ed_rnd_info;
  struct EMSedge_blend_info	*setback_info;
  struct IGRbsp_curve           *isocv = NULL;
 
  *EMmsg = EMS_S_Success;
  stat = OM_S_SUCCESS;
  ed_rnd_info = ed_rnd_infos[ed_inx];
  setback_info = &setback_infos[ed_inx];
 
  /* 
   * The processing depends on the number of pre-determined set back
   * points.
   */

  if (setback_info->setback_pt_stat[FIRST] == setback_pt_defined &&
      setback_info->setback_pt_stat[SECOND] == setback_pt_defined)
    {
    /*
     * Refine the set back point on the iso curve going to round vertex,
     * to avoid improper infinite plane intersection on the fillet.
     * Such situations can occur when the the two set back points are
     * far apart in model space, as in the case of a fillet which has a
     * large bend.
     */
 
    v1 = setback_info->setback_pts_uv[FIRST][V];
    v2 = setback_info->setback_pts_uv[SECOND][V];
 
    if (setback_info->bln_cv_props[FIRST] & EMSrnd_bln_trans_cv_to_rnd_vtx)
      {
      setback_info->setback_pts_uv[FIRST][V] = ( v1 + v2 ) / 2.0;
      BSsfeval (ed_rnd_info->fill_surf, setback_info->setback_pts_uv[FIRST][U],
                setback_info->setback_pts_uv[FIRST][V], ( IGRint ) 0,
                setback_info->setback_pts_xyz[FIRST], &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
      }
    else 
      if (setback_info->bln_cv_props[SECOND] & EMSrnd_bln_trans_cv_to_rnd_vtx)
        {
        setback_info->setback_pts_uv[SECOND][V] = ( v1 + v2 ) / 2.0;
        BSsfeval (ed_rnd_info->fill_surf,
                  setback_info->setback_pts_uv[SECOND][U],
                  setback_info->setback_pts_uv[SECOND][V], ( IGRint ) 0,
                  setback_info->setback_pts_xyz[SECOND], &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
        }
    }
  else if (setback_info->setback_pt_stat[FIRST] == setback_pt_undefined &&
           setback_info->setback_pt_stat[SECOND] == setback_pt_undefined)
    {
    stat = EMget_setback_pts_on_fillet_along_ed (&msg_loc, (IGRushort)0,
             md_env, ed_rnd_info, setback_info);
    EMerr_hndlr (!(1 & stat & msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    }
  else
    {
    /*
     * At least one set back point is pre-defined. Use it to generate
     * the other.
     */
    def_inx = FIRST;
    undef_inx = SECOND;
    if (setback_info->setback_pt_stat[FIRST] == setback_pt_undefined)
      {
      def_inx = SECOND;
      undef_inx = FIRST;
      }
    setback_info->setback_pts_uv[undef_inx][U] =
                  setback_info->fillet_int_iso[undef_inx];
    setback_info->setback_pts_uv[undef_inx][V] = 
                  setback_info->setback_pts_uv[def_inx][V];

    if (vtx_rnd_info->num_edges <= 3)
      {
      tpar = setback_info->setback_pts_uv[def_inx][V];
      isocv = ed_rnd_info->fill_isocvs[undef_inx];
      BSmdstptcv (isocv, vtx_rnd_info->vtx_pt, &vpar, dumpt, &mdist, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  
      if (tpar < vpar)
          tpar = tpar + (vpar - tpar) * SETBACK_FRACTION_3;
      else
          tpar = tpar - (tpar - vpar) * SETBACK_FRACTION_3;
      setback_info->setback_pts_uv[undef_inx][V] = tpar;
      }

    BSsfeval (ed_rnd_info->fill_surf,
              setback_info->setback_pts_uv[undef_inx][U],
              setback_info->setback_pts_uv[undef_inx][V], (IGRint)0,
              setback_info->setback_pts_xyz[undef_inx], &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    }

  setback_info->setback_pt_stat[FIRST] =
  setback_info->setback_pt_stat[SECOND] = setback_pt_defined;

wrapup:
  EMWRAPUP (*EMmsg, stat, "EMfix_setback_on_fillet");
  return (stat);
}

/*
  DESCRIPTION

    Given information on an edge that is rounded, a setback distance along
    the fillet, and a reference set back point on the fillet, this function
    evaluates a new set back point at the specified set back distance along
    the fillet.

    ed_rnd_info	        - Input : Information concerning the edge being rounded.
    ed_stop_end         - Input : TRUE or FALSE.
    setback_dist        - Input : The distance along the fillet from current
                                  setback point at which to place the new set
                                  back point.
    crnt_setback_pt_uv	- Input/Output : Modified set back point on fillet 
                                         (only the v-parameter is modified).
    crnt_setback_pt_xyz    The new xyz point on the fillet.

  HISTORY
    Janaka : 05/25/93 : Original.
    KNAP   : 20 Sep'94: Re-write, cleaned up the function.
*/

#argsused

IGRlong EMadjust_setback_pt_along_fillet_iso (IGRlong *EMmsg,
                  IGRboolean	      	        ed_stop_end,
                  struct EMSedge_rnd_info       *ed_rnd_info,
                  IGRdouble                     setback_dist,
                  point2d                       crnt_setback_pt_uv,
                  IGRpoint                      crnt_setback_pt_xyz)
{
  IGRboolean    test_planarity;
  IGRshort      cv_opt;
  IGRlong       msg_loc, stat;
  IGRdouble     ref_pt_on_iso, other_end_of_iso, param1;
  IGRpoint      pt_xyz;

  struct IGRbsp_curve   *iso_geom;
  struct IGRbsp_surface *fil_geom;

  *EMmsg = EMS_S_Success;
  stat = OM_S_SUCCESS;

  iso_geom = NULL;
  fil_geom = ed_rnd_info->fill_surf;
  ref_pt_on_iso = crnt_setback_pt_uv[V];
 
  BSalloccv (fil_geom->v_order, fil_geom->v_num_poles,
             fil_geom->rational, (IGRshort) 0, &iso_geom, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  cv_opt = CONST_U;
  BSconstprcv (&msg_loc, fil_geom, &cv_opt, &crnt_setback_pt_uv[U],
               &test_planarity, iso_geom);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  other_end_of_iso = PARAM_V0;
  if ((ed_rnd_info->props & EMSfillet_v0_closeto_start_end ? 1 : 0 ) ^
     (ed_stop_end == TRUE ? 1 : 0))

  other_end_of_iso = PARAM_V1;

  /* 
   * Determine the new setback point on the fillet.
   */
  BSiarcln (&msg_loc, iso_geom, &ref_pt_on_iso, &setback_dist,
            &other_end_of_iso, &param1);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  BScveval (iso_geom, param1, ( IGRint ) 0, &pt_xyz, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  crnt_setback_pt_uv[V] = param1;
  OM_BLOCK_MOVE (pt_xyz, crnt_setback_pt_xyz, sizeof (IGRpoint));

wrapup:

  if (iso_geom)  BSfreecv (&msg_loc, iso_geom);
  EMWRAPUP (*EMmsg, stat, "EMadjust_setback_pt_along_fillet_iso");
  return (stat);
}

/*
  DESCRIPTION

    Given an edge, a model space point along the edge (need not be on the
    edge), which demarks the edge, this function yeilds the following:

    . Edge length from the logical start of the edge to the demarkation
      point.
    . Edge length from the demarkation point to the logical stop of
      the edge.
    . The edge parameter at the demarkation point.

  ARGUMENTS
    ed_id     - Input : Edge id.
    pt_xyz    - Input : This point is minimum distance projected onto the edge
                        to obtain the demarkation point (It must yeild a unique
                         point).
    param_on_ed - Input : The demarkation point on the edge.
    ed_lengths  - Output: [FIRST] .. length from logical start to demarkation
                                   point.
                          [SECOND].. length from demarkation point to logical
                                   stop.
  HISTORY
    Janaka : 05-26-93 : Original.
    KNAP   : 20 Sep'94: Re-write, cleaned up the function.
*/

IGRlong EMget_edge_lengths (IGRlong *EMmsg, struct GRmd_env *md_env,
                 GRobjid        ed_id,
                 IGRpoint       pt_xyz,
                 IGRdouble      *param_on_ed,
                 IGRdouble      *ed_lengths)
{ 
  IGRlong       stat, msg_loc;
  IGRint        k, n, i;
  IGRdouble     *params, min_dist, *interval_params, loc_ed_lengths[2];
  GRspacenum    os;

  struct IGRbsp_curve   ed_geom;


  stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  ed_geom.poles = NULL;
  ed_geom.weights = NULL;
  ed_geom.knots = NULL;
  os = md_env->md_id.osnum;
  params = NULL;
  interval_params = NULL;
 
 
  stat = om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc, 
                                &md_env->md_env, NULL, NULL, (IGRint)0,
 	                        MAXINT, FALSE, NULL, &ed_geom),
 		        senderid = NULL_OBJID,
                        targetos = os,
       		        targetid = ed_id);
  EMerr_hndlr (!(msg_loc & stat & 1 ), *EMmsg, msg_loc, wrapup);

  k = n = 0;
  BSmdistptcv (&ed_geom, pt_xyz, &k, &n, &params, &min_dist,
              &interval_params, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC || n != 1, *EMmsg, EMS_E_BSerror, 
               wrapup);

  for (i=FIRST; i<=SECOND; i++)
    {
    stat = om$send ( msg = message EMSedge.EMget_edge_length (&msg_loc,
                                   (IGRushort)0, &md_env->md_env,
                                   i == FIRST ? NULL : &params[k],
                                   i == FIRST ? &params[k] : NULL,
                                   NULL, &loc_ed_lengths[i]),
                           senderid = NULL_OBJID,
                           targetid = ed_id,
                           targetos = os);
    EMerr_hndlr (!(1 & stat & msg_loc ), *EMmsg, EMS_E_EdgeError, wrapup);
    }

 if (param_on_ed)    *param_on_ed = params[k];
 if (ed_lengths)
   OM_BLOCK_MOVE (loc_ed_lengths, ed_lengths, 2*sizeof (IGRdouble));
    
wrapup:

  if (ed_geom.poles)   om$dealloc (ptr = ed_geom.poles);
  if (ed_geom.knots)   om$dealloc (ptr = ed_geom.knots);
  if (ed_geom.weights) om$dealloc (ptr = ed_geom.weights);
  if (params)   free (params);
  if (interval_params)  free (interval_params);
 
  EMWRAPUP (*EMmsg, stat, "EMget_edge_lengths");
  return (stat);
}


/*
  DESCRIPTION

    Move forward and delete the contents of each nodes in a NULL terminated
    list of round blend curves. All nodes in front of (that is previous)
    'ptr_to_free' will be untouched.
    NOTE: The list could be cyclic.

*/

void EMdealloc_rnd_blend_curve_info (EMmsg, ptr_to_free, num)
IGRlong                        *EMmsg;
struct EMSrnd_blend_curve_info *ptr_to_free;
IGRint                         num;
{
  IGRint                          i;
  IGRlong                         msg_loc;
  struct EMSrnd_blend_curve_info  *tmp_ptr;
  void	EMdataselect_data_free(), EMsfintedpar_free();
 
  *EMmsg = EMS_S_Success;
  if (!(tmp_ptr = ptr_to_free)) goto wrapup;
  do
    {
    EMdataselect_data_free (&msg_loc, &tmp_ptr->uv1, (IGRint)1);
    EMerr_hndlr (!(1 & msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    tmp_ptr->uv1.datatype = EMSdata_null;
   
    if (tmp_ptr->xyz_geom)
      BSfreecv (&msg_loc, tmp_ptr->xyz_geom);   
    tmp_ptr->xyz_geom = NULL;
  
    for (i=FIRST; i<=SECOND; i++)
      {
      if (tmp_ptr->incident_info[i])
        EMsfintedpar_free (tmp_ptr->incident_info[i], (IGRint)1);    
      tmp_ptr->incident_info[i] = NULL;
      }
    if (num == 1)
      break;
    tmp_ptr = tmp_ptr->next;
    }
  while (tmp_ptr && tmp_ptr != ptr_to_free);

wrapup:;
}


/*
  DESCRIPTION

    Initialize all fields in a NULL terminated list of instances of
    EMSrnd_blend_curve_info (other than 'next' and 'prev').
*/

void  EMinit_rnd_blend_curve_info (struct EMSrnd_blend_curve_info *list_ptr)
{
  for (;list_ptr;list_ptr = list_ptr->next)
    {
    list_ptr->xyz_geom = NULL;
    list_ptr->tangent_sf_geom = NULL;
    list_ptr->uv1_orientation = UNDEFINED;
    list_ptr->uv1.datatype = EMSdata_null;
    list_ptr->tangent_sf_id = NULL_OBJID;
    list_ptr->ed_info = NULL;
    list_ptr->props = EMSrnd_bln_trans_cv_undefined;
    list_ptr->incident_info[FIRST] =
    list_ptr->incident_info[SECOND] = NULL;
    }
}

/*
  DESCRIPTION
    Given fillet info:, edge info:, and the round vertex, generate a
    transition curve from the FIRST and/or SECOND setback point, to the
    round vertex.
    In case of SECOND, the transition curve is from the round vertex to the
    SECOND fillet iso curve's set back point.  In case of FIRST, the
    transition curve is from the set back point on the FIRST fillet iso,
    to the round vertex.

  ALGORITHM
    Extract the geometry of the edge for which the fillet is defined, as one
    one of the curves to the blend curve.  Depending on the 'process_..' flag,
    extract fillets U0 and/or U1 as the other geometry of the blend curve.
    Also determine the tangency requirements on each of these curve
    geometries.  Create the blend curve between these two geometries, such
    that it is constrained to the model surface that is defined by whether
    fillet's U0 or U1 is being processed.

  HISTORY
    Janaka : 06-07-93    : Original.
    KNAP   : Aug'16 1994 : Re-Write, cleaned up the function.
                         : Memory is now allocated inside this function.
*/

#argsused

IGRlong EMget_bln_cvs_to_rnd_vtx (IGRlong *EMmsg, IGRushort options,
          struct GRmd_env                       *md_env,
          struct EMSedge_rnd_info               *ed_info,
          struct EMSedge_blend_info             *ed_bln_info,
          IGRboolean                            process_FIRST,
          IGRboolean                            process_SECOND,
          struct EMSrnd_blend_curve_info        **bln_trans_cv)
{
  IGRboolean	cv_tan_dir_natural[2], tst_planarity, geom_constructed,
                cv_nat_dir, proc_ed_indi[2];
  IGRushort     bln_cv_props[2];
  IGRshort      cv_opt, *mat_type;
  IGRint        i, j, num_uv_pts, domi_ed_inx, iso_cv_inx, ed_cv_inx, count;
  IGRlong       msg_loc, stat;
  IGRdouble     cv_params[2], bas_tol, cht_tol, uv_tol, min_dist, iso_param,
                *matrix;
  IGRpoint      dum_pt;
  GRspacenum    os;
  GRobjid       sf_id_for_bln_cv[2];
  BSpair        *uv_pts;

  OM_S_CHANSELECT chan_to_loopset;

  struct IGRbsp_curve    ed_geom, *fil_iso_geom, *bln_cv_xyz[2],
                         *bsp_cv_uv, *cv_geoms[2];
  struct IGRbsp_surface	 *fil_geom;
  struct EMSdataselect   bln_cv_uv[2], sf_geom_for_bln_cv[2];
  struct EMSsfintedpar   *loc_incident_info[2][2], *tmp_intedpar;
  struct EMSedgebound    end_bound_info;
  struct BSgeom_bsp_surf tmp_sf_BSgeom;
  struct EMSpartolbasis	 par_tol_basis;
  struct EMSpypoint      *py_bdry;
  struct EMSrnd_blend_curve_info  *trans_cvs = NULL;

  struct EMSsfintedpar   *EMsfintedpar_malloc();
  void   EMsfintedpar_free(), EMdataselect_data_free();

  *EMmsg = EMS_S_Success;
  stat = OM_S_SUCCESS;

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bas_tol);
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);
  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  matrix = md_env->md_env.matrix;
  mat_type = &md_env->md_env.matrix_type;
  os = md_env->md_id.osnum;
  fil_geom = ed_info->fill_surf; 
  fil_iso_geom = NULL;
  py_bdry = NULL;
 
  bsp_cv_uv = NULL;
  uv_pts = NULL;
  for (i=FIRST; i <=SECOND; i++)
    {
    bln_cv_xyz[i] = NULL;
    bln_cv_uv[i].datatype = EMSdata_null;
  
    for (j=0; j<2; j++)
      loc_incident_info[i][j] = NULL;
    bln_cv_props[i] = 0;
    }

  ed_geom.poles = NULL;
  ed_geom.knots = NULL;
  ed_geom.weights = NULL;
 
  par_tol_basis.in_world = TRUE;
  par_tol_basis.mattyp = mat_type;
  par_tol_basis.mat = matrix;
 
  sf_geom_for_bln_cv[0].datatype =
  sf_geom_for_bln_cv[1].datatype = EMSdata_surface;
  sf_geom_for_bln_cv[0].data.surface =
  sf_geom_for_bln_cv[1].data.surface = NULL;
 
  proc_ed_indi[FIRST] = process_FIRST;
  proc_ed_indi[SECOND] = process_SECOND;
 
  EMerr_hndlr (process_FIRST == FALSE && process_SECOND == FALSE,
               *EMmsg, EMS_E_InvalidArg, wrapup);

  /*
   * Creat the blend curve constraining curve geometrie(s).
   * Obtain the blend curve.
   * Ensure its orientation.
   */
  domi_ed_inx = ed_bln_info->FIRST_is_dominant ? FIRST : SECOND;

  /* 
   * Allocate space for fillet iso geometry to be used as the other
   * blend-to curve.
   */
  BSalloccv (fil_geom->v_order, fil_geom->v_num_poles,
             (IGRshort)fil_geom->rational, (IGRshort)0, &fil_iso_geom,&msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  /*
   * Determine the tangent direction on the fillet iso (will be the
   * same for U0 and U1).
   */

  cv_nat_dir = TRUE;
  if ((ed_info->props & EMSfillet_v0_closeto_start_end ? 1 : 0) ^
      (ed_bln_info->rnd_end_stop[domi_ed_inx] == TRUE ? 1 : 0))
        /* Processing v0 end of fillet. */
    cv_nat_dir = FALSE;
  cv_opt = CONST_U;
  for (i=FIRST; i<=SECOND; i++)
    {
    if (proc_ed_indi[i] == FALSE) continue;
    ed_cv_inx = i == FIRST ? SECOND : FIRST;
    iso_cv_inx = i; 

    bln_cv_props[i] = i == FIRST ? EMSrnd_bln_trans_cv_to_rnd_vtx
                              : EMSrnd_bln_trans_cv_from_rnd_vtx;

    /*
     * Get the appropriate edge as one of the constraining geometries.
     */
    stat = om$send( msg = message EMSedge.EMget_bcxyz_geom(
                                  &msg_loc, &md_env->md_env, NULL, NULL,
                                  (IGRint) 0, MAXINT, FALSE, NULL, &ed_geom),
                          senderid = NULL_OBJID,
                          targetid = ed_bln_info->ed_ids[i],
                          targetos = os);
    EMerr_hndlr (!(msg_loc & stat & 1), *EMmsg, msg_loc, wrapup);
    cv_geoms[ ed_cv_inx ] = &ed_geom;

    cv_params[ ed_cv_inx ] = 0.0;
    cv_tan_dir_natural[ ed_cv_inx ] = TRUE;
    if (ed_bln_info->rnd_end_stop[i] == TRUE)
      {
      cv_params[ ed_cv_inx ] = 1.0;
      cv_tan_dir_natural[ ed_cv_inx ] = FALSE;
      }

    /*
     * Get the appropriate fillet iso as the other geometry.
     */
    iso_param = ed_bln_info->fillet_int_iso[i];
    BSconstprcv (&msg_loc, fil_geom, &cv_opt, &iso_param, &tst_planarity,
                 fil_iso_geom);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    cv_geoms[ iso_cv_inx ] = fil_iso_geom;
    cv_params[ iso_cv_inx ] = ed_bln_info->setback_pts_uv[i][V];
    cv_tan_dir_natural[ iso_cv_inx ] = cv_nat_dir;

    if (ed_bln_info->fillet_int_iso[i] == FILLET_U0)
      {
      sf_geom_for_bln_cv[i].data.surface = ed_info->surf;
      sf_id_for_bln_cv[i] = ed_info->surf_id;
      uv_tol = ed_info->surf_tol;
      }
    else
      {
      sf_geom_for_bln_cv[i].data.surface = ed_info->com_surf;
      sf_id_for_bln_cv[i] = ed_info->com_surf_id;
      uv_tol = ed_info->com_surf_tol;
      }

    stat = EMget_sf_BSgeom_info (&msg_loc, md_env, &sf_geom_for_bln_cv[i],
                                 &tmp_sf_BSgeom, &geom_constructed);
    EMerr_hndlr (!(1 & stat & msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    /* 
     * Cannot call BSblncvosf() here since there was no good way
     * of determining the speed parameters required by that function
     * (BSfndbldrto() did not return good values).  Consequently,
     * Dieter provided the following 2 function, which calls the pre 2.4
     * math blend curve.
     */
    BSblncvosf2 (cv_geoms[FIRST], cv_params[FIRST], cv_tan_dir_natural[FIRST],
                 cv_geoms[SECOND], cv_params[SECOND],
                 cv_tan_dir_natural[SECOND], &tmp_sf_BSgeom, &bln_cv_xyz[i],
                 &num_uv_pts, &uv_pts, &bsp_cv_uv, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    om$dealloc( ptr = ed_geom.poles );
    om$dealloc( ptr = ed_geom.knots );
    om$dealloc( ptr = ed_geom.weights );
    ed_geom.poles = NULL;
    ed_geom.knots = NULL;
    ed_geom.weights = NULL;

    /* 
     * Collect the proper uv curve (line string or bspline curve.
     */
    if (bsp_cv_uv)
      {
      bln_cv_uv[i].datatype = EMSdata_curve3d;
      bln_cv_uv[i].data.curve = bsp_cv_uv;
      bsp_cv_uv = NULL;
      }
    else
      {
      bln_cv_uv[i].data.poly = NULL;
      bln_cv_uv[i].data.poly = (struct IGRpolyline *) om$malloc
                                (size = sizeof (struct IGRpolyline));
      EMerr_hndlr (!bln_cv_uv[i].data.poly, *EMmsg, EMS_E_NoDynamicMemory,
                   wrapup);
      bln_cv_uv[i].datatype = EMSdata_poly2d;
      bln_cv_uv[i].data.poly->num_points = num_uv_pts;
      bln_cv_uv[i].data.poly->points = (IGRdouble *) uv_pts;
      uv_pts = NULL;
      }

    /* 
     * Validate the generated blend curve is entirely within the
     * area of its constraining surface.
     */

    par_tol_basis.is_valid = TRUE;
    par_tol_basis.tol = uv_tol * cht_tol / bas_tol;
    count = 0;
    stat = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc,
                                  &bln_cv_uv[i], &par_tol_basis,
                                  EMS_INTER_BDRYISAREA, &count, &py_bdry,
                                  NULL),
                             p_chanselect = &chan_to_loopset,  
                             senderid = sf_id_for_bln_cv[i]);
    EMerr_hndlr (!(1 & stat & msg_loc) || count != 1, *EMmsg, EMS_E_Fail, 
                 wrapup);

    EMerr_hndlr (!(py_bdry->props & EMS_PYPT_ATSTART &&
                 py_bdry->next->props & EMS_PYPT_ATSTOP), *EMmsg, EMS_E_Fail,
                 wrapup);

    /*
     * Generate the incident edge information for the edge.
     */
    for (j = FIRST; j <= SECOND; j++)
      {
      loc_incident_info[i][j] = EMsfintedpar_malloc (&msg_loc, (IGRint)1);
      EMerr_hndlr (!loc_incident_info[i], *EMmsg, EMS_E_NoDynamicMemory, 
                   wrapup);
      }

    stat = om$send (msg = message EMSedge.EMendpts (&msg_loc, NULL, NULL,
                                  ed_bln_info->rnd_end_stop[i] == TRUE ? 
                                  NULL : &end_bound_info,
                                  ed_bln_info->rnd_end_stop[i] == TRUE ?
                                  &end_bound_info : NULL, NULL),
                          senderid = NULL_OBJID,
                          targetid = ed_bln_info->ed_ids[i],
                          targetos = os);
    EMerr_hndlr (!(1 & stat & msg_loc), *EMmsg, EMS_E_EdgeError, wrapup);

    /*
     * Choose the intedpar on the edge, and initialize it.
     */
    tmp_intedpar = loc_incident_info[i][0];
    if (i == FIRST)
    tmp_intedpar = loc_incident_info[i][1];

    tmp_intedpar->intloc = ed_bln_info->rnd_end_stop[i] == TRUE ?
                           EMScvint_rtend : EMScvint_lfend;
    tmp_intedpar->edgeid = ed_bln_info->ed_ids[i];
    OM_BLOCK_MOVE (&end_bound_info, &tmp_intedpar->edgepar,
                   sizeof(struct EMSedgebound));
    BSmdistptsf (&msg_loc, sf_geom_for_bln_cv[i].data.surface,
                 ed_bln_info->rnd_end_vtx[i], &tmp_intedpar->point[0],
                 &tmp_intedpar->point[1], dum_pt, &min_dist);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    }    

    trans_cvs = (struct EMSrnd_blend_curve_info *) om$malloc
                             (size = sizeof (struct EMSrnd_blend_curve_info));
    trans_cvs->prev = NULL;
    trans_cvs->next = NULL;
    EMinit_rnd_blend_curve_info (trans_cvs);
    for (i=FIRST; i<=SECOND; i++)
      {
      if (proc_ed_indi[i] == FALSE) continue;

      trans_cvs->props |= bln_cv_props[i] | EMSrnd_bln_trans_cv_exists;
      trans_cvs->tangent_sf_geom = sf_geom_for_bln_cv[i].data.surface;
      trans_cvs->tangent_sf_id = sf_id_for_bln_cv[i];
      OM_BLOCK_MOVE (&bln_cv_uv[i], &trans_cvs->uv1,
                    sizeof (struct EMSdataselect));
      bln_cv_uv[i].datatype = EMSdata_null;
      trans_cvs->xyz_geom = bln_cv_xyz[i];
      bln_cv_xyz[i] = NULL;
      OM_BLOCK_MOVE (loc_incident_info[i], trans_cvs->incident_info,
                     2 * sizeof( struct EMSsfintedpar *));
      loc_incident_info[i][0] = loc_incident_info[i][1] = NULL;
      }

    *bln_trans_cv = trans_cvs; 

wrapup:

  if (EMSerror(*EMmsg))
    {
    if (trans_cvs)
      {
      EMdealloc_rnd_blend_curve_info (&msg_loc, trans_cvs, (IGRint)1);
      om$dealloc (ptr = trans_cvs);
      }
    }
  for (i=FIRST; i<=SECOND; i++)
    {
    if (bln_cv_xyz[i])
      BSfreecv (&msg_loc, bln_cv_xyz[i]);
 
    for (j=0; j<2; j++)
      EMsfintedpar_free (loc_incident_info[i][j], (IGRint)1);
    }
 
  if (fil_iso_geom)   BSfreecv (&msg_loc, fil_iso_geom);
  EMdataselect_data_free (&msg_loc, bln_cv_uv, (IGRint)2);

  if (ed_geom.poles)   om$dealloc (ptr = ed_geom.poles);
  if (ed_geom.knots)   om$dealloc (ptr = ed_geom.knots);
  if (ed_geom.weights) om$dealloc (ptr = ed_geom.weights);
 
  if (uv_pts)   free( uv_pts );
  if (bsp_cv_uv)   BSfreecv (&msg_loc, bsp_cv_uv);
 
  EMpypoint_free (py_bdry, 0);
 
  EMWRAPUP (*EMmsg, stat, "EMget_bln_cvs_to_rnd_vtx");
  return (stat);
}
    
/*
    DESCRIPTION

    This function creates blend transition curves on model surfaces
    such that the blend is between one of the following:
    .  edge - edge
    .  edge-fillet (or fillet-edge)
    .  fillet-fillet

    It is possible that such a transition curve is not well defined.  In such
    cases the function returns with an error (also see OUTPUT). Under such
    conditions, the caller may call EMget_bln_cvs_to_rnd_vtx() to force fillets
    to the round vertex (as oppose to going around the vertex as attempted by
    this function).

    ARGUMENTS
 
    options		 EMSrnd_bln_cv_donot_trim
                         If set, then the generated blend curve is not trimmed
                         against its contraining surface.
    fil_ed_infos[FIRST]  If the FIRST is a fillet iso, then that edge and
                         fillet information.  It is implied that the FIRST
                         information is used for this fillet.
    ed_ids[FIRST]        If the FIRST was an edge with no fillet, its id.
    ed_bln_infos[FIRST]  Blend related information for the above.

    The preceding comments are equally applicable to the SECOND index of these
    three variables.

    bln_trans_cv         The transition blend curves. Number of nodes required
                         is one.  On failure, props in this node will be set to 
                         EMSrnd_trans_bln_cv_undefined.

    ALGORITHM
    Extract the appropriate curve geometries that are to be used to construct
    the blend curve. Construct the blend curve, and determine whether it is
    valid by trimming it against the loops of the surface which is
    constraining the blend transition curve. If the transition curve is
    entirely within the area, then it is legal. Else, the blend transition
    curve is illdefined.

    NOTE: The interaction between the blend transition curve and any holes
          on the supporting surface can be handled by splitting the transition
          curve appropriately.  However, this is not done in this
          implementation.

    HISTORY
    Janaka : 06-08-03  : Original.
    KNAP   : Aug'16 94 : Re-write, cleaned up the code.
                       : Memory is now allocated in this function.
*/

#argsused

IGRlong EMget_bln_cv_from_fillet_or_edge( IGRlong *EMmsg, IGRushort options,
          struct GRmd_env                       *md_env,
          struct EMSedge_rnd_info               *ed_infos[2],
          GRobjid                               ed_ids[2],
          struct EMSedge_blend_info             *ed_bln_infos[2],
          struct EMSrnd_blend_curve_info        **bln_trans_cv )
{
  IGRboolean    cv_tan_dir_natural[2], tst_planarity, geom_constructed;
  IGRshort	cv_opt, *mat_type;
  IGRint	i, inx, num_uv_pts, count, rnded_inx;
  IGRlong	msg_loc, stat;
  IGRdouble	cv_params[2], bas_tol, cht_tol, uv_tol,
                *matrix, min_dist, uv_params[2];
  IGRpoint	dum_pt;
  BSpair	*bln_cv_uv_pts;
 
  GRspacenum	  os;
  GRobjid	  sf_id_for_trans_cv;
  OM_S_CHANSELECT chan_to_loopset;
  
  struct IGRbsp_curve    ed_geoms[2], *cv_geoms[2], *bln_cv_xyz, *bln_cv_bsp_uv;
  struct EMSpartolbasis	 par_tol_basis;
  struct EMSdataselect	 f_bln_cv_uv, sf_geom_for_trans_cv;
  struct GRid            tmp_GRid;
  struct EMSsfintedpar   *loc_incident_info[2];
  struct EMSproj_info    proj_info;
  struct BSgeom_bsp_surf tmp_sf_BSgeom;
  struct EMSpypoint      *py_bdry;
  struct EMSrnd_blend_curve_info *trans_cv;
 
  struct EMSsfintedpar	*EMsfintedpar_malloc();
  void                  EMsfintedpar_free(), EMdataselect_data_free();

  IGRboolean   onsrf, extract_iso_curve = FALSE, at_start = FALSE;
  IGRpoint     start_pt, stop_pt;
  IGRint       ext_iso_inx, edge_inx;
  struct EMSdataselect   xyzdata;
  struct IGRbsp_curve    *alloc_crv;
 
  stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
 
  EMerr_hndlr ((ed_infos[FIRST] == NULL && ed_ids[FIRST] == NULL_OBJID) ||
               (ed_infos[SECOND] == NULL && ed_ids[SECOND] == NULL_OBJID),
                *EMmsg, EMS_E_InvalidArg, wrapup);

  os = md_env->md_id.osnum;
  matrix = md_env->md_env.matrix;
  mat_type = &md_env->md_env.matrix_type;

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bas_tol);
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);
  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);

  for (i=FIRST; i<=SECOND; i++)
    {
    ed_geoms[i].poles = NULL;
    ed_geoms[i].knots = NULL;
    ed_geoms[i].weights = NULL;
    cv_geoms[i] = NULL;
    }
  py_bdry = NULL;
  bln_cv_xyz = NULL;
  bln_cv_bsp_uv = NULL;
  bln_cv_uv_pts = NULL;
  f_bln_cv_uv.datatype = EMSdata_null;

  par_tol_basis.in_world = TRUE;
  par_tol_basis.mattyp = mat_type;
  par_tol_basis.mat = matrix;
 
  for (i=FIRST; i<=SECOND; i++)
    {
    loc_incident_info[i] = NULL;
    loc_incident_info[i] = EMsfintedpar_malloc (&msg_loc, (IGRint)1);
    EMerr_hndlr (!loc_incident_info[i], *EMmsg, EMS_E_NoDynamicMemory,
                 wrapup);
    /*
    ed_bln_infos[i]->bln_cv_props[i] |= EMSrnd_bln_trans_cv_undefined;
    */
    }

  trans_cv = (struct EMSrnd_blend_curve_info *) om$malloc
                             (size = sizeof (struct EMSrnd_blend_curve_info));
  trans_cv->prev = NULL;
  trans_cv->next = NULL;
  EMinit_rnd_blend_curve_info (trans_cv);
  trans_cv->uv1.datatype = EMSdata_null;

  /*
   * Determine the constraining surface to the blend transition
   * curve.
   */
  rnded_inx = ed_infos[FIRST] ? FIRST:(ed_infos[SECOND] ? SECOND : UNDEFINED);
  sf_geom_for_trans_cv.datatype = EMSdata_surface;
  sf_geom_for_trans_cv.data.surface = NULL;
  if (rnded_inx != UNDEFINED)
    {
    sf_geom_for_trans_cv.data.surface = ed_infos[ rnded_inx ]->com_surf;
    sf_id_for_trans_cv = ed_infos[ rnded_inx ]->com_surf_id;
    uv_tol = ed_infos[ rnded_inx ]->com_surf_tol;
    if (ed_bln_infos[rnded_inx]->fillet_int_iso[rnded_inx] == FILLET_U0)
      {
      sf_geom_for_trans_cv.data.surface = ed_infos[ rnded_inx ]->surf;
      sf_id_for_trans_cv = ed_infos[ rnded_inx ]->surf_id;
      uv_tol = ed_infos[ rnded_inx ]->surf_tol;
      }
    }
  else
    {
    /* 
     * Getting the surface of the FIRST edge is adequate since
     * its neighbor is guaranteed to be on it.
     */
    par_tol_basis.is_valid = FALSE;
    stat = om$send (msg = message EMSboundary.EMgetsurface_info
                                  (&msg_loc, &sf_id_for_trans_cv,
                                   &par_tol_basis ),
                          targetos = os,
                          targetid = ed_bln_infos[FIRST]->ed_ids[FIRST],
                          senderid = NULL_OBJID);
    EMerr_hndlr (!(1 & stat & msg_loc), *EMmsg, EMS_E_EdgeError, wrapup);
    uv_tol = par_tol_basis.tol;
    tmp_GRid.objid = sf_id_for_trans_cv;
    tmp_GRid.osnum = os;
    stat = EMgetvggeom (&msg_loc, mat_type, matrix, &tmp_GRid,
             &sf_geom_for_trans_cv.data.surface, NULL);
    EMerr_hndlr (!(1 & stat & msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    }

  /*
   * Generate the two blend constraining curve geometries.
   */
  cv_opt = CONST_U;
  for (i=FIRST; i<=SECOND; i++)
    {
    if (ed_infos[i])
      {
      BSalloccv (ed_infos[i]->fill_surf->v_order,
                 ed_infos[i]->fill_surf->v_num_poles,
                 (IGRshort)ed_infos[i]->fill_surf->rational,
                 (IGRshort)0, &cv_geoms[i], &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   
      BSconstprcv (&msg_loc, ed_infos[i]->fill_surf, &cv_opt,
                   &ed_bln_infos[i]->setback_pts_uv[i][U],
                   &tst_planarity, cv_geoms[i]);
      EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   
      /*
       * Determine the tangent direction on the fillet iso (will be the
       * same for U0 and U1).
       */
      cv_tan_dir_natural[i] = TRUE;
      if ((ed_infos[i]->props & EMSfillet_v0_closeto_start_end ? 1 : 0) ^
          ed_bln_infos[i]->rnd_end_stop[ed_bln_infos[i]->FIRST_is_dominant ?
          FIRST : SECOND] == TRUE ? 1 : 0)
        /* Processing v0 end of fillet. */
        cv_tan_dir_natural[i] = FALSE;
        cv_params[i] = ed_bln_infos[i]->setback_pts_uv[i][V];
       if (ed_bln_infos[i]->bln_cv_props[i] &
              EMSrnd_bln_trans_cv_extracted_iso_curve)
         {
         extract_iso_curve = TRUE;
         ext_iso_inx = i;
         }
      }
    else
      {
      cv_geoms[i] = &ed_geoms[i];
      stat = om$send (msg = message EMSedge.EMget_bcxyz_geom( &msg_loc,
                                    &md_env->md_env, NULL, NULL, (IGRint)0,
                                    MAXINT, FALSE, NULL, cv_geoms[i]),
                            senderid = NULL_OBJID,
                            targetid = ed_bln_infos[i]->ed_ids[i],
                            targetos = os);
      EMerr_hndlr (!(msg_loc & stat & 1), *EMmsg, msg_loc, wrapup);
      cv_params[i] = ed_bln_infos[i]->setback_pts_uv[i][U];
      cv_tan_dir_natural[i] = FALSE;
      if (ed_bln_infos[i]->rnd_end_stop[i] == TRUE)
        cv_tan_dir_natural[i] = TRUE;

      /*
       * For existing model surfaces, generate incident information.
       */
      BSmdistptsf (&msg_loc, sf_geom_for_trans_cv.data.surface,
                   ed_bln_infos[i]->setback_pts_xyz[i], &uv_params[U],
                   &uv_params[V], dum_pt, &min_dist);
      EMerr_hndlr (msg_loc != BSSUCC || min_dist>cht_tol, *EMmsg, EMS_E_BSerror,
                   wrapup);
      stat = om$send (msg = message EMSedge.EMptproject (&msg_loc,
                                            uv_params, 1, &proj_info,
                                            NULL, &par_tol_basis),
                                    senderid = NULL_OBJID,
                                    targetos = os,
                                    targetid = ed_bln_infos[i]->ed_ids[i]);
      EMerr_hndlr (!(1 & stat & msg_loc), *EMmsg, EMS_E_EdgeError, wrapup);
      loc_incident_info[i]->edgeid = ed_bln_infos[i]->ed_ids[i];
      loc_incident_info[i]->intloc = EMScvint_middle;
      OM_BLOCK_MOVE (proj_info.proj_pt, loc_incident_info[i]->point,
                     2*sizeof(IGRdouble));
      OM_BLOCK_MOVE (&proj_info.param, &loc_incident_info[i]->edgepar,
                     sizeof (struct EMSedgebound));
      edge_inx = i;
      }
    }

  if (extract_iso_curve)
    {
    BSmdstptcv (cv_geoms[ext_iso_inx],
                ed_bln_infos[edge_inx]->setback_pts_xyz[edge_inx],
                &cv_params[edge_inx], dum_pt, &min_dist, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    }
  if (extract_iso_curve)
    {
    BSalloccv (ed_infos[rnded_inx]->fill_surf->v_order,
               ed_infos[rnded_inx]->fill_surf->v_num_poles +
               2 * ed_infos[rnded_inx]->fill_surf->v_order - 1,
               ed_infos[rnded_inx]->fill_surf->rational, 0,
               &alloc_crv, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    BSpartofcv (&msg_loc, cv_geoms[ext_iso_inx], cv_params[FIRST],
                (cv_params[FIRST]+cv_params[SECOND])/2.0,
                cv_params[SECOND], alloc_crv);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    xyzdata.datatype = EMSdata_curve3d;
    xyzdata.data.curve = alloc_crv;
    alloc_crv = NULL;

    EMgetendpts_xyz (&msg_loc, &mat_type, matrix, &xyzdata, FALSE, (IGRint)1,
                     start_pt, stop_pt);
    EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    if (ed_bln_infos[rnded_inx]->fillet_int_iso[ext_iso_inx] == FILLET_U1)
      {
      if (EMis_geomequal_3dpt (start_pt,
             ed_bln_infos[rnded_inx]->setback_pts_xyz[SECOND],
             bas_tol*100 ) == TRUE)
        BSrev_cv (&msg_loc, xyzdata.data.curve);
      at_start = TRUE;
      }
    else
      {
      if (EMis_geomequal_3dpt (start_pt,
             ed_bln_infos[rnded_inx]->setback_pts_xyz[FIRST],
             bas_tol*100) == FALSE)
        BSrev_cv (&msg_loc, xyzdata.data.curve);
      at_start = FALSE;
      }
    tst_planarity = EMS_O_Unknown;
    EMmapcvxyz_to_uv (&msg_loc, EMS_TRIM_AGAINST_NATBDRY,
                      sf_geom_for_trans_cv.data.surface, &xyzdata,
                      cht_tol, uv_tol, &tst_planarity, &f_bln_cv_uv,
                      &onsrf);
    EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    EMend_modify_data (&msg_loc, &md_env->md_env, &xyzdata, at_start,
                       ed_bln_infos[edge_inx]->setback_pts_xyz[edge_inx]);
    EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    EMend_modify_data (&msg_loc, &md_env->md_env, &f_bln_cv_uv, at_start,
                       loc_incident_info[edge_inx]->point);
    EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    bln_cv_xyz = xyzdata.data.curve;
    goto trim;
    }

  /*
   * Generate the initial blend transition curve.  Determine its validity
   * by trimming the transitions blend curve's uv geometry against its
   * supporting model surface.  A legal curve would lie entirely within its
   * supporting surface (transition curve interaction with the supporting
   * surface holes is considered an error for this implementation).
   */
  stat = EMget_sf_BSgeom_info (&msg_loc, md_env, &sf_geom_for_trans_cv,
                               &tmp_sf_BSgeom, &geom_constructed);
  EMerr_hndlr (!( 1 & stat & msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  /*
   * Cannot call BSblncvosf() here since there was no good way
   * of determining the speed parameters required by that function
   * (BSfndbldrto() did not return good values).  Consequently,
   * Dieter provided the following 2 function, which calls the pre 2.4
   * math blend curve. -JJ.
   */
  BSblncvosf2 (cv_geoms[FIRST], cv_params[FIRST], cv_tan_dir_natural[FIRST],
               cv_geoms[SECOND], cv_params[SECOND], cv_tan_dir_natural[SECOND],
               &tmp_sf_BSgeom, &bln_cv_xyz, &num_uv_pts, &bln_cv_uv_pts,
               &bln_cv_bsp_uv, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  /* 
   * Force the end points of the transition curve to be exactly on
   * the uv representation of the edge (if an edge is involved).
   */
  for (i=FIRST; i<=SECOND; i++)
    {
    if (ed_infos[i])
      continue; /* This end is on a fillet iso. */
     /* 
      * ith end of the blend curve is on an edge. Correct it.
      */
    if (bln_cv_bsp_uv)
      {
      inx = i == FIRST ? 0 : bln_cv_bsp_uv->num_poles - 1;
      OM_BLOCK_MOVE (loc_incident_info[i]->point, &bln_cv_bsp_uv->poles[inx],
                     sizeof(point2d));
      /* 
       * If the curve is rational, transform the coordinates
       * into homogeneous space.
       */
      if (bln_cv_bsp_uv->rational == TRUE)
        {
        bln_cv_bsp_uv->poles[inx] *= bln_cv_bsp_uv->weights[inx];
        bln_cv_bsp_uv->poles[inx+1] *= bln_cv_bsp_uv->weights[inx];
        }
      }
    else
      {
      inx = i == FIRST ? 0 : ( num_uv_pts - 1 ) * 2;
      OM_BLOCK_MOVE (loc_incident_info[i]->point, 
                     &((IGRdouble *)bln_cv_uv_pts)[inx], sizeof(point2d));
      }
    }

  if (bln_cv_bsp_uv)
    {
    f_bln_cv_uv.datatype = EMSdata_curve3d;
    f_bln_cv_uv.data.curve = bln_cv_bsp_uv;
    bln_cv_bsp_uv = NULL;
    }   
  else
    {   
    f_bln_cv_uv.data.poly = NULL;
    f_bln_cv_uv.data.poly = (struct IGRpolyline *) om$malloc
                                  (size = sizeof( struct IGRpolyline));
    EMerr_hndlr (!f_bln_cv_uv.data.poly, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    f_bln_cv_uv.datatype = EMSdata_poly2d;
    f_bln_cv_uv.data.poly->num_points = num_uv_pts;
    f_bln_cv_uv.data.poly->points = (IGRdouble *)bln_cv_uv_pts;
    bln_cv_uv_pts = NULL;
    }

  /*
   * Do a virtual trim of the transition curve against the boundaries
   * of the constraining surface to ensure that it does not cut any
   * existing boundaries.
   */

trim:
  if (!( options & EMSrnd_bln_cv_donot_trim ))
    {
    par_tol_basis.is_valid = TRUE;
    par_tol_basis.tol = uv_tol * cht_tol / bas_tol;
    count = 0;
    stat = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc,
                                  &f_bln_cv_uv, &par_tol_basis, 
                                  EMS_INTER_BDRYISAREA, &count, &py_bdry,
                                  NULL),
                          p_chanselect = &chan_to_loopset,
                          senderid = sf_id_for_trans_cv);
    EMerr_hndlr (!(1 & stat & msg_loc) || count != 1, *EMmsg, EMS_E_Fail,
                 wrapup );

    EMerr_hndlr (!(py_bdry->props & EMS_PYPT_ATSTART &&
                 py_bdry->next->props & EMS_PYPT_ATSTOP), *EMmsg, EMS_E_Fail,
                 wrapup);
    }

    trans_cv->xyz_geom = bln_cv_xyz;
    bln_cv_xyz = NULL;
    OM_BLOCK_MOVE (&f_bln_cv_uv, &trans_cv->uv1, sizeof (struct EMSdataselect));
    f_bln_cv_uv.datatype = EMSdata_null;
    trans_cv->tangent_sf_geom = sf_geom_for_trans_cv.data.surface;
    trans_cv->tangent_sf_id = sf_id_for_trans_cv;

    for (i=FIRST; i<=SECOND; i++)
      {
      OM_BLOCK_MOVE (&loc_incident_info[i], &trans_cv->incident_info[i],
                      sizeof (struct EMSsfintedpar *));
      loc_incident_info[i] = NULL;
      ed_bln_infos[i]->bln_cv_props[i] &= ~EMSrnd_bln_trans_cv_undefined;
      ed_bln_infos[i]->bln_cv_props[i] |= EMSrnd_bln_trans_cv_exists;
      }

    *bln_trans_cv = trans_cv;  
wrapup:

  if (EMSerror(*EMmsg))
    {
    if (trans_cv)
      {
      EMdealloc_rnd_blend_curve_info (&msg_loc, trans_cv, (IGRint)1);
      om$dealloc (ptr = trans_cv);
      *bln_trans_cv = NULL;
      }
    }
  for (i=FIRST; i<=SECOND; i++)
    {
    if (ed_geoms[i].poles)  om$dealloc (ptr = ed_geoms[i].poles);
    if (ed_geoms[i].knots)  om$dealloc (ptr = ed_geoms[i].knots);   
    if (ed_geoms[i].weights) om$dealloc (ptr = ed_geoms[i].weights);

    if (cv_geoms[i] && cv_geoms[i] != &ed_geoms[i])
      BSfreecv (&msg_loc, cv_geoms[i]);
    }

  if (bln_cv_xyz)   BSfreecv (&msg_loc, bln_cv_xyz);
  if (bln_cv_uv_pts)  free (bln_cv_uv_pts);
  if (bln_cv_bsp_uv)  BSfreecv (&msg_loc, bln_cv_bsp_uv);

  if (f_bln_cv_uv.datatype != EMSdata_null)
    EMdataselect_data_free (&msg_loc, &f_bln_cv_uv, (IGRint)1);
  for (i=FIRST; i<=SECOND; i++)
    if (loc_incident_info[i])
      EMsfintedpar_free (loc_incident_info[i], (IGRint)1);

  EMpypoint_free (py_bdry, 0);

  EMWRAPUP (*EMmsg, stat, "EMget_bln_cv_from_fillet_or_edge");
  return (stat);
}

/*
  DESCRIPTION
 
    Given a dataselect, reverse the direction of the curve
    stored within the dataselect.
    The data inside the dataselect must be either polyline, or curve.
  
  ARGUMENTS

    in_data   Input/Output : Dataselect containing the geometry to be reversed.
  
  HISTORY
    Janaka : 10/01/92 : Original.
*/

#argsused

void EMreverse_curve (IGRlong *EMmsg, IGRushort options,
                      struct EMSdataselect *in_data)
{
   IGRlong		msg_loc;
   enum EMSdatatype	in_data_type;

   *EMmsg = EMS_S_Success;

   in_data_type = in_data->datatype;
   if (in_data_type == EMSdata_poly2d ||
       in_data_type == EMSdata_poly3d)
     {
     EMrevpyline (&msg_loc, in_data->data.poly,
                  in_data_type == EMSdata_poly2d ?(IGRshort)2 : (IGRshort)3, 0);
     EMerr_hndlr (!(1 & msg_loc), *EMmsg, EMS_E_Fail, wrapup);
     }
   else if (in_data_type == EMSdata_curve2d || in_data_type == EMSdata_curve3d)
     {
     BSrev_cv( &msg_loc, in_data->data.curve );
     EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     }
   else
     {
     *EMmsg = EMS_E_Fail;
     goto wrapup;
     }

wrapup:
  return;
}

/*
 *  Make two bspline curves position continuous by forcing the end
 *  of cv1 to be the start of cv2.
 */

void  EMmake_curves_pos_continuous (struct IGRbsp_curve *cv1,
                                    struct IGRbsp_curve *cv2)
{
  IGRint         i, last_pole_inx;

  last_pole_inx = cv1->num_poles - 1;
  OM_BLOCK_MOVE (&cv1->poles[ last_pole_inx * 3 ], cv2->poles,
                 sizeof (IGRpoint));

  /*
   * Convert the points into model space.
   */
  if (cv1->rational && cv1->weights)
    for (i=FIRST; i<3; i++)
      cv2->poles[i] /= cv1->weights[last_pole_inx];

  /*
   * If needed, convert it back into homogeneous space.
   */
  if (cv2->rational && cv2->weights)
    for (i=FIRST; i<3; i++)
      cv2->poles[i] *= cv2->weights[FIRST];
}

/*
   Given two edges and the vertex at which they are incident, this function
   determines if the two edges are of the same curvature, and if they are
   both the edges are checked for curvature continuity at the vertex. 
   Appropriately, a flag is returned.
   
   History
   
   KNAP : September'94 :  Re-write of the function EMare_edges_collinear
                          also, re-named it. This was done for EMS 3.1.
*/

IGRboolean EMare_edges_curvatures_same (EMmsg, md_env, vertex, edge1, edge2)
IGRlong           *EMmsg;
IGRpoint          vertex;
struct GRmd_env   *md_env;
GRobjid           edge1, edge2;
{
  IGRushort    opts;
  IGRshort     *mattyp;
  IGRlong      stat, msg_loc;
  IGRboolean   are_collinear, on_cv;
  IGRdouble    *mat, radofcrv1, radofcrv2, bas_tol, dotp, cvpar;
  IGRpoint     tan_vec1[2], tan_vec2[2];
  struct IGRbsp_curve   ed_cv1, ed_cv2;
  GRspacenum   os;
  extern IGRdouble EMedradofcrv();

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bas_tol);
  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  os = md_env->md_id.osnum;
  are_collinear  = FALSE;

  ed_cv1.poles   = NULL;
  ed_cv1.knots   = NULL;
  ed_cv1.weights = NULL;
  ed_cv1.bdrys   = NULL;

  ed_cv2.poles   = NULL;
  ed_cv2.knots   = NULL;
  ed_cv2.weights = NULL;
  ed_cv2.bdrys   = NULL;

  radofcrv1 = -1.0; /* Initialisers only */
  radofcrv2 = -2.0; /* Initialisers only */

  opts = EMS_O_Internal;
  radofcrv1 = EMedradofcrv (&msg_loc, opts, mattyp, mat, edge1, os, NULL);
  EMerr_hndlr (EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  radofcrv2 = EMedradofcrv (&msg_loc, opts, mattyp, mat, edge2, os, NULL);
  EMerr_hndlr (EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  if (fabs (radofcrv1 - radofcrv2) < bas_tol)
    {
    stat = om$send(msg = message EMSedge.EMget_bcxyz_geom(
                                 &msg_loc, &md_env->md_env, NULL, NULL,
                                 0, MAXINT, FALSE, NULL, &ed_cv1),
                         senderid = NULL_OBJID,
                         targetid = edge1,
                         targetos = os);
    EMerr_hndlr( !( msg_loc & stat & 1 ), *EMmsg, EMS_E_EdgeError, wrapup );
    BSprptoncv (&msg_loc, &ed_cv1, vertex, &cvpar, &on_cv);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    BScveval (&ed_cv1, cvpar, (IGRint)1, tan_vec1, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    BSnorvec (&msg_loc, tan_vec1[1]);

    stat = om$send(msg = message EMSedge.EMget_bcxyz_geom(
                                 &msg_loc, &md_env->md_env, NULL, NULL,
                                 0, MAXINT, FALSE, NULL, &ed_cv2),
                         senderid = NULL_OBJID,
                         targetid = edge2,
                         targetos = os);
    EMerr_hndlr( !( msg_loc & stat & 1 ), *EMmsg, EMS_E_EdgeError, wrapup );
    BSprptoncv (&msg_loc, &ed_cv2, vertex, &cvpar, &on_cv);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    BScveval (&ed_cv2, cvpar, (IGRint)1, tan_vec2, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    BSnorvec (&msg_loc, tan_vec2[1]);

    dotp = BSdotp (&msg_loc, tan_vec1[1], tan_vec2[1]);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    if ( 1.0 - fabs(dotp) < bas_tol )
      are_collinear = TRUE;
    }

wrapup:
   if(ed_cv1.poles)     om$dealloc(ptr = ed_cv1.poles);
   if(ed_cv1.knots)     om$dealloc(ptr = ed_cv1.knots);
   if(ed_cv1.rational == TRUE && ed_cv1.poles)
     om$dealloc(ptr = ed_cv1.weights);
   if(ed_cv2.poles)     om$dealloc(ptr = ed_cv2.poles);
   if(ed_cv2.knots)     om$dealloc(ptr = ed_cv2.knots);
   if(ed_cv2.rational == TRUE && ed_cv1.poles)
     om$dealloc(ptr = ed_cv2.weights);
   return( are_collinear );
}

void EMadjust_setback_pts (EMmsg, edge_inx, vtx_rnd_info, setback_info, ed_info)
IGRlong                    *EMmsg;
IGRint                     edge_inx;
struct  EMSvtx_rnd_info    *vtx_rnd_info;
struct  EMSedge_blend_info *setback_info;
struct  EMSedge_rnd_info   *ed_info;
{
  IGRlong        msg_loc, stat;
  IGRdouble      u_val, v_val, dist1, dist2;
  IGRpoint       pt_xyz;
  IGRint         i, j, def_inx, undef_inx;
  IGRboolean     uniform_setback_solution = FALSE;

  *EMmsg = EMS_S_Success;

  if ((setback_info->setback_pt_stat[FIRST] == setback_pt_transient) ||
      (setback_info->setback_pt_stat[SECOND] == setback_pt_transient))
    {
    if (setback_info->setback_pt_stat[FIRST] == setback_pt_transient)
      {
      undef_inx = FIRST;
      def_inx = SECOND;
      }
    if (setback_info->setback_pt_stat[SECOND] == setback_pt_transient)
      {
      def_inx = FIRST;
      undef_inx = SECOND;
      }
    stat = EMadjust_setback_pt_along_fillet_iso (&msg_loc,
             vtx_rnd_info->edge_stops[edge_inx], ed_info,
             setback_info->default_setback,
             setback_info->setback_pts_uv[undef_inx],
             setback_info->setback_pts_xyz[undef_inx]);
    EMerr_hndlr (!(1 & stat & msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    u_val = setback_info->setback_pts_uv[undef_inx][U];
    v_val = setback_info->setback_pts_uv[def_inx][V];
    BSsfeval (ed_info->fill_surf, u_val, v_val, (IGRint)0, pt_xyz, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    MA2ptdis (&msg_loc, vtx_rnd_info->vtx_pt, pt_xyz, &dist1);
    EMerr_hndlr( msg_loc != MSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
    MA2ptdis (&msg_loc, vtx_rnd_info->vtx_pt, 
              setback_info->setback_pts_xyz[undef_inx], &dist2);
    EMerr_hndlr( msg_loc != MSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

/*
    dist1 = BSdistptpt (&msg_loc, vtx_rnd_info->vtx_pt, pt_xyz);
    EMerr_hndlr( msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
    dist2 = BSdistptpt (&msg_loc, vtx_rnd_info->vtx_pt,
              setback_info->setback_pts_xyz[undef_inx]);
    EMerr_hndlr( msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
*/

    if (dist1 < dist2)
      {
      OM_BLOCK_MOVE (pt_xyz, setback_info->setback_pts_xyz[undef_inx],
                     sizeof (IGRpoint));
      setback_info->setback_pts_uv[undef_inx][V] = 
                    setback_info->setback_pts_uv[def_inx][V];
      }
    setback_info->setback_pt_stat [undef_inx] = setback_pt_defined;
    }
  else if (uniform_setback_solution)
    {
    for (i=FIRST; i<=SECOND; i++)
      {
      j = i == FIRST ? SECOND : FIRST;
      u_val = setback_info->setback_pts_uv[i][U];
      v_val = setback_info->setback_pts_uv[j][V];
      BSsfeval (ed_info->fill_surf, u_val, v_val, (IGRint)0, pt_xyz, &msg_loc);
      EMerr_hndlr( msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
      MA2ptdis (&msg_loc, vtx_rnd_info->vtx_pt, pt_xyz, &dist1);
      EMerr_hndlr( msg_loc != MSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
      MA2ptdis (&msg_loc, vtx_rnd_info->vtx_pt, 
                setback_info->setback_pts_xyz[i], &dist2);
      EMerr_hndlr( msg_loc != MSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
/*
      dist1 = BSdistptpt (&msg_loc, vtx_rnd_info->vtx_pt, pt_xyz);
      EMerr_hndlr( msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
      dist2 = BSdistptpt (&msg_loc, vtx_rnd_info->vtx_pt,
                setback_info->setback_pts_xyz[i]);
      EMerr_hndlr( msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
*/
      if (dist1 < dist2)
        {
        OM_BLOCK_MOVE (pt_xyz, setback_info->setback_pts_xyz[i],
                       sizeof (IGRpoint));
        setback_info->setback_pts_uv[i][V] = setback_info->setback_pts_uv[j][V];
        }
      }
    }

wrapup:
;
}

/*
    DESCRIPTION

    This function is a wrapper to generate an infinite plane intersection
    on the fillet. Also, if the intersection generated is of type poly3d,
    a bsp curve is fitted through it. Also, the intersection is oriented
    such that it flows from SECOND setback point to FIRST setback pont.

    HISTORY
  
    KNAP   : Aug'9 94 : Initial Writng.
 */
IGRlong EMgenerate_blend_bound_curve_on_fillet (EMmsg, md_env, vtx_rnd_info, 
                                                ed_bln_info, ed_rnd_info,
                                                edge_inx, bln_bnd_cv)
IGRlong                          *EMmsg;
struct GRmd_env                  *md_env;
struct EMSvtx_rnd_info           *vtx_rnd_info;
struct EMSedge_blend_info        *ed_bln_info;
struct EMSedge_rnd_info          *ed_rnd_info;
IGRint                           edge_inx;
struct EMSrnd_blend_curve_info   **bln_bnd_cv;
{
  IGRint      j;
  IGRshort    *mattyp;
  IGRushort   options =0;
  IGRlong     msg_loc, stat;
  IGRvector   vec1, sf_normal;
  IGRpoint    pt_xyz, ref_point;
  IGRdouble   u_val, v_val, cht_tol, *mat, start_pt[3], stop_pt[3];
  struct      EMSdataselect int_xyz_data;
  struct      EMSrnd_blend_curve_info   *bln_bnd_cv_proc_ptr;
  struct      EMSsfintedpar* EMsfintedpar_malloc();
  GRspacenum  os;

  *EMmsg = EMS_S_Success;
  stat = TRUE;
  bln_bnd_cv_proc_ptr = NULL;
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);
  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  os = md_env->md_id.osnum;
  int_xyz_data.datatype = EMSdata_null;

  /*
   * Generate an infinite plane intersection on the fillet.
   */
  u_val = 0.5;
  v_val = ((ed_bln_info->setback_pts_uv[FIRST][V] +
            ed_bln_info->setback_pts_uv[SECOND][V])/2.0);
  BSsfarrevn (&msg_loc, ed_rnd_info->fill_surf, (IGRint)1, &u_val,
              (IGRint)1, &v_val, pt_xyz, sf_normal);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  for (j=0; j<3; j++)
    vec1[j] = pt_xyz[j] +  sf_normal[j];

  /*
   * Allocate memory for the intesection to be generated.
   */
  bln_bnd_cv_proc_ptr = (struct EMSrnd_blend_curve_info *) om$malloc
                             (size = sizeof (struct EMSrnd_blend_curve_info));
  bln_bnd_cv_proc_ptr->prev = NULL;
  bln_bnd_cv_proc_ptr->next = NULL;
  EMinit_rnd_blend_curve_info (bln_bnd_cv_proc_ptr);
  bln_bnd_cv_proc_ptr->ed_info = ed_rnd_info;

  OM_BLOCK_MOVE (ed_bln_info->setback_pts_xyz[FIRST], ref_point,
                 sizeof (IGRpoint));
  options |= EMSrnd_fit_bsp_curve;

  /*
   * Generate the intersection.
   */
  EMget_fillet_intpln_data (&msg_loc, options, ed_rnd_info,
    ed_bln_info->setback_pts_xyz[FIRST],
    ed_bln_info->setback_pts_xyz[SECOND], vec1, ref_point, os,
    vtx_rnd_info->edge_stops[edge_inx], &bln_bnd_cv_proc_ptr->uv1,
    &int_xyz_data, NULL);
  EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  EMgetendpts_xyz (&msg_loc, mattyp, mat, &int_xyz_data, FALSE, (IGRint)1,
                   start_pt, stop_pt);
  EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  /*
   * Ensure that the blend curve flows from SECOND setback point to the
   * FIRST set back point.
   */
  if (EMis_geomequal_3dpt (start_pt, ed_bln_info->setback_pts_xyz[SECOND],
                           cht_tol*2) == FALSE)
    {
    EMdata_reverse (&int_xyz_data);
    EMdata_reverse (&bln_bnd_cv_proc_ptr->uv1);
    }
  
  /*
   * It is possible that the end points of the xyz and uv data are out of tol,
   * w.r.t. the setback points. Force the end points of the xyz and uv data, 
   * to lie on the set back points.
   */
  EMend_modify_data (&msg_loc, &md_env->md_env, &int_xyz_data, TRUE, 
                     ed_bln_info->setback_pts_xyz[SECOND]);
  EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);
                     
  EMend_modify_data (&msg_loc, &md_env->md_env, &int_xyz_data, FALSE, 
                     ed_bln_info->setback_pts_xyz[FIRST]);
  EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  EMend_modify_data (&msg_loc, &md_env->md_env, &bln_bnd_cv_proc_ptr->uv1,
                     TRUE, ed_bln_info->setback_pts_uv[SECOND]);
  EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);
                     
  EMend_modify_data (&msg_loc, &md_env->md_env, &bln_bnd_cv_proc_ptr->uv1,
                     FALSE, ed_bln_info->setback_pts_uv[FIRST]);
  EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  /*
   * Extract all the necessary info and storre it into output structure.
   */
  bln_bnd_cv_proc_ptr->tangent_sf_geom = ed_rnd_info->fill_surf;
  bln_bnd_cv_proc_ptr->tangent_sf_id = ed_rnd_info->fill_id;
  bln_bnd_cv_proc_ptr->xyz_geom = int_xyz_data.data.curve;
  int_xyz_data.datatype = EMSdata_null;

  /*
   * Assign two empty incident edge information for the FIRST and
   * the SECOND of this intersection.
   */
  bln_bnd_cv_proc_ptr->incident_info[FIRST] =
                       EMsfintedpar_malloc (&msg_loc, (IGRint)1);
  EMerr_hndlr (!bln_bnd_cv_proc_ptr->incident_info[FIRST], *EMmsg,
               EMS_E_NoDynamicMemory, wrapup);
  bln_bnd_cv_proc_ptr->incident_info[SECOND] =
                       EMsfintedpar_malloc (&msg_loc,(IGRint)1);
  EMerr_hndlr (!bln_bnd_cv_proc_ptr->incident_info[SECOND], *EMmsg,
               EMS_E_NoDynamicMemory, wrapup);

  *bln_bnd_cv = bln_bnd_cv_proc_ptr;
 
wrapup:
    return(stat);
}

/*
    DESCRIPTION
    
    This function validates the blend bound curves, for positional
    tangential continuity, and if the blend curves are tangential
    continuous, the setback points on the respective fillets are refined
    and new blend curves are generated on these fillets. Apart from these
    a new fillet iso-iso transition is added between these two fillets.

    HISTORY
  
    KNAP   : Aug'9 94 : Initial Writing.

*/
void EMvalidate_blend_bound_curves (EMmsg, md_env, bln_cvs_list, ed_bln_info,
                                    vtx_rnd_info, ed_infos, are_valid, 
                                    num_cvs_added)
IGRlong                          *EMmsg;
struct GRmd_env                  *md_env;
struct EMSedge_blend_info        *ed_bln_info;
struct EMSedge_rnd_info          **ed_infos;
struct EMSvtx_rnd_info           *vtx_rnd_info;
struct EMSrnd_blend_curve_info   **bln_cvs_list;
IGRboolean                       *are_valid;
IGRint                           *num_cvs_added;
{
  IGRlong  stat, msg_loc;
  IGRint j, k, this_inx, next_inx, num_bln_cvs = 0, num = 1;
  IGRboolean on_cv=FALSE;
  IGRdouble cvpar, dotp, bas_tol, ref_dotp;
  IGRpoint tan_vec1[2], tan_vec2[2];
  GRobjid tmp_ed_ids[2];
  struct EMSedge_rnd_info  *tmp_ed_infos[2];
  struct EMSedge_blend_info  *tmp_ed_bln_info[2];
  struct IGRbsp_curve  *bln_cv_geom1, *bln_cv_geom2;
  struct EMSrnd_blend_curve_info *bln_cvs_head, *bln_cvs_ptr,
                                 *bln_cvs_proc_ptr, *new_bln_cvs_ptr,
                                 *ptr_to_free;
  bln_cvs_head = *bln_cvs_list;
  bln_cvs_ptr = bln_cvs_head;
  new_bln_cvs_ptr = NULL;
  this_inx=0;
  *are_valid = TRUE;
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bas_tol);
  ref_dotp = cos( LIMITING_INC_ANG );
  /*
   * Take each pair of blend bound curves, and evaluate the tangent verctors
   * for both the curves at point of continuity.
   */
  do 
    {
    bln_cvs_proc_ptr = bln_cvs_ptr->next;
    if (bln_cvs_ptr->ed_info && bln_cvs_proc_ptr->ed_info)
      {
      next_inx = (this_inx+1)%vtx_rnd_info->num_edges;
      bln_cv_geom1 = bln_cvs_ptr->xyz_geom;
      bln_cv_geom2 = bln_cvs_proc_ptr->xyz_geom;
      BSprptoncv (&msg_loc, bln_cv_geom1, 
                  ed_bln_info[this_inx].setback_pts_xyz[FIRST],
                  &cvpar, &on_cv);
      EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
      BScveval (bln_cv_geom1, cvpar, (IGRint)1, tan_vec1, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
      BSnorvec (&msg_loc, tan_vec1[1]);

      BSprptoncv (&msg_loc, bln_cv_geom2, 
                  ed_bln_info[next_inx].setback_pts_xyz[SECOND],
                  &cvpar, &on_cv);
      EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
      BScveval (bln_cv_geom2, cvpar, (IGRint)1, tan_vec2, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
      BSnorvec (&msg_loc, tan_vec2[1]);

      dotp = BSdotp (&msg_loc, tan_vec1[1], tan_vec2[1]);
      /*
       * If dotp is less than 100*bas_tol, then regenerate the blend bound
       * curves with refined setback points.
       */
      if (fabs(dotp) > ref_dotp)
        {
        /*
         * Refine the setback points on this fillet and generate a new 
         * transition curve on this fillet. Also free up the memory of the
         * previous transition.
         */
        /*
         * Adjust the setback points on this fillet.
         */
        ed_bln_info[this_inx].setback_pt_stat[FIRST] = setback_pt_transient;
        EMadjust_setback_pts (&msg_loc, this_inx, vtx_rnd_info, 
          &ed_bln_info[this_inx], ed_infos[this_inx]);
        EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);

        /*
         * Generate the new blend bound curve on the fillet.
         */
        EMgenerate_blend_bound_curve_on_fillet (&msg_loc, md_env, 
          vtx_rnd_info, &ed_bln_info[this_inx], ed_infos[this_inx], this_inx,
          &new_bln_cvs_ptr);
        EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);
        
        ptr_to_free = bln_cvs_ptr;
        new_bln_cvs_ptr->next = bln_cvs_ptr->next;
        new_bln_cvs_ptr->prev = bln_cvs_ptr->prev;
        bln_cvs_ptr->next->prev = new_bln_cvs_ptr;
        bln_cvs_ptr->prev->next = new_bln_cvs_ptr;
        EMdealloc_rnd_blend_curve_info (&msg_loc, bln_cvs_ptr, num);
        om$dealloc (ptr = ptr_to_free);
        bln_cvs_ptr->prev = bln_cvs_ptr->next = NULL;
        bln_cvs_ptr = NULL;

        bln_cvs_ptr = new_bln_cvs_ptr;
        if (!this_inx)
          bln_cvs_head = bln_cvs_ptr;

        /*
         * Adjust the setback points on the next fillet.
         */
        ed_bln_info[next_inx].setback_pt_stat[SECOND] = setback_pt_transient;
        EMadjust_setback_pts (&msg_loc, next_inx, vtx_rnd_info, 
          &ed_bln_info[next_inx], ed_infos[next_inx]);
        EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);

        /*
         * Generate a new fillet iso-iso transition from this fillet to
         * the next fillet iso and insert it into the blend curve list.
         */
        for (j=FIRST, k=this_inx; j<=SECOND; j++, k=next_inx)
          {
          tmp_ed_infos[j]    = ed_infos[k];
          tmp_ed_ids[j]      = ed_bln_info[k].ed_ids[j];
          tmp_ed_bln_info[j] = &ed_bln_info[k];
          }
        new_bln_cvs_ptr = NULL;
  
        stat = EMget_bln_cv_from_fillet_or_edge (&msg_loc, (IGRushort) 0,
                 md_env, tmp_ed_infos, tmp_ed_ids, tmp_ed_bln_info,
                 &new_bln_cvs_ptr);
        EMerr_hndlr (EMSerror (stat & msg_loc), *EMmsg, EMS_E_Fail, wrapup);

        bln_cvs_ptr->next = new_bln_cvs_ptr;
        new_bln_cvs_ptr->prev = bln_cvs_ptr;
        new_bln_cvs_ptr->next = bln_cvs_proc_ptr;
        bln_cvs_proc_ptr->prev = new_bln_cvs_ptr;
        bln_cvs_ptr = new_bln_cvs_ptr;
        num_bln_cvs++;

        /*
         * Generate the new blend bound curve on this fillet.
         */
        new_bln_cvs_ptr = NULL;
        EMgenerate_blend_bound_curve_on_fillet (&msg_loc, md_env, 
          vtx_rnd_info, &ed_bln_info[next_inx], ed_infos[next_inx], next_inx,
          &new_bln_cvs_ptr);
        EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);

        new_bln_cvs_ptr->next = bln_cvs_proc_ptr->next;
        bln_cvs_proc_ptr->next->prev = new_bln_cvs_ptr;
        new_bln_cvs_ptr->prev = bln_cvs_ptr;
        bln_cvs_ptr->next = new_bln_cvs_ptr;

        EMdealloc_rnd_blend_curve_info (&msg_loc, bln_cvs_proc_ptr, num);
        om$dealloc (ptr = bln_cvs_proc_ptr);
        bln_cvs_proc_ptr->prev = bln_cvs_proc_ptr->next = NULL;
        bln_cvs_proc_ptr = NULL;

        bln_cvs_proc_ptr = new_bln_cvs_ptr;
        if (!next_inx)
          bln_cvs_head = bln_cvs_proc_ptr;

        *are_valid = FALSE;
        if (!next_inx)
          break;
        }
      this_inx++;
      }
      bln_cvs_ptr = bln_cvs_proc_ptr;
    }
  while (bln_cvs_proc_ptr != bln_cvs_head);
  *num_cvs_added = num_bln_cvs;
  *bln_cvs_list = bln_cvs_head;

wrapup:;
}

end implementation EMSsfrndbool;
