/*
	I/STRUCT

	VSget_geometry
	--------------
Abstract

	This function gets the geometry of a curve or surface object.
	The resultant geometry must be freed by the caller using `free()'.

Arguments

OUT	long			*msg	completion code
IN	const struct GRid	*go	object from which to get geometry
IN	const struct GRmd_env	*mod	module environment of object
OUT	char			**geometry
					the geometry
						struct IGRbsp_curve
					OR	struct IGRbsp_surface
*/
class implementation GRvg ;

#include <stdio.h>
#include <stdlib.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "GRabsgutil.h"
/*----------------------------------------------------------------------------*/
int VSget_geometry( msg, go, mod, geometry )

long			*msg ;
const struct GRid	*go ;
const struct GRmd_env	*mod ;
char			**geometry ; {

	char	*generic_pointer ; 
	long    numBytes,
		sts ;

	*geometry = NULL ;

	GRabsg_del_all() ;

	/*
	 * Compute the number of bytes required
	 */
	sts = om$send(	msg	= message GRvg.GRgetsize(
					msg,
					&((struct GRmd_env*)mod)->_MATRIX_TYPE,
					((struct GRmd_env*)mod)->_MATRIX,
					&numBytes ),
			senderid = go->objid,
			targetid = go->objid,
			targetos = go->osnum ) ;
	if( !( sts & 1 ) ) *msg = EMS_E_OMerror ;
        __CheckRC( sts, *msg, "GRvg.GRgetsize", wrapup ) ;

	/*
	 * Malloc the required memory
	 */
        generic_pointer = _MALLOC( numBytes, char ) ;
        if( !generic_pointer ) { *msg = MANOMEMORY ; goto wrapup ; }

	/*
	 * Get the geometry
	 */
        sts = om$send( msg    = message GRvg.GRgetgeom(
        			msg,
				&((struct GRmd_env*)mod)->_MATRIX_TYPE,
				((struct GRmd_env*)mod)->_MATRIX,
				generic_pointer ),
			senderid = go->objid,
			targetid = go->objid,
			targetos = go->osnum ) ;
	if( !( sts & 1 ) ) *msg = EMS_E_OMerror ;
	if( 1 & sts & *msg )     *geometry = generic_pointer;
	else                     _FREE( generic_pointer ) ;
        __CheckRC( sts, *msg, "GRvg.GRgetgeom", wrapup ) ;

	wrapup : return *msg & 1 ;

} /* VSget_geometry */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;

