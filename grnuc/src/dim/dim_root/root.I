/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:31 $
$Locker:  $
$Log: root.I,v $
Revision 1.1.1.1  2001/12/17 22:39:31  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:08:59  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:23:02  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.2  1995/07/03  12:45:34  gvk
# COMMENT : Delete Dimension: Make temporary connections if remove_from_cpx fails.
#
# Revision 320.1  1995/05/26  04:32:07  satya
# COMMENT : Delete: Deletion of ref file dimensions after detach ref file resolved
#
# Revision 320.0  1994/12/12  17:52:29  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.4  1994/11/01  10:12:27  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.3  1993/09/27  09:34:09  samuel
# COMMENT : Fix for TR119310615
#
# Revision 240.2  1993/08/13  08:21:03  laxmi
# COMMENT : Minor changes for Sun compatibility -Laxmi 13 Aug 1993
#
# Revision 240.1  1993/08/03  05:42:39  laxmi
# COMMENT : Dimensioning 2.4 CR and TR fixes checkin. -Laxmi
#
# Revision 240.0  1992/12/06  23:46:25  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.3  1992/10/30  23:19:48  poo
# COMMENT : Initialising module osnum properly during Copy.
#
Revision 201.44  1992/10/19  21:01:10  poo
COMMENT : To handle Coordinate system as Dimension plane or DImensions parent

Revision 201.43  1992/10/09  21:38:02  poo
COMMENT : Edit dimension corruption problem -gvk

Revision 201.42  1992/10/05  18:16:48  poo
COMMENT : Fix for macro problem & cell creation.

Revision 201.41  1992/08/26  12:05:42  poo
COMMENT : Fix of command backup and Trak zone locking.

Revision 201.40  1992/08/11  08:30:48  laxmi
COMMENT : The files DMroot.S and root.I have been changed to incorporate the debug method.

Revision 201.38  1992/08/06  11:31:21  poo
COMMENT : Fix for Jogged & Return Status taken care of in ACcopy_to_Groot method.

Revision 201.37  1992/08/05  14:48:08  prasad
COMMENT : Preventing the return of error in ACcopy_to_Groot (temp fix)

Revision 201.36  1992/07/31  18:46:10  poo
COMMENT :

Revision 201.35  1992/07/30  10:17:01  poo
COMMENT : Clearing DIM_DRIVING bit from the copied dim, in ACcopy_to_Groot.

Revision 201.34  1992/07/19  16:14:16  poo
COMMENT : Inital Checkin of Jogged Dimension fuctionality.

Revision 201.30  1992/03/26  20:08:52  henry
COMMENT : Do NOT call postabsg for an arc that could not be constructed. (BS will loop forever with a bad arc)

Revision 201.29  1992/02/26  14:33:27  dimdp20
COMMENT : Swap dimension on groups

*/
class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "grownmacros.h"
#include "cotxmacros.h"
#include "grownerdef.h"
#include "dimcomplex.h"
#include "dimtxt.h"

#include "dimlinear.h"
#include "dimradial.h"
#include "dimangular.h"
#include "dimtxtdef.h"
#include "dimannot.h"
#include "dimweld.h"
#include "dimsurf.h"
#include "bserr.h"
#include "mascalmx.h"
#include "marotmx.h"
#include "mamulmx.h"
#include "maidmx.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bscrossp.h"
#include "bsac2eptscr.h"

from GRtext	import GRreplace_text, GRfield_inquire;
from GRtext	import GRchgtextattr, GRgettxattr;
from GRlinear	import GRputpolyline;
from dim_param	import give_internal, edit;
from ACroot	import ACmplace;
from DMdim	import get_orig_trak_pt, get_orig_trak_info;
from DMdim	import adjust_trak_dist;
from dim_plan	import give_info, give_plane, give_axis;
from DMangular  import update_src;

extern IGRboolean GRabsg_del_all();

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

method return_dim_go(
	IGRint *msg;
	IGRint go_index;
	IGRint create_flag;
	IGRint obj_type;
	struct GRmd_env *md_env;
	struct GRid *go_grid)
{
	IGRint status, rc;
	IGRlong long_rc;
	IGRint i, alt_const;
	IGRlong chan_index;
	struct GRvg_construct cnst_lis;
	struct IGRdisplay display;
	struct GRid my_grid;
	GRclassid go_classid;
	int sizbuf, nret;
	struct GRmd_env mod_info;
	struct DMenv_param par_env;
	IGRshort current_layer;
	IGRboolean invalid_layer;

	IGRuchar text_string[16];
	IGRshort	 text_length;

	IGRdouble txt_origin[3];
	IGRdouble line[9];
	struct IGRpolyline polyline;
	struct IGRarc arc_struct;

	extern GRclassid	OPP_GR3dlineseg_class_id,
				OPP_GR3dlinestr_class_id,
				OPP_GR3dtext_class_id,
				OPP_GR3dcirarc_class_id,
				OPP_GR3dpolygon_class_id,
				OPP_GR3dcircle_class_id;

	*msg = DIM_S_SUCCESS;
	invalid_layer = FALSE;

	go_grid->objid = NULL_OBJID;
	go_grid->osnum = OM_Gw_current_OS;
	mod_info = *md_env;
	mod_info.md_id.objid = NULL_OBJID;

	/*"go_index = %d, comp_mask = %d\n", go_index, me->comp_mask*/

	if (go_index < 0 || go_index > MAX_COMP_INDEX)
	{
		/*| Error in go_index */

		*msg = DIM_E_GO_INDEX;
		return(OM_W_ABORT);
	}

	chan_index=0;
	for (i=0; i<go_index; i++)
		if (me->comp_mask & (1 << i)) chan_index++;

	if (!(me->comp_mask & (1 << go_index)))
	{
		/*| - Component Not On Channel - */

		if (create_flag)
		{
			cnst_lis.msg = &long_rc;
			cnst_lis.env_info = &mod_info;
			cnst_lis.newflag = FALSE;
			cnst_lis.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
			cnst_lis.display = &display;
			cnst_lis.class_attr = NULL;
			cnst_lis.name = NULL;

			sizbuf = sizeof(struct IGRdisplay);

			dm$get_dim_param(
				type = DM_ENV_PARAM,
				p_data = (char *)&par_env,
				dim_objid = my_id,
				dim_osnum = OM_Gw_current_OS);

			gr$get_active_display(
				msg = &rc,
				sizbuf = &sizbuf,
				buffer = &display,
				nret = &nret);

			current_layer = par_env.dim_layr;

			if(DMvalid_dim_offset_active_layer(par_env.dim_layr))
				DMget_current_dim_layer(par_env.dim_layr,
					&current_layer, &invalid_layer);

			cnst_lis.level = current_layer ;
			display.color = (me->dim_state & DIM_DETACHED)?
					par_env.det_colr:par_env.dim_colr;
			display.style = 0;
			display.weight = par_env.dim_weig;

			switch(obj_type)
			{
				case DM_LINE:
				case DM_LINE_STR:

					/*| Create Line/Linestr */

					for (i=0; i<6; i++) line[i] = 0.0;
					polyline.num_points = 2;
					polyline.points = line;
					cnst_lis.geometry = (char *)&polyline;
					go_classid = (obj_type == DM_LINE)?
						OPP_GR3dlineseg_class_id:
						OPP_GR3dlinestr_class_id;
					alt_const = TRUE;
					break;

				case DM_POLYGON:

					/*| Create Line/Linestr */

					for (i=0; i<9; i++) line[i] = 0.0;
					polyline.num_points = 3;
					polyline.points = line;
					cnst_lis.geometry = (char *)&polyline;
					go_classid = OPP_GR3dpolygon_class_id;
					alt_const = TRUE;
					break;

				case DM_TEXT:

					/*| Create Text */

					display.weight = par_env.txt_weig;
					alt_const = FALSE;
					break;

				case DM_ARC:
				case DM_CIRCLE:

					/*| Create Arc */
                                        arc_struct.prim_axis = 0.3;
                                        arc_struct.sec_axis = 0.3;
                                        for( i = 0; i< 3; i++)
                                                arc_struct.origin[i]=0.0;

					memcpy(	arc_struct.rot_matrix,
						mod_info.md_env.matrix,
						sizeof(IGRmatrix));
                                        arc_struct.start_angle = 1.0;
                                        arc_struct.sweep_angle  = 2.0;
                                        cnst_lis.geometry = (char *)&arc_struct;
                                        go_classid = (obj_type == DM_ARC)?
							OPP_GR3dcirarc_class_id:
							OPP_GR3dcircle_class_id;
					alt_const = TRUE;
                                        break;

				default:
					*msg = DIM_E_BAD_OBJTYPE;
					return(OM_E_ABORT);
			}

			/*| Construct Graphic Object */

			if (alt_const)
			{
				/*| altconstruct */

				status =
				om$construct(
					classid = go_classid,
					msg = message GRgraphics.GRaltconstruct(
								&cnst_lis),
					p_objid = &go_grid->objid,
					osnum = go_grid->osnum);
				dm$status();
			}
			else
			{
				/*| Text Construction */

				txt_origin[0] =
				txt_origin[1] =
				txt_origin[2] = 0.0;

				text_string[0] = '\0';
				text_length = 0;

			
				current_layer = par_env.dim_layr;

				if(DMvalid_dim_offset_active_layer(
						par_env.dim_layr))
                                 	DMget_current_dim_layer(
						par_env.dim_layr,
						&current_layer, &invalid_layer);

				co$place_text(
					msg = &long_rc,
					text_string = text_string,
					text_length = &text_length,
					origin = txt_origin,
					rot_matrix = mod_info.md_env.matrix,
					ActiveDisplay = &display,
					ActiveLevel = current_layer,
					ModuleInfo = &mod_info,
					buffer = go_grid,
					flags = 0,
					classname="DMtext");
			}

			my_grid.objid = my_id;
			my_grid.osnum = OM_Gw_current_OS;

			/*| Connect Graphic Object */

			status =
			om$send(msg = message GRconnector.GRrigidconn(
							&long_rc,
							&my_grid,
							&chan_index),
				targetid = go_grid->objid,
				targetos = go_grid->osnum);
			dm$status(action = RET_STATUS);

			me->comp_mask |= (1 << go_index);

			*msg = DIM_I_OBJ_CREATED;
			return(OM_S_SUCCESS);
		}

		*msg = DIM_E_NO_OBJECT;
		return(OM_S_SUCCESS);
	}

	/*| Get object at index */

	status =
	om$get_objid_at_index(
		object = me,
		p_chanselect = &AS_to_comp,
		index = chan_index,
		objidaddr = &go_grid->objid,
		osnumaddr = &go_grid->osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method return_go_index(
	IGRint *msg;
	struct GRid go_grid;
	IGRint *go_index)
{
	IGRint status;
	IGRint index, mask, n;

	if (!me->comp_mask)
		return(OM_E_ABORT);

	status =
	om$get_index(
		object_c = me,
		objid = go_grid.objid,
		osnum2 = go_grid.osnum,
		p_chanselect = &AS_to_comp,
		indexaddr = (OMuint *) &index);
	dm$status(action = RET_STATUS);

	n = 0;
	mask = me->comp_mask;
	while (!(mask & (1 << n))) n++;

	/*"mask=%d, index=%d\n", me->comp_mask, index*/

	while (index)
	{
		n++;
		while (!(mask & (1 << n))) n++;
		index--;
	}

	*go_index = n;

	/*"go_index=%d\n", *go_index*/

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method delete_dim_go(
	IGRint *msg;
	IGRint go_index;
	struct GRmd_env *md_env)
{
	IGRint status;
	IGRlong long_rc;
	struct GRid go_grid;
	struct GRmd_env mod_info;

	*msg = DIM_S_SUCCESS;
	mod_info = *md_env;
	mod_info.md_id.objid = NULL_OBJID;

	/*"go_index = %d, comp_mask = %d\n", go_index, me->comp_mask*/

	if (me->comp_mask & (1 << go_index))
	{
		/*|Delete Component*/

		status =
		om$send(msg = message DMroot.return_dim_go(
						msg,
						go_index,
						FALSE,
						-1,
						&mod_info,
						&go_grid),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message GRgraphics.GRdelete(
						&long_rc,
						&mod_info),
			targetid = go_grid.objid,
			targetos = go_grid.osnum);
		dm$status(action = RET_STATUS);

		me->comp_mask &= ~(1 << go_index);
	}

	return(OM_S_SUCCESS);
}

method position_line(
	IGRint *msg;
	IGRint line_index;
	struct GRid *line_grid;
	struct GRmd_env *md_env;
	IGRdouble line[6])
{
	IGRint status;
	IGRlong long_rc;
	struct IGRpolyline polyline;
	struct GRpost_info post_info;
	struct GRid tmp_grid;
	struct GRmd_env mod_info;

	*msg = DIM_S_SUCCESS;
	mod_info = *md_env;
	mod_info.md_id.objid = NULL_OBJID;

	dm$return_dim_go(index=line_index, p_grid=line_grid, obj_type=DM_LINE);

	/*^ print_line("line", line); */

        
	polyline.num_points = 2;
	polyline.points = line;
	post_info.construct_flag = FALSE;

	/*| put polyline */

	status =
	om$send(msg = message GRlinear.GRputpolyline(
						&long_rc,
						&mod_info,
						&post_info,
						&polyline,
						&line_grid->objid),
		targetid = line_grid->objid,
		targetos = line_grid->osnum);
	dm$status(action = RET_STATUS);

	/*|- Clear the cache memory */

	status =
	GRabsg_del_all();
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method position_line_string(
	IGRint *msg;
	IGRint line_index;
	struct GRid *line_grid;
	struct GRmd_env *md_env;
	IGRint num_vertex;
	IGRdouble line[])
{
	IGRint status;
	IGRlong long_rc;
	struct IGRpolyline polyline;
	struct GRpost_info post_info;
	struct GRid tmp_grid;
	struct GRmd_env mod_info;

	*msg = DIM_S_SUCCESS;
	mod_info = *md_env;
	mod_info.md_id.objid = NULL_OBJID;

	dm$return_dim_go(index=line_index, p_grid=line_grid, obj_type=DM_LINE_STR);

	polyline.num_points = num_vertex;
	polyline.points = line;
	post_info.construct_flag = FALSE;

	/*| put polyline */

	status =
	om$send(msg = message GRlinear.GRputpolyline(
						&long_rc,
						&mod_info,
						&post_info,
						&polyline,
						&line_grid->objid),
		targetid = line_grid->objid,
		targetos = line_grid->osnum);
	dm$status(action = RET_STATUS);

	/*|- Clear the cache memory */

	status =
	GRabsg_del_all();
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method position_arc(
	IGRint *msg;
	IGRint arc_index;
	struct GRid *arc_grid;
	struct GRmd_env *md_env;
	IGRdouble *norm;
	struct DMdim_arc *arc_info)	
{
	IGRint status;
	IGRlong long_rc;
	BSrc bs_rc;
	struct GRpost_info post_info;
	struct IGRbsp_curve *bsp_curve, loc_curve;
	IGRdouble poles[21],weights[7],knots[10];
	struct GRid tmp_grid;
	struct GRmd_env mod_info;

	*msg = DIM_S_SUCCESS;
	mod_info = *md_env;
	mod_info.md_id.objid = NULL_OBJID;

	dm$return_dim_go(index=arc_index, p_grid=arc_grid, obj_type=DM_ARC);

        status =
        om$send(msg = message GRvg.GRgenabsg(
                                        &long_rc,
                                        &mod_info.md_env.matrix_type,
                                        mod_info.md_env.matrix,
                                        (char **)&bsp_curve),
                targetid = arc_grid->objid,
                targetos = arc_grid->osnum);
	dm$status( action = RET_STATUS);

	loc_curve = *bsp_curve;

	/*  we need to allocate enough memory for min 7poles and knots
	    and weights to take care of all cases */

	loc_curve.poles = poles;
	loc_curve.weights = weights;
	loc_curve.knots = knots;

	/*^
		print_point("startpt", arc_info->startpt);
		print_point("centerpt", arc_info->centerpt);
		print_point("endpt", arc_info->endpt);
		print_point("norm", norm);
		printf("flag=%d\n", arc_info->flag);
	*/

       	BSac2eptscr(&bs_rc,
		    arc_info->startpt,
		    arc_info->centerpt,
		    arc_info->endpt,
		    norm,
		    &arc_info->flag,
		    &loc_curve);

        /*
         * don't call postabsg if we could not build an arc
         */

        if (bs_rc == BSSUCC)
        {
		post_info.construct_flag = FALSE;

		status =
		om$send(msg = message GRvg.GRpostabsg(
						&long_rc,
						&mod_info,
						&post_info,
						(char *)&loc_curve,
						&arc_grid->objid),
			targetid = arc_grid->objid,
			targetos = arc_grid->osnum);
		dm$status( action = RET_STATUS);
        }

	/*|- Clear the cache memory */

	status =
	GRabsg_del_all();
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

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
	IGRint status, rc, i;
	IGRlong long_rc;
	BSrc bs_rc;
	IGRdouble perp_vec[3];
	struct IGRlbsys *lbsys_geom;
	struct GRid tmp_grid;
	struct GRdpb_text_symb text_symb;
	struct GRpost_info info;
	IGRint attr_num;
	struct GRmd_env mod_info;
	IGRdouble box[4][3];

	*msg = DIM_S_SUCCESS;
	mod_info = *md_env;
	mod_info.md_id.objid = NULL_OBJID;

	dm$return_dim_go(index=text_index, p_grid=text_grid, obj_type=DM_TEXT);

	/*^
		print_point("origin", origin);
		print_point("orie_vec", orie_vec);
		print_point("norm", norm);
	*/

	if (justification != -1)
	{
		text_symb.Active_just = justification;
		attr_num = GRTEXT_JUST;

		status =
		om$send(msg = message GRtext.GRchgtextattr(
						&long_rc,
						&mod_info,
						attr_num,
						&text_symb),
			targetid = text_grid->objid,
			targetos = text_grid->osnum);
		dm$status(action = RET_STATUS);
	}

	status =
	om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix,
					(char **)&lbsys_geom),
		targetid = text_grid->objid,
		targetos = text_grid->osnum);
	dm$status(action = RET_STATUS);

	if (orie_vec && norm)
	{
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
			lbsys_geom->matrix[i*4] = orie_vec[i];
			lbsys_geom->matrix[i*4 + 1] = perp_vec[i];
			lbsys_geom->matrix[i*4 + 2] = norm[i];
		}
	}

	lbsys_geom->matrix[12] =
	lbsys_geom->matrix[13] =
	lbsys_geom->matrix[14] = 0.0;
	lbsys_geom->matrix[15] = 1.0;

	lbsys_geom->matrix[3]  = origin[0];
	lbsys_geom->matrix[7]  = origin[1];
	lbsys_geom->matrix[11] = origin[2];

	info.construct_flag = FALSE;

	/*^ print_matrix("matrix", lbsys_geom->matrix); */

	status =
	om$send(msg = message GRvg.GRpostabsg(
					&long_rc,
					&mod_info,
					&info,
					(char *)lbsys_geom,
					&text_grid->objid),
		targetid = text_grid->objid,
		targetos = text_grid->osnum);
	dm$status(action = RET_STATUS);

	if ((me->dim_type == TEXT_WITH_LEADER) && txt_flag)
	{
		/*|- Text with leader: text placement*/

		if (me->geom_type & DIM_INTERMEDIATE)
		{
			/*|- Intermediate flag set*/

			MATH_get_box_points(&rc, lbsys_geom, box);

                  
			status = 
			om$send( msg= message DMroot.position_line(
						&rc,
						DIM_ULINE,
						NULL,
						md_env,
					        (IGRdouble *)box),
			targetid = my_id);
			dm$status( action= RET_STATUS);

			me->geom_type &= ~DIM_INTERMEDIATE;
		}
		else
		{
			/*|- No Intermediate Flag*/

			status =
			om$send(msg = message DMroot.delete_dim_go(
							&rc,
							DIM_ULINE,
							md_env),
			targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	/*|- Clear the cache memory */

	status =
	GRabsg_del_all();
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method replace_text(
	IGRint *msg;
	IGRint text_index;
	struct GRid *text_grid;
	struct GRmd_env *md_env;
	IGRint text_len;
	IGRuchar *text_str)
{
	IGRint status;
	IGRlong long_rc;
	struct GRid tmp_grid;
	struct GRmd_env mod_info;

	*msg = DIM_S_SUCCESS;
	mod_info = *md_env;
	mod_info.md_id.objid = NULL_OBJID;

	dm$return_dim_go(index=text_index, p_grid=text_grid, obj_type=DM_TEXT);

	status =
	om$send(msg = message GRtext.GRreplace_text(
					&long_rc,
					&mod_info,
					text_len,
					text_str),
		targetid = text_grid->objid,
		targetos = text_grid->osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method chgtextattr(
	IGRint *msg;
	IGRint text_index;
	struct GRid *text_grid;
	struct GRmd_env *md_env;
	struct GRdpb_text_symb *text_symb)
{
	IGRint status;
	IGRlong long_rc;
	IGRuint attr_number;
	struct GRid tmp_grid;
	struct GRmd_env mod_info;

	*msg = DIM_S_SUCCESS;
	mod_info = *md_env;
	mod_info.md_id.objid = NULL_OBJID;

	dm$return_dim_go(index=text_index, p_grid=text_grid, obj_type=DM_TEXT);

        attr_number = GRTEXT_FONT | GRTEXT_LN_SP |
		      GRTEXT_CHAR_SP | GRTEXT_HEIGHT | GRTEXT_WIDTH;

	status =
	om$send(msg = message GRtext.GRchgtextattr(
						&long_rc,
						&mod_info,
						attr_number,
						text_symb),
		targetid = text_grid->objid,
		targetos = text_grid->osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method set_ter_type(
	IGRint *msg;
	IGRint term_index;
	struct GRid *term_grid;
	struct GRmd_env *md_env;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc)
{
	IGRint status, rc;
	struct GRdpb_text_symb	text_symb;
	struct GRid tmp_grid;
	char ter_type;
	extern struct DMglobal DM_global;

	*msg = DIM_S_SUCCESS;

	dm$return_dim_go(index=term_index, p_grid=term_grid, obj_type=DM_TEXT);

	if (term_index == DIM_NO_INDEX)
	{
		status =
		om$send(msg = message DMroot.return_go_index(
						&rc,
						*term_grid,
						&term_index),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	ter_type = (term_index == DIM_ORI_TERM)?
			par_env->ter_type0:
			par_env->ter_type;

	text_symb.Active_font =
	DMmap_font(OM_Gw_current_OS, DM_global.term_info[ter_type].font_num);
	text_symb.Active_just = -1;
	text_symb.Active_charspac= 1;
	text_symb.Active_linespac= 1;
	text_symb.Active_width  = par_env->ter_widt_r * par_env->txt_heig;
	text_symb.Active_height = par_env->ter_heig_r * par_env->txt_heig;

	if (ter_type == TER_TYPE_DOT)
	{
		text_symb.Active_width /= 3.0;
		text_symb.Active_height /= 3.0;
	}

	status =
	om$send(msg = message DMroot.chgtextattr(
					&rc,
					DIM_NO_INDEX,
					term_grid,
					md_env,
					&text_symb),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.replace_text(
				&rc,
				DIM_NO_INDEX,
				term_grid,
				md_env,
				1,
		(IGRuchar *)&DM_global.term_info[ter_type].font_char),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method validate_roots(
	IGRint *msg;
	IGRint count;
	struct GRid list[])
{
	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method toggle_ter_loca(IGRint *msg; struct GRmd_env *md_env)
{
	return(OM_S_SUCCESS);
}

method get_dim_type(IGRshort *type)
{
	*type = me->dim_type;
	return(OM_S_SUCCESS);
}

method inq_dim_state(IGRchar *state)
{
	*state = me->dim_state;
	return(OM_S_SUCCESS);
}

method GRget_locate_properties(
	IGRlong *msg;
	IGRint *properties)
{
	*properties =	GR_LC_OWN_READ		|
			GR_LC_OWN_WRITE		|
			GR_LC_CMP_READ		|
			GR_LC_CMP_WRITE		|
			GR_LC_OWN_PRM_READ	|
			GR_LC_OWN_PRM_WRITE	|
			GR_LC_RIGID;

	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

method get_first_in_cpx(
	IGRint *msg;
	struct GRid *first)
{
	IGRint status;
	IGRboolean first_in_cpx;
	struct GRid prev;

	status =
	om$send(msg = message DMroot.give_previous(msg, &first_in_cpx, &prev),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!first_in_cpx)
	{
		status =
		om$send(msg = message DMroot.get_first_in_cpx(msg, first),
			targetid = prev.objid,
			targetos = prev.osnum);
		dm$status(action = RET_STATUS);
	}
	else
	{
		first->objid = my_id;
		first->osnum = OM_Gw_current_OS;
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method find_position_in_cpx(
	IGRint *msg;
	IGRint cpx_type;
	struct GRid new_dim;
	struct GRid new_meas;
	struct GRmd_env *md_env;
	IGRint *rel_pos;
	struct GRid *dim_before;
	struct GRid *dim_after)
{
	IGRint status;
	IGRint index;
	struct GRid next[2];
	IGRboolean last_in_cpx;

	*msg = DIM_S_SUCCESS;

	status =
	om$send(msg = message DMroot.give_rel_pos(
						msg,
						new_dim,
						new_meas,
						md_env,
						rel_pos),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if ((cpx_type == STRINGED_CPX) &&
	(*rel_pos == CPX_OPPOSITE_FAR || *rel_pos == CPX_OPPOSITE_NEAR))
	{
		/*| STRINGED_CPX */

		dim_after->objid = my_id;
		dim_after->osnum = OM_Gw_current_OS;
		return(OM_S_SUCCESS);
	}

	switch(*rel_pos)
	{
		/********************/
		case CPX_OPPOSITE_FAR:
		/********************/

		/*|CPX_OPPOSITE_FAR*/

		if (cpx_type == STACKED_CPX)
		{
			dim_before->objid = my_id;
			dim_before->osnum = OM_Gw_current_OS;
			break;
		}

		return(OM_S_SUCCESS);

		/*********************/
		case CPX_OPPOSITE_NEAR:
		/*********************/

		/*|CPX_OPPOSITE_NEAR*/

		if (cpx_type == STACKED_CPX)
		{
			dim_after->objid = my_id;
			dim_after->osnum = OM_Gw_current_OS;
		}

		return(OM_S_SUCCESS);

		/***********/
		case CPX_FAR:
		/***********/

		/*|CPX_FAR*/

		dim_before->objid = my_id;
		dim_before->osnum = OM_Gw_current_OS;
		break;

		/************/
		case CPX_NEAR:
		/************/

		/*|CPX_NEAR*/

		dim_after->objid = my_id;
		dim_after->osnum = OM_Gw_current_OS;
		return(OM_S_SUCCESS);

		default:

		printf("find_position_in_cpx: rel_pos %d\n", *rel_pos);
		return(OM_E_ABORT);
	}

	status =
	om$send(msg = message DMroot.give_next(msg, &last_in_cpx, next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	for (index=0; index<2; index++)
	{
		if (next[index].objid == NULL_OBJID) continue;

		status =
		om$send(msg = OPPmargs,
			targetid = next[index].objid,
			targetos = next[index].osnum);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method insert_into_cpx(
	IGRint *msg;
	IGRint action;
	struct GRmd_env *md_env;
	IGRint rel_pos;
	struct GRid *dim_before;
	struct GRid *dim_after)
{
	IGRint status, rc;
	struct GRid my_grid;
	struct GRid null_grid;
	struct GRid origin, meas;
	IGRint index;
	struct DMtrak_info trak_info;
	IGRint set_action;

	*msg = DIM_S_SUCCESS;

	my_grid.objid = my_id;
	my_grid.osnum = null_grid.osnum = OM_Gw_current_OS;
	null_grid.objid = NULL_OBJID;

	index = (me->dim_type == TEXT_WITH_BALLOON)?
			AN_ROOT_ELEM1:DIM_CPX_ORIG;

	if (dim_before->objid == NULL_OBJID)
	{
		if (dim_after->objid == NULL_OBJID)
			return(OM_S_SUCCESS);

		if ((me->dim_type == STRINGED_ANGULAR
		||  me->dim_type == STACKED_ANGULAR)
		&&  action != NO_ACTION)
		{
			status =
			om$send(msg = message DMangular.update_src(
						&rc,
						&meas,
						*dim_after,
						md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		/*|Make myself the parent for the next dimension*/

		status =
		om$get_objid_at_index(
			objid = dim_after->objid,
			osnum = dim_after->osnum,
			p_chanselect = &ND_father,
			index = DIM_CPX_ORIG,
			objidaddr = &origin.objid,
			osnumaddr = &origin.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message ASnode.NDchange_connect(
						1,
						&origin,
						&my_grid),
			mode = OM_e_wrt_message,
			targetid = dim_after->objid,
			targetos = dim_after->osnum);
		dm$status(action = RET_STATUS);

		if (action != NO_ACTION)
		{
			status =
			om$send(msg = message DMroot.get_trak_info(&trak_info),
				targetid = dim_after->objid,
				targetos = dim_after->osnum);
			dm$status(action = RET_STATUS);

			set_action = (action == ADJUST_TRAK_DIST)?
					MIN_TRAK_DIST:XCH_TRAK_DIST;

			status =
			om$send(msg = message DMroot.set_trak_info(
								set_action,
								&trak_info),
				targetid = dim_after->objid,
				targetos = dim_after->osnum);
			dm$status(action = RET_STATUS);

			trak_info.mea_trak &= ~MEAS_START;

			status =
			om$send(msg = message DMroot.set_trak_info(
								REP_TRAK_DIST,
								&trak_info),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}
	else
	{
		/*|Take previous dimension as my parent*/

		status =
		om$get_objid_at_index(
			object = me,
			p_chanselect = &ND_father,
			index = DIM_CPX_ORIG,
			objidaddr = &origin.objid,
			osnumaddr = &origin.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message ASnode.NDchange_connect(
						1,
						&origin,
						dim_before),
			mode = OM_e_wrt_message,
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (dim_after->objid == NULL_OBJID)
			return(OM_S_SUCCESS);

		/*|-connect myself to next dimension-*/

		status =
		om$send(msg = message ASnode.NDchange_connect(
							1,
							dim_before,
							&my_grid),
			mode = OM_e_wrt_message,
			targetid = dim_after->objid,
			targetos = dim_after->osnum);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method remove_from_cpx(
	IGRint *msg;
	IGRint action;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct GRid prev, next[2];
	struct GRid first, my_grid, new, meas;
	IGRint indx;
	IGRboolean first_in_cpx, last_in_cpx, string_cpx;
	IGRboolean str_lin_cpx, str_ang_cpx, no_action;
	struct DMtrak_info trak_info, trak_info1;
	IGRint cn_type;
	extern IGRboolean ASbroadcast_in_progress;
	IGRint set_action;
	IGRdouble trak_pt[3];

	*msg = DIM_S_SUCCESS;

	if (!DMis_complex(me->dim_type))
	{
		/*|- dimension is not complex*/
		return(OM_S_SUCCESS);
	}

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	status =
	om$send(msg = message DMroot.give_previous(&rc, &first_in_cpx, &prev),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.give_next(&rc, &last_in_cpx, next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (first_in_cpx && last_in_cpx)
	{
		/*|- Dimension is the only one in complex*/
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	str_lin_cpx = (me->dim_type == STRINGED_LINEAR);
	str_ang_cpx = (me->dim_type == STRINGED_ANGULAR);
	string_cpx = (str_lin_cpx || str_ang_cpx);
	no_action = ((action == NO_ACTION)
		|| (me->dim_state & DIM_IN_PLACEMENT));

	/*"dim state = %d\n", me->dim_state*/

	if (string_cpx
	&& (!(me->dim_state & DIM_IN_PLACEMENT))
	&& (action != NO_ACTION))
	{
		if ((!ASbroadcast_in_progress)
		&&  (!first_in_cpx))
		{
			cn_type = ND_COMP;
			nd$wait_batch(
				type = GR_GEOM_POSTED,
				l_object = &prev,
				l_obj_info = &cn_type,
				nb_obj   = 1);
		}

		if (str_ang_cpx
		&& !first_in_cpx
		&& !last_in_cpx
		&& !(me->geom_type & DIM_IMPORTED))
		{
			/*|- Update My Src object*/

			status =
			om$send(msg = message DMangular.update_src(
						&rc,
						&new,
						first,
						md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		else
		{
			status =
			om$get_objid_at_index(
				object = me,
				p_chanselect = &ND_father,
				index = DIM_CPX_MEAS,
				objidaddr = &new.objid,
				osnumaddr = &new.osnum);
			dm$status(action = RET_STATUS);
		}
	}
	else	new = prev;

	for (indx=0; indx<2; indx++)
	{
		if (next[indx].objid == NULL_OBJID)
			continue;

		/*^
			printf("change_connect: old=%d,%d,new=%d,%d\n",
					my_id,
					OM_Gw_current_OS,
					new.objid,
					new.osnum);
		*/

		if (me->dim_type == COORDINATE && first_in_cpx)
		{
			status =
			om$send(msg = message Root.disconnect(
							ND_children,
							next[indx].objid,
							next[indx].osnum,
							ND_father),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		else
		{
			if (((1 << me->dim_type) & ANGULAR_MASK)
			&& !no_action
			&& !(me->geom_type & DIM_IMPORTED))
			{
				/*|- Update the DMsrc object of Next*/

				status =
				om$send(msg = message DMangular.update_src(
							&rc,
							&meas,
							first,
							md_env),
					targetid = next[indx].objid,
					targetos = next[indx].osnum);
				dm$status(action = RET_STATUS);
			}

			if ((me->dim_type == TEXT_WITH_BALLOON)
			&& first_in_cpx
			&& !no_action
			&& !(me->geom_type & DIM_IMPORTED))
			{
				/*|- Update the DMsrc object to next position*/

				status =
				DMupdate_bln_src(
					&rc,
					&new,
					&next[indx],
					md_env);
				dm$status(action = RET_STATUS);
			}

			status =
			om$send(msg = message ASnode.NDchange_connect(
							1,
							&my_grid,
							&new),
				mode = OM_e_wrt_message,
				targetid = next[indx].objid,
				targetos = next[indx].osnum);
			dm$status(action = RET_STATUS);
		}

		if ((me->dim_type == COORDINATE && first_in_cpx)
		||  (str_lin_cpx && !no_action))
		{
			status =
			om$send(msg = message DMdim.get_orig_trak_pt(
							trak_pt,
							md_env),
				targetid = first.objid,
				targetos = first.osnum);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message DMdim.get_orig_trak_info(
							trak_pt,
							&trak_info,
							md_env),
				targetid = next[indx].objid,
				targetos = next[indx].osnum);
			dm$status(action = RET_STATUS);
		}
		else if (str_ang_cpx && !no_action)
		{
			status =
			om$send(msg = message DMroot.get_trak_info(&trak_info),
				targetid = first.objid,
				targetos = first.osnum);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message DMroot.get_trak_info(&trak_info1),
				targetid = next[indx].objid,
				targetos = next[indx].osnum);
			dm$status(action = RET_STATUS);

			trak_info.trak_dist += trak_info1.trak_dist;
			trak_info.mea_trak = trak_info1.mea_trak;

			status =
			om$send(msg = message DMdim.adjust_trak_dist(
						0,&trak_info1.trak_dist),
				targetid = next[indx].objid,
				targetos = next[indx].osnum);
			dm$status(action = RET_STATUS);
		}
		else
		{
			status =
			om$send(msg = message DMroot.get_trak_info(&trak_info),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if ((1 << me->dim_type) & ANGULAR_MASK)
			{
				status =
				om$send(msg = message DMroot.get_trak_info(&trak_info1),
					targetid = next[indx].objid,
					targetos = next[indx].osnum);
				dm$status(action = RET_STATUS);

				trak_info.mea_trak = trak_info1.mea_trak;
			}
		}

		set_action = -1;

		if (string_cpx && !no_action)
			set_action = REP_TRAK_DIST;
		else if (first_in_cpx && action == DELETE_ACTION)
			set_action = REP_TRAK_DIST;
		else if (first_in_cpx && action == CHG_MEAS_ACTION)
			set_action = XCH_TRAK_DIST;
		else if (action == DROP_ACTION)
			set_action = ADD_TRAK_DIST;

		if (set_action >= 0)
		{
			status =
			om$send(msg = message DMroot.set_trak_info(
							set_action,
							&trak_info),
				targetid = next[indx].objid,
				targetos = next[indx].osnum);
			dm$status(action = RET_STATUS);

			if (set_action == XCH_TRAK_DIST)
			{
				status =
				om$send(msg = message DMroot.set_trak_info(
							REP_TRAK_DIST,
							&trak_info),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
		}

		if (!no_action)
		{
			status =
			om$send(msg = message DMroot.set_degrade(md_env),
				targetid = next[indx].objid,
				targetos = next[indx].osnum);
			dm$status(action = RET_STATUS);
		}

		if (!ASbroadcast_in_progress)
		{
			cn_type = ND_COMP;
			nd$wait_batch(
				type = GR_GEOM_POSTED,
				l_object = &next[indx],
				l_obj_info = &cn_type,
				nb_obj   = 1);
		}
	}

	if (!first_in_cpx)
	{
		/*|- Final Checking */

		/* - If I am not the first dimension in the complex
		     my <prev_dim>, which is the previous dimension
		     in the complex, should be replaced by the actual
		     complex origin point - which is with the first
		     dimension in the complex - */

		if (last_in_cpx)
		{
			struct GRmd_env mod_info;

			DMget_module_info(&mod_info);

			if (!ASbroadcast_in_progress)
			{
				cn_type = ND_COMP;
				nd$wait_batch(
					type = GR_GEOM_POSTED,
					l_object = &prev,
					l_obj_info = &cn_type,
					nb_obj   = 1);
			}
		}

		status =
		om$send(msg = message DMroot.give_previous(
							&rc,
							&first_in_cpx,
							&first),
			targetid = first.objid,
			targetos = first.osnum);
		dm$status(action = RET_STATUS);

		/*^ print_grid("first", &first); */

		status =
		om$send(msg = message ASnode.NDchange_connect(
							1,
							&prev,
							&first),
			mode = OM_e_wrt_message,
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method give_previous(
	IGRint *msg;
	IGRboolean *first_in_cpx;
	struct GRid *prev)
{
	IGRint status;
	IGRint index, count;
	IGRshort matrix_type;
	IGRdouble matrix[16];
	struct GRid list[MAX_DIM_ROOTS], tmp;

	*msg = DIM_S_SUCCESS;

	if (!DMis_complex(me->dim_type))
	{
		*msg = DIM_I_NOT_A_COMPLEX;
		*first_in_cpx = TRUE;
		prev->objid = NULL_OBJID;
		return(OM_S_SUCCESS);
	}

	index = (me->dim_type == TEXT_WITH_BALLOON)?
			AN_ROOT_ELEM1:DIM_CPX_ORIG;

	status =
	om$send(msg = message DMroot.DMreturn_roots(
						&count,
						list),
			targetid = my_id);
	dm$status(action = RET_STATUS);
	
	if (list[index].objid == NULL_OBJID)
	{
		*first_in_cpx = TRUE;
		prev->objid = NULL_OBJID;
		return(OM_S_SUCCESS);
	}

	*prev = list[index];

	if (me->geom_type & DIM_IMPORTED)
	{
		status =
		om$send(msg = message NDnode.ASreturn_go(
						&tmp,
						&matrix_type,
						matrix),
			targetid = prev->objid,
			targetos = prev->osnum);
		dm$status(action = RET_STATUS);
	}
	else tmp = *prev;

	*first_in_cpx = (!DMancestry_valid(tmp, OPP_DMroot_class_id));

	return(OM_S_SUCCESS);
}

method give_next(
	IGRint *msg;
	IGRboolean *last_in_cpx;
	struct GRid *next)
{
	IGRint status;
	struct GRid *list;
	IGRint count, i, j;
	GRclassid obj_class;

	*msg = DIM_S_SUCCESS;

	next[0].objid = next[1].objid = NULL_OBJID;

	status =
	om$send(msg = message NDnode.NDget_objects(
					ND_CHILDREN | ND_IN_BUF,
					NULL,
					0,
					&list,
					0,
					OM_K_MAXINT,
					&count),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	*last_in_cpx = TRUE;

	for (i=0, j=0; i<count; i++)
	{
		status =
		om$get_classid(
			osnum = list[i].osnum,
			objid = list[i].objid,
			p_classid = &obj_class);
		dm$status(action = RET_STATUS);

		if (om$is_ancestry_valid(subclassid = obj_class,
			superclassname = "DMroot") == OM_S_SUCCESS)
		{
			if (j < 2)
			{
				*last_in_cpx = FALSE;
				next[j] = list[i];
				j++;
			}
			else
			{
/*
				During modification a copy is created
				and it also connected to same parent,
				because of this, children count could 
				exceed 2. Temporarily removing the
				check and in future release a better
				mechanism must be done to the above
				checking.

				/|ERROR: Count Exceeds two /
				return(OM_E_ABORT);
*/
			}
		}
	}

	return(OM_S_SUCCESS);
}

method get_complex_type(IGRint *type)
{
	switch (me->dim_type)
	{
		case STRINGED_LINEAR:
		case STRINGED_ANGULAR:
		*type = STRINGED_CPX;
		break;

		case COORDINATE:
		*type = COORDINATE_CPX;
		break;

		default:
		*type = STACKED_CPX;
		break;
	}

	return(OM_S_SUCCESS);
}

method give_rel_pos(
	IGRint *msg;
	struct GRid new_dim;
	struct GRid new_meas;
	struct GRmd_env *md_env;
	IGRint *rel_pos)
{
	return(OM_E_ABORT);
}

method change_parent(
	IGRint *msg;
	IGRint parent_index;
	struct GRid new;
	struct GRmd_env *md_env)
{
	IGRint status;
	IGRint count;
	struct GRid list[MAX_DIM_ROOTS], old;

	status =
	om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					list,
					MAX_DIM_ROOTS,
					NULL,
					0,
					MAX_DIM_ROOTS - 1,
					&count),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	old = list[parent_index];

	status =
	om$send(msg = message ASnode.NDchange_connect(
						1,
						&old,
						&new),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.set_degrade(md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method GRdrop(IGRlong *msg; struct GRmd_env *md_env)
{
	IGRint status, rc;

	if ((me->dim_type == STACKED_ANGULAR)
	||  (me->dim_type == STRINGED_ANGULAR)
	||  (me->dim_type == TEXT_WITH_BALLOON))
	{
		struct GRid next[2];
		IGRboolean last_in_cpx;

		status =
		om$send(msg = message DMroot.give_next(&rc, &last_in_cpx, next),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (!last_in_cpx)
		{
			status =
			om$send(msg = message GRowner.GRdrop(msg, md_env),
				targetid = next[0].objid,
				targetos = next[0].osnum);
			dm$status(action = RET_STATUS);
		}
	}

	status =
	om$send(msg = message DMroot.remove_from_cpx(
						&rc,
						DROP_ACTION,
						md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$change_class(
		osnum = OM_Gw_current_OS,
		objid = my_id,
		sd_override = OM_K_change_class_sd_override,
		classname = "GRgrgrp");
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message GRgraphics.GRaddwrng(msg, md_env),
		targetid = my_id);
	dm$status(action = RET_SATUS);

	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

method get_dim_params(
	IGRint *msg;
	IGRint type;
	IGRint size;
	char *param)
{
	return(OM_S_SUCCESS);
}

method set_dim_params(
	IGRint *msg;
	IGRint type;
	IGRint size;
	struct GRmd_env *md_env;
	char *param)
{
	return(OM_S_SUCCESS);
}

method get_dimension_plane(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct DMplan_info *plan_info)
{
	IGRint status, rc, count, i, j;
	IGRlong long_rc;
	BSrc bs_rc;
	struct GRmd_env mod_info;
	struct GRid plan;
	struct GRid list[MAX_DIM_ROOTS], dim_id;
	IGRshort four;
	IGRmatrix matrix, rot_matrix;
	struct dim_attr attr;
	IGRdouble *win_matrix, *act_matrix;
	IGRdouble angle, dotp, mea_axis[3], *axis;
	IGRvector win_xpos, act_xpos;
	IGRdouble scale, sca_fact;
	struct ret_struct ret_str;
	extern GRclassid OPP_GRgencs_class_id;

	if (me->geom_type & DIM_IMPORTED)
	{
		/*|- imported dim, pass the msg to parent dim */

		status =
		om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					list,
					MAX_DIM_ROOTS,
					NULL,
					NULL,
					OM_K_MAXINT,
					&count),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.ASreturn_go(
					&dim_id,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
			targetid = list[count-1].objid,
			targetos = list[count-1].osnum);
		dm$status(action = RET_STATUS);

		/*^ print_grid("dim_id",&dim_id);*/

		status =
		om$send(msg = message DMroot.get_dimension_plane(
							msg,
							&mod_info,
							plan_info),
			targetid = dim_id.objid,
			targetos = dim_id.osnum);
		dm$status(action = RET_STATUS);

	}
	else
	{
		/*- dimension could be connected directly to coordinate
		    system object(instead of dim_plan object), in this
		    case we need to do a NDgive_structure first and if
		    if fails send a give_plane message
		*/

		status =
		om$send(msg = message NDnode.ASreturn_go(
					&plan,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
			p_chanselect = &ND_father,
			from = DIM_ROOT_PLAN,
			to = DIM_ROOT_PLAN);
		dm$status(action = RET_STATUS);

		/*|- The object could be a coordinate system*/

		if (DMancestry_valid(plan, OPP_GRgencs_class_id))
		{
			ret_str.type = NULL;
			long_rc = 1;

			status =
			om$send(msg = message NDnode.NDgive_structure(
							&long_rc,
							&ret_str,
							md_env),
				p_chanselect = &ND_father,
				from = DIM_ROOT_PLAN,
				to = DIM_ROOT_PLAN);
			if ((1 & status & long_rc) && (ret_str.type == ref_generic))
			{
				/*|- Parent is a coordinate system*/
	
				/*- Need to transpose the matrix returned by
				    the NDgive_structure, since the format is
				    different from DMplan matrix */

				for (i=0; i<4; i++)
				{
				    for (j=0; j<4; j++)
				    {
					plan_info->win_plan.matrix[i*4+j] =
					plan_info->act_plan.matrix[i*4+j] =
					ret_str.var.ref_st.t[j*4+i];
				    }
				}
			}
			else
			{
				/*|- Invalid dimension plane object*/
				return(OM_E_ABORT);
			}
		}
		else
		{
			if (md_env->md_env.matrix_type != MAIDMX)
				mod_info = *md_env;

			/*^ print_matrix("md_env matrix",md_env->md_env.matrix); */

			status =
			om$send(msg = message dim_plan.give_plane(
							&rc,
							plan_info->win_plan.matrix,
							&mod_info),
				targetid = plan.objid,
				targetos = plan.osnum);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message dim_plan.give_axis(
							&rc,
							mea_axis,
							&mod_info),
				targetid = plan.objid,
				targetos = plan.osnum);
			dm$status(action = RET_STATUS);

			if(rc == NO_AXIS)
			{
				memcpy(
				plan_info->act_plan.matrix,
				plan_info->win_plan.matrix,
				sizeof(IGRmatrix));
			}
			else
			{
				MATH_compute_plan_info(
					&rc,
					mea_axis,
					plan_info->win_plan.matrix,
					plan_info->act_plan.matrix);
			}
		}	
	}

	if(((1 << me->dim_type) & LINEAR_MASK) &&
		(me->display & DIM_PLANE_ROTATED))
	{
		/*|- Linear Dimension & dim plane rotated */

		status = 
		om$send(msg = message DMroot.get_dim_attr(
						(char *)&attr),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		four = 4;

		if(me->display & DIM_PLANE_ROTATED_BY_90)
			angle = -PI * 0.5;
		else if(me->display & DIM_PLANE_ROTATED_BY_180)
			angle = -PI;
		else if(me->display & DIM_PLANE_ROTATED_BY_270)
			angle = -PI * 1.5;

		if(attr.mea_trak & DM_MEA_AXIS)
			axis = plan_info->act_plan.matrix;
		else	axis = &plan_info->act_plan.matrix[4];

		for( i = 0; i < 3; i++)
		{
			act_xpos[i] = plan_info->act_plan.matrix[i]; 
			win_xpos[i] = plan_info->win_plan.matrix[i]; 
			mea_axis[i] = axis[i];
		}

		scale = BSlenvec(&bs_rc, win_xpos);
		sca_fact = 1.0/scale;
		BSnorvec(&bs_rc,act_xpos);
		BSnorvec(&bs_rc,win_xpos);
		BSnorvec(&bs_rc,mea_axis);

		status = MArotmx(&long_rc,mea_axis,&angle,matrix);
		dm$status(action = RET_STATUS);

		/*^ print_matrix("rot_matrix",matrix); */

		dotp = BSdotp(&bs_rc, win_xpos, act_xpos);

		/*^ printf("dotp = %f\n",dotp); */

		win_matrix = plan_info->win_plan.matrix;
		act_matrix = plan_info->act_plan.matrix;

		if( dotp < DOTP_PARL_TOLERANCE)
		{
			/*|- mea_axis is set */

			/*^ print_matrix("act_matrix",act_matrix); */

			if (fabs(scale - 1.0) > 0.001)
			{
				status =
				MAscalmx(&long_rc,
					&four,
					&four,
					&sca_fact,
					act_matrix,
					act_matrix);
				dm$status(action = RET_STATUS);
			}

			MAmulmx(&long_rc, &four, &four, &four, act_matrix, matrix, rot_matrix);

			angle = -acos(dotp);

			/*^ printf("angle = %f\n",angle); */

			/*^ print_point("act_xaxis",rot_matrix); */

			MATH_rotate_vector(
				&rc,
				rot_matrix,
				angle,
				rot_matrix,
				mea_axis);

			/*^ print_point("win_xaxis",mea_axis); */

			MATH_compute_plan_info(
				&rc,
				mea_axis,
				rot_matrix,
				win_matrix);
			
			memcpy(act_matrix, rot_matrix, sizeof(IGRmatrix));

			if (fabs(scale - 1.0) > 0.001)
			{
				status =
				MAscalmx(&long_rc,
					&four,
					&four,
					&scale,
					act_matrix,
					act_matrix);
				dm$status(action = RET_STATUS);

				status =
				MAscalmx(&long_rc,
					&four,
					&four,
					&scale,
					win_matrix,
					win_matrix);
				dm$status(action = RET_STATUS);
			}
		}
		else
		{
			MAmulmx(&long_rc, &four, &four, &four, win_matrix, matrix, rot_matrix);

			memcpy(win_matrix, rot_matrix, sizeof(IGRmatrix));
			memcpy(act_matrix, rot_matrix, sizeof(IGRmatrix));
		}

		/*^
			print_matrix("act_matrix",act_matrix);
			print_matrix("win_matrix",win_matrix);
		*/

	}

	DMfill_plan_info(plan_info);

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method get_window_plane(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRmatrix matrix)
{
	IGRint status, rc, count, i, j;
	IGRlong long_rc;
	struct GRid plan;
	struct GRid list[MAX_DIM_ROOTS], dim_id;
	struct GRmd_env mod_info;
	struct DMplan_info plan_info;
	struct ret_struct ret_str;

	*msg = DIM_S_SUCCESS;

	if (me->geom_type & DIM_IMPORTED)
	{
		/*|- imported dim, pass the msg to parent dim */

		status =
		om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					list,
					MAX_DIM_ROOTS,
					NULL,
					NULL,
					OM_K_MAXINT,
					&count),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.ASreturn_go(
					&dim_id,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
			targetid = list[count-1].objid,
			targetos = list[count-1].osnum);
		dm$status(action = RET_STATUS);

		/*^ print_grid("dim_id",&dim_id);*/

		status =
		om$send(msg = message DMroot.get_window_plane(
							msg,
							&mod_info,
							matrix),
			targetid = dim_id.objid,
			targetos = dim_id.osnum);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	if (me->display & DIM_PLANE_ROTATED)
	{
		status =
		om$send(msg = message DMroot.get_dimension_plane(&rc, md_env, &plan_info),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		memcpy(matrix, plan_info.win_plan.matrix, sizeof(IGRmatrix));

		return(OM_S_SUCCESS);
	}

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
		p_chanselect = &ND_father,
		from = DIM_ROOT_PLAN,
		to = DIM_ROOT_PLAN);
	if ((1 & status & long_rc) && (ret_str.type == ref_generic))
	{
		/*|- Parent is a coordinate system*/

		/*- Need to transpose the matrix returned by
		    the NDgive_structure, since the format is
		    different from DMplan matrix */

		for (i=0; i<4; i++)
		    for (j=0; j<4; j++)
			matrix[i*4+j] = ret_str.var.ref_st.t[j*4+i];
	}
	else
	{
		status =
		om$send(msg = message NDnode.ASreturn_go(
					&plan,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
			p_chanselect = &ND_father,
			from = DIM_ROOT_PLAN,
			to = DIM_ROOT_PLAN);
		dm$status(action = RET_STATUS);

		if (md_env->md_env.matrix_type != MAIDMX)
			mod_info = *md_env;

		status =
		om$send(msg = message dim_plan.give_plane(
					&rc,
					matrix,
					&mod_info),
			targetid = plan.objid,
			targetos = plan.osnum);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method send_to_root(
	IGRint root_index;
	struct GRmd_env *md_env;
	OM_p_MESSAGE p_msg)
{
	IGRint status;
	struct GRid grid;
	struct GRmd_env tmp_env;

	tmp_env = *md_env;

	status =
	om$send(msg = message NDnode.ASreturn_go(
				&grid,
				&md_env->md_env.matrix_type,
				md_env->md_env.matrix),
		p_chanselect = &ND_father,
		from = root_index,
		to =  root_index);
	dm$status();

	if (status & 1)
	{

		/*
		md_env->md_id.objid = NULL_OBJID;
		md_env->md_id.osnum = impdim.osnum;
		*/

		status =
		om$send(msg = p_msg,
			targetid = grid.objid,
			targetos = grid.osnum);
		dm$status();
	}

	*md_env = tmp_env;
	return(status);
}

method DMplace(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	char *attr;
	struct GRmd_env *md_env)
{
	IGRint status, rc, i, num_parents;
	struct GRid null_grid;
	extern GRclassid OPP_dim_plan_class_id,
			 OPP_dim_src_class_id;

	/* - VALIDATE ROOTS - */

	status =
	om$send(msg = message DMroot.validate_roots(&rc, count, list),
		targetid = my_id);
 	dm$status(action = RET_STATUS);

	/*|	- Connect Parents - */

	null_grid.objid = NULL_OBJID;
	null_grid.osnum = OM_Gw_current_OS;

	me->comp_mask	= 0;
	me->state	= ND_DEFAULT;

	num_parents = count-1;

	for(i=num_parents; i>2; i--)
	{
		if ((DMancestry_valid(list[i], OPP_dim_plan_class_id))
		&& (DMancestry_valid(list[i], OPP_dim_src_class_id))
		&& (list[i].objid == list[0].objid))
		{
			/*| - Duplicate parent id */
			
			count--;
		}
	}

	status =
	om$send(msg = message NDnode.NDconnect(
					count,
					list,
					null_grid,
					ND_NEW),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.set_degrade(md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method get_trak_info(struct DMtrak_info *trak_info)
{
	return(OM_S_SUCCESS);
}

method set_trak_info(IGRint action; struct DMtrak_info *trak_info)
{
	return(OM_S_SUCCESS);
}

method GRdelete(
	IGRlong *msg;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRint mod_graph;
	OM_S_OBJID md_id;
	struct GRid my_grid;

	extern IGRboolean ASbroadcast_in_progress;

	me->dim_state |= GRDELETE_PENDING;

	if (!ASbroadcast_in_progress)
	{
		/*| Inquire mod_graph */

		nd$mod_graph(request = ND_INQ, p_ret_mode = &mod_graph);

		/*"mod_graph=0x%x\n", mod_graph*/

                if ((mod_graph & ND_NO_BROAD_DEL)
		&&  (md_env->md_id.objid != NULL_OBJID))
		{
			IGRuint l_count;
			/*|ND_NO_BROAD_DEL - remove_from_cpx*/

			status =
			om$send(msg = message DMroot.remove_from_cpx(
						&rc,
						DELETE_ACTION,
						md_env),
				targetid = my_id);
                        /** remove_from_cpx fails as dim_clones do not have
                            connection to the actual dim objects after
	                    a detach ref file is done. Provide temporary
	                    parents. 
			*/
			if( !(status &1) && DMis_complex(me->dim_type))
			{
			  struct GRid prev,next;

			    my_grid.objid = my_id;
			    my_grid.osnum = OM_Gw_current_OS;

        		    om$get_channel_count(objid = my_id,
                                          p_chanselect = &ND_children,
                             		  count = &l_count);
			    if(l_count)
			     {
				  next.objid = NULL_OBJID;
				  prev.objid = NULL_OBJID;
			          status =
				  om$get_objid_at_index(
					    object = me,
					    p_chanselect = &ND_father,
					    index = DIM_CPX_MEAS,
					    objidaddr = &prev.objid,
					    osnumaddr = &prev.osnum);

			          status =
				  om$get_objid_at_index(
					    object = me,
					    p_chanselect = &ND_children,
					    index = 0,
					    objidaddr = &next.objid,
					    osnumaddr = &next.osnum);

				    status =
				    om$send(msg = message ASnode.NDchange_connect(
						 1,
						&my_grid,
						&prev),
					    mode = OM_e_wrt_message,
					    targetid = next.objid,
					    targetos = next.osnum);

				/* All efforts to keep dim intact have failed. 
				   Do not check the status 
				*/
				 dm$status();

			     }
			    else 
				 dm$status();
			}
		}
	}

	if ((md_id = md_env->md_id.objid) != NULL_OBJID)
	{
		/* - Remove owner from R-tree and set
		   - md_id to NULL_OBJID so that no
		   - attempt is made to remove components
		   - from the R-tree (they are never in
		   - in the R-tree).
		*/

		status =
		om$send(msg = message GRgraphics.GRremwrng(msg, md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		md_env->md_id.objid = NULL_OBJID;
	}

	status =
	om$send(msg = message ASnode.GRdelete(msg, md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	md_env->md_id.objid = md_id;
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method NDdelete(
	struct GRmd_env *md_env)
{
	IGRint status;
	IGRlong long_rc;
	OM_S_OBJID md_id;

	if ((md_id = md_env->md_id.objid) != NULL_OBJID)
	{
		/* - Remove owner from R-tree and set
		   - md_id to NULL_OBJID so that no
		   - attempt is made to remove components
		   - from the R-tree (they are never in
		   - in the R-tree).
		*/

		status =
		om$send(msg = message GRgraphics.GRremwrng(&long_rc, md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		md_env->md_id.objid = NULL_OBJID;
	}

	status =
	om$send(msg = message GRgraphics.GRdelete(&long_rc, md_env),
		p_chanselect = &AS_to_comp);
	md_env->md_id.objid = md_id;
	dm$status(action = RET_STATUS);

	/*| - delete myself with respect to node message */
	/*|   (to notify roots for disconnection) */


	status =
	om$send( msg = message NDnode.NDdelete(md_env),
                   mode = OM_e_wrt_message,
                   targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method leader_needed(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRboolean *leader)
{
	*leader = FALSE;
	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method leader_off()
{
	return(OM_S_SUCCESS);
}

method is_complex(IGRint *msg)
{
	*msg = DMis_complex(me->dim_type);
	return(OM_S_SUCCESS);
}

method clear_offset()
{
	return(OM_S_SUCCESS);
}

method init_ter_loca(IGRdouble ter_limit)
{
	return(OM_S_SUCCESS);
}

method test_state(IGRshort mask; int *on, *off)
{
	if (me->dim_state & mask)
		(*on)++;
	else	(*off)++;

	if (*on && *off)
		return(OM_I_STOP_SENDING);

	return(OM_S_SUCCESS);
}

method connect_state(IGRshort mask; struct GRid *old, *new)
{
	IGRint status;

	if (me->dim_state & mask)
	{
		/*^
			print_grid("old", old);
			print_grid("new", new);
		*/

		status =
		om$send(msg = message ASnode.NDchange_connect(1, old, new),
			mode = OM_e_wrt_message,
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method ASreturn_go( struct GRid *go;
		    IGRshort *mat_type;
		    IGRdouble *matrix)
{
	IGRlong rc;

	if (matrix && mat_type)
	{
		MAidmx(&rc, matrix);
		*mat_type = MAIDMX;
	}

	go->objid = my_id;
	go->osnum = OM_Gw_current_OS;

	return(OM_S_SUCCESS);
}

method NDgive_structure(
	IGRlong *msg;
	struct ret_struct *str;
	struct GRmd_env *md_env)
{
	str->type = macro_generic;
	strcpy(str->var.macro_st.name, "ci_dim_mac");

	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

method NDcopy(
	IGRlong *msg;
	IGRint cp_type;
	struct GRmd_env *fr_env;
	struct GRmd_env *to_env;
	struct GRid *newobjid)
{
	IGRint status;
	OM_S_OBJID fr_md_id, to_md_id;

	fr_md_id = fr_env->md_id.objid;
	to_md_id = to_env->md_id.objid;
	to_env->md_id.objid = NULL_OBJID;
	fr_env->md_id.objid = NULL_OBJID;

	status =
	om$send(msg = message ASnode.NDcopy(
				msg,
				cp_type,
				fr_env,
				to_env,
				newobjid),
		mode = OM_e_wrt_message,
		targetid = my_id);
	to_env->md_id.objid = to_md_id;
	fr_env->md_id.objid = fr_md_id;
	dm$status(action = RET_STATUS);

	if (to_md_id != NULL_OBJID)
	{
		status =
		om$send(msg = message GRgraphics.GRaddwrng(msg, to_env),
			targetid = newobjid->objid,
			targetos = newobjid->osnum);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method NDcopy_to_root(
	IGRlong *msg;
	IGRint cp_type;
	struct GRmd_env *md_env, *new_info;
	struct GRid *newobjid)
{
	IGRint status, rc;
	struct GRid grid[MAX_COMP_INDEX + 1];
	OM_S_OBJECT_LINKAGE glist[MAX_COMP_INDEX + 1];
	struct ret_struct feet[MAX_COMP_INDEX + 1];
	struct GRid active_owner;
	extern GRclassid OPP_ACroot_class_id;
	int count, index, go_index, dim_mask, actmsg;

	if (me->state & ND_DEGRADED)
	{
		/*| ND_DEGRADED */

		return(OM_W_ABORT);
	}

	status =
	om$get_channel_objects(
		objid = my_id,
		size = MAX_COMP_INDEX + 1,
		list = glist,
		p_chanselect = &AS_to_comp,
		count = (OMuint *) &count);
	dm$status(action = RET_STATUS);

	/*"count=%d\n", count*/

	gr$get_active_owner(msg = &actmsg, active_owner = &active_owner);
	if (actmsg == MSSUCC) gr$clear_active_owner(msg = &actmsg);

	go_index = 0;
	dim_mask = me->comp_mask;

	for (index=0; index<count; index++)
	{
		status =
		om$send(msg =  message GRgraphics.GRcopy(
						msg,
						md_env,
						new_info,
						&grid[index].objid),
			targetid = glist[index].S_objid,
			targetos = glist[index].osnum);
		dm$status(action = RET_STATUS);

		grid[index].osnum = new_info->md_id.osnum;

		while (!(dim_mask & 1))
		{
			go_index++;
/*			dim_mask << 1;*/
		}

		/*"index=%d, go_index=%d\n", index, go_index*/

		status =
		as$any_give_structure(
			go_grid = grid[index],
			mod_env = new_info,
			inst = &feet[go_index]);
		dm$status(action = RET_STATUS);
	}

	newobjid->osnum=new_info->md_id.osnum;

	status =
	om$construct(
		classid = OPP_ACroot_class_id, 
		msg = message ACroot.ACmplace(
				&rc,
				0,
				"ci_dim_mac",
				count,
				grid,
				MAX_COMP_INDEX + 1,
				feet,
				new_info),
		p_objid = &(newobjid->objid),
		osnum = newobjid->osnum);
	dm$status(action = RET_STATUS);

	/*^ print_grid("newobjid", newobjid); */

	if(actmsg == MSSUCC)
	{
		gr$put_active_owner(
			msg = &actmsg,
			active_owner = &active_owner);
	}

	return(OM_S_SUCCESS);
}

method get_complex_size(IGRint *size)
{
	IGRint status, rc;
	struct GRid next[2];
	IGRboolean last_in_cpx;
	IGRint nsize, i;

	*size = 1;

	status =
	om$send(msg = message DMroot.give_next(&rc, &last_in_cpx, next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	for (i=0; i<2; i++)
	{
		if (next[i].objid == NULL_OBJID) continue;

		status =
		om$send(msg = message DMroot.get_complex_size(&nsize),
			targetid = next[i].objid,
			targetos = next[i].osnum);
		dm$status(action = RET_STATUS);

		*size += nsize;
	}

	return(OM_S_SUCCESS);
}

method jog_needed(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRboolean *jogged)
{
	*jogged = FALSE;
	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method jogged_off()
{
	return(OM_S_SUCCESS);
}

method clear_jog_pts(IGRint flag)
{
	return(OM_S_SUCCESS);
}

method ACcopy_to_Groot(
	IGRlong *msg;
	IGRint cp_type;
	struct GRmd_env *fr_env, *to_env;
	struct GRid *newobjid)
{
	/*- This message was overriden to support the macros. During
	    the placement of macros they copy the macro and send a display
	    to the copied macro. If the macro as dimensions attached
	    to it they don't get copied(GRcopy does not copy dimension)
	    so to support this capability the dimension overrides this
	    message and returns the a copy of it. Since dimension very
	    much depends on its parents they are also copied along with it.
	*/

	IGRint status, count, index;
	struct GRid list[MAX_DIM_ROOTS], go_grid, my_grid, src_copy;
	struct GRmd_env mod_info;
	extern GRclassid OPP_GRgencs_class_id;

	*msg = MSSUCC;
	newobjid->objid = NULL_OBJID;
	newobjid->osnum = to_env->md_id.osnum;
	mod_info.md_id.objid = NULL_OBJID;
	mod_info.md_id.osnum = fr_env->md_id.osnum;

	status =
	om$send(msg = message NDnode.NDcopy(
					msg,
					cp_type,
					fr_env,
					to_env,
					newobjid),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*|- Copy the DMplan & dim_param objects and connect it to copy */

	status =
	om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					list,
					MAX_DIM_ROOTS,
					NULL,
					0,
					OM_K_MAXINT,
					&count),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	for (index=0; index<count; index++)
	{
		status =
		om$send(msg = message NDnode.ASreturn_go(
					&go_grid,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
			targetid = list[index].objid,
			targetos = list[index].osnum);
		dm$status(action = RET_STATUS);

		/*|- Copy the parents */

		src_copy.osnum = to_env->md_id.osnum;

		if (DMancestry_valid(go_grid, OPP_GRgencs_class_id))
		{
			status =
			om$send(msg = message NDnode.NDcopy_to_root(
						msg,
						0,
						fr_env,
						to_env,
						&src_copy),
				targetid = list[index].objid,
				targetos = list[index].osnum);
			dm$status(action = RET_STATUS);
		}
		else
		{
			status =
			om$send(msg = message NDnode.NDcopy(
							msg,
							0,
							&mod_info,
							to_env,
							&src_copy),
				targetid = go_grid.objid,
				targetos = go_grid.osnum);
			dm$status(action = RET_STATUS);
		}

		if (src_copy.objid != NULL_OBJID)
		{
			list[index].objid = src_copy.objid;
			list[index].osnum = src_copy.osnum;
		}
	}

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	status =
	om$send(msg = message NDnode.NDconnect(
					count,
					list,
					my_grid,
					ND_NEW),
        	targetid = newobjid->objid,
        	targetos = newobjid->osnum);
	dm$status(action = RET_STATUS);

	status =
        om$send(msg = message DMroot.set_geom_type(BIT_SET, 0, NULL),
        	targetid = newobjid->objid,
        	targetos = newobjid->osnum);
        dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}
 
method return_vertex(
IGRint *msg;
IGRint *dim_type;
IGRboolean *first_in_cpx, *jogged;
IGRpoint point;
IGRint *vertex_no;
struct GRmd_env *md_env)
{
	IGRint status, rc, i,index;
	IGRlong long_rc;
	IGRpoint keypt, point2;
	IGRdouble *poles;
	struct GRparms par;
	struct IGRbsp_curve *bsp_curve;
	struct IGRline boreline;
	struct DMplan_info plan_info;
	struct GRid  go_grid, prev;

	*dim_type = me->dim_type;
	*first_in_cpx = FALSE;
	*jogged = FALSE;

	if (me->dim_type == COORDINATE)
	{
		status =
		om$send(msg = message DMroot.give_previous(
						&rc,
						first_in_cpx,
						&prev),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		index = (*first_in_cpx)?DIM_ORI_PROJ:DIM_MEA_PROJ;

		status =
		om$send(msg = message DMroot.get_jog_info(
						&rc,
						jogged,
						NULL,
						NULL,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else if (me->dim_type == WELD)
		index = LEAD_LINE;
	else if (me->dim_type == SURF)
		index = SURF_LEADER;
	else	index = DIM_LEADER;

	status =
	om$send(msg = message DMroot.return_dim_go(
					&rc,
					index,
					FALSE,
					NULL,
					md_env,
					&go_grid),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	if(go_grid.objid == NULL_OBJID)
	{
		/*| - no leader line present */
		return(OM_E_ABORT);
	}

	status =
	om$send(msg = message DMroot.get_dimension_plane(
						&rc,
						md_env,
						&plan_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	boreline.point1 = point;
	boreline.point2 = point2;

	point2[0] = point[0] + plan_info.act_plan.matrix[0 + 8];
	point2[1] = point[1] + plan_info.act_plan.matrix[1 + 8];
	point2[2] = point[2] + plan_info.act_plan.matrix[2 + 8];

	status =
	om$send(msg = message GRvg.GRkeypoint(
				&long_rc,
				&md_env->md_env.matrix_type,
				md_env->md_env.matrix,
				&boreline,
				keypt,
				&par),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	/*^
		printf("u_par = %lf\n", par.u);
		print_point("point", point);
		print_point("point2", point2);
		print_point("keypoint", keypt);
		print_grid("go_grid", &go_grid);
	*/

	status =
	om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					(char **)&bsp_curve),
		targetid = go_grid.objid,
		targetos = go_grid.osnum);
	dm$status(action = RET_STATUS);

	*vertex_no = -1;
	for (i=0; i<bsp_curve->num_poles; i++)
	{
		poles = &bsp_curve->poles[3*i];
		if ((fabs(poles[0] - keypt[0]) < 1e-09)
		    &&  (fabs(poles[1] - keypt[1]) < 1e-09)
		    &&  (fabs(poles[2] - keypt[2]) < 1e-09))
		{
			*vertex_no = i;

			/*^
				printf("vertex=%d\n", *vertex_no);
				print_point("pole_i", poles);
			*/

			break;
		}
	}

	if (*vertex_no < 0)
	{
		/*|Key point is not one of the poles*/
		return(OM_E_ABORT);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method get_jog_info(
	IGRint *msg;
	IGRboolean *jogged;
	IGRint *num_jog_pts;
	IGRdouble jog_line[12];
	struct GRmd_env *md_env)
{
	*jogged = FALSE;
	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method debug()
{
IGRint status;
IGRlong long_rc;
struct GRobj_info info;
struct dim_attr dm_attr;
struct annot_attr an_attr;
struct cenline_attr cen_attr;
IGRchar *attr;
IGRint index;
IGRchar comp[32];
IGRboolean annot, dim, cenline;

	status=
	om$send(msg = message DMroot.GRgetobjinfo(
					&long_rc,
					&info),
		targetid=my_id);
	dm$status(action = RET_STATUS);			

	
	printf("\nOBJECT (%d %d)\n ",my_id,OM_Gw_current_OS);
	printf("%s\n",info.type);

	annot   =  FALSE;
	dim     =  FALSE;
	cenline =  FALSE;

	if ( (1 << me->dim_type) & ANNOTATION_MASK)
	{
		attr = (char *)&an_attr;
		annot = TRUE;
	}
	else if ( (1 << me->dim_type) & CENTER_LINE_MASK)
	{
		attr = (char *)&cen_attr;
		cenline = TRUE;
	}
	else 
	{
		attr = (char *)&dm_attr;
		dim = TRUE;
	}
	
	status =
	om$send(msg = message DMroot.get_dim_attr((char *)attr),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	printf("dim_type = %d\n",me->dim_type);

	printf("driving dim %d\n", (me->geom_type & DIM_DRIVING));					
	printf("implicit dim %d\n", (me->geom_type & DIM_IMPLICIT));					
	printf("dim directed %d\n",(me->geom_type & DIM_DIRECTED));					
	printf("intermediate dim %d\n", (me->geom_type & DIM_INTERMEDIATE));					
	printf("detached dim %d\n", (me->geom_type & DIM_DETACHED));					
	printf("reference dim %d\n", (me->geom_type & DIM_REFERENCE));					
	printf("dim by name %d\n", (me->geom_type & DIM_BY_NAME));					
	printf("retrived dim %d\n", (me->geom_type & DIM_IMPORTED));					

	printf("dim_display_off %d\n",(me->display &DIM_DISPLAY_OFF));
	printf("dim swapped %d\n",(me->display & DIM_PLANE_ROTATED));

	if(annot)
	{
		print_point("start_pt",an_attr.start_pt);
		if(me->dim_type == LEADER_LINE)
			print_point("end_pt",an_attr.end_pt);
		printf("text_length = %d\n",an_attr.text_length);
		analyse_string(an_attr.text_string,an_attr.text_length);

		for ( index=0; index<an_attr.num_brkpt; index++ )
			printf("brk_pt[%d] = %lf ,%lf ,%lf\n",
				index,
				an_attr.brkpt[3*index],
				an_attr.brkpt[3*index+1],
				an_attr.brkpt[3*index+2]);

		printf("leader %d\n", an_attr.leader);

		printf("dual_mode %d\n",an_attr.dual_mode);
	
		printf("bln_dir = %d\n",an_attr.bln_dir);

		printf("tol_symbol = %d\n",an_attr.tol_symbol);
	}

	if(cenline)
	{
		printf("gap_r = %lf \n",cen_attr.gap_r);
		printf("minor_len_r = %lf \n",cen_attr.minor_len_r);
		printf("major_len_r = %lf\n",cen_attr.major_len_r);
		printf("posn = %d\n",cen_attr.posn);
	}

	if (dim)
	{	int ii;

		printf("brk_dist = %lf \n",dm_attr.brk_dist);
		printf("lead_dist = %lf \n",dm_attr.lead_dist);
		printf("trak_dist = %lf \n",dm_attr.trak_dist);
		printf("offs_pt %lf %lf \n",dm_attr.offs_pt[0],
					    dm_attr.offs_pt[1]);
		printf("prj_offs %lf %lf \n",dm_attr.prj_offs[0],
					     dm_attr.prj_offs[1]);
		printf("mea_trak = %d\n",dm_attr.mea_trak);
		printf("brk_pos = %d\n",dm_attr.brk_pos);
		printf("ter_loca = %d\n",dm_attr.ter_loca);
		printf("leader %d\n",dm_attr.leader);

		for ( ii=0,index=0; index< MAX_COMP_INDEX; index++ )
		{

			if (me->comp_mask & ( 1<<index))
			{
				status = DMfind_comp(index,comp);
				printf("\n%s\n",comp);
				printf("index = %d\n",index);
				om$send(msg = message Root.debug(),
					p_chanselect = &AS_to_comp,
					from = ii, to = ii);
				dm$status(action = RET_STATUS);
				ii++;
			}

		}
	}
	else
	{
		status =
		om$send(msg = message Root.debug(),
			p_chanselect = &AS_to_comp);
		dm$status(action = RET_STATUS);
	}

	return(TRUE);

}

DMfind_comp(index,comp)
IGRint index;
IGRchar *comp;
{
	if ( index==0 )
		strcpy(comp,"DIM_TEXT");
	else if ( index==1 )
		strcpy(comp,"DIM_ORIG_TERM");
	else if ( index==2 )
		strcpy(comp,"DIM_MEAS_TERM");
	else if ( index==3 )
		strcpy(comp,"DIM_ORIG_PROJ");
	else if ( index==4 )
		strcpy(comp,"DIM_MEAS_PROJ");
	else if ( index==5 )
		strcpy(comp,"DIM_LEADER");
	else if ( index==6 )
		strcpy(comp,"DIM_LINE1");
	else if ( index==7 )
		strcpy(comp,"DIM_LINE2");
	else if ( index==8 )
		strcpy(comp,"DIM_LINE3");
	else if ( index==9 )
		strcpy(comp,"DIM_LINE4");
	else if ( index==10 )
		strcpy(comp,"DIM_ULINE");
	else if ( index==11 )
		strcpy(comp,"DIM_BOX");
	else if ( index==12 )
		strcpy(comp,"DIM_BALLOON");
     
	return(TRUE);

}

method ACbecome_foot(
	long *msg;
	struct GRid *new_id;
	struct GRmd_env *md_env)
{
	/*- The message is overriden to take care of the macro problem.
	    When a copy is sent to dimension by a macro the dimension
	    is copied along with its parents, and ACbecome_foot default
	    implementation at NDmacro level disconnects all the parents
	    to avoid this problem the message is overriden at DMroot
	    level and return success.
	*/
	
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

end implementation DMroot;
