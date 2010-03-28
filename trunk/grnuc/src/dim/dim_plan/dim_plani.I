class implementation dim_plan;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "OMminimum.h" 
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "go.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "madef.h"
#include "bserr.h"
#include "asmacros.h"
#include "dpmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "GM.h"
#include "ndmacros.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "dim.h"
#include "dimplan.h"
#include "dm_status.h"
#include "dimmacros.h"
#include "dimdload.h"
#include "dimacc.h"
#include "dimext.h"
#include "dimerror.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"

method give_axis(
	IGRint *msg;
	IGRvector axis;
	struct GRmd_env *md_env)
{
	*msg = NO_AXIS;
	return(OM_S_SUCCESS);
}

method give_info(
	IGRint *msg;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRvector mea_axis;
	IGRmatrix matrix;

	status =
	om$send(msg = message dim_plan.give_plane(
					&rc,
					matrix,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message dim_plan.give_axis(
					&rc,
					mea_axis,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if(rc == NO_AXIS)
	{
		memcpy(plan_info->win_plan.matrix, matrix, sizeof(IGRmatrix));
		memcpy(plan_info->act_plan.matrix, matrix, sizeof(IGRmatrix));
	}
	else
	{
		memcpy(plan_info->win_plan.matrix, matrix, sizeof(IGRmatrix));

		MATH_compute_plan_info(
			&rc,
			mea_axis,
			plan_info->win_plan.matrix,
			plan_info->act_plan.matrix);
	}

	DMfill_plan_info(plan_info);

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method draw_axis(IGRint *msg; IGRdouble origin[3])

/*.draw_axis*/
{
struct  DMplan_info	plan_info;
struct	DPele_header	buffer[2];
struct  IGRpolyline     linex, liney;
struct	IGRdisplay    	display;
IGRdouble               pt_buffer[12];
IGRint 			status, rc;
struct  GRmd_env	md_env;
IGRboolean aflag = 0;

    if(aflag = pwIsActivationOn())
     {
      pwGetActiveModuleEnv(&md_env);
     }
    else
     {
      DMget_module_info(&md_env);
     } 

	/*| Get the Dimensional plane information */

	status =
	om$send(msg = message dim_plan.give_info(
					&rc,
					&plan_info,
					&md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - Set the display */

	display.color     = 0;
	display.weight    = 0;
	display.style     = 1;

	/*| - Compute the two axis end points */

	linex.num_points	= 2;
	linex.points		= pt_buffer;

	/*| - Multiply by BIGNUM to reach the space limits */

	pt_buffer[0]	= origin[0]
			  + 100000.0 * plan_info.act_plan.vec_xneg[0];
	pt_buffer[1]	= origin[1]
			  + 100000.0 * plan_info.act_plan.vec_xneg[1];
	pt_buffer[2]	= origin[2]
			  + 100000.0 * plan_info.act_plan.vec_xneg[2];
	pt_buffer[3]	= origin[0]
			  + 100000.0 * plan_info.act_plan.vec_xpos[0];
	pt_buffer[4]	= origin[1]
			  + 100000.0 * plan_info.act_plan.vec_xpos[1];
	pt_buffer[5]	= origin[2]
			  + 100000.0 * plan_info.act_plan.vec_xpos[2];

	liney.num_points	= 2;
	liney.points		= &pt_buffer[6];

	pt_buffer[6]	= origin[0]
			  + 100000.0 * plan_info.act_plan.vec_yneg[0];
	pt_buffer[7]	= origin[1]
			  + 100000.0 * plan_info.act_plan.vec_yneg[1];
	pt_buffer[8]	= origin[2]
			  + 100000.0 * plan_info.act_plan.vec_yneg[2];
	pt_buffer[9]	= origin[0]
			  + 100000.0 * plan_info.act_plan.vec_ypos[0];
	pt_buffer[10]	= origin[1]
			  + 100000.0 * plan_info.act_plan.vec_ypos[1];
	pt_buffer[11]	= origin[2]
			  + 100000.0 * plan_info.act_plan.vec_ypos[2];

	/*| - Builds the display buffer of the two lines */

	dp$build_dis_buffer(	buffer      = &buffer[0],
				type        = IGRPY,
				display_att = &display,
				geometry    = &linex);

	dp$build_dis_buffer(	buffer      = &buffer[1],
				type        = IGRPY,
				display_att = &display,
				geometry    = &liney);

	/*| Display the two buffer */

	dp$display(	msg      = &rc,
			mode     = GRhd,
			num_elem = 2, 
			buffer   = buffer );

	return(OM_S_SUCCESS);
}

method select_axis(IGRint *msg; IGRdouble origin[3]; IGRdouble pt[3]; 
				IGRint *axis)

/*.select_axis*/
{
IGRvector	vec;
IGRboolean	stat_func;
IGRint		status, rc, i;
IGRdouble	dotproduct_x, dotproduct_y;
struct DMplan_info plan_info;
struct GRmd_env md_env;
BSrc	bsrc;
IGRboolean aflag = 0;

    if(aflag = pwIsActivationOn())
     {
      pwGetActiveModuleEnv(&md_env);
     }
    else
     {
      DMget_module_info(&md_env);
     }

	/* Get the Dimensional plane information */

	status =
	om$send(msg = message dim_plan.give_info(
					&rc,
					&plan_info,
					&md_env),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	/* Compute vector */

	stat_func = BSmkvec(&bsrc,vec,origin,pt);

	stat_func = BSnorvec (&bsrc,vec);

	/* Compute angle between the vector and X axis of the dim_plan */

	dotproduct_x = BSdotp ( &bsrc, vec, plan_info.act_plan.vec_xpos );
	dotproduct_y = BSdotp ( &bsrc, vec, plan_info.act_plan.vec_ypos );

	/* Select measurement axis */
 
	/* The select pt is closer to the X axis */
	if (( dotproduct_x  >  0.707) || ( dotproduct_x < -0.707))
	 *axis = 0;

	/* The select pt is closer to the Y-axis */
	if (( dotproduct_y  >  0.707) || ( dotproduct_y < -0.707))
	 *axis = 1;

	return(OM_S_SUCCESS);
}

method give_parents(
	IGRint *count;
	struct GRid list[])
{
	*count = 0;
	return(OM_S_SUCCESS);
}

end implementation dim_plan;
