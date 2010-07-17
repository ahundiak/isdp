/*
	I/STRUCT
*/
class implementation VSrfvPlate ;

#include "vsglobalmsg.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

	long		sts ;	/* OM return code		*/

	sts = om$send(	msg	= message VSrflPlate.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	/*
	 * Override field set by above message send.
	 */
	myDef->info			= VS_gI_VarPlate ;
	myDef->type			= VS_m_VAR_PLATE ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSrfvPlate ;
