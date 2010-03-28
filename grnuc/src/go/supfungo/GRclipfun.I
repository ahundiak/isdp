/* #######################    APOGEE COMPILED   ######################## */
class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "grownerdef.h"
#include "growner.h"
#include "grerr.h"

from GRgraphics   import   GRclip;

/*\
Name
   GRclip_function

Description
   This function is used within the call to the GRfunction method to
   clip an element.

Arguments
   *msg           IGRlong                 return code
   *obj_id        struct GRid             Object id to be clipped.
   *fun_info      struct GRfunction_info  fuction information

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn   09/23/88 :  Creation date
\*/

IGRint GRclip_function (msg, obj_id, fun_info)
IGRlong                 *msg;
struct GRid             *obj_id;
struct GRfunction_info  *fun_info;
{
IGRlong              om_msg;
IGRint               copy_flag;
IGRint               rigid_connect;
IGRint               override_connect;
struct GRclip_args   *clip_args;

   *msg = MSSUCC;
   clip_args = (struct GRclip_args *)fun_info->info;

   copy_flag = (*(clip_args->clip_flag) & GR_CLIP_NODEL) ? TRUE : FALSE;
   rigid_connect = (*(clip_args->clip_flag) & GR_CLIP_RIGID) ? 
                   GR_RIGID : GR_FLEXIBLE;
   override_connect = (*(clip_args->clip_flag) & GR_CLIP_FLEXCONN) ? 
                      GR_OVERRIDE : GR_NO_OVERRIDE;

   om_msg = om$send (msg = message GRgraphics.GRclip (clip_args->msg,
            clip_args->mod_env, clip_args->target_env, clip_args->prism,
            clip_args->inside_id, clip_args->outside_id, 
            clip_args->overlap_id, clip_args->clip_flag),
            senderid = NULL_OBJID,
            targetos = obj_id->osnum, targetid = obj_id->objid);

   if (*msg & 1)
   {
      if ((*msg == GR_I_OBJINSIDE) && (clip_args->inside_id))
      {
         if (copy_flag)
         {
            om_msg = GRcopy_and_connect_object (clip_args->msg, 
                     obj_id->osnum, obj_id->objid, clip_args->mod_env, 
                     clip_args->target_env, clip_args->inside_id,
                     rigid_connect, override_connect, NULL);
         }else
         {
            om_msg = GRconnect_object (clip_args->msg, obj_id->osnum,
                     obj_id->objid, clip_args->inside_id, rigid_connect,
                     override_connect, OM_K_MAXINT, OM_K_MAXINT);
         }
      }else if ((*msg == GR_I_OBJOUTSIDE) && (clip_args->outside_id))
      {
         if (copy_flag)
         {
            om_msg = GRcopy_and_connect_object (clip_args->msg, 
                     obj_id->osnum, obj_id->objid, clip_args->mod_env,
                     clip_args->target_env, clip_args->outside_id,
                     rigid_connect, override_connect, NULL);
         }else
         {
            om_msg = GRconnect_object (clip_args->msg, obj_id->osnum, 
                     obj_id->objid, clip_args->outside_id, rigid_connect,
                     override_connect, OM_K_MAXINT, OM_K_MAXINT);
         }
      }
   }
   return (om_msg);
}
end implementation Root;
