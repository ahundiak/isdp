/*
	I/STRUCT
*/ 
class implementation VSornBeam ;

#include <string.h>
#include "vsdbgmacros.h"

extern char	DIR_G_car_dir ;
/*----------------------------------------------------------------------------*/
method VSsymmetrizeName(	long		*msg ;
				GRname		nameOfOutput,
						symmName ) {

	char		*symmMember,	/* Name of output after symmetry*/
			*lastMember ;	/* Of path to output		*/

	/*
	 * Isolate last member of name.
	 */
	if( lastMember = strrchr( nameOfOutput, DIR_G_car_dir ) ) {
		int length = lastMember - nameOfOutput + 1 ;

		lastMember++ ;
		/*
		 * End string after last DIR_G_car_dir.
		 */
		strncpy( symmName, nameOfOutput, length )[length] = '\0' ;
	} else {
		*symmName = '\0' ;
		lastMember = nameOfOutput ;
	}
	
	/*
	 * If Front/Back symmetry, swap end caps.
	 */
		if( !strcmp( lastMember, VS_K_bmBeginCap) )
			symmMember = VS_K_bmEndCap ;
	else	if( !strcmp( lastMember, VS_K_bmEndCap	) )
			symmMember = VS_K_bmBeginCap ;
	else		symmMember = lastMember ;

	strcat( symmName, symmMember ) ;

	*msg = MSSUCC ;

	return OM_S_SUCCESS ;
	
} /* method VSsymmetrizeName */
/*----------------------------------------------------------------------------*/
 
end implementation VSornBeam ;

