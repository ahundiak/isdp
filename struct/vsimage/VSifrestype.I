/*
	I/STRUCT
*/
class implementation VSimgFeature ;

#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetResultType( long *msg ; unsigned long *result ) {

	long		sts ;
	struct GRid	mdl ;

	*result = 0 ;

	sts = om$send(	msg	= message VSimgFeature.VSgetModel( &mdl, NULL ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, result ),
			targetid= mdl.objid,
			targetos= mdl.osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

	     if( *result & VS_m_BEAM  ) *result = VS_m_BEAM  | VS_m_IMG_generic;
	else if( *result & VS_m_PLATE ) *result = VS_m_PLATE | VS_m_IMG_generic;
	else if( *result & VS_m_JOINT ) *result = VS_m_JOINT | VS_m_IMG_generic;
	else				*result = 0 ;

	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* method VSgetResultType */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;
