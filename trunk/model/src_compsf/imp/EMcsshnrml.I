/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
/*
Description
   PPPPPPPPAAAAAAAASSSSSSSSSSSSSSSS        OOOOOOOONNNNNNNN!!!!!!!!

Return values
   EMS_S_Success if all goes well

History
   SS  x/x/87 creation
   DLB 10/30/87 modified channel for version 1.1.0
*/

#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "emserr.h"

method EMshow_normals (IGRlong *EMmsg;
                       struct GRmd_env *env;
                       struct IGRdisplay *active_display;
                       enum GRdpmode display_mode)

{
 IGRlong                status;
 OM_S_CHANSELECT        to_components;

 status = OM_S_SUCCESS;
 *EMmsg =  EMS_S_Success;
 
 status = om$make_chanselect(chanaddr = &ME.GRcmpowner->to_components,
                             p_chanselect = &to_components);
 if (! (1 & status)) goto wrapup;

 status = om$send (msg = OPPmargs,
                   p_chanselect = &to_components);
 if (! (1 & status & *EMmsg)) goto wrapup;

wrapup:
 EMWRAPUP( *EMmsg, status, "In EMScompsurf: EMshow_normals error")
 return (status);
}
end implementation EMScompsurf;
