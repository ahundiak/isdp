/*
  DESCRIPTION
    Simulates a tangency constraint for a profile vertex by placing a collinear
    or normal constraint.
  
  HISTORY
    Rajiv Agrawal : 12/4/92 : Implement handling of tangency constraint between 
                              b-spline and line, b-spline and arc, and two b-splines.

*/

class implementation SKtangency;

#include "OMmacros.h"

#define FIRST  0
#define SECOND 1

from SKvariable import SKgetvar;

extern OMuword OPP_SKnormal_class_id, OPP_SKcollinear_class_id;

method SKinit (IGRlong *msg; IGRushort options;
               struct GRmd_env *md_env;
               IGRint num_pts; GRobjid *pt_ids;
               IGRushort cnstr_props;
               GRobjid *geom_handle;
               IGRchar *moreinfo)
{
  IGRushort 		gmtypes[2];
  IGRint  		i;
  OMuint  		count;
  IGRlong 		stat_OM, msg_loc;
  GRobjid 		cnstr_id, geomobj;
  GRspacenum 		dumos;
  GRclassid 		cnstr_classid;
  OM_S_CHANSELECT 	chan_to_geoms, chan_to_vars, chan_to_cnstr;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Determine whether the working constraint will be a collinear
   * or an orthogonality constraint.
   */

  EMmake_chanselect(SKvariable_to_geometries, &chan_to_geoms);
  count = 0;
  om$get_channel_count (objid = pt_ids[FIRST],
                        p_chanselect = &chan_to_geoms, count = &count);
  EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);

  for (i=FIRST; i<=SECOND; i++)
  {
    geomobj = NULL_OBJID;
    om$get_objid_at_index (objid = pt_ids[FIRST],
                           p_chanselect = &chan_to_geoms, index = i, 
                           objidaddr = &geomobj, osnumaddr = &dumos);
    EMerr_hndlr (IF_NULL_OBJID (geomobj), *msg, EMS_E_InvalidCase, ret_end);

    SKgetgeomtype (geomobj, OM_Gw_current_OS, &gmtypes[i]);
  }

  if ((gmtypes[FIRST] == SK_LINE && gmtypes[SECOND] == SK_ARC) ||
      (gmtypes[SECOND] == SK_LINE && gmtypes[FIRST] == SK_ARC))
    cnstr_classid = OPP_SKnormal_class_id;
  else if (gmtypes[FIRST] == SK_ARC && gmtypes[SECOND] == SK_ARC)
    cnstr_classid = OPP_SKcollinear_class_id;
  else if ((gmtypes[FIRST] == SK_LINE && gmtypes[SECOND] == SK_BSPLINE) ||
           (gmtypes[SECOND] == SK_LINE && gmtypes[FIRST] == SK_BSPLINE))
    cnstr_classid = OPP_SKcollinear_class_id;
  else if ((gmtypes[FIRST] == SK_ARC && gmtypes[SECOND] == SK_BSPLINE) ||
           (gmtypes[SECOND] == SK_ARC && gmtypes[FIRST] == SK_BSPLINE))
    cnstr_classid = OPP_SKnormal_class_id;
  else if (gmtypes[FIRST] == SK_BSPLINE && gmtypes[SECOND] == SK_BSPLINE)
    cnstr_classid = OPP_SKcollinear_class_id;
  else    
   {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);}

  /*
   * Construct and initialize this and the working constraint
   */

  stat_OM = om$construct (classid = cnstr_classid, p_objid = &cnstr_id,
                          msg = message SKconstraint.SKinit (&msg_loc,
                                (options | SK_OPT_NO_MGR_CONNECT) & ~SK_OPT_CREATE_GEOMETRY,
                                 md_env, num_pts, pt_ids, NULL, NULL, NULL)
                         );
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message SKinterface.SKconnect_to_member
                           (&msg_loc, NULL, cnstr_id, MAXINT, MAXINT),
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);
  EMmake_chanselect (SKvariable_to_constraints, &chan_to_cnstr);
  stat_OM = om$send (msg = message Root.connect 
                           (chan_to_vars, 0, pt_ids[FIRST], OM_Gw_current_OS, chan_to_cnstr, 0),
                     targetid = my_id);
  EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);

  stat_OM = om$send (mode = OM_e_wrt_parent,
                     msg = message SKtangency.SKinit (&msg_loc,
                           (options & ~SK_OPT_NO_MGR_CONNECT) | SK_OPT_NO_CONNECT_PTS,
                            md_env, num_pts, pt_ids, cnstr_props, geom_handle, moreinfo), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKtangency.SKinit");
  return (stat_OM);
}

end implementation SKtangency;
