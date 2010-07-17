/*
	I/STRUCT
*/
class implementation VSxscurveAG ;

#include "vsprofmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method NDcopy_to_root(	long		*msg ;
			int		cp_type ;
			struct GRmd_env	*myEnv,
					*rootEnv ;
			struct GRid	*rootId ; ) {

	long		sts ;		/* OM return code	*/
	int		size,		/* Array size		*/
			*map = NULL ;	/* Mapping array	*/
	struct GRid	GRccId ;

	SetProc( VSxscurveAG_NDcopy_to_root ) ; Begin ; __DBGpr_me() ;

	sts = om$send(	msg	= message AScompcurve.NDcopy_to_root(
					msg, cp_type, myEnv, rootEnv, rootId ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "AScompcurve.NDcopy_to_root", wrapup ) ;

#ifdef vsDEBUG
	__DBGpr_com( "Result of move-to-root" ) ; ShowObj( rootId ) ;
#endif

	sts = om$send(	msg	= message NDnode.ASreturn_go(
						&GRccId, NULL, NULL ),
			targetid= rootId->objid,
			targetos= rootId->osnum ) ;
	__CheckRC( sts, 1, "NDnode.ASreturn_go", wrapup ) ;

#ifdef vsDEBUG
	__DBGpr_com( "Graphic object" ) ; ShowObj( &GRccId ) ;
#endif

	sts = om$send(	msg	= message VScompcurve.VSgetMapping(
							msg, &size, &map ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScompcurve.VSgetMapping", wrapup ) ;

	sts = vs$moveGRccToXSection(	msg	= msg,
					GRccId	= &GRccId,
					usrIndex= map ) ;
	__CheckRC( sts, *msg, "vs$moveGRccToXSection", wrapup ) ;

#ifdef vsDEBUG
	__DBGpr_com( "After change-class" ) ; ShowObj( &GRccId ) ;
#endif
	wrapup :
		End
		_FREE( map );
		return sts ;

} /* method NDcopy_to_root */
/*----------------------------------------------------------------------------*/
method ACcopy_to_Groot(	long		*msg ;
			int		cp_type ;
			struct GRmd_env	*myEnv,
					*rootEnv ;
			struct GRid	*rootId ; ) {

	return om$send(	msg	= message NDnode.NDcopy_to_root(
						msg, cp_type, myEnv, rootEnv,
						rootId ),
			targetid= my_id ) ;

} /* method ACcopy_to_root */
/*----------------------------------------------------------------------------*/

end implementation VSxscurveAG ;
