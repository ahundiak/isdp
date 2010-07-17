/*
	I/STRUCT
*/
class implementation VSrfsBeam ;

#include "vsglobalmsg.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

	long		sts ;	/* OM return code		*/

	sts = om$send(	msg	= message VSrflBeam.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	/*
	 * Override field set by above message send.
	 */
	myDef->info			= VS_gI_Stiffener ;
	myDef->type			= VS_m_STF_BEAM ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSrfsBeam ;
