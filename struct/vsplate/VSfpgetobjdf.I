/*
	I/STRUCT
*/
class implementation VSfrzPlate ;

#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs 2

	long		sts ;		/* OM return code		*/
	static char	*iNames[nbInputs] = {	VS_K_prPrvAttr,
						VS_K_prUsrAttr } ;
	static int	 iTypes[nbInputs] = {	gen_rg_collect,
						gen_rg_collect } ;

	sts = om$send(	msg	= message VSplate.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	myDef->info			= VS_gI_Plate ;
	myDef->type			= VS_m_FRZ_PLATE ;
	myDef->minInput			= 1 ;
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

end implementation VSfrzPlate ;
