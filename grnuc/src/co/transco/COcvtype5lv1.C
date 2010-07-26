/* #######################    APOGEE COMPILED   ######################## */
#include "exsysdep.h"
/*
#include "coimport.h"
*/
#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igewindef.h"
#include "igewindow.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igewinmacros.h"
#include "igecolmacros.h"
#include "transdef.h"
#include "translate.h"
#include "msdef.h"



IGRint COcvt_type5lv1 ( msg, igdsct )

IGRlong 		*msg;
struct IGDS_color_table *igdsct;

{
    IGRint		i;
    IGRint		status;
    IGRshort		num_colors;
    struct IGEvlt	color[256];
#ifdef BIG_ENDIAN
    unsigned short      swapped_short;
#endif
    status = TRUE;
    *msg = MSSUCC;

    /*
     *  Load only the IGDS right screen color table.
     */

#ifdef BIG_ENDIAN
    if ( igdsct->screen_select & 0x0080 )
#else
    if ( igdsct->screen_select & 0x8000 )
#endif
    {
	goto wrapup;
    }

    /*
     *  Shift the color values to the higher order n bits
     *  of the longword.
     */

    for ( i = 0; i < 256; i++ )
    {
	color[i].red = ( (unsigned short)igdsct->color[i].red ) << 8;
	color[i].green = ( (unsigned short)igdsct->color[i].green ) << 8;
	color[i].blue = ( (unsigned short)igdsct->color[i].blue ) << 8;	
    }

    /*
     *  Change the reserved colors.

     * TR 119314141 - dhm  12/16/93.
     * Don't need to do this any more. It can all be done in 
     * ige$change_color_table.

    status = ige$change_reserved_colors ( bgcolor = (IGRchar *) &color[0], 
				       	  hilite_color = (IGRchar *) &color[255] );
     */
				
    /*
     *	Change the color table.
     */

    num_colors = 256;
    status = ige$change_color_table ( num_colors = num_colors, 
			     	      colors = (IGRchar *) &color[0] );
			
    if ( !status )
    {
	*msg = MSFAIL;
	status = FALSE;
	goto wrapup;
    }
			
    /*
     *	Activate the new color table.
     */

    status = ige$configure_color_table ();

    if ( !status )
    {
	*msg = MSFAIL;
	status = FALSE;
	goto wrapup;
    }

wrapup:

    return ( status );
	
}
