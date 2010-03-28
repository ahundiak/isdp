/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRpa.GRget_locate_properties

Description
            This method is overridden to disallow location of any
        individual components of the pattern.

History
        mrm     02/08/88    creation
        scw     06/28/92    ANSI conversion
*/
class implementation GRpa;

#include "grimport.h"
#include "msdef.h"
#include "grownerdef.h"

method GRget_locate_properties (IGRlong *msg; IGRint *properties)
{
    *msg = MSSUCC;
    *properties = GR_LC_OWN_READ      |
                  GR_LC_OWN_WRITE     |
                  GR_LC_OWN_PRM_READ  |
                  GR_LC_OWN_PRM_WRITE |
                  GR_LC_RIGID;

    return (OM_S_SUCCESS);
}

end implementation GRpa;
