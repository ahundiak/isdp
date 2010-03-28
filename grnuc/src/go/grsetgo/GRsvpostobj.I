/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSpost_located_object 

Description
   This method is used to add a locatd object to a channel so that the
   located object can check to see if it has been located.
   
   *msg           IGRlong           return code 
   *obj_id        struct GRid       Located object.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    03/13/87    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "lcobjmacros.h"
#include "exmacros.h"

from module import   GRmod_passon;

method GSpost_located_object (IGRlong *msg; struct GRid *obj_id)
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRint            ret_msg1;
unsigned int      count;
IGRint            preset;
IGRint            begin;
IGRint            ending;
IGRint            size;
GRobjid           mod_id;
OM_S_CHANSELECT   post_sel;
OM_S_RTREESTAT    stat;
OM_S_MESSAGE      pass_msg;
struct 
{
   OM_p_RTREESTAT  stat;
   int             *ret;
} temp;

   *msg = MSSUCC;
   preset = 0;
   begin = 0;
   ending = OM_K_MAXINT;
   post_sel.type = OM_e_name;
   post_sel.u_sel.name = "GRgrset.to_sets";

   /*
    *  Get the channel count
    */

   om_msg = om$get_channel_count (objid = my_id,
            p_chanselect = &post_sel, count = &count);

   if ((om_msg & 1) && (!count))
   {
      /*
       *  Get the module id.
       */

      ex$get_modid( mod_osnum = obj_id->osnum, mod_id = &mod_id);

      /*
       *  Inquire the number of objects that the R-tree owns.
       */

      stat.request_type = RTREE_MISC_STATUS;
      temp.stat = &stat;
      temp.ret = &ret_msg1;
      size = sizeof (temp);
      om_msg = om$make_message (classname = "OMrtree",
               methodname = "get_stat", size = size, p_arglist = &temp,
               p_msg = &pass_msg);

      om_msg = om$send (msg = message module.GRmod_passon (&ret_msg,
               &pass_msg, "module.primary", &begin, &ending),
               targetid = mod_id,
               targetos = obj_id->osnum);

      preset = stat.rtree_status.misc.key_count;
   }

   /*
    *  Add the object to the posted objects channel.
    */

   om_msg = lc$multiple_connect( p_chanselect = &post_sel,
                                 go_objid = obj_id->objid,
                                 go_osnum = obj_id->osnum,
                                 preset = preset);

   return (om_msg);
}
end implementation GRsvset;
