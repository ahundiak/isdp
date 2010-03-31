class implementation NMnonmanigm;

#include "EMcp.h"

method GRcopy(IGRlong *EMmsg; struct GRmd_env *obj_mdenv; 
  	      struct GRmd_env *new_mdenv; GRobjid *newobjid)

{
 IGRlong            sts;
 struct EMcp_info   copy_info;

 *EMmsg = MSSUCC;
 sts = OM_S_SUCCESS;

 copy_info.num_entries = 0;
 copy_info.array_size = 0;
 copy_info.objid_array = NULL;

 /*
  * send a message to myself to perform the copy process
  */

 sts = om$send (msg = message NMnonmanigm.NMintcopy (EMmsg,
       obj_mdenv, new_mdenv, newobjid, &copy_info, NULL, NULL, NULL),
       targetid = my_id);

 if (copy_info.objid_array) om$dealloc (ptr = copy_info.objid_array);
 EMWRAPUP (*EMmsg, sts, "In NMnonmanigm.GRcopy");
 return(sts);
}

end implementation NMnonmanigm;
