/* ###################   APOGEE COMPILED   ################## */
class implementation ECdrop;

#include "EMS.h"
/*
Abstract
        This command will locate a composite object and drop its
        individual components, or after the at least one component has been
        dropped, those components will be dropped from the composite.

Return values
        Response contains information for the command server.
        If response is TERMINATE then the command is deleted by
        the command server.

Bugs
        Note the comments in the code where external routines
        do not behave as is expected.

History
        scw     08/14/94    clarified sleep method
	Tapadia 02/06/92    Modified for message sub system compliance	
        dhm     02/28/89    Added ifndef's for the I/DRAW product.
        DLB     04/13/88    Combined drop surface and curve into 1 unified
                            drop command.
        DLB     01/06/87    Creation date.
*/

#define DEBUG 0  /*Set to 1 if error strings are needed.*/

#include "msmacros.h"
#include "codef.h"
#include "ECdlb.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "grgs.h" 
#include "EMSmsgdef.h"
#include "lcmacros.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "EMSaction.h"
#include "EC_M.h"
#include "EC_P.h"
#include "EC_S.h"
#include "EC_I.h"
#include "DPdlist.h"

/* New Prototypes */
PROTO_DPdlist_set_partial_drop_mode

extern OMuword OPP_EMScomposite_class_id, OPP_GRbspline_class_id;
#ifndef IDRAW
  extern OMuword OPP_EMSsubbs_class_id;
#endif

from GRgraphics import GRdisplay;
from GRowner    import GRdrop, GRremove_components;

method wakeup(int pos)
{
  IGRint  sts=OM_S_SUCCESS, i;
  IGRlong msg=EMS_S_Success;
  enum GRdpmode display_mode;

  for (i = 0; i < me->num_located; i++)
  { 
    if (i == 0) display_mode = GRhhd;
    else display_mode = GRhd;

    sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                        &me->locate_info.module_info.md_env.matrix_type, 
                        me->locate_info.module_info.md_env.matrix, 
                        &display_mode, 
                        &me->locate_info.module_info.md_id),
                  targetid = me->located_ids[i],
                  targetos = me->locate_info.located_obj.osnum);
    ERROR(sts, msg, "display draw hi", wrapup);
  }

  wrapup:
   return(sts);
}


method super_cmd.sleep(int pos)
{
  IGRint sts=OM_S_SUCCESS,msg=EMS_S_Success;
  
  if (me->num_located) sts = dp$erase_hilite(msg = &msg);

  ex$message(msgnumb = EM_M_ClearMessageField);
  ex$message(msgnumb = EMS_I_ClearStatusField);
  ex$message(msgnumb = EMS_P_ClearPromptField);

   return(sts);
}


method execute(int *response; char *response_data; int pos)
{
 IGRint                sts=OM_S_SUCCESS, size=sizeof(struct GRevent), display_flag;
 IGRlong               msg;
 IGRint                locate_mask, accept_mask, token;
 enum     GRdpmode     display_mode;
 struct   GRlc_locate  attr;
 OM_S_CLASSLIST        rtree_classes, elig_classes;
 OMuword               rclass, eliclass[2];
 IGRchar               loc_prompt[54], acc_prompt[54], reloc_prompt[54];

 
#define NUM_TOKENS 4
 static int Tokens[NUM_TOKENS] =
 {
   EX_BACK_UP, DATA, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
 };

 enum actions
 {
   NIL, ERR, init, store_it, rem_it, drop
 };

#define NUM_STATES 2
 enum states
 {
   start, got_owner
 };

 static enum states NextState[NUM_STATES][NUM_TOKENS] =
 {
   /*  token:     BACK_UP    DATA       MOVEON UNK
   old state: */                                   
   /*start    */ {start,     got_owner, start, start     },
   /*got_owner*/ {got_owner, got_owner, start, got_owner }
 };

 static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
 {
   /*  token:     BACK_UP DATA      MOVEON UNK
   old state: */                                     
   /*start    */ {NIL,    store_it, NIL,   NIL }, 
   /*got_owner*/ {rem_it, store_it, drop,  NIL }
 };

 ex$message(msgnumb = EM_M_DropComposite);

 do
 {
  switch (ME.COconst->action)
  {
    case NIL:
    case ERR:
    {
      break;
    }


    case init:
    {
      me->num_located = 0;
      break;
    }


    case store_it:
    {
      if (! me->num_located)
        me->locate_info = me->locate_event.located_object[0];
      else
      {
        IGRlong qsize;

        qsize = sizeof(me->locate_event.event) + sizeof (IGRint);
        sts = ex$putque(msg = &msg, 
                        response = response, 
                        byte = &qsize,
                        buffer = (char *)&me->locate_event.event);
        ERROR(sts, EMS_S_Success, "put que", wrapup);
      }

      if (om$dimension_of(varray = me->located_ids) <= me->num_located)
      {
        sts = om$vla_set_dimension(varray = me->located_ids,
                                   size = me->num_located + 2);
        ERROR(sts, EMS_S_Success, "expand vla", wrapup);
      } 

      me->located_ids[me->num_located] = me->locate_event.located_object[0].
                                         located_obj.objid;
      me->num_located++;

/*
 * If the initial composite was located then get a list of
 * it's children.  This is done because we only want to let
 * the operator locate the children.
 */
      if (me->num_located == 1)
       {
        extern		IGRlong EMselective_fence();
        OMuword		eliclass[2];
        OM_S_CLASSLIST	elig_classes, no_classes;
        IGRlong		number_of_objects;
        struct		GRlc_info *objects;

        eliclass[0] = OPP_GRbspline_class_id;

#ifndef IDRAW
        eliclass[1] = OPP_EMSsubbs_class_id;
        elig_classes.w_count = 2;
#else
        elig_classes.w_count = 1;
#endif

        elig_classes.p_classes = eliclass;
        no_classes.w_count = 0;
        no_classes.p_classes = NULL;
        sts = EMselective_fence(
          &elig_classes,
          &no_classes, 
          &me->locate_info,
          TRUE,                  /* break_down_composites */
          FALSE,                 /* is_operation_readonly */
          my_id,
          &number_of_objects,
          &objects,
          &msg);
         if (! (1 & sts))
          me->num_children = 0;
         else
          {
           IGRlong	i;

           me->num_children = number_of_objects;
           sts = om$vla_set_dimension(
            varray = me->children,
            size = number_of_objects);
           for (i = 0; i < number_of_objects; i++)
            {
             me->children[i] = objects[i].located_obj.objid;
            }
           if (objects) free(objects);
          }
       } /* if (me->num_located == 1) */
      break;
    }   


    case rem_it:
    {
      me->num_located--;

      if (me->num_located == 0)
      {
        sts = dp$erase_hilite(msg = &msg);      
        ME.super_cmd->state = start;
      }
      else
      {
        display_mode = GRhhd;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                           &me->locate_info.module_info.md_env.matrix_type, 
                           me->locate_info.module_info.md_env.matrix, 
                           &display_mode, 
                           &me->locate_info.module_info.md_id),
                      targetid = me->located_ids[me->num_located],
                      targetos = me->locate_info.located_obj.osnum);
        ERROR(sts, msg, " display erase hi", wrapup);
      }

      break;
    }


    case drop:
    {
      ex$message(msgnumb = EMS_I_00003);
      ex$message(msgnumb = EMS_P_ClearPromptField);
  
      sts = dp$erase_hilite(msg = &msg);

      if (me->num_located == 1)
      {
        DPdlist_set_partial_drop_mode( FALSE );
        sts = om$send(msg = message GRowner.GRdrop(&msg,
                            &me->locate_info.module_info),
                      targetid = me->located_ids[0],
                      targetos = me->locate_info.module_info.md_id.osnum);
        if (COERROR(sts) || COERROR(msg))
	  ex$message(msgnumb = EMS_S_CantDropComposite)
      }
      else
      {
        IGRint i;
        struct GRobj_env *component_list = NULL;

        DPdlist_set_partial_drop_mode( TRUE );
        me->num_located--;

        component_list = (struct GRobj_env *) om$malloc(
                         size = me->num_located * sizeof(struct GRobj_env));
        if (!component_list)
          ERROR(OM_S_SUCCESS, EMS_E_NoDynamicMemory, "malloc", wrapup)

        for (i=0; i<me->num_located; i++)
        {
          component_list[i].mod_env = me->locate_info.module_info;
          component_list[i].obj_id.objid = me->located_ids[i+1];
          component_list[i].obj_id.osnum = 
                            me->locate_info.module_info.md_id.osnum;
        }

        sts = om$send(msg = message GRowner.GRremove_components(&msg,
                            &me->locate_info.module_info,
                            &me->num_located, component_list),
                      targetid = me->located_ids[0],
                      targetos = me->locate_info.module_info.md_id.osnum);
        if (COERROR(sts) || COERROR(msg))
        {
          if (me->num_located == 1) 
		ex$message(msgnumb = EMS_S_CantRemComp)
          else 
		ex$message(msgnumb = EMS_S_CantRemComps)
        }       

        if (component_list) om$dealloc(ptr = component_list);
      }

      ex$message(msgnumb = EMS_I_ClearStatusField);

      me->num_located = 0;

      break;
    }


    default:
      ERROR(OM_E_ABORT, msg, "action garbage", wrapup)

  }


  switch(ME.super_cmd->state)
  {
    case start:
    case got_owner:
    {
      if (me->num_located == 0)
      {
        display_flag = ELEM_HILIGHT | 
                       NO_PROJ_ACCEPT_POINT;
        locate_mask = GRm_DATA;

	ex$message(msgnumb = EMS_P_IdenCompEle, buff = loc_prompt);   
	ex$message(msgnumb = EMS_P_AccCompRej, buff = acc_prompt);   
	ex$message(msgnumb = EMS_P_CompNotFound, buff = reloc_prompt);   

        attr.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP | 
                            (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED);

        eliclass[0] = OPP_EMScomposite_class_id;
        elig_classes.w_count = 1;
      }
      else
      {
        display_flag = ELEM_HILIGHT | 
                       NO_PROJ_ACCEPT_POINT |
                       LC_ERASE_LOC_ELEMENT;
        locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;

        if (me->num_located == 1)
		ex$message(msgnumb = EMS_P_IdenFiCompMoDrComp,
			buff = loc_prompt) 
        else
		ex$message(msgnumb = EMS_P_IdenNxtCompMoDrComp,
			buff = loc_prompt)

        if (me->num_located > 2) strcat(loc_prompt,"s");

	ex$message(msgnumb = EMS_P_AccNxtCompRej, buff = acc_prompt); 
	ex$message(msgnumb = EMS_S_ComponentNotFound, buff = reloc_prompt); 

        attr.owner_action = LC_RIGID_COMP | LC_OBJ_W_OWNER | LC_FLEX_COMP;
        eliclass[0] = OPP_GRbspline_class_id;

#ifndef IDRAW
        eliclass[1] = OPP_EMSsubbs_class_id;
        elig_classes.w_count = 2;
#else
        elig_classes.w_count = 1;
#endif
      }

      accept_mask = GRm_DATA;   

      attr.properties = 0x11 | LC_RW;
      strcpy(attr.classes, "GRvg");

      rtree_classes.w_count = 1;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
      rclass = OPP_GRvg_class_id;
      rtree_classes.p_classes = &rclass;
      elig_classes.p_classes = eliclass;
/*
 * Modified to call an action handler which allows only
 * components of the composite to be located and does not
 * allow relocate of components already located.
 *
 * 09/26/88 : rlw
 */
     {
      extern	IGRlong EFlocate_action_handler();
      struct	EMSaction_handler already_located[2];

      already_located[0].next = &already_located[1];
      already_located[0].option = 0;
      already_located[0].type = 2;
      already_located[0].num_objects = me->num_located;
      already_located[0].objects.same_space.space_number = 
       me->locate_info.located_obj.osnum;
      already_located[0].objects.same_space.objid = &me->located_ids[0];

      already_located[1].next = NULL;
      already_located[1].option = 1;
      already_located[1].type = 2;
      if (me->num_located > 0)        /* Do we have the composite? */
       already_located[1].num_objects = me->num_children;
      else
       already_located[1].num_objects = 0;
      already_located[1].objects.same_space.space_number = 
       me->locate_info.located_obj.osnum;
      already_located[1].objects.same_space.objid = &me->children[0];

      lc$locate(rc = &msg, 
                event1 = &me->locate_event, 
                event2 = &me->locate_event,
                mask1 = locate_mask, 
                mask2 = accept_mask, 
                eventsize= &size, 
                display_flag = display_flag,
                unhilight_mode = (me->num_located ? GRhd : GRhhd),
                response = response, 
                response_data = response_data, 
                locate_prompt = loc_prompt, 
                acc_prompt = acc_prompt,
                relocate_prompt = reloc_prompt, 
                attributes = &attr, 
                act_handler = EFlocate_action_handler,
                act_args = &already_located[0],
                stack = &me->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);
     }
  
     token = GRloc_token(&msg, Tokens, &me->locate_event);
     break;
   }


   default:
     ERROR(OM_E_ABORT, msg, "state garbage", wrapup)

  }

  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 } while(Tokens[token] != GR_UNKNOWN_TYPE);
 
 return (sts);

 wrapup:
   *response = TERMINATE;
   return(OM_E_ABORT);
}
end implementation ECdrop;
