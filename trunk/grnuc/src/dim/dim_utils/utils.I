/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:33 $
$Locker:  $
$Log: utils.I,v $
Revision 1.1.1.1  2001/12/17 22:39:33  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:10:03  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.3  1996/12/31  07:24:30  skathiri
# COMMENT : Changes for RFA+Assembly
#
# Revision 330.2  1996/10/18  08:40:28  skathiri
# COMMENT : Changes for RFA, part of house keeping chores
#
# Revision 330.1  1996/03/27  13:08:51  skathiri
# COMMENT : Changes for Reference File activation
#
# Revision 330.0  1996/01/11  21:24:12  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.1  1995/06/13  09:00:49  gvk
# COMMENT : New parameter object will be created during edits for annotations.
#
# Revision 320.0  1994/12/12  17:53:34  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.5  1994/11/01  10:12:43  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.4  1994/09/23  11:31:19  gvk
# COMMENT : Cannot use toggle term icon on the form to switch terminators during dynamics.
#
# Revision 400.1  1994/05/11  14:17:05  gvk
# COMMENT : Dim parameters are reflected during dynamics.
#
# Revision 240.3  1993/09/27  09:34:06  samuel
# COMMENT : Fix for TR119310615
#
# Revision 240.2  1993/09/07  06:22:26  samuel
# COMMENT : CR11925349 - Fix for a partucular case which was not working
#
# Revision 240.1  1993/08/03  05:42:36  laxmi
# COMMENT : Dimensioning 2.4 CR and TR fixes checkin. -Laxmi
#
# Revision 240.0  1992/12/06  23:49:18  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.2  1992/10/19  21:12:50  poo
# COMMENT : Fix to handle Coordinate system as a dimension plane or dimensions parent.
#
Revision 201.35  1992/08/07  09:41:18  poo
COMMENT : Fix for surface texture symbol.

Revision 201.34  1992/08/03  18:25:38  grnuc20
COMMENT : ANSI conversion stuff

Revision 201.33  1992/07/29  18:54:58  poo
COMMENT : Initial Release of Surface Finish & Jogged bug fixes

Revision 201.32  1992/07/19  15:33:11  gvk
COMMENT : ANSI compilation and deleting obsolete functions.

Revision 201.27  1992/02/12  09:52:26  dimdp20
COMMENT : Fix for auto dimension (text with leader) S. Poovannan - 12 Feb. '92

Revision 201.26  1992/02/12  07:18:56  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - 12 Feb. 1992

Revision 201.24  1992/01/13  05:59:15  dimdp20
COMMENT : Dimensioning fixes release  - 13th Jan 92

*/

class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "dimdef.h"
#include "dimlinear.h"
#include "dimgraph.h"
#include "griodef.h"
#include "griomacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msmacros.h"
#include "DMmsg.h"
#include "dimweld.h"

from DMsuper import get_dim_param, set_dim_stan;
from DMsuper import update_dim_param, pass_message;
from DMplan_mgr import get_dim_plane;
from dim_param import give_internal;
from dim_plan import give_info, give_plane;
from Super_rfmgr import GRget_channel_count, GRget_channel_objects;
from GRreffile import GRgetenvironment;
from expression import NDgive_value, give_formula;
from dim_src import DMgive_structure;
from GRtext import GRgettxattr;

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "matypemx.h"
#include "maoptsxfo.h"
#include "mamulmx.h"
#include "maidmx.h"
#include "bsprepcirc.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"

#include "actparam.h"

static IGRboolean aflag;
static struct GRmd_env rfenv;


#define TOLERANCE     1.0e-6

extern IGRboolean BSproj0();
IGRint DMget_mea_trak (mea_trak,plan_info,mea_axis,
perp_axis,trak_dir)
/*(
	 IGRchar  mea_trak,
	 struct DMplan_info  *plan_info,
	 IGRdouble  mea_axis[3],
	 IGRdouble  perp_axis[3],
	 IGRdouble  trak_dir[3]
	)
*/
IGRchar mea_trak;
struct DMplan_info *plan_info;
IGRdouble mea_axis[3];
IGRdouble perp_axis[3];
IGRdouble trak_dir[3];
/*.DMget_mea_trak*/
{
	if (mea_trak & DM_MEA_AXIS)
	{
		math_v_equal(mea_axis, plan_info->act_plan.vec_xpos);
		math_v_equal(perp_axis, plan_info->act_plan.vec_ypos);

		if (mea_trak & DM_TRAK_DIR)
		{
			math_v_equal(trak_dir, plan_info->act_plan.vec_ypos);
		}
		else
		{
			math_v_equal(trak_dir, plan_info->act_plan.vec_yneg);
		}
	}
	else
	{
		math_v_equal(mea_axis, plan_info->act_plan.vec_ypos);
		math_v_equal(perp_axis, plan_info->act_plan.vec_xpos);

		if (mea_trak & DM_TRAK_DIR)
		{
			math_v_equal(trak_dir, plan_info->act_plan.vec_xpos);
		}
		else
		{
			math_v_equal(trak_dir, plan_info->act_plan.vec_xneg);
		}
	}

	return(TRUE);
}

IGRint DMget_axis_info (plan_info,norm_to_plane,pt_on_plane,mea_axis,perp_axis,
                        mea_trak,trak_dir)
/*(
	 struct DMplan_info  *plan_info,
	 IGRdouble  norm_to_plane[3],
	 IGRdouble  pt_on_plane[3],
	 IGRdouble  mea_axis[3],
	 IGRdouble  perp_axis[3],
	 IGRchar  mea_trak,
	 IGRdouble  trak_dir[3]
	)
*/
struct DMplan_info *plan_info;
IGRdouble norm_to_plane[3];
IGRdouble pt_on_plane[3];
IGRdouble mea_axis[3];
IGRdouble perp_axis[3];
IGRchar   mea_trak;
IGRdouble trak_dir[3];
/*.DMget_axis_info*/
{
	IGRint index;

	DMget_mea_trak(mea_trak, plan_info, mea_axis, perp_axis, trak_dir);

	for (index=0; index<3; index++)
	{
		norm_to_plane[index] = plan_info->win_plan.matrix[index + 8];
		pt_on_plane[index] = plan_info->win_plan.matrix[4*index + 3];
	}

	return(TRUE);
}

IGRint DMget_text_info (par_loc,plan_info,mea_trak,leader,text_dir,
                        offs_dir,just_pos,just_neg)
/*(
	 struct DMloc_param  *par_loc,
	 struct DMplan_info  *plan_info,
	 IGRchar  mea_trak,
	 IGRboolean  leader,
	 IGRdouble  text_dir[3],
	 IGRdouble  offs_dir[3],
	 IGRshort  *just_pos,
	 IGRshort  *just_neg
	)
*/
struct DMloc_param *par_loc;
struct DMplan_info *plan_info;
IGRchar   mea_trak;
IGRboolean leader;
IGRdouble text_dir[3];
IGRdouble offs_dir[3];
IGRshort *just_pos;
IGRshort *just_neg;
/*.DMget_text_info*/
{
	switch (par_loc->txt_orie)
	{
		case TXT_ORIE_HORIZONTAL:
		case TXT_ORIE_VERTICAL:

		if (par_loc->txt_orie == TXT_ORIE_HORIZONTAL)
		{
			math_v_equal(text_dir, plan_info->win_plan.vec_xpos);
			math_v_equal(offs_dir, plan_info->win_plan.vec_ypos);
		}
		else
		{
			math_v_equal(text_dir, plan_info->win_plan.vec_ypos);
			math_v_equal(offs_dir, plan_info->win_plan.vec_xneg);
		}

		if (leader)
		{
			if (par_loc->txt_posn == TXT_POSN_EMBEDDED)
			{
				*just_pos = LEFT_CENTER;
				*just_neg = RIGHT_CENTER;
			}
			else
			{
				*just_pos = LEFT_BASE;
				*just_neg = RIGHT_BASE;
			}
		}
		else	*just_pos = *just_neg = CENTER_CENTER;

		break;

		case TXT_ORIE_PARALLEL:

		if (mea_trak & DM_MEA_AXIS)
		{
			math_v_equal(text_dir, plan_info->act_plan.vec_xpos);
			math_v_equal(offs_dir, plan_info->act_plan.vec_ypos);
		}
		else
		{
			math_v_equal(text_dir, plan_info->act_plan.vec_ypos);
			math_v_equal(offs_dir, plan_info->act_plan.vec_xneg);
		}

		*just_pos = *just_neg = (par_loc->txt_posn == TXT_POSN_ABOVE)?
						CENTER_BASE:CENTER_CENTER;
		break;

		case TXT_ORIE_PERPENDICULAR:

		if (mea_trak & DM_MEA_AXIS)
		{
			math_v_equal(text_dir, plan_info->act_plan.vec_ypos);

			if (leader)
			{
				math_v_equal(	offs_dir,
						plan_info->act_plan.vec_xneg);
			}
			else
			{
				math_v_equal(	offs_dir,
						plan_info->act_plan.vec_ypos);
			}
		}
		else
		{
			math_v_equal(text_dir, plan_info->act_plan.vec_xpos);

			if (leader)
			{
				math_v_equal(	offs_dir,
						plan_info->act_plan.vec_ypos);
			}
			else
			{
				math_v_equal(	offs_dir,
						plan_info->act_plan.vec_xpos);
			}
		}

		if (leader)
		{
			if (par_loc->txt_posn == TXT_POSN_EMBEDDED)
			{
				*just_pos = LEFT_CENTER;
				*just_neg = RIGHT_CENTER;
			}
			else
			{
				*just_pos = LEFT_BASE;
				*just_neg = RIGHT_BASE;
			}
		}
		else
		{
			if (par_loc->txt_posn == TXT_POSN_EMBEDDED)
				*just_pos = *just_neg = CENTER_CENTER;
			else	*just_pos = *just_neg = LEFT_CENTER;
		}

		break;

		default:

		/*"ERROR: txt_orie=%d\n", par_loc->txt_orie*/
		return(FALSE);
	}

	if (par_loc->txt_orie == TXT_ORIE_PARALLEL
	||  par_loc->txt_orie == TXT_ORIE_PERPENDICULAR)
	{
	        BSrc bs_rc;
		IGRdouble *win_x_pos; 

		win_x_pos = plan_info->win_plan.vec_xpos;
		if (BSdotp(&bs_rc, text_dir, win_x_pos) < 0)
		{
			math_v_opposite(text_dir, text_dir);
			math_v_opposite(offs_dir, offs_dir);
		}
	}

	return(TRUE);
}

IGRint DMmake_proj_line (msg,pt1,pt2,offs,extn,line)
/*(
	 IGRint  *msg,
	 IGRdouble  pt1[3],
	 IGRdouble  pt2[3],
	 IGRdouble  offs,
	 IGRdouble  extn,
	 IGRdouble  line[[2][3]
	)
*/
IGRint *msg;
IGRdouble pt1[3], pt2[3];
IGRdouble offs, extn;
IGRdouble line[2][3];
/*.DMmake_proj_line*/
{
	IGRint    rc;
        BSrc bs_rc;
	IGRvector v1/*,v2*/;

	*msg = DIM_S_SUCCESS;

	BSmkvec(&bs_rc, v1, pt1, pt2);
	BSnorvec(&bs_rc, v1);

	MATH_ptdelta(&rc, pt1, v1, offs, line[0]);
	MATH_ptdelta(&rc, pt2, v1, extn, line[1]);

/*
	BSmkvec(&bs_rc, v2, &line[0], &line[1]);
	if (BSdotp(&bs_rc, v1, v2) < 0)
	{
		 - What ??? - 
	}
*/

	return(TRUE);
}

IGRint DMget_super (md_os,md_id,create,p_grid)
/*(
	 OMuword  md_os,
	 OM_S_OBJID  md_id,
	 IGRboolean  create,
	 struct GRid  *p_grid
	)
*/
OMuword md_os;
OM_S_OBJID md_id;
IGRboolean create;
struct GRid *p_grid;
/*.DMget_super*/
{
	IGRint status;

	if (md_id == NULL_OBJID)
	{
     aflag = pwIsActivationOn();
     if (aflag)
     {
       pwGetActiveModuleEnv(&rfenv);
       md_id = rfenv.md_id.objid;
       md_os = rfenv.md_id.osnum;
     }
     else
     {
		status =
		ex$get_modid(mod_osnum = md_os, mod_id = &md_id);
		dm$status(action = RET_STATUS);
     }
	}

	status =
	ex$get_super(
		mod_id = md_id,
		mod_osnum = md_os,
		super_name = "DIM$SUPER",
		create = create,
		super_class = "DMsuper",
		super_id = &p_grid->objid,
		super_osnum = &p_grid->osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

IGRint DMget_cur_super (p_grid)
/*(

	 struct GRid  *p_grid
	)
*/
struct GRid *p_grid;
{
	IGRint status;
	OMuword md_os;
	OM_S_OBJID md_id;

    aflag = pwIsActivationOn();
    if (aflag)
    {
    pwGetActiveModuleEnv(&rfenv);
    md_id = rfenv.md_id.objid;
    md_os = rfenv.md_id.osnum;
    }
    else
    {
	status =
	ex$get_cur_mod(id = &md_id, osnum = &md_os);
	dm$status(action = RET_STATUS);
    }

	status =
	dm$get_super(
		md_id = md_id,
		md_os = md_os,
		create = TRUE,
		p_grid = p_grid);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

IGRint DMget_plan_mgr (plan_mgr)
/*(
	 struct GRid  *plan_mgr
	)
*/
struct GRid *plan_mgr;
/*.DMget_plan_mgr*/
{
	IGRint status;
	OM_S_OBJID mod_id;
	OMuword mod_os;

    aflag = pwIsActivationOn();
    if (aflag)
    {
    pwGetActiveModuleEnv(&rfenv);
    mod_id = rfenv.md_id.objid;
    mod_os = rfenv.md_id.osnum;
    }
    else
    {
	status = ex$get_cur_mod(id = &mod_id, osnum = &mod_os);
	dm$status(action = RET_STATUS);
    }

	status =
	ex$get_super(
		mod_id = mod_id,
		mod_osnum = mod_os,
		super_name = "DIM$PLAN_MGR",
		create = TRUE,
		super_class = "DMplan_mgr",
		super_id = &plan_mgr->objid,
		super_osnum = &plan_mgr->osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

IGRint DMget_module_info (p_md_env)
/*(
	 struct GRmd_env  *p_md_env
	)
*/
struct GRmd_env *p_md_env;
/*.DMget_module_info*/
{
	int rc;
	int sizbuf, nret;

	sizbuf = sizeof(struct GRmd_env);
	gr$get_module_env(
		msg = &rc,
		sizbuf = &sizbuf,
		buffer = p_md_env,
		nret = &nret);
	dm$status(sts = rc, action = RET_STATUS);

	return(TRUE);
}

IGRint DMget_dim_param (type,dim_objid,dim_osnum,p_grid,p_data)
/*(
	 IGRint  type,
	 OM_S_OBJID  dim_objid,
	 OMuword  dim_osnum,
	 struct GRid  *p_grid,
	 char  *p_data
	)
*/
IGRint type;
OM_S_OBJID dim_objid;
OMuword dim_osnum;
struct GRid *p_grid;
char *p_data;
/*.DMget_dim_param*/
{
	IGRint status, rc;
	struct GRid dim_super;
	int size;
	struct GRid tmp_grid;

	status =
	dm$get_param_info(type = type, size = &size);
	dm$status(action = RET_STATUS);

	if (dim_objid != NULL_OBJID)
	{
		/*| Local Parameters */

		status =
		om$send(msg = message DMroot.get_dim_params(
						&rc,
						type,
						size,
						p_data),
			targetid = dim_objid,
			targetos = dim_osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*| Global Parameters */

		status = dm$get_cur_super(p_grid = &dim_super);
		dm$status(action = RET_STATUS);

		if (p_grid == NULL)
			p_grid = &tmp_grid;

		status =
		om$send(msg = message DMsuper.get_dim_param(
							&rc,
							type,
							p_grid),
			senderid = NULL_OBJID,
			targetid = dim_super.objid,
			targetos = dim_super.osnum);
		dm$status(action = RET_STATUS);

		if (p_data)
		{
			status =
			om$send(msg = message dim_param.give_internal(
							type,
							size,
							p_data),
				senderid = NULL_OBJID,
				targetid = p_grid->objid,
				targetos = p_grid->osnum);
			dm$status(action = RET_STATUS);

			if (type == DM_MISC_PARAM)
			{
				IGRint sizbuf, nret;
				struct GRdpb_text_symb text_symb;
				struct DMmisc_param *par_misc;

				sizbuf = sizeof(text_symb);

				status =
				gr$get_text_symb(
					msg = &rc,
					sizbuf = &sizbuf,
					buffer = &text_symb,
					nret = &nret);
				dm$status(action = RET_STATUS);

				par_misc = (struct DMmisc_param *)p_data;
				par_misc->sixteen_bit_font =
				text_symb.Active_font;
			}
		}
	}

	return(OM_S_SUCCESS);
}

IGRint DMput_dim_param (type,dim_objid,dim_osnum,p_grid,p_data)
/*(
	 IGRint  type,
	 OM_S_OBJID  dim_objid,
	 OMuword  dim_osnum,
	 struct GRid  *p_grid,
	 char  *p_data
	)
*/
IGRint type;
OM_S_OBJID dim_objid;
OMuword dim_osnum;
struct GRid *p_grid;
char *p_data;
/*.DMput_dim_param*/
{
	IGRint status, rc;
	struct GRid dim_super;
	struct GRmd_env md_env;
	struct GRid param;
	IGRint size;

	if (!p_grid) p_grid = &param;

	status = dm$get_param_info(type = type, size = &size);
	dm$status(action = RET_STATUS);

	status = DMget_module_info(&md_env);
	dm$status(action = RET_STATUS);

	if (dim_objid == NULL_OBJID)
	{
		/*| Update Global Parameters */

		status = dm$get_cur_super(p_grid = &dim_super);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMsuper.update_dim_param(
						&rc,
						type,
						size,
						p_data,
						&md_env,
						p_grid),
			senderid = NULL_OBJID,
			targetid = dim_super.objid,
			targetos = dim_super.osnum);
		dm$status(action = RET_STATUS);

		/*^ print_grid("p_grid", p_grid); */
	}
	else
	{
		/*| Update Local Parameters */

		status =
		om$send(msg = message DMroot.set_dim_params(
							&rc,
							type,
							size,
							&md_env,
							p_data),
			senderid = NULL_OBJID,
			targetid = dim_objid,
			targetos = dim_osnum);
		dm$status(action = RET_STATUS);
	}

	return(TRUE);
}

IGRint DMget_plan_info (dim_id,plan_id,osnum,md_env,win_matrix,plan_info)
/*(
	 OM_S_OBJID  dim_id,
	 OM_S_OBJID  plan_id,
	 OMuword  osnum,
	 struct GRmd_env  *md_env,
	 IGRmatrix  win_matrix,
	 struct DMplan_info  *plan_info
	)
*/
OM_S_OBJID dim_id, plan_id;
OMuword    osnum;
struct GRmd_env *md_env;
IGRmatrix win_matrix;
struct DMplan_info *plan_info;
/*.DMget_plan_info*/
{
	IGRint status, rc, i, j;
	IGRlong long_rc;
	struct GRmd_env mod_info;
	struct GRid plan_go;
	struct ret_struct ret_str;

	if (dim_id == NULL_OBJID)
	{
		/*- dimension could be connected directly to coordinate
		    system object(instead of dim_plan object), in this
		    case we need to do a NDgive_structure first and if
		    if fails send a give_plane message
		*/

		/*|- The object could be a coordinate system*/

		ret_str.type = NULL;
		long_rc = 1;

		status =
		om$send(msg = message NDnode.NDgive_structure(
						&long_rc,
						&ret_str,
						md_env),
			senderid = NULL_OBJID,
			targetid = plan_id,
			targetos = osnum);
		if ((1 & status & long_rc) && (ret_str.type == ref_generic))
		{
			/*|- Parent is a coordinate system*/

			/*- Need to transpose the matrix returned by
			    the NDgive_structure, since the format is
			    different from DMplan matrix */

			if (plan_info)
			{
				for (i=0; i<4; i++)
				{
				    for (j=0; j<4; j++)
				    {
					plan_info->win_plan.matrix[i*4+j] =
					plan_info->act_plan.matrix[i*4+j] =
					ret_str.var.ref_st.t[j*4+i];
				    }
				}

				DMfill_plan_info(plan_info);
			}
			else
			{
				for (i=0; i<4; i++)
				    for (j=0; j<4; j++)
					win_matrix[i*4+j] =
					ret_str.var.ref_st.t[j*4+i];
			}
		}
		else
		{
			status =
			om$send(msg = message NDnode.ASreturn_go(
						&plan_go,
						&mod_info.md_env.matrix_type,
						mod_info.md_env.matrix),
				senderid = NULL_OBJID,
				targetid = plan_id,
				targetos = osnum);
			dm$status(action = RET_STATUS);

			if (plan_info)
			{
				status =
				om$send(msg = message dim_plan.give_info(
							&rc,
							plan_info,
							&mod_info),
					senderid = NULL_OBJID,
					targetid = plan_go.objid,
					targetos = plan_go.osnum);
				dm$status(action = RET_STATUS);
			}
			else
			{
				status =
				om$send(msg = message dim_plan.give_plane(
								&rc,
								win_matrix,
								&mod_info),
					senderid = NULL_OBJID,
					targetid = plan_go.objid,
					targetos = plan_go.osnum);
				dm$status(action = RET_STATUS);
			}
		}
	}
	else
	{
		if (plan_info)
		{
			status =
			om$send(msg = message DMroot.get_dimension_plane(
						&rc,
						md_env,
						plan_info),
				senderid = NULL_OBJID,
				targetid = dim_id,
				targetos = osnum);
			dm$status(action = RET_STATUS);
		}
		else
		{
			status =
			om$send(msg = message DMroot.get_window_plane(
						&rc,
						md_env,
						win_matrix),
				senderid = NULL_OBJID,
				targetid = dim_id,
				targetos = osnum);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}

DMfill_plan_info (plan_info)
/*(
	 struct DMplan_info  *plan_info
	)
*/
struct DMplan_info *plan_info;
/*.DMfill_plan_info*/
{
	int index;
	IGRlong long_rc;

	for (index=0; index<3; index++)
	{
		plan_info->win_plan.vec_xpos[index] =
		plan_info->win_plan.matrix[index];

		plan_info->win_plan.vec_ypos[index] =
		plan_info->win_plan.matrix[index + 4];

		plan_info->win_plan.vec_xneg[index] =
		-plan_info->win_plan.matrix[index];

		plan_info->win_plan.vec_yneg[index] =
		-plan_info->win_plan.matrix[index + 4];

		plan_info->act_plan.vec_xpos[index] =
		plan_info->act_plan.matrix[index];

		plan_info->act_plan.vec_ypos[index] =
		plan_info->act_plan.matrix[index + 4];

		plan_info->act_plan.vec_xneg[index] =
		-plan_info->act_plan.matrix[index];

		plan_info->act_plan.vec_yneg[index] =
		-plan_info->act_plan.matrix[index + 4];
	}

	MAtypemx(
		&long_rc,
		plan_info->win_plan.matrix,
		&plan_info->win_plan.matrix_type);

	MAtypemx(
		&long_rc,
		plan_info->act_plan.matrix,
		&plan_info->act_plan.matrix_type);

	return(TRUE);
}

#argsused
IGRint DMcompute_endpt (msg,pt1, pt2,box,txt_posn, plane,md_env,endpt)
/*(
	 IGRint  *msg,
	 IGRpoint  pt1,
	 IGRpoint  pt2,
	 IGRdouble  **box,
	 IGRchar  txt_posn,
	 IGRmatrix  plane,
	 struct GRmd_env  *md_env,
	 IGRpoint  endpt
	)
*/
IGRint *msg;
IGRpoint pt1, pt2;
IGRdouble box[4][3];
IGRchar txt_posn;
IGRmatrix plane;
struct GRmd_env *md_env;
IGRpoint endpt;
/*.DMcompute_endpt*/
{
	if (txt_posn == TXT_POSN_EMBEDDED)
	{
		MATH_line_break(
			msg,
			pt1,
			pt2,
			plane,
			box,
			endpt);
	}
	else
	{
		MATH_line_extend(
			msg,
			pt1,
			pt2,
			box,
			endpt);
	}

	return(TRUE);
}

const_dim_line (p1,p2,dim_line)
/*(
	 IGRdouble  p1[3],
	 IGRdouble  p2[3],
	 struct DMdim_line  *dim_line
	)
*/
IGRdouble p1[3], p2[3];
struct DMdim_line *dim_line;
{
	int index;

	dim_line->needed = TRUE;

	for (index=0; index<3; index++)
	{
		dim_line->line[index] = p1[index];
		dim_line->line[index +3] = p2[index];
	}

	return(TRUE);
}
/*
char *dim_units_label(units, mea_units, par_misc)
int units, mea_units;
struct DMmisc_param *par_misc;
{
	switch (mea_units)
	{
		case MEA_UNIT_FEET_INCHES:
			return((units == 0)?
				par_misc->pri_label_ftin:
				par_misc->sec_label_ftin);

		case MEA_UNIT_METERS:
			return((units == 0)?
				par_misc->pri_label_M:
				par_misc->sec_label_M);

		case MEA_UNIT_MM:
			return((units == 0)?
				par_misc->pri_label_mm:
				par_misc->sec_label_mm);

		case MEA_UNIT_INCHES:
			return((units == 0)?
				par_misc->pri_label_inch:
				par_misc->sec_label_inch);

		default:
			printf("dim_units_label: Error in mea_units %d\n",
					mea_units);
			break;
	}
}
*/
IGRint DMget_dim_plane (win_grid,md_env,p_grid)
/*(
	 struct GRid  win_grid,
	 struct GRmd_env  *md_env,
	 struct GRid  *p_grid
	)
*/
struct GRid win_grid;
struct GRmd_env *md_env;
struct GRid *p_grid;
{
	IGRint status, rc;
	struct GRid plan_mgr;

	DMget_plan_mgr(&plan_mgr);

	status =
	om$send(msg = message DMplan_mgr.get_dim_plane(
						&rc,
						win_grid,
						md_env,
						p_grid),
		senderid = NULL_OBJID,
		targetid = plan_mgr.objid,
		targetos = plan_mgr.osnum);
	dm$status(action = RET_STATUS);

	return(TRUE);
}

IGRint DMget_cnv_factor (meas_unit,factor)
/*(
	 int  meas_unit,
	 double  *factor
	)
*/
int meas_unit;
IGRdouble *factor;
/*.DMget_cnv_factor*/
{
	IGRint status, rc;
	IGRchar unit_name[16];
	OM_S_OBJID mod_id;
	OMuword osnum;

	switch (meas_unit)
	{
		case MEA_UNIT_FEET_INCHES:
		case MEA_UNIT_INCHES:
		strcpy(unit_name, "inch"); break;

		case MEA_UNIT_METERS:
		strcpy(unit_name, "M"); break;

		case MEA_UNIT_MM:
		strcpy(unit_name, "mm"); break;

		default:
		printf("DMget_cnv_factor: Unknow unit %d\n", meas_unit);
		return(FALSE);
	}

	status = ex$get_cur_mod(id = &mod_id, osnum = &osnum);
	dm$status(action = RET_STATUS);

	status =
	co$cvt_exp_to_wrk(
		msg = &rc,
		unit_type = "UOM_DISTANCE",
		osnum = osnum,
		units = 1.0,
		alias = unit_name,
		result = factor);
	dm$status(action = RET_STATUS);

	*factor = 1.0 / (*factor);
	return( TRUE);
}

IGRint DMis_complex (type)/*(
	 int  type
	)
*/
int type;
/*.DMis_complex*/
{
	return (type == STACKED_LINEAR		||
		type == STRINGED_LINEAR		||
		type == STACKED_ANGULAR		||
		type == STRINGED_ANGULAR	||
		type == SYMMETRICAL_DIAMETER	||
		type == COORDINATE		||
		type == TEXT_WITH_BALLOON);
}

IGRint DMancestry_valid (grid,superclassid)
/*(
	 struct GRid  grid,
	 GRclassid  superclassid
	)
*/
struct GRid grid;
GRclassid superclassid;
/*.DMancestry_valid*/
{
	IGRint status;
	GRclassid subclassid;

	status =
	om$get_classid(
		objid = grid.objid,
		osnum = grid.osnum,
		p_classid = &subclassid);
	if (!(status & 1))
		return(FALSE);

	return(om$is_ancestry_valid(
		subclassid = subclassid,
		superclassid = superclassid) == OM_S_SUCCESS);
}

IGRint DMextend_curve (bsp_curve)
/*(
	 struct IGRbsp_curve  *bsp_curve
	)
*/
struct IGRbsp_curve *bsp_curve;
/*.DMextend_curve*/
{
	#define BIGNUM 1e5
	IGRvector v1, v2;
	IGRint i, p;
	BSrc bs_rc;

	if (bsp_curve->order != 2
	||  bsp_curve->num_poles < 2
	||  bsp_curve->phy_closed)
		return(OM_S_SUCCESS);

	p = bsp_curve->num_poles;
	BSmkvec(&bs_rc, v1, bsp_curve->poles, &bsp_curve->poles[3]);
	BSmkvec(&bs_rc, v2, &bsp_curve->poles[3*(p-2)], &bsp_curve->poles[3*(p-1)]);

	for (i=0; i<3; i++)
	{
		bsp_curve->poles[i] -= v1[i] * BIGNUM;
		bsp_curve->poles[(p-1)*3 + i] += v2[i] * BIGNUM;
	}

	return(OM_S_SUCCESS);
}

#argsused
IGRint DMcomp_obj (as_grid,md_env)
/*(
	 struct GRid  as_grid,
	 struct GRmd_env  *md_env
	)
*/
struct GRid as_grid;
 struct GRmd_env  *md_env;
/*.DMcomp_obj*/
{
	int info;

	info = ND_COMP;

	nd$wait_batch(
		type = GR_GEOM_POSTED,
		l_object = &as_grid,
		l_obj_info = &info,
		nb_obj   = 1);

	nd$exec_batch();

	return(OM_S_SUCCESS);
}

IGRint DMget_just_pt (msg,txt_just,txt_geom,new_just,txt_pt)
/*(
	 IGRint  *msg,
	 IGRshort  txt_just,
	 struct IGRlbsys  *txt_geom,
	 IGRshort  new_just,
	 IGRdouble  *txt_pt
	)
*/
IGRint *msg;
IGRshort txt_just;
struct IGRlbsys *txt_geom;
IGRshort new_just;
IGRdouble *txt_pt;
/*.DMget_just_pt*/
{
	IGRint rc, i, c1, c2;
	IGRdouble box[4][3];
	IGRvector vec;
	IGRpoint orig, pt;
	IGRdouble line[2][3];
	BSrc bs_rc;

	/*"txt_just=%d, new_just=%d\n", txt_just, new_just*/

	if (new_just == txt_just)
	{
		txt_pt[0] = txt_geom->matrix[3];
		txt_pt[1] = txt_geom->matrix[7];
		txt_pt[2] = txt_geom->matrix[11];

		return(OM_S_SUCCESS);
	}

	MATH_get_box_points(&rc, txt_geom, box);

	switch (new_just)
	{
		case CENTER_CENTER:
		/*|CENTER_CENTER*/
		c1 = 0;	c2 = 2;	break;

		case CENTER_BASE:
		case  CENTER_BOTTOM:
		/*|CENTER_BASE or CENTER_BOTTOM*/
		c1 = 0; c2 = 1; break;

		case  CENTER_TOP:
		/*|CENTER_TOP*/
		c1 = 2; c2 = 3; break;

		case LEFT_BASE:
		case LEFT_CENTER:
		/*|LEFT_BASE or LEFT_CENTER*/
		c1 = 0; c2 = 3; break;

		case RIGHT_CENTER:
		case RIGHT_BASE:
		/*|RIGHT_BASE or RIGHT_CENTER*/
		c1 = 1; c2 = 2; break;

		case LEFT_TOP:
		/*|LEFT_TOP*/
		c1 = 3; c2 = -1; break;

		case  LEFT_BOTTOM:
		/*|LEFT_BOTTOM*/
		c1 = 0; c2 = -1; break;

		case RIGHT_TOP:
		/*|RIGHT_TOP*/
		c1 = 2; c2 = -1; break;

		case  RIGHT_BOTTOM:
		/*|RIGHT_BOTTOM*/
		c1 = 1; c2 = -1; break;

		default:
		/*|ERROR in justification */
		c1 = 0;
		c2 = 2;
		break;
	}

	if (c2 == -1)
	{
		for (i=0; i<3; i++)
		txt_pt[i] = box[c1][i];
	}
	else
	{
		for (i=0; i<3; i++)
		txt_pt[i] = (box[c1][i] + box[c2][i])/2.0;
	}

	if ((new_just == LEFT_BASE)
	||  (new_just == RIGHT_BASE)
	||  (new_just == CENTER_BASE))
	{
		orig[0] = txt_geom->matrix[3];
		orig[1] = txt_geom->matrix[7];
		orig[2] = txt_geom->matrix[11];

		memcpy(pt, txt_pt, sizeof(IGRpoint));
		BSmkvec(&bs_rc, vec, box[c1], box[c2]);
		DMlineptvec(orig, vec, line);
		BSproj0(&bs_rc, pt, line, txt_pt);
	}

	/*^
		print_point("orig", orig);
		print_point("box[0]", box[0]);
		print_point("box[1]", box[1]);
		print_point("box[2]", box[2]);
		print_point("box[3]", box[3]);
		print_point("txt_pt", txt_pt);
	*/

	*msg = OM_S_SUCCESS;
	return(TRUE);
}

IGRint DMget_coord_text_info (par_loc,plan_info,mea_trak,proj_vec,
                              text_dir,offs_dir,txt_just)
/*(
	 struct DMloc_param  *par_loc,
	 struct DMplan_info  *plan_info,
	 IGRchar  mea_trak,
	 IGRdouble  proj_vec[3],
	 IGRdouble  text_dir[3],
	 IGRdouble  offs_dir[3],
	 IGRshort  *txt_just
	)
*/
struct DMloc_param *par_loc;
struct DMplan_info *plan_info;
IGRchar   mea_trak;
IGRdouble proj_vec[3];
IGRdouble text_dir[3];
IGRdouble offs_dir[3];
IGRshort *txt_just;
/*.DMget_coord_text_info*/
{
	BSrc bs_rc;
	IGRdouble *proj_dir;

	switch (par_loc->txt_orie)
	{
		case TXT_ORIE_HORIZONTAL:

		math_v_equal(text_dir, plan_info->win_plan.vec_xpos);
		if(mea_trak & DM_MEA_AXIS)
		{
			proj_dir = plan_info->win_plan.vec_ypos;
			if (BSdotp(&bs_rc, proj_vec, proj_dir) > 0.0)
				*txt_just = CENTER_BOTTOM;
			else	*txt_just = CENTER_TOP;
		}
		else
		{
			proj_dir = plan_info->win_plan.vec_xpos;
			if (BSdotp(&bs_rc, proj_vec, proj_dir) > 0.0)
				*txt_just = LEFT_CENTER;
			else	*txt_just = RIGHT_CENTER;
		}
		break;

		case TXT_ORIE_VERTICAL:

		math_v_equal(text_dir, plan_info->win_plan.vec_ypos);
		if(mea_trak & DM_MEA_AXIS)
		{
			proj_dir = plan_info->win_plan.vec_ypos;
			if (BSdotp(&bs_rc, proj_vec, proj_dir) > 0.0)
				*txt_just = LEFT_CENTER;
			else	*txt_just = RIGHT_CENTER;
		}
		else
		{
			proj_dir = plan_info->win_plan.vec_xpos;
			if (BSdotp(&bs_rc, proj_vec, proj_dir) > 0.0)
				*txt_just = CENTER_TOP;
			else	*txt_just = CENTER_BOTTOM;
		}
		break;

		case TXT_ORIE_PARALLEL:

		if(mea_trak & DM_MEA_AXIS)
		{
			math_v_equal(text_dir, plan_info->act_plan.vec_ypos);
			math_v_equal(offs_dir, plan_info->act_plan.vec_xneg);
			proj_dir = plan_info->act_plan.vec_ypos;
		}
		else
		{
			math_v_equal(text_dir, plan_info->act_plan.vec_xpos);
			math_v_equal(offs_dir, plan_info->act_plan.vec_ypos);
			proj_dir = plan_info->act_plan.vec_xpos;
		}
	
		if (BSdotp(&bs_rc, proj_vec, proj_dir) > 0.0)
		{
			if(par_loc->ctxt_posn == TXT_POSN_ABOVE)
				*txt_just = LEFT_BASE;
			else	*txt_just = LEFT_CENTER;
		}
		else
		{
			if (par_loc->ctxt_posn == TXT_POSN_ABOVE)
				*txt_just = RIGHT_BASE;
			else	*txt_just = RIGHT_CENTER;
		}
		break;

		case TXT_ORIE_PERPENDICULAR:

		if(mea_trak & DM_MEA_AXIS)
		{
			math_v_equal(text_dir, plan_info->act_plan.vec_xpos);
			math_v_equal(offs_dir, plan_info->act_plan.vec_xpos);
			proj_dir = plan_info->act_plan.vec_ypos;
		}
		else
		{
			math_v_equal(text_dir, plan_info->act_plan.vec_ypos);
			math_v_equal(offs_dir, plan_info->act_plan.vec_ypos);
			proj_dir = plan_info->act_plan.vec_xpos;
		}

		if (BSdotp(&bs_rc, proj_vec, proj_dir) > 0.0)
		{
			if (par_loc->ctxt_posn == TXT_POSN_ABOVE)
				*txt_just = LEFT_TOP;
			else	*txt_just = CENTER_BOTTOM;
		}
		else
		{
			if(par_loc->ctxt_posn == TXT_POSN_ABOVE)
				*txt_just = LEFT_BOTTOM;
			else	*txt_just = CENTER_BOTTOM;
		}
		break;

		default:

		/*"ERROR: txt_orie=%d\n", par_loc->txt_orie*/
		return(FALSE);
	}

	return(TRUE);
}

IGRint DMgive_formula (exp,str)
/*(
	 struct GRid  exp,
	 char  *str
	)
	*/
struct GRid exp;
char *str;
/*.DMgive_formula*/
{
	IGRint status;

	status =
	om$send(msg = message expression.give_formula(str),
		senderid = NULL_OBJID,
		targetid = exp.objid,
		targetos = exp.osnum);
	dm$status(action = RET_STATUS);

	return(DIM_S_SUCCESS);
}

IGRint DMgive_value (exp,d)
/*(
	 struct GRid  exp,
	 double  *d
	)
	*/
struct GRid exp;
IGRdouble *d;
/*.DMgive_value*/
{
	IGRint status;

	status =
	om$send(msg = message expression.NDgive_value(d),
		senderid = NULL_OBJID,
		targetid = exp.objid,
		targetos = exp.osnum);
	dm$status(action = RET_STATUS);

	return(DIM_S_SUCCESS);
}

IGRint DMcheck_edge_view (go_grid,dim_plan,md_env,edge_view)
/*(
	 struct GRid  go_grid,
	 struct GRid  dim_plan,
	 struct GRmd_env  *md_env,
	 IGRboolean  *edge_view
	)
	*/
struct GRid go_grid;
struct GRid dim_plan;
struct GRmd_env *md_env;
IGRboolean *edge_view;
/*.DMcheck_edge_view*/
{
	IGRint status, i;
	IGRlong long_rc;
	IGRshort props;
	IGRdouble dotp;
	IGRdouble dm_normal[3], cv_normal[3], cv_point[3];
	IGRmatrix matrix;
	struct IGRplane igr_plane;
	struct IGRbsp_curve *bsp_curve;
	BSrc bs_rc;

	status =
	om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					(char **)&bsp_curve),
		senderid = NULL_OBJID,
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	if (bsp_curve->num_poles < 3)
	{
		*edge_view = FALSE;
		return(OM_S_SUCCESS);
	}

	status =
	dm$get_plan_info(
		plan_objid = dim_plan.objid,
		osnum = dim_plan.osnum,
		md_env = md_env,
		win_matrix = matrix);
	dm$status(action = RET_STATUS);

	for (i=0; i<3; i++)
		dm_normal[i] = matrix[i+8];

	status =
	om$send(msg = message GRgraphics.GRgetprops(&long_rc, &props),
			senderid = NULL_OBJID,
			targetid = go_grid.objid,
			targetos = go_grid.osnum);
	if (status & 1)
	{
		/*"props=%d\n", props*/

		if (!(props & GRIS_PLANAR))
		{
			*edge_view = FALSE;
			return(OM_S_SUCCESS);
		}
	}

	igr_plane.normal = cv_normal;
	igr_plane.point  = cv_point;

	/*|GRdetplane*/

	status =
	om$send(msg = message GRvg.GRdetplane(
					&long_rc,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					&igr_plane),
		senderid = NULL_OBJID,
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	dotp = BSdotp(&bs_rc, dm_normal, cv_normal);

	/*^
		print_point("dm_normal",dm_normal);
		print_point("cv_point",cv_point);
		print_point("cv_normal",cv_normal);
		printf("dotp = %f\n",dotp);
	*/

	if(fabs(dotp) < DOTP_PERP_TOLERANCE)
		*edge_view = TRUE;
	else	*edge_view = FALSE;

	return(OM_S_SUCCESS);
}
		
IGRint DMcompute_mea_axis (msg,
			   list,
			   count,mea_axis,matrix,md_env)
			   /*(
	 IGRint  *msg,
	 struct GRid  list[],
	 IGRint  count,
	 IGRvector  mea_axis,
	 IGRmatrix  matrix,
	 struct GRmd_env  *md_env
	)
	*/
IGRint *msg;
struct GRid list[];
IGRint count;
IGRvector mea_axis;
IGRmatrix matrix;
struct GRmd_env *md_env;
/*.DMcompute_mea_axis*/
{
	IGRint 		status, index, rc;
	IGRdouble	pt1[3], pt2[3], origin[3], norm[3];
	struct ret_struct ret_st[2];
	BSrc bs_rc;

	/*| - compute_mea_axis */

	for (index=0; index<3; index++)
	{
		norm[index]   = matrix[index + 8];
		origin[index] = matrix[4*index+3];
	}

	switch (count)
	{
		case 1:

		status =
		DMnode_give_structure(
			&rc,
			DIM_NO_INDEX,
			ORIG_INFO,
			FALSE,
			list[0].objid,
			NULL_OBJID,
			list[0].osnum,
			md_env,
			ret_st);
		dm$status(action = RET_STATUS);

		for( index=0; index <3; index ++)
		{
			pt1[index] = ret_st[0].var.line_st.p0[index];
			pt2[index] = ret_st[0].var.line_st.p1[index];
		}

		break;

		case 2:

		status =
		DMnode_give_structure(
			&rc,
			DIM_NO_INDEX,
			ORIG_INFO,
			FALSE,
			list[0].objid,
			NULL_OBJID,
			list[0].osnum,
			md_env,
			ret_st);
		dm$status(action = RET_STATUS);

		status =
		DMnode_give_structure(
			&rc,
			DIM_NO_INDEX,
			ORIG_INFO,
			FALSE,
			list[1].objid,
			NULL_OBJID,
			list[1].osnum,
			md_env,
			&ret_st[1]);
		dm$status(action = RET_STATUS);

		for( index=0; index <3; index ++)
		{
			pt1[index] = ret_st[0].var.point_st.pt[index];
			pt2[index] = ret_st[1].var.point_st.pt[index];
		}
		break;

		default:
		printf("DMcompute_mea_axis : Invalid parent count %d\n", count);
		return(OM_E_ABORT);
	}

	/*^
		print_point("pt1",pt1);
		print_point("pt2",pt2);
		print_point("origin",origin);
		print_point("norm",norm);
	*/

	DMproject_points(
		&rc,
		pt1,
		pt2,
		NULL,
		NULL,
		norm,
		origin);

	BSmkvec(&bs_rc, mea_axis, pt1, pt2);
	BSnorvec(&bs_rc, mea_axis);

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

IGRint DMis_displayable (objid,osnum)
/*(
	 GRobjid  objid,
	 OMuword  osnum
	)
	*/
GRobjid objid;
OMuword osnum;
/*.DMis_displayable*/
{
	IGRint status;
	IGRchar type;
	struct GRid my_grid;

	my_grid.objid = objid;
	my_grid.osnum = osnum;

	if (DMancestry_valid(my_grid, OPP_DMroot_class_id))
	{
		status =
		om$send(msg = message DMroot.inq_display_type(&type),
			senderid = NULL_OBJID,
			targetid = objid,
			targetos = osnum);
		dm$status(action = RET_STATUS);

		if (type & DIM_DISPLAY_OFF)
			return(FALSE);
	}

	return(TRUE);
}

IGRint DMget_parents (root,size,list,
		      count)
		      /*(
	 struct GRid  root,
	 IGRint  size,
	 struct GRid  list[],
	 IGRint  *count
	)
	*/
struct GRid root;
IGRint size;
struct GRid list[];
IGRint *count;
/*.DMget_parents*/
{
	IGRint status;

	status =
	om$send(msg = message NDnode.NDget_objects(
						ND_ROOT,
						list,
						size,
						NULL,
						0,
						size - 1,
						count),
		targetid = root.objid,
		targetos = root.osnum,
		senderid = NULL_OBJID);
	dm$status(action = RET_STATUS);

	return(TRUE);
}

IGRint DMget_dit_tol (win_grid,
		      dittol)
	 struct GRid  *win_grid;
	 IGRdouble  *dittol;
/*.DMget_dit_tol*/
{
	IGRint ret_stat,status;
	IGRlong msg;
	struct var_list list_var[2];
	IGRdouble vwscale;

        /* fixed problem of sending in size of buffer instead of a pointer
           by not specifying the argument: Bill Cecil: 11/24/91 */

	gr$get_dit_tolerance(msg = &msg, 
     			buffer = dittol, 
			nret = &ret_stat);

	list_var[0].var = VVOL_VIEWPORT_SCALE;
	list_var[0].var_ptr = (char *)&vwscale;
	list_var[0].num_bytes = sizeof (IGRdouble);
	list_var[0].bytes_returned = (IGRlong *)&ret_stat;

	list_var[1].var = END_PARAM;
	list_var[1].var_ptr = NULL;
	list_var[1].num_bytes = 0;
	list_var[1].bytes_returned = NULL;

	/*^ print_grid("window",win_grid);*/

	status = 
	dp$inq_set_gragad (msg = &msg,
               		  osnum = win_grid->osnum, 
               		  gragad_objid = win_grid->objid, 
			  which_error = &ret_stat,
              		  var_list = list_var);
	dm$status(action= RET_STATUS);
	(*dittol) /= vwscale;
	return(TRUE);
}

IGRint DMget_active_just (pos,
			  type,
			  pt1,
			  pt2,
			  plane,
			  just,
			  annot_dir)
	 int  pos;
	 int  type;
	 IGRdouble  *pt1;
	 IGRdouble  *pt2;
	 IGRdouble  *plane;
	 IGRshort  *just;
	 IGRchar  *annot_dir;
/*.DMget_active_just*/
{

	IGRdouble point1[2],point2[2];
	IGRdouble deltaX,deltaY,deltaXY;

	/*"pt1=%lf,%lf,%lf\n", pt1[0], pt1[1], pt1[2]*/
	/*"pt2=%lf,%lf,%lf\n", pt2[0], pt2[1], pt2[2]*/

	point1[0] =	plane[0] * pt1[0] +  plane[1] * pt1[1] +
			plane[2] * pt1[2] ;

	point1[1] =	plane[4] * pt1[0] +  plane[5] * pt1[1] +
			plane[6] * pt1[2];

	point2[0] =	plane[0] * pt2[0] +  plane[1] * pt2[1] +
			plane[2] * pt2[2] ;

	point2[1] =	plane[4] * pt2[0] +  plane[5] * pt2[1] +
			plane[6] * pt2[2];

	deltaX = (point2[0] - point1[0]);
	deltaY = (point2[1] - point1[1]);
	deltaXY = deltaX*deltaY;

	if(type == DM_TEXT)
	{
		if (pos == TXT_POSN_ABOVE)
		{
			/*|TXT_POSN_ABOVE*/
			if(fabs(deltaX) < TOLERANCE || deltaXY < 0)
				*just = LEFT_BOTTOM;
			else
				*just = RIGHT_BOTTOM;
			*annot_dir = 1;
		}
		else 
		{
			/*|TXT_POSN_BELOW*/
			if(fabs(deltaXY) < TOLERANCE || deltaXY > 0)
				*just = LEFT_TOP;
			else
				*just = RIGHT_TOP;
		}
			*annot_dir = 0;
	}
	else
	{
		if(fabs(deltaY) < TOLERANCE)
		{
			*just = ( deltaX > 0.0 ? LEFT_BASE:RIGHT_BASE);
			*annot_dir = ( deltaX > 0.0 ? 1:0);
		}
		else if( fabs(deltaX) < TOLERANCE)
		{
			if(deltaY < 0.0)
			{
				*just = LEFT_CAP;
				*annot_dir = 0;
			}
			else
			{
			 	*just = LEFT_BASE;
				*annot_dir = 1;
			}
		}
		else if( deltaX > 0.0 && deltaY > 0.0)
		{
			*just  = LEFT_BASE;
			*annot_dir = 1;
		}
		else if( deltaX < 0.0 && deltaY < 0.0)
		{
			*just  = RIGHT_CAP;
			*annot_dir = 0;
		}
		else if( deltaX > 0.0 && deltaY < 0.0)
		{
			*just = LEFT_CAP;
			*annot_dir = 0;
		}
		else if( deltaX < 0.0 && deltaY > 0.0)
		{
			*just = RIGHT_BASE;
			*annot_dir = 1;
		}
	}
		/*"justification=%d\n", *just*/
	return(TRUE);
}


IGRint DMget_components (owner,
			 p_size,
			 p_root,
			 p_count)
			 /*(
	 struct GRid  owner,
	 IGRint  *p_size,
	 struct GRid  **p_root,
	 IGRint  *p_count
	)
	*/
struct GRid owner;
IGRint *p_size;
struct GRid **p_root;
IGRint *p_count;
/*.DMget_components*/
{
	IGRint status, count, i, byte;
	OM_S_OBJECT_LINKAGE *list, slist[10];
	struct GRid comp;
	IGRboolean is_owner, is_node;

	if (*p_size == 0)
	{
		*p_root = (struct GRid *)om$malloc(size = sizeof(struct GRid) * 10);
		if (*p_root == NULL) return(OM_E_NODYNMEM);
		*p_size = 10;
	}

	status =
	om$get_channel_count(
		objid = owner.objid,
		osnum = owner.osnum,
		p_chanselect = &AS_to_comp,
		count = (OMuint *) &count);
	if (!(status & 1) || !count)
		return(OM_S_SUCCESS);

	if (count > 10)
	{
		list = (OM_S_OBJECT_LINKAGE *)om$malloc(size = sizeof(OM_S_OBJECT_LINKAGE) * count);
		if (!list) return(OM_E_NODYNMEM);
	}
	else	list = slist;

	status =
	om$get_channel_objects(
		objid = owner.objid,
		osnum = owner.osnum,
		p_chanselect = &AS_to_comp,
		list = list,
		size = count,
		count = (OMuint *) &count);
	if (!(status & 1))
	{
		if (list != slist) om$dealloc(ptr = list);
		return(OM_E_ABORT);
	}

	for (i=0; i<count; i++)
	{
		comp.objid = list[i].S_objid;
		comp.osnum = list[i].osnum;

		DMget_obj_type(comp, &is_owner, &is_node, FALSE);
		/*"is_owner=%d, is_node=%d\n", is_owner, is_node*/

		if (is_node || !is_owner) 
		{
			if (*p_size <= *p_count)
			{
				*p_size += 10;
				byte = sizeof(struct GRid) * (*p_size);

				*p_root = (struct GRid *)
				om$realloc(ptr = (char *) *p_root, size = byte);
				if (*p_root == NULL) return(OM_E_NODYNMEM);
			}

			(*p_root)[*p_count] = comp;
			*p_count += 1;
		}

		if (is_owner)
		{
			status =
			DMget_components(
				comp,
				p_size,
				p_root,
				p_count);
			dm$status();
		}

	}

	if (list != slist) om$dealloc(ptr = list);
	return(OM_S_SUCCESS);
}

IGRint DMget_obj_type (node,
		       is_owner,
		       is_node,
		       load_classid)
		       /*(
	 struct GRid  node,
	 IGRboolean  *is_owner,
	 IGRboolean  *is_node,
	 IGRboolean  load_classid
	)
	*/
struct GRid node;
IGRboolean *is_owner, *is_node;
IGRboolean load_classid;
/*.DMget_obj_type*/
{
	IGRint status;
	GRclassid classid;
	static GRclassid EMScomposite;
	static IGRboolean model;
	extern GRclassid OPP_NDnode_class_id;
	extern GRclassid OPP_GRowner_class_id;

	status =
	om$get_classid(osnum = node.osnum,
		objid = node.objid,
		p_classid = &classid);
	dm$status(action = RET_STATUS);

	if (load_classid)
	{
		status =
		om$get_classid(classname = "EMScomposite",
			p_classid = &EMScomposite);
		model = (status == OM_S_SUCCESS);
	}

	status =
	om$is_ancestry_valid(subclassid = classid,
		superclassid = OPP_NDnode_class_id);
	*is_node = (status == OM_S_SUCCESS);

	if (*is_node)
	{
	    if (model)
	    {
		status =
		om$is_ancestry_valid(subclassid = classid,
			superclassid = EMScomposite);
		*is_owner = (status == OM_S_SUCCESS);
	    }
	    else *is_owner = FALSE;
	}
	else
	{
		status =
		om$is_ancestry_valid(subclassid = classid,
			superclassid = OPP_GRowner_class_id);
		*is_owner = (status == OM_S_SUCCESS);
	}

	return(OM_S_SUCCESS);
}

IGRint DMcopy_to_ram (type,
		      p_data,
		      size)
		      /*(
	 int  type,
	 char  *p_data,
	 int  size
	)
	*/
int type;
char *p_data;
int size;
{
	extern struct DMenv_param frm_env;
	extern struct DMloc_param frm_loc;
	extern struct DMmisc_param frm_misc;
	extern struct DMsenv_param frm_senv;
	extern struct DMglobal_param frm_glob;
	extern struct DMweld_param frm_weld;

	switch (type)
	{
		case DM_ENV_PARAM:
		OM_BLOCK_MOVE(p_data, &frm_env, size);
		break;

		case DM_LOC_PARAM:
		OM_BLOCK_MOVE(p_data, &frm_loc, size);
		break;

		case DM_MISC_PARAM:
		OM_BLOCK_MOVE(p_data, &frm_misc, size);
		break;

		case DM_SENV_PARAM:
		OM_BLOCK_MOVE(p_data, &frm_senv, size);
		break;

		case DM_GLOB_PARAM:
		OM_BLOCK_MOVE(p_data, &frm_glob, size);
		break;

		case DM_WELD_PARAM:
		OM_BLOCK_MOVE(p_data, &frm_weld, size);
		break;

		default:
		return(OM_E_ABORT);
	}

	return(OM_S_SUCCESS);
}

IGRint DMtransform_point (point,
			  matrix)
			  /*(
	 IGRpoint  point,
	 IGRmatrix  matrix
	)
	*/
IGRpoint point;
IGRmatrix matrix;
/*.DMtransform_point*/
{
	IGRlong rc;
	IGRshort four, one;
	IGRdouble p_matrix[4], t_matrix[4];

	/*^ print_point("point",point); */

	four = 4;
	one = 1;

	p_matrix[3] = 1.0;
	memcpy(p_matrix, point, sizeof(IGRpoint));
	MAmulmx(&rc,&four,&four,&one,matrix,p_matrix,t_matrix);
	memcpy(point, t_matrix, sizeof(IGRpoint));

	/*^ print_point("t_point", point); */

	return(OM_S_SUCCESS);

}

IGRint DMtransform_matrix (matrix,
			   md_env)
			   /*(
	 IGRpoint  matrix,
	 struct GRmd_env  *md_env
	)
	*/
IGRmatrix matrix;
struct GRmd_env *md_env;
/*.DMtransform_matrix*/
{
	IGRlong rc, one = 1;
	IGRshort rot_mx_type;
	IGRmatrix rot_matrix;

	/*^ print_matrix("matrix",matrix); */

	OM_BLOCK_MOVE(md_env->md_env.matrix, rot_matrix, sizeof(IGRmatrix));
	rot_matrix[3] = rot_matrix[7] = rot_matrix[11] = 0.0;

	MAtypemx(&rc, rot_matrix, &rot_mx_type);
	if (!(1 & rc)) goto wrapup;

	MAoptsxform(&rc, &one, &rot_mx_type, rot_matrix, matrix, matrix);
	if (!(1 & rc)) goto wrapup;

	MAoptsxform(&rc, &one, &rot_mx_type, rot_matrix, &matrix[4], &matrix[4]);
	if (!(1 & rc)) goto wrapup;

	MAoptsxform(&rc, &one, &rot_mx_type, rot_matrix, &matrix[8], &matrix[8]);
	if (!(1 & rc)) goto wrapup;

	/*^ print_matrix("t_matrix",matrix); */

wrapup:

	return(1 & rc);
}

IGRint DMchgdpmode (mode)
/*(
	 enum GRdpmode  *mode
	)
	*/
enum GRdpmode *mode;
/*.DMchgdpmode*/
{
	/*"mode=%d\n", *mode*/

	switch (*mode)
	{
		case GRhd:
		case GRbehd:
		case GRbdhd:
		*mode = GRhd;
		break;

		case GRbd:
		case GRbdhe:
		case GRhhd:
		case GRhdo:
		case GRhhdo:
		case GRbdheo:
		*mode = GRhhd;
		break;

		case GRbe:
		case GRhe:
		case GRbehe:
		case GRheo:
		case GRbeheo:
		*mode = GRhe;
		break;
	}

	return(OM_S_SUCCESS);
}

IGRint DMdim_imported (dim_id,
		       dim_os,
		       impdim,
		       context,
		       imported)
		       /*(
	 OM_S_OBJID  dim_id,
	 OMuword  dim_os,
	 struct GRid  *impdim,
	 struct GRid  *context,
	 IGRboolean  *imported
	)
	*/
OM_S_OBJID dim_id;
OMuword dim_os;
struct GRid *impdim;
struct GRid *context;
IGRboolean *imported;
/*.DMdim_imported*/
{
	IGRint status;
	IGRint pcount, ccount, count, i, j;
	OM_S_OBJID md_id;
	OMuword md_os;
	struct GRid pret;
	OM_S_OBJECT_LINKAGE list[20], clist[2];
	extern GRclassid OPP_ACpretendin_class_id,
			 OPP_GRcontext_class_id;

	*imported = TRUE;

	status =
	ex$get_cur_mod(id = &md_id, osnum = &md_os);
	dm$status(action = RET_STATUS);

	status =
	om$get_channel_objects(
		objid = dim_id,
		osnum = dim_os,
		p_chanselect = &AS_notification,
		list = list,
		size = 20,
		count = (OMuint *) &pcount);
	dm$status(action = RET_STATUS);

	/*"pcount=%d\n", pcount*/

	for (i=0; i<pcount; i++)
	{
		pret.objid = list[i].S_objid;
		pret.osnum = list[i].osnum;

		/*"pret[%d]=%d,%d\n", i, pret.objid, pret.osnum*/

		if ((pret.osnum != md_os)
		||  !DMancestry_valid(pret, OPP_ACpretendin_class_id))
			continue;

		status =
		om$get_channel_count(
			objid = pret.objid,
			osnum = pret.osnum,
			p_chanselect = &ND_children,
			count = (OMuint *) &count);
		dm$status(action = RET_STATUS);

		/*"count=%d\n", count*/

		for (j=0; j<count; j++)
		{
			status =
			om$get_objid_at_index(
				objid = pret.objid,
				osnum = pret.osnum,
				p_chanselect = &ND_children,
				index = j,
				objidaddr = &impdim->objid,
				osnumaddr = &impdim->osnum);
			dm$status(action = RET_STATUS);

			if (DMancestry_valid(*impdim, OPP_DMroot_class_id))
			{
				/*|- Dimension imported -*/

				status =
				om$get_channel_objects(
					objid = pret.objid,
					osnum = pret.osnum,
					p_chanselect = &AS_listeners,
					list = clist,
					size = 2,
					count = (OMuint *) &ccount);
				dm$status(action = RET_STATUS);

				context->objid = clist[0].S_objid;
				context->osnum = clist[0].osnum;

				if (!DMancestry_valid(*context, OPP_GRcontext_class_id))
				{
					context->objid = clist[1].S_objid;
					context->osnum = clist[1].osnum;
				}

				*imported = TRUE;
				return(OM_S_SUCCESS);
			}
		}
	}

	impdim->objid = context->objid = NULL_OBJID;
	*imported = FALSE;
	return(OM_S_SUCCESS);
}

IGRint DMdisplay_status (msg,
			 dim_id,
			 dim_os,
			 md_env,
			 vw_rot,
			 type,
			 view_angle)
			 /*(

	 IGRint  *msg,
	 OM_S_OBJID  dim_id,
	 OMuword  dim_os,
	 struct GRmd_env  *md_env,
	 IGRmatrix  vw_rot,
	 IGRint  type,
	 IGRdouble  view_angle
	)
	*/
IGRint *msg;
OM_S_OBJID dim_id;
OMuword dim_os;
struct GRmd_env *md_env;
IGRmatrix vw_rot;
IGRint type;
IGRdouble view_angle;
/*.DMdisplay_status*/
{
	IGRint status, rc, i;
	IGRmatrix dm_rot;
	IGRvector vw_norm, dm_norm;
	BSrc bs_rc;

	status =
	om$send(msg = message DMroot.get_window_plane(
					&rc,
					md_env,
					dm_rot),
		senderid = NULL_OBJID,
		targetid = dim_id,
		targetos = dim_os);
	dm$status(action = RET_STATUS);

	for (i=0; i<3; i++)
	{
		vw_norm[i] = vw_rot[i+8];
		dm_norm[i] = dm_rot[i+8];
	}

	BSnorvec(&bs_rc, dm_norm);

	/*^
		print_matrix("dm_rot", dm_rot);
		print_matrix("vw_rot", vw_rot);
		print_matrix("matrix", md_env->md_env.matrix);
	*/

	DMcheck_normal(msg, type, view_angle, dm_norm, vw_norm);

	return(OM_S_SUCCESS);
}

IGRint DMcheck_normal (msg,
		       type,
		       view_angle,
		       dm_norm,
		       vw_norm)
		       /*(
	 IGRint  *msg,
	 IGRint  type,
	 IGRdouble  view_angle,
	 IGRdouble  dm_norm[3],
	 IGRdouble  vw_norm[3]
	)
	*/
IGRint *msg;
IGRint type;
IGRdouble view_angle;
IGRdouble dm_norm[3];
IGRdouble vw_norm[3];
/*.DMcheck_normal*/
{
	BSrc bs_rc;
	IGRdouble dotp, angle;

	/*"type = %d\n", type*/

	if (type == DEFAULT_DISPLAY)
	{
		if ((vw_norm[0] > DOTP_PARL_TOLERANCE)
		||  (vw_norm[1] > DOTP_PARL_TOLERANCE)
		||  (vw_norm[2] > DOTP_PARL_TOLERANCE))
		{
			/*| Orthogonal view */

			type = DISPLAY_PARALLEL;
		}
		else
		{
			/*| Non-orthogonal view */

			type = DISPLAY_ALL;
		}
	}

	dotp = BSdotp(&bs_rc, dm_norm, vw_norm);

	/*^
		print_point("dm_norm", dm_norm);
		print_point("vw_norm", vw_norm);
		printf("dotp = %f\n", dotp);
	*/

	if (fabs(dotp) < DOTP_PERP_TOLERANCE)
	{
		/*| Dimension Plane orthogonal to view */

		*msg = DIM_E_ORTHOGONAL;
		return(OM_S_SUCCESS);
	}

	if (type == DISPLAY_ALL)
	{
		/*| Display dimension */

		angle = view_angle * PI / 180.0;

		if( cos(angle) > fabs(dotp))
			*msg = DIM_E_OUTSIDEANGLE;
		else
		{
			if ((fabs(dotp) > DOTP_LOWER_BOUND)
			&&  (fabs(dotp) < DOTP_UPPER_BOUND))
				*msg = DIM_I_PLANAR;
			else	*msg = DIM_I_NONPLANAR;
		}
	}
	else if (type == DISPLAY_PARALLEL)
	{
		if ((fabs(dotp) > DOTP_LOWER_BOUND)
		&&  (fabs(dotp) < DOTP_UPPER_BOUND))
		{
			/*| Dimension parallel to view */

			*msg = DIM_I_PLANAR;
		}
		else
		{
			/*| Dimension not parallel to view */

			*msg = DIM_E_NONPARALLEL;
		}
	}

	return(OM_S_SUCCESS);
}

IGRint DMget_normal (msg,
		     dim_id,
		     dim_os,
		     dim_type,
		     txt_length,
		     dm_norm,
		     lbsys_mat,
		     text_mat,
		     md_env)
		     /*(
	 IGRint  *msg,
	 OM_S_OBJID  dim_id,
	 OMuword  dim_os,
	 IGRint  dim_type,
	 IGRdouble  *txt_length,
	 IGRdouble  dm_norm[3],
	 IGRdouble  *lbsys_mat,
	 IGRdouble  *text_mat,
	 struct GRmd_env  *md_env
	)
	*/
IGRint *msg;
OM_S_OBJID dim_id;
OMuword dim_os;
IGRint dim_type;
IGRdouble *txt_length;
IGRdouble dm_norm[3];
IGRdouble *lbsys_mat, *text_mat;
struct GRmd_env *md_env;
/*.DMget_normal*/
{
	IGRint status, index, rc;
	IGRlong long_rc;
	BSrc bs_rc;
	struct GRid text_grid;
	struct IGRlbsys   *lbsys_geom;
	struct IGRestx tx_attr;
	struct GRmd_env mod_info;
	IGRdouble xaxis[3], pt[3], x_line[2][3];

	if (dim_type == CENTER_LINE
	||  dim_type == LEADER_LINE
	||  dim_type == SURF)
	{
		IGRmatrix dm_rot;

		status =
		om$send(msg = message DMroot.get_window_plane(
						&rc,
						md_env,
						dm_rot),
			senderid = NULL_OBJID,
			targetid = dim_id,
			targetos = dim_os);
		dm$status(action = RET_STATUS);

		for (index=0; index<3; index++)
		    dm_norm[index] = dm_rot[8+index];

		return(OM_S_SUCCESS);
	}

	index = (dim_type == WELD)? TERM:DIM_TEXT;

	status =
	om$send(msg = message DMroot.return_dim_go (
					msg,
					index,
					FALSE,
					DM_TEXT,
					md_env,
					&text_grid),
		senderid = NULL_OBJID,
		targetid = dim_id,
		targetos = dim_os);
	dm$status(action = RET_STATUS);

	if (*msg == DIM_E_NO_OBJECT)
	   return(OM_S_SUCCESS);		

	if (lbsys_mat && text_mat)
	{
		MAidmx(&long_rc, mod_info.md_env.matrix);
		mod_info.md_env.matrix_type = MAIDMX;
	}
	else	mod_info = *md_env;

	/*| - Get text Orientation - */

	status =
	om$send(msg = message GRtext.GRgettxattr(
					&long_rc,
					&tx_attr,
					NULL,
					NULL),
		senderid = NULL_OBJID,
		targetid = text_grid.objid,
		targetos = text_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message GRvg.GRgenabsg(
				&long_rc,
				&mod_info.md_env.matrix_type,
				mod_info.md_env.matrix,
				(char **) &lbsys_geom),
		senderid = NULL_OBJID,
		targetid = text_grid.objid,
		targetos = text_grid.osnum);
	dm$status(action = RET_STATUS);

	if (lbsys_mat && text_mat)
	{
		short four=4;

		memcpy(lbsys_mat, lbsys_geom->matrix, 16*sizeof(double));

		MAmulmx(&long_rc,
			&four,
			&four,
			&four,
			md_env->md_env.matrix,
			lbsys_mat,
			text_mat);

		for (index=0; index<3; index++)
		    dm_norm[index] = text_mat[index*4+2];

		if ((tx_attr.just < CENTER_BOTTOM)
		||  (tx_attr.just > CENTER_TOP))
		{
			/*|- Justification is not center*/

			/*^
				print_point("diag_pt1", lbsys_geom->diag_pt1);
				print_point("diag_pt2", lbsys_geom->diag_pt2);
			*/

			xaxis[0] = lbsys_mat[0];
			xaxis[1] = lbsys_mat[1];
			xaxis[2] = lbsys_mat[2];
			
			DMlineptvec(lbsys_geom->diag_pt1, xaxis, x_line);
			BSproj0(&bs_rc, lbsys_geom->diag_pt2, x_line, pt);

			*txt_length = fabs(lbsys_geom->diag_pt1[0] - pt[0]);

			if (tx_attr.just < CENTER_BOTTOM)
				*txt_length = -(*txt_length);
			/*"txt_length = %f\n", *txt_length*/
		}
		else	*txt_length = 0.0;
	}
	else
	{
		for (index=0; index<3; index++)
		    dm_norm[index] = lbsys_geom->matrix[index*4+2];
	}

	BSnorvec(&bs_rc, dm_norm);

	return(OM_S_SUCCESS);
}

#argsused
IGRint DMadd_dim_to_rtree (msg,
			   dim_grid,
			   dim_info)
			   /*(
	 IGRlong  *msg,
	 struct GRid  *dim_grid,
	 char  *dim_info
	)
	*/
IGRlong *msg;
struct GRid *dim_grid;
char *dim_info;
/*.DMadd_dim_in_rtree*/
{
	IGRint status;
	IGRlong long_rc;
	IGRchar display;
	struct GRmd_env md_env;

	*msg = MSSUCC;

	status =
	om$send(msg = message DMroot.inq_display_type(&display),
		senderid = dim_grid->objid,
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	if (!(display & DIM_COMP_NOT_IN_RTREE))
	{
		/* pre 2.0 dimension components must be removed
		   from RTREE and dimension must be added in the
		   RTREE. This needs to be done for the first
		   time dimension gets a display.
		*/

		DMget_module_info(&md_env);

		status =
		om$send(msg = message GRvg.GRremwrng(
					&long_rc,
					&md_env),
			senderid = dim_grid->objid,
			p_chanselect = &AS_to_comp);
		/*"GRremwrng : status = %d\n", status*/
		if (status & long_rc & 1)
		{
			status =
			om$send(msg = message GRvg.GRaddwrng(
					&long_rc,
					&md_env),
				senderid = dim_grid->objid,
				targetid = dim_grid->objid,
				targetos = dim_grid->osnum);
			/*"GRaddwrng : status = %d\n", status*/
		}

		status =
		om$send(msg = message DMroot.set_display_type(
						BIT_OR,
						DIM_COMP_NOT_IN_RTREE,
						NULL),
			senderid = dim_grid->objid,
			targetid = dim_grid->objid,
			targetos = dim_grid->osnum);
		dm$status(action = RET_STATUS);
	}

	return(TRUE);
}

#argsused
IGRint DMconvert_20dim (msg,
			 dim_grid,
			 dim_info)
			 /*(
	 IGRlong  *msg,
	 struct GRid  *dim_grid,
	 char  *dim_info
	)
	*/
IGRlong *msg;
struct GRid *dim_grid;
char *dim_info;
/*.DMconvert_20dim*/
{
	IGRint status, radial;
	extern GRclassid OPP_DMradial_class_id,
			 OPP_DMcoord_class_id;

	*msg = MSSUCC;

	/*- This function is called by DMsuper wakeup and sent to
	    all dimensions in the file.

	    In 2.1 the DMradial & DMcoord classes are moved to
	    DMradjog & DMcoordj classes respectively to add
	    the jogged functionality. So the old objects
	    placed on these classes needed to changed to
	    thier new classes and thier new instances set properly.
	*/

	radial = FALSE;

	if ((radial = DMancestry_valid(*dim_grid, OPP_DMradial_class_id))
	||  (DMancestry_valid(*dim_grid, OPP_DMcoord_class_id)))
	{
		status =
		om$change_class(
			osnum = dim_grid->osnum,
			objid = dim_grid->objid,
			sd_override = OM_K_change_class_sd_override,
			classname = (radial)?"DMradjog":"DMcoordj");
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.jogged_off(),
			senderid = dim_grid->objid,
			targetid = dim_grid->objid,
			targetos = dim_grid->osnum);
		dm$status(action = RET_STATUS);

		if (!radial)
		{
			IGRint rc;
			IGRboolean first_in_cpx;
			struct GRid prev;
			struct DMtrak_info trak_info;

			status =
			om$send(msg = message DMroot.get_trak_info(
							&trak_info),
				senderid = dim_grid->objid,
				targetid = dim_grid->objid,
				targetos = dim_grid->osnum);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message DMroot.give_previous(
							&rc,
							&first_in_cpx,
							&prev),
				senderid = dim_grid->objid,
				targetid = dim_grid->objid,
				targetos = dim_grid->osnum);
			dm$status(action = RET_STATUS);
				
			trak_info.mea_trak |= DM_TRAK_ZONE1;

			if (first_in_cpx)
			   trak_info.mea_trak |= DM_TRAK_CTRL_DIM;

			if (!(trak_info.trak_dist > 0.0))
			   trak_info.mea_trak |= DM_TRAK_LOCK;

			status =
			om$send(msg = message DMroot.set_trak_info(
							REP_TRAK_DIST,
							&trak_info),
				senderid = dim_grid->objid,
				targetid = dim_grid->objid,
				targetos = dim_grid->osnum);
			dm$status(action = RET_STATUS);
		}
	}

	return(TRUE);
}

IGRint DMcompute_break_pt(
	bounded,
	brk_pos,
	brk_dist,
	cursor,
	brk_pt,
	start_pt,
	end_pt)
IGRboolean bounded;
IGRint *brk_pos;
IGRdouble *brk_dist;
IGRdouble cursor[3];
IGRdouble brk_pt[3];
IGRdouble start_pt[3];
IGRdouble end_pt[3];
/*.DMcompute_break_pt*/
{
	IGRdouble start_end[3], start_brk[3], end_brk[3];
	IGRdouble dotp_start, dotp_end, distance;
	IGRdouble line[6];
	BSrc bs_rc;

	DMlineptpt(start_pt, end_pt, line);
	BSproj0(&bs_rc, cursor, line, brk_pt);

	BSmkvec(&bs_rc, start_end, start_pt, end_pt);
	BSmkvec(&bs_rc, start_brk, start_pt, brk_pt);
	BSmkvec(&bs_rc, end_brk, end_pt, brk_pt);

	dotp_start = BSdotp(&bs_rc, start_end, start_brk);
	dotp_end = BSdotp(&bs_rc, start_end, end_brk);

	distance = BSlenvec(&bs_rc, start_end);

	*brk_pos = 0;
	*brk_dist = 0.0;

	if (dotp_start > 0.0 && dotp_end > 0.0)
	{
		if (bounded)
		{
			*brk_dist = 1.0;
			math_v_equal(brk_pt, end_pt);
		}
		else
		{
			*brk_pos = BRK_RIGHT;
			*brk_dist = BSlenvec(&bs_rc, end_brk);
		}
	}
	else if ((dotp_start > 0.0 && dotp_end < 0.0)
	       ||(dotp_start < 0.0 && dotp_end > 0.0))
	{
		*brk_pos = BRK_CENTER;
		*brk_dist = BSlenvec(&bs_rc, start_brk) / distance;
	}
	else
	{
		if (bounded)
		{
			*brk_dist = 0.0;
			math_v_equal(brk_pt, start_pt);
		}
		else
		{
			*brk_pos = BRK_LEFT;
			*brk_dist = BSlenvec(&bs_rc, start_brk);
		}
	}

	return(TRUE);
}

IGRint DMmake_circle(
	msg,
	radius,
	center_pt,
	norm,
	go_grid,
	md_env)
IGRint *msg;
IGRdouble *radius, *center_pt, *norm;
struct GRid *go_grid;
struct GRmd_env *md_env;
/*.DMmake_circle*/
{
	IGRint status, type;
	IGRlong long_rc;
	IGRdouble poles[21],weights[7],knots[10];
	struct IGRbsp_curve *bsp_curve;
	struct GRpost_info post_info;
	IGRvector unit_normal;
	extern IGRboolean GRabsg_del_all();

        status =
       	om$send(msg = message GRvg.GRgenabsg(
                                        &long_rc,
                                        &md_env->md_env.matrix_type,
					md_env->md_env.matrix,
                                        (char **)&bsp_curve),
		senderid = NULL_OBJID,
                targetid = go_grid->objid,
       	        targetos = go_grid->osnum);
	dm$status( action = RET_STATUS);

	/*  we need to allocate memory for 7 poles, 7 knots
	    and 7 weights to take care of all cases */

	bsp_curve->poles = poles;
	bsp_curve->weights = weights;
	bsp_curve->knots = knots;

	/*^
		print_point("center_pt", center_pt);
		print_point("norm", norm);
		printf("radius = %f\n", *radius);
	*/

	status =
       	BSprepcirc(
		&long_rc,
		center_pt,
		radius,
		norm,
		bsp_curve,
		unit_normal,
		&type);
	if(status != OM_S_SUCCESS || long_rc != BSSUCC)
	{
		printf("DMmake_circle : BScirrdcr() Fails\n");
		return(OM_E_ABORT);
	}

	/*^
		{
		int i;
		printf("num poles:%ld\n",bsp_curve->num_poles);
		for( i = 0;i<bsp_curve->num_poles;i++)
			printf("pole[%d]:%lf\n",i,bsp_curve->poles[i]);
		}
	*/

	post_info.construct_flag = FALSE;

	status =
        om$send(msg = message GRvg.GRpostabsg(
					&long_rc,
					md_env,
               	                        &post_info,
               	                      	(char *)bsp_curve,
                       	              	&go_grid->objid),
		senderid = NULL_OBJID,
                targetid = go_grid->objid,
       	        targetos = go_grid->osnum);
	dm$status( action = RET_STATUS);

	/*|- Clear the cache memory */

	status = GRabsg_del_all();
	dm$status(action = RET_STATUS);

	*msg = MSSUCC;
	return(TRUE);
}



IGRint DMget_current_dim_layer(par_env_layr, current_layer, invalid_layer)
IGRshort par_env_layr,*current_layer;
IGRboolean *invalid_layer;
{
	IGRshort active_layer ;

	*invalid_layer = FALSE;
	gr$get_active_layer(buffer = &active_layer);

	*current_layer = active_layer - (DM_ACTIVE_LAYER - par_env_layr);
	if( ( *current_layer < 0) || ( *current_layer > 1023) )
	{
		*invalid_layer = TRUE;
		*current_layer = active_layer;
	}
	return(TRUE);

}

IGRboolean DMvalid_dim_offset_active_layer(par_env_layr)
IGRshort par_env_layr;
{

        if( ( par_env_layr >= DM_ACTIVE_LAYER_MIN_OFFSET) &&
            ( par_env_layr  < DM_ACTIVE_LAYER_MAX_OFFSET) )
                return(TRUE);
        else
                return(FALSE);
}

IGRint DMupdate_active_layer_info(msg,dim,par_env)
IGRint *msg;
struct GRid *dim;
struct DMenv_param *par_env;
{
  IGRint status;
  IGRshort current_layer,dim_type,par_layer;
  IGRboolean invalid_layer,env_type;
  struct DMenv_param env;
  struct DMsenv_param senv;
  char *p_par_env;
  
  *msg = DIM_S_SUCCESS;

    /* Ignore incoming par env*/
    status = om$send( msg = message DMroot.get_dim_type(&dim_type),
		senderid = NULL_OBJID, 
		targetid = dim->objid,
		targetos = dim->osnum);
    dm$status(action = RET_STATUS);

    if( ((1 << dim_type) & ANNOTATION_MASK) ||
        dim_type == WELD                    ||
        dim_type == SURF                    ||
        dim_type == CENTER_LINE )
	{
		env_type = DM_SENV_PARAM;
		p_par_env = (char *)&senv;
	}
	else
	{
		env_type = DM_ENV_PARAM;
		p_par_env = (char *)&env;
	}

	status = 
	dm$get_dim_param( type = env_type,
			  dim_objid = dim->objid,
			  dim_osnum = dim->osnum,
			  p_data = p_par_env);
	dm$status( action = RET_STATUS);

	if ( env_type == DM_SENV_PARAM)
		par_layer =  senv.dim_layr;
	else
		par_layer =  env.dim_layr;

  if(DMvalid_dim_offset_active_layer(par_layer))
     {
       DMget_current_dim_layer(par_layer, 
			       &current_layer, 
			       &invalid_layer);

	if ( env_type == DM_SENV_PARAM)
		senv.dim_layr = current_layer;
	else
		env.dim_layr  = current_layer;

       /* Set dim to state EDIT */

       status =
       om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_IN_EDIT),
	       senderid = dim->objid,
	       targetid = dim->objid,
	       targetos = dim->osnum);
       dm$status(action = RET_STATUS);

       /*| Put environment */

       status =
       dm$put_dim_param(type = env_type,
			dim_objid = dim->objid,
			dim_osnum = dim->osnum,
			p_grid = (struct GRid *)NULL,
			p_data =  p_par_env);
       dm$status(action = RET_STATUS);

       /*| Clear EDIT state*/

       status =
       om$send(msg = message DMroot.set_dim_state(BIT_CLEAR, DIM_IN_EDIT),
	       senderid = dim->objid,
	       targetid = dim->objid,
	       targetos = dim->osnum);
       dm$status(action = RET_STATUS);
     }
     return(TRUE);
}
end implementation DMroot;
