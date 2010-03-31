
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/


class specification HSctbl2 (1:3) of global_class, APPcolor;


/*
DESCRIPTION
	Hidden Surface global color table object.

		The purpose of this object is to initialize the EMS color table
		for shading and to store the device dependent color/shade
	        information.

HISTORY
	S.P. Rogers  05/27/87  Creation Date
	S.P. Rogers  06/07/90  Changed to HSctbl2 to support Turquoise
*/

instance HSctbl2
	{
	IGRshort user_colors;                /* number of user colors   */
	IGRshort user_shades;                /* number of user shades   */
	variable IGRshort device_colors[3];  /* number of device colors */
	variable IGRshort device_shades[3];  /* number of device shades */
	};

override wake_up, load_color_table;


end specification HSctbl2;
 
