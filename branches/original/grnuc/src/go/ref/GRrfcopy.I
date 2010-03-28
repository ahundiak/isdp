/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRcopy -  copies a reference file attachment

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

	The copy method copies the reference file attachment
	object, and it's clipping polygon.  The copy is 
	then attached to the Reference file manager object.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	04/05/87	Design date.
        dhm     07/06/92        ANSI conversion.
\*/

class implementation GRreffile;

#include "grimport.h"
#include "refpriv.h"
#include "msdef.h"
#include "OMmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "grownmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "refdef.h"

from GRcontext import GRcopyctx,GRgetinstance,GRchgflag;

method GRcopy(IGRlong *msg; struct GRmd_env *obj_dsenv;
	struct GRmd_env *new_dsenv; GRobjid *newobjid)

{
	IGRboolean connect_channel,
		constr_flag=FALSE;

	IGRshort properties,
		action,
		ctx_flag,
		ctx_flag1;

	IGRlong  OMmsg;			/* method return status		*/
	IGRlong	 msg1;

	IGRint	dimension,
		flag;
	IGRuint	tag;

	struct GRid mgr_id,		/* temporary ids		*/
		new_context_id,
		reffile_id;


	struct GRmd_env local_env;	/* local environment information*/

	GRobjid	 poly_objid;		/* new clippoly object		*/


	OM_S_CHANSELECT poly_chan,
			nested_files_chan;

	OMuword  osnum = 0;		/* object space number		*/

	*msg = MSSUCC;			/* initialize variables		*/
	OMmsg = OM_S_SUCCESS;
	*newobjid = 0;
	local_env = *new_dsenv;
	local_env.md_id.objid = NULL_OBJID;

	properties = me->properties;
 	flag = om$enable_tagging(flag=TRUE);

	if ( 1 & OMmsg & *msg)
	{
	    /* construct the new, tagged object
	     */

	    me->properties = me->properties & ~GR_RIGID_RELATIONSHIP;

	    OMmsg = om$construct_and_copy
		(objid = my_id,
		 osnum = new_dsenv->md_id.osnum,
		 p_objid = newobjid,
		 p_tag = &tag);

	    me->properties = properties;

	    /* check to see if the caller is the clipping polygon.
	     * A copy operation applies to both objects, so if the
	     * caller is not the clipping polygon send the GRcopy
	     * message to the clipping polygon also.
	     */

	    om$make_chanselect(channame = "GRreffile.to_clip",
		p_chanselect = &poly_chan);

    	    OMmsg = om$is_objid_on_channel(
		objid_c = my_id,
		p_chanselect = &poly_chan,
		objid = sender_id);

    	    if (OMmsg == OM_W_NOTONCHAN)
    	    {
		/* the sender is not the clipping polygon object.  
	 	 * Send the message to the clipping polygon object also
	 	 */

		OMmsg = om$send(
		    msg = message GRgraphics.GRcopy
     			(msg,obj_dsenv,&local_env,&poly_objid),
	    	    p_chanselect = &poly_chan);

		connect_channel	= TRUE;
	    }
    	    else
    	    {
		connect_channel = FALSE;
    	    }

	    /* check to see if a file has been attached.  If it has,
	     * increment the number of opens in the invisible table.
	     */
	
	    dimension = om$dimension_of(varray = me->osname);

	    if ((dimension) && ( 1 & OMmsg & *msg))
	    {		
					/* convert name to number	*/
	    	OMmsg = om$os_name_to_number(osname = me->osname,
			p_osnum = &osnum);

		if ( 1 & OMmsg)
		{
	    	    /* increment number opens in invisible table
		     */

                    Increment_num_opens(osnum);
		}
	    }
            if (1 & OMmsg & *msg)
            {

                GRconsmodctx(new_dsenv);

		/* connect the new copy of the reference file attachment 
		 * object to the Super for reference files.
		 */

		OMmsg = GRsuperconnect
		    (msg,&new_dsenv->md_id,newobjid,&mgr_id);

		if ((1 & OMmsg) && (connect_channel))
		{
		    /* connect to the new clipping polygon
		     */

		    OMmsg = GRpolyconnect(msg,&new_dsenv->md_id.osnum,
				&poly_objid,newobjid);
		}

		if ( 1 & OMmsg & *msg)
		{
		    /* find the context object for this object
		     * space in the master context object space.
		     */

		    reffile_id.objid = my_id;
		    reffile_id.osnum = OM_Gw_current_OS;

		    GRgetcontext(&msg1,&reffile_id,&mgr_id,&osnum,
			&new_context_id, &ctx_flag);

		    if ( 1 & msg1)
		    {
			reffile_id.objid = *newobjid;
			reffile_id.osnum = new_dsenv->md_id.osnum;

			if ( 1 & OMmsg)
			{
			    OMmsg = om$send(
			    	msg = message GRcontext.GRcopyctx
				    (msg,new_dsenv,&reffile_id,
				     &new_context_id),
			 	targetid = new_context_id.objid,
				targetos = new_context_id.osnum);

			    if ( 1 & OMmsg & *msg)
			    {
			        if (ctx_flag & GRCYCLIC_ATTACHMENT)
				{
				    /* a check must be made to see
				     * if the copy is cyclic.
				     */

				    om$make_chanselect(
				        channame = 
					    "GRcontext.to_nested_files",
				        p_chanselect = &nested_files_chan);

				    ctx_flag1 = 0;

				    GRcyclic_check(msg,&nested_files_chan,
				       &new_context_id,&osnum,&ctx_flag1);

			            if (! ctx_flag1)
				    {
				        /* This copy is not cyclic
 				         */

				    	action = 0; 

			    	    	OMmsg = om$send(
			    		    msg = 
						message GRcontext.GRchgflag
				    	    	(msg,&action,&ctx_flag1),
			 		    targetid = 
						new_context_id.objid,
					    targetos = 
						new_context_id.osnum);
				    }
				}

				/* transform the clipping polygon 
				 * and the reference file attachment 
				 * object if the method is not being
				 * driven by the clipping polygon.
		 		 */

				if (connect_channel)
				{
		    		    OMmsg = GRxformboth(msg,obj_dsenv,
					&local_env,newobjid,&poly_objid);
				}

				/* increment the number of opens in
				 * the invisible table for any
				 * nested spaces.
				 */

				GRincinvtable(msg,&new_context_id);
			    }
			}
		    }
		    else
		    {
			*msg = MSFAIL;
			OMmsg = OM_E_ABORT;
		    }
	        }
 	    }
       	}	    
	if (! (1 & OMmsg & *msg))	/* failure of method		*/
	{
	    if (*newobjid)		/* delete copy of attachment	*/
	    {
		om$send (msg = message GRgraphics.GRdelete(msg,&local_env),
		    targetid = *newobjid,
		    targetos = new_dsenv->md_id.osnum);

		*msg = MSFAIL;
	    }
	}
	else 
	{
	    gr$add_to_active_owner(
		msg = msg,
		mod_env = new_dsenv,
		objid = *newobjid);

	    if (! (IF_NULL_OBJID(new_dsenv->md_id.objid)))
	    {
	        OMmsg = GRrfaddrtree(msg,new_dsenv,&poly_objid,
			newobjid,NULL);
	    }

           /* if the operation is SplitPart check for read/write permissions
              of the file 
            */

            if(1 & OMmsg & *msg)
              {
                 if(ASMget_splitpart() == TRUE)
                  {
                    GRis_writable ( &msg1, me->filename, 0, OM_Gw_current_OS );

                    if(msg1 == MSSUCC )
                    {        
                       GRmake_writable(&msg1,me->filename,
                                       &new_dsenv->md_id.osnum);
                    }
                    else
                    {
                      GRis_force_writable(&msg1, me->filename, 0,
                                          OM_Gw_current_OS);

                      if(msg1 == MSSUCC)
                       {
                          GRforce_writable(&msg1, me->filename,
                                           &new_dsenv->md_id.osnum);
                       }
                    
                    }

                  }
              }

	    if ( 1 & OMmsg & *msg)
	    {
		IGRchar path[DI_PATH_MAX], name_used[DI_PATH_MAX];
		struct GRid ref_id;

		ref_id.objid = *newobjid;
		ref_id.osnum = new_dsenv->md_id.osnum;

		GRname_reffile(msg,me->filename,me->filename,
		    &ref_id,&constr_flag,name_used);
		
		/* Notify the directory system that a reference 
		 * file is mounted. This connects the directory 
		 * object to the context object.
	 	 */

	    	DIstmocpy(path,"ref",name_used,0,ref_id.osnum);

		di$mount_ref(
	    	    logical = path,
	    	    osnum =   osnum,
	    	    context = new_context_id);
	    }
	}

 	om$enable_tagging(flag=flag);

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_COPIED);

	return(OMmsg);
}

end implementation GRreffile;
