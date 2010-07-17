/*
	I/STRUCT
*/
class implementation VSgapPlate ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs	2
#define nbOutputs	2

	long		sts ;	/* OM return code		*/
	static char	*iNames [nbInputs] = {	VS_K_mpParentPlate,
						VS_K_cpSplittingPlate	} ;
	static int	iTypes  [nbInputs] = {	macro_generic,
						macro_generic } ;
	static char	*fNames [nbOutputs]= {	VS_K_cpGrCmpSurf0,
						VS_K_cpGrCmpSurf1	} ;

	sts = om$send(	msg	= message VSplate.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	myDef->type			= VS_m_GAP_PLATE ;
	myDef->minInput			= nbInputs ;
	myDef->input.count		= nbInputs ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;

	myDef->output.count		= nbOutputs ;
	myDef->output.names		= fNames ;

	/*
	 * IOs.
	 */
	myDef->i2o.count		= 0 ;
	myDef->i2o.type.types		= NULL ;
	myDef->i2o.names		= NULL ;

	/*
	 * When I consume my parent, I can have 2D only.
	 */
	myDef->parentRep		= AC_2D_REP | VS_m_2dWCompute ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSgapPlate ;

