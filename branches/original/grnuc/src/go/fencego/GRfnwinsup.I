/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   The following routines are overridden to set the fence properties
   when a display is sent from the defining window.  
   
   pre_update (msg, gragad_id)
   post_update(msg, gragad_id)
   pre_single_display(msg, gragad_id, graphic_id)
   post_single_display(msg, gragad_id, graphic_id)
   pre_delete (msg)

   *msg         IGRlong       completion code
   *gragad_id   GRid          gra gadget id
   *graphics_id GRid          the graphic object id on single update

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    10/05/86    Creation date.
   Gray Winn    10/07/88    Updated for message interception
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "OMerrordef.h"

method pre_update(IGRlong *msg; struct GRid *gragad_id;
                  struct DP_information *dp_info;
                  struct GRmd_env *md_env)
{
   *msg = MSSUCC;
   me->fence_properties = me->fence_properties | GRFN_IS_DISPLAYABLE;
   return (OM_S_SUCCESS);
}

method post_update(IGRlong *msg; struct GRid *gragad_id)
{
   *msg = MSSUCC;
   me->fence_properties = me->fence_properties & 
      (0xffff ^ GRFN_IS_DISPLAYABLE);
   return (OM_S_SUCCESS);
}

method pre_single_display(IGRlong *msg; struct GRid *gragad_id;
                          struct GRid *graphic_id)
{
   *msg = MSSUCC;

   me->fence_properties = me->fence_properties | GRFN_IS_DISPLAYABLE;
   return (OM_S_SUCCESS);
}

method post_single_display(IGRlong *msg; struct GRid *gragad_id;
                           struct GRid *graphic_id)
{
   *msg = MSSUCC;
   me->fence_properties = me->fence_properties & 
      (0xffff ^ GRFN_IS_DISPLAYABLE);
   return (OM_S_SUCCESS);
}

method pre_delete( IGRlong *msg)
{
struct GRmd_env   mod_env;

   *msg = MSSUCC;
   /******************* KLUDGE *************************/
   GRfindmod(&mod_env.md_id);
   mod_env.md_env.matrix_type = MAIDMX;
   MAidmx(msg,mod_env.md_env.matrix);
   /****************************************************/
   
   om$send (msg = message GRgraphics.GRdelete (msg, &mod_env),
      senderid = my_id, targetid = my_id);

   return(OM_S_SUCCESS);
}
end implementation GRgsmgr;
