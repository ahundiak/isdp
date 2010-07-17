/*
	I/STRUCT
*/
class implementation VSsubBeam ;

#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs 3

	long		sts ;	/* OM return code		*/
	static char	*iNames  [nbInputs]	= {	VS_K_mbParentBeam,
							VS_K_prPrvAttr,
							VS_K_prUsrAttr	} ;
	static int	 iTypes  [nbInputs]	= {	macro_generic,
							gen_rg_collect,
							gen_rg_collect	} ;

	sts = om$send(	msg	= message VSbeam.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	myDef->type			= VS_m_SUB_BEAM ;
	myDef->minInput			= 1 ;
	myDef->input.count		= nbInputs ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;

	myDef->i2o.count		= 0 ;
	myDef->i2o.names		= NULL ;
	myDef->i2o.type.types		= NULL ;

	/*
	 * When I consume my parent, I can have it in 2D only.
	 */
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSsubBeam ;
