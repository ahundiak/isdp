/* $Id: VDaddPktMenu.C,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdstartup/imp/VDaddPktMenu.C
 *
 * Description:
 *		This function adds the  SMAddToPocketMenu function to
 *		callback list, which are executed at the time of switch
 *		proding.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDaddPktMenu.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1995/08/10  18:28:14  pinnacle
 * Created: vdstartup/imp/VDaddPktMenu.C by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/10/95	Ravi		Creation.	
 *	
 * -------------------------------------------------------------------*/

/*****************************************************************************/

#include <stdio.h>
#include "igrdef.h"
#include "igrtypedef.h"
#include "vdprdmacros.h" 
#include "v_dbgmacros.h"

extern int SMAddToPocketMenu();

void VDaddToPcktMenu(
  char *oldprod,	/* I - old product from which we are switching */
  char *newprod		/* I - new product to which we are switching */
)
{
	long	sts;

	SetProc( VDaddToPcktMenu ); Begin

	if ( strcmp ( oldprod, newprod )) 
		if ( ! (   strcmp ( newprod, VD_PROD_NAME_VDS    )  
			&& strcmp ( newprod, VD_PROD_NAME_ROUTE  ) 
			&& strcmp ( newprod, VD_PROD_NAME_STRUCT ) 
			&& strcmp ( newprod, VD_PROD_NAME_LOFT   )))

		__DBGpr_com(" switchprod: SMAddToPocketMenu ");
		sts = SMAddToPocketMenu();

	End ;
}
