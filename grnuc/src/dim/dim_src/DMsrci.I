/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:31 $
$Locker:  $
$Log: DMsrci.I,v $
Revision 1.1.1.1  2001/12/17 22:39:31  hans
Initial import to CVS

# Revision 340.1  1997/08/12  12:15:08  ugummulu
# COMMENT : checked in.
#
# Revision 340.0  1997/05/27  23:09:13  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.2  1997/01/10  12:27:18  skathiri
# COMMENT : Changes for RFA+Assembly
#
# Revision 330.1  1996/12/09  14:31:50  jmopuri
# COMMENT : Update Associtive Attachment
#
# Revision 330.0  1996/01/11  21:23:17  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.3  1995/11/13  11:25:12  gvk
# COMMENT : Handling DMsrc objects which have text elements as parents.
#
# Revision 320.2  1995/07/19  06:19:12  gvk
# COMMENT : Line type DMconstln was  not initialized properly in NDgive_structure
#
# Revision 320.1  1994/12/28  07:15:22  sudha
# COMMENT : Purify fixes
#
# Revision 320.0  1994/12/12  17:52:43  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.5  1994/11/01  10:12:31  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.4  1993/11/16  08:18:49  gvk
# COMMENT : fix in NDmove_to_root method as directed by GVK
#
# Revision 240.3  1993/07/15  15:02:43  gvk
# COMMENT : Changes for feature patterning.
#
Revision 201.25  1992/10/06  20:52:51  poo
COMMENT : Fix for Surface Texture Symbol placed on polygon

Revision 201.24  1992/09/02  13:15:29  poo
COMMENT : Fix to handle curves properly in give_tangent method.

Revision 201.23  1992/07/20  05:44:53  gvk
COMMENT : ANSI compilation, global modification of DMglobal to DM_global.

Revision 201.21  1992/02/19  22:31:26  siki
COMMENT : Number of parents for DMcenpt was 1 when it should have been 2

Revision 201.20  1992/02/12  07:19:41  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - 12 Feb. 1992

Revision 201.18  1992/01/28  10:38:02  dimdp20
COMMENT : Dimension Fixes Checkin - S. Poovannan - Jan 28 1992

Revision 201.17  92/01/22  07:37:16  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Jan. 22 1992.

Revision 201.14  92/01/13  06:01:23  dimdp20
COMMENT : Dimensioning fixes release  - 13th Jan 92

*/

class implementation DMsrc;

#define AS_DEBUG 1

#include "madef.h"
#include "dim.h"
#include "dimdef.h"
#include "maidmx.h"
#include "bsxlnpl.h"
#include "bsprptoncv.h"
#include "bsperpa.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsmdstptcv.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

%safe
#include "math.h"
%endsafe

extern GRclassid OPP_GRtext_class_id;
extern GRclassid OPP_GR3dpoint_class_id;

extern void             BScveval();
extern IGRboolean	BSlininter();

from GRconic import GRgetarc;
from DMroot import set_degrade;

method NDplace(
	struct GRas *assoc_lis;
	struct GRmd_env *md_env;
	char *go_cnst_lis)
{
	IGRint 		index, status, rc;
	IGRint 		num_parents;
	IGRlong 	long_rc;
	IGRboolean	go_needed[2], matrix_type;
	IGRdouble	*attr, ptproj[3];
	IGRmatrix 	matrix;
	struct GRid 	null_grid;
	struct GRid 	*parents;
	struct GRid 	go_grid;
	struct GRparms 	par[2];

	struct src_attr		*src_attr;
	struct DMkeypt_str	dm_keypt;
	struct DMkeyseg_str	dm_keyseg;
	struct DM2ptseg_str	dm_2ptseg;
	struct DMaxis_str	dm_axis;
	struct DMradcen_str	dm_radcen;
	struct DMtanpt_str	dm_tanpt;
	struct DMmidpt_str	dm_midpt;
	struct DMptdist_str	dm_ptdist;
	struct DMarc_str	dm_arc;
	struct DMintpt_str	dm_intpt;
	struct DMcenpt_str	dm_cenpt;
	struct DMedgept_str	dm_edgept;
	struct DMedgeseg_str	dm_edgeseg;
	struct DMpt_str		dm_pt;
	struct DMln_str		dm_line;

	char *ptr;
	int  size;

	num_parents = assoc_lis->num_parents;
	parents = assoc_lis->parents;
	null_grid.objid = NULL_OBJID;

	src_attr = (struct src_attr *)assoc_lis->as_attr;
	me->type = src_attr->type;
	attr = src_attr->attr;

	go_needed[0] = (me->type != DMconstpt && me->type != DMconstln);
	go_needed[1] = (me->type == DM2ptseg) || (me->type == DMintpt);

	for (index=0; index<2; index++)
	{
         IGRboolean aflag= 0;
         struct GRmd_env refmd_env;  
          

		if (!go_needed[index]) continue;

		/*^
			printf("parents[%d]=%d, %d\n",
				index,
				parents[index].objid,
				parents[index].osnum);
		*/
	
		status =
		om$send(msg = message NDnode.ASreturn_go(
						&go_grid,
						&matrix_type,
						matrix),
			targetid = parents[index].objid,
			targetos = parents[index].osnum);
		dm$status(action = RET_STATUS);
                if(aflag = pwIsActivationOn())
                {
                 int i; 
                 pwGetActiveModuleEnv(&refmd_env);
                 matrix_type = refmd_env.md_env.matrix_type;
                 for(i=0; i < 16;i++)
                 matrix[i] = refmd_env.md_env.matrix[i];
                }  
		status =
		om$send(msg = message GRgraphics.GRptproject(
						&long_rc,
						&matrix_type,
						matrix,
						&attr[3*index],
						ptproj,
						&par[index]),
			targetid = go_grid.objid,
			targetos = go_grid.osnum);
		dm$status(action = RET_STATUS);

		if (par[index].leaf_id.objid != NULL_OBJID
		&&  par[index].leaf_id.objid != go_grid.objid)
		{
			struct GRid context;

			/*^
				printf("LEAF_ID=%d,%d\n",
					par[index].leaf_id.objid,
					par[index].leaf_id.osnum);
			*/
	
			status =
			GRfindcontext(
				&rc,
				&matrix_type,
				matrix,
				&par[index].leaf_id.osnum,
				&context);
			if (status != OM_S_SUCCESS || rc != MSSUCC)
				context.objid = NULL_OBJID;

			status =
			as$make_source(
				go_grid = par[index].leaf_id,
				context_grid = context,
				as_os = md_env->md_id.osnum,
				as_grid = &parents[index]);
			dm$status(action = RET_STATUS);
	
			/*^
				printf("UPDATED_PAR=%d,%d\n",
					parents[index].objid,
					parents[index].osnum);
			*/
		}
		else	par[index].leaf_id = go_grid;

		/*"u_par=%lf\n", par[index].u*/
	}

	status =
	om$send(msg = message NDnode.NDconnect(
					num_parents,
					parents,
					null_grid,
					ND_NEW),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	switch (me->type)
	{
		case DMkeypt:

		ptr = (char *)&dm_keypt;
		size = sizeof(dm_keypt);
		dm_keypt.u_par = par[0].u;
		break;

		case DMkeyseg:

		ptr = (char *)&dm_keyseg;
		size = sizeof(dm_keyseg);
		dm_keyseg.u_par = par[0].u;
		break;

		case DM2ptseg:

		ptr = (char *)&dm_2ptseg;
		size = sizeof(dm_2ptseg);
		dm_2ptseg.u_par1 = par[0].u;
		dm_2ptseg.u_par2 = par[1].u;
		break;

		case DMintpt:

		ptr = (char *)&dm_intpt;
		size = sizeof(dm_intpt);
		dm_intpt.u_par1 = par[0].u;
		dm_intpt.u_par2 = par[1].u;
		break;

		case DMaxis:

		ptr = (char *)&dm_axis;
		size = sizeof(dm_axis);
		dm_axis.u_par = par[0].u;
		dm_axis.axis = (IGRchar)attr[3];
		break;

		case DMradcen:

		ptr = (char *)&dm_radcen;
		size = sizeof(dm_radcen);
		dm_radcen.u_par = par[0].u;
		dm_radcen.on_curve = (par[0].u > 1e-08) &&
				     (par[0].u < (1.0 - 1e-08));
		break;

		case DMtanpt:

		ptr = (char *)&dm_tanpt;
		size = sizeof(dm_tanpt);
		dm_tanpt.u_par = par[0].u;
		break;

		case DMmidpt:

		ptr = (char *)&dm_midpt;
		size = sizeof(dm_midpt);
		dm_midpt.u_par = par[0].u;
		break;

		case DMptdist:

		ptr = (char *)&dm_ptdist;
		size = sizeof(dm_ptdist);

		if (DMancestry_valid(go_grid, OPP_GRtext_class_id))
		{
			MATH_get_box_pt_upar(&rc,
					TRUE,
					&dm_ptdist.u_par,
					ptproj,
					parents[0],
					md_env);
		}
		else dm_ptdist.u_par = par[0].u;

		for(index=0; index<3; index++)
		   dm_ptdist.vec[index] = attr[index] -  ptproj[index];

		break;

		case DMarc:

		ptr = (char *)&dm_arc;
		size = sizeof(dm_arc);
		break;

		case DMcenpt:

		ptr = (char *)&dm_cenpt;
		size = sizeof(dm_cenpt);
		dm_cenpt.u_par = par[0].u;
		break;

		case DMedgept:

		ptr = (char *)&dm_edgept;
		size = sizeof(dm_edgept);
		dm_edgept.u_par = par[0].u;
		break;

		case DMedgeseg:

		ptr = (char *)&dm_edgeseg;
		size = sizeof(dm_edgeseg);
		dm_edgeseg.u_par = par[0].u;
		break;

		case DMconstpt:
		
		ptr = (char *) &dm_pt;
		size = sizeof(struct DMpt_str);
		memcpy( ptr,attr,3*sizeof(double));		
		break;

		case DMconstln:
		ptr = (char *) &dm_line;
		size = sizeof(struct DMln_str);
		memcpy( ptr,attr,6*sizeof(double));		
		break;

		default:

		printf("DMsrc.NDplace: Invalid src_type %d\n", me->type);
		return(OM_E_ABORT);
	};

	status =
	om$vla_set_dimension(varray = ME.DMsrc->data, size = size);
	dm$status(action = RET_STATUS);

	memcpy(me->data, ptr, size);

	status =
	om$send(msg = message NDnode.NDchg_state(ND_DEGRADED, 0),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method NDgive_structure(
	IGRlong *msg;
	struct ret_struct *ret_st;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct DMkeypt_str	dm_keypt;
	struct DMkeyseg_str	dm_keyseg;
	struct DM2ptseg_str	dm_2ptseg;
	struct DMaxis_str	dm_axis;
	struct DMradcen_str	dm_radcen;
	struct DMtanpt_str	dm_tanpt;
	struct DMintpt_str	dm_intpt;
	struct DMmidpt_str	dm_midpt;
	struct DMptdist_str	dm_ptdist;
	struct DMarc_str	dm_arc;
	struct DMcenpt_str	dm_cenpt;
	struct DMedgept_str	dm_edgept;
	struct DMedgeseg_str	dm_edgeseg;
	struct DMplan_info	plan_info;
	struct DMpt_str		dm_pt;
	struct DMln_str		dm_line;

	struct GRid list[2];
	IGRchar *ptr;
	IGRint  vla_size, size, index, i, count;
	IGRdouble *line, cent_cvpt[3], cent_cvpt1[3];
	struct GRmd_env mod_info;
	BSrc	bsrc;

	vla_size = om$dimension_of(varray = me->data);
	if (!vla_size)
	{
		printf("DMsrc.NDgive_structure: Uninitialised instance\n");
		return(OM_E_ABORT);
	}

	switch (me->type)
	{
		case DMkeypt:

		size = sizeof(dm_keypt);
		ptr = (char *)&dm_keypt;
		break;

		case DMkeyseg:

		size = sizeof(dm_keyseg);
		ptr = (char *)&dm_keyseg;
		break;

		case DMaxis:

		size = sizeof(dm_axis);
		ptr = (char *)&dm_axis;
		break;

		case DM2ptseg:

		size = sizeof(dm_2ptseg);
		ptr = (char *)&dm_2ptseg;
		break;

		case DMradcen:

		size = sizeof(dm_radcen);
		ptr = (char *)&dm_radcen;
		break;

		case DMtanpt:

		size = sizeof(dm_tanpt);
		ptr = (char *)&dm_tanpt;
		break;

		case DMmidpt:

		size = sizeof(dm_midpt);
		ptr = (char *)&dm_midpt;
		break;

		case DMptdist:

		size = sizeof(dm_ptdist);
		ptr = (char *)&dm_ptdist;
		break;

		case DMarc:

		size = sizeof(dm_arc);
		ptr = (char *)&dm_arc;
		break;

		case DMintpt:

		size = sizeof(dm_intpt);
		ptr = (char *)&dm_intpt;
		break;

		case DMcenpt:

		size = sizeof(dm_cenpt);
		ptr = (char *)&dm_cenpt;
		break;

		case DMedgept:

		size = sizeof(dm_edgept);
		ptr = (char *)&dm_edgept;
		break;

		case DMedgeseg:

		size = sizeof(dm_edgeseg);
		ptr = (char *)&dm_edgeseg;
		break;

		case DMconstpt:

		size = sizeof(dm_pt);
		ptr  = (char *)&dm_pt;
		break;
		
		case DMconstln:

		size = sizeof(dm_line);
		ptr  = (char *)&dm_line;
		break;
		
		default:

		/*"Invalid type = %d\n", me->type*/
		return(OM_E_ABORT);
	}

	if (size != vla_size)
	{
		printf("DMsrc.NDgive_str: vla_size %d, act_size %d\n",
				vla_size, size);
		return(OM_E_ABORT);
	}

	memcpy(ptr, me->data, size);

	switch (me->type)
	{
		case DMkeypt:

		ret_st->type = point_generic;
		math_v_equal(ret_st->var.point_st.pt, dm_keypt.point);
		break;

		case DMtanpt:

		ret_st->type = point_generic;
		math_v_equal(ret_st->var.point_st.pt, dm_tanpt.point);
		break;

		case DMmidpt:

		ret_st->type = point_generic;
		math_v_equal(ret_st->var.point_st.pt, dm_midpt.point);
		break;

		case DMintpt:

		ret_st->type = point_generic;
		math_v_equal(ret_st->var.point_st.pt, dm_intpt.point);
		break;

		case DMcenpt:

		ret_st->type = point_generic;
		math_v_equal(ret_st->var.point_st.pt, dm_cenpt.point);
		break;

		case DMedgept:

		ret_st->type = point_generic;
		math_v_equal(ret_st->var.point_st.pt, dm_edgept.point);
		break;

		case DMptdist:

		ret_st->type = line_generic;
		for (index=0; index<3; index++)
		{

			ret_st->var.line_st.p0[index] = dm_ptdist.point[index]
						- dm_ptdist.vec[index];
			ret_st->var.line_st.p1[index] = dm_ptdist.point[index];
			ret_st->var.line_st.v0[index] = dm_ptdist.vec[index];
		};
		break;

		case DMkeyseg:
		case DMaxis:
		case DM2ptseg:
		case DMedgeseg:

		if (me->type == DMkeyseg)
			line = dm_keyseg.line;
		else if (me->type == DMaxis)
			line = dm_axis.line;
		else if (me->type == DMedgeseg)
			line = dm_edgeseg.line;
		else	line = dm_2ptseg.line;

		ret_st->type = line_generic;
		for (index=0; index<3; index++)
		{
			ret_st->var.line_st.p0[index] = line[index];
			ret_st->var.line_st.p1[index] = line[index+3];
			ret_st->var.line_st.v0[index] = line[index] - line[index+3];
		};

		BSnorvec(&bsrc, ret_st->var.line_st.v0);

		break;

		case DMradcen:
		case DMarc:

		/*| - NDget objects   */

        	status =
	        om$send(msg = message NDnode.NDget_objects(
        	                                ND_ROOT,
                	                        list,
                        	                2,
                                	        NULL,
                                        	0,
	                                        OM_K_MAXINT,
        	                                &count),
                	targetid = my_id);
	        dm$status(action = RET_STATUS);

		/*| get dimension plane info */

		mod_info.md_env.matrix_type = MAIDMX;
		MAidmx(&bsrc, mod_info.md_env.matrix);

		status =
		om$send(msg = message DMsrc.get_dimension_plane(
						&rc,
						&mod_info,
						&list[1],
						&plan_info),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if(me->type == DMradcen)
		{
			ret_st->type = circle_type;
			math_v_equal(ret_st->var.circle_st.cent_p, dm_radcen.center);

			BSmkvec(&bsrc, cent_cvpt, dm_radcen.center, dm_radcen.point);
			BSnorvec(&bsrc, cent_cvpt);

			MATH_ang_bet_lines(
				plan_info.win_plan.matrix,
				cent_cvpt, 
				&ret_st->var.circle_st.start_angle,
				&plan_info.win_plan.matrix[8]);

			ret_st->var.circle_st.rad = dm_radcen.radius;
			ret_st->var.circle_st.sweep_angle = (dm_radcen.on_curve)?0.0:10.0;
		}
		else
		{
			ret_st->type = arc_type;
			math_v_equal(ret_st->var.circle_st.cent_p, dm_arc.center);

			BSmkvec(&bsrc, cent_cvpt, dm_arc.center, dm_arc.start_pt);
			ret_st->var.circle_st.rad = BSlenvec(&bsrc, cent_cvpt);
			BSnorvec(&bsrc, cent_cvpt);

			MATH_ang_bet_lines(
				plan_info.win_plan.matrix,
				cent_cvpt, 
				&ret_st->var.circle_st.start_angle,
				&plan_info.win_plan.matrix[8]);

			BSmkvec(&bsrc, cent_cvpt1, dm_arc.center, dm_arc.end_pt);
			BSnorvec(&bsrc, cent_cvpt1);

			MATH_ang_bet_lines(
				cent_cvpt,
				cent_cvpt1, 
				&ret_st->var.circle_st.sweep_angle,
				&plan_info.win_plan.matrix[8]);
		}
		memcpy(ret_st->var.circle_st.mat,plan_info.win_plan.matrix, sizeof(IGRmatrix));
		break;

		case DMconstpt:

		ret_st->type = point_generic;
		math_v_equal(ret_st->var.point_st.pt, dm_pt.point);
		break;

		case DMconstln:

		ret_st->type = line_generic;
		line = dm_line.line;
		for (index=0; index<3; index++)
		{
			ret_st->var.line_st.p0[index] = line[index];
			ret_st->var.line_st.p1[index] = line[index+3];
			ret_st->var.line_st.v0[index] = line[index] - line[index+3];
		};
		break;

	}

	if (md_env->md_env.matrix_type != MAIDMX)
	{
		/*| - Transform data to current environment */

		switch (me->type)
		{
			case DMkeypt:
			case DMtanpt:
			case DMmidpt:
			case DMintpt:
			case DMcenpt:
			case DMedgept:
			case DMconstpt:

			DMtransform_point(
				ret_st->var.point_st.pt,
				md_env->md_env.matrix);
			break;

			case DMptdist:

			DMtransform_point(
				ret_st->var.line_st.p0,
				md_env->md_env.matrix);
			DMtransform_point(
				ret_st->var.line_st.p1,
				md_env->md_env.matrix);
			for(i=0; i<3; i++)
			ret_st->var.line_st.v0[i] = 
				ret_st->var.line_st.p1[i] - 
				ret_st->var.line_st.p0[i];
			break;

			case DMkeyseg:
			case DMaxis:
			case DM2ptseg:
			case DMedgeseg:
			case DMconstln:

			DMtransform_point(
				ret_st->var.line_st.p0,
				md_env->md_env.matrix);
			DMtransform_point(
				ret_st->var.line_st.p1,
				md_env->md_env.matrix);
			for(i=0; i<3; i++)
			ret_st->var.line_st.v0[i] = 
				ret_st->var.line_st.p0[i] - 
				ret_st->var.line_st.p1[i];
			break;

			case DMradcen:
			case DMarc:

			DMtransform_point(
				ret_st->var.circle_st.cent_p,
				md_env->md_env.matrix);
			DMtransform_matrix(ret_st->var.circle_st.mat, md_env);
			break;
		}
	}

	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

method find_keypoint(
	IGRint *msg;
	struct GRid as_grid;
	double u_par;
	short *matrix_type;
	IGRmatrix matrix;
	struct GRid *go_grid;
	struct IGRbsp_curve **bsp_curve;
	IGRpoint point;
	IGRpoint keypoint)
{
	IGRint status, rc;
	IGRlong long_rc;
	IGRpoint point2;
	struct IGRline boreline;
	struct IGRplane igr_plane;
	IGRdouble cv_normal[3], cv_point[3];
	struct GRparms par;
	struct IGRlbsys *lbsys;
	extern GRclassid OPP_GRgencs_class_id;
	BSrc	bsrc;

	/*"ASreturn_go %d, %d\n", as_grid.objid, as_grid.osnum*/

	status = 
	om$send(msg = message NDnode.ASreturn_go(
					go_grid,
					matrix_type,
					matrix),
		targetid = as_grid.objid,
		targetos = as_grid.osnum);
	dm$status(action = RET_STATUS);

	/*"GRgenagsg %d, %d\n", go_grid->objid, go_grid->osnum*/
	/* Some parents have text objects as parents, try to send
	   some key point */
	if (DMancestry_valid(*go_grid, OPP_GRgencs_class_id) ||
	     DMancestry_valid(*go_grid, OPP_GRtext_class_id))
	{
		/*|- Parent is coordinate system */

		status =
		om$send(msg = message GRvg.GRgenabsg(
						&long_rc,
						matrix_type,
						matrix,
						(char **)&lbsys),
			targetid = go_grid->objid,
			targetos = go_grid->osnum);
		dm$status(action = RET_STATUS);

		point[0] = lbsys->matrix[3];
		point[1] = lbsys->matrix[7];
		point[2] = lbsys->matrix[11];

		math_v_equal(keypoint, point);

		/*^ print_point("point", keypoint);*/
		*msg = DIM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					matrix_type,
					matrix,
					(char **)bsp_curve),
		targetid = go_grid->objid,
		targetos = go_grid->osnum);
	dm$status(action = RET_STATUS);

	/*"BScveval u=%lf\n", u_par*/

        /**
             check for valid ancestry TR#119603557
         **/
        if (!DMancestry_valid(*go_grid, OPP_GRcurve_class_id))
        {
          status = OM_E_ABORT;
          dm$status(action = RET_STATUS);
        }
        
	BScveval(*bsp_curve, u_par, 0, point, &bsrc);
	if (bsrc != BSSUCC)
	{
		/*"BScveval fails: rc=%d\n", rc*/
		return(OM_E_ABORT);
	}

	igr_plane.normal = cv_normal;
	igr_plane.point  = cv_point;

	/*|GRdetplane*/

	status =
	om$send(msg = message GRvg.GRdetplane(
					&long_rc,
					matrix_type,
					matrix,
					&igr_plane),
		targetid = go_grid->objid,
		targetos = go_grid->osnum);
	dm$status(action = RET_STATUS);

	boreline.point1 = point;
	boreline.point2 = point2;

	point2[0] = point[0] + cv_normal[0];
	point2[1] = point[1] + cv_normal[1];
	point2[2] = point[2] + cv_normal[2];

	/*|GRkeypoint*/

	status =
	om$send(msg = message GRvg.GRkeypoint(
					&long_rc,
					matrix_type,
					matrix,
					&boreline,
					keypoint,
					&par),
		targetid = go_grid->objid,
		targetos = go_grid->osnum);
	dm$status(action = RET_STATUS);

	/*^
		printf("u_par = %lf\n", u_par);
		print_point("point", point);
		print_point("point2", point2);
		print_point("keypoint", keypoint);
		print_grid("go_grid", go_grid);
	*/

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method NDcompute_node(
	IGRlong *msg;
	IGRint cn_type;
	int count;
	struct GRid list[];
	struct GRmd_env *md_env)
{
	IGRint status, rc;

	/*^
	{
		IGRint i;

		printf("count=%d\n", count);
		for (i=0; i<count; i++)
			printf("list[%d]=%d, %d\n",
				i, list[i].objid, list[i].osnum);
	}
	*/

	switch (me->type)
	{
		case DMkeypt:

		status =
		om$send(msg = message DMsrc.DMkeypt_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;

		case DMkeyseg:

		status =
		om$send(msg = message DMsrc.DMkeyseg_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;

		case DMaxis:

		status =
		om$send(msg = message DMsrc.DMaxis_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;

		case DM2ptseg:

		status =
		om$send(msg = message DMsrc.DM2ptseg_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;

		case DMradcen:

		DMclear_cache();

		status =
		om$send(msg = message DMsrc.DMradcen_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

 		DMclear_cache();

		break;

		case DMtanpt:

		status =
		om$send(msg = message DMsrc.DMtanpt_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;

		case DMmidpt:

		status =
		om$send(msg = message DMsrc.DMmidpt_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;

		case DMptdist:

		status =
		om$send(msg = message DMsrc.DMptdist_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;

		case DMarc:

		status =
		om$send(msg = message DMsrc.DMarc_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;

		case DMintpt:

		status =
		om$send(msg = message DMsrc.DMintpt_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;

		case DMcenpt:

		status =
		om$send(msg = message DMsrc.DMcenpt_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;

		case DMedgept:

		status =
		om$send(msg = message DMsrc.DMedgept_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;

		case DMedgeseg:

		status =
		om$send(msg = message DMsrc.DMedgeseg_compute(
						&rc,
						md_env,
						count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;

		case DMconstpt:
		case DMconstln:

		default:

		/*"Invalid type = %d\n", me->type*/
		return(OM_E_ABORT);
	}

	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

method DMgive_structure(
	IGRint *msg;
	IGRint type;
	IGRboolean inq0_set1;
	struct dim_ret_struct *str;
	struct GRmd_env *md_env)
{
	int size;
	char *ptr;
	double *pt1, *pt2, *ctr;

	str->type = me->type;

	switch (me->type)
	{
		case DMkeypt:
		size = sizeof(struct DMkeypt_str);
		ptr = (char *)&str->var.dm_keypt;
		pt1 = (double *)str->var.dm_keypt.point;
		break;

		case DMkeyseg:
		size = sizeof(struct DMkeyseg_str);
		ptr = (char *)&str->var.dm_keyseg;
		pt1 = (double *)str->var.dm_keyseg.line;
		break;

		case DMaxis:
		size = sizeof(struct DMaxis_str);
		ptr = (char *)&str->var.dm_axis;
		pt1 = (double *)str->var.dm_axis.line;
		break;

		case DM2ptseg:
		size = sizeof(struct DM2ptseg_str);
		ptr = (char *)&str->var.dm_2ptseg;
		pt1 = (double *)str->var.dm_2ptseg.line;
		break;

		case DMradcen:
		size = sizeof(struct DMradcen_str);
		ptr = (char *)&str->var.dm_radcen;
		pt1 = (double *)str->var.dm_radcen.point;
		ctr = (double *)str->var.dm_radcen.center;
		break;

		case DMtanpt:
		size = sizeof(struct DMtanpt_str);
		ptr = (char *)&str->var.dm_tanpt;
		pt1 = (double *)str->var.dm_tanpt.point;
		break;

		case DMmidpt:
		size = sizeof(struct DMmidpt_str);
		ptr = (char *)&str->var.dm_midpt;
		pt1 = (double *)str->var.dm_midpt.point;
		break;

		case DMptdist:
		size = sizeof(struct DMptdist_str);
		ptr = (char *)&str->var.dm_ptdist;
		pt1 = (double *)str->var.dm_ptdist.point;
		break;

		case DMarc:
		size = sizeof(struct DMarc_str);
		ptr = (char *)&str->var.dm_arc;
		ctr = (double *)str->var.dm_arc.center;
		pt1 = (double *)str->var.dm_arc.start_pt;
		pt2 = (double *)str->var.dm_arc.end_pt;
		break;

		case DMintpt:
		size = sizeof(struct DMintpt_str);
		ptr = (char *)&str->var.dm_intpt;
		pt1 = (double *)str->var.dm_intpt.point;
		break;

		case DMcenpt:
		size = sizeof(struct DMcenpt_str);
		ptr = (char *)&str->var.dm_cenpt;
		pt1 = (double *)str->var.dm_cenpt.point;
		break;

		case DMedgept:
		size = sizeof(struct DMedgept_str);
		ptr = (char *)&str->var.dm_edgept;
		pt1 = (double *)str->var.dm_edgept.point;
		break;

		case DMedgeseg:
		size = sizeof(struct DMedgeseg_str);
		ptr = (char *)&str->var.dm_edgeseg;
		pt1 = (double *)str->var.dm_edgeseg.line;
		break;

		case DMconstpt:
		size = sizeof(struct DMpt_str);
		ptr = (char *)&str->var.dm_pt;
		pt1 = (double *)str->var.dm_pt.point;
		break;

		case DMconstln:
		size = sizeof(struct DMln_str);
		ptr = (char *)&str->var.dm_line;
		pt1 = (double *)str->var.dm_line.line;
		break;

		default:
		printf("DMgive_structure: Invalid type %d\n", me->type);
		return(OM_E_ABORT);
	}

	if (om$dimension_of(varray = me->data) != size)
	{
		printf("DMgive_structure: SIZE MISMATCH\n");
		return(OM_E_ABORT);
	}

	if (!inq0_set1)
	   memcpy(ptr, me->data, size);

	if (md_env->md_env.matrix_type != MAIDMX)
	{
		/*| - Transform data to current environment */

		switch (me->type)
		{
			case DMkeypt:
			case DMtanpt:
			case DMmidpt:
			case DMintpt:
			case DMcenpt:
			case DMedgept:
			case DMptdist:
			case DMconstpt:

			DMtransform_point(pt1, md_env->md_env.matrix);
			break;

			case DMkeyseg:
			case DMaxis:
			case DM2ptseg:
			case DMedgeseg:
			case DMconstln:

			DMtransform_point(pt1, md_env->md_env.matrix);
			DMtransform_point(&pt1[3], md_env->md_env.matrix);
			break;

			case DMradcen:

			DMtransform_point(pt1, md_env->md_env.matrix);
			DMtransform_point(ctr, md_env->md_env.matrix);
			break;

			case DMarc:

			DMtransform_point(ctr, md_env->md_env.matrix);
			DMtransform_point(pt1, md_env->md_env.matrix);
			DMtransform_point(pt2, md_env->md_env.matrix);
			break;
		}
	}

	if (inq0_set1)
	   memcpy(me->data, ptr, size);

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMgive_src_info(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct dim_src_info *src_info)
{
	IGRint status, rc;
	int size, type;
	char *ptr, *cptr;
	IGRboolean go_needed[3];
	struct GRid list[2];
	IGRint exp_count, act_count;
	IGRint index;
	short matrix_type;	
	IGRmatrix matrix;
	struct dim_ret_struct dmstr;

	src_info->type = me->type;
	go_needed[0] = TRUE;
	go_needed[1] = FALSE;
	go_needed[2] = FALSE;

	switch (me->type)
	{
		case DMkeypt:
		size = sizeof(struct DMkeypt_str);
		ptr = (char *)&src_info->var.dm_keypt;
		cptr = (char *)&dmstr.var.dm_keypt;
		exp_count = 1;
		break;

		case DMkeyseg:
		size = sizeof(struct DMkeyseg_str);
		ptr = (char *)&src_info->var.dm_keyseg;
		cptr = (char *)&dmstr.var.dm_keyseg;
		exp_count = 1;
		break;

		case DMaxis:
		size = sizeof(struct DMaxis_str);
		ptr = (char *)&src_info->var.dm_axis;
		cptr = (char *)&dmstr.var.dm_axis;
		exp_count = 2;
		break;

		case DM2ptseg:
		size = sizeof(struct DM2ptseg_str);
		ptr = (char *)&src_info->var.dm_2ptseg;
		cptr = (char *)&dmstr.var.dm_2ptseg;
		go_needed[1] = TRUE;
		exp_count = 2;
		break;

		case DMradcen:
		size = sizeof(struct DMradcen_str);
		ptr = (char *)&src_info->var.dm_radcen;
		cptr = (char *)&dmstr.var.dm_radcen;
		exp_count = 2;
		break;

		case DMtanpt:
		size = sizeof(struct DMtanpt_str);
		ptr = (char *)&src_info->var.dm_tanpt;
		cptr = (char *)&dmstr.var.dm_tanpt;
		exp_count = 2;
		break;

		case DMmidpt:
		size = sizeof(struct DMmidpt_str);
		ptr = (char *)&src_info->var.dm_midpt;
		cptr = (char *)&dmstr.var.dm_midpt;
		exp_count = 1;
		break;

		case DMptdist:
		size = sizeof(struct DMptdist_str);
		ptr = (char *)&src_info->var.dm_ptdist;
		cptr = (char *)&dmstr.var.dm_ptdist;
		exp_count = 1;
		break;

		case DMarc:
		size = sizeof(struct DMarc_str);
		ptr = (char *)&src_info->var.dm_arc;
		cptr = (char *)&dmstr.var.dm_arc;
		exp_count = 2;
		break;

		case DMintpt:
		size = sizeof(struct DMintpt_str);
		ptr = (char *)&src_info->var.dm_intpt;
		cptr = (char *)&dmstr.var.dm_intpt;
		exp_count = 3;
		go_needed[1] = TRUE;
		break;

		case DMcenpt:
		size = sizeof(struct DMcenpt_str);
		ptr = (char *)&src_info->var.dm_cenpt;
		cptr = (char *)&dmstr.var.dm_cenpt;
		exp_count = 2;
		break;

		case DMedgept:
		size = sizeof(struct DMedgept_str);
		ptr = (char *)&src_info->var.dm_edgept;
		cptr = (char *)&dmstr.var.dm_edgept;
		exp_count = 2;
		break;

		case DMedgeseg:
		size = sizeof(struct DMedgeseg_str);
		ptr = (char *)&src_info->var.dm_edgeseg;
		cptr = (char *)&dmstr.var.dm_edgeseg;
		exp_count = 2;
		break;

		default:
		printf("DMgive_src_info: Invalid type %d\n", me->type);
		return(OM_E_ABORT);
	}

	if (om$dimension_of(varray = me->data) != size)
	{
		printf("DMgive_src_info: SIZE MISMATCH\n");
		return(OM_E_ABORT);
	}

	status =
	om$send(msg = message DMsrc.DMgive_structure(
						&rc,
						type,
						FALSE,
						&dmstr,
						md_env),
			targetid = my_id);
	dm$status(action = RET_STATUS);
						
	memcpy(ptr, cptr, size);

	/*| - NDget objects   */

        status =
        om$send(msg = message NDnode.NDget_objects(
                                        ND_ROOT,
                                        list,
                                        2,
                                        NULL,
                                        0,
                                        OM_K_MAXINT,
                                        &act_count),
                targetid = my_id);
        dm$status(action = RET_STATUS);


	/*^
		printf("act_count=%d\n", act_count);

		for (index=0; index<act_count; index++)
			printf("list[%d]=%d,%d\n",
				index,
				list[index].objid,
				list[index].osnum);
	*/

	if (me->type == DM2ptseg && act_count == 1)
	{
		act_count = 2;
		list[1] = list[0];
	}

	if (act_count != exp_count)
	{
		/*| - Src degraded - */

		for (index=0; index<exp_count; index++)
			src_info->parents[index].objid =
			src_info->context[index].objid = NULL_OBJID;

		src_info->degraded = TRUE;
		*msg = DIM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	src_info->degraded = FALSE;
	src_info->num_parents = act_count;

	for (index=0; index<act_count; index++)
	{
		if (go_needed[index])
		{
			status =
			om$send(msg = message NDnode.ASreturn_go(
							&src_info->parents[index],
							&matrix_type,
							matrix),
				targetid = list[index].objid,
				targetos = list[index].osnum);
			dm$status(action = RET_STATUS);

			status =
			GRfindcontext(
				&rc,
				&matrix_type,
				matrix,
				&src_info->parents[index].osnum,
				&src_info->context[index]);
			if (status != OM_S_SUCCESS || rc != MSSUCC)
				src_info->context[index].objid = NULL_OBJID;
		}
		else
		{
			src_info->parents[index] = list[index];
			src_info->context[index].objid = NULL_OBJID;
		}
	}

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMmodify(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint key;
	IGRboolean ptdist;
	struct IGRline *boreline)
{
	IGRint status, rc;
	IGRlong long_rc;
	IGRint index, count;
	BSrc	bsrc;

	struct IGRbsp_curve *bsp_curve, *proj_curve, *conv_curve;
	IGRdouble *dim_normal, *cv_normal, *point_on_cv;
	IGRdouble radius, *center, upar_low, upar_high, tol;
	IGRboolean planes_parallel, const_radius, dynamics_on;

	struct DMradcen_str dm_radcen;
	struct GRid list[2];

	struct GRid go;
	short matrix_type;
	IGRmatrix matrix;

	IGRpoint pt;
	IGRdouble ptproj[3];
	IGRdouble ln_pt[3], t;
	IGRvector cent_ptproj, cent_endpt1, cent_endpt2;
	IGRdouble endpt1[3], endpt2[3], angle1, angle2;
	struct GRparms par;

	IGRdouble dist;
	IGRint side;
	IGRshort num_par;
	IGRboolean cv_flag;
	GRclassid subclassid;

	/*| - Entering DMmodify method */

	if (me->type == DMarc)
	{
		*msg = OM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message NDnode.NDget_objects(
						ND_ROOT,
						list,
						2,
						NULL,
						0,
						1,
						&count),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->type != DMradcen)
	{
		if (me->type == DM2ptseg)
			index = key?1:0;
		else	index = 0;

		status =
		om$send(msg = message NDnode.ASreturn_go(&go, &matrix_type, matrix),
			targetid = list[0].objid,
			targetos = list[0].osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message GRgraphics.GRlnproject(
							&long_rc,
							&matrix_type,
							matrix,
							boreline,
							ln_pt,
							ptproj,
							&t,
							&par),
			targetid = go.objid,
			targetos = go.osnum);
		dm$status(action = RET_STATUS);

		switch (me->type)
		{
			case DMkeypt:

			{
				struct DMkeypt_str str;

				memcpy(&str, me->data, sizeof(str));
				str.u_par = par.u;
				memcpy(me->data, &str, sizeof(str));
			}
			break;

			case DMtanpt:

			{
				struct DMtanpt_str str;

				memcpy(&str, me->data, sizeof(str));
				str.u_par = par.u;
				memcpy(me->data, &str, sizeof(str));
			}
			break;

			case DMmidpt:

			{
				struct DMmidpt_str str;

				memcpy(&str, me->data, sizeof(str));
				str.u_par = par.u;
				memcpy(me->data, &str, sizeof(str));
			}
			break;

			case DMptdist:

			{
				struct DMptdist_str str;

				memcpy(&str, me->data, sizeof(str));

				status =
				om$get_classid(
					objid = go.objid,
					osnum = go.osnum,
					p_classid = &subclassid);
				dm$status(action = RET_STATUS);

				if(om$is_ancestry_valid(subclassid = subclassid,
				superclassid = OPP_GRtext_class_id) == OM_S_SUCCESS)
				{
					/*| - Object is GRtext class */
	
					MATH_get_box_pt_upar(
						&rc,
						(ptdist)?TRUE:FALSE,
						&str.u_par,
						ptproj,
						list[0],
						md_env);
				}
				else
				{
					if(ptdist)
					{
						str.u_par = par.u;
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
							targetid = go.objid,
							targetos = go.osnum);
						dm$status(action = RET_STATUS);

						BScveval(bsp_curve, str.u_par, 0, ptproj, &bsrc);
						if (bsrc != BSSUCC)
						{
							printf("DMmodify: BScveval failure\n");
							return(OM_E_ABORT);
						}
					}	
				}

				for(index=0; index<3; index++)
				{
				   str.vec[index] = (key)?
						(boreline->point1[index]
						- ptproj[index]):0;
				}

				/*^
					printf("ptdist=%d, key=%d\n",ptdist,key);
					printf("upar: %f\n",str.u_par);
					print_point("vec",str.vec);
					print_point("point",str.point);
					print_point("ptproj",ptproj);
					print_point("boreline.p1",boreline->point1);
				*/
	
				memcpy(me->data, &str, sizeof(str));
			}
			break;

			case DMkeyseg:

			{
				struct DMkeyseg_str str;

				memcpy(&str, me->data, sizeof(str));
				str.u_par = par.u;
				memcpy(me->data, &str, sizeof(str));
			}
			break;

			case DM2ptseg:

			{
				struct DM2ptseg_str str;

				memcpy(&str, me->data, sizeof(str));
				if (index)
					str.u_par1 = par.u;
				else	str.u_par2 = par.u;
				memcpy(me->data, &str, sizeof(str));
			}
			break;

			case DMaxis:

			{
				struct DMaxis_str str;

				memcpy(&str, me->data, sizeof(str));
				str.u_par = par.u;
				memcpy(me->data, &str, sizeof(str));
			}
			break;
		};

		status =
		om$send(msg = message NDnode.NDcompute_node(
						&long_rc,
						0,
						count,
						list,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*|- Leaving DMmodify method */

		*msg = OM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	memcpy(&dm_radcen, me->data, sizeof(dm_radcen));

	status = DMload_cache(list, TRUE, FALSE, NULL, md_env);
	dm$status(action = RET_STATUS);

	status =
	DMget_cache_data(
		&bsp_curve,
		&proj_curve,
		&conv_curve,
		&dynamics_on,
		&point_on_cv,
		&cv_normal,
		&dim_normal,
		&planes_parallel,
		&const_radius,
		&center,
		&radius,
		&upar_low,
		&upar_high);
	dm$status(action = RET_STATUS);

	/*^
		printf("bsp_curve=%d\n", bsp_curve);
		printf("proj_curve=%d\n", proj_curve);
		printf("conv_curve=%d\n", conv_curve);
		printf("center=%d\n", center);
		printf("dim_normal=%d\n", dim_normal);
		printf("point_on_cv=%d\n", point_on_cv);
		printf("upar_low = %f\n",upar_low);
		printf("upar_high = %f\n", upar_high);
	*/

	/*| Boreline project onto dimension plane */
	BSxlnpl(&bsrc,
		dim_normal,
		point_on_cv,
		boreline->point1,
		boreline->point2,
		ptproj);
	if (bsrc != BSSUCC)
	{
		/*|BSxlnpl fails*/
		return(OM_E_ABORT);
	}
	if(conv_curve->order > 2
           && conv_curve->num_poles > 3)

        {
		if(upar_low == 0.0 && upar_high == 1.0)
	     {
		 status = BSperpa(&bsrc,
                	conv_curve,
                	ptproj,
                	ptproj,
                	&num_par,
                	&dm_radcen.u_par,
                	&side);
        	if (!status || bsrc != BSSUCC)
        	{
                /*| BSperpa fails */
                return(OM_E_ABORT);
        	}
	      }
		else
	      {
		status = BSperpa(&bsrc,
                        conv_curve,
                        ptproj,
                        ptproj,
                        &num_par,
                        &dm_radcen.u_par,
                        &side);
                if (!status || bsrc != BSSUCC)
                {
                /*| BSperpa fails */
                return(OM_E_ABORT);
                }
		(void)BSEXTRACTPAR(&bsrc,BSTOLKNOT,tol);
		if(dm_radcen.u_par < upar_high && dm_radcen.u_par > upar_low)
		num_par = 1;
		else num_par = 0;
		if(num_par == 0)
			{
			upar_low = upar_low + tol;
			upar_high = upar_high - tol;
			dm_radcen.on_curve = FALSE;
			BScveval(conv_curve, upar_low, 0, endpt1, &bsrc);
			if(bsrc != BSSUCC) return(OM_E_ABORT);
			BScveval(conv_curve, upar_high, 0, endpt2, &bsrc);
                        if(bsrc != BSSUCC) return(OM_E_ABORT); 
			BSmkvec(&bsrc, cent_ptproj, center, ptproj);
			BSnorvec(&bsrc, cent_ptproj);
			BSmkvec(&bsrc, cent_endpt1, center, endpt1);
			BSnorvec(&bsrc, cent_endpt1);
			BSmkvec(&bsrc, cent_endpt2, center, endpt2);
			BSnorvec(&bsrc, cent_endpt2);
		angle1=fabs(acos(BSdotp(&bsrc, cent_ptproj, cent_endpt1)));
                angle2=fabs(acos(BSdotp(&bsrc, cent_ptproj, cent_endpt2)));
                	if(angle1 > angle2) angle1 = PI - angle1;
                	else angle2 = PI - angle2;
                	if(angle1 > angle2)
                	{
                       	 math_v_equal(dm_radcen.point, endpt2);
                       	 dm_radcen.u_par = upar_high;
                	}
                	else
                	{
                       	 math_v_equal(dm_radcen.point, endpt1);
                       	 dm_radcen.u_par = upar_low;
                	}  
	      		}
		}	

        }
	else {
	status =
	BSperpa(&bsrc,
		conv_curve,
		ptproj,
		ptproj,
		&num_par,
		&dm_radcen.u_par,
		&side);
	if (!status || bsrc != BSSUCC)
	{
		/*| BSperpa fails */
		return(OM_E_ABORT);
	}
	}

	if (num_par)
	{
		/*| BSperpa success */

		dm_radcen.on_curve = TRUE;

		BScveval(conv_curve, dm_radcen.u_par, 0, dm_radcen.point, &bsrc);
		if (bsrc != BSSUCC)
		{
			/*"BScveval fails: rc=%d\n", rc*/
			return(OM_E_ABORT);
		}

		if (!planes_parallel)
		{
			BSmdstptcv(
				proj_curve,
				dm_radcen.point,
				&dm_radcen.u_par,
				pt,
				&dist,
				&bsrc);
			if (bsrc != BSSUCC)
			{
				/*"BSmdstptcv fails: rc=%d\n", rc*/
				return(OM_E_ABORT);
			}

			math_v_equal(dm_radcen.point, pt);
		}
	}
	else        
	{
		if(upar_low == 0 && upar_high == 1)
	{
		/*| NOT ON CURVE */

		dm_radcen.on_curve = FALSE;

		BScveval(conv_curve, 0.0, 0, endpt1, &bsrc);
		if (bsrc != BSSUCC)
		{
			/*"BScveval fails: rc=%d\n", rc*/
			return(OM_E_ABORT);
		}

		BScveval(conv_curve, 1.0, 0, endpt2, &bsrc);
		if (bsrc != BSSUCC)
		{
			/*"BScveval fails: rc=%d\n", rc*/
			return(OM_E_ABORT);
		}

		BSmkvec(&bsrc, cent_ptproj, center, ptproj);
		BSnorvec(&bsrc, cent_ptproj);

		BSmkvec(&bsrc, cent_endpt1, center, endpt1);
		BSnorvec(&bsrc, cent_endpt1);
	
		BSmkvec(&bsrc, cent_endpt2, center, endpt2);
		BSnorvec(&bsrc, cent_endpt2);

		angle1=fabs(acos(BSdotp(&bsrc, cent_ptproj, cent_endpt1)));
		angle2=fabs(acos(BSdotp(&bsrc, cent_ptproj, cent_endpt2)));

		if(angle1 > angle2)
			angle1 = PI - angle1;
		else	angle2 = PI - angle2;
		if(angle1 > angle2)
		{
			math_v_equal(dm_radcen.point, endpt2);
			dm_radcen.u_par = 1.0;
		}
		else
		{
			math_v_equal(dm_radcen.point, endpt1);
			dm_radcen.u_par = 0.0;
		}
	}
	}

	if (!planes_parallel)
	{
		pt[0] = dm_radcen.point[0] + dim_normal[0];
		pt[1] = dm_radcen.point[1] + dim_normal[1];
		pt[2] = dm_radcen.point[2] + dim_normal[2];

		BSxlnpl(&bsrc,
			cv_normal,
			point_on_cv,
			dm_radcen.point,
			pt,
			ptproj);
		if (bsrc != BSSUCC)
		{
			/*|BSxlnpl fails*/
			return(OM_E_ABORT);
		}

		math_v_equal(dm_radcen.point, ptproj);

		status =
		BSprptoncv(
			&bsrc,
			bsp_curve,
			dm_radcen.point,
			&dm_radcen.u_par,
			&cv_flag);
		if (!status || bsrc != BSSUCC)
		{
			printf("DMmodify: BSprptoncv fails\n");
			return(OM_E_ABORT);
		}
	}

	/*"u_par=%lf\n", dm_radcen.u_par*/

	memcpy(me->data, &dm_radcen, sizeof(dm_radcen));

	if (!const_radius)
	{
		status =
		om$send(msg = message DMsrc.DMradcen_compute(
							&rc,
							md_env,
							count,
							list),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (!dynamics_on)
		DMclear_cache();

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMgive_tangent(
	IGRint *msg;
	IGRboolean *src_type;
	IGRdouble tangent[3];
	IGRdouble box[4][3];
	struct GRmd_env *md_env)
{
	IGRint status, rc, i, box_num;
	IGRlong	long_rc;
	IGRint num_pts, index, count, p_index;
	IGRdouble poles[15], knots[7], weights[5];
	IGRdouble pts[5][3], nvec[3], point[6];
	IGRdouble *pole, keypt[3], upar;
	struct ret_struct text_inst;
	struct DMptdist_str ptdist;
	struct DMkeypt_str dmkeypt;
	struct IGRbsp_curve *bsp_curve, lin_curve;
	struct GRid src_grid, go_grid;
	struct GRparms par;
	struct IGRplane igr_plane;
	struct IGRline boreline;
	IGRdouble cv_normal[3], cv_point[3], point2[3];
	IGRdouble dist, dist1, dist2;
	struct GRmd_env mod_info;
	BSrc	bsrc;

	*msg = OM_S_SUCCESS;

	/*| - Return graphic object */

	if ((me->type != DMptdist) && (me->type != DMkeypt))
		return(OM_E_ABORT);

	status =
	om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					&src_grid,
					1,
					NULL,
					0,
					0,
					&count),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (count == 0)
	{
		/*|- Parent is degarded */

		if (src_type) *src_type = POINT_TYPE;

		if (box)
		{
			if (me->type == DMptdist)
			{
				memcpy(&ptdist, me->data, sizeof(ptdist));
				math_v_equal(box[0], ptdist.point);
				math_v_equal(box[1], ptdist.point);
			}
			else
			{
				memcpy(&dmkeypt, me->data, sizeof(dmkeypt));
				math_v_equal(box[0], dmkeypt.point);
				math_v_equal(box[1], dmkeypt.point);
			}

			if (md_env->md_env.matrix_type != MAIDMX)
			{
				DMtransform_point(box[0],
					md_env->md_env.matrix);
				DMtransform_point(box[1],
					md_env->md_env.matrix);
			}
		}
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message NDnode.ASreturn_go(
					&go_grid,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
		targetid = src_grid.objid,
		targetos = src_grid.osnum);
	dm$status(action = RET_STATUS);

	/*^
		printf("go_grid = %d, %d\n",go_grid.objid, go_grid.osnum);
		printf("src_grid = %d, %d\n",src_grid.objid, src_grid.osnum);
	*/

	if (DMancestry_valid(go_grid, OPP_GRtext_class_id))
	{
		/*| - Object is of GRtext class */

		if(src_type) *src_type = TEXT_TYPE;
		
		as$any_give_structure(
			go_grid = go_grid,
			mod_env = &mod_info,
			inst = &text_inst);

		MATH_get_box_points(&rc, (struct IGRlbsys *) &text_inst.var.lb_st, pts);
		math_v_equal(pts[4], pts[0]);

		lin_curve.poles = poles;
		lin_curve.knots = knots;
		lin_curve.weights = weights;

		bsp_curve = &lin_curve;
		num_pts = 5;

		status =
		BSlininter(&bsrc, &num_pts, pts, bsp_curve, nvec);
		if( !status || bsrc != BSSUCC)
		{
			/*"BSlininter fails: rc=%d, status=%d\n", rc, status*/
			return(OM_E_ABORT);
		}
	}
	else
	{
		/*| - Object is of class GRcurve */

		if (DMancestry_valid(go_grid, OPP_GR3dpoint_class_id))
		{
			/*| - Object is of GR3dpoint class */

			if(src_type) *src_type = POINT_TYPE;
		}
		else
		{
			/*| - Object is of Line/Linestring class */

		 	if(src_type) *src_type = LINE_TYPE;
		}

		status =
		om$send(msg = message GRvg.GRgenabsg(
						&long_rc,
						&mod_info.md_env.matrix_type,
						mod_info.md_env.matrix,
						(char **)&bsp_curve),
			targetid = go_grid.objid,
			targetos = go_grid.osnum);
		dm$status(action = RET_STATUS);

		if (bsp_curve->order > 2)
		{
		 	if(src_type) *src_type = ARC_TYPE;
		}
	}

	if (me->type == DMptdist)
	{
		memcpy(&ptdist, me->data, sizeof(ptdist));
		upar = ptdist.u_par;
	}
	else
	{
		memcpy(&dmkeypt, me->data, sizeof(dmkeypt));
		upar = dmkeypt.u_par;
	}

	BScveval(bsp_curve, upar, 1, point, &bsrc);
	if (bsrc != BSSUCC)
	{
		/*"BScveval fails line:%d rc=%d\n",__LINE__, rc*/
		return(OM_E_ABORT);
	}

	for(index=0; index<3; index++)
	   tangent[index] = point[index + 3];

	if (box)
	{
		box_num = 2;

		if(*src_type == TEXT_TYPE)
		{
			box_num = 4;

			for(index=0; index<4; index++)
			{
				math_v_equal(box[index], pts[index]);
			}
		}
		else if(*src_type == LINE_TYPE)
		{
			if(bsp_curve->num_poles == 2)
				memcpy(box, bsp_curve->poles, 6*sizeof(double));
			else if(bsp_curve->num_poles > 2)
			{
				igr_plane.point  = cv_point;
				igr_plane.normal = cv_normal;

				status =
				om$send(msg = message GRvg.GRdetplane(
							&long_rc,
							&mod_info.md_env.matrix_type,
							mod_info.md_env.matrix,
							&igr_plane),
					targetid = go_grid.objid,
					targetos = go_grid.osnum);
				dm$status(action = RET_STATUS);

				boreline.point1 = point;
				boreline.point2 = point2;

				point2[0] = point[0] + cv_normal[0];
				point2[1] = point[1] + cv_normal[1];
				point2[2] = point[2] + cv_normal[2];


				status =
				om$send(msg = message GRvg.GRkeypoint(
							&long_rc,
							&mod_info.md_env.matrix_type,
							mod_info.md_env.matrix,
							&boreline,
							keypt,
							&par),
				targetid = go_grid.objid,
				targetos = go_grid.osnum);
				dm$status(action = RET_STATUS);

				index = -1;
				for (i=0; i<bsp_curve->num_poles; i++)
				{
					pole = &bsp_curve->poles[3*i];
					if ((fabs(pole[0] - keypt[0]) < 1e-09)
					&&  (fabs(pole[1] - keypt[1]) < 1e-09)
					&&  (fabs(pole[2] - keypt[2]) < 1e-09))
					{
						index = i;

						/*^
							printf("index=%d\n", index);
							print_point("pole_i", pole);
						*/

						break;
					}
				}

				if (index < 0)
				{
					*msg = DIM_E_BSMATH;
					return(OM_S_SUCCESS);
				}			

				pole = bsp_curve->poles;

				if(index == 0)
				{
					if(bsp_curve->phy_closed)
					{
						dist1 = BSdistptpt(&bsrc, point, &pole[0]);
						dist2 = BSdistptpt(&bsrc, point, &pole[3]);
						dist  = BSdistptpt(&bsrc, &pole[0], &pole[3]);

						if (fabs(dist - dist1 - dist2) > 1e-9)
							p_index = bsp_curve->num_poles - 2;
						else	p_index = 1;
					}
					else	p_index = 1;
				}
				else if (index == bsp_curve->num_poles - 1)
					p_index = bsp_curve->num_poles - 2;
				else
				{
					p_index = index + 1;

					dist1 = BSdistptpt(&bsrc, point, &pole[3*index]);
					dist2 = BSdistptpt(&bsrc, point, &pole[3*p_index]);
					dist  = BSdistptpt(&bsrc, &pole[3*index], &pole[3*p_index]);

					/*"dist=%lf, dist1=%lf, dist2=%lf\n", dist, dist1, dist2*/

					if (fabs(dist - dist1 - dist2) > 1e-9)
						p_index = index - 1;
				}

				for(i=0; i<3; i++)
				{
					box[0][i] = bsp_curve->poles[p_index*3+i];
					box[1][i] = bsp_curve->poles[index*3+i];
				}
			}
		}
                else if(*src_type == ARC_TYPE)
                {
                        /* Arc type */
                        BScveval(bsp_curve, upar, 0, box[0], &rc);
                        for( i = 0; i < 3;i++)
                                box[1][i] = box[0][i]+ tangent[i];
                }

		if (md_env->md_env.matrix_type != MAIDMX)
		{
		    for(index=0; index<box_num; index++)
			DMtransform_point(box[index],md_env->md_env.matrix);
		}
	}

	/*^ print_point("tangent",tangent); */

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method NDmove_to_root(
	IGRlong *msg;
	struct GRid *src_grid;
	struct GRmd_env *md_env)
{
	IGRint status;
	IGRchar my_state;
	extern IGRboolean ASbroadcast_in_progress;

	print_grid("src_grid",src_grid);

 	status = om$send(msg = message NDnode.NDget_state(&my_state),
       	           targetid = my_id);
 	if((status & 1) && (my_state & ND_DONT_MVRT))
   	{
		status =
		om$send(msg = message NDnode.NDmove_to_root(
					msg, src_grid, md_env),
			targetid = my_id,
			mode = OM_e_wrt_message);
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message NDnodein.NDmove_to_root(
				msg, src_grid, md_env),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message NDnode.NDchg_state(ND_DEGRADED, ND_DEGRADED),
		targetid = my_id);
	dm$status(action = RET_STATUS);

        print_grid("src_grid",src_grid);
	status =
	om$send(msg = message DMroot.set_degrade(md_env),
		senderid = my_id,
		p_chanselect = &ND_children);
	/*
	 * I don't worry about the status (setting degrade to children objects) 
         * as it causes some problem while setting to DMplan objects.
	 * ---11/16/93 Commented By GMK,  directed By GVK
	 dm$status(action = RET_STATUS);
	 */

        *msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMdisplay_source(
	IGRint *msg;
	IGRdouble *tolerance;
	struct IGRline *boreline;
	IGRint *display;
	struct GRmd_env *md_env)
{
	IGRint status, rc, count;
	IGRlong long_rc;
	IGRshort matrix_type;
	IGRdouble ptproj[3], ln_pt[3], t, dist;
	IGRmatrix matrix;
	struct GRid src_grid, go_grid;
	struct GRparms par;
	BSrc	bsrc;

	status =
	om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					&src_grid,
					1,
					NULL,
					0,
					0,
					&count),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message NDnode.ASreturn_go(
					&go_grid,
					&matrix_type,
					matrix),
		targetid = src_grid.objid,
		targetos = src_grid.osnum);
	dm$status(action = RET_STATUS);

	/*^
		printf("go_grid = %d, %d\n",go_grid.objid, go_grid.osnum);
		printf("src_grid = %d, %d\n",src_grid.objid, src_grid.osnum);
	*/

	status =
	om$send(msg = message GRgraphics.GRlnproject(
						&long_rc,
						&matrix_type,
						matrix,
						boreline,
						ln_pt,
						ptproj,
						&t,
						&par),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	dist = BSdistptpt(&bsrc, boreline->point1, ptproj);

	if (dist < *tolerance)
		*display = 1;
	else	*display = 0;

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}
	
method get_dimension_plane(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct GRid *plan;
	struct DMplan_info *plan_info)
{
	IGRint status, count;
	struct GRid grid;

	if (!plan)
	{
		plan = &grid;
		grid.objid = NULL_OBJID;
	}

	if (plan->objid == NULL_OBJID)
	{
		status =
		om$get_channel_count(
			object = me,
			p_chanselect = &ND_father,
			count = (OMuint *)&count);
		dm$status(action = RET_STATUS);

		status =
		om$get_objid_at_index(
			object = me,
			p_chanselect = &ND_father,
			index = count - 1,
			objidaddr = &plan->objid,
			osnumaddr = &plan->osnum);
		dm$status(action = RET_STATUS);
	}

	status =
	dm$get_plan_info(
		plan_objid = plan->objid,
		osnum = plan->osnum,
		md_env = md_env,
		plan_info = plan_info);
	dm$status(action = RET_STATUS);

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method NDmake_source(
	IGRlong *msg;
	struct GRid *located_obj;
	struct GRid *context;
	char *path;
	GRspacenum as_osnum;
	struct GRid *as)
{
	struct GRid owner, mygrid;

	mygrid.objid = my_id;
	mygrid.osnum = OM_Gw_current_OS;
	owner.objid  = NULL_OBJID;

	ASget_as_owner(&mygrid, &owner);

	if ((owner.objid != NULL_OBJID) &&
		(located_obj->objid != my_id))
	{
		/*| assoc owner */

		printf(" ERROR:No owner should be present\n");
		*msg = MSFAIL;
		return(OM_W_ABORT);
	}


	if (located_obj->objid == my_id
	&&  located_obj->osnum == as_osnum)
	{
		as->objid = my_id;
		as->osnum = OM_Gw_current_OS;

		*msg = OM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	ASmake_source_from_go(msg,located_obj,context,as_osnum,as); 

	return(OM_S_SUCCESS);
}

method GRxform(
	IGRlong *msg;
	struct GRmd_env *md_env;
	IGRshort *matrix_type;
	IGRmatrix matrix;
	GRobjid *newobjid)
{
	IGRint status, size;
	IGRlong long_rc;
	IGRchar my_state, *ptr;
	IGRdouble *pt1, *pt2, *ctr;
	struct DMkeypt_str	dm_keypt;
	struct DMkeyseg_str	dm_keyseg;
	struct DM2ptseg_str	dm_2ptseg;
	struct DMaxis_str	dm_axis;
	struct DMradcen_str	dm_radcen;
	struct DMtanpt_str	dm_tanpt;
	struct DMintpt_str	dm_intpt;
	struct DMmidpt_str	dm_midpt;
	struct DMptdist_str	dm_ptdist;
	struct DMarc_str	dm_arc;
	struct DMcenpt_str	dm_cenpt;
	struct DMedgept_str	dm_edgept;
	struct DMedgeseg_str	dm_edgeseg;
	struct DMpt_str		dm_pt;
	struct DMln_str		dm_line;

	status =
	om$send(msg = message NDnode.NDget_state(&my_state),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	pt1 = pt2 = ctr = NULL;
	if (my_state & ND_DEGRADED)
	{
		/*|- DMsrc is degarded apply transformation to instance */

		switch (me->type)
		{
			case DMkeypt:

			size = sizeof(dm_keypt);
			ptr = (char *)&dm_keypt;
			pt1 = (double *)dm_keypt.point;
			break;

			case DMkeyseg:

			size = sizeof(dm_keyseg);
			ptr = (char *)&dm_keyseg;
			pt1 = (double *)dm_keyseg.line;
			pt2 = (double *)&dm_keyseg.line[3];
			break;

			case DMaxis:

			size = sizeof(dm_axis);
			ptr = (char *)&dm_axis;
			pt1 = (double *)dm_axis.line;
			pt2 = (double *)&dm_axis.line[3];
			break;

			case DM2ptseg:

			size = sizeof(dm_2ptseg);
			ptr = (char *)&dm_2ptseg;
			pt1 = (double *)dm_2ptseg.line;
			pt2 = (double *)&dm_2ptseg.line[3];
			break;

			case DMradcen:

			size = sizeof(dm_radcen);
			ptr = (char *)&dm_radcen;
			pt1 = (double *)dm_radcen.point;
			ctr = (double *)dm_radcen.center;
			break;

			case DMtanpt:

			size = sizeof(dm_tanpt);
			ptr = (char *)&dm_tanpt;
			pt1 = (double *)dm_tanpt.point;
			break;

			case DMmidpt:

			size = sizeof(dm_midpt);
			ptr = (char *)&dm_midpt;
			pt1 = (double *)dm_midpt.point;
			break;

			case DMptdist:

			size = sizeof(dm_ptdist);
			ptr = (char *)&dm_ptdist;
			pt1 = (double *)dm_ptdist.point;
			break;

			case DMarc:

			size = sizeof(dm_arc);
			ptr = (char *)&dm_arc;
			pt1 = (double *)dm_arc.start_pt;
			pt2 = (double *)dm_arc.end_pt;
			ctr = (double *)dm_arc.center;
			break;

			case DMintpt:

			size = sizeof(dm_intpt);
			ptr = (char *)&dm_intpt;
			pt1 = (double *)dm_intpt.point;
			break;

			case DMcenpt:

			size = sizeof(dm_cenpt);
			ptr = (char *)&dm_cenpt;
			pt1 = (double *)dm_cenpt.point;
			break;

			case DMedgept:

			size = sizeof(dm_edgept);
			ptr = (char *)&dm_edgept;
			pt1 = (double *)dm_edgept.point;
			break;

			case DMedgeseg:

			size = sizeof(dm_edgeseg);
			ptr = (char *)&dm_edgeseg;
			pt1 = (double *)dm_edgeseg.line;
			pt2 = (double *)&dm_edgeseg.line[3];
			break;

			default:

			/*"Invalid type = %d\n", me->type*/
			return(OM_E_ABORT);
		}

		memcpy(ptr, me->data, size);

		if (pt1) DMtransform_point(pt1, matrix);
		if (pt2) DMtransform_point(pt2, matrix);
		if (ctr) DMtransform_point(ctr, matrix);

		memcpy(me->data, ptr, size);

		*newobjid = my_id;
	}
	else if (me->type == DMconstpt || me->type == DMconstln)
	{
		if( me->type == DMconstpt)
		{
			ptr = (char *) &dm_pt;
			size = sizeof(struct DMpt_str);
			pt1 = (double *)dm_pt.point;
		}
		else if (me->type == DMconstln)
		{
			ptr = (char *) &dm_line;
			size = sizeof(struct DMln_str);
			pt1 = (double *)dm_line.line;
			pt2 = (double *)&dm_line.line[3];
		}

		memcpy(ptr,me->data,size);
		if (pt1)
		{
			pt1[0] = matrix[3];
			pt1[1] = matrix[7];
			pt1[2] = matrix[11];
		}
		if (pt2)
		{
			pt2[0] = matrix[3];
			pt2[1] = matrix[7];
			pt2[2] = matrix[11];
		}
		memcpy(me->data, ptr, size);
	}
	else 
	{
		status =
		om$send(msg = message NDnode.NDs_compute_node(&long_rc, ND_COMP, md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

end implementation DMsrc;
