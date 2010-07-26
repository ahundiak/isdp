/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:31 $
$Locker:  $
$Log: plan_mgr.I,v $
Revision 1.1.1.1  2001/12/17 22:39:31  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:09:23  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:23:28  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:52:54  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.0  1992/12/06  23:47:53  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.0  1992/08/29  06:26:36  root
# COMMENT : Corresponds to Rel201.4 in 2.0.1 RCS
#
Revision 201.4  1992/05/26  05:21:40  dimdp20
COMMENT : Deleting pre 140 dimension conversion code from 2.1 version.

*/

class implementation DMplan_mgr;

#define AS_DEBUG 1

#include "cierrordef.h"
#include "ciexecdef.h"
#include "ciexecmacros.h"
#include "asbox.h"
#include "dimsrc.h"

from NDnode import NDplace;
from DMplan import update_plan, translate, translate_local;
from GRconnector import GRrigidconn;

extern GRclassid OPP_dim_plan_class_id;

method super_construct()
{
	ASsuper_construct();

	return(OM_S_SUCCESS);
}

method wake_up()
{
	IGRint status;

	/* - Invoke global_class wake_up - */

	status =
	om$send(msg = message global_class.wake_up(),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method create_dim_plane(
	IGRint *msg;
	struct GRid win_grid;
	IGRmatrix matrix;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env;
	struct GRid *dim_plan)
{
	IGRint status;
	struct GRas assoc_list;
	struct GRid my_grid;
	IGRlong owners_index, long_rc;
	struct DMplan_attr plan_attr;

	/*"count=%d\n", count*/

	dbg$print(msg = "Creating Dimension Plane - New");

	plan_attr.win_grid = win_grid;
	if (win_grid.objid == NULL_OBJID)
		memcpy(plan_attr.matrix, matrix, sizeof(double)*16);

	assoc_list.num_parents = count;
	assoc_list.parents = list;
	assoc_list.as_attr = (char *)&plan_attr;

	dim_plan->osnum = OM_Gw_current_OS;

	status =
	om$construct(
		classname = "DMplan",
		msg = message NDnode.NDplace(&assoc_list, md_env, NULL),
		p_objid = &dim_plan->objid,
		osnum = dim_plan->osnum);
	dm$status(action = RET_STATUS);

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;
	owners_index = 0;

	status =
	om$send(msg = message GRconnector.GRrigidconn(&long_rc, &my_grid, &owners_index),
		targetid = dim_plan->objid,
		targetos = dim_plan->osnum);
	dm$status(action = RET_STATUS);

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method get_dim_plane(
	IGRint *msg;
	struct GRid win_grid;
	struct GRmd_env *md_env;
	struct GRid *dim_plan)
{
	IGRint status, rc, count;
	IGRmatrix matrix;
	struct GRid parent;

	if (win_grid.objid == NULL_OBJID)
		return(OM_E_ABORT);

	*msg = DIM_S_SUCCESS;
	dim_plan->objid = NULL_OBJID;

	status =
	om$send(msg = message DMplan.translate(win_grid.objid, dim_plan),
		p_chanselect = &AS_to_comp);
	dm$status(action = RET_STATUS);

	if (dim_plan->objid != NULL_OBJID)
	{
		/*| - Update dimension plane orientation - */

		status =
		om$send(msg = message DMplan.update_plan(&rc, md_env, dim_plan),
			targetid = dim_plan->objid,
			targetos = dim_plan->osnum);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*| - Create new dimension plane - */

		if (DMancestry_valid(win_grid, OPP_dim_plan_class_id))
		{
			/*| - win_grid is a reference plane  */

			parent.objid = win_grid.objid;
			parent.osnum = win_grid.osnum;
			count = 1;
		}
		else
		{
			count = 0;
			parent.objid = NULL_OBJID;
		}

		status =
		om$send(msg = message DMplan_mgr.create_dim_plane(
							&rc,
							win_grid,
							matrix,
							count,
							&parent,
							md_env,
							dim_plan),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method create_local_plane(
	IGRint *msg;
	struct GRid win_grid;
	IGRdouble matrix[16];
	IGRint count;
	struct GRid list[];
	IGRdouble axis[6];
	struct GRmd_env *md_env;
	struct GRid *dim_plan)
{
	IGRint status, rc;

	dim_plan->objid = NULL_OBJID;

	status =
	om$send(msg = message DMplan.translate_local(
						&rc,
						win_grid.objid,
						matrix,
						count,
						list,
						axis,
						md_env,
						dim_plan),
		p_chanselect = &AS_to_comp);
	dm$status(action = RET_STATUS);

	if (dim_plan->objid == NULL_OBJID)
	{
		IGRint par_count;
		struct GRid axis_id, context[2];

		win_grid.objid =
		axis_id.objid = NULL_OBJID;

		if (count)
		{
			context[0].objid = context[1].objid = NULL_OBJID;

			status =
			dm$create_root(
				type = (count == 1)?DMkeyseg:DM2ptseg,
				count = count,
				list = list,
				context = context,
				attr = axis,
				md_env = md_env,
				p_root = &axis_id);
			dm$status(action = RET_STATUS);

			par_count = 1;
		}
		else	par_count = 0;

		status =
		om$send(msg = message DMplan_mgr.create_dim_plane(
							&rc,
							win_grid,
							matrix,
							par_count,
							&axis_id,
							md_env,
							dim_plan),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		/*^ print_matrix("matrix", matrix); */
	}

	return(OM_S_SUCCESS);
}

end implementation DMplan_mgr;
