/*
	I/STRUCT
*/
class implementation VSxscurveAG ;

#include "vsprofmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method NDmove_to_root(	long		*msg ;
			struct GRid	*src ;
			struct GRmd_env	*myEnv ; ) {

	long		sts ;		/* OM return code	*/
	int		size,		/* Array size		*/
			*map = NULL ;	/* Mapping array	*/

	SetProc( VSxscurveAG_NDmove_to_root ) ; Begin ; __DBGpr_me() ;

	sts = om$send(	msg	= message AScompcurve.NDmove_to_root(
							msg, src, myEnv ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "AScompcurve.NDmove_to_root", wrapup ) ;

#ifdef vsDEBUG
	__DBGpr_com( "Result of move-to-root" ) ; ShowObj( src ) ;
#endif

	sts = om$send(	msg	= message VScompcurve.VSgetMapping(
							msg, &size, &map ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScompcurve.VSgetMapping", wrapup ) ;

	sts = vs$moveGRccToXSection(	msg	= msg,
					GRccId	= src,
					usrIndex= map ) ;
	__CheckRC( sts, *msg, "vs$moveGRccToXSection", wrapup ) ;

#ifdef vsDEBUG
	__DBGpr_com( "After change-class" ) ; ShowObj( src ) ;
#endif
	wrapup :
		End
		_FREE( map );
		return sts ;

} /* method NDmove_to_root */
/*----------------------------------------------------------------------------*/

end implementation VSxscurveAG ;
