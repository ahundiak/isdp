/*
	I/STRUCT
*/ 
class implementation VSsubFeature ;

#include "exmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetUserEditableAttr(	long			*msg ;
				unsigned long		*type ;
				unsigned long		*attr ; ) {

	long			sts,		/* OM return code	*/
				rc ;		/* Local return code	*/
	OMuword			curOs ;		/* Current OS           */

	*msg = MSSUCC ;

	/*
	 * Get basic feature type from the original feature. Don't use your
	 * feature type since the sender of this message is rather interested
	 * in your instrinsic type rather than the operation result which you
	 * represent.
	 */
	sts = om$send(	msg 	= message VSfeature.VSforwardToOriginal(
					&rc, OM_e_wrt_object, OPPmargs ),
			targetid= my_id ) ;
	if( !( rc & 1 ) ) *msg = MSFAIL ;
	__CheckRC( sts, *msg, "VSfeature.VSforwardToOriginal", wrapup ) ;

	/*
	 * If the sub-feature is not in master file, the sub-feature is
	 * not editable.
	 */
	ex$get_cur_mod( osnum = &curOs ) ;

	if( OM_Gw_current_OS != curOs ) *attr = 0 ; 

	wrapup :
		 return sts ;

} /* method VSgetUserEditableAttr */
/*----------------------------------------------------------------------------*/

end implementation VSsubFeature ;
