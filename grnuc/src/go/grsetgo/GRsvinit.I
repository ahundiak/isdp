/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSsvinit

Description
   This method initializes a save set.

   *msg            IGRlong         return code
   *path           GRmd_env        Structure containing the new module
                                   environment.
   *env_properties IGRint          Properties of the environment.
   *preset         IGRint          An approximation of the number of
                                   elements that may be added to the
                                   save set channel.    

Note
   The preset variable maybe NULL.
   The path variable maybe NULL.
   The env_properties variable maybe NULL.
   If the preset variable is specified, call the GSunpreset message
   to collapse the channel.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "OMerrordef.h"

method GSsvinit (IGRlong *msg; struct GRmd_env *path;
                 IGRint *env_properties; IGRint *preset)
{
IGRlong           om_msg;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Init instance data.
    */

   if (path)  me->path = *path;

   if (env_properties) 
   {
      me->properties |= *env_properties & GSIS_SV_PROP_MASK;
   }

   if (preset && *preset > 0)
   {
      om_msg = om$channel_preset (p_chanselect = &chansel, size = *preset);
   }

   return ( om_msg );
}
end implementation GRsvset;
