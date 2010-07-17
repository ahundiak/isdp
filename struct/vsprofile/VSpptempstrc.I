/*
	I/STRUCT
*/
class implementation VSproffrplts ;

#include <string.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vssectiondef.h"
#include "vsxsfpmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method ACfind_temp_struct(	int			*ACrc ;
				char			*name ;
				struct ret_struct	*value;
				struct GRmd_env		*modEnv ) {

	long		sts,		/* OM return code		*/
			msg ;
	int		nbPlates,	/* Count of plate defs		*/
			nbCnxs,		/* Count of connections		*/
#define __H	0
#define __W	1
#define __FT	2
#define __WT	3
			what ;
	VSxsPlContour	contour ;	/* Contour of connected plates	*/
	VSxsPlShpDesc	shapeDescr ;	/* Description of contour shape	*/
	VSxsPlParms	parms ;		/* Parameters of contour	*/

	sts	= OM_S_SUCCESS ;
	*ACrc	= TRUE ;
	msg	= MSSUCC ;
	
	       if( !strcmp( name, VS_K_scHeight	) ) {
	       	what = __H ;
	} else if( !strcmp( name, VS_K_scWidth	) ) {
		what = __W ;
	} else if( !strcmp( name, VS_K_scFlgThk	) ) {
		what = __FT ;
	} else if( !strcmp( name, VS_K_scWebThk	) ) {
		what = __WT ;
	} else if( !strcmp( name, VS_K_scFltRad	) ) {
		value->var.root_pm_st.value = 0. ;
		goto wrapup ;
	} else {
		return om$send(	msg	= message ACncpx.ACfind_temp_struct(
						ACrc, name, value, modEnv ),
				targetid= my_id,
				mode	= OM_e_wrt_message ) ;
	}

	nbPlates = om$dimension_of( varray = me->plateDefs ) ;
	nbCnxs	 = om$dimension_of( varray = me->plateCnxs ) ;
	if( !nbPlates ) vs$inv_arg( msg = &msg ) ;

	sts = vs$getContour(	msg		= &msg,
				nbPlates	= nbPlates,
				plates		= me->plateDefs,
				nbCnxs		= nbCnxs,
				connections	= me->plateCnxs,
				contour		= &contour,
				shapeDescr	= &shapeDescr ) ;
	__CheckRC( sts, msg, "vs$getContour", wrapup ) ;

	if( shapeDescr.shapeType == VS_K_UNKNOWN_SHAPE )
		vs$inv_arg( msg = &msg ) ;

	sts = VSgetContourParameters(	&msg,
					&contour,
					shapeDescr.shapeType,
					shapeDescr.nmIndices,
					&parms );
	__CheckRC( sts, msg, "VSgetContourParameters", wrapup ) ;

	switch( what ) {
		case	__W	:
			value->var.root_pm_st.value = parms.width ;
			break ;
		case	__H	:
			value->var.root_pm_st.value = parms.height ;
			break ;
		case	__FT	:
			value->var.root_pm_st.value = parms.flgThickness ;
			break ;
		case	__WT	:
			value->var.root_pm_st.value = parms.webThickness ;
			break ;
	}
	wrapup :
		*ACrc = sts & 1 & msg ? TRUE : FALSE ;

		return sts ;

} /* method ACfind_temp_struct */
/*----------------------------------------------------------------------------*/

end implementation VSproffrplts ;

