class implementation ECmgsf;

/*

HISTORY

  October, 1991  : AMD :  Creation
  07/09/92       : AMD :  Added all eligibility checks. 
  08/14/94       : scw :  clarified sleep method
  05/04/97       :V.Srinivas: Extended the command to handle
                          tangential surfaces to unite.
  08/14/97       : Nilesh  Added the code to handle Uniting Tangential
                           surfaces.
  01/07/98       : Kiran   Modified code to give the error messages.

*/


#include "lcmacros.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "emsdef.h"
#include "OMminimum.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "EMSaction.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "emsplndef.h"
#include "dpmacros.h"
# include "msdef.h"
# include "msmacros.h"
# include "ECmsg.h"
# include "ECcmd.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSascmacros.h"

#define  ID_SURFACE   0
#define  MERGE_SURFACE   1

#define  INCREMENT       10

extern GRclassid     OPP_EMSsubbs_class_id,
		     OPP_EMSsurface_class_id;


from EMSsurface import EMgetactiveid, EMgetedges;
from EMSedge import EMgetsurface_info;
from GRgraphics import GRdisplay;

method init(int type; char *str_ptr)
{
 IGRlong sts;
 sts = OM_S_SUCCESS;

 me->num_surfs = 0;
 sts = om$vla_set_dimension(varray = me->surf_ids,
                            size = 10);

 sts = om$send(mode = OM_e_wrt_parent,
               msg = message ECmgsf.init(type, str_ptr),
               targetid = my_id);
 EMomerr_hndlr(sts, ret_end, "parent ECmgsf.init error");

 ret_end:
  return(sts);
}

method wakeup(int pos)
{
 IGRlong   sts, ret_msg;
 IGRint    i;
 enum   GRdpmode  dpmode;
 IGRboolean state;

 sts = OM_S_SUCCESS;
 
 gr$get_associative_flag( buffer = &state );
 if (state)
  {
    GRdisplay_associative_button(TRUE);
    me->associative = TRUE;
  }

 for (i=0; i<me->num_surfs; i++)
 { 
  dpmode = GRbdhd;
  sts = om$send( msg = message GRgraphics.GRdisplay( &ret_msg,
                 &me->ModuleInfo.md_env.matrix_type,
                 me->ModuleInfo.md_env.matrix, &dpmode,
                 &me->ModuleInfo.md_id),
           targetid = me->surf_ids[i].objid,
           targetos = me->surf_ids[i].osnum);
  EMomerr_hndlr ( sts, ret_end, "GRgraphics.GRdisplay");
 }
 
 ret_end:
  
  return (OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
  IGRlong msg;

  if (me->associative) GRdisplay_associative_button(FALSE);

  dp$erase_hilite(msg = &msg);

  ex$message (msgnumb = EMS_P_ClearPromptField);
  ex$message (msgnumb = EMS_I_ClearStatusField);
  ex$message (msgnumb = EM_M_ClearMessageField);

  return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
 OMuword                        rclass, eliclass;
 OM_S_CLASSLIST                 rtree_classes, elig_classes;
 struct          GRlc_locate    attributes;
 IGRlong                        sts, ret_msg, size, display_flag,
                                locate_mask, accept_mask;
 struct          GRevent        accept_event;
 IGRboolean                     stat_func;
 IGRchar                        locate_prompt[54],accept_prompt[54],
                                relocate_prompt[54];
 IGRint                         i, j, k;
 enum            GRdpmode       dpmode;
 struct     GRvg_construct      construct_list;
 extern                         IGRlong EFlocate_action_handler();
 struct                         EMSaction_handler was_located;

 extern IGRboolean EFcheck_nesting();
 extern IGRlong EFmerge_coincident_surfaces();
 
 ex$message ( msgnumb = EM_M_UniteSurfaces);

 ret_msg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 stat_func = TRUE;
  
  do
  {
   switch(me->state)
    {
      
     case ID_SURFACE:

       was_located.next = NULL;
       was_located.option = 0;
       was_located.type = 1;
       if (me->num_surfs)
        was_located.num_objects = me->num_surfs;
       else 
        was_located.num_objects = 0;
       was_located.objects.id = me->surf_ids;

      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
      accept_mask = GRm_DATA ;

      if (me->num_surfs)
       {
        if(me->num_surfs==1)
        {
         ex$message ( msgnumb = EMS_P_IdentifySurface2,
                      buff    = locate_prompt);
        }
        else
        {
         i = me->num_surfs + 1;
         ex$message ( msgnumb =  EMS_P_IdentPlanarSurface,
                      type    = "%d",
                      var     = `i`,
                      buff    = locate_prompt);
        }
       }
      else
       {
         ex$message ( msgnumb = EMS_P_IdentifySurface1,
                      buff    = locate_prompt);
       }

       ex$message ( msgnumb = EMS_P_AcceptWithNextSurfaceRj,
                    buff    = accept_prompt);
         
       ex$message ( msgnumb = EMS_P_ElementNotFound,
                    buff    = relocate_prompt);
 
       attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW ;
                              //   LC_PLANAR_ONLY;
       attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD |
                                 LC_OBJ_W_OWNER | 
                                 LC_RIGID_OWNER | 
                                 LC_REF_OBJECTS |
                                 LC_NO_REF_HEADER;
       strcpy(attributes.classes, "EMSsurface");
       display_flag = ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                      LC_ERASE_LOC_ELEMENT;
        
       rtree_classes.w_count = 1;
       elig_classes.w_count = 1;
       rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

       rclass   = OPP_EMSsubbs_class_id;
       eliclass = OPP_EMSsubbs_class_id;

       rtree_classes.p_classes = &rclass;
       elig_classes.p_classes = &eliclass;

       stat_func = lc$locate(rc = &ret_msg, 
                 event1 = &me->lc_event,
                 event2 = &accept_event,
                 mask1 = locate_mask,
                 mask2 = accept_mask,
                 eventsize= &size, 
                 display_flag = display_flag,
                 response = response, 
                 response_data = response_data, 
                 locate_prompt = locate_prompt, 
                 acc_prompt = accept_prompt,
                 relocate_prompt = relocate_prompt, 
                 attributes = &attributes,
                 act_handler = EFlocate_action_handler,
                 act_args = &was_located,  
                 stack = &me->lc_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);
       
       UI_echo(" ");

/*
        if (stat_func == FALSE)
          {
          UI_error ("Failure: Input processing...exiting");
           *response = TERMINATE; 
          goto ret_end;
          }
*/
      if (!ret_msg)
       {
        if (me->lc_event.response == EX_BACK_UP)
        {
         if(me->num_surfs)
         {
          dpmode = GRhe;
          sts = om$send( msg = message GRgraphics.GRdisplay( &ret_msg,
                         &me->ModuleInfo.md_env.matrix_type,
                         me->ModuleInfo.md_env.matrix, &dpmode,
                         &me->ModuleInfo.md_id),
                   targetid = me->surf_ids[me->num_surfs-1].objid,
                   targetos = me->surf_ids[me->num_surfs-1].osnum);
          EMomerr_hndlr ( sts, ret_end, "GRgraphics.GRdisplay");
          me->num_surfs--;
         }
         else
         { sts = OM_S_SUCCESS; goto ret_end; }
        }
       else if (me->lc_event.response == EX_RJT_MOVEON)
         {
          if (me->num_surfs <= 1)
	    { 
              ME.super_cmd->state = ID_SURFACE;
	      break;
	     }
          else
	    { 
              ME.super_cmd->state = MERGE_SURFACE;
	      break;
	     }
          }
       else
         return(OM_S_SUCCESS);
       }
       else
       {
        struct GRid  tempid, srf_ownr;
        OMuint  vla_size;


        tempid = accept_event.located_object[0].located_obj;
        me->ModuleInfo = accept_event.located_object[0].module_info;
 
        vla_size = om$dimension_of (varray = me->surf_ids);

         if ((me->num_surfs + 1)  > vla_size)
         {
            sts = om$vla_set_dimension (varray = me->surf_ids,
                                        size = vla_size + INCREMENT);
            EMomerr_hndlr ( sts, ret_end, "om$vla_set_dimension");
         }

       /* Check if this surface belongs to the same composite */
       {
        sts = om$send(msg = message EMSsurface.EMgetactiveid(&ret_msg,
                             &srf_ownr, NULL),
                     targetid = tempid.objid,
                     targetos = tempid.osnum);
        EMomerr_hndlr ( sts, ret_end, "EMSsurface.EMgetactiveid");

        if(!me->num_surfs)
         me->active_GRid = srf_ownr;
        else
         if ((me->active_GRid.objid != srf_ownr.objid) ||
            (me->active_GRid.osnum != srf_ownr.osnum))
         {
          ex$message ( msgnumb = EMS_S_SurfIsPartOfDiffComp);

          dpmode = GRhe;
          sts = om$send( msg = message GRgraphics.GRdisplay( &ret_msg,
                         &me->ModuleInfo.md_env.matrix_type,
                         me->ModuleInfo.md_env.matrix, &dpmode,
                         &me->ModuleInfo.md_id),
                   targetid = tempid.objid,
                   targetos = tempid.osnum);
          EMomerr_hndlr ( sts, ret_end, "GRgraphics.GRdisplay");        
          ME.super_cmd->state = ID_SURFACE;
          break;
         }
       }

       /* Check if this surface is coplanar */
       {
        struct EMStest_plan_group data;
        GRobjid *test_surfs[2];
        IGRboolean is_planar = FALSE,is_tangent=TRUE;
         GRobjid *tgt_surfs=NULL;
         IGRint   num_tgt_surfs,i;

        if(!me->num_surfs)
         {
          test_surfs[0]= &(tempid.objid);
          data.num_sfs = 1;
         }
        else
         {
          test_surfs[0] = &(me->surf_ids[0].objid);
          test_surfs[1] = &(tempid.objid);
          data.num_sfs = 2;
         }

        data.option = EMIndividual_Ids;
        data.data.sf_ids = test_surfs;
     
        sts = EMtest_planar(&ret_msg, &data, &me->ModuleInfo, 
                            &is_planar);




         
       /* check if the surfaces are tangent */
       /* V.Srinivas */

        if(me->num_surfs)
        {
         is_tangent = FALSE;
         EMget_tgt_surfaces(&ret_msg,me->surf_ids[0].objid ,
                              tempid.osnum,&tgt_surfs, &num_tgt_surfs,
                              &me->ModuleInfo.md_env.matrix_type,
                              me->ModuleInfo.md_env.matrix);
         EMomerr_hndlr ( ret_msg, ret_end, "EMget_tgt_surfaces");
       
         for(i=0; i<num_tgt_surfs; ++i)
             if(IF_EQ_OBJID ( tgt_surfs[i],tempid.objid))
                { is_tangent = TRUE; break; }
         }


        if (!is_planar && !is_tangent)
        {
         ex$message ( msgnumb = EMS_S_SurfIsNotCoplanar);
         dpmode = GRhe;
         sts = om$send( msg = message GRgraphics.GRdisplay( &ret_msg,
                        &me->ModuleInfo.md_env.matrix_type,
                        me->ModuleInfo.md_env.matrix, &dpmode,
                        &me->ModuleInfo.md_id),
                  targetid = tempid.objid,
                  targetos = tempid.osnum);
         EMomerr_hndlr ( sts, ret_end, "GRgraphics.GRdisplay");        
         ME.super_cmd->state = ID_SURFACE;
         break;
        } 

       }
       if(me->num_surfs)
       /* Check if the surface has edges common with other surfaces */
       {
        struct GRid            *sfedges = NULL;
        IGRint                 numed, array_size;
        OMuint                 edge_count=0;
        OM_S_CHANSELECT        to_common_edge;
        OM_S_OBJECT_LINKAGE    comm_edge;
        GRobjid                srfid;        
        IGRboolean             surf_in_buffer=FALSE;

        EMmake_chanselect( EMSedge_to_common_edge, &to_common_edge);

        numed = 0;
        sfedges = NULL;
        array_size = 0;
        sts = om$send ( msg = message EMSsurface.EMgetedges (&ret_msg,
                        EMS_OPT_NONDEG_NONSEAM, &sfedges, &array_size,
                        &numed, NULL, NULL, NULL, NULL),
                 targetid = tempid.objid,
                 targetos = tempid.osnum);
        EMomerr_hndlr ( sts, ret_end, "EMSsurface.EMgetedges");         

        for (j=0 ; j<numed; j++)
         {
          surf_in_buffer = FALSE;

          sts = om$get_channel_objects(
                objid = sfedges[j].objid,
                osnum = tempid.osnum,
                p_chanselect = &to_common_edge,
                list = &comm_edge,
                size = 1,
                count = &edge_count);
          EMomerr_hndlr ( sts, ret_end, "om$get_channel_objects");

          if(edge_count)
            {
             sts = om$send ( msg = message EMSedge.EMgetsurface_info
                           ( &ret_msg, &srfid, NULL),
                   targetid = comm_edge.S_objid,
                   targetos = tempid.osnum);
             EMomerr_hndlr ( sts, ret_end, "EMSedge.EMgetsurface_info"); 

             for(k=0; k<me->num_surfs; k++)
              if(IF_EQ_OBJID ( srfid, me->surf_ids[k].objid))
               { surf_in_buffer = TRUE; break;}

             if(surf_in_buffer) break;
            }
         }
 
         if(!surf_in_buffer)
         {
          ex$message ( msgnumb = EMS_S_NoCommonEdgeExists);

          dpmode = GRhe;
          sts = om$send( msg = message GRgraphics.GRdisplay( &ret_msg,
                         &me->ModuleInfo.md_env.matrix_type,
                         me->ModuleInfo.md_env.matrix, &dpmode,
                         &me->ModuleInfo.md_id),
                   targetid = tempid.objid,
                   targetos = tempid.osnum);
          EMomerr_hndlr ( sts, ret_end, "GRgraphics.GRdisplay");        

          ME.super_cmd->state = ID_SURFACE;
          break;
         }

        if (sfedges) om$dealloc (ptr = sfedges);

       }
       
       /* The surface has passed all the tests */

       me->surf_ids[me->num_surfs] = tempid;
       me->num_surfs++;


       size = sizeof(accept_event.event) + sizeof (IGRint); 
       sts = ex$putque(msg = &ret_msg, response = response,
                byte = &size, buffer = (char *)&accept_event.event);
       EMomerr_hndlr ( sts, ret_end, "ex$putque error");
      }
      
    break;


  case MERGE_SURFACE:

    {
     struct GRid   result;     

     ex$message ( msgnumb = EMS_S_ProcessingFour);

     construct_list.msg = &ret_msg;
     construct_list.env_info = &me->ModuleInfo,
     construct_list.newflag = FALSE;
     construct_list.geometry = NULL;
     construct_list.class_attr = NULL;
     construct_list.level = me->ActiveLevel;
     construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
     construct_list.display = &me->ActiveDisplay;
     construct_list.name = NULL;

     /* construct the relevant dpr object */

     result.objid = NULL_OBJID;
/**************************************************************************
     sts = EFmerge_coincident_surfaces( &ret_msg, construct_list,
           me->active_GRid, me->num_surfs, me->surf_ids, &result);
**************************************************************************/
     sts = ems$merge_coincident_surfaces(msg = &ret_msg,
                               construction_list = construct_list,
                               active_GRid = me->active_GRid,
                               num_surfaces = me->num_surfs,
                                   surfaces = me->surf_ids,
                                   resultant_obj = &result);
     EMomerr_hndlr ( sts, ret_end, "EFmerge_coincident_surfs");

     ex$message ( msgnumb = EMS_S_ClearStatusField);

    me->num_surfs = 0;
    ME.super_cmd->state = ID_SURFACE; 
    break;        
   } /* case DELETE_LOOPS */

   default:
       goto ret_end;

   }

  } while(TRUE);

ret_end:

   if(!(1&sts)) {
                 *response = TERMINATE;
                 ex$message ( msgnumb = EMS_E_OperationFailed);
                 sleep(2);
                 sts = OM_S_SUCCESS;
                }

   return(sts);
}


end implementation ECmgsf;
