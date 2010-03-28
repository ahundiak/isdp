class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"

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

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.
\*/

method GRget_locate_properties (IGRlong *msg; IGRint *properties)
{
    *msg = MSSUCC;
    *properties = GR_LC_CMP_READ        |
                  GR_LC_CMP_WRITE       |
                  GR_LC_OWN_READ        |
                  GR_LC_OWN_WRITE       |
                  GR_LC_OWN_PRM_READ    |
                  GR_LC_OWN_PRM_WRITE   |
                  GR_LC_RIGID;  

    return (OM_S_SUCCESS);
}
end implementation GRowner;
