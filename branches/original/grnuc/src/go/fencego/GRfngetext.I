/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRget_prism_extents

Description
   This method returns the range of the prism.

Arguments
   *msg        IGRlong             o   completion code
   *mod_env    struct GRmd_env     i   The module environment. 
   range       GRrange             o   Prism range

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn   10/18/88    Creation Date
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "gocmacros.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grgsdef.h"

from GRvg   import   GRgenabsg;

method GRget_prism_extents (IGRlong *msg; struct GRmd_env *mod_env;
                            GRrange range)
{
IGRlong              om_msg;
IGRint               prism_type;
IGRint               total_size;
IGRchar              *buffer;

   *msg = MSSUCC;
   buffer = (IGRchar *)NULL;

   om_msg = om$send (msg = message GRgsmgr.GRget_prism_size (msg, mod_env,
            &prism_type, &total_size, NULL, NULL, NULL, NULL),
            targetid = my_id);

   if (buffer = om$malloc (size = total_size))
   {
      om_msg = om$send (msg = message GRgsmgr.GRget_prism (msg, mod_env,
               0, buffer, NULL), targetid = my_id);

      if (prism_type == GR_RIGHT_PRISM)
      {
         MArpextents (msg, buffer, range, &range[3]);
      }else
      {
         MAcpextents (msg, buffer, range, &range[3]);
      }
   }

   if (buffer) om$dealloc (ptr = buffer);
   return(om_msg);
}
end implementation GRgsmgr;
