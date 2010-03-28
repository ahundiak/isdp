/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
     GRownerrem -  this function removes an object to the R-tree

Synopsis
	GRownerrem(msg,env,objid,osnum,range)

	IGRlong 	*msg;		the completion code
	struct 	GRmd_env *env;		the objects environment information
	GRobjid		*objid;		the object's id
	GRspacenum	*osnum;		the object's space number
	GRrange		*range;		the range of the object

Description
	This function sends a GRownremwrng message to all owners.
	If all owners fail to remove the object to the R-tree, it
	is removed by this function.
	
Diagnostics
	The return codes:
		MSSUCC - successful completion
		MSFAIL - failure, error occured
Notes
	None.

History
	MAS	09/21/87	Design Date.
\*/

class implementation GRconnector;

#include "grimport.h"
#include    "msdef.h"
#include    "OMmacros.h"

from GRmodule import GRmdremove;
from GRcmpowner import GRownremwrng;

GRownerrem(msg,env,objid,osnum,range)

IGRlong 	*msg;
struct 	GRmd_env *env;
GRobjid		*objid;
GRspacenum	*osnum;
GRrange		*range;
{
    IGRlong		OMmsg;

    OMuint		count;
    IGRint		cnt,
			i;

    OM_S_CHANSELECT	chandef;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    if (IF_NULL_OBJID(env->md_id.objid))
    {
	goto wrapup;
    }
				/* check for ownership			*/
    OMmsg = om$make_chanselect(channame = "GRconnector.to_owners",
	p_chanselect = &chandef);

    if( 1 & OMmsg)
    {
	OMmsg = om$get_channel_count(osnum = *osnum,
	    objid = *objid,
            p_chanselect = &chandef,
            count = &count);

	if (1 & OMmsg)
	{
	    cnt = 0;
	    for (i = 0; i < (IGRint)count; ++i)
	    {
                OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRcmpowner.GRownremwrng(
			msg,env,objid,*range),
                    senderid = *objid,
		    p_chanselect = &chandef,
		    to = i,
		    from = i);

		if ( OMmsg == OM_I_STOP_SENDING )
		{
		    i = count;		/* reset to exit loop		*/
		    cnt = 0;
		    OMmsg = OM_S_SUCCESS;
		}
		else if (! (1 & OMmsg))
		{
		    ++cnt;		/* increment failure count	*/
	  	    OMmsg = OM_S_SUCCESS;
	        }
	    } 

	    if (cnt == count)
	    {
		/* either the object has no owners or all owners failed
		 * to handle the R-tree manipulation
		 */

		OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRmodule.GRmdremove(msg,(double *)range,objid),
                    senderid = *objid,
                    targetid = env->md_id.objid,
                    targetos = env->md_id.osnum);
	    }	    
	}
	else
	{
	    *msg = MSFAIL;
	}	
    }
    else
    {
	*msg = MSFAIL;
    }

wrapup:

    return (OMmsg);
}

end implementation GRconnector;
