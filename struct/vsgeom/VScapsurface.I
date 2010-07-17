/*
	I/STRUCT
*/
class implementation EMSsfsolid ;

#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

extern OMuword		OPP_EMSsfsolid_class_id ;
/*----------------------------------------------------------------------------*/
long VScap_surface( msg, cst, surfId, solidId )

/*
 * This function is interfaced by macro vs$cap_surface.
 */
long			*msg ;
struct GRvg_construct	*cst ;
struct GRid		*surfId,
			*solidId ; {

	long	sts ;	/* OM return code	*/

	solidId->osnum = surfId->osnum ;
	sts = om$construct(	classid	= OPP_EMSsfsolid_class_id,
				osnum	= solidId->osnum,
				p_objid	= &solidId->objid ) ;
	if( sts & 1 ) {
		sts = om$send(	msg	= message EMSsfsolid.EMcap_thyself(
						msg, cst, &surfId->objid ),
			senderid= solidId->objid,
			targetid= solidId->objid,
			targetos= solidId->osnum ) ;

		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	count	= 1,
					grids	= solidId,
					theEnv	= cst->env_info ) ;
		}

	} else {
		*msg = EMS_E_OMerror ;
	}

	return sts ;
	
} /* VScap_surface */
/*----------------------------------------------------------------------------*/

end implementation EMSsfsolid ;
