/*
	I/STRUCT
*/ 
class implementation VSimgFeature ;

#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetUserEditableAttr(	long		*msg ;
				unsigned long	*type,
						*attr ; ) {
	long		sts ;
	struct GRid	mdl ;


	sts = om$send(	msg	= message VSimgFeature.VSgetModel( &mdl, NULL ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }

	sts = om$send(	msg	= OPPmargs,
			targetid= mdl.objid,
			targetos= mdl.osnum ) ;
	wrapup :
		/*
		 * Images are not editable.
		 */
		*attr = 0 ;

		return sts ;

} /* method VSgetUserEditableAttr */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

