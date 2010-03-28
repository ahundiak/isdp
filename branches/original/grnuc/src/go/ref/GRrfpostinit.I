/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRrfpostinit

Synopsis
	GRrfpostinit(msg,context_super)

     	IGRlong	*msg	 	return message
   	struct GRid *context_super context super for this attachment

Description

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion

Notes
	None.
History
	MAS  	08/20/86 	Design date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "godef.h"
#include "msdef.h"
#include "dpdef.h"
#include "referr.h"
#include "refdef.h"
#include "refpriv.h"
#include "exdef.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "dpsavevw.h"
#include "OMmacros.h"
#include "grerr.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"

from  GRcontext import GRputosnum,GRchgflag,GRgetinstance;

method GRrfpostinit(IGRlong *msg; struct GRid *context_super) 
{
    IGRboolean 	new_context,
		construct_flag = 0;

    IGRshort	ctx_type,
    		action,
		flag = 0;

    IGRlong 	OMmsg,		/* return codes				*/
    		msg1;
   
    IGRint  	dimension;

    struct GRid	context,
	    	saved_context_id,
		ref_super,
		mod,
		oid;

    IGRmatrix   ctx_matrix;

    GRspacenum 	osnum;

    OM_S_CHANSELECT chan;
    
    OMmsg = OM_S_SUCCESS;	
    *msg = MSSUCC;
				/* get the dimension of the filename	*/
    dimension = om$dimension_of(varray = me->filename);
    new_context = TRUE;
				/* do we have a filename yet		*/
    if (dimension)
    {
	oid.objid = my_id;
	oid.osnum = OM_Gw_current_OS;

	if ( 1 & OMmsg)
	{
	    /* find this object space's context object, if none exists,
	     * construct an empty context object and connect the
	     * channels.
	     */

	    OMmsg = GRcheckcontext(msg,me->ref_to_master_matrix,
		context_super,&oid,&construct_flag,&context,
		&new_context);
	}

  	/* Push new context id on the context stack before
 	 * going to the next object space
	 * Current context id is returned in saved_context_id
	 */

	if ( 1 & OMmsg)
  	{
	    OMmsg=1;
	    GRputcontextid(&msg1,&context.objid,
			&saved_context_id.objid);

            if(me->osname)
    	    {		
				/* get module info from invisible table	*/
		Get_module_info(&msg1,me->osname,&mod.osnum,&mod.objid)

		if ( 1 & msg1 )
		{	/* increment invisible table for this osnum	*/

		    Increment_num_opens(mod.osnum) 

    	    	    om$send(
		    	    msg = message GRcontext.GRputosnum
			    	(&msg1,&mod.osnum),
    		    	    targetid = context.objid,
    		    	    targetos = context.osnum);

		    if (new_context)
		    {
			om$make_chanselect(
			    channame = "GRcontext.to_nested_files",
			    p_chanselect = &chan);

			GRcyclic_check(msg,&chan,&context,&mod.osnum,
				&flag);
		    }
		    else
		    {
			/* see if this is a cyclic attachment
			 */

			OMmsg = om$send (
			    msg = message GRcontext.GRgetinstance
	    	    		(&msg1,&ctx_type,ctx_matrix,
				 &osnum,&flag,&context),
			    targetid = context.objid,
			    targetos = context.osnum);
		    }

		    if (! (flag & GRCYCLIC_ATTACHMENT))
		    {
		    	/* get the reference file super in the reference
		    	 * file object space.
		    	 */

		    	OMmsg = ex$get_super(mod_id = mod.objid,
			    mod_osnum = mod.osnum,
			    super_name = "Ref Mgr",
			    create = 0,
			    super_class = "GRreffile",
			    super_id = &ref_super.objid,
			    super_osnum = &ref_super.osnum);

		        if ( (1 & OMmsg) && 
			     (!IF_NULL_OBJID(ref_super.objid)))
		     	{
		            om$make_chanselect(
	    			channame = "Super_rfmgr.mgr",
	    			p_chanselect = &chan);

		    	    OMmsg = om$send(
			    	msg = message GRreffile.GRrfpostinit
				    (msg,context_super),
			    	senderid = ref_super.objid,
			    	targetos = ref_super.osnum,
			    	p_chanselect = &chan);
			}
		    }
		}
            }

	    action = 1;
	    flag |= GRACTIVATED_CONTEXT;

	    om$send (msg = message GRcontext.GRchgflag
			(&msg1,&action,&flag),
		    targetid = context.objid,
		    targetos = context.osnum);

	    GRputcontextid(&msg1,&saved_context_id.objid,
			&context.objid);
	}
    }

    if ( 1 & OMmsg )
    {			
	/* Notify the directory system that a reference file is mounted
	 * This connects the directory object to the context object.
	 */
/*
	di$mount_ref(
	    logical = path,
	    osnum = osnum,
	    context = context);
*/
    }

    return( OMmsg );
}

end implementation GRreffile;
