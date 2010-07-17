/*
	I/STRUCT
*/
class implementation VSbooBeam ;

#include <stdio.h>
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define maxName		10

	long		sts ;	/* OM return code		*/
	static char	*iNames[1+VS_K_bbMAX_NOTCHES] = { NULL } ;
	static int	 iTypes[1+VS_K_bbMAX_NOTCHES] ;
	static char	nameBuf[maxName * VS_K_bbMAX_NOTCHES] ;

	sts = om$send(	msg	= message VSbeam.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	if( !iNames[0] ) {
		char	*n = nameBuf ;
		int	i ;

		iNames[0] = VS_K_mbParentBeam ;
		iTypes[0] = macro_generic ;

		for( i = 1 ; i < VS_K_bbMAX_NOTCHES + 1 ; i++ ) {
			iTypes[i] = other_generic ;
			sprintf( iNames[i] = n, "solid%d", i-1 ) ;
			n += maxName ;
		}
	}
	myDef->type			= VS_m_BOO_BEAM ;
	myDef->minInput			= 2 ;
	myDef->input.count		= 1 + VS_K_bbMAX_NOTCHES ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;

	/*
	 * IOs.
	 */
	myDef->i2o.count		= 0 ;
	myDef->i2o.type.types		= NULL ;
	myDef->i2o.names		= NULL ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSbooBeam ;

