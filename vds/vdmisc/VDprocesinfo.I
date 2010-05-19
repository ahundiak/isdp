/* $Id: VDprocesinfo.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdmisc/VDprocessinfo.I
 *
 * Description:
 *		This file contains support functions to be called when
 *		information needs to be displayed on the screen for
 *		objects specific or general support information.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDprocesinfo.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
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
# Revision 1.1  1995/09/18  19:01:30  pinnacle
# Created: ./vdmisc/VDprocesinfo.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	09/16/95	adz		Creation Date
 *
 ***************************************************************************/

class implementation Root ;

#include <stdio.h>		/* For NULL		*/
#include <stdlib.h>		/* For malloc and free	*/
#include <tools.h>
#include "OMminimum.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "exdef.h"		/* Constants for exec (IGE)	*/
#include "ex.h"			/* Structs EX*			*/
#include "igrdef.h"		/* Constants IGR??		*/
#include "igr.h"		/* Structs IGR* for geometries	*/
#include "igrdp.h"		/* Structs IGR* for display	*/
#include "gr.h"			/* Structs GR* for graphic info	*/
#include "godef.h"
#include "growner.h"
#include "emssfdef.h"
#include "v_def.h"
#include "v_.h"
#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*
 * Warning Types.
 */

#define		VD_WARNING_TYPE1	1
#define		VD_WARNING_TYPE2	2
#define		VD_WARNING_TYPE3	3
#define		VD_WARNING_TYPE4	4
#define		VD_WARNING_TYPE5	5

/*----------------------------------------------------------------------------*/

void VD_InfoWarning( type, obj, usrInfo )

int		type ;
struct GRid	*obj ; 
IGRchar		*usrInfo ; {

	char	C[OM_K_MAXCLASS_LEN] ;
	char	*info ;
	int	rc ;

	C[0] = '?' ; C[1] = '\0' ;
	rc = om$is_objid_valid(	objid = obj->objid,
				osnum = obj->osnum ) ;
	if( rc & 1 ) {
		rc = om$get_classname(	objid = obj->objid,
					osnum = obj->osnum,
					classname = C ) ;
	}

	/*
	 * Print the warning Type.	
	 */
	switch( type ){

	case	VD_WARNING_TYPE1 : info = " Not Processed " ;	break ;
	case	VD_WARNING_TYPE2 : info = " Not Added " ;	break ;
	case	VD_WARNING_TYPE3 : info = " Is Ignored " ;	break ;
	case	VD_WARNING_TYPE4 : info = " Duplicate " ;	break ;
	case	VD_WARNING_TYPE5 : info = " ??? " ;		break ;
	default			 : info = "" ;			break ;
	}

	printf("WARNING: Object [%d,%d]<%s> --> %s %s\n",
				obj->osnum, obj->objid, C, info,
				(usrInfo) ? usrInfo : "" );
	fflush( stdout ) ;

} /* VD_InfoWarning */

/*----------------------------------------------------------------------------*/

end implementation Root ;
