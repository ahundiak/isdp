/* ###################   APOGEE COMPILED   ################## */
/*
 This command was originally written by Sajneev Saxena.

 rlw : ??/??/?? : Totally rewritten
 rlw : 05/20/87 : Put in hilite erase stuff, reduced ERROR macro
 pp  : 05/26/87 : Made additions so that a solid skinned solid is constructed
                  if desired
 pp  : 09/21/87 : Added code to check and see if the identified cross-sections
                  are planar and closed if a skinned solid is being 
                  constructed
 rlw : 01/03/87 : Converted to EMS 1.1 - Changed masks, routine names,
                  locate code, and reworked solid placement stuff.
 rlw : 04/26/88 : Totally reworked to show direction vectors, support
                  message subsystem, and fixed some very minor problems.
 rlw : 07/12/88 : Modified, as per Dieter's request, such that the default
                  answer for height scaling is yes.
 rlw : 09/12/88 : Modified to support suspend and non-suspend stuff
                  for the 1.2.0 release.
 rlw : 01/10/89 : Forgot to set pos on erasure of construction geometry.
 rlw : 10/20/89 : Fixed wraping problem when command is interupted.  Also
                  modified due to changes I made in the message keys.
 DLB : 06/04/91 : Support current creator.
 scw : 08/14/94 : Clarified sleep method

 BUGS

 I do not display the reference points that the user has input.  It's
 a bitch to do because this command branches in crazy ways.

 */

class implementation ECplcsknsf;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"
#include "EC_M.h"			/* Command strings */
#include "EC_P.h"			/* Prompt strings */
#include "EC_I.h"			/* Informational strings */
#include "EC_F.h"			/* Fatal strings */

from GRgraphics import GRdelete;
from GRcurve import GRendpts;
from IGEgragad import DPinrot;
from EMSgenbs import EMmove_cross_section;
from EMSsfsolid import EMcap_thyself;

#define SURFACE 0
#define SOLID 1

#define BIG_CURVE 0
#define LITTLE_CURVE 1
#define LITTLE_SURFACE 2
#define LITTLE_ELEMENT 3
#define ANY_ELEMENT 4
#define BIG_SURFACE 5

extern OMuword OPP_GRbspline_class_id;
extern OMuword OPP_GRcurve_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSsfsolid_class_id;

method display_constructions(
 IGRboolean	draw_background;
 IGRboolean	draw_single)
{
 me->msg = MSSUCC;
 return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
 IGRboolean	is_curve_reversed;
 IGRlong	i, sts, number_of_trace_vectors;
 struct		GRlc_info *lc_info;

/*
 * Do what my parent does
 */
 sts = om$send(
   mode = OM_e_wrt_message,
   msg = message ECconstruct.sleep(pos),
   targetid = my_id);
  ON_ERROR return(sts);
/*
 * Erase the vectors
 */
 if (pos == EX_suspend)
  {
   if (me->state == 2)
    number_of_trace_vectors = me->num_trace - 1;
   else
    number_of_trace_vectors = me->num_trace;
   for (i = 0; i < number_of_trace_vectors; i++)
    {
     lc_info = &me->trcobj[i];
     is_curve_reversed = lc_info->geom_parms.polygon_inx;
     sts = EFdisplay_curve_normal_or_tangent(
       lc_info,		/* The curve */
       NULL,		/* Not used for tangents */
       FALSE,		/* Display the tangent vector */
       is_curve_reversed,
       my_id,
       GRbe,		/* Erase */
       &me->display_env,
       &me->display,
       &me->msg);
      ON_ERROR return(sts);
    } /* for (i = 0; i < number_of_trace_vectors; i++) */
   for (i = 0; i < me->num_cross; i++)
    {
     lc_info = &me->crsobj[i];
     is_curve_reversed = lc_info->geom_parms.polygon_inx;
     sts = EFdisplay_curve_normal_or_tangent(
       lc_info,		/* The curve */
       NULL,		/* Not used for tangents */
       FALSE,		/* Display the tangent vector */
       is_curve_reversed,
       my_id,
       GRbe,		/* Erase */
       &me->display_env,
       &me->display,
       &me->msg);
      ON_ERROR return(sts);
    } /* for (i = 0; i < me->num_cross; i++) */
  } /* if (pos == EX_suspend) */
 return(sts);
}

method wakeup(int pos)
{
 IGRboolean	is_curve_reversed;
 IGRlong	i, sts, number_of_trace_vectors;
 struct		GRlc_info *lc_info;

/*
 * Do what my parent does
 */
 sts = om$send(
   mode = OM_e_wrt_message,
   msg = message ECconstruct.wakeup(pos),
   targetid = my_id);
  ON_ERROR return(sts);
/*
 * Draw the vectors
 */
 if (pos == EX_suspend)
  {
   if (me->state == 2)
    number_of_trace_vectors = me->num_trace - 1;
   else
    number_of_trace_vectors = me->num_trace;
   for (i = 0; i < number_of_trace_vectors; i++)
    {
     lc_info = &me->trcobj[i];
     is_curve_reversed = lc_info->geom_parms.polygon_inx;
     sts = EFdisplay_curve_normal_or_tangent(
       lc_info,		/* The curve */
       NULL,		/* Not used for tangents */
       FALSE,		/* Display the tangent vector */
       is_curve_reversed,
       my_id,
       GRbd,		/* Draw background */
       &me->display_env,
       &me->display,
       &me->msg);
      ON_ERROR return(sts);
    } /* for (i = 0; i < number_of_trace_vectors; i++) */
   for (i = 0; i < me->num_cross; i++)
    {
     lc_info = &me->crsobj[i];
     is_curve_reversed = lc_info->geom_parms.polygon_inx;
     sts = EFdisplay_curve_normal_or_tangent(
       lc_info,		/* The curve */
       NULL,		/* Not used for tangents */
       FALSE,		/* Display the tangent vector */
       is_curve_reversed,
       my_id,
       GRbd,		/* Draw background */
       &me->display_env,
       &me->display,
       &me->msg);
      ON_ERROR return(sts);
    } /* for (i = 0; i < me->num_cross; i++) */
  } /* if (pos == EX_suspend) */
 return(sts);
}

method execute(int *response; char *response_data; int pos)
{
 IGRchar        prompt[80];
 IGRboolean	put_on_queue, use_default, is_curve_reversed;
 IGRlong        event_mask, i, j, key, sts, msg, previous_state;
 struct		GRlc_info *lc_info;
 struct		RLW_locate_info loc_info;
/*
 * Initialize
 */
 if (me->mytype == SURFACE)
  ex$message(msgnumb = EM_M_0096)
 else
  ex$message(msgnumb = EM_M_0097)
/*
 * Enter infinite loop
 */
 do
  {
/*
 * I am trying to save the position of the command before it enters
 * the processing state so that I can backup to that state again
 * after processing.
 */
   if (me->state != 10)
    previous_state = me->state;
/*
 * Branch based on our state
 */
   switch(me->state)
    {
/*
 * Room for growth
 */
     case 0:
      me->previous_trace_count = me->num_trace;   /* Save for wrap around */
      me->previous_cross_count = me->num_cross;
      me->num_trace = 0;
      me->num_cross = 0;
      me->state = 1;
/*
 * Get the curves
 */
     case 1: 
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
      if (me->num_trace == 0)
       key = EMS_P_00122;                /* Identify trace 1 */
      else
       {
        event_mask |= GRm_RJT_MOVEON;    /* Identify trace 2/moveon */
        key = EMS_P_00123;
       }
      i = me->num_trace + 1;
      ex$message(
       msgnumb = key,
       type = "%d",
       var = `i`,
       buff = prompt)
      EFget_locate_information(
       BIG_CURVE,
       &loc_info);
      loc_info.acc_key = EMS_P_00107;  /* Accept with starting point/reject */
      sts = om$send(
        msg = message ECconstruct.locate_object(
         event_mask,
         prompt,
         LC_NO_MSG,             /* No locate key, use string */
         &loc_info,
         TRUE,                  /* Automatically put accept event on queue */
         &put_on_queue,         /* Is possible to put accept event on queue? */
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
      if (me->locate_stack.num_entries) return(OM_S_SUCCESS);
     switch (me->event.response)
      {
       case GR_UNKNOWN_TYPE:
        return(OM_S_SUCCESS);
       case EX_BACK_UP:
        {
         IGRboolean	wraping;

         wraping = ((me->number_of_events_input == 0) &&
                    me->have_a_constructed_object);
         if (wraping)
          {
           me->num_trace = me->previous_trace_count;
           me->num_cross = me->previous_cross_count;
          }
         sts = om$send(
           msg = message ECconstruct.backup_event(),
           targetid = my_id);
          ON_ERROR goto kill_command;
         if (wraping)
          {}
         else if (me->num_trace == 0)
          me->state = 0;
         else
          {
           me->state = 2;
           lc_info = &me->trcobj[0];
           is_curve_reversed = lc_info->geom_parms.polygon_inx;
           sts = EFdisplay_curve_normal_or_tangent(
             lc_info,		/* The curve */
             NULL,		/* Not used for tangents */
             FALSE,		/* Display the tangent vector */
             is_curve_reversed,
             my_id,
             GRbe,		/* Erase */
             &me->display_env,
             &me->display,
             &msg);
            ON_ERROR goto kill_command;
          }
        }
        break;
       case EX_RESTART:
        sts = om$send(
          msg = message ECconstruct.restart(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        break;
       case EX_RJT_MOVEON:
        sts = om$send(
          msg = message ECconstruct.add_event(
           FALSE),               /* Not a located object */
          targetid = my_id);
         ON_ERROR goto kill_command;
        me->state = 4;
        break;
       default:                  /* Object was located */
        sts = om$send(
          msg = message ECconstruct.add_event(
           TRUE),                /* It is a located object */
          targetid = my_id);
         ON_ERROR goto kill_command;
        me->trcobj[me->num_trace] = me->event.located_object[0];
        me->num_trace++;
        me->state = 2;
        break;
      } /* switch (me->event.response) */
      break;
/*
 * Get a point near the starting end of trace 1 and 2
 */
     case 2:
      key = EMS_P_00077;
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
      sts = om$send(
        msg = message ECconstruct.getevent(
         NONE,                      /* Don't need a value */
         event_mask,
         NULL,                      /* No prompt string */
         key,
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
     switch (me->event.response)
      {
       case GR_UNKNOWN_TYPE:
        return(OM_S_SUCCESS);
       case EX_BACK_UP:
        sts = om$send(
          msg = message ECconstruct.backup_event(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        me->num_trace--;
        me->state = 1;
        break;
       case EX_RESTART:
        sts = om$send(
          msg = message ECconstruct.restart(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        break;
       default:
        me->event.located_object[0] = me->trcobj[me->num_trace - 1];
        sts = EFdetermine_direction(
          &me->event,
          my_id,
          &me->msg);
         ON_ERROR goto kill_command;
        me->trcobj[me->num_trace - 1] = me->event.located_object[0];
        sts = om$send(
          msg = message ECconstruct.add_event(
           FALSE),                /* Not a located object */
          targetid = my_id);
         ON_ERROR goto kill_command;
        lc_info = &me->event.located_object[0];
        is_curve_reversed = lc_info->geom_parms.polygon_inx;
        if (me->num_trace == 1)
         {
          struct	GRid *located_object_id;
          struct	GRmdenv_info *mdenv_info;

          located_object_id = &lc_info->located_obj;
          mdenv_info = &lc_info->module_info.md_env;
          sts = om$send(
            msg = message GRcurve.GRendpts(
             &msg,
             &mdenv_info->matrix_type,
             mdenv_info->matrix,
             me->trace_end_point[0],
             me->trace_end_point[1]),
            targetid = located_object_id->objid,
            targetos = located_object_id->osnum);
           ON_ERROR goto kill_command;
          if (is_curve_reversed)
           {
            IGRpoint	tmp_pnt;

            OM_BLOCK_MOVE(
             me->trace_end_point[0],
             tmp_pnt,
             sizeof(IGRpoint));
            OM_BLOCK_MOVE(
             me->trace_end_point[1],
             me->trace_end_point[0],
             sizeof(IGRpoint));
            OM_BLOCK_MOVE(
             tmp_pnt,
             me->trace_end_point[1],
             sizeof(IGRpoint));
           } /* if (is_curve_reversed) */
         } /* if (me->num_trace == 1) */
        sts = EFdisplay_curve_normal_or_tangent(
          lc_info,		/* The curve */
          NULL,			/* Not used for tangents */
          FALSE,		/* Display the tangent vector */
          is_curve_reversed,
          my_id,
          GRbd,			/* Draw background */
          &me->display_env,
          &me->display,
          &msg);
         ON_ERROR goto kill_command;
        if (me->num_trace == 1)
         me->state = 1;
        else
         me->state = 3;
        break;
      } /* switch (me->event.response) */
      break;
/*
 * Determine if scaling is desired, note that this only makes
 * sense if 2 traces are present.
 */
     case 3:
      key = EMS_P_00120;
      event_mask = GRm_STRING | GRm_BACK_UP | GRm_RESTART;
      sts = om$send(
        msg = message ECconstruct.getevent(
         NONE,                      /* Don't need a value */
         event_mask,
         NULL,                      /* No prompt string */
         key,
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
     switch (me->event.response)
      {
       case GR_UNKNOWN_TYPE:
        return(OM_S_SUCCESS);
       case EX_BACK_UP:
        sts = om$send(
          msg = message ECconstruct.backup_event(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        if (me->num_trace == 1)		/* This is not possible */
         me->state = 1;
        else
         {
          lc_info = &me->trcobj[1];
          is_curve_reversed = lc_info->geom_parms.polygon_inx;
          sts = EFdisplay_curve_normal_or_tangent(
            lc_info,		/* The curve */
            NULL,		/* Not used for tangents */
            FALSE,		/* Display the tangent vector */
            is_curve_reversed,
            my_id,
            GRbe,		/* Erase */
            &me->display_env,
            &me->display,
            &msg);
           ON_ERROR goto kill_command;
          me->state = 2;
         } /* ELSE FOR if (me->num_trace == 1) */
        break;
       case EX_RESTART:
        sts = om$send(
          msg = message ECconstruct.restart(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        break;
       default:
        use_default = (me->msg == GRw_no_value);
        if (use_default ||
            (toupper(me->event.event.keyin[0]) == 'Y'))
         me->scaling = TRUE;
        else if (toupper(me->event.event.keyin[0]) == 'N')
         me->scaling = FALSE;
        else
         return(OM_S_SUCCESS);              /* Must have meant a command */
        sts = om$send(
          msg = message ECconstruct.add_event(
           FALSE),                /* Not a located object */
          targetid = my_id);
         ON_ERROR goto kill_command;
        me->state = 4;
        break;
      } /* switch (me->event.response) */
      break;
/*
 * Determine if the cross sections are on site
 */
     case 4:
      key = EMS_P_00121;
      event_mask = GRm_STRING | GRm_BACK_UP | GRm_RESTART;
      sts = om$send(
        msg = message ECconstruct.getevent(
         NONE,                      /* Don't need a value */
         event_mask,
         NULL,                      /* No prompt string */
         key,
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
     switch (me->event.response)
      {
       case GR_UNKNOWN_TYPE:
        return(OM_S_SUCCESS);
       case EX_BACK_UP:
        sts = om$send(
          msg = message ECconstruct.backup_event(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        if (me->num_trace == 2)
         me->state = 3;
        else
         me->state = 1;
        break;
       case EX_RESTART:
        sts = om$send(
          msg = message ECconstruct.restart(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        break;
       default:
        use_default = (me->msg == GRw_no_value);
        if (use_default ||
            (toupper(me->event.event.keyin[0]) == 'Y'))
         me->on_site = TRUE;
        else if (toupper(me->event.event.keyin[0]) == 'N')
         me->on_site = FALSE;
        else
         return(OM_S_SUCCESS);              /* Must have meant a command */
        sts = om$send(
          msg = message ECconstruct.add_event(
           FALSE),                /* Not a located object */
          targetid = my_id);
         ON_ERROR goto kill_command;
        me->state = 5;
        break;
      } /* switch (me->event.response) */
      break;
/*
 * Get the cross sections
 */
     case 5:
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
      if (me->num_cross == 0)
       key = EMS_P_00117;         /* Identify cross section */
      else
       {
        event_mask |= GRm_RJT_MOVEON;
        key = EMS_P_00124;        /* Identify cross section i/moveon */
       }
      i = me->num_cross + 1;
      ex$message(
       msgnumb = key,
       type = "%d",
       var = `i`,
       buff = prompt)
      EFget_locate_information(
       BIG_CURVE,
       &loc_info);
      loc_info.identify_event_type = good_data;
      if (me->on_site)
       {
        loc_info.acc_key = EMS_P_00045;   /* Accept with next curve/reject */
        loc_info.accept_event_type = chained;
       }
      else if (me->num_cross)
       loc_info.accept_event_type = dummy;   /* Accept event is not used */
      else
       loc_info.acc_key = EMS_P_00111;  /* Accept in orientation view/reject */
      if (me->mytype == SOLID)
       loc_info.planar_flag = LC_PLANAR_ONLY;
      else
       loc_info.planar_flag = LC_PLANAR_NON_PLANAR;
      sts = om$send(
        msg = message ECconstruct.locate_object(
         event_mask,
         prompt,
         LC_NO_MSG,             /* No locate key, use string */
         &loc_info,
         FALSE,                 /* Don't put accept event on queue */
         &put_on_queue,         /* Is possible to put accept event on queue? */
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
      if (me->locate_stack.num_entries) return(OM_S_SUCCESS);
     switch (me->event.response)
      {
       case GR_UNKNOWN_TYPE:
        return(OM_S_SUCCESS);
       case EX_BACK_UP:
        sts = om$send(
          msg = message ECconstruct.backup_event(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        if (me->num_cross == 0)
         me->state = 4;
        else
         {
          if (!me->on_site)
           me->state = 7;		/* Toss reference point 1 */
          else
           {
            me->num_cross--;
            lc_info = &me->crsobj[me->num_cross];
            is_curve_reversed = lc_info->geom_parms.polygon_inx;
            sts = EFdisplay_curve_normal_or_tangent(
              lc_info,		/* The curve */
              NULL,		/* Not used for tangents */
              FALSE,		/* Display the tangent vector */
              is_curve_reversed,
              my_id,
              GRbe,		/* Erase */
              &me->display_env,
              &me->display,
              &msg);
             ON_ERROR goto kill_command;
           }
         }
        break;
       case EX_RESTART:
        sts = om$send(
          msg = message ECconstruct.restart(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        break;
       case EX_RJT_MOVEON:
        sts = om$send(
          msg = message ECconstruct.add_event(
           FALSE),               /* Not a located object */
          targetid = my_id);
         ON_ERROR goto kill_command;
        if (me->on_site || (me->num_trace == 2))
         me->state = 10;
        else
         me->state = 8;
        break;
       default:                  /* Object was located */
        {
         IGRboolean	valid_object;
         IGRlong	current_size;

         sts = om$send(
           msg = message ECconstruct.add_event(
            TRUE),                /* It is a located object */
           targetid = my_id);
          ON_ERROR goto kill_command;
         valid_object = TRUE;
         current_size = om$dimension_of(varray = me->crsobj);
         if ((me->num_cross + 3) >= current_size)
          {
           sts = om$vla_set_dimension(
             varray = me->crsobj,
             size = current_size + 10);
            ON_ERROR goto kill_command;
          }
         if (me->mytype == SOLID)
          {
           struct GRprops	props;

           sts = EFgetprops(
             &me->event,
             my_id,
             &props,
             &msg);
            ON_ERROR goto kill_command;
           if (!(props.phy_closed || props.closed))
            {
             valid_object = FALSE;
             ex$message(msgnumb = EMS_I_00014)
            }
          } /* if (me->mytype == SOLID) */
         if (valid_object)
          {
           IGRboolean	auto_on_queue;

           auto_on_queue = FALSE;
           sts = EFdetermine_direction(
             &me->event,
             my_id,
             &me->msg);
            ON_ERROR goto kill_command;
           me->crsobj[me->num_cross] = me->event.located_object[0];
           lc_info = &me->crsobj[me->num_cross];
           is_curve_reversed = lc_info->geom_parms.polygon_inx;
           sts = EFdisplay_curve_normal_or_tangent(
             lc_info,		/* The curve */
             NULL,		/* Not used for tangents */
             FALSE,		/* Display the tangent vector */
             is_curve_reversed,
             my_id,
             GRbd,		/* Draw background */
             &me->display_env,
             &me->display,
             &msg);
            ON_ERROR goto kill_command;
           me->num_cross++;
           if (me->on_site)
            auto_on_queue = TRUE;
           else
            {
             if (me->num_cross == 2)
              me->state = 7;
             else
              {
               auto_on_queue = TRUE;
               me->state = 6;
              }
            }
           if (auto_on_queue && put_on_queue)
            {
             IGRlong	sizeof_event;

             sizeof_event = sizeof(struct GRevent);
             sts = ex$putque(
               msg = &msg,
               response = &me->event1.response,
               byte = &sizeof_event,		/* Should be slightly less */
               buffer = (IGRchar *)&me->event1.event);
              ON_ERROR goto kill_command;
            } /* if (auto_on_queue && put_on_queue) */
          } /* if (valid_object) */
         else
          {
           sts = om$send(
             msg = message ECconstruct.backup_event(),
             targetid = my_id);
            ON_ERROR goto kill_command;
          } /* ELSE FOR if (valid_object) */
        }
        break;
      } /* switch (me->event.response) */
      break;
/*
 * Get the orientation view
 */
     case 6:
      key = EMS_P_00110;
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
      sts = om$send(
        msg = message ECconstruct.getevent(
         NONE,                      /* Don't need a value */
         event_mask,
         NULL,                      /* No prompt string */
         key,
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
     switch (me->event.response)
      {
       case GR_UNKNOWN_TYPE:
        return(OM_S_SUCCESS);
       case EX_BACK_UP:
        sts = om$send(
          msg = message ECconstruct.backup_event(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        me->num_cross--;
        lc_info = &me->crsobj[me->num_cross];
        is_curve_reversed = lc_info->geom_parms.polygon_inx;
        sts = EFdisplay_curve_normal_or_tangent(
          lc_info,		/* The curve */
          NULL,			/* Not used for tangents */
          FALSE,		/* Display the tangent vector */
          is_curve_reversed,
          my_id,
          GRbe,		/* Erase */
          &me->display_env,
          &me->display,
          &msg);
         ON_ERROR goto kill_command;
        me->state = 5;
        break;
       case EX_RESTART:
        sts = om$send(
          msg = message ECconstruct.restart(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        break;
       default:
        {
         IGRdouble       matrix[4][4];

         sts = om$send(
           msg = message ECconstruct.add_event(
            FALSE),                /* Not a located object */
           targetid = my_id);
          ON_ERROR goto kill_command;
         sts = om$send(
           msg = message IGEgragad.DPinrot(
            &msg, 
            (IGRdouble *) &matrix[0][0]),
           targetid = me->event.event.button.objid,
           targetos = me->event.event.button.osnum);
          ON_ERROR goto kill_command;
         for (i = 0; i < 3; i++)
          for (j = 0; j < 3; j++)
           me->view_matrix[i][j] = matrix[i][j];  /* Math wants a 3 X 3 */
         me->state = 7;
        }
        break;
      } /* switch (me->event.response) */
      break;
/*
 * Get the reference point (must not be on site)
 */
     case 7:
      i = me->num_cross;
      ex$message(
       msgnumb = EMS_P_00125,
       type = "%d",
       var = `i`,
       buff = prompt)
      UI_prompt(prompt);
      if (me->num_cross == 1)
       EFrblineseg(
        me->trace_end_point[0], 
        &me->display);
      else
       EFrblineseg(
        me->trace_end_point[1], 
        &me->display);
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
      sts = om$send(
        msg = message ECconstruct.getevent(
         NONE,                      /* Don't need a value */
         event_mask,
         prompt,
         LC_NO_MSG,                 /* No prompt key */
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
     switch (me->event.response)
      {
       case GR_UNKNOWN_TYPE:
        return(OM_S_SUCCESS);
       case EX_BACK_UP:
        sts = om$send(
          msg = message ECconstruct.backup_event(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        if (me->num_cross == 1)
         me->state = 6;
        else
         {
          me->num_cross--;
          lc_info = &me->crsobj[me->num_cross];
          is_curve_reversed = lc_info->geom_parms.polygon_inx;
          sts = EFdisplay_curve_normal_or_tangent(
            lc_info,		/* The curve */
            NULL,		/* Not used for tangents */
            FALSE,		/* Display the tangent vector */
            is_curve_reversed,
            my_id,
            GRbe,		/* Erase */
            &me->display_env,
            &me->display,
            &msg);
           ON_ERROR goto kill_command;
          me->state = 5;
         }
        break;
       case EX_RESTART:
        sts = om$send(
          msg = message ECconstruct.restart(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        break;
       default:
        sts = om$send(
          msg = message ECconstruct.add_event(
           FALSE),                /* Not a located object */
          targetid = my_id);
         ON_ERROR goto kill_command;
        me->ref_pnts[me->num_cross - 1][0] = me->event.event.button.x;
        me->ref_pnts[me->num_cross - 1][1] = me->event.event.button.y;
        me->ref_pnts[me->num_cross - 1][2] = me->event.event.button.z;
        if (me->num_cross == 1)
         me->state = 5;
        else
         {
          if (me->num_trace == 2)
           me->state = 10;
          else
           me->state = 8;
         }
        break;
      } /* switch (me->event.response) */
     break;
/*
 * Get the x vector point
 */
     case 8:
      ex$message(
       msgnumb = EMS_P_00114,
       buff = prompt)
      UI_prompt(prompt);
      EFrblineseg(
       me->trace_end_point[0],
       &me->display);
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
      sts = om$send(
        msg = message ECconstruct.getevent(
         NONE,                      /* Don't need a value */
         event_mask,
         prompt,
         LC_NO_MSG,                 /* No prompt key */
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
     switch (me->event.response)
      {
       case GR_UNKNOWN_TYPE:
        return(OM_S_SUCCESS);
       case EX_BACK_UP:
        sts = om$send(
          msg = message ECconstruct.backup_event(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        if (me->num_cross == 1)
         me->state = 5;
        else
         me->state = 7;			/* Toss reference point 2 */
        break;
       case EX_RESTART:
        sts = om$send(
          msg = message ECconstruct.restart(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        break;
       default:
        sts = om$send(
          msg = message ECconstruct.add_event(
           FALSE),                /* Not a located object */
          targetid = my_id);
         ON_ERROR goto kill_command;
        me->vector_points[0][0] = me->trace_end_point[0][0];
        me->vector_points[0][1] = me->trace_end_point[0][1];
        me->vector_points[0][2] = me->trace_end_point[0][2];
        me->vector_points[1][0] = me->event.event.button.x;
        me->vector_points[1][1] = me->event.event.button.y;
        me->vector_points[1][2] = me->event.event.button.z;
        me->state = 9;
        break;
      } /* switch (me->event.response) */
     break;
/*
 * Get the y vector point
 */
     case 9:
      ex$message(
       msgnumb = EMS_P_00119,
       buff = prompt)
      UI_prompt(prompt);
      sts = ECdisplayPointSetByBuffer(
        &msg,
        me->display,
        me->display_env,
        my_id,
        2,
        me->vector_points,
        TRUE);                   /* Draw background */
       ON_ERROR goto kill_command;
      EFdynormal(
       me->vector_points[1],
       me->trace_end_point[0],
       &me->display);
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
      sts = om$send(
        msg = message ECconstruct.getevent(
         NONE,                      /* Don't need a value */
         event_mask,
         prompt,
         LC_NO_MSG,                 /* No prompt key */
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
      sts = ECdisplayPointSetByBuffer(
        &msg,
        me->display,
        me->display_env,
        my_id,
        2,
        me->vector_points,
        FALSE);                   /* Erase */
       ON_ERROR goto kill_command;
     switch (me->event.response)
      {
       case GR_UNKNOWN_TYPE:
        return(OM_S_SUCCESS);
       case EX_BACK_UP:
        sts = om$send(
          msg = message ECconstruct.backup_event(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        me->state = 8;
        break;
       case EX_RESTART:
        sts = om$send(
          msg = message ECconstruct.restart(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        break;
       default:
        sts = om$send(
          msg = message ECconstruct.add_event(
           FALSE),                /* Not a located object */
          targetid = my_id);
         ON_ERROR goto kill_command;
        me->vector_points[2][0] = me->event.event.button.x;
        me->vector_points[2][1] = me->event.event.button.y;
        me->vector_points[2][2] = me->event.event.button.z;
        me->state = 10;
        break;
      } /* switch (me->event.response) */
     break;
/*
 * Unhighlight all the geometry
 */
     case 10:
      ex$message(msgnumb = EMS_P_00000)
      ex$message(msgnumb = EMS_I_00004, type = "%s", var = " . ")
      pos = EX_suspend;
      sts = om$send(
        msg = message super_cmd.sleep(
         pos),
        targetid = my_id);
       ON_ERROR goto kill_command;
/*
 * Get the construct list
 */
      sts = om$send(
        msg = message ECconstruct.load_construction_information(),
        targetid = my_id);
       ON_ERROR goto kill_command;
      ex$message(msgnumb = EMS_I_00004, type = "%s", var = " .. ")
/*
 * Finally let's do something
 */
      {
       OMuword		osnum;
       IGRboolean	construction_failed;

       construction_failed = FALSE;
       osnum = me->construct_env.md_id.osnum;
       sts = om$construct(
         classid = OPP_EMSgenbs_class_id,
         msg = message EMSgenbs.EMmove_cross_section(
          &me->msg, 
          &me->construct_list, 
          me->num_cross,
          me->crsobj,
          me->num_trace,
          me->trcobj,
          me->scaling, 
          me->on_site, 
          me->ref_pnts,
          (IGRdouble *) &me->view_matrix[0][0],
          me->vector_points[1], 
          me->vector_points[2]),
         p_objid = &me->constructed_object,
         osnum = osnum);
       if (!(1 & sts))
        construction_failed = TRUE;
       else if (me->mytype == SOLID)
        {
         GRobjid	surface_id;

         surface_id = me->constructed_object;
         sts = om$construct(classid = OPP_EMSsfsolid_class_id,
                            p_objid = &me->constructed_object,
                            osnum = osnum);
         if (1 & sts)
         {
           extern OM_S_OBJID current_creator;
           current_creator = me->constructed_object;
           sts = om$send(msg = message EMSsfsolid.EMcap_thyself(&me->msg,
                               &me->construct_list, &surface_id),
                         targetid = me->constructed_object,
                         targetos = osnum);
           current_creator = NULL_OBJID;
         }                         
         if (! (1 & sts))
          {
            construction_failed = TRUE;
            sts = om$send (
              msg = message GRgraphics.GRdelete(
               &msg,
               &me->construct_env),
              targetid = surface_id,
              targetos = osnum);
             ON_ERROR goto kill_command;
          }
        } /* else if (me->mytype == SOLID) */
       me->have_a_constructed_object = TRUE;
       if (construction_failed)
        {
         me->constructed_object = NULL_OBJID;
         ex$message(msgnumb = EMS_I_00002)
        }
       else
        {
         enum	GRdpmode DisplayMode;

         ex$message(msgnumb = EMS_I_00004, type = "%s", var = " ... ")
         DisplayMode = GRbd;
         sts = om$send(
           msg = message ECconstruct.display_constructed_object(
            DisplayMode),
           targetid = my_id);
          ON_ERROR goto kill_command;
         ex$message(msgnumb = EMS_I_00000)
        }
/*
 * Clear my memory for a fresh start
 */
        me->state = previous_state + 1;     /* Don't ask me why */
        sts = om$send(
          msg = message ECconstruct.last_state_to_first_state(),
          targetid = my_id);
         ON_ERROR goto kill_command;
       }
      break;
/*
 * Something has messed up our state table
 */
     default:
      goto kill_command;
    }
  }
 while(TRUE);
/*
 * Kill the command
 */
kill_command:
 CMD_KILL
}

end implementation ECplcsknsf;
