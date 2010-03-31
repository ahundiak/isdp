/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This command is intended to provide a fast way to create
 parts by combining make face and lift face with certain
 restrictions.  Basically only planar surfaces are supported
 and the curves must be both closed and planar.  In additon
 ambiguous grouping cases are not supported and the lift
 direction must be normal to the planar surface.

 History

 08/14/94 : scw : clarified sleep method
 06/10/92 :Rustagi : Message sub-system Compliance
 08/08/91 : scw : Converted to use gr$dpb associative flag
 07/29/91 Tapadia : Modified to store the parents on make & lift face instead 
		    of macro object. Extensive changes made. 
 05/17/91 Tapadia : Make the command associative. Changed co$getevent to
	   	    ems$getevent. Added GRevent dist_eve in the instance data
 06/21/90 : BL  : Added a solid macro object on top of make_and_lift_face 
		  object such that it can handle several states for UNDO.
 22 May 1989 jBk  Changed comments from referring to GRlclocate to
                  refer to lc$locate.
 01/30/89 : rlw : Allow rigid children as curves
 09/12/88 : rlw : Change command name
 08/22/88 : DLB : Removed tree checking code.
 07/26/88 : rlw : Creation date
 */

class implementation ECfastlift;

#define DEBUG 0                 /*Set to 1 to print error strings.*/

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "ems_m_inc.h"
#include "EMSopt.h"             /* Has display options on undo */
#include "EMSmsgdef.h"          /* Defines EMS error return codes */
#include "EMSasmacros.h"	/* ems$getevent */
#include "OMmacros.h"
#include "EMSasopts.h"
#include "EMSdpb.h"
#include "emsdef.h"
#include "EMSdpb.h"

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    fprintf(stderr, "\n*************************");\
    fprintf(stderr, "\nIn ECfastlift error condition encountered");\
    fprintf(stderr, "\n%s", error_message, " Error");\
    fprintf(stderr, "\nError number %d", error_number, "\n");\
    om$report_error(sts = sts_stupid);\
    fprintf(stderr, "\n*************************\n");\
    goto wrapup;\
   }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    goto wrapup;\
   }\
 }
#endif

method delete(int f_defer_flag)
{
 IGRlong        sts;
 IGRint 	i;
/*
 * Clean out my local memory
 */
 if (me->number_of_datum_surfaces)
  {
   for (i = 0; i < me->number_of_datum_surfaces; i++)
    {
     if (me->lift_packet[i].curves)
      {
       free(me->lift_packet[i].curves);
       free(me->lift_packet[i].distances);
      }
    } /* for (i = 0; i < me->number_of_datum_surfaces; i++) */
   free(me->lift_packet);
  } /* if (me->number_of_datum_surfaces) */
/*
 * Death
 */
 sts = om$send(
   mode = OM_e_wrt_message,
   msg = message ECbase.delete(f_defer_flag),
   targetid = my_id);
  return(sts);
}

from GRgraphics import GRdisplay;
from EMSsurface import EMgetactiveid;
from EMSsurface import EMmake_active_state;
from EMSsfmacro import EMcreate_yourself;

extern OMuword OPP_EMSsubbs_class_id, OPP_EMSslmacro_class_id;
extern OMuword OPP_GRbspline_class_id, OPP_GRcurve_class_id;

%safe
static  IGRlong rlw_return_to_cmd_server(); /* It's in this file */
%endsafe

method execute(int *response; char *response_data; int pos)
{
 enum           GRdpmode DisplayMode;
 IGRchar        locate_prompt[80];
 IGRlong        object_was_located, msg, mask, sts;
 IGRlong        locate_mask, accept_mask, key;
 IGRint 	i, cp, nds, nc, number_of_groups = 0;
 struct         GRevent event, accept_event;
 struct GRid 	macro_obj;
 extern IGRlong EFgen_make_lift_face();

/*
 * Wakeup logic.  We must announce ourselves and
 * display the active datum surface, if any, in half highlight.
 * In addition we must highlight the curves in the active
 * packet, if any.
 */
 ex$message(msgnumb = EM_M_MkeAndLftFce);
 if (me->number_of_datum_surfaces &&
     (me->state != 1))
  {
   struct       GRid *id;
   struct       GRlc_info *lc_info;
   struct       GRmdenv_info *mdenv_info;

   cp = me->number_of_datum_surfaces - 1;
   id = &me->lift_packet[cp].datum_surface.located_obj;
   mdenv_info = &me->md_env.md_env;
   DisplayMode = GRhhd;
   sts = om$send(
     msg = message GRgraphics.GRdisplay(
      &msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix, 
      &DisplayMode,
      &me->display_env.md_id),
     targetid = id->objid,
     targetos = id->osnum);
    ERROR(sts, msg, "GRgraphics.GRdisplay")
   DisplayMode = GRhd;
   for (i = 0; i < me->lift_packet[cp].number_of_curves; i++)
    {
     lc_info = &me->lift_packet[cp].curves[i];
     id = &lc_info->located_obj;
     mdenv_info = &lc_info->module_info.md_env;
     sts = om$send(
       msg = message GRgraphics.GRdisplay(
        &msg,
        &mdenv_info->matrix_type,
        mdenv_info->matrix, 
        &DisplayMode,
        &me->display_env.md_id),
       targetid = id->objid,
       targetos = id->osnum);
      ERROR(sts, msg, "GRgraphics.GRdisplay error")
    } /* for (i = 0; i < me->lift_packet[cp].number_of_curves; i++) */
  } /* if (me->number_of_datum_surfaces) */
/*
 * Enter infinite loop
 */
 do
  {
   switch(me->state)
    {
/*
 * Room for growth
 */
     case 0:
      me->state = 1;
/*
 * Get the datum surface
 */
     case 1: 
      locate_mask = GRm_DATA;
      accept_mask = GRm_DATA;
      i = me->number_of_datum_surfaces + 1;
      if (i > 1)
       {
        key = EMS_P_00139;      /* Identify surface x/move on */
        locate_mask |= GRm_BACK_UP | GRm_RJT_MOVEON;
       }
      else
       key = EMS_P_00062;       /* Identify surface x */
      ex$message(
       msgnumb = key,
       type = "%d",
       var = `i`,
       buff = locate_prompt)
      {
       IGRlong          display_flag;
       struct           GRlc_locate attributes;
       OMuword          r_classes[5], e_classes[5];
       OM_S_CLASSLIST   rtree_classes, eligible_classes;

       display_flag = 
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_HALF_HIGHLIGHT       |       /* Use 1/2 hilite */
        LC_ERASE_ALL;                   /* Nothing else is in hilite */
       attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_ONLY          |       /* Planar surfaces only */
        LC_WRITE_ONLY;                  /* I am going to write */
       attributes.owner_action = 
       LC_FLEX_COMP   | LC_LOCALMOD |
        LC_RIGID_COMP  |
        LC_RIGID_OWNER |
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_EMSsubbs_class_id;
       e_classes[0] = OPP_EMSsubbs_class_id;
       sts = lc$locate(
         rc =                   &object_was_located,
         event1 =               &me->locate_event,
         event2 =               &accept_event,
         mask1 =                locate_mask,
         mask2 =                accept_mask,
         display_flag =         display_flag,
         hilight_mode =         (enum GRdpmode) GRhhd,
         unhilight_mode =       (enum GRdpmode ) GRhd,  /* Don't unhilite */
         locate_prompt =        locate_prompt,
         acc_key =              EMS_P_00038,
         relocate_key =         EMS_I_00011,
         attributes =           &attributes,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &eligible_classes);
       ERROR(sts, object_was_located, "lc$locate error")
      }
      ex$message(msgnumb = EMS_I_00000)
      if (!object_was_located)
       {
/*
 * If the user backups up at a request for a datum surface
 * then our lift is a bitch.  This means that we must undo
 * the last packet and rehighlight all the curves that the
 * user gave to build that packet.
 */
        if (me->locate_event.response == EX_BACK_UP)
         {
          IGRushort deactivate_option;
          IGRint        display_count, invoke_count;
          GRobjid       *display_ids;
          struct        GRid *undo_to, *id;
          struct        GRlc_info *lc_info;
          struct        GRmdenv_info *mdenv_info;

          cp = me->number_of_datum_surfaces - 1;
          undo_to = &me->lift_packet[cp].top_state_before;
          deactivate_option = EMS_UNDO_DELETE | 
                              EMS_DO_DISPLAY;
          display_count = 0;
          display_ids = NULL;
          invoke_count = 0;
          sts = om$send(
            msg = message EMSsurface.EMmake_active_state(
             &msg,
             &deactivate_option,
             &me->md_env,
             NULL,              /* Active ids after undo */
             NULL,              /* Number of active ids - better be 1 */
             NULL,              /* Space manager for memory on active ids */
             &display_ids,      /* Used for internal management */
             &display_count,    /* Used for internal management */
             &invoke_count),    /* Used for internal management */
            targetid = undo_to->objid,
            targetos = undo_to->osnum);
           ERROR(sts, msg, "EMSsurface.EMmake_active_state");
          me->top_lm_state = *undo_to;
/*
 * Redraw the curves in highlight
 */
          DisplayMode = GRhd;
          for (i = 0; i < me->lift_packet[cp].number_of_curves; i++)
           {
            lc_info = &me->lift_packet[cp].curves[i];
            id = &lc_info->located_obj;
            mdenv_info = &lc_info->module_info.md_env;
            sts = om$send(
              msg = message GRgraphics.GRdisplay(
               &msg,
               &mdenv_info->matrix_type,
               mdenv_info->matrix, 
               &DisplayMode,
               &me->display_env.md_id),
              targetid = id->objid,
              targetos = id->osnum);
             ERROR(sts, msg, "GRgraphics.GRdisplay error")
           } /* for (i = 0; i < me->lift_packet[cp].number_of_curves; i++) */
/*
 * Redraw the datum surface in highlight
 */
          id = &me->lift_packet[cp].datum_surface.located_obj;
          mdenv_info = &me->md_env.md_env;
          DisplayMode = GRhhd;
          sts = om$send(
            msg = message GRgraphics.GRdisplay(
             &msg,
             &mdenv_info->matrix_type,
             mdenv_info->matrix, 
             &DisplayMode,
             &me->display_env.md_id),
            targetid = id->objid,
            targetos = id->osnum);
           ERROR(sts, msg, "GRgraphics.GRdisplay")
          me->state = 2;
         }
        else if (me->locate_event.response == EX_RJT_MOVEON)
         me->state = 4;
        else
         {
          if (rlw_return_to_cmd_server(response, msg))
           return(OM_S_SUCCESS);
         }
       }
/*
 * We got a datum surface
 */
      else
       {
        IGRboolean      bad_surface;
        struct          GRid active_state, *sf_id;

        bad_surface = FALSE;
        nds = me->number_of_datum_surfaces;
/*
 * Find out who owns this sucker
 */
        sf_id = &accept_event.located_object[0].located_obj;
        sts = om$send(
          msg = message EMSsurface.EMgetactiveid(
           &msg,
           &active_state,
           NULL),   /*DLB*/
          targetid = sf_id->objid,
          targetos = sf_id->osnum);
         ERROR(sts, msg, "EMSsurface.EMgetactiveid")
/*
 * If we already have some datum surfaces then
 * we must ensure that this surface is in the same
 * solid as the others.
 */
        if (nds)
         {
          if ((active_state.objid != me->top_lm_state.objid) ||
              (active_state.osnum != me->top_lm_state.osnum))
           {
            ex$message(msgnumb = EMS_S_SfmstInSmSolid);
            bad_surface = TRUE;
           }
         } /* if (nds) */
/*
 * If we don't have any datum surfaces yet then
 * we must ensure that there are no booleans
 * on the state tree.
 */
        else
         {
           me->top_lm_state = active_state;   /*DLB*/
           me->md_env = accept_event.located_object[0].module_info;
         } /* ELSE FOR if (nds) */
/*
 * Create a new packet and add this datum surface
 */
        if (! bad_surface)
         {
          if (me->lift_packet)
           {
            me->lift_packet = (struct lift_packet *) realloc(
              me->lift_packet,
              sizeof(struct lift_packet) * (nds + 1));
           } /* if (me->lift_packet) */
          else
           {
            me->lift_packet = (struct lift_packet *) malloc(
              sizeof(struct lift_packet));
           } /* ELSE FOR if (me->lift_packet) */
          if (! me->lift_packet)
           {
            ERROR(OM_E_ABORT, MANOMEMORY, "No memory could be found")
           }
          me->lift_packet[nds].top_state_before = me->top_lm_state;
          me->lift_packet[nds].curves = NULL;
          me->lift_packet[nds].distances = NULL;
          me->lift_packet[nds].number_of_curves = 0;
          me->lift_packet[nds].datum_surface.located_obj = *sf_id;
          me->number_of_datum_surfaces++;
          me->state = 2;
         } /* if (! bad_surface) */
/*
 * Take the surface out of highlight if
 * it was not accepted 
 */
        else
         {
          sts = dp$erase_hilite(
            msg = &msg,
            osnum = me->display_env.md_id.osnum,
            objid = me->display_env.md_id.objid);
           ERROR(sts, msg, "Erasing surface")
         } /* ELSE FOR if (! bad_surface) */
       }
      break;
/*
 * Get the profile curves which are to be imposed on the
 * active datum surface.
 */
     case 2:
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;
      cp = me->number_of_datum_surfaces - 1;
      i = me->lift_packet[cp].number_of_curves + 1;
      if ((i > 1) ||            /* If I have more than one curve */
          cp)                   /* If I have more than one datum */
       {
        key = EMS_P_00037;      /* Identify curve x/move on */
        locate_mask |= GRm_RJT_MOVEON;
       }
      else
       key = EMS_P_00035;       /* Identify curve x */
      ex$message(
       msgnumb = key,
       type = "%d",
       var = `i`,
       buff = locate_prompt)
      {
       IGRlong          display_flag;
       struct           GRlc_locate attributes;
       OMuword          r_classes[5], e_classes[5];
       OM_S_CLASSLIST   rtree_classes, eligible_classes;

       display_flag = 
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite */
        LC_ERASE_LOC_ELEMENT;           /* Erase just the element */
       attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_ONLY          |       /* Planar surfaces only */
        LC_RW;                          /* I'm only going to read */
       attributes.owner_action = 
        LC_FLEX_COMP   |
        LC_RIGID_COMP  |
        LC_RIGID_OWNER |
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_GRbspline_class_id;
       e_classes[0] = OPP_GRcurve_class_id;
       sts = lc$locate(
         rc =                   &object_was_located,
         event1 =               &me->locate_event,
         event2 =               &accept_event,
         mask1 =                locate_mask,
         mask2 =                accept_mask,
         display_flag =         display_flag,
         unhilight_mode =       (enum GRdpmode ) GRhd,  /* Don't unhilite */
         locate_prompt =        locate_prompt,
         acc_key =              EMS_P_00038,
         relocate_key =         EMS_I_00010,
         attributes =           &attributes,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &eligible_classes);
       ERROR(sts, object_was_located, "lc$locate error")
      }
      ex$message(msgnumb = EMS_I_00000)
      if (!object_was_located)
       {
/*
 * If the user backups up and we don't have any curves
 * then we must toss the datum surface.  Otherwise
 * we go and ask for the sweep distance again.
 */
        if (me->locate_event.response == EX_BACK_UP)
         {
          if (i == 1)           /* Asking for the first curve */
           {
            me->number_of_datum_surfaces--;
            if (me->lift_packet[cp].curves)
             {
              free(me->lift_packet[cp].curves);
              free(me->lift_packet[cp].distances);
             }
            sts = dp$erase_hilite(
              msg = &msg,
              osnum = me->display_env.md_id.osnum,
              objid = me->display_env.md_id.objid);
             ERROR(sts, msg, "Erasing datum surface")
            me->state = 1;
           }
          else
           me->state = 3;
         }
/*
 * If this was the first curve in the packet then we are done.
 * Otherwise we must make and lift the required faces.
 */
        else if (me->locate_event.response == EX_RJT_MOVEON)
         {
          if (i == 1)           /* Asking for the first curve */
           me->state = 4;
/*
 * Time to do something useful.
 */
          else
           {
            IGRboolean  discard_packet;
            struct      GRid *id, made_face, top_lm_before, top_lm_after;
            struct      GRmdenv_info *mdenv_info;
/*
 * Erase the data which is highlighted
 */
            sts = dp$erase_hilite(
              msg = &msg,
              osnum = me->display_env.md_id.osnum,
              objid = me->display_env.md_id.objid);
             ERROR(sts, msg, "Erasing datum surface")
/*
 * Load the active construction information.
 * Note that the surfaces must be constructed in the
 * same module as the solid, not in the active module.
 */
            sts = om$send(
              msg = message ECbase.load_construction_information(NULL),
              targetid = my_id);
             ERROR(sts, me->msg, "load construction info")
            me->construct_list.msg = &msg;
            me->construct_list.env_info = &me->md_env;
/*
 * Let's make the face
 */
            top_lm_before = me->top_lm_state;
	
            sts = EFgen_make_lift_face(
	      	2, /* Part type is fast make lift - Don't ever change this */
              	&me->md_env,
              	&me->lift_packet[cp].datum_surface.located_obj,
              	me->lift_packet[cp].number_of_curves,
              	me->lift_packet[cp].curves,
	     	me->dist_eve, FALSE, NULL, me->is_associative ? NULL:
		EMSasconst_notassociative,
              	&me->construct_list,
              	&top_lm_before,
              	my_id,
              	&top_lm_after,
              	&made_face,
	  	&number_of_groups,
              	&msg);

            discard_packet = (! (1 & sts));

/*
 * Erase the curves out of the highlight plane, as we will
 * start on another make/lift packet.
 */
            sts = dp$erase_hilite(
              msg = &msg,
              osnum = me->display_env.md_id.osnum,
              objid = me->display_env.md_id.objid);
             ERROR(sts, msg, "Erasing hilite")
/*
 * If the operation failed then pretend as if
 * the user never gave us these curves.
 */
            if (discard_packet) {
              me->number_of_datum_surfaces--;
              free(me->lift_packet[cp].curves);
              free(me->lift_packet[cp].distances);
              me->state = 1;
            } /* if (discard_packet) */
            else {
	      IGRint  num_states;

	    /* 
	     *  Create a macro object on top of the make_and_lift_face 
	     *  object because this macro object can handle several 
	     *  states for UNDO.
	     */

	      macro_obj.osnum = me->top_lm_state.osnum;

      	      sts = om$construct(classid = OPP_EMSslmacro_class_id,
      			p_objid = &macro_obj.objid,
      			osnum = macro_obj.osnum);
      	      ERROR(sts, 1, "construct error");
	     
  	      /* There are 2 states (make face & lift face) in each group */

  	      num_states = number_of_groups * 2;

  	      sts = om$send(msg = message EMSsfmacro.EMcreate_yourself(&msg, 
			top_lm_after.objid, num_states, 
			&me->md_env),
                	targetid = macro_obj.objid,
			targetos = macro_obj.osnum);
  	      ERROR(sts, msg, "EMcreate_yourself");
/*
 * Go ahead and guess that the user will want his next datum surface
 * to be the lifted surface.
 */
              me->top_lm_state = macro_obj;
              nds = me->number_of_datum_surfaces;
              me->lift_packet = (struct lift_packet *) realloc(
                me->lift_packet,
                sizeof(struct lift_packet) * (nds + 1));
               if (! me->lift_packet) {
                 ERROR(OM_E_ABORT, MANOMEMORY, "No memory could be found")
                }
              me->lift_packet[nds].top_state_before = me->top_lm_state;
              me->lift_packet[nds].curves = NULL;
              me->lift_packet[nds].distances = NULL;
              me->lift_packet[nds].number_of_curves = 0;
              me->lift_packet[nds].datum_surface.located_obj = made_face;
              me->number_of_datum_surfaces++;
/*
 * Highlight the new datum surface
 */
              DisplayMode = GRhhd;
              id = &made_face;
              mdenv_info = &me->md_env.md_env;
              sts = om$send(
                msg = message GRgraphics.GRdisplay(
                 &msg,
                 &mdenv_info->matrix_type,
                 mdenv_info->matrix, 
                 &DisplayMode,
                 &me->display_env.md_id),
                targetid = id->objid,
                targetos = id->osnum);
               ERROR(sts, msg, "GRgraphics.GRdisplay")
             } 
           } /* ELSE FOR if (i == 1) */
         }
        else /* Object not located and event wasn't backup or move on */
         {
          if (rlw_return_to_cmd_server(response, msg))
           return(OM_S_SUCCESS);
         }
       }
/*
 * We got another curve.  Check to make sure that
 * the curve is physically closed.
 */
      else
       {
        extern          IGRlong EFgetprops();
        struct          GRprops properties;

        sts = EFgetprops(
          &accept_event,
          my_id,
          &properties,
          &msg);
         if (! (1 & sts)) goto wrapup;
        if (!properties.phy_closed)
         {
          struct        GRlc_info *lc_info;
          struct        GRmdenv_info *mdenv_info;
          struct        GRid *id;

          ex$message(msgnumb = EMS_I_00014)  /* Curve is not closed */
          DisplayMode = GRhe;
          lc_info = &accept_event.located_object[0];
          id = &lc_info->located_obj;
          mdenv_info = &lc_info->module_info.md_env;
          sts = om$send(
            msg = message GRgraphics.GRdisplay(
             &msg,
             &mdenv_info->matrix_type,
             mdenv_info->matrix, 
             &DisplayMode,
             &me->display_env.md_id),
            targetid = id->objid,
            targetos = id->osnum);
           ERROR(sts, msg, "GRgraphics.GRdisplay")
         } /* if (!properties.phy_closed) */
        else
         {
          nc = me->lift_packet[cp].number_of_curves++;
          if (me->lift_packet[cp].curves) {
            	me->lift_packet[cp].curves = (struct GRlc_info *) realloc(
              		me->lift_packet[cp].curves, sizeof(struct GRlc_info) * 
			me->lift_packet[cp].number_of_curves);
            	me->lift_packet[cp].distances = (IGRdouble *) realloc(
              		me->lift_packet[cp].distances, sizeof(IGRdouble) * 
			me->lift_packet[cp].number_of_curves);
	    	if(om$dimension_of(varray = me->dist_eve) <= (nc + 1)) {
			sts = om$vla_set_dimension(varray = me->dist_eve,
				size = nc + 4);
			ERROR(sts, msg, "execute.vla_set_dimension");
	    	}
	   }
          else
           {
            me->lift_packet[cp].curves = (struct GRlc_info *) malloc(
              sizeof(struct GRlc_info));
            me->lift_packet[cp].distances = (IGRdouble *) malloc(
              sizeof(IGRdouble));
           }
          if (! (me->lift_packet[cp].curves  && me->lift_packet[cp].distances))
           {
            ERROR(OM_E_ABORT, MANOMEMORY, "No memory could be found")
           }
          me->lift_packet[cp].curves[nc] = accept_event.located_object[0];
          me->state = 3;
         } /* ELSE FOR if (!properties.phy_closed) */
       }
      break;
/*
 * Get sweep distance for each profile curve
 */
     case 3:
      cp = me->number_of_datum_surfaces - 1;
      nc = me->lift_packet[cp].number_of_curves;
      mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON;
      if (nc > 1)
       {
        extern          IGRlong EFconvert_to_user_units();
        IGRchar         distance_string[80];
        IGRdouble       default_distance;

        distance_string[0] = '\0';
        default_distance = me->lift_packet[cp].distances[nc - 2];
        sts = EFconvert_to_user_units(
          default_distance,
          TRUE,                 /* Want master string */
          distance_string,
          &msg);
         ERROR(sts, msg, "EFconvert_to_user_units")
        ex$message (msgnumb = EMS_P_KyinSwepDistVar, type = "%s",
                   var = `distance_string`, buff = locate_prompt);
       }
      else {
        ex$message(msgnumb = EMS_P_KyinSwepDist, buff = locate_prompt);
      }
      sts = ems$getevent(
        msg =           &msg,
        event_mask =    mask,
        prompt =        locate_prompt,
        value_type =    GRIO_DISTANCE,
        response =      (long *)response,
        response_data = response_data,
        event =         &event);
       ERROR(sts, msg, "ems$getevent")
      ex$message(msgnumb = EMS_I_00000)
      if (event.response == GR_UNKNOWN_TYPE) {
        if (rlw_return_to_cmd_server(response, msg))
         return(OM_S_SUCCESS);
      }
      else if (event.response == EX_BACK_UP) {
        struct  GRlc_info *lc_info;
        struct  GRmdenv_info *mdenv_info;
        struct  GRid *id;

        DisplayMode = GRhe;
        lc_info = &me->lift_packet[cp].curves[nc - 1];
        id = &lc_info->located_obj;
        mdenv_info = &lc_info->module_info.md_env;
        sts = om$send(
          msg = message GRgraphics.GRdisplay(
           &msg,
           &mdenv_info->matrix_type,
           mdenv_info->matrix, 
           &DisplayMode,
           &me->display_env.md_id),
          targetid = id->objid,
          targetos = id->osnum);
         ERROR(sts, msg, "GRgraphics.GRdisplay")
        me->lift_packet[cp].number_of_curves--;
        me->state = 2;
      }
      else {
        if ((msg == GRw_no_value) ||
            (event.response == EX_RJT_MOVEON)) {
          if (nc > 1) {
            IGRdouble   default_distance;

            default_distance = me->lift_packet[cp].distances[nc - 2];
            me->lift_packet[cp].distances[nc - 1] = default_distance;
	    /* Assign the event value == 0.0 if no event occurs */
	    me->dist_eve[nc -1].event.value = 0.0;
            me->state = 2;
          }
          else {
            ex$message(msgnumb = EMS_I_00006) /* No default is supplied */
          }
        }
        else {
 	  OM_BLOCK_MOVE(&event, &me->dist_eve[nc - 1], sizeof(struct GRevent)); 
          me->lift_packet[cp].distances[nc - 1] = event.event.value;         
          if (event.event.value == 0.0) {
            ex$message(msgnumb = EMS_I_00009) /* Invalid value */
          }
          else
           me->state = 2;
        }
      }
      break;
/*
 * Process - Note that since the lifts were done
 * along the way all we have to do is clear out
 * the instance data and start all over again.
 */
     case 4:
      if (me->number_of_datum_surfaces) {
        for (i = 0; i < me->number_of_datum_surfaces; i++) {
          if (me->lift_packet[i].curves) {
            free(me->lift_packet[i].curves);
            free(me->lift_packet[i].distances);
          }
        } /* for (i = 0; i < me->number_of_datum_surfaces; i++) */
        free(me->lift_packet);
        me->lift_packet = NULL;
        me->number_of_datum_surfaces = 0;
      } /* if (me->number_of_datum_surfaces) */
      sts = dp$erase_hilite(
        msg = &msg,
        osnum = me->display_env.md_id.osnum,
        objid = me->display_env.md_id.objid);
       ERROR(sts, msg, "Erasing hilite")
      me->state = 0;
      break;
/*
 * Something has messed up our state table
 */
     default:
      ERROR(OM_E_ABORT, 0, "Default state reached")
    }
  }
 while(TRUE);
/*
 * eof
 */
wrapup:
 *response = TERMINATE;
 ex$message(msgnumb = EMS_F_0002)
 return(OM_E_ABORT);
}

method wakeup(int pos)
{
    IGRlong  	sts;
    IGRboolean  state;

    sts = om$send (mode = OM_e_wrt_parent,
                   msg = message ECfastlift.wakeup (pos),
                   targetid = my_id);
    if (!(1 & sts)) return(OM_E_ABORT);

    /* Get the dpb variables */

    gr$get_associative_flag( buffer = &state );
    if (state) {
     	GRdisplay_associative_button(TRUE);
     	me->is_associative = TRUE;
    }
    return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
 IGRint sts=OM_S_SUCCESS;

 sts = om$send (mode = OM_e_wrt_parent,
                msg = message ECfastlift.sleep(pos),
                targetid = my_id);

 if (me->is_associative) GRdisplay_associative_button(FALSE);

  return(sts);
}

/*
 Description

 This function will determine whether the command object should
 return the users input to the command server.

 History

 07/23/88 : rlw : Creation date

 */
static IGRlong rlw_return_to_cmd_server(response, msg)
 int *response;
 int msg;
{
 IGRboolean     return_to_cmd_server;

 return_to_cmd_server = TRUE;
 switch (*response)
  {
   case EX_STRING:
    if (msg == GRw_no_value)
     return_to_cmd_server = FALSE;
    break;
   case EX_RJT_MOVEON:
   case EX_DATA:
   case EX_BACK_UP:
   case EX_OBJID:
   case EX_RESTART:
    return_to_cmd_server = FALSE;
    break;
   default:
/*  noop; */
    break;
  }
/*
 * eof
 */
 if (! return_to_cmd_server)
  {
   ex$message(msgnumb = EMS_I_00005)            /* Input discarded */
  }
 return(return_to_cmd_server);
}

end implementation ECfastlift;
