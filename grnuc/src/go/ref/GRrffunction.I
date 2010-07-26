/* #######################    APOGEE COMPILED   ######################## */
/*\
Name	
	GRfunction - invokes a user provided function

Synopsis

	GRfunction(msg,user_function,info)
	
	IGRlong *msg		Completion code
	int    (*user_function)();
				function to invoke
	IGRchar	*info		user provided info

Description

	This method invokes the user provided function using the
	requests provided in the input character pointer (*info).
	This pointer actually points to a structure of type
	GRfunction_info.

	The function is invoked as follows:

        OMmsg = (*user_function)(msg,&obj,user_info);

	If the pass_to_other_spaces is set, the method will
	be passed to the reference file object space

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error

Notes
	None.
History
	MAS 	04/05/87	Design date.
        jhw     09/22/89        Added call to user function before
                                rtree pass if pass flag = 2. This
                                was done to support I/Image Interscript
                                plotting.
        dhm     07/06/92        ANSI conversion.                        
        WBC     09/03/92        Initializing the module id and module osnum
                                of the "pass along" module environment struct.
\*/

class implementation GRreffile;

#include "grimport.h"
#include "godef.h"
#include "madef.h"
#include "msdef.h"
#include "gomacros.h"
#include "refpriv.h"

from module import GRmod_passon;

method GRfunction(IGRlong *msg; IGRint (*user_function)();
		  IGRchar *user_info)
{
    IGRshort    four;			/* matrix dimension		*/

    IGRlong     OMmsg;			/* OM return code		*/
    IGRlong	msg1;			/* local message		*/

    IGRint	i;			
    IGRint	beg,fin;		/* limits for channel send	*/

    struct GRmd_env env,*ptr_env;	/* environment info		*/
					/* local buffer			*/
    struct GRfunction_info *buffer,local_buffer;
    struct GRid	obj;

    GRobjid	objid;
    GRspacenum  osnum;

    OM_S_KEY_DESC int_range_key;	/* range information for pass	*/
    OM_S_MESSAGE  pass_msg; 		/* structs for make message	*/

    DB_3D_DBL_BOX range_box;		/* range for pass structure	*/

    struct function_args_struct		/* arguments for function method*/
    {
	long	*msg;
	int    (*user_function)();
	char    *user_info;

    } function_args;

    struct pass_args_struct		/* arguments for pass method	*/
    {
	OM_S_MESSAGE *function_msg;
	OM_p_KEY_DESC p_select_key;
	char *p_criteria;
	OM_p_KEY_DESC p_target_key;
	int    (*user_compare)();
	int *ret;
    } pass_args;
    OM_S_MESSAGE function_msg;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    buffer = (struct GRfunction_info *)user_info;
    obj.objid = my_id;
    obj.osnum = OM_Gw_current_OS;

    if (buffer->pass_to_other_spaces)
    {
        if (buffer->md_env)
        {
            if (buffer->md_env->md_env.matrix_type != MAIDMX)
	    {
	        four = 4;
	        MAmulmx(&msg1,&four,&four,&four,buffer->md_env->md_env.matrix,
		    me->ref_to_master_matrix,env.md_env.matrix);
	    }
	    else
	    {
	        for(i=0; i<16; ++i)
	        {
		    env.md_env.matrix[i] = 
			me->ref_to_master_matrix[i];
	    	}
    	    }
            MAtypemx(&msg1,env.md_env.matrix,&env.md_env.matrix_type);
	    ptr_env = &env;
        }
	else
	{
	    ptr_env = NULL;
	}
					/* build buffer for GRfunction	*/
        go$build_user_function_buffer(buffer = &local_buffer,
		md_env = ptr_env,
		pass_on = buffer->pass_to_other_spaces,
		your_info = buffer->info);

					/* make GRfunction message	*/
    	if (1&(OMmsg = om$make_message(classname = "GRgraphics",
                    methodname = "GRfunction",
                    size = sizeof(struct function_args_struct),
                    p_arglist = &function_args,
                    p_msg = &function_msg )))
	{
	    pass_args.function_msg = &function_msg;

					/* make OMrtree.pass message	*/
            if (1&(OMmsg = om$make_message(classname = "OMrtree",
                           methodname = "pass",
                           size = sizeof( struct pass_args_struct),
                           p_arglist = &pass_args,
                           p_msg = &pass_msg )))
	    {
					/* set up for pass method	*/
		pass_args.ret = (int *) &msg1;
		pass_args.p_criteria = NULL;
		pass_args.p_target_key = 0;
		pass_args.user_compare = 0;
		pass_args.p_select_key = &int_range_key;
		pass_args.p_select_key->key.p_3ddbl = &range_box;

				       /* Set up the select key for 
					  the pass method.		*/
		pass_args.p_select_key->type = KEY_3D_DBL;

        	pass_args.p_select_key->key.p_3ddbl->xmin = 
			me->range[0];
        	pass_args.p_select_key->key.p_3ddbl->ymin = 
			me->range[1];
        	pass_args.p_select_key->key.p_3ddbl->zmin = 
			me->range[2];
        	pass_args.p_select_key->key.p_3ddbl->xmax = 
			me->range[3];
        	pass_args.p_select_key->key.p_3ddbl->ymax = 
			me->range[4];
        	pass_args.p_select_key->key.p_3ddbl->zmax =
			me->range[5];

	    	function_args.msg = msg;
		function_args.user_info = (char *) &local_buffer;
		function_args.user_function = user_function;

		beg = 0;		/* limits for channel send	*/
		fin = OM_K_MAXINT;

		Get_module_info(&msg1,me->osname,&osnum,&objid);
                if (msg1 & 1)
                {
                    if (ptr_env)
                    {
                        ptr_env->md_id.osnum = osnum;
                        ptr_env->md_id.objid = objid;
                    }

                    /*
                     * Added to support I/Image interscript plotting.
                     */
                    if (buffer->pass_to_other_spaces == 2)
                    {  
                        OMmsg = (*user_function)(msg,&obj,user_info);

                        if (!(1 & *msg))
                            OMmsg = OM_E_ABORT;
                    }
                    if (OMmsg & 1)
                    {
                        /* do R-tree pass */
                        OMmsg = om$send(mode = OM_e_wrt_object,
                                        msg = message module.GRmod_passon
                                             (&msg1, &pass_msg,
                                              "module.primary", &beg, &fin),
                                        senderid = my_id,
                                        targetid = objid,
                                        targetos = osnum);
                        if (!(1 & OMmsg))
                            *msg = MSFAIL;
                    }
                    else
                        *msg = MSFAIL;
                }
                else
                    *msg = MSFAIL;
	    }
	    else
		*msg = MSFAIL;
	}
	else
	    *msg = MSFAIL;
    }
    if (1 & *msg & OMmsg)
    {  
        if ( ((struct GRfunction_info *)user_info)->pass_to_other_spaces == 2 )
        {
            ((struct GRfunction_info *)user_info)->pass_to_other_spaces = 1;
            OMmsg = (*user_function)(msg,&obj,user_info);
            ((struct GRfunction_info *)user_info)->pass_to_other_spaces = 2;
	}
        else
        {
            OMmsg = (*user_function)(msg,&obj,user_info);
        }

        if (! (1 & *msg))
        {
  	    OMmsg = OM_E_ABORT;
        }
    }

    return(OMmsg);
}

end implementation GRreffile;
