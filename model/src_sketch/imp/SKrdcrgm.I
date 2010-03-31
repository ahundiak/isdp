class implementation SKradial;

#include "OMmacros.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dim.h"
#include "dimplcmacros.h"

#define FIRST  0
#define SECOND 1

extern GRclassid OPP_SKarc_class_id, OPP_SKcircle_class_id;

from GRcurve import GRmidpoint;

method SKcreate_geom (IGRlong *msg; unsigned short options;
                      struct GRmd_env *md_env; GRobjid *geom_handle)
{
  IGRshort planmattyp;
  OMuint count;
  IGRint i, j, counts[2];
  IGRlong index, msg_loc, stat_OM;
  IGRpoint pt;
  IGRmatrix planmat;
  GRobjid obj, skmgr, arcobj, vars[2], geomlist[2][3];
  GRclassid objclass;
  GRspacenum dum_os;
  struct GRid planid, dimid, origid, my_grid;
  struct GRparms ref_parms;
  OM_S_CHANSELECT chan_to_vars, chan_to_geom, chan_to_parent, chan_to_memb;
  OM_S_OBJECT_LINKAGE varlist[2], objlist;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the arc. Looked up via the member-SKptpt constraint, it's
   * variables, then it's geometry.
   */

  EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_memb);
  count = 0;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_memb,
   size = 1, count = &count, list = &objlist);
  EMerr_hndlr (count != 1, *msg, EMS_E_InvalidCase, ret_end);

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);
  count = 0;
  om$get_channel_objects (objid = objlist.S_objid,
   p_chanselect = &chan_to_vars, size = 2, count = &count, list = varlist);
  EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);
  for (i=0; i<2; i++)
    vars[i] = varlist[i].S_objid;

  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geom);
  for (i=FIRST; i<=SECOND; i++)
    {
    count = 0;
    om$get_channel_count (objid = vars[i], p_chanselect = &chan_to_geom,
     count = &count);
    EMerr_hndlr (!count, *msg, EMS_E_InvalidCase, ret_end);

    counts[i] = 0;
    for (j=0; j<count; j++)
      {
      om$get_objid_at_index (objid = vars[i], p_chanselect = &chan_to_geom,
       index = j, objidaddr = &obj, osnumaddr = &dum_os);

      om$get_classid (objid = obj, p_classid = &objclass);
      if ((om$is_ancestry_valid (subclassid = objclass,
              superclassid = OPP_SKarc_class_id) == OM_S_SUCCESS) ||
          (om$is_ancestry_valid (subclassid = objclass,
              superclassid = OPP_SKcircle_class_id) == OM_S_SUCCESS))
         {
        geomlist[i][counts[i]] = obj;
        counts[i]++;
        }
      }
    }
  EMerr_hndlr (!counts[FIRST] || !counts[SECOND], *msg,
   EMS_E_InvalidArg, ret_end);

  arcobj = NULL_OBJID;
  for (i=0; i<counts[FIRST]; i++)
    for (j=0; j<counts[SECOND]; j++)
        if (geomlist[FIRST][i] == geomlist[SECOND][j])
          arcobj = geomlist[FIRST][i];
  EMerr_hndlr (IF_NULL_OBJID (arcobj), *msg, EMS_E_InvalidCase,
   ret_end);

  /*
   * The plane parent of the dimension is the plane parent
   * of this sketch manager.
   */

  stat_OM = om$send (msg = message SKconstraint.SKgetmgr (&msg_loc, &skmgr),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  planid.objid = NULL_OBJID;
  EMmake_chanselect (NDfather_father, &chan_to_parent);
  om$send (msg = message NDnode.ASreturn_go (&planid, &planmattyp,
    planmat), senderid = skmgr, p_chanselect = &chan_to_parent,
    from = FIRST, to = FIRST);
  EMerr_hndlr (IF_NULL_OBJID (planid.objid), *msg, EMS_E_Fail, ret_end);

  /*
   * Obtain the midpoint of the arc as the point where the radial dimension
   * will attach.
   */

  stat_OM = om$send (msg = message GRcurve.GRmidpoint (&msg_loc, 
             &md_env->md_env.matrix_type, md_env->md_env.matrix, 
             &ref_parms, pt), targetid = arcobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  dimid.objid = NULL_OBJID;
  origid.objid = arcobj;
  origid.osnum = OM_Gw_current_OS;
  dm$place_radial (orig_grid = &origid, orig_pt = pt,
   plane_grid = &planid, dim_grid = &dimid);
  EMerr_hndlr (IF_NULL_OBJID (dimid.objid), *msg, EMS_E_Fail, ret_end);

  /*
   * Rigidly connect the geometric handle to me
   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  index = OM_K_MAXINT;
  stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
             &my_grid, &index), targetid = dimid.objid);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Return one of the point handles as the geometric handle to this
   * constraint
   */

  if (geom_handle)
    *geom_handle = dimid.objid;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKradial.SKcreate_geom");
  return (stat_OM);
}

end implementation SKradial;
