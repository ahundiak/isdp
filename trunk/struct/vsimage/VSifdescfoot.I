/*
	I/STRUCT
*/ 
class implementation VSimgFeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSdescribeOutput( long *msg ; char *nameOfOutput, *description ) {

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

} /* method VSdescribeOutput */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

