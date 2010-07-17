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
method VSputDivJoints(	long		*msg ;
			struct GRmd_env	*myEnv ;
			char		*dir ;
			int		count ;
			VSjointList	jList[] ) {

	*msg	= MSSUCC ;

	return OM_S_SUCCESS ;

} /* method VSputDivJoints */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;


