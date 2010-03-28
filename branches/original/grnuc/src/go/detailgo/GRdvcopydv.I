/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRcopy_drawing_view

Description
    This method is used to copy a drawing view.
 
Arguments
    *msg           IGRlong              completion code
    *mod_env       struct GRmd_env      The module environment
    *target_env    struct GRmd_env      The target environment
    *dv_id         GRobjid              The new drawing view

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Gray Winn      07/20/88      Coding Date
\*/

class implementation GRdrawview;

#include "grimport.h"
#include "msdef.h"
#include "grownerdef.h"
#include "gocmacros.h"

#define  OWNER                 1
#define  OWNER_PLUS_ONE        2

extern IGRint GRget_to_comp_chansel();

method GRcopy_drawing_view ( IGRlong *msg; 
                             struct GRmd_env *mod_env;
                             struct GRmd_env *target_env; 
                             GRobjid *dv_id )
{
    IGRlong              om_msg;
    IGRlong              ret_msg;
    IGRint               cleanup;
    IGRint               channel_type;
    IGRint               connection_type;
    GRobjid              go_objid;
    struct GRid          owner_id;
    struct GRmd_env      local_mod_env;
    struct GRmd_env      local_target_env;
    OM_S_CHANSELECT      chansel;

    *msg = MSSUCC;
    cleanup = 0;

    GRget_to_comp_chansel(&chansel);

    /*
     *  Make a copy of the owner.
     */
    owner_id.osnum = target_env->md_id.osnum;
    om_msg = om$send (msg = message GRowner.GRcopy_owner ( msg, 
                                                           mod_env, 
                                                           target_env, 
                                                           &owner_id.objid ), 
                      targetid = my_id);

    if (om_msg & *msg & 1) 
    {
        cleanup = OWNER;

        /*
         *  Get the type of connection (i.e. Rigid or Flexible )
         */
        om_msg = om$send ( msg = message GRowner.GRget_channel_type ( &ret_msg,
                                                                      &channel_type, 
                                                                      &connection_type ),
                           targetid = my_id);

        if (om_msg & ret_msg & 1) 
        {
            /*
             *  Get the local context of the elements.  It is neccessary
             *  to get the context of the new owner first so that when
             *  the old owner gets it context it will clear the abstract
             *  cache.
             */
            om$send (msg = message GRowner.GRget_context ( msg,
                                                           target_env, 
                                                           &local_target_env ), 
                     targetos = owner_id.osnum, 
                     targetid = owner_id.objid );
         
            om$send (msg = message GRowner.GRget_context ( msg, 
                                                           mod_env, 
                                                           &local_mod_env ), 
                     targetid = my_id);

            /*
             *  Copy the drawing attachment
             */
            om_msg = om$send ( msg = message GRdrawview.GRcopy_drawing_view
                                                        ( &ret_msg, 
                                                          &local_mod_env,
                                                          &local_target_env,
                                                          &go_objid ),
                               p_chanselect = &chansel, 
                               from = 0, 
                               to = 0 );

            if (om_msg & ret_msg & 1) 
            {
                cleanup = OWNER_PLUS_ONE;

                /*
                 *  Connect the copy of the component to the new owner.
                 */
                om_msg = GRconnect_object ( &ret_msg, 
                                            local_target_env.md_id.osnum, 
                                            go_objid,
                                            &owner_id, 
                                            channel_type, 
                                            connection_type,
                                            OM_K_MAXINT, 
                                            OM_K_MAXINT );

                if (om_msg & ret_msg & 1) cleanup = OWNER;
            }
        }
    }

    if (!( om_msg & ret_msg & 1)) 
    {
        *msg = MSFAIL;

        if (cleanup) 
        {
            /*
             *  Delete the owner and all components.
             */
            om_msg = om$send( msg = message GRgraphics.GRdelete ( &ret_msg, 
                                                                  target_env ),
                              targetid = owner_id.objid,
                              targetos = owner_id.osnum);
         
            if (cleanup == OWNER_PLUS_ONE) 
            {
                om_msg = om$send( msg = message GRgraphics.GRdelete ( &ret_msg, 
                                                                      &local_target_env ),
                                  targetid = go_objid, 
                                  targetos = local_target_env.md_id.osnum);
            }
        }
    }

    *dv_id = owner_id.objid;

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_COPIED);

    return (om_msg);
}
end implementation GRdrawview;
