/* $Id: VSdpb_wakeup.I,v 1.1.1.1 2001/01/04 21:10:32 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsdpb/VSdpb_wakeup.I 
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSdpb_wakeup.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1997/12/19  05:15:32  pinnacle
# Replaced: vsdpb/VSdpb_wakeup.I for:  by svkadamb for struct
#
# Revision 1.2  1997/11/14  12:28:12  pinnacle
# Replaced: vsdpb/VSdpb_wakeup.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSdpb ;

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

extern struct GRid	VS_GS_DpbId ;
/*----------------------------------------------------------------------------*/
method wake_up() {

	OMuword		curModOs ;

	ex$get_cur_mod( osnum = &curModOs ) ;

	if( curModOs == OM_Gw_current_OS ) {
		/*
		 * Only do the following if you are the super in the active
		 * file.
		 */
		VS_GS_DpbId.objid = my_id ;
		VS_GS_DpbId.osnum = OM_Gw_current_OS ;
	}

	return OM_S_SUCCESS ;

} /* method wake_up */
/*----------------------------------------------------------------------------*/

end implementation VSdpb ;

