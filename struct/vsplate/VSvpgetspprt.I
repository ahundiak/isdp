/*
	I/STRUCT
*/
class implementation VSvarPlate ;

#include "exmacros.h"
#include "madef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
/*----------------------------------------------------------------------------*/
method VSgetSupports(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		*count ;
			VSsuppList	mySupp ) {

	long		sts ;		/* OM return code	*/
	int		ACrc ;		/* AC completion code	*/

	/*
	 * Use ancestor's method to get support surface, then get parent
	 * expression.
	 */
	sts = om$send(	msg	= message VSsrcPlate.VSgetSupports(
						msg, myEnv, count, mySupp ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSsrcPlate.VSget_support", wrapup ) ;

	sts = om$send(	msg	= message ACcpx.ACfind_temp_obj(
							&ACrc,
							VS_K_vpThicknessExp,
							&mySupp[*count]._grid ),
			targetid= my_id ) ;
	*msg = ACrc ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup ) ;

	mySupp[*count]._md_os = mySupp[*count]._osnum ;
	ex$get_modid(	mod_osnum	= mySupp[*count]._md_os,
			mod_id		= &mySupp[*count]._md_id ) ;
	mySupp[*count]._matrix_type = MAIDMX ;
	MAidmx( msg, mySupp[*count]._matrix ) ;

	(*count)++ ;

	wrapup :
		return sts ;

} /* method VSgetSupports */
/*----------------------------------------------------------------------------*/

end implementation VSvarPlate ;

