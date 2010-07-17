/*
	I/STRUCT
*/
class implementation VSgapDtector ;

#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsgddef.h"
#include "vsmiscmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs 	2
#define nbOutputs	VS_K_gdMaxOutputs
#define nbVirtOuts	2
#define maxName		10

	long		sts ;		/* OM return code		*/
	static char	*iNames[nbInputs ]	= { VS_K_gdInputBeam,
						    VS_K_gdInputMaxAdmGap } ;
	static int	 iTypes[nbInputs ]	= { macro_generic,
						    double_type		} ;
	static char	*oNames[nbOutputs]	= { NULL } ;
	static char	nameBuf[maxName * nbOutputs] ;

	static char	*vNames[nbVirtOuts]	= { VS_K_gdVirtOutMaxAdmGap,
						    VS_K_gdVirtOutExcessGap } ;
	/*
	 * Virtual feet's types.
	 */
	static int	vTypes[nbVirtOuts]	= {	double_type,
							double_type	} ;

	if( !oNames[0] ) {
		char	*n = nameBuf ;
		int	i ;

		for( i = 0 ; i < nbOutputs ; i++ ) {
			sprintf( oNames[i] = n, "marker%d", i ) ;
			n += maxName ;
		}
	}

	myDef->info			= VS_gI_GapDetector ;
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
	myDef->virtual.count		= nbVirtOuts ;
	myDef->virtual.names		= vNames ;
	myDef->virtual.type.types	= vTypes ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSgapDtector ;

