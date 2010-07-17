/*
	I/STRUCT
*/
class implementation VSsubJoint ;

#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs 5

	long		sts ;		/* OM return code		*/
	static char	*iNames  [nbInputs] = {	VS_K_jnParentJn,
						VS_K_jnFeature0,
						VS_K_jnFeature1,
						VS_K_prPrvAttr,
						VS_K_prUsrAttr         } ;
	static int	 iTypes  [nbInputs] = {	macro_generic,
						macro_generic,
						macro_generic,
						gen_rg_collect,
						gen_rg_collect		} ;

	sts = om$send(	msg	= message VSjoint.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	myDef->info			= VS_gI_Joint ;
	myDef->type			= VS_m_SUB_JOINT ;
	myDef->minInput			= nbInputs - 2 ;
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

end implementation VSsubJoint ;
