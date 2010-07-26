class implementation DPvd;
/*
** DPvd_transf.C   - transformation handling for dynamics
*/


#define PI 3.14159265358979323846

#include <stdio.h>
#include <math.h>
#include "bsdefs.h"
#include "OMmacros.h"
#include "exdef.h"
#include "msdef.h"
#include "exmacros.h"
#include "msmacros.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "igrdef.h"
#include "go.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igewinmacros.h"

#include "maang2vc.h"    /* prototypes */
#include "maatan.h"    /* prototypes */
#include "madotvc.h"    /* prototypes */
#include "maidmx.h"    /* prototypes */
#include "mamulmx.h"    /* prototypes */
#include "maptsxfor.h"    /* prototypes */
#include "marotmx.h"    /* prototypes */
#include "masubvc.h"    /* prototypes */
#include "maunitvc.h"    /* prototypes */
#include "masqrt.h"

#include "DPvd.h"

#define DPvd_MAX_ZOOM_FACTOR 100.0

#define DPvd_MIN_VIEWVOL   0.0001  /* smallest parallel view vol. Smaller than
				    this, graphics will be draw outside window.*/
#define DPvd_MAX_VIEWVOL   20000000.0  /* largest parallel view vol */


/*----------------------------------------------------------------------
NAME
        DPvd_curve_ratio

DESCRIPTION
        Change ratio so that it increases slower when near 0 and
	faster when near 1. It uses some form of the function y = 1/x.

SYNOPSIS
        double DPvd_curve_ratio(double ratio, double interval)

PARAMETERS
        ratio (IN) - a value in the range [0.0, 1.0].
	interval(IN) - a value > 1.0. It tells which piece of the function
	               y = 1/x to use. Larger value will cause ratio to
		       increase more slowly at begining and more fast later.

GLOBALS USED

RETURN VALUES
        curved ratio, value in the range [0.0, 1.0].

NOTES
HISTORY
        06/20/93    T. Wang
*/

static double DPvd_curve_ratio(double ratio, double interval)
{
    double x,y,x1,x2;

    x2 = interval;		/* must > 1 */
    x1 = 1.0/x2;
    
    x = (1.0-ratio)*(x2-x1) + x1;
    y = 1.0 / x - x1;
    y = y / (x2-x1);
    return(y);
}

/*--------------------------------------------------------------------- */
static IGRdouble base_vec[3];
void DPvd_set_tilt_base_vec(struct DPvd_wrk_t *wrk)
{
    /* same way as calculating rubber_vec[] */
    base_vec[0] = wrk->x - wrk->start_x;
    base_vec[1] = -(wrk->y - wrk->start_y);
    base_vec[2] = 0.0;
}


/*----------------------------------------------------------------------
NAME
        zoom_view

DESCRIPTION
        Internal routine to calculate the new gragad for zoom.

SYNOPSIS
        static zoom_view(struct DPgra_gad *orig_gg, 
	                 double *wld_to_view,
			 double *view_to_wld,
			 double *zoom_center_wld,
			 double factor_dist,
			 int planes_try_to_stay,
			 struct DPgra_gad *next_gg)

PARAMETERS

        *orig_gg (IN) - The original gragad structure before zoom.

	*wld_to_view (IN) - wld to view matrix for original gragad.

	*view_to_wld (IN) - view to wld matrix for original gragad.

	*zoom_center_wld (IN) - wld point. Zoom center.

	factor_dist (IN) - For parallel view, it is zoom factor. >1.0 zoom in.
	                   For perspective view, it is distance to move by eye_pt,
			   <0.0 zoom in.

	planes_try_to_stay (IN) - Only for perspective. TRUE: try to make near,
	                          far, act_z planes stay. FALSE: all these planes
				  move with the eye_pt.

	*next_gg (I/O) - When (IN), same copy as orig_gg. When (O), modified
	                 gragad due to zoom. Need DPcal() to sync. 


GLOBALS USED

RETURN VALUES
        TRUE - Sucessful
	FALSE - Failed.
NOTES
HISTORY
        06/20/93    T. Wang
*/


static zoom_view(struct DPgra_gad *orig_gg, 
		 double *wld_to_view,
		 double *view_to_wld,
		 double *zoom_center_wld,
		 double factor_dist,
		 int planes_try_to_stay,
		 struct DPgra_gad *next_gg)

{
    long msg;
    long num_pts;
    double zoom_center_vw[3],tmp_double;
    
    num_pts = 1;
    MAptsxform(&msg,&num_pts,wld_to_view,zoom_center_wld,zoom_center_vw);

    if(!(orig_gg->flags&IS_PERSP))
    {
	IGRdouble vw0,vw1,vw3,vw4,ext;
	
	factor_dist = 1.0/factor_dist;

	vw0 = zoom_center_vw[0] + 
	  (next_gg->vw_volume[0]-zoom_center_vw[0]) * factor_dist;

	vw1 = zoom_center_vw[1] + 
	  (next_gg->vw_volume[1]-zoom_center_vw[1]) * factor_dist;

	vw3 = zoom_center_vw[0] + 
	  (next_gg->vw_volume[3]-zoom_center_vw[0]) * factor_dist;

	vw4 = zoom_center_vw[1] + 
	  (next_gg->vw_volume[4]-zoom_center_vw[1]) * factor_dist;

	/* Don't change view volume if it will be out of range since
	 dp$display() will have problem */
	ext = vw3 - vw0;
	if(ext>DPvd_MAX_VIEWVOL || ext<DPvd_MIN_VIEWVOL) return(TRUE);
	ext = vw4 - vw1;
	if(ext>DPvd_MAX_VIEWVOL || ext<DPvd_MIN_VIEWVOL) return(TRUE);

	next_gg->vw_volume[0] = vw0;
	next_gg->vw_volume[1] = vw1;
	next_gg->vw_volume[3] = vw3;
	next_gg->vw_volume[4] = vw4;
    }
    else /* perspective */
    {
	/* adjust eye and keep the zoom center */
	next_gg->eye_pt[2] = factor_dist;
	tmp_double = factor_dist/zoom_center_vw[2];
	next_gg->eye_pt[0] = tmp_double*zoom_center_vw[0];
	next_gg->eye_pt[1] = tmp_double*zoom_center_vw[1];

	if(planes_try_to_stay)
	{
	    /* active z try to stay */
	    next_gg->act_z = orig_gg->act_z + factor_dist;

	    if(factor_dist > 0.0) 
	    {
		/* eye_pt moves backward, far plane try to stay, near plane 
		   moves with eye_pt */
		next_gg->vw_volume[5] = orig_gg->vw_volume[5] + factor_dist;
	    }
	    else
	    {
		/* eye_pt moves forward, near plane and far plane try to stay */
		next_gg->vw_volume[2] = orig_gg->vw_volume[2] + factor_dist;
		next_gg->vw_volume[5] = orig_gg->vw_volume[5] + factor_dist;
	    }

	    /* adjust to make vaules legal */
	    if(next_gg->vw_volume[2] < DPvd_VIEW_DELTA) 
	      next_gg->vw_volume[2] = DPvd_VIEW_DELTA;
	    if(next_gg->vw_volume[5] < DPvd_VIEW_2DELTA) 
	      next_gg->vw_volume[5] = DPvd_VIEW_2DELTA;
	    if(next_gg->act_z <= next_gg->vw_volume[2] || next_gg->act_z >= next_gg->vw_volume[5] )
	      next_gg->act_z = (next_gg->vw_volume[2]+next_gg->vw_volume[5])/2.0;
	}
	
	/* calculate new coi since eye_pt may pass over it */
	next_gg->coi[0] = next_gg->eye_pt[0];
	next_gg->coi[1] = next_gg->eye_pt[1];
	next_gg->coi[2] = next_gg->eye_pt[2]-next_gg->act_z;
		    
	/* transfer to wld point */
	num_pts = 1;
	MAptsxform(&msg,&num_pts,view_to_wld,next_gg->coi,next_gg->coi);
	MAptsxform(&msg,&num_pts,view_to_wld,next_gg->eye_pt,next_gg->eye_pt);

	/* sync other variables, important! */
	next_gg->vrp[0] = next_gg->coi[0];
	next_gg->vrp[1] = next_gg->coi[1];
	next_gg->vrp[2] = next_gg->coi[2];
    }

    return (TRUE);
}


/*----------------------------------------------------------------------
NAME
        rotate_view

DESCRIPTION
        Internal routine to calculate the gragad for rotation.

SYNOPSIS
        static rotate_view(struct DPgra_gad *orig_gg, 
                           IGRdouble *rot_point_wld,
			   IGRdouble *rot_mx,
			   struct DPgra_gad *new_gg)
PARAMETERS

        *orig_gg (IN) - The original gragad structure before rotation.

        *rot_point_wld (IN) - wld point. After rotation, it will stay at the same 
	                      place on the window.

	*rot_mx (IN) - Rotation matrix (around a vector)

	*new_gg (IN/OUT) - When (IN), same copy as orig_gg. When (O), modified
	                   gragad due to rotation. Need DPcal() to sync. 

GLOBALS USED

RETURN VALUES
        TRUE - Sucessful
	FALSE - Failed.
NOTES
HISTORY
        06/20/93    T. Wang
*/
static rotate_view
  (struct DPgra_gad *orig_gg, 
   IGRdouble *rot_point_wld,
   IGRdouble *rot_mx,
   struct DPgra_gad *new_gg)
{
    IGRlong   msg;
    IGRlong   num_pts;
    IGRdouble tmp_pts[15];
    
    /* Calculate rotation[][] also for perspective view, because it will
       be used to adjust clipping planes */
    {
	tmp_pts[0] = orig_gg->rotation[0][0];
	tmp_pts[1] = orig_gg->rotation[0][1];
	tmp_pts[2] = orig_gg->rotation[0][2];

	tmp_pts[3] = orig_gg->rotation[1][0];
	tmp_pts[4] = orig_gg->rotation[1][1];
	tmp_pts[5] = orig_gg->rotation[1][2];

	tmp_pts[6] = orig_gg->rotation[2][0];
	tmp_pts[7] = orig_gg->rotation[2][1];
	tmp_pts[8] = orig_gg->rotation[2][2];

	tmp_pts[9] = orig_gg->origin[0] - rot_point_wld[0];
	tmp_pts[10] = orig_gg->origin[1] - rot_point_wld[1];
	tmp_pts[11] = orig_gg->origin[2] - rot_point_wld[2];
	
	num_pts = 4;
	MAptsxform(&msg,&num_pts,rot_mx,tmp_pts,tmp_pts);

	new_gg->rotation[0][0] = tmp_pts[0];
	new_gg->rotation[0][1] = tmp_pts[1];
	new_gg->rotation[0][2] = tmp_pts[2];

	new_gg->rotation[1][0] = tmp_pts[3];
	new_gg->rotation[1][1] = tmp_pts[4];
	new_gg->rotation[1][2] = tmp_pts[5];

	new_gg->rotation[2][0] = tmp_pts[6];
	new_gg->rotation[2][1] = tmp_pts[7];
	new_gg->rotation[2][2] = tmp_pts[8];

	new_gg->origin[0] = tmp_pts[9] + rot_point_wld[0];
	new_gg->origin[1] = tmp_pts[10] + rot_point_wld[1];
	new_gg->origin[2] = tmp_pts[11] + rot_point_wld[2];

    }

    if(orig_gg->flags&IS_PERSP)  /* perspective */
    {
	tmp_pts[0] = orig_gg->eye_pt[0] - rot_point_wld[0];
	tmp_pts[1] = orig_gg->eye_pt[1] - rot_point_wld[1];
	tmp_pts[2] = orig_gg->eye_pt[2] - rot_point_wld[2];

	tmp_pts[3] = orig_gg->coi[0] - rot_point_wld[0];
	tmp_pts[4] = orig_gg->coi[1] - rot_point_wld[1];
	tmp_pts[5] = orig_gg->coi[2] - rot_point_wld[2];

	tmp_pts[6] = orig_gg->vup[0];
	tmp_pts[7] = orig_gg->vup[1];
	tmp_pts[8] = orig_gg->vup[2];
	
	num_pts = 3;
	MAptsxform(&msg,&num_pts,rot_mx,tmp_pts,tmp_pts);

	new_gg->eye_pt[0] = tmp_pts[0] + rot_point_wld[0];
	new_gg->eye_pt[1] = tmp_pts[1] + rot_point_wld[1];
	new_gg->eye_pt[2] = tmp_pts[2] + rot_point_wld[2];

	new_gg->coi[0] = tmp_pts[3] + rot_point_wld[0];
	new_gg->coi[1] = tmp_pts[4] + rot_point_wld[1];
	new_gg->coi[2] = tmp_pts[5] + rot_point_wld[2];

	new_gg->vup[0] = tmp_pts[6];
	new_gg->vup[1] = tmp_pts[7];
	new_gg->vup[2] = tmp_pts[8];
	
	/* sync other variables */
	new_gg->vpn[0] = new_gg->coi[0] - new_gg->eye_pt[0];
	new_gg->vpn[1] = new_gg->coi[1] - new_gg->eye_pt[1];
	new_gg->vpn[2] = new_gg->coi[2] - new_gg->eye_pt[2];

	new_gg->vrp[0] = new_gg->coi[0];
	new_gg->vrp[1] = new_gg->coi[1];
	new_gg->vrp[2] = new_gg->coi[2];
    }
    
    return(TRUE);
}

/*----------------------------------------------------------------------
NAME

        scroll_view

DESCRIPTION
        Internal routine to calculate the new gragad for scroll.

SYNOPSIS
        static scroll_view(struct DPgra_gad *orig_gg, 
                           IGRdouble *view_to_wld,
			   IGRdouble dist_x_vw,
			   IGRdouble dist_y_vw,
			   struct DPgra_gad *new_gg)

PARAMETERS

        *orig_gg (IN) - The original gragad structure before scroll.

        *view_to_wld (IN) - view to wld matrix for original gragad.

	dist_x_vw (IN) - distance along X-axis in viewing system.
	dist_y_vw (IN) - distance along Y-axis in viewing system.

	*new_gg (I/O) - When (IN), same copy as orig_gg. When (O), modified
	                gragad due to scroll. Need DPcal() to sync.

GLOBALS USED

RETURN VALUES
        TRUE - Sucessful
	FALSE - Failed.
NOTES
HISTORY
        06/20/93    T. Wang
*/
static scroll_view
  (struct DPgra_gad *orig_gg, 
   IGRdouble *view_to_wld,
   IGRdouble dist_x_vw,
   IGRdouble dist_y_vw,
   struct DPgra_gad *new_gg)
{

    if(!(orig_gg->flags&IS_PERSP))
    {
	new_gg->vw_volume[0] = orig_gg->vw_volume[0] + dist_x_vw;
	new_gg->vw_volume[1] = orig_gg->vw_volume[1] + dist_y_vw;
	new_gg->vw_volume[3] = orig_gg->vw_volume[3] + dist_x_vw;
	new_gg->vw_volume[4] = orig_gg->vw_volume[4] + dist_y_vw;
    }
    else  /* perspective */
    {
	IGRlong msg;
	IGRdouble vector[3];
	IGRlong   num_pts = 1;
	
	vector[0] = dist_x_vw;
	vector[1] = dist_y_vw;
	vector[2] = 0.0;
	MAptsxform(&msg,&num_pts,view_to_wld,vector,vector);

	new_gg->coi[0] = orig_gg->coi[0] + vector[0] - orig_gg->eye_pt[0];
	new_gg->coi[1] = orig_gg->coi[1] + vector[1] - orig_gg->eye_pt[1];
	new_gg->coi[2] = orig_gg->coi[2] + vector[2] - orig_gg->eye_pt[2];
	new_gg->eye_pt[0] = vector[0];
	new_gg->eye_pt[1] = vector[1];
	new_gg->eye_pt[2] = vector[2];
    
	new_gg->vrp[0] = new_gg->coi[0];
	new_gg->vrp[1] = new_gg->coi[1];
	new_gg->vrp[2] = new_gg->coi[2];
    }    
    return(TRUE);
}

     
	
/*----------------------------------------------------------------------
NAME
        DPvd_fit_clipping_planes

DESCRIPTION
        Internal routine to fit the near,far clipping planes around the
	model. 

SYNOPSIS
        static int DPvd_fit_clipping_planes(struct DPvd_wrk_t *wrk)

PARAMETERS
        wrk->new_gg.flags (IN)
        wrk->new_gg.rotation (IN) -- rotation matrix.
	wrk->new_gg.eye_pt(IN)
	wrk->new_gg.origin(IN)
	wrk->dyn_state(IN)
	wrk->limited_zoom(IN)
	wrk->model_center(IN)
	wrk->model_radius(IN)
	wrk->new_gg.vw_volume(IN/OUT)
	wrk->new_gg.act_z(IN/OUT)

GLOBALS USED

RETURN VALUES
        TRUE - Sucessful
	FALSE - Failed.
NOTES
HISTORY
        06/20/93    T. Wang
*/

static int DPvd_fit_clipping_planes(struct DPvd_wrk_t *wrk)
{
    IGRlong msg;
    IGRlong num_pts;
    IGRdouble near_position,far_position;
    IGRdouble vec1[3],trans[4][4];
    IGRshort four = 4;

    /* create a wld_to_view. (Note, rotation[][] is correct now) */
    memcpy((IGRchar *)wrk->new_gg.wld_to_view,
	   (IGRchar *)wrk->new_gg.rotation,16*(sizeof (IGRdouble)));

    MAidmx(&msg,(IGRdouble *)trans);
    if(wrk->new_gg.flags & IS_PERSP)
    {
	trans[0][3] = -wrk->new_gg.eye_pt[0];
	trans[1][3] = -wrk->new_gg.eye_pt[1];
	trans[2][3] = -wrk->new_gg.eye_pt[2];
    }
    else
    {
	trans[0][3] = -wrk->new_gg.origin[0];
	trans[1][3] = -wrk->new_gg.origin[1];
	trans[2][3] = -wrk->new_gg.origin[2];
    }
    MAmulmx(&msg,&four,&four,&four,(IGRdouble*)wrk->new_gg.rotation,
		(IGRdouble *)trans, (IGRdouble *)wrk->new_gg.wld_to_view);
    
    /* Calculate ideal near,far clipping planes positions */
    num_pts = 1;
    MAptsxform(&msg,&num_pts,(IGRdouble *)wrk->new_gg.wld_to_view,wrk->model_center,vec1);
    near_position = vec1[2] + wrk->model_radius;
    far_position  = vec1[2] - wrk->model_radius;
    
    /* Adjust new_gg's near,far plane */
    if(wrk->new_gg.flags & IS_PERSP)
    {
	/* Make near_position and far_position in front of eye, and positive */
	if(near_position > -DPvd_VIEW_DELTA) 
	  near_position = -DPvd_VIEW_DELTA;
	else
	  near_position = -near_position;
	  
	if(far_position > -DPvd_VIEW_2DELTA) 
	  far_position = DPvd_VIEW_2DELTA;
	else 
	  far_position = -far_position;

	/* change to the idel position */
	wrk->new_gg.vw_volume[2] = near_position;
	wrk->new_gg.vw_volume[5] = far_position;
	
	/* For all commands other than "unlimited perspective zoom",
	   adjust near, far plane to be outside act_z, so that the act_z
	   will not moved */ 
	if(!(wrk->dyn_state==SCALE_STATE && wrk->limited_zoom==FALSE))
	{
	    if(wrk->new_gg.vw_volume[2] >= wrk->new_gg.act_z)
	      wrk->new_gg.vw_volume[2] = wrk->new_gg.act_z - DPvd_VIEW_DELTA;
	    if(wrk->new_gg.vw_volume[5] <= wrk->new_gg.act_z)
	      wrk->new_gg.vw_volume[5] = wrk->new_gg.act_z + DPvd_VIEW_DELTA;
	}

	/* make near, far plane in front of eye (not behind eye) */
	if(wrk->new_gg.vw_volume[2]<DPvd_VIEW_DELTA) 
	  wrk->new_gg.vw_volume[2] = DPvd_VIEW_DELTA;
	if(wrk->new_gg.vw_volume[5]<DPvd_VIEW_2DELTA) 
	  wrk->new_gg.vw_volume[5] = DPvd_VIEW_2DELTA;

	/* if act_z is outside view volume, or command is "unlimited 
	   perspective zoom", put act_z in the middle of view volume */
	if(wrk->new_gg.vw_volume[2] >= wrk->new_gg.act_z ||
	   wrk->new_gg.vw_volume[5] <= wrk->new_gg.act_z ||
	   (wrk->dyn_state==SCALE_STATE && wrk->limited_zoom==FALSE))
	{
	    wrk->new_gg.act_z = 
	      ( wrk->new_gg.vw_volume[2]+wrk->new_gg.vw_volume[5])/2.0;
	}
    }
    else /* parallel */
    {
	wrk->new_gg.vw_volume[5] = near_position;
	wrk->new_gg.vw_volume[2] = far_position;

	/* adjust near, far plane to be outside act_z, so that the act_z
	 will not moved */ 
        if(wrk->new_gg.vw_volume[5] <= wrk->new_gg.act_z)
	  wrk->new_gg.vw_volume[5] = wrk->new_gg.act_z + DPvd_VIEW_DELTA;
        if(wrk->new_gg.vw_volume[2] >= wrk->new_gg.act_z)
	  wrk->new_gg.vw_volume[2] = wrk->new_gg.act_z - DPvd_VIEW_DELTA;
    }

    return(TRUE);
}
	


/*----------------------------------------------------------------------
NAME
      DPvd_change_view

DESCRIPTION
      According to the parameters set change the gragad of
      the specified window.

SYNOPSIS
      extern int DPvd_change_view(struct DPvd_wrk_t *wrk)

PARAMETERS
      wrk(IN/OUT)                 - structure containing all info                        
      wrk->dyn_state              - ROTATE_STATE,TRANSL_STATE,SCALE_STATE
      wrk->wld_to_view            - wld to view matrix for original gragad.
      wrk->view_to_wld            - view to wld matrix for original gragad.
      wrk->wld_ref_point    
      wrk->rotation_axis    
      wrk->start_x                - start point of the modification
      wrk->start_y 
      wrk->x                      - current point of the modification
      wrk->y 
      wrk->orig_gg                - The original gragad structure before modif..
      wrk->new_gg                 - The new gragad structure after modification

      wrk->model_center    
      wrk->model_radius

      wrk->selected_axis          - axis selected for rotation
      wrk->rubber_tolerance       - tolerance where rubber band starts
      wrk->new_orig_same(OUT)     - TRUE if no change
      wrk->curr_gn_mode(IN)       - TRACKING,STEP, CONTINOUS mode

      wrk->element_tangent_vw(IN) - tangent vector for rotation about element.

      wrk->step_value(OUT)        - step value for STEP_mode
      wrk->limited_zoom 

GLOBALS USED

RETURN VALUES
        TRUE - Sucessful
	FALSE - Failed.
NOTES
HISTORY
        06/20/93    T. Wang
*/

int DPvd_change_view(struct DPvd_actwin *actwin,struct DPvd_wrk_t *wrk)
{
    IGRlong msg;
    IGRdouble ratio,factor,angle;
    IGRdouble win_width, win_height;
    IGRdouble rubber_length,rubber_vec[3];
    IGRdouble vec1[3],vec2[3], tmp_double;
    IGRlong   num_pts;

    memcpy((char*)&wrk->new_gg,(char*)&wrk->orig_gg,sizeof(struct DPgra_gad));
    wrk->new_orig_same = TRUE;

    win_width = wrk->orig_gg.dit_clip_range[3] - wrk->orig_gg.dit_clip_range[0];
    win_height = wrk->orig_gg.dit_clip_range[4] - wrk->orig_gg.dit_clip_range[1];

    /* vector of rubber band on the screen, (viewing system) */
    rubber_vec[0] = wrk->x - wrk->start_x;
    rubber_vec[1] = -(wrk->y - wrk->start_y);
    rubber_vec[2] = 0.0;

    if(wrk->x==wrk->start_x && wrk->y==wrk->start_y)
    {
	rubber_length = 0.0;
	goto wrapup;
    }
    else
    {
	tmp_double = rubber_vec[0]*rubber_vec[0]+rubber_vec[1]*rubber_vec[1];
	rubber_length = (IGRdouble) MAsqrt(&msg,&tmp_double);
    }
    
    switch(wrk->dyn_state)
    {
      case ROTATE_STATE:
	
	if(rubber_length > wrk->rubber_tolerance)
	{
	    /* Rubber length outside tolerance will clear any align state */
	    DPvd_set_GN_align_state(0);

	    /* Calculate ratio */

	    ratio = 2.0 * (rubber_length-wrk->rubber_tolerance) / (IGRdouble)win_width;
	    ratio = (ratio>1.0)?1.0:ratio;
	
	    /* Adjust ratio so that it is not linear */
	    ratio = DPvd_curve_ratio(ratio,2.5);
	    angle = 4.0 * PI * ratio; 
	}
	else
	  angle = 0.0;
	
	if(wrk->selected_axis == DPvd_GN_XAXIS)
	{
	    if(wrk->y > wrk->start_y) angle = -angle;
	}
	else if(wrk->selected_axis == DPvd_GN_YAXIS)
	{
	    if(wrk->x > wrk->start_x) angle = -angle;
	}
	else if(wrk->selected_axis == DPvd_GN_ZAXIS)
	{
	    if(rubber_length > wrk->rubber_tolerance)
	    {
		tmp_double = MAang2vc(&msg,rubber_vec,base_vec,vec2);
		angle = vec2[0];
		
		if(angle > PI) angle = -(2.0*PI - angle);
	    }
	    else
	    {
		angle = 0.0;
	    }
	}
	else if(wrk->selected_axis == DPvd_GN_CENTER)
	{
	    /* change rotation_axis to be the Product of 
	       (rubber_vec X into_screen_vec) */

	    vec1[0] = -rubber_vec[1];
	    vec1[1] = rubber_vec[0];
	    vec1[2] = 0.0;
	    num_pts = 1;

	    MAptsxform(&msg,&num_pts,(IGRdouble*)wrk->view_to_wld,vec1,vec1);

	    wrk->rotation_axis[0] = vec1[0] - wrk->view_to_wld[3];
	    wrk->rotation_axis[1] = vec1[1] - wrk->view_to_wld[7];
	    wrk->rotation_axis[2] = vec1[2] - wrk->view_to_wld[11];

	    /* Make free rotation direction consistent with that of axis */
	    angle = -angle;
	}

	else if(wrk->selected_axis == DPvd_GN_ELEMENT)
	{
	    /* perpendicular vector */
	    vec1[0] = -wrk->element_tangent_vw[1];
	    vec1[1] = wrk->element_tangent_vw[0];

	    /* dot product */
	    tmp_double = vec1[0]*rubber_vec[0]+vec1[1]*rubber_vec[1];
	    
	    /* which side is rubber line */
	    if(tmp_double < 0.0) angle = -angle;
	}
	else 
	  goto wrapup;		/* something wrong */
    

        if(wrk->curr_gn_mode == DPvd_STEP)
	{
	    int k; /* degree of abs(angle) */
	    
	    /* For step mode, adjust the angle to be 
	       exactly the number we want to display on rubber band. */

	    if(angle>0.0)  k = angle * 180.0 / PI + 0.5;
	    else  k = (-angle * 180.0 / PI) + 0.5;

	    if(k>5) k = (k/5)*5; /* steps of 5 when angle > 5 */
	    k = k % 360;

	    if(angle < 0.0)  angle = -k * PI / 180.0;
	    else angle = k * PI / 180.0;
	    
	    if(wrk->selected_axis == DPvd_GN_ZAXIS)
	    {
		/* When display step angle, make counter clockwise positive,
		   and clockwise negative */
		if(angle < 0.0) wrk->step_value = k;
		else wrk->step_value = -k;
	    }
	    else
	    {
		/* always display positive numbers */
		wrk->step_value = k;
	    }
	}
	else if(wrk->curr_gn_mode == DPvd_CONT)
	{
	    /* For continues mode, it doesn't make sense to rotate 360 degree
	       in each step, since the object seems not rotating. So we only
	       allow a maximum of 180 degree. Also make it slower */
	    angle /= 4.0;
	    if(angle > PI || angle < -PI) angle = PI;
	}
	
	if(angle != 0.0)
	{
	    IGRdouble rot_mx[16];
	    MArotmx(&msg,wrk->rotation_axis,&angle,rot_mx);
	    rotate_view(&wrk->orig_gg, 
			wrk->wld_ref_point,
			rot_mx,
			&wrk->new_gg);
	    wrk->new_orig_same = FALSE;
	}
	
	break;


     case TRANSL_STATE:
	
	if(wrk->x!=wrk->start_x || wrk->y!=wrk->start_y)
	{
	    if(wrk->new_gg.flags & IS_PERSP)
	    {
		angle = wrk->orig_gg.vw_angle/2.0;
		num_pts = 1;
		MAptsxform(&msg,&num_pts,wrk->wld_to_view,wrk->wld_ref_point,vec1);
		MAsincos(&msg,&angle,&tmp_double,&factor);
		tmp_double = tmp_double / factor;
		if(win_width < win_height)
		  tmp_double = -(tmp_double*vec1[2])*2.0 / win_width;
		else
		  tmp_double = -(tmp_double*vec1[2])*2.0 / win_height;
	    }
	    else
	    {
		tmp_double = 1.0 / wrk->orig_gg.vvol_viewport_scale;
	    }
	    
	    if(wrk->curr_gn_mode == DPvd_STEP) 
	    {
		int distx, disty;
		distx = (wrk->start_x-wrk->x);
		disty = (wrk->start_y-wrk->y);
		if(distx < 0) distx = -distx;
		if(disty < 0) disty = -disty;
		/* do some scrolling only, at least 3 pixels depart */
		if( (distx>disty ? distx:disty) > 3 )
		{
		   double d1,d2;
		   d1 = (wrk->start_x-wrk->x)*tmp_double;
		   d2 = (wrk->start_y-wrk->y)*tmp_double;
		   tmp_double = d1*d1 + d2*d2;
		   wrk->step_value = (IGRdouble) MAsqrt(&msg,&tmp_double);
	           scroll_view(&wrk->orig_gg,
		       wrk->view_to_wld, d1, -d2,
		       &wrk->new_gg);
	           wrk->new_orig_same = FALSE;
		}
		else
		{
		   wrk->step_value = (IGRdouble) 0.0;
	           wrk->new_orig_same = TRUE;
		}
	    }
	    else
	    {
	        scroll_view(&wrk->orig_gg,
		       wrk->view_to_wld,
		       (IGRdouble)(wrk->start_x-wrk->x)*tmp_double,
		       (IGRdouble)(wrk->y-wrk->start_y)*tmp_double,
		       &wrk->new_gg);
	        wrk->new_orig_same = FALSE;
	    }
	}

	break;


      case SCALE_STATE:

	if(wrk->x!=wrk->start_x || wrk->y!=wrk->start_y)
	{
	    ratio = 2.0 * rubber_length / (IGRdouble)win_width;
	    ratio = (ratio>1.0)?1.0:ratio;

	    /* Adjust ratio so that it is not linear */
	    ratio = DPvd_curve_ratio(ratio,3.0);
	    
	    /* Calculate a zoom factor within range:
	       [1.0/DPvd_MAX_ZOOM_FACTOR,DPvd_MAX_ZOOM_FACTOR ].
	       This factor is used for drag mode */

	    if( wrk->y < wrk->start_y ) /* zoom out */
	    {
		factor = 1.0 / (1.0 + ratio * DPvd_MAX_ZOOM_FACTOR);
		tmp_double = 1.0/DPvd_MAX_ZOOM_FACTOR;
		if(factor<tmp_double) factor = tmp_double;
	    }
	    else if( wrk->y > wrk->start_y ) /* zoom in */
	    {		
		factor = 1.0 + ratio * DPvd_MAX_ZOOM_FACTOR;
		if(factor>DPvd_MAX_ZOOM_FACTOR)factor=DPvd_MAX_ZOOM_FACTOR;
	    }
	    else  /*  y == start_y */
	    {
		factor = 1.0;
	    }

	    if(wrk->curr_gn_mode == DPvd_STEP && 
	       !(wrk->orig_gg.flags&IS_PERSP && !wrk->limited_zoom)) 
	    {
		/* For step mode in parallel view , adjust the factor to be 
		   exactly the number we want to display on rubber band. */

		if(factor>1.0)  /* zoom in */
		{
		    if(factor<10.0) factor=(int)factor;
		    else factor = ((int)(factor/5.0))*5.0;
		    wrk->step_value = factor;
		}
		else if(factor<1.0)
		{
		    tmp_double = 1.0/factor;
		    if(tmp_double<10.0) tmp_double=(int)tmp_double;
		    else tmp_double = ((int)(tmp_double/5.0))*5.0;

		    wrk->step_value = -tmp_double;
		    factor = 1.0/tmp_double;
		}
		else
		{
		    wrk->step_value = factor;
		}
	    }

	    else if(wrk->curr_gn_mode == DPvd_CONT)
	    {
		/* For continuous mode, reduce the factor, making it slower */
		if(factor>1.0) factor = 1.0 + (factor-1.0) * 0.01;
		else if(factor<1.0) 
		{
		    tmp_double = 1.0 / factor;
		    tmp_double = 1.0 + (tmp_double-1.0) * 0.01;
		    factor = 1.0 / tmp_double;
		}
	    }
	    
	    /* Change gragad */

	    if(!(wrk->orig_gg.flags&IS_PERSP))
	    {
		if(factor > 1.0)
		{

		    /* If the view volume is already tiny, don't zoom in any more. Since
		       this will make view volume zero and destroy window data */
		    if(wrk->orig_gg.vw_volume[3]-wrk->orig_gg.vw_volume[0] < DPvd_MIN_VIEWVOL ||
		       wrk->orig_gg.vw_volume[4]-wrk->orig_gg.vw_volume[1] < DPvd_MIN_VIEWVOL)
		    {
			factor = 1.0;
			wrk->step_value = 1.0;
		    }
		}
		else if(factor < 1.0)
		{
		    /* Put a guard on very huge view volume */
		    if(wrk->orig_gg.vw_volume[3]-wrk->orig_gg.vw_volume[0] > 
DPvd_MAX_VIEWVOL ||
		       wrk->orig_gg.vw_volume[4]-wrk->orig_gg.vw_volume[1] > DPvd_MAX_VIEWVOL)
		    {
			factor = 1.0;
			wrk->step_value = 1.0;
		    }
		}

		if(factor != 1.0)
		{
		    zoom_view(&wrk->orig_gg, 
			      wrk->wld_to_view,
			      wrk->view_to_wld,
			      wrk->wld_ref_point,
			      factor,
			      0,	/* not used */
			      &wrk->new_gg);
		    wrk->new_orig_same = FALSE;
		}
	    }
	    else  /* perspective */
	    {
		double eye_move_dist;
		
		if(wrk->limited_zoom==TRUE)
		{
		    /* with respect to the wld_ref_point plane */

		    num_pts = 1;
		    MAptsxform(&msg,&num_pts,wrk->wld_to_view,
			       wrk->wld_ref_point,vec1);

		    if(factor > 1.0) /* zoom_in */
		    {
			/* eye_move_dist = wrk->orig_gg.act_z*(1.0 - 1.0/factor); */
			eye_move_dist = -vec1[2] * (1.0-1.0/factor);

			/* eye_pt at least (1.5*DPvd_VIEW_DELTA) away from
			   act_z, so that act_z will not be pushed away 
			tmp_double = wrk->orig_gg.act_z-DPvd_VIEW_DELTA*1.5;
			if(eye_move_dist > tmp_double)
			  eye_move_dist = tmp_double;
			*/

			/* eye_pt should be at least (1.5*DPvd_VIEW_DELTA) away from the
			   wld_ref_point plane, because the nearest clipping plane
			   distance is DPvd_VIEW_DELTA */
			tmp_double = (-vec1[2])-DPvd_VIEW_DELTA*1.5; /* max dist eye_pt can move */
			if(eye_move_dist > tmp_double)
			{
			    /* For step mode, re-adjust the step_value to reflect the real zoom
			       factor */
			    if(wrk->curr_gn_mode == DPvd_STEP)
			    {
				wrk->step_value *= (tmp_double/eye_move_dist);
				if(wrk->step_value<1.0) wrk->step_value=1.0;
			    }
			}
			
			eye_move_dist = -eye_move_dist;
		    }
		    else /* zoom out */
		    {
			/* eye_move_dist = wrk->orig_gg.act_z*(1.0/factor - 1.0); */
			eye_move_dist = -vec1[2] * (1.0/factor - 1.0);
		    }
		}
		else /* unlimited zoom */
		{
		    /* If eye_pt is inside model range, let eye_move_dist be a
		       function of model range. Otherwise, let eye_move_dist be a
		       function of the distance from the eye to the model's far edge */

		    /* get model_radius if not got yet */
		    if(wrk->get_model_size_by_fit && !wrk->got_fitted_size)
		    {
			IGRdouble rng[6];
			DPvd_fit_model_range(&actwin->grid, &wrk->new_gg, actwin->win_no, rng);
			DPvd_get_rng_radius_center(rng,&(wrk->model_radius),wrk->model_center);
			wrk->got_fitted_size = TRUE;
		    }

		    num_pts = 1;
		    MAptsxform(&msg,&num_pts,wrk->wld_to_view,wrk->model_center,vec1);
		    if(vec1[2]<0.0) vec1[2]= -vec1[2];
		    if(vec1[2] < wrk->model_radius) /* eye within model space */
		    {
			eye_move_dist = wrk->model_radius * 2.0 * ratio;
		    }
		    else  /* eye outside model size */
		    {
			eye_move_dist = (vec1[2]+wrk->model_radius) * ratio ;
		    }
		    
		    if(wrk->y > wrk->start_y ) /* zoom in */
		      eye_move_dist = -eye_move_dist;   /* negative direc move */
		}

		/* change eye_pt position and others */
		if(eye_move_dist != 0.0)
		{
		    zoom_view(&wrk->orig_gg, 
			      wrk->wld_to_view,
			      wrk->view_to_wld,
			      wrk->wld_ref_point,
			      eye_move_dist,
			      wrk->limited_zoom,
			      &wrk->new_gg);
		    wrk->new_orig_same = FALSE;
		}
		
		/* For walk through zoom, can only display distance */
		if(wrk->curr_gn_mode == DPvd_STEP && !wrk->limited_zoom) 
		{
		    wrk->step_value = -eye_move_dist;
		}
	    }
	}

	break;

      default:
	fprintf(stderr,"Error: invalid dynamic state\n");
    }


    /* If pan operation or paralell view zoom, don't fit clipping plane.
       For other operations, if view has been changed, fit the clipping planes.
       See ems CR119415323 */
    
    if((wrk->new_orig_same == TRUE) || /* view not changed */
       (wrk->dyn_state == TRANSL_STATE) ||
       (!(wrk->new_gg.flags & IS_PERSP) && (wrk->dyn_state == SCALE_STATE)))
    {
	/* don't change clipping planes */
    }
    else
    {
	/* get model_size if it is not ready yet */
	if(wrk->get_model_size_by_fit && !wrk->got_fitted_size)
	{
	    IGRdouble rng[6];
	    DPvd_fit_model_range(&actwin->grid, &wrk->new_gg, actwin->win_no, rng);
	    DPvd_get_rng_radius_center(rng,&(wrk->model_radius),wrk->model_center);
	    wrk->got_fitted_size = TRUE;
	}
	
	DPvd_fit_clipping_planes(wrk);
    }

  wrapup:
    
    return TRUE;
}



/*----------------------------------------------------------------------
NAME
        DPvd_align_view

DESCRIPTION
        Align the specified view along a given axis

SYNOPSIS
        extern int DPvd_align_view(struct DPvd_wrk_t *wrk)

PARAMETERS
        wrk                  - structure containing all information

GLOBALS USED

RETURN VALUES
        TRUE - Sucessful
	FALSE - Failed.
NOTES
HISTORY
        06/20/93    T. Wang
*/

int DPvd_align_view(struct DPvd_actwin *actwin, struct DPvd_wrk_t *wrk)
{
    IGRlong msg;
    IGRdouble rot_mx[16], rot_mx2[16],rot_mx3[16];
    IGRdouble vec[3];
    IGRint  align_axis;
    IGRshort four=4;
    IGRlong num_pts=1;

    memcpy((char*)&wrk->new_gg,(char*)&wrk->orig_gg,sizeof(struct DPgra_gad));

    /* Get rotation matrix to rotate in viewing system.
       Note, I change the direction of vec[] to avoid doing MAinvmx().
       */
    MAptsxform(&msg,&num_pts,(IGRdouble*)wrk->orig_gg.rotation,
	       wrk->rotation_axis, vec);
    align_axis = DPvd_get_GN_align_state();
    if(align_axis == DPvd_GN_XAXIS)
    {
	vec[1] = -vec[1];
	vec[2] = -vec[2];
	MAxrotmx(&msg,vec,rot_mx);
    }
    else if(align_axis == DPvd_GN_YAXIS)
    {
	vec[0] = -vec[0];
	vec[2] = -vec[2];
	MAyrotmx(&msg,vec,rot_mx);
    }
    else if(align_axis == DPvd_GN_ZAXIS)
    {
	vec[0] = -vec[0];
	vec[1] = -vec[1];
	MAzrotmx(&msg,vec,rot_mx);
    }
    else
      return(FALSE);

    MAmulmx(&msg,&four,&four,&four,rot_mx,(IGRdouble*)wrk->orig_gg.rotation,rot_mx2);
    MAtrnmx(&msg,&four,(IGRdouble*)wrk->orig_gg.rotation,rot_mx3);
    MAmulmx(&msg,&four,&four,&four,rot_mx3,rot_mx2,rot_mx);

    /* Rotate the viewing coordinate system */
    rotate_view(&wrk->orig_gg, 
		wrk->wld_ref_point,
		rot_mx,
		&wrk->new_gg);

    /*	if(need_fit_clipping_plane) */

    if(wrk->get_model_size_by_fit && !wrk->got_fitted_size)
    {
	IGRdouble rng[6];
	DPvd_fit_model_range(&(actwin->grid), &wrk->new_gg, actwin->win_no, rng);
	DPvd_get_rng_radius_center(rng,&(wrk->model_radius),wrk->model_center);
	wrk->got_fitted_size = TRUE;
    }
	
    DPvd_fit_clipping_planes(wrk);

    return(TRUE);
}


end implementation DPvd;
