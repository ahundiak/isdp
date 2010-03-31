class implementation EMAsurface;

# include "exmacros.h"
# include "EMS.h"
# include "godef.h" /* For GR_RIGID_RELATIONSHIP */
# include "nddef.h"
# include "EMSkey.h"

method NDcopy_graph(IGRlong *EMmsg;IGRint cp_type;
  		    struct GRmd_env *fr_env,*to_env;
		    struct NDcp_list *list;
                    int list_count;
		    int position)
/*
 * This override just attempts to copy the node without any geometry
 * or topology.
 */
{
 IGRlong status, i,children_count;
 IGRboolean undone = FALSE;
 OM_S_CHANSELECT children;
 struct NDcp_list *myinx;
 struct GRid activeid;

 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;

 myinx = &list[position];
 myinx->original = my_id;

/*
 * Copy myself without copying topology, or geometry.
 */

/*
 * If I am being copied to a macro, then I make myself active first and
 * then I will only try to copy my node only and expect the graph manager
 * to make my owner component connections.
 * If I am not being copied to a macro, then I will not try to make myself 
 * active since that would happen during recompute
 */

 status = om$send (msg = message EMSsurface.EMgetactiveid (EMmsg,
                         &activeid, NULL),
                   targetid = my_id);
 EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 if (activeid.objid != my_id) 
 {
  unsigned short option;

  IGRint num, buff_size;

  option = EMS_UNDO_SAVE;
  buff_size = num = 0;
  undone = TRUE;

  status = om$send (msg = message EMSsurface.EMmake_active_state (EMmsg,
                        &option,fr_env,NULL, &num, &buff_size, 
                        NULL, NULL, NULL),
                   targetid = my_id);
  EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 }

/*
 * Ask the children to store the key in preparation for the copy.
 */

 EMmake_chanselect(NDchildren_children, &children);

 status = om$get_channel_count(p_chanselect = &children,
                               objid = my_id,
                               count = (OMuint *)&children_count);
 if (!(1&status)) goto wrapup;

 for (i=0;i<children_count;i++)
 {
   IGRlong msg_loc;

   om$send (msg = message EMSpointerA.EMstore_key_from_id(&msg_loc,
                          EMS_OPT_STORE_ID, NULL),
                    p_chanselect = &children,
                    from = i,
                    to = i);
 }

/*
 * This method would only cause a construct and copy to occur which is
 * exactly what we need.
 */

 if (myinx->position & ND_BODY)
 {
  IGRuint type,info_size;
  IGRchar *info_ptr=NULL;
 
  myinx->clone = NULL_OBJID;

  status = om$send (msg = message EMSassoc.EMget_info(EMmsg,NULL,&type,
                          &info_size, NULL),
                    targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 

  if (type != EMS_ASattached_to_cs)
  {
   status = om$send (msg = message EMSassoc.NDcopy_graph (EMmsg,
                         cp_type, fr_env, to_env,list, list_count,
                         position),
                   mode = OM_e_wrt_message,
                   targetid = my_id);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);
  }
  else
  {
    IGRshort props, set_bits;
    if (info_size > 0)
    {
      info_ptr = (IGRchar *) stackalloc(info_size);
      EMerr_hndlr(!info_ptr, *EMmsg, EMS_E_NoStackMemory,wrapup); 
    }
 
    status = om$send (msg = message EMSassoc.EMget_info(EMmsg, NULL, &type,
                          &info_size, 
                          &info_ptr),
                    targetid = my_id);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

    status = om$send (msg = message GRgraphics.GRcopy(EMmsg, fr_env,
                         to_env, &myinx->clone),
                   targetid = my_id);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    status = om$send(msg = message EMSassoc.EMput_info(EMmsg, NULL, type, 
                           info_size,
                           info_ptr),
                    targetid = myinx->clone,
                    targetos = to_env->md_id.osnum);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
    set_bits = 0;
    props = GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT;

    status = om$send(msg = message GRvg.GRchgprops(EMmsg,
                             &set_bits, &props),
       	  targetid = myinx->clone,
          targetos = to_env->md_id.osnum);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
 }
 else if (myinx->position & ND_EXTERN)
 {
/*
 * If I am an external element I copy my geometry only.
 */
  myinx->clone = NULL_OBJID;
  status = om$send (msg = message GRgraphics.GRcopy(EMmsg, fr_env,
                         to_env, &myinx->clone),
                   targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 else if (myinx->position & ND_ROOT)
 {
  OM_S_CHANSELECT to_father, to_children;
  OM_S_OBJID old_clone;
  extern OMuword OPP_ACpretend_class_id;


/*
 * If my clone is not coming in then just perform a copy of myself.
 * A clone of a root element is not passed when a template has a 
 * fixed value.
 * pp 07/13/92
 */

  old_clone = myinx->clone;

  if (old_clone == NULL_OBJID)
  {
   IGRshort split_flag;
   myinx->clone = NULL_OBJID;
   split_flag = FALSE ;
   if(ASMget_splitpart() == TRUE)
    {
       if(to_env->md_id.objid == NULL_OBJID)
        {
          /* to_env->md_id.objid = fr_env->md_id.objid; */
          ex$get_modid(mod_osnum = to_env->md_id.osnum,
                       mod_id = &(to_env->md_id.objid));
          split_flag = TRUE; 
        }
    }
   status = om$send (msg = message GRgraphics.GRcopy(EMmsg, fr_env,
                         to_env, &myinx->clone),
                   targetid = my_id);
   if(split_flag)
     to_env->md_id.objid = NULL_OBJID;
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   old_clone = myinx->clone;
  }


/*
 * First check to see if I am rigidly owned by somebody. If I am not
 * owned (consumed) then it is OK to return success. If I am owned,
 * (consumed) then I need to replace the incoming object with the
 * proper copy of myself due to the fact that I have to live in a
 * DPR structure (for now). This is necessary for VDS to work.
 */

  if (!(ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP))
   goto wrapup;

  if (EFisAncestryValid(EMmsg, old_clone, to_env->md_id.osnum, 
                          OPP_ACpretend_class_id, FALSE))
  {
   EMmake_chanselect(NDchildren_children, &to_children);
   EMmake_chanselect(NDfather_father, &to_father);

   status = om$send (msg = message GRgraphics.GRcopy(EMmsg, fr_env,
                         to_env, &myinx->clone),
                   targetid = my_id);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   status = om$send(msg = message Root.move_chan(to_father, old_clone,          
                        to_env->md_id.osnum,
                        to_father), 
                   targetid = myinx->clone,
                   targetos = to_env->md_id.osnum);
   if (!(1 & status)) goto wrapup;

   status = om$send(msg = message Root.move_chan(to_children, old_clone, 
                        to_env->md_id.osnum,
                        to_children), 
                   targetid = myinx->clone,
                   targetos = to_env->md_id.osnum);
   if (!(1 & status)) goto wrapup;
  }
  else
  {
   struct GRid clone_activeid;

   status = om$send (msg = message EMSsurface.EMgetactiveid (EMmsg,
                         &clone_activeid, NULL),
                   targetid = myinx->clone,
                   targetos = to_env->md_id.osnum);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);

   myinx->clone = clone_activeid.objid;

  }
 }
 else
 {
  *EMmsg = MSINARG;
  goto wrapup;
 }

/*
 * Clear the rigid relationship bit if the same is set.
 */
 {
  IGRshort props, clear_bits;
  clear_bits = 0;
  props = GR_RIGID_RELATIONSHIP;
  status = om$send(msg = message GRvg.GRchgprops(EMmsg,
                             &clear_bits, &props),
       	  targetid = myinx->clone,
          targetos = to_env->md_id.osnum);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

wrapup:
/*
 * Reactivate my active guy even though this process is less efficient.
 * this will eliminate the chance of corruption of the model while
 * creating/placing macros
 */
 if (undone) 
 {
  unsigned short option;

  IGRint num, buff_size;

  option = EMS_UNDO_SAVE;
  buff_size = num = 0;

  status = om$send (msg = message EMSsurface.EMmake_active_state (EMmsg,
                        &option,fr_env,NULL, &num, &buff_size, 
                        NULL, NULL, NULL),
                   targetid = activeid.objid);
  EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 }
  EMWRAPUP (*EMmsg, status, "In EMAsurface:NDcopy_graph error");
  return (status);
}

method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *fr_env,*to_env;
  			 struct GRid *newobjid)
/* **********************************************************************
Description
 This method checks to see if the surface is active. If so then
 it attempts to copy itself by sending ACcopy_to_Groot with respect
 to parent. Else it returns success.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MDFAIL : If there is some form of failure

History
 Creation : PP : 08/10/91
*********************************************************************** */
{
 IGRlong status, msg_loc;
 struct GRid activeid;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 status = om$send (msg = message EMSsurface.EMgetactiveid (&msg_loc,
                         &activeid, NULL),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&msg_loc), *msg, MSFAIL, wrapup);

 if (activeid.objid != my_id) 
 {
  newobjid->objid = NULL_OBJID;
  newobjid->osnum = to_env->md_id.osnum;
/*
 * Copy the entity non-associatively for the purpose of displaying
 * the same to the user while placing a macro.
 */
  if (cp_type & ND_TO_DEF_TEMP)
  {
   IGRshort props, clear_bits;
   status = om$send (msg = message GRgraphics.GRcopy(msg, fr_env,
                         to_env, &newobjid->objid),
                   targetid = my_id);
   EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);

   status = om$send(msg = message EMSsurface.EMfix_creator_id(msg, NULL,
                     NULL_OBJID, NULL),
       	  targetid = newobjid->objid,
          targetos = newobjid->osnum);
   EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);
/*
 * Clear the rigid relationship bit if the same is set.
 */
    clear_bits = 0;
    props = GR_RIGID_RELATIONSHIP;
    status = om$send(msg = message GRvg.GRchgprops(msg,
                             &clear_bits, &props),
       	  targetid = newobjid->objid,
          targetos = newobjid->osnum);
    EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, wrapup);
  }
 }
 else
 {
  status = om$send (msg = message EMSassoc.ACcopy_to_Groot(msg,
                          cp_type, fr_env, to_env, newobjid),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
  EMerr_hndlr (!(1&status&msg_loc), *msg, MSFAIL, wrapup);

  status = om$send(msg = message EMSsurface.EMfix_creator_id(msg, NULL,
                     NULL_OBJID, NULL),
      	  targetid = newobjid->objid,
         targetos = newobjid->osnum);
  EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);
 }

wrapup:
 EMWRAPUP (*msg, status, "Im EMAsurface:ACcopy_to_Groot error");
 return (status);
}

method NDcopy_to_root(IGRlong *EMmsg;IGRint cp_type;
	              struct GRmd_env *fr_env,*to_env;
  		      struct GRid *newobjid)
{
 IGRlong status;
 IGRint children_count,i;
 struct GRid activeid;
 OM_S_CHANSELECT children;

 activeid.objid = NULL_OBJID;

 status = om$send (msg = message EMSsurface.EMgetactiveid (EMmsg,
                         &activeid, NULL),
                   targetid = my_id);
 EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 if (activeid.objid != my_id) 
 {
  IGRushort option;

  option = EMS_UNDO_SAVE;

  status = om$send (msg = message EMSsurface.EMmake_active_state (EMmsg,
                        &option,fr_env,NULL, NULL, NULL, 
                        NULL, NULL, NULL),
                   targetid = my_id);
  EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 }

/*
 * Ask the children to store the key just in case.
 */

 EMmake_chanselect(NDchildren_children, &children);

 status = om$get_channel_count(p_chanselect = &children,
                               objid = my_id,
                               count = (OMuint *)&children_count);
 if (!(1&status)) goto wrapup;

 for (i=0;i<children_count;i++)
 {
   IGRlong msg_loc;

   om$send (msg = message EMSpointerA.EMstore_key_from_id(&msg_loc,
                          EMS_OPT_STORE_ID, NULL),
                    p_chanselect = &children,
                    from = i,
                    to = i);
 }

 status = om$send (msg = message GRgraphics.GRcopy(EMmsg, fr_env,
                         to_env, &newobjid->objid),
                   targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 newobjid->osnum = to_env->md_id.osnum;

wrapup:

 if (activeid.objid != my_id) 
 {
  IGRlong l_msg;
  IGRushort undo_option;
  undo_option = EMS_UNDO_SAVE;

  om$send (msg = message EMSsurface.EMmake_active_state (&l_msg,
                        &undo_option,fr_env,NULL, NULL, NULL, 
                        NULL, NULL, NULL),
                   targetid = activeid.objid);

 }

 return (status);
}
end implementation EMAsurface;

