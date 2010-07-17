/*
	I/STRUCT
*/
class implementation VSpart ;

#include <stdio.h>
#include <stdlib.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VStransNameToIPATH(	long		*msg ;
				char		*name ;
				VSixPath	*ipath ) {
	long	sts ;

	sts = OM_W_ABORT ;

	/*
	 * (Sub-)components have a name in the form:
	 *			$<n1>:$<n2>:$<n3>:...
	 */
	if( *name == VS_K_GENERIC_CMP_MARKER ) {
		char	*n,
			*next ;
		int	index ;

		n		= name ;
		ipath->sz	= 0 ;
		while( *n ) {
			/*
			 * Skip leading '$'.
			 */
			n++ ;

			index = strtol( n, &next, 0 ) ;

			if( next != n && index >= 0 ) {
				if( ipath->sz < VS_K_MAXOWNDEPTH ) {
					ipath->ls[ipath->sz++] = index ;
					/*
					 * Skip next ':' if not at end of string
					 */
					if( *next ) {
						n = next + 1 ;
					} else {
						n = next ; /* Stop looping */
					}
				} else {
					*msg = EMS_E_InvalidArg ;
					goto wrapup ;
				}
			} else {
				/* Extra character at the end, negative index:
				 * ill-formed name : error.
				 */
				*msg = EMS_E_InvalidArg ;
				goto wrapup ;
			}
		} /* while */

		*msg	= MSSUCC ;
		sts	= OM_S_SUCCESS ;
	} else {
		/*
		 * Not a direct indexing: one may need further translation
		 * to retrieve index.
		 */
		 *msg = EMS_W_NoSolution ;
	}
	wrapup :	
		return sts ;

} /* method VStransNameToIPATH */
/*----------------------------------------------------------------------------*/

end implementation VSpart ;
