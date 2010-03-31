
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

/* This file contains definitions associated with the toolpath. */

struct NC_toolpath_data
   {
   IGRpoint	curr_location;		/* the current location				*/
   IGRpoint	next_location;		/* the next location				*/
   IGRpoint	curr_orient_vec;	/* the current orientation vector		*/
   IGRpoint	next_orient_vec;	/* the next orientation vector			*/
   IGRboolean	five_axis;		/* the five-axis flag				*/
   IGRboolean	end_of_toolpath;	/* the end of toolpath flag			*/
   };
