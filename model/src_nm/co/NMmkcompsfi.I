class implementation NMnmmkcompsf;

#include "EMS.h"
#include "EMSopt.h"

# ifndef DEBUG
# define DEBUG 0
# endif

#include <stdio.h>
#include "codef.h"
#include "ECdlb.h"
#include "igr.h"
#include "igrtypedef.h"
#include "griodef.h"
#include "exdef.h"
#include "EMSmsgdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSlmdef.h"
#include "grgsdef.h"    /* Needed for the macros */
#include "grgsmacros.h" /* gr$gsput_locate_criteria() */
#include "ECcmd.h"       /* Command strings */
#include "NMcmd.h"       /* Command strings */
#include "NMmsg.h"
#include "ECmsg.h"
#include "EMSaction.h"  /* Structure definition for select handler */
#include "emsdef.h"
#include "EMSdpb.h"

/* AND, ISNT ... */
# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif
                                        
#if DEBUG
#define ERRORs(sts_stupid, error_number, error_message, label)\
 {\
        if (EMSmsgReport (sts_stupid, error_message, FALSE) OR \
                EMSmsgReport (error_number, error_message, FALSE)) \
                goto label; \
 }
#else
#define ERRORs(sts_stupid, error_number, error_message, label)\
 {\
  if (! (1 & sts_stupid)) goto label;\
 }
#endif

from GRgraphics         import GRdisplay;
from NMnonmanist	import NMperform_stitch;

extern OMuword OPP_NMnonmanist_class_id, OPP_GRcurve_class_id, 
               OPP_EMSsurface_class_id, OPP_EMSsubbs_class_id, 
	       OPP_NMnonmani_class_id;
	
        
method init (IGRint type; IGRchar *string)
{
 IGRint sts=OM_S_SUCCESS;
 IGRlong msg=EMS_S_Success;
 IGRboolean is_assoc = TRUE;

 sts = om$send(mode = OM_e_wrt_message, 
	       msg = message COconst.init(type, string), 
	       targetid = my_id);
 ERROR(sts, msg, "COconst.init", wrapup);

 gr$get_associative_flag(buffer = &me->dpb_assoc_flag);

 if(!me->dpb_assoc_flag)
  gr$put_associative_flag(buffer = &is_assoc);

 GRdisplay_associative_button(TRUE);

wrapup:
 return(sts);
}




method wakeup(int pos)
{
 enum GRdpmode Display_Mode = GRhhd;
 IGRint sts=OM_S_SUCCESS,i;
 IGRboolean is_assoc = TRUE;
 IGRlong msg = EMS_S_Success;

 if (me->num_located)
 { 
   for (i = 0; i < me->num_located; i++)
   { 
     sts = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay(&msg, 
                        &me->locate_info.module_info.md_env.matrix_type, 
                        me->locate_info.module_info.md_env.matrix, 
                        &Display_Mode, 
                        &me->locate_info.module_info.md_id),
                   targetid = me->surf_info[i].objid,
                   targetos = me->locate_info.located_obj.osnum);
     ERRORs(sts, msg, "NMnmmkcompsf_wake draw hi", wrapup);
   }
 }


 gr$get_associative_flag(buffer = &me->dpb_assoc_flag);

 if(!me->dpb_assoc_flag)
  gr$put_associative_flag(buffer = &is_assoc);


  GRdisplay_associative_button(TRUE);

wrapup:
  return(sts);
}


method super_cmd.sleep(int pos)
{
 IGRint sts=OM_S_SUCCESS;
 IGRlong msg=EMS_S_Success;

 sts = dp$erase_hilite(msg = &msg);
 ERRORs(sts, msg, "NMnmmkcompsf_sleep erase hi", wrapup);

 ex$message(msgnumb = EM_M_ClearMessageField)
 ex$message(msgnumb = EMS_I_00000)
 ex$message(msgnumb = EMS_P_00000)


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
 IGRint                sts, size=sizeof(struct GRevent),display_flag;
 IGRint                locate_mask, accept_mask, token, i, j;
 IGRint                count;
 enum     GRdpmode     Display_Mode;
 struct   GRlc_locate  attr;
 OM_S_CLASSLIST        rtree_classes, elig_classes;
 OMuword               rclass[3], eliclass[3];
 IGRlong               loc_key, acc_key, reloc_key,msg;
 IGRchar	       status_str[54];
 
#   define NUM_TOKENS 6
    /* */ static /* */ int Tokens[NUM_TOKENS] =
    {
        EX_BACK_UP, DATA, EX_OBJID, STRING, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
    };

    enum actions
    {
         NIL, ERR, rem_obj, store_obj, makecs
    };

#   define NUM_STATES 1
    enum states
    {
        start
    };

    static enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      BACK_UP DATA      OBJ    STRING   MOVEON   UNK
    old state: */                                   
    /* start    */ {start, start,     start, start,   start,   start }
    };

    static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      BACK_UP   DATA      OBJ      STRING MOVEON  UNK
    old state: */
    /* start    */ {rem_obj, store_obj, store_obj, NIL, makecs, NIL}
    }; 


 ex$message(msgnumb = NMC_M_GlueEdges)

 do
 {
  switch (ME.COconst->action)
  {

   case NIL:
   case ERR:
   {
     break;
   }
 
   case rem_obj:
   {
    if (me->num_located)
    {
      if (me->num_located == 1)
      {
        sts = dp$erase_hilite(msg = &msg);
        ERRORs(sts, msg, "NMnmmkcompsf_exec erase hi", wrapup);
      }
      else
      {
        Display_Mode = GRhe;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                          &me->locate_info.module_info.md_env.matrix_type,
                          me->locate_info.module_info.md_env.matrix,
                          &Display_Mode, 
                          &me->locate_info.module_info.md_id),
                    targetid = me->surf_info[me->num_located-1].objid,
                    targetos = me->locate_info.located_obj.osnum);
        ERRORs(sts, msg, "NMnmmkcompsf_exec erase", wrapup);
      }      
      me->num_located--;

    }
    break;
   }


   case store_obj:
   {
    IGRlong             number_of_objects;
    struct              GRlc_info *objects, static_object;
    OMuword             yeslist, nolist;
    OM_S_CLASSLIST      yes_classes, no_classes;
    extern              IGRlong EMselective_fence();

    number_of_objects = 0;
    objects = NULL;
/*
 * If a set was located then decompose it into leaf nodes ensuring
 * that only surfaces and composite surfaces are present.  Note that
 * I also go through this code if only a single object was located
 * and we have already located some objects.  This is done because
 * the code will discard solids as being not eligible.
 */

      yeslist = OPP_EMSsurface_class_id;
      yes_classes.w_count = 1;
      yes_classes.p_classes = &yeslist;
      nolist = OPP_GRcurve_class_id;
      no_classes.w_count = 1;
      no_classes.p_classes = &nolist;
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
       ERRORs(sts, msg, "NMnmmkcompsf_exec EMselective_fence", wrapup);

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
        if ((me->surf_info[i].objid == objects[j].located_obj.objid) ||
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
      IGRboolean        put_on_queue;
      IGRlong           total_count;

      put_on_queue = (me->num_located &&
       (me->locate_event.response != EX_OBJID));
      total_count = me->num_located + number_of_objects + 2; /* Conservative */
      sts = om$vla_set_dimension(
        varray = me->surf_info,
        size = total_count);
       ERRORs(sts, EMS_S_Success, "NMnmmkcompsf_exec expand vla", wrapup);
      for (i = 0; i < number_of_objects; i++)
       {
        me->surf_info[me->num_located] = objects[i].located_obj;       
        me->num_located = me->num_located + 1;
       } /* for (i = 0; i < number_of_objects; i++) */
/*
 * Put the accept event on the queue if the object
 * was not a specified object (fence).
 */
      if (put_on_queue)
       {
        sts = ex$putque(
          msg = &msg, 
          response = response, 
          byte = (IGRlong *) &size,
          buffer = (IGRchar *) &me->locate_event.event);
        ERRORs(sts, EMS_S_Success, "NMnmmkcompsf_exec put que", wrapup);
       } /* if (put_on_queue) */

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
          ERRORs(sts, msg, "NMnmmkcompsf GRdisplay", wrapup);
         } /* if (me->num_located) */
        else
         {
          sts = dp$erase_hilite(
            msg = &msg);
           ERRORs(sts, msg, "NMnmmkcompsf erase hilite", wrapup);
         } /* ELSE FOR if (me->num_located) */
       } /* if (me->locate_event.response != EX_OBJID) */
      ex$message(msgnumb = EMS_I_00092)
      sleep(2);
     }
/*
 * Free the memory
 */
    if (objects &&
        (objects != &static_object)) free(objects);

     break;

   } /* case store_obj: */


   case makecs:
   {
    IGRushort makecs_opt = NULL;
    struct GRvg_construct construct;    /*DECL*/

    sts = dp$erase_hilite(msg = &msg);
    ERRORs(sts, msg, "NMnmmkcompsf_exec erase hi", wrapup);

    construct.msg        = (IGRlong *)&msg;
    construct.class_attr = NULL;       /* use defaults */
    construct.level      = ME.COconst->ActiveLevel;
    construct.display    = &ME.COconst->ActiveDisplay;
    construct.env_info   = &me->locate_info.module_info;
    construct.newflag    = FALSE;
    construct.name       = NULL;
    construct.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    construct.geometry   = NULL;

    me->construct_id.osnum = me->locate_info.located_obj.osnum;
    sts = om$construct(classid = OPP_NMnonmanist_class_id,
                       p_objid = &me->construct_id.objid,
                       osnum = me->construct_id.osnum);
    ERRORs(sts, EMS_S_Success, "NMnmmkcompsf_exec construct", wrapup);

    makecs_opt = NULL;

    ex$message(msgnumb = EMS_P_00000)
    ex$message(msgnumb = EMS_I_Processing, buff = status_str);

    sts = om$send(msg = message NMnonmanist.NMperform_stitch(&msg, 
                        me->num_located, me->surf_info,
                        &me->locate_info.module_info, NULL, 0, 
		        NULL, NULL, makecs_opt, NULL, &construct, status_str),
                        targetid = me->construct_id.objid,
                        targetos = me->construct_id.osnum);

    if( (msg == EMS_E_NoDynamicMemory) || 
        (msg == EMS_E_DynamicMemoryAllocated))
     {
      ex$message(msgnumb = EMS_E_NoMemFewElem);
      msg = EMS_S_Success;
      sts = OM_S_SUCCESS;
      ME.super_cmd->state = start;
     }
    else
     {
      ERRORs(sts, msg, "NMnmmkcompsf_exec perform_stitch", wrapup);
      
      if (msg == EMS_I_Fail) /*Stitch failed.*/
       {
        OM_S_CHANSELECT       to_comps;  /*DECL*/

        ex$message(msgnumb = NM_I_EdgesNotGlued)
        sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
        ERRORs(sts, EMS_S_Success, "NMnmmkcompsf_exec mk chan sel", wrapup);

        sts = om$get_channel_count(objid = me->construct_id.objid,
                                   osnum = me->construct_id.osnum,
                                   p_chanselect = &to_comps,
                                   count = (OMuint *) &count);
        ERRORs(sts, EMS_S_Success, "exec get chan count", wrapup);

        if (!count)
         {
          /*Delete composite object.*/
          sts = om$send(msg = message Root.delete(0),
                        targetos = me->construct_id.osnum,
                        targetid = me->construct_id.objid);
          ERRORs(sts, msg, "NMnmmkcompsf_exec rt del", wrapup);
         }

        if(me->num_located == 1)
         {
          me->construct_id.objid = me->surf_info[0].objid;
          me->construct_id.osnum = me->locate_info.located_obj.osnum;
         }
       }
      else  /*It worked.*/
       { 
        if(msg == EMS_I_Interrupt)
         {
          ex$message(msgnumb = EMS_I_ProcessingInterrupt);
          sleep(3);
         }
        ex$message(msgnumb = NM_I_EdgesGlued) 

       }  /* Comp surf made */

     } /* else for no dynamic memory */

    me->num_located = 0;
    break;
   }


   default:
   {
     ERRORs(OM_E_ABORT, EMS_E_Fail, "action garbage", wrapup);
     break;
   }
  } /*end switch */


  switch(ME.super_cmd->state)
  {

   case start:
   {

    /*Set proper locate prompt*/
    if (me->num_located < 1)
    {
      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_OBJID;
      loc_key = EMS_P_00134;
      acc_key = EMS_P_AccSfSl;
      reloc_key = EMS_I_SfSlNotLocated;
      display_flag = ALL_WINDOWS | ELEM_HILIGHT |
        NO_PROJ_ACCEPT_POINT | LC_ERASE_ALL;
    }
    else
    {
      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_OBJID | GRm_RJT_MOVEON;
      loc_key = EMS_P_IdSfStEnough;
      acc_key = EMS_P_AccwSf;
      reloc_key = EMS_I_00011;
      display_flag = ALL_WINDOWS | ELEM_HILIGHT |
        NO_PROJ_ACCEPT_POINT | LC_ERASE_LOC_ELEMENT;
    }

    /*Set proper accept prompt*/
    accept_mask = GRm_DATA;   

    attr.properties = 
     LC_LC_ONLY         |       /* Locate locatable objects */
     LC_DP_ONLY         |       /* Locate displayable objects */
     IGN_MOD_BIT        |       /* Ignore modified and new props */
     IGN_PLANAR_BIT     |       /* Ignore planar checks */
     LC_WRITE_ONLY;             /* I am going to change is guy */
    attr.owner_action = 
     LC_ASSOCIATIVE     |       /* Associative elements */
     LC_EXTERN_CONSTRAINED |    /* Externally constrained assoc elements */
     LC_RIGID_OWNER     |       /* Composites */
     LC_FLEX_OWNER      |       /* Graphic groups, etc. */
     LC_FLEX_COMP       |       /* Members of graphic groups, etc. */
     LC_REF_OBJECTS     |       /* Objects in ref. files are allowed */
     LC_NO_REF_HEADER;          /* No reference file headers */

    rtree_classes.w_count = 1;
    elig_classes.w_count = 2;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass[0] = OPP_EMSsubbs_class_id;
    eliclass[0] = OPP_EMSsurface_class_id;
    eliclass[1] = OPP_NMnonmani_class_id;

    rtree_classes.p_classes = rclass;
    elig_classes.p_classes = eliclass;
/*
 * Call the graphic set deposit function.  This will help
 * us weed out garbage from the fence.
 */
    sts = gr$gsput_locate_criteria(
      msg = &msg,
      attributes = &attr,
      rtree_classes = &rtree_classes,
      eligible_classes = &elig_classes);
     ERRORs(sts, msg, "NMnmmkcompsf_exec gsput_locate_criteria", wrapup);
/*
 * End of graphic set deposit
 */
#   if DEBUG
    (void)print_queue ();
#   endif
/*
 * Modified to call an action handler which mark already located
 * objects as not eligible for locate.
 *
 * 09/26/88 : rlw
 */
   {
    extern      IGRlong EFlocate_action_handler();
    struct      EMSaction_handler already_located;

    already_located.next = NULL;
    already_located.option = 0;
    already_located.type = 1; /* Passing GRids */
    already_located.num_objects = me->num_located;
    already_located.objects.id = me->surf_info;
    lc$locate(rc = &msg, 
              event1 = &me->locate_event, 
              event2 = &me->locate_event,
              mask1 = locate_mask, 
              mask2 = accept_mask, 
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
   }

    token = GRloc_token(&msg, Tokens, &me->locate_event);
    break;
   }


   default:
   {
    ERRORs(OM_E_ABORT, EMS_E_Fail, "NMnmmkcompsf_exec state garbage", wrapup);
    break;
   }

  } /*switch(state) */

  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 } while(Tokens[token] != GR_UNKNOWN_TYPE);
 return sts;

 wrapup:
  ex$message(msgnumb = EMS_F_0002)
  *response = TERMINATE;
  return(OM_E_ABORT);

}
end implementation NMnmmkcompsf;
