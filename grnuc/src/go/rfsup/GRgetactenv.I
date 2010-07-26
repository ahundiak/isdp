/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
        GRgetactenv -- get the active environment
			information
Synopsis

	GRgetactenv(msg,point,sizebuf,md_env,nret)

	IGRlong		*msg;
	struct EX_button *point;
	IGRint		*sizebuf;
	struct GRmd_env *md_env;
	IGRint		*nret;

Description

	This function determines if the system is in
	model mode or if it is in drawing sheet mode.
	If it is in model mode the input point is used
	to determine which model window is to become the
	active window for the construct operation.

Diagnostics
	This method returns the following return codes:
	  MSSUCC  - successful completion
	  MSFAIL  - error occured
	  MSINARG - size of the buffer provided is not 
		sufficient.
Notes
	None
History
        MAS     03/27/87    Design date
\*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"
#include "dpdef.h"
#include "ex.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "gomacros.h"
#include "griodef.h"
#include "refdef.h"
#include "grdpbdef.h"

from Super_rfmgr import GRselectpass;

extern    IGRint    GRgetattachment();

GRgetactenv(msg,point,sizebuf,md_env,nret)

IGRlong		*msg;			/* return message		*/
struct EX_button *point;		/* point to be used 		*/
IGRint		*sizebuf;		/* size of output buffer	*/
struct GRmd_env *md_env;		/* environment returned		*/
IGRint		*nret;			/* size of buffer returned	*/

{
    IGRchar 	mode;			/* system mode			*/

    IGRshort	pass_to_nested_files;	

    IGRlong	msg1; 			/* local message		*/
    IGRlong 	OMmsg;

    IGRulong	ref_properties;		/* reference file properties	*/

    IGRint 	size,			/* size for macro call		*/
		err;			/* err variable for view macro	*/

    IGRdouble	pt1[3],			/* pointers for line		*/
		pt2[3];

    IGRmatrix	matrix;			/* view matrix			*/
  
    struct GRmd_env env;		/* environment structure	*/
    struct GRfunction_info buffer;	/* buffer for GRfunction	*/
    struct var_list list[2];		/* structure for view macro	*/

    GRobjid 	Super_id;		/* object id of Reference Mgr	*/

    OM_S_MESSAGE pass_msg;		/* message to pass to graphics	*/

    
    struct function_arguments		/* arguments for pass message	*/
    {
	IGRlong  *msg;		
	IGRint    (*compare_function)();
	IGRchar  *info;

    } function_args;

    struct get_att_arguments
    {
	struct GRmd_env env;
	struct IGRline  line;
	IGRdouble	tol;
    } get_att_args;


    if (*sizebuf < sizeof(struct GRmd_env))
    {
	*msg = MSINARG;	
	OMmsg = OM_E_ABORT;
    }
    else			
    {
	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	/* 
	 * the mode of the system must be checked to see
	 * if you are in model mode or if you are in
	 * drawing sheet mode.
	 */
	
	size = sizeof(IGRchar);

	gr$get_model_mode(msg = &msg1,
		sizbuf = &size,
		buffer = &mode,
		nret = &size);

	/* 
	 * If the system is in drawing sheet mode the environment
	 * information returned is the environment of the Master
	 * file.  This is retrieved using the gr$get_locate_env
	 * macro.
	 */

	if ( mode == DRAWING_MODE )	
	{	
	    gr$get_locate_env(msg = msg,
		    sizbuf = sizebuf,
		    buffer = md_env,
		    nret = nret);
	}
	else
	{
	    /* 
	     * Form the bore line to determine the closest attachment
	     * to the input point.  The view information is used to
	     * form the bore vector.
	     */
					/* assign line pointers		*/
  	    get_att_args.line.point1 = pt1;	
  	    get_att_args.line.point2 = pt2;
					
	    get_att_args.line.point1[0] = point->x;	
	    get_att_args.line.point1[1] = point->y;
	    get_att_args.line.point1[2] = point->z;
					/* set up for set/inq view	*/
	    list[0].var = VIEW_ROTATION;
	    list[0].var_ptr = (IGRchar *)matrix;
	    list[0].num_bytes = sizeof (IGRmatrix);
	    list[0].bytes_returned = (IGRlong *)&size;
	    list[1].var = END_PARAM;
					/* get view rotation		*/
	    dp$inq_set_gragad(msg = msg,
		osnum = point->osnum,
		gragad_objid = point->objid,
		which_error = &err,
		var_list = list);

   	    if (1 & *msg)		/* form bore vector		*/
	    {
   	        pt2[0] = pt1[0] + matrix[8];
	    	pt2[1] = pt1[1] + matrix[9];
	    	pt2[2] = pt1[2] + matrix[10];
		
		/* 
		 * if the system is in model mode, do not pass to
		 * nested reference files.  If the system is in 
		 * selected model mode, pass to nested spaces.
		 */

		if ( mode == MODEL_MODE )
		{
		    pass_to_nested_files = 0;
		}
		else 
		{
		    pass_to_nested_files = 1;
		}

		OMmsg = gr$get_locate_env(msg = &msg1,
		    sizbuf = sizebuf,
		    buffer = &env,
		    nret = nret);
		/* 
		 * make the message to send a GRfunction message
	 	 * to all eligible reference file attachments.
		 */
		
		if ( 1 & OMmsg)
		{
		    OMmsg = om$make_message(
		        classname = "GRgraphics",
		    	methodname = "GRfunction",
		    	size = (sizeof (struct function_arguments)),
		    	p_arglist = &function_args,
		    	p_msg = &pass_msg);
		
		    if ( 1 & OMmsg)
		    {
		    	go$build_user_function_buffer(
			    buffer = &buffer,
			    md_env = &env,
			    pass_on = pass_to_nested_files,
			    your_info = (IGRchar *)&get_att_args);

		        function_args.compare_function = GRgetattachment;
		        function_args.msg = &msg1;
		        function_args.info = (IGRchar *) &buffer;

			get_att_args.tol = 0.0000000001;
		    		
		        ref_properties = GR_CAN_BE_ACTIVE;

					/* get Super info		*/

		    	OMmsg = ex$get_objid_from_NOD
		    	    (NODname = "IGENOD",
			    objname = "Ref Mgr",
			    pobjid = &Super_id);

		    	if (1 & OMmsg)
		    	{
		            OMmsg = om$send(
		            	msg = message Super_rfmgr.GRselectpass
			            (&msg1,&ref_properties,
			             &pass_to_nested_files,&pass_msg,
			             &env.md_env.matrix_type,
			             env.md_env.matrix,
				     &env.md_id.objid,
				     &env.md_id.osnum),
		                senderid = NULL_OBJID,
		                targetid = Super_id);

		            if (OMmsg != OM_I_STOP_SENDING)
		            {
			    	/* 
			     	 * The locate point does not fall within
			     	 * any of the attachments.  Return the
			     	 * master file environment.
			     	 */

	    		    	OMmsg = gr$get_locate_env(msg = msg,
		    		    sizbuf = sizebuf,
		    		    buffer = md_env,
		    		    nret = nret);
			    }
			    else
			    {
			    	*md_env = get_att_args.env;
			    	*nret = sizeof(struct GRmd_env);   
				OMmsg = gr$put_model_env(
				    msg = &msg1,
				    sizbuf = sizebuf,
				    buffer = md_env);
			    }
		 	}
		    }
		}
	    }
	}
    }

    return(1 & *msg);
}

end implementation GRgraphics;
