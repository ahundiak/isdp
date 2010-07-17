/*
	I/STRUCT
*/
class implementation VSmergeShExp ;

#include <stdio.h>
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"

/*----------------------------------------------------------------------------*/
method VSget_limiting_points( long		*msg ;
			      struct GRmd_env	*myEnv ;
			      double		*beginPoint,
						*endPoint )
{
	long			sts ;	  /* OM return code.		      */
	int			i ;	  /* Loop index.		      */
	struct GRobj_env	frShExp,  /* My "from" shell expansion parent.*/
				toShExp ; /* My "to" shell expansion parent.  */
	double			frBeg[3], /* Begin point of "from" shell exp. */
				frEnd[3], /* End point of "from" shell exp.   */
				toBeg[3], /* Begin point of "to" shell exp.   */
				toEnd[3] ;/* End point of "to" shell exp.     */

	SetProc( VSmergeShExp_VSget_limiting_points ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "VSget_limiting_points" //, argfmt = "", args = ``
        );

	for( i=0; i<3; i++ ) {
		beginPoint[i] = IGE_DESIGN_LIMITS_MIN ;
		endPoint[i]   = IGE_DESIGN_LIMITS_MAX ;
	}

	/*
	 * Get my "from" and "to" shell expansion parents.
	 */
	sts = om$send( msg	= message VSmergeShExp.VSget_shell_exp_parents(
								     msg,
								     myEnv,
								     &frShExp,
								     &toShExp ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VSmergeShExp.VSget_shell_exp_parents", wrapup ) ;

	/*
	 * Get limiting points of "from" shell expansion.
	 */
	sts = om$send( msg	= message VSshellExp.VSget_limiting_points(
							       msg,
							       &frShExp.mod_env,
							       frBeg,
							       frEnd ),
		       targetid = frShExp._objid,
		       targetos = frShExp._osnum ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_limiting_points", wrapup ) ;

	__DBGpr_vec( "Begin point of FROM shell expansion", frBeg ) ;
	__DBGpr_vec( "End   point of FROM shell expansion", frEnd ) ;

	/*
	 * Get limiting points of "to" shell expansion.
	 */
	sts = om$send( msg	= message VSshellExp.VSget_limiting_points(
							       msg,
							       &toShExp.mod_env,
							       toBeg,
							       toEnd ),
		       targetid = toShExp._objid,
		       targetos = toShExp._osnum ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_limiting_points", wrapup ) ;

	__DBGpr_vec( "Begin point of TO   shell expansion", toBeg ) ;
	__DBGpr_vec( "End   point of TO   shell expansion", toEnd ) ;

	/*
	 * Find my limiting points.
	 */
	if( frBeg[0] == toEnd[0] ) {
		VSvccpy( beginPoint, toBeg ) ;
		VSvccpy( endPoint,   frEnd ) ;
	} else if( frEnd[0] == toBeg[0] ) {
		VSvccpy( beginPoint, frBeg ) ;
		VSvccpy( endPoint,   toEnd ) ;
	} else	vs$inv_arg() ;

	__DBGpr_vec( "Begin point", beginPoint ) ;
	__DBGpr_vec( "End   point", endPoint   ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :

        __exitMethod ( name = "VSget_limiting_points", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End
		return sts ;

} /* VSget_limiting_points */
/*----------------------------------------------------------------------------*/

end implementation VSmergeShExp ;
