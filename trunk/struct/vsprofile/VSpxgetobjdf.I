/*
	I/STRUCT
*/
class implementation VSprjCrsSctn ;

#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbRoots 3
#define nbFeet  1

	long		sts ;		/* OM return code		*/
	static char	*tNames  [nbRoots] = {	VS_K_pxParentBeam,
						VS_K_pxSurface,
						VS_K_pxCurveOffset	} ;
	static int	 tTypes  [nbRoots] = {	macro_generic,
						other_generic,
						double_type		} ;
	static char	*fNames	 [nbFeet ] = {	VS_K_pxPrjCurve		} ;

	myDef->info			= VS_gI_PrjCrsSctn ;
	myDef->type			= 0 ;
	myDef->minInput			= 2 ;
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

end implementation VSprjCrsSctn ;
