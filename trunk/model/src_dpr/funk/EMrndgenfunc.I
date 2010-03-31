/*
 * This file contains a collection of functions that get called from
 * other functions or methods in rounding. These functions are specific
 * to the rouding functionality.
 */

class implementation EMSsfrndbool;

#include <math.h>
#include "OMmacros.h"
#include "msmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsconic.h"
#include "emsedgedef.h"
#include "EMSbnd.h"
#include "bsgeom_cvsf.h"
#include "EMSrndprotyp.h"
#include "emsinterdef.h"
#include "bststcvfarc.h"
#include "bsparameters.h"
#include "bsmdistptsf.h"
#include "bsmdistcvcv.h"
#include "bsfreesf.h"
#include "bsfreecv.h"
#include "bsconstprcv.h"
#include "bsarclength.h"
#include "bsalloccv.h"
#include "bscvarrevt.h"
#include "bsnorvec.h"
#include "bsmdstptcv.h"
#include "bssfploutcv.h"

#define ARR_INCR  16

#define  SQUARE(x)  ((x) * (x))

#define CONST_U  1
#define CONST_V  2

#define U0 0
#define V1 1
#define U1 2
#define V0 3

#define FIRST  0
#define SECOND 1
#define THIRD  2
#define LAST   1

#define START 0
#define STOP  1

#define MIN  0
#define MAX  1

#define ALL_POLY	 0
#define XYZ_CVS          1
#define XYZ_AND_UV_CVS   3
#define XYZ_AND_UV1_CVS  4
#define XYZ_AND_UV2_CVS  5

#define MAX_TO_STACK_ALLOC 8

#define DIM_XYZ_SPACE 3

from EMSboundary import EMget_edges, EMgetsurface_info;
from EMSedge import EMset_props, EMget_edge_length;
from EMSedge import EMget_props, EMchkconvex, EMget_bcxyz_geom, EMgetvtxedges;
from EMSedge import EMedpytrimint, EMedbstrimint;
from EMSpartedge import EMpeinit;
from EMSsubbs import EMget_edges;

void EMget_rnd_included_data (msg, rnd_info_1, rnd_info_2, vtx_pt,
                              sf_obj, sf_geom, sf_param, f_params, isocvs,
                              point)
IGRlong *msg;
struct EMSedge_rnd_info *rnd_info_1, *rnd_info_2;
IGRpoint vtx_pt;
GRobjid *sf_obj;
struct IGRbsp_surface **sf_geom;
IGRdouble sf_param[2], f_params[2][2];
struct IGRbsp_curve *isocvs[2];
IGRpoint point;
{
  IGRboolean this_surf;
  IGRint i, uinx1, uinx2, mininx, numpts;
  IGRlong msg_loc;
  IGRdouble mindist, loc_sf_tol, cht_tol;
  IGRpoint minpt, dumpt, *xyzpts, dumpster;
  GRobjid loc_sf_obj; 
  struct IGRbsp_curve *cv1, *cv2;
  struct IGRbsp_surface *p_sf, *loc_sf_geom;
  struct EMSpypoint *uvpts, *intpts1, *intpts2;

  *msg = EMS_S_Success;

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);
  cv1 = cv2 = NULL;
  intpts1 = intpts2 = NULL;
  xyzpts = NULL;

  if (isocvs)
    isocvs[FIRST] = isocvs[SECOND] = NULL;

  /*
   * Obtain information from the EMSedge_rnd_info structure
   * that is directly available into local variables.
   */

  if (IF_EQ_OBJID (rnd_info_1->surf_id, rnd_info_2->surf_id) ||
       IF_EQ_OBJID (rnd_info_1->surf_id, rnd_info_2->com_surf_id))
    {
    loc_sf_obj = rnd_info_1->surf_id;
    loc_sf_geom = rnd_info_1->surf;
    loc_sf_tol = rnd_info_1->surf_tol;
    this_surf = TRUE;
    }
  else if (IF_EQ_OBJID (rnd_info_1->com_surf_id, rnd_info_2->surf_id) ||
           IF_EQ_OBJID (rnd_info_1->com_surf_id, rnd_info_2->com_surf_id))
    {
    loc_sf_obj = rnd_info_1->com_surf_id;
    loc_sf_geom = rnd_info_1->com_surf;
    loc_sf_tol = rnd_info_1->com_surf_tol;
    this_surf = FALSE;
    }
  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

  if (sf_obj)
    *sf_obj = loc_sf_obj;
  if (sf_geom)
    *sf_geom = loc_sf_geom;

  if (!(sf_param || f_params || isocvs || point))
    goto ret_end; 

  /*
   * Obtain the appropriate iso-curves of the fillets on the
   * included surface.
   */

  p_sf = rnd_info_1->fill_surf;
  uinx1 = this_surf ? FIRST : SECOND;
  cv1 = rnd_info_1->fill_isocvs[uinx1];

  p_sf = rnd_info_2->fill_surf;
  uinx2 = IF_EQ_OBJID (loc_sf_obj, rnd_info_2->surf_id) ? FIRST : SECOND;
  cv2 = rnd_info_2->fill_isocvs[uinx2];

  if (isocvs)
    {
    isocvs[FIRST] = cv1;
    isocvs[SECOND] = cv2;
    }

  /*
   * Obtain the intersection points between the two iso-curves by
   * intersecting the mapped iso-curves and then evaluating
   * the resulting uv intersection points into xyz space. Pick the
   * point closest to the input vertex point.
   */

  EFget_intersection_points (&msg_loc, loc_sf_tol, NULL, NULL,
   &rnd_info_1->fill_isocvs_onsfs[uinx1], FALSE,
   &rnd_info_2->fill_isocvs_onsfs[uinx2], FALSE,
   &numpts, &intpts1, &intpts2);

  xyzpts = (IGRpoint *) alloca (numpts * sizeof (IGRpoint));
  EMerr_hndlr (!xyzpts, *msg, EMS_E_NoStackMemory, ret_end);

  uvpts = intpts1;
  for (i=0; i<numpts; i++)
    {
    BSsfeval (loc_sf_geom, uvpts->point[U], uvpts->point[V], 0,
     (IGRpoint *) xyzpts[i], &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    uvpts = uvpts->next;
    }

  EFfind_the_closest_pt (&msg_loc, 3, vtx_pt, numpts, xyzpts, &mininx, minpt);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Fill up the required output
   */

  if (f_params)
    {
    f_params[FIRST][U] = this_surf ? 0.0 : 1.0;
    BSmdstptcv (cv1, minpt, &f_params[FIRST][V], dumpt, &mindist, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    f_params[SECOND][U] = IF_EQ_OBJID (loc_sf_obj, rnd_info_2->surf_id) ?
                           0.0 : 1.0;
    BSmdstptcv (cv2, minpt, &f_params[SECOND][V], dumpster, &mindist, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    /*
     * If the xyz points of the intersection of two iso are not
     * within tolerance, it means there is some problem in the 
     * uv intersection of the iso's. Try generating the intersection
     * in model space. - KNAP.
     */
    if (!EMis_geomequal_3dpt (dumpt, dumpster, 2*cht_tol))
      {
      IGRint num_int_pts = 0;
      IGRdouble *int_pts_par1, *int_pts_par2;
      IGRpoint *int_pts1, *int_pts2;
      BSmdistcvcv (cv1, cv2, &num_int_pts, &int_pts_par1, &int_pts_par2,
                   &int_pts1, &int_pts2, &mindist, &msg_loc);
      if (msg_loc == BSSUCC)
        {
        if (mindist <= 2*cht_tol)
          {
          f_params[FIRST][V] = int_pts_par1[0];
          f_params[SECOND][V] = int_pts_par2[0];
          OM_BLOCK_MOVE (int_pts1[0], minpt, sizeof(IGRpoint));
          }
        }
      }
    }

  if (sf_param)
    {
    BSmdistptsf (&msg_loc, loc_sf_geom, minpt, &sf_param[U], &sf_param[V],
     dumpt, &mindist); 
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    }

  if (point)
    OM_BLOCK_MOVE (minpt, point, sizeof (IGRpoint));

ret_end:
  if (intpts1)
    EMpypoint_free (intpts1, MAXINT);
  if (intpts2)
    EMpypoint_free (intpts2, MAXINT);

  return;
}



void EMforce_v_degeneracy (msg, sf, sf_id, sf_props, deg_iso, non_deg_iso)
IGRlong *msg;
struct IGRbsp_surface *sf;
struct GRid *sf_id;
IGRushort *sf_props;
struct IGRbsp_curve **deg_iso, **non_deg_iso;
{
  IGRboolean tst_plan;
  IGRushort chkside;
  IGRshort isodir;
  IGRint count;
  IGRint i,  deg_side, four=4;
  IGRlong stat_OM, msg_loc;
  IGRdouble v, chttol, lens[2], start_par, stop_par;
  struct GRid *idptr, natids[4];
  struct IGRbsp_curve *cvs[2];
  struct GRmd_env md_env;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  cvs[FIRST] = cvs[SECOND] = NULL;

  for (i=FIRST; i<=SECOND; i++)
    {  
    BSalloccv (sf->u_order, sf->u_num_poles, sf->rational, 0,
     &cvs[i], &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    v = (IGRdouble) i;
    tst_plan = TRUE;
    isodir = CONST_V;
    BSconstprcv (&msg_loc, sf, &isodir, &v, &tst_plan, cvs[i]);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    start_par = 0.0;
    stop_par = 1.0;
    BSarclength (&msg_loc, cvs[i], &start_par, &stop_par, &lens[i]);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    }

  if (lens[FIRST] < lens[SECOND])
    *sf_props |= EMSfillet_v0_is_degenerate;
  else
    *sf_props |= EMSfillet_v1_is_degenerate;

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
  if (lens[FIRST] < chttol)
    *sf_props |= EMSfillet_v0_is_degenerate;
  if (lens[SECOND] < chttol)
    *sf_props |= EMSfillet_v1_is_degenerate;

  EMgetmdenv (&md_env, NULL, NULL, sf_id->osnum);
  idptr = natids;
  count = 0;
  stat_OM = om$send (msg = message EMSsubbs.EMget_edges (&msg_loc,
             MAXINT, EMS_OPT_NATURAL, &md_env, &idptr, &four,
             &count), targetid = sf_id->objid,
             targetos = sf_id->osnum, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

  for (i=FIRST; i<=SECOND; i++)
    {
    chkside = i == FIRST ? 
               EMSfillet_v0_is_degenerate : EMSfillet_v1_is_degenerate;
    if (*sf_props & chkside)
      {
      deg_side = i == FIRST ? V0 : V1;
      stat_OM = om$send (msg = message EMSedge.EMset_props (&msg_loc,
                 EMED_DEGENERATE, EMS_O_ON), 
                 targetid = natids[deg_side].objid,
                 targetos = sf_id->osnum, senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
      }
    }

  if (deg_iso)
    {
    if (*sf_props & EMSfillet_v0_is_degenerate)
      {
      *deg_iso = cvs[FIRST];
      cvs[FIRST] = NULL;
      }
    else
      {
      *deg_iso = cvs[SECOND];
      cvs[SECOND] = NULL;
      }
    }

  if (non_deg_iso)
    {
    if (*sf_props & EMSfillet_v0_is_degenerate)
      {
      *non_deg_iso = cvs[SECOND];
      cvs[SECOND] = NULL;
      }
    else
      {
      *non_deg_iso = cvs[FIRST];
      cvs[FIRST] = NULL;
      }
    }

ret_end:
  if (EMSerror (stat_OM))
    *msg = EMS_E_OMerror;

  for (i=FIRST; i<=SECOND; i++)
    if (cvs[i])
      BSfreecv (&msg_loc, cvs[i]);
  return;
}


/*
  DESCRIPTION:

    This function is used to output the V-parameter at which the fillet
    intersects a given edge on the surface. The V-isocurve on the fillet
    as well as the point of intersection between the fillet and the
    intersection may be returned. The fillet is input as an EMSedge_rnd_info
    with all relevant fields initialized. The input EMSedge must be an edge
    that lies on one of the surfaces that support the fillet. 

    The iso-curves are returned oriented such that they enclose the area
    that is not at the end where the intersection takes place.

  OUTPUT
    
    Any of the output arguments can be NULL: fill_uv_iso, fill_xyz_iso, intpt

  HISTORY:

    Janaka : November 30, 1992 : Origin.
    SS     : October  25, 1993 : Re-write.
*/

#argsused

IGRdouble EMget_fillet_int_data (msg, rnd_info, edge, os, int_at_stop,
                                 int_iso_type, fill_uv_iso, fill_xyz_iso,
                                 edge_par, intpt)
IGRlong *msg;
struct EMSedge_rnd_info	*rnd_info;
GRobjid edge;
GRspacenum os;
IGRboolean int_at_stop;
IGRint     *int_iso_type;
struct EMSdataselect *fill_uv_iso, *fill_xyz_iso;
IGRdouble *edge_par;
IGRdouble *intpt;
{
  IGRboolean dir;
  IGRushort props;
  IGRuint count; 
  IGRint dumnum, num_ints, i;
  IGRlong msg_loc, stat;
  IGRdouble chttol, lentol, uv_tol, dist, mindist, par, vpar, dumpar;
  IGRdouble uvpt[2];
  IGRdouble *vtxpt, knots[4];
  IGRpoint poles[2], dumpt, temp_xyzpt, xyzpt;
  GRobjid nxt_edge, ref_edge, uv_edge, comm_edge, edge_sf, comm_edge_sf;
  struct GRmdenv_info mdenv_info;
  struct IGRbsp_curve *f_isocv, ed_cv, ln_cv;
  struct IGRbsp_surface *sf;
  struct EMSpypoint *pypts, *pyptr;
  struct EMSpartolbasis ptolbas;
  struct EMSdataselect *f_uv_isocv;
  OM_S_CHANSELECT chan_to_common;
  OM_S_OBJECT_LINKAGE objlist;
  extern IGRdouble BSdistptpt();

  *msg = EMS_S_Success;

  vpar = 0.0;

  pypts = NULL;
  ed_cv.poles = ed_cv.knots = ed_cv.weights = NULL;

  /*
   * Obtain surfaces defining the input edge.
   */

  edge_sf = NULL_OBJID;
  om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
   &edge_sf, NULL), targetid = edge, targetos = os, senderid = NULL_OBJID);
  EMerr_hndlr (IF_NULL_OBJID (edge_sf), *msg, EMS_E_InvalidCase, ret_end);

  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);
  count = 0;
  om$get_channel_objects (objid = edge, osnum = os,
   p_chanselect = &chan_to_common, list = &objlist, size = 1,
   count = &count);
  EMerr_hndlr (!count, *msg, EMS_E_InvalidCase, ret_end);
  comm_edge = objlist.S_objid;

  comm_edge_sf = NULL_OBJID;
  om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
   &comm_edge_sf, NULL), targetid = comm_edge, targetos = os, 
   senderid = NULL_OBJID);
  EMerr_hndlr (IF_NULL_OBJID (comm_edge_sf), *msg, EMS_E_InvalidCase, ret_end);
  
  /*
   * Determine which of the two uv-edges interact with the fillet. 
   * Get all the other relevant pieces of information for the intersection
   * computation.
   */

  if (rnd_info->surf_id == edge_sf || 
      rnd_info->surf_id == comm_edge_sf)
    {
    if (rnd_info->surf_id == edge_sf)
      uv_edge = edge;
    else
      uv_edge = comm_edge;

    sf = rnd_info->surf;
    f_isocv = rnd_info->fill_isocvs[FIRST];
    f_uv_isocv = &rnd_info->fill_isocvs_onsfs[FIRST];
    uv_tol = rnd_info->surf_tol;
    if (int_iso_type)
      *int_iso_type = FIRST;
    }
  else if (rnd_info->com_surf_id == edge_sf || 
      rnd_info->com_surf_id == comm_edge_sf)
    {
    if (rnd_info->com_surf_id == edge_sf)
      uv_edge = edge;
    else
      uv_edge = comm_edge;

    sf = rnd_info->com_surf;
    f_isocv = rnd_info->fill_isocvs[SECOND];
    f_uv_isocv = &rnd_info->fill_isocvs_onsfs[SECOND];
    uv_tol = rnd_info->com_surf_tol;
    if (int_iso_type)
      *int_iso_type = SECOND;
    }
  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);}

  /*
   * If the input edge is a seam-edge (edge_sf and comm_edge_sf are the same)
   * then use the next-edge at the vertex as the criterion to decide which
   * uv-edge to use. If this test does not yield an answer, leave the
   * current choice alone.
   */

  if (edge_sf == comm_edge_sf)
    {
    if (sf == rnd_info->com_surf)
      {
      props = NULL;
      om$send (msg = message EMSedge.EMget_props (&msg_loc, &props),
       targetid = rnd_info->edge_id, targetos = os, senderid = NULL_OBJID);
      if (props & EMED_REVERSE_CONNECT)
        dir = !int_at_stop;
      else        
        dir = int_at_stop;

      objlist.S_objid = NULL_OBJID;
      om$get_channel_objects (objid = rnd_info->edge_id, osnum = os,
       p_chanselect = &chan_to_common, count = &count, size = 1, 
       list = &objlist);
      ref_edge = objlist.S_objid;
      }
    else
      {
      dir = int_at_stop;
      ref_edge = rnd_info->edge_id;
      }

    nxt_edge = NULL_OBJID;
    EMgetnxtedges (&msg_loc, NULL, ref_edge, OM_Gw_current_OS, dir, 1,
     &dumnum, &nxt_edge, &props, &dumnum);
    if (nxt_edge == edge)
      uv_edge = edge;
    else if (nxt_edge == comm_edge)
      uv_edge = comm_edge;
    }

  /*
   * Perform an intersection operation in uv between the mapped 
   * U0 or U1 iso-curve and the edge. Determine the V-parameter
   * value on the fillet at which this intersection point occurs.
   * All ambiguity is resolved by proximity checks with the vertex
   * point. The tolerance used is the equivalent cht tol in uv-space.
   */

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  ptolbas.tol = uv_tol * (chttol / lentol);
  ptolbas.is_valid = TRUE;
  num_ints = 0;
  if (f_uv_isocv->datatype == EMSdata_curve3d)
    om$send (msg = message EMSedge.EMedbstrimint (&msg_loc, 
     f_uv_isocv->data.curve, NULL,
     &ptolbas, NULL, NULL, &num_ints, NULL, &pypts),
     targetid = uv_edge, senderid = NULL_OBJID);
  else if (f_uv_isocv->datatype == EMSdata_poly2d)
    om$send (msg = message EMSedge.EMedpytrimint (&msg_loc, 
     f_uv_isocv->data.poly, NULL,
     &ptolbas, NULL, NULL, &num_ints, NULL, &pypts),
     targetid = uv_edge, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (!num_ints, *msg, EMS_E_NoIntersection, ret_end);

  /*
   * If more than one intersections result, chose the one with
   * closest xyz proximity to the vertex.
   */

  if (int_at_stop)
    vtxpt = rnd_info->stop_vtx->vtx_pt;
  else
    vtxpt = rnd_info->start_vtx->vtx_pt;

  pyptr = pypts;
  BSsfeval (sf, pyptr->point[U], pyptr->point[V], 0, temp_xyzpt, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  mindist = BSdistptpt (&msg_loc, temp_xyzpt, vtxpt);

  OM_BLOCK_MOVE (pyptr->point, uvpt, 2 * sizeof (IGRdouble));
  OM_BLOCK_MOVE (temp_xyzpt, xyzpt, 3 * sizeof (IGRdouble));

  for (i=1; i<num_ints; i++)
    {
    pyptr = pyptr->next;
    
    BSsfeval (sf, pyptr->point[U], pyptr->point[V], 0, temp_xyzpt, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    if ((dist = BSdistptpt (&msg_loc, temp_xyzpt, vtxpt)) < mindist)
      {
      OM_BLOCK_MOVE (pyptr->point, uvpt, 2 * sizeof (IGRdouble));
      OM_BLOCK_MOVE (temp_xyzpt, xyzpt, 3 * sizeof (IGRdouble));
      mindist = dist;
      }
    }

  /*
   * Compute the v-parameter on the fillet surface knowing that the
   * xyz U-iso-curve stored with fillet-data is parameterized the same
   * way as the surface. This is obtained by finding the corresponding
   * parameter value on the curve relating to xyzpt determined above.
   *
   * In the first attempt, try to find the local minima
   * between the fillet-isocurve and the neutral edge in model-space,
   * using the xyzpt obtained above. If this local minima is 'very' far off
   * the initial guess-point, then assume that this approach did not work
   * and revert back to the 'guess-point' as the true point. 
   */

  EMidmatrix (&msg_loc, &mdenv_info.matrix_type, mdenv_info.matrix);
  om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc, &mdenv_info,
   NULL, sf, 0, MAXINT, FALSE, NULL, &ed_cv), targetid = uv_edge,
   targetos = os, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

  ln_cv.poles = (IGRdouble *) poles;
  ln_cv.knots = knots;
  BSlnn2cvs (&msg_loc, f_isocv, &ed_cv, xyzpt, xyzpt, &ln_cv, &par, &dumpar);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  dist = BSdistptpt (&msg_loc, xyzpt, poles[FIRST]);
  if (dist > 100.0 * chttol)
    {
    BSmdstptcv (f_isocv, xyzpt, &vpar, dumpt, &mindist, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    }
  else
    {
    OM_BLOCK_MOVE (poles[FIRST], xyzpt, sizeof (IGRpoint));
    vpar = par;
    }

  /*
   * Prepare the rest of the output
   */

  EMget_iso_data (&msg_loc, rnd_info->fill_surf, vpar, FALSE, 
   fill_uv_iso, fill_xyz_iso);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Orient it correctly
   */

  if ((rnd_info->props & EMSfillet_v0_closeto_start_end ? 0x1 : 0x0) ^
      (int_at_stop ? 0x1 : 0x0))
    {
    if (fill_uv_iso)
      EMdata_reverse (fill_uv_iso);
    if (fill_xyz_iso)
      EMdata_reverse (fill_xyz_iso);
    }

  if (edge_par)
    {
    BSmdstptcv (&ed_cv, xyzpt, edge_par, dumpt, &mindist, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    }
  
  if (intpt)
    OM_BLOCK_MOVE (xyzpt, intpt, sizeof (IGRpoint));

ret_end:
  if (pypts)
    EMpypoint_free (pypts, MAXINT);
  if (ed_cv.poles)
    om$dealloc (ptr = ed_cv.poles);
  if (ed_cv.knots)
    om$dealloc (ptr = ed_cv.knots);
  if (ed_cv.weights)
    om$dealloc (ptr = ed_cv.weights);

  stat = TRUE;
  EMWRAPUP (*msg, stat, "EMget_fillet_int_pt");
  return (vpar);
}


/*
  DESCRIPTION:

    This function is used to output the V-value on a fillet at which a
    given point has a minimum distance characteristic. Optionally, it 
    extracts the v-constant iso curve of the fillet. The fillet is input as
    an EMSedge_rnd_info with all relevant fields initialized. 

    The iso-curves are returned oriented such that they enclose the area
    that is not at the end where the intersection takes place.

  OUTPUT
    
    Any of the output arguments can be NULL: v_uv_iso, v_xyz_iso, reverse_flag.

  HISTORY:

    Janaka : November 30, 1992 : Origin.
    SS     : October  25, 1993 : Re-write.
*/

#argsused

IGRdouble EMget_fillet_minpt_data (msg, rnd_info, pt, os, pt_at_stop,
                                   fill_uv_iso, fill_xyz_iso)
IGRlong *msg;
struct EMSedge_rnd_info	*rnd_info;
IGRpoint pt;
GRspacenum os;
IGRboolean pt_at_stop;
struct EMSdataselect *fill_uv_iso, *fill_xyz_iso;
{
  IGRint i;
  IGRlong msg_loc, stat;
  IGRdouble mindist, vpar, v[2];
  IGRdouble dumpt[3];
  extern IGRdouble BSdistptpt();

  *msg = EMS_S_Success;

  vpar = 0.0;

  /*
   * The v-par value is obtained by projecting the input point onto the
   * U0 and the U1 iso-curves of the fillet and determining the average.
   */

  for (i=FIRST; i<=SECOND; i++)
    {
    BSmdstptcv (rnd_info->fill_isocvs[i], pt, &v[i], dumpt, &mindist, 
     &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    }
  vpar = (v[FIRST] + v[SECOND]) / 2.0;

  /*
   * Prepare the rest of the output
   */

  EMget_iso_data (&msg_loc, rnd_info->fill_surf, vpar, FALSE,
   fill_uv_iso, fill_xyz_iso);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Orient the output
   */

  if ((rnd_info->props & EMSfillet_v0_closeto_start_end ? 0x1 : 0x0) ^
      (pt_at_stop ? 0x1 : 0x0))
    {
    if (fill_uv_iso)
      EMdata_reverse (fill_uv_iso);
    if (fill_xyz_iso)
      EMdata_reverse (fill_xyz_iso);
    }

ret_end:
  stat = TRUE;
  EMWRAPUP (*msg, stat, "EMget_fillet_minpt_pt");
  return (vpar);
}


/*
  DESCRIPTION:

    This function is used to output the sort of V-intersection curve on a
    fillet which is defined as the intersection of the fillet with a plane
    defined by the input 3 points. In the case of multiple interesctions
    the one in the vicinity of the input reference point is chosen.
    The fillet is input as an EMSedge_rnd_info with all relevant fields 
    initialized. The input 3 points may not be colinear.

    The uv-curves are returned oriented such that they enclose the area
    that is not at the end where the intersection takes place.

  OUTPUT
    
    Any of the output arguments can be NULL: fill_uv_iso, fill_xyz_iso, intpln

  HISTORY:

    SS  :  Nov 17, 1993 :  Creation
*/

#argsused

void EMget_fillet_intpln_data (msg, options, rnd_info, p1, p2, p3, in_refpt, os,
                               int_at_stop, fill_uv_int, fill_xyz_int, intpln)
IGRlong *msg;
IGRushort options;
struct EMSedge_rnd_info	*rnd_info;
IGRpoint p1, p2, p3;
IGRdouble *in_refpt;
GRspacenum os;
IGRboolean int_at_stop;
struct EMSdataselect *fill_uv_int, *fill_xyz_int;
struct IGRplane *intpln;
{
  IGRboolean is_xyz_cvs, dumbool, reverse;
  IGRshort cvscode;
  IGRint i, j, inx, num_grps, tot_num_ints, *num_ints_grp, *num_pts_int,
         num_cv_grps, *num_cvs_per_grp;
  IGRlong msg_loc, stat;
  IGRdouble lentol, dist, mindist, dumpar, u_start, u_stop;
  IGRdouble ***myuvpts, ***otheruvpts, ***xyzpts;
  IGRdouble (*uvpts)[2], *refpt;
  IGRpoint dumpt, pts[3];
  IGRvector norm;
  struct IGRpolyline py, *p_py;
  struct EMSpypoint pypt;
  struct BSgeom_bsp_surf pln, fsf;
  struct BSgeom_bsp_curve *xyz_cvs, *uv1_cvs, *uv2_cvs;
  struct IGRbsp_curve     ***out_cvs;
  extern void getsftype();

  *msg = EMS_S_Success;
  stat = TRUE;

  num_cv_grps = 0;
  num_cvs_per_grp = NULL;
  out_cvs = NULL;

  num_grps = 0;
  num_ints_grp = NULL;
  num_pts_int = NULL;
  myuvpts = NULL;
  otheruvpts = NULL;
  xyzpts = NULL;
  xyz_cvs = NULL;
  uv1_cvs = NULL;
  uv2_cvs = NULL;
  pln.sfgen_cv = NULL;
  fsf.sfgen_cv = NULL;

  /*
   * Construct the plane data.
   */

  OM_BLOCK_MOVE (p1, pts[FIRST], sizeof (IGRpoint));
  OM_BLOCK_MOVE (p2, pts[SECOND], sizeof (IGRpoint));
  OM_BLOCK_MOVE (p3, pts[THIRD], sizeof (IGRpoint));
  BStst_plan (3, (IGRdouble *) pts, NULL, &dumbool, norm, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  pln.geom_prop = TRUE;
  pln.type = BSINF_PLANE;
  pln.bounded = FALSE;
  OM_BLOCK_MOVE (p1, pln.pt1, sizeof (IGRpoint));
  OM_BLOCK_MOVE (norm, pln.vec1, sizeof (IGRvector));

  /*
   * Construct the fillet surface data.
   */

  fsf.geom_prop = FALSE;
  getsftype (rnd_info->fill_id, os, &fsf.type);
  fsf.bounded = TRUE;
  fsf.urange[MIN] = fsf.vrange[MIN] = 0.0;
  fsf.urange[MAX] = fsf.vrange[MAX] = 1.0;
  fsf.bspsf = rnd_info->fill_surf;

  /*
   * Intersect the two pieces of data.
   */

  BSsfsfint (&pln, &fsf, &num_grps, &num_ints_grp, &num_pts_int,
   &xyzpts, &myuvpts, &otheruvpts, 
   &cvscode, &xyz_cvs, &uv1_cvs, &uv2_cvs, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  tot_num_ints = 0;
  for (i=0; i<num_grps; i++)
    tot_num_ints += num_ints_grp[i];
  is_xyz_cvs = cvscode == XYZ_AND_UV_CVS ||
               cvscode == XYZ_AND_UV1_CVS ||
               cvscode == XYZ_AND_UV2_CVS;

  /*
   * In the case of multiple intersections determine the group to be returned
   * by proximity check to the vtx.
   */

  if (in_refpt)
    refpt = in_refpt;
  else
    {
    if (int_at_stop)
      refpt = rnd_info->stop_vtx->vtx_pt;
    else
      refpt = rnd_info->start_vtx->vtx_pt;
    }
  if (tot_num_ints > 1)
    {
    inx = UNDEFINED;
    mindist = MAXDOUBLE;
    BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
    for (i=0; i<tot_num_ints; i++)
      {
      if (is_xyz_cvs)
        {
        BSmdstptcv (xyz_cvs[i].bspcv, refpt, &dumpar, dumpt, &dist, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);
        }
      else
        {
        py.num_points = num_pts_int[i];
        py.points = (IGRdouble *) xyzpts[i];
        EMcnvtpypts (&msg_loc, &py, 3, 1, refpt, lentol, &pypt, &dist);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }

      if (dist < mindist)
        {
        inx = i;
        mindist = dist;
        }
      }
    }
  else if (tot_num_ints == 1)
    inx = FIRST;
  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_Fail, ret_end);}

  /*
   * Format the output. Also preserve the U-values of the two ends of the
   * uv-curve on the fillet. This latter information is needed for orientation
   * further down.
   */

  uvpts = (IGRdouble (*)[]) otheruvpts[inx];
  u_start = uvpts[FIRST][U];
  u_stop = uvpts[num_pts_int[inx]-1][U];

  if (fill_uv_int)
    {
    fill_uv_int->datatype = EMSdata_poly2d;
    p_py = (struct IGRpolyline *) om$malloc (size = sizeof
            (struct IGRpolyline));
    EMerr_hndlr (!p_py, *msg, EMS_E_NoDynamicMemory, ret_end);
    p_py->num_points = num_pts_int[inx];
    p_py->points = (IGRdouble *) otheruvpts[inx];
    fill_uv_int->data.poly = p_py;
    otheruvpts[inx] = NULL;
    p_py = NULL;   
    }

  if (fill_xyz_int)
    {
    if (is_xyz_cvs)
      {
      fill_xyz_int->datatype = EMSdata_curve3d;
      fill_xyz_int->data.curve = xyz_cvs[i].bspcv;
      xyz_cvs[i].bspcv = NULL;
      }
    else
      {
      fill_xyz_int->datatype = EMSdata_poly3d;
      p_py = (struct IGRpolyline *) om$malloc (size = sizeof
              (struct IGRpolyline));
      EMerr_hndlr (!p_py, *msg, EMS_E_NoDynamicMemory, ret_end);
      p_py->num_points = num_pts_int[inx];
      p_py->points = (IGRdouble *) xyzpts[inx];
      fill_xyz_int->data.poly = p_py;
      xyzpts[inx] = NULL;
      p_py = NULL;
      }
    }

  if (intpln)
    {
    OM_BLOCK_MOVE (p1, intpln->point, sizeof (IGRpoint));
    OM_BLOCK_MOVE (norm, intpln->normal, sizeof (IGRvector));
    }

  /*
   * Orient the curve data correctly. The logic to reverse is first derived
   * assuming that uv-data flows from LO to HI in parametric space, ie,
   * from U=0 to U=1. If this is not TRUE then the logic is to simply 
   * flip this decision.
   */

  if ((rnd_info->props & EMSfillet_v0_closeto_start_end ? 0x1 : 0x0) ^
      (int_at_stop ? 0x1 : 0x0))
    reverse = TRUE;
  else
    reverse = FALSE;

  if (u_start > u_stop)
    reverse = !reverse;

  if (reverse)
    {
    if (fill_uv_int)
      EMdata_reverse (fill_uv_int);
    if (fill_xyz_int)
      EMdata_reverse (fill_xyz_int);
    }

  if (options & EMSrnd_fit_bsp_curve)
    {
    if (fill_xyz_int->datatype == EMSdata_poly3d)
      {
      BSsfploutcv( rnd_info->fill_surf, refpt, norm, (IGRint)1,
                   (IGRint *)&fill_xyz_int->data.poly->num_points,
                   (IGRpoint **)&fill_xyz_int->data.poly->points,
                   (BSpair **)&fill_uv_int->data.poly->points,
                   &num_cv_grps, &num_cvs_per_grp, &out_cvs,
                   &msg_loc );
      EMerr_hndlr (msg_loc != BSSUCC || num_cv_grps != 1 ||
                   !num_cvs_per_grp[0], *msg, EMS_E_BSerror, ret_end);
      if (num_cvs_per_grp[0] > 1)
        {
        BSmergarrcv (num_cvs_per_grp[0], out_cvs[0], &fill_xyz_int->data.curve,
                     &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
        for (j = 0; j<num_cvs_per_grp[0]; j++)
          {
          BSfreecv (&msg_loc, out_cvs[0][j]);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
          out_cvs[0][j] = NULL;
          }
          free( out_cvs );
          out_cvs = NULL;
        }
      else
        {
        fill_xyz_int->data.curve = out_cvs[0][0];
        free( out_cvs );
        out_cvs = NULL;
        }
      num_cv_grps = 0;
      free( num_cvs_per_grp );
      num_cvs_per_grp = NULL;
      fill_xyz_int->datatype = EMSdata_curve3d;
      }
    }
  
ret_end:
  if (num_ints_grp)
    om$dealloc (ptr = num_ints_grp);
  if (num_pts_int)
    om$dealloc (ptr = num_pts_int);
  EMfree_double_array (tot_num_ints, xyzpts);
  EMfree_double_array (tot_num_ints, myuvpts);
  EMfree_double_array (tot_num_ints, otheruvpts);
  EMfree_bsgmcv_array (tot_num_ints, xyz_cvs);
  EMfree_bsgmcv_array (tot_num_ints, uv1_cvs);
  EMfree_bsgmcv_array (tot_num_ints, uv2_cvs);
  if (pln.sfgen_cv)
    BSfreecv (&msg_loc, pln.sfgen_cv);
  if (fsf.sfgen_cv)
    BSfreecv (&msg_loc, fsf.sfgen_cv);

  EMWRAPUP (*msg, stat, "EMget_fillet_intpln_data");
  return;
}


/*
 * DESCRIPTION:
      Given two adjacent edges, this function finds their point of
      intersection closest to 'ref_pt'.

 * OPTIONS:
      int_pt1_xyz, int_pt2_xyz,
      int_pt1_uv, int_pt2_uv	At least one of these output variables
                                must be not NULL.
 * INPUT:
      md_env		Module environment.
      ref_pt		If the two edges have multiple intersections points,
                        the one closest to this point is picked.
      edge1_geom	Edge as an object, or its xyz geometry.
      edge2_geom        As above.

 * OUTPUT:
      In case not NULL, the caller must ensuare adequate memory for the
      following,
       int_pt1_xyz
       int_pt1_u	Intersection point xyz and u on edge1. These must
                        be three doubles and a single double respectively.
       int_pt2_xyz,
       int_pt2_u	As above.

 * ALGORITHM:
      Trivial.

 * HISTORY:
      Janaka : 02/01/93 : Original.
 */

IGRlong EMget_edges_int_pt( IGRlong *EMmsg, struct GRmd_env *md_env,
               IGRpoint ref_pt, struct EMSdataselect *edge1_geom,
               struct EMSdataselect *edge2_geom, IGRdouble *int_pt1_xyz,
               IGRdouble *int_pt2_xyz, IGRdouble *int_pt1_u,
               IGRdouble *int_pt2_u )
{
   IGRint	num, index;
   IGRlong	OM_stat, msg;
   IGRdouble	*par1, *par2, dist;
   IGRpoint	*pt1, *pt2, tmp_pt;

   struct IGRbsp_curve	*cv1, *cv2;

   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
   cv1 = cv2 = NULL;
   par1 = par2 = NULL;
   pt1 = pt2 = NULL;

   if( edge1_geom->datatype == EMSdata_curve3d )
      cv1 = edge1_geom->data.curve;
   else
      if( edge1_geom->datatype == EMSdata_object )
      {
           cv1 = ( struct IGRbsp_curve * ) om$malloc(
                            size = sizeof( struct IGRbsp_curve ) );
           cv1->poles = NULL;
           cv1->knots = NULL;
           cv1->weights = NULL;

           OM_stat = om$send( msg = message EMSedge.EMget_bcxyz_geom(
  			&msg, &md_env->md_env, NULL, NULL, 0, MAXINT,
			FALSE, NULL, cv1 ),
		              senderid = NULL_OBJID,
			      targetid = edge1_geom->data.object->objid,
                              targetos = edge1_geom->data.object->osnum );
           EMerr_hndlr( !( msg & OM_stat & 1 ), *EMmsg, EMS_E_EdgeError,
                        wrapup );
      }
      else
      {
         *EMmsg = EMS_E_InvalidArg;
         goto wrapup;
      }

   if( edge2_geom->datatype == EMSdata_curve3d )
      cv2 = edge2_geom->data.curve;
   else
      if( edge2_geom->datatype == EMSdata_object )
      {
           cv2 = ( struct IGRbsp_curve * ) om$malloc(
                            size = sizeof( struct IGRbsp_curve ) );
           cv2->poles = NULL;
           cv2->knots = NULL;
           cv2->weights = NULL;

           OM_stat = om$send( msg = message EMSedge.EMget_bcxyz_geom(
  			&msg, &md_env->md_env, NULL, NULL, 0, MAXINT,
			FALSE, NULL, cv2 ),
		              senderid = NULL_OBJID,
			      targetid = edge2_geom->data.object->objid,
                              targetos = edge2_geom->data.object->osnum );
           EMerr_hndlr( !( msg & OM_stat & 1 ), *EMmsg, msg, wrapup );
      }
      else
      {
         *EMmsg = EMS_E_InvalidArg;
         goto wrapup;
      }

   BSmdistcvcv( cv1, cv2, &num, &par1, &par2, &pt1, &pt2, &dist, &msg );
   EMerr_hndlr( msg != BSSUCC || !num, *EMmsg, EMS_E_BSerror, wrapup );

   index = 0;
   if( num != 1 )
   {
      EFfind_the_closest_pt( &msg, 3, ref_pt, num, pt1,
                                &index, tmp_pt );
      EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );
   }

   if( int_pt1_xyz )
      OM_BLOCK_MOVE( pt1[index], int_pt1_xyz, sizeof( IGRpoint ) );

   if( int_pt2_xyz )
      OM_BLOCK_MOVE( pt2[index], int_pt2_xyz, sizeof( IGRpoint ) );

   if( int_pt1_u )
      OM_BLOCK_MOVE( &par1[index], int_pt1_u, sizeof( IGRdouble ) );

   if( int_pt2_u )
      OM_BLOCK_MOVE( &par2[index], int_pt2_u, sizeof( IGRdouble ) );

wrapup:

   if( edge1_geom->datatype != EMSdata_curve3d && cv1 )
   {
      om$dealloc( ptr = cv1->poles );
      om$dealloc( ptr = cv1->knots );
      om$dealloc( ptr = cv1->weights );
      om$dealloc( ptr = cv1 );
   }

   if( edge2_geom->datatype != EMSdata_curve3d && cv2 )
   {
      om$dealloc( ptr = cv2->poles );
      om$dealloc( ptr = cv2->knots );
      om$dealloc( ptr = cv2->weights );
      om$dealloc( ptr = cv2 );
   }

   if( par1 ) free( par1 );
   if( par2 ) free( par2 );
   if( pt1 )  free( pt1 );
   if( pt2 )  free( pt2 );

   EMWRAPUP( *EMmsg, OM_stat, "EMget_edges_int_pt" );
   return( OM_stat );
}



/*
 * DESCRIPTION:
      This function performs the interpolation neccessary to generate
      internal radii, when performing variable radius rounding on a chain
      of edges (Under this condition, given a chain of edges, the radii
      are known at the free ends of the first and the last edges, but not
      at any of the intermediate nodes of the edge chain).

 * INPUT:
      options		Unused.
      md_env		Module environment.
      edges             An array of edges within which there exists a group
                        of edges that constitutes an edge chain on which
                        variable radius rounding is performed.  Considering
                        this group of edges, there are two free ends (one at
                        the start of the chain, and the other at the end),
                        which are not shared with any other edge in the chain.
                        Radii must be specified for these two ends.
      start_index	Index into the 'edges' array indicating the first
                        edge in the edge chain.
      stop_index	As above, for the last edge of the chain.

 * OUTPUT:
      EMmsg		EMS errors.
      return value	OM errors.
      edges		The first and last edges would have the missing radius
                        generated.  All other edges in the chain would have
                        two radii (at the logical start and stop) generated.

 * ALGORITHM:
      . Determine the total arc length of the chain, and the absolute
        difference between the radii at the free ends of the first (r1) and
        the last (r2) edges in the chain. Obtain the ratio:
              ratio = ( |r1 - r2| ) / total arc length of chain.
        Use this ratio to determine the intermediate radii along the chain.
        i.e. radius at the any internal edge end would be:
             del_r = ratio * cumalative arc length of chain at that
                             edge end.
             radius = radius at first edge free end +/- del_r
                      ( + if r1 < r2 else - ).

 * HISTORY:
      Janaka : 01/13/93 : Original.
 */

#argsused

IGRlong EMgenerate_missing_radii( EMmsg, options, md_env, edges,
                                  start_index, stop_index )
IGRlong				*EMmsg;
IGRushort			options;
struct GRmd_env			*md_env;
struct EMSrnd_boundary_input	*edges;
IGRint				start_index, stop_index;
{
   IGRboolean	prev_edge_free_end_is_start, prev_ed_at_stop;
   IGRint	i, j, chain_free_ends[2], num_eds;
   IGRlong	msg, OM_stat;
   IGRdouble    chain_length, *edge_lengths, chain_start_radius,
                chain_end_radius, current_length, basis_tol, ratio,
                current_radius;

   struct GRid  *chain_eds;

   /*
    * STEP 0: Initialize.
    */
       *EMmsg = EMS_S_Success;
       OM_stat = OM_S_SUCCESS;
       BSEXTRACTPAR( &msg, BSTOLLENVEC, basis_tol );
       num_eds = stop_index - start_index + 1;

       /* Make a temporary buffer for edges, and get the chains free ends */
          chain_eds = ( struct GRid * ) alloca
                                 ( num_eds * sizeof( struct GRid ) );
          for( i = start_index, j = 0; i <= stop_index; i++, j++ )
           OM_BLOCK_MOVE( &edges[i].boundary_id,
                          &chain_eds[j],
                          sizeof( struct GRid ) );
           OM_stat = EMget_chain_free_ends( &msg, ( IGRushort ) 0, md_env,
                           chain_eds, num_eds, chain_free_ends );
           EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );

   /*
    * STEP 1: Determine the ratio: delta_radius to total chain length.
    */
       edge_lengths = ( IGRdouble * ) alloca
                   ( ( stop_index - start_index + 1 ) * sizeof( IGRdouble ) );
       for( i = start_index, chain_length = 0; i <= stop_index; i++ )
       {
          OM_stat = om$send( msg = message EMSedge.EMget_edge_length
                                     ( &msg, ( IGRushort ) 0,
                                       &md_env->md_env,
                                       NULL, NULL, NULL,
                                       &edge_lengths[i] ),
                             targetid = edges[ i ].boundary_id.objid,
                             targetos = edges[ i ].boundary_id.osnum,
                             senderid = NULL_OBJID );
          EMerr_hndlr( !( 1 & OM_stat &msg ), *EMmsg, EMS_E_EdgeError,
                       wrapup );
          chain_length += edge_lengths[i];
       }

       OM_stat = EMgetparval_numeric( &msg,
                           &edges[start_index].radius,
                       &chain_start_radius );
       EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );

       OM_stat = EMgetparval_numeric( &msg,
                           &edges[stop_index].other_radius ,
                       &chain_end_radius );
       EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );

       ratio = (chain_end_radius - chain_start_radius ) / chain_length;
                                       
   /*
    * STEP 2:
    *
    * Generate the intermediate radii along the chain.  At each of the chain
    * vertices that are not free, a single radius is generated, and it is
    * assigned to the two edges at the vertex.  In the following, the use of
    * START and STOP w.r.t. edges refer to the logical direction of the edge.
    */
      prev_edge_free_end_is_start = chain_free_ends[FIRST] == START
                                      ? FALSE : TRUE;
      if(chain_free_ends[FIRST] == START)
        {
        edges[start_index].radius.val = chain_start_radius;
        edges[start_index].radius.type = EMSdatainfo_numeric;
        }
      else
        {
        edges[start_index].other_radius.type = EMSdatainfo_numeric;
        edges[start_index].other_radius.val = chain_start_radius;
        }

      if (chain_free_ends[SECOND] == START)
        {
        edges[stop_index].radius.type = EMSdatainfo_numeric;
        edges[stop_index].radius.val = chain_end_radius;
        }
      else
        {
        edges[stop_index].other_radius.type = EMSdatainfo_numeric;
        edges[stop_index].other_radius.val = chain_end_radius;
        }
      /* 
       * Now, do the remaining free ends in the chain (there are a total of
       * n-1 interior free vertices, where n is the number of edges in the
       * chain).
       */
          current_length = 0;
          for( i = start_index + 1; i <= stop_index; i++ )
          {
             current_length += edge_lengths[i-1];
             current_radius = chain_start_radius + ratio*current_length;

             /* Set the radius for the previous edge. */
                if( prev_edge_free_end_is_start == TRUE )
                {
                   edges[i-1].radius.type = EMSdatainfo_numeric;
                   edges[i-1].radius.val = current_radius;
                }
                else
                {
                   edges[i-1].other_radius.type = EMSdatainfo_numeric;
                   edges[i-1].other_radius.val = current_radius;
                }
             /*
              * Determine the ith edge end vertex that is coincident with
              * the previous edges free end.  Then, set the radius for the
              * ith edge, at the concident end.
              */
                 OM_stat = EMget_neighbor_pos_wrt_ed( &msg, (IGRushort ) 0,
                        md_env, edges[i].boundary_id.objid,
                        edges[i-1].boundary_id.objid, &prev_ed_at_stop );
                 EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_EdgeError,
                              wrapup );

                 if( prev_ed_at_stop == FALSE )
                 {
                  edges[i].radius.type = EMSdatainfo_numeric;
                  edges[i].radius.val = current_radius;
                  prev_edge_free_end_is_start = FALSE;
                 }
                 else
                 {
                  edges[i].other_radius.type = EMSdatainfo_numeric;
                  edges[i].other_radius.val = current_radius;
                  prev_edge_free_end_is_start = TRUE;
                 }
          }
wrapup:

   EMWRAPUP( *EMmsg, OM_stat, "EMgenerate_missing_radii" );
   return( OM_stat );
}


/*
 * DESCRIPTION:
      Given an edge determine its neutralily and dominance.

 * INPUT:
      options		Unused.
      md_env		Module environment.
      edge_in		Edge to be validated.
 
 * OUTPUT:
      EMmsg		EMS errors.
      return value	OM errors.
      is_neutral	TRUE if 'edge_in' is neutral, else FALSE.
      edge_out		If 'edge_in' is not neutral and is subordinate, then
                        that edges common edge.
                        Else 'edge_out = edge_in'.

 * ALGORITHM:
      Trivial.
 
 * HISTORY:
      Janaka : 01/08/1993 : Original.
*/

#argsused

IGRlong EMvalidate_round_edge( EMmsg, options, md_env, edge_in,
                               is_neutral, edge_out )
IGRlong		*EMmsg;
IGRushort	options;
struct GRmd_env	*md_env;
struct GRid	*edge_in, *edge_out;
IGRboolean	*is_neutral;
{
   IGRboolean		is_convex;
   IGRushort		edge_props;
   IGRshort		*matrix_type;
   IGRlong		msg, OM_stat;
   OMuint		count;
   IGRdouble		angle_meas, *matrix;
   OM_S_OBJECT_LINKAGE	common_edge[1];
   OM_S_CHANSELECT	to_common_edge;


   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;
   matrix = md_env->md_env.matrix;
   matrix_type = &md_env->md_env.matrix_type;
   OM_BLOCK_MOVE( edge_in, edge_out, sizeof( struct GRid ) );
   EMmake_chanselect( EMSedge_to_common_edge, &to_common_edge );


   /* Get the included angle measure of the edge. */
   OM_stat = om$send ( msg = message EMSedge.EMchkconvex
				 	( &msg,
                                  	  NULL,
					  matrix_type,
					  matrix,
				  	  EMS_ZEROANGLE_DEG_MAX,
				  	  &is_convex,
                                  	  is_neutral,
                                          &angle_meas ),
                      senderid = NULL_OBJID,
 		      targetid = edge_in->objid,
		      targetos = edge_in->osnum );
   EMerr_hndlr( !( OM_stat & msg ), *EMmsg, EMS_E_EdgeError, wrapup );

   if( *is_neutral == FALSE  )
   {
      /* Obtain the dominant edge */

         OM_stat = om$send( msg = message EMSedge.EMget_props
                                    ( &msg,
                                      &edge_props ),
                   senderid = NULL_OBJID,
                   targetid = edge_in->objid,
                   targetos = edge_in->osnum );
         EMerr_hndlr( !( 1 & msg & OM_stat ), *EMmsg, EMS_E_EdgeError,
                      wrapup );

         if( edge_props & EMED_SUBORDINATE )
         {
            OM_stat = om$get_channel_objects ( objid = edge_in->objid,
                                     osnum = edge_in->osnum,
                                     p_chanselect = &to_common_edge,
                                     count = &count,
                                     size = ( OMuint ) 1,
                                     list = common_edge );
            EMerr_hndlr( !( 1 & OM_stat ) || count != 1, *EMmsg,
                         EMS_E_EdgeError, wrapup );
            edge_out->objid = common_edge[0].S_objid;
         }
    }
    else
       *is_neutral = TRUE;

wrapup:

   EMWRAPUP( *EMmsg, OM_stat, "EMvalidate_round_edge" );
   return( OM_stat );
}



/*
 * DESCRIPTION:
      Obtain a loop's dominant edges that not neutral.  Optionally, only
      the count of such non-neutral edges can be obtained (see INPUT).

 * INPUT:
      options		Unused.
      md_env		Module environment.
      loop_id		GRid of the loop from which the edges are
                        obtained.
      num_edges         Size of 'edges' array (typically the object
                        count in the 'to_comps' channel in 'loop_id').
                        If no edges are required, then this could be 0.

 * OUTPUT:
      EMmsg		EMS errors.
      return value	OM errors.
      edge_count        The number of non-neutral edges.  If only the edges
                        were required, this could be NULL.
      edges		The actual dominant, non-neutral edges of 'loop_id'.
                        Space must be allocated by the caller.  If
                        no edges are required, then this could be NULL.

 * ALGORITHM:
      Trivial.

 * HISTORY:
      Janaka : 01/07/1993 : Origin.
*/

#argsused

IGRlong	EMget_loop_dominant_non_neutral_edges( EMmsg, options, md_env,
                     loop_id, num_edges, edges, edge_count )
IGRlong		*EMmsg;
IGRushort	options;
IGRint		num_edges, *edge_count /* num_edges - num neutral edges */;
struct GRmd_env	*md_env;
struct GRid	*loop_id, *edges;
{
   IGRboolean		is_neutral;
   IGRint	        i, j,
                        local_edge_count; /* Number of non-neutral edges */
   OMuint		count, local_num_edges;
   IGRlong		msg, OM_stat;
   GRspacenum		edge_osnum;
   OM_S_OBJECT_LINKAGE  *local_edges;
   OM_S_CHANSELECT	to_comps;

   struct GRid		edge_tobe_checked, new_edge;
   extern IGRlong	EMvalidate_round_edge();


   /* STEP 0: initialize */
      OM_stat = OM_S_SUCCESS;
      *EMmsg = EMS_S_Success;
      EMerr_hndlr( !edges && !edge_count, *EMmsg, EMS_E_InvalidArg, wrapup );
      edge_osnum = loop_id->osnum;
      EMmake_chanselect( EMSbd_owner_to_comps, &to_comps );

   /* STEP 1: Obtain the loop's edges */
      if( !num_edges )
      {
         OM_stat = om$get_channel_count(
                                  osnum = loop_id->osnum,
                                  objid = loop_id->objid,
                                  p_chanselect = &to_comps,
                                  count = &local_num_edges );
         EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_LoopError,
                      wrapup );
      }
      else
         local_num_edges = ( OMuint ) num_edges;

      local_edges = ( OM_S_OBJECT_LINKAGE * ) alloca
                   ( local_num_edges * sizeof( OM_S_OBJECT_LINKAGE ) );

      OM_stat = om$get_channel_objects( objid = loop_id->objid,
                           osnum = loop_id->osnum,
                           p_chanselect = &to_comps,
                           count = &count,
                           size = local_num_edges,
                           list = local_edges );
      EMerr_hndlr( !( 1 & OM_stat ) || count != local_num_edges, *EMmsg,
                   EMS_E_Fail, wrapup );

   /* STEP 2:
    * Check each edge for:
    *   . neutrality.
    *   . dominant.
    * and assign to output.
    * i .. index into the actual edges in the loop.
    * j .. index into the array of dominant, non-neutral edges of the loop.
    */
       for( i = 0, j = 0, local_edge_count = 0; i < local_num_edges ;
            i++ )
       {
          edge_tobe_checked.objid = local_edges[i].S_objid;
          edge_tobe_checked.osnum = edge_osnum;
          OM_stat = EMvalidate_round_edge( &msg, ( IGRushort ) 0, md_env,
                       &edge_tobe_checked, &is_neutral, &new_edge );
          EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, msg, wrapup );
          if( is_neutral == FALSE )
          {
             local_edge_count++;
             if( edges )
             {
                OM_BLOCK_MOVE( &new_edge,
                               &edges[j],
                               sizeof( struct GRid ) );
                ++j;
             }
          }
       }

       if( edge_count )	 *edge_count = local_edge_count;

wrapup:

  EMWRAPUP( *EMmsg, OM_stat, "EMget_loop_dominant_non_neutral_edges" );
  return( OM_stat );
}



/*
 * DESCRIPTION:
      Given, an edge to be rounded, and a neighboring edge at one of its end
      vertices, get the surface id of the neighboring edge, ensuring that
      the neighboring edge is the edge that is not on one of the surfaces
      of the edge being rounded (here, neighboring edge referes to either
      the cyclic previous or the next edge to the round edge at the vertex).
      Optionally, the surface's parametric tolerance can be obtained.

 * OPTIONS:
      partol            Could be NULL.

 * INPUT:
      neighbor_ed
      rnd_ed

 * OUTPUT:
      EMmsg		EMS errors.
      return value	OM_errors.
      neighbor_ed_sf_id
      partol            Parametric tolerance of 'neighbor_ed_sf_id'.

 * ALGORITHM:
      Trivial.

 * HISTORY:
      Janaka : 01/31/93 : Original.
 */

IGRlong EMget_rndedge_neighbors_sf_id( IGRlong *EMmsg,
             GRobjid neighbor_ed, struct EMSedge_rnd_info *rnd_ed,
             GRobjid *neighbor_ed_sf_id, struct EMSpartolbasis *partol )
{
   IGRlong		OM_stat, msg;
   OM_S_CHANSELECT	chan_to_common_edge;

   OM_stat = OM_S_SUCCESS;
   *EMmsg  = EMS_S_Success;
   EMmake_chanselect( EMSedge_to_common_edge, &chan_to_common_edge );

   OM_stat = om$send( msg = message EMSboundary.EMgetsurface_info
                             ( &msg, neighbor_ed_sf_id, partol ),
                      targetid = neighbor_ed,
                      senderid = NULL_OBJID );
   EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_EdgeError, wrapup );
   if( IF_EQ_OBJID( *neighbor_ed_sf_id, rnd_ed->surf_id ) == TRUE ||
       IF_EQ_OBJID( *neighbor_ed_sf_id, rnd_ed->com_surf_id ) == TRUE )
   {
      OM_stat = om$send( msg = message EMSboundary.EMgetsurface_info
                           ( &msg, neighbor_ed_sf_id, partol ),
                       senderid = neighbor_ed,
                       p_chanselect = &chan_to_common_edge );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_EdgeError,
                   wrapup );
   }

wrapup:
   EMWRAPUP( *EMmsg, OM_stat, "EMget_rndedge_neighbors_sf" );
   return( OM_stat );
}



/*
 * DESCRIPTION:
      Given a surface as a dataselect, construct an equivalent BSgeom_bsp_surf
      instance for the surface.

 * OPTIONS:
      None.
 
 * INPUT:
      md_env            Module environment.
      sf		This could be:
                          . An object.
                          . A bsp surface.
                          . An infinite plane.

 * OUTPUT:
      sf_info		   An instance of BSgeom_bsp_surf for the input
                           surface.  If 'sf' is an object, then its geometry
                           is extracted (memory is allocated by this
                           function.  Use BSfreesf() to deallocate).
                           Else, the input geometry is used.
      sf_geom_constructed  If 'sf' was an object TRUE, else FALSE.
                           Caller should use this flag to determine whether to
                           deallocate the surface geometry returned within
                           'sf_info'.
 * ALGORITHM:
      Trivial.

 * HISTORY:
      Janaka : 01/21/93 : Original.
 */
                           

IGRlong EMget_sf_BSgeom_info( IGRlong *EMmsg, struct GRmd_env *md_env,
             struct EMSdataselect *sf, struct BSgeom_bsp_surf *sf_info,
             IGRboolean *sf_geom_constructed )

{
   IGRshort	mat_type;
   IGRlong	OM_stat, msg;
   IGRdouble	*mat;

   struct BSgeom_bsp_surf	loc_sf_info;

   extern void	getsftype();

   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;
   mat_type = md_env->md_env.matrix_type;
   mat = md_env->md_env.matrix;

   /* Initialize for bsp surfaces */
      loc_sf_info.geom_prop = FALSE;
      loc_sf_info.bounded = FALSE;
      loc_sf_info.reg_constr = FALSE;
      loc_sf_info.bspsf = NULL;
      loc_sf_info.sfgen_cv = NULL;
      loc_sf_info.urange[0] =
      loc_sf_info.vrange[0] = 0.0;
      loc_sf_info.urange[1] =
      loc_sf_info.vrange[1] = 1.0;
   
   if( sf->datatype == EMSdata_object )
   {
      OM_stat = EMgetvggeom( &msg, &mat_type, mat, sf->data.object,
                         ( IGRchar ** ) &loc_sf_info.bspsf, NULL );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError,
                   wrapup );
      *sf_geom_constructed = TRUE;
      getsftype( sf->data.object->objid, sf->data.object->osnum,
                 &loc_sf_info.type );
   }
   else
      if( sf->datatype == EMSdata_surface )
      {
         loc_sf_info.bspsf = sf->data.surface;
         *sf_geom_constructed = FALSE;
         loc_sf_info.type = BSGEN_BSP_SF;
      }
      else
         if( sf->datatype == EMSdata_plane )
         {
            *sf_geom_constructed = FALSE;
            loc_sf_info.geom_prop = TRUE;
            loc_sf_info.type = BSINF_PLANE;
            loc_sf_info.bounded = FALSE;
            OM_BLOCK_MOVE( sf->data.plane->point, loc_sf_info.pt1,
                           sizeof( IGRpoint ) );
            OM_BLOCK_MOVE( sf->data.plane->normal, loc_sf_info.vec1,
                           sizeof( IGRvector ) );
         }
         else
         {
            *EMmsg = EMS_E_InvalidArg;
            goto wrapup;
         }

   /* Assign output */
      OM_BLOCK_MOVE( &loc_sf_info, sf_info,
                     sizeof( struct BSgeom_bsp_surf ) );

wrapup:

   EMWRAPUP( *EMmsg, OM_stat, "EMget_sf_BSgeom_info" );
   return( OM_stat );
}




/*
 * DESCRIPTION:
    Given a packet of round vertex information, and two indicies into the
    arrays within that packet, indicating the edges, the function returns the
    two tangents of those edges at the round vertex.  The tangents are
    oriented towards the other vertex of each edge.

 * OPTIONS:
    None.

 * INPUT:
    rnd_vtx_info	Information on the round vertex.
    ed_inx		Indicies into the arrays within 'rnd_vtx_info'
                        indicating the edges beeing processed.

 * OUTPUT:
    EMmsg		EMS errors.
    return values	OM errors.

    Memory must be managed by the caller.
     tan_vecs           Normalized tangent vectors of 'ed_inx' at the round
                        vertex. Each is oriented towards the other vertex of
                        that edge.

 * ALGORITHM:
    Trivial.

 * HISTORY:
    Janaka : 07-13-93 : Original.
 */

#argsused

IGRlong	EMget_edge_tangents_at_rnd_vtx( IGRlong *EMmsg,
          struct GRmd_env		*md_env,
          struct EMSvtx_rnd_info 	*rnd_vtx_info,
          IGRint 			ed_inx[2],
          IGRvector 			tan_vecs[2] )
{
 IGRint		i, j;
 IGRlong	msg, OM_stat;
 IGRdouble	param;
 IGRpoint	vec_pts[2];
 IGRvector      loc_tan_vecs[2];

 GRspacenum	os;

 struct IGRbsp_curve	ed_geoms[2];


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 os = md_env->md_id.osnum;

 for( i = FIRST; i <= SECOND; i++ )
 {
  ed_geoms[i].poles = NULL;
  ed_geoms[i].knots = NULL;
  ed_geoms[i].weights = NULL;
 }


 for( i = FIRST; i <= SECOND; i++ )
 {
  OM_stat = om$send( msg = message EMSedge.EMget_bcxyz_geom
     		     ( &msg, &md_env->md_env, NULL, NULL, ( IGRint ) 0,
   	               MAXINT, FALSE, NULL, &ed_geoms[i] ),
                     senderid = NULL_OBJID,
                     targetos = os,
       	             targetid = rnd_vtx_info->edge_ids[ ed_inx[i] ] );
  EMerr_hndlr( !( msg & OM_stat & 1 ), *EMmsg, msg, wrapup );

  param = rnd_vtx_info->edge_stops[ ed_inx[i] ] == TRUE ? 1.0 : 0.0;
  BScvarrevt( &ed_geoms[i], &param, ( IGRint ) 1, 1.0, &vec_pts, &msg );
  EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
  for( j = 0; j < DIM_XYZ_SPACE; j++ )
   loc_tan_vecs[i][j] = vec_pts[SECOND][j] - vec_pts[FIRST][j];
  BSnorvec( &msg, loc_tan_vecs[i] );
  EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
  if( rnd_vtx_info->edge_stops[ ed_inx[i] ] == TRUE )
   for( j = 0; j < DIM_XYZ_SPACE; j++ )
    loc_tan_vecs[i][j] = -loc_tan_vecs[i][j];    
 }

 OM_BLOCK_MOVE( loc_tan_vecs, tan_vecs, 2*sizeof( IGRvector ) );


wrapup:
 for( i = FIRST; i <= SECOND; i++ )
 {
  if( ed_geoms[i].poles )	om$dealloc( ptr = ed_geoms[i].poles );
  if( ed_geoms[i].knots )	om$dealloc( ptr = ed_geoms[i].knots );
  if( ed_geoms[i].weights )	om$dealloc( ptr = ed_geoms[i].weights );
 }
 
 EMWRAPUP( *EMmsg, OM_stat, "EMget_edge_tangents_at_rnd_vtx" );
 return( OM_stat );
}




/* DESCRIPTION:
    Given a reference edge (ed), and one of its neighbors, determine whether
    the neighbor is at the START or the STOP of the reference edge. The
    determination is based on the topology.
 */

#argsused

IGRlong EMget_neighbor_pos_wrt_ed( IGRlong *EMmsg, IGRushort options,

           struct GRmd_env *md_env, GRobjid ed, GRobjid neighbor_ed,
           IGRboolean *neighbor_ed_at_stop )
{
 IGRboolean	*ed_ends, ed_ends_stack_mem[ MAX_TO_STACK_ALLOC ],
                is_stop_end;
 IGRlong	OM_stat, msg;
 IGRint		num_vtx_eds, i, k;

 GRspacenum	osnum;
 GRobjid	*vtx_eds, vtx_eds_stack_mem[ MAX_TO_STACK_ALLOC ];

 OMuint		count;

 OM_S_CHANSELECT	to_common_ed;
 OM_S_OBJECT_LINKAGE	object_list[1];

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 vtx_eds = NULL;
 ed_ends = NULL;
 osnum = md_env->md_id.osnum;
 is_stop_end = FALSE;
 EMmake_chanselect( EMSedge_to_common_edge, &to_common_ed );

 count = 0;
 OM_stat = om$get_channel_objects( objid = neighbor_ed,
                                   osnum = osnum,
                                   p_chanselect = &to_common_ed,
                                   list         = object_list,
                                   size         = ( OMuint ) 1,
                                   count        = &count );
 EMerr_hndlr( !( 1 & OM_stat ) || count != 1, *EMmsg, EMS_E_EdgeError,
              wrapup);

 for( i = 0; i < 2; i++ )
 {
  /* Get the edges at this end of the edge. */
     vtx_eds = vtx_eds_stack_mem;
     ed_ends = ed_ends_stack_mem;
     num_vtx_eds = 0;
 
     OM_stat = om$send( msg = message EMSedge.EMgetvtxedges
                           ( &msg, EMSvtxedges_nodegenerate |
                                               EMSvtxedges_onlydominant,
                             i ? TRUE : FALSE,
                             ( IGRint ) MAX_TO_STACK_ALLOC,
                             &num_vtx_eds, &vtx_eds, &ed_ends ),

                       targetid = ed,
                       targetos = osnum,
                       senderid = NULL_OBJID );
     EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_EdgeError, wrapup );

  /* Now, check to see whether one of the vertex edges is the neighbor, or
   * the neighbors common edge.
   */
     for( k = 0; k < num_vtx_eds; k++ )
      if( IF_EQ_OBJID( vtx_eds[k], neighbor_ed ) ||
          IF_EQ_OBJID( vtx_eds[k], object_list[FIRST].S_objid ) )
      {
       is_stop_end = i ? TRUE : FALSE;
       goto ASSIGN_OUTPUT;
      }

  /* If num_vtx_eds > MAX_TO_STACK_ALLOC, then must free the memory
   * allocated by EMgetvtxedges.
   */
     if( vtx_eds && vtx_eds != vtx_eds_stack_mem )
      om$dealloc( ptr = vtx_eds );
     if( ed_ends && ed_ends != ed_ends_stack_mem )
      om$dealloc( ptr = ed_ends );
     vtx_eds = NULL;
     ed_ends = NULL;

  EMerr_hndlr( i, *EMmsg, EMS_E_EdgeError, wrapup );
 }

ASSIGN_OUTPUT: *neighbor_ed_at_stop = is_stop_end;

wrapup:

 if( vtx_eds && vtx_eds != vtx_eds_stack_mem )
  om$dealloc( ptr = vtx_eds );
 if( ed_ends && ed_ends != ed_ends_stack_mem )
  om$dealloc( ptr = ed_ends );

 EMWRAPUP( *EMmsg, OM_stat, "EMget_neighbor_pos_wrt_ed" );
 return( OM_stat );
}




/*
 * DESCRIPTION:
      Given a chain of edge GRids, this function determines the free ends
      of the first edge and the last edge in the chain.
 
 * INPUT:
      options		unused.
      md_env		Module environment.
      chain_eds 	A collection of edges.
      start_index       Index to 'edge_GRids' array, indicating the first
                        edge of the chain.
      stop_index        Index to the last edge in the chain.

 * OUTPUT:
      EMmsg		EMS errors.
      return value	OM errors.
      chain_free_ends   Indicator of which end of the first and last edges
                        are free.  The 0th location in the array is for the
                        first edge, and the 1st is for the last edge.
                        Memory must be allocated by the caller.

 * ALGORITHM:
      Trivial.

 * HISTORY:
      Janaka : 01/07/1993 : Original.
*/

#argsused

IGRlong EMget_chain_free_ends( IGRlong *EMmsg, IGRushort options,
           struct GRmd_env *md_env, struct GRid *chain_eds,
           IGRint num_eds, IGRint *chain_free_ends )
{
  IGRboolean	neighbor_ed_at_stop;
  IGRlong	msg, OM_stat, i, j, next;
  IGRdouble     basis_tol;


  /* STEP 0: initialize */
     *EMmsg = EMS_S_Success;
     OM_stat = OM_S_SUCCESS;
     BSEXTRACTPAR( &msg, BSTOLLENVEC, basis_tol );
     chain_free_ends[0] =
     chain_free_ends[1] = UNDEFINED;

  /* STEP 1:
   * . For the FIRST and the LAST edges of the chain, determine whether the
   *   START or the STOP end is free.
   */
      i = 0;
      next = 1;
      for( j = FIRST; j <= LAST; j++ )
      {
       OM_stat = EMget_neighbor_pos_wrt_ed( &msg, ( IGRushort ) 0,
                  md_env, chain_eds[i].objid, chain_eds[next].objid,
                  &neighbor_ed_at_stop );
       EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );

       chain_free_ends[j] = neighbor_ed_at_stop == TRUE ? START : STOP;
       /* Do the other end of the chain. */
          i = num_eds-1;
          next = num_eds-2;
      }

wrapup:

   EMWRAPUP( *EMmsg, OM_stat, "EMget_chain_free_ends" );
   return( OM_stat );
}



end implementation EMSsfrndbool;

