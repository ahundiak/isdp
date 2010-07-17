/*
	I/STRUCT
*/
class implementation VSplate ;

#include "EMSutlmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetFaceCount( long *msg ; int *count ) {

	long		sts ;
	struct GRid	solid ;
	OMuint		chCount ;
	OM_S_CHANSELECT toCmps ;

	sts = om$send(	msg	= message ACncpx.ACreturn_foot(
					msg, VS_K_plGrCmpName, &solid,
					NULL, NULL ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "ACncpx.ACreturn_foot", wrapup ) ;

	ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		     chan_selector = &toCmps ) ;
	sts = om$get_channel_count(	objid		= solid.objid,
					osnum		= solid.osnum,
					count		= &chCount,
					p_chanselect	= &toCmps ) ;
	*count = (int) chCount ;

	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* method VSgetFaceCount */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
