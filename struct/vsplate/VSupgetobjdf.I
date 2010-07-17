/*
	I/STRUCT
*/
class implementation VSsubPlate ;

#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs 3

	long		sts ;	/* OM return code		*/
	static char	*iNames  [nbInputs]	= {	VS_K_mpParentPlate,
							VS_K_prPrvAttr,
							VS_K_prUsrAttr	} ;
	static int	 iTypes  [nbInputs]	= {	macro_generic,
							gen_rg_collect,
							gen_rg_collect	} ;

	sts = om$send(	msg	= message VSplate.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	myDef->type			= VS_m_SUB_PLATE ;
	myDef->minInput			= nbInputs - 2 ;
	myDef->input.count		= nbInputs ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;

	/*
	 * IOs.
	 */
	myDef->i2o.count		= 0 ;
	myDef->i2o.type.types		= NULL ;
	myDef->i2o.names		= NULL ;

	/*
	 * When I consume my parent, I can have it in 2D only.
	 */
	myDef->parentRep		= AC_2D_REP | VS_m_2dWCompute ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSsubPlate ;

