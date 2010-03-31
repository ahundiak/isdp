/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#include "emserr.h"
#include "emsdef.h"
#include "emserr.h"

method EMrevorient (IGRlong *EMmsg)
/*
Description
    This method simply reverses the orientation of it's surfaces, by
    reversing the "pos_orient" bit in the surfaces. 

Return values
    EMS_S_Success if all is well

Notes
 
History
    DLB 10/30/87 modified channel for version 1.1.0
    DLB 3/31/87 creation
*/
{
  IGRint                OM_stat;
  OM_S_CHANSELECT       to_comps;


  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  to_comps.type = OM_e_addr;
  to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

  /*Reverse the orientation of all my comps*/
  OM_stat = om$send (msg = OPPmargs,
                     p_chanselect = &to_comps);
  if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMScompsurf.EMrevorient")
  return (OM_stat);
}
end implementation EMScompsurf;
