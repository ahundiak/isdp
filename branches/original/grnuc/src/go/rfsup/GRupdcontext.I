/* #######################    APOGEE COMPILED   ######################## */
/*
Name
	GRupdcontext - updates a reference file's context 
		object and all files nested in the file
Synopsis
	GRupdcontext(msg,md_env,ref_to_master_matrix,
		constr_flag,reffid)
	
	IGRlong *msg			return code
		MSSUCC - successful completion
		MSFAIL - error occurred
	struct GRmd_env  *md_env	module environment info
	IGRmatrix  ref_to_master_matrix

	IGRboolean *constr_flag		flag indicating call is
					     from construct
	GRobjid	*reffid			reference file object id

Description
	This function updates the context object associated with
	a reference file attachment object

Diagnostics
	MSSUCC
	MSFAIL

History
	MAS	 09/21/87	Design Date
*/

class implementation GRcontext;

#include "grimport.h"
#include 	"msdef.h"

extern    IGRboolean    GRcomputectx();

GRupdcontext(msg,md_env,ref_to_master_matrix,constr_flag,ref_objid,
	context_objid)

IGRlong		*msg;
struct GRmd_env *md_env;
IGRmatrix	ref_to_master_matrix;
IGRboolean	*constr_flag;
GRobjid		*ref_objid;
struct GRid	*context_objid;
{
    IGRshort	flag,
		flag1,
		context_type,
		type,
		change_flag;

    IGRlong	OMmsg,
		msg1;

    struct GRid	gr_oid,
		context;

    IGRmatrix	context_mx,
		matrix;

    GRspacenum	osnum;

    OM_S_CHANSELECT context_chan,
		nested_files_chan;


    *msg =  MSSUCC;
    OMmsg = OM_S_SUCCESS;

    gr_oid.objid = *ref_objid;		/* set up arguments		*/
    gr_oid.osnum = md_env->md_id.osnum;

    if (context_objid)
    {
	context = *context_objid;
    }
    else if (*constr_flag)
    {					/* context is at index 0	*/
        OMmsg = om$make_chanselect(channame = "GRreffile.to_context",
		p_chanselect = &context_chan);

    	if ( 1 & OMmsg)
    	{
	    OMmsg = om$get_objid_at_index(osnum = gr_oid.osnum,
		objid = gr_oid.objid,
		p_chanselect = &context_chan,
		index = 0,
		objidaddr = &context.objid,
		osnumaddr = &context.osnum);
	}
    }
    else	/* additional context objects must be checked		*/
    {
	if (GRcomputectx(msg,&md_env->md_env.matrix_type,
		md_env->md_env.matrix,ref_to_master_matrix,
		&context_type,context_mx))
	{
	    OMmsg = GRgetctxid(msg,&context_type,
			context_mx,&gr_oid,&context);
	}
	else
	{
	    OMmsg = OM_E_ABORT;
	    *msg = MSFAIL;
	}
    }

    if ( 1 & OMmsg & *msg)
    {    				/* update the context object	*/
      /* FIX for 119418970, recompute sent to source objects connected to 
         objects in nested ref files everytime the master file is 
         saved/retrieved. The fix is: GRupdatectx() is sent to the contexts 
         of the ref files within the master(active) os only. The nested 
         contexts are to be updated from the master os contexts only and 
         not directly.
         --  Moved this Fix from GRrfinit.I . TR# 119426088
      */

	if (OM_Gw_current_OS == EX_active_OS_num)
	{
    		OMmsg = om$send(msg = message GRcontext.GRupdatectx
			(msg,&md_env->md_env.matrix_type,
		 	md_env->md_env.matrix),
    	    		senderid = *ref_objid,
	    		targetid = context.objid,
	    		targetos = context.osnum);
	}

	if ( (1 & OMmsg) && (*constr_flag))
	{
	    OMmsg = om$send(msg = message GRcontext.GRgetinstance
			(msg,&type,matrix,&osnum,&flag,&context),
			senderid = gr_oid.objid,
			targetid = context.objid,
			targetos = context.osnum);
			
	    if ( 1 & OMmsg)
	    {
		OMmsg = om$make_chanselect(
			channame = "GRcontext.to_nested_files",
			p_chanselect = &nested_files_chan);

		if ( 1 & OMmsg)
		{
		    flag1 = 0;
		    GRcyclic_check(msg,&nested_files_chan,&context,
				&osnum,&flag1);

		    if (1 & *msg)
		    {
			if (flag != flag1)
			{
			    change_flag = 1;
			    OMmsg = om$send(
				    msg = message GRcontext.GRchgflag
					(&msg1,&change_flag,&flag1),
				    senderid = context.objid,
				    targetid = context.objid,
				    targetos = context.osnum);
			}
		    }
		}
	     }   
	}
    }

    return (OMmsg);
}
end implementation GRcontext;
