class implementation ECtrmcompsf;


#include <stdio.h>
#include "math.h"
#include <stdlib.h>
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
#include "emsmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "EMSaction.h"
#include "grio.h"
#include "griomacros.h"
#include "OMprimitives.h"
#include "emserr.h"
#include "DIdef.h"
#include "EMSdpb.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsdistptpts.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ECmsg.h"
#include "ECcmd.h"
#include "emssfintdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "dpstruct.h"
#include "igrdef.h"

/* command states */

#define INIT			0
#define IDENTIFY_SOLORSURF      1
#define ACC_TRM_CURVE		2
#define IDENTIFY_TRMA_CURVE	3	
#define IDENTIFY_TRMB_CURVE	4	
#define IDENTIFY_CURVES         5 
#define DISP_ARROW		6
#define UNDO_IMPOSE     	7

/* mytypes */

#define TRMCOMPSF 0

extern OMuword  OPP_EMSsubbs_class_id, OPP_EMScompsurf_class_id,
	        OPP_GRcurve_class_id, OPP_GRcompcurve_class_id,
                OPP_GAcompcurve_class_id, OPP_SKcompcurve_class_id;

from GRgraphics import GRdisplay, GRgetrang;
from EMScompsurf import ECtrmcmpsfs, GRptproject;
from EMSdpr import EMundo;
from GRcurve import GRendpts, GRrevparm;
from GRowner import GRget_number_components, GRget_components;

/*
 * This command object places a Trimmed Composite State either
 * associatively or non-associatively.
 *
 * HISTORY :
 *
 *   P.S. Vidya : ???        : The beginning.
 *
 *   M.R. Vadiraj : 07/04/94 : If the longest curve is a single curve,
 *                             string it with other continuing curves.
 *                             Reverse their parameterization, if needed.
 *                    
 *                             Also, made the necessary changes for
 *                             associativity.
 */          

method init(int type; char *str_ptr)
{
  IGRlong sts;
  /* Initialise */
  ME.super_cmd->state = IDENTIFY_SOLORSURF ;
  me->num_located = 0;
  me->construct_id.objid = NULL_OBJID;
  me->lrgst_compid = NULL_OBJID;
  me->crv_index = 0;
  sts = om$send(mode = OM_e_wrt_message,
                msg = message COconst.init(type, str_ptr),
                targetid = my_id);
  return(sts);
}

method wakeup(int pos)
{
    IGRlong        i, msg, sts;
    enum           GRdpmode DisplayMode;

    sts = 1;
    if(ME.super_cmd->state != UNDO_IMPOSE)
      sts = om$send (mode = OM_e_wrt_parent,
                   msg = message ECtrmcompsf.wakeup (pos),
                   targetid = my_id);
    if (!(1 & sts)) return(OM_E_ABORT);
   
    DisplayMode = GRhd;
    for (i = 1; i <= me->num_located; i++)
    {
        sts = om$send(msg = message GRgraphics.GRdisplay
                          (&msg,
                           &me->lcinfo_curves[i].module_info.md_env.matrix_type,
                           me->lcinfo_curves[i].module_info.md_env.matrix,
                           &DisplayMode, &me->ModuleInfo.md_id),
                      targetid = me->lcinfo_curves[i].located_obj.objid,
                      targetos = me->lcinfo_curves[i].located_obj.osnum);
        if (!(1 & sts)) return(OM_E_ABORT);
    }

    gr$get_associative_flag(buffer = &me->associative);
    if(me->associative) GRdisplay_associative_button(TRUE);

  return(sts);
}	

method sleep(int pos)
{
    IGRlong        msg, sts;

    sts = 1;
    sts = dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "dp$erase_hilite error",ret_end);

    if(me->associative) GRdisplay_associative_button(FALSE);

ret_end:
    return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
 {
   IGRint                      mytype, i, num_lrgst_crvs,
                               *lrgst_crv_inx = NULL, num_bad_pts = 0,
                               inx;
   OMuword                     objspc_num,rclass, eliclass;
   OM_S_CLASSLIST              rtree_classes, elig_classes;
   struct  GRlc_locate         attributes;
   struct  GRid                owner;     
   IGRlong                     msg ,event_size,qsize,sts,  size, display_flag,
                               object_located=0,locate_mask, accept_mask;
   IGRchar                     acc_prompt[80],loc_prompt[80];
   IGRboolean                  stat_func=TRUE;
   IGRshort 		       *mattyp = NULL;
   IGRdouble                   *mat = NULL, *bad_pts = NULL;
   enum GRdpmode 	       mode;
   GRobjid		       object_id;
   IGRushort                   imp_options;
   OM_S_CHANSELECT             to_owners;

   extern IGRlong EMorntcvonsf();

   sts = OM_S_SUCCESS;
   mytype = ME.super_cmd->mytype;
   event_size = sizeof(struct GRevent);
   qsize = event_size - 2 * sizeof(IGRint);

   EMmake_chanselect(GRconnector_to_owners, &to_owners);

   switch(mytype) {

     case TRMCOMPSF:
       ex$message(msgnumb = EM_M_TrmCompSurfSolid ); 
       break;

     default:
       ERROR(OM_E_ABORT, EMS_E_Fail, "invalid mytype", ret_end);
   }

 do
  {
   switch(ME.super_cmd->state) {

     case INIT:
     {
       me->num_located = 0;
       me->construct_id.objid = NULL_OBJID;
       me->lrgst_compid = NULL_OBJID;
       me->crv_index = 0;
       ME.super_cmd->state =  IDENTIFY_SOLORSURF;
       break;
     }

     case IDENTIFY_SOLORSURF:
     {

       locate_mask = GRm_DATA | GRm_RJT_MOVEON;
       accept_mask = GRm_DATA | GRm_RJT_MOVEON ;

       ex$message(msgnumb = EMS_S_ClearStatusField);
       ex$message (msgnumb = EMS_P_IdSlCmSf,buff = loc_prompt);
       ex$message (msgnumb = EMS_P_AccIdenTrmCurv,buff = acc_prompt);

         display_flag =
	 ALL_WINDOWS		 |
         ELEM_HILIGHT            |       /* Hilite the whole element */
         NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
         LC_ERASE_LOC_ELEMENT    |
         DO_NOT_RELOCATE                ;       /* Relocate if none found */

         attributes.properties =
         LC_LC_ONLY              |       /* Locate locatable objects */
         LC_DP_ONLY              |       /* Locate displayable objects */
	 LC_RW			 ;
	 

         attributes.owner_action =
         LC_LOCALMOD    |
	 LC_RIGID_OWNER |
         LC_FLEX_COMP   |
         LC_RIGID_COMP  |                /* We want the surface itself */
         LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
         LC_NO_REF_HEADER;               /* No reference file headers */

         rtree_classes.w_count = 1;
         elig_classes.w_count = 1;
         rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

         rclass = OPP_EMSsubbs_class_id;
         eliclass = OPP_EMScompsurf_class_id;

         rtree_classes.p_classes = &rclass;
         elig_classes.p_classes = &eliclass;
       
         stat_func = lc$locate(
         rc =                   &object_located,
         event1 =               &me->locate_event,
         event2 =               &me->accept_event,
         mask1  =               locate_mask,
         mask2  =               accept_mask, 
	 eventsize = 		&size,
         response = 		response,
         response_data = 	response_data,
         display_flag =         display_flag,
	 locate_prompt =        loc_prompt,	
         acc_prompt =        acc_prompt,
         relocate_key =         EMS_I_00010,  
         attributes =           &attributes,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &elig_classes);

	 if( (!stat_func)) {
	   stat_func = 0;
           goto ret_end;
         }

	 if(object_located == GRw_no_value)
            me->accept_event.response = EX_RJT_MOVEON;

         if(object_located) {
	     sts = ex$putque(msg = &object_located, response = response,
                        byte = &qsize, buffer =(char *)&me->accept_event.event);
	   ME.super_cmd->state = ACC_TRM_CURVE; 
         }

	 switch(me->accept_event.response) {

	   case EX_DATA:
	     {
	     object_id = me->accept_event.located_object[0].located_obj.objid;
             objspc_num = me->accept_event.located_object[0].located_obj.osnum;
             me->surf_info = me->accept_event.located_object[0];

             mattyp = &me->surf_info.module_info.md_env.matrix_type;
	     mat = me->accept_event.located_object[0].module_info.md_env.matrix;
	     sts = dp$erase_hilite(msg = &msg);
	     mode = GRhhd;
             sts = om$send (msg = message GRgraphics.GRdisplay
                                      (&sts,mattyp,mat,
                                       &mode, &me->locate_stack.window),
                             senderid = NULL_OBJID,
                             targetid = object_id,
                             targetos = objspc_num);
             EMomerr_hndlr(sts, ret_end, "GRdisplay");
              break;
	       
             }
           default:
		
	     goto ret_end;
         }
	break;
     } /* case of IDENTIFY_SOLORSURF */

     case ACC_TRM_CURVE:

     { 
       locate_mask = GRm_DATA | GRm_RJT_MOVEON;
       accept_mask = GRm_DATA | GRm_RJT_MOVEON ;

       ex$message (msgnumb = EMS_P_AccIdenTrmCurv,buff = loc_prompt);
       ex$message (msgnumb = EMS_P_AccIdenNxtCurv ,buff = acc_prompt);

         display_flag =
	 ALL_WINDOWS		 |
         ELEM_HILIGHT            |       /* Hilite the whole element */
         NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
         LC_ERASE_LOC_ELEMENT    |
         DO_NOT_RELOCATE                ;       /* Relocate if none found */

         attributes.properties =
         LC_LC_ONLY              |       /* Locate locatable objects */
         LC_DP_ONLY              |       /* Locate displayable objects */
	 LC_RW			 ;
	 

         attributes.owner_action =
         LC_LOCALMOD    |
	 LC_RIGID_OWNER |
         LC_FLEX_COMP   |
         LC_RIGID_COMP  |                /* We want the surface itself */
         LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
         LC_NO_REF_HEADER;               /* No reference file headers */

         rtree_classes.w_count = 1;
         elig_classes.w_count = 1;
         rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

         rclass =  OPP_GRcurve_class_id;
         eliclass = OPP_GRcurve_class_id;

         rtree_classes.p_classes = &rclass;
         elig_classes.p_classes = &eliclass;
      
         {
         extern      IGRlong EFlocate_action_handler();
         struct      EMSaction_handler already_located;
         IGRboolean  use_act = TRUE;

         if(me->num_located > RLW_STACK_SIZE)
            use_act = FALSE;

         if(use_act)
          {
           already_located.next = NULL;
           already_located.option = 0;  /* Do not locate objects in the list*/
           already_located.type = 0; /* array of GRlc_info pointers */
           already_located.num_objects = me->num_located;
           for(inx=0; inx<me->num_located; inx++)
               already_located.objects.lc_info[inx] =
                                 &me->lcinfo_curves[inx];
          }

         stat_func = lc$locate(
         rc =                   &object_located,
         event1 =               &me->locate_event,
         event2 =               &me->accept_event,
         mask1  =               locate_mask,
         mask2  =               accept_mask, 
	 eventsize = 		&size,
         response = 		response,
         response_data = 	response_data,
         display_flag =         display_flag,
         locate_prompt = 	loc_prompt,
         acc_prompt =           acc_prompt,
         relocate_key =         EMS_I_00010,  
         attributes =           &attributes,
         act_handler =          use_act ? EFlocate_action_handler : NULL,
         act_args =             use_act ? &already_located : NULL,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &elig_classes);

	 if( (!stat_func)) {
	   stat_func = 0;
           goto ret_end;
         }
        }

	 if(object_located == GRw_no_value)
            me->accept_event.response = EX_RJT_MOVEON;
	 if(object_located) {
             owner.objid = NULL_OBJID;
             sts = om$get_objid_at_index(
               objid = me->accept_event.located_object[0].located_obj.objid,
               osnum = me->accept_event.located_object[0].located_obj.osnum,
               p_chanselect = &to_owners, index = 0, objidaddr = &owner.objid,
               osnumaddr = &owner.osnum);
             if(!IF_NULL_OBJID(owner.objid))
               {
               for(inx = 0; inx < me->num_located; inx++)
                  {
                  if(IF_EQ_GRID(me->lcinfo_curves[inx].located_obj, owner))
                    {
                    ex$message(msgnumb = EMS_I_CvAlreadyLocated);
                    return(OM_S_SUCCESS);
                    }
                  }
                }
	     me->num_located++; 
	     sts = ex$putque(msg = &object_located, response = response,
                        byte = &qsize, buffer =(char *)&me->accept_event.event);
	     ME.super_cmd->state = IDENTIFY_TRMB_CURVE; 
	 }
	 else ME.super_cmd->state = IDENTIFY_TRMA_CURVE;
	 switch(me->accept_event.response) {
	   case EX_DATA:
	    if(!object_located) break; 
	    me->lcinfo_curves[0] = me->accept_event.located_object[0];
            me->win_ids[0] = me->locate_stack.window;
            object_id = me->accept_event.located_object[0].located_obj.objid;
            objspc_num = me->accept_event.located_object[0].located_obj.osnum;

           mode = GRhe;
           mattyp = &me->lcinfo_curves[0].module_info.md_env.matrix_type;
           mat = me->accept_event.located_object[0].module_info.md_env.matrix;
           sts = om$send (msg = message GRgraphics.GRdisplay
                                      (&sts,mattyp,mat,
                                       &mode, &me->locate_stack.window),
                        senderid = NULL_OBJID,
                        targetid = object_id,
                        targetos = objspc_num);
             EMomerr_hndlr(sts, ret_end, "GRdisplay");
           mode = GRhhd;
	   sts = om$send (msg = message GRgraphics.GRdisplay
                                      (&sts,mattyp,mat,
                                       &mode, &me->locate_stack.window),
                             senderid = NULL_OBJID,
                             targetid = object_id,
                             targetos = objspc_num);
             EMomerr_hndlr(sts, ret_end, "GRdisplay");
              break;
	   default:
		goto ret_end;
	 }
	break;
      } /* case of ACC_TRM_CURVE */
      case IDENTIFY_TRMA_CURVE:
      case IDENTIFY_TRMB_CURVE:
	{
	  
       locate_mask = GRm_DATA | GRm_RJT_MOVEON;
       accept_mask = GRm_DATA | GRm_RJT_MOVEON ;

       ex$message (msgnumb = EMS_P_AccIdenNxtCurv ,buff = acc_prompt);
       if(ME.super_cmd->state == IDENTIFY_TRMA_CURVE) {
         display_flag =
	 ALL_WINDOWS		 |
         ELEM_HILIGHT            |       /* Hilite the whole element */
         NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
         LC_ERASE_LOC_ELEMENT    |
         DO_NOT_RELOCATE                ;       /* Relocate if none found */
         ex$message (msgnumb = EMS_P_IdenTrmCurv ,buff = loc_prompt);
       }
       else {
	 ex$message (msgnumb = EMS_P_AccIdenNxtCurv,buff = loc_prompt );
         display_flag =
	 ALL_WINDOWS		 |
         ELEM_HILIGHT            |       /* Hilite the whole element */
         NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
         LC_ERASE_LOC_ELEMENT    |
         DO_NOT_RELOCATE                ;       /* Relocate if none found */
        }

         attributes.properties =
         LC_LC_ONLY              |       /* Locate locatable objects */
         LC_DP_ONLY              |       /* Locate displayable objects */
	 LC_RW			 ;
	 

         attributes.owner_action =
         LC_LOCALMOD    |
	 LC_RIGID_OWNER |
         LC_FLEX_COMP   |
         LC_RIGID_COMP  |                /* We want the surface itself */
         LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
         LC_NO_REF_HEADER;               /* No reference file headers */

         rtree_classes.w_count = 1;
         elig_classes.w_count = 1;
         rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

         rclass = OPP_GRcurve_class_id;
         eliclass = OPP_GRcurve_class_id;

         rtree_classes.p_classes = &rclass;
         elig_classes.p_classes = &eliclass;

         {
         extern      IGRlong EFlocate_action_handler();
         struct      EMSaction_handler already_located;
         IGRboolean  use_act = TRUE;

         if(me->num_located > RLW_STACK_SIZE)
            use_act = FALSE;

         if(use_act)
          {
           already_located.next = NULL;
           already_located.option = 0;  /* Do not locate objects in the list*/
           already_located.type = 0; /* array of GRlc_info pointers */
           already_located.num_objects = me->num_located;
           for(inx=0; inx<me->num_located; inx++)
               already_located.objects.lc_info[inx] =
                                 &me->lcinfo_curves[inx];
          }

         stat_func = lc$locate(
         rc =                   &object_located,
         event1 =               &me->locate_event,
         event2 =               &me->accept_event,
         mask1  =               locate_mask,
         mask2  =               accept_mask, 
	 eventsize = 		&size,
         response = 		response,
         response_data = 	response_data,
         display_flag =         display_flag,
         locate_prompt = 	loc_prompt,
	 acc_prompt = 	acc_prompt,
         relocate_key =         EMS_I_00010,  
         attributes =           &attributes,
         act_handler =          use_act ? EFlocate_action_handler : NULL,
         act_args =             use_act ? &already_located : NULL,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &elig_classes);

	 if( (!stat_func)) {
	   stat_func = 0;
           goto ret_end;
         }
        }

	 if(object_located == GRw_no_value)
            me->accept_event.response = EX_RJT_MOVEON;
	 if(object_located) {
           owner.objid = NULL_OBJID;
           sts = om$get_objid_at_index(
               objid = me->accept_event.located_object[0].located_obj.objid,
               osnum = me->accept_event.located_object[0].located_obj.osnum,
               p_chanselect = &to_owners, index = 0, objidaddr = &owner.objid,
               osnumaddr = &owner.osnum);
           if(!IF_NULL_OBJID(owner.objid))
             {
             for(inx = 0; inx < me->num_located; inx++)
                {
                if(IF_EQ_GRID(me->lcinfo_curves[inx].located_obj, owner))
                  {
                   ex$message(msgnumb = EMS_I_CvAlreadyLocated);
                   return(OM_S_SUCCESS);
                   }
                 }
               }
           sts = ex$putque(msg = &object_located, response = response,
                        byte =&qsize, buffer =(char *)&me->accept_event.event);
         }
         else {
           if(ME.super_cmd->state == IDENTIFY_TRMB_CURVE) 
	      ME.super_cmd->state = IDENTIFY_CURVES;
         }
         switch(me->accept_event.response) {
           case EX_DATA:
	     {
	    IGRint num_entries;
	   if(!object_located) break;
           ME.super_cmd->state = IDENTIFY_TRMB_CURVE; 

           num_entries = om$dimension_of(varray = me->lcinfo_curves);
           if((me->num_located + 1) >= num_entries) {
           sts = om$vla_set_dimension(varray = me->lcinfo_curves,
                        size = num_entries + 1 );
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           sts = om$vla_set_dimension(varray = me->win_ids,
                        size = num_entries + 1 );
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");
           }
            me->lcinfo_curves[me->num_located] = me->accept_event.located_object[0];
	   object_id = me->accept_event.located_object[0].located_obj.objid;
           objspc_num = me->accept_event.located_object[0].located_obj.osnum;
           me->win_ids[me->num_located] = me->locate_stack.window;

	   mode = GRhe;
           mattyp =
             &me->lcinfo_curves[me->num_located].module_info.md_env.matrix_type;
           mat = me->accept_event.located_object[0].module_info.md_env.matrix;
	   me->num_located++;
           sts = om$send (msg = message GRgraphics.GRdisplay
                                      (&sts,mattyp,mat,
                                       &mode, &me->locate_stack.window),
                        senderid = NULL_OBJID,
                        targetid = object_id,
                        targetos = objspc_num);
             EMomerr_hndlr(sts, ret_end, "GRdisplay");
	    mode = GRhhd;
           sts = om$send (msg = message GRgraphics.GRdisplay
                                      (&sts,mattyp,mat,
                                       &mode, &me->locate_stack.window),
                             senderid = NULL_OBJID,
                             targetid = object_id,
                             targetos = objspc_num);
             EMomerr_hndlr(sts, ret_end, "GRdisplay");
              break;
	     }
	   case EX_RJT_MOVEON:
	      if(ME.super_cmd->state == IDENTIFY_TRMA_CURVE) {
                ex$message(msgnumb = EMS_S_IgnMoOnRej);
                sleep(1);
 	      }
	      else {
	        if(me->num_located >= 1) 
                   ME.super_cmd->state = IDENTIFY_CURVES;
		else ME.super_cmd->state = IDENTIFY_TRMA_CURVE;
              }
              break;
           default:
                goto ret_end;
         }
	break;
	} /* case of TRMA_CURVE and TRMB_CUR */

      case IDENTIFY_CURVES:
	{
          locate_mask = GRm_DATA | GRm_RJT_MOVEON;
          accept_mask = GRm_DATA | GRm_RJT_MOVEON ;

       ex$message (msgnumb = EMS_P_IdenNxtTrmCurvMvOn ,buff = loc_prompt);
       ex$message (msgnumb = EMS_P_AccIdenNxtCurv ,buff = acc_prompt);

         display_flag =
	 ALL_WINDOWS		 |
         ELEM_HILIGHT            |       /* Hilite the whole element */
         NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
         LC_ERASE_LOC_ELEMENT    |
         DO_NOT_RELOCATE                ;       /* Relocate if none found */

         attributes.properties =
         LC_LC_ONLY              |       /* Locate locatable objects */
         LC_DP_ONLY              |       /* Locate displayable objects */
	 LC_RW			 ;
	 

         attributes.owner_action =
         LC_LOCALMOD    |
	 LC_RIGID_OWNER |
         LC_FLEX_COMP   |
         LC_RIGID_COMP  |                /* We want the surface itself */
         LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
         LC_NO_REF_HEADER;               /* No reference file headers */

         rtree_classes.w_count = 1;
         elig_classes.w_count = 1;
         rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

         rclass = OPP_GRcurve_class_id;
         eliclass = OPP_GRcurve_class_id;

         rtree_classes.p_classes = &rclass;
         elig_classes.p_classes = &eliclass;

         {
         extern      IGRlong EFlocate_action_handler();
         struct      EMSaction_handler already_located;
         IGRboolean  use_act = TRUE;

         if(me->num_located > RLW_STACK_SIZE)
            use_act = FALSE;

         if(use_act)
          {
           already_located.next = NULL;
           already_located.option = 0;  /* Do not locate objects in the list*/
           already_located.type = 0; /* array of GRlc_info pointers */
           already_located.num_objects = me->num_located;
           for(inx=0; inx<me->num_located; inx++)
               already_located.objects.lc_info[inx] =
                                 &me->lcinfo_curves[inx];
          }

         stat_func = lc$locate(
         rc =                   &object_located,
         event1 =               &me->locate_event,
         event2 =               &me->accept_event,
         mask1  =               locate_mask,
         mask2  =               accept_mask, 
	 eventsize = 		&size,
         response = 		response,
         response_data = 	response_data,
         display_flag =         display_flag,
         locate_prompt = 	loc_prompt,
	 acc_prompt = 	acc_prompt,
         relocate_key =         EMS_I_00010,  
         attributes =           &attributes,
         act_handler =          use_act ? EFlocate_action_handler : NULL,
         act_args =             use_act ? &already_located : NULL,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &elig_classes);

	 if( (!stat_func)) {
	   stat_func = 0;
           goto ret_end;
         }
        }

	 if(object_located == GRw_no_value)
            me->accept_event.response = EX_RJT_MOVEON;

	 if(object_located) {
             owner.objid = NULL_OBJID;
             sts = om$get_objid_at_index(
               objid = me->accept_event.located_object[0].located_obj.objid,
               osnum = me->accept_event.located_object[0].located_obj.osnum,
               p_chanselect = &to_owners, index = 0, objidaddr = &owner.objid,
               osnumaddr = &owner.osnum);
             if(!IF_NULL_OBJID(owner.objid))
               {
               for(inx = 0; inx < me->num_located; inx++)
                  {
                  if(IF_EQ_GRID(me->lcinfo_curves[inx].located_obj, owner))
                    {
                    ex$message(msgnumb = EMS_I_CvAlreadyLocated);
                    return(OM_S_SUCCESS);
                    }
                  }
                }
           ME.super_cmd->state = IDENTIFY_TRMB_CURVE;
             sts = ex$putque(msg = &object_located, response = response,
                        byte =&qsize, buffer =(char *)&me->accept_event.event);
         }

	 switch(me->accept_event.response) {
           case EX_DATA:
	     {
	     IGRint num_entries;
             
             if(!object_located) break;
             num_entries = om$dimension_of(varray = me->lcinfo_curves);
             if((me->num_located + 1) >= num_entries) {
             sts = om$vla_set_dimension(varray = me->lcinfo_curves,
                        size = num_entries + 1 );
             EMomerr_hndlr(sts, ret_end, "set_dimension  error");

             sts = om$vla_set_dimension(varray = me->win_ids,
                        size = num_entries + 1 );
             EMomerr_hndlr(sts, ret_end, "set_dimension  error");
             }
            me->lcinfo_curves[me->num_located]=
                    me->accept_event.located_object[0];
           me->win_ids[me->num_located] = me->locate_stack.window;
            object_id = me->accept_event.located_object[0].located_obj.objid;
            objspc_num = me->accept_event.located_object[0].located_obj.osnum;
            mode = GRhe;
            mattyp =
             &me->lcinfo_curves[me->num_located].module_info.md_env.matrix_type;
            me->num_located++;
            mat = me->accept_event.located_object[0].module_info.md_env.matrix;
            sts = om$send (msg = message GRgraphics.GRdisplay
                                      (&sts,mattyp,mat,
                                       &mode, &me->locate_stack.window),
                        senderid = NULL_OBJID,
                        targetid = object_id,
                        targetos = objspc_num);
             EMomerr_hndlr(sts, ret_end, "GRdisplay");
	    mode = GRhhd;
           sts = om$send (msg = message GRgraphics.GRdisplay
                                      (&sts,mattyp,mat,
                                       &mode, &me->locate_stack.window),
                             senderid = NULL_OBJID,
                             targetid = object_id,
                             targetos = objspc_num);
             EMomerr_hndlr(sts, ret_end, "GRdisplay");

	    break;
	    }

           case EX_RJT_MOVEON:
		ME.super_cmd->state = DISP_ARROW;
		break;
	   default:
	       goto ret_end;
         } /* switch of curves */
	break;
        } /* of CURVES */
       case DISP_ARROW:
	 {
         struct GRlc_info **crvs_info = NULL;
         GRobjid temp_objid;
         struct GRmd_env temp_mdenv;
         struct IGRdisplay active_display;
         IGRlong n_bytes, b_rec;
         struct DPele_header ele_header;
         struct IGRpointset points;

	 crvs_info = (struct GRlc_info **) om$malloc(size = 
                        me->num_located * sizeof(struct GRlc_info *));

         for (i=0; i<me->num_located; i++) {
           crvs_info[i] = 
            (struct GRlc_info *) om$malloc(size = sizeof(struct GRlc_info));
           crvs_info[i]->located_obj.objid = 
              me->lcinfo_curves[i].located_obj.objid;
           crvs_info[i]->located_obj.osnum = 
              me->lcinfo_curves[i].located_obj.osnum;
           OM_BLOCK_MOVE(&me->lcinfo_curves[i].module_info, 
                         &crvs_info[i]->module_info, sizeof(struct GRmd_env));
         }

	  me->reverse = EMorntcvonsf( &msg,
			&me->surf_info,
			crvs_info,
			me->num_located,
			me->win_ids,
			response,
			response_data,
			my_id,
			&me->crv_index,
			&me->lrgst_compid);

          if(me->reverse == EX_BACK_UP)
          {
          ME.super_cmd->state = IDENTIFY_TRMB_CURVE;
          break;
          }

          for(i = 0; i < me->num_located; i++) {
             if(i == me->crv_index) 
                 {
                temp_objid = crvs_info[0]->located_obj.objid;
                crvs_info[0]->located_obj.objid =
                crvs_info[i]->located_obj.objid; 
                crvs_info[i]->located_obj.objid = temp_objid;
                OM_BLOCK_MOVE(&crvs_info[0]->module_info,
                              &temp_mdenv, sizeof(struct GRmd_env));
                OM_BLOCK_MOVE(&crvs_info[i]->module_info,
                           &crvs_info[0]->module_info, sizeof(struct GRmd_env));
                OM_BLOCK_MOVE(&temp_mdenv,
                           &crvs_info[i]->module_info, sizeof(struct GRmd_env));
                           }
              else continue;
		      } 
	  me->construct_id.objid = NULL_OBJID;
	  imp_options = EMSsfbool_opt_HandleStop;

          lrgst_crv_inx = (IGRint *) om$malloc(size = me->num_located *
                                               sizeof(IGRint));
          {
          IGRpoint ref_start, ref_stop,
                   comp_start, comp_stop;
          IGRdouble end_dist, distance_tol, connect_tol, dist[4];
          IGRint j, tmp_inx, k, rev_crv;
          IGRboolean same_inx;  

          num_lrgst_crvs = 1;
          sts = BSEXTRACTPAR(&msg, BSTOLLENVEC, connect_tol);
          distance_tol = connect_tol * connect_tol;
          lrgst_crv_inx[0] = 0;
          for(k = 0; k < num_lrgst_crvs; k++) {
              tmp_inx = lrgst_crv_inx[k];
              same_inx = FALSE;
          sts = om$send(msg = message GRcurve.GRendpts(&msg,
                           &crvs_info[tmp_inx]->module_info.md_env.matrix_type,
                           crvs_info[tmp_inx]->module_info.md_env.matrix,
                                  ref_start, ref_stop),
                                  targetid = 
                                  crvs_info[tmp_inx]->located_obj.objid,
                                  targetos = 
                                  crvs_info[tmp_inx]->located_obj.osnum,
                                  senderid = my_id);

          if(!BSdistptpts(&msg, ref_start, ref_stop ) < connect_tol)
             {
              end_dist = distance_tol;
              for(i = 1; i < me->num_located; i++)
                 {
                 rev_crv = 0;
                 for(j = 0; j < num_lrgst_crvs; j++) {

                     if(i == lrgst_crv_inx[j]) {
                        same_inx = TRUE;
                        break;
                         }
                       }
                 if(same_inx) continue;
                 sts = om$send(msg = message GRcurve.GRendpts(&msg,
                                  &crvs_info[i]->module_info.md_env.matrix_type,
                                  crvs_info[i]->module_info.md_env.matrix,
                                  comp_start, comp_stop),
                                  targetid =
                                  crvs_info[i]->located_obj.objid,
                                  targetos =
                                  crvs_info[i]->located_obj.osnum,
                                  senderid = my_id);
                 if(BSdistptpts(&msg, comp_start, comp_stop ) < connect_tol)
                    continue;
                 else
                    {
                    dist[0] = BSdistptpts(&msg, ref_stop, comp_start);
                    dist[1] = BSdistptpts(&msg, ref_stop, comp_stop);
                    dist[2] = BSdistptpts(&msg, ref_start, comp_stop);
                    dist[3] = BSdistptpts(&msg, ref_start, comp_start);
           
                    for(j = 0; j < 4; j++) {
                        if(dist[j] < end_dist) 
                          end_dist = dist[j];

                        if(dist[j] >= end_dist &&
                           dist[j] < distance_tol)
                           rev_crv = j;
                          }
                    if(end_dist >= distance_tol)
                       continue;
                    else {
                         lrgst_crv_inx[num_lrgst_crvs] = i;
                         num_lrgst_crvs++;
                         if(rev_crv == 1 || rev_crv == 3)
                           {
                          sts = om$send(msg = message GRcurve.GRrevparm(&msg,
                                        &crvs_info[i]->module_info),
                                targetid = crvs_info[i]->located_obj.objid,
                                targetos = crvs_info[i]->located_obj.osnum);
                           }
                       }
                    }
                 }
             } 
          }
       }

          sts = om$send(msg = message EMScompsurf.ECtrmcmpsfs(crvs_info,
                                      me->num_located,
                                      &me->surf_info,
                                      imp_options,
                                      num_lrgst_crvs,
                                      lrgst_crv_inx,
                                      me->reverse,
                                      &me->lrgst_compid,
                                      me->associative,
                                      &num_bad_pts,
                                      &bad_pts,
                                      &me->construct_id,
                                      &msg),
                 targetid = me->surf_info.located_obj.objid,
                 targetos = me->surf_info.located_obj.osnum,
                 senderid = NULL_OBJID);

	 if(!me->construct_id.objid )
	    ME.super_cmd->state = UNDO_IMPOSE;
	 else {  
          ME.super_cmd->state = INIT;

          if(msg == EMS_I_OutOfBounds) {
	   ex$message(msgnumb = EMS_F_0003)
           sts = dp$erase_hilite(msg = &msg);
           ERROR(sts, msg, "dp$erase_hilite error",ret_end);

               if(num_bad_pts) {
               n_bytes = sizeof( struct IGRdisplay );
               gr$get_active_display( msg = &msg,
                                      sizbuf = &n_bytes,
                                      buffer = &active_display,
                                      nret = &b_rec );
               active_display.weight = 4;

               points.num_points = num_bad_pts;
               points.points     = bad_pts; 

               dp$build_dis_buffer(buffer      = &ele_header,
                                   type        = IGRPS,
                                   display_att = &active_display,
                                   geometry    = (struct IGRpointset *)&points);

               sts = dp$display(msg = &msg,
                                osnum = me->surf_info.located_obj.osnum,
                                buffer = &ele_header);
                
               }

          loc_wrapup :

          for(i = 0; i < me->num_located; i++) {
             if(crvs_info[i]) {
               om$dealloc(ptr = crvs_info[i]);
               crvs_info[i] = NULL;
               }
            }
          if(crvs_info) {
            om$dealloc(ptr = crvs_info);
            crvs_info = NULL;
             }  
          
           if(bad_pts) {
            om$dealloc(ptr = bad_pts);
            bad_pts = NULL;  
            }
           }
        }
	 break;
      }

       case UNDO_IMPOSE:
	 {
	  
           GRobjid    *display_ids = NULL;  /*DECL*/ 
           IGRint     display_count = 0;
           IGRushort  deactivate_option;    
     
           ex$message(msgnumb = EMS_P_AccwAnyEventBackupForUndo);

           stat_func = co$getevent (msg = &msg,
        	event_mask = GRm_DATA | GRm_BACK_UP,
        	response = response,
        	response_data = response_data,
        	event = &me->accept_event);

           ex$message(msgnumb = EMS_P_ClearPromptField);
           if (stat_func == FALSE) {
        	ex$message(msgnumb = EMS_E_FailInputProcExit);
        	*response = TERMINATE;
        	goto ret_end;
           }
           if (msg == GRw_no_value) {
        	ex$message(msgnumb = EMS_I_00006);
        	goto ret_end;
           }
           if (msg != MSSUCC) {
             goto ret_end;
           }

           switch(me->accept_event.response) {
             case EX_DATA:
                ME.super_cmd->state = INIT;
                break;

             case EX_BACK_UP:

              /*Undo the impose operation.*/
                 deactivate_option = EMS_UNDO_DELETE | 
                                     EMS_DO_DISPLAY | EMS_DELETE_DPR;
                {
                  IGRint invoke_cnt=0;
                  sts = om$send(msg = message EMSdpr.EMundo(&msg,
                                  &deactivate_option, &me->ModuleInfo,
                                  NULL, NULL, NULL,
                                  &display_ids, &display_count, &invoke_cnt),
                                    targetid = me->construct_id.objid,
                                    targetos = me->construct_id.osnum);
                }
                ERROR(sts, msg, "undo", ret_end);
 
                sts = om$send (mode = OM_e_wrt_parent,
                           msg = message ECtrmcompsf.wakeup(NULL),
                  targetid = my_id );
                ERROR(sts, msg, "ECtrmcompsf.wakeup", ret_end);

                ME.super_cmd->state = INIT;

                break;

                default:
       		goto ret_end;
     	    } /* switch of accept */
	   break;
         }  /* of UNDO */

       default:
	 goto ret_end;
     } /* switch of super */
   }  while (TRUE);/* of do */


ret_end:
   return(sts);
}

end implementation ECtrmcompsf;
