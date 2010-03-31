/* ###################   APOGEE COMPILED   ################## */
class implementation ECmirror;

#include <stdio.h>                      /* Needed for print statements */
#include "griodef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "griodef.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "lcmacros.h"

#include "exmacros.h"                   /* Has ex$putque */
#include "maerr.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "godef.h"
#include "dpdef.h"
#include "EMSasopts.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsdef.h"

#include "ECcmd.h"
#include "ECmsg.h"
#include "EMSascmacros.h"

# ifndef DEBUG
# define DEBUG 0  /*Set to 1 if want error strings printed.*/
# endif

#define IDENTIFY_OBJECT 2
#define IDENTIFY_REFERENCE_PLANE 1
#define PROCESS 3

#define MIRROR_COPY 0
#define EXPORT_COPY 2

from GRgraphics   import GRdisplay, GRgetprops;
extern OMuword OPP_GRvg_class_id, OPP_EMSdatpln_class_id,
               OPP_SKmgr_class_id,
               OPP_ACconst_class_id,
               OPP_EMSplane_class_id,
               OPP_GRcurve_class_id, OPP_EMSsurface_class_id;

method super_cmd.sleep(int pos)
{
 long sts = OM_S_SUCCESS;
 long msg;

 /* clear fields */
 ex$message( field=PROMPT_FIELD, 
             msgnumb = EMS_P_00000 );
 ex$message( field = ERROR_FIELD, 
             msgnumb = EMS_I_00000 );
 ex$message (field=MESSAGE_FIELD, 
             msgnumb = EMS_I_00000 );

 if (me->is_associative)
  GRdisplay_associative_button(FALSE);

 if (me->element_count)
 {
    sts = dp$erase_hilite(msg = &msg);
 }

 return(sts);
}

method execute(int *response; char *response_data; int pos)
{
  long sts,msg;
  int locate_mask, accept_mask,display_flag;
  enum GRdpmode display_mode;
  struct GRlc_locate attributes;
  OMuword r_classes[5], e_classes[5];
  OM_S_CLASSLIST        rtree_classes, eligible_classes;
  struct GRevent accept_event;

  sts = OM_S_SUCCESS;
  msg = MSSUCC;

  accept_mask = GRm_DATA | GRm_TEXT_VALUE;

  if (me->mytype == 0)
  {
   ex$message (field=MESSAGE_FIELD, 
              msgnumb = EM_M_CrMrCpRfPl,
              justification=CENTER_JUS );
  }
  else if (me->mytype == 1) 
  {
   ex$message (field = MESSAGE_FIELD,
               msgnumb = EM_M_CpInPlc,
              justification=CENTER_JUS );
  }
 else
   ex$message (field = MESSAGE_FIELD,
               msgnumb = EM_M_PrepSfMod,
               justification=CENTER_JUS );

 
  display_flag = 
       ELEM_HILIGHT                |  /* Hilite the whole element */
       NO_PROJ_ACCEPT_POINT        |  /* Don't project the accept point */
       ACC_REJ_CYCLE               |  /* Run through accept reject cycle */
       RELOCATE                    |  /* Relocate if none found */
       LC_REGULAR_HIGHLIGHT        |  /* Use regular hilite not 1/2 */
       LC_ERASE_ALL;                  /* Erase the hilite plane */
 
  attributes.properties = 
         LC_LC_ONLY                |  /* Locate locatable objects */
         LC_DP_ONLY                |  /* Locate displayable objects */
         IGN_MOD_BIT               |  /* Ignore modified and new props */
         LC_PLANAR_NON_PLANAR      ;  /* Planarity doesn't matter */
 
  rtree_classes.w_flags = OM_CLST_subclass;
  rtree_classes.p_classes = &r_classes[0];
  eligible_classes.w_flags = OM_CLST_subclass;
  eligible_classes.p_classes = &e_classes[0];
  attributes.properties |= LC_RW;

  attributes.owner_action = LC_FLEX_COMP | 
                            LC_RIGID_OWNER |
                            LC_RIGID_COMP |
                           (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED);

  /*
   * Enter infinite loop.
   */
  do
  {
   switch (ME.super_cmd->state)
   {
     case 0:
      if (me->mytype == MIRROR_COPY)
       ME.super_cmd->state = IDENTIFY_REFERENCE_PLANE;
      else 
      {
       ME.super_cmd->state = IDENTIFY_OBJECT;
       ME.ECmirror->ref_pln_info.located_obj.objid = NULL_OBJID;
      }
     break;

     case IDENTIFY_REFERENCE_PLANE:
       locate_mask =  GRm_DATA | GRm_BACK_UP | GRm_TEXT_VALUE;
       rtree_classes.w_count = 1;
       eligible_classes.w_count = 2;
       r_classes[0] = OPP_GRvg_class_id;
       e_classes[0] = OPP_EMSdatpln_class_id;
       e_classes[1] = OPP_EMSplane_class_id;
       attributes.owner_action = attributes.owner_action | LC_HANDLES;

       sts = lc$locate(
         rc               = &msg,
         event1           = &me->locate_event,
         event2           = &accept_event,
         mask1            =  locate_mask,
         mask2            =  accept_mask,
         display_flag     =  display_flag,
         locate_key       =  EMS_P_IdPlFcRfPl,
            /* Identify reference plane/planar face */
         acc_key       =  EMS_P_00101, /* Accept with element/Reject */
         attributes       = &attributes,
         relocate_key  =  EMS_I_EltNotLocated, /* Element not located */
         stack            = &me->locate_stack,
         rtree_classes    = &rtree_classes,
         eligible_classes = &eligible_classes);

       if (!(1&sts)) return (OM_S_SUCCESS);
       
       if (!(1&msg))
       {
        if (ME.ECmirror->locate_event.response == EX_BACK_UP)
        {
        }
        else
         return(OM_S_SUCCESS);
       }
       else
       {
         IGRlong putque_size;
         ME.ECmirror->ref_pln_info = accept_event.located_object[0];

         sts = dp$erase_hilite(msg = &msg);
         if (!(1&sts&msg)) return (OM_E_ABORT);

         /*
          * Put the accept event onto the queue
          */
         if ( (accept_event.response == EX_DATA) ||
              (accept_event.response == EX_STRING) )
         {
            putque_size = sizeof(accept_event.event) + sizeof (int) ;
            sts = ex$putque( msg = &msg, 
                             response = response,
                             byte = &putque_size, 
                             buffer = (IGRchar *) &accept_event.event);
            if (!(1&sts)) return (OM_E_ABORT);
         }
         ME.super_cmd->state = IDENTIFY_OBJECT;
      }
      break;

    case IDENTIFY_OBJECT:
    {
     int prompt_key;
     IGRint (*act_handler) (); 
     extern int ppah_for_locating_entity_in_cm();

     rtree_classes.w_count = 1;
     if (me->mytype != EXPORT_COPY)
     {
      r_classes[0] = OPP_GRvg_class_id;
      eligible_classes.w_count = 4;
      e_classes[0] = OPP_EMSsurface_class_id;
      e_classes[1] = OPP_EMSdatpln_class_id;
      e_classes[2] = OPP_GRcurve_class_id;
      e_classes[3] = OPP_SKmgr_class_id;
      attributes.owner_action &= ~LC_HANDLES;
      act_handler = NULL;
     }
     else
     {
      eligible_classes.w_count = 1;
      r_classes[0] = OPP_GRvg_class_id;
      e_classes[0] = OPP_EMSsurface_class_id;
      act_handler = ppah_for_locating_entity_in_cm;
     }


     locate_mask = GRm_RJT_MOVEON | GRm_DATA | GRm_BACK_UP | GRm_TEXT_VALUE;

     if (me->element_count == 0)
       /* Identify element */
       prompt_key = EMS_P_00033;
     else
       /* Identify next elementd/moveon to end */
       prompt_key = EMS_P_IdNxElCpMvOnEnd; 

     attributes.owner_action |= LC_NO_REF_HEADER | LC_REF_OBJECTS;

     sts = lc$locate(
         rc               = &msg,
         act_handler      = act_handler,
         event1           = &me->locate_event,
         event2           = &accept_event,
         mask1            =  locate_mask,
         mask2            =  accept_mask,
         display_flag     =  display_flag,
         locate_key       =  prompt_key,
         acc_key          =  EMS_P_00101,
         attributes       = &attributes,
         relocate_key     =  EMS_I_EltNotLocated,
         stack            = &me->locate_stack,
         rtree_classes    = &rtree_classes,
         eligible_classes = &eligible_classes);

     if (!(1&sts)) return (OM_S_SUCCESS);
       
     if (!(1&msg))
     {
        if (ME.ECmirror->locate_event.response == EX_BACK_UP)
        {
          if (me->element_count)
          {
            om$send (msg = message ECmirror.display_constructions(GRhe, TRUE),
                     targetid = my_id);
            --(me->element_count);
          }
          else
          {
           if (me->mytype == MIRROR_COPY)
            ME.super_cmd->state = IDENTIFY_REFERENCE_PLANE;
          }
        }
        else if (ME.ECmirror->locate_event.response == EX_RJT_MOVEON)
        {
          ME.super_cmd->state = PROCESS;
        }
        return(OM_S_SUCCESS);
     }
     else
     {
        long putque_size, vla_size;

        vla_size = om$dimension_of(varray=me->element_info);
        if ((me->element_count+1) > vla_size)
        {
           om$vla_set_dimension(varray = me->element_info,
                                size = me->element_count + 5);
        }

           ME.ECmirror->element_info[me->element_count] = 
              accept_event.located_object[0];

        ++(me->element_count);

        display_mode = GRhe;

        om$send (msg = message ECmirror.display_constructions(GRhe, TRUE),
                 targetid = my_id);

        om$send (msg = message ECmirror.display_constructions(GRhhd, TRUE),
                 targetid = my_id);

        /*
         * Put the accept event onto the queue
         */

        if ( (accept_event.response == EX_DATA) ||
             (accept_event.response == EX_STRING) ) 
        {
            putque_size = sizeof(accept_event.event) + sizeof (int) ;
            sts = ex$putque( msg = &msg, 
			     response = response,
                             byte = &putque_size, 
			     buffer = (IGRchar *) &accept_event.event);
            if (!(1&sts)) return (OM_E_ABORT);
        }
     }
     break;
    }


    case PROCESS:
    {
     struct GRvg_construct const_list;
     struct GRlc_info *cur_info;
     int i;
     OM_S_OBJID res_id;

     const_list.msg = &msg;
     const_list.env_info = &me->md_env;
     const_list.newflag = FALSE;
     const_list.level = ME.ECelement->active_level;
     const_list.properties = GRIS_DISPLAYABLE | GRIS_NEW | GRIS_LOCATABLE;
     const_list.geometry = NULL;
     const_list.display = &ME.ECelement->active_display;
     const_list.class_attr = NULL;
     const_list.name = NULL;
     sts = dp$erase_hilite(msg = &msg);
     if (!(1&sts&msg)) return (OM_E_ABORT);
  
     if (me->mytype != EXPORT_COPY)
     {
     for (i=0;i<me->element_count;i++)
     {
       cur_info = &ME.ECmirror->element_info[i];
/*****************************************************************************
       sts = EFplace_mirror_copy(&msg,
                                 (me->is_associative ? 
                                  NULL : EMSasconst_notassociative),
                                 cur_info,
                                 &ME.ECmirror->ref_pln_info,
                                 &const_list, &res_id);
*****************************************************************************/
       sts = ems$place_mirror_copy(msg = &msg,
         options = (me->is_associative ? NULL : EMSasconst_notassociative),
                                   elem_info = cur_info,
                             ref_pln_info = &ME.ECmirror->ref_pln_info,
                            construction_list = &const_list,
                            resultant_obj = &res_id);
       if (!(1&sts&msg))
       {
         ex$message( field = ERROR_FIELD, 
                     msgnumb = EMS_E_ConstFail );
                     /* Construction failed */
       }
       else
       {
         display_mode = GRbd;
         sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &display_mode,
                          &me->md_env.md_id),
                       targetid = res_id,
                       targetos = const_list.env_info->md_id.osnum);
         if (!(1&sts&msg))  return (OM_E_ABORT);
       }
     }
     }
     else
   {
    for (i=0;i<me->element_count;i++)
    {
     cur_info = &ME.ECmirror->element_info[i];
     EFplace_consume_copy(&msg, 
                          (me->is_associative ? 
                           NULL : EMSasconst_notassociative),
                           cur_info,
                           &const_list, 
                           &res_id);
     if (!(1&msg))
     {
      UI_status("Export failed");
     }
    }
   }

     if (me->mytype == MIRROR_COPY)
      ME.super_cmd->state = IDENTIFY_REFERENCE_PLANE;
     else
      ME.super_cmd->state = IDENTIFY_OBJECT;
     me->element_count = 0;

    }
    break;
   } /* end switch */
  } while (TRUE);
}

method wakeup (int pos)
{
 long sts = OM_S_SUCCESS;
 
 sts = om$send (msg = message ECmirror.wakeup(pos),
                mode = OM_e_wrt_parent,
                targetid = my_id);

 {
   gr$get_associative_flag( buffer = &me->is_associative ); 
   if (me->is_associative)
    GRdisplay_associative_button(TRUE);
 }

 if (me->element_count)
 {
  om$send (msg = message ECmirror.display_constructions(GRhhd,FALSE),
           targetid = my_id);
 }

 return(sts);
}

method display_constructions(enum GRdpmode display_mode; int last_one)
{
 long sts,msg;
 int i;
 struct GRid *cur_obj;

 sts = OM_S_SUCCESS;

 if (last_one)
 {
  cur_obj = &me->element_info[me->element_count - 1].located_obj;
  sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                      &me->md_env.md_env.matrix_type,
                      me->md_env.md_env.matrix,
                      &display_mode,
                      &me->md_env.md_id),
                   targetid = cur_obj->objid,
                   targetos = cur_obj->osnum);
  if (!(1&sts&msg))  return (OM_E_ABORT);
 }
 else
 {
  for (i=0;i<me->element_count;i++)
  {
   cur_obj = &me->element_info[i].located_obj;
   sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                      &me->md_env.md_env.matrix_type,
                      me->md_env.md_env.matrix,
                      &display_mode,
                      &me->md_env.md_id),
                   targetid = cur_obj->objid,
                   targetos = cur_obj->osnum);
   if (!(1&sts&msg))  return (OM_E_ABORT);
  }
 }
 return (sts);
}

/*
 * The following function serves as the action handler for preventing the 
 * locate of solids/surfaces who are not owned by a construction macro.
 * pp 07/26/92
 */

ppah_for_locating_entity_in_cm(
 info,
 new_entry,
 locate_args,
 action)

IGRchar *info;
struct	GRlc_info *new_entry;
struct	LC_action_args *locate_args;
enum	GRlocate_action *action;

{
 IGRboolean	call_action_handler;
 IGRlong msg_loc;
 IGRlong	sts;
/*
 * Initialize
 */
 call_action_handler = TRUE;

 switch (*action)
  {
   case add_all:
   case add_inside:
   case add_outside:
   case add_overlap:
   case add_nopost:
   {
     IGRlong	i;
     IGRshort graphics_props;
     struct	GRlc_info *object;
     struct	GRid check_id, *search_id, temp_GRid;
     OM_S_CHANSELECT to_owners;

     search_id = &new_entry->located_obj;
/*
 * See if the guy that was identified has a rigid owner.
 */
     graphics_props = 0;
     sts = om$send (msg = message GRgraphics.GRgetprops(&msg_loc,
                          &graphics_props),
                    senderid = NULL_OBJID,
                    targetid = search_id->objid,
                    targetos = search_id->osnum);
     if (!(1&sts&msg_loc)) return (OM_S_SUCCESS);

     if (graphics_props & GR_RIGID_RELATIONSHIP)
      {
       EMmake_chanselect(GRconnector_to_owners, &to_owners);

       sts = om$get_objid_at_index( osnum = search_id->osnum,
                                    objid = search_id->objid,
                                    p_chanselect = &to_owners,
                                    index = 0,      
                                    objidaddr = &temp_GRid.objid,
                                    osnumaddr = &temp_GRid.osnum);
       if (!(1&sts))
       {
        return (OM_S_SUCCESS);
       }
/*
 * If the owner of the entity being located is not a subclass of
 * construction macro, then the surface/solid does not have any
 * business getting located.
 * pp 07/26/92
 */
       if (!(EFisAncestryValid(&msg_loc,temp_GRid.objid, temp_GRid.osnum,
                             OPP_ACconst_class_id, FALSE)))
        call_action_handler = FALSE;
      }
      else
      {
       call_action_handler = FALSE;
      }
      break;
     }
   

/*
 * If the action is not to add then let the
 * regular action handler take care of the 
 * situation.
 */
   case start_transition:
   case end_transition:
   case post_object:
   case check_object:
    break;
  } /* switch (*action) */
/*
 * Call the action handler
 */
 if (call_action_handler)
  {
   extern IGRlong LCptlocact();

   sts = LCptlocact(NULL, new_entry, locate_args, action);
  }
 else
  sts = OM_S_SUCCESS;
/*
 * Eof
 */
 return(sts);
}
end implementation ECmirror;

