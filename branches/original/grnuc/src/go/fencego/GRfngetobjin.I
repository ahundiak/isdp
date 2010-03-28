/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRgetobjinfo

Description
   This routine reports information about the object.

Arguments
    *msg        IGRlong        completion code
    *info       GRobj_info     structure for information about the object

Algorithm
   This routine retrieves information about the object and stores
   it in the input structure.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    10/05/86    Creation date.
   Gray Winn    10/07/88    Updated for message interception
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "msmacros.h"
#include "grmessage.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
   *msg = MSSUCC;
   ex$message(msgnumb = GR_I_fence, buff = info->type);
   return(OM_S_SUCCESS);
}
end implementation GRgsmgr;
