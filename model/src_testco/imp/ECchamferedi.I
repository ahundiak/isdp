/* ###################   APOGEE COMPILED   ################## */
/* 
Description

Return values
   Returns an OM_S_SUCCESS  if successful and returns an OM_E_ABORT
   if it fails. 

History

scw      08/14/94       clarified sleep method
Tapadia  11/25/92 	This was earlier merged with ECroundi.I. Moved to a 
			separate file as the interface for round edge/vertex is
			completely changed. Also removed the support of Z 
			command.
*/

class implementation ECchamfered;

#include <stdio.h>
#include "emsdef.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "codef.h"
#include "ECdlb.h"
#include "lcmacros.h"
#include "EMSlmdef.h"
#include "EMSbnddef.h"
#include "EMSmsgdef.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "EMSaction.h"
#include "griomacros.h"
#include "OMprimitives.h"
#include "emserr.h"
#include "DIdef.h"
#include "EMSdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSasmacros.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasdef.h"
#include "EMSasopts.h"
#include "EMSprop.h"
#include "EC_P.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_E.h"
#include "EC_S.h"
#include "msdef.h"
#include "msmacros.h"

#define DEBUG 0  /*Set to 1 if want error strings printed.*/

#define INIT     0
#define UNIFORM  1
#define ID_EDG   2
#define GET_VAL  3
#define ROUND    4
#define UNDO     5

from GRgraphics  import GRdisplay,
                        GRdelete;
from GRvg        import GRgetsize, GRgetgeom, GRgetsymb, GRputsymb
                        ;
from EMSsurface  import EMgetactiveid, EMlmround, EMshow_normals, 
                        EMrevorient,EMlmnewround;
from EMSsubbs    import EMget_edges;
from EMSdpr      import EMdeactivate, EMundo;
from EMSsfdpr    import EMadd;
from EMSboundary import EMgetsurface_info;
from EMSedge     import EMdisplay, EMxyz_endpt;

#define CHAMEDGE 	2
#define CHAMVERT 	3

#define ARRAY_INC 10

extern OMuword OPP_EMSsubbs_class_id, 
               OPP_EMSsolid_class_id,
               OPP_EMSsfboolean_class_id;

method wakeup(int pos)
{
    IGRboolean    state;

    gr$get_associative_flag( buffer = &state );
    if (state) {
    	GRdisplay_associative_button(TRUE);
    	me->associative = TRUE;
    }

    if(ME.super_cmd->state != UNDO)
     	return(om$send(mode = OM_e_wrt_parent,
                 msg = message ECchamfered.wakeup(pos),
                 targetid = my_id));

    if(me->form_displayed == TRUE)
	FIf_display(ME.ECsfedloc->form);

    return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
    if (me->associative) GRdisplay_associative_button(FALSE);
    if(me->form_displayed == TRUE)
	FIf_erase(ME.ECsfedloc->form);

    return(om$send(mode = OM_e_wrt_parent,
                 msg = message ECchamfered.sleep(pos),
                 targetid = my_id));
}

method execute( int *response; char *response_data; int pos )
{
 IGRushort 	    local_options;
 IGRlong            OM_stat;
 IGRint             i, mytype;
 IGRlong            msg, msg_loc; 
 IGRuint	    previous_rnd_edge_code;
 struct GRvg_construct construct_list;
 OMuword            osnum;
 IGRshort           operation_type;
 IGRboolean         EFisAncestryValid();
 extern IGRlong     EFlocate_action_handler();
 IGRlong            stat_func;
 IGRchar            prompt_string[MAX_CHAR];
 struct EMSrnd_boundary_input   *rnd_edges;
 struct EMSround_error          *round_error;

 IGRpoint           edge_ends[2];

 
 OM_stat = OM_S_SUCCESS;
 mytype = ME.super_cmd->mytype;
 osnum = me->ModuleInfo.md_id.osnum;
 round_error = NULL;

 switch(mytype)
 {
   case CHAMEDGE:
     ex$message(msgnumb = EM_M_ChmfEdg); 
     operation_type = EMS_CHAMFER_OPR;
     break;
   case CHAMVERT:
     ex$message(msgnumb = EM_M_ChmfVtx);
     operation_type = EMS_CHAMFER_OPR;
     break;
   default:
     ERROR(OM_E_ABORT, EMS_E_Fail, "invalid mytype", wrapup);      
 }

 do
  {
   switch( ME.super_cmd->state)
   {
    case INIT:
     {
      OM_stat = OM_S_SUCCESS;
      me->uniformval = -1;      /*Set to non uniform. */
      me->event.response = NULL;
      ME.super_cmd->state = UNIFORM;
      }
      break;   

    case UNIFORM:
     {
       ex$message(msgnumb = EMS_P_EntUnfmStbckMvOn); 

      stat_func = ems$getevent (
        msg = &msg,
        event_mask = GRm_VALUE | GRm_RJT_MOVEON ,
        value_type = GRIO_DISTANCE,
        response = (long *)response,
        response_data = response_data,
        event = &me->event);

      ex$message(msgnumb = EMS_P_ClearPromptField);
      if (stat_func == FALSE)
       {
        ex$message(msgnumb = EMS_E_FailInputProcExit);
        *response = TERMINATE;
        goto wrapup;
       }
      if (msg == GRw_no_value)
       {
        ex$message(msgnumb = EMS_I_00006);
        goto wrapup;
       }
      if (msg != MSSUCC)
        goto wrapup;
  
      switch(me->event.response)
       {
        case EX_VALUE:
         if (me->event.event.value <= 0)
          {
           ex$message(msgnumb = EMS_S_DistMustBeGrtThanZero);
           ME.super_cmd->state = UNIFORM;
           break;
           } 
          me->uniformval = me->event.event.value;
          me->uniformval_event = me->event; /**.event.value;**/
          ME.super_cmd->state = ID_EDG;
          break;
        case EX_RJT_MOVEON:
          me->uniformval = -1;
          ME.super_cmd->state = ID_EDG;
          break;
        default:
           goto wrapup;
       }
     break;
    }
     
    case ID_EDG:
    {
     char (*funcptr)()=NULL ;
     ex$message(msgnumb = EMS_P_StBckDist, buff = prompt_string);
     if (mytype == CHAMEDGE)
       OM_stat = om$send(mode = OM_e_wrt_message,
                       msg = message ECchamfered.locate_edge( &msg_loc, 
                             response, response_data, prompt_string, 
                             funcptr
                             ),
                   targetid = my_id);
     else
       OM_stat = om$send(mode = OM_e_wrt_message,
                       msg = message ECchamfered.locate_vertex( &msg_loc, 
                             response, response_data, prompt_string, 
                             funcptr
                             ),
                   targetid = my_id);
     EMomerr_hndlr(OM_stat, wrapup, "parent ECchamfered.ECsfedloc error");
     if(msg_loc == EMS_I_Interrupt) goto wrapup;
     if(me->event.response == EX_BACK_UP) {
          ME.super_cmd->state = INIT; 
          break;
        }

     osnum = ME.COroot->ModuleInfo.md_id.osnum;

     if(me->uniformval!=-1) {
        OM_stat = om$vla_set_dimension(varray = me->edgeval_event,
                                       size = me->numed + 2) ;
        EMomerr_hndlr(OM_stat, wrapup, "om$vla_set_dimension error");

        for ( i=0; i<me->numed; i++ ) {
          me->edgeval_event[i] = me->uniformval_event;
         }
       }
       ME.super_cmd->state = ROUND;
       break;
     }

   case ROUND:
   {
      ex$message(msgnumb = EMS_P_ClearPromptField);
      ex$message(msgnumb = EMS_I_00003);

      dp$erase_hilite(msg = &msg);

      construct_list.msg = &msg;
      construct_list.env_info = &ME.COroot->ModuleInfo;
      construct_list.newflag = FALSE;
      construct_list.level = ME.COconst->ActiveLevel;
      construct_list.properties = GRIS_DISPLAYABLE | 
                                  GRIS_NEW |
                                  GRIS_LOCATABLE;
      construct_list.geometry = NULL;
      construct_list.display = &ME.COconst->ActiveDisplay;
      construct_list.class_attr = NULL;
      construct_list.name = NULL;

      {
        IGRint ii, num_vals;
        struct EMSvalue_info *edge_vals=NULL;
        IGRushort rnd_opts;
        extern IGRboolean IGEstop();
        extern int ems_do_print_error_messages;

        /*Uniform edge vals?*/
        num_vals = (me->uniformval != -1) ? 1 : me->numed;

        edge_vals = (struct EMSvalue_info *) 
                    alloca(num_vals * sizeof(struct EMSvalue_info));
        if (!edge_vals)
         ERROR(OM_E_ABORT, EMS_E_NoStackMemory, "val_info", wrapup);

        for(ii=0; ii<num_vals; ii++)
        {
          edge_vals[ii].type = EMSdatainfo_event;
          edge_vals[ii].valevent = &me->edgeval_event[ii];
        }

        rnd_opts = me->associative ? NULL : EFrnd_cham_PLACE_NON_ASSOC;
        rnd_opts |= (me->uniformval != -1) ? EFrnd_cham_UNIFORM : NULL;

        if (mytype <= CHAMVERT)
        {
         ems_do_print_error_messages = FALSE;
         rnd_edges = ( struct EMSrnd_boundary_input * ) alloca
                ( me->numed * sizeof( struct EMSrnd_boundary_input ) );
         for( i = 0; i < me->numed; i++ )
         {
            rnd_edges[i].boundary_id.objid = me->located_obj[i];
            rnd_edges[i].boundary_id.osnum = osnum;
            /* Following used for simulating variable radius rounding */
               om$send( msg = message EMSedge.EMxyz_endpt( &msg, 0,
                                 &ME.COroot->ModuleInfo.md_env,
                                 0, 0,
                                 edge_ends[0], edge_ends[1], 0 ),
                        targetid = rnd_edges[i].boundary_id.objid,
                        targetos = rnd_edges[i].boundary_id.osnum );
                                 
            if( num_vals == 1 /* uniform case */ )
            {
               OM_BLOCK_MOVE( &edge_vals[0], &rnd_edges[i].radius,
                              sizeof( struct EMSvalue_info ) );
               rnd_edges[i].props = 0;
            }
            else /* non-uniform case */
            {
               OM_BLOCK_MOVE( &edge_vals[i], &rnd_edges[i].radius,
                              sizeof( struct EMSvalue_info ) );
               rnd_edges[i].props = EMSrnd_input_ed_grp_start;

            }
            rnd_edges[i].rho_value.type = EMSdatainfo_undefined;
            rnd_edges[i].other_radius.type = EMSdatainfo_undefined;
            rnd_edges[i].options = 0;
         }
         if( num_vals == 1 /* uniform case */ )
           rnd_edges[0].props = EMSrnd_input_ed_grp_start;
         local_options = me->associative ? 0 : EMS_RND_NON_ASSOCIATIVE;
         local_options |= operation_type == EMS_CHAMFER_OPR
                             ? EMS_RND_CHAMFER : 0;
	me->rnd_construct_id.osnum = osnum;
         OM_stat = EMround_chamfer_edges (&msg, 
                                 local_options,
                                 &ME.COroot->ModuleInfo,
                                 me->numed,
                                 rnd_edges,
                                 &round_error,
			  	 &me->rnd_construct_id);

         ems_do_print_error_messages = TRUE;
        }

        if (IGEstop()) msg = EMS_I_Interrupt;
       }

      if(msg == EMS_I_Interrupt)
      {
        if(me->rnd_construct_id.objid != NULL_OBJID)
        {
	 /* Replaced GRdelete by Root.delete because the former causes
	    ripple effects on unsuspecting dependents. The dependency could
	    have been already established before rounding was
	    interrupted.
	    SM 10/12/92
	 */
	 /**************
          OM_stat = om$send(msg = message  GRgraphics.GRdelete(&msg,
                                 &ME.COroot->ModuleInfo),
                           targetid = me->rnd_construct_id.objid,
                           targetos = osnum);
         ***************/
          OM_stat = om$send(msg = message  Root.delete(TRUE), 
                    targetid = me->rnd_construct_id.objid, targetos = osnum);

             ERROR(OM_stat, msg, "GRdelete", wrapup);      
        }
        ex$message(msgnumb = EMS_I_Intrupt);
      }

      ex$message(msgnumb = EMS_S_ClearStatusField);
      if (msg == EMS_I_RndGrExit || (!(1 & msg & OM_stat)))
      {
          ex$message(msgnumb = EMS_E_ChamfOprnFald); 

      me->numed = 0;
      me->num_vertex = 0;
      ME.super_cmd->state = INIT;
      break;
     }

       ex$message(msgnumb = EMS_P_ClearPromptField);
 
       ME.super_cmd->state = UNDO;
       break;
   }


   case UNDO:
    {
      GRobjid    *display_ids = NULL;  /*DECL*/ 
      IGRint     display_count = 0;
      IGRushort deactivate_option;    

      ex$message(msgnumb = EMS_P_AccwAnyEventBackupForUndo);

      stat_func = co$getevent (
        msg = &msg,
        event_mask = GRm_DATA | GRm_BACK_UP,
        response = (long *)response,
        response_data = response_data,
        event = &me->event
      );

      ex$message(msgnumb = EMS_P_ClearPromptField);
      if (stat_func == FALSE)
       {
        ex$message(msgnumb = EMS_E_FailInputProcExit);
        *response = TERMINATE;
        goto wrapup;
       }
      if (msg == GRw_no_value)
       {
        ex$message(msgnumb = EMS_I_00006);
        goto wrapup;
       }
      if (msg != MSSUCC)
        goto wrapup;

      switch(me->event.response)
       {
        case EX_DATA:
           me->numed = 0;
           me->num_vertex = 0;
           ME.super_cmd->state = INIT;
           goto wrapup;

        case EX_BACK_UP:

        /*Undo the rnd operation.*/
        deactivate_option = EMS_UNDO_DELETE | EMS_DO_DISPLAY | EMS_DELETE_DPR;
        {
          IGRint invoke_cnt=0;
          OM_stat = om$send(msg = message EMSdpr.EMundo(&msg,
                                  &deactivate_option, &me->ModuleInfo,
                                  NULL, NULL, NULL,
                                  &display_ids, &display_count, &invoke_cnt),
                            targetid = me->rnd_construct_id.objid,
                            targetos = osnum);
        }
        ERROR(OM_stat, msg, "undo", wrapup);
 
        OM_stat = om$send (mode = OM_e_wrt_parent,
                           msg = message ECchamfered.wakeup(NULL),
                  targetid = my_id );
        ERROR(OM_stat, msg, "ECchamfered.wakeup", wrapup);

        ME.super_cmd->state = ID_EDG;     
       break;
     default:
       goto wrapup;
     }
   }   /* UNDO */
   default:
     goto wrapup;
   } /* ME.super_cmd->state */
  }
  while (TRUE);
 wrapup: 
  return(OM_stat);
}

end implementation ECchamfered;
