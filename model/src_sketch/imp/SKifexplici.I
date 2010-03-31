/*

Name
  SKifexplicit

Abstract

Synopsis

Description

Return Value

Notes

Index

Keywords
  dimension,profile,units,wireframe

History
  03/12/93 : Rajiv Agrawal : Added code for the units conversion for the NDupdate method.
             The member constraints should store the value in data-base units only.

 */
class implementation SKifexplicit;

#include "nddef.h"
#include "ndmacros.h"
#include "EMSopt.h"

extern GRclassid OPP_SKfixang_class_id, OPP_SKrelang_class_id;

method NDupdate(IGRint *msg;
                IGRint cn_type;
                IGRint count;
	        struct GRid *list;
	        IGRint *parent_state;
	        struct GRid *context,*new_objid;
	        struct GRmd_env *md_env)
{
  IGRchar 		*valtype = NULL;
  long 			status, msg_loc;
  double 		db_value;
  struct GRid 		my_grid;
  GRclassid 		myclass;
  OM_S_CHANSELECT 	to_members;

  *msg = EMS_S_Success;
  status = OM_S_SUCCESS;

  new_objid->objid = my_id;
  new_objid->osnum = OM_Gw_current_OS;

  status = om$send (mode = OM_e_wrt_message,
                    msg = message SKexplicit.NDupdate(msg,cn_type,count,list,
                          parent_state,context,new_objid,md_env),
                    targetid = my_id);
  EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, wrapup);

  /*
   * If this expression stores a value other than in data-base units,
   * this means that the value coming in is in units other than data-base.
   * Obtain the value in data-base units in case one needs to post this
   * into the member constraints.
   */

  db_value = ME.expression->value;
  if (ME.SKconstraint->props & SK_UNITSCONVERT)
  {
    om$get_classid (object = me, p_classid = &myclass);
    if (om$is_ancestry_valid (superclassid = OPP_SKrelang_class_id,
         subclassid = myclass) == OM_S_SUCCESS ||
        om$is_ancestry_valid (superclassid = OPP_SKfixang_class_id,
         subclassid = myclass) == OM_S_SUCCESS)
      valtype = GRIO_ANGLE;
    else
      valtype = GRIO_DISTANCE;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &db_value, valtype, TRUE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
  }

  EMmake_chanselect (SKinterface_to_member_constrs, &to_members);
  status = om$send (msg = message SKexplicit.SKstoreval(&msg_loc, db_value),
                    p_chanselect = &to_members);
  EMerr_hndlr(!(1&status&msg_loc), *msg, EMS_E_Fail, wrapup);

wrapup:
 if (1&status&*msg)
  *msg = ND_COMP_SUCC;
 else
  *msg = ND_COMP_FAIL;
 EMWRAPUP (*msg, status, "SKifexplicit.NDupdate");
 return (status);
}

method GRdelete (IGRlong *msg; struct GRmd_env *md_env)
{
  IGRboolean	  change_to_noval;
  int		  i, j;
  long 		  stat_OM, msg_loc;
  OMuint	  count, super_count;
  GRclassid 	  superclass;
  GRobjid	  memid, superid;
  GRspacenum	  memos, superos;
  OM_S_CHANSELECT chan_to_memcnstrs, chan_to_supercnstrs, chan_to_children;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Turn off the property that indicates that the constraint I control
   * has an explicit value.  Do this only if there are no other interface
   * explicit constraints that put a value on the controlled member constraint.
   * RA 10/1/92.
   */

  om$make_chanselect ( channame = "NDchildren.children",
    p_chanselect = &chan_to_children );
  om$make_chanselect (channame = "SKinterface.to_member_constrs",
                      p_chanselect = &chan_to_memcnstrs);
  om$make_chanselect (channame = "SKconstraint.to_super_constrs",
                      p_chanselect = &chan_to_supercnstrs);
  
  om$get_channel_count (objid = my_id, osnum = OM_Gw_current_OS,
                        p_chanselect = &chan_to_memcnstrs, count = &count);

  for (i=0; i < count; i++)
  {
    om$get_objid_at_index (objid = my_id,
                           p_chanselect = &chan_to_memcnstrs, index = i,
                           objidaddr = &memid,
                           osnumaddr = &memos);
    /*
     * check if the memid is connected to another SKifexplicit constraint.
     */
    om$get_channel_count ( objid = memid, p_chanselect = &chan_to_supercnstrs,
                           count = &super_count );
    change_to_noval = TRUE;
    for (j=0; j < super_count; j++)
    {
      om$get_objid_at_index ( objid = memid, osnum = memos,
                              p_chanselect = &chan_to_supercnstrs,
                              index = j,
                              objidaddr = &superid, osnumaddr = &superos );
      om$get_classid (objid = superid, osnum= superos, p_classid = &superclass); 
      if (superid != my_id && om$is_ancestry_valid (subclassid = superclass,
                superclassid = OPP_SKifexplicit_class_id ) == OM_S_SUCCESS)
        change_to_noval = FALSE;
    }
    
    if (change_to_noval)
    {
      stat_OM = om$send (msg = message SKconstraint.SKchgprops (&msg_loc,
                 EMS_O_ON, SK_NOVALUE), p_chanselect = &chan_to_memcnstrs);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
         
  }  

  /*
   * Invoke the default message to do the rest of the work
   */
  stat_OM = om$send (mode = OM_e_wrt_parent,
             msg = message SKifexplicit.GRdelete (&msg_loc, md_env),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKifexplicit.GRdelete");
  return (stat_OM);
}

method SKgetpseudovarlist (IGRlong *msg; IGRushort opts;
                           struct SKsolvevars **varlist)
{
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_memcnstrs;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Invoke the default implementation
   */

  stat_OM = om$send (mode = OM_e_wrt_message,
             msg = message SKexplicit.SKgetpseudovarlist (msg, opts,
             varlist), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & *msg), *msg, EMS_E_Fail, ret_end);

  /*
   * Pass on the message
   */

  om$make_chanselect (channame = "SKinterface.to_member_constrs",
   p_chanselect = &chan_to_memcnstrs);

  om$send (msg = message SKconstraint.SKgetpseudovarlist (msg, opts,
   varlist), p_chanselect = &chan_to_memcnstrs);
  EMerr_hndlr (EMSerror (stat_OM & *msg), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKifexplicit.SKgetpseudo");
  return (stat_OM);
}

end implementation SKifexplicit;

#if GMK_SKexplicit_GRdelete_method_is_taking_care_of_children
  /*   ========== DELEDTED FROM GRdelete method ==========
   * Make sure the children know that I'm going away
   */
  om$make_chanselect ( channame = "NDchildren.children",
    p_chanselect = &chan_to_children );
  om$get_channel_count ( objid = my_id, osnum = OM_Gw_current_OS,
    p_chanselect = &chan_to_children, count = &count );
  for (i = 0; i < count; i++)
  {
    struct GRid my_grid;
    
    if (om$get_objid_at_index ( objid = my_id,
          p_chanselect = &chan_to_children, index = 0,
          objidaddr = &memid, osnumaddr = &memos ) & 1)
    {
      stat_OM = om$send ( msg = message NDnode.NDmove_to_root ( &msg_loc,
        &my_grid, md_env ), targetid = memid, targetos = memos );
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  }
#endif

