/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRflexconn

Description
   This method will flatten the graphics group for all connections
   that do not have the override privilege.

   *msg              IGRlong           Return code
   *flag             IGRlong           Flag indicating action to be
                                       taken if a rigid owner exists
                                          0 - do not connect object
                                          1 - connect object
   *owners_id        struct GRid       The owners objid, osnum
   *owners_index     IGRlong           The index on the flexible
                                       owners channel
   *graphics_index   IGRlong           The index on the graphics
                                       object channel

Return Values
   MSSUCC  -- if successful
   MSFAIL  -- if failure
History
   Gray Winn    09/07/87    Creation date.
\*/

class implementation GRgrgrp;

#include "grimport.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "grerr.h"
#include "grownerdef.h"

method   GRflexconn(IGRlong *msg; IGRlong *flag; struct GRid *owners_id; 
                    IGRlong *owners_index; IGRlong *graphics_index)
{
IGRlong           om_msg;
OM_S_CHANSELECT   chansel;

   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   if (*flag & GR_OVERRIDE)   /* Override */
   {
      om_msg = om$send (mode = OM_e_wrt_message,
               msg = message GRconnector.GRflexconn (msg, flag, owners_id,
               owners_index, graphics_index),
               targetid = my_id);
   }else
   {
      om_msg = om$send (
               msg = message GRconnector.GRflexconn (msg, flag, owners_id,
               owners_index, graphics_index),
               p_chanselect = &chansel);

      if (om_msg & *msg & 1)
      {
         *msg = GR_I_CPXFLATTEN;
      }
   }
   return(om_msg);
}
end implementation GRgrgrp;
