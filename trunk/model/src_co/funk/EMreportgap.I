/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function gets the geometry for a set of curves and reports if
 there are gaps between the curves.  It was intended to be used by
 the place surface by 3/4 boundaries and place blending surface commands
 to report these problems to the user.

 For each illegal gap that is found the follow occurs:

 1) Points are displayed at the gaps using the display and display_env
    information.
 2) If the button is valid then a raster text string is displayed
    at the gap which shows the gap distance.

 Arguments
 
 number_of_curves       The number of input curves
 curves                 Locate information for the input curves
 buttons		The objid, osnum, and hardware window number of
                        the window in which each curve was located.  
                        Pointer may be NULL or entry may be NULL_OBJID.
 closed_contour         Flag indicating whether the linked input curves must
                        form a closed region.
 display                Symbology information for points to be drawn.
 display_env            Display information for the points to be drawn.
 gaps_exist		If TRUE then gaps out of tolerance exist between the
                        curves.
 msg			Error return code - one of 
                        MSSUCC      - Geometry is OK
                        MANOMEMORY  - No memory
			MSFAIL      - Just failed
                        MSINARG     - Geometry has gaps

 History

 rlw : 07/25/89 : Creation date.
 Sudha   06/02/93        modified to include for BSprototype headers
 */

class implementation GRvg;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"
#include "bststcvcnct.h"
#include "bsdistptpt.h"

IGRlong EMreport_curve_gaps(
 number_of_curves,
 curves,
 buttons,
 closed_contour,
 display,
 display_env,
 gaps_exist,
 msg)

IGRlong		number_of_curves;
struct		GRlc_info curves[];
struct		EX_button buttons[];
IGRboolean	closed_contour;
struct		IGRdisplay *display;
struct		GRmd_env *display_env;
IGRboolean	*gaps_exist;
IGRlong		*msg;

{ 
 IGRlong	*gap_information;
 struct		IGRbsp_curve **curves_geom;
/*
 * Initialize
 */
 *msg = MSSUCC;
 *gaps_exist = FALSE;
 gap_information = NULL;
 curves_geom = NULL;
/*
 * Get the geometry of all the input curves
 */
 {
  IGRlong	i, sts;
  extern	IGRlong EMget_the_geometry();

  curves_geom = (struct IGRbsp_curve **) malloc(
    number_of_curves * sizeof(struct IGRbsp_curve *));
   if (! curves_geom)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  for (i = 0; i < number_of_curves; i++) curves_geom[i] = NULL;
  for (i = 0; i < number_of_curves; i++)
   {
    sts = EMget_the_geometry(
      &curves[i],
      TRUE,               /* is_curve */
      FALSE,              /* not directed */
      FALSE,              /* no separate mallocs */
      NULL_OBJID,         /* my_id */
      &curves_geom[i],    /* the geometry */
      msg);
     if (! (1 & *msg)) goto wrapup;
   } /* for (i = 0; i < number_of_curves; i++) */
 }
/*
 * Call the math to determine the relationships among
 * the curves.
 */
 {
  IGRlong	loc_msg;
  IGRint        number_of_points;
  IGRpoint	*points;

  gap_information = (IGRlong *) malloc(
    number_of_curves * 3 * sizeof(IGRlong));
   if (! gap_information)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  points = (IGRpoint *) malloc(
    number_of_curves * sizeof(IGRpoint));
   if (! points)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }

  BStstcvcnct(
    number_of_curves,
    curves_geom,
    closed_contour,
    (IGRint *)gap_information,
    &number_of_points,
    points,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  if (points) free(points);
 }
/*
 * Process the gaps, if any
 */
 {
  IGRlong	i, j;

  for (i = 0; i < number_of_curves; i++)
   {
    j = 3 * i;
/*
 * If we have a gap then we wish to compute the distance between
 * the two curves so that it can be displayed on the screen.
 */
    if (gap_information[j + 1])
     {
      extern	IGRlong ECdisplayPointSetByBuffer();
      IGRlong	cv_1_index, cv_1_rever, cv_2_index, cv_2_rever;
      IGRlong	index, next_cv, loc_msg, sts;
      IGRdouble	gap_distance, weight;
      IGRpoint	endpoints[2];
      struct	IGRbsp_curve *curve;

      *gaps_exist = TRUE;
      cv_1_index = gap_information[j];
      cv_1_rever = gap_information[j + 2];
      next_cv = i + 1;
      if (next_cv == number_of_curves) next_cv = 0;
      j = 3 * next_cv;
      cv_2_index = gap_information[j];
      cv_2_rever = gap_information[j + 2];
      curve = curves_geom[cv_1_index];
      if (cv_1_rever)
       index = 0;
      else
       index = curve->num_poles - 1;
      j = index * 3;
      endpoints[0][0] = curve->poles[j++];
      endpoints[0][1] = curve->poles[j++];
      endpoints[0][2] = curve->poles[j];
      if (curve->rational)
       {
        weight = curve->weights[index];
        endpoints[0][0] /= weight;
        endpoints[0][1] /= weight;
        endpoints[0][2] /= weight;
       }
      curve = curves_geom[cv_2_index];
      if (cv_2_rever)
       index = curve->num_poles - 1;
      else
       index = 0;
      j = index * 3;
      endpoints[1][0] = curve->poles[j++];
      endpoints[1][1] = curve->poles[j++];
      endpoints[1][2] = curve->poles[j];
      if (curve->rational)
       {
        weight = curve->weights[index];
        endpoints[1][0] /= weight;
        endpoints[1][1] /= weight;
        endpoints[1][2] /= weight;
       }
      gap_distance = BSdistptpt(
       &loc_msg,
       endpoints[0],
       endpoints[1]);
/*
 * Display weighted points at the endpoints of the gap.
 */
      for (j = 0; j < 2; j++)
       {
        sts = ECdisplayPointSetByBuffer(
          msg,
          *display,
          *display_env,
          NULL_OBJID,
          1,
          endpoints[j],
          TRUE);                 /* draw_background */
         if (! (1 & sts)) goto wrapup;
       } /* for (j = 0; j < 2; j++) */
/*
 * Display a raster string indicating the gap distance on the screen.
 */
      if (buttons)
       {
        struct	EX_button *button;

        if (buttons[cv_1_index].objid != NULL_OBJID)
         button = &buttons[cv_1_index];
        else if (buttons[cv_2_index].objid != NULL_OBJID)
         button = &buttons[cv_2_index];
        else
         button = NULL;
        if (button)
         {
          extern	IGRlong EFconvert_to_user_units(), EMrastext();
          IGRchar	prompt[80];

          strcpy(prompt,"gap dist = ");
          sts = EFconvert_to_user_units(
            gap_distance,
            TRUE,          /* Want master string */
            prompt,
            msg);
           if (! (1 & sts)) goto wrapup;
          button->x = (endpoints[0][0] + endpoints[1][0]) / 2.0;
          button->y = (endpoints[0][1] + endpoints[1][1]) / 2.0;
          button->z = (endpoints[0][2] + endpoints[1][2]) / 2.0;
          sts = EMrastext(
            msg, 
            prompt, 
            button);
           if (! (1 & sts)) goto wrapup;
         } /* if (button) */
       } /* if (buttons) */
     } /* if (gap_information[j + 1]) */
   } /* for (i = 0; i < number_of_curves; i++) */
 }
/*
 * eof
 */
wrapup:
 if (gap_information) free(gap_information);
 if (curves_geom)
  {
   IGRlong	i;

   for (i = 0; i < number_of_curves; i++) free(curves_geom[i]);
   free(curves_geom);
  }
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

end implementation GRvg;
