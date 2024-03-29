/*
	I/STRUCT
*/
class implementation VSvarPlate ;

#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs 4

	long		sts ;	/* OM return code		*/
	static char	*iNames  [nbInputs] = {	VS_K_plSuppSurf,
						VS_K_vpThicknessExp,
						VS_K_prPrvAttr,
						VS_K_prUsrAttr	} ;
	static int	 iTypes  [nbInputs] = {	other_generic,
						double_type,
						gen_rg_collect,
						gen_rg_collect	} ;

	sts = om$send(	msg	= message VSplate.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	myDef->info			= VS_gI_VarPlate ;
	myDef->type			= VS_m_VAR_PLATE ;
	myDef->minInput			= 2 ;
	myDef->input.count		= nbInputs ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;

	/*
	 * IOs.
	 */
	myDef->i2o.count		= 0 ;
	myDef->i2o.names		= NULL ;
	myDef->i2o.type.types		= NULL ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSvarPlate ;
