/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRdelete -  deletes the graphics object from the 
		object space.  

Synopsis
    	GRdelete(msg,md_env)
	
	IGRlong *msg		completion code
	struct GRmd_env *md_env	structure containing environment
				information

Description

	This method deletes a graphic object from the design
	space.  Entries in the R-tree will also be removed.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS	10/10/86	Design date.

\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)
{
    IGRlong 		OMmsg;		/* return status for method	*/

    struct GRmd_env	local_env;

    OM_S_CHANSELECT	to_reffile;		

    GRobjid		curve;

/*
 *  initialize return variables
 */

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    to_reffile.type = OM_e_addr;
    to_reffile.u_sel.addr = &me->to_attachment;

    OMmsg = om$is_objid_on_channel(
	objid_c = my_id,
	p_chanselect = &to_reffile,
	objid = sender_id);

    if (OMmsg == OM_W_NOTONCHAN)
    {
	/* the sender is not the reference file object.  Therefore
	 * send the message to the reference file object also
	 */

	OMmsg = om$send(msg = message GRgraphics.GRdelete(msg,md_env),
	    p_chanselect = &to_reffile);

    }
    if ( 1 & OMmsg & *msg)
    {
	curve = me->cv_objid;

        /* Delete the prism information
	 */

        OMmsg = om$send(
	        mode = OM_e_wrt_message,
	        msg = message GRgraphics.GRdelete(msg,md_env),
	        targetid = my_id);

	if ( 1 & *msg & OMmsg)
	{

	    /* the curve defining the face of the clipping polygon
	     * must be deleted.  Since it is not in the R-tree, reset
	     * the module id to be NULL_OBJID.
	     */

	    local_env = *md_env;
	    local_env.md_id.objid = NULL_OBJID;

            OMmsg = om$send(
	    	msg = message GRgraphics.GRdelete(msg,&local_env),
	    	targetid = curve);

	}
    }


    if (1 & OMmsg & *msg)
    {
					/* remove from cache		*/
    	GRabsg_del_by_objid(&my_id,&md_env->md_id.osnum);
    }

#ifdef DEBUG
    printf("In GRcpdelete\n");
    printf("OMmsg = %X \n",OMmsg);
#endif

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_DELETED);

    return(OMmsg);
}

end implementation GRclippoly;
