class implementation DMsrc;

#define AS_DEBUG 1

#include "madef.h"
#include "dim.h"
#include "dimdef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

%safe
#include "math.h"
%endsafe

#include "dimco.h"
#include "bsxlnpl.h"
#include "bststcvfln.h"
#include "bsrdcencrcv.h"
#include "bsprptoncv.h"
#include "bsproj1.h"
#include "bsprj_cv_pl.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "bscvnrpervc.h"
#include "bscvcv_int.h"
#include "bscircprop.h"
#include "bsarcofpts.h"
#include "bsalloccv.h"

extern void 	BScveval();
extern double fabs();
extern GRclassid OPP_GRtext_class_id;

from GRconic import GRgetarc;
from ACpreroot import ACplace;
from DMroot import set_degrade;

method DMkeypt_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list)
{
	IGRint status, rc;
	struct GRid go_grid;
	short matrix_type;
	IGRmatrix matrix;
	IGRpoint point;
	struct IGRbsp_curve *bsp_curve;
	struct DMkeypt_str dm_keypt;

	if (count < 1)
	{
		/*| DMkeypt - Invalid parent count */

		*msg = MSSUCC;
		return(OM_S_SUCCESS);
	}

	if (om$dimension_of(varray = me->data) != sizeof(dm_keypt))
	{
		/*| Invalid instance size */
		return(OM_E_ABORT);
	}

	memcpy(&dm_keypt, me->data, sizeof(dm_keypt));

	status =
	om$send(msg = message DMsrc.find_keypoint(
					&rc,
					list[0],
					dm_keypt.u_par,
					&matrix_type,
					matrix,
					&go_grid,
					&bsp_curve,
					point,
					dm_keypt.point),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	memcpy(me->data, &dm_keypt, sizeof(dm_keypt));

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMkeyseg_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list)
{
	IGRint status, rc;
	struct GRid go_grid;
	short matrix_type;
	IGRmatrix matrix;
	struct IGRbsp_curve *bsp_curve;
	IGRdouble *poles, *pole_i;
	IGRdouble dist, dist1, dist2;
	int i, index1, index2;
	IGRpoint pt, keypt;
	struct DMkeyseg_str dm_keyseg;
	BSrc	bsrc;

	if (count < 1)
	{
		/*| DMkeypt - Invalid parent count */
		*msg = MSSUCC;
		return(OM_S_SUCCESS);
	}

	if (om$dimension_of(varray = me->data) != sizeof(dm_keyseg))
	{
		/*| Invalid instance size */
		return(OM_E_ABORT);
	}

	memcpy(&dm_keyseg, me->data, sizeof(dm_keyseg));

	status =
	om$send(msg = message DMsrc.find_keypoint(
					&rc,
					list[0],
					dm_keyseg.u_par,
					&matrix_type,
					matrix,
					&go_grid,
					&bsp_curve,
					pt,
					keypt),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (bsp_curve->order != 2 || bsp_curve->num_poles < 2)
	{
		/*| Parent is a non_linear element */
		return(OM_E_ABORT);
	}

	poles = bsp_curve->poles;

	index1 = -1;
	for (i=0; i<bsp_curve->num_poles; i++)
	{
		pole_i = &poles[3*i];
		if ((fabs(pole_i[0] - keypt[0]) < 1e-09)
		&&  (fabs(pole_i[1] - keypt[1]) < 1e-09)
		&&  (fabs(pole_i[2] - keypt[2]) < 1e-09))
		{
			index1 = i;
			break;
		}
	}

	if (index1 < 0)
	{
		/*|Key point is not one of the poles*/
		return(OM_E_ABORT);
	}

	/*"index1=%d\n", index1*/

	if (index1 == 0)
	{
		if (!bsp_curve->phy_closed)
			index2 = 1;
		else
		{
			dist1 = BSdistptpt(&bsrc, pt, &poles[0]);
			dist2 = BSdistptpt(&bsrc, pt, &poles[3]);
			dist  = BSdistptpt(&bsrc, &poles[0], &poles[3]);

			if (fabs(dist - dist1 - dist2) > 1e-9)
				index2 = bsp_curve->num_poles - 2;
			else	index2 = 1;
		}
	}
	else if (index1 == bsp_curve->num_poles - 1)
		index2 = bsp_curve->num_poles - 2;
	else
	{
		index2 = index1 + 1;

		dist1 = BSdistptpt(&bsrc, pt, &poles[3*index1]);
		dist2 = BSdistptpt(&bsrc, pt, &poles[3*index2]);
		dist  = BSdistptpt(&bsrc, &poles[3*index1], &poles[3*index2]);

		/*"dist=%lf, dist1=%lf, dist2=%lf\n", dist, dist1, dist2*/

		if (fabs(dist - dist1 - dist2) > 1e-9)
			index2 = index1 - 1;
	}

	/*^
		printf("num_poles=%d\n", bsp_curve->num_poles);
		printf("index1=%d, index2=%d\n", index1, index2);
	*/

	for (i=0; i<3; i++)
	{
		dm_keyseg.line[i] = poles[3*index1 + i];
		dm_keyseg.line[i+3] = poles[3*index2 + i];
	}

	/*^ print_line("keyseg", dm_keyseg.line); */

	memcpy(me->data, &dm_keyseg, sizeof(dm_keyseg));

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMaxis_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list)
{
	IGRint status, rc;
	struct GRid go_grid;
	short matrix_type;
	IGRmatrix matrix;
	struct IGRbsp_curve *bsp_curve;
	IGRpoint pt, keypt;
	IGRdouble *axis;
	struct DMplan_info plan_info;
	int axis_dir, i;
	struct DMaxis_str dm_axis;

	if (count < 2)
	{
		/*| DMaxis - Invalid parent count */
		*msg = MSSUCC;
		return(OM_S_SUCCESS);
	}

	if (om$dimension_of(varray = me->data) != sizeof(dm_axis))
	{
		/*| Invalid instance size */
		return(OM_E_ABORT);
	}

	memcpy(&dm_axis, me->data, sizeof(dm_axis));

	status =
	om$send(msg = message DMsrc.find_keypoint(
					&rc,
					list[0],
					dm_axis.u_par,
					&matrix_type,
					matrix,
					&go_grid,
					&bsp_curve,
					pt,
					keypt),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMsrc.get_dimension_plane(
					&rc,
					md_env,
					&list[1],
					&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	axis_dir = dm_axis.axis;

	switch(axis_dir)
	{
		case WIN_X_AXIS:
		axis = plan_info.win_plan.vec_xpos;
		break;

		case WIN_Y_AXIS:
		axis = plan_info.win_plan.vec_ypos;
		break;

		case ACT_X_AXIS:
		axis = plan_info.act_plan.vec_xpos;
		break;

		case ACT_Y_AXIS:
		axis = plan_info.act_plan.vec_ypos;
		break;

		default:
		/*"Unknown axis_dir %d\n", axis_dir*/
		return(OM_E_ABORT);
	}

	for (i=0; i<3; i++)
	{
		dm_axis.line[i] = keypt[i];
		dm_axis.line[i+3] = keypt[i] + axis[i] * 0.001;
	}

	memcpy(me->data, &dm_axis, sizeof(dm_axis));

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DM2ptseg_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list)
{
	IGRint status, rc;
	struct GRid go_grid;
	short matrix_type;
	IGRmatrix matrix;
	struct IGRbsp_curve *bsp_curve;
	IGRpoint pt;
	struct DM2ptseg_str dm_2ptseg;

	if (count < 1)
	{
		/*| DM2ptseg - Invalid parent count */
		*msg = MSSUCC;
		return(OM_S_SUCCESS);
	}

	if (om$dimension_of(varray = me->data) != sizeof(dm_2ptseg))
	{
		/*| Invalid instance size */
		return(OM_E_ABORT);
	}

	memcpy(&dm_2ptseg, me->data, sizeof(dm_2ptseg));

	status =
	om$send(msg = message DMsrc.find_keypoint(
					&rc,
					list[0],
					dm_2ptseg.u_par1,
					&matrix_type,
					matrix,
					&go_grid,
					&bsp_curve,
					pt,
					&dm_2ptseg.line[0]),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMsrc.find_keypoint(
					&rc,
					(count == 2)?list[1]:list[0],
					dm_2ptseg.u_par2,
					&matrix_type,
					matrix,
					&go_grid,
					&bsp_curve,
					pt,
					&dm_2ptseg.line[3]),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	memcpy(me->data, &dm_2ptseg, sizeof(dm_2ptseg));

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}


method DMradcen_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list)
{
	IGRint status;
	struct DMradcen_str dm_radcen;

	if (om$dimension_of(varray = me->data) != sizeof(dm_radcen))
	{
		/*| Invalid instance size */
		return(OM_E_ABORT);
	}

	memcpy(&dm_radcen, me->data, sizeof(dm_radcen));

	status =
	om$send(msg = message DMsrc.compute_radcen(
					msg,
					md_env,
					count,
					list,
					&dm_radcen),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	memcpy(me->data, &dm_radcen, sizeof(dm_radcen));

	return(OM_S_SUCCESS);
}

method compute_radcen(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list;
	struct DMradcen_str *dm_radcen)
{
	IGRint status, rc;

	/* --- The following are READ ONLY parameters ---- */

	struct IGRbsp_curve *R_bsp_curve, *R_proj_curve, *R_conv_curve;
	IGRdouble *R_dim_normal, *R_cv_normal, *R_point_on_cv;
	IGRdouble R_radius, *R_center, R_upar_low, R_upar_high;
	IGRboolean R_planes_parallel, R_const_radius, R_dynamics_on;

	/* ----------------------------------------------- */

	struct IGRbsp_curve bc_conic;
	IGRdouble wghts[BSCIRCLE_NUM_POLES_MAX];
	IGRdouble knots[BSCIRCLE_NUM_KNOTS_MAX];
	IGRdouble  poles[BSCIRCLE_NUM_POLES_MAX * 3];

	IGRboolean cv_flag, use_3ptcir;
	IGRdouble u_par;
	IGRdouble l_crv, r_crv, l_rad;
	IGRpoint l_cnt;
	IGRboolean bndry;
	IGRdouble cir_normal[3];
	IGRpoint center_P;
	IGRdouble pt_on_proj_cv[3];

	IGRint iv;
	IGRpoint vertex;
	IGRdouble *p1, *p2, *p3;
	IGRdouble d, tol;
	BSrc	bsrc;

	if (count < 2)
	{
		/*| DMradcen - Invalid parent count */

		*msg = MSSUCC;
		return(OM_S_SUCCESS);
	}

	/*^ printf("dm_radcen.upar = %f\n",dm_radcen->u_par);*/

	status =
	DMload_cache(list, FALSE, TRUE, &dm_radcen->u_par, md_env);
	dm$status(action = RET_STATUS);

	status =
	DMget_cache_data(
		&R_bsp_curve,
		&R_proj_curve,
		&R_conv_curve,
		&R_dynamics_on,
		&R_point_on_cv,
		&R_cv_normal,
		&R_dim_normal,
		&R_planes_parallel,
		&R_const_radius,
		&R_center,
		&R_radius,
		&R_upar_low,
		&R_upar_high);
	dm$status(action = RET_STATUS);

	/*^
		printf("bsp_curve=%d\n", R_bsp_curve);
		printf("proj_curve=%d\n", R_proj_curve);
		printf("conv_curve=%d\n", R_conv_curve);
		printf("center=%d\n", R_center);
		printf("dim_normal=%d\n", R_dim_normal);
		printf("point_on_cv=%d\n", R_point_on_cv);
		printf("upar_low = %f\n", R_upar_low);
		printf("upar_high = %f\n", R_upar_high);
	*/

	if (!R_dynamics_on)
	{
		/*| Evaluate point on the curve */

		BScveval(R_bsp_curve, dm_radcen->u_par, 0, dm_radcen->point, &bsrc);
		if (bsrc != BSSUCC)
		{
			printf("DMradcen_comp: BScveval failure\n");
			return(OM_E_ABORT);
		}
	}

	/*^
		printf("u_par=%lf\n", dm_radcen->u_par);
		print_point("point", dm_radcen->point);
	*/

	if (R_const_radius)
	{
		dm_radcen->radius = R_radius;
		math_v_equal(dm_radcen->center, R_center);

		if (!R_dynamics_on)
			DMclear_cache();

		*msg = DIM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	if (R_planes_parallel)
	{
		u_par = dm_radcen->u_par;
		math_v_equal(pt_on_proj_cv, dm_radcen->point);
	}
	else
	{
		/*|BSproj1 begins*/

		status =
		BSproj1(&bsrc,
			dm_radcen->point,
			R_dim_normal,
			R_point_on_cv,
			pt_on_proj_cv);
		if (!status || bsrc != BSSUCC)
		{
			/*|BSproj1 fails*/
		}

		/*|If non_linear curve find u_par value*/

		if (R_proj_curve->order != 2)
		{
			status =
			BSprptoncv(
				&bsrc,
				R_proj_curve,
				pt_on_proj_cv,
				&u_par,
				&cv_flag);
			if (!status || bsrc != BSSUCC)
			{
				printf("DMradcen_compute: BSprptoncv fails\n");
				return(OM_E_ABORT);
			}
		}
	}

	if (R_proj_curve->order != 2)
	{
		/*| Non-linear curve - Use BSrdcencrcv */

		status =
		BSrdcencrcv(
			&bsrc,
			R_proj_curve,
			&u_par,
			&bndry,
			&r_crv,
			&l_crv,
			&dm_radcen->radius,
			&l_rad,
			dm_radcen->center,
			l_cnt);
		if (!status || bsrc != BSSUCC)
		{
			printf("BSrdcencrcv: Error status=%d, rc=%d\n",
				status, bsrc);
			return(OM_E_ABORT);
		}
	}
	else
	{
		/*| Line string */

		if (R_proj_curve->num_poles >= 5)
		{
			BSEXTRACTPAR(&bsrc, BSTOLCHRDHT, tol);

			bc_conic.poles	= poles;
			bc_conic.weights= wghts;
			bc_conic.knots	= knots;

			/*|BSarcofpts*/

			/*^
				ASedit_bsp(*R_proj_curve);
				print_point("pt_on_proj_cv", pt_on_proj_cv);
				printf("tol=%lf\n", tol);
			*/

			BSarcofpts(
				R_proj_curve,
				pt_on_proj_cv,
				tol,
				&bc_conic,
				&bsrc);
			if (bsrc == BSSUCC)
			{
				/*|BSarcofpts success*/

				use_3ptcir = FALSE;

				if (!bc_conic.rational)
					bc_conic.weights = NULL;

				status =
				BSprptoncv(
					&bsrc,
					&bc_conic,
					pt_on_proj_cv,
					&u_par,
					&cv_flag);
				if (!status || bsrc != BSSUCC)
				{
					printf("DMradcen_comp: BSprptoncv fails\n");
					return(OM_E_ABORT);
				}

				if (!cv_flag)
				{
					/*|DMradcen_comp: NOT ON CURVE*/
					u_par = 0.5;
				}

				/*"u_par=%lf\n", u_par*/

				status =
				BSrdcencrcv(
					&bsrc,
					&bc_conic,
					&u_par,
					&bndry,
					&r_crv,
					&l_crv,
					&dm_radcen->radius,
					&l_rad,
					dm_radcen->center,
					l_cnt);
				if (!status || bsrc != BSSUCC)
				{
					printf("DMradcen_comp: BSrdcencrcv fails\n");
					return(OM_E_ABORT);
				}
			}
			else	use_3ptcir = TRUE;
		}
		else	use_3ptcir = TRUE;

		if (use_3ptcir)
		{
			/*|Find nearest vertex*/

			ASfind_nearest_vertex(
				R_proj_curve,
				0,
				1.e+36,
				1.e+36,
				dm_radcen->point,
				vertex,			/* vertex */
				&iv, 			/* index_of_vertex */
				&d);			/* dist_from_vertex */

			if (d >= 1.e+36)
			{
				printf("DMradcen_compute: ASfind_nearest_vertex fails\n");
				return(OM_E_ABORT);
			}

			/*"iv=%d\n", iv*/

			p1 = &R_proj_curve->poles[3*iv];

			if (iv > 0)
				p2 = &R_proj_curve->poles[3*(iv - 1)];
			else	p2 = &R_proj_curve->poles[3*(iv + 2)];

			if (iv < R_proj_curve->num_poles - 1)
				p3 = &R_proj_curve->poles[3*(iv+1)];
			else	p3 = &R_proj_curve->poles[3*(iv-2)];

			/*| Construct circle by 3 points */

			status =
			BScircprop(
				&bsrc,
				p1,
				p2,
				p3,
				dm_radcen->center,
				&dm_radcen->radius,
				cir_normal);
			if (!status || bsrc != BSSUCC)
			{
				/*| BScircprop failure - return something */

				dm_radcen->radius = 1e06;
				math_v_equal(dm_radcen->center, p1);
			}
			else
			{
				/*| BScircprop success */
			}
		}
	}

	if (!R_planes_parallel)
	{
		/*|Project center onto new dim plan*/

		status =
		BSproj1(&bsrc,
			dm_radcen->center,
			R_dim_normal,
			dm_radcen->point,
			center_P);
		if (!status || bsrc != BSSUCC)
		{
			/*|BSproj1 fails*/
		}

		math_v_equal(dm_radcen->center, center_P);
	}

	if (!R_dynamics_on)
		DMclear_cache();

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMtanpt_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	int count;
	struct GRid *list)
{
	IGRint status, rc, i, pt_index;
	IGRlong long_rc;
	struct GRid go_grid;
	IGRshort matrix_type, pt_found[2];
	IGRmatrix matrix;
	IGRdouble par[2], *axis[2], d1, d2;
	IGRvector norm;
	IGRpoint point, tangent_pt[2];
	struct IGRbsp_curve *bsp_curve = NULL;
	struct IGRbsp_curve *proj_curve = NULL;
	struct DMtanpt_str dm_tanpt;
	struct DMplan_info plan_info;
	BSrc	bsrc;

	if (count < 1)
	{
		/*| DMtanpt - Invalid parent count */
		*msg = MSSUCC;
		return(OM_S_SUCCESS);
	}

	if (om$dimension_of(varray = me->data) != sizeof(dm_tanpt))
	{
		/*| Invalkid instance */
		return(OM_E_ABORT);
	}

	memcpy(&dm_tanpt, me->data, sizeof(dm_tanpt));

	/*| get dimension plane info */

	status =
	om$send(msg = message DMsrc.get_dimension_plane(
					&rc,
					md_env,
					&list[1],
					&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	for(i=0; i<3; i=i+1)
	   norm[i] = plan_info.act_plan.matrix[i + 8];

	status = 
	om$send(msg = message NDnode.ASreturn_go(
					&go_grid,
					&matrix_type,
					matrix),
		targetid = list[0].objid,
		targetos = list[0].osnum);
	dm$status(action = RET_STATUS);

	/*^ printf(" go_grid : %d, %d\n",go_grid.objid, go_grid.osnum); */

	status =
	om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&matrix_type,
					matrix,
					(char **)&bsp_curve),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	BScveval(bsp_curve, dm_tanpt.u_par, 0, point, &bsrc);
	if (bsrc != BSSUCC)
	{
		/*"BScveval fails: rc=%d\n", rc*/
		free(proj_curve);
		return(OM_E_ABORT);
	}

	BSalloccv(
		bsp_curve->order,
		bsp_curve->num_poles,
		bsp_curve->rational,
		bsp_curve->num_boundaries,
		&proj_curve,
		&bsrc);
	if (bsrc != BSSUCC)
	{
		printf("DMtanpt_compute: BSalloccv Fail\n");
		return(OM_E_ABORT);
	}

	/*|Project curve onto dim_plane*/

	status =
	BSprj_cv_pl(
		&bsrc,
		bsp_curve,
		point,
		norm,
		norm,
		proj_curve);
	if (!status || bsrc != BSSUCC)
	{
		printf("DMtanpt_compute: BSprj_cv_pl fails\n");
		free(proj_curve);
		return(OM_E_ABORT);
	}

	axis[0] = plan_info.act_plan.vec_xpos;
	axis[1] = plan_info.act_plan.vec_ypos;

	for (i=0; i<2; i++)
	{
		BScvnrpervc(
			proj_curve,
			point,
			axis[i],
			norm,
			&pt_found[i],
			&par[i],
			tangent_pt[i],
			&bsrc);
		if (bsrc != BSSUCC)
			pt_found[i] = FALSE;

		/*^
			printf("pt found = %d\n", pt_found[i]);
			printf("par = %lf\n", par);
			print_point("point",point);
			print_point("axis", axis[i]);
			print_point("tangent pt", tangent_pt[i]);
		*/
	}

	if (pt_found[0] || pt_found[1])
	{
		/*| tangent pt found */

		if (pt_found[0] && pt_found[1])
		{
			d1 = BSdistptpts(&bsrc, point, tangent_pt[0]);
			d2 = BSdistptpts(&bsrc, point, tangent_pt[1]);
			pt_index = (d1 < d2)?0:1;
		}
		else 	pt_index = (pt_found[0])?0:1;

		dm_tanpt.u_par = par[pt_index];
	 	for(i=0; i<3; i++)
			dm_tanpt.point[i] = tangent_pt[pt_index][i];
	}
	else
	{
		/*| - tangent not found */

		status =
		om$send(msg = message DMsrc.find_keypoint(
						&rc,
						list[0],
						dm_tanpt.u_par,
						&matrix_type,
						matrix,
						&go_grid,
						&bsp_curve,
						point,
						dm_tanpt.point),
				targetid = my_id);
		dm$status(action = RET_STATUS);

	}

	/*^ print_point("DMtanpt", dm_tanpt.point); */

	memcpy(me->data, &dm_tanpt, sizeof(dm_tanpt));

	free(proj_curve);
	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMmidpt_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list)
{
	IGRint status, rc;
	struct GRid go_grid;
	short matrix_type;
	IGRmatrix matrix;
	struct IGRbsp_curve *bsp_curve;
	IGRdouble *poles, *pole_i;
	IGRdouble dist, dist1, dist2;
	int i, index1, index2;
	IGRpoint pt, keypt;
	struct DMmidpt_str dm_midpt;
	IGRboolean cv_flag;
	BSrc	bsrc;

	if (count < 1)
	{
		/*| DMmidpt- Invalid parent count */
		*msg = MSSUCC;
		return(OM_S_SUCCESS);
	}

	if (om$dimension_of(varray = me->data) != sizeof(dm_midpt))
	{
		/*| Invalid instance size */
		return(OM_E_ABORT);
	}

	memcpy(&dm_midpt, me->data, sizeof(dm_midpt));

	status =
	om$send(msg = message DMsrc.find_keypoint(
					&rc,
					list[0],
					dm_midpt.u_par,
					&matrix_type,
					matrix,
					&go_grid,
					&bsp_curve,
					pt,
					keypt),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (bsp_curve->order == 2 && bsp_curve->num_poles > 2)
	{
		poles = bsp_curve->poles;
	
		index1 = -1;
		for (i=0; i<bsp_curve->num_poles; i++)
		{
			pole_i = &poles[3*i];
			if ((fabs(pole_i[0] - keypt[0]) < 1e-09)
			&&  (fabs(pole_i[1] - keypt[1]) < 1e-09)
			&&  (fabs(pole_i[2] - keypt[2]) < 1e-09))
			{
				index1 = i;
				break;
			}
		}

		if (index1 < 0)
		{
			/*|Key point is not one of the poles*/
			return(OM_E_ABORT);
		}

		/*"index1=%d\n", index1*/

		if (index1 == 0)
		{
			if (!bsp_curve->phy_closed)
				index2 = 1;
			else
			{
				dist1 = BSdistptpt(&bsrc, pt, &poles[0]);
				dist2 = BSdistptpt(&bsrc, pt, &poles[3]);
				dist  = BSdistptpt(&bsrc, &poles[0], &poles[3]);

				if (fabs(dist - dist1 - dist2) > 1e-9)
					index2 = bsp_curve->num_poles - 2;
				else	index2 = 1;
			}
		}
		else if (index1 == bsp_curve->num_poles - 1)
			index2 = bsp_curve->num_poles - 2;
		else
		{
			index2 = index1 + 1;

			dist1 = BSdistptpt(&bsrc, pt, &poles[3*index1]);
			dist2 = BSdistptpt(&bsrc, pt, &poles[3*index2]);
			dist  = BSdistptpt(&bsrc, &poles[3*index1], &poles[3*index2]);

			/*"dist=%lf, dist1=%lf, dist2=%lf\n", dist, dist1, dist2*/

			if (fabs(dist - dist1 - dist2) > 1e-9)
				index2 = index1 - 1;
		}

		/*^
			printf("num_poles=%d\n", bsp_curve->num_poles);
			printf("index1=%d, index2=%d\n", index1, index2);
		*/

		for (i=0; i<3; i++)
		{
			dm_midpt.point[i] = (poles[3*index1 + i] + 
						poles[3*index2 + i])/ 2.0;
		}

		status =
		BSprptoncv(
			&bsrc,
			bsp_curve,
			dm_midpt.point,
			&dm_midpt.u_par,
			&cv_flag);
		if (!status || bsrc != BSSUCC)
		{
			printf("DMmidpt_compute: BSprptoncv fails\n");
			return(OM_E_ABORT);
		}

	}
	else
	{
		dm_midpt.u_par = 0.5;

		/*| Evaluate point on the curve */

		BScveval(bsp_curve, dm_midpt.u_par, 0, dm_midpt.point, &bsrc);
		if (bsrc != BSSUCC)
		{
			printf("DMmidpt: BScveval failure\n");
			return(OM_E_ABORT);
		}
	}

	/*^ print_point("midpt", dm_midpt.point); */

	memcpy(me->data, &dm_midpt, sizeof(dm_midpt));

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMarc_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list)
{
	IGRint status, rc, i, j;
	IGRlong long_rc;
	struct ret_struct rst;
	struct DMarc_str dm_arc;
	struct DMplan_info plan_info;
	IGRdouble *start_pt, *end_pt, matrix[16];
	IGRdouble start_vec[3], end_vec[3], radius;
	IGRdouble start_angle, sweep_angle;
	IGRdouble pt1[3], pt2[3];
	BSrc	bsrc;

	if (count < 2)
	{
		*msg = OM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	memcpy(&dm_arc, me->data, sizeof(dm_arc));

	status =
	om$send(msg = message NDnode.NDgive_structure(&long_rc, &rst, md_env),
		targetid = list[0].objid,
		targetos = list[0].osnum);
	dm$status(action = RET_STATUS);

	/*| get dimension plane info */

	status =
	om$send(msg = message DMsrc.get_dimension_plane(
					&rc,
					md_env,
					&list[1],
					&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	math_v_equal(dm_arc.center, rst.var.circle_st.cent_p);
	start_angle = rst.var.circle_st.start_angle;
	sweep_angle = rst.var.circle_st.sweep_angle;
	radius = rst.var.circle_st.rad;

	/*^
		print_point("center",dm_arc.center);
		printf("start_angle = %f\n",start_angle);
		printf("sweep_angle = %f\n",sweep_angle);
		printf("radius = %f\n", radius);
	*/

	for(j=0; j<4; j++)
	{
		for(i=0; i<4; i++)
		   matrix[i+j*4] = rst.var.circle_st.mat[i*4+j];
	}

	/*^ print_matrix("arc matrix", matrix); */
		
	for (i=0; i<3; i++)
	{
		plan_info.win_plan.matrix[i*4 + 3] =
		plan_info.act_plan.matrix[i*4 + 3] = dm_arc.center[i];
	}

	MATH_rotate_vector(&rc, &matrix[0], start_angle, matrix, start_vec);
	MATH_rotate_vector(&rc, start_vec, sweep_angle, matrix, end_vec);

	for(i = 0; i < 3; i++)
	{
		pt1[i] = dm_arc.center[i] + radius * start_vec[i];
		pt2[i] = dm_arc.center[i] + radius * end_vec[i];
	}

	if(BSdotp(&bsrc, &matrix[8], &plan_info.win_plan.matrix[8]) > 0)
	{
		start_pt = pt1;
		end_pt = pt2;
	}
	else
	{
		start_pt = pt2;
		end_pt = pt1;
	}

	status =
	BSproj1(&bsrc,
		start_pt,
		&plan_info.act_plan.matrix[8],
		dm_arc.center,
		dm_arc.start_pt);
	dm$status(action = RET_STATUS);

	status =
	BSproj1(&bsrc,
		end_pt,
		&plan_info.act_plan.matrix[8],
		dm_arc.center,
		dm_arc.end_pt);
	dm$status(action = RET_STATUS);

	memcpy(me->data, &dm_arc, sizeof(dm_arc));

	/*^
		print_point("start_pt",dm_arc.start_pt);
		print_point("end_pt",dm_arc.end_pt);
	*/

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMptdist_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list)
{
	IGRint status, rc, i;
	IGRlong long_rc;
	struct GRid go_grid;
	IGRdouble point[3];
	IGRshort matrix_type;
	IGRmatrix matrix;
	struct IGRbsp_curve *bsp_curve;
	struct DMptdist_str dm_ptdist;
	GRclassid subclassid;
	BSrc	bsrc;

	rc = BSSUCC;
        long_rc = OM_S_SUCCESS;
        point[0] = point[1] = point[2] = 0.0;

	/*| - DMptdist_compute : begin */

	if (count < 1)
	{
		/*| DMptdist- Invalid parent count */
		*msg = MSSUCC;
		return(OM_S_SUCCESS);
	}

	if (om$dimension_of(varray = me->data) != sizeof(dm_ptdist))
	{
		/*| Invalid instance size */
		return(OM_E_ABORT);
	}

	memcpy(&dm_ptdist, me->data, sizeof(dm_ptdist));

	/*^
		printf(" upar : %f\n",dm_ptdist.u_par);
		print_point("vec", dm_ptdist.vec);
	*/

	/*| - Return graphic object */

	status = 
	om$send(msg = message NDnode.ASreturn_go(
					&go_grid,
					&matrix_type,
					matrix),
		targetid = list[0].objid,
		targetos = list[0].osnum);
	dm$status(action = RET_STATUS);

	status =
	om$get_classid(
		objid = go_grid.objid,
		osnum = go_grid.osnum,
		p_classid = &subclassid);
	dm$status(action = RET_STATUS);

	if(om$is_ancestry_valid(subclassid = subclassid,
		superclassid = OPP_GRtext_class_id) == OM_S_SUCCESS)
	{
		/*| - Object is of GRtext class */

		MATH_get_box_pt_upar(&rc,
				FALSE,
				&dm_ptdist.u_par,
				point,
				list[0],
				md_env);
	}
	else
	{
		/*| - Object is of class GRcurve */

		status =
		om$send(msg = message GRvg.GRgenabsg(
						&long_rc,
						&matrix_type,
						matrix,
						(char **)&bsp_curve),
			targetid = go_grid.objid,
			targetos = go_grid.osnum);
		dm$status(action = RET_STATUS);

		/*^
			printf(" upar : %f\n",dm_ptdist.u_par);
			print_point("vec", dm_ptdist.vec);
		*/

		BScveval(bsp_curve, dm_ptdist.u_par, 0, point, &bsrc);
		if (bsrc != BSSUCC)
		{
			printf("DMptdist: BScveval failure\n");
			return(OM_E_ABORT);
		}
	}

	for (i=0; i<3; i++)
	   dm_ptdist.point[i] = point[i] + dm_ptdist.vec[i];	

	/*^
		print_point("point", point);
		print_point("ptdist", dm_ptdist.point);
	*/

	/*| - DMptdist_compute : return */

	memcpy(me->data, &dm_ptdist, sizeof(dm_ptdist));

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMcenpt_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list)
{
	IGRint status;
	struct DMcenpt_str dm_cenpt;
	struct DMradcen_str dm_radcen;

	if (count < 2)
	{
		/*| DMcenpt- Invalid parent count */
		*msg = MSSUCC;
		return(OM_S_SUCCESS);
	}

	if (om$dimension_of(varray = me->data) != sizeof(dm_cenpt))
	{
		/*| Invalid instance size */
		return(OM_E_ABORT);
	}

	memcpy(&dm_cenpt, me->data, sizeof(dm_cenpt));

	dm_radcen.u_par = dm_cenpt.u_par;
	math_v_equal(dm_radcen.center, dm_cenpt.point);

	status =
	om$send(msg = message DMsrc.compute_radcen(
					msg,
					md_env,
					count,
					list,
					&dm_radcen),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	math_v_equal(dm_cenpt.point, dm_radcen.center);
	memcpy(me->data, &dm_cenpt, sizeof(dm_cenpt));

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMintpt_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	int count;
	struct GRid list[])
{
	IGRint status, rc, i, nint, min;
	IGRlong long_rc, size, nover;
	struct GRid go_grid;
	short matrix_type;
	IGRmatrix matrix;
	IGRdouble dist, dist1, norm[3];
	IGRdouble *xpar1, *xpar2, *xover1, *xover2;
	IGRdouble *xintpt, *xendpt;
	IGRpoint point;
	struct IGRbsp_curve *bsp_curve1, *bsp_curve2;
	struct IGRbsp_curve *proj_curve1, *proj_curve2;
	struct DMplan_info plan_info;
	struct DMintpt_str dm_intpt;
	BSrc	bsrc;

	if (count < 2)
	{
		/*| DMintpt - Invalid parent count */
		return(OM_E_ABORT);
	}

	memcpy(&dm_intpt, me->data, sizeof(dm_intpt));

	status =
	om$send(msg = message DMsrc.get_dimension_plane(
					&rc,
					md_env,
					&list[2],
					&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status = 
	om$send(msg = message NDnode.ASreturn_go(
					&go_grid,
					&matrix_type,
					matrix),
		targetid = list[0].objid,
		targetos = list[0].osnum);
	dm$status(action = RET_STATUS);

	/*^ printf(" go_grid : %d, %d\n",go_grid.objid, go_grid.osnum); */

	status =
	om$send(msg = message GRvg.GRgetexsize(
					&long_rc,
					&matrix_type,
					matrix,
					&size),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	bsp_curve1 = (struct IGRbsp_curve *)om$malloc(size = size);

	status =
	om$send(msg = message GRvg.GRgetexgeom(
					&long_rc,
					&matrix_type,
					matrix,
					(char *)bsp_curve1),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	BScveval(bsp_curve1, dm_intpt.u_par1, 0, point, &bsrc);
	if (bsrc != BSSUCC)
	{
		/*"BScveval fails: rc=%d\n", rc*/
		om$dealloc(ptr = bsp_curve1);
		return(OM_E_ABORT);
	}

	for(i = 0; i < 3; i++)
	{
		plan_info.win_plan.matrix[i*4+3] =
		plan_info.act_plan.matrix[i*4+3] = point[i];
		norm[i] = plan_info.win_plan.matrix[i + 8];
	}

	BSalloccv(
		bsp_curve1->order,
		bsp_curve1->num_poles,
		bsp_curve1->rational,
		bsp_curve1->num_boundaries,
		&proj_curve1,
		&bsrc);
	if (bsrc != BSSUCC)
	{
		printf("DMintpt_compute: BSalloccv Fail\n");
		om$dealloc(ptr = bsp_curve1);
		return(OM_E_ABORT);
	}

	/*|Project curve onto dim_plane*/

	status =
	BSprj_cv_pl(
		&bsrc,
		bsp_curve1,
		point,
		norm,
		norm,
		proj_curve1);
	if (!status || bsrc != BSSUCC)
	{
		printf("DMintpt_compute: BSprj_cv_pl fails\n");
		om$dealloc(ptr = bsp_curve1);
		BSfreecv(&bsrc, proj_curve1);
		return(OM_E_ABORT);
	}

	status = 
	om$send(msg = message NDnode.ASreturn_go(
					&go_grid,
					&matrix_type,
					matrix),
		targetid = list[1].objid,
		targetos = list[1].osnum);
	dm$status(action = RET_STATUS);

	/*^ printf(" go_grid : %d, %d\n",go_grid.objid, go_grid.osnum); */

	status =
	om$send(msg = message GRvg.GRgetexsize(
					&long_rc,
					&matrix_type,
					matrix,
					&size),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	bsp_curve2 = (struct IGRbsp_curve *)om$malloc(size = size);

	status =
	om$send(msg = message GRvg.GRgetexgeom(
					&long_rc,
					&matrix_type,
					matrix,
					(char *)bsp_curve2),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	BSalloccv(
		bsp_curve2->order,
		bsp_curve2->num_poles,
		bsp_curve2->rational,
		bsp_curve2->num_boundaries,
		&proj_curve2,
		&bsrc);
	if (bsrc != BSSUCC)
	{
		printf("DMintpt_compute: BSalloccv Fail\n");
		om$dealloc(ptr = bsp_curve1);
		BSfreecv(&bsrc, proj_curve1);
		om$dealloc(ptr = bsp_curve2);
		return(OM_E_ABORT);
	}

	/*|Project curve onto dim_plane*/

	status =
	BSprj_cv_pl(
		&bsrc,
		bsp_curve2,
		point,
		norm,
		norm,
		proj_curve2);
	if (!status || bsrc != BSSUCC)
	{
		printf("DMintpt_compute: BSprj_cv_pl fails\n");
		om$dealloc(ptr = bsp_curve1);
		om$dealloc(ptr = bsp_curve2);
		BSfreecv(&bsrc, proj_curve1);
		BSfreecv(&bsrc, proj_curve2);
		return(OM_E_ABORT);
	}

	xintpt =
	xpar1  =
	xpar2  =
	xendpt =
	xover1 =
	xover2 = NULL;

	DMextend_curve(proj_curve1);
	DMextend_curve(proj_curve2);

	BScvcv_int(
		&bsrc,
		proj_curve1,
		proj_curve2,
		&nint,
		&xintpt,
		&xpar1,
		&xpar2,
		&nover,
		&xendpt,
		&xover1,
		&xover2);

	/*^
		printf("rc = %d\n", rc);
		printf("nint = %d\t nover = %d\n", nint, nover);
	*/

	om$dealloc(ptr = bsp_curve1);
	om$dealloc(ptr = bsp_curve2);
	BSfreecv(&bsrc, proj_curve1);
	BSfreecv(&bsrc, proj_curve2);

	if (nint)
	{
		min = 0;

		if (nint > 1)
		{
			dist = BSdistptpts(&bsrc, point, xintpt);
			for(i=1; i<nint; i++)
			{
				dist1 = BSdistptpts(&bsrc, point, &xintpt[i*3]);
				if(dist1 < dist)
				{
					dist = dist1;
					min = i;
				}
			}
		}

		for(i=0; i<3; i=i+1)
		dm_intpt.point[i] = xintpt[i+3*min];
	}
	else	math_v_equal(dm_intpt.point, point);

	if (xintpt) free(xintpt);
	if (xpar1)  free(xpar1);
	if (xpar2)  free(xpar2);
	if (xendpt) free(xendpt);
	if (xover1) free(xover1);
	if (xover2) free(xover2);

	/*^  print_point("int_pt",dm_intpt.point); */

	memcpy(me->data, &dm_intpt, sizeof(dm_intpt));

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method edge_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	int count;
	struct GRid list[];
	struct DMedgeseg_str *dm_edgeseg)
{
	IGRint status, rc, i;
	IGRlong long_rc, size;
	struct GRid go_grid;
	short matrix_type, is_line, props;
	IGRmatrix matrix;
	IGRdouble dist, dist1, dotp;
	IGRpoint point, point1, cv_normal, cv_point;
	IGRpoint dm_normal, dm_point, edge_vec;
	IGRpoint projpt1, projpt2, edge_pt, pt1, pt2;
	struct IGRplane igr_plane;
	struct IGRbsp_curve *bsp_curve, *proj_curve;
	struct DMplan_info plan_info;
	BSrc	bsrc;

	if (count < 2)
	{
		/*| DMedge - Invalid parent count */
		return(OM_E_ABORT);
	}

	status =
	om$send(msg = message DMsrc.get_dimension_plane(
					&rc,
					md_env,
					&list[1],
					&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	for(i=0; i<3; i++)
	dm_normal[i] = plan_info.win_plan.matrix[i+8];

	status = 
	om$send(msg = message NDnode.ASreturn_go(
					&go_grid,
					&matrix_type,
					matrix),
		targetid = list[0].objid,
		targetos = list[0].osnum);
	dm$status(action = RET_STATUS);

	/*^ printf(" go_grid : %d, %d\n",go_grid.objid, go_grid.osnum); */

	status =
	om$send(msg = message GRgraphics.GRgetprops((IGRlong *) &rc, &props),
			targetid = go_grid.objid,
			targetos = go_grid.osnum);
	if (status & 1)
	{
		/*"props=%d\n", props*/

		if (!(props & GRIS_PLANAR))
		   return(OM_E_ABORT);
	}

	igr_plane.normal = cv_normal;
	igr_plane.point  = cv_point;

	/*|GRdetplane*/

	status =
	om$send(msg = message GRvg.GRdetplane(
					&long_rc,
					&matrix_type,
					matrix,
					&igr_plane),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	dotp = BSdotp(&bsrc, dm_normal, cv_normal);

	/*^
		print_point("dm_normal",dm_normal);
		print_point("cv_point",cv_point);
		print_point("cv_normal",cv_normal);
		printf("dotp = %f\n",dotp);
	*/

	if((dotp > DOTP_LOWER_BOUND) &&
	   (dotp < DOTP_UPPER_BOUND))
	{
		printf("Both planes are parallel\n");
		return(OM_E_ABORT);
	}

	status =
	om$send(msg = message GRvg.GRgetsize(
					&long_rc,
					&matrix_type,
					matrix,
					&size),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	bsp_curve = (struct IGRbsp_curve *)om$malloc(size = size);

	status =
	om$send(msg = message GRvg.GRgetgeom(
					&long_rc,
					&matrix_type,
					matrix,
					(char *)bsp_curve),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message GRvg.GRcenter(
				&long_rc,
				&matrix_type,
				matrix,
				point),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	if (!(status & long_rc & 1))
	{
		BScveval(bsp_curve, dm_edgeseg->u_par, 0, point, &bsrc);
		if (bsrc != BSSUCC)
		{
			/*"BScveval fails: rc=%d\n", rc*/
			om$dealloc(ptr = bsp_curve);
			return(OM_E_ABORT);
		}
	}

	for(i=0; i<3; i++) dm_point[i] = point[i];

	BSalloccv(
		bsp_curve->order,
		bsp_curve->num_poles,
		bsp_curve->rational,
		bsp_curve->num_boundaries,
		&proj_curve,
		&bsrc);
	if (bsrc != BSSUCC)
	{
		printf("DMedge_compute: BSalloccv Fail\n");
		om$dealloc(ptr = bsp_curve);
		return(OM_E_ABORT);
	}

	if(fabs(dotp) < DOTP_PERP_TOLERANCE)
	{
		/*|- planes are perpendicular project curve on dimplan */

		for(i=0; i<3; i++)
		   point1[i] = point[i] + dm_normal[i];

		/*|Calling BSxlnpl*/

		BSxlnpl(&bsrc,
			dm_normal,
			dm_point,
			point,
			point1,
			edge_pt);

		for(i=0; i<3; i++)
		   edge_vec[i] = dm_normal[i];
	}
	else
	{
		/*| planes are inclined */

		for(i=0; i<3; i++)
		   point1[i] = dm_point[i] + cv_normal[i];

		BSxlnpl(
			&bsrc,
			cv_normal,
			cv_point,
			dm_point,
			point1,
			projpt1);

		/*^ print_point("projpt1",projpt1);*/

		for(i=0; i<3; i++)
		   point1[i] = dm_normal[i] + cv_normal[i];

		BSxlnpl(
			&bsrc,
			cv_normal,
			cv_point,
			dm_normal,
			point1,
			projpt2);

		/*^ print_point("projpt2",projpt2);*/

		for(i=0; i<3; i++)
		   edge_vec[i] = projpt2[i] - projpt1[i];
		BSnorvec(&bsrc, edge_vec);

		for(i=0; i<3; i++)
		   point1[i] = point[i] + edge_vec[i];

		BSxlnpl(
			&bsrc,
			dm_normal,
			dm_point,
			point,
			point1,
			edge_pt);
	}

	/*^
		print_point("edge_pt",edge_pt);
		print_point("edge_vec",edge_vec);
		print_point("point",point);
	*/


	status =
	BSprj_cv_pl(
		&bsrc,
		bsp_curve,
		edge_pt,
		dm_normal,
		edge_vec,
		proj_curve);
	if (!status || bsrc != BSSUCC)
	{
		printf("DMedge_compute: BSprj_cv_pl fails\n");
		om$dealloc(ptr = bsp_curve);
		BSfreecv(&bsrc, proj_curve);
		return(OM_E_ABORT);
	}

	BStstcvfln(proj_curve, &is_line, pt1, pt2, &bsrc);

	if(!is_line)
	{
		printf("Projected Curve is not line\n");
		return(OM_E_ABORT);
	}

	/*^
		print_point("pt1",pt1);
		print_point("pt2",pt2);
	*/

	dist = BSdistptpt(&bsrc, edge_pt, pt1);
	dist1 = BSdistptpt(&bsrc, edge_pt, pt2);

	if(dist > dist1)
	{
		for(i=0; i<3; i++)
		{
			dm_edgeseg->line[i] = pt2[i];
			dm_edgeseg->line[i+3] = pt1[i];
		}
	}
	else
	{
		for(i=0; i<3; i++)
		{
			dm_edgeseg->line[i] = pt1[i];
			dm_edgeseg->line[i+3] = pt2[i];
		}
	}

	/*^
		print_line("line[0]",dm_edgeseg->line);
	*/

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMedgeseg_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	int count;
	struct GRid list[])
{
	IGRint status;
	struct DMedgeseg_str dm_edgeseg;

	if (count < 2)
	{
		/*| DMedgeseg - Invalid parent count */
		return(OM_E_ABORT);
	}

	memcpy(&dm_edgeseg, me->data, sizeof(dm_edgeseg));

	status =
	om$send(msg = message DMsrc.edge_compute(
					msg,
					md_env,
					count,
					list,
					&dm_edgeseg),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	memcpy(me->data, &dm_edgeseg, sizeof(dm_edgeseg));

	return(OM_S_SUCCESS);
}

method DMedgept_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	int count;
	struct GRid list[])
{
	IGRint status;
	struct DMedgeseg_str dm_edgeseg;
	struct DMedgept_str dm_edgept;

	if (count < 2)
	{
		/*| DMedgept - Invalid parent count */
		return(OM_E_ABORT);
	}

	memcpy(&dm_edgept, me->data, sizeof(dm_edgept));

	dm_edgeseg.u_par = dm_edgept.u_par;
	math_v_equal(dm_edgeseg.line, dm_edgept.point);

	status =
	om$send(msg = message DMsrc.edge_compute(
					msg,
					md_env,
					count,
					list,
					&dm_edgeseg),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	math_v_equal(dm_edgept.point, dm_edgeseg.line);
	memcpy(me->data, &dm_edgept, sizeof(dm_edgept));

	return(OM_S_SUCCESS);
}

end implementation DMsrc;
