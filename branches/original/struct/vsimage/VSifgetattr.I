/*
	I/STRUCT
*/ 
class implementation VSimgFeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method GRgetattr(	long	*msg ;
			char	*attr ) {

	long		sts ;
	struct GRid	mdl ;

	sts = om$send(	msg	= message VSimgFeature.VSgetModel( &mdl, NULL ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }

	sts = om$send(	msg	= OPPmargs,
			targetid= mdl.objid,
			targetos= mdl.osnum ) ;
	wrapup :
		return sts ;

} /* method GRgetattr */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

