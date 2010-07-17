/*
	I/STRUCT
*/
class implementation VSsrcBeam ;

#include <string.h>
/*
 * Includes of function prototypes.
 */
#include "vsgetinpbynm.h"
/*----------------------------------------------------------------------------*/
method VDget_trans_table_entries( long		*msg ;
				  struct GRid	*main_root ;
				  char		*cmd_name ) {

	struct GRid	moi ;
	struct GRmd_env	env ;

	moi.objid = my_id ;
	moi.osnum = OM_Gw_current_OS ;

	/*
	 * Command name is 'beam'.
	 */
	strcpy( cmd_name, "beam" ) ;

	/*
	 * Main root is the surface support. So, get it.
	 */
	return VSgetInputByName( msg, &moi, VS_K_bmSuppSurf, main_root, &env ) ;

} /* method VDget_trans_table_entries */
/*----------------------------------------------------------------------------*/

end implementation VSsrcBeam ;
