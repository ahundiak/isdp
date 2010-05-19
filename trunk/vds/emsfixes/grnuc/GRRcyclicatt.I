/* $Id: GRRcyclicatt.I,v 1.2 2001/01/13 00:23:18 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/emsfixes/grnuc/GRRcyclicatt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: GRRcyclicatt.I,v $
 *      Revision 1.2  2001/01/13 00:23:18  hans
 *      SP16 modifications
 *
 *      Revision 1.1  2001/01/13 00:04:40  hans
 *      SP16 modifications
 *
# Revision 1.1  2000/10/27  20:54:52  pinnacle
# Created: vds/emsfixes/grnuc/GRRcyclicatt.I by jpulapar for Service Pack
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      10/27/00        adz             VDcheck_cycleOS
 *
 * -------------------------------------------------------------------*/

/* #######################    APOGEE COMPILED   ######################## */
/*
Name
	GRcyclic_check - checks context objects for a
		cyclic attachment
Synopsis

	GRcyclic_check(msg,nested_files_chan,context_id,osnum,flag)

	IGRlong *msg			return code
		MSSUCC - successful completion
		MSFAIL - error occurred
	OM_S_CHANSELECT *nested_files_chan
					channel to nested files
	GRobjid		*context_id;	context object id
	IGRint		*flag;		flags of context object,
					initialized to 0 before calling
Description
	This function checks the nested files for a cyclic
	attachment

Diagnostics
	MSSUCC
	MSFAIL

History
	MAS	 09/21/87	Design Date
*/

class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "refdef.h"
#include <exmacros.h>
#include <coimport.h>
#include <stdio.h>
#include <FI.h>
#include <refdef.h>
#include <ref.h>
#include <grgsmacros.h>
#include "grdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include <DIdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <DImacros.h>
#include <OMlimits.h>
#include <grmessage.h>
#include "vdrefmacros.h"


from GRreffile	  import   GRinquireref;
from GRdrawview   import   GRcomponent_pass, GRget_drawview_description,
                           GRget_drawview_scale, GRget_drawview_label,
                           GRget_alignment_count, GRget_alignment_objects;
from GRdvattach   import   GRget_drawing_view_id;
from GRgrset      import   GSstart_transition, GSend_transition;
from GRvg         import   GRgetname;
from Super_rfmgr  import   GRget_channel_count;
from GRgraphics   import   GRgetprops;

static OM_S_CHANSELECT ref_chan;


%safe
static int chan_initialized=0;
%endsafe


/*
 * The following routines handle the nested list of reference
 * file nodes.
 * These routines are to be used when the review reference file
 * form can be written to in 2.0.0.
 */
struct VDref_info
{
    GRspacenum      osnum;
    int             found;
};

#argsused
extern int VDrevref_output ( msg, num, depth, requests, info )
    IGRint * msg;
    IGRint num;
    IGRint depth;
    struct GRinquire_list * requests;
    struct VDref_info * info;
{
 /*   struct nest_node * cn; */
    IGRint 		j, req;
    struct GRid		ref_id;
    IGRlong 		sts,msg1;
    IGRboolean		pass_on;	/* pass to nested spaces flag	*/
    GRspacenum		nested_osnum;
    struct GRinquire_list inquire_requests[2];
    struct GRmd_env dummy_env,new_env, mdEnv;

    sts = OM_S_SUCCESS;
    msg1 = OM_S_SUCCESS;

    /* Set up the data pointers.
     *
     * Attach Name, Type, File Name, Description, Saved View, Scale
     */
    for (req=0; req<1; ++req)
    {
        switch (requests[req].var)
        {
        case REFERENCE_ID:
             ref_id.objid = ((struct GRid *)(requests[req].var_ptr))->objid;
             ref_id.osnum = ((struct GRid *)(requests[req].var_ptr))->osnum;

             inquire_requests[0].var = ENVIRONMENT_INFO;
             inquire_requests[0].var_ptr = (IGRchar *)&new_env;
             inquire_requests[0].num_requested = sizeof(struct GRmd_env);
             inquire_requests[1].var = END_REPORT_REQUEST;

             MAidmx(msg,dummy_env.md_env.matrix);
                           dummy_env.md_env.matrix_type = MAIDMX;

             dummy_env.md_id.objid = NULL_OBJID;
             pass_on = FALSE;

             sts = om$send( msg = message GRreffile.GRinquireref
                            (&msg1,&dummy_env,inquire_requests,
                             &j,&pass_on,NULL),
                        senderid = ref_id.objid,
                        targetid = ref_id.objid,
                        targetos = ref_id.osnum );

// 	     printf(" New OS: %d\n", new_env.md_id.osnum );

             if (new_env.md_id.osnum == info->osnum)
             {
//		printf(" CYCLE ATTACHEMENT OS: %d\n", new_env.md_id.osnum );
			info->found = 1 ;
             }

             break;
        }
    }

    return(1);
}


int VDcheck_cycleOS( msg, mdEnv, context_id, osnum, flag )
long		*msg;
struct GRmd_env	*mdEnv ;
struct GRid     *context_id;
GRspacenum      *osnum;
IGRshort        *flag;
{

	struct VDref_info       ref_info;
	struct GRreport_info    review_info;

	*msg = MSSUCC ;

        /*
         * Fill in the reference file nest list.
         */
	if( ! osnum ){
		return (OM_S_SUCCESS);
	}

        ref_info.osnum = *osnum ;
        ref_info.found = 0;

        review_info.output_func = VDrevref_output;
        review_info.info = (IGRchar *)&ref_info;

        GRreffile_reports ( msg,
                            mdEnv,
			    GR_reference_id,

/*****
                            GR_reference_file_duposname |
                            GR_reference_file_found |
                            GR_reference_name | GR_reference_file_name |
                            GR_reference_instance_data | GR_saved_view_name |
                            GR_reference_type | GR_file_properties |
                            GR_reference_id,
 *****/
                            &review_info,
                            TRUE );

	if( ref_info.found ){
		*flag |= GRCYCLIC_ATTACHMENT;
		UI_status(" Part is cyclic attachment");
	}

	return (OM_S_SUCCESS);
}

GRcyclic_check(msg,nested_files_chan,context_id,osnum,flag)

IGRlong		*msg;
OM_S_CHANSELECT *nested_files_chan;
struct GRid	*context_id;
GRspacenum	*osnum;
IGRshort	*flag;
{
    IGRboolean 	pass_on;		/* pass to nested spaces flag	*/

    IGRshort	nest_flag,
		type,
		change_flag=1;		/* flag for change properties	*/

    IGRlong	OMmsg,			/* return codes			*/
		msg1;

    IGRint	i,j,step,
		sizbuf, BytesRet,
		count;

    IGRmatrix	matrix;			/* local matrix for method	*/

    struct GRid	prev_context_id,	/* context ids			*/
		context_info;

    GRspacenum	nested_osnum;
    struct GRinquire_list inquire_requests[2];
    struct GRmd_env dummy_env,new_env, mdEnv;

    *msg =  MSSUCC;
    OMmsg = OM_S_SUCCESS;
    step = 0 ;

    sizbuf = sizeof ( struct GRmd_env );
    gr$get_module_env (  msg    =  msg,
                         sizbuf =  &sizbuf,
                         buffer =  &mdEnv,
                         nret   =  &BytesRet );

    nest_flag = *flag;
    prev_context_id = *context_id;

    if (!chan_initialized)
    {
	om$make_chanselect(channame = "GRcontext.to_reffile",
	    p_chanselect = &ref_chan);

	chan_initialized = 1;
    }

    /* get the nested files count	*/
    OMmsg = om$get_channel_count(objid = context_id->objid,
		osnum = context_id->osnum,
		p_chanselect = nested_files_chan,
		count = (OMuint *)&count);

    if ( 1 & OMmsg)
    {
	if ( count)			/* if there are any objects	*/
	{
	    /* check to see if the context object represents a
	     * cyclic attachment with an object in the tree to
	     * this point
	     */

	    step = 0 ;

	    while (! ( nest_flag & GRMASTER_CONTEXT))
	    {
		/* check backwards all objects in the tree to this point
		 * until you reach the master file context object
		 */

	        context_info.objid = NULL_OBJID ;
		OMmsg = om$send (msg = message GRcontext.GRgetinstance
	    	    	(&msg1,&type,matrix,&nested_osnum,
			 &nest_flag,&context_info),
	    	    p_chanselect = nested_files_chan,
	    	    senderid = prev_context_id.objid,
		    targetos = prev_context_id.osnum,
	    	    from = 0,
	      	    to = 0);

		prev_context_id = context_info;


		if (! ( (nest_flag & GRACTIVATED_CONTEXT) ||
		        (nest_flag & GRMASTER_CONTEXT) ) )
		{
		    /* This context object has not yet been updated
		     * with the new osnum get it from the reffile object
		     */

		    inquire_requests[0].var = ENVIRONMENT_INFO;
		    inquire_requests[0].var_ptr = (IGRchar *)&new_env;
		    inquire_requests[0].num_requested = sizeof(struct GRmd_env);
		    inquire_requests[1].var = END_REPORT_REQUEST;

		    MAidmx(msg,dummy_env.md_env.matrix);
			   dummy_env.md_env.matrix_type = MAIDMX;

		    dummy_env.md_id.objid = NULL_OBJID;
    		    pass_on = FALSE;

    		    OMmsg = om$send(
	    		msg = message GRreffile.GRinquireref
			    (&msg1,&dummy_env,inquire_requests,
			     &j,&pass_on,NULL),
			senderid = prev_context_id.objid,
			targetos = prev_context_id.osnum,
	                p_chanselect = &ref_chan);

  		    if (new_env.md_id.osnum == *osnum)
		    {
	    	    	*flag |= GRCYCLIC_ATTACHMENT;
		    	break;
		    }
		}
		else if (nested_osnum == *osnum)
		{
	    	    *flag |= GRCYCLIC_ATTACHMENT;
		    break;
		}

/** Ad **/
		step ++ ;
		if( step == 1000 ) {
			VDcheck_cycleOS( &msg1, &mdEnv,
				   &prev_context_id, osnum, flag );
			break ;

		}
/** Ad **/
	    }

	    count -= 1;			/* adjust index			*/

	    /* After checking all the attachments above this one
	     * we must now check the attachments nested inside this
	     * attachment.  The check will start at the bottom of
	     * the tree and call this routine recursively to check
	     * all attachments.
	     */

	    for (i = count; i > 0; --i)
	    {
		OMmsg = om$send (msg = message GRcontext.GRgetinstance
	    	    	(&msg1,&type,matrix,&nested_osnum,
			 &nest_flag,&context_info),
	    	    p_chanselect = nested_files_chan,
	    	    senderid = context_id->objid,
		    targetos = context_id->osnum,
	    	    from = i,
	      	    to = i);

		if ( context_id->objid == context_info.objid)
		{
		     break;
		}

		GRcyclic_check(&msg1,nested_files_chan,&context_info,
			&nested_osnum,&nest_flag);

		if (nest_flag & GRCYCLIC_ATTACHMENT)
		{
		    OMmsg = om$send(msg = message GRcontext.GRchgflag
				(&msg1,&change_flag,&nest_flag),
			p_chanselect = nested_files_chan,
			senderid = context_id->objid,
			targetos = context_id->osnum,
			from = i,
			to = i);

		    nest_flag = 0;
		}
	    }
	}
    }
    else
    {
	*msg = MSFAIL;
    }

    return (OMmsg);
}

end implementation GRcontext;
