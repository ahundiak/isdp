/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
    This file contains the code needed to implement the active owner
    manager.
    
History
    Gray Winn       07/18/88    Creation date.
    jay wallingford 05/15/89    Added override for Root.connect to fix owner 
                                drop problem.
    jhw             06/01/89    Optimized the making of the to_comp chansel
    jhw             06/15/89    Added support for the CODrawviewActive flag
    scw             08/09/94    Clarified sleep method

Note
    In 1.2.0 there was a problem when an element was removed from the active
    owner. That element would be added to the active owner manager's to_comp
    channel at slot 0. This caused the active owner to NOT be active any
    more. If the user changed active owners the channel would be cleared by
    the GRclear_active_owner method and everything would be hunky dorrie 
    until they removed another element from the active owner.

    Two changes were required to fix this problem. (1) The Root.connect
    method was overridden to insure that only one object was allowed on the
    to_components channel. (2) The global_class.wakeup method was changed to
    disconnect all but the last object on the to_components channel of the
    active owner manager. This corrects any files which were saved with this
    problem.

    The CODrawviewActive flag supports the scaling of user input when a 
    drawing view is active.
\*/

class implementation GRactownmgr;

#include "OMerrordef.h"
#include "msdef.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "OMmacros.h"
#include "grownerdef.h"
#include "exmacros.h"
#include "grownmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

#define  GR_ACTIVE_OWNER   "GRactive_owner"

extern GRget_to_comp_chansel();
extern GRget_to_comp_info();

from GRowner      import   GRadd_components;
from GRconnector  import   GRdisconn;

/*
 *  The GR_ACTIVE_OWNER_ON flag signifies if an active owner is defined.
 *  The active owner manager mantains this flag.  It is initialized to
 *  FALSE in its static definiton.  If an active owner is defined at
 *  system startup, the flag is set to TRUE in the manager wakeup method.
 *  If a manager is put to sleep, it sets the flag to FALSE.
 */

%safe
static int GR_ACTIVE_OWNER_ON = 0;
%endsafe

extern int CODrawviewActive;

int GRactive_owner_temp_clear (old_value)
    int *old_value;
{
    int temp;

    if (old_value) 
    {
        GR_ACTIVE_OWNER_ON = *old_value;
        CODrawviewActive = *old_value;
        temp = GR_ACTIVE_OWNER_ON;
    }
    else 
    {
        temp = GR_ACTIVE_OWNER_ON;
        GR_ACTIVE_OWNER_ON = FALSE;
        CODrawviewActive = FALSE;	
    }
    return (temp);
}

/*
 * Root.connect is overridden to fix a problem discovered in 1.2.0
 * I/Draft. When a graphic object was removed from an active drawing
 * view it was being added to the active owner manager's to_components
 * channel. This caused the active owner to be pushed down on the
 * channel, causing it to not behave as an active owner.
 * Only one object is allowed on the to_components channel of the 
 * active owner manager, the current active owner in the system.
 *
 * This fix depends on put_active_owner method disconnecting the
 * active owner before putting a new one on the channel.
 */
method connect ( OM_S_CHANSELECT to_sel;
                 int to_idx;
                 OM_S_OBJID fr_objid;
                 OMuword fr_os;
                 OM_S_CHANSELECT fr_sel;
                 int fr_idx)
{
    IGRlong           om_msg = OM_S_SUCCESS;

    if ( !GR_ACTIVE_OWNER_ON ) 
    {
          om_msg = om$send ( mode = OM_e_wrt_message,
                             msg = message Root.connect ( to_sel,
                                                          to_idx,
                                                          fr_objid,
                                                          fr_os,
                                                          fr_sel,
                                                          fr_idx ),
                             targetid = my_id );
   }

   return ( om_msg );
}

method wake_up ()
{
IGRlong              om_msg;
IGRlong              msg;
OMuint               count;
OM_S_CHANSELECT      to_comp_chansel;
IGRint               i;
struct GRid          my_GRid;
OM_p_OBJECT_LINKAGE  list_ids;
IGRboolean           is_invis;

    if ( om_msg = GRget_to_comp_info ( &to_comp_chansel,
                                       OM_Gw_current_OS,
                                       my_id,
                                       &count ) ) 
    {

        is_invis = ex$is_invis(mod_osnum = OM_Gw_current_OS);

        if ((count == 1) && !is_invis) 
        {
            GR_ACTIVE_OWNER_ON = CODrawviewActive = TRUE;
        }

        /*
         * Prior to 1.3.0 removal of an object from an owner which was the 
         * active owner would add the removed object to the 0th slot of the 
         * active owner manager's to_components channel, pushing the actual 
         * active owner down to the next slot on the to_components channel. 
         * This check for count greater than 1 is intended to correct this 
         * situation if it is present upon bringing up a file.
         * 
         * The active owner will always be the last object on the channel 
         * because set the active owner clears all objects off the 
         * channel. All objects will be deleted off the channel except the
         * last object. This is the true active owner.
         */
        else if ( count > 1 )
        {  
            my_GRid.osnum = OM_Gw_current_OS;
            my_GRid.objid = my_id;

            list_ids = (OM_p_OBJECT_LINKAGE) om$malloc 
                       ( size = (sizeof (OM_S_OBJECT_LINKAGE)) * count);

            om_msg = om$get_channel_objects (object = me, 
                                             p_chanselect = &to_comp_chansel,
                                             list = list_ids, 
                                             size = count,
                                             count = &count);
  
            for (i = 0; i < (count - 2); i++)
            {
                om_msg = om$send (msg = message GRconnector.GRdisconn ( &msg, 
                                                                        &my_GRid),
                                  targetid = list_ids[i].S_objid,
                                  targetos = list_ids[i].osnum);
            }

            GR_ACTIVE_OWNER_ON = CODrawviewActive = ( (om_msg & 1) && !is_invis);

            om$dealloc ( ptr = list_ids );
        }
        else
        {
            GR_ACTIVE_OWNER_ON = CODrawviewActive = FALSE;
        }
    }

    return(OM_S_SUCCESS);
}

method global_class.sleep(int type_sleep)
{
    if ( !ex$is_invis(mod_osnum = OM_Gw_current_OS) )
    {
        GR_ACTIVE_OWNER_ON = CODrawviewActive = FALSE;
    }
 
    return (OM_S_SUCCESS);
}

/*\
Name
   GRget_active_owner

Description
   This method returns the active owner.

   *msg         IGRlong          completion code
   *actown_id   struct GRid      object id of the active owner.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
method GRget_active_owner (IGRlong *msg; struct GRid *actown_id)
{
    IGRlong              om_msg;
    OMuint               count;
    OM_S_OBJECT_LINKAGE  list;
    OM_S_CHANSELECT      chansel;

    *msg = MSSUCC;

    if ( om_msg = GRget_to_comp_chansel ( &chansel ) ) 
    {
        om_msg = om$get_channel_objects ( object = me, 
                                          p_chanselect = &chansel,
                                          list = &list, 
                                          size = 1, 
                                          count = &count);


        if ((om_msg & 1) && count) 
        {
            actown_id->objid = list.S_objid;
            actown_id->osnum = list.osnum;
        }
        else *msg = MSFAIL;
    }

    return (OM_S_SUCCESS);
}

/*\
Name
   GRput_active_owner

Description
   This method defines the given owner as the active owner.

   *msg         IGRlong          completion code
   *actown_id   struct GRid      object id of the active owner

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
method GRput_active_owner (IGRlong *msg; struct GRid *actown_id)
{
    IGRlong           om_msg;
    IGRint            count;
    OM_S_CHANSELECT   chansel;
    struct GRid       my_GRid;

    *msg = MSSUCC;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    /*
     *  Is an owner active?
     */
    if ( om_msg = GRget_to_comp_info ( &chansel,
                                       OM_Gw_current_OS,
                                       my_id,
                                       &count ) ) 
    {
        if (count) 
        {   
            /*
             * Clear the active owner.
             */
            om_msg = om$send (msg = message GRactownmgr.GRclear_active_owner
                                                      ( msg ),
                              targetid = my_id );
        }

        /*
         *  Connect the active owner to the manager.
         */
        if (om_msg & *msg & 1) 
        {
            om_msg = GRconnect_object ( msg, 
                                        actown_id->osnum, 
                                        actown_id->objid,
                                        &my_GRid, 
                                        GR_FLEXIBLE, 
                                        GR_OVERRIDE, 
					0,0);
/*
                                        OM_K_MAXINT, 
                                        OM_K_MAXINT);
*/

            if (om_msg & *msg & 1) 
            {
                GR_ACTIVE_OWNER_ON = TRUE;
                CODrawviewActive = TRUE;
            }
        }
    }
    return ( om_msg );
}

/*\
Name
   GRclear_active_owner

Description
   This method clears the active owner.

   *msg         IGRlong          completion code

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
method GRclear_active_owner (IGRlong *msg)
{
    IGRlong           om_msg;
    IGRint            count;
    OM_S_CHANSELECT   chansel;
    struct GRid       my_GRid;

    *msg = MSSUCC;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    GR_ACTIVE_OWNER_ON = FALSE;
    CODrawviewActive = FALSE;

    /*
     *  Is an owner active?
     */
    if ( om_msg = GRget_to_comp_info ( &chansel,
                                       OM_Gw_current_OS,
                                       my_id,
                                       &count ) )
    {   
        if ((om_msg & 1) && count) 
        {   
            /*
             *  Disconnect the active owner.
             */
            om_msg = om$send ( msg = message GRconnector.GRdisconn 
                                                        (msg, &my_GRid),
                               p_chanselect = &chansel);
        }
    }

    return (om_msg);
}

IGRint GRadd_component_to_active_owner (msg, mod_env, osnum, objid)
    IGRlong           *msg;
    struct GRmd_env   *mod_env;
    GRspacenum        osnum;
    GRobjid           objid;
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    IGRint            one = 1;
    struct GRid       actown_id;
    struct GRobj_env  obj_env;

    *msg = MSSUCC;
   
    /*
     *  Is an active owner defined.
     */

    if (GR_ACTIVE_OWNER_ON && (mod_env->md_id.objid != NULL_OBJID)) 
    {
        om_msg = gr$get_active_owner ( msg = &ret_msg, 
                                       mod_id = &mod_env->md_id, 
                                       active_owner = &actown_id);

        if (om_msg & ret_msg & 1) 
        {
            obj_env.mod_env = *mod_env;
            obj_env.obj_id.osnum = osnum;
            obj_env.obj_id.objid = objid;
            om_msg = om$send (msg = message GRowner.GRadd_components 
                                                  ( &ret_msg, 
                                                    mod_env, 
                                                    &one, 
                                                    &obj_env, 
                                                    NULL, 
                                                    NULL),
                              senderid = NULL_OBJID,
                              targetid = actown_id.objid,
                              targetos = actown_id.osnum);
        }
    }

    return (OM_S_SUCCESS);
}

IGRint GRactive_owner_fun (msg, flag, mod_id, active_owner_id)
    IGRlong     *msg;
    IGRint      flag;
    struct GRid *mod_id;
    struct GRid *active_owner_id;
{
    IGRlong           om_msg;
    GRspacenum        mod_osnum;
    GRobjid           mod_objid;
    GRobjid           global_mgr;

    *msg = MSSUCC;

    if (mod_id) 
    {
        mod_objid = mod_id->objid;
        mod_osnum = mod_id->osnum;
    }
    else 
    {
        om_msg = ex$get_cur_mod( id = &mod_objid, osnum = &mod_osnum);
    }

    om_msg = ex$get_super ( mod_id = mod_objid, 
                            mod_osnum = mod_osnum,
                            super_name = GR_ACTIVE_OWNER, 
                            create = TRUE,
                            super_class = "GRactownmgr", 
                            super_id = &global_mgr);

    if (flag == GRGET_ACTIVE_OWNER) 
    {
        om_msg = om$send (msg = message GRactownmgr.GRget_active_owner 
                                                      ( msg, 
                                                        active_owner_id), 
                          senderid = NULL_OBJID,
                          targetos = mod_osnum, 
                          targetid = global_mgr);
    }
    else if (flag == GRPUT_ACTIVE_OWNER) 
    {
        om_msg = om$send (msg = message GRactownmgr.GRput_active_owner 
                                                      ( msg, 
                                                        active_owner_id),
                          senderid = NULL_OBJID,
                          targetos = mod_osnum, 
                          targetid = global_mgr);
    }
    else if (flag == GRCLEAR_ACTIVE_OWNER) 
    {
        om_msg = om$send (msg = message GRactownmgr.GRclear_active_owner
                                                      ( msg ),
                          senderid = NULL_OBJID,
                          targetos = mod_osnum, 
                          targetid = global_mgr);
    }

    return (om_msg);
}

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
    components then an infinite loop could occur.

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure
\*/
method GRcomponent_disconnecting (IGRlong *msg; 
                                  struct GRmd_env *md_info;
                                  struct GRid *comp_id)
{
    IGRlong	status;

    GR_ACTIVE_OWNER_ON = FALSE;

    status = om$send( 	msg = message GRcmpowner.GRcomponent_disconnecting( msg,
							md_info,
							comp_id ),
			mode = OM_e_wrt_ancestor,
			targetid = my_id );

    return(status);
}

end implementation GRactownmgr;

