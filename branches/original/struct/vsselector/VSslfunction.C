/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include "DIdef.h"
#include "msdef.h"
#include "vsslc.h"
#include "vsslcmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsslcproto.h"
/*----------------------------------------------------------------------------*/
int VSisTestCpxFcn( function ) char *function ; {

	/*
	 * Check that we have the name of a function testing the type of a
	 * macro (ie. its definition name).
	 * Those function have a name of the form "%<mac-def-name>%".
	 */
	int	l = strlen( function ) ;

	return     l > 2
		&& function[0]   == '%'
		&& function[l-1] == '%' ;

} /* VSisTestCpxFcn */
/*----------------------------------------------------------------------------*/
void VSslcExtractCpxName( function, name ) char *function, *name ; {

	int		l = strlen( function ) ;

	l -= 2 ;

	strncpy( name, function + 1, l )[l] = '\0' ;

} /* VSslcExtractCpxName */
/*----------------------------------------------------------------------------*/
int VSslcFunction( msg, function, argc, argv, res )

long		*msg ;
int		argc ;
VSexecRes	*function,
		argv[],
		*res ; {

	/*
	 * Executes a function.
	 */
	char	*fcn ;

	fcn = function->_sval ;

	/*
	 * Check args type here !.
	 */
	       if( !strcmp( fcn, VS_K_internalBEAM  ) )	{

		VSevalBeamLF( msg, argc, argv, res ) ;

	} else if( !strcmp( fcn, VS_K_internalPLATE ) ) {

		VSevalPlateLF( msg, argc, argv, res ) ;

	} else if( !strcmp( fcn, VS_K_internalDISTANCE ) ) {

		VSevalDistanceLF( msg, argc, argv, res ) ;

	} else if( !strcmp( fcn, VS_K_internalDSPREP ) ) {

		VSevalRepresentationLF( msg, argc, argv, res ) ;

	} else if( VSisTestCpxFcn( fcn ) ) {

		char	cpxName[DI_PATH_MAX] ;

		VSslcExtractCpxName( fcn, cpxName ) ;

		VSevalCpxType( msg, &argv[0]._oval, cpxName, res ) ;
	} else {
		/*
		 * Unknown function.
		 */
		*msg = MSINARG ;
	}

	return *msg & 1 ;

} /* VSslcFunction */
/*----------------------------------------------------------------------------*/

