#include <stdio.h>
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dperr.h"
#include "dpdef.h"
#include "godef.h"
#include "msdef.h"
#include "OMmacros.h"

/* prototype files */
#include "dppresetvvol.h"
#include "dpgetrng.h"
#include "dpsetrng.h"

#include "maidmx.h"
#include "mainvmx.h"
#include "madabs.h"
#include "mamulmx.h"
#include "maptsxfor.h"


#define VOLSMALL 1.0e-13

IGRboolean DPpresetvvol (msg,vw_vol,min_x_vwport,max_x_vwport,min_y_vwport,max_y_vwport,wld_to_view_mtx)

IGRlong *msg;
IGRdouble *vw_vol;
IGRint min_x_vwport;
IGRint max_x_vwport;
IGRint min_y_vwport;
IGRint max_y_vwport;
IGRdouble *wld_to_view_mtx;

{
	IGRdouble vw_vol_ext_x;
	IGRdouble vw_vol_ext_y;
	IGRdouble vw_vol_ext_z;	
	IGRdouble ext_x;
	IGRdouble ext_y;
	IGRdouble ext_z;
	IGRdouble x_vwport;
	IGRdouble y_vwport;
	IGRdouble x_ratio;
	IGRdouble y_ratio;
	IGRdouble new_x_vwvol_ext;
	IGRdouble new_y_vwvol_ext;
	IGRdouble temp;
	IGRdouble DGNlimit;
	IGRdouble limit_vol[6];	
	IGRdouble vw_limit[6];		
	IGRdouble limit_ext[3];
	IGRdouble scale_mtx[4][4];
	IGRdouble trans[4][4];	
	IGRdouble result[4][4];		
	IGRdouble extra_mtx[4][4];			
	IGRdouble ex_mtx[4][4];	
	IGRdouble wld_to_view[4][4];	
	IGRdouble view_to_wld[4][4];
	IGRdouble scaling[2];
	IGRdouble wld_vol[6];
	IGRdouble temp_vol[6];	
	IGRdouble ex_vol[6];	
	IGRdouble wld_range[6];	
	IGRdouble  vw_vol_small;
	IGRlong num_pts = 2;
	IGRlong scale_msg;
	IGRlong trans_msg;	
	IGRint status;
	struct DPrange_check range_chk;	
	IGRshort four = 4;
	IGRboolean x_min = FALSE;
	IGRboolean y_min = FALSE;


	trans_msg = MSSUCC;
	scale_msg = MSSUCC;
	*msg = MSSUCC;
	status = TRUE;

	OM_BLOCK_MOVE (wld_to_view_mtx, wld_to_view, (sizeof(IGRdouble)*16));
	
	x_vwport = max_x_vwport - min_x_vwport;
	y_vwport = max_y_vwport - min_y_vwport;

	if ((x_vwport < 1) || (y_vwport < 1))
	{
	    status = FALSE;
	    *msg = DPVWPTOOSM;
	    goto fini;
	}
	/* Making sure that the view volume is in the correct order : 
	   [0,1,2] x,y,z minimums & [3,4,5] x,y,z maximums       */

	if (vw_vol[0] > vw_vol[3])
	{
	    temp = vw_vol[3];
	    vw_vol[3] = vw_vol[0];
	    vw_vol[0] = temp;
	}
	if (vw_vol[1] > vw_vol[4])
	{
	    temp = vw_vol[4];
	    vw_vol[4] = vw_vol[1];
 	    vw_vol[1] = temp;
	}
	if (vw_vol[2] > vw_vol[5])
	{
	    temp = vw_vol[5];
	    vw_vol[5] = vw_vol[2];
	    vw_vol[2] = temp;
	}

	vw_vol_ext_x = vw_vol[3] - vw_vol[0];
	vw_vol_ext_y = vw_vol[4] - vw_vol[1];
	vw_vol_ext_z = vw_vol[5] - vw_vol[2];
	
	/* Making sure the view volume extents do not get too small
	   ( approaching 0) */

	vw_vol_small = VOLSMALL;
  	if ( vw_vol_ext_y < vw_vol_small)
	{
	    if (vw_vol[1] < 1.0 && vw_vol[1] > -1.0)
	    {
	    	vw_vol_ext_y = VOLSMALL;
	    	vw_vol[4] = vw_vol[1] + vw_vol_ext_y;
	    }
	    else
	    {
	    	vw_vol_ext_y = VOLSMALL * MAdabs(msg,&vw_vol[1]);
	    	vw_vol[4] = vw_vol[1] + vw_vol_ext_y;
	    }
	    y_min = TRUE;
	    scale_msg = DPDGNSLIMIT;
	}
	if ( vw_vol_ext_x < vw_vol_small)
	{
	    if (vw_vol[0] < 1.0 && vw_vol[0] > -1.0)
	    {
	    	vw_vol_ext_x = VOLSMALL;
	    	vw_vol[3] = vw_vol[0] + vw_vol_ext_x;
	    }
	    else
	    {
	    	vw_vol_ext_x = VOLSMALL * MAdabs(msg,&vw_vol[0]);
	    	vw_vol[3] = vw_vol[0] + vw_vol_ext_x;
	    }
	    x_min = TRUE;
	    scale_msg = DPDGNSLIMIT;
	}

	/* The view volume is kept proportional with the viewport's size 
	   so that a uniform scale can be used to scale the view volume to 
	   fit the viewport exactly. 
	*/
	
	limit_vol[0] = GRDGNLIMITS_MIN_D;
	limit_vol[1] = GRDGNLIMITS_MIN_D;
	limit_vol[2] = GRDGNLIMITS_MIN_D;
	limit_vol[3] = GRDGNLIMITS_MAX_D;
	limit_vol[4] = GRDGNLIMITS_MAX_D;
	limit_vol[5] = GRDGNLIMITS_MAX_D;

	DPsetrng(msg, (IGRdouble *)wld_to_view, &range_chk);
	DPgetrng(msg, (IGRdouble *)wld_to_view, &range_chk, limit_vol,vw_limit);

	limit_ext[0] = vw_limit[3] - vw_limit[0];
	limit_ext[1] = vw_limit[4] - vw_limit[1];
	limit_ext[2] = vw_limit[5] - vw_limit[2];
	
	if (vw_vol_ext_x > limit_ext[0])
	{
	   vw_vol[0] = vw_limit[0];
	   vw_vol[3] = vw_limit[3];
	   vw_vol_ext_x = limit_ext[0];
	}
	if (vw_vol_ext_y > limit_ext[1])
	{
	    vw_vol[1] = vw_limit[1];
	    vw_vol[4] = vw_limit[4];	
	    vw_vol_ext_y = limit_ext[1];	
	}
	if (vw_vol_ext_z > limit_ext[2])
	{
	    vw_vol[2] = vw_limit[2];
	    vw_vol[5] = vw_limit[5];
	    vw_vol_ext_z = limit_ext[2];	
	}
	
	y_ratio =  y_vwport/vw_vol_ext_y;
	x_ratio =  x_vwport/vw_vol_ext_x;

	if ( y_ratio < x_ratio)
	{
	    /*  the x view volume is enlarged to make the
	  	ratios equal.
	    */
	    new_x_vwvol_ext = vw_vol_ext_y * (x_vwport / y_vwport);
	    /*  the difference between the old x view volume
		extent and the new extent is found,and the
		view volume is enlarged to be the new
		extent.
	    */
	    temp = (new_x_vwvol_ext - vw_vol_ext_x) / 2.0;
	    vw_vol[0] -= temp;
            vw_vol[3] += temp;
	}
	else
	{ 
	    new_y_vwvol_ext = vw_vol_ext_x * (y_vwport / x_vwport);
	    temp = (new_y_vwvol_ext - vw_vol_ext_y) /2.0;
 	    vw_vol[1] -= temp;
	    vw_vol[4] += temp;
	 }

	/* If the view volume's extents are outside the Design
	file limits, the view volume is readjusted */

	DGNlimit = GRDGNLIMITS_MAX_D - GRDGNLIMITS_MIN_D;

	/* Note: the following code is dependent on the view volume
			being proportional to the viewport.
	*/
	/* SHOULD probably put in an if statement to check for smallest or
	   change the message sent in					*/
	
	MAinvmx(msg,&four, (IGRdouble *)wld_to_view, (IGRdouble *)view_to_wld);

	if(!MAptsxform(msg, &num_pts, (IGRdouble *)view_to_wld, vw_vol, wld_vol))
	{
#ifdef DEBUG
	    printf("error in pts transform/n");
#endif
	    goto fini;
	}
	
	DPsetrng(msg, (IGRdouble *)view_to_wld, &range_chk);
	DPgetrng(msg, (IGRdouble *)view_to_wld, &range_chk, vw_vol, wld_range);
	
	ext_x = wld_range[3] - wld_range[0];
	ext_y = wld_range[4] - wld_range[1];
        ext_z = wld_range[5] - wld_range[2];

	scaling[0] = 1;
	
	if (ext_x > DGNlimit)
	{
	    scale_msg = DPDGNLIMIT;
	    scaling[0] = DGNlimit / ext_x;
	}		  
	if (ext_y > DGNlimit)
	{
	    scale_msg = DPDGNLIMIT;
	    scaling[1] = DGNlimit / ext_y;
	    if (scaling[1] < scaling[0])
	    {
		scaling[0] = scaling[1];
	    }
 	}
	if (ext_z > DGNlimit)
	{
	    scale_msg = DPDGNLIMIT;
	    scaling[1] = DGNlimit / ext_z;
	    if (scaling[1] < scaling[0])
	    {
		scaling[0] = scaling[1];
	    }
	}
	MAidmx (msg, (IGRdouble *)scale_mtx);
	if (scale_msg == DPDGNLIMIT)
	{
	    scale_mtx[0][0] = scaling[0];
	    scale_mtx[1][1] = scaling[0];
	    scale_mtx[2][2] = scaling[0];
	
	    if(!MAptsxform(msg, &num_pts, (IGRdouble *)scale_mtx, wld_range, 
				wld_range))
	    {
#ifdef DEBUG
	    	printf("error in pts transform/n");
#endif
	    	goto fini;
	    }
	} /* close for if DPDGNLIMIT */
	
	/* The extents are now fine, but the view volume might need
	    to be shifted if it is past the edge of the design file */

	MAidmx (msg, (IGRdouble *)trans);
  	if (wld_range[0] < GRDGNLIMITS_MIN_D)
  	{
	    trans_msg = DPDGNEDGE;
	    trans[0][3] = GRDGNLIMITS_MIN_D - wld_range[0];
	}
	if (wld_range[3] > GRDGNLIMITS_MAX_D)
	{
	    trans_msg = DPDGNEDGE;
	    trans[0][3] = GRDGNLIMITS_MAX_D - wld_range[3];
	}
  	if (wld_range[1] < GRDGNLIMITS_MIN_D)
  	{
	    trans_msg = DPDGNEDGE;
	    trans[1][3] = GRDGNLIMITS_MIN_D - wld_range[1];
	}
	if (wld_range[4] > GRDGNLIMITS_MAX_D)
	{
	    trans_msg = DPDGNEDGE;
	    trans[1][3] = GRDGNLIMITS_MAX_D - wld_range[4];
	}
  	if (wld_range[2] < GRDGNLIMITS_MIN_D)
  	{
	    trans_msg = DPDGNEDGE;
	    trans[2][3] = GRDGNLIMITS_MIN_D - wld_range[2];
	}
	if (wld_range[5] > GRDGNLIMITS_MAX_D)
	{
	    trans_msg = DPDGNEDGE;
	    trans[2][3] = GRDGNLIMITS_MAX_D - wld_range[5];
	}

	if (scale_msg != MSSUCC)
	{
	    vw_vol_ext_x = vw_vol[3] - vw_vol[0];
	    vw_vol_ext_y = vw_vol[4] - vw_vol[1];

	    if (x_min && y_min)
	    {
	    	*msg = scale_msg;	    
	    }
	    if (x_min)
	    {
	    	if (vw_vol_ext_x < (vw_vol_small * 2.0 * (y_vwport/x_vwport)))
		{
		    *msg = scale_msg;
		}
		else
		{
		    if (trans_msg == DPDGNEDGE)
		    {
	    		*msg = trans_msg;
	   	    }
		}
	    }
	    if (y_min)
	    {
	    	if (vw_vol_ext_y < (vw_vol_small * 2.0 * (x_vwport/y_vwport)))
		{
		    *msg = scale_msg;
		}
		else
		{
		    if (trans_msg == DPDGNEDGE)
		    {
	    		*msg = trans_msg;
	   	    }
		}
	    }
	}
	else if (trans_msg == DPDGNEDGE)
	{
	    *msg = trans_msg;
	}
	
	/* if order of matrix mult. is [T][S] then can use one matrix */

	MAmulmx(&trans_msg, &four, &four, &four, (IGRdouble *)trans, 
			(IGRdouble *)scale_mtx, (IGRdouble *)result);

	MAmulmx(&trans_msg, &four, &four, &four, (IGRdouble *)result, 
			(IGRdouble *)view_to_wld, (IGRdouble *)extra_mtx);

	MAmulmx(&trans_msg, &four, &four, &four, (IGRdouble *)wld_to_view, 
			(IGRdouble *)extra_mtx, (IGRdouble *)ex_mtx);

	if(!MAptsxform(&trans_msg, &num_pts, (IGRdouble *)ex_mtx, vw_vol,ex_vol ))
	{
#ifdef DEBUG
	    printf("error in pts transform/n");
#endif
	    goto fini;
	}
	DPgetrng(&trans_msg, (IGRdouble *)view_to_wld, &range_chk, ex_vol,
		 wld_range);	
	
	if(!MAptsxform(&trans_msg, &num_pts, (IGRdouble *)result, wld_vol, temp_vol))
	{
#ifdef DEBUG
	    printf("error in pts transform/n");
#endif
	    goto fini;
	}
	
	if(!MAptsxform(&trans_msg, &num_pts, (IGRdouble *)wld_to_view, temp_vol, vw_vol))
	{
#ifdef DEBUG
	    printf("error in pts transform/n");
#endif
	    goto fini;
	}

fini:
	return(status);
	
}
