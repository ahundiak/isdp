
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

#include <stdlib.h>
#include <stdio.h>

#include "wl.h"

#include "hnmilling.h"
#include "hnorient.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hsdisplay.h"
#include "hstiler.h"
#include "hnmill.h"
#include "HSpr_ncv_fun.h"


/**********************
 * EXTERNAL VARIABLES *
 **********************/

extern struct NC_tool_orient   NCtool_orient;


/*-----NCupdate_orientation_vectors-------------------------------------------*/

   void NCupdate_orientation_vectors(void)

/*
 * ABSTRACT:   NCupdate_orientation_vectors recalculates the tool orientation
 *             vectors using the current rotation matrix.
 *
 * HISTORY:   08/11/88   Created.         C. M. Jablonski
 */

{
   IGRpoint   point[3];


   point[0][0] = 1.0;
   point[0][1] = 0.0;
   point[0][2] = 0.0;

   point[1][0] = 0.0;
   point[1][1] = 1.0;
   point[1][2] = 0.0;

   point[2][0] = 0.0;
   point[2][1] = 0.0;
   point[2][2] = 1.0;

   rotate_points( NCtool_orient.rotation, 3, point );

   NCtool_orient.perp[0] = point[0][0];
   NCtool_orient.perp[1] = point[0][1];
   NCtool_orient.perp[2] = point[0][2];

   NCtool_orient.xsect[0] = point[1][0];
   NCtool_orient.xsect[1] = point[1][1];
   NCtool_orient.xsect[2] = point[1][2];

   NCtool_orient.axis[0] = point[2][0];
   NCtool_orient.axis[1] = point[2][1];
   NCtool_orient.axis[2] = point[2][2];
}


/*-----NCinit_orientation-----------------------------------------------------*/

void NCinit_orientation(void)


/*
 * ABSTRACT:   NCinit_orientation initializes the orientation parameters.
 *
 * HISTORY:   07/21/88   Created.         C. M. Jablonski
 */

{
   /* Update the rotation matrix */
   NCtool_orient.rotation[0][0] = 1.0;
   NCtool_orient.rotation[0][1] = 0.0;
   NCtool_orient.rotation[0][2] = 0.0;

   NCtool_orient.rotation[1][0] = 0.0;
   NCtool_orient.rotation[1][1] = 1.0;
   NCtool_orient.rotation[1][2] = 0.0;

   NCtool_orient.rotation[2][0] = 0.0;
   NCtool_orient.rotation[2][1] = 0.0;
   NCtool_orient.rotation[2][2] = 1.0;

   /* Update the vectors */
   NCupdate_orientation_vectors();
}


/*-----NCchange_orientation-----------------------------------------------------*/

void NCchange_orientation( IGRdouble rotation[3][3] )

/*
 * ABSTRACT: NCchange_orientation changes the current orientation parameters and
 *           updates those variables that are affected.
 *
 * HISTORY:  07/21/88   Created.         C. M. Jablonski
 */

{
   /* Update the rotation matrix */
   NCtool_orient.rotation[0][0] = rotation[0][0];
   NCtool_orient.rotation[0][1] = rotation[0][1];
   NCtool_orient.rotation[0][2] = rotation[0][2];

   NCtool_orient.rotation[1][0] = rotation[1][0];
   NCtool_orient.rotation[1][1] = rotation[1][1];
   NCtool_orient.rotation[1][2] = rotation[1][2];

   NCtool_orient.rotation[2][0] = rotation[2][0];
   NCtool_orient.rotation[2][1] = rotation[2][1];
   NCtool_orient.rotation[2][2] = rotation[2][2];

   /* Update the vectors */
   NCupdate_orientation_vectors();
}
