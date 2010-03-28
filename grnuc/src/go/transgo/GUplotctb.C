/* #######################    APOGEE COMPILED   ######################## */
/*
#include "grimport.h"
*/
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igewindef.h"
#include "igewindow.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igewinmacros.h"
#include "igecolmacros.h"
#include "msdef.h"

struct rgb_entry
{
    IGRuchar	red, green, blue;
};


IGRint GUplotctb ( msg, plotctb )

IGRlong 	 *msg;
struct rgb_entry plotctb[];

{
    IGRint		i;
    IGRint		index;
    IGRint		status;
    IGRshort		num_colors = 512,
			num_active_colors;
    struct IGEvlt	color[512];


    status = TRUE;
    *msg = MSSUCC;

    /*
     *	Read the color table.
     */

    status = ige$read_color_table ( num_colors = &num_colors, 
			     	    colors = (IGRchar *) color );
			
    if ( !status )
    {
	*msg = MSFAIL;
	goto wrapup;
    }

    /*
     *  Get the number of active colors for this workstation.
     */

    status = ige$get_num_active_colors ( num_colors = &num_active_colors );
    if ( !status )
    {
	*msg = MSFAIL;
#ifdef DEBUG
	printf ( "\nGUplotctb: error getting number of active colors.\n" );
#endif
	goto wrapup;
    }

    if (num_active_colors)
    {
	num_colors = num_active_colors;
    }

    /*
     *  Shift the color values to the higher order n bits
     *  of the longword.
     */

    for ( i = 1; i < 255; i++ )
    {
	index = (i-1) % num_colors;
	
	plotctb[i].red = (IGRuchar ) (color[index].red >> 8);
	plotctb[i].green = (IGRuchar ) (color[index].green >> 8);
	plotctb[i].blue = (IGRuchar ) (color[index].blue >> 8);
    }

    /*
     *  Read the reserved colors.
     */

    status = ige$read_reserved_colors ( bgcolor = (IGRchar *) &color[0], 
				        hilite_color = (IGRchar *) &color[1] );
/*
 *  These three lines of code will insert a color background
 *  for plotting, at this time the background is hardcoded
 *  to black so that Interplot will not draw the background.
 *  This will be changed in the future if needed.
 *
 *  plotctb[0].red = (IGRuchar ) (color[0].red >> 8);
 *  plotctb[0].green = (IGRuchar ) (color[0].green >> 8);
 *  plotctb[0].blue = (IGRuchar ) (color[0].blue >> 8);
 */
    plotctb[0].red = 0;
    plotctb[0].green = 0;
    plotctb[0].blue = 0;

    plotctb[255].red = (IGRuchar ) (color[1].red >> 8);
    plotctb[255].green = (IGRuchar ) (color[1].green >> 8);
    plotctb[255].blue = (IGRuchar ) (color[1].blue >> 8);

wrapup:

    return ( status );
	
}


