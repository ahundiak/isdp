/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method copies the surface and its active topology only. When
sent to a DPR state, it will copy only the leaf nodes (with their respective
active topologies) and not the save state information or any any other 
intermediate state. Thus it is equivalent to a copy followed by a compress.
Though its apparent use is best for EMSsfdpr subclasses, this message  is
defined at EMSsurface so that the caller does not have to distinguish between
a surface with history and one without. All surfaces not subclassed off
EMSsfdpr will simply copy themselves, as if they received GRcopy message.

Arguments
	my_env, cp_env	input	env info for element and its copy.
	new_id		output	copy id.
	options		input	Currently ignored.
History
	SM	15-Jun-89	Creation.
	NP      03/31/92        use targetos in EMfix_creator_id send.	
*/

class implementation EMSsurface;

#include "EMS.h"
#include "EMcp.h"
#include "EMSopt.h"

method EMcompressed_copy(IGRlong *EMmsg; struct GRmd_env *my_env, *cp_env;
                       GRobjid *new_id; IGRushort options)
{
 IGRlong         sts;
 struct EMcp_info   copy_info;

 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 copy_info.num_entries = 0;
 copy_info.array_size = 0;
 copy_info.objid_array = NULL;
 if(!cp_env) cp_env = my_env;

 sts = om$send(msg = message EMSsurface.EMintcopy (EMmsg, my_env, cp_env, 
                     new_id, &copy_info, EMS_COPY_ACTIVETOPOLOGY, NULL),
               targetid = my_id);
 if (!(1 & sts & *EMmsg)) goto wrapup;

 sts = om$send(msg = message EMSsurface.EMfix_creator_id(EMmsg, NULL,
                     *new_id, NULL),
               targetid = *new_id, targetos = cp_env->md_id.osnum);
 if (!(1 & sts & *EMmsg)) goto wrapup;               

wrapup:
 if (copy_info.objid_array) om$dealloc (ptr = copy_info.objid_array);
 return (sts);
}
end implementation EMSsurface;
