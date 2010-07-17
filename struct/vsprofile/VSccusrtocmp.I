/*
	I/STRUCT
*/
class implementation VScompcurve ;

#include <limits.h>
#include "OMmacros.h"
#include "msdef.h"
#include "EMSutlmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VStransUsrIxToCmp(	long		*msg ;
				int		usrIndex ;
				int		*p_cmpIndex ;
				struct GRid	*p_cmpId ) {

	long	sts ;		/* OM return code	*/
	int	i,		/* Loop index		*/
		max,		/* Size of mapping array*/
		cmpIndex ;	/* Component index	*/

	SetProc( VScompcurve_VStransUsrIxToCmp ) ; Begin ; __DBGpr_me() ;

	/*
	 * We do not allow usrIndex to be VS_K_NULL_INDEX (-1), because several
	 * components may not have a user index.
	 */
	__DBGpr_int( "Usr index", usrIndex ) ;
	if( usrIndex < 0 || usrIndex > CHAR_MAX ) {
		*msg = MSINARG ; sts = OM_E_INVARG ; goto wrapup ;
	}
	cmpIndex = -1 ; max = om$dimension_of( varray = me->cmpToUsr ) ;
	for( i = 0 ; i < max ; i++ ) {
		if( me->cmpToUsr[i] == usrIndex ) {
			cmpIndex = i ;
			break ;
		}
	}

	__DBGpr_int( "Found component index", cmpIndex ) ;

	if( cmpIndex == -1 ) {
		*msg = MSFAIL ; sts = OM_W_INDEXEMPTY ; goto wrapup ;
	}

	if( p_cmpIndex ) {
		*p_cmpIndex = cmpIndex ;
	}
	if( p_cmpId ) {
		OM_S_CHANSELECT toCmps ;
		ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		             chan_selector = &toCmps ) ;

		sts = om$get_objid_at_index(	
					objid		= my_id,
					p_chanselect	= &toCmps,
					index		= cmpIndex,
					objidaddr	= &p_cmpId->objid,
					osnumaddr	= &p_cmpId->osnum ) ;
		__DBGpr_obj( "Component id", *p_cmpId ) ;

		if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		End
		return sts ;

} /* method VStransUsrIxToCmp */
/*----------------------------------------------------------------------------*/

end implementation VScompcurve ;
