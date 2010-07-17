/*
	I/STRUCT
*/
class implementation VSvrsnStamp ;

#include <stdio.h>
#include "OMversion.h"
#include "msdef.h"		/* For MS...		*/
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "vsdbgmacros.h"

extern INGR_S_PRODUCT_DEF	STRUCT_appl_version_id ;
/*----------------------------------------------------------------------------*/
int VSgetVersionStampId( osnum, stamp_id )

OMuword		osnum ;
OM_S_OBJID	*stamp_id ; {

/*
 * This function interfaced by macro vs$getVersionStampId.
 */
	OM_S_OBJID	mod_id ;
	int		rc ;

	if( ex$get_modid(	mod_osnum	= osnum,
				mod_id		= &mod_id ) & 1 ) {

		rc = ex$get_super(	mod_id		= mod_id,
					mod_osnum	= osnum,
					super_name	= "STRUCTversion",
					super_class	= "VSvrsnStamp",
					create		= TRUE,
					super_id	= stamp_id ) ;
		if( rc & 1 ) {
			rc = TRUE ;
		} else {
			*stamp_id = NULL_OBJID ;
			rc = FALSE ;
		}
	} else {
		*stamp_id = NULL_OBJID ;
		rc = FALSE ;
	}
		
	return rc ;

} /* VSgetVersionStampId */
/*----------------------------------------------------------------------------*/
void VSgetCurrentVersion( p_rr, p_uu, p_ss, p_tt )

int	*p_rr,
	*p_uu,
	*p_ss,
	*p_tt ; {

	char	*versionStamp ;

	versionStamp = STRUCT_appl_version_id.curr_version ;

	/*
	 * Version stamp has the following format:
	 * "I/STRUCT rr.uu.ss.tt dd-Mon-yy"
	 */
	sscanf( versionStamp, "%*s %d.%d.%d.%d", p_rr, p_uu, p_ss, p_tt ) ;

} /* VSgetCurrentVersion */
/*----------------------------------------------------------------------------*/

end implementation VSvrsnStamp ;

