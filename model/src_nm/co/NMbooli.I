class implementation NMnmbool;


# define INTER  0 
# define UNION  1
# define SPLIT  2

#define DEBUG 0 /*Set to 1 if want error strings.*/

#include <stdio.h>
#include "codef.h"
#include "ECdlb.h"
#include "igr.h"
#include "igrtypedef.h"
#include "griodef.h"
#include "exdef.h"
#include "EMSmsgdef.h"
#include "emsbool.h"
#include "emssfintdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "EMSopt.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "EMSaction.h"                  /* Locate action handler */
#include "msmacros.h"   /* ex$message */
#include "emsdef.h"
#include "OMmacros.h"
#include "ECprepsf.h"

#include "ECcmd.h"
#include "ECmsg.h"

#include "NMcmd.h"
#include "NMmsg.h"


#define StaticBuf 10

#include "EMStypedef.h"

from GRgraphics   import GRdisplay, GRdelete;
from NMnonmanigm import NMperform_boolean;
from EMSsurface import EMputLsIfNotThere, EMshow_normals;

extern OMuword OPP_EMSsubbs_class_id,
               OPP_EMSsurface_class_id,
               OPP_EMSsolid_class_id, 
               OPP_GRcurve_class_id,
	       OPP_NMnonmani_class_id, 
               OPP_GRbspline_class_id;

extern EMSrc EFextractOperationInformation ();

static void localMsg();
static int localDisplay();

method init (IGRint type; IGRchar *string)
{
 IGRint sts=OM_S_SUCCESS;
 IGRlong msg=EMS_S_Success;
 IGRboolean is_assoc = TRUE;

 sts = om$send(mode = OM_e_wrt_message, 
	       msg = message COconst.init(type, string), 
	       targetid = my_id);
 ERROR(sts, msg, "COconst.init", wrapup);

 /* Save current dpb flag in my instance data.
 */
 gr$get_associative_flag(buffer = &me->dpb_assoc_flag);

 if(!me->dpb_assoc_flag)
  gr$put_associative_flag(buffer = &is_assoc);

 GRdisplay_associative_button(TRUE);

wrapup:
 return(sts);
}

method wakeup(int pos)
{
 IGRint sts=OM_S_SUCCESS,i;
 IGRlong msg=EMS_S_Success;
 IGRboolean is_assoc = TRUE;
 
 if (me->is_hilited)
 { 
   for (i = 0; i < me->num_located; i++)
   { 
     sts = localDisplay(&msg, &me->ModuleInfo, GRhd, me->located_ids[i].objid,
                        me->locate_info.located_obj.osnum);
     ERROR(sts, msg, "NMnmbool_wake draw hi", wrapup);
   }

 /* Save current dpb flag in my instance data.
 */
 gr$get_associative_flag(buffer = &me->dpb_assoc_flag);

 if(!me->dpb_assoc_flag)
  gr$put_associative_flag(buffer = &is_assoc);

  GRdisplay_associative_button(TRUE);
 }

 wrapup:
  return(sts);
}


method super_cmd.sleep(int pos)
{
 IGRint sts=OM_S_SUCCESS;
 IGRlong msg=EMS_S_Success;

 if (me->num_located && me->is_hilited)
 {
    sts = dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "NMnmbool_sleep erase hi", wrapup);
 }

 localMsg (EM_M_ClearMessageField);

 localMsg (EMS_P_ClearPromptField);

 GRdisplay_associative_button(FALSE);
 gr$put_associative_flag(buffer = &me->dpb_assoc_flag);

 wrapup:
  return(sts);
}


method delete(int f_defer_flag)
{
  IGRint sts;

  GRdisplay_associative_button(FALSE);

 gr$put_associative_flag(buffer = &me->dpb_assoc_flag);

  sts = om$send(mode = OM_e_wrt_message,
                msg = message COconst.delete(NULL),
                targetid = my_id);
  ERROR(sts, EMS_S_Success, "NMnmbool_delete delete", wrapup);

 wrapup:
  return(sts);
}


method execute(int *response; char *response_data; int pos)
{
 IGRint                sts = OM_S_SUCCESS, size=sizeof(struct GRevent),
		       display_flag;
 IGRint                locate_mask, accept_mask, token, i, j;
 IGRlong	       *error_codes = NULL, msg, qsize, eventmsg;
 IGRint                eventsts, save_rsp;
 enum     NMbooltype   bool_type = NMbool_intersect;
 struct   GRvg_construct construct_list;
 struct   GRlc_locate  attr;
 struct   GRevent      loc_obj_event;        /*Added by DLB 08/04/88*/
 OM_S_CLASSLIST        rtree_classes, elig_classes;
 OMuword               rclass[3], eliclass[2];
 IGRboolean            found_same, output_inters=FALSE, dosplit = FALSE;


#define NUM_TOKENS 6
#define NUM_STATES 3

 static int Tokens[NUM_TOKENS] =
 {
   EX_BACK_UP, DATA, VALUE, STRING, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
 };

 enum actions
 {
   NIL, init, rem_it, store_it, do_bool, reset_all, stmask
 };

 enum states
 {
   start, prepsf, get_int
 };

 static enum states NextState[NUM_STATES][NUM_TOKENS] =
 {
 /*  token:     BACK_UP  DATA       VALUE      STRING  MOVEON    UNK
 old state:  */                                   
 /* start    */ {prepsf, prepsf,    start,     prepsf, start,    start    },
 /* prepsf   */ {start,  prepsf,    prepsf,    start,  prepsf,   prepsf   },
 /* get_int  */ {start,  start,     start,     get_int,start,    get_int  },
 };

 static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
 {
 /*  token:      BACK_UP    DATA      VALUE      STRING    MOVEON   UNK
 old state: */                                     
 /* start    */ {NIL,       store_it, NIL,       store_it, do_bool, NIL   },
 /* prepsf   */ {rem_it,    NIL,      NIL,       stmask,   NIL,     NIL   },
 /* get_int  */ {reset_all, do_bool,  NIL,       NIL,      do_bool, NIL   },
 };


 if(ME.super_cmd->mytype == SPLIT)
 localMsg (NMC_M_GlueSurfAtInters);
 else
  localMsg (NMC_M_TrimGlueSurfAtInters);

 bool_type = (ME.super_cmd->mytype == SPLIT) ? NMbool_split : NMbool_intersect;

 do
 {
  switch (ME.COconst->action)
  {
   case NIL:
    break;

   case init:
    me->num_located = 0;
    break;

   case rem_it:
   {
    if (me->num_located)
    {
      if (me->num_located == 1)
      {
        sts = dp$erase_hilite(msg = &msg);
        ERROR(sts, msg, "NMnmbool_exec erase hi", wrapup);
      }
      else
      {
        sts = localDisplay(&msg, &me->ModuleInfo, GRhe, 
              me->located_ids[me->num_located-1].objid,
              me->locate_info.located_obj.osnum);
        ERROR(sts, msg, "NMnmbool_exec erase", wrapup);
      }      
     
      me->num_located--;
    }
    break;
   }


   case store_it:
   {
    IGRlong             number_of_objects;
    struct              GRlc_info *objects, static_object;
    OMuword             yes_list, no_list;
    OM_S_CLASSLIST      yes_classes, no_classes;
    extern              IGRlong EMselective_fence();

    number_of_objects = 0;
    objects = NULL;
    found_same = FALSE;

    yes_list = OPP_EMSsurface_class_id;
    yes_classes.w_count = 1;
    yes_classes.p_classes = &yes_list;
    no_list = OPP_GRcurve_class_id;
    no_classes.w_count = 1;
    no_classes.p_classes = &no_list;

    sts = EMselective_fence(
          &yes_classes,
          &no_classes,
          &me->locate_event.located_object[0],
          FALSE,                  /* Don't break up composites */
          FALSE,                  /* This is not read only */
          my_id,
          &number_of_objects,
          &objects,
          &msg);
    ERROR(sts, msg, "NMbool_exec EMselective_fence", wrapup);

    /*
     * The first object which we located will determine the
     * object space and module enviroment of all other objects
     * that are located.
     */
    if (number_of_objects &&
        (me->num_located == 0))
     {
      OM_BLOCK_MOVE(
       objects,
       &me->locate_info,
       sizeof(struct GRlc_info));

     } /* If it's the first pass */


   /*
    * For each object in the set discard those which
    * have already been located during a previous operation.  Also
    * ensure that we are staying in the same object space, as composites
    * cannot cross object spaces.
   */
    for (i = 0; i < me->num_located; i++)
     {
      for (j = 0; j < number_of_objects; j++)
       {
        if ((me->located_ids[i].objid == objects[j].located_obj.objid) ||
            (me->locate_info.located_obj.osnum != 
             objects[j].located_obj.osnum))
         {
          IGRlong       number_remaining;

          number_remaining = number_of_objects - (j + 1);
          if (number_remaining)
           {
            OM_BLOCK_MOVE(
             &objects[j + 1],
             &objects[j],
             number_remaining * sizeof(struct GRlc_info));
           } /* if (number_remaining) */
          number_of_objects--;
          j--;                                  /* Stay on this entry */
         } /* If the object is not acceptable */
       } /* for (j = 0; j < number_of_objects; j++) */
     } /* for (i = 0; i < me->num_located; i++) */

    /*
     * Add the processed element set to the processed list.
    */
    if (number_of_objects)
     {
      IGRlong           total_count;

      total_count = me->num_located + number_of_objects + 2; /* Conservative */
      sts = om$vla_set_dimension(
        varray = me->located_ids,
        size = total_count);
       ERROR(sts, EMS_S_Success, "NMbool_exec expand vla", wrapup);
      for (i = 0; i < number_of_objects; i++)
       {
        me->located_ids[me->num_located] = objects[i].located_obj;       
        me->num_located = me->num_located + 1;
       } /* for (i = 0; i < number_of_objects; i++) */

      me->is_hilited = TRUE;

     } /* if (number_of_objects) */

   /*
    * Erase the highlighed object and tell the operator 
    * if we have thrown everything away.  Note that fences
    * do not need to be erased as they are never highlighted.
    */
    else
     {
      if (me->locate_event.response != EX_OBJID)
       {
        if (me->num_located)
         {
          struct        GRlc_info *info;
          enum GRdpmode Display_Mode;

          info = &me->locate_event.located_object[0];
          Display_Mode = GRhe;
          sts = om$send(
            msg = message GRgraphics.GRdisplay(
             &msg,
             &info->module_info.md_env.matrix_type,
             info->module_info.md_env.matrix,
             &Display_Mode, 
             &info->module_info.md_id),
            targetid = info->located_obj.objid,
            targetos = info->located_obj.osnum);
          ERROR(sts, msg, "NMbool GRdisplay", wrapup);
         } /* if (me->num_located) */
        else
         {
          sts = dp$erase_hilite(
            msg = &msg);
           ERROR(sts, msg, "NMbool erase hilite", wrapup);
         } /* ELSE FOR if (me->num_located) */
       } /* if (me->locate_event.response != EX_OBJID) */
      ex$message(msgnumb = EMS_I_00092)
      sleep(2);
      ME.super_cmd->state = start;
     }
/*
 * Free the memory
 */
    if (objects &&
        (objects != &static_object)) free(objects);

     break;
   }   


   case stmask:
   {
    if (save_rsp == EX_BACK_UP)  break;
    /*Place accept event on the software stack for the next locate*/

    if ( (me->locate_event.subtype != GRst_REGULAR) && 
          me->locate_event.num_id && 
         (me->locate_event.located_object[0].located_obj.objid ==
          me->accept_event.located_object[0].located_obj.objid) ) break;

    qsize = sizeof(me->accept_event.event) + sizeof (IGRint);
    sts = ex$putque(msg = &msg, 
                       response = &me->accept_event.response, /*save_rsp,*/
                       byte = &qsize,
                       buffer = (IGRchar *) &me->accept_event.event);
    ERROR(sts, EMS_S_Success, "NMnmbool_exec put que", wrapup);
    break;
   }


   case do_bool:
   {
    GRobjid    inters=NULL_OBJID, endpts=NULL_OBJID;
    IGRboolean can_output_inters, it_worked, trim_split = FALSE; 
    IGRchar    status_str[54];
    IGRushort boolopt;
    struct GRid *nmop = NULL, nmopbuf[StaticBuf];
    IGRint	num_nmop = 0;

    nmop = NULL;
    trim_split = FALSE;
    ex$message (msgnumb = EMS_I_Processing, buff = status_str);

    sts = dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "NMnmbool_sleep erase hi", wrapup);

    me->is_hilited = FALSE;

    construct_list.msg = &msg;
    construct_list.env_info = &me->locate_info.module_info,
    construct_list.newflag = FALSE;
    construct_list.geometry = NULL;
    construct_list.class_attr = NULL;
    construct_list.level = ME.COconst->ActiveLevel;
    construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    construct_list.display = &ME.COconst->ActiveDisplay;
    construct_list.name = NULL;

    localMsg (EMS_I_Processing);
    localMsg (EMS_P_ClearPromptField);

    me->construct_id.osnum = me->locate_info.located_obj.osnum;

    sts = om$construct(classid = OPP_NMnonmanigm_class_id, 
                         p_objid = &me->construct_id.objid,
                         osnum = me->locate_info.located_obj.osnum);
    ERROR(sts, EMS_S_Success, "NMnmbool_exec construct", wrapup);


    boolopt = EMSsfbool_opt_display | EMSsfbool_opt_HandleStop;
    if(output_inters)
       boolopt |= EMSsfbool_opt_doublecheck | EMSsfbool_opt_outinters | 
                  EMSsfbool_opt_outaux;

    if(dosplit && (ME.super_cmd->mytype != SPLIT))
     {
      if(me->num_located > StaticBuf)
       nmop = (struct GRid *) om$malloc(size = me->num_located *
				sizeof(struct GRid));
      else nmop = (struct GRid *) nmopbuf;

      num_nmop = 0;
      for(i=0; i<me->num_located - 1; i++)
       {
        if(1&error_codes[i]) continue;
        nmop[num_nmop++] = me->located_ids[i+1];
       }
      trim_split = TRUE;      
     }

    if(dosplit || (ME.super_cmd->mytype == SPLIT)) bool_type = NMbool_split;

    if( om$dimension_of(varray = me->error_codes) < (me->num_located-1))
     sts = om$vla_set_dimension(varray = me->error_codes, 
             size = me->num_located - 1);
    error_codes = me->error_codes;

    eventsts = om$send(msg = message NMnonmanigm.NMperform_boolean(&eventmsg,
	         error_codes, 
                 &construct_list, 
                 me->located_ids[0], 				/* vol_op */
                 &me->locate_info.module_info, 			/* volenv */
                 trim_split ? num_nmop : me->num_located-1, 	/* num_nmop */
                 trim_split ? nmop : &me->located_ids[1],	/* nm_op */
                 NULL, 				/* nmop_env -- use volenv */
                 bool_type,			/* bool_type */
                 boolopt, 			/* options */
                 status_str, 
                 output_inters ? &inters : NULL, 
                 output_inters ? &endpts : NULL), 

                 targetid=me->construct_id.objid,
                 targetos=me->construct_id.osnum);

    can_output_inters = FALSE;
    it_worked = FALSE;
    if(nmop && (nmop != nmopbuf))
     {
      om$dealloc(ptr = nmop);
      nmop = NULL;
     }

    if(eventmsg == EMS_E_NoDynamicMemory)
      localMsg (EMS_E_InsufficientDynamicMemory);
    else if(eventmsg ==EMS_F_Fail)
     {
      localMsg (EMS_I_00101);			
      localMsg (EMS_F_0006);
     }
    else if( (eventmsg == EMS_E_Success) || (eventmsg == EMS_W_Success))
     {
      IGRint i;
      if(eventmsg == EMS_W_Success) localMsg (NM_E_PartialSuccess);
      else localMsg (EMS_E_OperationFailed);
      eventmsg = EMS_S_Success;
      eventsts = OM_S_SUCCESS;
      /* Check to see whether none of the elements intersected.
      */
      for(i=0; i<me->num_located - 1; i++)
       if( (error_codes[i] != EMS_I_NoIntersection) && 
           (!(1&error_codes[i])))
        { can_output_inters = TRUE; break;}
	
      if(can_output_inters)
       {
	can_output_inters = FALSE;
        for(i=0; i<me->num_located - 1; i++)
	 if( (!(1&error_codes[i])) && (error_codes[i] != EMS_E_Intersect))
	 {can_output_inters = TRUE; break;}
       }
     }
    else if(eventmsg == EMS_I_NoIntersection)
      localMsg (NM_I_EleNoIntersect);
    else if(eventmsg == EMS_E_Intersect)
      localMsg (EMS_E_BadIntersectionResults);
    else if(eventmsg == EMS_E_IntersClosureOrient)
     {
      localMsg (EMS_E_IntersOrientClosure);
      can_output_inters = TRUE;
     }
    else if(eventmsg == EMS_E_IntersectOrient)
     {
      localMsg (EMS_E_IntxCvsImproperOrient);
      can_output_inters = TRUE;
     }
    else if(eventmsg == EMS_E_IntersectTrim)
     {
      localMsg (NM_E_BadDataForTrimming);
      can_output_inters = TRUE;
     }
    else if(!(1&eventsts&eventmsg) && !output_inters)
      localMsg (EMS_E_OperationFailed);
    else if( (1&eventsts&eventmsg) && !output_inters)	/* Its cool */
     {
      if(eventmsg == EMS_I_Interrupt) localMsg (EMS_I_ProcessingInterrupt);
      else localMsg (NM_I_Done);
      it_worked = TRUE;
     }

    if (!(1&eventsts&eventmsg) || output_inters)
     {
      sts = om$send(msg = message Root.delete(NULL),
                      targetid = me->construct_id.objid,
                      targetos = me->construct_id.osnum);
      ERROR(sts, EMS_S_Success, "NMnmbool_exec delete", wrapup);
     }
        
    if (output_inters)
     {
      if (inters != NULL_OBJID)
       {
        sts = localDisplay(&msg, &me->ModuleInfo, GRbd, inters, 
                  me->locate_info.located_obj.osnum);
        ERROR(sts, msg, "NMnmbool_exec erase loc curves", wrapup);    

        sts = localDisplay(&msg, &me->ModuleInfo, GRhhd, inters, 
                  me->locate_info.located_obj.osnum);
        ERROR(sts, msg, "NMnmbool_exec erase loc curves", wrapup);    
        localMsg (NM_I_InterResultHilited);
       }

      if (endpts != NULL_OBJID)
       {
        sts = localDisplay(&msg, &me->ModuleInfo, GRbdhd, endpts, 
                  me->locate_info.located_obj.osnum);
        ERROR(sts, msg, "NMnmbool_exec erase loc curves", wrapup);    
       }
      output_inters = FALSE;
     }

    if(can_output_inters)
     {
      ME.super_cmd->state = get_int;
      break;
     }
    else
     {
      /*if(!it_worked) sleep(3)*/;
      /*localMsg (NM_I_ClearStatusField);*/
      /* Fall through to reset_all.
      */
     }
   }

   
   case reset_all:
   {
     me->num_located = 0;
     ME.super_cmd->state = start;
     break;
   }  
     
   default:
   {
    ERROR(OM_E_ABORT, EMS_E_Fail, "NMnmbool_exec action garbage", wrapup);
    break;
   }

  } /*end switch */


  switch(ME.super_cmd->state)
  {
    IGRlong locKey, accKey, relKey;

   case start:
   {
    locate_mask = GRm_DATA | GRm_BACK_UP;
    accept_mask = GRm_DATA;   

    switch(me->num_located)
    {
      case 0:
      {
        me->is_hilited = FALSE;
        output_inters = FALSE;
        if(ME.super_cmd->mytype == SPLIT)
         {
	  dosplit = TRUE;
          locKey = NM_P_IdPrimarySfSl;
          accKey = NM_P_AccWSecSfSl;
         }
        else
         {
	  dosplit = FALSE;
	  bool_type = NMbool_intersect;
          locKey = NM_P_IdSfSlTrimWrt;
          accKey = NM_P_AccWithEleToTrim;
         }

        break;
      }
     
      case 1:
      {
	if(ME.super_cmd->mytype == SPLIT)
	 {
          locKey = NM_P_IdSecSfSl;
          accKey = NM_P_AccWSecSfSl;
	 }
	else
	 {
          locKey = NM_P_IdEleToTrim;
          accKey = NM_P_AccWithEleToTrim;
	 }
        break;
      }
    
      default:
      {
        locate_mask |= GRm_RJT_MOVEON;
       if(ME.super_cmd->mytype == SPLIT)
        {
         locKey = NM_P_IdSecSfSlEnough;
         accKey = NM_P_AccWSecSfSl;
        }
       else
        {
         locKey = NM_P_IdEleToTrimEnough;
         accKey = NM_P_AccWithEleToTrim;
        }
       break;
      }
    }

    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
    display_flag = LC_ERASE_LOC_ELEMENT |
                        NO_PROJ_ACCEPT_POINT |
                        ALL_WINDOWS |
                        LC_ACCEPT_CURSOR |
                        ELEM_HILIGHT;
    attr.properties = LC_LC_ONLY |  LC_DP_ONLY | LC_RW;

    attr.owner_action = LC_FLEX_COMP | LC_FLEX_OWNER |
                        LC_RIGID_OWNER | 
                        (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED);

    if (me->num_located)
    {
     /*rclass[1] = OPP_GRbspline_class_id;*/
     rclass[0] = OPP_EMSsubbs_class_id;
     rtree_classes.w_count = 1;
     eliclass[0] = OPP_EMSsurface_class_id;
     eliclass[1] = OPP_NMnonmani_class_id;
     elig_classes.w_count = /*2*/ 1;               

     relKey = EMS_I_EltNotLocated;
     if(ME.super_cmd->mytype == SPLIT) attr.owner_action |= LC_RIGID_COMP;
    }
    else
    {
     attr.owner_action |= LC_RIGID_COMP;
     rtree_classes.w_count = 1;
     elig_classes.w_count = 1;
     rclass[0] = OPP_EMSsubbs_class_id;
     eliclass[0] = OPP_EMSsurface_class_id;
        
     relKey = EMS_I_SfSlNotLocated;
    }


   strcpy(attr.classes, "GRvg");

   rtree_classes.p_classes = rclass;
   elig_classes.p_classes = eliclass;

   {
    extern      IGRlong EFlocate_action_handler();
    struct      EMSaction_handler already_located;

    locate_mask |= GRm_STRING;
    if ( me->num_located == 0) 
      accept_mask |= GRm_STRING;
    already_located.next = NULL;
    already_located.option = 0;
    already_located.type = 1;	/* Passing GRids */
    already_located.num_objects = me->num_located;
    already_located.objects.id = me->located_ids;

    lc$locate(rc = &msg, 
              event1 = &me->locate_event, 
              event2 = &me->accept_event,  /*Mod by DLB 08/04/88*/
              event3 = &loc_obj_event,     /*Added by DLB 08/04/88*/
              mask1 = locate_mask, 
              mask2 = accept_mask, 
              eventsize= &size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              unhilight_mode = (enum GRdpmode) GRhd,
              locate_key = locKey,
              acc_key = accKey,
              relocate_key = relKey, 
              attributes = &attr, 
              act_handler = EFlocate_action_handler,
              act_args = &already_located,
              stack = &me->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);
   }

#if DEBUG
    fprintf(stderr,"\nloc_event.response = %d", me->locate_event.response);
    fprintf(stderr,"\nacc_event.response = %d", me->accept_event.response);
    fprintf(stderr,"\nloc_obj_event.response = %d", loc_obj_event.response);
    fprintf(stderr,"\nloc_stk.#entries = %d", me->locate_stack.num_entries);
    fprintf(stderr,"\nloc_stk.#loc = %d", me->locate_stack.number_located);
#endif

    if (msg == LC_OBJ_LOCATED) /*Something was located.*/
    {
      me->locate_event.num_id = loc_obj_event.num_id;
      me->locate_event.located_object[0] = loc_obj_event.located_object[0];
      me->locate_event.response = me->accept_event.response; /*correct it*/
    }
    else if (me->locate_stack.num_entries)
      me->locate_event.response = me->accept_event.response; 
    else if (me->locate_event.response == EX_DATA)    
      me->locate_event.response = EX_BACK_UP; /*Backed out of acc/rjt*/

    token = GRloc_token(&msg, Tokens, &me->locate_event);

    break;                                               
   }                                                     
                                                         
                                                         
   case prepsf:
   {                                                     
     if (me->num_located)                                
     { 
      struct GRid    tempid;
      struct GRevent tempevent;                         
      IGRint	     event_size;
      IGRlong	     event_mask = locate_mask, locsts, event_msg;
      extern OM_S_OBJID	current_creator;

      tempid.objid = me->located_ids[me->num_located-1].objid;
      tempid.osnum = me->locate_info.located_obj.osnum; 

      /* Put a loopset on the element.
      */
      current_creator = tempid.objid;
      sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(&msg, 
	    &me->ModuleInfo.md_env, NULL, NULL, NULL, NULL), 
	    targetid = tempid.objid, targetos = tempid.osnum);
      current_creator = NULL_OBJID;
      ERROR(sts, msg, "NMnmbool_exec create LS", wrapup);

      locate_mask = GRm_BACK_UP;                        
      msg = EMS_I_NoResponse;
      event_msg = MSSUCC;
      save_rsp = me->locate_event.response;  /*save the response*/
      tempevent = me->locate_event;          /*save the data event*/

      if( (me->num_located == 1) && (ME.super_cmd->mytype != SPLIT))
       {    
        sts = om$send (msg = message EMSsurface.EMshow_normals (&msg,
              &me->ModuleInfo, &ME.COconst->ActiveDisplay, GRhd), 
              targetid = tempid.objid, targetos = tempid.osnum);
        ERROR(sts, msg, "NMnmbool_exec show normals", wrapup);

        event_size = sizeof (struct GRevent);
        event_mask |= (GRm_TEXT_VALUE | GRm_RJT_MOVEON);

        locsts = co$getevent (
                 msg = &event_msg,
                 event_mask = event_mask,
                 msgnum = NM_P_KeepIndicatedSide, 
                 response = response,
                 response_data = response_data,
                 event = &tempevent);

        localMsg (EMS_P_ClearPromptField);
        if (sts != OM_I_STOP_SENDING)
         {
          sts = om$send (msg = message EMSsurface.EMshow_normals (&msg,
                &me->ModuleInfo, &ME.COconst->ActiveDisplay, GRhe), 
	        targetid = tempid.objid, targetos = tempid.osnum);
          ERROR(sts, msg, "NMnmbool_exec erase normals", wrapup);
         }

        /* If the user simply enters <CR>, take same action as <move_on>
	*/
        if(event_msg == GRw_no_value)
         {
	  tempevent.response = EX_RJT_MOVEON;
	  event_msg = MSSUCC;
         }

        ERROR(locsts, event_msg, "NMnmbool_exec normals getevent", wrapup);
       }

      if (msg == EMS_I_NoResponse)
       {
        if (save_rsp == EX_BACK_UP)
         tempevent.response = EX_BACK_UP;
        else
         tempevent.response = STRING;
       }
      else if (tempevent.response == STRING)
       {
        if (toupper (tempevent.event.keyin[0]) == 'N') 
	 bool_type = NMbool_union;
       }
      else if (tempevent.response == EX_RJT_MOVEON) 
       {
        tempevent.response = STRING;
        tempevent.event.keyin[0] = '\0';
       }

      token = GRloc_token(&msg, Tokens, &tempevent);
     }
     else
       token = 0;  /*SIMULATE A EX_BACK_UP OP*/
     break;
   }


   case get_int:
   {
    if(ME.super_cmd->mytype == SPLIT)
     {
      localMsg(NM_P_DataForInters);

      locate_mask = GRm_BACK_UP | GRm_DATA;
     
      token = GRget_token(&eventmsg, Tokens, &locate_mask, 
                         &me->locate_event, &size, 
                         response, response_data);
      if (token == 1)		/* Got data */
       output_inters = TRUE;

     }
    else
     {
      localMsg(NM_P_OutIntChgState);

      locate_mask = GRm_BACK_UP | GRm_DATA | GRm_RJT_MOVEON;
     
      token = GRget_token(&eventmsg, Tokens, &locate_mask, 
                         &me->locate_event, &size, 
                         response, response_data);
      if (token == 1)		/* Got data */
       output_inters = TRUE;
      dosplit = TRUE;
     }

     break;
   }           

   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "NMnmbool_exec state garbage", wrapup);
     break;
   }

  } /*switch(state) */

  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 } while(Tokens[token] != GR_UNKNOWN_TYPE);
 return(sts);

 wrapup:
  *response = TERMINATE;
  return(OM_E_ABORT);

}

static void localMsg (msgnumb)
IGRlong msgnumb;
{
    ex$message (msgnumb = msgnumb);

    return;
}



static int localDisplay(msg, ModuleInfo, dismode, objid, objos)
long *msg;
struct GRmd_env *ModuleInfo;
enum GRdpmode dismode;
GRobjid objid;
GRspacenum objos;
{
 long sts;

 sts = om$send(msg = message GRgraphics.GRdisplay(msg,
                            &ModuleInfo->md_env.matrix_type,
                            ModuleInfo->md_env.matrix,
                            &dismode, &ModuleInfo->md_id),
			  senderid = NULL_OBJID, 
                          targetid = objid, targetos = objos);
 return (sts);
}

end implementation NMnmbool;
