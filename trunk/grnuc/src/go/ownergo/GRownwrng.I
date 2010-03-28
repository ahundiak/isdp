/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRownaddwrng
    
Description
    This method adds a component of an owner to the rtree with respect 
    to range.

    *msg        IGRlong              completion code
    *mod_env    struct GRmd_env      environment information
    *objid      GRobjid              objid of the component
    range       GRrange              range of component object

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
    Gray Winn      04/19/88    Creation date
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"

extern IGRint   GRget_to_owner_info();

from GRmodule  import   GRmdaddwrng, GRmdremove;

method GRownaddwrng(IGRlong *msg; 
                    struct GRmd_env *mod_env;
                    GRobjid *objid; 
                    GRrange range)
{
    IGRlong           om_msg;
    IGRint            count;
    IGRint            i;
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;
    
    if ( om_msg = GRget_to_owner_info ( &chansel,
                                        OM_Gw_current_OS,
                                        my_id,
                                        &count ) ) 
    {
        if (count) 
        {
            for (i=0; i < count; ++i) 
            {
                om_msg = om$send( msg = message GRcmpowner.GRownaddwrng(msg, 
                                                                        mod_env,
                                                                        objid, 
                                                                        range),
                                  p_chanselect = &chansel, 
                                  from = i, 
                                  to = i);

                if (om_msg == OM_I_STOP_SENDING) return (om_msg);
            }
        }

        /*
         *  None of my owners responded; add the component to the R-tree.
         */
        om_msg = om$send( msg = message GRmodule.GRmdaddwrng(msg, range, objid),
                          senderid = *objid,
                          targetid = mod_env->md_id.objid,
                          targetos = mod_env->md_id.osnum);

        if (om_msg & *msg & 1) om_msg = OM_I_STOP_SENDING;
    }

    return(om_msg);
}

/*\
Name
    GRownremwrng

Description
    This method removes a component of an owner from the rtree with 
    respect to range.
 
    *msg        IGRlong           completion code
    *mod_env    struct GRmd_env   environment information
    *objid      GRobjid           objid of the component
    range       GRrange           range of component object

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
    Gray Winn       04/19/88    Creation date
    jay wallingford 04/29/89    Optimized the making of chansel
\*/

method GRownremwrng(IGRlong *msg; 
                    struct GRmd_env *mod_env;
                    GRobjid *objid; 
                    GRrange range)
{
    IGRlong           om_msg;
    IGRint            count;
    IGRint            i;
    OM_S_CHANSELECT   chansel;


    *msg = MSSUCC;

    if ( om_msg = GRget_to_owner_info( &chansel,
                                       OM_Gw_current_OS,
                                       my_id,
                                       &count ) ) 
    {
        if (count) 
        {
            for (i=0; i < count; ++i) 
            {
                om_msg = om$send( msg = message GRcmpowner.GRownremwrng(msg, 
                                                                        mod_env,
                                                                        objid, 
                                                                        range),
                                  p_chanselect = &chansel, 
                                  from = i, 
                                  to = i);

                if (om_msg == OM_I_STOP_SENDING) return (om_msg);
            }
        }

        /*  
         *  None of my owners responded; delete the object from the R-tree
         */
        om_msg = om$send( msg = message GRmodule.GRmdremove(msg, range, objid),
                          senderid = *objid,
                          targetid = mod_env->md_id.objid,
                          targetos = mod_env->md_id.osnum);

        if (om_msg & *msg & 1) om_msg = OM_I_STOP_SENDING;
    }
 
    return(om_msg);
}
end implementation GRowner;
