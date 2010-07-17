/*
	I/STRUCT
*/
class implementation VSjoint ;

#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetJoints(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		*count ;
			VSjointList	**jList ) {

	SetProc( VSjoint_VSgetJoints ) ; Begin ; __DBGpr_me() ;

	/*
	 * There are no joints between joints.
	 */
	*jList	= NULL ;
	*count	= 0 ;
	*msg	= MSSUCC ;

	End
	return OM_S_SUCCESS ;

} /* method VSgetJoints */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

