/* #######################    APOGEE COMPILED   ######################## */
/*\
Name

Description
   This method is a pre clip message sent to the fence so that it will
   know whether to be inside or outside.

Arguments
   *msg         IGRlong        completion code
   *mode        IGRshort       flag -  GRFN_CLIP_INSIDE
                                    -  GRFN_CLIP_OUTSIDE
Return Values
   MSSUCC  -- successful completion

History
   Gray Winn    02/24/87    Creation date.
   Gray Winn    10/07/88    Updated for message interception
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grgsdef.h"

method GRpre_clip(IGRlong *msg; IGRshort *mode)
{
   *msg = MSSUCC;
   me->fence_properties |= 
         (*mode & (GRFN_CLIP_INSIDE | GRFN_CLIP_OUTSIDE));
   return (OM_S_SUCCESS);
}

end implementation GRgsmgr;
