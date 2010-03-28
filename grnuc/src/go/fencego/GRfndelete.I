/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRdelete

Description
   This method deletes the fence object.

Arguments
   *msg         IGRlong        completion code
   *mod_env     GRmd_env       mod_env structure 

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    10/08/88    Creation date.
   msm          07/09/92    ANSI-C conversion.
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "dpmacros.h"

method GRdelete(IGRlong *msg; struct GRmd_env *mod_env)
{
IGRlong              om_msg;
unsigned int         count;
OM_S_OBJECT_LINKAGE  list;
OM_S_CHANSELECT      chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   om_msg = om$get_channel_objects (objid = my_id,
            p_chanselect = &chansel, list = &list, size = 1,
            count = &count);

   if (om_msg & 1)
   {
      om_msg = om$cancel_intercept(osnum = list.osnum,
               objid = list.S_objid);

      if (om_msg & 1)
      {
         om_msg = om$send (msg = OPPmargs, p_chanselect = &chansel);
      }
   }
   return(om_msg);                                              
}
end implementation GRgsmgr;
