/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "vsslc.h"
#include "vsslcmacros.h"
#include "VSslyacc.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsslcproto.h"

extern char	DIR_G_car_dir ;
/*----------------------------------------------------------------------------*/
int VSslcCountFcnArgs( arglist ) VS_NODE *arglist ; {

	int	count ;
	VS_NODE	*a ;

	for( a = arglist, count = 0 ; a ; a = a->a2 ) count++ ;
	return count ;

} /* VSslcCountFcnArgs */
/*----------------------------------------------------------------------------*/
int VSslcCheckFunction( err, function, arglist, aliases )

VSparseErr	*err ;
VS_TOKEN	*function ;
VS_NODE		*arglist ;
VSaliasTable	aliases ; {

	/*
	 * Verifies that function exists, that its argument count is correct,
	 * and its arguments are defined.
	 */
	long	msg ;				/* Completion code	*/
	int	rc,				/* Return code		*/
		argc ;				/* Count of args	*/
	char	*fname	= function->_sval ;	/* Name of function	*/
	VS_NODE	*a ;				/* Loop-on-args pointer	*/

#define NULL_RES ( (VSexecRes *) NULL )

	argc = VSslcCountFcnArgs( arglist ) ;

	       if( !strcmp( fname, VS_K_internalBEAM ) ) {

		rc = VSevalBeamLF( &msg, argc, NULL_RES, NULL_RES ) ;

	} else if( !strcmp( fname, VS_K_internalPLATE ) ) {

		rc = VSevalPlateLF( &msg, argc, NULL_RES, NULL_RES ) ;

	} else if( !strcmp( fname, VS_K_internalDISTANCE ) ) {

		rc = VSevalDistanceLF( &msg, argc, NULL_RES, NULL_RES ) ;

	} else if( !strcmp( fname, VS_K_internalDSPREP ) ) {

		rc = VSevalRepresentationLF( &msg, argc, NULL_RES, NULL_RES ) ;

	} else if( VSisTestCpxFcn( fname ) ) {

		rc = argc == 1 ;

	} else {
		VStktxt	F ;

		vs$translateKw(	toFlag	= VS_K_TO_EXTERNAL,
				inKw	= fname,
				outKw	= F ) ;
				
		VSslcSetParseErr( VS_UNKNOWN_FUNCTION, F, err ) ;
		rc = FALSE ;
		goto wrapup ;
	}

	if( !rc ) {
		VStktxt	F ;

		vs$translateKw(	toFlag	= VS_K_TO_EXTERNAL,
				inKw	= fname,
				outKw	= F ) ;
				
		VSslcSetParseErr( VS_BAD_ARG_COUNT, F, err ) ;
		goto wrapup ;
	}

	/*
	 * Check that all input idents exist.
	 * Look for arguments in alias table.
	 */
	rc = TRUE ;
	for( a = arglist ; a ; a = a->a2 ) {

		if( vs$searchAlias(	table	= aliases,
					alias	= a->a1->_sval ) == -1 ) {
			rc = FALSE ;
			VSslcSetParseErr( VS_UNKNOWN_IDENT, a->a1->_sval, err ) ;
			break ;
		}
	}
	wrapup :
		return rc ;

} /* VSslcCheckFunction */
/*----------------------------------------------------------------------------*/
int VSslcSplitPath( err, table, path, complex, output )

VSparseErr	*err ;
VSaliasTable	table ;
VS_TOKEN	*path,
		*complex,
		*output ; {

	char	*p ;
	int	rc = FALSE ;

	if( p = strchr( path->_sval, DIR_G_car_dir ) ) {
		*p = '\0' ;
		if( vs$searchAlias(	table	= table,
					alias	= path->_sval ) != -1 ) {
			strcpy( complex->_sval, path->_sval ) ;
			strcpy( output->_sval, p + 1 ) ;
			complex->type	= VS_IDENT ;

			output->type	= VS_string ;
			rc = TRUE ;
		} else {
			VSslcSetParseErr( VS_UNKNOWN_IDENT, path->_sval, err ) ;
		}
		*p = DIR_G_car_dir ;
	} else {
		VSslcSetParseErr( VS_INVALID_PATH, path->_sval, err ) ;
	}

	return rc ;

} /* VSslcSplitPath */
/*----------------------------------------------------------------------------*/
