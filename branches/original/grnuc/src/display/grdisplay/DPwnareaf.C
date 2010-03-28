#include <stdio.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "dpdef.h"
#include "dpstruct.h"

/* prototype files */
#include "DPwnareaf.h"
#include "dpgetrng.h"
#include "dpsetrng.h"

#include "mainvmx.h"
#include "maatan.h"
#include "madabs.h"
#include "maptsxfor.h"


DPperwnarea(msg,in_flags,wld_pts,old_coi,wld_to_view,r_angle,r_eye,r_coi)
IGRlong *msg;
IGRint in_flags;
IGRdouble *wld_pts;
IGRdouble *old_coi;
IGRdouble *wld_to_view;
IGRdouble *r_angle;
IGRdouble *r_eye;
IGRdouble *r_coi;
{
IGRlong num_points = 1;
IGRshort i;
IGRdouble delta[3];
IGRdouble ex_pnts[6];
IGRdouble new_coi_vw[3];
IGRdouble old_coi_vw[3];
IGRdouble temp;
IGRdouble view_to_wld[4][4];
IGRdouble m_cos;
IGRdouble m_tan;
IGRshort four=4;
struct DPrange_check range_chk;


    for (i=0; i < 3; i++)
    {
    	if (wld_pts[i] > wld_pts[i+3])
    	{
		temp = wld_pts[i]; /*switched around to fix bug*/
		wld_pts[i] = wld_pts[i+3];
		wld_pts[i+3] = temp;
    	}
    }
    	DPsetrng(msg,wld_to_view,&range_chk);
    	DPgetrng(msg,wld_to_view,&range_chk,wld_pts,ex_pnts);
    if(!MAptsxform(msg,&num_points,wld_to_view,old_coi,old_coi_vw))
	{
#ifdef DEBUG
	    printf("\nin COwnctr pt transfrom failed\n");
#endif
	    goto fini;
	}            
    delta[0] = (ex_pnts[3] - ex_pnts[0])/2.0;
    delta[1] = (ex_pnts[4] - ex_pnts[1])/2.0;

    if (delta[1] > delta[0])
    {
	delta[0] = delta[1];
    }

    new_coi_vw[0] = (ex_pnts[3] + ex_pnts[0]) / 2.0;
    new_coi_vw[1] = (ex_pnts[4] + ex_pnts[1]) / 2.0;
    new_coi_vw[2] = ex_pnts[2];

    
	m_cos = MAdabs(msg,&new_coi_vw[2]);
	m_tan = delta[0]/m_cos;
    	*r_angle = MAatan(msg,&m_tan) * 2.0; 
    
    delta[2] = 0;
    delta[0] = new_coi_vw[0] - old_coi_vw[0];
    delta[1] = new_coi_vw[1] - old_coi_vw[1];

    if (!MAinvmx(msg, &four, wld_to_view, (IGRdouble *)view_to_wld))
    {
	goto fini;
    }

    if(!MAptsxform(msg, &num_points, (IGRdouble *)view_to_wld, delta, r_eye))
	{
#ifdef DEBUG
	    printf("\nin COwnctr pt transfrom failed\n");
#endif
	    goto fini;
	}            

    if(!MAptsxform(msg, &num_points, (IGRdouble *)view_to_wld, new_coi_vw, 
			r_coi))
	{
#ifdef DEBUG
	    printf("\nin COwnctr pt transfrom failed\n");
#endif
	    goto fini;
	}            

	fini:

return (1);
}

