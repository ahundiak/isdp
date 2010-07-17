/*
	I/STRUCT
*/
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

extern OMuword	OPP_ACpretend_class_id,
		OPP_ACpretendin_class_id ;
/*----------------------------------------------------------------------------*/
long VSmakeUnitPretend( pretendId ) struct GRid *pretendId ; {

	OMuword pretendClassid ;
	long	sts ;
	char	*className ;

	sts = om$get_classid(	objid		= pretendId->objid,
				osnum		= pretendId->osnum,
				p_classid	= &pretendClassid ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	if( pretendClassid == OPP_ACpretend_class_id ) {
		className = "VSupretend" ;
	} else if( pretendClassid == OPP_ACpretendin_class_id ) {
		className = "VSupretendRF" ;
	} else goto wrapup ;
	
	om$change_class(	osnum		= pretendId->osnum,
				objid		= pretendId->objid,
				classname	= className ) ;

	wrapup :
		return OM_S_SUCCESS ;

} /* VSmakeUnitPretend */
/*----------------------------------------------------------------------------*/

