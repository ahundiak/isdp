/* $Id: VScxgrinput.I,v 1.9 2001/03/02 19:50:12 jayadev Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscpx/VScxgrinput.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VScxgrinput.I,v $
 *  Revision 1.9  2001/03/02 19:50:12  jayadev
 *  reverting back to version 1.1; ASCII process cutout control has been made local to VSholPlates
 *
 *  Revision 1.8  2001/02/24 15:40:19  jayadev
 *  *** empty log message ***
 *
 *  Revision 1.7  2001/02/23 17:04:09  jayadev
 *  ASCII control done for only VSholPlate
 *
 *  Revision 1.6  2001/02/20 22:57:32  jayadev
 *  changes for ASCII process cutout control
 *
 *  Revision 1.4  2001/02/17 16:22:34  jayadev
 *  *** empty log message ***
 *
 *  Revision 1.3  2001/02/17 16:00:02  jayadev
 *  changes for TR#4401
 *
 *  Revision 1.2  2001/01/17 00:08:16  ramarao
 *  *** empty log message ***
 *
# Revision 1.3  2000/11/28  21:39:48  pinnacle
# Replaced: struct/vscpx/VScxgrinput.I for:  by jpulapar for Service Pack
#
# Revision 1.2  2000/11/27  16:04:34  pinnacle
# Replaced: struct/vscpx/VScxgrinput.I for:  by jpulapar for Service Pack
#
 # Revision 1.1  2000/11/09  17:56:04  pinnacle
 # Created: struct/vscpx/VScxgrinput.I by jpulapar for Service Pack
 #
 *
 * History:
 *      MM/DD/YY    AUTHOR      DESCRIPTION
 *      11/07/00    Jayadev     Modified for TR#MP3357 - Filter macro graphics
 *                              for macros $STRUCT/config/process/macro_setup
 ***************************************************************************/

/*
	I/STRUCT
*/
class implementation VScpx ;

#include <stdlib.h>
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
method	VSget_graphic_input(	long			*msg ;
				int			count ;
				struct GRid		roots[] ;
				struct GRobj_env	graphics[] ) {
							
	int			i,	/* World's favorite loop index	*/
				alloc ; /* Flags space allocation	*/
	long			sts ;	/* OM return code		*/
	struct GRobj_env	*gRoot ;/* Pointer to GO's id & module	*/

	sts  = OM_S_SUCCESS ;
	alloc= FALSE ;

	*msg = MSFAIL ;
	if( !roots ) {
		sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_ROOT | ND_IN_BUF,
							NULL,
							0,
							&roots,
							0,
							OM_K_MAXINT,
							&count ),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

		if( roots && count ) {
			struct GRid	*ptr ;
			unsigned	size = count * sizeof *ptr ;

			ptr = (struct GRid *) VSmemdup( roots, size ) ;
			if( ptr ) {
				roots = ptr ;
				alloc = TRUE ;

			} else	vs$mem_fail() ;
		}
	}

	for( i = 0 ; i < count ; i++ ) {

		gRoot = graphics + i ;
		sts = om$send(	msg	= message NDnode.ASreturn_go(
							&gRoot->_grid,
							&gRoot->_matrix_type,
							gRoot->_matrix ),
				targetid= roots[i].objid,
				targetos= roots[i].osnum ) ;
		if( !( sts & 1 ) ) {
			sts = OM_S_SUCCESS ;
			gRoot->_grid = roots[i] ;
		} else {
			__CheckRC( sts, 1, "NDnode.ASreturn_go", wrapup ) ;
		}

		ex$get_modid(	mod_osnum	= gRoot->_osnum,
				mod_id		= &gRoot->_md_id );
		gRoot->_md_os = gRoot->_osnum ;
	}

	*msg = MSSUCC ;

	wrapup :
		if( alloc ) _FREE( roots ) ;
		return sts ;

} /* method VSget_graphic_input */
/*----------------------------------------------------------------------------*/

end implementation VScpx ;
