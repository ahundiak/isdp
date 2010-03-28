/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRcopyctx - copy method for the GRcontext class.

Synopsis
    	GRcopyctx(msg,md_env,reffile_id,new_context_id)
	
 	IGRlong	*msg		completion code
	struct GRmd_env *md_env new information for the context object
	struct GRid *reffile_id reference file attachment object id
	struct GRid *new_context_id new copiec context object id
				
Description
	This method copies a context object.  

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.

History
	MAS  	05/27/87 	Design date.

\*/

class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"
#include "refdef.h"
#include "gr.h"
#include "godef.h"
#include "gocmacros.h"
#include "exdef.h"
#include "exmacros.h"

method GRcopyctx(IGRlong *msg; struct GRmd_env *new_env;
	struct GRid *reffile_id,*new_context_id)
{

    IGRlong 	OMmsg,			/* local return codes		*/
		msg1;


    IGRuint	count;

    struct GRid	Super_id,		/* object id of Ref Super	*/
		saved_context_id,
		new_ref_id,
		dummy_id;

    OM_S_CHANSELECT nested_files_chan,
		to_reffile_chan;

    OM_S_OBJECT_LINKAGE objid_list;

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;
     msg1 = MSSUCC;

					/* make copy of new object	*/
    OMmsg = om$construct_and_copy(objid = my_id,
                osnum = new_env->md_id.osnum,
		p_objid = &new_context_id->objid);

    if ( 1 & OMmsg)
    {	
/*
	new_context_id->osnum = OM_Gw_current_OS;
*/
        new_context_id->osnum = new_env->md_id.osnum;

	/* attach this context object to its reference file 
	 * object, and the context Super.
	 */
		
        if(new_env->md_id.osnum == OM_Gw_current_OS)
	  GRgetctxsuper(&msg1,&Super_id);
        else
          {
             OMmsg = ex$get_super(
                        mod_id = new_env->md_id.objid,
                        mod_osnum = new_env->md_id.osnum,
                        super_name = "Ref Mgr",
                        super_class = "Super_rfmgr",
                        create = 0,
                        super_id = &Super_id.objid,
                        super_osnum = &Super_id.osnum);

          }
	
	if (1 & msg1)
	{
	    if (! reffile_id)
	    {
		OMmsg = om$make_chanselect(
		    channame = "GRcontext.to_reffile",
		    p_chanselect = &to_reffile_chan);

		if ( 1 & OMmsg)
		{
		    OMmsg = om$get_channel_objects(objid = my_id,
		      	p_chanselect = &to_reffile_chan,
			list = &objid_list,
			size = 1,
			count = &count);

		    if ( 1 & OMmsg & count)
		    {
			new_ref_id.objid = objid_list.S_objid;
			new_ref_id.osnum = objid_list.osnum;
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
	    }	        
	    else
	    {
		new_ref_id = *reffile_id;
	    }

	    if ( 1 & *msg & OMmsg)
	    {
    	        GRconnchannels(&msg1,&new_ref_id,&Super_id,new_context_id);

	        if ( 1 & msg1)
		{		
		    /* store this context id as current context id	*/

	            GRputcontextid(&msg1,&new_context_id->objid,
			&saved_context_id.objid);

		    if ( 1 & msg1)
		    {			/* copy nested context objects*/

	    	        OMmsg = om$make_chanselect(
			    channame = "GRcontext.to_nested_files",
			    p_chanselect = &nested_files_chan);
			
   	    	        if ( 1 & OMmsg)
			{
    			    OMmsg = om$get_channel_count(objid = my_id,
	    	    		p_chanselect = &nested_files_chan,
	    	    		count = &count);
				
    			    if ( (1 & OMmsg) && (count > 1 ))
    			    {
  	    		    	/* copy the nested context objects
	     	 	    	 */

				count -= 1;

	    		    	OMmsg = om$send(
		    	    	    msg = message GRcontext.GRcopyctx
					(msg,new_env,NULL,&dummy_id),
		    	    	    p_chanselect = &nested_files_chan,
		    	    	    from = 1,
				    to = count);
			    }
			    if ( 1 & OMmsg)
			    {
			    	OMmsg = om$send(
				    msg = message GRcontext.GRupdatectx
					(msg,&new_env->md_env.matrix_type,
					 new_env->md_env.matrix),
				    targetid = new_context_id->objid,
				    targetos = new_context_id->osnum);
			    }
			}
			else
			{
			    *msg = MSFAIL;
			}
		    			/* restore context id		*/
	                GRputcontextid(&msg1,&saved_context_id.objid,
				&new_context_id->objid);
	    	    }
		    else
		    {
		    	OMmsg = OM_E_ABORT;
		    	*msg = MSFAIL;
		    }
		}
		else
		{
		    OMmsg = OM_E_ABORT;
		    *msg = MSFAIL;
		}
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


    return( OMmsg );
}

end implementation GRcontext;
