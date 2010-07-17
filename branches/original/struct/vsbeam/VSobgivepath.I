/*
	I/STRUCT
*/
class implementation VSornBeam ;

#include <string.h>
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method ACgive_path(	int		*ok ;
			struct GRid	*idOfOutput ;
			char		*nameOfOutput ; ) {

	long		sts,		/* OM return code		*/
			msg ;		/* Completion code		*/
	GRname		symmName ;	/* Path to output after symmetry*/

	/*
	 * Get non-symmetrized path to output.
	 */
	sts = om$send(	msg	= message VSmodBeam.ACgive_path(ok,
								idOfOutput,
								nameOfOutput ),
			targetid= my_id,
			mode	= OM_e_wrt_message ) ;
	__CheckRC( sts, (*ok != 0), "ACcpx.ACgive_path", wrapup ) ;

	/*
	 * Transform name of output into its symmetric.
	 */
	sts = om$send(	msg	= message VSornBeam.VSsymmetrizeName(
								&msg,
								nameOfOutput,
								symmName ),
			targetid= my_id ) ;
	*ok = msg & 1 ;
	__CheckRC( sts, msg, "VSornBeam.VSsymmetrizeName", wrapup ) ;

	strcpy( nameOfOutput, symmName ) ;

	wrapup:
		return sts ;
	
} /* method ACgive_path */
/*----------------------------------------------------------------------------*/
 
end implementation VSornBeam ;

