
/* 10/17/91 --- The "perspective view && keep view angle unchange" case is
		re-written by T.W. */



class implementation IGEgragad;

#include <math.h>
#include <stdio.h>

#include "grimport.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "madef.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igewindef.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "igr.h"
#include "igrdp.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"
#include "dpstruct.h" 
#include "dpcodef.h"
#include "dpcomacros.h"

/* prototype files */
%safe
#include "DPwnareaf.h"
#include "DPcodpbi.h"
#include "dpgetrng.h"
#include "dpsetrng.h"

#include "mainvmx.h"
#include "maidmx.h"
#include "maptsxfor.h"
#include "mamulmx.h"
%endsafe


#define DISPLAY_DELTA	.001
/*#define DISPLAY_DELTA		1.0  */


method DPwnarea (IGRlong *msg; IGRint in_flags; IGRdouble *wld_points;
	IGRboolean update)
{
IGRlong num_points = 2;
IGRlong vol_msg = MSSUCC; /* this is needed to preserve any view volume 
			     messages such as (maximum window - DPDGNLIMIT) */
IGRboolean  update_all = FALSE;
IGRdouble ex_pnts[6];
IGRdouble trans[4][4];
IGRdouble wld_to_view[4][4];
IGRdouble view_to_wld[4][4];
IGRshort four=4;

struct DPrange_check range_chk;
extern 	  IGRdouble tan( double );

IGRint status = OM_S_SUCCESS;

#ifndef IDRAW
	IGRushort pflag;

	IGRdouble center_pnt[3];
	struct DPgra_gad *p_gg;
	IGRdouble vw_coi[3];
	IGRdouble vw_eye[3];

	IGRdouble vw_points[6];
	IGRdouble ext_x,ext_y,ext,win_ext_x,win_ext_y;
	IGRdouble pnear,pfar,tmp_double,dist_eye_coi;

*msg = MSSUCC;
p_gg=&ME.IGEgragad->gragad;

if ((ME.IGEgragad->gragad.flags & IS_PERSP))
{
	num_points = 1;

    if (!MAidmx(msg, (IGRdouble *)trans))
    {
    	goto fini;
    }
    trans[0][3] = -ME.IGEgragad->gragad.eye_pt[0];
    trans[1][3] = -ME.IGEgragad->gragad.eye_pt[1];
    trans[2][3] = -ME.IGEgragad->gragad.eye_pt[2];

	
    dp$codpb_get_persp_flags( persp_flags= &pflag );

    if ( ! (pflag & PERSP_CHANGE_ANGLE) )
    {
       /*
	*  perspective angle not changed case
	*/

    	MAmulmx(msg, &four, &four, &four, (IGRdouble *)p_gg->rotation,
			(IGRdouble *)trans, (IGRdouble *)wld_to_view);
    	MAinvmx(msg, &four, (IGRdouble *)wld_to_view, (IGRdouble *)view_to_wld);

	/* the two wld points in viewing system */

	num_points = 2;
    	MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view, wld_points,
			vw_points);

	/* center point */

	center_pnt[0]=(wld_points[0]+wld_points[3])/2.0;
	center_pnt[1]=(wld_points[1]+wld_points[4])/2.0;
	center_pnt[2]=(wld_points[2]+wld_points[5])/2.0;
        

	/* put new coi at the center_pnt */

	OM_BLOCK_MOVE(center_pnt,p_gg->coi,(sizeof(IGRdouble)*3));

	/* new vw_coi[] */

	num_points = 1;
    	MAptsxform(msg,&num_points,(IGRdouble *)wld_to_view,p_gg->coi,vw_coi);

	/* move eye parallell so that the direction of view vector not changed */

	vw_eye[0] = vw_coi[0];
	vw_eye[1] = vw_coi[1];

	/*
	 * determine vw_eye[2] so that the size of the object is what
	 * we wanted 
	 */

	/* the extent of the two wld points in viewing coord. system */

	ext_x = vw_points[0] - vw_points[3];
	ext_y = vw_points[1] - vw_points[4];
	ext_x = (ext_x < 0.0) ? -ext_x : ext_x;
	ext_y = (ext_y < 0.0) ? -ext_y : ext_y;

	/* window shape */

	win_ext_x = (IGRdouble)(me->max_x_dep-me->min_x_dep);
	win_ext_y = (IGRdouble)(me->max_y_dep-me->min_y_dep);

	/* when eye at any position such that the image plane is (ext_x,ext_y)
	   we need to expand ext_x,ext_y to fit the shape of window. The side
	   which reach the window first	should dominant. So the smaller ratio
	   of win:ext_? will be used to determine the eye 
	*/

	if(ext_x == 0.0)
	{
	   ext = ext_y;
	}
	else if(ext_y == 0.0)
	{
	   ext = ext_x;
	}
	else
	{
	   if(  (win_ext_x/ext_x) < (win_ext_y/ext_y) )
	 	ext = ext_x;
	   else
		ext = ext_y;
	}

	/* calculate vw_eye[2] position */

	dist_eye_coi = ext / ( tan((p_gg->vw_angle/2.0)) * 2.0) ;
	dist_eye_coi = (dist_eye_coi<DISPLAY_DELTA)?DISPLAY_DELTA:dist_eye_coi;

	vw_eye[2] = vw_coi[2] + dist_eye_coi;  /* vw_eye[2] is always greater than vw_coi[2] */

	/* get new wld eye and coi */

	num_points = 1;
    	MAptsxform(msg, &num_points, (IGRdouble *)view_to_wld, vw_coi,
			p_gg->coi);
    	MAptsxform(msg, &num_points, (IGRdouble *)view_to_wld, vw_eye,
			p_gg->eye_pt);

	/*------------------------------------------------------------------*/
	/* Now eye and coi are set up. I need to make act_z at coi. 	    */
	/* Also we want to make the vw_volume contain the box determined by */
	/* the two wld points.  If it already contains the box, we do 	    */
	/* nothing. Otherwise, we adjust the vw_volume. 		    */
	/*------------------------------------------------------------------*/

	/* new act_z */

	p_gg->act_z = dist_eye_coi;

	/* 
	 * new vw_volume 
	 */

	/* make vw_points[2] >= vw_points[5] first */

	if(vw_points[2] < vw_points[5] )
	{
	    tmp_double = vw_points[2];
	    vw_points[2] = vw_points[5];
	    vw_points[5] = tmp_double;
	}

	/* the smallest volume containing the box */

	pnear = dist_eye_coi - (vw_points[2] - vw_coi[2]);
	pfar  = dist_eye_coi + (vw_coi[2] - vw_points[5]);
	if(pnear < DISPLAY_DELTA) pnear = DISPLAY_DELTA;

	/* adjust vw_volume if needed */

	p_gg->vw_volume[2]=(p_gg->vw_volume[2]>pnear)?pnear:p_gg->vw_volume[2]; 
	p_gg->vw_volume[5]=(p_gg->vw_volume[5]<pfar)?pfar:p_gg->vw_volume[5]; 

	/* end perspective and same view angle	*/
    }
    else
    {
       if(!MAmulmx(msg, &four, &four, &four, (IGRdouble *)ME.IGEgragad->gragad.rotation,
			(IGRdouble *)trans, (IGRdouble *)wld_to_view))
       {
   	 goto fini;
       }
	DPperwnarea(msg, 0, wld_points, ME.IGEgragad->gragad.coi,
		(IGRdouble *)wld_to_view, &ME.IGEgragad->gragad.vw_angle,
		ME.IGEgragad->gragad.eye_pt, ME.IGEgragad->gragad.coi);
    }
}
else
#endif
{  
    num_points = 2;
    if (!MAptsxform(msg, &num_points, (IGRdouble *)ME.IGEgragad->gragad.wld_to_view,
			wld_points, ex_pnts ))
    {
#ifdef DEBUG
        printf("\nDPscroll ptsxform\n");
#endif
        goto fini;
    }
    if (num_points == 1)
    {
    	DPsetrng(msg,(IGRdouble *)ME.IGEgragad->gragad.wld_to_view,&range_chk);
    	DPgetrng(msg,(IGRdouble *)ME.IGEgragad->gragad.wld_to_view,&range_chk,
			wld_points, ex_pnts);
    }
                ME.IGEgragad->gragad.vw_volume[0] = ex_pnts[0];
                ME.IGEgragad->gragad.vw_volume[3] = ex_pnts[3];
                ME.IGEgragad->gragad.vw_volume[1] = ex_pnts[1];
                ME.IGEgragad->gragad.vw_volume[4] = ex_pnts[4];
}






    status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPcal(&vol_msg),
                             senderid = my_id,
                             targetid = my_id);
	    if ( ! (1 & status) )
            {
#ifdef DEBUG
                printf("\nIN DPscroll Error send to window DPcal\n");
                om$report_error(sts = status);
#endif
                goto fini;	  
            } 


    if (update)
    {
	       if (!(ME.IGEgragad->gragad.flags & DP_DELAY))
	       {
	          status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPupdate(msg,NULL,
						&update_all),
                             senderid = my_id,
                             targetid = my_id);

	      	   if ( ! (1 & status) )
            	   {
#ifdef DEBUG
                	printf("\nIN DPscroll Error send to window DPupdate\n");
                	om$report_error(sts = status);
#endif
                	goto fini;	  
            	    } 
	        }
		else
		{
		   ex$message( msgnumb = GR_I_DlyOn);
		}

    }
    if(*msg == MSSUCC)
    {
	    *msg = vol_msg;
    }
fini:

	return(status);
}

end implementation IGEgragad;

