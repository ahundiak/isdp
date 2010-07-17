/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#include "vsdef.h"
#include "vsdatadef.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"
/*----------------------------------------------------------------------------*/
void VSgenCmpName( cmpIndex, name )

int	cmpIndex ;
char	*name ; {

	/*
	 * Given an index <n> creates a generic name "<marker><n>".
	 */
	sprintf( name, "%c%d", VS_K_GENERIC_CMP_MARKER, cmpIndex ) ;

} /* VSgenCmpName */
/*----------------------------------------------------------------------------*/
int VSreadGenericName( name, p_index )

char	*name ;
int	*p_index ; {

	int	rc = FALSE ;

	/*
	 * Given a generic name "<marker><n>", returns <n>.
	 */

	/*
	 * Begins with VS_K_GENERIC_CMP_MARKER ?
	 */
	if( *name == VS_K_GENERIC_CMP_MARKER ) {
		char *ptr ;

		*p_index = strtol( name + 1, &ptr, 0 ) ;
		/*
		 * Followed by valid integer (positive) ?
		 */
		if( ptr == name + 1 || *p_index < 0 ) {
			*p_index = VS_K_NULL_INDEX ;
		} else {
			rc = TRUE ;
		}
	}
	return rc ;

} /* VSreadGenericName */
/*----------------------------------------------------------------------------*/
int VSreadGenericNameAcceptNegative( name, p_index )

char	*name ;
int	*p_index ; {

	/*
	 * Same as above but does not err if index read is < 0.
	 */
	int	rc = FALSE ;

	/*
	 * Begins with '$' ?
	 */
	if( *name == VS_K_GENERIC_CMP_MARKER ) {
		char *ptr ;

		*p_index = strtol( name + 1, &ptr, 0 ) ;
		/*
		 * Followed by integer ?
		 */
		if( ptr == name + 1 ) {
			*p_index = VS_K_NULL_INDEX ;
		} else {
			rc = TRUE ;
		}
	}
	return rc ;

} /* VSreadGenericNameAcceptNegative */
/*----------------------------------------------------------------------------*/
