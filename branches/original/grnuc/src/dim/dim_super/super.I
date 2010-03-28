/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:31 $
$Locker:  $
$Log: super.I,v $
Revision 1.1.1.1  2001/12/17 22:39:31  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:09:24  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:23:29  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:52:55  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.3  1994/08/09  21:38:29  grnuc40
# COMMENT : upgraded for v3.1
#
# Revision 240.2  1993/08/03  05:42:42  laxmi
# COMMENT : Dimensioning 2.4 CR and TR fixes checkin. -Laxmi
#
# Revision 240.1  1993/03/01  19:39:15  mikel
# COMMENT : remove ms.h or change it to msmacros.h
#
# Revision 240.0  1992/12/06  23:47:49  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.0  1992/08/29  06:26:33  root
# COMMENT : Corresponds to Rel201.23 in 2.0.1 RCS
#
Revision 201.23  1992/07/23  19:54:02  doree
COMMENT : message subsystem compliance

Revision 201.22  1992/07/20  05:45:05  gvk
COMMENT : ANSI compilation, global modification of DMglobal to DM_global.

Revision 201.19  1992/04/09  06:09:59  dimdp20
COMMENT : Initialise Assoc Global Variables used by dimensions.

Revision 201.15  1992/02/19  13:22:08  dimdp20
COMMENT : Preventing Global structure filled from reference super objects during wakeup.

Revision 201.14  1992/01/29  05:18:45  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Jan 29. 92.

*/

class implementation DMsuper;

#define AS_DEBUG 1

#include "cierrordef.h"
#include "ciexecdef.h"
#include "ciexecmacros.h"
#include "asbox.h"
#include "exmacros.h"
#include "dimgraph.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "DMmessages.h"

%safe
#include "math.h"
%endsafe

from NDnode import NDplace, NDs_compute_node;
from IGEgragad import DPinrot;
from dim_param import give_internal, store_internal, datcmp, pass_message;
from GRconnector import GRrigidconn, GRdisconn;
from dim_param import translate, find_match, update, edit, delete_no_ch;

method super_construct()
{
	IGRint status, rc;

	/*| - Set dimensioning standard - */

	ASsuper_construct();

	ex$message(msgnumb = DM_I_InitDimension);

	DMinit_glob();

	status =
	om$send(msg = message DMsuper.set_dim_stan(&rc, DMdefault_dim_stan()),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	ex$message(msgnumb = GR_I_Clear);

	return(OM_S_SUCCESS);
}

method wake_up()
{
	IGRint status, i, rc;
	IGRint size[MAX_PARAM_TYPE+1];
	struct GRid grid;
	char   *p_data[MAX_PARAM_TYPE+1];
	IGRboolean const_glob, const_weld;
	extern struct DMenv_param frm_env;
	extern struct DMloc_param frm_loc;
	extern struct DMmisc_param frm_misc;
	extern struct DMsenv_param frm_senv;
	extern struct DMglobal_param frm_glob;
	extern struct DMweld_param frm_weld;
	OM_S_OBJID md_id;
	OMuword md_os;
	struct GRmd_env md_env;
	IGRint DMconvert_20dim();

	status = DMget_module_info(&md_env);
	dm$status(action = RET_STATUS);

	status = DMinit_glob();
	dm$status(action = RET_STATUS);

	/* Initialise the Assoc Global Variables */

	status = ASassoc_init();
	dm$status(action = RET_STATUS);

	/* - Invoke global_class wake_up - */

	status =
	om$send(msg = message global_class.wake_up(),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	ex$get_cur_mod(id = &md_id,
		osnum = &md_os);
	dm$status(action = RET_STATUS);

	/* - only the master file param objects needs to be copied to global*/

	if (md_os != OM_Gw_current_OS)
	{
		/*|- Reference OS - initilise the global objects from cur super*/

		status =
		dm$get_cur_super(p_grid = &grid);
		dm$status(action = RET_STATUS);	

		return(OM_S_SUCCESS);
	}

	const_glob = const_weld = FALSE;

	p_data[DM_ENV_PARAM] = (char *)&frm_env;
	p_data[DM_LOC_PARAM] = (char *)&frm_loc;
	p_data[DM_MISC_PARAM] = (char *)&frm_misc;
	p_data[DM_SENV_PARAM] = (char *)&frm_senv;
	p_data[DM_GLOB_PARAM] = (char *)&frm_glob;
	p_data[DM_WELD_PARAM] = (char *)&frm_weld;

	size[DM_ENV_PARAM] = sizeof(frm_env);
	size[DM_LOC_PARAM] = sizeof(frm_loc);
	size[DM_MISC_PARAM] = sizeof(frm_misc);
	size[DM_SENV_PARAM] = sizeof(frm_senv);
	size[DM_GLOB_PARAM] = sizeof(frm_glob);
	size[DM_WELD_PARAM] = sizeof(frm_weld);

	for (i=DM_ENV_PARAM; i<=DM_WELD_PARAM; i++)
	{
		status =
		om$send(msg = message DMsuper.get_dim_param(&rc, i, &grid),
			targetid = my_id);
		if (!(status & 1))
		{
			if (((rc == DIM_E_NO_OBJECT)
			||   (status & OM_E_INVCHAN))
			&& (i == DM_GLOB_PARAM))
			{
				const_glob = TRUE;
				continue;
			}
			else if (((rc == DIM_E_NO_OBJECT)
			||   (status & OM_E_INVCHAN))
			&& (i == DM_WELD_PARAM))		
			{
				const_weld = TRUE;
				continue;
			}
			else	break;
		}

		status =
		om$send(msg = message dim_param.give_internal(i, size[i], p_data[i]),
			targetid = grid.objid,
			targetos = grid.osnum);
		dm$status(action = RET_STATUS);
	}

	/* DM_GLOB_PARAM and DM_WELD_PARAM are new
	   super objects created in 2.0 all pre 2.0
	   files on wake up must construct them and
	   initialise them from standard files. */

	if (const_glob || const_weld)
	{
		struct DMenv_param par_env;
		struct DMloc_param par_loc;
		struct DMsenv_param par_senv;
		struct DMmisc_param par_misc;
		struct DMglobal_param par_glob;
		struct DMweld_param par_weld;

		status =
		DMinit_dim_params(
			me->dim_stan,
			OM_Gw_current_OS,
			&par_env,
			&par_loc,
			&par_misc,
			&par_senv,
			&par_glob,
			&par_weld);
		dm$status(action = RET_STATUS);

		if (const_glob)
		{
			/*"constructing DM_GLOB_PARAM object \n"*/

		   	DMcopy_to_ram(DM_GLOB_PARAM,(char *) &par_glob, size[DM_GLOB_PARAM]);

			status =
			om$send(msg = message DMsuper.create_dim_param(
							&rc,
							TRUE,
							DM_GLOB_PARAM,
							size[DM_GLOB_PARAM],
							p_data[DM_GLOB_PARAM],
							&md_env,
							&grid),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			DMpost_conversion(&md_env);
			dm$status(action = RET_STATUS);
		}

		if (const_weld)
		{
			/*"constructing DM_WELD_PARAM object \n"*/

	   		DMcopy_to_ram(DM_WELD_PARAM, (char *) &par_weld, size[DM_WELD_PARAM]);

			status =
			om$send(msg = message DMsuper.create_dim_param(
							&rc,
							TRUE,
							DM_WELD_PARAM,
							size[DM_WELD_PARAM],
							p_data[DM_WELD_PARAM],
							&md_env,
							&grid),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	/* - Convert pre 2.1 dimensions */

	status =
	DMpass_function(DMconvert_20dim, &md_env);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method global_class.sleep(int type_sleep)
{
	IGRint status;

	IGRint par_count[MAX_PARAM_TYPE + 1], i;

	for (i=0; i<=MAX_PARAM_TYPE; i++)
		par_count[i] = 0;

	status =
	om$send(msg = message dim_param.delete_no_ch(par_count),
		p_chanselect = &AS_to_comp);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message global_class.sleep(type_sleep),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method get_dim_param(
	IGRint *msg;
	IGRint type;
	struct GRid *param)
{
	IGRint status;

	param->objid = NULL_OBJID;

	status =
	om$send(msg = message dim_param.translate(type, param),
		p_chanselect = &AS_to_comp);
	dm$status();

	if (param->objid == NULL_OBJID)
	{
		/*|Parameter object not found*/

		*msg = DIM_E_NO_OBJECT;
		return(OM_E_ABORT);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method update_dim_param(
	IGRint *msg;
	IGRint type;
	IGRint size;
	char   *p_data;
	struct GRmd_env *md_env;
	struct GRid *param)
{
	IGRint status, rc;

	param->objid = NULL_OBJID;

	status =
	om$send(msg = message dim_param.translate(type, param),
		p_chanselect = &AS_to_comp);
	dm$status(action = RET_STATUS);

	DMcopy_to_ram(type, p_data, size);

	if (param->objid != NULL_OBJID)
	{
		/*| - Params Object Exists - */	

		status =
		om$send(msg = message dim_param.update(	type,
							size,
							p_data,
							md_env,
							param),
			targetid = param->objid,
			targetos = param->osnum);
		dm$status(action = RET_STATUS);

		*msg =  DIM_S_SUCCESS;
	}
	else
	{
		status =
		om$send(msg = message DMsuper.create_dim_param(
							&rc,
							TRUE,
							type,
							size,
							p_data,
							md_env,
							param),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		*msg =  DIM_I_OBJ_CREATED;
	}

	return(OM_S_SUCCESS);
}

method create_dim_param(
	IGRint *msg;
	IGRboolean global;
	IGRint type;
	IGRint size;
	char   *p_data;
	struct GRmd_env *md_env;
	struct GRid *p_grid)
{
	IGRint status, rc;
	struct dim_param_attr dim_param;
	struct GRas assoc_list;
	struct GRid my_grid;
	IGRlong owners_index;

	p_grid->objid = NULL_OBJID;

	if (type == DM_MISC_PARAM
	||  type == DM_GLOB_PARAM
	||  type == DM_WELD_PARAM)
	{
		status =
		om$send(msg = message dim_param.translate(type, p_grid),
			p_chanselect = &AS_to_comp);
		dm$status(action = RET_STATUS);
	}
	else
	{
		status =
		om$send(msg = message dim_param.find_match(
						type,
						size,
						p_data,
						p_grid),
			p_chanselect = &AS_to_comp);
		dm$status(action = RET_STATUS);
	}

	if (p_grid->objid !=  NULL_OBJID)
	{
		if (type == DM_MISC_PARAM
		||  type == DM_GLOB_PARAM
		||  type == DM_WELD_PARAM)
		{
			status =
			om$send(msg = message dim_param.store_internal(
							type,
							size,
							p_data),
				targetid = p_grid->objid,
				targetos = p_grid->osnum);
			dm$status(action = RET_STATUS);
		}
		else if (global)
		{
			status =
			om$send(msg = message DMsuper.activate_dim_param(
								&rc,
								*p_grid),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		*msg =  DIM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	{
		char dbg_msg[64];

		sprintf(dbg_msg, "Creating Parameter Object - %d", type);
		dbg$print(msg = dbg_msg);
	}

	dim_param.data = p_data;
	dim_param.type = type;
	dim_param.size = size;
	assoc_list.as_attr = (char *)&dim_param;
	assoc_list.num_parents = 0;
	p_grid->osnum = OM_Gw_current_OS;

	status =
	om$construct(
		classname = "dim_param",
		msg = message NDnode.NDplace(
					&assoc_list,
					md_env,
					NULL),
		p_objid = &p_grid->objid,
		osnum = p_grid->osnum);
	dm$status(action = RET_STATUS);

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;
	owners_index = global?0:OM_K_MAXINT;

	/*| - Connect parameter object to myself - */

	status =
	om$send(msg = message GRconnector.GRrigidconn(
						(IGRlong *) &rc,
						&my_grid,
						&owners_index),
		targetid = p_grid->objid,
		targetos = p_grid->osnum);
	dm$status(action = RET_STATUS);

	*msg =  DIM_I_OBJ_CREATED;
	return(OM_S_SUCCESS);
}

method activate_dim_param(IGRint *msg; struct GRid param)
{
	IGRint status;
        IGRlong long_rc;
	struct GRid my_grid;
	IGRlong owners_index;

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	status =
	om$send(msg = message GRconnector.GRdisconn(&long_rc, &my_grid),
		targetid = param.objid,
		targetos = param.osnum);
	dm$status(action = RET_STATUS);

	owners_index = 0;

	status =
	om$send(msg = message GRconnector.GRrigidconn(
						&long_rc,
						&my_grid,
						&owners_index),
		targetid = param.objid,
		targetos = param.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method set_dim_stan(IGRint *msg; IGRint stan)
{
	IGRint status, rc;
	IGRint i;
	IGRint type[6], size[6];
	char *data[6];
	struct GRid grid[6];
	struct DMenv_param par_env;
	struct DMloc_param par_loc;
	struct DMmisc_param par_misc;
	struct DMsenv_param par_senv;
	struct DMglobal_param par_glob;
	struct DMweld_param par_weld;
	struct GRmd_env md_env;
	struct IGRdisplay display;
	short  level;

	me->dim_stan = stan;

	status =
	DMinit_dim_params(
		stan,
		OM_Gw_current_OS,
		&par_env,
		&par_loc,
		&par_misc,
		&par_senv,
		&par_glob,
		&par_weld);
	dm$status(action = RET_STATUS);

	ASget_active_symb(&level, &display);

/*
	par_env.dim_layr = level;
*/

	status =
	DMmerge_senv(&par_senv, &par_env, &par_loc, &par_misc);
	dm$status(action = RET_STATUS);

	status = DMget_module_info(&md_env);
	dm$status(action = RET_STATUS);

	type[0] = DM_ENV_PARAM;
	size[0] = sizeof(par_env);
	data[0] = (char *)&par_env;

	type[1] = DM_LOC_PARAM;
	size[1] = sizeof(par_loc);
	data[1] = (char *)&par_loc;

	type[2] = DM_MISC_PARAM;
	size[2] = sizeof(par_misc);
	data[2] = (char *)&par_misc;

	type[3] = DM_SENV_PARAM;
	size[3] = sizeof(par_senv);
	data[3] = (char *)&par_senv;

	type[4] = DM_GLOB_PARAM;
	size[4] = sizeof(par_glob);
	data[4] = (char *)&par_glob;

	type[5] = DM_WELD_PARAM;
	size[5] = sizeof(par_weld);
	data[5] = (char *)&par_weld;

	for (i=0; i<=5; i++)
	{
		status =
		om$send(msg = message DMsuper.update_dim_param(
							&rc,
							type[i],
							size[i],
							data[i],
							&md_env,
							&grid[i]),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method pass_message(OM_p_MESSAGE p_msg)
{
	IGRint status;

	status =
	om$send(msg = message dim_param.pass_message(p_msg),
		senderid = my_id,
		p_chanselect = &AS_to_comp);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

end implementation DMsuper;
