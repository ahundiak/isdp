class implementation DPvd;
/*
** DPvd_select.I - select a user line or curve and return a tangent
*/

#include "griomacros.h"
#include "OMerrordef.h"
#include "grio.h"
#include "lcdef.h"
#include "dp.h"
#include "lc.h"
#include "lcmacros.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grwireframe.h"

from GRcurve import EMcvtanorm;
from GRvg import GRlnproject;

/*
NAME
        DPvd_locate_select

DESCRIPTION
        This is the user provided select function for the lc$locate().
	
	This routine select the first located element without asking
	user to accept. It is a simplified version of LCselect().

SYNOPSIS
        DPvd_locate_select(IGRlong *msg, 
		           struct LC_select_args *select_info,
		           IGRchar *select_args)

PARAMETERS
        See how this routine is invoked in GRNUC's LClocproc.I file.
 
GLOBALS USED

RETURN VALUES
        TRUE - Sucessful
	FALSE - Failed

NOTES
        The *msg value returned is important.
	The accept_event is not a real DATA event.

HISTORY
        12/22/93    T. Wang  
                    Provide this routine to fix TR119312326. If NO_ACC_REJ_CYCLE
		    is used, some composite curves cannot be located properly:
		    the returned object's osnum is 1, which causes GRlnproject()
		    and other methods fail.
*/

#argsused
int DPvd_locate_select(IGRlong *msg, 
		       struct LC_select_args *select_info,
		       IGRchar *select_args)
{
    IGRint ret_code = 0;
    IGRint found = 0;

    struct GRlc_info       *entry;
    struct GRlc_stack      *stack;
    
    stack = select_info->stack;

    if(stack->num_entries < 1) 
    {
	*msg = LC_NO_OBJ_LOCATED;
	ret_code = 0;
	return(ret_code);
    }

    while (!found)
    {
	/* Only use the first object.
	   (We will investigate if this doesn't work properly. Now I don't
	   see any problem)
	*/
	entry = &stack->entry[0];

	select_info->accept_event->located_object[0] = *entry;
	select_info->accept_event->response = DATA;
	select_info->accept_event->num_id = 1;

	*select_info->acc_event1 = *select_info->accept_event;
	select_info->acc_event1->num_id = 1;
	
	stack->num_entries = 0;

	*msg = LC_OBJ_LOCATED;
	found = 1;
	ret_code = 1;
    }

    return(ret_code);
}


int DPvd_locate_element(struct DPvd_actwin *actwin, struct DPvd_wrk_t *wrk,
        int *response, char *response_data)
/*
NAME
        DPvd_locate_element

DESCRIPTION
        This routine will locate a wireframe element (curve) and return
	this element's objid, osnum, and tangent vector, tangent point.

SYNOPSIS
        DPvd_locate_element(struct DPvd_wrk_t *wrk)

PARAMETERS
        wrk->x
	wrk->y (IN)             - dits location of the point in window
	
	wrk->orig_gg (IN)       - gragad of the window

	wrk->element_id (OUT)   - objid of the located element
	wrk->wld_ref_point(OUT) - locate point on the element
	wrk->rotation_axis(OUT) - tangent vec of the tangent at locate point
	wrk->locate_pt_type(OUT) - 0: locate failed, wrk_ref_point is not changed.
	                           1: wrk_ref_point is a point on the curve and tangent vec is correct.
				   2: wrk_ref_point is a vertex (end of curve) and tangent vec is not set.

GLOBALS USED
RETURN VALUES
        TRUE - Sucessful
	FALSE - Failed
NOTES
HISTORY
        06/20/93    T. Wang
        07/05/93    G. Werner
	09/16/93    T. Wang  Clean up format, so that dbg can work properly.
	                     Moved "toggle EMSedge" to wakeup() method.
*/
{
    struct GRevent    locate_event;
    struct GRevent    accept_event;
    struct GRlc_stack locate_stack;
    struct GRmd_env   md_env;
    struct GRlc_info  *lc_info;
    
    long               sts,  msg;
    IGRlong            display_flag;
    int                event_mask;
    struct GRlc_locate attributes;
    OMuword            r_classes[1], e_classes[1];
    OM_S_CLASSLIST     rtree_classes, eligible_classes;
    int                status;
    IGRlong            size;
    struct EX_button   set_button;
    IGRint             local_response;
    int                num_pts = 1;
    double             point[3];
    struct GRparms     proj_parms;
    IGRpoint           ln_pt;
    struct IGRline     bore_line;
    IGRdouble          t;
    
    /* I could not find an include file with this definition: */
    extern OMuword OPP_GRcurve_class_id;

    wrk->locate_pt_type = 0;
    
    /* first, create an event, which looks like a button
     ** event from the given data point and put this 
     ** onto the software queue
     */
    
    local_response = DATA;
    size = sizeof(struct EX_button);
    
    /* Change the point into WCS */
    point[0] = wrk->x;
    point[1] = wrk->y;
    point[2] = wrk->orig_gg.act_z_screen;
    MAptsxform(&msg,&num_pts,wrk->orig_gg.viewport_to_wld,point,&set_button.x);
    
    set_button.window = actwin->win_no;
    set_button.objid = actwin->grid.objid;
    set_button.osnum = actwin->grid.osnum; 
    set_button.numb =  100;
    set_button.clicks =DPvd_UP; 
    set_button.button_down = 0; 
    
    status = ex$putque(msg = &msg,
		       pos      = FRONT,
		       response = &local_response,
		       byte     = &size,
		       buffer   = (IGRchar *) &set_button,
		       mode     = 0 );
    
    
    /* check if successful */
    if(status != 1)
    {
	goto error;
    }
    
    /* Now do a lc$locate to locate exactly this event and 
     ** return the first element located, if any 
     */
    
    sts = OM_S_SUCCESS;
    msg = MSSUCC;
    
    /* set up filter event masks */
    event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_DATA;
    
    /* locate display flag set */
    display_flag = NO_PROJ_ACCEPT_POINT | DO_NOT_RELOCATE;

    /* locate attributes set */
    attributes.owner_action = LC_READ | LC_REF_OBJECTS ;
    
    attributes.properties = LC_LC_ONLY | /* Locate locatable objects */
                            LC_DP_ONLY | /* Locate displayable objects */
			         LC_RW | /* locate readable and writable objs */
			   IGN_MOD_BIT ; /* Ignore modified and new props */
    
    /* Rtree set up */
    rtree_classes.w_count = 1;
    rtree_classes.w_flags   = OM_CLST_subclass;
    rtree_classes.p_classes = &r_classes[0];
    eligible_classes.w_count = 1;
    eligible_classes.w_flags   = OM_CLST_subclass;
    eligible_classes.p_classes = &e_classes[0];
    
    r_classes[0] = OPP_GRcurve_class_id;
    e_classes[0] = OPP_GRcurve_class_id; 
    
    msg = 0;
    sts = 0;
    locate_stack.num_entries = 0;
    
    sts = lc$locate(rc               = &msg,
		    event1           = &locate_event,
		    event2           = &accept_event,
		    response         =  response,
		    response_data    =  response_data,
		    locate_prompt    =  "",
		    acc_prompt       =  "",
		    relocate_prompt  =  "",
		    display_flag     =  display_flag,
		    attributes       = &attributes,
		    stack            = &locate_stack,
		    select           = DPvd_locate_select,
		    select_args      = NULL,
		    rtree_classes    = &rtree_classes,
		    eligible_classes = &eligible_classes);
    
    
    if (!(1&sts))
    {
#ifdef DPvd_DEBUG
	printf("Error on calling lc$locate\n");
#endif
	goto error;
    }
    
    if( msg == LC_NO_OBJ_LOCATED)
    {
	goto error;
    }
    if( msg ==  LC_OBJS_IN_STACK)
    {
	lc_info = &locate_stack.entry[0];
	wrk->element_id = locate_stack.entry[0].located_obj;
	
#ifdef DPvd_DEBUG
	printf("polygon_inx: %d (stack)\n",
	       locate_stack.entry[0].geom_parms.polygon_inx);
	printf("locate_stack num_entries:%d\n",locate_stack.num_entries);
#endif
	
    }
    else if( msg ==  LC_OBJ_LOCATED)
    {
	lc_info = &accept_event.located_object[0];
	wrk->element_id = accept_event.located_object[0].located_obj;
    }
    else
    {
	goto error;
    }
    
#ifdef DPvd_DEBUG
    printf("Element %d selected (%f,%f,%f) \n",
	   wrk->element_id.objid,
	   wrk->wld_ref_point[0],wrk->wld_ref_point[1],wrk->wld_ref_point[2]);
#endif
    

      md_env = lc_info->module_info;

     /*
      * Changes for RFA: using the matrix returned by gr$get_module_env()
      * was causing CVD to misbehave. Now using the info returned by locate
      * to calculate the matrix. This should work fine irrespective of 
      * activation status.
      *
      * gr$get_module_env(buffer = &md_env);
      */
    
    /*
     * project locating point onto the object. For composite object, get its
     * sub-element id.
     */
    {
	point[0] = wrk->x;
	point[1] = wrk->y;
	point[2] = wrk->orig_gg.act_z_screen+10.0;
	num_pts = 1;
	MAptsxform(&msg,&num_pts,wrk->orig_gg.viewport_to_wld,point,point);

	bore_line.point1 = &set_button.x;
	bore_line.point2 = point;

	status = om$send(msg = message GRvg.GRlnproject(&msg,
							&md_env.md_env.matrix_type,
							md_env.md_env.matrix,
							&bore_line,
							ln_pt,
							wrk->wld_ref_point,
							&t,
							&proj_parms),
			 senderid =  NULL_OBJID,
			 targetid =  wrk->element_id.objid,
			 targetos =  wrk->element_id.osnum);
	if(!(1&status&msg))
	{
#ifdef DPvd_DEBUG
	    printf("DPvd_select.I: GRlnproject() failed\n");
#endif    
	    goto error;
	}

	wrk->element_id.objid = proj_parms.leaf_id.objid;
	wrk->element_id.osnum = proj_parms.leaf_id.osnum;
    }

    
    /*
     * Try to find vertex point 
     */

    {
	IGRdouble end_pts[6],pts_vwport[6];
	IGRint has_end_points;
	IGRlong num_pts;
	IGRdouble dx,dy,d1;
	has_end_points = FALSE;
	
	/* Now, wrk->wld_ref_point[] is the proj point. 
	   If end_of_elem_point is very close, place GN at the endpt */
	
	/* Do I need to test this ? since the locate flag already .. */
	if(om$is_ancestry_valid(subclassid=wrk->element_id.objid,
				superclassname="GRcurve"))
	{
	    /* Get end point of GRcurve */
	    status = gr$get_endpoints(msg = &msg,
				      md_env=NULL,
				      object_id = &wrk->element_id,
				      point1 = &end_pts[0],
				      point2 = &end_pts[3]);
	
	    if(status&1)
	    {
		/* Check if end points is close to the locate point */
		num_pts = 2;
		MAptsxform(&msg,&num_pts,(IGRdouble *)(wrk->orig_gg.wld_to_viewport),
			   end_pts,pts_vwport);
	    
		dx = pts_vwport[0]-wrk->x;
		dy = pts_vwport[1]-wrk->y;
		d1 = dx*dx + dy*dy;
	    
		if(d1 < 16) /* 4 pixel tolerance */
		{
		    wrk->locate_pt_type = 2;
		    wrk->wld_ref_point[0] = end_pts[0];
		    wrk->wld_ref_point[1] = end_pts[1];
		    wrk->wld_ref_point[2] = end_pts[2];
		}
		else
		{
		    dx = pts_vwport[3]-wrk->x;
		    dy = pts_vwport[4]-wrk->y;
		    d1 = dx*dx + dy*dy;
		    if(d1 < 16) /* 4 pixel tolerance */
		    {
			wrk->locate_pt_type = 2;
			wrk->wld_ref_point[0] = end_pts[3];
			wrk->wld_ref_point[1] = end_pts[4];
			wrk->wld_ref_point[2] = end_pts[5];
		    }
		}
	    }
	}
    }
    

    /*
     * find a tangent at the given point to the element found
     */
    if(wrk->locate_pt_type != 2)
    {
	IGRpoint poly[2];
	
	status = om$send(msg = message GRcurve.EMcvtanorm(&msg,
							  &md_env.md_env.matrix_type, md_env.md_env.matrix,
							  NULL, 1, &proj_parms, NULL, NULL, 1.0, NULL, TRUE,
							  FALSE, (double *)poly, NULL),
			 senderid = NULL_OBJID,
			 targetid =  wrk->element_id.objid,
			 targetos =  wrk->element_id.osnum);
	if (!(1&status))
	{
#ifdef DPvd_DEBUG
	    printf("View Dynamic:EMcvtanorm failed in DPvd_select.I \n");
#endif
	    goto error;
	}
	
#ifdef DPvd_DEBUG
	printf("point=(%f,%f,%f),tang=(%f,%f,%f)\n",
	       poly[0][0],poly[0][1],poly[0][2],
	       poly[1][0],poly[1][1],poly[1][2]);
#endif
	
	wrk->rotation_axis[0] = poly[1][0] - poly[0][0];
	wrk->rotation_axis[1] = poly[1][1] - poly[0][1];
	wrk->rotation_axis[2] = poly[1][2] - poly[0][2];
	
	wrk->locate_pt_type = 1;
    }

    return(TRUE);

  error:
    wrk->element_id.objid = NULL_OBJID;
    return(FALSE);
}


end implementation DPvd;
