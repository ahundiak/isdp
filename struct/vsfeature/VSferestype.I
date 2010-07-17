/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "OMmacros.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "ASsupport.h"
/*----------------------------------------------------------------------------*/
method VSgetResultType( long *msg ; unsigned long *result ) {

	long		sts ;
	struct GRid	complex,
			myGRid ;
	VSobjDef	myDef ;

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	/*
	 * If output of a macro ASget_as_owner, will return the id of the
	 * macro occurrence, but if it returns no owner, there is still a
	 * possibility that we are inside the graph of the macro definition,
	 * which we can be aware of thanks to ACin_macro_def.
	 */
	ASget_as_owner( &myGRid, &complex ) ;

	if( IF_NULL_OBJID( complex.objid ) ) {
		int	inDf ;
		sts = om$send(	msg	= message NDmacro.ACin_macro_def(
									&inDf ),
				targetid= my_id ) ;

		if( inDf ) *result = VS_m_IN_ASSEMBLY | VS_m_IN_DEFINITION ;
		else	   *result = 0 ;
	} else {
		*result = VS_m_IN_ASSEMBLY | VS_m_IN_OCCURRENCE ;
	}

	sts = om$send(	msg	= message VScpx.VSgetObjDef( msg, &myDef ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSgetObjDef", wrapup ) ;

	*result |= myDef.type ;

	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* method VSgetResultType */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
