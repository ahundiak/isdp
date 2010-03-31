class implementation ECdelbnd;

/* 

HISTORY

 August, 1991  :  AMD  :  Creation
 02/13/92      :  AMD  :  If all the loops selected belong to the same
                          loopset then blow away the topology but let
                          the natural surface remain.
 05/19/92      :  AMD  :  Message subsystem compliance
 08/14/94      :  scw  :  Intel Solaris port
*/

#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
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
#include "dpmacros.h"
#include "msmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSascmacros.h"

#define  IDENTIFY_LOOP   0
#define  DELETE_LOOPS    1

#define  INCREMENT       10

extern GRclassid    OPP_EMSloopset_class_id,
                    OPP_EMSsurface_class_id,
                    OPP_EMSloop_class_id,
		    OPP_EMSsolid_class_id,
                    OPP_EMSgraloop_class_id, 
		    OPP_EMSsfrembnd_class_id,
		    OPP_EMSslrembnd_class_id;

from EMSedge import EMdisplay;
from EMSsfrembnd  import EMremove_boundaries;
from EMSboundary import EMgetsurface_info;
from EMSsurface import  EMgetactiveid;
from EMSloop    import  EMget_loops;
from GRowner    import  GRget_number_components;
from EMSsubbs   import  EMdelete_boundary;
from EMSdpr     import  EMmake_primitive1;

method init(int type; char *str_ptr)
{
 IGRlong sts;
 sts = OM_S_SUCCESS;

 me->num_loops = 0;
 sts = om$vla_set_dimension(varray = me->loop_ids,
                            size = 10);
 return(sts);
}

method wakeup(int pos)
{
 IGRlong   sts, ret_msg;
 IGRint    i;
 enum   GRdpmode  DisplayMode;
 IGRshort         disp_flag;
 OM_S_CHANSELECT  loop_to_edges;
 IGRboolean       state;

 EMmake_chanselect( EMSbd_owner_to_comps, &loop_to_edges);

 sts = OM_S_SUCCESS;
 
 gr$get_associative_flag( buffer = &state );
 if (state)
  {
    GRdisplay_associative_button(TRUE);
    me->associative = TRUE;
  }

 for (i=0; i<me->num_loops; i++)
  {
   DisplayMode = GRbdhd;
   disp_flag = EMS_WHL_EDGE;
   sts = om$send (msg = message EMSedge.EMdisplay( &ret_msg,
                       NULL, &me->module_info.md_env.matrix_type,
                       me->module_info.md_env.matrix, &DisplayMode, 
                       NULL, disp_flag, NULL), 
                 p_chanselect = &loop_to_edges,
          senderid = me->loop_ids[i].objid,
          targetos = me->loop_ids[i].osnum);
   EMomerr_hndlr ( sts, ret_end, "EMSedge.EMdisplay");
   }
 
 ret_end:
  
  return (OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
  IGRlong msg=EMS_S_Success;

  if (me->associative) GRdisplay_associative_button(FALSE);

  dp$erase_hilite(msg = &msg);

  ex$message (msgnumb = EM_M_ClearMessageField);
  ex$message (msgnumb = EMS_S_ClearStatusField);
  ex$message (msgnumb = EMS_P_ClearPromptField);

  return(OM_S_SUCCESS);
}

 
method execute( int *response; char *response_data; int pos )
{
 OMuword                        rclass, eliclass, owner_classid;
 OM_S_CLASSLIST                 rtree_classes, elig_classes;
 struct          GRlc_locate    attributes;
 IGRlong                        sts, ret_msg, size, display_flag,
                                locate_mask, accept_mask;
 struct          GRevent        accept_event;
 IGRboolean                     stat_func, InList,
				loop_locatable, edge_locatable,
 				outter_and_alone;
 IGRchar                        locate_prompt[54],accept_prompt[54],
                                relocate_prompt[54];
 IGRint                         i, num_components;
 enum            GRdpmode       DisplayMode;
 IGRshort                       disp_flag;
 struct     GRvg_construct      construct_list;
 extern                         IGRlong EFlocate_action_handler();
 struct                         EMSaction_handler was_located;
 OM_S_CHANSELECT                loop_to_edges;
 struct  GRid                   result, newid;
 GRobjid                        srfid;

 extern IGRboolean EFcheck_nesting();
 extern IGRboolean EFloop_curves_locatable();
 extern IGRboolean EFedge_curves_locatable();
 extern IGRlong    EFcheck_loop_position();

 ex$message(msgnumb = EM_M_DeleteSurfaceBoundary);

 sts = OM_S_SUCCESS;
 stat_func = TRUE;

 loop_locatable = EFloop_curves_locatable();
 edge_locatable = EFedge_curves_locatable();

 if(!loop_locatable)
   EFset_locate_eligibility(&ret_msg,1,"EMSloop");
 if(edge_locatable)
   EFset_locate_eligibility(&ret_msg,0,"EMSedge");

 EMmake_chanselect( EMSbd_owner_to_comps, &loop_to_edges);

  do
  {
   switch(me->state)
    {
      
     case IDENTIFY_LOOP:

       ret_msg = EMS_S_Success;
       was_located.next = NULL;
       was_located.option = LOCATE_LOOP;
       was_located.type = 1;
       if (me->num_loops)
        was_located.num_objects = me->num_loops;
       else 
        was_located.num_objects = 0;
       was_located.objects.id = me->loop_ids;

      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
      accept_mask = GRm_DATA ;

      if (me->num_loops)
       {
        i = me->num_loops + 1;
        ex$message ( msgnumb = EMS_P_IdentBound,
                     type    = "%d",
                     var     = `i`,
                     buff    = locate_prompt)
       }
      else
       {
        ex$message ( msgnumb = EMS_P_IdentBound1,
                     buff    = locate_prompt)
       }
    
       attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                 LC_PLANAR_NON_PLANAR;
       attributes.owner_action = LC_RIGID_COMP  |
                                 LC_OBJ_W_OWNER | 
                                 LC_REF_OBJECTS |
                                 LC_NO_REF_HEADER | LC_LOCALMOD;
       strcpy(attributes.classes, "EMSsurface");
       display_flag = ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                      LC_ERASE_LOC_ELEMENT;
        
       rtree_classes.w_count = 1;
       elig_classes.w_count = 1;
       rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

       rclass = OPP_EMSsurface_class_id;
       eliclass = OPP_EMSloop_class_id;

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
                 acc_key = EMS_P_AccWtNextBoundary,
                 relocate_key = EMS_P_BoundaryNotFound, 
                 attributes = &attributes,
                 act_handler = EFlocate_action_handler,
                 act_args = &was_located,  
                 stack = &me->lc_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);
       

      if (!ret_msg)
       {
        if (me->lc_event.response == EX_BACK_UP)
         {
          if (me->num_loops)
           {
            DisplayMode = GRbdhe;
            disp_flag = EMS_WHL_EDGE;
            sts = om$send (msg = message EMSedge.EMdisplay( &ret_msg,
                       NULL, &me->module_info.md_env.matrix_type,
                       me->module_info.md_env.matrix, &DisplayMode, 
                       NULL, disp_flag, NULL), 
                 p_chanselect = &loop_to_edges,
              senderid = me->loop_ids[me->num_loops - 1].objid,
 	      targetos = me->loop_ids[me->num_loops - 1].osnum);
            EMomerr_hndlr ( sts, ret_end, "EMSedge.EMdisplay");
            me->num_loops--;

           /* highlight display all other loops */
           for (i=0; i<me->num_loops; i++)
           {
            DisplayMode = GRbdhd;
            disp_flag = EMS_WHL_EDGE;
            sts = om$send (msg = message EMSedge.EMdisplay( &ret_msg,
                       NULL, &me->module_info.md_env.matrix_type,
                       me->module_info.md_env.matrix, &DisplayMode, 
                       NULL, disp_flag, NULL), 
                 p_chanselect = &loop_to_edges,
              senderid = me->loop_ids[i].objid,
 	      targetos = me->loop_ids[i].osnum);
            EMomerr_hndlr ( sts, ret_end, "EMSedge.EMdisplay");
            }
           } 
          else
           {sts = OM_S_SUCCESS; goto ret_end ;}
         }
        else if (me->lc_event.response == EX_RJT_MOVEON)
         {
          if (me->num_loops)
	    { 
              ME.super_cmd->state = DELETE_LOOPS;
	      break;
	     }
          }
        else
           {sts = OM_S_SUCCESS; goto ret_end ;}
       }
      else
       {
        struct GRid  tempid, srf_ownr;
        GRclassid    classid;
        OMuint  vla_size;

        tempid = accept_event.located_object[0].located_obj;
        me->module_info = accept_event.located_object[0].module_info;

        /* Check to see if this is a graphics loop */
        sts = om$get_classid ( objid = tempid.objid,
                               osnum = tempid.osnum,  
                               p_classid = &classid);

        sts = om$is_ancestry_valid( subclassid = classid, 
                  superclassid = OPP_EMSgraloop_class_id);
  
        if ( sts == OM_S_SUCCESS)/* Is a graphics Loop !!*/
         {
            ex$message(msgnumb = EMS_S_InvalidLoop);
            DisplayMode = GRhe ;
            disp_flag = EMS_WHL_EDGE;
            sts = om$send (msg = message EMSedge.EMdisplay( &ret_msg,
                       NULL, &me->module_info.md_env.matrix_type,
                       me->module_info.md_env.matrix, &DisplayMode, 
                       NULL, disp_flag, NULL), 
                 p_chanselect = &loop_to_edges,
              senderid = tempid.objid,
 	      targetos = tempid.osnum);
            EMomerr_hndlr ( sts, ret_end, "EMSedge.EMdisplay");

            ME.super_cmd->state = IDENTIFY_LOOP;
            break;
         }

        /* Check to see if the loop belongs to the same composite */
        sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                            (&ret_msg, &srfid, NULL),
                           targetid = tempid.objid,
                           targetos = tempid.osnum );
        EMomerr_hndlr ( sts, ret_end, "EMSboundary.EMgetsurface_info");

        sts = om$send(msg = message EMSsurface.EMgetactiveid(&ret_msg,
                              &srf_ownr, NULL),
                        targetid = srfid,
                        targetos = tempid.osnum);
        EMomerr_hndlr ( sts, ret_end, "EMSsurface.EMgetactiveid");

        if(!me->num_loops)
         me->active_GRid = srf_ownr;
        else
         if ((me->active_GRid.objid != srf_ownr.objid) ||
            (me->active_GRid.osnum != srf_ownr.osnum))
         {
          /*Nupe.*/
            ex$message ( msgnumb = EMS_S_BoundaryDiffComposite);
            DisplayMode = GRhe ;
            disp_flag = EMS_WHL_EDGE;
            sts = om$send (msg = message EMSedge.EMdisplay( &ret_msg,
                       NULL, &me->module_info.md_env.matrix_type,
                       me->module_info.md_env.matrix, &DisplayMode, 
                       NULL, disp_flag, NULL), 
                 p_chanselect = &loop_to_edges,
              senderid = tempid.objid,
 	      targetos = tempid.osnum);
            EMomerr_hndlr ( sts, ret_end, "EMSedge.EMdisplay");

            ME.super_cmd->state = IDENTIFY_LOOP;
            break;
         }

         /* Check if this loop is owned by loops already in list */

         InList = FALSE;

         if(me->num_loops)
          InList = EFcheck_nesting( &ret_msg, me->num_loops, me->loop_ids,
		                   tempid);
	 if (InList)
	  {
           ex$message(msgnumb = EMS_S_BoundaryPrevSelected );
           DisplayMode = GRhe ;
           disp_flag = EMS_WHL_EDGE;
           sts = om$send (msg = message EMSedge.EMdisplay( &ret_msg,
                       NULL, &me->module_info.md_env.matrix_type,
                       me->module_info.md_env.matrix, &DisplayMode, 
                       NULL, disp_flag, NULL), 
                 p_chanselect = &loop_to_edges,
              senderid = tempid.objid,
 	      targetos = tempid.osnum);
           EMomerr_hndlr ( sts, ret_end, "EMSedge.EMdisplay");

           ME.super_cmd->state = IDENTIFY_LOOP;
	   break;
	  }

         sts = om$get_classid ( objid = srfid,
				osnum = tempid.osnum,
                                p_classid = &owner_classid);
         EMomerr_hndlr ( sts, ret_end, "om$get_classid");

         sts = om$is_ancestry_valid( subclassid = owner_classid,
				     superclassid = OPP_EMSsolid_class_id);
         if(!(1&sts)) goto ret_end;
        
   	 if (sts == OM_S_SUCCESS)
             me->got_solid = TRUE;
         else
             me->got_solid = FALSE;

         /*
          * Check if enough space is available to save
          * the located boundary.
          */

         vla_size = om$dimension_of (varray = me->loop_ids);

         if ((me->num_loops + 1)  > vla_size)
         {
            sts = om$vla_set_dimension (varray = me->loop_ids,
                                        size = vla_size + INCREMENT);
            EMomerr_hndlr ( sts, ret_end, "om$vla_set_dimension");
         }

       me->loop_ids[me->num_loops] = tempid;
       me->num_loops++;

       /* Check for single surface state */
       if ( me->active_GRid.objid == srfid )
       {
        EFcheck_loop_position (&ret_msg, tempid.objid, tempid.osnum, 
				&outter_and_alone);
        if(outter_and_alone)
         {
          /* Blow away the loopset but let the surface remain. This
          functionality is as before */

          ex$message (msgnumb = EMS_S_TreeCompressed);

          sts = om$send (msg = message EMSsubbs.EMdelete_boundary
                   ( &ret_msg, &me->module_info, 
                     &me->module_info.md_id, NULL),
                targetid = srfid,
                targetos = tempid.osnum);
          EMomerr_hndlr ( sts, ret_end, "EMSsubbs.EMdelete_boundary");

          me->num_loops = 0;
          ME.super_cmd->state = IDENTIFY_LOOP;
	  break;
         }
       }
       else
       {
        num_components = 0;
        sts = om$send(msg = message GRowner.GRget_number_components
 			   (&ret_msg, &num_components),
             targetid = me->active_GRid.objid,
	     targetos = me->active_GRid.osnum);
        EMomerr_hndlr ( sts, ret_end, "GRget_number_components");
       }

       if (num_components==1) /* eg: impose boundary state */
       {
        EFcheck_loop_position (&ret_msg, tempid.objid, tempid.osnum, 
				&outter_and_alone);
        if(outter_and_alone)
         {
          /* Blow away the loopset but let the surface remain. This
          functionality is as before */

          ex$message (msgnumb = EMS_S_TreeCompressed);
          sts = om$send (msg = message EMSsubbs.EMdelete_boundary
                   ( &ret_msg, &me->module_info, 
                     &me->module_info.md_id, NULL),
                targetid = srfid,
                targetos = tempid.osnum);
          EMomerr_hndlr ( sts, ret_end, "EMSsubbs.EMdelete_boundary");

          /* Compress the tree only if it is not a single surface
             state */
          if ( me->active_GRid.objid != srfid )
          {
           sts = om$send (msg = message EMSdpr.EMmake_primitive1
                   ( &ret_msg, &me->module_info, &newid),
                targetid = me->active_GRid.objid,
                targetos = me->active_GRid.osnum);
           EMomerr_hndlr ( sts, ret_end, "EMSdpr.EMmake_primitive1");
          }

          me->num_loops = 0;
          ME.super_cmd->state = IDENTIFY_LOOP;
	  break;
         }
       }
       /* else many surfaces are picked including the last one */
       else if (me->num_loops == num_components) 
       {
        EFcheck_loop_position (&ret_msg, tempid.objid, tempid.osnum, 
				&outter_and_alone);
        if(outter_and_alone)
         {
          ex$message (msgnumb = EMS_S_LastSurfaceNotDeleted);
          DisplayMode = GRhe ;
          disp_flag = EMS_WHL_EDGE;
          sts = om$send (msg = message EMSedge.EMdisplay( &ret_msg,
                       NULL, &me->module_info.md_env.matrix_type,
                       me->module_info.md_env.matrix, &DisplayMode, 
                       NULL, disp_flag, NULL), 
                 p_chanselect = &loop_to_edges,
              senderid = tempid.objid,
 	      targetos = tempid.osnum);
          EMomerr_hndlr ( sts, ret_end, "EMSedge.EMdisplay");

          me->num_loops--;
          ME.super_cmd->state = IDENTIFY_LOOP;
	  break;
         }
       }


       size = sizeof(accept_event.event) + sizeof (IGRint); 
       sts = ex$putque(msg = &ret_msg, response = response,
                       byte = &size, buffer = (IGRchar *)&accept_event.event);
       EMomerr_hndlr ( sts, ret_end, "ex$putque error");
     }
      
     break;

   case DELETE_LOOPS:
    {
     GRobjid   *loops, loopset;
     IGRboolean delete_loopset=TRUE;
     OM_S_CHANSELECT to_loopset, to_surfs, to_loops;
     OM_S_OBJECT_LINKAGE ls_list;
     OMuint count, loop_count;
     IGRint i;
     GRclassid classid;
     
     loops = (GRobjid *)om$malloc(size=me->num_loops * sizeof(GRobjid));
     
     for (i=0; i<me->num_loops; i++)
       loops[i] = me->loop_ids[i].objid;

     if(me->num_loops > 1)
      /* If all the loops selected are owned by a single loopset then
         blow the topology but let the surface remain */
      {
        sts = EMmake_chanselect(EMSloop_to_outter, &to_loopset);

        for (i=0; i<me->num_loops; i++)
         {
          sts = om$get_channel_objects(
               osnum = me->module_info.md_id.osnum,
               objid = loops[i],
               p_chanselect = &to_loopset,
               list = &ls_list,
               size = 1,
               count= &count);
     
          sts = om$get_classid( objid = ls_list.S_objid,
                           osnum = me->module_info.md_id.osnum,
                           p_classid = &classid);

          if (classid != OPP_EMSloopset_class_id)     
              { delete_loopset = FALSE; break; }
          if(i==0) loopset = ls_list.S_objid;
          if ( ls_list.S_objid != loopset ){delete_loopset = FALSE; break; }
         }

       sts = EMmake_chanselect( EMSloopset_to_loops, &to_loops);

       sts = om$get_channel_count (objid = loopset,
                                   osnum = me->module_info.md_id.osnum,
                                   p_chanselect = &to_loops,
                                   count = &loop_count);

       if(me->num_loops != loop_count) delete_loopset = FALSE;  

       if(delete_loopset)
        {
          /* now compress the tree */
          sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                               (&ret_msg, &srfid, NULL),
                           targetid = loops[0],
                           targetos = me->module_info.md_id.osnum );
          EMomerr_hndlr ( sts, ret_end, "EMSboundary.EMgetsurface_info");
    

          sts = om$send (msg = message EMSsubbs.EMdelete_boundary
                     ( &ret_msg, &me->module_info, 
                     &me->module_info.md_id, NULL),
               targetid = srfid,
               targetos = me->module_info.md_id.osnum);
          EMomerr_hndlr ( sts, ret_end, "EMSsubbs.EMdelete_boundary");

          if ( me->active_GRid.objid != srfid )
           {
            sts = om$send (msg = message EMSdpr.EMmake_primitive1
                   ( &ret_msg, &me->module_info, &newid),
                targetid = me->active_GRid.objid,
                targetos = me->active_GRid.osnum);
            EMomerr_hndlr ( sts, ret_end, "EMSdpr.EMmake_primitive1");
           }

          me->num_loops = 0;
          ME.super_cmd->state = IDENTIFY_LOOP;
          break;
        }

     }  /* if (me->num_loops > 1) */
    
    /*  Construct the dpr object */
     sts = om$construct( classid = (me->got_solid ? 
  			      OPP_EMSslrembnd_class_id :
 			      OPP_EMSsfrembnd_class_id),
                         p_objid = &me->delete_dprid,
                         osnum   = me->module_info.md_id.osnum);
     EMomerr_hndlr ( sts, ret_end, "om$construct error");
      
     construct_list.msg = &ret_msg;
     construct_list.env_info = &me->module_info,
     construct_list.newflag = FALSE;
     construct_list.geometry = NULL;
     construct_list.class_attr = NULL;
     construct_list.level = ME.COconst->ActiveLevel;
     construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
     construct_list.display = &ME.COconst->ActiveDisplay;
     construct_list.name = NULL;

     /* make the loops associative */

     result.objid = NULL_OBJID;
/****************************************************************************
     sts = EFremove_boundaries( &ret_msg, construct_list, me->active_GRid,
                                me->num_loops, me->loop_ids, &result );
****************************************************************************/
     sts = ems$remove_boundaries(msg = &ret_msg,
                     construction_list = construct_list,
                      active_GRid = me->active_GRid,
                      num_loops = me->num_loops,
                          loops = me->loop_ids,
                       resultant_obj = &result );
/*
     sts = om$send (msg = message EMSsfrembnd.EMremove_boundaries( &ret_msg,
                          me->module_info.md_env.matrix_type,
                          me->module_info.md_env.matrix,
                          construct_list,
		          me->active_GRid,
                          me->num_loops, 
                          loops),
              targetid = me->delete_dprid,
              targetos = me->module_info.md_id.osnum);
*/
    if(!(1&sts))    if(loops) om$dealloc (ptr=loops);
    EMomerr_hndlr ( sts, ret_end, "EMSsfrembnd.EMremove_boundaries");

    if(loops) om$dealloc (ptr=loops);
    me->num_loops = 0;
    ME.super_cmd->state = IDENTIFY_LOOP; 
    break;        
   } /* case DELETE_LOOPS */

   default:
       goto ret_end;

   }

  } while(TRUE);

 ret_end:

   if(!loop_locatable)
     EFset_locate_eligibility(&ret_msg,0,"EMSloop");
   if(edge_locatable)
     EFset_locate_eligibility(&ret_msg,1,"EMSedge");

   if(!(1&sts)) *response = TERMINATE;
   return( sts );

}


IGRboolean EFcheck_nesting ( EMmsg, num_loops, loops, test_loop)

IGRlong          *EMmsg;
IGRint           num_loops;
struct  GRid     *loops;
struct  GRid     test_loop;
{

 IGRlong    sts, rc;
 IGRint     depth, buffer_size, count, i, j;
 GRobjid    *inner_loops;
 IGRushort  *props=NULL ;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 depth = MAXINT;

 for ( i=0; i<num_loops; i++)
  {
   inner_loops = NULL;
   buffer_size = 0;
   count = 0;
   props = NULL;
 
   sts = om$send( msg = message EMSloop.EMget_loops( &rc,
                  EMS_OPT_UNSPLIT, &depth, &inner_loops, &props,
                  &buffer_size, &count),
           targetid = loops[i].objid,
           targetos = loops[i].osnum,
           senderid = NULL_OBJID);
   EMomerr_hndlr (sts, ret_end, "EMSloop.EMget_loops");

   for (j=0; j<count; j++)
    {
     if (IF_EQ_OBJID( test_loop.objid, inner_loops[j]))
        {
   /* fix for mlk */
        if (props) om$dealloc(ptr=props);
        props = NULL;
        if (inner_loops) om$dealloc(ptr=inner_loops);
        inner_loops = NULL;
        return (TRUE);
        }
     }

  }

ret_end:
 if (inner_loops) om$dealloc(ptr=inner_loops);
/* fix for mlk */
 if (props) om$dealloc(ptr=props);

 return(FALSE);
}

end implementation ECdelbnd;
