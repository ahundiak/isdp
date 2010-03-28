class implementation GRflxown;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "gocmacros.h"

/*\
Name
   GRget_locate_properties

Description
   This method is used to get the owner's locate properties.

   *msg           IGRlong           completion code 
   *properties    IGRint            The allowable properties:
                                       -  GR_LC_CMP_READ
                                       -  GR_LC_CMP_WRITE
                                       -  GR_LC_CMP_PRM_READ
                                       -  GR_LC_CMP_PRM_WRITE
                                       -  GR_LC_OWN_READ
                                       -  GR_LC_OWN_WRITE
                                       -  GR_LC_OWN_PRM_READ
                                       -  GR_LC_OWN_PRM_WRITE
                                       -  GR_LC_RIGID
                                       -  GR_LC_FLEXIBLE
                                       -  GR_LC_NO_PRM_COMP

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/

method GRget_locate_properties (IGRlong *msg; IGRint *properties)
{
    IGRlong     om_msg;
    IGRshort    prop;

    *msg = MSSUCC;
    om_msg = om$send (msg = message GRowner.GRget_owner_properties (msg, &prop),
                      targetid = my_id);

    *properties = GR_LC_CMP_READ        |
                  GR_LC_CMP_WRITE       |
                  GR_LC_OWN_READ        |
                  GR_LC_OWN_WRITE       |
                  GR_LC_FLEXIBLE;

    if (prop & GR_SPATIAL)
    {
       *properties = *properties           |
                     GR_LC_OWN_PRM_READ    |
                     GR_LC_OWN_PRM_WRITE;
    }
    else
    {
       *properties = *properties           |
                     GR_LC_CMP_PRM_READ    |
                     GR_LC_CMP_PRM_WRITE;
    }
    return (OM_S_SUCCESS);
}


end implementation GRflxown;
