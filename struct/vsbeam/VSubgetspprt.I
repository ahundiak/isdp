/*
	I/STRUCT
*/
class implementation VSsubBeam ;

#include "exmacros.h"
#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetSupportSf(	long			*msg ;
			struct GRmd_env		*myEnv ;
			struct GRobj_env 	*sf ) {

	long		sts ;
	struct GRid	divMgr ;

	sts = om$send( msg	= message VSfeature.VSgetConsumedParent(
							msg, &divMgr, NULL ),
		       targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetConsumedParent", wrapup ) ;

	sts = om$send( msg	= message VSbeam.VSgetSupportSf(
							msg, myEnv, sf ),
		       targetid = divMgr.objid,
		       targetos = divMgr.osnum ) ;

	wrapup :
		return sts ;
	
} /* method VSgetSupportSf */
/*----------------------------------------------------------------------------*/
method VSgetSupportAxis(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env 	*axis ) {

	long		sts ;		/* OM return code		*/
	int		myIndex ;	/* My index in parent's ordering*/
	struct GRid	superBeam ;	/* My parent beam at index #0	*/
	char		*name	 ;	/* Names of parent's input	*/

	sts = om$send(	msg	= message VSsubFeature.VSgetIndex( 
								msg, &myIndex ),
			targetid= my_id ) ;

	switch( myIndex ) {
		case 0 : name = VS_K_cbAxis0 ; break ;
		case 1 : name = VS_K_cbAxis1 ; break ;
		default: *msg = MSINARG ; sts = OM_E_INVARG ; goto wrapup ;
	}

	sts = om$send(	msg	= message VSfeature.VSgetConsumedParent(
							msg, &superBeam, NULL ),
			targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetConsumedParent", wrapup ) ;

	sts = om$send( msg	= message NDmacro.ACreturn_foot(
							msg,
							name,
							&axis->_grid,
							&axis->_matrix_type,
							axis->_matrix ),
			targetid= superBeam.objid,
			targetos= superBeam.osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	axis->_md_os = axis->_osnum ;
	ex$get_modid(	mod_osnum	= axis->_md_os,
			mod_id		= &axis->_md_id ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* method VSgetSupportAxis */
/*----------------------------------------------------------------------------*/

end implementation VSsubBeam ;

