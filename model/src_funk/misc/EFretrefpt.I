/* ###################   APOGEE COMPILED   ################## */
class implementation ECplhole;

#include <stdio.h>
#include "OMmacros.h"
#include "emserr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "bsgeom_cvsf.h"

#define WBC_USE_NEW_MATH 1

from GRlinear import GRgetpolyline;

#define CONSIDER_REF_PLANES_TO_BE_INFINITE 1

/* Tapadia - 07/27/92 - Genesis. This function returns a closest point on the
			reference plane. 
    WBC    - 01/11/93 - Replaced the call to BSmdistptsf with a call
                        to BSprptarrsf.
   SM        02/10/93 - Modified to just send GRptproject message to the
                        ref plane, to consider it infinite. The new code
                        can be activated/deactivated based on the conditional
                        compile switch CONSIDER_REF_PLANES_TO_BE_INFINITE
                        for testing purpose.


	Input 		ref_info 
			input_pt
	Output 		surf_pt
*/ 

#if CONSIDER_REF_PLANES_TO_BE_INFINITE
from GRvg import GRptproject;
#endif

IGRlong EFpton_refplane(EMmsg, ref_info, input_pt, surf_pt)
IGRlong *EMmsg;
struct GRlc_info *ref_info;
IGRpoint input_pt;
IGRpoint surf_pt;
{
	IGRlong sts;
	
#if !CONSIDER_REF_PLANES_TO_BE_INFINITE		
	IGRlong loc_msg;
	OM_S_CHANSELECT	to_comps;
	GRobjid comp_ids;
	OMuword dum_os;
	IGRint action = 1, num_pts = 5;
	struct IGRpolyline poly;
	IGRpoint pts_buff[5], tmp_pt;
	extern void BSpl_of_pts(),
                    BSprptarrsf();
	struct IGRbsp_surface pl_gm;
        struct BSgeom_bsp_surf  geom_surface;
	IGRdouble u_knots[4], v_knots[4], dist_tol;
	IGRpoint poles[4];
	IGRboolean all_on_surf;
	extern IGRboolean BSmdistptsf();
        extern IGRboolean BSfreecv();
#endif

	*EMmsg = EMS_S_Success;
 	sts = OM_S_SUCCESS;

#if CONSIDER_REF_PLANES_TO_BE_INFINITE
       
        sts = om$send(msg = message GRvg.GRptproject(EMmsg,
              &ref_info->module_info.md_env.matrix_type,
	      ref_info->module_info.md_env.matrix, input_pt, surf_pt, 
	      NULL), targetid = ref_info->located_obj.objid, 
	      targetos = ref_info->located_obj.osnum, senderid = NULL_OBJID);
#else

	poly.num_points = num_pts;
	poly.points = (IGRdouble *)pts_buff;
		
	sts = EMmake_chanselect(GRcmpowner_to_components, &to_comps);

	sts = om$get_objid_at_index(
			objid = ref_info->located_obj.objid,
			osnum = ref_info->located_obj.osnum,
			p_chanselect = &to_comps,
			index = 0,
			objidaddr = &comp_ids,
			osnumaddr = &dum_os);

	sts = om$send(msg = message GRlinear.GRgetpolyline(&loc_msg,
		       &ref_info->module_info.md_env.matrix_type,
		       ref_info->module_info.md_env.matrix,
		       &action, &poly),
		senderid = NULL_OBJID,
		targetid = comp_ids,
		targetos = ref_info->located_obj.osnum);

	pl_gm.poles = (IGRdouble *)poles;
	pl_gm.u_knots = u_knots;
	pl_gm.v_knots = v_knots;

	BSpl_of_pts(num_pts, pts_buff, NULL, &pl_gm, &loc_msg);

#if WBC_USE_NEW_MATH
        geom_surface.bspsf = &pl_gm;
        geom_surface.type = BSRECT_PLANE;
        geom_surface.bounded = TRUE;
        geom_surface.urange[0] = geom_surface.vrange[0] = 0.0;
        geom_surface.urange[1] = geom_surface.vrange[1] = 1.0;
	geom_surface.sfgen_cv = NULL;
        geom_surface.geom_prop = FALSE;
        num_pts = 1;
        BSEXTRACTPAR(&loc_msg, BSTOLLENVEC, dist_tol);

        BSprptarrsf(&geom_surface, dist_tol, 1, 2, &num_pts, input_pt,
                    NULL, tmp_pt, &all_on_surf, NULL, &loc_msg);
        if(loc_msg != BSSUCC) {
	    *EMmsg = MSFAIL;
	    goto wrapup;
        }
#else
        {
            IGRdouble  dist;
            BSpair uv_pt;
            IGRboolean status;

    	    status = BSmdistptsf(&loc_msg, &pl_gm, input_pt, &uv_pt[0],
	    	                 &uv_pt[1], tmp_pt, &dist);
   	    if(!status) {
	  	*EMmsg = MSFAIL;
		goto wrapup;
            }
        }
#endif
	OM_BLOCK_MOVE(tmp_pt, surf_pt, sizeof(IGRpoint));
#endif

#if !CONSIDER_REF_PLANES_TO_BE_INFINITE	
wrapup:
#endif
    return(sts);
}


end implementation ECplhole;

