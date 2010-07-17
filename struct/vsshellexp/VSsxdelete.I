/*
	I/STRUCT
*/
class implementation VSshellExp ;

#include <stdio.h>
#include "nddef.h"
#include "msdef.h"
#include "vsshexpdef.h"
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
	long			sts ;	   /* OM return code.		      */
	int			count ;    /* Count of parents. 	      */
	struct GRid		yTransID ; /* ACrg_collect where y translation*/
					   /* is stored.		      */

	SetProc( VSshellExp_NDdelete ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "NDdelete" //, argfmt = "", args = ``
        );

	if( me->flagAttr & VS_K_sxUseYTranslation ) {

		__DBGpr_com( "Change state of y translation object" ) ;

		sts = om$send( msg	= message NDnode.NDget_objects(
								    ND_ROOT,
								    NULL,
								    0,
								    NULL,
								    0,
								    OM_K_MAXINT,
								    &count ),
			       targetid = my_id ) ;

		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

		__DBGpr_int( "Count of parents", count ) ;

		if( count ) {

			sts = om$send( msg	= message NDnode.NDget_objects(
								      ND_ROOT,
								      &yTransID,
								      1,
								      NULL,
								      count-1,
								      count-1,
								      &count ),
				       targetid = my_id ) ;

			__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

			__DBGpr_obj( "Y translation object", yTransID ) ;

			sts = om$send( msg	= message NDnode.NDchg_state(
								 ND_DEL_NO_CH,
								 ND_DEL_NO_CH ),
				       targetid = yTransID.objid,
				       targetos = yTransID.osnum ) ;

			__CheckRC( sts, 1, "NDnode.NDchg_state", wrapup ) ;
		}
	}

	sts = om$send( msg	= message VShelper.NDdelete( myEnv ),
		       mode	= OM_e_wrt_message,
		       targetid = my_id ) ;

	__CheckRC( sts, 1, "VShelper.NDdelete", wrapup ) ;

	sts = OM_S_SUCCESS ;

	wrapup :

        __exitMethod ( name = "NDdelete", argfmt = "sts = %d", args = `sts` );

		End
		return sts ;

} /* NDdelete */
/*----------------------------------------------------------------------------*/

end implementation VSshellExp ;
