/*
	I/STRUCT
*/
class implementation VSmergeShExp ;

#include <stdio.h>
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*
 * Includes of function prototypes.
 */

/*----------------------------------------------------------------------------*/
method NDdelete( struct GRmd_env *myEnv )
{
	long			sts,	 /* OM return code.		      */
				msg ;	 /* OM completion code. 	      */
	struct GRobj_env	frShExp, /* My "from" shell expansion parent. */
				toShExp ;/* My "to" shell expansion parent.   */

        __enterMethod ( name = "NDdelete" //, argfmt = "", args = ``
        );

	/*
	 * Get my "from" and "to" shell expansion parents.
	 */
	sts = om$send( msg	= message VSmergeShExp.VSget_shell_exp_parents(
								     &msg,
								     myEnv,
								     &frShExp,
								     &toShExp ),
		       targetid = my_id ) ;

	__CheckRC( sts, msg, "VSmergeShExp.VSget_shell_exp_parents", wrapup ) ;

	/*
	 * Unconsume my "from" shell expansion parent.
	 */
	sts = vs$unconsume( msg 	= &msg,
			    object	= &frShExp._grid,
			    mod_env	= &frShExp.mod_env ) ;

	__CheckRC( sts, msg, "vs$unconsume", wrapup ) ;

	/*
	 * Redisplay my "from" shell expansion parent.
	 */
	sts = vs$bulk_display( dpmode	= GRbd,
			       objenvs	= &frShExp ) ;

	__CheckRC( sts, 1, "vs$bulk_display", wrapup ) ;

	/*
	 * Unconsume my "to" shell expansion parent.
	 */
	sts = vs$unconsume( msg 	= &msg,
			    object	= &toShExp._grid,
			    mod_env	= &toShExp.mod_env ) ;

	__CheckRC( sts, msg, "vs$unconsume", wrapup ) ;

	/*
	 * Redisplay my "to" shell expansion parent.
	 */
	sts = vs$bulk_display( dpmode	= GRbd,
			       objenvs	= &toShExp ) ;

	__CheckRC( sts, 1, "vs$bulk_display", wrapup ) ;

	/*
	 * Delete myself.
	 */
	sts = om$send( msg	= message VSshellExp.NDdelete( myEnv ),
		       mode	= OM_e_wrt_message,
		       targetid = my_id ) ;

	wrapup :

        __exitMethod ( name = "NDdelete", argfmt = "sts = %d, msg = %#x", args = `sts, msg` );

		return sts ;

} /* NDdelete */
/*----------------------------------------------------------------------------*/

end implementation VSmergeShExp ;
