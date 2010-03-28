/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRcomponent_disconnecting

Description
   This method notifies a owner that one of his components is disconnecting
   from the "GRcmpowner.to_components" channel.

   *msg        IGRlong           completion code
   *mod_env    struct GRmd_env   environment information
   *comp_id    struct GRid       Object id of the component

Notes
   The owner is responsible for disconnecting the components if the
   owner is deleting himself.  If the owner does not disconnect the
   components before a delete then an infinite loop could occur.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn      04/19/87    Creation date
\*/

class implementation GRflxown;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "gocmacros.h"
#include "godef.h"

extern IGRint GRget_to_comp_info();

method GRcomponent_disconnecting ( IGRlong *msg; 
                                   struct GRmd_env *mod_env;
                                   struct GRid *comp_id )
{
    IGRlong           om_msg;
    IGRint            count;
    struct GRid       my_GRid;
    OM_S_CHANSELECT   chansel;

    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    if ( om_msg = GRget_to_comp_info ( &chansel, 
                                       OM_Gw_current_OS,
                                       my_id,
                                       &count) ) 
    {
        if (count == 1) 
        {

            /*
             *  Only one object exists on the channel disconnect the object.
             */
            om_msg = om$send( msg = message GRconnector.GRdisconn (msg, 
                                                                   &my_GRid),
                              targetid = comp_id->objid,
                              targetos = comp_id->osnum);

            count = 0;
        }

        if (!count) 
        {
            om_msg = om$send ( msg = message GRgraphics.GRdelete (msg, 
                                                                  mod_env),
                               targetid = my_id);
        }

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_CHANNEL_USED);
    }

    return (om_msg);
}
end implementation GRflxown;
