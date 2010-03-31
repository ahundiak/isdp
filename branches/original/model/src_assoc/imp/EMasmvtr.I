/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

#include "EMSasdef.h"

from EMSparameter import EMparam_delete;

extern OMuword OPP_GRcmpowner_class_id,
               OPP_COadd_opt_class_id;

method NDmove_to_root(IGRlong *msg; struct GRid *src_grid;
                      struct GRmd_env *md_env)
/* *******************************************************************
Description
 This method shall cause the disconnection of the object to which
 this message is sent to from its parents. It will compress the
 recomputation vla and reset the bits. Also it will send a private
 message on the father channel to cause deletion of any temporary
 objects that were being used by this object.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is some form of failure

History:
 Send EMexternal_constraint_changed message : DLB : 05/06/91
 Creation : PP : 04/25/91
*********************************************************************** */
{
 IGRlong status=OM_S_SUCCESS;
 IGRlong msg_loc;

 *msg = MSSUCC;

/*
 * Send a private delete messate to delete the parameter objects.
 */

/*
 * Do not support if I am moving to root in a different object space
 * for now until it is clear what to do. 
 */
 if (md_env && (md_env->md_id.osnum != OM_Gw_current_OS))
 {
  *msg = EMS_E_InvalidCase;
  goto wrapup;
 }

/*
 * This is a major kludge. I need to do this until JLA provides
 * a formalised protocol for dropping associativity.
 * pp 10/1/91
 */
 if ((sender_id != NULL_OBJID) && (sender_id != my_id) &&
     (EFisAncestryValid(&msg_loc, sender_id, sender_os, 
                          OPP_COadd_opt_class_id, FALSE))) 
 {
  src_grid->osnum = OM_Gw_current_OS;

  status = om$send (msg = message EMSassoc.EMdrop_associativity(&msg_loc,
                          NULL, md_env, &src_grid->objid),
                    targetid = my_id);
  EMerr_hndlr(!(1&status&msg_loc), *msg, EMS_E_Fail, wrapup);
  goto wrapup;
 }

/* end kludge */
 

/*
 * Send a param delete to the parents.
 */
 {
   IGRint msg_loc;
   OM_S_CHANSELECT to_father;

   EMmake_chanselect(NDfather_father, &to_father);
   om$send (msg = message EMSparameter.EMparam_delete(
           (IGRlong *)&msg_loc, md_env),
           p_chanselect = &to_father);
 }
               



 status = om$send (msg = message NDnode.NDdisconnect(0,NULL),
          targetid = my_id);
 EMerr_hndlr(!(1&status), *msg, MSFAIL, wrapup);

 status = om$send (msg = message EMSassoc.EMput_info(msg,NULL,
                         EMS_ASno_type,0,NULL),
                   targetid = my_id);
 EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);

 if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
  ME.GRgraphics->properties &= ~GRIS_ASSOCIATIVE;

 if (ME.GRgraphics->properties & GRHAS_EXTERNAL_CONSTRAINT)
 {
  /*Determine if the EXT_CONST bit can be reset.*/
  status = om$send(msg = message EMSassoc.EMexternal_constraint_changed(msg,
                         EMext_const_chg_CHECK),
                   targetid = my_id);
  if (!(1 & status & *msg)) goto wrapup;                   
 }

 if (src_grid)
 {
  src_grid->objid = my_id;
  src_grid->osnum = OM_Gw_current_OS;
 }

wrapup:
 EMWRAPUP (status, *msg, "In EMSassoc:NDmove_to_root error");
 return (status);
}

method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *fr_env,*to_env;
  			 struct GRid *newobjid)
/* **********************************************************************
Description
 This method has been overriden to return the non-associative copy
 of the geometry.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MDFAIL : If there is some form of failure

History
 Creation : PP : 08/10/91
*********************************************************************** */
{
 IGRlong status, msg_loc;
 OM_S_OBJID temp_objid;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 status = om$send (msg = message GRgraphics.GRcopy(&msg_loc,fr_env, to_env,
                          &temp_objid),
                   targetid = my_id);
 EMerr_hndlr(!(1&status&msg_loc), *msg, MSFAIL, wrapup);

 newobjid->objid = temp_objid;
 newobjid->osnum = to_env->md_id.osnum;

wrapup:
 EMWRAPUP (*msg, status, "In EMSassoc:copy to groot error");
 return (status);
}

method EMdrop_associativity(IGRlong *EMmsg;
                             IGRuint options;
                             struct GRmd_env *md_env;
                             OM_S_OBJID *newobjid)
/* ********************************************************************
Description
 This message strips the element of its associativity.

Arguments
 options  :  I : Currently can be set to NULL.
 md_env   :  I : Module environment
 EMmsg    :  O : Completion code
 newobjid :  O : The new object which has resulted from dropping
                 associativity on the element to which this message
                 is sent

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well.
 EMS_E_Fail   : If there is some form of failure.

History
 10/1/91 : PP : Creation
*********************************************************************** */
{
 IGRlong status;
 IGRlong msg_loc;
 OM_S_CHANSELECT to_comps;
 struct GRid src_grid;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 *newobjid = NULL_OBJID;

 EMmake_chanselect(GRcmpowner_to_components, &to_comps);

 if (EFisAncestryValid(&msg_loc, my_id, OM_Gw_current_OS, 
                          OPP_GRcmpowner_class_id, FALSE)) 
 {
  status = om$send (msg = message NDnode.NDmove_to_root(&msg_loc,
                          &src_grid, md_env),
           targetid = my_id);
  EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  *newobjid = src_grid.objid;

  om$send (msg = message EMSassoc.EMdrop_associativity(&msg_loc, options,
                 md_env, newobjid),
           p_chanselect = &to_comps);
 }
 else
 {
  status = om$send (msg = message NDnode.NDmove_to_root(&msg_loc,
                          &src_grid, md_env),
           targetid = my_id);
  EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  *newobjid = src_grid.objid;
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSassoc:EMdrop_associtivity error");
 return (status);
}
end implementation EMSassoc;

