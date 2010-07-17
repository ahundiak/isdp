/*
	I/STRUCT
*/
class implementation VScompcurve ;

#include <limits.h>
#include "OMmacros.h"
#include "msdef.h"
#include "EMSutlmacros.h"
#include "vsdatadef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSinitMapping(	long	*msg ;
			int	usrIndices[] ) {

	long	sts ;	/* OM return code	*/
	int	i,	/* Loop index		*/
		nbCmp ;	/* Count of components	*/

	SetProc( VScompcurve_VSinitMapping ) ; Begin ; __DBGpr_me() ;

	{ OM_S_CHANSELECT toCmps ;
	  ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		       chan_selector = &toCmps ) ;

	  sts = om$get_channel_count(	objid		= my_id,
					p_chanselect	= &toCmps,
					count		= (OMuint *) &nbCmp ) ;
	  if( !( sts & 1 ) ) { *msg = EMS_E_OMerror ; goto wrapup ; }
	}

	if( !nbCmp ) {
		*msg	= EMS_E_ChanCountWrong ;
		sts	= OM_W_ABORT ;
		goto wrapup ;
	}

#ifdef vsDEBUG
	for( i = 0 ; i < nbCmp ; i++ ) {
		__DBGpr_int( "Array", usrIndices[i] ) ;
	}
#endif
	sts = om$vla_set_dimension(	varray	= me->cmpToUsr,
					size	= nbCmp ) ;
	if( !( sts & 1 ) ) { *msg = EMS_E_NoDynamicMemory ; goto wrapup ; }

	for( i = 0 ; i < nbCmp ; i++ ) {
		if( 0 <= usrIndices[i] && usrIndices[i] <= CHAR_MAX
		    || usrIndices[i] == VS_K_NULL_INDEX ) {
		    	__DBGpr_int( "Put", usrIndices[i] ) ;
			me->cmpToUsr[i] = usrIndices[i] ;
		} else {
			*msg = MSINARG ; sts = OM_E_INVARG ; goto wrapup ;
		}
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		End
		return sts ;

} /* method VSinitMapping */
/*----------------------------------------------------------------------------*/

end implementation VScompcurve ;
