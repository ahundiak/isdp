/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:31 $
$Locker:  $
*/

class implementation DMdim;

#define AS_DEBUG 1

#include "cotxmacros.h"
#include "grownerdef.h"
#include "diminst.h"
#include "dimcomplex.h"
#include "dimtxt.h"

#include "dimlinear.h"
#include "dimradial.h"
#include "dimangular.h"
#include "dimtxtdef.h"
#include "sunlimits.h"
#include "DItypedef.h"

#include "DIdef.h"
#include "DIprims.h"
#include "refdef.h"
#include "matypemx.h"
#include "mascalvc.h"
#include "mamulmx.h"
#include "mainvmx.h"
#include "maaddvc.h"
#include "bsrpower.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bsdetmat.h"
#include "bscrossp.h"

%safe
#include <math.h>
%endsafe

extern double fabs();
extern IGRboolean BSproj0();
extern GRclassid OPP_dim_plan_class_id;
extern GRclassid OPP_DMsrc_class_id;
extern GRclassid OPP_expression_class_id;
extern GRclassid OPP_DMcenline_class_id;
extern GRclassid OPP_GRdrawview_class_id;
extern IGRboolean GRabsg_del_all();

from GRtext	import GRreplace_text, GRfield_inquire;
from GRtext	import GRchgtextattr, GRgettxattr;
from GRlinear	import GRgetpolyline;
from dim_param	import give_internal, edit;
from DMtext	import make_text_string, DMget_dim_fields;
from dim_src	import DMgive_structure;
from dim_plan	import give_parents;
from GRconic	import GRgetarc;
from GRdrawview import GRget_drawview_scale;
from GRreffile	import GRgetrfprops, GRgetscale;

/*
 *    Global Dim_grid used during forms for scale functionality, put
 *   during 2.1 TR, needs to moved in later versions to "glob.I"
 */

#omdef dm$return_dim_go(index, p_grid, obj_type)
{
	if (p_grid == NULL)
	{
		if (index == DIM_NO_INDEX)
		{
			*msg = DIM_E_BAD_OBJSPEC;
			return(OM_E_ABORT);
		}

		p_grid = &tmp_grid;
	}

	if (index != DIM_NO_INDEX)
	{
		status =
		om$send(msg = message DMroot.return_dim_go(
						msg,
						index,
						TRUE,
						obj_type,
						md_env,
						p_grid),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	/*	printf("go = %d, %d\n", p_grid->objid, p_grid->osnum); */
}
#endomdef

method position_text(
	IGRint *msg;
	IGRboolean txt_flag;
	IGRint text_index;
	struct GRid *text_grid;
	struct GRmd_env *md_env;
	IGRshort  justification;
	IGRdouble origin[3];
	IGRdouble orie_vec[3];
	IGRdouble norm[3];
	struct DMloc_param *par_loc;
	struct DMenv_param *par_env)
{
	IGRint status, rc;
	IGRlong long_rc;
	BSrc bs_rc;
	IGRdouble perp_vec[3];
	struct IGRlbsys *lbsys;
	struct GRid tmp_grid;
	struct GRdpb_text_symb text_symb;
	struct GRpost_info info;
	IGRint attr_num;
	int i;
	OM_S_OBJID md_id_save;
	IGRshort mat_type;
	struct GRid line_grid,dummy;
	IGRshort rows,cols;
	IGRmatrix rot_matrix, inp_matrix, inv_matrix;

	/* - parameters of box and underline*/

	IGRuchar field_num;
	IGRshort length;
	IGRint four;
	IGRuchar *contents;
	IGRuchar attributes;
	struct extents extents;
	GRrange range;
	struct just_pts just_pts;
	IGRdouble box[5][3];
	IGRint override_on, nts_uline_on=0;
	IGRdouble x_gap, y_gap;
	IGRvector x_dir, y_dir;
	struct DMmisc_param misc_param;
	extern struct DMglobal_param frm_glob;

	*msg = DIM_S_SUCCESS;

	dm$return_dim_go(index=text_index, p_grid=text_grid, obj_type=DM_TEXT);

	/*^ print_point("origin", origin); */

	override_on = om$dimension_of(varray = me->dim_override);

	if (txt_flag)
	{
		if (frm_glob.dim_mode == MODELING_MODE)
		{
			if (me->geom_type & DIM_INTERMEDIATE)
				nts_uline_on = TRUE;
			else	nts_uline_on = FALSE;
		}
		else
		{
			nts_uline_on = (par_env->nts_uline && override_on);
		}
	}
	
	if (justification != -1)
	{
		text_symb.Active_just = justification;
		attr_num = GRTEXT_JUST;

		md_id_save = md_env->md_id.objid;
		md_env->md_id.objid = NULL_OBJID;

		status =
		om$send(msg = message GRtext.GRchgtextattr(
						&long_rc,
						md_env,
						attr_num,
						&text_symb),
			targetid = text_grid->objid,
			targetos = text_grid->osnum);
		dm$status(action = RET_STATUS);

		md_env->md_id.objid = md_id_save;
		

		/* - Dimension Text - Update Box and/or Underline postion - */


		if ( txt_flag && (nts_uline_on || par_loc->tole_mode == TOLE_MODE_BOX))
		{
			status =
			dm$get_dim_param(
				type = DM_MISC_PARAM,
				dim_objid = my_id,
				dim_osnum = OM_Gw_current_OS,
				p_data = (char *) &misc_param);
			dm$status(action = RET_STATUS);

			/*| - Under line or Box needs to be constructed */

			/*| - Get the dim field extents  */
			field_num = FNUM_DIM_FIELD;
			length = 0;
			contents = NULL;

			status =
			om$send(msg = message GRtext.GRfield_inquire(
						&long_rc,
						&field_num,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						&length,
						&contents,
						&attributes,
						&extents,
						range,
						&just_pts),
				targetid = text_grid->objid,
				targetos = text_grid->osnum);
			dm$status(action = RET_STATUS);

			x_gap = misc_param.std_param.dm_box_hor_gap * par_env->txt_heig;
			y_gap = misc_param.std_param.dm_box_ver_gap * par_env->txt_heig;

			status =
			om$send(msg = message GRvg.GRgenabsg(
						&long_rc,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						(char **)&lbsys),
				targetid = text_grid->objid,
				targetos = text_grid->osnum);
			dm$status(action = RET_STATUS);

			for (i=0; i<3; i++)
			{
				x_dir[i] = lbsys->matrix[4*i];
				y_dir[i] = lbsys->matrix[4*i+1];
			}

			DMextend_points(
				just_pts.left_bottom,
				just_pts.right_bottom,
				just_pts.right_top,
				just_pts.left_top,
				x_dir,
				y_dir,
				x_gap,
				y_gap);

			math_v_equal( box[0],just_pts.left_bottom);
			math_v_equal( box[1],just_pts.right_bottom);
			math_v_equal( box[2],just_pts.right_top);
			math_v_equal( box[3],just_pts.left_top);
			math_v_equal( box[4],just_pts.left_bottom);

			if( par_loc->tole_mode == TOLE_MODE_BOX)
			{ 
				four = 5;
				status = 
				om$send( msg= message DMroot.position_line_string(
								&rc,
								DIM_BOX,
								NULL,
								md_env,
								four,
							(IGRdouble *)box),
				targetid = my_id);
				dm$status( action= RET_STATUS);
			}	
			else
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
 								DIM_BOX,
								md_env),
				targetid = my_id);
				dm$status(action = RET_STATUS);
			}

			if (nts_uline_on)
			{

				status = 
				om$send( msg= message DMroot.position_line(
							&rc,
							DIM_ULINE,
							NULL,
							md_env,
						        (IGRdouble *) box),
				targetid = my_id);
				dm$status( action= RET_STATUS);
			}
			else
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								DIM_ULINE,
								md_env),
				targetid = my_id);
				dm$status(action = RET_STATUS);
			}
		}
	}

	status =
	om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					(char **)&lbsys),
		targetid = text_grid->objid,
		targetos = text_grid->osnum);
	dm$status(action = RET_STATUS);

	/* - Compute the transformation matrix for box and underline*/
	for( i = 0; i< 16 ;i++)
		inp_matrix[i] = lbsys->matrix[i];

	if (orie_vec && norm)
	{
		/*^
			print_point("orie_vec", orie_vec);
			print_point("norm", norm);
		*/

		BSnorvec(&bs_rc, orie_vec);
		BSnorvec(&bs_rc, norm);
		BScrossp(&bs_rc, norm, orie_vec, perp_vec);
		if (bs_rc != BSSUCC)
		{
			*msg = DIM_E_BSMATH;
			return(OM_E_ABORT);
		}
		BSnorvec(&bs_rc, perp_vec);

		for (i=0; i<3; i++)
		{
			lbsys->matrix[i*4] = orie_vec[i];
			lbsys->matrix[i*4 + 1] = perp_vec[i];
			lbsys->matrix[i*4 + 2] = norm[i];
		}
	}

	lbsys->matrix[12] =
	lbsys->matrix[13] =
	lbsys->matrix[14] = 0.0;
	lbsys->matrix[15] = 1.0;

	lbsys->matrix[3]  = origin[0];
	lbsys->matrix[7]  = origin[1];
	lbsys->matrix[11] = origin[2];

	info.construct_flag = FALSE;

	/*^ print_matrix("matrix", lbsys->matrix); */

	status =
	om$send(msg = message GRvg.GRpostabsg(
					&long_rc,
					md_env,
					&info,
					(char *)lbsys,
					&text_grid->objid),
		targetid = text_grid->objid,
		targetos = text_grid->osnum);

	if (!txt_flag)
	{
		/* - Terminator - Procesing is over - */

		return(OM_S_SUCCESS);
	}

	if ( txt_flag && !(nts_uline_on || par_loc->tole_mode == TOLE_MODE_BOX))
	{
		if( me->comp_mask &(1<< DIM_BOX))
		{
			status =
			om$send(msg = message DMroot.delete_dim_go(
							&rc,
							DIM_BOX,
							md_env),
			targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		if( me->comp_mask &(1<< DIM_ULINE))
		{
			status =
			om$send(msg = message DMroot.delete_dim_go(
							&rc,
							DIM_ULINE,
							md_env),
			targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		return(OM_S_SUCCESS);
	}

	if(( me->comp_mask &(1<< DIM_BOX)) ||
	   ( me->comp_mask &(1<< DIM_ULINE)))
	{
		/* - Find the  rotation  matrix - */
		rows = cols = 4;
		status = MAinvmx(&long_rc, &rows, inp_matrix, inv_matrix);
		dm$status(action=RET_STATUS);

		MAmulmx(&long_rc,&rows,&cols,&rows,lbsys->matrix,
			inv_matrix, rot_matrix);

		MAtypemx(&long_rc,rot_matrix,&mat_type);

		if( me->comp_mask &(1<< DIM_BOX))
		{
			status =
			om$send(msg = message DMroot.return_dim_go(
							msg,
							DIM_BOX,
							FALSE,
							DM_LINE_STR,
							md_env,
							&line_grid),
			targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send( msg = message GRgraphics.GRxform( &long_rc,
								   md_env,
								   &mat_type,
								   rot_matrix,
								   &dummy.objid),
				targetid = line_grid.objid,
				targetos = line_grid.osnum);
			dm$status(action = RET_STATUS);

		}

		if( me->comp_mask &(1<< DIM_ULINE))
		{
			status =
			om$send(msg = message DMroot.return_dim_go(
							msg,
							DIM_ULINE,
							FALSE,
							DM_LINE,
							md_env,
							&line_grid),
			targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send( msg = message GRgraphics.GRxform( &long_rc,
								   md_env,
								   &mat_type,
								   rot_matrix,
								   &dummy.objid),
				targetid = line_grid.objid,
				targetos = line_grid.osnum);
			dm$status(action = RET_STATUS);
		}
	}

	if ((frm_glob.dim_mode == MODELING_MODE) && txt_flag)
		me->geom_type &= ~DIM_INTERMEDIATE;

	/*|- Clear the cache memory */

	status =
	GRabsg_del_all();
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method toggle_ter_loca(IGRint *msg; struct GRmd_env *md_env)
{
	IGRint status;

	*msg = DIM_S_SUCCESS;
	me->ter_loca = (me->ter_loca == TER_LOCA_INTERNAL)?
			TER_LOCA_EXTERNAL:TER_LOCA_INTERNAL;

	if (md_env) 
	{
		struct GRid my_grid;

		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;

                status = dm$change_node(
                        as_grid = my_grid,
                        md_env = md_env,
                        broadcast = FALSE);
                dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method get_dim_params(
	IGRint *msg;
	IGRint type;
	IGRint size;
	char   *param)
{
	IGRint status, rc;
	struct GRid param_grid;
	IGRint param_index;
	IGRint count;

	struct DMenv_param par_env;
	struct DMloc_param par_loc;
	struct DMmisc_param *par_misc;
	IGRint vsize;

	*msg = DIM_S_SUCCESS;

	if (!param)
	{
		printf("DMroot.get_dim_param: NULL pointer for data\n");
		return(OM_E_ABORT);
	}

	switch(type)
	{
		case DM_ENV_PARAM:

		param_index = DIM_ROOT_ENV;
		break;

		case DM_LOC_PARAM:

		param_index = DIM_ROOT_LOC;
		break;

		case DM_MISC_PARAM:

		status =
		om$send(msg = message DMdim.get_active_params(
					&rc, &par_env, &par_loc),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		dm$get_dim_param(
			type = type,
			p_data = (char *) param);
		dm$status(action = RET_STATUS);

		par_misc = (struct DMmisc_param *)param;
		vsize = om$dimension_of(varray = me->dim_override);
		par_misc->mod_comp = (vsize)?MOD_COMP_STATIC:MOD_COMP_DYNAMIC;

		status =
		om$send(msg = message DMtext.DMget_dim_fields(
					&par_env,
					&par_loc,
					par_misc),
			p_chanselect = &AS_to_comp,
			senderid = my_id,
			from = 0, to = 0);
		dm$status(action = RET_STATUS);

		if (vsize)
		{
			memcpy( par_misc->dim_override,
				me->dim_override,
				vsize);
		}

		par_misc->dim_override[vsize] = '\0';

		/*^
			printf("prefix=%s\n", par_misc->prefix);
			printf("suffix=%s\n", par_misc->suffix);
			printf("pri_tole_sym=%s\n", par_misc->pri_tole_sym);
			printf("sec_tole_sym=%s\n", par_misc->sec_tole_sym);
			printf("dim_override=%s\n", par_misc->dim_override);

			printf("pri_label=%s\n", par_loc.primary.label);
			printf("sec_label=%s\n", par_loc.secondary.label);
			printf("pri sub label=%s\n",par_loc.primary.sub_label);
			printf("sec sub label=%s\n",par_loc.secondary.sub_label);
			printf("prefix_disp=%d\n", par_misc->prefix_disp);
			printf("suffix_disp=%d\n", par_misc->suffix_disp);
			printf("mod_comp=%d\n", par_misc->mod_comp);
		*/

		return(OM_S_SUCCESS);

		case DM_SENV_PARAM:

		status =
		dm$get_dim_param(type = type, p_data = (char *) param);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);

		default:

		/*"Illegal type=%d\n", type*/
		return(OM_E_ABORT);
	}

	status =
	om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					&param_grid,
					1,
					NULL,
					param_index,
					param_index,
					&count),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!count)
	{
		/*| Error obtaining parameter grid */
		return(OM_E_ABORT);
	}				

	/*| - Get Dim Params - */

	status =
	om$send(msg = message dim_param.give_internal(
						type,
						size,
						param),
		targetid = param_grid.objid,
		targetos = param_grid.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method set_dim_params(
	IGRint *msg;
	IGRint type;
	IGRint size;
	struct GRmd_env *md_env;
	char   *param)
{
	IGRint status, rc, index;
	struct GRid grid;
	struct DMenv_param par_env;
	struct DMloc_param par_loc;

	if (type == DM_ENV_PARAM || type == DM_LOC_PARAM)
	{
		index = (type == DM_ENV_PARAM)?DIM_ROOT_ENV:DIM_ROOT_LOC;

		if (type == DM_ENV_PARAM
		&&  (me->dim_type == STACKED_LINEAR
		||   me->dim_type == SYMMETRICAL_DIAMETER
		||   me->dim_type == STACKED_ANGULAR))
		{
			struct DMenv_param *new_env, old_env;

			status =
			om$send(msg = message DMroot.get_dim_params(
						&rc,
						DM_ENV_PARAM,
						sizeof(struct DMenv_param),
            					(char *) &old_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			new_env = (struct DMenv_param *)param;

			me->trak_dist =
				new_env->txt_heig * new_env->lin_offs_r +
				me->trak_dist -
				old_env.txt_heig * old_env.lin_offs_r;
		}

		status =
		om$send(msg = message dim_param.edit(
					type,
					size,
					param,
					md_env,
					&grid),
			p_chanselect = &ND_father,
			from = index, to = index);
		dm$status(action =  RET_STATUS);
	}
	else
	{
		status =
		om$send(msg = message DMdim.get_active_params(
					&rc, &par_env, &par_loc),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMdim.make_text_string(
						&rc,
						me->dim_value,
						md_env,
						&par_env,
						&par_loc,
			(struct DMmisc_param *) param),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method get_active_params(
	IGRint *msg;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc)
{
	IGRint status, rc;
	struct DMmisc_param misc;
	extern struct DMglobal DM_global;

	status =
	om$send(msg = message DMroot.get_dim_params(
						&rc,
						DM_ENV_PARAM,
						sizeof(struct DMenv_param),
						(char *) par_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.get_dim_params(
						&rc,
						DM_LOC_PARAM,
						sizeof(struct DMloc_param),
						(char *) par_loc),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (par_loc->txt_posn == TXT_POSN_ABOVE
	&&  ((par_env->nts_uline && om$dimension_of(varray = me->dim_override))
	    || par_loc->tole_mode == TOLE_MODE_BOX))
	{
		dm$get_dim_param(
			type = DM_MISC_PARAM,
			p_data = (char *) &misc);

		par_env->txt_yoff_r += misc.std_param.dm_box_ver_gap;
	}

	switch(me->dim_type)
	{
		case STRINGED_LINEAR:
		case STRINGED_ANGULAR:
		case COORDINATE:

		par_env->lin_offs_r = 0.0;
		par_env->sym_posn = SYM_POSN_NONE;
		break;

		case STACKED_LINEAR:
		case SINGLE_PARALLEL:
		case STACKED_ANGULAR:
		case SINGLE_ARC_LENGTH:
		case SINGLE_ARC_ANGLE:

		par_env->sym_posn = SYM_POSN_NONE;
		break;

		case SYMMETRICAL_DIAMETER:

		par_loc->ter_disp &= (~TER_DISP_ORI);
		par_loc->proj_disp &= (~PROJ_DISP_ORI);
		par_loc->lin_disp = LIN_DISP_ON;
		break;

		case CIRCULAR_DIAMETER:
		case RADIAL_DIAMETER:

		dm$get_dim_param(
			type = DM_MISC_PARAM,
			p_data = (char *) &misc);

		if ((par_env->dim_stan == DIM_STAN_DIN) &&
		    (me->ter_loca == TER_LOCA_INTERNAL))
		{
			if (misc.aut_dia == 1)
			par_env->sym_posn = SYM_POSN_NONE;			
		}
	}

	if (me->dim_type == COORDINATE)
	{
		IGRboolean first_in_cpx;
		struct GRid prev;

		status =
		om$send(msg = message DMroot.give_previous(
						&rc,
						&first_in_cpx,
						&prev),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (first_in_cpx)
		{
			par_env->dual_mode = DUAL_MODE_OFF;
			par_loc->tole_mode = TOLE_MODE_OFF;
			par_loc->primary.label[0] =
			par_loc->primary.sub_label[0] = '\0';
			par_loc->primary.decacc = DECI_ACC1;
			par_loc->primary.leading = TRUE;
		}
	}

	/*|- If geom_type is set as REFERENCE_DIM set tol_mode to REF_TYPE */

	if (me->geom_type & DIM_REFERENCE)
	   par_loc->tole_mode = TOLE_MODE_REF;

	return(OM_S_SUCCESS);
}

method make_text_string(
	IGRint *msg;
	IGRdouble dimn_value;
	struct GRmd_env *md_env;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMmisc_param *par_misc)
{
	IGRint status, rc, len, count;
	IGRdouble sca_fact, scale;
	struct GRid grid, list[MAX_DIM_ROOTS];
	struct GRid text_grid, first;
	IGRchar dual_mode;
	IGRint  size, drawview;
	IGRchar name[DI_PATH_MAX];
	struct DMmisc_param misc_param;

	/*|- Find out from dimension source if any scale is present*/

	if((me->display & DIM_AUTO_SCALED)  && !(me->geom_type & DIM_DRIVING)) 
	{
        	status =
        	om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
               	                 targetid = my_id);
        	dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.DMreturn_roots(&count, list),
				targetid = first.objid,
				targetos = first.osnum);
		dm$status(action = RET_STATUS);

		DMget_scale(&scale, &drawview, list[DIM_CPX_ORIG], md_env);

		if((scale > 0.0) && (fabs(par_env->sca_fact - scale) > 0.00001))
				par_env->sca_fact = scale;

	}

	if (!(me->dim_state)
	&&  (fabs(me->dim_value - dimn_value) < 1e-9))
	{
		/*| NO CHANGE NEEDED IN DIM_TEXT */

		return(OM_S_SUCCESS);
	}

	/*| Get Miscellaneous Params */

	me->dim_value = dimn_value;

	status =
	om$send(msg = message DMroot.return_dim_go(
					&rc,
					DIM_TEXT,
					TRUE,
					DM_TEXT,
					md_env,
					&text_grid),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/* - If dimension in placement use global misc parameters
	     otherwise extract parameters from dimension text - */

	if (par_misc)
		misc_param = *par_misc;
	else
	{
		status =
		dm$get_dim_param(
			type = DM_MISC_PARAM,
			dim_objid = (me->dim_state & DIM_IN_PLACEMENT)?NULL_OBJID:my_id,
			dim_osnum = OM_Gw_current_OS,
			p_data = (char *) &misc_param);
		dm$status(action = RET_STATUS);
	}

	dual_mode = par_env->dual_mode;
	sca_fact  = par_env->sca_fact;
	len = strlen(misc_param.dim_override);
	if (!len) misc_param.mod_comp = MOD_COMP_DYNAMIC;

	/* - If dimension is in placement copy override value
	     from the global parameters - */

	if (me->dim_state & DIM_IN_PLACEMENT
	||  me->dim_state & DIM_IN_EDIT)
	{
		/*| - Copy override value to value - */

		size = strlen(misc_param.dim_override);

		/*"size=%d\n", size*/

		status =
		om$vla_set_dimension(varray = me->dim_override, size = size);
		dm$status(action = RET_STATUS);

		memcpy(me->dim_override, misc_param.dim_override, size);
	}

	/* - If the dimension name needs to be displayed
	     then get the expression name and display as
	     the override value - */

	if (me->geom_type & DIM_BY_NAME)
	{
		status =
		om$get_objid_at_index(
			object = me,
			p_chanselect = &AS_to_owner,
			index = 0,
			objidaddr = &grid.objid,
			osnumaddr = &grid.osnum);
		if (!((status & 1) &&
		DMancestry_valid(grid, OPP_expression_class_id)))
		{
			grid.objid = my_id;
			grid.osnum = OM_Gw_current_OS;
		}

		status =
		di$untranslate(
			objname = name,
			objid = grid.objid,
			osnum = grid.osnum);
		if (status == DIR_S_SUCCESS)
		{
			char *sname;

			sname = &name[strlen(name)-1];
			while ((sname != name) && (*sname != ':'))
				sname--;
			sname++;

			par_env->dual_mode = DUAL_MODE_OFF;
			misc_param.mod_comp = MOD_COMP_STATIC;
			memcpy(misc_param.dim_override, sname, EXFI_STRLEN);
		}
	}

	/* - If the dimension value is overridden with a non-numeric
	     value - dual mode display is not possible - in such a
	     case turn off dual mode display - */

	if (misc_param.mod_comp == MOD_COMP_STATIC
	&&  me->dim_type != STACKED_ANGULAR
	&&  me->dim_type != STRINGED_ANGULAR)
	{
		IGRint dot, i, ch;

		/*| - MOD_COMP_STATIC - */

		par_loc->deci_frac = DECIMAL_MODE;
		par_loc->primary.decacc =
		par_loc->secondary.decacc = DECI_ACC1;

		dot = FALSE;
		for (i=0; i<len; i++)
		{
			ch = misc_param.dim_override[i];
			if (ch == '.') 
			{
				/*|DOT found*/
				if (dot)
				{
					par_env->dual_mode = DUAL_MODE_OFF;
					break;
				}

				dot = TRUE;
			}
			else if ((ch < '0') || (ch > '9'))
			{
				par_env->dual_mode = DUAL_MODE_OFF;
				break;
			}
			else if (dot && par_loc->primary.decacc < DECI_ACC_7)
			{
				par_loc->primary.decacc++;
				par_loc->secondary.decacc++;
			}
		}

		par_env->sca_fact = 1.0;
	}

	if (me->geom_type & DIM_DRIVING) 
	{
		me->display &= ~DIM_AUTO_SCALED;
		par_env->sca_fact = 1.0;
	}

	status =
	om$send(msg = message DMtext.make_text_string(
				dimn_value + 1e-8,
				me->dim_type,
				par_loc,
				par_env,
				&misc_param,
				md_env),
		targetid = text_grid.objid,
		targetos = text_grid.osnum);
	dm$status(action=RET_STATUS);

	/* - Reset dual_mode value - */

	par_env->dual_mode = dual_mode;
	par_env->sca_fact  = sca_fact;

	me->dim_state &= ~DIM_TEXT_NEEDS_UPDATE;

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method get_info(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct diminfo *info)
{
	IGRint status, rc, i, j, size;
	IGRint ori_index, cpx_type, pcount;
	IGRboolean first_in_cpx;
	struct GRid my_par, impdim,go_grid;
	struct GRid plist[MAX_DIM_ROOTS];
	struct dim_ret_struct dmstr;

	if(me->geom_type & DIM_IMPORTED)
	{
		/*|- Imported dimension - fill parent dim info */

		status =
		om$send(msg = message NDnode.NDget_objects(
						ND_ROOT,
						plist,
						MAX_DIM_ROOTS,
						NULL,
						NULL,
						OM_K_MAXINT,
						&pcount),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.ASreturn_go(
						&impdim,
						&info->matrix_type,
						info->matrix),
			targetid = plist[pcount-1].objid,
			targetos = plist[pcount-1].osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMdim.get_info(
						msg,
						md_env,
						info),
			targetid = impdim.objid,
			targetos = impdim.osnum);
		dm$status(action = RET_STATUS);

		info->dim_in_ref = impdim;
		info->dim_value = me->dim_value;

		return(OM_S_SUCCESS);
	}
	else info->dim_in_ref.objid = NULL_OBJID;

	info->dim_type = me->dim_type;
	info->geom_type = me->geom_type;
	info->display = me->display;
	info->dim_value = me->dim_value;

	info->lin_axis = WIN_X_AXIS;

	status =
	om$send(msg = message DMroot.DMreturn_roots(
					&info->count,
					info->list),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.give_previous(&rc, &first_in_cpx, &my_par),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	info->prev_dim = my_par;

	if (rc == DIM_S_SUCCESS && !first_in_cpx)
	{
		status =
		om$send(msg = message DMroot.get_complex_type(&cpx_type),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (cpx_type == STACKED_CPX
		||  cpx_type == COORDINATE_CPX)
		{
			status =
			om$send(msg = message DMroot.get_first_in_cpx(&rc, &my_par),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			ori_index = DIM_CPX_ORIG;
		}
		else	ori_index = DIM_CPX_MEAS;

		status =
		om$send(msg = message DMroot.DMreturn_roots(
						&pcount,
						plist),
			targetid = my_par.objid,
			targetos = my_par.osnum);
		dm$status(action = RET_STATUS);

		info->list[DIM_CPX_ORIG] = plist[ori_index];
	}

	status =
	om$send(msg = message DMroot.get_dimension_plane(
						&rc,
						md_env,
						&info->plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	info->const_plane.objid  =
	info->meas_axis[0].objid =
	info->meas_axis[1].objid = NULL_OBJID;


	status =
	om$send(msg = message NDnode.ASreturn_go(
				     &go_grid,
				     &info->matrix_type,
				     info->matrix),
		targetid = info->list[DIM_ROOT_PLAN].objid,
		targetos = info->list[DIM_ROOT_PLAN].osnum);
	dm$status(action = RET_STATUS);
		
	status =
	om$send(msg = message dim_plan.give_parents(&pcount, plist),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	for (i=j=0; i<pcount; i++)
	{
		if (DMancestry_valid(plist[i], OPP_dim_plan_class_id))
			info->const_plane = plist[i];
		else if (j < 2)
			info->meas_axis[j++] = plist[i];
		else
		{
			dbg$print(msg = "Too many parents for plan");
		}
	}

	if ((me->dim_type == STACKED_ANGULAR)
	||  (me->dim_type == STRINGED_ANGULAR))
	{
		info->ang_sector = 0;

		if(me->mea_trak & CLOCK_WISE)
			info->ang_sector |= CLOCK_WISE;

		/*|- get go direction from DMsrc objects */

		status =
		om$send(msg = message dim_src.DMgive_structure(
							&rc,
							ORIG_INFO,
							FALSE,
							&dmstr,
							md_env),
			targetid = info->list[DIM_CPX_ORIG].objid,
			targetos = info->list[DIM_CPX_ORIG].osnum);
		dm$status(action = RET_STATUS);

		if(dmstr.type == DMkeyseg)
		{
			if(me->mea_trak & ORIG_START)
			{
				if (dmstr.var.dm_keyseg.u_par == 0.0)
				   info->ang_sector |= ORIG_START;
			}
			else
			{
				if (dmstr.var.dm_keyseg.u_par > 0.)
				   info->ang_sector |= ORIG_START;
			}
		}
		else
		{
			if(me->mea_trak & ORIG_START)
			   info->ang_sector |= ORIG_START;
		}

		status =
		om$send(msg = message dim_src.DMgive_structure(
							&rc,
							MEAS_INFO,
							FALSE,
							&dmstr,
							md_env),
			targetid = info->list[DIM_CPX_MEAS].objid,
			targetos = info->list[DIM_CPX_MEAS].osnum);
		dm$status(action = RET_STATUS);

		if(dmstr.type == DMkeyseg)
		{
			if(me->mea_trak & MEAS_START)
			{
				if (dmstr.var.dm_keyseg.u_par == 0.0)
				   info->ang_sector |= MEAS_START;
			}
			else
			{
				if (dmstr.var.dm_keyseg.u_par > 0.)
				   info->ang_sector |= MEAS_START;
			}
		}
		else
		{
			if(me->mea_trak & MEAS_START)
			   info->ang_sector |= MEAS_START;
		}
	}
	else if (info->meas_axis[0].objid != NULL_OBJID)
		info->lin_axis = (me->mea_trak & DM_MEA_AXIS)?
				ACT_X_AXIS:ACT_Y_AXIS;
	else	info->lin_axis = (me->mea_trak & DM_MEA_AXIS)?
				WIN_X_AXIS:WIN_Y_AXIS;

	if (size = om$dimension_of(varray = me->dim_override))
	{
		info->mod_comp = MOD_COMP_STATIC;
		memcpy(info->dim_override, me->dim_override, size);
		info->dim_override[size] = '\0';
	}
	else	info->mod_comp = MOD_COMP_DYNAMIC;

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method get_dim_attr(char *attr)
{
	struct dim_attr *dim_attr;

	dim_attr = (struct dim_attr *)attr;

	dim_attr->dim_type	= me->dim_type;
	dim_attr->dim_state	= me->dim_state;
	dim_attr->brk_dist	= me->brk_dist;
	dim_attr->lead_dist	= me->lead_dist;
	dim_attr->trak_dist	= me->trak_dist;
	dim_attr->offs_pt[0]	= me->offs_pt[0];
	dim_attr->offs_pt[1]	= me->offs_pt[1];
	dim_attr->prj_offs[0]	= me->prj_offs[0];
	dim_attr->prj_offs[1]	= me->prj_offs[1];
	dim_attr->mea_trak	= me->mea_trak;
	dim_attr->brk_pos	= me->brk_pos;
	dim_attr->leader	= me->leader;
	dim_attr->ter_loca	= me->ter_loca;
	dim_attr->geom_type	= me->geom_type;
	dim_attr->display	= me->display;

	return(OM_S_SUCCESS);
}

method copy_dim_attr(
	IGRint *msg;
	IGRint control;
	struct GRid *dim_grid;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct dim_attr dim_attr;
	struct GRid grid;
	IGRboolean first_in_cpx;
	extern IGRboolean ASbroadcast_in_progress;

	status =
	om$send(msg = message DMroot.get_dim_attr((char *)&dim_attr),
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	/*" trak dist:%f\n",dim_attr.trak_dist*/
	if (control & INST_BREAK_PT
	||  control & INST_TRAK_PT)
	{
		me->brk_pos = dim_attr.brk_pos;
		me->brk_dist = dim_attr.brk_dist;
		me->trak_dist = dim_attr.trak_dist;
		me->mea_trak = dim_attr.mea_trak;
	}

	if (control & INST_PROJ_OFFS_PT)
	{
		me->prj_offs[0] = dim_attr.prj_offs[0];
		me->prj_offs[1] = dim_attr.prj_offs[1];
	}

	if (control & INST_LEADER_PT)
	{
		me->leader = dim_attr.leader;
		me->lead_dist = dim_attr.lead_dist;
	}

	if (control & INST_OFFS_PT)
	{
		me->offs_pt[0] = dim_attr.offs_pt[0];
		me->offs_pt[1] = dim_attr.offs_pt[1];
	}

	if (control & INST_TER_LOCA)
		me->ter_loca = dim_attr.ter_loca;

	if ((control & INST_TRAK_PT) && (me->dim_type == STRINGED_LINEAR))
	{
		status =
		om$send(msg = message DMroot.give_previous(
						&rc,
						&first_in_cpx,
						&grid),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (first_in_cpx)
		{
			grid.objid = my_id;
			grid.osnum = OM_Gw_current_OS;
		}
	}
	else
	{
		grid.objid = my_id;
		grid.osnum = OM_Gw_current_OS;
	}

	if ((!ASbroadcast_in_progress) && !(control & INST_NOT_IN_BATCH))
	{
		IGRint cn_type;

		cn_type = ND_COMP;

		nd$wait_batch(
			type = GR_GEOM_POSTED,
			l_object = &grid,
			l_obj_info = &cn_type,
			nb_obj   = 1);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method DMplace(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	char   *attr;
	struct GRmd_env *md_env)
{
	IGRint status, rc, drawview, num_parents;
	IGRdouble scale;
	struct dim_attr *dim_attr;
	struct GRid parents[MAX_DIM_ROOTS], first;

	dim_attr = (struct dim_attr *)attr;

	me->brk_dist	= dim_attr->brk_dist;
	me->lead_dist	= dim_attr->lead_dist;
	me->trak_dist	= dim_attr->trak_dist;
	me->offs_pt[0]	=
	me->offs_pt[1]	=
	me->prj_offs[0] =
	me->prj_offs[1] = 0.0;
	me->mea_trak	= dim_attr->mea_trak;
	me->brk_pos	= dim_attr->brk_pos;
	me->leader	= dim_attr->leader;
	me->ter_loca	= dim_attr->ter_loca;
	me->dim_type	= dim_attr->dim_type;
	me->dim_state	= dim_attr->dim_state;
	me->geom_type	= dim_attr->geom_type;
	me->display	= dim_attr->display;

	status =
	om$send(msg = message DMroot.DMplace(
					msg,
					count,
					list,
					attr,
					md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*|- Find out from dimension source if any scale is present*/

	if  ( (!((1 << me->dim_type) & ANGULAR_MASK))  
	     || ( me->dim_type == SINGLE_ARC_LENGTH) )
	{
        	status =
        	om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
               	                 targetid = my_id);
        	dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.DMreturn_roots(&num_parents, parents),
				targetid = first.objid,
				targetos = first.osnum);
		dm$status(action = RET_STATUS);

		DMget_scale(&scale, &drawview, parents[DIM_CPX_ORIG], md_env);

		if (scale > 0.0) me->display |= DIM_AUTO_SCALED;
	}

	return(OM_S_SUCCESS);
}

method clear_offset()
{
	me->offs_pt[0] =
	me->offs_pt[1] = 0.0;
	return(OM_S_SUCCESS);
}

method get_trak_info(struct DMtrak_info *trak_info)
{
	trak_info->mea_trak = me->mea_trak;
	trak_info->trak_dist = me->trak_dist;
	return(OM_S_SUCCESS);
}

method set_trak_info(IGRint action; struct DMtrak_info *trak_info)
{
	IGRint status, rc;
	IGRlong long_rc;
	struct DMenv_param par_env;
	struct DMloc_param par_loc;
	struct ret_struct  str;
	IGRdouble x, radius, trak_diff;
	struct GRmd_env md_env;
        BSrc bs_rc;

	DMget_module_info(&md_env);

	switch (action)
	{
		case XCH_TRAK_DIST:

		x = trak_info->trak_dist;
		trak_info->trak_dist = me->trak_dist;
		me->trak_dist = x;
		break;

		case REP_TRAK_DIST:

		me->trak_dist = trak_info->trak_dist;
		me->mea_trak = trak_info->mea_trak;
		break;

		case MIN_TRAK_DIST:

		status =
		om$send(msg = message DMdim.get_active_params(&rc, &par_env, &par_loc),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		me->trak_dist = par_env.lin_offs_r * par_env.txt_heig;
		break;

		case ADD_TRAK_DIST:

		me->trak_dist += trak_info->trak_dist;
		break;

		case TOG_TRAK_DIR:

		if (me->dim_type == STACKED_ANGULAR
		||  me->dim_type == STRINGED_ANGULAR)
			me->mea_trak =
			((me->mea_trak + 1) & 0x3) | (me->mea_trak & 0x4);
		else if (me->dim_type == RADIAL
		||	 me->dim_type == RADIAL_DIAMETER)
		{
			switch (me->brk_pos)
			{
				case BRK_LEFT:
				me->brk_pos = BRK_RIGHT; break;
				case BRK_RIGHT:
				me->brk_pos = BRK_LEFT; break;
				case BRK_CENTER:
				break;
			}
		}
		else if (me->dim_type == SINGLE_ARC_ANGLE
		||       me->dim_type == SINGLE_ARC_LENGTH)
		{
			status =
			DMnode_give_structure(
				&rc,
				DIM_CPX_ORIG,
				ORIG_INFO,
				(me->geom_type & DIM_IMPORTED),
				NULL_OBJID,
				my_id,
				OM_Gw_current_OS,
				&md_env,
				&str);
			dm$status(action = RET_STATUS);

			radius = str.var.circle_st.rad;
			trak_diff = me->trak_dist - radius;
			me->trak_dist = radius - trak_diff;
		}
		else	me->mea_trak ^= DM_TRAK_DIR;
		break;

		case CUR_TRAK_DIST:
		{
			struct GRid go;
			IGRdouble line[6], trk_pt[3];
			struct IGRpolyline polyline;
			struct ret_struct str;
			struct IGRarc arc;
			IGRint action;
			IGRdouble trak_diff;

			DMget_module_info(&md_env);

			status =
			om$send(msg = message DMroot.return_dim_go(
						&rc,
						DIM_LINE1,
						FALSE,
						NULL,
						&md_env,
						&go),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->dim_type == STRINGED_ANGULAR)
			{
				status =
				om$send(msg = message GRconic.GRgetarc(
						&long_rc,
						&md_env.md_env.matrix_type,
						md_env.md_env.matrix,
						&arc),
					targetid = go.objid,
					targetos = go.osnum);
				dm$status(action = RET_STATUS);

				trak_diff = arc.prim_axis;
			}
			else
			{
				status =
				DMnode_give_structure(
					(IGRint *) &long_rc,
					DIM_CPX_ORIG,
					ORIG_INFO,
					(me->geom_type & DIM_IMPORTED),
					NULL_OBJID,
					my_id,
					OM_Gw_current_OS,
					&md_env,
					&str);
				dm$status(action = RET_STATUS);

				action = 1;
				polyline.num_points = 2;
				polyline.points = line;

				status =
				om$send(msg = message GRlinear.GRgetpolyline(
						&long_rc,
						&md_env.md_env.matrix_type,
						md_env.md_env.matrix,
						&action,
						&polyline),
					targetid = go.objid,
					targetos = go.osnum);
				dm$status(action = RET_STATUS);

				BSproj0(&bs_rc, str.var.point_st.pt, line, trk_pt);
				trak_diff = BSdistptpt(&bs_rc, trk_pt, str.var.point_st.pt);
			}

			status =
			om$send(msg = message DMdim.adjust_trak_dist(
							0,
							&trak_diff),
				targetid = my_id);
			dm$status(action = RET_STATUS);
			
			me->trak_dist = trak_diff;
		}
		break;

		default:

		printf("set_trak_info: Illegal action %d\n", action);
		return(OM_E_ABORT);
	}

	return(OM_S_SUCCESS);
}

method get_real_parents(
	IGRint count;
	struct GRid list[])
{
	IGRint status, index;

	for (index=0; index<count; index++)
	{
		status =
		om$send(msg = message NDnode.ASreturn_go(&list[index], NULL, NULL),
			targetid = list[index].objid,
			targetos = list[index].osnum);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method leader_off()
{
	me->leader = FALSE;
	return(OM_S_SUCCESS);
}

method update_parents()
{
	IGRint status;
	struct GRid list[MAX_DIM_ROOTS];
	struct GRid env_grid, loc_grid;
	struct GRid my_grid, null_grid;
	IGRint count;

	if (!(me->dim_state & DIM_IN_PLACEMENT))
		return(OM_S_SUCCESS);

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;
	null_grid.objid = NULL_OBJID;

	status =
	DMget_parents(my_grid, MAX_DIM_ROOTS, list, &count);
	dm$status(action = RET_STATUS);

	status =
	dm$get_dim_param(type = DM_ENV_PARAM, p_grid = &env_grid);
	dm$status(action = RET_STATUS);

	status =
	dm$get_dim_param(type = DM_LOC_PARAM, p_grid = &loc_grid);
	dm$status(action = RET_STATUS);

	if (list[DIM_ROOT_ENV].objid != env_grid.objid
	||  list[DIM_ROOT_LOC].objid != loc_grid.objid)
	{
		list[DIM_ROOT_ENV] = env_grid;
		list[DIM_ROOT_LOC] = loc_grid;

		status =
		om$send(msg = message NDnode.NDconnect(
					count,
					list,
					null_grid,
					ND_FULL),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		me->dim_state |= DIM_NEEDS_UPDATE;
	}

	return(OM_S_SUCCESS);
}

method get_text_extents(
	IGRint *msg;
	IGRdouble box[12];
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	IGRlong long_rc;
	BSrc bs_rc;
	struct GRid go_grid[2];
	IGRint go_index[2];
	struct IGRlbsys lbsys;
	struct DMmisc_param par_misc;
	struct IGRbsp_curve *bsp_curve;
	IGRdouble *poles;
	IGRdouble extbox[12];
	IGRvector x_vec, y_vec, hdir, vdir;
	IGRpoint h0, h1, v0, v1;
	IGRdouble *point_l, *point_r;
	IGRdouble *point_b, *point_t;
	IGRdouble vline[6];
	struct DMloc_param par_loc;

	go_index[0] = DIM_TEXT;
	go_index[1] = DIM_BOX;

	for (i=0; i<2; i++)
	{
		status =
		om$send(msg = message DMroot.return_dim_go(
					&rc,
					go_index[i],
					FALSE,
					NULL,
					md_env,
					&go_grid[i]),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (go_grid[0].objid == NULL_OBJID)
	{
		/*| Text component not on channel */
		return(OM_E_ABORT);
	}

        /*
         *  #TR 119601961 -SKP 18/7/96
         *   Moved this call from below to avoid usage of unintialized
         *   par_misc structure later in the code in case the control 
         *   goes to SUCC_WRAP 
         */

	dm$get_dim_param(
		type = DM_MISC_PARAM,
		dim_objid = my_id,
		dim_osnum = OM_Gw_current_OS,
		p_data = (char *) &par_misc);

	status =
	om$send(msg = message GRvg.GRgetgeom(
				&long_rc,
				&md_env->md_env.matrix_type,
				md_env->md_env.matrix,
				(char *)&lbsys),
		targetid = go_grid[0].objid,
		targetos = go_grid[0].osnum);
	dm$status(action = RET_STATUS);

	status = MATH_get_box_points(&rc, &lbsys, (double (*)[])box);
	dm$status(action = RET_STATUS);

	if (go_grid[1].objid == NULL_OBJID)
 	goto SUCC_WRAP;
/*
		return(OM_S_SUCCESS);
*/
	status =
	om$send(msg = message GRvg.GRgenabsg(
				&long_rc,
				&md_env->md_env.matrix_type,
				md_env->md_env.matrix,
				(char **)&bsp_curve),
		targetid = go_grid[1].objid,
		targetos = go_grid[1].osnum);
	dm$status(action = RET_STATUS);
	
	poles = bsp_curve->poles;

/*  Moved this call above the GRgetgeom to avoid usage of unintialized
    par_misc structure later in the code in case the control goes to
    SUCC_WRAP 
	dm$get_dim_param(
		type = DM_MISC_PARAM,
		dim_objid = my_id,
		dim_osnum = OM_Gw_current_OS,
		p_data = (char *) &par_misc);
*/

	if (!(par_misc.prefix_disp || par_misc.suffix_disp))
	{
		memcpy(box, poles, 12 * sizeof(IGRdouble));
 	goto SUCC_WRAP;
/*
		return(OM_S_SUCCESS);
*/
	}

	for (i=0; i<3; i++)
	{
		x_vec[i] = lbsys.matrix[i*4];
		y_vec[i] = lbsys.matrix[i*4 + 1];
	}

	/*	Project poles (0, 1) to bottom line
		and poles (1, 2) onto right line of
		the actual text box.
	*/

	BSproj0(&bs_rc, poles, box, h0);
	BSproj0(&bs_rc, &poles[3], box, h1);
	BSproj0(&bs_rc, &poles[3], &box[3], v0);
	BSproj0(&bs_rc, &poles[6], &box[3], v1);

	/*	Find the left most and right most
		points on the bottom line.
	*/

	BSmkvec(&bs_rc, hdir, box, h0);
	if (BSdotp(&bs_rc, hdir, x_vec) < 0)
		point_l = h0;
	else	point_l = box;

	BSmkvec(&bs_rc, hdir, &box[3], h1);
	if (BSdotp(&bs_rc, hdir, x_vec) < 0)
		point_r =  &box[3];
	else	point_r = h1;

	/*	Find the bottom most and top most
		points on the right line.
	*/

	BSmkvec(&bs_rc, vdir, &box[3], v0);
	if (BSdotp(&bs_rc, vdir, y_vec) < 0)
		point_b = v0;
	else	point_b = &box[3];

	BSmkvec(&bs_rc, vdir, &box[6], v1);
	if (BSdotp(&bs_rc, vdir, y_vec) < 0)
		point_t =  &box[6];
	else	point_t = v1;

	/*	Make a vertical lines through
		the farthest points on the
		bottom line and project the
		farthest points on the right
		line on to them to obtain the
		extended box extents
	*/

	DMlineptvec(point_l, y_vec, vline);
	BSproj0(&bs_rc, point_b, vline, extbox);
	BSproj0(&bs_rc, point_t, vline, &extbox[9]);

	DMlineptvec(point_r, y_vec, vline);
	BSproj0(&bs_rc, point_b, vline, &extbox[3]);
	BSproj0(&bs_rc, point_t, vline, &extbox[6]);

	memcpy(box, extbox, 12 * sizeof(IGRdouble));

SUCC_WRAP:
 
/* Fix for TR# 11893687 */
	dm$get_dim_param(
		type = DM_LOC_PARAM,
		dim_objid = my_id,
		dim_osnum = OM_Gw_current_OS,
		p_data = (char *) &par_loc);

	if (( par_loc.deci_frac == FRACTION_MODE ) && 
	    ( par_loc.tole_mode != TOLE_MODE_BOX))
	{
 		struct DMenv_param par_env;

		dm$get_dim_param(
			type = DM_ENV_PARAM,
 			dim_objid = my_id,
 			dim_osnum = OM_Gw_current_OS,
 			p_data = (char *) &par_env);

        	for (i=0; i<3; i++)
        	{
               	 x_vec[i] = lbsys.matrix[i*4];
               	 y_vec[i] = lbsys.matrix[i*4 + 1];
        	}
 
		DMextend_points(
        		&box[0],
        		&box[3],
        		&box[6],
        		&box[9],
        		x_vec,
        		y_vec,
        		(IGRdouble)0,
        		par_misc.std_param.dm_box_hor_gap*par_env.txt_heig);
 	}
 /* end of fix */

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method compute_offset(
	IGRint *msg;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	IGRdouble off_dir[3];
	IGRdouble app_pos[3];
	IGRdouble act_pos[3])
{
	IGRlong long_rc;
	IGRdouble def_offs[3];
	IGRdouble def_pos[3];
	IGRdouble txt_yoff;

	if (par_loc->txt_posn == TXT_POSN_ABOVE
	&&  ((par_loc->txt_orie != TXT_ORIE_HORIZONTAL &&
	      par_loc->txt_orie != TXT_ORIE_VERTICAL) || me->leader))
	{
		txt_yoff = par_env->txt_yoff_r * par_env->txt_heig;
		MAscalvc(&long_rc, &txt_yoff, off_dir, def_offs);
		MAaddvc(&long_rc, app_pos, def_offs, def_pos);
	}
	else	math_v_equal(def_pos, app_pos);

	me->offs_pt[0] =
	plan_info->act_plan.matrix[0] * (act_pos[0] - def_pos[0]) +
	plan_info->act_plan.matrix[1] * (act_pos[1] - def_pos[1]) +
	plan_info->act_plan.matrix[2] * (act_pos[2] - def_pos[2]);

	me->offs_pt[1] =
	plan_info->act_plan.matrix[4] * (act_pos[0] - def_pos[0]) +
	plan_info->act_plan.matrix[5] * (act_pos[1] - def_pos[1]) +
	plan_info->act_plan.matrix[6] * (act_pos[2] - def_pos[2]);

	/*"offs_pt=(%lf, %lf)\n", me->offs_pt[0], me->offs_pt[1]*/

	return(OM_S_SUCCESS);
}

method GRchgname(
	IGRlong *msg;
	struct GRmd_env *env;
	IGRchar *name)
{
	IGRint status;
	struct GRid my_grid;

	if (me->geom_type & DIM_BY_NAME)
	{
		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;
		dm$change_node(as_grid = my_grid, md_env = env);
	}

	status =
	om$send(msg = message GRowner.GRchgname(msg, env, name),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method adjust_trak_dist(
	IGRchar mask;
	IGRdouble *trak_dist)
{
	IGRint status, rc;
	IGRboolean last_in_cpx;
	struct GRid next[2];

	if(me->trak_dist < *trak_dist)
		me->trak_dist = 0.0;
	else	me->trak_dist -= *trak_dist;

	status =
	om$send(msg = message DMroot.give_next(&rc, &last_in_cpx, next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if(!last_in_cpx)
	{
		status =
		om$send(msg = OPPmargs,
			targetid = next[0].objid,
			targetos = next[0].osnum);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method get_orig_trak_pt(
	IGRdouble trak_pt[3];
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRdouble *trak_vec;
	struct ret_struct ret_st;
	struct DMplan_info plan_info;
	IGRint src_type, src_info;

	status =
	om$send(msg = message DMroot.get_dimension_plane(
					&rc,
					md_env,
					&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->dim_type == COORDINATE)
	{
		src_type = DIM_CPX_MEAS;
		src_info = MEAS_INFO;
	}
	else
	{
		src_type = DIM_CPX_ORIG;
		src_info = ORIG_INFO;
	}

	status =
	DMnode_give_structure(
		&rc,
		src_type,
		src_info,
		(me->geom_type & DIM_IMPORTED),
		NULL_OBJID,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&ret_st);
	dm$status(action = RET_STATUS);

	if (me->mea_trak & DM_MEA_AXIS)
	{
		trak_vec = (me->mea_trak & DM_TRAK_DIR)?
				plan_info.act_plan.vec_ypos:
				plan_info.act_plan.vec_yneg;
	}
	else
	{
		trak_vec = (me->mea_trak & DM_TRAK_DIR)?
				plan_info.act_plan.vec_xpos:
				plan_info.act_plan.vec_xneg;
	}

	MATH_ptdelta(&rc, ret_st.var.point_st.pt, trak_vec, me->trak_dist, trak_pt);

	/*^
		print_point("orig_trak_pt",trak_pt);
		printf("orig_mea_trak=%d\n",me->mea_trak);
	*/

	return(OM_S_SUCCESS);
}

method get_orig_trak_info(
	IGRdouble trak_pt[3];
	struct DMtrak_info *trak_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc, mask;
	IGRdouble *perp_axis, trak_line[6];
	IGRdouble new_trak_pt[3], trak_dir[3], trak_diff;
	struct ret_struct ret_st;
	struct DMplan_info plan_info;
	IGRint src_type, src_info;
	BSrc bs_rc;

	status =
	om$send(msg = message DMroot.get_dimension_plane(
					&rc,
					md_env,
					&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->dim_type == COORDINATE)
	{
		src_type = DIM_CPX_MEAS;
		src_info = MEAS_INFO;
	}
	else
	{
		src_type = DIM_CPX_ORIG;
		src_info = ORIG_INFO;
	}

	status =
	DMnode_give_structure(
		&rc,
		src_type,
		src_info,
		(me->geom_type & DIM_IMPORTED),
		NULL_OBJID,
		my_id,
		OM_Gw_current_OS,
		md_env,
		&ret_st);
	dm$status(action = RET_STATUS);

	math_v_equal(trak_line, ret_st.var.point_st.pt);

	if (me->mea_trak & DM_MEA_AXIS)
		perp_axis = plan_info.act_plan.vec_ypos;
	else	perp_axis = plan_info.act_plan.vec_xpos;

	DMlineptvec(trak_line, perp_axis, trak_line);

	BSproj0(&bs_rc, trak_pt, trak_line, new_trak_pt);

	trak_info->mea_trak = me->mea_trak;
	trak_info->trak_dist = BSdistptpt(&bs_rc, trak_line, new_trak_pt);

	/*|- scale the trak_dist if scale present*/

	trak_info->trak_dist /= BSlenvec(&bs_rc, plan_info.win_plan.vec_xpos);

	trak_info->trak_dist += me->trak_dist;

	BSmkvec(&bs_rc, trak_dir, trak_line, new_trak_pt);

	if(BSdotp(&bs_rc, trak_dir, perp_axis) < 0)
		trak_info->mea_trak &= (~DM_TRAK_DIR);
	else	trak_info->mea_trak |= DM_TRAK_DIR;

	trak_diff = me->trak_dist;

	if (me->dim_type == COORDINATE)
	{
		mask = (me->mea_trak & DM_TRAK_ZONE1)?
			DM_TRAK_ZONE1:DM_TRAK_ZONE2;
	}
	else	mask = 0;

	status =
	om$send(msg = message DMdim.adjust_trak_dist(mask, &trak_diff),
		targetid = my_id);
	dm$status(action = RET_STATUS);
 
	/*^
		print_point("trak_pt",trak_pt);
		print_line("trak_line",trak_line);
		print_point("new_trak_pt",new_trak_pt);
		printf("me->trak_dist = %f\n",me->trak_dist);		
		printf("trak_dist = %f\n",trak_info->trak_dist);
		printf("mea_trak = %d\n",trak_info->mea_trak);
	*/

	return(OM_S_SUCCESS);
}

method get_dim_value(IGRdouble *dim_value)
{
	*dim_value = me->dim_value;
	return(OM_S_SUCCESS);
}

IGRint DMget_scale(scale, drawview, src_grid, md_env)
IGRdouble *scale;
IGRint	*drawview;
struct GRid src_grid;
struct GRmd_env *md_env;
{
	IGRint status, count, rc;
	IGRlong long_rc;
	IGRshort matrix_type, owner_found;
	IGRulong ref_props;
	IGRmatrix matrix;
	struct GRid go_grid, owner, parents[3], context;
	OM_S_CHANSELECT chan;
	OM_S_OBJECT_LINKAGE list[1];
	IGRdouble  rotmat[3][3];
	IGRdouble  matscale, tmp_scale;
	BSrc       bs_rc;
	struct GRid par_list1[MAX_DIM_ROOTS];
	struct GRid par_list2[MAX_DIM_ROOTS];
	IGRint par_count1, par_count2;


	*scale = -1.0;
	*drawview = ref_props = 0;
	owner_found = FALSE;

	status =
	om$send(msg = message NDnode.ASreturn_go(
					&go_grid,
					&matrix_type,
					matrix),
		senderid = NULL_OBJID,
		targetid = src_grid.objid,
		targetos = src_grid.osnum);
	dm$status(action = RET_STATUS);

	if (DMancestry_valid(go_grid, OPP_DMsrc_class_id))
	{
	        status =
        	om$send(msg = message NDnode.NDget_objects(
                	                        ND_ROOT,
                        	                parents,
                                	        3,
                                        	NULL,
	                                        0,
        	                                OM_K_MAXINT,
                	                        &count),
			senderid = NULL_OBJID,
			targetid = go_grid.objid,
			targetos = go_grid.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.ASreturn_go(
						&go_grid,
						&matrix_type,
						matrix),
			senderid = NULL_OBJID,
			targetid = parents[0].objid,
			targetos = parents[0].osnum);
		dm$status(action = RET_STATUS);

		/*"go_grid = %d,%d\n", go_grid.objid, go_grid.osnum*/

		status =
		GRfindcontext(
			&rc,
			&matrix_type,
			matrix,
			&go_grid.osnum,
			&context);
		if (status != OM_S_SUCCESS || rc != MSSUCC)
			context.objid = NULL_OBJID;

		if (context.objid != NULL_OBJID)
		{
			/*"context = %d,%d\n", context.objid, context.osnum*/

			status=
		        om$make_chanselect (
				channame="GRcontext.to_reffile",
     	              		p_chanselect = &chan );
			dm$status(action = RET_STATUS);

			status = 
			om$send(msg = message GRreffile.GRgetrfprops(
							&long_rc,
							&ref_props),
				p_chanselect = &chan,
				senderid = context.objid,
				targetos = context.osnum);
			dm$status(action = RET_STATUS);
			
/* commented out for TR# 119304411			
			if( ref_props & GRIS_MODEL_ATTACHMENT)
			{
*/
				*drawview = 1;

/* this returns scale factor bet lowest levels only
				|- Get scale from reffile

				status =
				om$send(msg = message GRreffile.GRgetscale(
								&long_rc,
								scale),
					p_chanselect = &chan,
					senderid = context.objid,
					targetos = context.osnum);
				dm$status(action = RET_STATUS);
*/
	/* extract rotation matrix */
				rotmat[0][0] = matrix[0];
				rotmat[0][1] = matrix[1];
 				rotmat[0][2] = matrix[2];
 				rotmat[1][0] = matrix[4];
				rotmat[1][1] = matrix[5];
				rotmat[1][2] = matrix[6];
				rotmat[2][0] = matrix[8];
				rotmat[2][1] = matrix[9];
				rotmat[2][2] = matrix[10];

	/* get third root of the det of matrix */
				matscale = BSdetmat ( 3, (IGRdouble *)rotmat, &bs_rc );
				if ( bs_rc == BSSUCC )
				{
					tmp_scale = BSrpower (matscale, 1.0/3.0, &bs_rc);
					if ( bs_rc == BSSUCC ) 
					{
						*scale = tmp_scale;
					}
				}
/*  commented out for TR# 119304411
    parameter drawview is not being used anywhere
			}
			else
			{
				*scale = 1.0;
				*drawview = 2; 
			}
*/
		}
		else
/* fix for TR#119221833 */
		{
			status =
			DMget_parents(parents[0], MAX_DIM_ROOTS, 
						par_list1, &par_count1);
			dm$status(action = RET_STATUS);
			if(( par_count1 ) &&
			   (DMancestry_valid(par_list1[0], 
						OPP_DMcenline_class_id)))
			{
				status =
				DMget_parents(par_list1[0],
				 	MAX_DIM_ROOTS, par_list2, &par_count2);
				dm$status(action = RET_STATUS);
				if ( par_count2 )
					DMget_scale(scale, drawview, 
						par_list2[par_count2-1], md_env);
			}
/* end of fix */
			else
			{
			/*|- Find GO owner */

				count = 0;
    				status =
				om$get_channel_objects(
                			objid = go_grid.objid,
                    	   		osnum = go_grid.osnum,
        	        		p_chanselect = &AS_to_owner,
                			list = list,
                			size = 1,
               	 			count = (OMuint *)&count);
				dm$status(action = RET_STATUS);
          
				if (!count)
				{
					/*|-No Owner found*/
					return(TRUE);
				}

				owner.objid = list[0].S_objid;
				owner.osnum = list[0].osnum;

				/*"owner = %d,%d\n", owner.objid, owner.osnum*/

				if (DMancestry_valid(owner, OPP_GRdrawview_class_id))
					owner_found = TRUE;
				else
				{
					/*|- Find owner's owner */

					count = 0;
    					status =
					om$get_channel_objects(
                				objid = owner.objid,
                    	   			osnum = owner.osnum,
	        	        		p_chanselect = &AS_to_owner,
        	        			list = list,
                				size = 1,
               	 				count = (OMuint *)&count);
					dm$status(action = RET_STATUS);
          
					if (!count)
					{
						/*|-No Owner found*/
						return(TRUE);
					}

					owner.objid = list[0].S_objid;
					owner.osnum = list[0].osnum;

					/*"owner = %d,%d\n", owner.objid, owner.osnum*/

					if (DMancestry_valid(owner, OPP_GRdrawview_class_id))
						owner_found = TRUE;
				}

				if (owner_found)
				{
					/*|-Get the scale from GRdrawview object*/
				IGRdouble n_scale[3];

					status =
               	        		om$send(msg = message GRdrawview.GRget_drawview_scale(
							 &long_rc,
							 md_env,
       	               					 NULL,	
                       					 n_scale),
						senderid = NULL_OBJID,
						targetid = owner.objid,
						targetos = owner.osnum);
					dm$status(action = RET_STATUS);

					*scale = n_scale[0];
				}
			}
		}
	}
	
	/*"scale = %lf\n", *scale*/

	return(TRUE);
}

IGRint DMconvert_scale(msg, dim_grid, dim_info)
IGRlong *msg;
struct GRid *dim_grid;
char *dim_info;
/*.DMconvert_scale*/
{
	IGRshort dim_type;
	IGRint status, rc, num_parents;
	struct GRmd_env md_env;
	struct GRid parents[MAX_DIM_ROOTS], first;
	IGRint drawview;
	IGRdouble scale;

	*msg = DIM_S_SUCCESS;

	status=
	om$send(msg = message DMroot.get_dim_type(&dim_type),
		senderid = NULL_OBJID,
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action= RET_STATUS);
	
	if (!((1 << dim_type) & ANGULAR_MASK))
	{
		DMget_module_info(&md_env);

        	status =
        	om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
               	        senderid = NULL_OBJID,
			targetid = dim_grid->objid,
			targetos = dim_grid->osnum);
        	dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.DMreturn_roots(&num_parents, parents),
			senderid = NULL_OBJID,
			targetid = first.objid,
			targetos = first.osnum);
		dm$status(action = RET_STATUS);

		DMget_scale(&scale, &drawview, parents[DIM_CPX_ORIG], &md_env);

		if (scale > 0.0)
		{
			status =
			om$send( msg = message DMroot.set_display_type(
						BIT_OR,
						DIM_AUTO_SCALED,
						NULL),
				senderid = NULL_OBJID,
				targetid = dim_grid->objid,
				targetos = dim_grid->osnum);
			dm$status(action = RET_STATUS);
		}
		
		status =
		dm$change_node(
			broadcast = FALSE,
			as_grid = *dim_grid,
			md_env = &md_env);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

end implementation DMdim;

