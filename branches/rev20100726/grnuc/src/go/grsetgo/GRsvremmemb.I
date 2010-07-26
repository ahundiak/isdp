/*
Name
        GRremove_member

Description
        This method is used to remove a member of the graphics set.  The
        member does not necessarily have to belong to the graphics set.

Notes
        This method checks whether the member to be removed is in the current
        object space.  If it is not, then there is zero chance that it is
        actually connected to the save set, since the channel is restricted.
        Before this check was installed, a customer file floated through in
        which a fence was not where it was expected to be (in channel terms),
        and the code crashed shortly after passing through here (see
        TR119301259).  This additional check prevents that crash, and maybe
        makes things a bit more efficient by preventing unnecessary sends.

Synopsis
        IGRlong *msg                Return code
        struct GRid *member_id      The member id

Return Values
        MSSUCC   -  if successful.
        MSFAIL   -  if failure.

History
        hgw     04/21/88    Creation date
        mrm     02/17/93    added check for same osnum
*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"

from GRconnector import GRdisconn;

method GSremove_member (IGRlong *msg; struct GRid *member_id)
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    struct GRid       my_GRid;

    *msg = MSSUCC;

    /* check whether member is in current space */

    if (member_id->osnum == OM_Gw_current_OS)
    {
        my_GRid.osnum = OM_Gw_current_OS;
        my_GRid.objid = my_id;

        /* remove the member from the set */

        om_msg = om$send(msg = message GRconnector.GRdisconn(&ret_msg,
                                                             &my_GRid),
                         targetid = member_id->objid,
                         targetos = member_id->osnum);
    }
    return ( OM_S_SUCCESS);
}

end implementation GRsvset;
