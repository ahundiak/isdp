/*
	I/VDS	Copy
*/
class implementation ACmacro_defn ;

#include <limits.h>
#include <unistd.h>
#include "acdef.h"
#include "acmacros.h"
#include "COmdef.h"
#include "EMSmsgdef.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes
 */
#include "COm_option.h"
#include "v_getmacinfo.h"

#ifdef X11
#define NAME_MAX 14
#endif

/*----------------------------------------------------------------------------*/
long VD_getMacroInformation(	msg,
				mcDfNm,
				mcDefId,
				mcLibNm,
				nbInputs,
				inputInfo,
				nbOutputs,
				outputInfo,
				optObj )

long			*msg ;
const char		*mcDfNm ;
const struct GRid	*mcDefId ;
char			mcLibNm[1+NAME_MAX] ;
int			*nbInputs,
			*nbOutputs ;
struct stemp		**inputInfo ;
struct myfeet		**outputInfo ;
struct GRid		*optObj ; {

	/*
	 * Gathers information about a macro definition given its name.
	 */
	long		sts ;
	struct GRid	mcDfId ;

	*msg = MSFAIL ;

	if( !mcDefId ) {
		sts = ac$find_macro_defn( action	  = ACfind_no_load,
					  macro_name	  = mcDfNm,
					  p_macro_defn_id = &mcDfId ) ;
		/*
		 * If error macro not found.
		 */
		if( !( sts & 1 ) ) {
			*msg = EMS_W_NotFound ;
			goto wrapup ;
		}
	} else {
		mcDfId = *mcDefId ;
	}

	if( mcLibNm ) {
		sts = ac$lib_name(	osnum		= mcDfId.osnum,
					name_size	= 1+NAME_MAX,
					name		= mcLibNm ) ;
		__CheckRC( sts, 1, "ac$lib_name", wrapup ) ;
	}

	if( optObj ) {
		 COm_get_option_grid( &mcDfId, optObj, NULL ) ;
	}

	if( nbInputs && inputInfo ) {
		sts = om$send(	msg	= message ACcpx_defn.ACgive_temp_desc(
							nbInputs, inputInfo ),
				senderid= mcDfId.objid,
				targetid= mcDfId.objid,
				targetos= mcDfId.osnum ) ;
		__CheckRC( sts, 1, "ACcpx_defn.ACgive_temp_desc", wrapup ) ;
	}

	if( nbOutputs && outputInfo ) {
		sts = om$send(	msg	= message ACcpx_defn.ACgive_feet_desc(
							nbOutputs, outputInfo ),
				senderid= mcDfId.objid,
				targetid= mcDfId.objid,
				targetos= mcDfId.osnum ) ;
		__CheckRC( sts, 1, "ACcpx_defn.ACgive_feet_desc", wrapup ) ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VD_getMacroInformation */
/*----------------------------------------------------------------------------*/

end implementation ACmacro_defn ;

