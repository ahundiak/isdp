/*

Name
  SKinit

Abstract

Synopsis

Description
    The first point is constrained to lie on the phantom element defined by the
    rest of the points.

Return Value

Notes

Index

Keywords
  profile

History
  ??/??/?? : ???     : created
  10/25/93 : GMK     : TR#119303786 : circle contains first SKptvar at 3'O clock position
  		       and second SKptvar at centre of circle.
  10/27/93 : GMK     : TR#119222818 : changed the ancestry valid path from GR3dlineseg to
  	               GRlineseg.

 */

class implementation SKptonelmt;

#include "OMmacros.h"

#define FIRST 0

extern GRclassid OPP_SKcollinear_class_id, OPP_SKequal_class_id;
extern GRclassid OPP_SKcircle_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;
extern GRclassid OPP_GRlineseg_class_id;
extern GRclassid OPP_GR3dcirarc_class_id, OPP_GR3dcircle_class_id;

from SKvariable import SKgetvar;

method SKinit ( long *msg; unsigned short options;
                struct GRmd_env *md_env;
                int num_pts; GRobjid *pt_ids;
                unsigned short cnstr_props;
                GRobjid *geom_handle;
                char *moreinfo )

{
  int num_temp_ids;
  long stat_OM, msg_loc;
  GRobjid temp_ids[4], elemobj, sibling0;
  GRclassid objclass, cnstr_class_id;
  OM_S_CHANSELECT chan_to_vars, chan_to_cnstr;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Determine the kind of constraint to be constructed
   */

  EMerr_hndlr (!moreinfo, *msg, EMS_E_InvalidArg, ret_end);

  elemobj = ((struct SKptonelmt_info *) moreinfo)->elemobj;
  om$get_classid (objid = elemobj, p_classid = &objclass);
  if (om$is_ancestry_valid (subclassid = objclass,
      superclassid = OPP_GRlineseg_class_id) == OM_S_SUCCESS) 
  {
    cnstr_class_id = OPP_SKcollinear_class_id;
    OM_BLOCK_MOVE (pt_ids, temp_ids, num_pts * sizeof (GRobjid));
    num_temp_ids = 3;
  }
  else if ((om$is_ancestry_valid (subclassid = objclass,
      superclassid = OPP_GR3dcirarc_class_id) == OM_S_SUCCESS) ||
      om$is_ancestry_valid (subclassid = objclass,
      superclassid = OPP_SKcircle_class_id) == OM_S_SUCCESS)
  {
    cnstr_class_id = OPP_SKequal_class_id;
    temp_ids[0] = pt_ids[0];
    temp_ids[1] = pt_ids[2];
    temp_ids[2] = pt_ids[1];
    temp_ids[3] = pt_ids[2];
    num_temp_ids = 4;
  }
  else
    if (om$is_ancestry_valid ( subclassid = objclass,
        superclassid = OPP_GR3dcircle_class_id) == OM_S_SUCCESS)
    {
      cnstr_class_id = OPP_SKequal_class_id;
      temp_ids[0] = pt_ids[0];
      temp_ids[1] = pt_ids[2];     /* before it is pt_ids[1]. for a circle, first SKptvar
      				      point is at circumfernce point, second SKptvar point
      				      is at centre point -- GMK */
      temp_ids[2] = pt_ids[1];
      temp_ids[3] = pt_ids[2];
      num_temp_ids = 4;
    }
    else
    {
      *msg = EMS_E_NotSupported;
      goto ret_end;
    }

  stat_OM = om$construct(classid = cnstr_class_id, p_objid = &sibling0,
      msg = message SKconstraint.SKinit(&msg_loc,
      (options | SK_OPT_NO_MGR_CONNECT) & ~SK_OPT_CREATE_GEOMETRY,
      md_env, num_temp_ids, temp_ids, cnstr_props,
      NULL, moreinfo));
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message SKinterface.SKconnect_to_member
      (&msg_loc, NULL, sibling0, MAXINT, MAXINT),
      targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);
  EMmake_chanselect (SKvariable_to_constraints, &chan_to_cnstr);
  stat_OM = om$send (msg = message Root.connect (chan_to_vars,
      0, pt_ids[FIRST], OM_Gw_current_OS, chan_to_cnstr, 0),
      targetid = my_id);
  EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);

  stat_OM = om$send (mode = OM_e_wrt_parent,
      msg = message SKptonelmt.SKinit (&msg_loc,
      (options & ~SK_OPT_NO_MGR_CONNECT) | SK_OPT_NO_CONNECT_PTS,
      md_env, num_pts, pt_ids, cnstr_props, geom_handle,
      moreinfo), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKptonelmt.SKinit");
  return stat_OM;
}

end implementation SKptonelmt;
