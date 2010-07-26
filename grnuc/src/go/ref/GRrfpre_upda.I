/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRpre_update - routes the pre_update message to the reference
		file
Synopsis

	GRpre_update(msg,env,named_object_name,gragad_id,dp_info)

	IGRlong *msg		Completion code
	struct GRmd_env *env	environment information
	IGRchar	*named_object_name the name of the object in the named
				object directory
	struct GRid *gragad_id	the graphic gadget for display
        struct DP_information *dp_info gadget information
Description

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	11/17/87	Design date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "refpriv.h"
#include "exmacros.h"
#include "dpdef.h"
#include "dpmacros.h"

from Super_rfmgr import Super_passon;
from IGEwinsup import pre_update;

method GRpre_update(IGRlong *msg; struct GRmd_env *env; IGRchar
	*named_object_name; struct GRid *gragad_id; 
	struct DP_information *dp_info)
{
    IGRboolean  world;
   
    IGRint	reset,
		old_levels[32];

    IGRlong	OMmsg,
		msg1,
		i;

    GRrange	range,
		old_range;

    GRobjid	named_object;
    struct GRmd_env local_env;

    struct  pass_args_struct
    {
	IGRlong		*msg;
	struct GRmd_env	*env;
 	IGRchar		*named_object_name;
 	struct  GRid	*gragad_id;
	struct DP_information *dp_info;
    } pass_args;
	
    OM_S_MESSAGE  pass_msg;

    *msg = MSSUCC;		/* initialize return values		*/
    OMmsg = OM_S_SUCCESS;

    if (! GRexpansion_valid())	/* cyclic attachment encountered, exit	*/
    {
	goto wrapup;
    }
				/* get the range of the attachment	*/
    world = TRUE;
    OMmsg = om$send(
	msg = message GRvg.GRgetrang(msg,&env->md_env.matrix_type,
		env->md_env.matrix,&world,range),
	targetid = my_id);

    if (1 & OMmsg & *msg)
    {
    	/* reset the window information to alter the clipping extents when
     	 * displaying objects in the reference file
     	 */

	dp$inter_clip_range		    
	    (msg = &msg1,
	     old_range = old_range,
	     range = range,
	     dp_info = dp_info);

	/* if  dp$inter_clip_range fails, it means the object is outside
	 * the window.
	 */

	if (! (1 & msg1))
	{
	    goto wrapup;
	}
					/* alter levels for reffile	*/
	DPset_levels(old_levels,me->dp_levels,dp_info);

        if (env->md_env.matrix_type != MAIDMX)
        {
	    OMmsg = GRcomputectx(msg,&env->md_env.matrix_type,
		env->md_env.matrix, me->ref_to_master_matrix,
		&local_env.md_env.matrix_type,local_env.md_env.matrix);
        }
        else
    	{
	    for(i=0; i<16; ++i)
	    {
	    	local_env.md_env.matrix[i] = me->ref_to_master_matrix[i];
	    }
	    MAtypemx(&msg1,local_env.md_env.matrix,
		&local_env.md_env.matrix_type);
    	}

	reset = 0;
					/* set up expansion mode	*/
	GRrefmode(&msg1,&local_env.md_env.matrix_type,
	    	local_env.md_env.matrix,&my_id,&OM_Gw_current_OS,&reset);

	if ( 1 & *msg)
	{
	    Get_module_info(&msg1,me->osname,&local_env.md_id.osnum,
			&local_env.md_id.objid);

	    if ( 1 & msg1)
	    {
	    	OMmsg = ex$get_objid_from_NOD(NODname = "IGENOD",
			objname = named_object_name,
			pobjid = &named_object,
			modid = local_env.md_id.objid,
			mod_osnum = local_env.md_id.osnum);

	    	if ( 1 & OMmsg)
	    	{
		    /* Send the pre_update message to the desired
		     * named object.
		     */
	
		    OMmsg = om$send(msg = message IGEwinsup.pre_update
			    (msg,gragad_id,dp_info,&local_env),
		        targetid = named_object,
		        targetos = local_env.md_id.osnum);
	        }
	    	else	
	    	{
		    /* In the event that the desired named object does not
		     * exist in the reference file, the message must
		     * be sent to the Reference file super in the reference
		     * file to check for possible nested files.
		     */
		
	    	    OMmsg = ex$get_objid_from_NOD(NODname = "IGENOD",
			objname = "Ref Mgr",
			pobjid = &named_object,
			modid = local_env.md_id.objid,
			mod_osnum = local_env.md_id.osnum);
	
		    if ( 1 & OMmsg)
		    {
                	OMmsg = om$make_message(
		    	    classname = "GRreffile",
                    	    methodname = "GRpost_update",
                    	    size = sizeof( struct pass_args_struct),
                    	    p_arglist = &pass_args,
                    	    p_msg = &pass_msg);
		    
			pass_args.msg = msg;
			pass_args.env = &local_env;
			pass_args.named_object_name = named_object_name;
			pass_args.gragad_id = gragad_id;
			pass_args.dp_info = dp_info;

		    	OMmsg = om$send(
			    msg=message Super_rfmgr.Super_passon
				(msg,&pass_msg),
			    targetid = named_object,
			    targetos = local_env.md_id.osnum);
		    }		
		    else 	/* reference manager does not exist	*/
		    {
		    	OMmsg = OM_S_SUCCESS;
		    }
	    	}
	    }
	}
        dp$reset_clip_range(msg = &msg1,
     		old_range = old_range,
     		dp_info = dp_info);

        DPreset_levels(old_levels,dp_info);
	if (reset)
	{
	    reset = 1;
   	    GRset_expansion_mode(&reset);
	}
    }

 wrapup:

    return(OMmsg);
}

end  implementation GRreffile;
