/*
	I/STRUCT
*/ 
class implementation VSimgFeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetSupports(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		*count ;
			VSsuppList	mySupports ) {

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

} /* method VSgetSupports */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

