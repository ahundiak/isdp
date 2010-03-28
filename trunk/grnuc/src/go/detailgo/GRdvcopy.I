/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRcopy

Description
    This method will  send a message to each of its components to copy
    and then connect themselves to the new owner.  The new owner id will
    be returned in newobjid.

    *msg         IGRlong          Completion code
    *mod_env     struct GRmd_env  Module environment structure 
    *target_env  struct GRmd_env  The target environment structure 
    *newobjid    GRobjid          Objid of the transformed object

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
    Gray Winn 11/23/88      Coding Date
    jhw       12/18/88      Clear active owner if active owner is a dv
\*/

class implementation GRdrawview;

#include "grimport.h"
#include "msdef.h"
#include "grownerdef.h"
#include "grownmacros.h"
#include "gocmacros.h"
#include "OMmacros.h"

method GRcopy ( IGRlong *msg; 
                struct GRmd_env *mod_env;
                struct GRmd_env *target_env; 
                GRobjid *new_objid)
{
    IGRlong              om_msg, ret_msg;
    IGRint               save_active_owner;
    GRclassid            act_own_classid;
    GRclassid            GRdrawview_class_id;
    struct GRid          act_own_id;

    *msg = MSSUCC;

    /*
     * Get the objid of the active owner. "ret_msg" will equal MSFAIL if there
     * is not an active owner.
     */
    om_msg = gr$get_active_owner ( msg = &ret_msg, 
                                   mod_id = &mod_env->md_id,
                                   active_owner = &act_own_id );

    if (!(om_msg  &  1)) 
    {
        om_msg = OM_S_SUCCESS;
        ret_msg = MSFAIL;
    }

    /*
     * If there was an active owner clear it.
     */
    if ( ret_msg & 1 ) 
    {
        om$get_classid ( osnum = act_own_id.osnum, 
                         objid = act_own_id.objid, 
                         p_classid = &act_own_classid);

        om$get_classid ( classname = "GRdrawview",
                         p_classid = &GRdrawview_class_id);

        /*
         *  Temporary clear the active owner if the active owner is a
         *  drawing view.
         */
        if (act_own_classid == GRdrawview_class_id)
        {
            save_active_owner = GRactive_owner_temp_clear (NULL);
        }
    }
    
    om_msg = om$send (mode = OM_e_wrt_message, 
                      msg = message GRowner.GRcopy ( msg, 
                                                     mod_env, 
                                                     target_env, 
                                                     new_objid ),
                      targetid = my_id);

    /*
     * If there was a active owner make it active again.
     */
    if ( ret_msg & 1 ) 
    {
        /*
         *  Restore the active owner if there is an active owner and it is another 
         *  drawing view.
         */
        if ( (act_own_classid == GRdrawview_class_id) &&
             (ret_msg & 1) ) 
        {
            GRactive_owner_temp_clear (&save_active_owner);
        }
    }

    return (om_msg);
}
end implementation GRdrawview;
