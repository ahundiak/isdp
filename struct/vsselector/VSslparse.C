/*
	I/STRUCT
*/
#include <string.h>
#include "vsslc.h"
#include "vsslcmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsslcproto.h"
/*----------------------------------------------------------------------------*/
int VSslcCompile( err, string, p, aliases )

VSparseErr	*err ;
char		*string ;
VS_NODE		**p ;
VSaliasTable	aliases ; {

	/*
	 * Compile program in "string".
	 */
	int	i,
		rc ;

	/*
	 * Init alias table.
	 */
	for( i = 0 ; i < VS_K_MAX_INPUT ; i++ ) aliases[i][0] = '\0' ;

	/*
	 * Initialize LEX's input.
	 */
	VSslcSetLEXstring( string ) ;

	err->msg = -1 ;

	rc = vs$parse( error = err, executable	= p, aliases = aliases ) ;

	/*
	 * Yacc returns 0 if OK.
	 */
	if( rc != 0 ) {
		/*
		 * Parsing error.
		 */
		if( *p ) {
			VSfreeProg( *p ) ;
			*p = NULL ;
		}
	}

	return !rc ;

} /* VSslcCompile */
/*----------------------------------------------------------------------------*/
int VSslcCheckSyntax( err, string, table, count )

VSparseErr	*err ;
char		*string ;
VSaliasTable	table ;
int		*count ; {

	/*
	 * Checks that program in "string" is syntactically correct.
	 */
	VS_NODE		*p = NULL ;
	VSaliasTable	aliases ;
	int		i,
			rc ;

	/*
	 * Init alias table.
	 */
	for( i = 0 ; i < VS_K_MAX_INPUT ; i++ ) aliases[i][0] = '\0' ;

	VSslcSetLEXstring( string ) ;

	rc = vs$parse( error = err, executable = &p, aliases = aliases ) ;

	if( table ) {
		int	cnt = 0 ;
		for( i = 0 ; i < VS_K_MAX_INPUT ; i++ ) {
			if( aliases[i][0] ) cnt++ ;
			strcpy( table[i], aliases[i] ) ;
		}
		if( count ) *count = cnt ;
	}

	return !rc ;

} /* VSslcCheckSyntax */
/*----------------------------------------------------------------------------*/

