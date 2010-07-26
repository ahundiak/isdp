#include <stdio.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dperr.h"
#include "msdef.h"

/* prototype files */
#include "DPfitpersp.h"
#include "mainvmx.h"
#include "masincos.h"
#include "maptsxfor.h"


IGRint DPfitpersp(msg,in_flag,vw_vol,act_z,wld_to_view,old_coi, old_vrp,angle,
					vrp,
					eye_pt,new_coi,
					pnear,pfar,new_act_z)
IGRlong *msg;
IGRint in_flag;
IGRdouble *vw_vol;
IGRdouble *act_z;
IGRdouble *wld_to_view;
IGRdouble *old_coi;
IGRdouble *old_vrp;
IGRdouble angle;
IGRdouble *vrp;
IGRdouble *eye_pt;
IGRdouble *new_coi;
IGRdouble *pnear;
IGRdouble *pfar;
IGRdouble *new_act_z;
{
IGRlong status = 1;
IGRshort four = 4;
IGRdouble view_to_wld[4][4];
IGRlong num_pts = 1;
IGRdouble temp_sm;
IGRdouble vw_angle;
IGRdouble sine;
IGRdouble cosine;
IGRdouble delta_coi[3];
IGRdouble eye_dist;
IGRdouble old_vw_coi[3];
IGRdouble old_vw_vrp[3];


/* this is dependent on vw_vol being in min max order */

    	if(!MAinvmx(msg, &four, wld_to_view, (IGRdouble *)view_to_wld))
    	{
    		goto fini;
    	}
	if (!MAptsxform (msg,&num_pts,wld_to_view,old_coi,old_vw_coi))
	{
	    goto fini;
	}
	new_coi[0] = (vw_vol[3] + vw_vol[0]) / 2.0;
	new_coi[1] = (vw_vol[4] + vw_vol[1]) / 2.0;
	if (old_vw_coi[2] < vw_vol[5] && old_vw_coi[2] > vw_vol[2])
	{
	    new_coi[2] = old_vw_coi[2];
	}
	else
	{
	    new_coi[2] = (vw_vol[5] + vw_vol[2]) / 2.0;
	}
	delta_coi[0] = new_coi[0] - old_vw_coi[0];
	delta_coi[1] = new_coi[1] - old_vw_coi[1];
	delta_coi[2] = new_coi[2] - old_vw_coi[2];
	vw_angle = angle/2.0; /* 0.52359878; */
	if (!MAsincos(msg,&vw_angle,&sine,&cosine))
	{
#ifdef DEBUG
	    printf("error in MAsincos");
#endif
	    goto fini;
	}
	
	if ((vw_vol[3] - vw_vol[0]) > (vw_vol[4] - vw_vol[1]))
	{
	    temp_sm = (vw_vol[3] - vw_vol[0])/2.0;
	}
	else
	{
	    temp_sm = (vw_vol[4] - vw_vol[1])/2.0;
	}

	eye_dist = temp_sm/(sine/cosine);

	delta_coi[2] = vw_vol[2] - eye_dist;
	*pnear = eye_dist;
	*pfar = *pnear + (vw_vol[5] - vw_vol[2]);
	if (!MAptsxform (msg, &num_pts, (IGRdouble *)view_to_wld, new_coi,
				new_coi))
	{
	    goto fini;
	}
	if (!MAptsxform (msg, &num_pts, (IGRdouble *)view_to_wld, delta_coi,
				eye_pt))
	{
	    goto fini;
	}
	if (!MAptsxform (msg,&num_pts,wld_to_view,old_vrp,old_vw_vrp))
	{
	    goto fini;
	}
	if ( old_vw_vrp[0] < vw_vol[3] && old_vw_vrp[0] > vw_vol[0])
	{
	    vrp[0] = old_vrp[0];
	}
	else
	{
	    vrp[0] = new_coi[0];
	}
	if ( old_vw_vrp[1] < vw_vol[4] && old_vw_vrp[1] > vw_vol[1])
	{
	    vrp[1] = old_vrp[1];
	}
	else
	{
	    vrp[1] = new_coi[1];
	}
	if ( old_vw_vrp[2] < vw_vol[5] && old_vw_vrp[2] > vw_vol[2])
	{
	    vrp[2] = old_vrp[2];
	}
	else
	{
	    vrp[2] = new_coi[2];
	}

fini:
    return(status);
}

