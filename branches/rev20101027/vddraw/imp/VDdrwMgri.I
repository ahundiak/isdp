/* $Id: VDdrwMgri.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddraw/imp/VDdrwMgri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwMgri.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/06/27  18:25:16  pinnacle
# Created: vddraw/imp/VDdrwMgri.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/21/95	adz		creation date.
 * -------------------------------------------------------------------*/

class implementation VDdrwMgr;

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "AS_status.h"
#include "vddrwattr.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

from	VDdrw2dVw 	import	VDdeleteIfEmpty;
from	VDdrw3dVw 	import	VDdeleteIfEmpty;


long	VDdrwMgr_CleanUp( msg, type, mdEnv )

long			*msg ;
IGRushort		type ;
struct	GRmd_env	*mdEnv ;
{
	
	long			sts = OM_S_SUCCESS ;
	IGRint			i,count ;
	struct	GRid		*grids ;

	SetProc( VDdrwMgr_CleanUp );

	*msg	= MSSUCC;
	grids	= NULL ;

	if( type & VD_O_drw2d ){

	    /*
	     * Check the VDdrw2dVw objects.
	     */

	    sts =
	    VDdrwMgrGetInfo( msg, mdEnv, VD_O_drw2dVw, NULL, NULL,
				&count, &grids, NULL );

	    for( i=0 ; i<count ; i++ ){

		sts =
		_VD_SEND_OBJN(	grids[i],
				VDdrw2dVw.VDdeleteIfEmpty( msg, mdEnv ));
		__CheckRC( sts, *msg, "VDdrw2dVw.VDdeleteIfEmpty", wrapup );
	    }

	    _FREE( grids ); 
	    grids = NULL ;
	}


	if( type & VD_O_drw3d ){

	    /*
	     * Check the VDdrw3dVw objects.
	     */
	    sts = VDdrwMgrGetInfo( msg, mdEnv, VD_O_drw3dVw, NULL, NULL,
				&count, &grids, NULL );

	    for( i=0 ; i<count ; i++ ){

		sts =
		_VD_SEND_OBJN(	grids[i],
				VDdrw3dVw.VDdeleteIfEmpty( msg, mdEnv ));
		__CheckRC( sts, *msg, "VDdrw2dVw.VDdeleteIfEmpty", wrapup );
	    }
	}

	wrapup :

		_FREE( grids );
		End ;
		return TRUE ;
}

/*===========================================================================*/

end implementation VDdrwMgr;
