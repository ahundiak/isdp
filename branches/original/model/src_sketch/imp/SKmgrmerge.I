class implementation SKmgr;

#include <alloca.h>
#include <math.h>

#include "bserr.h"
#include "bsparameters.h"
#include "bsdotp.h"
#include "maptpldis.h"

from SKvariable import SKputvar, SKgetvar;

/*

Name
  SKmergemgr

Abstract

Synopsis

Description

Return Value

Notes

Index

Keywords

History
  07/02/93 : Sudha  :  Modified for BSprototypes ansification
  10/27/93 : Rajiv Agrawal : check for ref-planes before merging. (TR#119310913)

 */
method SKmergemgr (IGRlong *msg; IGRushort opts;
                   struct GRmd_env *md_env;
                   GRobjid other_mgr)
{
  IGRshort 		mattyp, other_xyz_mattyp, my_xy_mattyp;
  OMuint   		other_num_pts, other_num_cnstrs, other_num_geoms;
  IGRint 		i;
  IGRlong 		owner_index, msg_loc, stat_OM;
  IGRdouble 		mdist, *mat, lentol, dottol;
  IGRpoint 		my_origin, other_origin, other_pt;
  IGRvector 		my_xaxis, my_zaxis, other_xaxis, other_zaxis;
  IGRmatrix 		other_xyz_mat, my_xy_mat;
  GRobjid 		ptobj, cnobj, gmobj;
  struct GRid 		refpln_grid[2];
  struct IGRplane 	pln;
  struct GRid 		other_mgr_id, my_grid;
  OM_S_CHANSELECT 	chan_to_vars, chan_to_constrs;
  OM_S_CHANSELECT 	chan_to_vmgr, chan_to_cmgr, chan_to_comps, chan_to_parent;
  OM_S_OBJECT_LINKAGE 	*other_ptobjs, *other_cnstrs, *other_geoms;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Check if the managers being merged lie on the same reference plane.
   */
  EMmake_chanselect (NDfather_father, &chan_to_parent);
  refpln_grid[0].objid = refpln_grid[1].objid = NULL_OBJID;
  om$get_objid_at_index (objid = my_id, 
                         p_chanselect = &chan_to_parent,
                         index = 0, 
                         objidaddr = &refpln_grid[0].objid, 
                         osnumaddr = &refpln_grid[0].osnum);

  om$get_objid_at_index (objid = other_mgr, 
                         p_chanselect = &chan_to_parent,
                         index = 0, 
                         objidaddr = &refpln_grid[1].objid, 
                         osnumaddr = &refpln_grid[1].osnum);
  EMerr_hndlr ( refpln_grid[0].objid != refpln_grid[1].objid, *msg, EMS_I_BadPlane, ret_end );

  /*
   * Check if the two sketches lie on the same plane and are oriented
   * the same way
   */

  stat_OM = om$send (msg = message SKmgr.SKgetornt (&msg_loc, my_origin,
             my_xaxis, my_zaxis), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message SKmgr.SKgetornt (&msg_loc, other_origin,
             other_xaxis, other_zaxis), targetid = other_mgr);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  pln.point = my_origin;
  pln.normal = my_zaxis;
  MAptpldis (&msg_loc, other_origin, &pln, &mdist);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
            
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  BSEXTRACTPAR (&msg_loc, BSTOLTRPLPROD, dottol);

  EMerr_hndlr (mdist > lentol ||
               fabs (BSdotp (&msg_loc, my_xaxis, other_xaxis) - 1.0) > dottol,
   *msg, opts & SK_UPDATE_INFOERROR ? EMS_I_InvalidCase : EMS_E_InvalidCase,
    ret_end);

  if (opts & SK_UPDATE_DONOTPOST)
    goto ret_end;

  /*
   * The two sketches are oriented correctly for merging to take place.
   * Proceed to merge the other sketch into this one. First thing is to
   * transform the points of the other sketch into this sketch's local
   * coordinate system. Also disconnect these points from the other
   * sketch and connect them onto this sketch.
   */

  mattyp = md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc,
             SK_OPT_GET_XY_TO_XYZ, &mattyp, mat, &other_xyz_mattyp,
             other_xyz_mat), targetid = other_mgr);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc,
             SK_OPT_GET_XYZ_TO_XY, &mattyp, mat, &my_xy_mattyp, my_xy_mat),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
 
  EMmake_chanselect (SKmgr_to_vars, &chan_to_vars);

  om$get_channel_count (objid = other_mgr, p_chanselect = &chan_to_vars,
   count = &other_num_pts);

  other_ptobjs = (OM_p_OBJECT_LINKAGE) alloca (other_num_pts *
                  sizeof (OM_S_OBJECT_LINKAGE));
  EMerr_hndlr (!other_ptobjs, *msg, EMS_E_NoStackMemory, ret_end);

  om$get_channel_objects (objid = other_mgr, p_chanselect = &chan_to_vars,
   count = &other_num_pts, size = other_num_pts, list = other_ptobjs);

  stat_OM = om$send (msg = message Root.wild_disconnect (chan_to_vars),
             targetid = other_mgr);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);

  EMmake_chanselect (SKvariable_to_mgr, &chan_to_vmgr);

  for (i=0; i<other_num_pts; i++)
  {
    ptobj = other_ptobjs[i].S_objid;

    stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
               SK_OPT_FULL_TRANSFORM, &other_xyz_mattyp, other_xyz_mat,
               other_pt), targetid = ptobj);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = om$send (msg = message SKvariable.SKputvar (&msg_loc,
               SK_OPT_FULL_TRANSFORM, &my_xy_mattyp, my_xy_mat,
               other_pt), targetid = ptobj);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = om$send (msg = message Root.connect (chan_to_vmgr, OM_K_MAXINT,
               my_id, OM_Gw_current_OS, chan_to_vars, 0), targetid = ptobj);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);
  }

  /*
   * Next, move the constraints from the other sketch onto this sketch
   * manager.
   */

  EMmake_chanselect (SKmgr_to_constrs, &chan_to_constrs);

  om$get_channel_count (objid = other_mgr, p_chanselect = &chan_to_constrs,
   count = &other_num_cnstrs);

  other_cnstrs = (OM_p_OBJECT_LINKAGE) alloca (other_num_cnstrs *
                  sizeof (OM_S_OBJECT_LINKAGE));
  EMerr_hndlr (!other_cnstrs, *msg, EMS_E_NoStackMemory, ret_end);

  om$get_channel_objects (objid = other_mgr, p_chanselect = &chan_to_constrs,
   count = &other_num_cnstrs, size = other_num_cnstrs, list = other_cnstrs);

  stat_OM = om$send (msg = message Root.wild_disconnect (chan_to_constrs),
                     targetid = other_mgr);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);

  EMmake_chanselect (SKconstraint_to_mgr, &chan_to_cmgr);

  for (i=0; i<other_num_cnstrs; i++)
  {
    cnobj = other_cnstrs[i].S_objid;

    stat_OM = om$send (msg = message Root.connect (chan_to_cmgr, OM_K_MAXINT,
               my_id, OM_Gw_current_OS, chan_to_constrs, 0),
               targetid = cnobj);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);
  }             

  /*
   * Next, move the geometry from the other sketch onto this sketch
   * manager.
   */

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);

  om$get_channel_count (objid = other_mgr, p_chanselect = &chan_to_comps,
                        count = &other_num_geoms);

  other_geoms = (OM_p_OBJECT_LINKAGE) alloca (other_num_geoms *
                 sizeof (OM_S_OBJECT_LINKAGE));
  EMerr_hndlr (!other_geoms, *msg, EMS_E_NoStackMemory, ret_end);

  om$get_channel_objects (objid = other_mgr, p_chanselect = &chan_to_comps,
   count = &other_num_geoms, size = other_num_geoms, list = other_geoms);

  other_mgr_id.objid = other_mgr;
  other_mgr_id.osnum = OM_Gw_current_OS;
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  owner_index = OM_K_MAXINT;
  for (i=0; i<other_num_geoms; i++)
  {
    gmobj = other_geoms[i].S_objid;
  
    stat_OM = om$send (msg = message GRconnector.GRdisconn (&msg_loc,
               &other_mgr_id), targetid = gmobj);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_OMerror, ret_end);

    stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
               &my_grid, &owner_index),
               targetid = gmobj);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_OMerror, ret_end);
  }             

  /*
   * The other, now emptied sketch manager, is deleted
   */

  stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc, md_env),
             targetid = other_mgr);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_OMerror, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKmgrmerge");
  return (stat_OM);
}

end implementation SKmgr;
