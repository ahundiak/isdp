/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRremove_components

Description
    This method is used to remove a list of elements from owner.

    *msg           IGRlong              return code 
    *mod_env       struct GRmd_env      The current module enviroment
    *num_objects   IGRint               The number of objects
    *objects[]     struct GRobj_env     The list of elements to be removed.

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Gray Winn       09/15/87    Creation date.

\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "growner.h"
#include "gocmacros.h"

extern IGRint   GRget_to_comp_chansel();
extern IGRint   GRget_to_owner_chansel();

method GRremove_components( IGRlong *msg; 
                            struct GRmd_env *mod_env;
                            IGRint *num_objects; 
                            struct GRobj_env objects[])
{
    IGRlong             om_msg;
    IGRlong             ret_msg;
    OMuint              count;
    IGRint              i;
    OM_S_CHANSELECT     chansel, owner_chansel;
    struct GRid         my_GRid, *ids;

    *msg = MSSUCC;

    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    GRget_to_comp_chansel( &chansel );
    GRget_to_owner_chansel( &owner_chansel );

    ids = (struct GRid *) malloc (sizeof (struct GRid) * *num_objects);

    for (i = 0; i < *num_objects; ++i) 
    {
        ids[i] = objects[i].obj_id;

        /*
         *  Remove the object from the owner; only elements which are
         *  really components of the owner will respond to this message, so
         *  the return codes needn't be checked
         */
        om_msg = om$send ( msg = message GRconnector.GRdisconn (&ret_msg, 
                                                                &my_GRid),
                           targetid = objects[i].obj_id.objid,
                           targetos = objects[i].obj_id.osnum);
    }

    /*
     * Use the GRcomponent_idchanged method to connect this owners comps
     * to it's owners.
     */
    om_msg = om$send (msg = message GRcmpowner.GRcomponent_idchanged (&ret_msg,
                                                                      (short *)num_objects, 
                                                                      ids),
                      p_chanselect = &owner_chansel );

    om_msg = om$get_channel_count ( object = me, 
                                    p_chanselect = &chansel, 
                                    count = &count);

    /*
     *  Were all the elements removed?
     */
    if ((om_msg & 1) && (!count)) 
    {
        /*
         *  If all my elements were removed then delete myself.
         */
        om_msg = om$send ( msg = message GRowner.GRdelete_owner (msg, mod_env),
                           targetid = my_id);
    }        

    if (ids) free (ids);

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_CHANNEL_USED);

    return (OM_S_SUCCESS);
}
end implementation GRowner;
