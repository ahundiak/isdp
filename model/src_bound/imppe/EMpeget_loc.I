/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "EMSbnddef.h"
#include "emsmacros.h"

method EMget_location(IGRlong *EMmsg;
                      IGRshort *location)
/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure
                - EMS_E_EdgeError error in edge method
Assumption
           this edge is part edge whose owner is a natural edge
Bugs

History
	
	  gupta 	05/04/87:	design date
                10/19/87:   change to new class structure
Algorithm

      This method passes on the message for getting the location
      to its owners until it hits the natural edge. The location
      corresponds to this natural edge 
*/

{

  IGRlong			stat_OM,msg;
  OM_S_CHANSELECT	to_comps;

/*-------------------------------------------------------------------*/
 
  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  to_comps.type = OM_e_addr;
  to_comps.u_sel.addr = &ME.EMSbd_owner->to_comps;

  stat_OM = om$send(msg = message EMSedge.EMget_location(&msg,
                          location),
                    p_chanselect = &to_comps);
  EMomerr_hndlr(stat_OM, wrapup, "EMpeget_loc.EMget_location");
  EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

  wrapup:

  return(stat_OM);
}

end implementation EMSpartedge;
