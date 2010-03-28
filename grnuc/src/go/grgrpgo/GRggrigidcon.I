/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRrigidconn

Description
   This method will flatten the graphics group.

   *msg              IGRlong           Return code
   *owners_id        struct GRid       The owners objid, osnum
   *owners_index     IGRlong           The index on the flexible
                                       owners channel

Return Values
   MSSUCC  -- successful completion

History
   Gray Winn    09/07/87    Creation date.
\*/

class implementation GRgrgrp;

#include "grimport.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "grerr.h"

method   GRrigidconn(IGRlong *msg; struct GRid *owners_id; 
                     IGRlong *owners_index)
{
IGRlong           om_msg;
OM_S_CHANSELECT   chansel;

   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   om_msg = om$send (
            msg = message GRconnector.GRrigidconn (msg, owners_id,
            owners_index), p_chanselect = &chansel);

   if (om_msg & *msg & 1)
   {
      *msg = GR_I_CPXFLATTEN;
   }
   return(om_msg);
}
end implementation GRgrgrp;
