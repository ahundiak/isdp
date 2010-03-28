/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRadd_components

Description
   This method is used to add a list of elements to an owner.

   *msg           IGRlong              completion code 
   *mod_env       struct GRmd_env      The current module environment
   *num_objects   IGRint               The number of objects
   objects[]      struct GRobj_env     The list of elements to be added.
   own_index[]    IGRint               An array of indexes for the owner's
                                       channel when connecting.
   go_index[]     IGRint               An array of indexes for the graphics
                                       object's channel when connecting. 

Notes
   The own_index and go_index arrays may be NULL.  If either is NULL
   then OM_K_MAXINT will be used.

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.

History
    Gray Winn       09/15/87    Creation date.
    Jimmy Dodd      03/02/92    Do not connect NULL_OBJID objects.
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "gocmacros.h"

method GRadd_components (IGRlong *msg; 
                         struct GRmd_env *mod_env;
                         IGRint *num_objects; 
                         struct GRobj_env objects[];
                         IGRint own_index[]; 
                         IGRint go_index[])
{
    IGRlong     om_msg;
    IGRint      i;
    IGRint      local_go_index;
    IGRint      local_own_index;
    IGRint      channel_type;
    IGRint      connection_type;
    struct GRid my_GRid;

    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

   /*
    *  Get the type of channel.
    */
   om_msg = om$send (msg = message GRowner.GRget_channel_type (msg,
                                                               &channel_type, 
                                                               &connection_type), 
                     targetid = my_id);

    for (i = 0; i < *num_objects; ++i) 
    {
        /*
         *  This method only adds objects which are within the
         *  same object space as the current module environment.
         */
        if ( (objects[i].mod_env.md_id.osnum == mod_env->md_id.osnum) &&
             (objects[i].mod_env.md_id.objid == mod_env->md_id.objid) &&
	     (objects[i].obj_id.objid != NULL_OBJID) )
        {
            local_own_index = (own_index) ? own_index[i] : OM_K_MAXINT;

            local_go_index = (go_index) ? go_index[i] : OM_K_MAXINT;

            /*
             *  Add the object to the owner.
             */
            om_msg = GRconnect_object (msg, 
                                       objects[i].obj_id.osnum,
                                       objects[i].obj_id.objid, 
                                       &my_GRid, 
                                       channel_type,
                                       connection_type, 
                                       local_own_index, 
                                       local_go_index);
        }
    }

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_CHANNEL_USED);

    return (om_msg);
}
end implementation GRowner;
