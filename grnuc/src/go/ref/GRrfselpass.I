/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
 	GRselpass - this method passes an input message to
		attachments which satisfy the input mask
		requirements

Synopsis

	GRselpass(msg,ref_properties_mask,pass_to_nested_attachments,
	 pass_msg, mx_type, matrix, module_id, module_osnum)

	IGRlong *msg		completion code
	unsigned IGRlong *ref_properties_mask
				requested properties for the
				attachment

	IGRshort *pass_to_nested_attachments
				flag to indicate whether you 
				should pass the message to nested 
				attachments
	OM_p_MESSAGE *pass_msg  the message to pass
	IGRshort *mx_type	the matrix type if it is an argument
				in the message you are passing
	IGRmatrix matrix	the matrix if it is an argument
				in the message you are passing
	GRobjid	  *module_id	the module id if it is an argument
				in the message you are passing
	GRspacenum *module_osnum 
				the module space number if it is 
				an argument in the message you are passing

Description
	This method passes an input message to the reference
	file attachament object if it satisfies the input 
	mask.  

	The module_id, module_osnum, mx_type, and matrix are
	included as separate arguments so that they can be 
	updated if you are passing the message to nested 
	reference file attachments.  You should pass a NULL
	pointer for any of these fields not included in the
	argument list of the method you are passing.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error

Notes
	None.
History
	MAS 	04/05/87	Design date.

\*/
class implementation GRreffile;

#include "grimport.h"
#include "refpriv.h"
#include "exmacros.h"
#include "madef.h"
#include "msdef.h"

from Super_rfmgr import GRselectpass;

method GRselpass(IGRlong *msg; IGRulong *ref_properties_mask;
	IGRshort *pass_to_nested_attachments;
	OM_p_MESSAGE pass_msg; IGRshort *mx_type;IGRmatrix matrix;
	GRobjid *module_id; GRspacenum *module_osnum)

{
    IGRshort    four;			/* matrix dimension		*/

    IGRlong     OMmsg;			/* OM return code		*/
    IGRlong	msg1;			/* local message		*/

    IGRulong	mask_check;	/* check for masks		*/
    IGRint	i;			

    struct GRmd_env saved_env;		/* environment info		*/

    GRobjid	Super_id;
    GRobjid	objid;
    GRspacenum  osnum;

    *msg = MSSUCC;			/* initialize return		*/
    OMmsg = OM_S_SUCCESS;

    mask_check = me->ref_properties & *ref_properties_mask;

    if (mask_check == *ref_properties_mask)
    {
	OMmsg = om$send(msg = pass_msg,
		targetid = my_id);

	if ((OMmsg != OM_I_STOP_SENDING) && *pass_to_nested_attachments)
	{
	    Get_module_info(&msg1,me->osname,&osnum,&objid);

	    if (! (1 & msg1))
	    {
		/* file is not found; exit - this is not an error
		 * the reference file is just missing, since this 
		 * method is a pass mechanism, we don't want to 
		 * terminate the send.
		 */

		goto wrapup;
	    }

    	    OMmsg = ex$get_objid_from_NOD(NODname = "IGENOD",
		objname = "Ref Mgr",
		pobjid = &Super_id,
		modid = objid,
		mod_osnum = osnum);
	    
	    if ( 1 & OMmsg)		/* super exists			*/
	    {		
		/* 
		 * if the environment matrix and type have been 
		 * sent in, alter them to be the environment of the 
		 * reference file.
		 */

	        if (mx_type && matrix)
	    	{
		    for (i=0; i<16; ++i)
		    {
		       saved_env.md_env.matrix[i] = matrix[i];
		    }
		    saved_env.md_env.matrix_type = *mx_type;

    	            if (*mx_type != MAIDMX)
    	            {
		        four = 4;
		        MAmulmx(&msg1,&four,&four,&four,
			    saved_env.md_env.matrix,
			    me->ref_to_master_matrix,
			    matrix);
    	    	    }
    	    	    else
    	    	    {
        	        for(i=0; i<16; ++i)
        	        {
	    	            matrix[i] = 
			        me->ref_to_master_matrix[i];
    		        }
    	            }

   	           MAtypemx(&msg1,matrix,mx_type);
  	    	}
		
		/* 
		 * if the module-id and module osnum have been 
		 * sent in, alter them to be the module of the 
		 * reference file.
		 */

	    	if (module_id && module_osnum)
	    	{
		    saved_env.md_id.objid = *module_id;
		    saved_env.md_id.osnum = *module_osnum;
		    *module_id = objid;
		    *module_osnum = osnum;
	    	}		

		OMmsg = om$send(
		   msg = message Super_rfmgr.GRselectpass
		      (msg,ref_properties_mask,pass_to_nested_attachments,
		       pass_msg,mx_type,matrix,module_id,module_osnum),
		   targetid = Super_id,
		   targetos = osnum);

				/* restore saved environment info	*/
	    	if (module_id && module_osnum)
	    	{
		    *module_id = saved_env.md_id.objid;
		    *module_osnum = saved_env.md_id.osnum;
	    	}		
	        if (mx_type && matrix)
	    	{
		    for (i=0; i<16; ++i)
		    {
		       matrix[i] = saved_env.md_env.matrix[i];
		    }
		    *mx_type = saved_env.md_env.matrix_type;
		}
	    }	    
	    else
	    {
		OMmsg = OM_S_SUCCESS;
	    }
	}
    }

wrapup:

    return(OMmsg);
}

end implementation GRreffile;
