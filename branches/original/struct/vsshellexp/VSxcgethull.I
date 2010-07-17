/*
	I/STRUCT
*/
class implementation VSexpandedCv ;

#include <stdio.h>
#include "msdef.h"
#include "vsshexpdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>
/*
 * Includes of function prototupes.
 */
#include "vsvecmxproto.h"
#include "vsvirtualinf.h"

/*----------------------------------------------------------------------------*/
method VSget_hull_surface( long 		*msg ;
			   struct GRid		*hlId ;
			   struct GRmd_env	*hlEnv )
{
	long			sts ;	/* OM completion code.		      */
	int			rc ;	/* Return code. 		      */
	struct GRid		shExp,	/* My shell expansion parent.	      */
				AShull ;/* Hull parent of shell expansion.    */
	struct GRmd_env 	shEnv ; /* Shell expansion env. 	      */

	SetProc( VSexpandedCv_VSget_hull_surface ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "VSget_hull_surface" //, argfmt = "", args = ``
        );

	/*
	 * Get my shell expansion parent.
	 */
	sts = om$send( msg	= message ACcpx.ACfind_temp_obj(
							  &rc,
							  VS_K_sxShellExpansion,
							  &shExp ),
		       targetid = my_id ) ;

	*msg = rc & 1 ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup ) ;

	sts = VSgetVirtualInfo( msg,
				&shExp,
				&shEnv,
				&shExp ) ;

	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	__DBGpr_obj( "Shell expansion", shExp ) ;

	/*
	 * Get hull of shell expansion.
	 */
	sts = om$send( msg	= message ACcpx.ACfind_temp_obj( &rc,
								 VS_K_sxShell,
								 &AShull ),
		       targetid = shExp.objid,
		       targetos = shExp.osnum ) ;

	*msg = rc & 1 ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup ) ;

	sts = VSgetVirtualInfo( msg,
				&AShull,
				hlEnv,
				hlId ) ;

	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	__DBGpr_obj( "Hull", *hlId ) ;

	VSmulmx( shEnv._MATRIX, hlEnv->_MATRIX, hlEnv->_MATRIX,
		 &hlEnv->_MATRIX_TYPE ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :

        __exitMethod ( name = "VSget_hull_surface", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End

		return sts ;

} /* VSget_hull_surface */
/*----------------------------------------------------------------------------*/

end implementation VSexpandedCv ;
