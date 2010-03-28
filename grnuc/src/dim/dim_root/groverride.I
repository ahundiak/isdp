/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:31 $
$Locker:  $
$Log: groverride.I,v $
Revision 1.1.1.1  2001/12/17 22:39:31  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:08:55  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.2  1996/12/31  07:24:31  skathiri
# COMMENT : Changes for RFA+Assembly
#
# Revision 330.1  1996/04/24  22:29:28  siki
# COMMENT : 321 checkin
#
# Revision 320.4  1995/06/28  05:29:26  gvk
# COMMENT : Place dimension:Imposing detached symbology on copied graphics
#
# Revision 320.3  1995/01/30  14:35:16  gvk
# COMMENT : Detached dimensions copy across reference files will be copied as graphic group.
#
# Revision 320.1  1994/12/27  12:03:25  sudha
# COMMENT : Purify fixes
#
# Revision 320.0  1994/12/12  17:52:25  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.12  1994/11/01  10:12:25  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.11  1993/11/03  22:14:57  shridar
# COMMENT : Added fix for dlist matrix
#
# Revision 240.10  1993/09/27  09:34:10  samuel
# COMMENT : Fix for TR119310615
#
# Revision 240.9  1993/09/14  16:57:11  rogers
# COMMENT : Add dimension header (for performance boost) and curve/surface polygon support
#
# Revision 240.8  1993/08/24  14:07:21  gvk
# COMMENT : Updated GRcopy method
#
# Revision 240.7  1993/08/13  08:21:05  laxmi
# COMMENT : Minor changes for Sun compatibility -Laxmi 13 Aug 1993
#
# Revision 240.6  1993/08/03  05:42:51  laxmi
# COMMENT : Dimensioning 2.4 CR and TR fixes checkin. -Laxmi
#
# Revision 240.5  1993/06/02  18:30:46  henry
# COMMENT : call DIupdate_form from NDexec_batch.
#
# Revision 240.4  1993/05/07  21:02:19  mike
# COMMENT : TR11924981 - Plot dimensions using the same global color definitions that are used for display.
#
# Revision 240.3  1993/05/06  10:15:13  laxmi
# COMMENT : DImensioning TR fixes checkin. -Laxmi.
#
# Revision 240.2  1993/04/12  14:11:14  mike
# COMMENT : TR119303891 - Restore NULL alt_symb->color in GRdisyourself.
#
# Revision 220.5  1993/01/22  16:52:40  mike
# COMMENT : TR11926001 - Pass the correct module id/os along to components when plotting.
#
# Revision 220.4  1992/10/30  23:19:57  poo
# COMMENT : Initialising module osnum properly during Copy.
#
# Revision 220.3  1992/10/19  21:12:46  poo
# COMMENT : Fix to handle Coordinate system as a dimension plane or dimensions parent.
#
Revision 201.46  1992/10/09  21:38:07  poo
COMMENT : Edit dimension corruption problem -gvk

Revision 201.45  1992/10/05  18:16:43  poo
COMMENT : Fix for macro problem & cell creation.

Revision 201.44  1992/09/03  11:10:38  poo
COMMENT : Filling the layer in GRgetsymb, was left out.

Revision 201.43  1992/08/20  14:11:29  prasad
COMMENT : Dimensions without parents did not display sometimes

Revision 201.42  1992/08/20  08:06:22  poo
COMMENT : GRgetsymb - return dimension line parameters.

Revision 201.41  1992/08/14  12:16:41  prasad
COMMENT : Support for copy of dimensions in nested macros

Revision 201.40  1992/07/29  18:55:06  poo
COMMENT : Initial Release of Surface Finish & Jogged bug fixes

Revision 201.39  1992/07/19  16:14:12  poo
COMMENT : Inital Checkin of Jogged Dimension fuctionality.

Revision 201.32  1992/02/13  12:54:05  dimdp20
COMMENT : Plot file problem & text with leader(auto dim) changes.

Revision 201.31  1992/02/12  07:19:22  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - 12 Feb. 1992

Revision 201.30  1992/02/06  14:03:07  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Feb. 6 1992

Revision 201.29  1992/02/06  12:47:50  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Feb. 6 92

Revision 201.28  1992/02/03  13:01:14  dimdp20
COMMENT : Dimensioning Fixes Release - S. Poovannan - Feb 3 1992

Revision 201.27  1992/01/31  18:18:10  dimdp20
COMMENT : DIMENSION FIXES RELEASE - 31-1-92

Revision 201.25  92/01/22  07:37:00  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Jan. 22 1992.

Revision 201.23  92/01/20  07:58:46  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Jan 20 1992

*/

class implementation DMroot;

#include "gocmacros.h"
#include "dpdef.h"
#include "msmacros.h"
#include "DMmsg.h"

#include "DPdlist.h"
#include "matypemx.h"
#include "mamulmx.h"
#include "mainvmx.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bscrossp.h"
#include <alloca.h>

#define AS_DEBUG 1

extern struct DMglobal_param frm_glob;
extern IGRboolean display_invisible_dims;
extern IGRboolean display_reffile_dims;
extern IGRboolean display_different_dims;
extern IGRboolean display_ref_diff_dims;
extern double fabs();

from IGEgragad import DPinrot;
from module import mod_info;

method GRdisyourself(
	IGRlong *msg; 
	IGRshort *mx_type; 
	IGRmatrix matrix; 
	enum GRdpmode *mode; 
	struct IGRaltdisplay *alt_symb;
	struct DP_information *sp_info;
	OM_p_KEY_DESC range_key)
{
	IGRint status, rc, i;
	OMuint parent_count=0;
	struct GRmd_env md_env;
	IGRdouble *dp_rotation, dm_norm[3], offset, txt_length;
	struct GRid impdim, context;
	struct DPgra_gad *gragad;
	struct IGRaltdisplay new_symb;
	IGRushort color, *p_old_color = NULL;
        IGRint alt_color_disturbed = FALSE;
	enum GRdpmode dpmode; 
	IGRlong long_rc;
	IGRshort new_type, txt_check;
	IGRmatrix new_env, lbsys_mat, text_mat;
	extern IGRint Disp_count;
	struct DMenv_param par_env;
	IGRshort current_layer;
	IGRboolean invalid_layer;

	invalid_layer = FALSE;

	if (*mode == GRhd || *mode == GRbdhd || *mode == GRbehd ||
            *mode == GRhe || *mode == GRbehe || *mode == GRbdhe)
	{
		struct GRid grid;
	    	OM_S_OBJECT_LINKAGE list[1];
	    	OMuint count = 0;

		grid.osnum = OM_Gw_current_OS;

		if (me->to_owners)
		{
			om$get_channel_objects(
				p_chanselect = &AS_to_owner,
				size = 1,
				count = &count,
				list = list,
				objid = my_id);

			grid.objid = list[0].S_objid;
		}
		else	grid.objid = my_id;

                if (*mode == GRhd || *mode == GRbdhd || *mode == GRbehd)
		  DIhilite_line ( &grid );
                else
		  DIunhilite_line ( &grid );
	}

	dpmode = *mode;
	txt_check = TRUE;
/*
 * If parents exist, then use my_id else get_dim_param returns error
 * which causes some dimensions to not display. 
 * Dimensions without parents exist in macros.
 * pp 08/20/92
 */

        status = 
        om$get_channel_count(objid = my_id,
                             p_chanselect = &ND_father,
                             count = &parent_count);
	dm$status();

	status=
	dm$get_dim_param(
       		type= DM_ENV_PARAM,
		dim_objid = (parent_count ? my_id : NULL_OBJID),
	        dim_osnum = OM_Gw_current_OS,
        	p_data = (char *) &par_env);
	dm$status();
	if (!(status & 1)) txt_check = FALSE;

/* end pp */

	current_layer = par_env.dim_layr;
        if(DMvalid_dim_offset_active_layer(par_env.dim_layr))
	{
                DMget_current_dim_layer(par_env.dim_layr, &current_layer, 
					&invalid_layer);
		if (invalid_layer)
			ex$message(msgnumb=DM_E_LyrOutOfRngActLyr);
	}

	if (DPlevel_on(current_layer, sp_info))
	{
		/*|- Level ON */

		me->display &= ~DIM_LAYER_OFF;
	}
	else
	{
		/*|- Level OFF */

		me->display |= DIM_LAYER_OFF;
		return(OM_S_SUCCESS);
	}

	/*"display_invisible_dims = %d\n", display_invisible_dims*/
	/*"display_reffile_dims = %d\n", display_reffile_dims*/

	if (me->display & DIM_DISPLAY_OFF)
	{
		/*| - Dimension Display is Off.*/

		/* - Needs to display dimension only
		   - when the global flag is set.
		*/

		if (!display_invisible_dims)
			return(OM_S_SUCCESS);
		else
		{
			/* Can only be displayed in
			   half highlight mode */

			DMchgdpmode(&dpmode);
		}
	}

	if (me->display & DIM_IS_DIFFERENT)
	{
		/*|- Dimension is different */
		if ((display_different_dims) && (dpmode != GRbe))
		{
			/*|- should be displayed in half highlight */
			DMchgdpmode(&dpmode);
		}
	}

	status =
	ex$get_cur_mod(id = &md_env.md_id.objid,
		osnum = &md_env.md_id.osnum);
	dm$status();

	if (frm_glob.dim_mode == MODELING_MODE)
	{
		/*| - Modeling Mode - do not display imported dim */

		if(me->geom_type & DIM_IMPORTED)
			return(OM_S_SUCCESS);
	}
	else
	{
		if ((md_env.md_id.osnum != OM_Gw_current_OS)
		||  (*mx_type != MAIDMX))
		{
			/* - Dimension is in reference file.
			   - Needs to display dimension only
			   - when global flag is set. Imported
			   - dimensions in reference files should
			   - never be displayed.
			*/
			/*|-Detailing Mode - different OS */

			if (((!display_ref_diff_dims)
			&&   (!display_reffile_dims))
			||   (me->geom_type & DIM_IMPORTED))
				return(OM_S_SUCCESS);
			else
			{
				IGRboolean imported;

				/*|- Checking for display */

				status =
				DMdim_imported(my_id, OM_Gw_current_OS, &impdim, &context, &imported);
				dm$status();

				if ((imported) &&
				(!display_ref_diff_dims))
				{
					/*|- Dimension imported into master file -*/
					return(OM_S_SUCCESS);
				}

				/* Can only be displayed in
				   half highlight mode */

				DMchgdpmode(&dpmode);
			}
		}
		else
		{
			/*- Hidden dimension in master file should
			    be displayed only when
			    "display_invisible_dims" flag is on
			*/

			if (me->display & DIM_DISPLAY_OFF)
			{
				if (!display_invisible_dims)
				   return(OM_S_SUCCESS);
			}
		}
	}

	/*| - Fill environment info - */

	md_env.md_env.matrix_type = *mx_type;
	memcpy(md_env.md_env.matrix, matrix, sizeof(IGRmatrix));

	/*| - Get View Orientation - */

	gragad = (struct DPgra_gad *)sp_info->gragad;
	dp_rotation = (IGRdouble *)gragad->rotation;

	/*| - Check display status */

	if (txt_check)
	{
		status =
		DMget_normal(
			&rc,
			my_id,
			OM_Gw_current_OS,
			me->dim_type,
			&txt_length,
			dm_norm,
			lbsys_mat,
			text_mat,
			&md_env);
		dm$status();
		if (!(status & 1)) txt_check = FALSE;

		status =
		DMcheck_normal(
			&rc,
			frm_glob.disp_type,
			frm_glob.view_angle,
			dm_norm,
			&dp_rotation[8]);
		dm$status();
		if (!(status & 1)) txt_check = FALSE;

	        /*** Fix for TR 119312332. In boundary conditions text 
		     reversal does not work properly, So to avoid this 
		     problem text reversal not being effected on 
		     dimensions within a box **/

	        if( me->comp_mask & (1<< DIM_BOX) )
		  txt_check = FALSE;

		if (!(rc & 1)) return(OM_S_SUCCESS);
	}

	/*| Checking Display Mode */

	if (dpmode != GRbe)
	{
		if ((frm_glob.dim_mode == MODELING_MODE)
		||  (me->geom_type & DIM_DETACHED))
		{
			/* - For modeling mode and detached
			     dimensions use the corresponding
			     global color for display - */

			if (!alt_symb)
			{
				alt_symb = &new_symb;
				new_symb.color = NULL;
				new_symb.weight = NULL;
				new_symb.style = NULL;
				new_symb.rgb_value = NULL;
			}

                        /* - Set a flag to indicate that the input alternate
                             symbology color was disturbed; using p_old_color
                             is no good if alt_symb_color was originally NULL.
                             TR119303891 - */

        	        p_old_color = alt_symb->color;
			alt_symb->color = &color;
                        alt_color_disturbed = TRUE;
			if (me->geom_type & DIM_DETACHED)
				color = frm_glob.detached_color;
			else	color = (me->geom_type & DIM_DRIVING)?
					frm_glob.driving_color:
					frm_glob.driven_color;
		}
	}

	if (!(me->display & DIM_COMP_NOT_IN_RTREE))
	{
		/* pre 2.0 dimension components must be removed
		   from RTREE and dimension must be added in the
		   RTREE. This needs to be done for the first
		   time dimension gets a display.
		*/

		if (me->comp_mask)
		{
			status =
			om$send(msg = message GRvg.GRremwrng(
						&long_rc,
						&md_env),
				senderid = my_id,
				from = 0,
				to = OM_K_MAXINT,
				p_chanselect = &AS_to_comp);
			/*"GRremwrng : status = %d\n", status*/
			if (status & long_rc & 1)
			{
				status =
				om$send(msg = message GRvg.GRaddwrng(
						&long_rc,
						&md_env),
					targetid = my_id);
				/*"GRaddwrng : status = %d\n", status*/
			}
		}
		me->display |= DIM_COMP_NOT_IN_RTREE;
	}

	/*| Sending GRdisyourself message */

	for (i=0; i<2; i++)
	{
		if (i
		&& (!((1 << me->dim_type)& CENTER_LINE_MASK))
		&& (!((1 << me->dim_type)& LEADER_LINE_MASK))
		&& (!((1 << me->dim_type)& WELD_MASK))
		&& (!(me->dim_type == SURF))
		&& txt_check)
		{
			/*|- Check text orientation*/

			offset = 2 * par_env.txt_heig * par_env.txt_yoff_r;

			status =
			DMget_text_rotation_matrix(
				dp_rotation,
				lbsys_mat,
				text_mat,
				offset,
				txt_length,
				my_id,
				OM_Gw_current_OS,
                	        mx_type,
				matrix,
                       		&new_type,
				new_env);
			dm$status();
		}
		else
		{
			/*|- No need to check text orientation*/
			new_type = *mx_type;
			memcpy(new_env, matrix, sizeof(IGRmatrix));
		}


		if (i && (me->geom_type & DIM_IMPLICIT)
	              && (frm_glob.dim_mode == MODELING_MODE)) 
			color = frm_glob.driven_color;
                /* Set the new matrix for the display lists */

                DPdlist_enter_reference_file( sp_info,
                                              &new_type,
                                              new_env);
		
		status =
		om$send(msg = message GRgraphics.GRdisyourself(
					msg,
					&new_type,
					new_env,
					&dpmode,
					alt_symb,
					sp_info,
					range_key),
			from = (i)?0:1,
			to = (i)?0:OM_K_MAXINT,
			p_chanselect = &AS_to_comp,
			senderid = my_id);
		dm$status();
                DPdlist_exit_reference_file( sp_info,
                                             mx_type,
                                             matrix);
	}

	GR_NOTIFY_LISTENERS(msg, &long_rc, GR_DISPLAYED);

	if (alt_color_disturbed) alt_symb->color = p_old_color;

	Disp_count++;	
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

method GRlocate(
	struct GRlc_cvl *cvl; 
	OM_p_KEY_DESC range_key)
{
	IGRint status, rc, index;
	enum GRlocate_types loc_type;
	struct GRid module, impdim, context;
	IGRdouble dm_norm[3], vw_norm[3], txt_length;
	BSrc bs_rc;
	
	loc_type = cvl->attributes.type;
	if (loc_type != GR_bl_loc
	&&  loc_type != GR_rp_loc
	&&  loc_type != GR_cv_loc)
	{
		/*"locate_type=%d\n", cvl->attributes.type*/

		status =
		om$send(msg = message GRgraphics.GRlocate(cvl, range_key),
			senderid = my_id,
			p_chanselect = &AS_to_comp);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	if (me->display & DIM_DISPLAY_OFF)
	{
		/* - Dimension Locate is Off.
		   - Needs to locate dimension only
		   - when the global flag is set.
		*/
		if ((!display_invisible_dims) && (!display_reffile_dims))
		   return(OM_S_SUCCESS);
	}

	/* - Get active module environment - */

	status =
	ex$get_cur_mod(id = &module.objid,
		osnum = &module.osnum);
	dm$status(action = RET_STATUS);

	if (frm_glob.dim_mode == MODELING_MODE)
	{
		/*| - Modeling Mode - do not locate imported dim */

		if(me->geom_type & DIM_IMPORTED)
			return(OM_S_SUCCESS);
	}
	else
	{
		if ((module.osnum != OM_Gw_current_OS)
		||  (cvl->module.md_env.matrix_type != MAIDMX))
		{
			IGRboolean imported;
	
			/* - Dimension is in reference file.
			   - Needs to locate dimension only
			   - when global flag is set. Imported
			   - dimensions in reference files are
			   - never locatable.
			*/

			if ((!display_reffile_dims)
			||  (me->geom_type & DIM_IMPORTED))
				return(OM_S_SUCCESS);

			status =
			DMdim_imported(my_id, OM_Gw_current_OS, &impdim, &context, &imported);
			dm$status(action = RET_STATUS);

			if (imported)
			{
				/*|- Dimension imported into master file -*/
				return(OM_S_SUCCESS);
			}
		}
		else
		{
			/*- Hidden dimension in master file should
			    be displayed only when
			    "display_invisible_dims" flag is on
			*/

			if (me->display & DIM_DISPLAY_OFF)
			{
				if (!display_invisible_dims)
				   return(OM_S_SUCCESS);
			}
		}
	}

	/*|- boreline locate */

	if (loc_type == GR_bl_loc)
	{
		for (index = 0; index < 3; index++)
		{
			vw_norm[index] =
			cvl->attributes.acc_line.point2[index] -
			cvl->attributes.acc_line.point1[index];
		}
	}
	else if (loc_type == GR_rp_loc)
	{
		IGRdouble *matrix;

		matrix = cvl->attributes.acc_rt_prism.matrix;
		vw_norm[0] = matrix[2];
		vw_norm[1] = matrix[6];
		vw_norm[2] = matrix[10];

		/*^ print_matrix("matrix", matrix); */
	}
	else if (loc_type == GR_cv_loc)
	{
		IGRdouble *matrix;
	
		matrix = cvl->attributes.acc_cv_prism.matrix;
		vw_norm[0] = matrix[2];
		vw_norm[1] = matrix[6];
		vw_norm[2] = matrix[10];

		/*^ print_matrix("matrix", matrix); */
	}

	BSnorvec(&bs_rc, vw_norm);

	status =
	DMget_normal(
		&rc,
		my_id,
		OM_Gw_current_OS,
		me->dim_type,
		&txt_length,
		dm_norm,
		NULL,
		NULL,
		&cvl->module);
	dm$status(action = RET_STATUS);

	status =
	DMcheck_normal(
		&rc,
		frm_glob.disp_type,
		frm_glob.view_angle,
		dm_norm,
		vw_norm);
	dm$status(action = RET_STATUS);

	if (!(rc & 1)) return(OM_S_SUCCESS);

	/*| - send GRlocate to components */

	status =
	om$send(msg = message GRgraphics.GRlocate(cvl, range_key),
		senderid = my_id,
		p_chanselect = &AS_to_comp);
	dm$status(action = RET_STATUS);

	return(status);
}

method GRgetrang(
	IGRlong *msg; 
	IGRshort *matrix_type; 
	IGRmatrix matrix; 
	IGRboolean *world; 
	GRrange range)
{
	IGRint status, index, count = 0, i;
	BSrc bs_rc;
	IGRlong num_pts;
	IGRdouble max[3], min[3], range_c[6]; 
	IGRdouble points[MAX_COMP_INDEX][6];

	status =
	om$get_channel_count(
		objid = my_id,
		p_chanselect = &AS_to_comp,
		count = (OMuint *) &count);
	dm$status(action = RET_STATUS);

	/*^ printf("component no = %d\n", count); */

	for(index = 0; index < count; index++)
	{
		status =
		om$send(msg = message GRgraphics.GRgetrang(
						msg,
						matrix_type,
						matrix,
						world,
						range_c),
			senderid = my_id,
			from = index,
			to = index,
			p_chanselect = &AS_to_comp);
		dm$status(action = RET_STATUS);

		/*^ print_line("range_c",range_c); */

		for(i=0; i<6; i++)
		{
			points[index][i] = range_c[i];
		}
	}

	num_pts = count * 2;

	status =
	BSbx2(&bs_rc, &num_pts, points, NULL, min, max);
	dm$status(action = RET_STATUS);

	for(i=0; i<3; i++)
	{
		range[i] = min[i];
		range[i+3] = max[i];
	}

	/*^ print_line("range",range); */

	return(OM_S_SUCCESS);
}

method GRaddwrng(
	IGRlong *msg; 
	struct GRmd_env *md_info)
{
	IGRint status;

	if (me->comp_mask)
	{
		status =
		om$send(msg = message  GRvg.GRaddwrng(msg, md_info),
			mode = OM_e_wrt_message,
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method GRremwrng(
	IGRlong *msg; 
	struct GRmd_env *md_info)
{
	IGRint status;

	if (me->comp_mask)
	{
		status =
		om$send(msg = message GRvg.GRremwrng(msg, md_info),
			mode = OM_e_wrt_message,
			targetid = my_id);
		/* dm$status(action = RET_STATUS); */
	}

	return(OM_S_SUCCESS);
}

method NDdisplay(
	IGRint dp_type;
	enum GRdpmode mode;
	struct GRmd_env *md_env)
{
	IGRint status;
	IGRlong long_rc;
	enum GRdpmode dpmode;
        IGRboolean    aflag;
        struct GRmd_env display_env;

        gr$get_module_env(buffer = &display_env);
        aflag = pwIsActivationOn();

	dpmode = mode;

        status = om$send(msg = message GRgraphics.GRdisplay(&long_rc,
                                 aflag?&display_env.md_env.matrix_type:
                                       &md_env->md_env.matrix_type,
                                 aflag?display_env.md_env.matrix:
                                       md_env->md_env.matrix,
                                 &dpmode,
                                 aflag?&display_env.md_id:
                                 &md_env->md_id),
                         targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method GRcopy(
	IGRlong *msg;
	struct GRmd_env *obj_dsenv;
	struct GRmd_env *new_dsenv;
	GRobjid *newobjid)
{
	IGRint status, count, index;
	OMuint owner_count = 0;
	IGRchar name[20];
	IGRboolean cell_copy = FALSE, macro_copy = FALSE;
	OM_S_OBJID md_id;
	struct GRmd_env mod_info;
	struct GRid copy, list[MAX_COMP_INDEX], owner_GRid;
	struct GRid go_grid, src_copy, my_grid;
	struct GRid comp_GRid, tmp_copy;
	IGRint i;
	IGRlong long_rc;
	OMuint comp_count = 0;
	OM_S_OBJECT_LINKAGE *copy_list;
	extern GRclassid OPP_DMsrc_class_id, OPP_ACcpx_class_id;
	extern GRclassid OPP_GRgencs_class_id;

	*newobjid = NULL_OBJID;
	mod_info.md_id.objid = NULL_OBJID;
	mod_info.md_id.osnum = obj_dsenv->md_id.osnum;

	/*
		The GRcopy method copies a dimension only on certain
		conditions. They are if the dimension is a detached
		one or if the dimension belongs to a cell. The following
		things done on each case.

		1) If the dimension happens to be a detached, the dimension
		   is copied along with the DMsrc parents of the dimension.
		   Parents other than DMsrc are shared by the copy(or same
		   as original). This done in order to take care of move
		   or dimension modification or independent of each other.
		   (i.e the copy and original no longer depend on each other.

		2) The dimension belongs to a cell. The from/to module
		   the dimension is checked, and if the module is a
		   cell libaray, the dimension is copied and is made to
		   a graphic group. The GRcopy returns this graphic group
		   id. This was a special fix to address the problem
		   of creation/placing of cells with dimension.

                3) If the copy is being issued by the owner who is a macro.
		   The dimension is dependent on its parents for display,
		   modify etc., So the parents are copied along with them.
	*/

        status = om$get_channel_count(
		p_chanselect = &AS_to_owner,
                objid = my_id,
                count = &owner_count);
        if (status && (owner_count == 1))
        {
		status =
		om$get_objid_at_index(
				objid = my_id,
                                objidaddr = &owner_GRid.objid,
                                osnumaddr = &owner_GRid.osnum,
                                p_chanselect = &AS_to_owner,
                                index = 0);
		if (status & 1)
		{
			if (DMancestry_valid(owner_GRid, OPP_ACcpx_class_id))
			   macro_copy = TRUE;
		}
        }

	status = 
	om$send(mode = OM_e_wrt_object,
		msg = message module.mod_info(EX_INQ, NULL, NULL, name, 20),
        	senderid = NULL_OBJID,
		targetid = obj_dsenv->md_id.objid,
		targetos = obj_dsenv->md_id.osnum);
	if (status & 1)
	{
		/*"module name <%s>\n", name*/

		if (!strcmp(name, "cell"))
			cell_copy = TRUE;
	}

	status =
	ex$get_modid(
		mod_osnum = new_dsenv->md_id.osnum,
		mod_id = &md_id);
	if (status & 1)
	{
		status = 
		om$send(mode = OM_e_wrt_object,
			msg = message module.mod_info(EX_INQ, NULL, NULL, name, 20),
	        	senderid = NULL_OBJID,
			targetid = md_id,
			targetos = new_dsenv->md_id.osnum);
		if (status & 1)
		{
			/*"module name <%s>\n", name*/

			if (!strcmp(name, "cell"))
				cell_copy = TRUE;
		}
	}

	if ((me->geom_type & DIM_DETACHED) || cell_copy || macro_copy)
	{
		copy.osnum = new_dsenv->md_id.osnum;

		status =
		om$send(msg = message NDnode.NDcopy(
					msg,
					0,
					obj_dsenv,
					new_dsenv,
					&copy),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (cell_copy)
	{
		/*|- Dimension from cell - convert copy to grahic group*/

		status =
		om$send(msg = message DMroot.GRremwrng(msg, new_dsenv),
			targetid = copy.objid,
			targetos = copy.osnum);
		dm$status(action = RET_SATUS);

		status =
		om$change_class(
			osnum = copy.osnum,
			objid = copy.objid,
			sd_override = OM_K_change_class_sd_override,
			classname = "GRgrgrp");
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message GRgraphics.GRaddwrng(msg, new_dsenv),
			targetid = copy.objid,
			targetos = copy.osnum);
		dm$status(action = RET_SATUS);

		*newobjid = copy.objid;
	}
	else if (me->geom_type & DIM_DETACHED)
	{
	  if( obj_dsenv->md_id.osnum != new_dsenv->md_id.osnum)
	    {
	      OM_S_OBJECT_LINKAGE *list;
	      IGRlong l_count;
	      IGRuint rgb_value;
	      IGRushort d_color;
		  
	      /* copy all graphics */

	      status = om$get_channel_count(object = me,
					    p_chanselect = &AS_to_comp,
					    count = (OMuint *)&l_count);

	      list = (OM_S_OBJECT_LINKAGE *) alloca(l_count *
				 sizeof( OM_S_OBJECT_LINKAGE));

		d_color = frm_glob.detached_color;
	      for ( i = 0; i < l_count; i++)
		{

		  status = 
		  om$send( msg = message GRgraphics.GRcopy(&long_rc,
							   obj_dsenv,
							   new_dsenv,
							   &list[i].S_objid),
			  from = i, to = i,
			  p_chanselect = &AS_to_comp);
		  dm$status(action = RET_STATUS);
		  list[i].osnum = new_dsenv->md_id.osnum;

		  status =		  
		  om$send(msg = message GRvg.GRchgcolor(
					&long_rc,
					&rgb_value,
					&d_color),
			targetid = list[i].S_objid,
			targetos = list[i].osnum);
		  dm$status(action = RET_STATUS);

		}
	      
	      status = DMmake_grgrp( list,&l_count,new_dsenv,&copy);
	      *newobjid = copy.objid;
		
	    }
	  else
	    {

		/*|- Copy the DMsrc object and connect it to copy */

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

		for (index=2; index<count; index++)
		{
			status =
			om$send(msg = message NDnode.ASreturn_go(
						&go_grid,
						&mod_info.md_env.matrix_type,
						mod_info.md_env.matrix),
				targetid = list[index].objid,
				targetos = list[index].osnum);
			if (!(status & 1) 
			|| (go_grid.objid == NULL_OBJID)
			|| (!DMancestry_valid(go_grid, OPP_DMsrc_class_id)))
				continue;

			/*|- Source Object copy it */

			src_copy.osnum = new_dsenv->md_id.osnum;

			status =
			om$send(msg = message NDnode.NDcopy(
							msg,
							0,
							&mod_info,
							new_dsenv,
							&src_copy),
				targetid = go_grid.objid,
				targetos = go_grid.osnum);
			dm$status(action = RET_STATUS);

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
			targetid = copy.objid,
			targetos = copy.osnum);
		dm$status(action = RET_STATUS);

		*newobjid = copy.objid;
	      }
	}
        else if (macro_copy)
	{
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

			/*|- Copy the parents along with them */

			src_copy.osnum = new_dsenv->md_id.osnum;

			if (DMancestry_valid(go_grid, OPP_GRgencs_class_id))
			{
			        status =
				om$send(msg = message NDnode.NDcopy_to_root(
								msg,
								0,
								obj_dsenv,
								new_dsenv,
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
							new_dsenv,
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
			targetid = copy.objid,
			targetos = copy.osnum);
		dm$status(action = RET_STATUS);

		status =
	        om$send(msg = message DMroot.set_geom_type(BIT_SET, 0, NULL),
			targetid = copy.objid,
			targetos = copy.osnum);
	        dm$status(action = RET_STATUS);

		*newobjid = copy.objid;
	}

/* CR#11912703 */
	else
	{
        	status = om$get_channel_count(
			p_chanselect = &AS_to_comp,
               	 	objid = my_id,
                	count = &comp_count);
        	if (status && comp_count)
        	{
			copy_list = (OM_S_OBJECT_LINKAGE *) om$malloc(size = 
				sizeof(OM_S_OBJECT_LINKAGE) * comp_count);

			tmp_copy.osnum = new_dsenv->md_id.osnum;
			for ( i=0; i< comp_count; i++)
			{
				status =
				om$get_objid_at_index(
					objid = my_id,
                               	 	objidaddr = &comp_GRid.objid,
                                	osnumaddr = &comp_GRid.osnum,
                                	p_chanselect = &AS_to_comp,
                                	index = i);

				tmp_copy.objid = NULL_OBJID;
				status =
				om$send(msg = message GRgraphics.GRcopy(
							msg,
							obj_dsenv,
							new_dsenv,
							&tmp_copy.objid),
					targetid = comp_GRid.objid,
					targetos = comp_GRid.osnum);
				dm$status(action = RET_STATUS);

				if (tmp_copy.objid != NULL_OBJID)
				{
					copy_list[i].S_objid = tmp_copy.objid;
					copy_list[i].osnum = tmp_copy.osnum;
				}
			}

			status = DMmake_grgrp ( 
				copy_list,
				(IGRint *) &comp_count,
				new_dsenv,
				&copy);

			if ( status & 1 ) *newobjid = copy.objid;
			if ( copy_list ) om$dealloc ( ptr=copy_list );
		}
	}
/* end of fix */
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

method GRchgcolor(
	IGRlong *msg;
	IGRuint  *rgb_value;
	IGRushort  *color)
{
	IGRint status;
	IGRlong long_rc;

	if (!me->dim_state)
	{
		struct DMenv_param par_env;

		/*| Get environment */

		status =
		dm$get_dim_param(
			type = DM_ENV_PARAM,
			dim_objid = my_id,
			dim_osnum = OM_Gw_current_OS,
			p_data = (char *) &par_env);
		dm$status(action = RET_STATUS);

		par_env.dim_colr  = *color;

		/*| Set dim to state EDIT */

		status =
		om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_IN_EDIT),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*| Put environment */

		status =
		dm$put_dim_param(
			type = DM_ENV_PARAM,
			dim_objid = my_id,
			dim_osnum = OM_Gw_current_OS,
			p_data = (char *) &par_env);
		dm$status(action = RET_STATUS);

		/*| Clear EDIT state */

		status =
		om$send(msg = message DMroot.set_dim_state(BIT_XOR, DIM_IN_EDIT),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	/*| Send Message with respect to ASnode */

	status =
	om$send(msg = message ASnode.GRchgcolor(
					msg,
					rgb_value,
					color),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	GR_NOTIFY_LISTENERS(msg, &long_rc, GR_ATTR_MODIFIED);

	return(OM_S_SUCCESS);
}

method GRchglevel(
	IGRlong *msg;
	IGRshort *level)
{
	IGRint status;
	IGRlong long_rc;

	if (!me->dim_state)
	{
		struct DMenv_param par_env;

		/*| Get environment */

		status =
		dm$get_dim_param(
			type = DM_ENV_PARAM,
			dim_objid = my_id,
			dim_osnum = OM_Gw_current_OS,
			p_data = (char *) &par_env);
		dm$status(action = RET_STATUS);

		par_env.dim_layr  = *level;

		/*| Set dim to state EDIT */

		status =
		om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_IN_EDIT),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*| Put environment */

		status =
		dm$put_dim_param(
			type = DM_ENV_PARAM,
			dim_objid = my_id,
			dim_osnum = OM_Gw_current_OS,
			p_data = (char *) &par_env);
		dm$status(action = RET_STATUS);

		/*| Clear EDIT state */

		status =
		om$send(msg = message DMroot.set_dim_state(BIT_XOR, DIM_IN_EDIT),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	/*| Send Message with respect to ASnode */

	status =
	om$send(msg = message ASnode.GRchglevel(
					msg,
					level),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	GR_NOTIFY_LISTENERS(msg, &long_rc, GR_ATTR_MODIFIED);

	return(OM_S_SUCCESS);
}

method GRchgweight(
	IGRlong *msg;
	IGRuchar  *weight)
{
	IGRint status;
	IGRlong long_rc;

	if (!me->dim_state)
	{
		struct DMenv_param par_env;

		/*| Get environment */

		status =
		dm$get_dim_param(
			type = DM_ENV_PARAM,
			dim_objid = my_id,
			dim_osnum = OM_Gw_current_OS,
			p_data = (char *) &par_env);
		dm$status(action = RET_STATUS);

		par_env.dim_weig  = *weight;

		/*| Set dim to state EDIT */

		status =
		om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_IN_EDIT),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	
		/*| Put environment */

		status =
		dm$put_dim_param(
			type = DM_ENV_PARAM,
			dim_objid = my_id,
			dim_osnum = OM_Gw_current_OS,
			p_data = (char *) &par_env);
		dm$status(action = RET_STATUS);

		/*| Clear EDIT state */

		status =
		om$send(msg = message DMroot.set_dim_state(BIT_XOR, DIM_IN_EDIT),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	/*| Send Message with respect to ASnode */

	status =
	om$send(msg = message ASnode.GRchgweight(
					msg,
					weight),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	GR_NOTIFY_LISTENERS(msg, &long_rc, GR_ATTR_MODIFIED);
	return(OM_S_SUCCESS);
}

method GRgetsymb(
	IGRlong *msg;
	struct GRsymbology *symb)
{
	IGRint status;
	struct DMenv_param par_env;
	IGRshort current_layer;
	IGRboolean invalid_layer;

	invalid_layer = FALSE;

	/*| Get environment */

	status =
	dm$get_dim_param(
		type = DM_ENV_PARAM,
		dim_objid = my_id,
		dim_osnum = OM_Gw_current_OS,
		p_data = (char *) &par_env);
	dm$status(action = RET_STATUS);

	symb->display_attr.color = par_env.dim_colr;
	symb->display_attr.weight = par_env.dim_weig;
	symb->display_attr.style = 0;
	
	current_layer = par_env.dim_layr;
        if(DMvalid_dim_offset_active_layer(par_env.dim_layr))
	{
                DMget_current_dim_layer(par_env.dim_layr, &current_layer, 
					&invalid_layer);
		if (invalid_layer)
			ex$message(msgnumb=DM_E_LyrOutOfRngActLyr);
	}


	symb->level = current_layer;
	
	/* If mode is modelling or dimension is detached set
	   global values */

	if ((frm_glob.dim_mode == MODELING_MODE)
	||  (me->geom_type & DIM_DETACHED))
	{
		if (me->geom_type & DIM_DETACHED)
		   symb->display_attr.color = frm_glob.detached_color;
		else if (me->geom_type & DIM_DRIVING)
		   symb->display_attr.color = frm_glob.driving_color;
		else symb->display_attr.color = frm_glob.driven_color;
	}
	
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

method GRxform(
	IGRlong *msg;
	struct GRmd_env *md_env;
	IGRshort *matrix_type;
	IGRmatrix matrix;
	GRobjid *newobjid)
{
	IGRint status, count, index;
	struct GRid list[MAX_DIM_ROOTS], go_grid;
	struct GRmd_env mod_info;
	GRobjid md_id_save;
	extern GRclassid OPP_DMsrc_class_id;

	if (me->geom_type & DIM_DETACHED)
	{
		/*|- Transform the source objects instance */

		status =
		om$send(msg = message DMroot.DMreturn_roots(
						&count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		for (index=2; index<5; index++)
		{
			status =
			om$send(msg = message NDnode.ASreturn_go(
						&go_grid,
						&mod_info.md_env.matrix_type,
						mod_info.md_env.matrix),
				targetid = list[index].objid,
				targetos = list[index].osnum);
			if (!(status & 1) 
			|| (go_grid.objid == NULL_OBJID)
			|| (!DMancestry_valid(go_grid, OPP_DMsrc_class_id)))
				continue;

			/*|- Source Object pass transform msg */

			status =
			om$send(msg = message GRgraphics.GRxform(
							msg,
							&mod_info,
							matrix_type,
							matrix,
							newobjid),
				targetid = go_grid.objid,
				targetos = go_grid.osnum);
			dm$status(action = RET_STATUS);
		}

		md_id_save = md_env->md_id.objid;
		if (md_id_save != NULL_OBJID)
		{
			status =
			om$send(msg = message  DMroot.GRremwrng(msg, md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
	
			md_env->md_id.objid = NULL_OBJID;
		}

       		status =
		om$send(msg = message DMroot.DMcompute_node(
					msg,
					0,
					count,
					list,
					md_env),
			targetid = my_id);

		if (md_id_save != NULL_OBJID)
		{
			md_env->md_id.objid = md_id_save;

			status =
			om$send(msg = message  GRgraphics.GRaddwrng(msg, md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		*msg = MSSUCC;
		*newobjid = my_id;
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message ASnode.GRxform(
				msg,
				md_env,
				matrix_type,
				matrix,
				newobjid),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	*msg = MSSUCC;
	*newobjid = my_id;
	return(OM_S_SUCCESS);
}

method GRplotyourself(
	IGRlong *msg;
	struct GRmd_env *md_env;
        IGRchar *dgn_buf;
	IGRchar *bs_buf;
	IGRchar *ele_buf;
        IGRint *ele_size;
	IGRint *file_des;
	IGRdouble  *max_overflow;
        struct GRid *window_id;
	IGRdouble *scale_factor)
{
	IGRint status, rc, i;
	IGRlong long_rc;
	struct GRmd_env mod_info;
	IGRmatrix dp_rotation, lbsys_mat, text_mat;
	IGRdouble txt_offset, dm_norm[3], txt_length;
	struct DMenv_param par_env;
        struct var_list list_var[2];
	IGRboolean txt_check = TRUE;
        OMuint count = 0;
        unsigned int rgb_value = 0;
        unsigned short color;
        struct GRsymbology symb;
	short comp_props;


	/*|- Do not plot hidden dimension*/

	txt_check = TRUE;

	if (me->display & DIM_DISPLAY_OFF)
		return(OM_S_SUCCESS);

	/*|- Get the current module id*/

	status =
	ex$get_cur_mod(id = &mod_info.md_id.objid,
		osnum = &mod_info.md_id.osnum);
	dm$status();

	if (frm_glob.dim_mode == MODELING_MODE)
	{
		/*| - Modeling Mode - do not plot imported dim */

		if(me->geom_type & DIM_IMPORTED)
			return(OM_S_SUCCESS);
	}
	else
	{
		/*|-Detailing Mode - Do not plot dim in Reference file.*/

		if ((mod_info.md_id.osnum != OM_Gw_current_OS)
		||  (md_env->md_env.matrix_type != MAIDMX))
			return(OM_S_SUCCESS);
	}

	/*| - Get View Orientation - */

	list_var[0].var = VW_ROT_NO_CON;
        list_var[0].var_ptr = (char *)dp_rotation;
        list_var[0].num_bytes = sizeof (IGRmatrix);
        list_var[0].bytes_returned = (IGRlong *)&long_rc;

        list_var[1].var = END_PARAM;
        list_var[1].var_ptr = NULL;
        list_var[1].num_bytes = 0;
        list_var[1].bytes_returned = NULL;

        status =
        dp$inq_set_gragad (msg = msg,
                          osnum = window_id->osnum,
                          gragad_objid = window_id->objid,
                          which_error = &long_rc,
                          var_list = list_var);
        dm$status();

	status=
	dm$get_dim_param(
       		type= DM_ENV_PARAM,
		dim_objid = my_id,
	        dim_osnum = OM_Gw_current_OS,
        	p_data = (char *) &par_env);
     	dm$status();
	if (!(status & 1)) txt_check = FALSE;

	/*| - Check display status */

	if (txt_check)
	{
		status =
		DMget_normal(
			&rc,
			my_id,
			OM_Gw_current_OS,
			me->dim_type,
			&txt_length,
			dm_norm,
			lbsys_mat,
			text_mat,
			md_env);
		dm$status();
		if (!(status & 1)) txt_check = FALSE;

		status =
		DMcheck_normal(
			&rc,
			frm_glob.disp_type,
			frm_glob.view_angle,
			dm_norm,
			&dp_rotation[8]);
		dm$status();
		if (!(status & 1)) txt_check = FALSE;

		if (!(rc & 1)) return(OM_S_SUCCESS);
	}

        /* 
            Pass the module id info sent in here along to the components;
            otherwise it will be incorect when plotting reference file
            elements (TR11926001 - MRMathis)
        */

        mod_info.md_id = md_env->md_id;

        // In order to plot with the proper color, each element that comprises
        // the dimension must be changed to reflect the color defined for that
        // type of dimension.  Therefore, get a channel count and loop through
        // it processing each element individually.  (TR11924981 - MRMathis)

        status = om$get_channel_count(objid = my_id,
                                      p_chanselect = &AS_to_comp,
                                      count = &count);
        dm$status();


	/*| Sending GRplotyourself message */

	for (i = 0; i < count; i++)
	{
		if ((i == 0)
                    && (!((1 << me->dim_type)& CENTER_LINE_MASK))
                    && (!((1 << me->dim_type)& LEADER_LINE_MASK))
                    && (!((1 << me->dim_type)& WELD_MASK))
                    && (!(me->dim_type == SURF))
                    && txt_check)
		{
			/*|- Check text orientation*/

			txt_offset = 2 * par_env.txt_heig * par_env.txt_yoff_r;

			status =
			DMget_text_rotation_matrix(
				dp_rotation,
				lbsys_mat,
				text_mat,
				txt_offset,
				txt_length,
				my_id,
				OM_Gw_current_OS,
                	        &md_env->md_env.matrix_type,
				md_env->md_env.matrix,
                       		&mod_info.md_env.matrix_type,
				mod_info.md_env.matrix);
			dm$status();
		}
		else
		{
			/*|- No correction needed for text orientation*/

			mod_info.md_env.matrix_type =
			md_env->md_env.matrix_type;
			memcpy(mod_info.md_env.matrix,
			md_env->md_env.matrix, sizeof(IGRmatrix));
		}

                /* CHECK IF THE COMPONENT DISIPLAY BIT IS OFF */
  
                status = om$send( msg = message GRgraphics.GRgetprops( 
                                                             msg,
                                                             &comp_props),
                                 from = i,
                                 to   = i,
                                 p_chanselect = &AS_to_comp);
                dm$status()
                 
                if(!(comp_props & GRIS_DISPLAYABLE))
                  continue;

                
		if ((frm_glob.dim_mode == MODELING_MODE)
                    || (me->geom_type & DIM_DETACHED))
		{
                    // For modeling mode and detached dimensions use the
                    // corresponding global color for display - store the
                    // original symbology for restoration after the object has
                    // been plotted.
                    
                    status = om$send(msg = message GRvg.GRgetsymb(msg, &symb),
                                     from = i,
                                     to = i,
                                     p_chanselect = &AS_to_comp);
                    dm$status();

                    if (me->geom_type & DIM_DETACHED)
                        color = frm_glob.detached_color;
                    else
                        color = (me->geom_type & DIM_DRIVING) ?
                            frm_glob.driving_color: frm_glob.driven_color;

                    status = om$send(msg = message GRvg.GRchgcolor(msg,
                                                                   &rgb_value,
                                                                   &color),
                                     from = i,
                                     to = i,
                                     p_chanselect = &AS_to_comp);
                    dm$status();
		}


		status =
		om$send(msg = message GRgraphics.GRplotyourself(
					msg,
					&mod_info,
					dgn_buf,
					bs_buf,
					ele_buf,
					ele_size,
					file_des,
					max_overflow,
					window_id,
					scale_factor),
			from = i,
			to = i,
			p_chanselect = &AS_to_comp,
			senderid = my_id);
		dm$status();

		if ((frm_glob.dim_mode == MODELING_MODE)
                    || (me->geom_type & DIM_DETACHED))
		{
                    // Restore the original color
                    status = om$send(msg = message GRvg.GRchgcolor
                                     (msg,
                                      &rgb_value,
                                      &symb.display_attr.color),
                                     from = i,
                                     to = i,
                                     p_chanselect = &AS_to_comp);
                    dm$status();
                }
	}

	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

IGRint DMget_text_rotation_matrix(
	dp_rotation,
	lbsys_matrix,
	text_matrix,
	txt_offset,
        txt_length,
	dim_id,
	dim_os,
	mx_type,
	matrix,
	new_type,
	new_env)
IGRdouble  *dp_rotation;
IGRdouble  *lbsys_matrix;
IGRdouble  *text_matrix;
IGRdouble  txt_offset;
IGRdouble  txt_length;
OM_S_OBJID  dim_id;
OMuword  dim_os;
IGRshort  *mx_type;
IGRdouble  *matrix;
IGRshort  *new_type;
IGRdouble  *new_env;
/*.DMget_text_rotation_matrix*/
{
	IGRmatrix         inv_matrix;
	IGRdouble         *vw_xvec, *vw_yvec, *vw_zvec;
	IGRint            status, rc, i, opindex;
	BSrc 		  bs_rc;
	IGRshort          four;
	IGRlong           long_rc;
	IGRdouble         txt_xvec[3], txt_yvec[3], txt_zvec[3];
	IGRdouble         dotx, dotyx, dotxy;
	IGRdouble         cross_vwz_txtx[3], text_pt[3];
	struct DMloc_param par_loc;

	vw_xvec = &dp_rotation[0];
	vw_yvec = &dp_rotation[4];
	vw_zvec = &dp_rotation[8];

	/* Purify fix - for annotations text position is not set */
        par_loc.txt_posn = -1;

	status=
	dm$get_dim_param(
		type= DM_LOC_PARAM,
		dim_objid = dim_id,
		dim_osnum = dim_os,
		p_data = (char *) &par_loc);
	dm$status(action = RET_STATUS);

	/*^
		print_matrix("vw_matrix",dp_rotation);
		print_matrix("env_matrix",matrix);
		print_matrix("lbsys",lbsys_matrix);
		print_matrix("text_matrix",text_matrix);
	*/

	for (i = 0; i < 3; i++)
	{
		txt_xvec[i] = text_matrix[i*4];
		txt_yvec[i] = text_matrix[i*4+1];
		txt_zvec[i] = text_matrix[i*4+2];
		text_pt[i]  = text_matrix[i*4+3];
	}

	dotx = BSdotp (&bs_rc, txt_xvec, vw_xvec);

	/*"dotx=%f\n",dotx */

	if ((dotx > 1e-10) || (dotx < -1e-10))
	{
		BScrossp (&bs_rc, vw_zvec, txt_xvec, cross_vwz_txtx);

		if (BSdotp (&bs_rc, txt_yvec, cross_vwz_txtx) > 0.0)
		{
		       if (dotx > 0.0)
				opindex = 8;/* Do not rot. txt mat. */
		       else	opindex = 3;/* Rotate about Z axis */
		}
		else
		{
			if (dotx > 0.0)
				opindex = 6;/* Rotate about X axis */
			else	opindex = 5;/* Rotate about Y axis */
		}
	} 
	else
	{
		dotxy = BSdotp (&bs_rc, txt_xvec, vw_yvec);
		dotyx = BSdotp (&bs_rc, txt_yvec, vw_xvec);

		if (dotxy > 0.0)
		{
			if (dotyx < 0.0)
				opindex = 8;/* Do not rotate */
			else	opindex = 6;/* Rotate about X axis */
		}
		else
		{
			if (dotyx < 0.0)
				opindex = 5;/* Rotate about Y axis */
			else	opindex = 3;/* Rotate about Z axis */
		}
	}

	/*"opindex = %d\n", opindex*/

	if (opindex != 8)
	{
		if (opindex & 1)
		{
			/*|- X opp*/
			math_v_opposite (txt_xvec, txt_xvec);

			if (fabs(txt_length - 0.0) > 0.001)
			{
				/*"txt_length = %f\n", txt_length*/

				MATH_ptdelta(&rc,text_pt,txt_xvec,txt_length,text_pt);
			}
		}

		if (opindex & 2)
		{
			/*|- Y opp*/
			math_v_opposite (txt_yvec, txt_yvec);

			if (par_loc.txt_posn == TXT_POSN_ABOVE)
			{
				/*"txt pt moved in Y dir: offset = %f\n", txt_offset*/
				MATH_ptdelta(&rc,text_pt,txt_yvec,txt_offset,text_pt);
			}
		}

		if (opindex & 4)
		{
			/*|- Z opp*/
			math_v_opposite (txt_zvec, txt_zvec);
		}

		for (i = 0; i < 3; i++)
		{
		       text_matrix[i*4]   = txt_xvec[i];
		       text_matrix[i*4+1] = txt_yvec[i];
		       text_matrix[i*4+2] = txt_zvec[i];
		       text_matrix[i*4+3] = text_pt[i];
		}

		/*^ print_matrix("text_matrix", text_matrix); */

		four=4;
		MAinvmx (&long_rc, &four, lbsys_matrix, inv_matrix);
		MAmulmx (&long_rc, &four, &four, &four, text_matrix, inv_matrix, new_env);
		MAtypemx (&long_rc, new_env, new_type);

		/*^ print_matrix("new_env", new_env); */
	}
	else
	{
		/*|- Not rotation applied*/
		*new_type = *mx_type;
		memcpy(new_env, matrix, 16*sizeof(double));
	}

	return(OM_S_SUCCESS);
}

method GRadd_to_display_list(
   IGRlong *msg;
   IGRboolean is_hidden_line )

{
   int sts;
   unsigned int ele_flags = DP_DLIST_ELE_DISPLAYABLE;

   *msg = MSSUCC;
   sts = OM_S_SUCCESS;

   sts = DPdlist_add_dimension( my_id, OM_Gw_current_OS, ele_flags,
                                1, 0, 1, me->level );
                                
   if ( !(1 & sts) )
   {
     return( OM_E_ERROR );
   }

   return( OM_S_SUCCESS );

} /* GRadd_to_display_list */

end implementation DMroot;
