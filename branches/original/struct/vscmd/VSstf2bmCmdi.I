/*
	I/STRUCT
*/
class implementation VSstf2bmCmd ;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vscmddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsioproto.h"
/*----------------------------------------------------------------------------*/
method operation() {

	long			msg,
				sts ;
	struct	GRobj_env	*stfList = NULL ;
	int			i,
				max ;
	char			info[MS_MAX_MSG_LENGTH],
				type[MS_MAX_MSG_LENGTH] ;

	max = me->number_of_stiffeners ;
	/*
	 * Get located stiffener(s).
	 */
	if( !( stfList = _MALLOC( max, struct GRobj_env ) ) ) {
		msg = EMS_E_NoDynamicMemory ; sts = OM_W_ABORT ; goto wrapup ;
	}

	sts = om$send( msg	= message VSlocateCmd.getLocObjs(
						       &msg, max, stfList ),
		       targetid = my_id ) ;
	__CheckRC( sts, msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	for( i = 0 ; i < max ; i++ ) {
		if( max > 1 ) {

			strcpy( type, VSmsgkey2string( VS_gI_Stiffener ) ) ;
			sprintf( info, "%s # %d -> %s",
				 type,
				 i + 1,
				 VSmsgkey2string( VS_gI_Beam ) ) ;
				
			ex$message(	in_buff 	= info,
					field		= ERROR_FIELD,
					justification	= CENTER_JUS ) ;
		}
		sts = VSmoveStiffenerToBeam( &msg, stfList + i ) ;
		__CheckRC( sts, msg, "VSmoveStiffenerToBeam", wrapup ) ;
	}

	wrapup :
		_FREE( stfList ) ;
		me->ret = sts & msg & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

		return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/

end implementation VSstf2bmCmd ;
