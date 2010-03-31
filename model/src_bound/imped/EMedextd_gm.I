/* ###################   APOGEE COMPILED   ################## */
/*
History
	Gupta	??/??/??	Creation.
	SM	28-Mar-89	Argument change in EMget_loops_for_imposition
				Function renamed as EMget_mapped_data().
        Janaka  05/05/93        Quick and dirty fix for TR119300132
                                (search for this TR within the code).
        Sudha   06/04/93        modified to include BSprototype header files
*/
class implementation EMSedge;

#include "EMS.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSlmdef.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsmapdef.h"
#include "emsmacros.h"
#include "emsedgedef.h"
#include "bspartofcv.h"
#include "bsparameters.h"
#include "bsmdistcvcv.h"
#include "bscv_copy.h"
#include "bsalloccv.h"

from EMSsfround import EMfix_end_point;

extern OMuword OPP_EMSplane_class_id;

method EMextend_geometry (IGRlong               *EMmsg;
                          GRobjid               rnd_edge_id,
                                                comm_surf_id,
                                                my_surf_id;
                          struct IGRbsp_surface *edge_surf;
                          struct EMSpartolbasis *partol;
                          GRobjid               *round_id;
                          struct GRmd_env       *my_env)
{
 IGRlong             stat_OM, msg;
 IGRushort   ed1_prop, ed2_prop;
 OMuword             dum_os;
 OMuword             surf_classid;
 IGRboolean          clip_curve, status;
 extern IGRint       EMget_mapped_data();
 IGRint              num_edge, num_of_curves, num_loops;
 IGRint              i, edge_index, loop_num;
 OMuint              ed_count;
 struct GRid         surf_GRid,
                     clip_ls;
 IGRushort   lp_options;
 GRobjid             *loop_id = NULL,
                     my_loop,
                     new_edge;
 struct GRid         edge_ids[2];
 struct IGRbsp_curve comm_edge_geom;
 struct IGRbsp_curve *new_curve;
 struct IGRbsp_curve *trimmed_curve;
 OM_S_CHANSELECT     to_common_edge,
                     to_edges,
                     to_owner;

 /*-------------------------------------------------------------------*/

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 if (ME.EMSedge->ed_props & EMED_END_ROUNDED)
  {
   ME.EMSedge->ed_props &= ~EMED_END_ROUNDED;
   return (stat_OM);
  }

 trimmed_curve = NULL;
 clip_curve = FALSE;
 loop_num = 0;
 edge_index = 0;

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 if (! (1 & stat_OM)) goto wrapup;

 comm_edge_geom.weights = NULL;
 comm_edge_geom.poles = NULL;
 comm_edge_geom.knots = NULL;
 comm_edge_geom.bdrys = NULL;

 surf_GRid.objid = comm_surf_id;
 surf_GRid.osnum = OM_Gw_current_OS;

 stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                         &my_env->md_env, &surf_GRid, NULL, 0,
                         OM_K_MAXINT, FALSE, NULL, &comm_edge_geom),
                   p_chanselect = &to_common_edge);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 new_curve = &comm_edge_geom;
 clip_ls.objid = NULL_OBJID;
 clip_ls.osnum = OM_Gw_current_OS;
 loop_id = NULL;
 num_loops = 0;
 num_of_curves = 1;

 stat_OM = om$send(msg = message EMSedge.EMget_sf_edges(&msg,
                         EMS_WHL_EDGE, edge_ids, &num_edge),
                   targetid = rnd_edge_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 stat_OM = om$send(msg = message EMSedge.EMget_props(&msg, &ed1_prop),
                   targetid = edge_ids[0].objid);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 stat_OM = om$send(msg = message EMSedge.EMget_props(&msg, &ed2_prop),
                   targetid = edge_ids[1].objid);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 if ((! edge_surf->u_phy_closed) && (! edge_surf->v_phy_closed))
  {
   if ((ed1_prop & EMED_NATURAL) || (ed2_prop & EMED_NATURAL))
        clip_curve = TRUE;
  }

 if (clip_curve)
  {
   IGRlong EFfix_the_curve();

   BSalloccv (new_curve->order,
              new_curve->num_poles + 2 * new_curve->order - 1, 
              new_curve->rational, 0, &trimmed_curve, &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   surf_GRid.objid = my_surf_id;
   surf_GRid.osnum = OM_Gw_current_OS;

   EFfix_the_curve(&msg, edge_ids[0].objid, edge_ids[1].objid, surf_GRid,
                   new_curve, edge_surf, my_env, trimmed_curve);
   EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
  }

 lp_options = NULL | EMMapBnd_WantBadCurves | EMMapBnd_StrokeIfNeeded |
              EMMapBnd_NoValidate;

 /* If this is a plane or its subclass, set the appropriate bit on so 
    that mapping to uv space is optimised.
 */

 stat_OM = om$get_classid(objid = my_surf_id,
                          p_classid = &surf_classid);
 if (! (1 & stat_OM)) goto wrapup;

 if(surf_classid == OPP_EMSplane_class_id)
    lp_options |= EMMapBnd_SurfIsPlane;
 else
  {
   stat_OM = om$is_ancestry_valid(subclassid = surf_classid, 
                                  superclassid = OPP_EMSplane_class_id);
			
   if(stat_OM == OM_S_SUCCESS) lp_options |= EMMapBnd_SurfIsPlane;
  }

 {
  struct EMSgetlp_output	junk;

  junk.num_objs = 0;
  junk.objs = NULL;
  status = EMget_mapped_data(num_of_curves,
                     (clip_curve) ? &trimmed_curve : &new_curve,
                      NULL,		/* object information */
                      NULL,		/* construct list */
                      edge_surf,	/* surface */
                      &partol->tol,	/* par tol */
                      my_env,		/* surface env */
		      NULL, 		/* bad curves */
		      NULL, 		/* bad points */
                      &junk, 		/* out loops */
                      NULL,		/* out curves */
                      clip_ls,
                      lp_options,
                      NULL, 
                      &msg);
  EMerr_hndlr (! status || ! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
  loop_id = junk.objs;
  num_loops = junk.num_objs;
 }

 /* A quick and dirty fix to prevent core dumping on the SUN (TR119300132) */
    EMerr_hndlr( !loop_id || !num_loops, *EMmsg, EMS_E_Fail, wrapup );

 if ((edge_surf->u_phy_closed || edge_surf->v_phy_closed) &&
     (num_loops > 1))
  {
   IGRlong EMget_right_loop();

   EMget_right_loop (&msg, my_id, &num_loops, loop_id, &loop_num, partol);
   EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
  }

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
 if (! (1 & stat_OM)) goto wrapup;

 stat_OM = om$get_channel_count(objid = loop_id[loop_num],
                                p_chanselect = &to_edges,
                                count = &ed_count);
 if (! (1 & stat_OM)) goto wrapup;

 if (ed_count > 1)
  {
   IGRlong EMget_right_edge();

   EMget_right_edge (&msg, my_id, loop_id[loop_num], ed_count,
                     &edge_index, partol);
   EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
  }

 stat_OM = om$get_objid_at_index(objid = loop_id[loop_num],
                                 p_chanselect = &to_edges,
                                 index = edge_index,
                                 objidaddr = &new_edge,
                                 osnumaddr = &dum_os);
 EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 stat_OM = om$send (msg = message Root.disconnect (to_owner,
                          loop_id[loop_num], OM_Gw_current_OS, to_edges),
                    senderid = loop_id[loop_num],
                    targetid = new_edge);
 if (! (1 & stat_OM)) goto wrapup;
 
 for (i=0; i<num_loops; i++)
  {
   stat_OM = om$send (msg = message Root.delete(1),
                      targetid = loop_id[i]);
   if (! (1 & stat_OM)) goto wrapup;
  }

 stat_OM = om$send(msg = message EMSedge.EMreplace_edge
				(&msg, new_edge, TRUE), 
				targetid = my_id);
/*************************

 Function was replaced by message. SM Feb 14, 1989.

 EMreplace_edge (&msg, new_edge, my_id, TRUE);
************************/

 EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

 stat_OM = om$get_objid_at_index(objid = new_edge,
                                 p_chanselect = &to_owner,
                                 index = 0,
                                 objidaddr = &my_loop,
                                 osnumaddr = &dum_os);
 EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 stat_OM = om$send (msg = message EMSsfround.EMfix_end_point(&msg,
                          my_loop),                          
                    targetid = *round_id);
 EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

wrapup:

  EMWRAPUP(*EMmsg, stat_OM, "In EMSedge.EMextend_geometry");
  if (trimmed_curve) om$dealloc (ptr = trimmed_curve);
  if (comm_edge_geom.weights) om$dealloc (ptr = comm_edge_geom.weights);
      comm_edge_geom.weights = NULL;
  if (comm_edge_geom.poles) om$dealloc (ptr = comm_edge_geom.poles);
      comm_edge_geom.poles = NULL;
  if (comm_edge_geom.knots) om$dealloc (ptr = comm_edge_geom.knots);
      comm_edge_geom.knots = NULL;
  if (comm_edge_geom.bdrys) om$dealloc (ptr = comm_edge_geom.bdrys);
      comm_edge_geom.bdrys = NULL;
  if(loop_id) om$dealloc(ptr = loop_id);

  return (stat_OM);
}

IGRlong EFfix_the_curve(EMmsg, beg_edge_id, end_edge_id, surf_GRid, curve,
                        curve_surface, my_env, trimmed_curve)

IGRlong *EMmsg;
GRobjid beg_edge_id, end_edge_id;
struct GRid surf_GRid;
struct IGRbsp_curve *curve, *trimmed_curve;
struct IGRbsp_surface *curve_surface;
struct GRmd_env *my_env;
{
 IGRlong             stat_OM, msg;
 IGRint              num_int;
 IGRdouble           *par1=NULL, *par2=NULL,
                     *par3=NULL, *par4=NULL;
 IGRdouble           mid_par, dist1, dist2;
 IGRdouble           knot_tol, chdht_tol;
 IGRboolean          stat;
 IGRpoint            *cv1_points, *cv2_points,
                     *cv3_points, *cv4_points;
 struct IGRbsp_curve beg_edge_geom, end_edge_geom;

 /*-------------------------------------------------------------*/

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 
 par1 = par2 = NULL;
 par3 = par4 = NULL;
 cv1_points = cv2_points = NULL;
 cv3_points = cv4_points = NULL;

 BSEXTRACTPAR(&msg, BSTOLCHRDHT, chdht_tol);
 BSEXTRACTPAR(&msg, BSTOLKNOT, knot_tol);

 beg_edge_geom.weights = NULL;
 beg_edge_geom.poles = NULL;
 beg_edge_geom.knots = NULL;
 beg_edge_geom.bdrys = NULL;

 end_edge_geom.weights = NULL;
 end_edge_geom.poles = NULL;
 end_edge_geom.knots = NULL;
 end_edge_geom.bdrys = NULL;

 stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                         &my_env->md_env, &surf_GRid, curve_surface, 0,
                         OM_K_MAXINT, FALSE, NULL, &beg_edge_geom),
                   senderid = NULL_OBJID,
                   targetid = beg_edge_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                         &my_env->md_env, &surf_GRid, curve_surface, 0,
                         OM_K_MAXINT, FALSE, NULL, &end_edge_geom),
                   senderid = NULL_OBJID,
                   targetid = end_edge_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 BSmdistcvcv(curve, &beg_edge_geom, &num_int, &par1, &par2, &cv1_points,
             &cv2_points, &dist1, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSmdistcvcv(curve, &end_edge_geom, &num_int, &par3, &par4, &cv3_points,
             &cv4_points, &dist2, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if ((dist1 > chdht_tol) && (dist2 > chdht_tol))
  {
   par1[0] = 0.0;
   par3[0] = 1.0;
  }
 else
 if ((dist1 <= chdht_tol) && (dist2 > chdht_tol))
  {
   if (par1[0] > 0.9 && par3[0] > 0.9)
    {
     par3[0] = 0.0;
    }
   else if (par1[0] < 0.1 && par3[0] < 0.1)
    {
     par3[0] = 1.0;
    }
   else
    {
     if (par3[0] > par1[0])
         par3[0] = 1.0;
     else 
         par3[0] = 0.0;
    }
  }
 else
 if ((dist2 <= chdht_tol) && (dist1 > chdht_tol))
  {
   if (par1[0] > 0.9 && par3[0] > 0.9)
    {
     par1[0] = 0.0;
    }
   else if (par1[0] < 0.1 && par3[0] < 0.1)
    {
     par1[0] = 1.0;
    }
   else
    {
     if (par1[0] > par3[0])
         par1[0] = 1.0;
     else 
         par1[0] = 0.0;
    }
  }

 mid_par = (par1[0] + par3[0]) / 2;

 if (((par1[0] <= knot_tol) || (par1[0] >= 1-knot_tol)) &&
     ((par3[0] <= knot_tol) || (par3[0] >= 1-knot_tol)))
  {
   stat = BScv_copy(&msg, curve, trimmed_curve);
   EMerr_hndlr(! stat || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }
 else
  {
   stat = BSpartofcv (&msg,curve,par1[0], mid_par, par3[0],trimmed_curve);
   EMerr_hndlr(! stat || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSedge.EFfix_the_curve");
 if (par1) om$dealloc(ptr = par1);
 if (par2) om$dealloc(ptr = par2);
 if (par3) om$dealloc(ptr = par3);
 if (par4) om$dealloc(ptr = par4);
 if (cv1_points) om$dealloc (ptr = cv1_points);
 if (cv2_points) om$dealloc (ptr = cv2_points);
 if (cv3_points) om$dealloc (ptr = cv3_points);
 if (cv4_points) om$dealloc (ptr = cv4_points);
 if (beg_edge_geom.weights) om$dealloc (ptr = beg_edge_geom.weights);
     beg_edge_geom.weights = NULL;
 if (beg_edge_geom.poles) om$dealloc (ptr = beg_edge_geom.poles);
     beg_edge_geom.poles = NULL;
 if (beg_edge_geom.knots) om$dealloc (ptr = beg_edge_geom.knots);
     beg_edge_geom.knots = NULL;
 if (beg_edge_geom.bdrys) om$dealloc (ptr = beg_edge_geom.bdrys);
     beg_edge_geom.bdrys = NULL;

 if (end_edge_geom.weights) om$dealloc (ptr = end_edge_geom.weights);
     end_edge_geom.weights = NULL;
 if (end_edge_geom.poles) om$dealloc (ptr = end_edge_geom.poles);
     end_edge_geom.poles = NULL;
 if (end_edge_geom.knots) om$dealloc (ptr = end_edge_geom.knots);
     end_edge_geom.knots = NULL;
 if (end_edge_geom.bdrys) om$dealloc (ptr = end_edge_geom.bdrys);
     end_edge_geom.bdrys = NULL;
 return (stat_OM);
}

IGRlong EMget_right_loop (EMmsg, old_edge, num_loops, loop_ids, loop_num,
                          partolbasis)

IGRlong               *EMmsg;
GRobjid               old_edge;
IGRint                *num_loops;
GRobjid               *loop_ids;
IGRint                *loop_num;
struct EMSpartolbasis *partolbasis;

 {
  IGRlong               stat_OM, msg;
  IGRint                i;
  IGRdouble             min_dist;
  IGRdouble             uv_begpt[2];
  struct EMSproj_info   proj_info;
  OM_S_CHANSELECT       to_edges;

 /*-------------------------------------------------------------*/

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 *loop_num = 0;

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

 min_dist = 9999999.0;
 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uv_begpt,
                         NULL, NULL, NULL, NULL),
                   senderid = NULL_OBJID,
                   targetid = old_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 for (i=0; i<(*num_loops); i++)
  {
   stat_OM = om$send(msg = message EMSedge.EMptproject (&msg, uv_begpt, 1,
                           &proj_info, NULL, partolbasis),
                     senderid = loop_ids[i],
                     p_chanselect = &to_edges,
                     from = 0,
                     to = 0);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   if (proj_info.dist < min_dist)
    {
     *loop_num = i;
     min_dist = proj_info.dist;
    }
  }

 wrapup:
  EMWRAPUP (*EMmsg, stat_OM, "EMSedge.EMget_right_loop");
  return (stat_OM);

 }

IGRlong EMget_right_edge (EMmsg, old_edge, loop_id, ed_count, edge_index,
                          partolbasis)

IGRlong               *EMmsg;
GRobjid               old_edge;
GRobjid               loop_id;
IGRint                ed_count;
IGRint                *edge_index;
struct EMSpartolbasis *partolbasis;

 {
  IGRlong               stat_OM, msg;
  IGRint                i;
  IGRdouble             min_dist;
  IGRdouble             my_parms[2];
  struct EMSproj_info   proj_info;
  struct EMSedgebound   bound[2], mid_param;
  OM_S_CHANSELECT       to_edges;

 /*-------------------------------------------------------------*/

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 *edge_index = 0;

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, NULL,
                         NULL, bound, &bound[1], NULL),
                   senderid = NULL_OBJID,
                   targetid = old_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 if (bound[0].span_inx == bound[1].span_inx)
     mid_param.span_inx = bound[0].span_inx;
 else
     mid_param.span_inx =
          (IGRint) (bound[0].span_inx + bound[1].span_inx)/2;

 mid_param.param = (bound[0].param + bound[1].param) / 2;

 stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1, &mid_param,
                         NULL, my_parms),
                   senderid = NULL_OBJID,
                   targetid = old_edge);
 EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 min_dist = 9999999.0;

 for (i=0; i<ed_count; i++)
  {
   stat_OM = om$send(msg = message EMSedge.EMptproject (&msg, my_parms, 1,
                           &proj_info, NULL, partolbasis),
                     senderid = loop_id,
                     p_chanselect = &to_edges,
                     from = i,
                     to = i);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   if (proj_info.dist < min_dist)
    {
     *edge_index = i;
     min_dist = proj_info.dist;
    }
  }

 wrapup:
  EMWRAPUP (*EMmsg, stat_OM, "EMSedge.EMget_right_edge");
  return (stat_OM);

 }

end implementation EMSedge;
