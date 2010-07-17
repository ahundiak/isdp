/*
	I/STRUCT
*/
class implementation VSsurfOfProj ;

#include "vsglobalmsg.h"
#include "vssurfpjdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs 3
#define nbOutputs	1

	long		sts ;		/* OM return code		*/
	
	/* For inputs */
	static char	*iNames[nbInputs] = {	VS_K_sfPlane,
						VS_K_sfCurve,
						VS_K_sfWidth	      } ;

	static int	 iTypes[nbInputs] = {	other_generic,
						other_generic,
						parameter_generic     } ;
						
	/* For outputs */
	static	char	*oNames	 [nbOutputs] = { VS_K_sfSurfOfProj } ;	

	myDef->info			= VS_gI_SfOfPjPrlToPln ;
	myDef->type			= 0 ;
	myDef->minInput			= 3 ;
	
	/*
	 * Inputs.
	 */
	myDef->input.count		= nbInputs ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;
	
	/*
	 * Outputs.
	 */
	myDef->output.count		= nbOutputs ;
	myDef->output.names		= oNames ;
	myDef->output.type.classids	= NULL ;
	
	/*
	 * Virtual outputs.
	 */
	myDef->virtual.count		= 0 ;
	
	/*
	 * IOs.
	 */
	myDef->i2o.count 		= 0 ; 

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSsurfOfProj ;

