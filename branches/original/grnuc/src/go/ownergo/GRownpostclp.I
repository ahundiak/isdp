/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRpost_clip_owner

Description
    This method is sent to an owner object after the clip operation is 
    performed.  This method allows the owner to update its geometry based
    upon its new components.  If the owner has no components it should
    delete itself.

Arguments
    *msg         IGRlong             completition code
    *mod_env     struct GRmd_env     The originial module environment.
    *target_env  struct GRmd_env     The target environment.
    *prism       IGRchar             The right prism to clip against.
    *inside_id   struct GRid         The object id of the inside owner.
    *outside_id  struct GRid         The object id of the outside owner.
    *overlap_id  struct GRid         The object id of the overlapping owner.
    *clip_flag   IGRlong             The flag describing the type of clip.

Return Values
    MSSUCC  -- successful completion
    MSFAIL  -- failure

History
    Gray Winn    10/27/87    Creation date.
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "godef.h"
#include "grownerdef.h"
#include "grerr.h"
#include "gocmacros.h"

method GRpost_clip_owner ( IGRlong *msg; 
                           struct GRmd_env *mod_env; 
                           struct GRmd_env *target_env; 
                           IGRchar *prism; 
                           struct GRid *inside_id; 
                           struct GRid *outside_id;
                           struct GRid *overlap_id; 
                           IGRlong *clip_flag)
{
    IGRlong  om_msg;
    IGRint   count;

    *msg = MSSUCC;

    /* 
     *  Get the number of components.
     */
    om_msg = om$send ( msg = message GRowner.GRget_number_components(msg, &count),
                       targetid = my_id);

    if ((om_msg & *msg & 1) && (!count)) 
    {
        /*
         *  Delete the owner if it does not have any children.
         */
        om_msg = om$send ( msg = message GRowner.GRdelete (msg, target_env),
                           targetid = my_id);
    }

    return (om_msg);
}
end implementation GRowner;

