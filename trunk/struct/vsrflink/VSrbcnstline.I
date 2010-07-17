/*
	I/STRUCT
*/
class implementation VSrflBeam ;

#include "vsmiscmacros.h"
#include "vsbeammacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VScnst_line_rep(	long			*msg ;
			struct GRmd_env         *my_env ;
			struct GRobj_env	supports[2];
			struct GRvg_construct	*cst ;
			struct GRid  		*profile ;
			struct GRid  		*linearRep ) {

	long			sts ;	/* OM return code	*/
	struct GRobj_env        axis ;	/* Support axis		*/

	sts = om$send(	msg	= message VSbeam.VSgetSupportAxis(
							msg, my_env, &axis ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSupports", wrapup ) ;
/* RM IF OK
        sts = om$send( msg	= message VSbeam.VSextractProfile(
					msg, my_env, supports + 0, supports + 1,
					0.0, cst, AC_2D_REP, &prfl ),
                       targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ;

	vs$bulk_delete(	grids = profile, theEnv = cst->env_info ) ;

	*profile = prfl ;
RM IF OK*/
	sts = vs$make_linear_beam_rep(	msg		= msg,
					xSection	= profile,
					surface		= supports + 0,
					axis		= &axis,
					copyAxis	= TRUE,
					cst		= cst,
					linearRep	= linearRep ) ; 
	 __CheckRC( sts, *msg, "vs$make_linear_beam_rep", wrapup ) ;

	wrapup : 
		return sts ;

}/* method VScnst_line_rep */
/*----------------------------------------------------------------------------*/

end implementation VSrflBeam ;

