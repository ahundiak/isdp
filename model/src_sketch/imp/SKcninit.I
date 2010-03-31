/*
  DESCRIPTION

    This method initializes a constraint. The point-variables passed in
    are assumed to be part of sketch-manager (which is also assumed to
    exist). Initialization consists of:

    1) Initialize the "props" field,
    2) Sequence the input points via the message SKorder_points.
    3) Connect the variables to the constraint (can be inhibited)
    4) Connect the constraint to the manager (can be inhibited)
    5) Connect the geometric handle (if passed in) as a component (can be
        inhibited)
                                     OR
       Create a geometric handle and have it connected up as a component (can
        be inhibited)
    6) Display the geometric handle if requested by the options chosen.
*/

class implementation SKconstraint;

#include "OMmacros.h"
#include <alloca.h>

from SKmgr import SKmgrprops;
from SKvariable import SKgetmgr;

method SKinit (IGRlong *EMmsg; IGRushort options;
               struct GRmd_env *md_env;
               IGRint num_pts; GRobjid *pt_ids;
               IGRushort cnstr_props;
               GRobjid *geom_handle;
               IGRchar *moreinfo)
{
 IGRlong status;
 IGRlong index;
 GRobjid *loc_pt_ids, mgr;
 struct GRid my_GRid;
 OM_S_CHANSELECT cnstr_pts_chan, pts_cnstr_chan;
 OM_S_CHANSELECT constraint_to_mgr, to_constraints;
 enum GRdpmode dpmode;
 IGRint i;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 /*
  * Initialize the "props" field based on input. The introduction
  * of a constraint causes the sketch to be out-of-date. Mark this.
  */

 if (options & SK_OPT_MARK_AS_NEWADD)
   ME.SKconstraint->props |= SK_NEWADD;
 if (options & SK_OPT_MARK_AS_USERADD)
   ME.SKconstraint->props |= SK_USERADD;
 ME.SKconstraint->props |= cnstr_props;
 
 status = om$send (msg = message SKvariable.SKgetmgr (EMmsg, &mgr),
          targetid = pt_ids[0]);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 status = om$send (msg = message SKmgr.SKmgrprops (EMmsg, SK_CHGPROPS_ON,
           SK_MGR_OUTOFDATE, NULL), targetid = mgr);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 /*
  * Order the variational points that are sent in
  */

 loc_pt_ids = (GRobjid *) alloca (num_pts * sizeof (GRobjid));
 EMerr_hndlr (!loc_pt_ids, *EMmsg, EMS_E_NoStackMemory, wrapup);
 
 OM_BLOCK_MOVE (pt_ids, loc_pt_ids, num_pts * sizeof (GRobjid));

 status = om$send (msg = message SKconstraint.SKorder_points (EMmsg,options,
           num_pts, loc_pt_ids, moreinfo),
           targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 /*
  * If not inhibited, connect the points up to this constraint.
  */

 if (!(options & SK_OPT_NO_CONNECT_PTS))
  {
  EMmake_chanselect (SKconstraint_to_variables, &cnstr_pts_chan);
  EMmake_chanselect (SKvariable_to_constraints, &pts_cnstr_chan);
  for (i=0;i<num_pts;i++)
    {
    status  = om$send (msg = message Root.connect (cnstr_pts_chan,
               OM_K_MAXINT, loc_pt_ids[i], OM_Gw_current_OS, 
               pts_cnstr_chan, i), targetid = my_id);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
    }
  }
                         
 /*
  * If not inhibited, connect this constraint up to the manager
  */

 if (!(options & SK_OPT_NO_MGR_CONNECT))
   {
   EMmake_chanselect (SKconstraint_to_mgr, &constraint_to_mgr);
   EMmake_chanselect (SKmgr_to_constrs, &to_constraints);
   status = om$send (msg = message Root.connect(constraint_to_mgr,OM_K_MAXINT,
             mgr,OM_Gw_current_OS, to_constraints, OM_K_MAXINT),
             targetid = my_id);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
   }

 /*
  * If not inhibited, connect up the geometric-handle being passed in
  * as a component. If this connection is not being made check if this
  * constraint should generate it's own geometric handle (and have it
  * connected up as a component).
  */

 if (options & SK_OPT_CONNECT_GEOMETRY && geom_handle)
   {
   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;

   index = 0;
   status = om$send (msg = message GRconnector.GRrigidconn (EMmsg,
             &my_GRid, &index), targetid = *geom_handle);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }
 else if (options & SK_OPT_CREATE_GEOMETRY)
   {
   status  = om$send (msg = message SKconstraint.SKcreate_geom (EMmsg,
              options, md_env, geom_handle), targetid = my_id);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }

 /*
  * If the request for display is on, do the display
  */

 if (options & SK_OPT_DISPLAY_GEOMETRY)
   {
   dpmode = GRbd;
   status = om$send (msg = message GRgraphics.GRdisplay (EMmsg,
             &md_env->md_env.matrix_type, md_env->md_env.matrix, &dpmode,
             &md_env->md_id), targetid = my_id);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }

  /*
   * The solution path for the this sketch-manager needs to be recalculated.
   * Nullify the existing solution path ... no longer being done. Rajiv  7/30/92

  SKfree_solvepath();
   */

wrapup:
 EMWRAPUP (*EMmsg, status, "SKconstraint.SKinit");
 return (status);
}


end implementation SKconstraint;
