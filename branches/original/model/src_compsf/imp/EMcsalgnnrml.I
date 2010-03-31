/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#include "EMSerrordef.h"
#include "emserr.h"

method EMalgnnrml ( IGRlong *EMmsg;
                    IGRushort options;
                    IGRshort *pos_orient;
                    IGRpoint point_in_solid;
                    struct GRmd_env *env) 

/* *********************************************************

Description

      This method will pass the align normal message to all the
      surfaces belonging to the composite surface

      Input
       point_in_solid    -     point lying inside the solid
       env               -     Module environment information
                               of the solid

      Output
       EMmsg             -     pointer to completion status

Notes

      Upon exit the completion code will be one of the following
        
       EMS_S_Success      -     if successful

Algorithm
 
 1.   Pass the message across channel to all the surfaces

History

   PP       :      01/01/87       design date
   DLB      :      10/30/87       channel conversion for version 1.1.0   

********************************************************* */

{

 IGRlong                status;        /* OM return status */
 OM_S_CHANSELECT        to_components; 


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 to_components.type = OM_e_addr;
 to_components.u_sel.addr = &ME.GRcmpowner->to_components;

 status = om$send (msg = message EMSsurface.EMalgnnrml (
                         EMmsg, options, pos_orient, point_in_solid, env),
                   p_chanselect = &to_components);
 if (! (1 & status & *EMmsg)) goto wrapup;

wrapup:
 EMWRAPUP(*EMmsg, status, "EMScompsurf.EMalgnnrml")
 return (status);

}
end implementation EMScompsurf;
