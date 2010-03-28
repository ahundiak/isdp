/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
     GRgetctxsuper -  This file gets the object id and object space
		Reference File manager of the master file.

		If the Super does not exist, it is an error.

Synopsis
	IGRlong GRgetctxsuper(msg,Super_id)

	IGRlong		*msg;		 completion code		
	struct GRid 	*Super_id;	 objid, osnum for your super	

Description

	This function returns the object id and object 
	space number of the Reference file Super of the
	master file.  This would be the super for the context
	objects for a particular design session.

Diagnostics
	The return codes:

	MSSUCC - successful completion
	MSFAIL - error

Notes
	None.

History
	MAS	06/01/87	Design Date.
\*/

class implementation GRgraphics;

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "exmacros.h"
#include "msdef.h"

IGRlong GRgetctxsuper(msg,Super_id)

IGRlong		*msg;		/* completion code		*/
struct GRid 	*Super_id;	/* objid, osnum for your super	*/
{
    IGRlong	OMmsg;

    extern OM_S_OBJID EX_active_module;
    extern OMuword EX_active_OS_num;
    
    OMmsg = OM_S_SUCCESS;	/* initialize return values	*/
    *msg = MSSUCC;
				/* Get Super from Named Object
				   directory			*/
    OMmsg = ex$get_objid_from_NOD(NODname = "IGENOD",
		objname = "Ref Mgr",
		pobjid = &Super_id->objid,
		modid = EX_active_module,
		mod_osnum = EX_active_OS_num);

    if (1 & OMmsg)
    {				/* space number same as module	*/
        Super_id->osnum = EX_active_OS_num;
    }
    else
    {
	*msg = MSFAIL;
    }

    return( OMmsg );
}
end implementation GRgraphics;

