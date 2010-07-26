class implementation IGEgragad;

#include <stdlib.h>
#include <stdio.h>

#include "grimport.h"
#include "dpdef.h"

#include "wl.h"
#include "igr.h"
#include "dl.h"

/* prototype files */
%safe
#include "DPsetpersp.h"
#include "DPordphigs.h"

#include "mainvmx.h"
#include "maidmx.h"
#include "mamulmx.h"
#include "ma2ptdis.h"
%endsafe
#include "DPsetpersp.h"
#include "dpalignper.h"
#include "DPwnareaf.h"

int DPsetpersp(	IGRlong *msg,
		struct GRid *gg_id,
		IGRshort in_flags,
		IGRshort *ret_flags,
		IGRdouble *vrp,
		IGRdouble *vpn,
		IGRdouble *vup,
		IGRdouble *eye_pt,
		IGRdouble *coi,
		IGRdouble *vw_angle,
		IGRdouble *pnear,
		IGRdouble *pfar,
		IGRdouble *r_vrp,
		IGRdouble *r_vpn,
		IGRdouble *r_vup,
		IGRdouble *r_eye_pt,
		IGRdouble *r_coi,
		IGRdouble *r_vw_angle,
		IGRdouble *r_near,
		IGRdouble *r_far )

{
IGRint status;
 
status = OM_S_SUCCESS;
 
*msg = MSSUCC;

    status = om$send(mode = OM_e_wrt_object,
          msg = message IGEgragad.DPset_persp(msg, gg_id, in_flags, 
		ret_flags, vrp,	 vpn, vup,
		 eye_pt, coi, vw_angle, pnear, pfar, r_vrp, r_vpn, r_vup, 
		r_eye_pt , r_coi, r_vw_angle, r_near, r_far),
                             senderid = NULL_OBJID,
                             targetid = gg_id->objid,
                             targetos = gg_id->osnum);
    	    if(! (1 & status))
    	    {
#ifdef DEBUG
            	printf("om send persp\n");
            	om$report_error(sts = status);
#endif
    	    } 
return (status);
}

method DPset_persp (IGRlong *msg; struct GRid *gg_id; 
IGRshort in_flags; IGRshort *ret_flags; IGRdouble *vrp; 
IGRdouble *vpn; IGRdouble *vup; IGRdouble *eye_pt; IGRdouble *coi; 
IGRdouble *vw_angle; IGRdouble *pnear; IGRdouble *pfar; IGRdouble *r_vrp; 
IGRdouble *r_vpn; IGRdouble *r_vup; IGRdouble *r_eye_pt; IGRdouble *r_coi; 
IGRdouble *r_vw_angle; IGRdouble *r_near; IGRdouble *r_far)

{

IGRint status = OM_S_SUCCESS;	
IGRshort four = 4;
IGRdouble trans_eyept[4][4];
IGRdouble left_handed[4][4];
IGRdouble temp_2mx[4][4];
IGRdouble s_vrp[3];
IGRdouble s_vpn[3];
IGRdouble s_vup[3];
IGRdouble s_eye_pt[3];
IGRdouble s_coi[3];
IGRdouble s_vw_angle;
IGRdouble s_near;
IGRdouble s_far;
IGRdouble view_to_wld[4][4];
IGRdouble temp;
IGRdouble new_act_z;


*msg = MSSUCC;

if ( ret_flags != NULL)
{
    if (ME.IGEgragad->gragad.flags & IS_PERSP)
    {
    	*ret_flags = 0;
    }
    else
    {
	*ret_flags = DP_NOT_PERSP;
    }
}
if (!(in_flags & DP_CVT_WN_ONLY))
{
    if (ME.IGEgragad->gragad.flags & IS_PERSP)
    {
	/* move to inquire and set method */
	trans_eyept[0][3] = -ME.IGEgragad->gragad.eye_pt[0];
	trans_eyept[1][3] = -ME.IGEgragad->gragad.eye_pt[1];
	trans_eyept[2][3] = -ME.IGEgragad->gragad.eye_pt[2];
        if (!MAidmx(msg, (IGRdouble *)left_handed))
        {
	    goto fini;
        }
        left_handed[2][2] = -1;
        if (!MAmulmx(msg, &four, &four, &four, (IGRdouble *)left_handed,
			(IGRdouble *)ME.IGEgragad->gragad.rotation,
			(IGRdouble *)temp_2mx))
	{
	    goto fini;
	}
        if (!MAmulmx(msg, &four, &four, &four, (IGRdouble *)temp_2mx,
			(IGRdouble *)trans_eyept, (IGRdouble *)view_to_wld))
	{
	    goto fini;
	}
    }
    else
    {
    	if(!MAinvmx(msg, &four, (IGRdouble *)ME.IGEgragad->gragad.wld_to_view,
			(IGRdouble *)view_to_wld))
    	{
    		goto fini;
    	}
    }
    if ((in_flags & DP_STD_DEFAULTS) || (!(ME.IGEgragad->gragad.flags & IS_PERSP)))
    {
        DPordphigs(msg,in_flags,ME.IGEgragad->gragad.vw_volume,
			&ME.IGEgragad->gragad.act_z,
			(IGRdouble *)ME.IGEgragad->gragad.wld_to_view,
			s_vrp, s_vpn, s_vup, s_eye_pt, s_coi, &s_vw_angle,
			&s_near, &s_far, &new_act_z);
    }
    else
    {
    	s_coi[0] = ME.IGEgragad->gragad.coi[0];
    	s_coi[1] = ME.IGEgragad->gragad.coi[1];
    	s_coi[2] = ME.IGEgragad->gragad.coi[2];

    	s_vrp[0] = ME.IGEgragad->gragad.vrp[0];
    	s_vrp[1] = ME.IGEgragad->gragad.vrp[1];
    	s_vrp[2] = ME.IGEgragad->gragad.vrp[2];

    	s_vpn[0] = ME.IGEgragad->gragad.vpn[0];
    	s_vpn[1] = ME.IGEgragad->gragad.vpn[1];
    	s_vpn[2] = ME.IGEgragad->gragad.vpn[2];

    	s_vup[0] = ME.IGEgragad->gragad.vup[0];
    	s_vup[1] = ME.IGEgragad->gragad.vup[1];
    	s_vup[2] = ME.IGEgragad->gragad.vup[2];

	s_eye_pt[0] = ME.IGEgragad->gragad.eye_pt[0];
	s_eye_pt[1] = ME.IGEgragad->gragad.eye_pt[1];
	s_eye_pt[2] = ME.IGEgragad->gragad.eye_pt[2];

	s_near = ME.IGEgragad->gragad.vw_volume[2];

	s_far = ME.IGEgragad->gragad.vw_volume[5];

	s_vw_angle = ME.IGEgragad->gragad.vw_angle;
    }
    if (coi != NULL)
    {
    	s_coi[0] = coi[0];
   	s_coi[1] = coi[1];
    	s_coi[2] = coi[2];
    }
    if (vrp != NULL)
    {
	s_vrp[0] = vrp[0];
    	s_vrp[1] = vrp[1];
    	s_vrp[2] = vrp[2];
    }
    if (vpn != NULL)
    {
    	s_vpn[0] = vpn[0];
    	s_vpn[1] = vpn[1];
    	s_vpn[2] = vpn[2];
    }
    if (vup != NULL)
    {
    	s_vup[0] = vup[0];
    	s_vup[1] = vup[1];
    	s_vup[2] = vup[2];
    }
    if (eye_pt != NULL)
    {
    	s_eye_pt[0] = eye_pt[0];
    	s_eye_pt[1] = eye_pt[1];
    	s_eye_pt[2] = eye_pt[2];
    }
    if (pnear != NULL)
    {
    	s_near = *pnear;
    }
    if (pfar != NULL)
    {
    	s_far = *pfar;
    }
    if (vw_angle != NULL)
    {
    	s_vw_angle = *vw_angle;
    }
    if (s_near > s_far)
    {
    	temp = s_near;
    	s_near = s_far;
    	s_far = temp;
    }

/* returning values */

    if (r_vrp != NULL)
    {
    	r_vrp[0] = s_vrp[0];
    	r_vrp[1] = s_vrp[1];
    	r_vrp[2] = s_vrp[2];
    }
    if (r_vpn != NULL)
    {
    	r_vpn[0] = s_vpn[0];
    	r_vpn[1] = s_vpn[1];
    	r_vpn[2] = s_vpn[2];
    }
    if (r_vup != NULL)
    {
    	r_vup[0] = s_vup[0];
    	r_vup[1] = s_vup[1];
    	r_vup[2] = s_vup[2];
    }
    if (r_eye_pt != NULL)
    {
    	r_eye_pt[0] = s_eye_pt[0];
    	r_eye_pt[1] = s_eye_pt[1];
    	r_eye_pt[2] = s_eye_pt[2];
    }
    if (r_coi != NULL)
    {
    	r_coi[0] = s_coi[0];
    	r_coi[1] = s_coi[1];
    	r_coi[2] = s_coi[2];
    }
    if (r_vw_angle != NULL)
    {
    	*r_vw_angle = s_vw_angle;
    }
    if (r_near != NULL)
    {
    	*r_near = s_near;
    }
    if (r_far !=NULL)
    {
    	*r_far = s_far;
    }
    if (in_flags & DP_SET)
    {
    	ME.IGEgragad->gragad.vrp[0] = s_vrp[0];
    	ME.IGEgragad->gragad.vrp[1] = s_vrp[1];
    	ME.IGEgragad->gragad.vrp[2] = s_vrp[2];

    	ME.IGEgragad->gragad.vpn[0] = s_vpn[0];
    	ME.IGEgragad->gragad.vpn[1] = s_vpn[1];
    	ME.IGEgragad->gragad.vpn[2] = s_vpn[2];

    	ME.IGEgragad->gragad.vup[0] = s_vup[0];
    	ME.IGEgragad->gragad.vup[1] = s_vup[1];
    	ME.IGEgragad->gragad.vup[2] = s_vup[2];

    	ME.IGEgragad->gragad.eye_pt[0] = s_eye_pt[0];
    	ME.IGEgragad->gragad.eye_pt[1] = s_eye_pt[1];
    	ME.IGEgragad->gragad.eye_pt[2] = s_eye_pt[2];

    	ME.IGEgragad->gragad.coi[0] = s_coi[0];
    	ME.IGEgragad->gragad.coi[1] = s_coi[1];
    	ME.IGEgragad->gragad.coi[2] = s_coi[2];

	if (!MA2ptdis (msg,s_eye_pt,s_coi,&ME.IGEgragad->gragad.act_z))
	{
#ifdef DEBUG
	    printf("2pt in set persp failed");
#endif
	    goto fini;
	}

    	ME.IGEgragad->gragad.vw_angle = s_vw_angle;

    	ME.IGEgragad->gragad.vw_volume[2] = s_near;
    	ME.IGEgragad->gragad.vw_volume[5] = s_far;
    }
}
if((( in_flags & DP_SET) && (!(ME.IGEgragad->gragad.flags & IS_PERSP))) ||
	(in_flags & DP_CVT_WN_ONLY))
{
	if (!(ME.IGEgragad->gragad.flags & IS_PERSP))
	{
	    ME.IGEgragad->gragad.act_z = new_act_z;
	}
    	if (ret_flags != NULL)
    	{
	    *ret_flags = DP_FIR_PERSP;
    	}	
    	ME.IGEgragad->gragad.flags |= IS_PERSP;  
    	ME.IGEgragad->gragad.flags |= FRONT_CLIP;  
    	ME.IGEgragad->gragad.flags |= BACK_CLIP;  
    	ME.IGEgragad->gragad.flags &= ~GRID_ON;

    	if ( DLdelete_drawing_pipeline( ME.IGEgragad->gragad.gpipe_id ) != DL_SUCCESS )
    	{
#ifdef DEBUG
	    printf("error in pipe id");
#endif
	    goto fini;
    	}

    	if ( DLcreate_drawing_pipeline( DL_PERSP_PIPE, ME.IGEgadget->win_no,
                                       &ME.IGEgragad->gragad.gpipe_id ) != DL_SUCCESS )
    	{    
#ifdef DEBUG
	    printf("error in getting pipe id");
#endif
	    goto fini;
    	}

    	if ( DLset_curve_max_points( ME.IGEgragad->gragad.gpipe_id, 100 ) != DL_SUCCESS )
    	{
#ifdef DEBUG
	    printf("error in maxpts");
#endif
	    goto fini;
    	}
}
if(( in_flags & DP_SET) || (in_flags & DP_CVT_WN_ONLY))
{
    status = om$send(mode = OM_e_wrt_object,
                 msg = message IGEgragad.DPcal ( msg ),
                 senderid = my_id,
                 targetid = my_id);
    if ( !(status & 1))
    {
        if (*msg != DPVUPPRLVPN)
        {
#ifdef DEBUG
            printf("\nin DPset_persp:  DPcal send failed\n");
            om$report_error(sts = status);
#endif
        }
    }
}

fini:
return(status);
}
end implementation IGEgragad;
