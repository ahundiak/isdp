/*
	I/STRUCT
*/
class implementation VSmergeShExp ;

#include <stdio.h>
#include "EMSmsgdef.h"
#include "vsshexpdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"
#include "vsvecmxproto.h"

/*----------------------------------------------------------------------------*/
method VSget_shell_exp_parents( long			*msg ;
				struct GRmd_env 	*myEnv ;
				struct GRobj_env	*frShell ;
				struct GRobj_env	*toShell )
{
	long			sts ;	  /* OM return code.		      */
	int			rc ;	  /* Return code.		      */

	SetProc( VSmergeShExp_VSget_shell_exp_parents ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "VSget_shell_exp_parents" //, argfmt = "", args = ``
        );

	if( !frShell && !toShell )
		vs$inv_arg() ;

	/*
	 * Get my "from" shell expansion parent if wanted.
	 */
	if( frShell ) {
		sts = om$send( msg	= message VSmergeShExp.ACfind_temp_obj(
							      &rc,
							      VS_K_sxFrShellExp,
							      &frShell->_grid ),
			       targetid = my_id ) ;

		*msg = rc & 1 ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "VSmergeShExp.ACfind_temp_obj", wrapup ) ;

		sts = VSgetVirtualInfo( msg,
					&frShell->_grid,
					&frShell->mod_env,
					&frShell->_grid ) ;

		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

		VSmulmx( myEnv->_MATRIX,
			 frShell->_matrix,
			 frShell->_matrix,
			 &frShell->_matrix_type ) ;

		__DBGpr_obj( "FROM shell expansion parent", frShell->_grid   ) ;
		__DBGpr_mat( "Matrix of FROM",		    frShell->_matrix ) ;
	}

	/*
	 * Get my "to" shell expansion parent.
	 */
	if( toShell ) {
		sts = om$send( msg	= message VSmergeShExp.ACfind_temp_obj(
							      &rc,
							      VS_K_sxToShellExp,
							      &toShell->_grid ),
			       targetid = my_id ) ;

		*msg = rc & 1 ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "VSmergeShExp.ACfind_temp_obj", wrapup ) ;

		sts = VSgetVirtualInfo( msg,
					&toShell->_grid,
					&toShell->mod_env,
					&toShell->_grid ) ;

		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

		VSmulmx( myEnv->_MATRIX,
			 toShell->_matrix,
			 toShell->_matrix,
			 &toShell->_matrix_type ) ;

		__DBGpr_obj( "TO   shell expansion parent", toShell->_grid   ) ;
		__DBGpr_mat( "Matrix of TO",		    toShell->_matrix ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :

        __exitMethod ( name = "VSget_shell_exp_parents", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End
		return sts ;

} /* VSget_shell_exp_parents */
/*----------------------------------------------------------------------------*/

end implementation VSmergeShExp ;
