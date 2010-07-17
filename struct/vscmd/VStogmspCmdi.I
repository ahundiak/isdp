/*
	I/STRUCT
*/
class implementation VStogmspCmd ;

#include "gr.h"
#include "vsdef.h"
#include "vs.h"
#include "vsdpb.h"
#include "vsdpbmacros.h"
#include "vscmddef.h"
#include "vsglobalmsg.h"
%safe
#include "VX_FIproto.h"
%endsafe

/*----------------------------------------------------------------------------*/
method toggleMassProperties( long *msg ) {

	int	oldToggle,
		newToggle ;

	vs$get_massp_toggle(	msg	= msg,
				p_toggle= &oldToggle ) ;
	if( *msg & 1 ) {
		newToggle = !oldToggle ;

		vs$put_massp_toggle(	msg	= msg,
					p_toggle= &newToggle ) ;
		if( *msg & 1 ) {
			ex$message(	msgnumb		= newToggle
						  	? VS_gI_CmptEnabled
						  	: VS_gI_CmptDisabld,
					justification	= CENTER_JUS ) ;
		}
	}
	me->ret = *msg & 1 ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
	return OM_S_SUCCESS ;

} /* method toggleMassProperties */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
method warningMessage( long *msg ) {

	int 	msglng;
	char	ErrBuf[100];

	strcpy( ErrBuf,"All Mass Property Evaluations Are Done In \"Exact\" Mode \n \"Approximate\" Mode Is No Longer Supported" ) ;
                /* Error_box( 0, ErrBuf, 2 ) ; */
                msglng = strlen(ErrBuf) ;
 
	FI_message_box (    FI_CURRENT_SCREEN, -1, -1, 	"Warning", FI_BLACK,
				"swiss742b", 25.0, ErrBuf, FI_BLACK, 
				"swiss742b", 18.0, FI_FITTED,  msglng );

	return OM_S_SUCCESS ;

}/* method warningMessage */
/*----------------------------------------------------------------------------*/

end implementation VStogmspCmd ;
