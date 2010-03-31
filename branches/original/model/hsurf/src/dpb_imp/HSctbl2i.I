
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

class implementation HSctbl2;

/*
DESCRIPTION
	Implementation of the global color table object for shading

HISTORY
	S.P. Rogers  06/01/87  Creation Date
	S.P. Rogers  06/07/90  Changed to HSctbl2 to support Turquoise
	R. Druzynski 04/11/91  Apogee compliance
*/

#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"

/*--- wake_up --------------------------------------------------------*/

method wake_up()
/*
DESCRIPTION
   

HISTORY
	xx/xx/xx               Creation Date (as HSctbl method)
	07/14/90  S.P. Rogers  Change to HSctbl2 and cleaned up method	
        05/04/93  J.D. Underwood removing this object.  
*/

{
   return(om$send(msg = message HSctbl2.delete(0), targetid=my_id));
}


/*--- load_color_table --------------------------------------------*/

method load_color_table( IGRint *num_colors;
	                 IGRint *num_shades;
	                 IGRint *calc_shades;
	                 IGRint (**shade_func)();
	                 IGRint screen_no;
	                 IGRint total_vlt_slots )

/*
DESCRIPTION
	Set the parameters of the message to the current number of
	colors and shades.  This message is sent each time the color table
	is going to be configured.

HISTORY
	1/14/93		M. Lanier
		Put in test to see if MDS is running or not.  If it
		is, then lead the color shade configuration at
		MAX Colors and 1 Shade.
        5/04/93    J.D. Underwood
                only functionality needed is if shades were calculated or stored.
*/

{
   *num_colors = me->user_colors;
   *num_shades = me->user_shades;
   *calc_shades = ( me->user_colors == 0 );
   return( OM_S_SUCCESS );
}  /* load_color_table */


end implementation HSctbl2;
