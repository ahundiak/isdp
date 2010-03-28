/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:32 $
$Locker:  $
$Log: dmsrc.I,v $
Revision 1.1.1.1  2001/12/17 22:39:32  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:09:44  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:23:50  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:53:14  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.2  1994/11/01  10:12:38  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.1  1993/05/06  10:15:19  laxmi
# COMMENT : DImensioning TR fixes checkin. -Laxmi.
#
# Revision 220.0  1992/08/29  06:28:16  root
# COMMENT : Corresponds to Rel201.1 in 2.0.1 RCS
#
# Revision 201.1  1992/08/07  15:40:38  grnuc20
# COMMENT : ANSI C conversion fixes
#
# Revision 201.0  1992/07/19  15:33:27  gvk
# COMMENT : ANSI compilation and deleting obsolete functions.
#
*/

class implementation DMroot;

#define AS_DEBUG 1

#include "OMminimum.h"
#include "OMtypes.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"

from dim_src import DMgive_structure;

IGRint DMsrc_give_structure(msg, index, type, imported, inq0set1, src_id, dim_id, osnum, md_env, str)
IGRint *msg;
IGRint index;
IGRint type;
IGRboolean imported;
IGRboolean inq0set1;
OM_S_OBJID src_id, dim_id;
OMuword osnum;
struct GRmd_env *md_env;
struct dim_ret_struct *str;
/*.DMsrc_give_structure*/
{
	IGRint status, count, rc;
	struct GRmd_env mod_info;
	struct GRid src_grid, list[MAX_DIM_ROOTS], parent_dim;
	OMuword save_os;
	
	if (imported)
	{
		/*|- imported dim, get src info */

		src_grid.objid = src_id;
		src_grid.osnum = osnum;
	
		parent_dim.objid = dim_id;
		parent_dim.osnum = osnum;

		status =
		DMget_src_info(&rc, index, &src_grid, &parent_dim, &mod_info);
		dm$status(action = RET_STATUS);

		status =
		DMsrc_give_structure(
				msg,
				DIM_NO_INDEX,
				type,
				FALSE,
				inq0set1,
				src_grid.objid,
				parent_dim.objid,
				parent_dim.osnum,
				&mod_info,
				str);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	src_grid.osnum = osnum;

	if (index != DIM_NO_INDEX)
	{
		/*"get object at index = %d\n", index*/

		status =
		om$send(msg = message DMroot.DMreturn_roots(
							&count,
							list),
			senderid = NULL_OBJID,
			targetid = dim_id,
			targetos = osnum);
		dm$status(action = RET_STATUS);

		src_grid.objid = list[index].objid;
	}
	else src_grid.objid = src_id;

	status =
	om$send(msg = message NDnode.ASreturn_go(
				&src_grid,
				&mod_info.md_env.matrix_type,
				mod_info.md_env.matrix),
		senderid = dim_id,
		targetid = src_grid.objid,
		targetos = src_grid.osnum);
	dm$status(action = RET_STATUS);

	save_os = OM_Gw_current_OS;

	/* Note: Modify this as soon as possible */
	om$make_current_os(osnum = osnum );

	if (md_env->md_env.matrix_type != MAIDMX)
		mod_info = *md_env;

	/*"src_grid=%d,%d\n",src_grid.objid,src_grid.osnum*/
	/*"dim_grid=%d,%d\n",dim_id, osnum*/

	status =
	om$send(msg = message dim_src.DMgive_structure(
				msg,
				type,
				inq0set1,
				str,
				&mod_info),
		senderid = dim_id,
		targetid = src_grid.objid,
		targetos = src_grid.osnum);
	dm$status(action = RET_STATUS);

	om$make_current_os(osnum = save_os);
	return(OM_S_SUCCESS);
}

IGRint DMnode_give_structure(msg, index, type, imported, src_id, dim_id, osnum, md_env, str)
IGRint *msg;
IGRint index;
IGRint type;
IGRboolean imported;
OM_S_OBJID src_id, dim_id;
OMuword osnum;
struct GRmd_env *md_env;
struct ret_struct *str;
/*.DMnode_give_structure*/
{
	IGRint status, rc, count;
	IGRdouble *line;
	struct GRmd_env mod_info;
	struct dim_ret_struct dmstr;
	struct GRid src_grid, list[MAX_DIM_ROOTS], parent_dim;
	OMuword save_os;
	BSrc bs_rc;

	if (imported)
	{
		/*|- imported dim, get src info */

		src_grid.objid = src_id;
		src_grid.osnum = osnum;
	
		parent_dim.objid = dim_id;
		parent_dim.osnum = osnum;

		status =
		DMget_src_info(&rc, index, &src_grid, &parent_dim, &mod_info);
		dm$status(action = RET_STATUS);

		/*^ print_grid("parent_dim",&parent_dim);*/

		status =
		DMnode_give_structure(
				msg,
				DIM_NO_INDEX,
				type,
				FALSE,
				src_grid.objid,
				parent_dim.objid,
				parent_dim.osnum,
				&mod_info,
				str);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	src_grid.osnum = osnum;

	if (index != DIM_NO_INDEX)
	{
		status =
		om$send(msg = message DMroot.DMreturn_roots(
							&count,
							list),
			senderid = NULL_OBJID,
			targetid = dim_id,
			targetos = osnum);
		dm$status(action = RET_STATUS);

		src_grid.objid = list[index].objid;
	}
	else src_grid.objid = src_id;

	status =
	om$send(msg = message NDnode.ASreturn_go(
				&src_grid,
				&mod_info.md_env.matrix_type,
				mod_info.md_env.matrix),
		senderid = dim_id,
		targetid = src_grid.objid,
		targetos = src_grid.osnum);
	dm$status(action = RET_STATUS);

	/* Note: Modify this as soon as possible 
	   no validation is done on the osnum */
	
	save_os = OM_Gw_current_OS;

	/* Note: Modify this as soon as possible */

	om$make_current_os(osnum = osnum );

	if (md_env->md_env.matrix_type != MAIDMX)
		mod_info = *md_env;

	/*"src_grid=%d,%d\n",src_grid.objid,src_grid.osnum*/
	/*"dim_grid=%d,%d\n",dim_id, osnum*/

	status =
	om$send(msg = message dim_src.DMgive_structure(
				msg,
				type,
				FALSE,
				&dmstr,
				&mod_info),
		senderid = dim_id,
		targetid = src_grid.objid,
		targetos = src_grid.osnum);
	dm$status(action = RET_STATUS);

	om$make_current_os(osnum = save_os);

	switch (dmstr.type)
	{
		case DMkeypt:

		str->type = point_generic;
		math_v_equal(str->var.point_st.pt, dmstr.var.dm_keypt.point);
		break;

		case DMtanpt:

		str->type = point_generic;
		math_v_equal(str->var.point_st.pt, dmstr.var.dm_tanpt.point);
		break;

		case DMmidpt:

		str->type = point_generic;
		math_v_equal(str->var.point_st.pt, dmstr.var.dm_midpt.point);
		break;

		case DMintpt:

		str->type = point_generic;
		math_v_equal(str->var.point_st.pt, dmstr.var.dm_intpt.point);
		break;

		case DMcenpt:

		str->type = point_generic;
		math_v_equal(str->var.point_st.pt, dmstr.var.dm_cenpt.point);
		break;

		case DMedgept:

		str->type = point_generic;
		math_v_equal(str->var.point_st.pt, dmstr.var.dm_edgept.point);
		break;

		case DMptdist:

		str->type = line_generic;
		for (index=0; index<3; index++)
		{

			str->var.line_st.p0[index] = dmstr.var.dm_ptdist.point[index]
						- dmstr.var.dm_ptdist.vec[index];
			str->var.line_st.p1[index] = dmstr.var.dm_ptdist.point[index];
			str->var.line_st.v0[index] = dmstr.var.dm_ptdist.vec[index];
		};
		break;

		case DMkeyseg:
		case DMaxis:
		case DM2ptseg:
		case DMedgeseg:

		if (dmstr.type == DMkeyseg)
			line = dmstr.var.dm_keyseg.line;
		else if (dmstr.type == DMaxis)
			line = dmstr.var.dm_axis.line;
		else if (dmstr.type == DMedgeseg)
			line = dmstr.var.dm_edgeseg.line;
		else	line = dmstr.var.dm_2ptseg.line;

		str->type = line_generic;
		for (index=0; index<3; index++)
		{
			str->var.line_st.p0[index] = line[index];
			str->var.line_st.p1[index] = line[index+3];
			str->var.line_st.v0[index] = line[index] - line[index+3];
		};

		BSnorvec(&bs_rc, str->var.line_st.v0);

		break;

		case DMradcen:

		str->type = circle_type;
		math_v_equal(str->var.circle_st.cent_p, dmstr.var.dm_radcen.center);
		str->var.circle_st.rad = dmstr.var.dm_radcen.radius;
		str->var.circle_st.start_angle = 0.0;
		str->var.circle_st.sweep_angle = 2*PI;
		break;

		case DMarc:

		str->type = circle_type;
		math_v_equal(str->var.circle_st.cent_p, dmstr.var.dm_arc.center);
		str->var.circle_st.rad =  BSdistptpt(&bs_rc,
					dmstr.var.dm_arc.center,
					dmstr.var.dm_arc.start_pt);
		str->var.circle_st.start_angle = 0.0;
		str->var.circle_st.sweep_angle = 2*PI;
		break;
	}

	return(OM_S_SUCCESS);
}

IGRint DMget_src_info(
	msg,
	index,
	src_grid,
	dim_grid,
	md_env)
IGRint *msg;
IGRint index;
struct GRid *src_grid, *dim_grid;
struct GRmd_env *md_env;
/*.DMget_src_info*/
{
	IGRint status, my_index;

	my_index = index;
	
	if (index == DIM_NO_INDEX)
	{
		/*|-Src Id given get the index*/

		status =
		DMget_index_object(
			msg,
			TRUE,
			&my_index,
			src_grid,
			dim_grid,
			md_env);
		dm$status(action = RET_STATUS);
	}

	status =
	DMget_index_object(
		msg,
		FALSE,
		&my_index,
		src_grid,
		dim_grid,
		md_env);
	dm$status(action = RET_STATUS);

	return(TRUE);
}

IGRint DMget_index_object(msg, idx0_src1, index, src_grid, dim_grid, md_env)
IGRint *msg;
IGRboolean idx0_src1;
IGRint *index;
struct GRid *src_grid, *dim_grid;
struct GRmd_env *md_env;
/*.DMget_index_object*/
{
	IGRint status, count, i, idx;
	struct GRid list[MAX_DIM_ROOTS];

	/*^ print_grid("dim_grid", dim_grid); */

	status =
	om$send(msg = message DMroot.DMreturn_roots(&count, list),
		senderid = NULL_OBJID,
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	if (idx0_src1)
	{
		/*^ print_grid("src_grid", src_grid); */

		*index = -1;
		for(i=0; i<count; i++)
		if (list[i].objid == src_grid->objid) *index = i;

		if (*index < 0)
		{
			/*|- Error src object not found*/
			*msg = DIM_E_NO_OBJECT;
			return(OM_E_ABORT);
		}

		/*"index = %d\n", *index*/
	}
	else
	{
		if (*index < 0 || *index > count)
		{
			/*"Error in index = %d\n", *index*/
			*msg = DIM_E_GO_INDEX;
			return(OM_E_ABORT);
		}

		*src_grid = list[*index];

		status =
		om$send(msg = message NDnode.ASreturn_go(
						src_grid,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix),
			senderid = NULL_OBJID,
			targetid = list[*index].objid,
			targetos = list[*index].osnum);
		dm$status(action = RET_STATUS);

		if (DMancestry_valid(*src_grid, OPP_DMroot_class_id))
		{
			/*|- Dimension present at given index*/

			*dim_grid = *src_grid;

			DMget_index_object(
				msg,
				FALSE,
				index,
				src_grid,
				dim_grid,
				md_env);
			dm$status(action = RET_STATUS);
		
			return(OM_S_SUCCESS);
		}

		idx = -1;
		for(i=0; i<count; i++)
			if ( (list[i].objid == src_grid->objid)
			|| (list[i].osnum == src_grid->osnum) )
				{ 
					idx = i;
					break;
				}

		if (idx < 0)
		{
			struct GRmd_env mod_info;
			/*|- Find the correct dimension parent*/

			DMget_parents(*dim_grid, MAX_DIM_ROOTS, list, &count);

			status =
			om$send(msg = message NDnode.ASreturn_go(
						dim_grid,
						&mod_info.md_env.matrix_type,
						mod_info.md_env.matrix),
				senderid = NULL_OBJID,
				targetid = list[count -1].objid,
				targetos = list[count -1].osnum);
			dm$status(action = RET_STATUS);

			/*^ print_grid("dim_grid", dim_grid); */
		}

		/*^ print_grid("src_grid", src_grid); */
	}

	*msg = DIM_S_SUCCESS;
	return(TRUE);
}

end implementation DMroot;

