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
	space.  For a reference file object, additional objects
	are involved.  The header object will be deleted, the
	clipping polygon and the context object.

	Entries in the R-tree will also be removed.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS	10/10/86	Design date.
	jhw	11/6/89		Added check for "temp active" before
				closing file.
        dhm     07/06/92        ANSI conversion.
\*/

	
class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "referr.h"
#include "exdef.h"
#include "refpriv.h"

#include "actparam.h"

from GRmodule import GRmdremove;
from GRcontext import GRdeletectx;
from GRcmpowner import GRcomponent_disconnecting;

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)
{
    IGRboolean		world;		/* flag for GRgetrang		*/

    IGRshort		context_matrix_type;

    IGRlong 		OMmsg;		/* return status for method	*/
    IGRint		i;		/* loop index			*/
    IGRlong		msg1;
    IGRlong		type;		


    IGRmatrix		context_matrix;

    struct GRid		context_id,
			gr_oid;

    GRrange		range;		/* range for delete from Rtree	*/
    
    OM_S_CHANSELECT	chan;		

    IGRint              index, flag;

/*
 *  initialize return variables
 */

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    /* special flag to signify the close message is originating from
     * a delete request, not a sleep.
     */

    type = 2;

/*
 * The reference file should be closed unless this file is an active
 * invisible object space. An active invisible object space's reference
 * file attachments do not have their object spaces loaded.
 */
    flag = TRUE;

    /*
     * Check if I am an activated OS in RFA. If so, deactivate before
     * deleting. Alas! This is not being done now. When a reference file
     * is deleted, the storage for RFA is being initialized to zero thus
     * deactivating any other activated reference file.
     * Intentional block to set scope.
     */
    {
        GRspacenum osn;
        IGRint sts;
        struct GRid rfid;
        IGRboolean aflag;

        aflag = pwIsActivationOn();
        if (aflag)
        {
          /** Get the OS **/
          osn = pwGetActiveOs();

          /** Change 'save' button to normal color **/
          rfDisplaySaveBtn(FALSE);

          /** Change the cursor to normal **/
          rfRestoreCursor();

          /** Reset all global variables **/
          sts = pwDeactivateOS(osn);
        }
        /** remove my color from the global list **/
        rfid.objid = my_id;
        rfid.osnum = osn;
        rfRemoveColorFromList(rfid);
    }

    /*
     * See if this os is in the invisible table.
     */
    Get_invisible_index(OM_Gw_current_OS, index)

    if ( index >= 0 )
    {
        /*
         * If this an active invisible os (PDM kludge), don't close 
         * reference file.
         */
        Get_ref_flag(index, flag)

        if ( flag & EX_ACTINV ) flag = FALSE;
    }

    if (flag)
    {
        /* 
         * Close the reference file 
         */
        OMmsg = om$send(msg = message GRreffile.GRrfclose(msg,&type),
                        targetid = my_id);
    }

#ifdef DEBUG
    printf("In GRrfdelete\n");
    printf("OMmsg from GRrfclose = %d\n",OMmsg);
#endif

    if ( (1 & OMmsg & *msg) || (*msg == GRFILENOTFOUND))
    {
				   /*NULL_OBJID ==> object not in Rtree*/
    	if (! (IF_EQ_OBJID( md_env->md_id.objid , NULL_OBJID)))
    	{
	    world = FALSE;	  	/* get range in local coord.	*/
	    OMmsg = om$send(msg = message GRvg.GRgetrang(
				msg,&md_env->md_env.matrix_type,
				md_env->md_env.matrix,&world,range),
                             targetid = my_id);
	    if (1 & OMmsg & *msg)
	    { 			     
					/* remove from R-tree		*/
        	OMmsg = om$send(msg = message GRmodule.GRmdremove(
					   msg,range,&my_id),
                             	 targetid = md_env->md_id.objid,
                                 targetos = md_env->md_id.osnum);
	    }
	}
	/* check to see if the message originated from the clipping
	 * polygon.  If not, send the delete message to the clipping
	 * polygon also.
	 */
					/* set up channel to clip poly	*/
	om$make_chanselect(channame = "GRreffile.to_clip",
		p_chanselect = &chan);

        OMmsg = om$is_objid_on_channel(
	    objid_c = my_id,
	    p_chanselect = &chan,
	    objid = sender_id);

    	if (OMmsg == OM_W_NOTONCHAN)
    	{
	    /* the sender is not the clipping polygon object.  Therefore
	     * send the message to the clipping polygon object also
	     */

	    OMmsg = om$send(msg = message GRgraphics.GRdelete(msg,md_env),
	        p_chanselect = &chan);

    	}					

/*   	GRgetctxsuper(&msg1,&super);

 	om$make_chanselect(channame = "GRreffile.to_context",
	    p_chanselect = &chan);

	OMmsg = om$send(msg = message GRcontext.GRrefcheck
		(msg,&super.osnum,me->ref_to_master_matrix,
*/
					/* delete the context object	 */
	OMmsg = GRcomputectx(&msg1,&md_env->md_env.matrix_type,
		md_env->md_env.matrix,me->ref_to_master_matrix,
		&context_matrix_type,context_matrix);

        gr_oid.objid = my_id;
	gr_oid.osnum = OM_Gw_current_OS;

	if ( 1 & OMmsg & msg1)
	{
	    if (1 & (GRgetctxid(&msg1,&context_matrix_type,
		context_matrix,&gr_oid,&context_id)))
	    {
		OMmsg = om$send(msg = message GRcontext.GRdeletectx
			(msg,md_env),
		    targetid = context_id.objid,
		    targetos = context_id.osnum);
	    }
	}
    	chan.type = OM_e_name;
    	chan.u_sel.name = "GRconnector.to_owners";
		
	/* notify owner that you are disconnecting so the owner
	 * can delete himself if this is the last component on
	 * the channel.
	 */

	om$send(
	    msg = message GRcmpowner.GRcomponent_disconnecting
		(msg,md_env,&gr_oid),
	    p_chanselect = &chan);

					/* delete the header object	*/
        i = 1;
	OMmsg =  om$send(msg = message Root.delete(i),
                          targetid = my_id,
                          targetos = md_env->md_id.osnum);
    }



    if (! (1 & OMmsg))
    {
	*msg = MSFAIL;
    }
    else
    {
					/* remove from cache		*/
    	GRabsg_del_by_objid(&my_id,&md_env->md_id.osnum);
    }

    /* must be at the end of this function to make */
    /* sure the context object has been deleted    */
    DPdlist_set_object_space_scales();

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_DELETED);

    return(OMmsg);
}
end implementation GRreffile;
