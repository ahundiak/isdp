/*
	I/STRUCT
*/
class implementation VSbeam ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetSupports(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		*count ;
			VSsuppList	mySupp ) {

	long		sts ;		/* OM return code		*/

	sts = om$send(	msg	= message VSbeam.VSgetSupportSf(
						       msg, myEnv, mySupp + 0 ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSupportSf", wrapup ) ;

	sts = om$send(	msg	= message VSbeam.VSgetSupportAxis(
						       msg, myEnv, mySupp + 1 ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

	*count	= 2 ;

	wrapup :
		return sts ;

} /* method VSgetSupports */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;

