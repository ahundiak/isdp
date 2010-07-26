/* #######################    APOGEE COMPILED   ######################## */
class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "refdef.h"

IGRlong GRlocref_objects_by_range (msg,cvl,properties,levels, objid, 
	osnum,master_to_ref,vw_volume,vw_matrix,vw_origin,range)

IGRlong			*msg;
struct  GRlc_cvl 	*cvl;
IGRlong			*properties;
IGRint			*levels;
GRobjid			*objid;
GRspacenum		*osnum;
IGRdouble		*master_to_ref;
IGRdouble		*vw_volume;
IGRdouble		*vw_matrix;
IGRdouble		*vw_origin;
IGRdouble       *range;
{
    enum GRlocate_action action2;

    IGRlong	OMmsg,
		msg1;

    IGRboolean is_skew;			/* flag for skew view		*/

    struct GRlc_info junk_parms;	/* parameters for action handler*/
    IGRdouble *pt1,*pt2;		/* working pointers		*/

    struct GRlc_cvl local_cvl;		/* internal locate information	*/

    OM_S_MESSAGE  pass_msg; 		/* structs for make message	*/

    struct GRlocate_args_struct locate_args;

				/* make GRgraphics.GRlocate message	*/
    if (1&(OMmsg = om$make_message(
	classname = "GRgraphics",
        methodname = "GRlocate",
        size = sizeof(struct GRlocate_args_struct),
        p_arglist = &locate_args,
        p_msg = &pass_msg )))
    {
        /* the environment info sent to the reference
        * file will transform the objects found in the 
     	* reference file into master file coordinates.
     	* This enables the locate line/point to
     	* remain in the master file coordinates.
     	* The module information sent to the reference file
     	* will be as follows:
     	*   module id and object space number of the
     	*		reference file
     	*   environment information to take object in
     	* 		reference file to master file 
     	*		coordinates.
     	*/

	local_cvl = *cvl;				
        locate_args.cvl = &local_cvl;
 	locate_args.range_key = NULL;
	local_cvl.levels = levels;

	OMmsg = om$send(
	    msg = message GRreffile.GRgetenvironment
		   (msg,&cvl->module,&local_cvl.module),
	    senderid = *objid,
	    targetid = *objid);

	if ( 1 & *msg & OMmsg)
	{
	    action2 = start_transition;
	    junk_parms.module_info = local_cvl.module;
			
       	    (*cvl->action_handler)
		((cvl->act_parms),&junk_parms,
		  cvl->locate_args,&action2);

	    is_skew = (*properties & GRIS_SKEW ? 1 : 0);

	    if (cvl->attributes.type == GR_pt_loc)
	    {
		pt1 = pt2 = &cvl->attributes.acc_point[0];
	    }
	    else if (cvl->attributes.type == GR_bl_loc)
	    {
		pt1 = cvl->attributes.acc_line.point1;
		pt2 = cvl->attributes.acc_line.point2;
	    }
	    else
	    {
		pt1 = pt2 = NULL;
	    }

	    OMmsg = GRrefpass(&msg1,
		&cvl->module.md_env.matrix_type,
		cvl->module.md_env.matrix,
		&local_cvl.module,
		&pass_msg,&is_skew,vw_origin,
		vw_matrix,pt1,pt2,NULL,vw_volume,
		master_to_ref,range,
		&cvl->attributes.acc_tolerance,
		objid,osnum);

	    action2 = end_transition;
	    junk_parms.module_info = local_cvl.module;
			
       	    (*cvl->action_handler)
		((cvl->act_parms),&junk_parms,
		  cvl->locate_args,&action2);

    	    cvl->msg = local_cvl.msg;
       	}
    }
    else				/* make message failed		*/
    {
	*msg = MSFAIL;
    }

    return(OMmsg);
}

IGRlong GRlocref_objects(msg,cvl,properties,levels, objid, 
	osnum,master_to_ref,vw_volume,vw_matrix,vw_origin)

IGRlong			*msg;
struct  GRlc_cvl 	*cvl;
IGRlong			*properties;
IGRint			*levels;
GRobjid			*objid;
GRspacenum		*osnum;
IGRdouble		*master_to_ref;
IGRdouble		*vw_volume;
IGRdouble		*vw_matrix;
IGRdouble		*vw_origin;
{
    return GRlocref_objects_by_range (msg,
                                      cvl,
                                      properties,
                                      levels,
                                      objid,
                                      osnum, 
                                      master_to_ref,
                                      vw_volume,
                                      vw_matrix,
                                      vw_origin,
                                      (IGRdouble *)NULL);
}

end implementation GRreffile;
