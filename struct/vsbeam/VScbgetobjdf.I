/*
	I/STRUCT
*/
class implementation VSsplBeam ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs 	2
#define nbOutputs	2

	long		sts ;	/* OM return code		*/
	static char	*iNames [nbInputs] = {	VS_K_mbParentBeam,
						VS_K_cbSplittingPlate	} ;
	static int	iTypes  [nbInputs] = {	macro_generic,
						macro_generic		} ;
	static char	*oNames [nbOutputs]  = {VS_K_cbAxis0,
						VS_K_cbAxis1		} ;

	sts = om$send(	msg	= message VSbeam.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	myDef->type			= VS_m_SPL_BEAM ;
	myDef->minInput			= nbInputs ;
	myDef->input.count		= nbInputs ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;

	myDef->output.count		= nbOutputs ;
	myDef->output.names		= oNames ;

	/*
	 * IOs.
	 */
	myDef->i2o.count		= 0 ;
	myDef->i2o.type.types		= NULL ;
	myDef->i2o.names		= NULL ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/
end implementation VSsplBeam ;

