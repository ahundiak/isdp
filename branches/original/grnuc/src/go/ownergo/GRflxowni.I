/* #######################    APOGEE COMPILED   ######################## */
class implementation GRflxown;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "gocmacros.h"

/*\
Name
   GRget_channel_type

Description
   This method is used to get the type of channel (i.e. Rigid or Flexible).

   *msg           IGRlong              return code 
   *type          IGRint               The type of channel
                                          GR_RIGID
                                          GR_FLEXIBLE
   *conn_type     IGRint               Override the flexible connection
                                          GR_OVERRIDE
                                          GR_NO_OVERRIDE

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/

method GRget_channel_type (IGRlong *msg; IGRint *type; IGRint *conn_type)
{
   *msg = MSSUCC;
   *type = GR_FLEXIBLE;
   *conn_type = GR_NO_OVERRIDE;
   return (OM_S_SUCCESS);
}

method GRget_owner_properties (IGRlong *msg; IGRshort *properties)
{
    *msg = MSSUCC;
    *properties = me->owner_properties;
    return (OM_S_SUCCESS);
}
end implementation GRflxown;
