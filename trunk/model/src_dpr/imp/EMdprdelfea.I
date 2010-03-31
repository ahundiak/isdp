class implementation EMSdpr;

#include "EMSdpr.h"
#include "emsdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include <alloca.h>
#include <stdio.h>
#include "EMSopt.h"

from EMSsurface  import EMunevaluate;
from EMSdprparam import EMget_display_ids, EMput_display_ids;
from NDnode      import NDmove_to_root;
from EMSsuppress import EMget_suppress_id;
from EMSsubbs    import EMput_range_in_rtree;

method EMdelete_feature(IGRlong         *EMmsg;
                        struct GRmd_env *env;
                        OMuword         options)

/*
Description
    Delete a feature from the tree while keeping the integrity of the tree
    intact. 

Return Values
    EMS_S_Success if all is well

Notes
    This method assumes that a feature has all added geometry after index 0 are
    added and such added geom will not be connected up to the owner.

    Boolean and stitch nodes do not meet this assumtion and it is assumed that
    these cases will be handled later...

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
   WBC 12/17/93 Update the display_ids in the EMSdprparam object at the end
                of the method if necessary.  Currently, if an error is
                returned by certain method/function calls, the display_ids
                may not be posted.
   WBC 11/22/93 After sending the EMunevaluate message, update the ranges of
                the affected surfaces by sending the message
                EMput_range_in_rtree (TR#119312751).
   DLB 03/22/93 Allow non-feature dps to be deleted if they are dependent on
                a deleting feature.
   DLB 11/20/92 Creation.
*/
{
  IGRlong       OM_stat=OM_S_SUCCESS;
  IGRint        fea_cnt=0, ii, comp_type=ND_COMP, loc_display_count=0;
  GRobjid       *fea_ids=NULL, *loc_display_ids=NULL, param_id;
  struct GRid   batch_GRid;
  IGRushort     dpr_props;
  IGRboolean    update_display_ids = FALSE;

  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSdpr.EMget_feature_definition(EMmsg,
                          &fea_cnt, &fea_ids, NULL),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                                    
 
  if (!fea_cnt) 
  {
    /*I'm a non-feature dpr who is dependent on a feature being deleted.
     *  just proceed with my id as the feature.
     */
    fea_cnt = 1;
    fea_ids = &my_id;
  }

  if (options & EMdel_fea_DELETE_AND_SAVE)
  {
    GRobjid     ownerid;
    IGRboolean  set=TRUE, save_broadcast_in_progress;
    extern OMuword OPP_EMSsfmacro_class_id;
    extern IGRboolean ASbroadcast_in_progress;


    /*Get the display_ids array*/
    OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(
                                     EMmsg, &loc_display_count,
                                     &loc_display_ids, NULL), 
                              my_id, OM_Gw_current_OS, &param_id, NULL);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                            

    update_display_ids = TRUE;

    for(ii=0; ii<fea_cnt; ii++)
    {
      *EMmsg = EMS_S_Success;

      if (!EFisAncestryValid(EMmsg, fea_ids[ii], OM_Gw_current_OS, 
                             OPP_EMSsfmacro_class_id, FALSE))
      {
        OM_stat = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg,
                                &dpr_props),       
                          targetid = fea_ids[ii]);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
        if (!(dpr_props & EMS_UNEVAL_STATE))
        {
          /*Set broadcast_in_progress to 1 before issuing uneval in order to
           * keep any of my MSCs.  Otherwise edges created by me will
           * send a delete to the MSC on its notification chan.  THe
           * EMpostdelete message overridden at EMSedge chechks for the 
           * broadcast_in_progress flag before deleting.
           */
          save_broadcast_in_progress = ASbroadcast_in_progress;
          ASbroadcast_in_progress = 1;

          OM_stat = om$send(msg = message EMSsurface.EMunevaluate(EMmsg,
                                  EMuneval_DO_DISPLAY | 
                                  EMuneval_DONT_REDRAW |
                                  EMuneval_IMMEDIATE_OPER |
                                  EMuneval_DELETE_SSI,
                                  env, &loc_display_ids, &loc_display_count,
                                  &ownerid, NULL_OBJID, NULL),
                        targetid = fea_ids[ii]); 
          ASbroadcast_in_progress = save_broadcast_in_progress;

          if (!(1 & *EMmsg & OM_stat)) goto wrapup;

          /* update the range of the "unevaluated" element; this is necessary
           * since we set ASbroadcast_in_progress to 1 during EMunevaluate
           * above, which prevents the affected surface's ranges from being
           * updated during display
           */

          OM_stat = om$send(msg = message EMSsubbs.EMput_range_in_rtree(
                                                EMmsg, NULL, NULL, NULL,
                                                GEOMETRICAL, &env->md_id),
                            targetid = fea_ids[ii]);

          if (!(1 & *EMmsg & OM_stat)) goto wrapup;
        }
      }

      if (*EMmsg != EMS_I_CantRecompute)
      {
        dpr_props = EMS_DELETED;
        OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &set,
                                &dpr_props),
                          targetid = fea_ids[ii]);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;                          

        batch_GRid.objid = fea_ids[ii];
        batch_GRid.osnum = OM_Gw_current_OS;      

        nd$wait_batch(type = GR_GEOM_POSTED,
                      nb_obj = 1,
                      l_object = &batch_GRid,
                      l_obj_info = &comp_type);
      }
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
    IGRboolean clear=FALSE;

    for(ii=0; ii<fea_cnt; ii++)
    {
      OM_stat = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg,
                              &dpr_props),       
                        targetid = fea_ids[ii]);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
      if (dpr_props & EMS_DELETED)
      {
        dpr_props = EMS_DELETED;
        OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &clear,
                                &dpr_props),
                          targetid = fea_ids[ii]);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;                          

        batch_GRid.objid = fea_ids[ii];
        batch_GRid.osnum = OM_Gw_current_OS;      

        nd$wait_batch(type = GR_GEOM_POSTED,
                      nb_obj = 1,
                      l_object = &batch_GRid,
                      l_obj_info = &comp_type);
      }
    }   

    if (!(options & EMdel_fea_DELAY_UPDATE))
    {
      nd$exec_batch();
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
    IGRlong         inx=0, max_inx=OM_K_MAXINT, connect_no_matter_what=1;
    OMuint          owner_count, jj;
    GRobjid         comp_id, suppress_id;
    struct GRid     cur_GRid, tmp_GRid;
    OM_S_CHANSELECT to_comps, to_owners, to_children;
    OM_S_OBJECT_LINKAGE *owner_links=NULL;
    OMuword         dumosnum;
    IGRushort       dpr_props;
    IGRshort        grprops;


    EMmake_chanselect(GRcmpowner_to_components, &to_comps);
    EMmake_chanselect(GRconnector_to_owners, &to_owners);
    EMmake_chanselect(NDchildren_children, &to_children);

    /*Issue a move_to_root msg to the fea to clean up assoc info, EMSparam*/ 
    for(ii=0; ii<fea_cnt; ii++)
    {
      OM_stat = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg,
                              &dpr_props), 
                        targetid = fea_ids[ii]);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
                              
      /*This fella better be DELETED!!!*/
      if (!(dpr_props & EMS_DELETED)) {*EMmsg=EMS_I_InvalidSend; goto wrapup;}

      OM_stat = om$send(msg = message GRgraphics.GRgetprops(EMmsg,
                              &grprops),
                        targetid = fea_ids[ii]);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                            

      OM_stat = om$send(msg = message NDnode.NDmove_to_root(EMmsg, &tmp_GRid,
                              env),
                        targetid = fea_ids[ii]);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      
      /*Now actually delete the node from the tree.*/
      cur_GRid.osnum = OM_Gw_current_OS;
 
      /*Get my 0 index component.  Obviously am assuming that all added geom
       * is on index 1-n (at any rate this node is uneval'd so should only have
       * 1 comp).
       */
      OM_stat = om$get_objid_at_index(objid = fea_ids[ii],
                                      p_chanselect = &to_comps,
                                      index = 0,
                                      objidaddr = &comp_id,
                                      osnumaddr = &dumosnum);
      if (!(1 & OM_stat)) goto wrapup;

      /*Get the dudes above (if any).*/
      owner_count = 0;
      OM_stat = om$get_channel_count(objid = fea_ids[ii],
                                     p_chanselect = &to_owners,
                                     count = &owner_count);
      if (!(1 & OM_stat)) goto wrapup;

      if (owner_count)
      {
        /*Get the owner ids and then disconnect them from the deleted fea.*/
        owner_links = (OM_S_OBJECT_LINKAGE *) 
                      alloca(owner_count * sizeof(OM_S_OBJECT_LINKAGE));

        OM_stat = om$get_channel_objects(objid = fea_ids[ii],
                                         p_chanselect = &to_owners,
                                         list = owner_links,
                                         size = owner_count,
                                         count = &owner_count);
        if (!(1 & OM_stat)) goto wrapup;                                       

        /*Disconnect'em*/
        for(jj=0; jj<owner_count; jj++)
        {
          cur_GRid.objid = owner_links[jj].S_objid;
          
          OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, 
                                  &cur_GRid),
                            targetid = fea_ids[ii]);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        }
      }                                  

      /*Disconnect the component from the deleted feature.*/
      cur_GRid.objid = fea_ids[ii];

      OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, &cur_GRid),
                        targetid = comp_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    
      /*If the fea is the top of the tree set the component to active*/
      if (dpr_props & EMSIS_ACTIVE_STATE)
      {
        IGRboolean  true=TRUE;
        IGRushort   mask=EMSIS_ACTIVE_STATE;
  
        OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &true, &mask),
                          targetid = comp_id); 
        if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS; /*non-dpr*/
        else if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }

      /*Attach my owners to the comp id.*/
      for(jj=0; jj<owner_count; jj++)
      {
        cur_GRid.objid = owner_links[jj].S_objid;

        if (jj == 0 && (grprops & GR_RIGID_RELATIONSHIP))
        {
          OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                                  &cur_GRid, &inx),
                            targetid = comp_id);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        }
        else
        {
          OM_stat = om$send(msg = message GRconnector.GRflexconn(EMmsg, 
                                  &connect_no_matter_what, &cur_GRid,
                                  &inx, &max_inx),
                            targetid = comp_id);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;                            
        }
      }     

      /*Last of all, delete the suppress id (if any) and then me.*/
      suppress_id = NULL_OBJID;
      OM_stat = om$send(msg = message EMSsuppress.EMget_suppress_id(EMmsg,
                              &suppress_id, NULL),
                        senderid = fea_ids[ii],
                        p_chanselect = &to_children);
      if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
      else if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (suppress_id != NULL_OBJID)
      {
        OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                          targetid = suppress_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }

      OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                        targetid = fea_ids[ii]);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                                

      if (owner_links) 
      {
        allocf(owner_links);  /*NOOP!!!*/
        owner_links = NULL;
      }
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

  if (fea_ids) om$dealloc(ptr = fea_ids);
  EMWRAPUP(*EMmsg, OM_stat, "dpr.delfea")
  return(OM_stat);
}
end implementation EMSdpr;

