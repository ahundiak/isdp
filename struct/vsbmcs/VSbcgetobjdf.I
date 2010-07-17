/*
	I/STRUCT
*/
class implementation VSbeamCS ;

#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vspxdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs   1
#define nbOutputs  1

	long		sts ;		/* OM return code		*/
	static char	*iNames[nbInputs ] = {	VS_K_pxParentBeam	} ;
	static int	 iTypes[nbInputs ] = {	macro_generic		} ;
	static char	*oNames[nbOutputs] = {	"coordSys"		} ;

	myDef->info			= VS_gI_BeamCS ;
	myDef->type			= 0 ;
	myDef->minInput			= nbInputs ;
	myDef->input.count		= nbInputs ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;
	myDef->i2o.count		= 0 ;
	myDef->i2o.names		= NULL ;
	myDef->i2o.type.types		= NULL ;

	/*
	 * Feet.
	 */
	myDef->output.count		= nbOutputs ;
	myDef->output.names		= oNames ;
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

end implementation VSbeamCS ;

