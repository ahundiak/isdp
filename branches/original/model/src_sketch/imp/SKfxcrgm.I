class implementation SKfixang;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dim.h"
#include "dimplcmacros.h"
#include "msmacros.h"
#include "ECmsg.h"

#define FIRST  0
#define SECOND 1

extern GRclassid OPP_SKline_class_id;

from SKvariable import SKgetvar;

method SKcreate_geom (IGRlong *msg; unsigned short options;
                      struct GRmd_env *md_env; GRobjid *geom_handle)
{
  IGRshort planmattyp;
  IGRuint count;
  IGRint i, j, sector, counts[2];
  IGRlong msg_loc, stat_OM, index;
  IGRpoint pt;
  IGRmatrix planmat;
  GRobjid obj, skmgr, lineobj, vars[2], geomlist[2][3];
  GRclassid objclass;
  GRspacenum dum_os;
  struct GRid planid, dimid, origid, measid, my_grid;
  OM_S_CHANSELECT chan_to_vars, chan_to_geom, chan_to_parent;
  OM_S_OBJECT_LINKAGE varlist[2];
  IGRboolean aflag;
  long sts = 1;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  aflag = pwIsActivationOn();

  /*
   * Obtain the origin (measure) point that need to be supplied to
   * dimension macro. It is assumed that the first point of the constraint
   * is at the vertex of the angle and this is the one that is given
   * as the required point.
   */

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);
  count = 0;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_vars,
   size = 2, count = &count, list = varlist);
  EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);
  vars[FIRST] = varlist[FIRST].S_objid;
  vars[SECOND] = varlist[SECOND].S_objid;

  stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL,
             &md_env->md_env.matrix_type, md_env->md_env.matrix,
             pt), targetid = vars[FIRST]);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  if(aflag)
  {
    /*
     * The pt has been computed in model space. But as the dimension
     * macro needs that in ref-space, transform it to ref-space
     * by the inverse of mat.
     */
     int num_pts = 1;
    sts = RFinverse_pts( md_env->md_env.matrix, num_pts, &pt);
    EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
 
  }


  /*
   * Obtain the relevant origin (measure) objects. Only the line segment is
   * needed. 
   */

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
      if (om$is_ancestry_valid (subclassid = objclass,
           superclassid = OPP_SKline_class_id) == OM_S_SUCCESS)
        {
        geomlist[i][counts[i]] = obj;
        counts[i]++;
        }
      }
    }

  /* 
   * made the msg a success even if there is no line to connect to.  RA 3/20/92
   */
  if (!counts[FIRST] || !counts[SECOND])
  {
    ex$message (msgnumb = EMS_S_CouldNotConstAngleConst);
  }
  EMerr_hndlr (!counts[FIRST] || !counts[SECOND], *msg, EMS_S_InvalidArg,
               ret_end);

  lineobj = NULL_OBJID;
  for (i=0; i<counts[FIRST]; i++)
    for (j=0; j<counts[SECOND]; j++)
      if (geomlist[FIRST][i] == geomlist[SECOND][j])
        lineobj = geomlist[FIRST][i];
  EMerr_hndlr (IF_NULL_OBJID (lineobj), *msg, EMS_E_InvalidCase,
   ret_end);

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
  origid.objid = lineobj;
  origid.osnum = OM_Gw_current_OS;
  measid.objid = lineobj;
  measid.osnum = OM_Gw_current_OS;
  sector = NULL;
  dm$place_angular (orig_grid = &origid, orig_pt = pt,
   meas_grid = &measid, meas_pt = pt, plane_grid = &planid,
   sector = sector, mask = ANG_DIM_HORIZANTAL, dim_grid =  &dimid);
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
  EMWRAPUP (*msg, stat_OM, "SKfixang.SKcreate_geom");
  return (stat_OM);
}

end implementation SKfixang;
