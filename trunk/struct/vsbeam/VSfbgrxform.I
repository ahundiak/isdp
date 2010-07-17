/*
	I/STRUCT
*/ 
class implementation VSfrzBeam ;

#include "EMSutlmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method GRxform(	long		*msg ;
		struct GRmd_env	*myEnv ;
		short		*xfType ;
		IGRmatrix	xfMx ;
		OM_S_OBJID	*newObjid ; ) {

	long		sts ;
	OM_S_CHANSELECT	toComponents ;

	ems$make_chanselect(	chan_label	= GRcmpowner_to_components,
	 			chan_selector	= &toComponents ) ;

	sts = om$send(	msg	     = message GRvg.GRxform(
					msg, myEnv, xfType, xfMx, newObjid ),
			p_chanselect = &toComponents ) ;
	__CheckRC( sts, *msg, "GRvg.GRxform", wrapup ) ;

	me->length *= xfMx[15] ;

	sts = om$send(	msg	= message NDnode.NDchange_node( myEnv ),
			targetid= my_id ) ;

	*newObjid = my_id ;

	wrapup :
		return sts ;

} /* method GRxform */
/*----------------------------------------------------------------------------*/

end implementation VSfrzBeam ;

