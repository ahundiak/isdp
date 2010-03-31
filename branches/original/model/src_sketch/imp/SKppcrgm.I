class implementation SKptpt;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dim.h"
#include "dimplcmacros.h"
#include "bserr.h"

#define FIRST  0
#define SECOND 1

#define X 0
#define Y 1
#define Z 2

extern GRclassid OPP_SKhvptpt_class_id;
extern GRclassid OPP_SKline_class_id;

from SKvariable import SKgetvar;

method SKcreate_geom (IGRlong *msg; unsigned short options;
                      struct GRmd_env *md_env; GRobjid *geom_handle)
{
  IGRboolean sglpara;
  IGRshort planmattyp;
  OMuint   count;
  IGRint i, j, axis, trak_dir, counts[2];
  IGRlong index, msg_loc, stat_OM;
  IGRpoint pts[2];
  IGRmatrix planmat;
  GRobjid obj, skmgr, vars[2], geoms[2], geomlist[2][3];
  GRclassid myclass, objclass;
  GRspacenum dum_os;
  struct GRid planid, dimid, origid, measid, my_grid;
  OM_S_CHANSELECT chan_to_vars, chan_to_geom, chan_to_parent;
  OM_S_OBJECT_LINKAGE varlist[2];
  IGRboolean aflag = 0;
  IGRlong sts = 1;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  //aflag = pwIsActivationOn();
  /*
   * Obtain the origin and measure points that need to be supplied to
   * dimension macro. 
   */

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);
  count = 0;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_vars,
   size = 2, count = &count, list = varlist);
  EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);
  
  for (i=FIRST; i<=SECOND; i++)
    {
    vars[i] = varlist[i].S_objid;
    stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL,
               &md_env->md_env.matrix_type, md_env->md_env.matrix,
               pts[i]), targetid = vars[i]);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * Obtain the relevant origin and measure objects. In the case of a single
   * parallel dimension, only the line segment is needed. In this case,
   * the origin point is also modified to be the mid-point.
   */

  sglpara = FALSE;
  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geom);
  om$get_classid (object = me, p_classid = &myclass);
  if (om$is_ancestry_valid (subclassid = myclass,
       superclassid = OPP_SKhvptpt_class_id) == OM_S_SUCCESS)
    {
    for (i=FIRST; i<=SECOND; i++)
      {
      geoms[i] = NULL_OBJID;
      om$get_objid_at_index (objid = vars[i], p_chanselect = &chan_to_geom,
       index = 0, objidaddr = &geoms[i], osnumaddr = &dum_os);
      EMerr_hndlr (IF_NULL_OBJID (geoms[i]), *msg, EMS_E_InvalidCase, ret_end);
      }
    }
  else
    {
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
        if (om$is_ancestry_valid (subclassid = objclass,
             superclassid = OPP_SKline_class_id) == OM_S_SUCCESS)
          {
          geomlist[i][counts[i]] = obj;
          counts[i]++;
          }
        }
      }
    EMerr_hndlr (!counts[FIRST] || !counts[SECOND], *msg, EMS_E_InvalidArg,
     ret_end);

    geoms[FIRST] = NULL_OBJID;
    for (i=0; i<counts[FIRST]; i++)
      for (j=0; j<counts[SECOND]; j++)
        if (geomlist[FIRST][i] == geomlist[SECOND][j])
          geoms[FIRST] = geomlist[FIRST][i];
    EMerr_hndlr (IF_NULL_OBJID (geoms[FIRST]), *msg, EMS_E_InvalidCase,
     ret_end);

    for (i=X; i<=Z; i++)
      pts[FIRST][i] = pts[FIRST][i] + (pts[SECOND][i] - pts[FIRST][i])/2.0;

    sglpara = TRUE;
    }

  /*
   * Create the dimension object. The plane parent is the plane parent
   * of this sketch manager.
   */

  stat_OM = om$send (msg = message SKconstraint.SKgetmgr (&msg_loc, &skmgr),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  EMmake_chanselect (NDfather_father, &chan_to_parent);
  stat_OM = om$send (msg = message NDnode.ASreturn_go (&planid, &planmattyp,
             planmat), senderid = skmgr, p_chanselect = &chan_to_parent,
             from = FIRST, to = FIRST);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

  dimid.objid = NULL_OBJID;
  if (sglpara)
    {
    origid.objid = geoms[FIRST];
    origid.osnum = OM_Gw_current_OS;
    trak_dir = FALSE;
    dm$place_sglpara (orig_grid = &origid, orig_pt = pts[FIRST],
     plane_grid = &planid, trak_dir = trak_dir, dim_grid =  &dimid);
    EMerr_hndlr (IF_NULL_OBJID (dimid.objid), *msg, EMS_E_Fail, ret_end);
    }
  else
    {
    origid.objid = geoms[FIRST];
    origid.osnum = OM_Gw_current_OS;
    measid.objid = geoms[SECOND];
    measid.osnum = OM_Gw_current_OS;
    trak_dir = TRUE;
    axis = ME.SKconstraint->props & SK_HORIZONTAL ? DM_MEA_AXIS : NULL;
    dm$place_stack_linear (orig_grid = &origid, orig_pt = pts[FIRST],
     meas_grid = &measid, meas_pt = pts[SECOND], plane_grid = &planid,
     trak_dir = trak_dir, axis = axis, dim_grid = &dimid);
    }

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
  EMWRAPUP (*msg, stat_OM, "SKptpt.SKcreate_geom");
  return (stat_OM);
}

end implementation SKptpt;
