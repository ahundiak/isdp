/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRpost_update - routes the post_update message to the reference
		file
Synopsis

	GRpost_update(msg,named_object_name,gragad_id)

	IGRlong *msg		Completion code
	IGRchar	*named_object_name the name of the object in the named
				object directory
	struct GRid *gragad_id	the graphic gadget for display

Description

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	11/17/87	Design date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "refpriv.h"
#include "exmacros.h"

from Super_rfmgr import Super_passon;
from IGEwinsup import post_update;

method GRpost_update(IGRlong *msg; IGRchar *named_object_name; 
	struct GRid *gragad_id)
{

    IGRlong	OMmsg,
		msg1;

    GRspacenum  osnum;

    GRobjid	objid;
    GRobjid	named_object;

    struct  pass_args_struct
    {
	IGRlong		*msg;
 	IGRchar		*named_object_name;
 	struct  GRid	*gragad_id;
    } pass_args;
	

    OM_S_MESSAGE  pass_msg;

    *msg = MSSUCC;		/* initialize return values		*/
    OMmsg = OM_S_SUCCESS;


    Get_module_info(&msg1,me->osname,&osnum,&objid);

    if ( 1 & msg1)
    {
	OMmsg = ex$get_objid_from_NOD(NODname = "IGENOD",
		objname = named_object_name,
		pobjid = &named_object,
		modid = objid,
		mod_osnum = osnum);

	if ( 1 & OMmsg)
	{
		/* Send the post_update message to the desired
		 * named object.
		 */
	
	    OMmsg = om$send(msg = message IGEwinsup.post_update
			(msg,gragad_id),
		    targetid = named_object,
		    targetos = osnum);
	}
	else	
	{
		/* In the event that the desired named object does not
		 * exist in the reference file, the message must
		 * be sent to the Reference file super in the reference
		 * file to check for possible nested files.
		 */
		
	    OMmsg = ex$get_objid_from_NOD(NODname = "IGENOD",
			objname = "Ref Mgr",
			pobjid = &named_object,
			modid = objid,
			mod_osnum = osnum);
	
	    if ( 1 & OMmsg)
	    {
                OMmsg = om$make_message(
		    classname = "GRreffile",
                    methodname = "GRpost_update",
                    size = sizeof( struct pass_args_struct),
                    p_arglist = &pass_args,
                    p_msg = &pass_msg);
		    
		pass_args.msg = msg;
		pass_args.named_object_name = named_object_name;
		pass_args.gragad_id = gragad_id;

		OMmsg = om$send(msg=message Super_rfmgr.Super_passon
				(msg,&pass_msg),
			targetid = named_object,
			targetos = osnum);

	    }		
	    else	 	/* reference manager does not exist	*/
	    {
		OMmsg = OM_S_SUCCESS;
	    }
	}
    }
    else
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
    }

    return(OMmsg);
}

end  implementation GRreffile;
