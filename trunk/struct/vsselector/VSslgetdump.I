/* $Id: VSslgetdump.I,v 1.1.1.1 2001/01/04 21:10:58 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsselector/VSslgetdump.I
 *
 * Description:
 *		Function will print out the internal VSselector program
 *		on the screen for debug purpose.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSslgetdump.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/09/22  17:33:56  pinnacle
# Created: vsselector/VSslgetdump.I by s250_int for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	09/22/97	adz		creation date
 ***************************************************************************/

class implementation VSselector ;

#include "EMSmsgdef.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsslc.h"
#include "vsslcmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes for function prototypes.
 */
#include "vsslcproto.h"

/*----------------------------------------------------------------------------*/
int	VSslc_dumpInfo( msg, myObj, myEnv )

long		*msg ;
struct GRid	*myObj ;
struct GRmd_env	*myEnv ;
{
	long			sts ;		/* OM return code	*/
	char			*program ;	/* Program text		*/
	VSexecIN		inParms ;	/* Input to exec.	*/
	VSexecOUT		outParms ;	/* Output from exec.	*/
	VSparseErr		err ;		/* Parsing error	*/
	VS_NODE			*progStart ;	/* Start node of program*/

	SetProc( VSslc_dumpInfo );

	sts			= OM_S_SUCCESS ;
	*msg			= MSSUCC ;

	progStart		= NULL ;
	program 		= NULL ;

	/*
	 * Get selection program to run.
	 */
	sts =
	om$send(msg	= message GRvg.GRgetattr( msg, (char *) &program ),
		senderid= myObj->objid,
		targetid= myObj->objid,
		targetos= myObj->osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	/*
	 * Compile and execute program.
	 */
	if( vs$compile(	error		= &err,
			program		= program,
			executable	= &progStart,
			aliases		= inParms.aliases )  ) {

		VSdumpProg( progStart ); 

	} /* else error */

	wrapup :

		if( progStart ) VSfreeProg( progStart ) ;
		_FREE( program ) ;

		return sts ;

}
/*----------------------------------------------------------------------------*/

end implementation VSselector ;
