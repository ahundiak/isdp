/*
	I/STRUCT
*/
class implementation VSsdofplCmd ;

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "comiscmac.h"
#include "exdef.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vscmddef.h"
#include "vsplatedef.h"
/*
 * Includes of function prototypes.
 */
#include "vsioproto.h"
#include "vsvecmxproto.h"

from NDmacro	import ACreturn_foot ;
/*----------------------------------------------------------------------------*/
method init_cmd( int *sts ) {

	/*
	 * Init argument WantSide to have "plate:offset".
	 */
	me->WantSide	   = VS_K_plTopSfPath ;
	me->SideObj._objid = NULL_OBJID ;

	me->suppressHilite = TRUE ;

	return OM_S_SUCCESS ;

} /* method init_cmd */
/*----------------------------------------------------------------------------*/
method store_plate( long *msg ) {

	long			sts ;
	struct GRlc_info	*toStore = me->event1.located_object ;

	sts = om$send( msg	= message VSlocateCmd.addLocObj(
							&toStore->located_obj,
							&toStore->module_info,
							0 ),
		       targetid = my_id ) ;

	*msg = sts & 1 ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;

	return OM_S_SUCCESS ;

} /* method store_plate */
/*----------------------------------------------------------------------------*/
method hilight_side( int * sts ) {

	long	msg ;

	/*
	 * Hilight side selected.
	 */
	vs$bulk_display( count	= 1,
			 dpmode = GRhdo,
			 objenvs= &me->SideObj ) ;

	/*
	 * Display in status field the type of side.
	 */
	ex$message( field		= ERROR_FIELD,
		    justification	= CENTER_JUS,
		    in_buff		= me->WantSide ) ;

	/*
	 * Display normal.
	 */
	VSdisplaySurfaceNormal( &msg,
				&me->SideObj,
				TRUE,
				&me->ActiveDisplay,
				GRhd ) ;

	*sts = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method hilight_side */
/*----------------------------------------------------------------------------*/
method unhilight_side( int *sts ) {

	/*
	 * Unhiligh side and normal.
	 */
	if( !IF_NULL_OBJID( me->SideObj._objid ) ) {

		long	msg ;

		vs$bulk_display( count	= 1,
				 dpmode = GRheo,
				 objenvs= &me->SideObj ) ;

		VSdisplaySurfaceNormal( &msg,
					&me->SideObj,
					TRUE,
					&me->ActiveDisplay,
					GRhe ) ;
	}

	*sts = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method unhilight_side */
/*----------------------------------------------------------------------------*/
method swap_side( long *msg ) {

	long			sts ;
	struct GRobj_env	plate ;

	/*
	 * Retrieve plate.
	 */
	sts = om$send( msg   = message VSlocateCmd.getLocObjAtIndex(
							msg, 0, &plate ),
		       targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjAtIndex", wrapup ) ;

	/*
	 * Get the opposite side.
	 */
	me->WantSide = !strcmp( me->WantSide, VS_K_plTopSfPath )
					? VS_K_plBotSfPath
					: VS_K_plTopSfPath ;

	sts = om$send( msg	= message NDmacro.ACreturn_foot(
						msg,
						me->WantSide,
						&me->SideObj.obj_id,
						&me->SideObj._matrix_type,
						me->SideObj._matrix ),
		       targetid = plate._objid,
		       targetos = plate._osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	VSmulmx( me->SideObj._matrix, plate._matrix,
		 me->SideObj._matrix, &me->SideObj._matrix_type ) ;

	me->SideObj.mod_env.md_id = plate.mod_env.md_id ;

	wrapup :
		*msg = ( sts & *msg & 1 ) ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;

	return OM_S_SUCCESS ;

} /* method swap_side */
/*----------------------------------------------------------------------------*/
method put_side_on_queue( long *msg ) {

	long			size ;
	int			resp ;
	struct GRevent		event ;

	/*
	 * Format event structure.
	 */
	co$build_button( msg	  = msg,
			 objid	  = me->event1.event.button.objid,
			 osnum	  = me->event1.event.button.osnum,
			 button   = &event.event.button ) ;
	if( !( *msg & 1 ) ) { CheckRC( 1, *msg ) ; goto wrapup ; }

	event.num_id = 1 ;

	event.located_object[0].located_obj = me->SideObj.obj_id ;
	event.located_object[0].module_info = me->SideObj.mod_env ;

	/*
	 * Put EX_OBJID event on front of software queue.
	 */
	size = sizeof( struct GRevent ) - sizeof( long ) *2 ;

	resp = EX_OBJID ;

	ex$putque( msg		= msg,
		   byte 	= &size,
		   response	= &resp,
		   buffer	= (char *) &event.event.button ) ;

	wrapup :
		*msg = *msg & 1 ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;

	return OM_S_SUCCESS ;

} /* method put_side_on_queue */
/*----------------------------------------------------------------------------*/

end implementation VSsdofplCmd ;
