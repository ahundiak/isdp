/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRcopy

Description
    This method will  send a message to each of its components to copy
    and then connect themselves to the new owner.  The new owner id will
    be returned in newobjid.

    *msg         long          Completion code
    *mod_env     struct GRmd_env  Module environment structure 
    *target_env  struct GRmd_env  The target environment structure 
    *newobjid    GRobjid          Objid of the transformed object

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
    Gray Winn       09/08/87    Coding Date
    jay wallingford 04/27/89    Optimized method of getting to_components chansel
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "grownerdef.h"
#include "gocmacros.h"
#include "OMmacros.h"

#define  OWNER                 1
#define  OWNER_PLUS_ONE        2

extern int   GRget_to_comp_info();

method GRcopy( long *msg; 
               struct GRmd_env *mod_env;
               struct GRmd_env *target_env; 
               GRobjid *new_objid)
{
    long              om_msg;
    long              ret_msg;
    int               i;
    int               cleanup;
    int               channel_type;
    int               connection_type;
    GRobjid              go_objid;
    unsigned int      count;
    struct GRid          owner_id;
    struct GRmd_env      local_mod_env;
    struct GRmd_env      local_target_env;
    OM_S_CHANSELECT      chansel;

    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;
    cleanup = 0;

    /*
     *  Get the number of components.
     *  This must be done first to avoid problems with active owners.
     */
    if ( om_msg = GRget_to_comp_info(&chansel,
                                     OM_Gw_current_OS,
                                     my_id,
                                     &count) ) 
    {
        /*
         *  Make a copy of the owner.
         */
        owner_id.osnum = target_env->md_id.osnum;
        om_msg = om$send (msg = message GRowner.GRcopy_owner (msg, 
                                                              mod_env, 
                                                              target_env, 
                                                              &owner_id.objid), 
                          targetid = my_id);

        if (om_msg & *msg & 1) 
        {
            cleanup = OWNER;

            /*
             *  Get the type of connection (i.e. Rigid or Flexible )
             */
            om_msg = om$send (msg = message GRowner.GRget_channel_type 
                                               (&ret_msg,
                                                &channel_type, 
                                                &connection_type),
                              targetid = my_id);

            if ((om_msg & ret_msg & 1) && count) 
            {
                /*
                 *  Get the local context of the elements.  It is neccessary
                 *  to get the context of the new owner first so that when
                 *  the old owner gets it context it will clear the abstract
                 *  cache.
                 */
                om_msg = om$send (msg = message GRowner.GRget_context 
                                                    (msg,
                                                     target_env, 
                                                     &local_target_env), 
                                  targetos = owner_id.osnum, 
                                  targetid = owner_id.objid);
          
                om_msg = om$send (msg = message GRowner.GRget_context
                                                    (msg, 
                                                     mod_env, 
                                                     &local_mod_env), 
                                  targetid = my_id);
 
                for (i=0; i < count; ++i) 
                {
                    /*
                     *  Copy the component
                     */

                  if(ASMget_splitpart() == TRUE) 
                   if(IF_NULL_OBJID(local_target_env.md_id.objid))
                     local_target_env.md_id.objid = local_mod_env.md_id.objid;

                    om_msg = om$send( msg = message GRgraphics.GRcopy 
                                                    (&ret_msg, 
                                                     &local_mod_env, 
                                                     &local_target_env, 
                                                     &go_objid),
                                      p_chanselect = &chansel, 
                                      from = i, 
                                      to = i);
 
                    if (om_msg & ret_msg & 1) 
                    {
                        cleanup = OWNER_PLUS_ONE;

                        /*
                         *  Connect the copy of the component to the 
                         *  new owner.
                         */
                        om_msg = GRconnect_object (&ret_msg, 
                                                   local_target_env.md_id.osnum, 
                                                   go_objid,
                                                   &owner_id, 
                                                   channel_type, 
                                                   connection_type,
                                                   OM_K_MAXINT, 
                                                   OM_K_MAXINT);

                       if (om_msg & ret_msg & 1) cleanup = OWNER;
                    }
                }
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
            om_msg = om$send(msg = message GRgraphics.GRdelete (&ret_msg, 
                                                                target_env),
                             targetid = owner_id.objid,
                             targetos = owner_id.osnum);
          
            if (cleanup == OWNER_PLUS_ONE) 
            {
                om_msg = om$send(msg = message GRgraphics.GRdelete 
                                                    (&ret_msg, 
                                                     &local_target_env),
                                 targetid = go_objid, 
                                 targetos = local_target_env.md_id.osnum);
            }
        }
    }

    *new_objid = owner_id.objid;

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_COPIED);

   return (om_msg);
}

end implementation GRowner;
