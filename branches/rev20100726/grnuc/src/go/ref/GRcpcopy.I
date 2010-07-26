/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRcopy -  copies a clipping polygon

Synopsis
     	GRcopy(msg,obj_dsenv,new_dsenv,newobjid)

	IGRlong *msg		completion code
	struct GRmd_env *obj_dsenv	 
				struct describing object's present
				  environment
     	struct GRmd_env *new_dsenv
				struct describing copy's environment
     	GRobjid *newobjid	objid of the copied object

Description

	The copy method copies the clipping polygon. If the send did
	not originate from the reference file attachment object, it is sent
	a GRcopy message.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	04/05/87	Design date.

\*/

class implementation GRclippoly;

#include "grimport.h"
#include "refpriv.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "OMmacros.h"

method GRcopy(IGRlong *msg; struct GRmd_env *obj_dsenv;
	struct GRmd_env *new_dsenv; GRobjid *newobjid)

{
    IGRboolean  connect_channel;	/* connect to attachment flag	*/

    IGRshort	properties;

    IGRlong 	OMmsg;			/* method return status		*/
    

    GRobjid	poly_objid,		/* new clipping polygon		*/
		saved_poly_objid,	/* save before calling GRcopy	*/
		new_attachment;		/* new attachment object	*/

    struct GRmd_env clip_from_env,
		clip_to_env,
		new_local_env;

    OM_S_CHANSELECT to_reffile;		/* channels for connections	*/



    *msg = MSSUCC;			/* initialize to success	*/
    OMmsg = OM_S_SUCCESS;

    *newobjid = 0;
    new_attachment = 0;
    poly_objid = 0;
    new_local_env = *new_dsenv;
    new_local_env.md_id.objid = NULL_OBJID;

    /* a copy operation applies to both the clipping polygon object and
     * the reference file attachment object.  Check to see if the message
     * originated from the reference file attachment object.
     */

    to_reffile.type = OM_e_addr;
    to_reffile.u_sel.addr = &me->to_attachment;

    OMmsg = om$is_objid_on_channel(
	objid_c = my_id,
	p_chanselect = &to_reffile,
	objid = sender_id);

    if (OMmsg == OM_W_NOTONCHAN)
    {
	/* the sender is not the reference file object.  Therefore
	 * send the message to the reference file object also.
	 * Rtree manipulations are not done.
	 */

	OMmsg = om$send(msg = message GRgraphics.GRcopy
     		(msg,obj_dsenv,&new_local_env,&new_attachment),
	    p_chanselect = &to_reffile);

	connect_channel	= TRUE;
    }
    else
    {
	connect_channel = FALSE;
    }

    if (1 & OMmsg & *msg)
    {					/* don't put copy in R-tree	*/
	/* copy the clipping polygon curve definition.  It is not put
	 * in the R-tree so send down NULL_OBJID for the module objid
	 */

	MAidmx(msg,clip_from_env.md_env.matrix);
	clip_from_env.md_env.matrix_type = MAIDMX;
	clip_from_env.md_id.osnum = obj_dsenv->md_id.osnum;
	clip_from_env.md_id.objid = NULL_OBJID;

	clip_to_env = clip_from_env;	
	clip_to_env.md_id.osnum = new_dsenv->md_id.osnum;

					/* copy the clip polygon	*/
	OMmsg = om$send(
	    msg = message GRgraphics.GRcopy
		(msg,&clip_from_env,&clip_to_env,&poly_objid),
	    targetid = me->cv_objid);
					
        if (1 & OMmsg & *msg)
        {
	    /* reset the objid of the clippoly so the construct 
	     * and copy macro called by the GRcopy method can
	     * have the correct objid of the clipping polygon
	     */

	    saved_poly_objid = me->cv_objid;
	    me->cv_objid = poly_objid;
	    properties = me->properties;
	    me->properties = me->properties & ~GR_RIGID_RELATIONSHIP;

	    OMmsg = om$construct_and_copy
		(objid = my_id,
		 osnum = new_dsenv->md_id.osnum,
		 p_objid = newobjid);
	
	    me->properties = properties;
	    me->cv_objid = saved_poly_objid;

	    if ( 1 & OMmsg & *msg)	/* everything succeeded		*/
	    {
		/* If the call did not originate from the attachment
		 * object, the new clipping polygon objid must be 
		 * connected to the reference file attachment object.
		 */
		
	        if (connect_channel)
	        {	
		    OMmsg = GRpolyconnect
		    	(msg,&new_dsenv->md_id.osnum,newobjid,
			 &new_attachment);

		    /* transform the clipping polygon and the reference
		     * file attachment object.
		     */

		    if ( 1 & OMmsg & *msg)
		    {
		        OMmsg = GRxformboth(msg,obj_dsenv,&new_local_env,
				&new_attachment,newobjid);
		    }

		}
	    }
   	}	    
    }
    if (! (1 & OMmsg & *msg))		/* failure of method		*/
    {
	if (new_attachment)		/* delete copy of attachment	*/
	{
	    om$send (msg = message GRgraphics.GRdelete(msg,&new_local_env),
		    targetid = new_attachment,
		    targetos = new_dsenv->md_id.osnum);
	}
	if (*newobjid)
	{
	    om$send (msg = message GRgraphics.GRdelete(msg,&new_local_env),
		    targetid = *newobjid,
		    targetos = new_dsenv->md_id.osnum);
	}
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
    }
    else 
    {
/*	gr$add_to_active_owner(
		msg = msg,
		mod_env = new_dsenv,
		objid = *newobjid);
*/
    	if (! (IF_NULL_OBJID(new_dsenv->md_id.objid)))
	{
	    OMmsg = GRrfaddrtree(msg,new_dsenv,&poly_objid,newobjid,NULL);
    	}
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_COPIED);

    return(OMmsg);

}
end implementation GRclippoly;
