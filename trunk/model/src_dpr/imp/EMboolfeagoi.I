class implementation EMSsfboolfea;

#include "msdef.h" /* MS message codes */
#include "msmacros.h"
#include "EMSasfeatdef.h"
#include "EMSdpr.h"
#include "emsdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grmacros.h"
#include "exmacros.h"
#include <alloca.h>

extern unsigned char EMS_locate_features;

/*
Uses class name and appends operation type to it. Uses the resulting string
as the message name to search the message file.
*/
method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 IGRlong sts = OM_S_SUCCESS;
 OMuint  cnt=0;
 *msg = MSSUCC;

   if (EMS_locate_features)
   {
     OM_S_CHANSELECT to_comps;

     EMmake_chanselect(GRcmpowner_to_components, &to_comps);
     sts = om$is_objid_on_channel(object_c = me,
                                  p_chanselect = &to_comps,
                                  objid = sender_id);
     if (sts != OM_S_SUCCESS)
     {
       sts = om$get_channel_count(object = me,
                                 p_chanselect = &to_comps,
                                 count = &cnt);
      if (!(1 & sts)) return(sts);
     }
     else sts = OM_S_SUCCESS;
   }

   if ((ME.EMSassoc->type >= EMS_ASCIR_THRU_ALL_HOLE_TYPE  &&
        ME.EMSassoc->type <= EMS_ASCIR_FINITE_V_HOLE_TYPE)
          ||( ME.EMSassoc->type >= EMS_ASCIR_THRU_ALL_HOLE_TYPE_1 &&
             ME.EMSassoc->type <= EMS_ASCIR_FINITE_V_REFPLANE  ))
   {
     if (cnt < 3)
     {
       ex$message(msgname = "EMSsfboolfea1", buff = info->type)
     }
     else       
     {
       ex$message(msgname = "EMSsfboolfea10", buff = info->type) 
     }
   }
   else if (ME.EMSassoc->type  >= EMS_ASCBORE_AXIS_NOR_AND_THRU &&
            ME.EMSassoc->type  <= EMS_ASCBORE_AXIS_ALI_AND_BLIND) 
   {
     if (cnt < 3)
     {
       ex$message(msgname = "EMSsfboolfea2", buff = info->type)
     }
     else
     {
       ex$message(msgname = "EMSsfboolfea11", buff = info->type)
     }
   }
   else if (ME.EMSassoc->type  >= EMS_ASCSINK_AXIS_NOR_AND_THRU &&
            ME.EMSassoc->type  <= EMS_ASCSINK_AXIS_ALI_AND_BLIND) 
   {
     if (cnt < 3)     
     {
       ex$message(msgname = "EMSsfboolfea3", buff = info->type)
     }
     else       
     {
       ex$message(msgname = "EMSsfboolfea12", buff = info->type)
     }
   }
   else if(ME.EMSassoc->type == EMS_I_AM_A_BOSS)
      ex$message(msgname = "EMSsfboolfea5", buff = info->type)

   else if(ME.EMSassoc->type == EMS_I_AM_A_POCKET)
      ex$message(msgname = "EMSsfboolfea6", buff = info->type)

   else if (ME.EMSassoc->type >= EMS_ASPRO_THRU_ALL_HOLE_TYPE  &&
        ME.EMSassoc->type <= EMS_ASPRO_THRU_UNTIL_HOLE_TYPE)
   {
     if (cnt < 3)
     {
       ex$message(msgname = "EMSsfboolfea9", buff = info->type)
     }
     else
     {
       ex$message(msgname = "EMSsfboolfea13", buff = info->type)
     }
   }
   else
   {
   sts = om$send (mode = OM_e_wrt_message,
                   msg =  message  EMSsurface.GRgetobjinfo(msg, info),
                    targetid = my_id);
   }

 return(sts);
}


from EMSdprparam import EMget_display_ids, EMput_display_ids;
from EMSpartsupp import EMget_partial_suppress_id,
                        EMmove_comp,
                        EMdelete_group_comp,
                        EMget_index_of_comp_id;
from EMSparameter import EMparam_delete;


method EMpartial_delete_group_feature(IGRlong         *EMmsg;
                                      struct GRmd_env *env;
                                      GRobjid         group_comp_id;
                                      OMuword         options)
/*
Description
    Delete a component from a group feature while keeping the integrity of the
    tree (and the group feature) intact. 

Return Values
    EMS_S_Success if all is well

Notes
    This method assumes that a feature has all added geometry after index 0 are
    added and such added geom will not be connected up to the owner.

    About parameters:
        options - 
            EMdel_fea_DELETE_AND_SAVE - delete the feature and mark it as 
                                        such but dont remove it from the
                                        model.  Usefull if allowing and
                                        undo-delete capability.
            EMdel_fea_CLEANUP_DELETED - remove the already deleted-and-saved
                                        feature from the model.  This mask
                                        can be used in conjuction with the
                                        above DELETE_AND_SAVE to delete and
                                        cleanup the feature in one shot.
            EMdel_fea_RESTORE_DELETED - restore a deleted feature to its
                                        original state.  Usefull if allowing
                                        an undo delete capability.
            EMdel_fea_DELAY_UPDATE    - do not issue an nd$exec_batch().  Must
                                        be issued by the sender.
History
   DLB 11/20/92 Creation.
   WBC 12/17/93 Update the display_ids in the EMSdprparam object at the end
                of the method if necessary.  Currently, if an error is
                returned by certain method/function calls, the display_ids
                may not be posted.
*/
{
  IGRlong       OM_stat=OM_S_SUCCESS;
  IGRint        fea_cnt=0, comp_type=ND_COMP;
  IGRint        loc_display_count=0;
  GRobjid       part_supp_id=NULL_OBJID;
  GRobjid       ownerid, *loc_display_ids=NULL, param_id;
  struct GRid   batch_GRid;
  OM_S_CHANSELECT to_children;
  IGRushort       dpr_props;
  IGRboolean      save_broadcast_in_progress,
                  update_display_ids = FALSE;
  extern IGRboolean ASbroadcast_in_progress;
  extern IGRlong    EFregen_autodim();

  *EMmsg = EMS_S_Success;

  /*Do a safety check*/
  OM_stat = om$send(msg = message EMSdpr.EMget_feature_definition(EMmsg,
                          &fea_cnt, NULL, NULL),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                                    
 
  if (!fea_cnt || fea_cnt > 1) {*EMmsg=EMS_E_InvalidSend; goto wrapup;}

  /*Get the partial suppress id if it already exists*/
  EMmake_chanselect(NDchildren_children, &to_children);

  OM_stat = om$send(msg = message EMSpartsupp.EMget_partial_suppress_id(EMmsg,
                          &part_supp_id, NULL), 
                    p_chanselect = &to_children);
  if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;  
  else if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (options & EMdel_fea_DELETE_AND_SAVE)
  {
    if (part_supp_id == NULL_OBJID)
    {
      /*Not already there so create the new part supp id and connect it up*/
      OM_stat = EFcreate_suppress_id(EMmsg, my_id, OM_Gw_current_OS, 
                                     &part_supp_id,
                                     EFcreate_supp_id_CREATE_PARTIAL);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;      
    }

    /*Get the display_ids array*/
    OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(
                                     EMmsg, &loc_display_count,
                                     &loc_display_ids, NULL), 
                              my_id, OM_Gw_current_OS, &param_id, NULL);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                            

    update_display_ids = TRUE;

    OM_stat = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg,
                            &dpr_props),       
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
    if (!(dpr_props & EMS_UNEVAL_STATE))
    {
      /*Set broadcast_in_progress to 1 before issuing uneval in order to
       * keep any of my MSCs.  Otherwise edges created by me will
       * send a delete to the MSC on its notification chan.  THe EMpostdelete
       * message overridden at EMSedge chechks for the broadcast_in_progress
       * flag before deleting.
       */
      save_broadcast_in_progress = ASbroadcast_in_progress;
      ASbroadcast_in_progress = 1;

      /*Unevaluate me*/
      OM_stat = om$send(msg = message EMSsurface.EMunevaluate(EMmsg,
                              EMuneval_DO_DISPLAY | 
                              EMuneval_DONT_REDRAW |
                              EMuneval_IMMEDIATE_OPER,
                              env, &loc_display_ids, &loc_display_count,
                              &ownerid, NULL_OBJID, NULL),
                       targetid = my_id); 
      ASbroadcast_in_progress = save_broadcast_in_progress;

      if (!(1 & *EMmsg & OM_stat)) goto wrapup;
    }

    if (*EMmsg != EMS_I_CantRecompute)
    {
      OM_stat = om$send(msg = message EMSpartsupp.EMmove_comp(EMmsg, 
                              my_id, TRUE, group_comp_id, NULL),
                        targetid = part_supp_id);                              
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      batch_GRid.objid = my_id;
      batch_GRid.osnum = OM_Gw_current_OS;      

      nd$wait_batch(type = GR_GEOM_POSTED,
                    nb_obj = 1,
                    l_object = &batch_GRid,
                    l_obj_info = &comp_type);
    }   

    if (loc_display_count)
    {
      OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(EMmsg,
                               loc_display_count, loc_display_ids, NULL),
                        targetid = param_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                 
 
      loc_display_ids = NULL;
      loc_display_count = 0;
      update_display_ids = FALSE;
    }

    if (!(options & EMdel_fea_DELAY_UPDATE))
    {
      nd$exec_batch();

      /*The auto dimension is now incorrect so delete the dimensions and
       * regen after the param pt has been disconnected/deleted
       */
      OM_stat = EFregen_autodim(EMmsg, my_id, OM_Gw_current_OS, env, FALSE,
                                NULL); 
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
    else
    {
      /*Delete the now out-of-date autodim*/
      OM_stat = EFregen_autodim(EMmsg, my_id, OM_Gw_current_OS, env, TRUE, 
                                NULL);      
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }
  else if (options & EMdel_fea_RESTORE_DELETED)
  {
    if (part_supp_id == NULL_OBJID) {*EMmsg=EMS_E_InvalidCase; goto wrapup;}

    /*Get the display_ids array*/
    OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(
                                     EMmsg, &loc_display_count,
                                     &loc_display_ids, NULL), 
                              my_id, OM_Gw_current_OS, &param_id, NULL);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                            

    update_display_ids = TRUE;

    OM_stat = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg,
                            &dpr_props),       
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
    if (!(dpr_props & EMS_UNEVAL_STATE))
    {
      /*Unevaluate me*/
      OM_stat = om$send(msg = message EMSsurface.EMunevaluate(EMmsg,
                              EMuneval_DO_DISPLAY | 
                              EMuneval_DONT_REDRAW |
                              EMuneval_IMMEDIATE_OPER |
                              EMuneval_DELETE_SSI, 
                              env, &loc_display_ids, &loc_display_count,
                              &ownerid, NULL_OBJID, NULL),
                       targetid = my_id); 
      if (!(1 & *EMmsg & OM_stat)) goto wrapup;
    }

    if (*EMmsg == EMS_I_CantRecompute) 
    {*EMmsg = EMS_E_InvalidCase; goto wrapup;}
      
    if (loc_display_count)
    {
      OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(EMmsg,
                               loc_display_count, loc_display_ids, NULL),
                        targetid = param_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                 
 
      loc_display_ids = NULL;
      loc_display_count = 0;
      update_display_ids = FALSE;
    }

    /*Move the group_comp_id back*/
    OM_stat = om$send(msg = message EMSpartsupp.EMmove_comp(EMmsg, 
                            my_id, FALSE, group_comp_id, NULL),
                      targetid = part_supp_id);                              
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (*EMmsg == EMS_I_WasLastGroupComp)
    {
      OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                        targetid = part_supp_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    batch_GRid.objid = my_id;
    batch_GRid.osnum = OM_Gw_current_OS;      

    nd$wait_batch(type = GR_GEOM_POSTED,
                  nb_obj = 1,
                  l_object = &batch_GRid,
                  l_obj_info = &comp_type);

    if (!(options & EMdel_fea_DELAY_UPDATE))
    {
      nd$exec_batch();

      /*The auto dimension is now incorrect so delete the dimensions and
       * regen after the param pt has been disconnected/deleted
       */
      OM_stat = EFregen_autodim(EMmsg, my_id, OM_Gw_current_OS, env, FALSE, 
                                NULL);      
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
    else
    {
      /*Delete the now out-of-date autodim*/
      OM_stat = EFregen_autodim(EMmsg, my_id, OM_Gw_current_OS, env, TRUE, 
                                NULL);      
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }
  else if (options & EMdel_fea_CLEANUP_DELETED)
  {
    IGRuint         as_type, total_group_cnt;
    OMuint          parent_inx, param_child_cnt;
    GRobjid         param_id;
    OM_S_CHANSELECT to_father;
    IGRushort       group_comp_inx;
    OMuword         dumosnum;
    IGRboolean      hole_flag, axis_normal, through_hole, ref_plane,
                    del_all_parampts=FALSE;
    IGRuint         var_par, ii;
    IGRushort       hole_type, depth_type;
    IGRint          part_type;
    IGRuint         info_size=0;
    IGRchar         *info=NULL;


    if (part_supp_id == NULL_OBJID) {*EMmsg=EMS_E_InvalidCase; goto wrapup;}

    /*Delete the proper parent*/
    OM_stat = om$send(msg = message EMSpartsupp.EMget_index_of_comp_id(EMmsg, 
                            group_comp_id, &group_comp_inx, 
                            &total_group_cnt, NULL),
                      targetid = part_supp_id);                              
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL,
                            &as_type, NULL, NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      

    EFret_hole_cpart_data_mod(EMmsg, as_type, &hole_flag, &axis_normal,  
                              &var_par, &hole_type, &depth_type, &part_type, 
                              &through_hole, &ref_plane);
    if (!(1 & *EMmsg)) goto wrapup;

    /*Adjust the assoc info in necessary*/
    if(hole_flag)
    {
      struct EMSplace_hole *plhole_info;

      OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL,
                              &as_type, &info_size, &info),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      
        
      plhole_info = (struct EMSplace_hole *) info;

      plhole_info->hole_count--;

      OM_stat = om$send(msg = message EMSassoc.EMput_info(EMmsg, NULL,
                              as_type, info_size, info),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      /*If cutout and only 1 left then del all param pts*/
      if (hole_type == 2 && plhole_info->hole_count == 1)
         del_all_parampts = TRUE;

      if (info) om$dealloc(ptr = info);        
    }

    EMmake_chanselect(NDfather_father, &to_father);

    for(ii=0; ii<2; ii++)
    {
      if (ii == 0)               parent_inx = group_comp_inx;
      else if (del_all_parampts) parent_inx = 0;
      else break;  /*safety only*/

      OM_stat = om$get_objid_at_index(object = me,
                                      p_chanselect = &to_father,
                                      index = parent_inx,
                                      objidaddr = &param_id,
                                      osnumaddr = &dumosnum);
      if (!(1 & OM_stat)) goto wrapup;                                    
    
      OM_stat = om$get_channel_count(objid = param_id,
                                     p_chanselect = &to_children,
                                     count = &param_child_cnt);
      if (!(1 & OM_stat)) goto wrapup;

      /*Simply disconnect the param pt no matter what*/      
      OM_stat = om$send(msg = message Root.range_disconnect(to_father, 
                              parent_inx, parent_inx),
                        targetid = my_id);
      if (!(1 & OM_stat)) goto wrapup;                      

      /* If the param pt had more than 1 child then dont delete it since
       * it has dependents of its own.
       */

      if (param_child_cnt < 2) /*Im the only dependent*/
      {
        OM_stat = om$send(msg = message EMSparameter.EMparam_delete(EMmsg,
                                env),
                          targetid = param_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;                        
      }

      if (!del_all_parampts) break; /*Cycle only once in this case*/
    }
    
    if (total_group_cnt <= 1)
    {
      /*delete the partial suppress id (if no other group comp ids).*/
      OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                        targetid = part_supp_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
    else
    {
      /*adjust the indices in the comp_info vla*/
      OM_stat = om$send(msg = message EMSpartsupp.EMdelete_group_comp(EMmsg,
                              group_comp_id, env, NULL),
                        targetid = part_supp_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                        
    }
  }

wrapup:

  /* post the display_ids to the EMSdprparam object if necessary */

  if (update_display_ids && loc_display_count)
  {
    OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(EMmsg,
                                   loc_display_count, loc_display_ids, NULL),
                      targetid = param_id);
  }

  EMWRAPUP(*EMmsg, OM_stat, "boolfea.partialdelfea")
  return(OM_stat);
}


#argsused
IGRlong EFregen_autodim(EMmsg, id, os, env, delete_only, options)
IGRlong     *EMmsg;
GRobjid     id;
OMuword     os;
struct GRmd_env *env;
IGRboolean  delete_only;
OMuword     options;
{
  IGRlong       OM_stat=OM_S_SUCCESS, msg_loc=EMS_S_Success;
  IGRuint       my_child_cnt;  
  IGRint        fea_cnt=0, ii;
  GRobjid       *fea_ids=NULL;
  OM_S_CHANSELECT to_children, to_comps;
  struct GRmd_env temp_env;
  IGRboolean      is_invis;

  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSdpr.EMget_feature_definition(EMmsg,
                          &fea_cnt, &fea_ids, NULL),
                    senderid = id,
                    targetid = id,
                    targetos = os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                                    
 
  if (!fea_cnt) {*EMmsg = EMS_I_InvalidSend; goto wrapup;}

  EMmake_chanselect(NDchildren_children, &to_children);
  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  temp_env = *env;
  temp_env.md_id.objid = NULL_OBJID;
  
  is_invis = ex$is_invis(mod_osnum = os); 

  for(ii=0; ii<fea_cnt; ii++)
  {
    id = fea_ids[ii];
  
    OM_stat = om$get_channel_count(objid = id,
                                   osnum = os,
                                   p_chanselect = &to_children,
                                   count = &my_child_cnt);
    if (!(1 & OM_stat)) goto wrapup;                                   
  
    if (my_child_cnt)
    {
      enum GRdpmode mode=GRbehe;
      OMuint        ii;
      GRobjid       dim_id;
      OM_S_OBJECT_LINKAGE *child_links=NULL;
      IGRshort       action=0, grprops=(GRIS_LOCATABLE | GRIS_DISPLAYABLE);
      extern OMuword OPP_DMroot_class_id;
        
  
      /*Update auto dim*/
      child_links = (OM_S_OBJECT_LINKAGE *) 
                    alloca(my_child_cnt * sizeof(OM_S_OBJECT_LINKAGE));      
  
      OM_stat = om$get_channel_objects(objid = id,
                                       osnum = os,
                                       p_chanselect = &to_children,
                                       list = child_links,
                                       size = my_child_cnt,
                                       count = &my_child_cnt);
      if (!(1 & OM_stat)) goto wrapup;                                       
  
      for(ii=0; ii<my_child_cnt; ii++)
      {
        dim_id = child_links[ii].S_objid;
  
        if (EFisAncestryValid(&msg_loc, dim_id, os, 
                              OPP_DMroot_class_id, FALSE))
        {
          /*Go thru the following hoops in order to delete the old dim.*/
  
          if (!is_invis)
          {
            om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                    &env->md_env.matrix_type,
                                    env->md_env.matrix,
                                    &mode, &env->md_id),
                    senderid = dim_id,
                    targetos = os,
                    p_chanselect = &to_comps);
          }
  
          om$send(msg = message GRgraphics.GRchgprops(&msg_loc, &action,
                        &grprops), 
                  senderid = dim_id,
                  targetid = dim_id,
                  targetos = os);
  
          if (env->md_id.objid != NULL_OBJID)
          {
            om$send(msg = message GRgraphics.GRremwrng(&msg_loc, env),
                    senderid = dim_id,
                    targetid = dim_id,
                    targetos = os);
          }
  
          om$send(msg = message GRowner.GRdelete(&msg_loc,
                        &temp_env),
                  mode = OM_e_wrt_message,
                  senderid = dim_id,
                  targetid = dim_id,
                  targetos = os);
        }
      }                          
    }
  
    if (!delete_only)
    {
      /*Finally do that autodim thing again*/
      om$send(msg = message EMSassoc.EMautodim(&msg_loc, env),
              senderid = id,
              targetid = id,
              targetos = os);
    }
  }

wrapup:
  if (fea_ids) om$dealloc(ptr = fea_ids);
  EMWRAPUP(*EMmsg, OM_stat, "EFregen_autodim")
  return(OM_stat);
}
end implementation EMSsfboolfea;
