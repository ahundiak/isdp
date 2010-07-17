/*
	I/STRUCT
*/
class implementation VSsomeObjcVw ;

#include "OMmacros.h"
/*----------------------------------------------------------------------------*/
method DPdisbyoid(	long			*msg ;
			enum GRdpmode		*mode ;
			struct GRid		*objList ;
			IGRlong			*objCount ;
			IGRshort		*mxTypeList ;
			IGRmatrix		*mxList[] ;
			struct IGRaltdisplay	*alt_symb ) {

	long		sts ;
	int		i,
			found = -1 ;
	struct GRid	theObjToDisplay ;

	om$send(msg	= message VSsomeObjcVw.getObjectToDisplay(
							&theObjToDisplay ),
		targetid= my_id ) ;

	if( IF_NULL_OBJID( theObjToDisplay.objid ) ) {
		*msg = MSSUCC ; return OM_S_SUCCESS ;
	}

	for( i = 0 ; i < *objCount ; i++ ) {
		if( IF_EQ_OBJID( objList[i].objid, theObjToDisplay.objid )
		    && objList[i].osnum == theObjToDisplay.osnum ) {
		    	found = i ; break ;
		}
	}

	if( found != -1 ) {
		long	noOids = 1 ;
		sts = om$send(	msg	= message IGEgragad.DPdisbyoid(
						msg,
						mode,
						objList + found,
						&noOids,
						mxTypeList + found,
						mxList + i,
						alt_symb ),
				targetid= my_id,
				mode	= OM_e_wrt_message ) ;
	} else {
		sts = OM_S_SUCCESS ; *msg = MSSUCC ;
	}

	return sts ;

} /* method DPdisbyoid */
/*----------------------------------------------------------------------------*/

end implementation VSsomeObjcVw ;
