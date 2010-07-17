/*
	I/STRUCT
*/
class implementation VSsrcPlate ;

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

	/*
	 * Command name is 'plate'.
	 */
	strcpy( cmd_name, "plate" ) ;

	moi.objid = my_id ;
	moi.osnum = OM_Gw_current_OS ;
	return VSgetInputByName( msg, &moi, VS_K_plSuppSurf, main_root, &env ) ;

} /* method VDget_trans_table_entries */
/*----------------------------------------------------------------------------*/

end implementation VSsrcPlate ;
