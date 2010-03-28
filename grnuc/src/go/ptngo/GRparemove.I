/* #######################    APOGEE COMPILED   ######################## */

class implementation GRpa;

#include "grimport.h"
#include "msdef.h"

method remove(IGRlong *msg)
{
    *msg = MSSUCC;
    return(OM_S_SUCCESS);
}
end implementation GRpa;
