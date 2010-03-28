/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRflexconn

Description
   This method does not allow flexible connections unless the override
   flag is set.

Arguments
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
   MSSUCC  -- successful completion

History
   Gray Winn    09/07/87    Creation date.
   Gray Winn    10/07/88    Updated for message interception
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "OMerrordef.h"
#include "msdef.h"

method   GRflexconn(IGRlong *msg; IGRlong *flag; struct GRid *owners_id; 
                    IGRlong *owners_index; IGRlong *graphics_index)
{
IGRlong  om_msg;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   if (*flag)   /* Override */
   {
      om_msg = GRpass_on_to_fence (OM_Gw_current_OS, my_id, OPPmargs);
   }
   return(om_msg);
}
end implementation GRgsmgr;
