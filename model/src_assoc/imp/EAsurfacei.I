class implementation EMAsurface;

from ASnode import ACgive_path;
from EMSdpr import EMundo;

method EMcopy_recomp_info (IGRlong *EMmsg;
                            struct GRmd_env *obj_mdenv;
                            struct GRmd_env *new_mdenv;
                            GRobjid newobjid;
                            struct EMcp_info *copy_info;
                            IGRushort bdry_options, sf_options)
/* *********************************************************************
Description
 This method serves to copy the recomputation information. This implementation
 just returns success.


History
 Creation : PP : 05/05/91
 
  ********************************************************************** */
{
 *EMmsg = EMS_S_Success;
 return (OM_S_SUCCESS);
}

method NDdelete(struct GRmd_env *md_env)
/* **********************************************************

Description
 This method if sent to an intermediate node in the DPR tree or
 a solid in the DPR tree shall cause the tree to get deleted.

History
 Creation : PP : 06/15/91
 
  *********************************************************** */
{
 IGRlong EMmsg, status;
 struct GRid owner_GRid;
 extern OMuword OPP_EMSdpr_class_id;
 IGRlong l_msg;
 OM_S_CHANSELECT to_components;
 OMuint component_count=0;
 OMuword deact_option;
 extern IGRboolean ASbroadcast_in_progress;
 IGRint is_dpr;

 EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 EMmake_chanselect (GRcmpowner_to_components, &to_components);

 status = om$get_channel_count(object = me,
                               p_chanselect = &to_components,
                               count = &component_count);
 EMerr_hndlr(!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 is_dpr = EFisAncestryValid(&l_msg, my_id, OM_Gw_current_OS,
                          OPP_EMSdpr_class_id, FALSE);

 if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP)
 {
  OM_S_CHANSELECT to_owners;

  EMmake_chanselect (GRconnector_to_owners, &to_owners);
  status = om$get_objid_at_index(objid = my_id,
                                 osnum = OM_Gw_current_OS,
                                 p_chanselect = &to_owners,
                                 objidaddr = &owner_GRid.objid,
                                 osnumaddr = &owner_GRid.osnum,
                                 index = 0);
  if (1&status)
  {
    if (EFisAncestryValid(&l_msg, owner_GRid.objid, owner_GRid.osnum, 
                          OPP_EMSdpr_class_id, FALSE))
    {
     deact_option = EMS_UNDO_DELETE;
/*
 * We are checking the ASbroadcast_in_progress flag just to be safe.
 * This will protect ourselves from an odd ball trying to send an
 * stand alone NDdelete.
 * The following code was added to fix the TR 119300494
 * begin pp Aug 15, 1993
 */
     if (component_count && ASbroadcast_in_progress)
     {
      if (is_dpr)
      {
       status = om$send (msg = message EMSdpr.EMundo(&EMmsg,&deact_option,
                             md_env,NULL,NULL,NULL,NULL,NULL,NULL),
                        targetid = my_id);
      }
      else
      {
       status = om$send (msg = message EMSdpr.EMundo(&EMmsg,&deact_option,
                             md_env,NULL,NULL,NULL,NULL,NULL,NULL),
                        targetid = owner_GRid.objid,
                        targetos = owner_GRid.osnum);
       om$send (msg = message GRgraphics.GRdelete(&l_msg,md_env),
                        targetid = my_id);
      }
     }

/* end pp */
    }
  }
 }
 else
 {

/*
 * This should usually only come about by the graph subsystem.
 *
 */
  if (component_count && is_dpr && ASbroadcast_in_progress)
  {
    deact_option = EMS_UNDO_DELETE;
    status = om$send (msg = message EMSdpr.EMundo(&EMmsg,&deact_option,
                           md_env,NULL,NULL,NULL,NULL,NULL,NULL),
                      targetid = my_id);
  }
   else
     om$send (msg = message GRgraphics.GRdelete(&l_msg,md_env),
                    targetid = my_id);
 }


wrapup:
 EMWRAPUP (EMmsg, status, "In EMAsurface: NDdelete error");
 if (!(1&EMmsg)) status = OM_E_ABORT;
 return (status);
}

method EMpreprocess_delete(IGRlong *EMmsg;
                            struct GRmd_env *md_env)
/* *****************************************************************

Description
 The purpose of this message is to take any action which is required before
 an associative surface/solid gets deleted.

 Currently this message makes sure that if the current object is created
 by consuming a parent, then it asks its parent to unconsume it.

Arguments
 msg: O : Completion code
 md_env : I : Module environment.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well.
 EMS_E_Fail: If there is some sort of failure.

History
 pp: 07/22/92 : Creation
********************************************************************** */
{
 IGRlong status;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 if ((ME.GRgraphics->properties & GRIS_ASSOCIATIVE) &&
     (me->type == EMS_ASfunction))
 {
  IGRuint info_size;
  IGRuint type;
  IGRchar *info_ptr;
  OM_S_CHANSELECT father, to_owners;

   status = om$send (msg = message EMSassoc.EMget_info(EMmsg,NULL,&type,
                           &info_size, NULL),
                     targetid = my_id);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

   if (info_size > 0)
   {
     info_ptr = (IGRchar *) stackalloc(info_size);
     EMerr_hndlr(!info_ptr, *EMmsg, EMS_E_NoStackMemory,wrapup); 
   }
   else
     info_ptr = NULL;

   status = om$send (msg = message EMSassoc.EMget_info(EMmsg, NULL, &type,
                         &info_size, 
                         &info_ptr),
                   targetid = my_id);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

   EMmake_chanselect(NDfather_father, &father);

   if (!(strcmp(info_ptr,"EFconsume_copy")))
   {
    IGRshort props;
    struct GRid copyee_GRid, const_GRid;
    struct GRmd_env env;
    extern OM_S_OBJID current_creator;
    char footname[1024];
    IGRlong msg_loc;
    OM_S_OBJID save_creator;
    extern OMuword OPP_ACconst_class_id;


    status = om$send (msg = message NDnode.ASreturn_go(&copyee_GRid,
                            &env.md_env.matrix_type, env.md_env.matrix),
                      p_chanselect = &father,
                      from = 0,
                      to = 0);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
    EMmake_chanselect(GRconnector_to_owners, &to_owners);

    status = om$send (msg = message GRgraphics.GRgetprops(&msg_loc, &props),
                     targetid = copyee_GRid.objid,
                     targetos = copyee_GRid.osnum);
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    if (props & GR_RIGID_RELATIONSHIP)
    {
     const_GRid.objid = NULL_OBJID;

     status = om$get_objid_at_index(objid = copyee_GRid.objid,
                                    osnum = copyee_GRid.osnum,
                                    p_chanselect = &to_owners,
                                    index = 0,
                                    objidaddr = &const_GRid.objid,
                                    osnumaddr = &const_GRid.osnum);
     EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
    }
    else goto wrapup;


    if (EFisAncestryValid(EMmsg, const_GRid.objid, const_GRid.osnum,
                          OPP_ACconst_class_id, FALSE))
    {
      footname[0] = '\0';
      status = om$send (msg = message ASnode.ACgive_path((IGRint *)&msg_loc,
                           &copyee_GRid, footname),
                        targetid = const_GRid.objid,
                        targetos = const_GRid.osnum);
      EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

      save_creator = current_creator;
      current_creator = NULL_OBJID;

      status = om$send (msg = message NDmacro.ACunconsume(&msg_loc, footname),
                        targetid = const_GRid.objid,
                        targetos = const_GRid.osnum);
      current_creator = save_creator;
      EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    }
   }
   else if (!(strcmp(info_ptr,"EFpattern")))
   {
    status = om$send (msg = message GRgraphics.GRdelete(EMmsg,
                            md_env),
                      p_chanselect = &father);
   }
   
 }

wrapup:
 if (!(1&status&*EMmsg)) 
 {
   status = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
 }
 return (status);
}
end implementation EMAsurface;

