/*
	I/STRUCT
*/ 
class implementation VSfrzBeam ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method ACbecome_foot(	long		*msg ;
			struct GRid	*newObj ;
			struct GRmd_env	*my_env ) {

	newObj->objid	= my_id ;
	newObj->osnum	= OM_Gw_current_OS ;
	*msg		= MSSUCC ;

	return OM_S_SUCCESS ;

} /* method ACbecome_foot */
/*----------------------------------------------------------------------------*/

end implementation VSfrzBeam ;

