/*
	I/STRUCT
*/
class implementation VSrflPlate ;

#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetSupports(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		*count ;
			VSsuppList	mySupp ) {

	long		sts ;		/* OM return code	*/

	SetProc( VSrflPlate_VSgetSupports ) ; Begin ; __DBGpr_me() ;

	*count = 0 ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_plBotSfPath,
							&mySupp[0]._grid,
							NULL,
							NULL ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	mySupp[0].mod_env = *myEnv ;
	*count = 1 ;

	wrapup :
		End
		return sts ;

} /* method VSgetSupports */
/*----------------------------------------------------------------------------*/

end implementation VSrflPlate ;

