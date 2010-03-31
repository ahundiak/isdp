class implementation SKifcol;

#include "OMmacros.h"

extern OMuword OPP_SKcollinear_class_id;
/*

Name
  SKinit

Abstract

Synopsis

Description
  This method creates individual collinear constraints out of the given 
  set of points.  These constraints are then attached to the parent super-
  constraint.
  
Return Value

Notes

Index

Keywords
  collinear, constraint, initialization

History
  07/28/93 : Rajiv Agrawal : changed the order in which the collinear constraints are
                             created.  (TR119222548)

 */

method SKinit (IGRlong *msg; IGRushort options;
               struct GRmd_env *md_env;
               IGRint num_pts; GRobjid *pt_ids;
               IGRushort cnstr_props;
               GRobjid *geom_handle;
               IGRchar *moreinfo)

{
  int 		i, num_col_cnstrs;
  long 		stat_OM, msg_loc;
  GRobjid 	cnstrid, col_pts[3];

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * Create individual collinear constraints.  The constraints are
   * always between pnt-1, pnt-2, and pnt-n where n is the nth constraint.
   * Each of the member constraints is connected up to this interface.
   */

  num_col_cnstrs = num_pts - 2;
  col_pts[0] = pt_ids[0];
  col_pts[1] = pt_ids[1];
  for (i=0; i<num_col_cnstrs; i++)
  {
    col_pts[2] = pt_ids[2+i];

    stat_OM = om$construct (classid = OPP_SKcollinear_class_id,
                            msg = message SKconstraint.SKinit (&msg_loc,
                                  (options | SK_OPT_NO_MGR_CONNECT) & ~SK_OPT_CREATE_GEOMETRY,
                                 md_env, 3, col_pts, cnstr_props, NULL, moreinfo),
                            p_objid = &cnstrid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_OMerror, ret_end);

    stat_OM = om$send (msg = message SKinterface.SKconnect_to_member
                             (&msg_loc, NULL, cnstrid, MAXINT, MAXINT),
                       targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_OMerror, ret_end);
  }
  
  /*
   * Having constructed the member constraints, this interface constraint is
   * then initialized using the default method.
   */

  stat_OM = om$send (mode = OM_e_wrt_parent,
                     msg = message SKinterface.SKinit (&msg_loc,
                           (options & ~SK_OPT_NO_MGR_CONNECT) | SK_OPT_NO_CONNECT_PTS,
                           md_env, num_pts, pt_ids, cnstr_props, geom_handle, moreinfo),
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_OMerror, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKifcol.SKinit");
  return (stat_OM);
}

end implementation SKifcol;
