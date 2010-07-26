/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:31 $
$Locker:  $
$Log: update.I,v $
Revision 1.1.1.1  2001/12/17 22:39:31  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:09:02  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/05/31  10:09:22  skathiri
# COMMENT : Code changes for the enhanced balloon functionality
#
# Revision 330.0  1996/01/11  21:23:05  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.2  1995/01/09  10:04:02  satya
# COMMENT : Recheck in
#
# Revision 320.1  1995/01/09  09:36:14  satya
# COMMENT : dim cnstr btwn ref file and master file deleted when ref file del/detached
#
# Revision 320.0  1994/12/12  17:52:32  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.6  1994/09/23  11:31:12  gvk
# COMMENT : Cannot use toggle term icon on the form to switch terminators during dynamics.
#
# Revision 240.5  1993/09/27  09:34:08  samuel
# COMMENT : Fix for TR119310615
#
# Revision 240.4  1993/09/20  08:52:45  samuel
# COMMENT : Changes for SGI compilation
#
# Revision 240.3  1993/08/03  05:42:41  laxmi
# COMMENT : Dimensioning 2.4 CR and TR fixes checkin. -Laxmi
#
# Revision 240.2  1993/05/16  11:01:15  gvk
# COMMENT : Fixes for dimension font TRs.
#

*/

class implementation DMroot;

#define AS_DEBUG 1

#include "msdef.h"
#include "msmacros.h"
#include "DMmessages.h"

extern double fabs();

from dim_param import import_param;
from DMdim import get_dim_value;

method set_degrade(struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRlong	msg_loc;
	IGRint index, count;
	IGRchar my_state;

	status = OM_S_SUCCESS;
	if (me->dim_state & GRDELETE_PENDING
	||  md_env->md_id.objid == NULL_OBJID)
	{
		/*^
			printf("GRDELETE_PENDING = %d\n", me->dim_state & GRDELETE_PENDING);
			print_grid("md_id", &md_env->md_id);
		*/

		return(OM_S_SUCCESS);
	}

	if (me->dim_state & DIM_IN_PLACEMENT)
	{
		/*|- Dimension parent deleted in placement delete myself*/

		status =
		om$send(msg = message ASnode.GRdelete((IGRlong *) &rc, md_env),
			mode = OM_e_wrt_message,
			targetid = my_id);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	me->geom_type &= ~DIM_DETACHED;

	status =
	om$get_channel_count(
		objid = my_id,
		osnum = OM_Gw_current_OS,
		p_chanselect = &ND_father,
		count = (OMuint *) &count);
	dm$status(action = RET_STATUS);

	/*^ printf("count = %d\n", count); */

	for (index=0; index<count; index++)
	{
		status =
		om$send(msg = message NDnode.NDget_state(&my_state),
			p_chanselect = &ND_father,
			from = index, to = index,
			senderid = my_id);
		dm$status(action = RET_STATUS);

		if (my_state & ND_DEGRADED)
		{
			/*|- Set Geom Type to Detached*/

			status =
			om$send(msg = message DMroot.set_geom_type(
							BIT_OR,
							DIM_DETACHED,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			/*|- Remove from cpx */

			if ((DMis_complex(me->dim_type))
			&&  (me->dim_type != TEXT_WITH_BALLOON)
			&&  (me->dim_type != COORDINATE))
			{
				status =
				om$send(msg = message DMroot.remove_from_cpx(
							&rc,
							DROP_ACTION,
							md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
                        /* While ref files are detached or deleted the
                           dimension between the reffile element and master
                           file should be deleted  
		           9th Jan 1995. --- TR# 119415564 -- Satya */

                        SKexp_dim_clean(&msg_loc,my_id,OM_Gw_current_OS,md_env);


			break;
		}
	}

	return(OM_S_SUCCESS);
}

method set_dim_state(int flag; IGRchar state)
{

	/*"flag=%d, state=%d\n", flag, state*/

	if (flag == BIT_AND)
		me->dim_state &=state;
	else if (flag == BIT_OR)
		me->dim_state |= state;
	else if (flag == BIT_XOR)
		me->dim_state ^= state;
	else if (flag == BIT_SET)
		me->dim_state = state;
	else if (flag == BIT_CLEAR)
		me->dim_state &= ~state;

	/*"me->dim_state=%d", me->dim_state*/

	return(OM_S_SUCCESS);
}

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
	switch (me->dim_type)
	{
		case STACKED_LINEAR:

		ex$message( msgnumb = DM_I_StkLnDm,
			    buff    = info->type );
		break;

		case STRINGED_LINEAR:

		ex$message( msgnumb = DM_I_StrLnDm,
			    buff    = info->type );
		break;

		case SYMMETRICAL_DIAMETER:

		ex$message( msgnumb = DM_I_SymDiaDm,
			    buff    = info->type );
		break;

		case SINGLE_PARALLEL:

		ex$message( msgnumb = DM_I_SngPrlDm,
			    buff    = info->type );
		break;

		case CIRCULAR_DIAMETER:

		ex$message( msgnumb = DM_I_CirDiaDm,
			    buff    = info->type );
		break;

		case LINEAR_DIAMETER:

		ex$message( msgnumb = DM_I_LinDiaDm,
			    buff    = info->type );
		break;

		case STACKED_ANGULAR:

		ex$message( msgnumb = DM_I_StkAngDm,
			    buff    = info->type );
		break;

		case STRINGED_ANGULAR:

		ex$message( msgnumb = DM_I_StrAngDm,
			    buff    = info->type );
		break;

		case RADIAL:

		ex$message( msgnumb = DM_I_RdlDm,
			    buff    = info->type );
		break;

		case RADIAL_DIAMETER:

		ex$message( msgnumb = DM_I_RdlDiaDm,
			    buff    = info->type );
		break;

		case COORDINATE:

		ex$message( msgnumb = DM_I_CordDm,
			    buff    = info->type );
		break;

		case CENTER_LINE:

		ex$message( msgnumb = DM_I_CenLns,
			    buff    = info->type );
		break;

		case SINGLE_ARC_LENGTH:

		ex$message( msgnumb = DM_I_ArcLenDm,
			    buff    = info->type );
		break;

		case SINGLE_ARC_ANGLE:

		ex$message( msgnumb = DM_I_ArcAngDm,
			    buff    = info->type );
		break;

		case CHAMFER:

		ex$message( msgnumb = DM_I_Chmfr,
			    buff    = info->type );
		break;

		case TEXT_WITH_LEADER:

		ex$message( msgnumb = DM_I_TxtWthLdr,
			    buff    = info->type );
		break;

		case LEADER_LINE:

		ex$message( msgnumb = DM_I_LdrLn,
			    buff    = info->type );
		break;

		case TEXT_WITH_BALLOON:

		ex$message( msgnumb = DM_I_TxtWthBln,
			    buff    = info->type );
		break;

		case FEATURE_CONTROL_FRAME:

		ex$message( msgnumb = DM_I_FtrCntrlFrm,
			    buff    = info->type );
		break;

		case DATUM_FRAME:

		ex$message( msgnumb = DM_I_DtmFrm,
			    buff    = info->type );
		break;

		case WELD:

		ex$message( msgnumb = DM_I_WldSmbl,
			    buff    = info->type );
		break;

		case SURF:

		ex$message( msgnumb = DM_I_SrfTxtSmbl,
			    buff    = info->type );
		break;

		default:

		sprintf(info->type, "Dimension - Unknown type(%d)", me->dim_type);
		break;
	}

	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

method chgdp(
        IGRint *msg;
        struct DMenv_param *par_env)
{
        IGRint status, rc;
        IGRlong long_rc;
        struct IGRdisplay line_display, text_display;
        struct GRid text_grid,my_grid;
        struct GRmd_env md_env;
        IGRshort current_layer;
        IGRint temp_state;
	IGRboolean invalid_layer;

        *msg = DIM_S_SUCCESS;
	invalid_layer = FALSE;

        line_display.color =
        text_display.color = (me->dim_state & DIM_DETACHED)?
                        par_env->det_colr:par_env->dim_colr;

        line_display.weight = par_env->dim_weig;
        text_display.weight = par_env->txt_weig;

        line_display.style =
        text_display.style = 0;

        status =
        om$send(msg = message GRvg.GRchgdp(&long_rc, &line_display),
                targetid = my_id);
        dm$status(action = RET_STATUS);

        /*
         * Need to get the active layer.
         */

        current_layer = par_env->dim_layr;
        if(DMvalid_dim_offset_active_layer(par_env->dim_layr))
	{
                DMget_current_dim_layer(par_env->dim_layr , &current_layer, 
					&invalid_layer);
		if (invalid_layer)
			ex$message(msgnumb=DM_E_LyrOutOfRngActLyr);
	}


        status =
        om$send(msg = message GRvg.GRchglevel(&long_rc, &current_layer),
                targetid = my_id);
        dm$status(action = RET_STATUS);

        status =
        om$send(msg = message DMroot.return_dim_go(
                                &rc,
                                DIM_TEXT,
                                FALSE,
                                DM_TEXT,
                                &md_env,
                                &text_grid),
                targetid = my_id);
        dm$status(action = RET_STATUS)

        if (rc == DIM_S_SUCCESS)
        {
                status =
                om$send(msg = message GRvg.GRchgdp(&long_rc, &text_display),
                        targetid = text_grid.objid,
                        targetos = text_grid.osnum);
                dm$status(action = RET_STATUS);
        }

        status =
        om$send(msg = message DMroot.return_dim_go(
                                &rc,
                                DIM_TEXT2,
                                FALSE,
                                DM_TEXT,
                                &md_env,
                                &text_grid),
                targetid = my_id);
        dm$status(action = RET_STATUS)

        if (text_grid.objid != NULL_OBJID)
        {
                status =
                om$send(msg = message GRvg.GRchgdp(&long_rc, &text_display),
                        targetid = text_grid.objid,
                        targetos = text_grid.osnum);
                dm$status(action = RET_STATUS);
        }

        if(!( me->dim_state & DIM_IN_PLACEMENT))
	  {
          my_grid.objid = my_id;
          my_grid.osnum = OM_Gw_current_OS;
          status = DMupdate_active_layer_info(&long_rc,&my_grid,par_env);
          dm$status(action = RET_STATUS);
        }

        return(OM_S_SUCCESS);
}

method set_geom_type(
	IGRint flag;
	IGRchar type;
	struct GRmd_env *md_env)
{
	IGRint status;
	struct GRid my_grid;
	char before1, after1;
	char before2, after2;

	/*"flag=%d, type=%d\n", flag, type*/

	before1 = me->geom_type & DIM_BY_NAME;
	before2 = me->geom_type & DIM_REFERENCE;

	if (flag == BIT_AND)
		me->geom_type &= type;
	else if (flag == BIT_OR)
		me->geom_type |= type;
	else if (flag == BIT_XOR)
		me->geom_type ^= type;
	else if (flag == BIT_SET)
		me->geom_type = type;
	else if (flag == BIT_CLEAR)
		me->geom_type &= ~type;

	if (me->geom_type & DIM_DETACHED)
		me->geom_type = DIM_DETACHED;
	else if (!(me->geom_type & DIM_DRIVING))
		me->geom_type &= ~(DIM_IMPLICIT | DIM_DIRECTED |
				   DIM_INTERMEDIATE);
	else	me->geom_type &= ~DIM_REFERENCE;

	after1 = me->geom_type & DIM_BY_NAME;
	after2 = me->geom_type & DIM_REFERENCE;

	/*"before1 =%d, after1 =%d\n", before1, after1*/
	/*"before2 =%d, after2 =%d\n", before2, after2*/

	if ((before1 != after1) || (before2 != after2))
		me->dim_state |= DIM_TEXT_NEEDS_UPDATE;

	/*"me->geom_type=%d\n", me->geom_type*/

	if (md_env)
	{
		/*|- Compute */

		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;

		status =
		dm$change_node(
			broadcast = FALSE,
			as_grid = my_grid,
			md_env = md_env);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method set_display_type(int flag; IGRchar display; struct GRmd_env *md_env)
{
	IGRint status;
	IGRchar disp, display0, display1, display2;

	/*"flag=%d, display=%x\n", flag, display*/

	display0 = display1 = display2 = disp = 0;

	display0 = me->display & DIM_DISPLAY_OFF;
	display2 = me->display & DIM_COMP_NOT_IN_RTREE;

	disp = me->display;

	if (flag == BIT_AND)
		disp &= display;
	else if (flag == BIT_OR)
		disp |= display;
	else if (flag == BIT_XOR)
		disp ^= display;
	else if (flag == BIT_SET)
		disp = display;
	else if (flag == BIT_CLEAR)
		disp &= ~display;

	display1 = disp & DIM_DISPLAY_OFF;

	/*"display0=%x, display1=%x\n", display0, display1*/

	if (!display0 && display1 && md_env)
	{
		/*|- erase the dimension */

		status =
		om$send(msg = message NDnode.NDdisplay(
					0,
					GRbe,
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	me->display = disp;

	if (display2)
	me->display |= DIM_COMP_NOT_IN_RTREE;

	if (display0 && !display1 && md_env)
	{
		/*|- display the dimension */

		status =
		om$send(msg = message NDnode.NDdisplay(
					0,
					GRbd,
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	/*"me->display=%x\n", me->display*/
	return(OM_S_SUCCESS);
}

method inq_display_type(IGRchar *type)
{
	*type = me->display;
	return(OM_S_SUCCESS);
}

method inq_geom_type(IGRchar *type)
{
	*type = me->geom_type;
	return(OM_S_SUCCESS);
}

method GLupdate(
	IGRchar g_type, g_mask;
	IGRchar d_type, d_mask;
	IGRboolean compute;
	struct GRmd_env *md_env)
{
	IGRint status;

	if (((me->geom_type & g_mask) != g_type)
	||  ((me->display & d_mask) != d_type))
	{
		if ((g_mask & DIM_DRIVING)
		&& !(g_type & DIM_DRIVING))
		{
			/* - Target dimension are DRIVEN type
			   - DRIVING IMPLICIT may need an update
			*/

			if (!(me->geom_type & DIM_IMPLICIT))
				return(OM_S_SUCCESS);
		}
		else	return(OM_S_SUCCESS);
	}

	/*| - Force an update if directed dimension */

	if ((me->geom_type & DIM_DIRECTED)
	|| (me->geom_type & DIM_INTERMEDIATE)
	|| (me->geom_type & DIM_REFERENCE))
		compute = TRUE;

	if (compute)
	{
		struct GRid my_grid;

		/*|- Compute */

		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;
		dm$change_node(as_grid = my_grid, md_env = md_env);
	}
	else
	{
		if (!d_mask)
		{
			status =
			om$send(msg = message NDnode.NDdisplay(
					0,
					GRbe,
					md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		status =
		om$send(msg = message NDnode.NDdisplay(
					0,
					(d_mask)?GRhhd:GRbd,
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method get_import_info(
	IGRint *msg;
	struct GRid *original;
	struct GRid *impdim;
	struct GRid *context)
{
	IGRint status, rc;
	struct GRid next[2];
	IGRboolean imported, last_in_cpx;

	status =
	DMdim_imported(
		my_id,
		OM_Gw_current_OS,
		impdim,
		context,
		&imported);
	dm$status(action = RET_STATUS);

	if (imported)
	{
		original->objid = my_id;
		original->osnum = OM_Gw_current_OS;

		*msg = DIM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message DMroot.give_next(&rc, &last_in_cpx, next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (last_in_cpx)
	{
		*msg = DIM_I_NOT_IMPORTED;
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = OPPmargs,
		targetid = next[0].objid,
		targetos = next[0].osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method import_dimension(
	IGRint *msg;
	IGRboolean parallel_only;
	IGRmatrix vw_orientation;
	struct GRmd_env *fr_env;
	struct GRmd_env *to_env;
	struct GRid *copy)
{
	IGRint status, rc, count, index;
	IGRdouble angle = 80.;
	IGRdouble dm_norm[3], txt_length;
	struct GRid list[MAX_DIM_ROOTS], parents[MAX_DIM_ROOTS];
	struct GRid my_grid, context, first, first_ref, first_imp, prev;
	IGRboolean imported, first_in_cpx, last_in_cpx;
	extern GRclassid OPP_dim_param_class_id;
	extern IGRint Imp_count, Dim_count;
	struct DMtrak_info trak_info;
	struct GRmd_env mod_info;
	struct GRid next[2];
	struct GRid child_copy, junk_context;

	first_in_cpx = FALSE;

	if (me->dim_type == TEXT_WITH_BALLOON)
	{
		/*|- Text with balloons are imported as group*/

		status =
		om$send(msg = message DMroot.give_previous(&rc, &first_in_cpx, &prev),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (!first_in_cpx)
		{
			status =
			om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			first_ref = prev;

			DMdim_imported(
				first_ref.objid,
				first_ref.osnum,
				&first_imp,
				&context,
				&imported);

			if (!imported)
			{
				status =
				om$send(msg = OPPmargs,
					targetid = first.objid,
					targetos = first.osnum);
				dm$status(action = RET_STATUS);

				return(OM_S_SUCCESS);
			}
		}
	}

	Dim_count++;	

	if (me->display & DIM_LAYER_OFF)
	{
		/*|- Dimension Layer off - cannot retrieve*/
		*msg = DIM_E_IMPORTED;
		return(OM_S_SUCCESS);
	}

	if (me->geom_type & DIM_IMPORTED)
	{
		/* - Imported dimensions in reference
		   - files cannot be imported again - */

		*msg = DIM_E_IMPORTED;
		return(OM_E_ABORT);
	}

	status =
	DMdim_imported(my_id, OM_Gw_current_OS, copy, &junk_context, &imported);
	if (imported)
	{
		/* - This dimension has already been
		     imported into the master file - */

		Imp_count++;
		*msg = DIM_E_IMPORTED;
		return(OM_S_SUCCESS);
	}

	/*| - Find out if any dimension of the group was imported - */

	rc = DIM_S_SUCCESS;

	if (!((me->dim_type == TEXT_WITH_BALLOON) && !first_in_cpx))
	{
		/*| - Get the dimension of this group - */
	
		status =
		om$send(msg = message DMroot.get_first_in_cpx(&rc, &first),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.get_import_info(
					&rc,
					&first_ref,
					&first_imp,
					&context),
			targetid = first.objid,
			targetos = first.osnum);
		dm$status(action = RET_STATUS);
	}


	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	/*^
		print_grid("first_ref", &first_ref);
		print_grid("first_imp", &first_imp);
		print_grid("context", &context);
		printf("rc = %d\n", rc);
	*/

	if (rc != DIM_S_SUCCESS)
	{
		/* - No dimension in the same group has been
		   - imported yet. Check to see if the import
		   - is valid with respect to the view orientation
		   - and dimension plane orientation. - */

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
			fr_env);
		dm$status(action = RET_STATUS);

		status =
		DMcheck_normal(
			&rc,
			parallel_only?DISPLAY_PARALLEL:DISPLAY_ALL,
			angle,
			dm_norm,
			&vw_orientation[8]);
		dm$status(action = RET_STATUS);

		if (!(rc & 1))
		{
			/*| - Import invalid - */
			return(OM_S_SUCCESS);
		}

		if (rc == DIM_I_NONPLANAR)
		{
	           ex$message(msgnumb = DM_I_DimPlaneNotParal);
		}

		/*| - get the context of import - */

		status =
		GRfindcontext(
			&rc,
			&fr_env->md_env.matrix_type,
			fr_env->md_env.matrix,
			&my_grid.osnum,
			&context);
		if (!(status & rc & 1) || context.objid == NULL_OBJID)
		{
			/*|- NO context found -*/
			return(OM_E_ABORT);
		}
	}

	/*| - get the parents of my_id - */

	status =
	om$send(msg = message DMroot.get_absolute_roots(
					&count,
					list,
					&prev),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - import parents into current os - */

	for (index=0; index<count; index++)
	{
		/*^
			printf("list[%d] =",index);
			print_grid("",&list[index]);
		*/

		if (DMancestry_valid(list[index], OPP_dim_param_class_id))
		{
			/*|- Import to ENV & LOC objects */

			status =
			om$send(msg = message dim_param.import_param(
							&rc,
							fr_env,
							to_env,
							&parents[index]),
				targetid = list[index].objid,
				targetos = list[index].osnum);
			dm$status(action = RET_STATUS);
		}
		else
		{
			/*"Make source - %d\n", index*/

			/*^
				print_grid("go_grid", &list[index]);
				print_grid("context_grid", &context);
				printf("as_os=%d\n", to_env->md_id.osnum);
			*/

			status =
			as$make_source(
				go_grid = list[index],
				context_grid = context,
				as_os = to_env->md_id.osnum,
				as_grid = &parents[index]);
			dm$status(action = RET_STATUS);
		}
	}

	/* - Create ACpretendin in the current os - */

	status =
	as$make_source(
		go_grid = my_grid,
		context_grid = context,
		as_os = to_env->md_id.osnum,
		as_grid = &parents[count]);
	dm$status(action = RET_STATUS);

	count++;

	/*^
		printf("context=%d,%d\n", context.objid, context.osnum);
		printf("pretend=%d,%d\n", parents[0].objid, parents[0].osnum);
		printf("count=%d\n", count);
	*/

	/* - Copy the dimension to master object space - */

	status =
	om$send(msg = message NDnode.NDcopy(
				(IGRlong *) &rc,
				NULL,
				fr_env,	
				to_env,
				copy),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - connect the new parents to copy */

	status =
	om$send(msg = message NDnode.NDconnect(
					count,
					parents,
					my_grid,
					ND_NEW),
		targetid = copy->objid,
		targetos = copy->osnum);
	dm$status(action = GOTO_VALUE, value = wrap_up);

	if ((DMis_complex(me->dim_type))
	&& (me->dim_type != TEXT_WITH_BALLOON)
	&& (first_imp.objid == NULL_OBJID))
	{
		status =
		om$send(msg = message DMroot.get_trak_info(&trak_info),
			targetid = first.objid,
			targetos = first.osnum);
		dm$status(action = GOTO_VALUE, value = wrap_up);

		status =
		om$send(msg = message DMroot.set_trak_info(
						REP_TRAK_DIST,
						&trak_info),
			targetid = copy->objid,
			targetos = copy->osnum);
		dm$status(action = GOTO_VALUE, value = wrap_up);
	}

	if (first_imp.objid != NULL_OBJID)
	{
		if (me->dim_type == TEXT_WITH_BALLOON)
		{
			status =
			om$send(msg = message ASnode.NDchange_connect(
						1,
						&parents[2],
						&first_imp),
				mode = OM_e_wrt_message,
				targetid = copy->objid,
				targetos = copy->osnum);
			dm$status(action = GOTO_VALUE, value = wrap_up);
		}
		else
		{
			struct GRid dim_before, dim_after;
			IGRint cpx_type, rel_pos;

			/*| - Add to the complex - */

			status =
			om$send(msg = message DMroot.get_complex_type(&cpx_type),
			targetid = my_id);
			dm$status(action = GOTO_VALUE, value = wrap_up);

			dim_before.objid = dim_after.objid = NULL_OBJID;

			status =
			om$send(msg = message DMroot.find_position_in_cpx(
							&rc,
							cpx_type,
							*copy,
							parents[count - 2],
							to_env,
							&rel_pos,
							&dim_before,
							&dim_after),
				targetid = first_imp.objid,
				targetos = first_imp.osnum);
			dm$status(action = GOTO_VALUE, value = wrap_up);

			status =
			om$send(msg = message DMroot.insert_into_cpx(
							&rc,
							ADJUST_TRAK_DIST,
							to_env,
							rel_pos,
							&dim_before,
							&dim_after),
				targetid = copy->objid,
				targetos = copy->osnum);
			dm$status(action = GOTO_VALUE, value = wrap_up);
		}
	}

	/*|- Set DIM_TEXT_NEEDS_UPDATE Flag */

	status =
	om$send(msg = message DMroot.set_dim_state(
					BIT_OR,
					DIM_TEXT_NEEDS_UPDATE),
		targetid = copy->objid,
		targetos = copy->osnum);
	dm$status(action = GOTO_VALUE, value = wrap_up);

	/*|- Set DIM_IMPORTED Flag */

	status =
	om$send(msg = message DMroot.set_geom_type(
					BIT_SET,
					DIM_IMPORTED,
					NULL),
		targetid = copy->objid,
		targetos = copy->osnum);
	dm$status(action = GOTO_VALUE, value = wrap_up);

	if ((me->dim_type != CENTER_LINE)
	&&  (me->dim_type != LEADER_LINE))
	{
	  DMupdate_text_fonts(me->dim_type, *copy, OM_Gw_current_OS, to_env);
	}

	/*|- clear display instance for imported dim */

	status =
	om$send(msg = message DMroot.set_display_type(
					BIT_SET,
					0,
					NULL),
		targetid = copy->objid,
		targetos = copy->osnum);
	dm$status(action = GOTO_VALUE, value = wrap_up);

	/*| Send a compute to check if everything is fine*/

	count--;

	mod_info = *to_env;
	mod_info.md_id.objid = NULL_OBJID;

	status =
	om$send(msg = message  DMroot.DMcompute_node(
					(IGRlong *) msg,
					0,
					count,
					parents,
					&mod_info),
		targetid = copy->objid,
		targetos = copy->osnum);
	dm$status(action = GOTO_VALUE, value = wrap_up);

	if (me->dim_type == TEXT_WITH_BALLOON)
	{
		status =
		om$send(msg = message DMroot.give_next(&rc, &last_in_cpx, next),
			targetid = my_id);
		dm$status(action = GOTO_VALUE, value = wrap_up);

		if (!last_in_cpx)
		{
			/*|- Import my children*/

			status =
			om$send(msg = message DMroot.import_dimension(
							msg,
							parallel_only,
							vw_orientation,
							fr_env,
							to_env,
							&child_copy),
				targetid = next[0].objid,
				targetos = next[0].osnum);
			dm$status(action = GOTO_VALUE, value = wrap_up);
		}
	}

	status =
	dm$change_node(as_grid = *copy, md_env = to_env);
	dm$status(action = GOTO_VALUE, value = wrap_up);

	Imp_count++;
	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);

	wrap_up:

	/*|- Import failed for some reason*/

	if (copy->objid != NULL_OBJID)
	{	
		/*|- Delete the badly retrived dimension*/

		status =
		om$send(msg = message NDnode.NDdelete(to_env),
			targetid = copy->objid,
			targetos = copy->osnum);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method compare_dimension(
	IGRint set0clear1;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRboolean compare;
	struct GRid parent_dim;
	struct GRmd_env mod_info;
	struct DMenv_param my_env, parent_env;
	struct DMloc_param my_loc, parent_loc;
	struct DMmisc_param my_misc, parent_misc;
	IGRdouble my_value, parent_value;

	if (set0clear1)
	{
		/*|- Clear DIM_IS_DIFFERENT BIT if set */

		if ( me->display & DIM_IS_DIFFERENT)
		{
			me->display &= ~DIM_IS_DIFFERENT;

			status =
			om$send(msg = message NDnode.NDdisplay(
						0,
						GRbd,
						md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}
	else
	{
		/*| gather compare info */

		status =
		om$send(msg = message DMroot.get_compare_info(
						&rc,
						&compare,
						&parent_dim,
						&mod_info,
						&my_env,
						&parent_env,
						&my_loc,
						&parent_loc,
						&my_misc,
						&parent_misc),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if(!compare) return(OM_S_SUCCESS);

		/*|- Set Dimension different bit initially */

		me->display |= DIM_IS_DIFFERENT;

		status =
		om$send(msg = message DMdim.get_dim_value(&my_value),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMdim.get_dim_value(&parent_value),
			targetid = parent_dim.objid,
			targetos = parent_dim.osnum);
		dm$status(action = RET_STATUS);

		if (fabs(my_value - parent_value) > 0.0001)
			return(OM_S_SUCCESS);

		if (my_env.dim_stan != parent_env.dim_stan)
			return(OM_S_SUCCESS);

		if (strcmp(my_misc.prefix, parent_misc.prefix) != 0)
			return(OM_S_SUCCESS);

		if (strcmp(my_misc.suffix, parent_misc.suffix) != 0)
			return(OM_S_SUCCESS);
 
		if (strlen(my_misc.dim_override) != 0)
			return(OM_S_SUCCESS);

		if (my_loc.tole_mode != parent_loc.tole_mode)
			return(OM_S_SUCCESS);

		if ((parent_loc.tole_mode == TOLE_MODE_UP_LOW) ||
			(parent_loc.tole_mode == TOLE_MODE_LIMITS))
		{
			if (strcmp((char *)my_loc.primary.tole_up, (char *)parent_loc.primary.tole_up) != 0)
				return(OM_S_SUCCESS);

			if (strcmp((char *)my_loc.primary.tole_low, (char *)parent_loc.primary.tole_low) != 0)
				return(OM_S_SUCCESS);
		}

		if (parent_loc.tole_mode == TOLE_MODE_MIDDLE)
			if (strcmp(my_misc.pri_tole_sym, parent_misc.pri_tole_sym) != 0)
				return(OM_S_SUCCESS);

		if ((1 << me->dim_type) & ANGULAR_MASK)
		{
			/*|- Angular Dimension */

			if (my_env.ang_unit != parent_env.ang_unit)
				return(OM_S_SUCCESS);

			if (my_loc.angular.ang_roff_unit !=
				parent_loc.angular.ang_roff_unit)
				return(OM_S_SUCCESS);
		
			if (my_loc.angular.ang_roff_unit == DECIMAL_MODE)
			{
				if (my_loc.angular.decacc !=
					parent_loc.angular.decacc)
					return(OM_S_SUCCESS);
			}
			else
			{
				if (my_loc.angular.fraacc !=
					parent_loc.angular.fraacc)
					return(OM_S_SUCCESS);
			}
		}
		else
		{
			/*|- Linear Dimensions */

			if (my_env.pri_unit != parent_env.pri_unit)
				return(OM_S_SUCCESS);

			if (my_loc.deci_frac != parent_loc.deci_frac)
				return(OM_S_SUCCESS);
		
			if (my_loc.deci_frac == DECIMAL_MODE)
			{
				if (my_loc.primary.decacc !=
					parent_loc.primary.decacc)
					return(OM_S_SUCCESS);
			}
			else
			{
				if (my_loc.primary.fraacc !=
					parent_loc.primary.fraacc)
					return(OM_S_SUCCESS);
			}
		}

		/*|- Dimension is not different - clear bit */

		me->display &= ~DIM_IS_DIFFERENT;
	}

	return(OM_S_SUCCESS);
}

method get_compare_info(
	IGRint *msg;
	IGRboolean *compare;
	struct GRid *parent_dim;
	struct GRmd_env *md_env;
	struct DMenv_param *my_env, *parent_env;
	struct DMloc_param *my_loc, *parent_loc;
	struct DMmisc_param *my_misc, *parent_misc)
{
	IGRint status, count;
	struct GRid list[MAX_DIM_ROOTS];

	*compare = FALSE;

	if (((1 << me->dim_type) & ANNOTATION_MASK)
	||  ((1 << me->dim_type) & CENTER_LINE_MASK))
	{
		/*|- Dim Not Eligible */

		*msg = DIM_I_NOT_ELIGIBLE;
		return(OM_S_SUCCESS);
	}

	if (!(me->geom_type & DIM_IMPORTED))
	{
		/*|- Dimension Not Imported */

		*msg = DIM_I_NOT_IMPORTED;
		return(OM_S_SUCCESS);
	}

	*compare = TRUE;

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
					parent_dim,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix),
		targetid = list[count-1].objid,
		targetos = list[count-1].osnum);
	dm$status(action = RET_STATUS);

	md_env->md_id.objid = NULL_OBJID;

	/*|- Get my dimension parameters */

	status =
	dm$get_dim_param(
		type = DM_ENV_PARAM,
		dim_objid = my_id,
		dim_osnum = OM_Gw_current_OS,
		p_data = (char *)my_env);
	dm$status(action = RET_STATUS);

	status =
	dm$get_dim_param(
		type = DM_LOC_PARAM,
		dim_objid = my_id,
		dim_osnum = OM_Gw_current_OS,
		p_data = (char *)my_loc);
	dm$status(action = RET_STATUS);

	status =
	dm$get_dim_param(
		type = DM_MISC_PARAM,
		dim_objid = my_id,
		dim_osnum = OM_Gw_current_OS,
		p_data = (char *)my_misc);
	dm$status(action = RET_STATUS);

	/*|- Get my parent dimension parameters */

	status =
	dm$get_dim_param(
		type = DM_ENV_PARAM,
		dim_objid = parent_dim->objid,
		dim_osnum = parent_dim->osnum,
		p_data = (char *)parent_env);
	dm$status(action = RET_STATUS);

	status =
	dm$get_dim_param(
		type = DM_LOC_PARAM,
		dim_objid = parent_dim->objid,
		dim_osnum = parent_dim->osnum,
		p_data = (char *)parent_loc);
	dm$status(action = RET_STATUS);

	status =
	dm$get_dim_param(
		type = DM_MISC_PARAM,
		dim_objid = parent_dim->objid,
		dim_osnum = parent_dim->osnum,
		p_data = (char *)parent_misc);
	dm$status(action = RET_STATUS);

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method display_update(
	IGRchar g_type, g_mask;
	IGRchar d_type, d_mask;
	IGRboolean erase;
	IGRboolean display;
	IGRboolean parallel_only;
	enum GRdpmode mode;
	IGRmatrix vw_orientation;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRdouble angle = 80., dm_norm[3], txt_length;
	extern IGRint Dim_count;

	Dim_count++;

	if ((me->geom_type & g_mask) != g_type)
		return(OM_S_SUCCESS);

	if ((me->display & d_mask) != d_type)
		return(OM_S_SUCCESS);

	if (vw_orientation)
	{
		/*|- View Orientation Matrix Supplied */

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
			md_env);
		dm$status(action = RET_STATUS);

		status =
		DMcheck_normal(
			&rc,
			(parallel_only)?DISPLAY_PARALLEL:DISPLAY_ALL,
			angle,
			dm_norm,
			&vw_orientation[8]);
		dm$status(action = RET_STATUS);

		if (!(rc & 1))
		{
			/*| - Dimension View Not Parallel */
			return(OM_S_SUCCESS);
		}
	}	

	if (erase)
	{
		status =
		om$send(msg = message NDnode.NDdisplay(
					0,
					GRbe,
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (display)
	{
		status =
		om$send(msg = message NDnode.NDdisplay(
					0,
					mode,
					md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

end implementation DMroot;
