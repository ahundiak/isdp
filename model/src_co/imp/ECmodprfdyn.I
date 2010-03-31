/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method performs the dynamics for the
 following simple commands:

                 Command                      my_type
        ----------------------------------    -------
	Modify curve shape			106
        Reduce curve data			107
	Modify surface shape			108
						---
	Reduce surface data			114

 Notes

 This routine may only be called after the events have been
 verified as it assumes that they are valid.  It also accesses
 information deposited in other event fields by the verify function.

 History

 12/29/87 : rlw : Creation date.
 07/04/88 : rlw : Took this method from ECmodifyi.I and put it in it's
                  own file.  Before the method did nothing, now it
                  performs dynamics for the modify curve shape command.
 07/08/88 : rlw : Added modify surface shape command
 08/08/88 : rlw : Changed curve data reduction from a placement command to
                  a modification command.
                  Added surface data reduction command.
 01/20/89 : rlw : Dynamics was being performed about the wrong point for
                  global modifications of curves.
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 */

class implementation ECmodify;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "OMmacros.h"		/* OM_BLOCK_MOVE macro */
#define MAX_POINTS 20

from GRcurve import GRendpts;

method perform_dynamics()
{
 IGRlong	number_of_points, my_type, *my_msg;
 IGRpoint	points[MAX_POINTS];
 struct		IGRdisplay *my_display;
 struct		GRmd_env *my_display_env;
 struct		GRlc_info *lc_info;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
 my_type = me->mytype;
 my_display = &me->display;
 my_display_env = &me->display_env;
 lc_info = &me->events[0].located_object[0];
/*
 * Initialize - note that I have made the assumption that
 * the maximum case # will not exceed MAX_POINTS.
 */
 me->msg = MSSUCC;
 if (me->number_of_events_input < MAX_POINTS)
  {
   EFextract_points(
    me->number_of_events_input,
    me->events,
    points);
  }
/*
 * Branch based on the command state
 */
 switch (me->number_of_events_input)
  {
/*
 * Event 1 dynamics
 */
   case 1:
    switch (my_type)
     {
#ifndef IDRAW
      case 107:
       EFrblineseg(
        &lc_info->proj_pnt[0],
        my_display);
       break;
      case 114:
       {
        BSpair	uv;
        struct	GRparms *low, *hig;

        low = &lc_info->geom_parms;
        hig = &me->events[0].located_object[1].geom_parms;
        uv[0] = (hig->u - low->u) / 2.0;
        uv[1] = (hig->v - low->v) / 2.0;
        EFdisplay_iso_curve_of_a_surface(
         lc_info,
         my_display,
         my_display_env,
         FALSE,			/* Use constant v */
         uv,
         TRUE,
         TRUE,
         my_id,
         NULL,
         my_msg);
       }
       break;
#endif
      default:
/*     noop; */
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 2 dynamics
 */
   case 2:
    switch (my_type)
     {
      case 106:
      case 108:
       EFrblineseg(
        points[1],
        my_display);
       break;
#ifndef IDRAW
      case 107:
       EFrblineseg(
        &me->events[0].located_object[1].proj_pnt[0],
        my_display);
       break;
      case 114:
       EFdisplay_iso_curve_of_a_surface(
        lc_info,
        my_display,
        my_display_env,
        TRUE,			/* Use constant u */
        &lc_info->geom_parms.u,
        TRUE,
        TRUE,
        my_id,
        NULL,
        my_msg);
       break;
#endif
      default:
/*     noop; */
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 3 dynamics
 */
   case 3:
    switch (my_type)
     {
#ifndef IDRAW
      case 114:
       EFdisplay_iso_curve_of_a_surface(
        lc_info,
        my_display,
        my_display_env,
        TRUE,			/* Use constant u */
        &me->events[0].located_object[1].geom_parms.u,
        TRUE,
        TRUE,
        my_id,
        NULL,
        my_msg);
       break;
#endif
      default:
/*     noop; */
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 4 dynamics
 */
   case 4:
    switch (my_type)
     {
#ifndef IDRAW
      case 108:
       EFrblineseg(
        points[3],
        my_display);
       break;
      case 114:
       {
        BSpair	uv;
        struct	GRparms *low, *hig;

        low = &lc_info->geom_parms;
        hig = &me->events[0].located_object[1].geom_parms;
        uv[0] = (hig->u - low->u) / 2.0;
        uv[1] = (hig->v - low->v) / 2.0;
        EFdisplay_iso_curve_of_a_surface(
         lc_info,
         my_display,
         my_display_env,
         TRUE,			/* Use constant u */
         uv,
         TRUE,
         TRUE,
         my_id,
         NULL,
         my_msg);
       }
       break;
#endif
      default:
/*     noop; */
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 5 dynamics
 */
   case 5:
    switch (my_type)
     {
      case 106:
       if (me->events[3].response != EX_DATA)		/* Is global? */
        {
         IGRlong	sts;
         struct		GRid *id;
         struct		GRmdenv_info *mdenv_info;

         id = &lc_info->located_obj;
         mdenv_info = &lc_info->module_info.md_env;
         sts = om$send(
           msg = message GRcurve.GRendpts(
            my_msg,
            &mdenv_info->matrix_type,
            mdenv_info->matrix,
            points[3],					/* 1st end point */
            &me->events[4].event.button.x),		/* 2nd end point */
           targetid = id->objid,
           targetos = id->osnum);
          if (! (1 & sts)) goto wrapup;
        } /* if (me->events[3].response != EX_DATA) */
       EFrblineseg(
        points[3],
        my_display);
       break;
#ifndef IDRAW
      case 108:
       EFdisplay_iso_curve_of_a_surface(
        lc_info,
        my_display,
        my_display_env,
        FALSE,			/* Use constant v */
        &me->events[1].located_object[0].geom_parms.u,
        TRUE,
        TRUE,
        my_id,
        NULL,
        my_msg);
       break;
      case 114:
       EFdisplay_iso_curve_of_a_surface(
        lc_info,
        my_display,
        my_display_env,
        FALSE,			/* Use constant v */
        &lc_info->geom_parms.u,
        TRUE,
        TRUE,
        my_id,
        NULL,
        my_msg);
       break;
#endif
      default:
/*     noop; */
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 6 dynamics
 */
   case 6:
    switch (my_type)
     {
      case 106:
       EFrblineseg(
        points[4],
        my_display);
       break;
#ifndef IDRAW
      case 108:
       EFdisplay_iso_curve_of_a_surface(
        lc_info,
        my_display,
        my_display_env,
        TRUE,			/* Use constant u */
        &me->events[3].located_object[0].geom_parms.u,
        TRUE,
        TRUE,
        my_id,
        NULL,
        my_msg);
       break;
      case 114:
       EFdisplay_iso_curve_of_a_surface(
        lc_info,
        my_display,
        my_display_env,
        FALSE,			/* Use constant v */
        &me->events[0].located_object[1].geom_parms.u,
        TRUE,
        TRUE,
        my_id,
        NULL,
        my_msg);
       break;
#endif
      default:
/*     noop; */
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 7 dynamics
 */
   case 7:
    switch (my_type)
     {
#ifndef IDRAW
      case 108:
       EFdisplay_iso_curve_of_a_surface(
        lc_info,
        my_display,
        my_display_env,
        TRUE,			/* Use constant u */
        &me->events[4].located_object[0].geom_parms.u,
        TRUE,
        TRUE,
        my_id,
        NULL,
        my_msg);
       break;
#endif
      default:
/*     noop; */
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 8 dynamics
 */
   case 8:
    switch (my_type)
     {
#ifndef IDRAW
      case 108:
       EFdisplay_iso_curve_of_a_surface(
        lc_info,
        my_display,
        my_display_env,
        TRUE,			/* Use constant u */
        &me->events[1].located_object[0].geom_parms.u,
        TRUE,
        TRUE,
        my_id,
        NULL,
        my_msg);
       break;
#endif
      default:
/*     noop; */
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 9 dynamics
 */
   case 9:
    switch (my_type)
     {
#ifndef IDRAW
      case 108:
       EFdisplay_iso_curve_of_a_surface(
        lc_info,
        my_display,
        my_display_env,
        FALSE,			/* Use constant v */
        &me->events[3].located_object[0].geom_parms.u,
        TRUE,
        TRUE,
        my_id,
        NULL,
        my_msg);
       break;
#endif
      default:
/*     noop; */
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 10 dynamics
 */
   case 10:
    switch (my_type)
     {
#ifndef IDRAW
      case 108:
       EFdisplay_iso_curve_of_a_surface(
        lc_info,
        my_display,
        my_display_env,
        FALSE,			/* Use constant v */
        &me->events[4].located_object[0].geom_parms.u,
        TRUE,
        TRUE,
        my_id,
        NULL,
        my_msg);
       break;
#endif
      default:
/*     noop; */
       break;
     } /* switch (my_type) */
    break;
/*
 * Default is to do nothing
 */
   default:
/*  noop; */
    break;
  } /* switch (me->number_of_events_input) */
/*
 * eof
 */
wrapup:
 if (1 & me->msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation ECmodify;
