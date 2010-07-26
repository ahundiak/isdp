/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRcopy

Description
   This method copies the fence object.

Arguments
   *msg         IGRlong        completion code
   *mod_env     GRmd_env       mod_env structure 
   *target_env  GRmd_env       target_env structure 
   *newobjid    GRobjid        objid of the transformed object

Algorigthm
   If the target_env is NULL_OBJID then the fence is being copied
   for dynamics.  Thus send to parent to construct a copy.

   If the target_env is specified then this is a real copy and
   since their is only one fence object do not copy.  However
   one must erase the fence object from display.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    10/05/86    Creation date.
   Gray Winn    10/07/88    Updated for message interception
   dhm          01/30/92    TR 92N0218. fixed memory fault when displaying.
   msm          07/09/92    ANSI-C conversion.

\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "dpmacros.h"

method GRcopy (IGRlong *msg; struct GRmd_env *mod_env;
              struct GRmd_env *target_env; GRobjid *new_objid)
{
IGRlong              om_msg;
unsigned int         count;
OM_S_OBJECT_LINKAGE  list;
OM_S_CHANSELECT      chansel;
struct GRid          fence_id;
IGRmatrix            *mat[1];

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   if (target_env->md_id.objid == NULL_OBJID)
   {
      om_msg = GRpass_on_to_fence (OM_Gw_current_OS, my_id, OPPmargs);
   }else
   {
      om_msg = om$get_channel_objects (objid = my_id,
               p_chanselect = &chansel, list = &list, size = 1,
               count = &count);

      fence_id.osnum = list.osnum;
      fence_id.objid = list.S_objid;

      /*
       *  Erase the fence object from the defining view. 
       *  The original fence object must be cleared from
       *  display.  It is the responsiblity of any calling
       *  command to redisplay the new object.
       */

      /*   TR 92N0218.   fix memory fault.   dhm  */

      mat[0] = (IGRmatrix *) mod_env->md_env.matrix;

      om_msg = dp$display (msg = msg,
               osnum = mod_env->md_id.osnum,
               objid = mod_env->md_id.objid,
               mode = GRbehe,
               oids = &fence_id,
               mtx_type = &mod_env->md_env.matrix_type,
               matrix = mat);

      *new_objid = list.S_objid;
   }
   return (OM_S_SUCCESS);
}
end implementation GRgsmgr;
