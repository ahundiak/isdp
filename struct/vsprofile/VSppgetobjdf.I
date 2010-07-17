/*
	I/STRUCT
*/
class implementation VSproffrplts ;

#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vssectiondef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbRoots 1
#define nbFeet  2

	long		sts ;		/* OM return code		*/
	static char	*tNames[nbRoots] = {	VS_K_ppParentCS	} ;
	static int	 tTypes[nbRoots] = {	ref_generic	} ;
	static char	*fNames[nbFeet ] = {	VS_K_WoFilletCv,
						VS_K_EnvelopeCv } ;

	myDef->info			= VS_gI_CmpPrfl ;
	myDef->type			= 0 ;
	myDef->minInput			= nbRoots ;
	myDef->input.count		= nbRoots ;
	myDef->input.names		= tNames ;
	myDef->input.type.types		= tTypes ;
	myDef->i2o.count		= 0 ;
	myDef->i2o.names		= NULL ;
	myDef->i2o.type.types		= NULL ;

	/*
	 * Feet.
	 */
	myDef->output.count		= nbFeet ;
	myDef->output.names		= fNames ;
	myDef->output.type.classids	= NULL ;

	/*
	 * Virtual feet.
	 */
	myDef->virtual.count		= 0 ;
	myDef->virtual.names		= NULL ;
	myDef->virtual.type.types	= NULL ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSproffrplts ;
