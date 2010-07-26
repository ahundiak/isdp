/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRdelete

Description
    This method will delete the owner object and all of its components.

    *msg         IGRlong               Completion code
    *mod_env     struct GRmd_env       Module environment structure 

Notes
    This method should perform the following steps:
       -  Get all components.
       -  Delete the owner object.
       -  Delete the components.

Return Values
    MSSUCC   if successful
    MSFAIL   if failure

History
    Gray Winn       09/09/87    Creation date
    jay wallingford 04/27/89    Optimized the getting the to_components chanselect
    WBC             12/02/91    If the owner is associative, send the message
                                NDparent_deleted to its children.
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "gocmacros.h"

extern IGRint   GRget_to_comp_info();

from NDnode import NDparent_deleted;


method GRdelete (IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    IGRint            count;
    IGRint            i;
    IGRchar           *buffer;
    OM_S_CHANSELECT   chansel;
    struct GRmd_env   local_mod_env;
    struct GRid       my_GRid;
   
    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;
    buffer = (IGRchar *)NULL;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    /* 
     *  Get the number of objects on my channel.
     */
    om_msg = GRget_to_comp_info ( &chansel,
                                  OM_Gw_current_OS,
                                  my_id,
                                  &count ); 
    if ((om_msg & 1) && count) 
    {
        /*
         *  Get the components 
         */
        if (buffer = om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) * count))
        {
            om_msg = om$get_channel_objects (object = me, 
                                             p_chanselect = &chansel, 
                                             list = (OM_S_OBJECT_LINKAGE *)buffer, 
                                             size = count, 
                                             count = (OMuint *)&count);

            if (om_msg & 1) 
            {
                om_msg = om$send (msg = message GRowner.GRget_context
                                                        (msg,
                                                         mod_env, 
                                                         &local_mod_env), 
                                  targetid = my_id);
            }
        }
        else 
        {
            *msg = MSFAIL;
            om_msg = OM_E_ABORT;
        }
    }

    if (om_msg & *msg & 1) 
    {
        /* notify any children one of their parents is being deleted */

        if (me->properties & GRIS_ASSOCIATIVE)
        {
            struct GRid  new_grid;

            om$make_chanselect(channame = "NDchildren.children",
                              p_chanselect = &chansel);

            om$send (msg = message NDnode.NDparent_deleted(&ret_msg, 1,
                                                           &my_GRid, &new_grid,
                                                           mod_env),
                     p_chanselect = &chansel);
        }

        /* 
         *  Delete the owner object.
         */
        om_msg = om$send(msg = message GRowner.GRdelete_owner (msg, 
                                                               mod_env),
                         targetid = my_id );
        if (om_msg & *msg & 1) 
        {
            for (i=0; i < count; i++) 
            {
                /*
                 *  Disconnect the graphics object from the owner.
                 */
                om_msg = om$send (msg = message GRconnector.GRdisconn 
                                                        (msg, &my_GRid),
                                  targetos = ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum,
                                  targetid = ((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid);
        
                /*
                 *  Delete the graphics object.
                 */
                om_msg = om$send(msg = message GRgraphics.GRdelete 
                                                        (msg,
                                                         &local_mod_env),
                                 targetos = ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum,
                                 targetid =((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid);
            }
        }
    }

    if (buffer) om$dealloc (ptr = buffer);

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_DELETED);

    return (om_msg);
}
end implementation GRowner;
