/*
	I/STRUCT
*/
class implementation VSimbPlate ;

#include <stdio.h>
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define maxName		10

	long		sts ;	/* OM return code		*/
	static char	*iNames[VS_K_MAX_BOUNDARIES + 1] = { NULL } ;
	static int	 iTypes[VS_K_MAX_BOUNDARIES + 1] ;
	static char	nameBuf[maxName * VS_K_MAX_BOUNDARIES] ;

	sts = om$send(	msg	= message VSplate.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	if( !iNames[0] ) {
		char	*n = nameBuf ;
		int	i ;

		iNames  [0] = VS_K_mpParentPlate ;
		iTypes  [0] = macro_generic ;

		for( i = 1 ; i < VS_K_MAX_BOUNDARIES + 1 ; i++ ) {
			iTypes[i] = curve_generic ;
			sprintf( iNames[i] = n, "bndry%d", i-1 ) ;
			n += maxName ;
		}
	}
	myDef->type			= 0 ;
	myDef->minInput			= 2 ;
	myDef->input.count		= VS_K_MAX_BOUNDARIES + 1 ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;

	/*
	 * IOs.
	 */
	myDef->i2o.count		= 0 ;
	myDef->i2o.type.types		= NULL ;
	myDef->i2o.names		= NULL ;

	/*
	 * When I consume my parent, I can have it in 2D only.
	 */
	myDef->parentRep		= AC_2D_REP | VS_m_2dWCompute ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSimbPlate ;

