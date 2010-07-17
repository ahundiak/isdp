/*
	I/STRUCT
*/ 
class implementation VSmodFeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetUserEditableAttr(	long			*msg ;
				unsigned long		*type ;
				unsigned long		*attr ; ) {

	long			sts,		/* OM return code	*/
				notUsed ;	/* Self-explanatory	*/
	struct GRid		source ;	/* Source element	*/

	/*
	 * Consumer beam in master file who comes from a consumed parent
	 * in a reference file is not editable.
	 */
	sts = om$send(	msg 	= message VSfeature.VSforwardToSource(
					&notUsed,
					OM_e_wrt_object,
					message NDmacro.ACreturn_foot(
								 msg,
								 "",
								 &source,
								 NULL,
								 NULL ) ),
			targetid= my_id ) ;

	if( source.osnum != OM_Gw_current_OS ) {
		sts = om$send(	msg	= message VSpart.VSgetUserEditableAttr(
							msg, type, attr ),
				targetid= source.objid,
				targetos= source.osnum ) ;
		*attr = 0 ; 
		goto wrapup ;
	}
	
	/*
	 * Traverse the graph up through all the consumed parts.
	 */
	sts = om$send(	msg	= message VSfeature.VSforwardToSource(
					&notUsed, OM_e_wrt_object, OPPmargs ),
			targetid= my_id ) ;

	sts = om$send(	msg 	= message VSfeature.VSforwardToOriginal(
					&notUsed,
					OM_e_wrt_object,
					message VSfeature.VSgetResultType(
								 msg, type ) ),
			targetid= my_id ) ;

	wrapup :
		return sts ;

} /* method VSgetUserEditableAttr */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;
