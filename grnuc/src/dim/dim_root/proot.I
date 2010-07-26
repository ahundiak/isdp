class implementation DMproot;

#include "madef.h"
#include "nddef.h"
#include "asmacros.h"
#include "dm_status.h"
#include "dimdload.h"
#include "maidmx.h"

#define AS_DEBUG 1

method ASreturn_go(
	struct GRid *go;
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

method NDcopy(
	IGRlong *msg;
	IGRint cp_type;
	struct GRmd_env *fr_env;
	struct GRmd_env *to_env;
	struct GRid *newobjid)
{
	IGRint status;
	*msg = MSSUCC;

	if (!to_env) to_env = fr_env;

	status =
	om$send(msg = message NDnodein.NDcopy(
					msg,
					cp_type,
					fr_env,
					to_env,
					newobjid),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMproot.change_copy(
					(IGRint *)msg,
					fr_env,
					to_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method NDcopy_to_root(
	IGRlong *msg;
	IGRint cp_type;
	struct GRmd_env *obj_env, *new_env;
	struct GRid *new_id)
{
	IGRint status;
	*msg = MSSUCC;

	status =
	om$send(msg = message NDnode.NDcopy(
				msg,
				cp_type,
				obj_env,
				new_env,
				new_id),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method change_copy(
	IGRint *msg;
	struct GRmd_env *fr_env;
	struct GRmd_env *to_env)
{
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

end implementation DMproot;
