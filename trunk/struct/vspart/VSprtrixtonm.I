/*
	I/STRUCT
*/
class implementation VSpart ;

#include <stdio.h>
#include <string.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "DItypedef.h"
#include "DImacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"
/*----------------------------------------------------------------------------*/
method VStransIPATHToName(	long		*msg ;
				VSixPath	*ipath ;
				GRname		name ) {

	int	i ;		/* Loop-on-path-indices index	*/
	GRname	dollarN ;	/* Character string for "$<N>"	*/

	for( i = 0 ; i < ipath->sz ; i++ ) {
		VSgenCmpName( ipath->ls[i], dollarN ) ;

		if( i == 0 ) {
			strcpy( name, dollarN ) ;
		} else {
			di$strcat( to = name, from = dollarN ) ;
		}
	}
	*msg	= MSSUCC ;

	return OM_S_SUCCESS ;

} /* method VStransIPATHToName */
/*----------------------------------------------------------------------------*/

end implementation VSpart ;
