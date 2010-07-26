/* #######################    APOGEE COMPILED   ######################## */

/*\
Name
     GRget_Super_info -  This file gets the object id and object space
		number for the Super_rfmgr super. 
		If the Super does not exist, it is not created.

Synopsis
	GRget_Super_info(msg,osname,Super_id)

	IGRlong		*msg;		 completion code		
	IGRchar		*osname;	 object space name
	struct GRid 	*Super_id;	 objid, osnum for your super	

Description

	This function returns the object id and object 
	space number of the Reference file Super from the
	named object directory. 
	If the Super does not exist in the named object
	directory it is not constructed.

Diagnostics
	The return codes:

	MSSUCC - successful completion
	MSFAIL - error

Notes
	None.

History
	MAS	04/03/87	Design Date.
\*/

class implementation GRreffile;

#include "grimport.h"
#include "exmacros.h"
#include "msdef.h"
#include "refpriv.h"

IGRlong  GRget_Super_info(msg,osname,Super_id)

IGRlong *msg; 
IGRchar *osname;
struct GRid *Super_id;

{
    GRobjid mod_id;

    IGRlong OMmsg;			/* local return codes		*/
					
    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;

    Get_module_info(msg,osname,&Super_id->osnum,&mod_id);

    if (1 & *msg)
    {				/* Get Super from Named Object
				   directory			*/
        OMmsg = ex$get_objid_from_NOD(NODname = "IGENOD",
		objname = "Ref Mgr",
		pobjid = &Super_id->objid,
		modid = mod_id,
		mod_osnum = Super_id->osnum);

	if (! (1 & OMmsg))
    	{
	    *msg = MSFAIL;
    	}
    }
    else
    {
	OMmsg = OM_E_ABORT;
    }

    return( OMmsg );
}
end implementation GRreffile;

