/*
	I/STRUCT
*/
class implementation VSfmbeamCmd ;

#include <FI.h>

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VSfmbeamCmd_window_event( form_label, event, form )

int	form_label,
	event ;
char	*form ; {
	

	OM_S_OBJID	cmdId ;
	OMuword		cmdOs ;
	long		msg ;

	FIf_get_cmd_oid_os( form, &cmdId, &cmdOs ) ;

	if( event == FI_REFRESH )
		om$send(msg	= message VSfmbeamCmd.draw_section_on_form( 
									&msg ),
			senderid= cmdId,
			targetid= cmdId,
			targetos= cmdOs ) ;
	return FI_SUCCESS ;

} /* VSfmbeamCmd_window_event */
/*----------------------------------------------------------------------------*/

end implementation VSfmbeamCmd ;
