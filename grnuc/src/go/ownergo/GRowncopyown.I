/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRcopy_owner

Description
    The method is used to copy the header object and not the components.

    *msg           IGRlong              return code 
    *mod_env       struct GRmd_env      The module environment
    *target_env    struct GRmd_env      The target environment
    *owner_id      GRobjid              The new owner

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Gray Winn       09/15/87    Creation Date
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "grownerdef.h"

method GRcopy_owner (IGRlong *msg; 
                     struct GRmd_env *mod_env;
                     struct GRmd_env *target_env; 
                     GRobjid *owner_id)
{
    IGRlong              om_msg;
    IGRshort             properties;
    IGRshort             action;

    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;
    action = -1;

    /*
     *  Make a copy of the owner.
     */
    om_msg = om$construct_and_copy ( object = me,
                                     obj_osnum = OM_Gw_current_OS, 
                                     osnum = target_env->md_id.osnum,
                                     p_objid = owner_id);

    if (om_msg & 1) 
    {
       /*
        *  Change the properties of the element.
        *  Set the new bit.  Clear the modified and component.
        */
       properties = me->properties & 
                    (~GR_RIGID_RELATIONSHIP) &
                    (~GRIS_MODIFIED) & 
                    (~GRNOT_IN_RTREE) | 
                    GRIS_NEW;

       om_msg = om$send (msg = message GRgraphics.GRchgprops (msg, 
                                                              &action, 
                                                              &properties),
                         targetos = target_env->md_id.osnum, 
                         targetid = *owner_id);
    }

    om$send (msg = message GRowner.GRadd_to_active_owner (msg, target_env),
             targetos = target_env->md_id.osnum, 
             targetid = *owner_id);
      
    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_COPIED);

    return (om_msg);
}
end implementation GRowner;
