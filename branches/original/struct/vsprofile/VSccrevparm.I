/*
	I/STRUCT
*/
class implementation VScompcurve ;

#include <stdlib.h>
#include "OMprimitives.h"
#include "msdef.h"
#include "EMSutlmacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetchanobj.h"
/*----------------------------------------------------------------------------*/
method GRrevparm( long			*msg ;
		  struct GRmd_env	*md_env ) {

	long		sts ;
	int		i,
			nbOldMapping,
			*oldMapping = NULL,
			*newMapping = NULL,
			nbCmps,
			cmpIndex ;
	struct GRid	moi,
			*cmpId = NULL ;
	OM_S_CHANSELECT toCmps ;

	SetProc( VScompcurve_GRrevparm ); Begin

	__DBGpr_me() ;

	moi.objid = my_id ;
	moi.osnum = OM_Gw_current_OS ;

	/*
	 * Get mapping.
	 */
	sts = om$send( msg	= message VScompcurve.VSgetMapping(
					      msg, &nbOldMapping, &oldMapping ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VScompcurve.VSgetMapping", wrapup ) ;

	__DBGpr_int( "Size of old mapping array", nbOldMapping ) ;

#ifdef vsDEBUG
	__DBGpr_com( "Old mapping" ) ;
	for( i=0; i<nbOldMapping; i++ ) {
		printf( "\t%d -> %d\n", i, oldMapping[i] ) ;
	}
#endif

	/*
	 * Get my components.
	 */
	ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		     chan_selector = &toCmps ) ;
	sts = VS_GetChanObjWithMalloc( &moi, &toCmps, &nbCmps, &cmpId ) ;

	if( !( sts & 1 ) ) *msg = MSFAIL ;
	__CheckRC( sts, *msg, "VS_GetChanObjWithMalloc", wrapup ) ;

	__DBGpr_int( "Number of curve components", nbCmps ) ;

	if( nbCmps != nbOldMapping ) vs$failure() ;

	/*
	 * Reverse the parametrization.
	 */
	sts = om$send( msg	= message GRcompcurve.GRrevparm( msg,
								 md_env ),
		       mode	= OM_e_wrt_message,
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "GRcompcurve.GRrevparm", wrapup ) ;

	/*
	 * Update mapping according to the new index of the components on
	 * the channel.
	 */
	if( !( newMapping = _MALLOC( nbOldMapping, int ) ) ) vs$mem_fail() ;

	for( i=0; i<nbCmps; i++ ) {

		__DBGpr_obj( "Curve component", cmpId[i] ) ;

		sts = om$get_index( objid_c	 = my_id,
				    p_chanselect = &toCmps,
				    objid	 = cmpId[i].objid,
				    osnum2	 = cmpId[i].osnum,
				    indexaddr	 = (OMuint *) &cmpIndex ) ;

		if( !( sts & 1 ) ) *msg = MSFAIL ;
		__CheckRC( sts, *msg, "om$get_index", wrapup ) ;

		newMapping[cmpIndex] = oldMapping[i] ;

		__DBGpr_int( "Index on channel", cmpIndex ) ;
		__DBGpr_int( "Mapping attached", newMapping[cmpIndex] ) ;
	}

	/*
	 * Set new mapping.
	 */
	sts = om$send( msg	= message VScompcurve.VSinitMapping(
								   msg,
								   newMapping ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VScompcurve.VSinitMapping", wrapup ) ;

	wrapup :
		_FREE( oldMapping ) ;
		_FREE( newMapping ) ;
		_FREE( cmpId ) ;

	return sts ;
	End

} /* GRrevparm */
/*----------------------------------------------------------------------------*/

end implementation VScompcurve ;
