/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method display the constructions for the following simple commands:

                 Command                      my_type
        ----------------------------------    -------
	Change curve order			71
	Change surface order			72
	Increase curve order			73
	Increase surface order			74
	Change rule line display		75
	Place solid by capping surface		76
	Toggle polygon on/off			77
	Insert pole without changing shape	78
	Insert knot				79
	Extend surface - linear			80
	Extend surface - circular		81
	Extend surface - polynomial		82
	Delete surface boundaries		86
	Align 2 curves				87
	Align 2 surfaces			88
	Bezier curves from a bspline curve	89
	Bezier surfaces from a bspline surface	90
	Insert knotline				91
						--
	Modify curve shape			106
        Reduce curve data			107
	Modify surface shape			108
						---
	Change curve direction			110
						---
	Reduce surface data			114

 History

 12/29/87 : rlw : Creation date.
 01/05/88 : rlw : Added some commands
 07/04/88 : rlw : Added modify curve shape command
 07/08/88 : rlw : Modified due to function name change in display iso curve
                  Added modify surface shape command
 07/20/88 : rlw : Added Change curve direction command
 08/08/88 : rlw : Changed curve data reduction from a placement command to
                  a modification command.
                  Added surface data reduction command.
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 */


class implementation ECmodify;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "EMSifmacros.h"
#define MAX_POINTS 20

method display_constructions(
 IGRboolean draw_background;
 IGRboolean draw_single)

{
 IGRlong	number_of_points, i, alpha, omega, *my_msg, my_type;
 IGRpoint	points[MAX_POINTS];
 struct		IGRdisplay *my_display;
 struct		GRmd_env *my_display_env;
 struct		GRlc_info *lc_info;
/*
 * Compiler optimizations
 */
 my_display = &me->display;
 my_display_env = &me->display_env;
 my_msg = &me->msg;
 my_type = me->mytype;
 lc_info = &me->events[0].located_object[0];
/*
 * Initialize
 */
 *my_msg = MSSUCC;
/*
 * Set up the loop indices
 */
 omega = me->number_of_events_input;
 if (!omega) goto wrapup;		/* Degenerate case */
 if (draw_single)
  alpha = omega;
 else
  alpha = 1;
/*
 * Enter the loop - Note that it is necessary to
 * reextract the points each time since they are
 * messed up in order to perform the display.
 */
 for (i = alpha; i <= omega; i++)
  {
   number_of_points = 0;
   if (i < MAX_POINTS)
    {
     EFextract_points(
      i,				/* me->number_of_events_input */
      me->events,
      points);
    }
/*
 * Branch based on the command state
 */
   switch (i)
    {
/*
 * Event 1 construction lines
 */
     case 1:
      switch (my_type)
       {
#ifndef IDRAW
        case 110:
         {
          IGRboolean	is_curve_reversed;
          IGRlong	sts;
        /*  IGRlong       EFdisplay_curve_normal_or_tangent();*/

          is_curve_reversed = lc_info->geom_parms.polygon_inx;
/***********************************************************************
          sts = EFdisplay_curve_normal_or_tangent(
            lc_info,		 The curve 
            NULL,		 Not used for tangents 
            FALSE,		 Display the tangent vector 
            is_curve_reversed,
            my_id,
            draw_background ? GRbd : GRbe,
            my_display_env,
            my_display,
            my_msg);
***********************************************************************/
           sts = ems$display_curve_normal_or_tangent(
                                      loc_info = lc_info,
                                    display_normal_tangent = FALSE,
                                  reverse_vector = is_curve_reversed,
                               senderid = my_id,
                            draw_mode = draw_background ? GRbd : GRbe,
                            display_mdenv = my_display_env,
                                   display = my_display,
                                       msg = my_msg);
         }
         break;
#endif
        default:
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 2 construction lines
 */
     case 2:
      switch (my_type)
       {
        case 80:
        case 81:
        case 82:
        case 106:
        case 108:
         number_of_points = 1;
         points[0][0] = points[1][0];
         points[0][1] = points[1][1];
         points[0][2] = points[1][2];
         break;
#ifndef IDRAW
        case 91:
         {
          IGRboolean	use_u_curve;

          use_u_curve = lc_info->geom_parms.polygon_inx;
/***********************************************************************
          EFdisplay_iso_curve_of_a_surface(
           lc_info,
           my_display,
           my_display_env,
           use_u_curve,
           &me->events[1].located_object[0].geom_parms.u,
           draw_background,
           FALSE,			 Don't wait 
           my_id,
           NULL,
           my_msg);
***********************************************************************/
          ems$display_iso_curve_of_a_surface(
                               loc_info = lc_info,
                               display = my_display,
                               display_mdenv = my_display_env,
                               use_u_curve = use_u_curve,
                 uv_coordinate = &me->events[1].located_object[0].geom_parms.u,
                               draw_background = draw_background,
                               senderid = my_id,
                               msg = my_msg);
         }
         break;
        case 114:
         if (me->events[1].response == EX_DATA)
          {
           BSpair	uv;
           struct	GRparms *low, *hig;

           low = &lc_info->geom_parms;
           hig = &me->events[0].located_object[1].geom_parms;
           uv[0] = (hig->u - low->u) / 2.0;
           uv[1] = (hig->v - low->v) / 2.0;
/***************************************************************************
           EFdisplay_iso_curve_of_a_surface(
            lc_info,
            my_display,
            my_display_env,
            FALSE,			 Use constant v 
            uv,
            draw_background,
            FALSE,
            my_id,
            NULL,
            my_msg);
***************************************************************************/
           ems$display_iso_curve_of_a_surface(
                                 loc_info = lc_info,
                                 display = my_display,
                                 display_mdenv = my_display_env,
                                 use_u_curve = FALSE,
                                 uv_coordinate = uv,
                                 draw_background = draw_background,
                                 senderid = my_id,
                                 msg = my_msg);
          } /* if (me->events[1].response == EX_DATA) */
         break;
#endif
        default:
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 3 construction lines
 */
     case 3:
      switch (my_type)
       {
        case 87:
        case 88:
         number_of_points = 1;
         points[0][0] = points[2][0];
         points[0][1] = points[2][1];
         points[0][2] = points[2][2];
         break;
        case 106:
        case 108:
         number_of_points = 2;
         points[0][0] = points[1][0];
         points[0][1] = points[1][1];
         points[0][2] = points[1][2];
         points[1][0] = points[2][0];
         points[1][1] = points[2][1];
         points[1][2] = points[2][2];
         break;
#ifndef IDRAW
        case 114:
         if ((me->events[2].response != EX_MAX_RESPONSE) &&
             me->events[2].located_object[0].geom_parms.polygon_inx)
          {
/***************************************************************************
           EFdisplay_iso_curve_of_a_surface(
            lc_info,
            my_display,
            my_display_env,
            TRUE,			 Use constant u 
            &lc_info->geom_parms.u,
            draw_background,
            FALSE,
            my_id,
            NULL,
            my_msg);
***************************************************************************/
           ems$display_iso_curve_of_a_surface(
                                loc_info = lc_info,
                                display = my_display,
                                display_mdenv = my_display_env,
                                uv_coordinate = &lc_info->geom_parms.u,
                                draw_background = draw_background,
                                senderid = my_id,
                                     msg = my_msg);  
                             
          } /* if (me->events[2].response == EX_DATA) */
         break;
#endif
        default:
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 4 construction lines
 */
     case 4:
      switch (my_type)
       {
        case 106:
        case 108:
         if (me->events[3].response == EX_DATA)
          {
           number_of_points = 1;
           points[0][0] = points[3][0];
           points[0][1] = points[3][1];
           points[0][2] = points[3][2];
          } /* if (me->events[3].response == EX_DATA) */
         break;
#ifndef IDRAW
        case 114:
         if ((me->events[3].response != EX_MAX_RESPONSE) &&
             me->events[3].located_object[0].geom_parms.polygon_inx)
          {
/************************************************************************
           EFdisplay_iso_curve_of_a_surface(
            lc_info,
            my_display,
            my_display_env,
            TRUE,			 Use constant u 
            &me->events[0].located_object[1].geom_parms.u,
            draw_background,
            FALSE,
            my_id,
            NULL,
            my_msg);
************************************************************************/
           ems$display_iso_curve_of_a_surface(
                                loc_info = lc_info,
                                display = my_display,
                                display_mdenv = my_display_env,
               uv_coordinate = &me->events[0].located_object[1].geom_parms.u, 
                                draw_background = draw_background,
                                       senderid = my_id,
                                            msg = my_msg);
          } /* if (me->events[3].response == EX_DATA) */
         break;
#endif
        default:
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 5 construction lines
 */
     case 5:
      switch (my_type)
       {
        case 106:
        case 108:
         if (me->events[4].response == EX_DATA)
          {
           number_of_points = 1;
           points[0][0] = points[4][0];
           points[0][1] = points[4][1];
           points[0][2] = points[4][2];
          } /* if (me->events[4].response == EX_DATA) */
         break;
#ifndef IDRAW
        case 114:
         if (me->events[4].response == EX_DATA)
          {
           BSpair	uv;
           struct	GRparms *low, *hig;

           low = &lc_info->geom_parms;
           hig = &me->events[0].located_object[1].geom_parms;
           uv[0] = (hig->u - low->u) / 2.0;
           uv[1] = (hig->v - low->v) / 2.0;
/**************************************************************************
           EFdisplay_iso_curve_of_a_surface(
            lc_info,
            my_display,
            my_display_env,
            TRUE,			 Use constant u 
            uv,
            draw_background,
            FALSE,
            my_id,
            NULL,
            my_msg);
**************************************************************************/
           ems$display_iso_curve_of_a_surface(
                                loc_info = lc_info,
                                display = my_display,
                                display_mdenv = my_display_env,
                                uv_coordinate = uv,
                                draw_background = draw_background,
                                       senderid = my_id,
                                            msg = my_msg);
          } /* if (me->events[4].response == EX_DATA) */
         break;
#endif
        default:
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 6 construction lines
 */
     case 6:
      switch (my_type)
       {
#ifndef IDRAW
        case 108:
         if (me->events[5].response == EX_DATA)
          {
/**************************************************************************
           EFdisplay_iso_curve_of_a_surface(
            lc_info,
            my_display,
            my_display_env,
            FALSE,			 Use constant v 
            &me->events[1].located_object[0].geom_parms.u,
            draw_background,
            FALSE,
            my_id,
            NULL,
            my_msg);
**************************************************************************/
           ems$display_iso_curve_of_a_surface(
                                loc_info = lc_info,
                                   display = my_display,
                               display_mdenv = my_display_env,
                               use_u_curve = FALSE,
            uv_coordinate = &me->events[1].located_object[0].geom_parms.u,
                           draw_background = draw_background,
                                senderid = my_id,
                                     msg = my_msg);
          } /* if (me->events[5].response == EX_DATA) */
         break;
        case 114:
         if ((me->events[5].response != EX_MAX_RESPONSE) &&
             me->events[5].located_object[0].geom_parms.polygon_inx)
          {
/***************************************************************************
           EFdisplay_iso_curve_of_a_surface(
            lc_info,
            my_display,
            my_display_env,
            FALSE,			 Use constant v 
            &lc_info->geom_parms.u,
            draw_background,
            FALSE,
            my_id,
            NULL,
            my_msg);
***************************************************************************/
           ems$display_iso_curve_of_a_surface(
                                 loc_info = lc_info,
                                  display = my_display,
                                  display_mdenv = my_display_env,
                                   use_u_curve = FALSE,
                                   uv_coordinate = &lc_info->geom_parms.u,
                                  draw_background = draw_background,
                                         senderid = my_id,
                                              msg = my_msg); 
          } /* if (me->events[5].response == EX_DATA) */
         break;
#endif
        default:
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 7 construction lines
 */
     case 7:
      switch (my_type)
       {
#ifndef IDRAW
        case 108:
         if ((me->events[6].response != EX_MAX_RESPONSE) &&
             me->events[6].located_object[0].geom_parms.polygon_inx)
          {
/***************************************************************************
           EFdisplay_iso_curve_of_a_surface(
            lc_info,
            my_display,
            my_display_env,
            TRUE,			 Use constant u 
            &me->events[3].located_object[0].geom_parms.u,
            draw_background,
            FALSE,
            my_id,
            NULL,
            my_msg);
***************************************************************************/
           ems$display_iso_curve_of_a_surface(
                                   loc_info = lc_info,
                                   display = my_display,
                                   display_mdenv = my_display_env,
                uv_coordinate = &me->events[3].located_object[0].geom_parms.u,
                                   draw_background = draw_background,
                                          senderid = my_id,
                                               msg = my_msg);   
          } /* if (me->events[6].response == EX_DATA) */
         break;
#endif
        default:
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 8 construction lines
 */
     case 8:
      switch (my_type)
       {
#ifndef IDRAW
        case 108:
         if ((me->events[7].response != EX_MAX_RESPONSE) &&
             me->events[7].located_object[0].geom_parms.polygon_inx)
          {
/**************************************************************************
           EFdisplay_iso_curve_of_a_surface(
            lc_info,
            my_display,
            my_display_env,
            TRUE,			 Use constant u 
            &me->events[4].located_object[0].geom_parms.u,
            draw_background,
            FALSE,
            my_id,
            NULL,
            my_msg);
**************************************************************************/
           ems$display_iso_curve_of_a_surface(
                                  loc_info = lc_info,
                                  display = my_display,
                                  display_mdenv = my_display_env,
                 uv_coordinate = &me->events[4].located_object[0].geom_parms.u,
                                  draw_background = draw_background,
                                       senderid = my_id,
                                            msg = my_msg);                 
          } /* if (me->events[7].response == EX_DATA) */
         break;
#endif
        default:
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 9 construction lines
 */
     case 9:
      switch (my_type)
       {
#ifndef IDRAW
        case 108:
         if (me->events[8].response == EX_DATA)
          {
/***************************************************************************
           EFdisplay_iso_curve_of_a_surface(
            lc_info,
            my_display,
            my_display_env,
            TRUE,			 Use constant u 
            &me->events[1].located_object[0].geom_parms.u,
            draw_background,
            FALSE,
            my_id,
            NULL,
            my_msg);
***************************************************************************/
            ems$display_iso_curve_of_a_surface(
                                   loc_info = lc_info,
                                   display = my_display,
                                   display_mdenv = my_display_env,
             uv_coordinate = &me->events[1].located_object[0].geom_parms.u,
                                   draw_background = draw_background,
                                          senderid = my_id,
                                               msg = my_msg);                   
          } /* if (me->events[8].response == EX_DATA) */
         break;
#endif
        default:
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 10 construction lines
 */
     case 10:
      switch (my_type)
       {
#ifndef IDRAW
        case 108:
         if (me->events[9].located_object[0].geom_parms.polygon_inx)
          {
/************************************************************************
           EFdisplay_iso_curve_of_a_surface(
            lc_info,
            my_display,
            my_display_env,
            FALSE,			 Use constant v 
            &me->events[3].located_object[0].geom_parms.u,
            draw_background,
            FALSE,
            my_id,
            NULL,
            my_msg);
************************************************************************/
            ems$display_iso_curve_of_a_surface(
                                   loc_info = lc_info,
                                   display = my_display,
                                display_mdenv = my_display_env,
          uv_coordinate = &me->events[3].located_object[0].geom_parms.u,
                                draw_background = draw_background,
                                        senderid = my_id,
                                             msg = my_msg);                         
          } /* if (me->events[9].response == EX_DATA) */
         break;
#endif
        default:
         break;
       } /* switch (my_type) */
      break;
/*
 * Default is to do nothing
 */
     default:
      break;
    } /* switch (i) */
/*
 * Display my constructions
 */
   if (number_of_points)
    {
     IGRlong	sts;
   /*  IGRlong    ECdisplayPointSetByBuffer();*/
/************************************************************************
     sts = ECdisplayPointSetByBuffer(
       my_msg,
       *my_display,
       *my_display_env,
       my_id,
       number_of_points,
       points,
       draw_background);
************************************************************************/
      sts = ems$displayPointSetByBuffer(
                            msg = my_msg,
                         display_attr = *my_display,
                         mdenv = *my_display_env,
                          senderid = my_id,
                         num_points = number_of_points,
                             points = points,
                         draw_background = draw_background);      
      if (! (1 & sts))
       {
        *my_msg = MSFAIL;
        goto wrapup;
       }
    } /* if (number_of_points) */
  } /* for (i = start; i <= end; i++) */
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation ECmodify;
