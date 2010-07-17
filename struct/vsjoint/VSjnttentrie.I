/*
	I/STRUCT
*/
class implementation VSjoint ;

#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VDget_trans_table_entries( long		*msg ;
				  struct GRid	*main_root ;
				  char		*cmd_name ) {

	long			sts ;
	struct GRobj_env	feature0,
				feature1 ;

	/*
	 * Main root is the first joined feature. So, get it.
	 */
	sts = om$send( msg	= message VSjoint.VSgetJoinedFeatures(msg,
								      &feature0,
								      &feature1,
								      NULL ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VSjoint.VSgetJoinedFeatures", wrapup ) ;

	sts = om$send( msg	= message VSjoint.ACreturn_foot( msg,
								 "",
								 main_root,
								 NULL,
								 NULL ),
		       targetid = feature0._objid,
		       targetos = feature0._osnum ) ;

	__CheckRC( sts, *msg, "VSjoint.ACreturn_foot", wrapup ) ;

	/*
	 * Command name is 'joint'.
	 */
	strcpy( cmd_name, "joint" ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) main_root->objid = NULL_OBJID ;
		return sts ;

} /* VDget_trans_table_entries */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;
