/*
	I/STRUCT
*/ 
class implementation VShelper ;

#include <stdlib.h>
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method GRconstruct( struct GRvg_construct *cl ) {

	long			*msg,		/* Completion code	*/
				sts ;		/* OM return code	*/
	struct GRid		*src ;		/* Source objects	*/
	struct VScnst_list 	*attr ;		/* Class attributes	*/

	msg = cl->msg ;

	attr = (struct VScnst_list *) cl->class_attr ;

	if( !( src = _MALLOC( attr->parent_count, struct GRid ) ) ) {
		vs$mem_fail() ;
	}

	sts = om$send(	msg	= message VScpx.VSpre_construct( cl, src ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSpre_construct", wrapup ) ;

	sts = om$send(	msg	= message ACncpx.ACput_NV_rep(
							attr->representation ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "ACncpx.ACput_NV_rep", wrapup ) ;

	if( attr->feature_att ) {
		sts = om$send(	msg	= message GRvg.GRputattr(
						msg, attr->feature_att ),
				targetid= my_id ) ;
		if( !( sts & 1 & *msg ) ) goto wrapup ;
	}
	sts = om$send(	msg	= message VScpx.VSevaluate(
							msg,
							attr->parent_count,
							src,
							cl->env_info,
							cl->level,
							cl->display ),
				targetid= my_id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	if( cl->name && *cl->name ) {

		sts = om$send(	msg	= message GRgraphics.GRputname(
								msg, cl->name ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRputname", wrapup ) ;
	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		_FREE( src ) ;
		if( sts & 1 & *msg ) {
			*msg = MSSUCC ;
		} else {

			om$send(msg	= message NDnode.NDdelete(
								cl->env_info ),
				targetid= my_id ) ;
			if( *msg & 1 ) *msg = MSFAIL ;
		}
		return sts ;

} /* method GRconstruct */
/*----------------------------------------------------------------------------*/

end implementation VShelper ;
