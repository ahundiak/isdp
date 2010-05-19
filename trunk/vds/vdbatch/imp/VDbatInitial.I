/* $Id: VDbatInitial.I,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbatch/imp/BDbatInitial.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDbatInitial.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
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
# Revision 1.1  1995/08/31  21:45:28  pinnacle
# Created: vdbatch/imp/VDbatInitial.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/31/95	adz		creation date
 *
 ***************************************************************************/

class implementation  VDSroot;

#include <stdio.h>

#include "msdef.h"
#include "msmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#include "vdbatdrw.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*----------------------------------------------------------------------------
Function : VDbat_InitBatchInfo 
  ----------------------------------------------------------------------------*/

void VDbat_InitBatchInfo(	int		count,
				VDdrwBatchInfo	*info ){

	int		i;
	VDdrwBatchInfo	*p ;

	SetProc( VDbat_InitBatchInfo ); Begin 

	if( ! info )	return ;

	for( i=0, p=info ; i<count ; i++ , p++ ){

		p->dv.objid		= NULL_OBJID ;
		p->dv.osnum		= NULL_OBJID ;

		p->props		= 0 ;
		p->solid._objid		= NULL_OBJID ;
		p->setupFile[0]		= '\0' ;
		p->layer		= 1 ;
		p->offset		= 0. ;
		p->error		= MSSUCC ;
		p->procSts		= VD_B_drwInitialSts ;
		p->drw3dVw[0]		= '\0';
		p->drw2dVw[0]		= '\0';
	}

	End ;
	return ;

}

/*----------------------------------------------------------------------------*/
		
end implementation VDSroot;

