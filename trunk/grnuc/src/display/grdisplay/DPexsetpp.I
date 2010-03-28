class implementation IGEgragad;

#include <stdio.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "dpdef.h"
#include "dpmacros.h"

/* prototype files */
%safe
#include "DPexsetpp.h"
#include "DPwnareaf.h"
#include "DPsetpersp.h"
#include "dpalignper.h"

#include "madabs.h"
#include "masincos.h"
#include "maptsxfor.h"
%endsafe


#if defined(__STDC__) || defined(__cplusplus)
int DPcompersp(	IGRlong *msg,
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
		IGRdouble *fence_pts,
		IGRdouble *r_vrp,
		IGRdouble *r_vpn,
		IGRdouble *r_vup,
		IGRdouble *r_eye_pt,
		IGRdouble *r_coi,
		IGRdouble *r_vw_angle,
		IGRdouble *r_near,
		IGRdouble *r_far,
		IGRdouble *z_scrn_dist,
		IGRdouble *tilt )
#else
int DPcompersp(msg, gg_id, in_flags, ret_flags, vrp, vpn, vup, eye_pt, coi, 
		vw_angle, pnear, pfar, fence_pts, r_vrp, r_vpn, r_vup, r_eye_pt, r_coi, 
		r_vw_angle, r_near, r_far,z_scrn_dist,tilt)

IGRlong *msg;
struct GRid *gg_id;
IGRshort in_flags;
IGRshort *ret_flags;
IGRdouble *vrp;
IGRdouble *vpn;
IGRdouble *vup;
IGRdouble *eye_pt;
IGRdouble *coi;
IGRdouble *vw_angle;
IGRdouble *pnear;
IGRdouble *pfar;
IGRdouble *fence_pts;
IGRdouble *r_vrp;
IGRdouble *r_vpn;
IGRdouble *r_vup;
IGRdouble *r_eye_pt;
IGRdouble *r_coi;
IGRdouble *r_vw_angle;
IGRdouble *r_near;
IGRdouble *r_far;
IGRdouble *z_scrn_dist;
IGRdouble *tilt;
#endif

{
IGRint status;
IGRlong num_points = 1;
IGRdouble half_way_mtx[4][4];
IGRdouble rotation[4][4];
IGRdouble x_scrn_ext;
IGRdouble y_scrn_ext;
IGRdouble p_plane_ext;
IGRdouble z_scale;
IGRdouble my_angle;
IGRdouble half_angle;
IGRvector my_vpn;               /* view plane normal */  
IGRvector my_vup;               /* the view up vector  */
IGRvector my_coi;               /* the center of interest */
IGRvector my_eye;
IGRvector my_vrp;
IGRdouble m_sin;
IGRdouble m_cos;
IGRint min_x_dep;
IGRint min_y_dep;
IGRint max_x_dep;
IGRint max_y_dep;
IGRdouble my_far;
IGRdouble my_near;
IGRvector fin_vrp;
IGRshort my_in_flags;
IGRshort my_ret_flags;


status = OM_S_SUCCESS;
 
*msg = MSSUCC;

	my_in_flags = DP_STD_DEF_PSP | DP_FIT_VOL | DP_NOFIT_X | DP_NOFIT_Y;
	status = dp$set_persp(msg = msg, gg_id = gg_id, in_flags = my_in_flags, 
		ret_flags = &my_ret_flags, r_vrp = my_vrp, r_vpn = my_vpn, 
		r_vup = my_vup, r_eye_pt = my_eye, r_coi = my_coi, 
		r_vw_angle = &my_angle, r_near = &my_near, r_far = &my_far);

    	    if(! (1 & status))
    	    {
#ifdef DEBUG
            	printf("om send persp\n");
            	om$report_error(sts = status);
#endif
    	    } 

    DPalignper(msg, (DPRIGHT_ROT | DPLEFT_VIEW), my_vpn, my_vup, my_eye,
		(IGRdouble *)rotation, (IGRdouble *)half_way_mtx);
if (fence_pts != NULL)
{
    DPperwnarea(msg, 0, fence_pts, my_coi, (IGRdouble *)half_way_mtx,
			&my_angle, my_eye,my_coi);

    DPalignper(msg, (DPRIGHT_ROT | DPLEFT_VIEW), my_vpn, my_vup, my_eye,
		(IGRdouble *)rotation, (IGRdouble *)half_way_mtx);
}
    if (!MAptsxform(msg, &num_points, (IGRdouble *)half_way_mtx, my_vrp,
				fin_vrp))
     	 {
	    goto fini;
	 }     	
	half_angle = my_angle / 2.0;
	if (!MAsincos(msg,&half_angle,&m_sin,&m_cos) )
	{
	    goto fini;
	}
	p_plane_ext = 2.0 * (m_sin/m_cos) * fin_vrp[2];
	p_plane_ext = MAdabs (msg,&p_plane_ext);	
    	status = om$send(mode = OM_e_wrt_object,
          	msg = message IGEgragad.dep_extents(msg,&min_x_dep,&min_y_dep,
							&max_x_dep,&max_y_dep),
                             senderid = NULL_OBJID,
                             targetid = gg_id->objid,
                             targetos = gg_id->osnum);
    	if(! (1 & status))
	{
#ifdef DEBUG
            	printf("om send dep_extents\n");
            	om$report_error(sts = status);
#endif
	}
	x_scrn_ext = max_x_dep - min_x_dep;
	y_scrn_ext = max_y_dep - min_y_dep;

	if (y_scrn_ext < x_scrn_ext)
	{
		z_scale =  y_scrn_ext/p_plane_ext;
	}
	else
	{
		z_scale =  x_scrn_ext/p_plane_ext;
	}

	if (z_scrn_dist != NULL)
	{
		*z_scrn_dist = z_scale * fin_vrp[2];
	}
	if (tilt != NULL)
	{
	    tilt[0] = 0;
	    tilt[1] = 0;
	    tilt[2] =0;
	}

    status = om$send(mode = OM_e_wrt_object,
          msg = message IGEgragad.DPset_persp(msg, gg_id, in_flags, 
		ret_flags, vrp, vpn, vup,
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
OM_BLOCK_MOVE(my_eye,r_eye_pt,sizeof(IGRdouble) * 3);
OM_BLOCK_MOVE(my_coi,r_coi,sizeof(IGRdouble) * 3);

fini:

;
return (status);
}
end implementation IGEgragad;
