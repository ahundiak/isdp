/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: 	GRreffile
     METHOD NAME:	GRlocate_processing

     Abstract: 	This method will check to see if the graphics object
		passes the class list check and the tolerance check.
		
-----
%SC%    

     GRlocate_processing(msg,cvl,path,path_position,owner_elig,
			comp_elig)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
       *cvl	   GRlc_cvl	 structure containing all locate info
       path[]	   GRlc_path	 path information about the object
       *path_position IGRint	 position of object in path array
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
  	*msg	   IGRlong	 completion code
       path[]	   GRlc_path	 path information about the object
       *path_position IGRint	 position of object in path array
       *owner_elig IGRint	 indicator of whether owner is eligible
       *comp_elig  IGRint	 indicator of whether component is
				 eligible

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	
	MAS	11/30/87 : Design date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "bserr.h"
#include "dpmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "lcmacros.h"
#include "grerr.h"
#include "refdef.h"

extern    IGRboolean    GRtransrange();

method GRlocate_processing(IGRlong *msg; struct GRlc_cvl *cvl;
	struct GRlc_path *path; IGRint *path_position,
	*owner_elig, *comp_elig)
{
    IGRchar	*ptr;			/* pointer to cache		*/

    IGRshort   	type_prism;
    
    IGRlong  	relationship;
    IGRlong  	OMmsg;			/* OM return value		*/
    IGRlong  	msg1;			/* local return message 	*/

    IGRint 	eligible_flag;

    IGRdouble	t;


    IGRpoint    line_pt;

    GRclassid	classid;
    OM_S_CHANSELECT poly_chan;

    IGRboolean  top_down_locate;	/* kludge for now		*/


    OMmsg = OM_S_SUCCESS;
    cvl->msg = MSSUCC;
    eligible_flag = 0;
    top_down_locate = 1;		/* for now assume all
					    locates are top down	*/

    if ((*comp_elig) && 
	(path[*path_position].object_info & GRLOC_ATTACHMENT))
    {
	if (1 & (OMmsg = om$get_classid(objid = my_id,
		           p_classid = &classid)))
	{				/* check ancestry		*/
	    msg1 = lc$classchek(rc = &OMmsg,
			classid_to_check = classid,
			eligible_classes = cvl->classes);
	    if ( 1 & msg1 )
	    {
		eligible_flag = 1;
	    }
	}
    }

    if (eligible_flag || *owner_elig || 
	(path[*path_position].object_info & GRLOC_OBJECTS))
    {
	if (path[*path_position].result == GR_LC_NORESULT)
	{
	    /* 
	     * see if the reference attachment is within
	     * tolerance of the locate geometry.
	     */

	    path[*path_position].lc_info.geom_parms.polygon_inx = 3;

	    om$make_chanselect(p_chanselect = &poly_chan,
		channame = "GRreffile.to_clip");

	    if (cvl->attributes.type == GR_pt_loc) 
	    {
		OMmsg = om$send(msg = message GRgraphics.GRptprocess(
		    	msg,&cvl->module.md_env.matrix_type,
	   	      	cvl->module.md_env.matrix,
			&cvl->attributes.acc_tolerance,
			cvl->attributes.acc_point,
			path[*path_position].lc_info.proj_pnt,
			&path[*path_position].lc_info.geom_parms),
		    senderid = my_id,
		    targetid = my_id);

		if ( 1 & OMmsg & *msg)
		{		
 		    if (eligible_flag)
		    {
	    	  	path[*path_position].action = add_all;
		    }
		    if ( *msg != GR_I_OUTSIDE_TOL)
		    {
		        path[*path_position].result = GR_LC_HIT;
		    }
		}
	    }
	    else if (cvl->attributes.type == GR_bl_loc) 
	    {
		OMmsg = om$send(msg = message GRgraphics.GRlnprocess(
		    	msg,&cvl->module.md_env.matrix_type,
	   	      	cvl->module.md_env.matrix,
			&cvl->attributes.acc_tolerance,
			&cvl->attributes.acc_line,
			line_pt,
			path[*path_position].lc_info.proj_pnt,
			&t,
			&path[*path_position].lc_info.geom_parms),
		    senderid = my_id,
		    targetid = my_id);

		if ( 1 & OMmsg & *msg)
		{
 		    if (eligible_flag)
		    {
	    	  	path[*path_position].action = add_all;
		    }
		    if ( *msg != GR_I_OUTSIDE_TOL)
		    {
		        path[*path_position].result = GR_LC_HIT;
		    }
		}
	    }
	    else if ( (cvl->attributes.type == GR_rp_loc) ||
		      (cvl->attributes.type == GR_cv_loc) )
	    {
		if (cvl->attributes.type == GR_rp_loc)
		{
		    type_prism = 0;
		    ptr = (IGRchar *)&cvl->attributes.acc_rt_prism;
		}
		else
		{
		    type_prism = 1;
		    ptr = (IGRchar *)&cvl->attributes.acc_cv_prism;
		}

		OMmsg = om$send(
		    msg = message GRgraphics.GRprismrel
			(&msg1,&cvl->module.md_env.matrix_type,
			cvl->module.md_env.matrix,&cvl->prism_attr,
			&type_prism,ptr,&relationship),
		    targetid = my_id);
		
		if (1 & OMmsg & msg1)
		{
            	    if (relationship == 1)
 	    	    {
		    	if (eligible_flag)
		    	{
			    path[*path_position].action = add_inside;
			}
		    	path[*path_position].result = GR_LC_INSIDE;
	    	    }
	    	    else if (relationship == 2)
	    	    {
		    	path[*path_position].result = GR_LC_OVERLAP;
			if (eligible_flag)
			{
			    path[*path_position].action = add_overlap;
			}
	    	    }
	   	    else 
	   	    {
		    	path[*path_position].result = GR_LC_OUTSIDE;
			if (eligible_flag)
			{
			    path[*path_position].action = add_outside;
			}
	    	    }
		}
    	    }
    	    else if ((cvl->attributes.type == GR_nam_loc) ||
    	    	(cvl->attributes.type == GR_crit_loc))
    	    {
		if (eligible_flag)
		{
		    path[*path_position].action = add_all;
		}
		path[*path_position].result = GR_LC_HIT;
    	    }
    	    else			/* invalid locate for now	*/
    	    {
		OMmsg = OM_E_ABORT;
		cvl->msg = MSFAIL;
    	    }
	    path[*path_position].result  |= GR_LC_PROCESSED;
	}

	/* The processing of the attachment has been completed.  Now
	 * process the elements in the reference file if the owner has
	 * indicated this is a valid operation.
	 */

	if (path[*path_position].object_info & GRLOC_OBJECTS)
	{
	    if (!*comp_elig)
	    {
		path[*path_position].object_info &= ~GRLOC_OBJECTS;
	    }
	} 


	if ( (path[*path_position].result & (~GR_LC_PROCESSED)) 
		&& 
	     (eligible_flag) && (OMmsg != OM_I_STOP_SENDING))
	{
	    if ( top_down_locate )
	    {
		path[*path_position].call_action_handler = 1;
	    }
	    else
	    {
	        if (path[*path_position].object_info
				& GRLOC_OBJECTS)
		{

		    /* let objects in reference file 
		     * be located
		     */
  		    struct GRlc_path	saved_path; 
            IGRdouble           d, view_range[6];
            IGRmatrix           ref_to_view_mx;
            IGRint              num_pts = 2;

            /*
             * Transform me->range from reference file to the view 
             * coordinates and use that range rather than the view volume
             * range (me->vw_volume) which was sent to GRlocref_objects
             * previously. This is necessary because modification to
             * the clipping polygon doesn't update the view volume.
             */

            /* Get the xformation from ref world to view */
            MAwclsmx (msg, 
                      me->vw_origin, 
                      me->vw_rotation, 
                      ref_to_view_mx);
                
            /* Transform the range to view coordinates */
            MAptsxform (msg,
                        &num_pts,
                        ref_to_view_mx,
                        me->range,
                        view_range);
            
            /* Put range in (lowx,lowy,lowz)-(highx,highy,highz) format */
            if (view_range[0] > view_range[3])
            {
                d = view_range[0];
                view_range[0] = view_range[3];
                view_range[3] = d;
            }
            
            if (view_range[1] > view_range[4])
            {
                d = view_range[1];
                view_range[1] = view_range[4];
                view_range[4] = d;
            }
            
            if (view_range[2] > view_range[5])
            {
                d = view_range[2];
                view_range[2] = view_range[5];
                view_range[5] = d;
            }

		    saved_path=path[*path_position];
            
            OMmsg = GRlocref_objects (msg,
                                      cvl,
                                      &me->ref_properties,
                                      me->dp_levels, 
                                      &my_id, 
                                      &OM_Gw_current_OS, 
                                      me->master_to_ref_matrix, 
                                      view_range,
                                      me->vw_rotation,
                                      me->vw_origin);

		    path[*path_position]=saved_path;

		}
	    	if (OMmsg != OM_I_STOP_SENDING)
		{
	    	    OMmsg = (*cvl->action_handler)( cvl->act_parms,
    	    		&path[*path_position].lc_info,cvl->locate_args,
			&path[*path_position].action);
		}
	    }
	}
    }



    return(OMmsg);
}
end implementation GRreffile;
