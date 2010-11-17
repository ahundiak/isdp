/* $Id: groverride.I,v 1.1.2.2 2002/09/10 20:08:28 ramarao Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        isdp/vds/emsfixes/grnuc/groverride.I
 *
 * Description: Override some methods for VDS.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: groverride.I,v $
 *      Revision 1.1.2.2  2002/09/10 20:08:28  ramarao
 *      Fixed TR# 5268.
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR                       DESCRIPTION
 *      09/10/02   Rama Rao 			Fixed TR# 5268.
 *************************************************************************/

class implementation DMroot;

#include "gocmacros.h"
#include "msmacros.h"
#include "DMmsg.h"

extern struct DMglobal_param frm_glob;
extern IGRboolean display_invisible_dims;
extern IGRboolean display_reffile_dims;
extern IGRboolean display_different_dims;
extern IGRboolean display_ref_diff_dims;

from ACncpx	import	ACget_STATE;

static void CheckForVDfrmTxt( GRobjid		objid,
			      GRspacenum	osum,
			      IGRushort		*color  )
{
IGRlong		sts; 
IGRint		state;
IGRchar		clsName[40];

    om$get_classname( objid = objid,
		      osnum = osum,
		      classname = clsName );
    if( strcmp( clsName, "VDfrmtxt" ) )  return;

    sts = om$send( msg = message ACncpx.ACget_STATE( &state ),
		   senderid = objid,
		   p_chanselect = &ND_father,
		   from = 3,
		   to = 3    );
    if( !(state & ncpx_root) )  return;

    *color = 2 ;

}

method GRdisyourself( IGRlong			*msg;
		      IGRshort			*mx_type;
		      IGRmatrix			matrix;
		      enum GRdpmode		*mode;
		      struct IGRaltdisplay	*alt_symb;
		      struct DP_information	*sp_info;
		      OM_p_KEY_DESC		range_key )
{
	IGRint 			status, rc, i;
	OMuint 			parent_count=0;
	struct GRmd_env 	md_env;
	IGRdouble 		*dp_rotation, dm_norm[3], offset, txt_length;
	struct GRid 		impdim, context;
	struct DPgra_gad 	*gragad;
	struct IGRaltdisplay 	new_symb;
	IGRushort 		color, *p_old_color = NULL;
        IGRint 			alt_color_disturbed = FALSE;
	enum GRdpmode 		dpmode; 
	IGRlong 		long_rc;
	IGRshort 		new_type, txt_check;
	IGRmatrix 		new_env, lbsys_mat, text_mat;
	extern IGRint 		Disp_count;
	struct DMenv_param 	par_env;
	IGRshort 		current_layer;
	IGRboolean 		invalid_layer;

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

			CheckForVDfrmTxt( my_id, OM_Gw_current_OS, &color );
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

method GRgetsymb(
	IGRlong *msg;
	struct GRsymbology *symb)
{
	IGRint 			status;
	struct DMenv_param 	par_env;
	IGRshort 		current_layer;
	IGRboolean 		invalid_layer;
	struct GRsymbology 	mySymb;

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

	// symb->level = current_layer;
	
	om$send( msg = message GRvg.GRgetsymb( msg, &mySymb ),
		 p_chanselect = &AS_to_comp );

	symb->level = mySymb.level;


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

	CheckForVDfrmTxt( my_id, OM_Gw_current_OS, &symb->display_attr.color );
	
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

method GRchglevel(
        IGRlong *msg;
        IGRshort *level)
{
    IGRint                  	status;
    IGRlong 			long_rc;
    struct DMenv_param      	par_env;

    status = dm$get_dim_param(
                type = DM_ENV_PARAM,
                dim_objid = my_id,
                dim_osnum = OM_Gw_current_OS,
                p_data = (char *) &par_env);
    dm$status(action = RET_STATUS);

    if( par_env.dim_layr >= DM_ACTIVE_LAYER ) return (OM_S_SUCCESS);

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

   status = om$send( msg = message ASnode.GRchglevel( msg, level ),
                     mode = OM_e_wrt_message,
                     targetid = my_id);
   dm$status(action = RET_STATUS);

   GR_NOTIFY_LISTENERS(msg, &long_rc, GR_ATTR_MODIFIED);

   return(OM_S_SUCCESS);
}

end implementation DMroot;
