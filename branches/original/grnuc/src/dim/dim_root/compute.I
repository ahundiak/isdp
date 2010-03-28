/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:31 $
$Locker:  $
$Log: compute.I,v $
Revision 1.1.1.1  2001/12/17 22:39:31  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:08:51  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:22:53  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.3  1995/09/27  04:24:29  satya
# COMMENT : Dimension Recompute: Dimension constraints not present in rtree will also be recomputed
#
# Revision 320.2  1995/07/20  14:27:55  gvk
# COMMENT : Do not recompute dimensions which are not in rtree during assoc update
#
# Revision 320.1  1995/03/22  22:30:32  siki
# COMMENT : Changed GRbehe to GRbe during the NDcompute erase
#
# Revision 320.0  1994/12/12  17:52:21  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.4  1993/12/30  05:17:55  gvk
# COMMENT : Add proper include file
#
# Revision 240.3  1993/12/29  14:17:44  gvk
# COMMENT : Notify listeners after recomputing the dimension.
#
# Revision 240.2  1993/12/23  06:08:53  gvk
# COMMENT : Clear the DIM_IN_PLACEMENT bit for dimensions already recomputed.
#
# Revision 240.1  1993/07/15  15:02:44  gvk
# COMMENT : Changes for feature patterning.
#
# Revision 220.0  1992/08/29  06:25:32  root
# COMMENT : Corresponds to Rel201.11 in 2.0.1 RCS
#
Revision 201.11  1992/07/19  16:14:05  poo
COMMENT : Inital Checkin of Jogged Dimension fuctionality.

*/

class implementation DMroot;

#include "gocmacros.h"
#define AS_DEBUG 1

method NDcompute_node(
	IGRlong *msg;
	IGRint cn_type;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env)
{
	IGRint status;
	OM_S_OBJID md_id;

	if (me->geom_type & DIM_IMPORTED)
		count--;

	md_id = md_env->md_id.objid;
	if (md_id != NULL_OBJID)
	{
		status =
		om$send(msg = message  DMroot.GRremwrng((IGRlong *)msg, md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		md_env->md_id.objid = NULL_OBJID;
	}

	/*| - Send a DMcompute_node message */

	status =
	om$send(msg = message  DMroot.DMcompute_node(
					(IGRlong *)msg,
					cn_type,
					count,
					list,
					md_env),
		targetid = my_id);

	/* - No status check here. Cannot return until
	   - dimension is put back into the R-tree
	   - (if necessary).
	*/

	if (md_id != NULL_OBJID)
	{
		md_env->md_id.objid = md_id;

		status =
		om$send(msg = message  GRgraphics.GRaddwrng((IGRlong *)msg, md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if( me->dim_state & DIM_IN_EDIT)
	  me->dim_state &= (~(DIM_IN_PLACEMENT|DIM_IN_EDIT));

	GR_NOTIFY_LISTENERS(msg, &status, GR_GEOM_MODIFIED);

	return(status);
}

method DMreturn_roots(
	IGRint *count;
	struct GRid list[])
{
	IGRint status, i;
	OM_S_OBJECT_LINKAGE slist[MAX_DIM_ROOTS];
	extern GRclassid OPP_dim_src_class_id;
	struct GRid tmp_grid;
	struct GRmd_env mod_info;

	status =
	om$get_channel_objects(
		object = me,
		p_chanselect = &ND_father,
		list = slist,
		size = MAX_DIM_ROOTS,
		count = (OMuint *)count);
	dm$status(action = RET_STATUS);

	if (me->geom_type & DIM_IMPORTED)
		(*count)--;

	for (i=0; i < (*count); i++)
	{
		list[i].objid = slist[i].S_objid;
		list[i].osnum = slist[i].osnum;
	}

	if (me->geom_type & DIM_IMPORTED)
	{
		status =
		om$send(msg = message NDnode.ASreturn_go(
					&tmp_grid,
					&mod_info.md_env.matrix_type,
					mod_info.md_env.matrix),
			targetid = list[0].objid,
			targetos = list[0].osnum);
		dm$status(action = RET_STATUS);
	}
	else	tmp_grid = list[0];

	if (DMancestry_valid(tmp_grid, OPP_dim_src_class_id))
	{
		for(i=*count; i<5; i++)
		{
			list[i].objid = list[0].objid;
			list[i].osnum = list[0].osnum;
			(*count)++;
		}
	}

	if( *count < 5 && me->dim_type == STACKED_ANGULAR)
	{
		for(i=*count; i<5; i++)
		{
			list[i].objid = list[3].objid;
			list[i].osnum = list[3].osnum;
			(*count)++;
		}
	}

	/*^
		printf("count = %d\n", *count);
		for (i=0; i<*count; i++)
		  printf("list[%d] = %d, %d\n",i, list[i].objid,
				list[i].osnum);
	*/


	return(OM_S_SUCCESS);
}

method get_absolute_roots(
	IGRint *count;
	struct GRid list[];
	struct GRid *prev)
{
	IGRint status, rc;
	IGRint ori_index, cpx_type, pcount;
	struct GRid my_par, plist[MAX_DIM_ROOTS];
	IGRboolean first_in_cpx;

	status =
	om$send(msg = message DMroot.DMreturn_roots(count, list),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.give_previous(&rc, &first_in_cpx, &my_par),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	*prev = my_par;

	if ((rc == DIM_S_SUCCESS) && (!first_in_cpx))
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
		om$send(msg = message DMroot.DMreturn_roots(&pcount, plist),
			targetid = my_par.objid,
			targetos = my_par.osnum);
		dm$status(action = RET_STATUS);

		list[DIM_CPX_ORIG] = plist[ori_index];
	}

	return(OM_S_SUCCESS);
}

method NDupdate(
	int *msg;
	int cn_type;
	int count;
	struct GRid *parents;
	int *parent_state;
	struct GRid *context,*new_objid;
	struct GRmd_env *md_env)
{
	IGRint status;
	IGRlong long_rc;
	enum GRdpmode mode;
	OM_S_OBJID md_id;
        struct GRid cur_mod;
        OMuint owner_count = 0;

        status = ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);
	dm$status(action = RET_STATUS);

	if (me->geom_type & DIM_IMPORTED)
		count--;

	md_id = md_env->md_id.objid;
	if (md_id != NULL_OBJID)
	{
		status =
		om$send(msg = message  GRvg.GRremwrng((IGRlong *)msg, md_env),
			mode = OM_e_wrt_message,
			targetid = my_id);
		/* Do not recompute the dimension if they arenot in rtree */
                /* Modified the above fix to now exclude dimension 
                   constraints from this check on recompute */

                status = om$get_channel_count(
		        p_chanselect = &AS_to_owner,
                        objid = my_id,
                        count = &owner_count);
                
		if(!(status &1) && !(owner_count)) return( OM_S_SUCCESS);

		md_env->md_id.objid = NULL_OBJID;
	}

	/*|- Erase the dimension */

        if (!(cn_type & ND_COMP_NO_ERASE))
	{
		mode = GRbe;

		status =
		om$send(msg = message GRgraphics.GRdisplay(
						&long_rc,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						&mode,
						&cur_mod),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	/*| - Send a DMcompute_node message */

	status =
	om$send(msg = message  DMroot.DMcompute_node(
					(IGRlong *)msg,
					cn_type,
					count,
					parents,
					md_env),
		targetid = my_id);

	/* - No status check here. Cannot return until
	   - dimension is put back into the R-tree
	   - (if necessary).
	*/

	if (md_id != NULL_OBJID)
	{
		md_env->md_id.objid = md_id;

		status =
		om$send(msg = message  GRgraphics.GRaddwrng((IGRlong *)msg, md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	/*|- Display the dimension */

        if (!(cn_type & ND_COMP_NO_DISPLAY))
	{
		mode = GRbd;

		status =
		om$send(msg = message GRgraphics.GRdisplay(
						&long_rc,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						&mode,
						&cur_mod),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	new_objid->objid = my_id;
	new_objid->osnum = OM_Gw_current_OS;

	GR_NOTIFY_LISTENERS(msg, &status, GR_GEOM_MODIFIED);

	return(status);
}

end implementation DMroot;

