class implementation GRflxown;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "gocmacros.h"

method GRchg_owner_properties (IGRlong *msg; IGRint action; IGRshort *mask)
{
    IGRlong om_msg;

    *msg = MSSUCC;
    om_msg = OM_S_SUCCESS;

    if (action == 0)
    {
       me->owner_properties = me->owner_properties &  ~*mask;   /* clear */
    }
    else if (action == 1)
    {
       me->owner_properties = me->owner_properties | *mask;     /* set   */
    }
    else if (action == 2)
    {
       me->owner_properties = *mask;                      /* replace     */
    }
    else
    {
       *msg = MSINARG;
       om_msg = OM_E_ABORT;
    }

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);

    return(om_msg);
}

end implementation GRflxown;
