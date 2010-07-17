/*
	I/STRUCT
*/
class implementation VSjoint ;

#include "EMSmsgdef.h"
#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VSputModJoints(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		count ;
			VSjointList	jList[] ) {

	SetProc( VSjoint_VSputModJoints ) ; Begin ; __DBGpr_me() ;

	/*
	 * We do not put modified joints between joints.
	 */

	*msg	= MSSUCC ;

	End
	return OM_S_SUCCESS ;

} /* method VSputModJoints */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;


