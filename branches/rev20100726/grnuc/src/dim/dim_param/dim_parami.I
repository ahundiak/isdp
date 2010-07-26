/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:31 $
$Locker:  $
$Log: dim_parami.I,v $
Revision 1.1.1.1  2001/12/17 22:39:31  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:08:28  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:22:29  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.1  1995/06/13  09:00:51  gvk
# COMMENT : New parameter object will be created during edits for annotations.
#
# Revision 320.0  1994/12/12  17:51:58  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1994/11/01  10:12:17  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.0  1992/12/06  23:45:17  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.0  1992/08/29  06:24:26  root
# COMMENT : Corresponds to Rel201.12 in 2.0.1 RCS
#
Revision 201.12  1992/06/30  06:23:39  laxmi
COMMENT : Source code changed to comply with ANSI compilation.

*/

class implementation dim_param;

#define AS_DEBUG 1

#include "exmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "dimext.h"
#include "dimerror.h"
#include "nddef.h"
#include "bstypes.h"
#include "bslenvec.h"
 
extern double MATH_fix_dbl( );

from DMsuper import create_dim_param, activate_dim_param;
from DMsuper import get_dim_param;
from DMroot  import test_state, connect_state;

method NDplace( struct GRas *assoc_list;
		struct GRmd_env *md_env;
		char *go_cnst_lis)
{
	int status;
	struct dim_param_attr *attr;

	attr = (struct dim_param_attr *)assoc_list->as_attr;
	if (attr->size <= 0)
	{
		printf("dim_param.NDplace: bad size = %d\n", attr->size);
		return(OM_E_ABORT);
	}

	me->version_no = CURRENT_VERSION;
	me->type = attr->type;

	status =
	om$vla_set_dimension(varray = ME.dim_param->data, size = attr->size);
	dm$status(action = RET_STATUS);

	memcpy(ME.dim_param->data, attr->data, attr->size);

	return(OM_S_SUCCESS);
}

method give_internal(int type; int size; char *data)
{
	int status;
	int vla_size;

	vla_size = om$dimension_of(varray = ME.dim_param->data);
	if (!vla_size)
	{
		printf("dim_param.give_internal: vla not initialised\n");
		return(OM_E_ABORT);
	}

	if (vla_size != size)
	{
		printf("dim_param.give_internal:vla_size = %d, size = %d\n",
				vla_size, size);
		return(OM_E_ABORT);
	}

	if (me->type != type)
	{
		printf("dim_param.give_internal: vla_type = %d, type = %d\n",
				me->type, type);
		return(OM_E_ABORT);
	}

	memcpy(data, ME.dim_param->data, size);

	status = DMclean_data(type, data);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method store_internal(int type; int size; char *data)
{
	int vla_size;

	vla_size = om$dimension_of(varray = ME.dim_param->data);
	if (!vla_size)
	{
		printf("dim_param.store_internal: vla not initialised\n");
		return(OM_E_ABORT);
	}

	if (vla_size != size)
	{
		printf("dim_param.store_internal:vla_size = %d, size = %d\n",
				vla_size, size);
		return(OM_E_ABORT);
	}

	if (me->type != type)
	{
		printf("dim_param.store_internal: vla_type = %d, type = %d\n",
				me->type, type);
		return(OM_E_ABORT);
	}

	DMclean_data(type, data);
	memcpy(ME.dim_param->data, data, size);

	return(OM_S_SUCCESS);
}

method datcmp(int *rc; int type; int size; char *data)
{
	int vla_size;
	char *my_data;
	extern int DMsizes[];

	if (type != me->type)
	{
		printf("dim_param: Type mismatch type=%d, me->type=%d\n",
				type, me->type);
		return(OM_E_ABORT);
	}

	my_data = ME.dim_param->data;
	vla_size = om$dimension_of(varray = ME.dim_param->data);
	if (size != vla_size)	
	{
		printf("dim_param: Size mismatch size=%d, me->size=%d\n",
				size, vla_size);
		return(OM_E_ABORT);
	}

	DMclean_data(type, data);
	*rc = memcmp(my_data, data, DMsizes[type]);

	/*^
	{
		int i;

		if (*rc)
		{
			printf("datcmp-%d: Different", type);
			for (i=0; i<DMsizes[type]; i++)
				if (my_data[i] != data[i])
				{
					printf(" @ byte %d\n", i);
					break;
				}
		}
		else	printf("datcmp-%d: No difference\n", type);
	}
	*/

	return(OM_S_SUCCESS);
}

method convert()
{
	if (ME.dim_param->version_no != CURRENT_VERSION)
	{
		printf("dim_param.convert: Needs conversion\n");
		return(OM_E_ABORT);
	}

	return(OM_S_SUCCESS);
}

method translate(IGRint type; struct GRid *p_grid)
{
	if (me->type == type)
	{
		p_grid->objid = my_id;
		p_grid->osnum = OM_Gw_current_OS;
		return(OM_I_STOP_SENDING);
	}

	return(OM_S_SUCCESS);
}

method update(
	IGRint type;
	IGRint size;
	char *data;
	struct GRmd_env *md_env;
	struct GRid *new_grid)
{
	IGRint status, rc;
	struct GRid dim_super;
	IGRint on_count, off_count;
	struct GRid mygrid, match;

	on_count = off_count = 0;

	status =
	om$send(msg = message DMroot.test_state(
					DIM_IN_PLACEMENT,
					&on_count,
					&off_count),
		p_chanselect = &ND_children);
	dm$status(action = RET_STATUS);

	mygrid.objid = my_id;
	mygrid.osnum = OM_Gw_current_OS;
	match.objid = NULL_OBJID;

	status = dm$get_super(p_grid = &dim_super);
	dm$status(action = RET_STATUS);

	/*"on_count=%d, off_count=%d\n", on_count, off_count*/

	if (off_count)
	{
		/*| - Non_dynamic dependents exist - */

		status =
		om$send(msg = message DMsuper.create_dim_param(	&rc,
								TRUE,
								type,
								size,
								data,
								md_env,
								new_grid),
			targetid = dim_super.objid,
			targetos = dim_super.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.connect_state(
						DIM_IN_PLACEMENT,
						&mygrid,
						new_grid),
			p_chanselect = &ND_children);
		dm$status(action = RET_STATUS);
	}
	else
	{
		if (type != DM_MISC_PARAM
		&&  type != DM_GLOB_PARAM
		&&  type != DM_WELD_PARAM)
		{
			status =
			om$send(msg = message dim_param.find_match(
							type,
							size,
							data,
							&match),
				senderid = dim_super.objid,
				p_chanselect = &AS_to_comp);
			dm$status(action = RET_STATUS);

			if (match.objid != NULL_OBJID)
			{
				status =
				om$send(msg = message DMroot.connect_state(
							DIM_IN_PLACEMENT,
							&mygrid,
							&match),
					p_chanselect = &ND_children);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message DMsuper.activate_dim_param(
							&rc,
							match),
					targetid = dim_super.objid,
					targetos = dim_super.osnum);
				dm$status(action = RET_STATUS);

				return(OM_S_SUCCESS);
			}
		}

		/*| - Store_internal - */

		status =
		om$send(msg = message dim_param.store_internal(type, size, data),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method edit(
	IGRint type;
	IGRint size;
	char *data;
	struct GRmd_env *md_env;
	struct GRid *new_grid)
{
	IGRint status, rc;
	struct GRid dim_super;
	IGRint on_count, off_count;
	IGRboolean copy_needed;
	struct GRid mygrid, glob, match;

	on_count = off_count = 0;

	status =
	om$send(msg = message DMroot.test_state(DIM_IN_EDIT, &on_count, &off_count),
		p_chanselect = &ND_children);
	dm$status(action = RET_STATUS);

	copy_needed = FALSE;

	if (!off_count)
	{
		if (me->type == DM_ENV_PARAM
		||  me->type == DM_SENV_PARAM
		||  me->type == DM_LOC_PARAM)
		{
			status = dm$get_dim_param(type = me->type, p_grid = &glob);
			dm$status(action = RET_STATUS);

			if (glob.objid == my_id)
			{
				/*| - Edit on global paramter object - */
				copy_needed = TRUE;
			}
		}
	}
	else if (on_count)
	{
		/* - Dependents not in edit exist - */
		copy_needed = TRUE;
	}

	mygrid.objid = my_id;
	mygrid.osnum = OM_Gw_current_OS;
	match.objid = NULL_OBJID;

	status = dm$get_super(p_grid = &dim_super);
	dm$status(action = RET_STATUS);

	if (copy_needed)
	{
		status =
		om$send(msg = message DMsuper.create_dim_param(	&rc,
								FALSE,
								type,
								size,
								data,
								md_env,
								new_grid),
			targetid = dim_super.objid,
			targetos = dim_super.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.connect_state(DIM_IN_EDIT, &mygrid, new_grid),
			p_chanselect = &ND_children);
		dm$status(action = RET_STATUS);
	}
	else
	{
		status =
		om$send(msg = message dim_param.find_match(
						type,
						size,
						data,
						&match),
			senderid = dim_super.objid,
		p_chanselect = &AS_to_comp);
		dm$status(action = RET_STATUS);

		if (match.objid != NULL_OBJID)
		{
			status =
			om$send(msg = message DMroot.connect_state(
						DIM_IN_EDIT,
						&mygrid,
						&match),
				p_chanselect = &ND_children);
			dm$status(action = RET_STATUS);

			return(OM_S_SUCCESS);
		}

		/*| - Store_internal - */

		status =
		om$send(msg = message dim_param.store_internal(type, size, data),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method find_match(
	IGRint type;
	IGRint size;
	char *data;
	struct GRid *match)
{
	IGRint status, rc;

	if (me->type != type) return(OM_S_SUCCESS);

	status =
	om$send(msg = message dim_param.datcmp(&rc, type, size, data),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!rc)
	{
		match->objid = my_id;
		match->osnum = OM_Gw_current_OS;
		return(OM_I_STOP_SENDING);
	}

	return(OM_S_SUCCESS);
}

method delete_no_ch(IGRint par_count[])
{
	IGRint status, count;

	if (me->type > MAX_PARAM_TYPE)
	{
		printf("delete_no_ch: Invalid type %d\n", me->type);
		return(OM_S_SUCCESS);
	}

	if (par_count[me->type])
	{
		status =
		om$get_channel_count(
			objid = my_id,
			osnum = OM_Gw_current_OS,
			p_chanselect = &ND_children,
			count = (OMuint *) &count);
		dm$status(action = RET_STATUS);

		if (!count)
		{
			status =
			om$send(msg = message Root.delete(1),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	par_count[me->type]++;

	return(OM_S_SUCCESS);
}

method import_param(
	IGRint *msg;
	struct GRmd_env *fr_env;
	struct GRmd_env *to_env;
	struct GRid *copy)
{
	IGRint status, rc, size;
	IGRchar *p_data, *cur_data;
	struct GRid dim_super, env_grid;
	struct DMenv_param par_env, cur_env;
	struct DMsenv_param par_senv, cur_senv;

	if ((me->type != DM_ENV_PARAM) && (me->type != DM_SENV_PARAM))
	{
		status =
		om$send(msg = message NDnode.NDcopy(
					(IGRlong *) &rc,
					NULL,
					fr_env,
					to_env,
					copy),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*"parameter object [%d]\n",me->type*/

		if (me->type == DM_ENV_PARAM)
		{
			size = sizeof(par_env);
			p_data = (char *)&par_env;
			cur_data = (char *)&cur_env;
		}
		else
		{
			size = sizeof(par_senv);
			p_data = (char *)&par_senv;
			cur_data = (char *)&cur_senv;
		}

		status =
		om$send(msg = message dim_param.give_internal(
						me->type,
						size,
						p_data),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		dm$get_super(
			md_os = to_env->md_id.osnum,
			create = TRUE,
			p_grid = &dim_super);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMsuper.get_dim_param(
						&rc,
						me->type,
						&env_grid),
			targetid = dim_super.objid,
			targetos = dim_super.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message dim_param.give_internal(
						me->type,
						size,
						cur_data),
			targetid = env_grid.objid,
			targetos = env_grid.osnum);
		dm$status(action = RET_STATUS);

		if (me->type == DM_ENV_PARAM)
		{
			par_env.txt_heig = cur_env.txt_heig;
			par_env.txt_widt = cur_env.txt_widt;
			par_env.dim_colr = cur_env.dim_colr;
			par_env.det_colr = cur_env.det_colr;
			par_env.dim_layr = cur_env.dim_layr;
		}
		else
		{
			par_senv.txt_heig = cur_senv.txt_heig;
			par_senv.txt_widt = cur_senv.txt_widt;
			par_senv.dim_colr = cur_senv.dim_colr;
			par_senv.dim_layr = cur_senv.dim_layr;
		}

		status =
		om$send(msg = message DMsuper.create_dim_param(
						&rc,
						FALSE,
						me->type,
						size,
						p_data,
						to_env,
						copy),
			targetid = dim_super.objid,
			targetos = dim_super.osnum);
		dm$status(action = RET_STATUS);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method NDcopy(
	IGRlong *msg;
	IGRint cp_type;
	struct GRmd_env *fr_env;
	struct GRmd_env *to_env;
	struct GRid *newobjid)
{
	IGRint status, rc;
	IGRint size;
	char *param;
	struct DMenv_param par_env;
	struct DMloc_param par_loc;
	struct DMsenv_param par_senv;
	struct GRid dim_super;
	BSrc	bsrc;

	*msg = MSSUCC;
	if (!to_env) to_env = fr_env;

	switch (me->type)
	{
		case DM_ENV_PARAM:
		size = sizeof(par_env);
		param = (char *)&par_env;
		break;

		case DM_LOC_PARAM:
		size = sizeof(par_loc);
		param = (char *)&par_loc;
		break;

		case DM_SENV_PARAM:
		size = sizeof(par_senv);
		param = (char *)&par_senv;
		break;

		default:
		dbg$error(msg = "Unknown param type");
		return(OM_E_ABORT);
	}

	status =
	om$send(msg = message dim_param.give_internal(
					me->type,
					size,
					param),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->type == DM_ENV_PARAM
	||  me->type == DM_SENV_PARAM)
	{
		IGRdouble s_scale, d_scale, scale;

		s_scale = BSlenvec(&bsrc, fr_env->md_env.matrix);
		d_scale = BSlenvec(&bsrc, to_env->md_env.matrix);
		scale = MATH_fix_dbl(s_scale / d_scale);

		/*"scales=%lf, %lf, %lf\n", s_scale, d_scale, scale*/

		if (me->type == DM_ENV_PARAM)
		{
			par_env.txt_heig *= scale;
			par_env.txt_widt *= scale;
		}
		else
		{
			par_senv.txt_heig *= scale;
			par_senv.txt_widt *= scale;
		}
	}

	status =
	dm$get_super(
		md_os = to_env->md_id.osnum,
		create = TRUE,
		p_grid = &dim_super);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMsuper.create_dim_param(
					&rc,
					FALSE,
					me->type,
					size,
					param,
					to_env,
					newobjid),
		targetid = dim_super.objid,
		targetos = dim_super.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method pass_message(OM_p_MESSAGE p_msg)
{
	IGRint status;

	if ((me->type == DM_ENV_PARAM) || (me->type == DM_SENV_PARAM))
	{
		status =
		om$send(msg = p_msg,
			senderid = my_id,
			p_chanselect = &ND_children);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

end implementation dim_param;
