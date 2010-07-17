/*
	I/STRUCT
*/
class implementation VSorbeamCmd ;

#include <stdlib.h>
#include "griomacros.h"
#include "growner.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "vsdef.h"
#include "vs.h"
#include "vsattr.h"
#include "vscmddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

from VSpart	import	VSshowOrientation ;
/*----------------------------------------------------------------------------*/
method operation( long *sts ) {

	long			msg ;
	int			saveWeight, saveColor ;
	struct GRobj_env	part ;
 	struct  GRevent         event;
        int                     response;
        char                    response_data[EX_RESPONSE_DATA_SIZE];


	saveWeight		= me->ActiveDisplay.weight ;
	me->ActiveDisplay.weight= 2 ;

	saveColor = me->ActiveDisplay.color ;
	*sts =
	ige$get_color_from_name( color = (short *)&me->ActiveDisplay.color, 
				 name = "Highlight" );

	*sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
							&msg, 1, &part ),
				targetid= my_id ) ;
	if( !( *sts & 1 & msg ) ) goto wrapup ;

	*sts = om$send(	msg	= message VSpart.VSshowOrientation(
							&msg,
							&part.mod_env,
							FALSE,
							GRbd,
							&me->ActiveDisplay ),
			targetid= part._objid,
			targetos= part._osnum ) ;

	if( !( *sts & 1 & msg ) ) goto wrapup ;

	if( me->mytype == 1 ) {
		/*
		 * Display orientation only.
		 */
		goto wrapup ;
	}

	while( 1 )
	{
	  *sts = om$send(	msg	= message VSpart.VSshowOrientation(
							&msg,
							&part.mod_env,
							FALSE,
							GRbd,
							&me->ActiveDisplay ),
			targetid= part._objid,
			targetos= part._osnum ) ;

 	   co$getevent (
		  msg           = &msg,
                  event_mask    = ( GRm_DATA | GRm_RJT_MOVEON | GRm_STRING ),
                  prompt        = "Accept to reverse orientation y/n [y]",
                  response      = &response,
                  response_data = &response_data,
                  event         = &event );

	   *sts = om$send(	msg	= message VSpart.VSshowOrientation(
							&msg,
							&part.mod_env,
							FALSE,
							GRbe,
							&me->ActiveDisplay ),
			targetid= part._objid,
			targetos= part._osnum ) ;
	   if( !( *sts & 1 & msg ) ) goto wrapup ;

	   if ( response == CLEAR_STACK || response == TERMINATE ||
		response == TOGGLE_COMMAND || response == EX_POCKET )
	   {
		 *sts = ex$putque( msg         = &msg,
				   pos         = FRONT,
				   response    = &response );
	         goto quit ;		
	   }

	   if ( response == EX_RJT_MOVEON ) goto wrapup;

	   if( response == EX_DATA || response == EX_STRING )
	   {
	     if( response == EX_STRING )
	     {
		if( event.event.keyin[0] != '\0' &&
		    event.event.keyin[0] != 'y' && event.event.keyin[0] != 'Y' )
		  goto wrapup ; 
             }

	     *sts = om$send(	msg	= message VSpartopCmd.operation( &msg ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	     if( !( *sts & 1 & msg ) ) goto wrapup ;

	     *sts = om$send(	msg	= message VSpart.VSshowOrientation(
							&msg,
							&me->cstEnv,
							TRUE,
							GRbd,
							&me->ActiveDisplay ),
			targetid= me->constructedObject.objid,
			targetos= me->constructedObject.osnum ) ;
	     if( !( *sts & 1 & msg ) ) goto wrapup ;

	     break;

	   } /* if( response == EX_DATA || response == EX_STRING ) */

       } /* while(1) loop */

wrapup :
	me->ActiveDisplay.weight = saveWeight ;
	me->ActiveDisplay.color  = saveColor  ;
	me->ret = ( msg & 1 & *sts ) ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
	quit :
	return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/

end implementation VSorbeamCmd ;
