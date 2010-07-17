/*
	I/STRUCT
*/
class implementation VSselector ;

#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsslcdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs   VS_K_MAX_INPUT
#define nbOutputs  VS_K_MAX_OUTPUT
#define maxName	   10

	int		i ;
	static char	*iNames  [nbInputs]  ;
	static int	 iTypes  [nbInputs]  ;
	static char	*oNames	 [nbOutputs] ;
	static char	iNameBuf[maxName * nbInputs ] ; 
	static char	oNameBuf[maxName * nbOutputs] ;

	if( !iNames[0] ) {
		char	*n = iNameBuf ;
		for( i = 0 ; i < nbInputs ; i++ ) {
			iTypes[i] = other_generic ;
			sprintf( iNames[i] = n, "input%d", i ) ;
			n += maxName ;

		}
	}

	if( !oNames[0] ) {
		char	*n = oNameBuf ;
		for( i = 0 ; i < nbOutputs ; i++ ) {
			sprintf( oNames[i] = n, "output%d", i ) ;
			n += maxName ;
		}
	}

	myDef->info			= VS_gI_Selector ;
	myDef->type			= 0 ;
	myDef->minInput			= 1 ;
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

	*msg	= MSSUCC ;

	return OM_S_SUCCESS ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSselector ;
