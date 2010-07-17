/*
	I/STRUCT
*/
class implementation VSbeam ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

from VSfrzBeam import VSformatUsingOriginal ;
/*----------------------------------------------------------------------------*/
method VScreateFrozenCopy(	long		*msg ;
				struct GRmd_env	*myEnv,
						*cpyEnv ;
				struct GRid	*copy ) {

	long			sts ;
	struct GRobj_env	moi ;

	copy->objid = NULL_OBJID ;

	/*
	 * First NDcopy yourself: it will copy you and your owned graphics.
	 */
	sts = om$send(	msg	= message NDnode.NDcopy(
						msg, 0, myEnv, cpyEnv, copy ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "NDnode.NDcopy", wrapup ) ;

	/*
	 * Then change class of copy to "VSfrzBeam".
	 */
	sts = om$change_class(  osnum		= copy->osnum,
				objid		= copy->objid,
				classname	= "VSfrzBeam" ) ;
	if( !( sts & 1 ) ) { vs$om_error( sts = sts ) ; }

	/*
	 * Now tell frozen copy to format itself, possibly using your data.
	 */
	moi._objid	= my_id ;
	moi._osnum	= OM_Gw_current_OS ;
	moi.mod_env	= *myEnv ;

	sts = om$send(	msg	= message VSfrzBeam.VSformatUsingOriginal(
							msg, cpyEnv, &moi ),
			targetid= copy->objid,
			targetos= copy->osnum ) ;
	__CheckRC( sts, *msg, "VSfrzBeam.VSformatUsingOriginal", wrapup ) ;

	*msg 	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	grids	= copy,
					theEnv	= cpyEnv ) ;
		}
		return sts ;

} /* method VScreateFrozenCopy */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;

