class implementation EMScomposite;

#include "EMScc.h"
#include "EMSmsgdef.h"

method EMcomponentchanged(IGRlong *EMmsg; GRobjid old_id; IGRint num_newids;
                          GRobjid *new_ids)
/*
Description
   This method is used to notify EMS composite objects that one of their
   components ids has changed.  Since the component could have changed to
   multiple ids, an array of new ids is passed.

Return values 
   EMS_S_Success if all is well.

Notes 
   The method of this class does not do anything but send on up the owners
   channel.  It is assumed that if a specific class has a use for this
   information then it should override this message and do what it must.

History
   DLB  11/09/87  Creation.
*/

{
 IGRlong         OM_stat = OM_S_SUCCESS;
 OM_S_CHANSELECT to_owners;
 

 *EMmsg = EMS_S_Success;
 to_owners.type = OM_e_addr;
 to_owners.u_sel.addr = &ME.GRconnector->to_owners;
  
 /*Since I send on up to everyone, an object may not understand this
  * message.  Therefore, I check the return code for this possiblity.
  */ 
 OM_stat = om$send(msg = OPPmargs, p_chanselect = &to_owners);
 if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;

 OM_stat = OM_S_SUCCESS; /*Fix the return code so wrapup doesn't complain.*/
  
 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMScomposite.EMcomponentchanged")
  return(OM_stat);
}
end implementation EMScomposite;
