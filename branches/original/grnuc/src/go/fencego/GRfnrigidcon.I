/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRrigidconn

Description
   This method does not allow rigid connections.

Arguments
   *msg              IGRlong           Return code
   *owners_id        struct GRid       The owners objid, osnum
   *owners_index     IGRlong           The index on the flexible
                                       owners channel

Return Values
   MSSUCC  -- successful completion

History
   Gray Winn    09/07/87    Creation date.
   mrm          07/06/89    return MSFAIL, since the object is not connecting
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "OMerrordef.h"
#include "msdef.h"

method   GRrigidconn(IGRlong *msg; struct GRid *owners_id; 
                     IGRlong *owners_index)
{
   *msg = MSFAIL;
   return(OM_S_SUCCESS);
}
end implementation GRgsmgr;
