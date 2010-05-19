/* $Id: VDgetgeom.I,v 1.3 2002/05/08 22:09:26 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdmisc/VDgetgeom.I
 *
 * Description:
 *		Get geometry size + buffer.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDgetgeom.I,v $
 *	Revision 1.3  2002/05/08 22:09:26  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2002/05/08 22:07:02  ylong
 *	return appropriate status for VD_get_geometry()
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/11/21  00:57:28  pinnacle
# Replaced: ./vdmisc/VDgetgeom.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			adz		creation date
 *
 ***************************************************************************/
/*
	I/VDS	Copy.

	VD_get_geometry
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
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "GRabsgutil.h"
/*----------------------------------------------------------------------------*/
int VD_get_geometry( msg, go, mod, geometry )

long			*msg ;
const struct GRid	*go ;
const struct GRmd_env	*mod ;
char			**geometry ; {

	char	*generic_pointer = NULL ;
	long    numBytes = 0 ,
		sts ;

	*geometry = NULL ;

	GRabsg_del_all() ;

	__DBGpr_obj(" Object ", *go );
	__DBGpr_mat(" Matrix ", ((struct GRmd_env*)mod)->_MATRIX );

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
	__DBGpr_int(" sts ", sts );
	__DBGpr_int(" msg ", *msg );

	if( !( sts & 1 ) ) *msg = EMS_E_OMerror ;
        __CheckRC( sts, *msg, "GRvg.GRgetsize", wrapup ) ;

	/*
	 * Malloc the required memory
	 */
	__DBGpr_int(" numBytes ", numBytes );
	if( ! numBytes ){ *msg = EMS_E_OMerror ; goto wrapup ; }

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
	if( !( *msg & sts & 1 ) ){
		*msg = EMS_E_OMerror ;
		_FREE( generic_pointer ) ;
	}
	else{	*geometry = generic_pointer;	}

        __CheckRC( sts, *msg, "GRvg.GRgetgeom", wrapup ) ;

	wrapup : 
		/*
		 * GRgenabsg does not set the internal "occupant" to
		 * NULL_OBJECT as result geom buffer will be 
		 * returned.
		 */
		if( !( 1 & sts & *msg )) GRabsg_del_all();
		return (sts & *msg & 1 );

} /* VD_get_geometry */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;

