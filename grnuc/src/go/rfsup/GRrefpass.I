/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRlocate - locate graphics object

Synopsis

Description

Diagnostics

	This method returns the following return codes:

	MSSUCC - successful completion
	MSFAIL - error occurred
Notes
	None

History
	MAS	08/27/86:	Design Date

\*/
	
class implementation GRreffile;


#include "grimport.h"
#include "msdef.h"
#include "refpriv.h"
#include "madef.h"
#include "lcdef.h"
#include "godef.h"
#include "grerr.h"
#include "refdef.h"
#include "gocmacros.h"
#include "bserr.h"
#include "OMmacros.h"

from module import GRmod_passon;

#define NO_RANGE 1
#define NO_CLIP_POLY 0

extern    IGRboolean    GRpassrange();

GRrefpass(msg,mx_type,matrix,ref_env,msg_to_pass,skew_flag,
	origin,vw_rotation,pt1,pt2,clippoly_flag,vw_volume,
	master_to_ref_matrix,range,tolerance,objid,osnum)

IGRlong		*msg;
IGRshort	*mx_type;
IGRmatrix	matrix;
struct GRmd_env	*ref_env;
OM_S_MESSAGE	*msg_to_pass;
IGRboolean	*skew_flag;
IGRdouble	*origin;
IGRdouble	*vw_rotation;
IGRdouble	*pt1;
IGRdouble	*pt2;
IGRboolean	*clippoly_flag;
IGRdouble	*vw_volume;
IGRmatrix 	master_to_ref_matrix;
IGRdouble	*range;
IGRdouble	*tolerance;
GRobjid		*objid;
GRspacenum	*osnum;
{
	IGRchar  *scan_ptr;		/* pointer to scan range	*/
	IGRboolean range_flag;
	
	IGRlong  OMmsg;			/* OM return code		*/
	IGRlong  msg1;			/* local message		*/

	IGRint   beg,fin;		/* limits for channel send	*/
	IGRint	 reset;

  	IGRdouble range1[6],
		*range_ptr;

	IGRmatrix vw_matrix;

	OM_S_MESSAGE  pass_msg; 	/* structs for make message	*/
	OM_S_MESSAGE skew_pass_msg;
	OM_S_MESSAGE *pass_msg_ptr;

	struct GRpass_args_struct pass_args;
	struct GRskew_pass_args_struct skew_pass_args;

	DB_3D_DBL_BOX range_box;	/* range for pass structure	*/
	SKEW_KEY_3D_DBL skew_range_box;	/* range for pass structure	*/

	OM_S_KEY_DESC range_key;	/* range information for pass	*/
	OM_S_SKEW_DESC skew_range_key;	/* range information for pass	*/

		
	OMmsg = OM_S_SUCCESS;		/* initialize return codes	*/
	*msg = MSSUCC;

  	if (*skew_flag)
	{			/* make OMrtree.skew_pass message	*/
     	    OMmsg = om$make_message(
		classname = "OMrtree",
                methodname = "skew_pass",
                size = sizeof(struct GRskew_pass_args_struct),
	        p_arglist = &skew_pass_args,
                p_msg = &skew_pass_msg);

	    skew_pass_args.msg_to_pass = msg_to_pass;
	    skew_pass_args.ret = (int *)&msg1;
	    skew_pass_args.p_criteria = NULL;
	    skew_pass_args.p_target_key = 0;
	    skew_pass_args.user_compare = 0;
	    skew_pass_args.p_select_key = &skew_range_key;
	    skew_pass_args.p_select_key->key.p_skew_3ddbl= &skew_range_box;
	    skew_pass_args.p_select_key->type = KEY_3D_DBL;
	    scan_ptr = (IGRchar	*) & skew_range_key;
   	    pass_msg_ptr = &skew_pass_msg;
	}
	else
	{				/* make OMrtree.pass message	*/
       	    OMmsg = om$make_message(classname = "OMrtree",
                methodname = "pass",
                size = sizeof( struct GRpass_args_struct),
                p_arglist = &pass_args,
                p_msg = &pass_msg);

	    pass_args.msg_to_pass = msg_to_pass;
   	    pass_args.ret = (int *)&msg1;
    	    pass_args.p_criteria = NULL;
    	    pass_args.p_target_key = 0;
    	    pass_args.user_compare = 0;
    	    pass_args.p_select_key = &range_key;
    	    pass_args.p_select_key->key.p_3ddbl = &range_box;
    	    pass_args.p_select_key->type = KEY_3D_DBL;

    	    scan_ptr = (IGRchar *) &range_key;
    	    pass_msg_ptr = &pass_msg;
       	}

    	MAlswcmx(&msg1,origin,vw_rotation,vw_matrix);

	if (range)
	{
	    range_ptr = range;
	    range_flag = 0;
	}
	else
	{
	    range_ptr = range1;
	    range_flag = 1;
	}

        if ( GRpassrange(&msg1,pt1,pt2,mx_type,matrix,clippoly_flag,
		 vw_volume,master_to_ref_matrix,vw_matrix,range_ptr,
		 range_flag,*skew_flag,tolerance,scan_ptr))
    	{
	    GRrefmode(&msg1,&ref_env->md_env.matrix_type,
		ref_env->md_env.matrix,objid,osnum,&reset);

	    if ( 1 & msg1)
	    {
    	        beg = 0;
    	        fin = GRDGNLIMITS_MAX_I;
			    
    	        OMmsg = om$send(mode = OM_e_wrt_object,
                     msg = message module.GRmod_passon(
		        &msg1,pass_msg_ptr,"module.primary",
			&beg,&fin),
		     senderid = *objid,
                     targetid = ref_env->md_id.objid,
                     targetos = ref_env->md_id.osnum);

		if (reset)
		{
		    reset = 1;	
		    GRset_expansion_mode(&reset);
		}
	    }
	}
 
/* wrapup: */
        return(OMmsg);
}


GRrefdisplaypass(msg,mx_type,matrix,ref_env,msg_to_pass,skew_flag,
	origin,vw_rotation,pt1,pt2,clippoly_flag,vw_volume,
	master_to_ref_matrix,range,tolerance,objid,osnum)

IGRlong		*msg;
IGRshort	*mx_type;
IGRmatrix	matrix;
struct GRmd_env	*ref_env;
OM_S_MESSAGE	*msg_to_pass;
IGRboolean	*skew_flag;
IGRdouble	*origin;
IGRdouble	*vw_rotation;
IGRdouble	*pt1;
IGRdouble	*pt2;
IGRboolean	*clippoly_flag;
IGRdouble	*vw_volume;
IGRmatrix 	master_to_ref_matrix;
IGRdouble	*range;
IGRdouble	*tolerance;
GRobjid		*objid;
GRspacenum	*osnum;
{
	IGRchar  *scan_ptr;		/* pointer to scan range	*/
	IGRboolean range_flag;
	
	IGRlong  OMmsg;			/* OM return code		*/
	IGRlong  msg1;			/* local message		*/

	IGRint   beg,fin;		/* limits for channel send	*/
	IGRint	 reset;

  	IGRdouble range1[6],
		*range_ptr;

	IGRmatrix vw_matrix;

	OM_S_MESSAGE  pass_msg; 	/* structs for make message	*/
	OM_S_MESSAGE skew_pass_msg;
	OM_S_MESSAGE *pass_msg_ptr;

	struct GRpass_args_struct pass_args;
	struct GRskew_pass_args_struct skew_pass_args;

	DB_3D_DBL_BOX range_box;	/* range for pass structure	*/
	SKEW_KEY_3D_DBL skew_range_box;	/* range for pass structure	*/

	OM_S_KEY_DESC range_key;	/* range information for pass	*/
	OM_S_SKEW_DESC skew_range_key;	/* range information for pass	*/

		
	OMmsg = OM_S_SUCCESS;		/* initialize return codes	*/
	*msg = MSSUCC;

  	if (*skew_flag)
	{			/* make OMrtree.skew_pass message	*/
     	    OMmsg = om$make_message(
		classname = "GRrtree",
                methodname = "skew_display_pass",
                size = sizeof(struct GRskew_pass_args_struct),
	        p_arglist = &skew_pass_args,
                p_msg = &skew_pass_msg);

	    skew_pass_args.msg_to_pass = msg_to_pass;
	    skew_pass_args.ret = (int *)&msg1;
	    skew_pass_args.p_criteria = NULL;
	    skew_pass_args.p_target_key = 0;
	    skew_pass_args.user_compare = 0;
	    skew_pass_args.p_select_key = &skew_range_key;
	    skew_pass_args.p_select_key->key.p_skew_3ddbl= &skew_range_box;
	    skew_pass_args.p_select_key->type = KEY_3D_DBL;
	    scan_ptr = (IGRchar	*) & skew_range_key;
   	    pass_msg_ptr = &skew_pass_msg;
	}
	else
	{				/* make OMrtree.pass message	*/
       	    OMmsg = om$make_message(classname = "GRrtree",
                methodname = "display_pass",
                size = sizeof( struct GRpass_args_struct),
                p_arglist = &pass_args,
                p_msg = &pass_msg);

	    pass_args.msg_to_pass = msg_to_pass;
   	    pass_args.ret = (int *)&msg1;
    	    pass_args.p_criteria = NULL;
    	    pass_args.p_target_key = 0;
    	    pass_args.user_compare = 0;
    	    pass_args.p_select_key = &range_key;
    	    pass_args.p_select_key->key.p_3ddbl = &range_box;
    	    pass_args.p_select_key->type = KEY_3D_DBL;

    	    scan_ptr = (IGRchar *) &range_key;
    	    pass_msg_ptr = &pass_msg;
       	}

    	MAlswcmx(&msg1,origin,vw_rotation,vw_matrix);

	if (range)
	{
	    range_ptr = range;
	    range_flag = 0;
	}
	else
	{
	    range_ptr = range1;
	    range_flag = 1;
	}

        if ( GRpassrange(&msg1,pt1,pt2,mx_type,matrix,clippoly_flag,
		 vw_volume,master_to_ref_matrix,vw_matrix,range_ptr,
		 range_flag,*skew_flag,tolerance,scan_ptr))
    	{
	    GRrefmode(&msg1,&ref_env->md_env.matrix_type,
		ref_env->md_env.matrix,objid,osnum,&reset);

	    if ( 1 & msg1)
	    {
    	        beg = 0;
    	        fin = GRDGNLIMITS_MAX_I;
			    
    	        OMmsg = om$send(mode = OM_e_wrt_object,
                     msg = message module.GRmod_passon(
		        &msg1,pass_msg_ptr,"module.primary",
			&beg,&fin),
		     senderid = *objid,
                     targetid = ref_env->md_id.objid,
                     targetos = ref_env->md_id.osnum);

		if (reset)
		{
		    reset = 1;	
		    GRset_expansion_mode(&reset);
		}
	    }
	}
 
/* wrapup: */
        return(OMmsg);
}

end implementation GRreffile;
