/*
	I/STRUCT
*/
class implementation VSxtrBeam ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs 2

	long		sts ;	/* OM return code		*/
	static char	*iNames  [nbInputs] = {	VS_K_mbParentBeam,
						VS_K_xbTrimSurf		} ;
	static int	 iTypes  [nbInputs] = {	macro_generic,
						other_generic } ;

	sts = om$send(	msg	= message VSbeam.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	myDef->type			= VS_m_XTR_BEAM ;
	myDef->minInput			= nbInputs ;
	myDef->input.count		= nbInputs ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;

	myDef->i2o.count		= 0 ;
	myDef->i2o.names		= NULL ;
	myDef->i2o.type.types		= NULL ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSxtrBeam ;
