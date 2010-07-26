/*
Name
        GSadd_object

Keywords
        graphic-set

Description
        This function adds an object onto a commands channel.  If need it will
        create a save set to add the object to.

Synopsis
        IGRlong *msg                return code
        struct GRid *obj_id         The object id of the object to be
                                    added to the save set.
        struct GRmd_env *path       Structure containing the new module
                                    environment.
        IGRint *env_properties      environment properties.
        struct GRid *target_id      The object id of the owner.
        OM_p_CHANSELECT target_sel  The channel to connect the graphics set to.

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure

History
        Gray Winn   11/02/86    Creation date.
        msm         07/10/92    ANSI-C conversion.
        mrm         01/25/93    Evaluated for possible dangling ISO 
                                connections.  Since this function only
                                connects graphic sets to the command objects
                                in the transient os, no changes were
                                necessary.
*/

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
#include "OMerrordef.h"
#include "exdef.h"
#include "msdef.h"
#include "grgsmacros.h"
#include "grgsdef.h"

from GRgrset import GSobject_add;

IGRint GRgsadd_object (msg, obj_id, path, env_properties, target_id,
                       target_sel)
IGRlong           *msg;
struct GRid       *obj_id;
struct GRmd_env   *path;
IGRint            *env_properties;
struct GRid       *target_id;
OM_p_CHANSELECT   target_sel;
{
IGRlong  om_msg;
IGRlong  ret_msg;
unsigned int  count;
OM_S_CHANSELECT   to_owners_sel;

   *msg = MSSUCC;
   to_owners_sel.type = OM_e_name;
   to_owners_sel.u_sel.name = "GRgrset.to_owners";

   om_msg = om$get_channel_count (osnum = target_id->osnum,
            objid = target_id->objid, p_chanselect = target_sel,
            count = &count);

   /*
    *  Are there any objects on the channel?  If yes then add the
    *  object to the existing graphics sets.
    */

   if (om_msg && count)
   {
      om_msg = om$send (
               msg = message GRgrset.GSobject_add (msg, obj_id, path,
               env_properties, target_id, target_sel),
               senderid = target_id->objid, p_chanselect = target_sel,
               from = NULL, to = NULL);
   }else
   {
      /*
       *  Is the object a graphics set?
       */

      om_msg = gr$gsis_graphics_set (msg = &ret_msg,
               senderid = target_id->objid,
               senderos = target_id->osnum,
               object_id = obj_id);

      if (om_msg & ret_msg & 1)
      {
         /*
          *  The object is a graphics set.  Connect the object to the
          *  target channel.
          */

         om_msg = om$send(
                  msg = message Root.connect (*target_sel, OM_K_MAXINT,
                  obj_id->objid, obj_id->osnum, to_owners_sel, OM_K_MAXINT),
                  senderid = NULL_OBJID,
                  targetid = target_id->objid,
                  targetos = target_id->osnum);
      }else
      {
         /*
          *  The object is not a graphics set. Create a save set and
          *  add the object to it.
          */

         om_msg = gr$gsinit ( msg = &ret_msg,
                              senderid = target_id->objid,
                              senderos = target_id->osnum,
                              p_chanselect = target_sel,
                              osnum = obj_id->osnum);

         om_msg = om$send (
                  msg = message GRgrset.GSobject_add (msg, obj_id, path,
                  env_properties, target_id, target_sel),
                  senderid = target_id->objid, p_chanselect = target_sel);
      }
   }
   return (om_msg);
}
end implementation Root;
