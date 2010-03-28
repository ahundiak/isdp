/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
     GRmakeSuper -  This file gets the object id and object space
		number for the requested super. 
		If the Super does not exist, it is created.

Synopsis
	IGRlong GRmakeSuper(msg, module_info, Super_name, 
		Super_classname, Super_id)

	IGRlong		*msg;		 completion code		
	struct GRid 	*module_info;	 module information		
	IGRchar		*Super_name;	 name for your Super		
	IGRchar		*Super_classname;  classname for your Super	
	struct GRid 	*Super_id;	 objid, osnum for your super	

Description

	This function returns the object id and object 
	space number of the Requested Super from the
	named object directory. 
	If the Super does not exist in the named object
	directory it will be constructed for you using
	exec provided macros.

Diagnostics
	The return codes:

	MSSUCC - successful completion
	MSFAIL - error

Notes
	None.

History
	MAS	04/03/87	Design Date.
\*/


class implementation GRgraphics;

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "exmacros.h"
#include "msdef.h"

from  OMNamObjDir import add_name;

IGRlong GRmakeSuper(msg, module_info, Super_name, 
		Super_classname, Super_id)

IGRlong		*msg;		/* completion code		*/
struct GRid 	*module_info;	/* module information		*/
IGRchar		*Super_name;	/* name for your Super		*/
IGRchar		*Super_classname; /* classname for your Super	*/
struct GRid 	*Super_id;	/* objid, osnum for your super	*/
{
    IGRlong	OMmsg;
    GRobjid	NOD_object;

    OMmsg = OM_S_SUCCESS;	/* initialize return values	*/
    *msg = MSSUCC;
				/* Get Super from Named Object
				   directory			*/
    OMmsg = ex$get_objid_from_NOD(NODname = "IGENOD",
		objname = Super_name,
		pobjid = &Super_id->objid,
		modid = module_info->objid,
		mod_osnum = module_info->osnum);
				/* Named Object not yet created	*/
    if (! (1 & OMmsg ))
    {				/* reset OMmsg			*/
	OMmsg = OM_S_SUCCESS;
				/* construct Super		*/
	OMmsg = ex$attach_super(super_class = Super_classname,
			super_id = &Super_id->objid,
			modid = module_info->objid,
			mod_osnum = module_info->osnum);
	if (1 & OMmsg)
	{
	    OMmsg = ex$get_NOD(NODname = "IGENOD",
			pobjid = &NOD_object,
			modid = module_info->objid,
			mod_osnum = module_info->osnum,
			create = 1);

	    if (1 & OMmsg)
	    {
		OMmsg = om$send(mode = OM_e_wrt_object,
                                msg = message OMNamObjDir.add_name
					(Super_name,Super_id->objid),
                                senderid = Super_id->objid,
                                targetid = NOD_object,
				targetos = module_info->osnum);
	    }
   	}

    }
				/* space number same as module	*/
    Super_id->osnum = module_info->osnum;

    if (! (1 & OMmsg))
    {
	*msg = MSFAIL;
    }

    return( OMmsg );
}
end implementation GRgraphics;
