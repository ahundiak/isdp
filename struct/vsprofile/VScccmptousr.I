/*
	I/STRUCT
*/
class implementation VScompcurve ;

#include "OMmacros.h"
#include "msdef.h"
#include "EMSutlmacros.h"
#include "vsdatadef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VStransCmpToUsrIx(	long		*msg ;
				int		cmpIndex ;
				struct GRid	*cmpId ;
				int		*p_usrIndex ) {

	long	sts ;	/* OM return code	*/

	SetProc( VScompcurve_VStransCmpToUsrIx ) ; Begin ; __DBGpr_me() ;

	if( cmpId ) {
		OM_S_CHANSELECT toCmps ;
	  	ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		       	     chan_selector = &toCmps ) ;

		__DBGpr_obj( "Cmp id", *cmpId ) ;
		sts = om$get_index(	objid_c		= my_id,
					p_chanselect	= &toCmps,
					objid		= cmpId->objid,
					osnum2		= cmpId->osnum,
					indexaddr	= (OMuint *) &cmpIndex);
		if( !( sts & 1 ) ) { *msg = MSINARG ; goto wrapup ; }
	}

	__DBGpr_int( "Component index", cmpIndex ) ;
	if(    cmpIndex < 0
	    || cmpIndex >= om$dimension_of( varray = me->cmpToUsr ) ) {
	    	sts = OM_E_INVARG ; *msg = MSINARG ; goto wrapup ;
	}

	if( (int) me->cmpToUsr[cmpIndex] != VS_K_NULL_INDEX ) {
		*p_usrIndex = me->cmpToUsr[cmpIndex] ;
	} else {
		/*
		 * Component curve has no user index: return the opposite of
		 * its component index.
		 */
		*p_usrIndex = -cmpIndex ;
	}
	__DBGpr_int( "User index found", *p_usrIndex ) ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		End
		return sts ;

} /* method VStransCmpToUsrIx */
/*----------------------------------------------------------------------------*/

end implementation VScompcurve ;
