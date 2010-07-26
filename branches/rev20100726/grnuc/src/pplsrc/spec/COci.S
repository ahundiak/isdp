class specification COci (1:0) of COroot;

#include "ci.h"

instance COci {

	IGRint		action;		/* Action to be performed	*/
	OM_S_OBJID	ci_objid;	/* Objid of the ci constructed	*/

	IGRboolean	dyn_save ;	/* Saves the dynamics flag	*/
	IGRint		dsp_save ;	/* Saves the display flag	*/
	IGRshort	msg_save ;	/* Saves the message flag	*/
} ;

  override init, wakeup, super_cmd.sleep, execute, delete ;

end specification COci;
