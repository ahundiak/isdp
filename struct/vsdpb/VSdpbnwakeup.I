/* $Id: VSdpbnwakeup.I,v 1.1.1.1 2001/01/04 21:10:32 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsdpb/VSdpbnwakeup.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSdpbnwakeup.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/11/14  13:35:34  pinnacle
# Created: vsdpb/VSdpbnwakeup.I by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSdpbn ;

#include <stdio.h>
#include "OMmacros.h"
#include "msdef.h"		/* For MS...		*/
#include "igetypedef.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "gr.h"
#include "vsdbgmacros.h"

extern struct GRid	VS_GS_DpbnId ;
/*----------------------------------------------------------------------------*/
method wake_up() {

	OMuword		curModOs ;

	SetProc( VSdpbn_wake_up ) ; Begin 
	ex$get_cur_mod( osnum = &curModOs ) ;

	if( curModOs == OM_Gw_current_OS ) {
		/*
		 * Only do the following if you are the super in the active
		 * file.
		 */
		VS_GS_DpbnId.objid = my_id ;
		VS_GS_DpbnId.osnum = OM_Gw_current_OS ;
	}
	End ;
	return OM_S_SUCCESS ;

} /* method wake_up */
/*----------------------------------------------------------------------------*/

end implementation VSdpbn ;

