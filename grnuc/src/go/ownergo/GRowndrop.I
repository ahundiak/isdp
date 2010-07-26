/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRdrop

Description
    This method is used to drop the grouping status (i.e. dissolve 
    the group).

    *msg           IGRlong              return code 
    *mod_env       struct GRmd_env      The module environment

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Gray Winn       09/15/87    Creation date
    jay wallingford 04/27/89    Optimized the making of the chanselects
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "gocmacros.h"

extern IGRint   GRget_to_comp_info();
extern IGRint   GRget_to_owner_info();

method GRdrop  (IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong           om_msg, ret_msg;
    IGRint            ii;
    IGRint            owner_count, component_count;
    OMuint            count;
    OM_S_CHANSELECT   owner_chansel, component_chansel;
    struct GRid       my_GRid, *ids;
    OM_p_OBJECT_LINKAGE list_ids = NULL;

    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;
    my_GRid.osnum = OM_Gw_current_OS;
    my_GRid.objid = my_id;

    component_count = 0;
    GRget_to_comp_info ( &component_chansel,
                         OM_Gw_current_OS,
                         my_id,
                         &component_count );

    owner_count = 0;
    GRget_to_owner_info ( &owner_chansel,
                          OM_Gw_current_OS,
                          my_id,
                          &owner_count );
                
    /*
     *  If there are any owners simply change who the components belong to.
     *  Then send the new owner a GRcomponent_idchanged message so that
     *  the owner is aware of the change in its components.
     *
     *  Otherwise disconnect the elements from the owner.
     */
    if (owner_count && component_count) 
    {
        list_ids = (OM_p_OBJECT_LINKAGE) malloc 
                ( (sizeof (OM_S_OBJECT_LINKAGE)) * component_count);

        om_msg = om$get_channel_objects (object = me, 
                                         p_chanselect = &component_chansel,
                                         list = list_ids, 
                                         size = component_count,
                                         count = &count);

        ids = (struct GRid *) malloc 
                ( (sizeof (struct GRid)) * component_count);

        for (ii = 0; ii < component_count; ii++) 
        {
            ids[ii].objid = list_ids[ii].S_objid;
            ids[ii].osnum = list_ids[ii].osnum;

            om_msg = om$send (msg = message GRconnector.GRdisconn (&ret_msg, 
                                                                   &my_GRid),
                              targetid = ids[ii].objid,
                              targetos = ids[ii].osnum);
        }

        /*
         * The GRcomponent_idchanged method will cause the component ids
         * in the list to be added to this owner's owner. This message
         * should be sent to all owners of this owner.
         */
        om_msg = om$send (msg = message GRcmpowner.GRcomponent_idchanged 
                                                       (msg,
                                                        (short *)&component_count, 
                                                        ids),
                          p_chanselect = &owner_chansel );

        if (list_ids) free (list_ids);

        if (ids) free (ids);
    }   
    else 
    {
        if (component_count) 
        {
            for (ii=component_count - 1; ii >= 0; ii--) 
            {
               /*
                *  Disconnect all the components.
                */
               om_msg = om$send(msg = message GRconnector.GRdisconn (msg, 
                                                                     &my_GRid),
                                p_chanselect = &component_chansel, 
                                from = ii, 
                                to = ii);
            }
        }
    }
       
    /*
     *  Delete the owner object.
     */
    om_msg = om$send( msg = message GRowner.GRdelete_owner(msg, mod_env),
                      targetid = my_id);

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_DELETED);

    return (om_msg);
}
end implementation GRowner;
