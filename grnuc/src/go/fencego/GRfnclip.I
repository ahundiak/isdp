/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRclip

Description
   This method clips the fence object.  

Arguments
   *msg         IGRlong             completition code
   *mod_env     struct GRmd_env     The originial module environment.
   *target_env  struct GRmd_env     The target environment.
   *prism       IGRchar             The right prism to clip against.
   *inside_id   struct GRid         The object id of the inside owner.
   *outside_id  struct GRid         The object id of the outside owner.
   *overlap_id  struct GRid         The object id of the overlapping owner.
   *clip_flag   IGRlong             The flag describing the type of clip.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    02/24/87    Creation date.
   Gray Winn    10/07/88    Updated for message interception
   msm          07/09/92    ANSI-C conversion.
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "godef.h"
#include "grownerdef.h"

method GRclip(IGRlong *msg; struct GRmd_env *mod_env; 
              struct GRmd_env *target_env; IGRchar *prism; 
              struct GRid *inside_id; struct GRid *outside_id;
              struct GRid *overlap_id; IGRlong *clip_flag)
{
IGRlong              om_msg;
unsigned int         count;
IGRint               rigid_connect;
IGRint               override_connect;
GRobjid              objid;
struct GRid          target_id;
OM_S_OBJECT_LINKAGE  list;
OM_S_CHANSELECT      chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";
   rigid_connect = (*clip_flag & GR_CLIP_RIGID) ? GR_RIGID : GR_FLEXIBLE;
   override_connect = (*clip_flag & GR_CLIP_FLEXCONN) ? 
                      GR_OVERRIDE : GR_NO_OVERRIDE;

   if (me->fence_properties & GRFN_CLIP_INSIDE)
   {
      target_id = *inside_id;
   }else if (me->fence_properties & GRFN_CLIP_OUTSIDE)
   {
      target_id = *outside_id;
   }else
   {
      /*
       *  The fence is not allowed to be clipped.
       */

      return(OM_S_SUCCESS);
   }

   /*
    * Clear the clip fence properties.
    */

   me->fence_properties &= 
                        (0xffff ^ (GRFN_CLIP_INSIDE | GRFN_CLIP_OUTSIDE));

   if (*clip_flag & GR_CLIP_NODEL)
   {
      om_msg = om$send (
               msg = message GRgraphics.GRcopy (msg, mod_env, target_env,
               &objid), p_chanselect = &chansel);
   }else
   {
      om_msg = om$get_channel_objects (objid = my_id,
               p_chanselect = &chansel, list = &list, size = 1,
               count = &count);

      objid = list.S_objid;
   }

   om_msg = GRconnect_object (msg, OM_Gw_current_OS, my_id, &target_id,
            rigid_connect, override_connect, OM_K_MAXINT, 
            OM_K_MAXINT);

   return (OM_S_SUCCESS);
}
end implementation GRgsmgr;
