/*
	I/STRUCT
*/
class implementation VSintCrsSctn ;

#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

	long	sts ;

	sts = om$send(	msg	= message VSprjCrsSctn.VSgetObjDef(
								msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	myDef->info = VS_gI_IntCrsSctn ;


	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSintCrsSctn ;
