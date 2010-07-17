/*
	I/STRUCT
*/
class implementation VSmrkPlate ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

	long	sts ;

	sts = om$send(	msg	= message VSimbPlate.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	myDef->type = VS_m_MRK_PLATE ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSmrkPlate ;
