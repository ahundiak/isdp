
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

/* This file contains definitions associated with the orientation. */

struct NC_tool_orient
   {
   IGRpoint	axis;			/* the current orientation vector (NORMALIZED) */
   IGRpoint	xsect;			/* a vector perpendicular to the axis (NORMALIZED) */
   IGRpoint	perp;			/* the vector that, together with the other two,
   					   forms a right-handed coordinate system (NORMALIZED) */
   IGRdouble	rotation[3][3];		/* the rotation matrix for the current orientation
   					   	x-axis * rotation -----> xsect
   					   	y-axis * rotation -----> perp
  					   	z-axis * rotation -----> axis */
   };
