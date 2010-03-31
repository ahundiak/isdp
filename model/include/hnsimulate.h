
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

/* This file contains definitions associated with simulation mode. */

struct NC_sim_data
   {
   IGRboolean	simulation_mode;	/* the simulation mode flag			*/
   IGRint	simulation_speed;	/* the current simulation speed			*/
   IGRint	active_tool_color;	/* the current tool color			*/
   IGRint	active_tool_trans;	/* the current tool translucency state		*/
   IGRint	x_loc, y_loc;		/* x and y offsets from first location in a
   					   sub-toolpath for five axis  			*/
   };
