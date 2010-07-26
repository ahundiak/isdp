
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:34 $
$Locker:  $
*/

class implementation DPusrlnstl;

/*
DESCRIPTION
	Implementation of the user define linestyles.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "exmacros.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "dpdls.h"

#include "wl.h"

/*--- super_construct -------------------------------------------------------*/

method super_construct()
/*
DESCRIPTION
	Initialize default instance data.
*/

{
	int ii;

	for( ii = 0; ii < 248; ii++ )
	{
		me->patterns[ii] = 0xffff;
	}

	return( OM_S_SUCCESS );
}

/*--- wake_up --------------------------------------------------------------*/

method wake_up()

/*
DESCRIPTION
	Load the line styles into WL.
	NOTE: This is only done for the main file and not for reference files.

HISTORY:
	4/12/91	Created.
								Trevor Mink
*/

{
	OM_S_OBJID cur_mod_id;
	OMuword cur_mod_os;
	int ii;

	ex$get_cur_mod( osnum = &cur_mod_os, id = &cur_mod_id );
	if ( cur_mod_os == OM_Gw_current_OS )
	{
     
		/* load the standard built-in styles into WL */
       WLset_line_style_factor( TRUE );
	        WLdefine_style( 0, (WLuint16) 0xFFFF );
		WLdefine_style( 1, (WLuint16) 0x8888 );
		WLdefine_style( 2, (WLuint16) 0xE79C );
		WLdefine_style( 3, (WLuint16) 0xFCFC );

#if defined (SUNOS5)
		WLdefine_style( 4, (WLuint16) 0xFF88 );
#else
      WLdefine_style( 4, (WLuint16) 0xF88F );
#endif

		WLdefine_style( 5, (WLuint16) 0xCCCC );
		WLdefine_style( 6, (WLuint16) 0x8F88 );

#if defined (SUNOS5)
		WLdefine_style( 7, (WLuint16) 0xFF9C );
#else
      WLdefine_style( 7, (WLuint16) 0xF9CF );
#endif

       WLset_line_style_factor( FALSE );

		/* load the user defined styles into WL */
		for ( ii = 0; ii < 248; ii++ )
		{
			WLdefine_style( ii + 8, (WLuint16) me->patterns[ii] );
		}

	}

	return( OM_S_SUCCESS );

} /* wake_up */


/*--- sleep --------------------------------------------------------------*/

/* need to undefine sleep included by stdlib.h */
%undef sleep

method sleep( int position )

/*
DESCRIPTION
	Copy the user defined styles from WL  back to the object so
	that they will be saved with the file.
	NOTE: This is only done for the main file and not for reference files.

HISTORY:
	4/12/91	Created.
								Trevor Mink
*/

{
	OM_S_OBJID cur_mod_id;
	OMuword cur_mod_os;
	int ii;

	ex$get_cur_mod( osnum = &cur_mod_os, id = &cur_mod_id );
	if ( cur_mod_os == OM_Gw_current_OS )
	{
		/* get the user defined styles from WL */
		for ( ii = 0; ii < 248; ii++ )
		{
			WLget_defined_style( ii + 8, (WLuint16 *) &me->patterns[ii] );
		}
	}

	return( OM_S_SUCCESS );

} /* sleep */

end implementation DPusrlnstl;
