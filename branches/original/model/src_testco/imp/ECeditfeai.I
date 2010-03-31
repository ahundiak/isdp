class implementation ECeditfea;

/*
History
    DLB 06/31/91    Creation date.
    scw 08/14/94    clarified sleep method
*/

#define DELFEA 0

#include <stdio.h>
#include "msmacros.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
#include "dp.h"
#include "dpmacros.h"
#include "lcmacros.h"
#include "EMSlcdef.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grmacros.h"
#include "emsdef.h"
#include "ECcmd.h"
#include "ECmsg.h"
#include "EMSdpr.h"
#include "batch.h"
#include "nddef.h"
#include "ndmacros.h"
#include "emserr.h"
#include "EMSaction.h"

from EMSdpr      import EMdelete_feature, EMpartial_delete_group_feature;
from EMSpartsupp import EMget_partial_suppress_id;                
from EMSpatfea import EMdelete_pattern_node;

extern OMuword OPP_EMSsubbs_class_id,
               OPP_EMSdpr_class_id;

extern unsigned char EMS_locate_features;

static IGRlong EFcheck_group_feas(EMmsg, num_feas, fea_info,
                                  new_num_feas, new_fea_info)
IGRlong            *EMmsg;
IGRuint            num_feas;
struct EMSfea_info *fea_info;
IGRuint            *new_num_feas;
struct EMSfea_info **new_fea_info;
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRuint         ii, jj, cmp_cnt;  
  OM_S_CHANSELECT to_comps, to_children;
  struct GRid     cur_fea_grid;
  IGRboolean      keep_as_is, skip_this_one;
  

  *EMmsg = EMS_S_Success;

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);
  EMmake_chanselect(NDchildren_children, &to_children);

  /*Alloc the new array to be same size as original since its more efficient*/
  *new_fea_info = (struct EMSfea_info *) 
                  om$malloc(size = num_feas * sizeof(struct EMSfea_info));
  if (!*new_fea_info) {*EMmsg=EMS_E_NoDynamicMemory; goto wrapup;}

  *new_num_feas = 0;

  for(ii=0; ii<num_feas; ii++)
  {
    keep_as_is = TRUE;
    skip_this_one = FALSE;

    if (fea_info[ii].grid.objid == NULL_OBJID)
    {
      skip_this_one = TRUE;
    }
    else if (fea_info[ii].group_comp_grid.objid != NULL_OBJID)
    {
      /*Have a group fea so see if there is a partsuppress object.  If so
       * a partial suppress is in progress (NOT a delete) so cant do a 
       * full delete.
       */
      GRobjid part_supp_id=NULL_OBJID;

      OM_stat = om$send(msg = message EMSpartsupp.EMget_partial_suppress_id
                              (EMmsg, &part_supp_id, NULL), 
                        senderid = fea_info[ii].grid.objid,
                        targetos = fea_info[ii].grid.osnum,
                        p_chanselect = &to_children);
      if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;  
      else if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (part_supp_id == NULL_OBJID)
      {
        /*See if all were located.*/
        OM_stat = om$get_channel_count(objid = fea_info[ii].grid.objid,
                                       osnum = fea_info[ii].grid.osnum,
                                       p_chanselect = &to_comps,
                                       count = &cmp_cnt);
        if (!(1 & OM_stat)) goto wrapup;

        cmp_cnt--; /*Due to the base solid on the same chan.*/

        for(jj=ii; jj<num_feas; jj++)
        {
          if (fea_info[jj].grid.objid == fea_info[ii].grid.objid &&
              fea_info[jj].grid.osnum == fea_info[ii].grid.osnum)
          {
            if (fea_info[jj].group_comp_grid.objid != NULL_OBJID) cmp_cnt--;
            else 
            {
              /*Have a case where fea was located for both PARTIAL and FULL
               * delete.  Should have been screened at locate time.
               */

              *EMmsg = EMS_E_InvalidCase;
              goto wrapup;
            }
          }
        }

        if (cmp_cnt == 0)
        {
          keep_as_is = FALSE; /*Every group comp was located so just del all.*/
        }
      }
    }                       

    if (!skip_this_one)
    {
      if (keep_as_is) /*full fea or partial group fea*/
      {
        (*new_fea_info)[*new_num_feas] = fea_info[ii];
        (*new_num_feas)++;
  
        /*ptrs were moved from old to new so reset old -safety- DONT FREE!!!!*/
        fea_info[ii].num_deps = 0;
        fea_info[ii].dep_grids = NULL;
      }
      else
      {
        /*partial group fea with all group comps located - collapse the group
         * and just do single full fea delete.
         */
        IGRuint total_dep_grids=0;

        (*new_fea_info)[*new_num_feas] = fea_info[ii];
        (*new_fea_info)[*new_num_feas].group_comp_grid.objid = NULL_OBJID;
        
        /*Must merge all dependent feas into one*/
        /*First get a total to merge*/
        for(jj=ii; jj<num_feas; jj++)
        {
          if (fea_info[jj].grid.objid == fea_info[ii].grid.objid &&
              fea_info[jj].grid.osnum == fea_info[ii].grid.osnum)
          {
            total_dep_grids += fea_info[jj].num_deps;
          }
        }

        if (total_dep_grids)
        {
          (*new_fea_info)[*new_num_feas].dep_grids = (struct GRid *) 
                       om$malloc(size = total_dep_grids * sizeof(struct GRid));
          if (!(*new_fea_info)[*new_num_feas].dep_grids)
          {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
        }
        else (*new_fea_info)[*new_num_feas].dep_grids = NULL;
          
        total_dep_grids = 0;

        /*Combine all the partials into one full*/
        cur_fea_grid = fea_info[ii].grid;

        for(jj=ii; jj<num_feas; jj++)
        {
          if (fea_info[jj].grid.objid == cur_fea_grid.objid &&
              fea_info[jj].grid.osnum == cur_fea_grid.osnum)
          {
            /*Clear the old so it isnt processed again*/
            fea_info[jj].grid.objid = NULL_OBJID;
            fea_info[jj].group_comp_grid.objid = NULL_OBJID;

            if (fea_info[jj].num_deps)
            {
              /*Move the deps over to the new full fea*/
              OM_BLOCK_MOVE
                   (fea_info[jj].dep_grids,
                    &(*new_fea_info)[*new_num_feas].dep_grids[total_dep_grids],
                    fea_info[jj].num_deps * sizeof(struct GRid));

              total_dep_grids += fea_info[jj].num_deps;
                          
              /*free the old ptrs*/
  
              om$dealloc(ptr = fea_info[jj].dep_grids);
              fea_info[jj].num_deps = 0;
              fea_info[jj].dep_grids = NULL;
            }
          }
        }

        (*new_fea_info)[*new_num_feas].num_deps = total_dep_grids;
        (*new_num_feas)++;
      }            
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFcheck_group_feas")
  return(OM_stat);
}    

static IGRlong EFcmd_regen_autodim(EMmsg, num_feas, fea_info, restore_fea)
IGRlong            *EMmsg;
IGRuint            num_feas;
struct EMSfea_info *fea_info; 
IGRboolean         restore_fea;
{
  IGRlong     OM_stat=OM_S_SUCCESS;
  IGRuint     num_deps, ii, jj;
  struct GRid *dep_grids;


  /*Auto dim the changed features*/
  for(ii=0; ii<num_feas; ii++)
  {
    if (fea_info[ii].group_comp_grid.objid != NULL_OBJID) 
    {
      /*See if have already processed this fea group.*/
      for(jj=0; jj<ii; jj++)
      {
        if (fea_info[ii].grid.objid == fea_info[jj].grid.objid &&
            fea_info[ii].grid.osnum == fea_info[jj].grid.osnum) break;
      }
      if (jj == ii)
      {
        /*Not already processed so regen the group fea if deleting OR
         * restoring.
         */
        OM_stat = EFregen_autodim(EMmsg, 
                                  fea_info[ii].grid.objid,
                                  fea_info[ii].grid.osnum, 
                                  &fea_info[ii].env,
                                  FALSE, NULL); 
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }
    }
    else if (restore_fea)
    {
      /*The fea delete code deleted the auto dim.  The restore process
       * must therefore regen the autodim.*/
      OM_stat = EFregen_autodim(EMmsg, 
                                fea_info[ii].grid.objid,
                                fea_info[ii].grid.osnum, 
                                &fea_info[ii].env,
                                FALSE, NULL); 
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    num_deps = fea_info[ii].num_deps;
    dep_grids = fea_info[ii].dep_grids;
 
    for(jj=0; jj<num_deps; jj++, dep_grids++)
    {
      OM_stat = EFregen_autodim(EMmsg, 
                                dep_grids->objid,
                                dep_grids->osnum, 
                                &fea_info[ii].env,
                                FALSE, NULL); 
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFcmd_regen_autodim")
  return(OM_stat);
}

method delete(int f_defer_flag)
{
  IGRuint ii;

  for(ii=0; ii<me->num_feas; ii++)
  {
    if (me->fea_info[ii].dep_grids)
    {
      om$dealloc(ptr = me->fea_info[ii].dep_grids);
      me->fea_info[ii].num_deps = 0;
      me->fea_info[ii].dep_grids = NULL;
    }
  }

  return(om$send(mode = OM_e_wrt_parent,
                 msg = message ECeditfea.delete(NULL),
                 targetid = my_id));
}

method wakeup(int pos)
{
  IGRuint ii, jj;

  EMS_locate_features = TRUE;
  for(ii=0; ii<me->num_feas; ii++)
  {
    if (me->fea_info[ii].group_comp_grid.objid == NULL_OBJID)
    {
      gr$display_object(object_id = &me->fea_info[ii].grid,
                        md_env = &me->fea_info[ii].env,
                        mode = GRhhd);
    }
    else
    {
      gr$display_object(object_id = &me->fea_info[ii].group_comp_grid,
                        md_env = &me->fea_info[ii].env,
                        mode = GRhhd);
    }

    for(jj=0; jj<me->fea_info[ii].num_deps; jj++)
    {
      gr$display_object(object_id = &me->fea_info[ii].dep_grids[jj],
                        md_env = &me->fea_info[ii].env,
                        mode = GRhhd);
    }
  }      
  EMS_locate_features = FALSE;

  return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
  IGRlong EMmsg;

  ex$message(msgnumb=EM_M_ClearMessageField);
  ex$message(msgnumb=EMS_S_ClearStatusField);
  ex$message(msgnumb=EMS_P_ClearPromptField);
  dp$erase_hilite(msg = &EMmsg);
  return(OM_S_SUCCESS);
}

#define GET_FEAS        0
#define SHOW_DEPS       1
#define PROC_FEAS        2

method execute(int *response; char *response_data; int pos)
{
 IGRlong               OM_stat=OM_S_SUCCESS, EMmsg=EMS_S_Success;
 IGRlong               loc_key, acc_key, reloc_key;
 IGRint                size=sizeof(struct GRevent), display_flag;
 IGRuint               num_deps, ii, jj;
 struct GRid           *dep_grids, loc_grid, group_comp_grid;
 IGRboolean            feas_processed=FALSE;
 extern struct ext_list NDmodif;


 ex$message(msgnumb = EM_M_DlFea);

 if (NDmodif.nb_obj)
 {
   ex$message(msgnumb = EMS_E_NoDelInDelay);
   ex$message(msgnumb = EMS_E_MustTogToImed);   
   return(OM_E_ABORT);
 }

 do
 {
   switch(me->state)
   {
     case GET_FEAS:
     {
       IGRuint cur_fea, total_loc;
       struct GRlc_locate attr;
       OM_S_CLASSLIST     rtree_classes, elig_classes;
       OMuword            rclass, eliclass;
       struct EMSaction_handler already_located;
       struct GRid              *already_list,pattern_id;
       extern IGRlong           EFlocate_action_handler();


       display_flag = ALL_WINDOWS |
                      ELEM_HILIGHT | 
                      NO_PROJ_ACCEPT_POINT |
                      LC_ERASE_LOC_ELEMENT;
       strcpy(attr.classes, "EMSsurface");
       attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
       attr.owner_action = LC_RIGID_COMP     | 
                           LC_RIGID_OWNER    | 
                           LC_INTERMIDIATE   |
                           LC_BOTTOM_UP      |
                           LC_NO_REF_HEADER  |
                           LC_REF_OBJECTS    |
                           LC_ASSOCIATIVE    |
                           LC_EXTERN_CONSTRAINED;

       rtree_classes.w_count = elig_classes.w_count = 1;
       rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
  
       rclass = OPP_EMSsubbs_class_id;
       eliclass = OPP_EMSdpr_class_id;
  
       rtree_classes.p_classes = &rclass;
       elig_classes.p_classes = &eliclass;
  
       if (!feas_processed)
       {
         if (!me->num_feas)
           loc_key = EMS_P_IdFea;
         else
           loc_key = EMS_P_IdNextFeaMvOn;
       }
       else
         loc_key = EMS_P_IdFeaBkUpToUndo;
       
       acc_key = EMS_P_00038; /*Acc/Rjt*/
       
       reloc_key = EMS_I_00013; /*Ele not found*/

       already_located.next = NULL;
       already_located.option = 0;
       already_located.type = 1;  /*GRid*/

       if (!feas_processed)
       {
         for(ii=0, total_loc=0; ii<me->num_feas; ii++)
         {
           if (me->fea_info[ii].group_comp_grid.objid == NULL_OBJID)
             total_loc++;       /*full fea id*/
           else total_loc += 2; /*full AND partial fea ids*/

           total_loc += me->fea_info[ii].num_deps;  /*its dependents*/
         }

         already_list = (struct GRid *) 
                        alloca(total_loc * sizeof(struct GRid));

         for(ii=0, total_loc=0; ii<me->num_feas; ii++)
         {
           if (me->fea_info[ii].group_comp_grid.objid == NULL_OBJID)
             already_list[total_loc] = me->fea_info[ii].grid;
           else
           {
             already_list[total_loc++] = me->fea_info[ii].grid;
             already_list[total_loc] = me->fea_info[ii].group_comp_grid;
           }

           total_loc++;

           num_deps = me->fea_info[ii].num_deps;

           if (num_deps)
           {
             OM_BLOCK_MOVE(me->fea_info[ii].dep_grids,
                           &already_list[total_loc],
                           num_deps * sizeof(struct GRid));
             total_loc += num_deps;
           }                         
         }

         already_located.num_objects = total_loc;
         already_located.objects.id = already_list;
       }
       else
       {
         already_located.num_objects = 0;
         already_located.objects.id = NULL;
       }
        
       EMS_locate_features = TRUE;
       lc$locate(rc = &EMmsg, 
                 event1 = &me->event, 
                 event2 = &me->event,
                 mask1 = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON, 
                 mask2 = GRm_DATA,
                 eventsize= &size, 
                 display_flag = display_flag,
                 response = response, 
                 response_data = response_data, 
                 unhilight_mode = (enum GRdpmode) GRhhd,
                 locate_key = loc_key,
                 acc_key = acc_key,
                 relocate_key = reloc_key,
                 attributes = &attr,
                 act_handler = EFlocate_action_handler,
                 act_args = &already_located, 
                 stack = &me->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);
       EMS_locate_features = FALSE;
  
       if (me->event.response != EX_BACK_UP && feas_processed)
       {
         /*Cleanup the deleted featues since the user doesn't want to restore*/
         for(ii=0; ii<me->num_feas; ii++)
         {
           if (me->fea_info[ii].group_comp_grid.objid == NULL_OBJID)
           {
	     /* kludge to take care of delete of pattern elements */

	     OM_stat = EMSget_pattern_object(&EMmsg, 
					    &me->fea_info[ii].grid,
					    &me->fea_info[ii].env,
					    &pattern_id);
	     if( pattern_id.objid != NULL_OBJID)
	       {
		 OM_stat = 
		 om$send( msg = message EMSpatfea.EMdelete_pattern_node(
						     &EMmsg,
						     &me->fea_info[ii].grid,
						     &me->fea_info[ii].env),
			 targetid = pattern_id.objid,
			 targetos = pattern_id.osnum);
		 if (!(1 & OM_stat & EMmsg)) goto wrapup;
	       }
	     else
	       {
		 OM_stat = 
		   om$send(msg = message EMSdpr.EMdelete_feature(&EMmsg, 
                                     &me->fea_info[ii].env, 
                                     EMdel_fea_CLEANUP_DELETED),
			   targetid = me->fea_info[ii].grid.objid,
			   targetos = me->fea_info[ii].grid.osnum);
		 if (!(1 & OM_stat & EMmsg)) goto wrapup;
	       }
           }
           else
           {
             OM_stat = om$send(msg = 
                        message EMSdpr.EMpartial_delete_group_feature(&EMmsg, 
                                     &me->fea_info[ii].env,
                                     me->fea_info[ii].group_comp_grid.objid,
                                     EMdel_fea_CLEANUP_DELETED),
                               targetid = me->fea_info[ii].grid.objid,
                               targetos = me->fea_info[ii].grid.osnum);
             if (!(1 & OM_stat & EMmsg)) goto wrapup;                        
           }

           num_deps = me->fea_info[ii].num_deps;
           dep_grids = me->fea_info[ii].dep_grids;
 
           for(jj=0; jj<num_deps; jj++, dep_grids++)
           {
             OM_stat = om$send(msg = message EMSdpr.EMdelete_feature(
                                     &EMmsg,  
                                     &me->fea_info[ii].env, 
                                     EMdel_fea_CLEANUP_DELETED),
                               targetid = dep_grids->objid,
                               targetos = dep_grids->osnum);
             if (!(1 & OM_stat & EMmsg)) goto wrapup;                      
           }

           if (num_deps && me->fea_info[ii].dep_grids)
           {
             om$dealloc(ptr = me->fea_info[ii].dep_grids);
             me->fea_info[ii].num_deps = 0;
             me->fea_info[ii].dep_grids = NULL;
           }
         }

         feas_processed = FALSE;
         me->num_feas = 0;
       }

       group_comp_grid.objid = NULL_OBJID;

       switch(me->event.response)
       {
         case EX_DATA:
         {
           /*First see if the located id is a feature.  If not then we have
            * a group feature and the returned id is the group component id.
            */
           loc_grid = me->event.located_object[0].located_obj;
            
           if (!EFisAncestryValid(&EMmsg, loc_grid.objid, loc_grid.osnum,
                                 OPP_EMSdpr_class_id, FALSE) || 
               !EFis_dpr_a_feature(&EMmsg, loc_grid.objid, loc_grid.osnum,
                                   NULL, NULL, NULL))
           {
             GRobjid creator_id;

             OM_stat = EFget_creator_id(&EMmsg, loc_grid.objid,
                                        loc_grid.osnum, &creator_id, NULL);
             if (!(1 & OM_stat & EMmsg)) goto wrapup;

             if (EFisAncestryValid(&EMmsg, creator_id, loc_grid.osnum,
                                   OPP_EMSdpr_class_id, FALSE) && 
                 EFis_dpr_a_feature(&EMmsg, creator_id, loc_grid.osnum,
                                    NULL, NULL, NULL))
             {
                group_comp_grid = loc_grid;
                loc_grid.objid = creator_id;
             }
             else {EMmsg = EMS_E_InvalidCase; goto wrapup;}
           }

           /*Store the feature and check for dependents*/
           if (om$dimension_of(varray = me->fea_info) <= me->num_feas)
           {
             OM_stat = om$vla_set_dimension(varray = me->fea_info,
                                            size = me->num_feas + 4);
             if (!(1 & OM_stat)) goto wrapup;
           }

           me->fea_info[me->num_feas].grid = loc_grid;
           me->fea_info[me->num_feas].group_comp_grid = group_comp_grid;

           OM_BLOCK_MOVE(&me->event.located_object[0].module_info,
                         &me->fea_info[me->num_feas].env,
                         sizeof(struct GRmd_env));

           me->fea_info[me->num_feas].num_deps = 0;
           me->fea_info[me->num_feas].dep_grids = NULL;

           me->num_feas++;

           me->state = SHOW_DEPS;
           break;
         }

         case EX_BACK_UP:
         {
           if (!feas_processed)
           {
             cur_fea = me->num_feas - 1;
             
             if (!me->num_feas)
             {
               /*Just stay where I am*/
               me->state = GET_FEAS; 
             }
             else
             {
               /*Erase the last located feature and any dependents*/
               EMS_locate_features = TRUE;
               for(ii=0; ii<me->fea_info[cur_fea].num_deps; ii++)
               {
                 gr$display_object
                           (object_id = &me->fea_info[cur_fea].dep_grids[ii],
                            md_env = &me->fea_info[cur_fea].env,
                            mode = GRhe);
               }
           
               if (me->fea_info[cur_fea].dep_grids)
               {
                 om$dealloc(ptr = me->fea_info[cur_fea].dep_grids);
                 me->fea_info[cur_fea].dep_grids = NULL;
                 me->fea_info[cur_fea].num_deps = 0;
               }
    
               
               if (me->fea_info[cur_fea].group_comp_grid.objid == NULL_OBJID)
               {
                 gr$display_object(object_id = &me->fea_info[cur_fea].grid,
                                   md_env = &me->fea_info[cur_fea].env,
                                   mode = GRhe);
               }
               else
               {
                 gr$display_object(
                            object_id = &me->fea_info[cur_fea].group_comp_grid,
                            md_env = &me->fea_info[cur_fea].env,
                            mode = GRhe);
               }
               EMS_locate_features = FALSE;

               me->num_feas--;
               me->state = GET_FEAS;
             }
           }
           else
           {
             /*Restore the features and dependents*/
             for(ii=0; ii<me->num_feas; ii++)
             {
               if (me->fea_info[ii].group_comp_grid.objid == NULL_OBJID)
               {
                 OM_stat = om$send(msg = message EMSdpr.EMdelete_feature(
                                         &EMmsg,  
                                         &me->fea_info[ii].env, 
                                         EMdel_fea_RESTORE_DELETED |
                                         EMdel_fea_DELAY_UPDATE),
                                   targetid = me->fea_info[ii].grid.objid,
                                   targetos = me->fea_info[ii].grid.osnum);
                 if (!(1 & OM_stat & EMmsg)) goto wrapup;                      
               }
               else
               {
                 OM_stat = om$send(
                         msg = message EMSdpr.EMpartial_delete_group_feature(
                                        &EMmsg,  
                                        &me->fea_info[ii].env, 
                                        me->fea_info[ii].group_comp_grid.objid,
                                        EMdel_fea_RESTORE_DELETED |
                                        EMdel_fea_DELAY_UPDATE),
                                   targetid = me->fea_info[ii].grid.objid,
                                   targetos = me->fea_info[ii].grid.osnum);
                 if (!(1 & OM_stat & EMmsg)) goto wrapup;                      
               }

               num_deps = me->fea_info[ii].num_deps;
               dep_grids = me->fea_info[ii].dep_grids;
 
               for(jj=0; jj<num_deps; jj++, dep_grids++)
               {
                 OM_stat = om$send(msg = message EMSdpr.EMdelete_feature(
                                         &EMmsg,  
                                         &me->fea_info[ii].env, 
                                         EMdel_fea_RESTORE_DELETED | 
                                         EMdel_fea_DELAY_UPDATE),
                                   targetid = dep_grids->objid,
                                   targetos = dep_grids->osnum);
                 if (!(1 & OM_stat & EMmsg)) goto wrapup;                      
               }
             }

             nd$exec_batch();

             OM_stat = EFcmd_regen_autodim(&EMmsg, me->num_feas, me->fea_info,
                                           TRUE);
             if (!(1 & OM_stat & EMmsg)) goto wrapup;
             
             /*Must free after regen_autodim*/
             for(ii=0; ii<me->num_feas; ii++)
             {
               if (me->fea_info[ii].num_deps && me->fea_info[ii].dep_grids)
               {
                 om$dealloc(ptr = me->fea_info[ii].dep_grids);
                 me->fea_info[ii].num_deps = 0;
                 me->fea_info[ii].dep_grids = NULL;
               }
             }

             feas_processed = FALSE;
             me->num_feas = 0;
             me->state = GET_FEAS;    
           }
           break;
         }

         case EX_RJT_MOVEON:
         {
           if (!me->num_feas)
             me->state = GET_FEAS;
           else
             me->state = PROC_FEAS;           
         }

         default:
         {
           OM_stat = EMmsg = EMS_S_Success; 
           goto wrapup;
         }
       }

       break;
     }


     case SHOW_DEPS:
     {
       IGRuint         cur_fea, total_known_deps;
       struct GRid     *known_deps;
       struct GRmd_env disp_env;
       extern IGRlong  EFshow_parent_child_relationship();


       cur_fea = me->num_feas - 1;

       if (me->fea_info[cur_fea].num_deps)
       {
         /*Got here due to a backup or due to a cmd stack so just free the
          * exising mem and get the feas again.
          */        
         if (me->fea_info[cur_fea].dep_grids) 
           om$dealloc(ptr = me->fea_info[cur_fea].dep_grids);
         
         me->fea_info[cur_fea].num_deps = 0;         
         me->fea_info[cur_fea].dep_grids = NULL;         
       }

       /*Build a list of already found features & their dependents to pass to
        * EFshow_p_c_rel...
        * BUT! Let pass the last feature since the whole point of this
        *      exercise is finding its dependents!
        */ 
       for(ii=0, total_known_deps=0; ii<cur_fea; ii++)
       {
         /*Add full fea id only if not same as cur fea id.  Can only happen
          * if doing a partial delete and already have a group comp id of
          * the group fea.
          */
         if (me->fea_info[ii].grid.objid != me->fea_info[cur_fea].grid.objid ||
             me->fea_info[ii].grid.osnum != me->fea_info[cur_fea].grid.osnum)
         {
           total_known_deps++;  /*full fea id or fea group id*/
         }
         total_known_deps += me->fea_info[ii].num_deps;  /*its dependents*/
       }

       known_deps = (struct GRid *) 
                    alloca(total_known_deps * sizeof(struct GRid));

       for(ii=0, total_known_deps=0; ii<cur_fea; ii++)
       {
         if (me->fea_info[ii].grid.objid != me->fea_info[cur_fea].grid.objid ||
             me->fea_info[ii].grid.osnum != me->fea_info[cur_fea].grid.osnum) 
         {
           known_deps[total_known_deps++] = me->fea_info[ii].grid;
         }

         num_deps = me->fea_info[ii].num_deps;

         if (num_deps)
         {
           OM_BLOCK_MOVE(me->fea_info[ii].dep_grids,
                         &known_deps[total_known_deps],
                         num_deps * sizeof(struct GRid));
           total_known_deps += num_deps;
         }                         
       }

       /*Show dependent features*/
       gr$get_display_env(buffer = &disp_env);
       OM_stat = EFshow_parent_child_relationship(&EMmsg, 
                               me->fea_info[cur_fea].grid.objid,
                               me->fea_info[cur_fea].grid.osnum,
                               TRUE, &disp_env, GRhd, 
                               &me->fea_info[cur_fea].dep_grids,
                               &me->fea_info[cur_fea].num_deps,
                               NULL, 0, 
                               known_deps, total_known_deps,
                               me->fea_info[cur_fea].group_comp_grid.objid,
                               NULL);
       if (!(1 & OM_stat & EMmsg)) goto wrapup;

       if (me->fea_info[cur_fea].num_deps)
       {
#        if DEBUG
         int ii;
         fprintf(stderr, "dependent_cnt = %d\n", 
                 me->fea_info[cur_fea].num_deps);
         for(ii=0; ii<me->fea_info[cur_fea].num_deps; ii++) 
            fprintf(stderr, "dependent_grids[%d] = %d, %d\n", 
                    ii, 
                    me->fea_info[cur_fea].dep_grids[ii].objid,
                    me->fea_info[cur_fea].dep_grids[ii].osnum);
#        endif
       }
       else
       {
         /*No dependents found!!!*/
         me->state = GET_FEAS;
         break;
       }

       loc_key = EMS_P_AcDelHiDepFea;

       OM_stat = co$getevent(msg = &EMmsg,
                             event_mask = GRm_DATA | 
                                          GRm_BACK_UP | 
                                          GRm_RJT_MOVEON,
                             msgnum = loc_key,
                             response = response,
                             response_data = response_data,
                             event = &me->event);

       ex$message(msgnumb=EMS_S_ClearStatusField, field=KEYIN_FIELD);

       switch(me->event.response)
       {
         case EX_DATA:
         {
           EMS_locate_features = TRUE;
           for(ii=0; ii<me->fea_info[cur_fea].num_deps; ii++)
           {
             gr$display_object
                           (object_id = &me->fea_info[cur_fea].dep_grids[ii],
                            md_env = &me->fea_info[cur_fea].env,
                            mode = GRhhd);
           }
           EMS_locate_features = FALSE;

           me->state = GET_FEAS;
           break;
         }

         case EX_RJT_MOVEON:
         case EX_BACK_UP:
         {
           EMS_locate_features = TRUE;
           for(ii=0; ii<me->fea_info[cur_fea].num_deps; ii++)
           {
             gr$display_object
                           (object_id = &me->fea_info[cur_fea].dep_grids[ii],
                            md_env = &me->fea_info[cur_fea].env,
                            mode = GRhe);
           }
           
           if (me->fea_info[cur_fea].dep_grids)
           {
             om$dealloc(ptr = me->fea_info[cur_fea].dep_grids);
             me->fea_info[cur_fea].dep_grids = NULL;
             me->fea_info[cur_fea].num_deps = 0;
           }

           if (me->fea_info[cur_fea].group_comp_grid.objid == NULL_OBJID)
           {
             gr$display_object(object_id = &me->fea_info[cur_fea].grid,
                               md_env = &me->fea_info[cur_fea].env,
                               mode = GRhe);
           }
           else
           {
             gr$display_object(
                            object_id = &me->fea_info[cur_fea].group_comp_grid,
                            md_env = &me->fea_info[cur_fea].env,
                            mode = GRhe);
           }
           
           EMS_locate_features = FALSE;

           me->num_feas--;
           me->state = GET_FEAS;
           break;
         }

         default:
         {
           OM_stat = EMmsg = EMS_S_Success;
           goto wrapup;
         }
       }

       break;
     }


     case PROC_FEAS:
     {
       /*Do a pre-processing step here to determine if all group components
        * were located.  If so then just issue a delete instead of a partial
        * delete.
        */
       IGRuint            new_num_feas=0;
       struct EMSfea_info *new_fea_info=NULL;

       OM_stat = EFcheck_group_feas(&EMmsg, me->num_feas, me->fea_info,
                                    &new_num_feas, &new_fea_info);
       if (!(1 & OM_stat & EMmsg)) goto wrapup;

       if (new_num_feas)
       {
         /*EFcheck_group_feas freed the dep_grids on those it didnt move.*/
         OM_stat = om$vla_set_dimension(varray = me->fea_info,
                                        size = new_num_feas);
         if (!(1 & OM_stat)) goto wrapup;

         OM_BLOCK_MOVE(new_fea_info, 
                       me->fea_info, 
                       new_num_feas * sizeof(struct EMSfea_info));

         om$dealloc(ptr = new_fea_info);

         me->num_feas = new_num_feas;
       }
  
       for(ii=0; ii<me->num_feas; ii++)
       {
         if (me->fea_info[ii].group_comp_grid.objid == NULL_OBJID)
         {
           OM_stat = om$send(msg = message EMSdpr.EMdelete_feature(&EMmsg, 
                                   &me->fea_info[ii].env, 
                                   EMdel_fea_DELETE_AND_SAVE | 
                                   EMdel_fea_DELAY_UPDATE),
                             targetid = me->fea_info[ii].grid.objid,
                             targetos = me->fea_info[ii].grid.osnum);
           if (!(1 & OM_stat & EMmsg)) goto wrapup;                        
         }
         else
         {
           OM_stat = om$send(msg = 
                         message EMSdpr.EMpartial_delete_group_feature(&EMmsg, 
                                   &me->fea_info[ii].env, 
                                   me->fea_info[ii].group_comp_grid.objid,
                                   EMdel_fea_DELETE_AND_SAVE | 
                                   EMdel_fea_DELAY_UPDATE),
                             targetid = me->fea_info[ii].grid.objid,
                             targetos = me->fea_info[ii].grid.osnum);
           if (!(1 & OM_stat & EMmsg)) goto wrapup;                        
         }

         num_deps = me->fea_info[ii].num_deps;
         dep_grids = me->fea_info[ii].dep_grids;
 
         for(jj=0; jj<num_deps; jj++, dep_grids++)
         {
           OM_stat = om$send(msg = message EMSdpr.EMdelete_feature(
                                   &EMmsg,  
                                   &me->fea_info[ii].env, 
                                   EMdel_fea_DELETE_AND_SAVE |
                                   EMdel_fea_DELAY_UPDATE),
                             targetid = dep_grids->objid,
                             targetos = dep_grids->osnum);
           if (!(1 & OM_stat & EMmsg)) goto wrapup;                      
         }
       }

       nd$exec_batch();

       OM_stat = EFcmd_regen_autodim(&EMmsg, me->num_feas, me->fea_info,
                                     FALSE); 
       if (!(1 & OM_stat & EMmsg)) goto wrapup;

       feas_processed = TRUE;

       me->state = GET_FEAS;
       break;
     }


     default:
     {
       EMmsg = EMS_E_InvalidCase;
       goto wrapup;
     }
   } /*end state switch*/
 } while(TRUE);

wrapup:
  EMWRAPUP(EMmsg, OM_stat, "editfea.exec")
  if (!(1 & OM_stat & EMmsg)) *response = TERMINATE;
  dp$erase_hilite(msg = &EMmsg);
  return(OM_S_SUCCESS);
}
end implementation ECeditfea;

