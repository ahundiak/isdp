/* ###################   APOGEE COMPILED   ################## */
/*
 Description

  This function extracts points out of an array
  of event structures.

 History

  10/19/87 : rlw : The beginning
 */

class implementation Root;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"		/* Includes everthing */

void EFextract_points(
 number_of_points,		/* Number of points to get */
 events,			/* Event structures */
 points)			/* The answer */

IGRlong		number_of_points;
struct		GRevent events[];
IGRpoint	points[];
{
 IGRlong	i;
 struct		EX_button *button;

 for (i = 0; i < number_of_points; i++)
  {
   button = &events[i].event.button;
   points[i][0] = button->x;
   points[i][1] = button->y;
   points[i][2] = button->z;
  } /* for (i = 0; i < number_of_points; i++) */
}

end implementation Root;
