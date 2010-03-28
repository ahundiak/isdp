/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSstart_transition 

Description
   This method is used to define the start of a different environment.

   *msg            IGRlong         return code
   *path           GRmd_env        Structure containing the new module
                                   environment.
   *env_properties IGRint          Properties of the environment.
   *cur_sv_id      GRid            The object id of the previous saveset.
   *new_sv_id      GRid            The object id of the saveset initilazed.

Notes
   If the path is NULL the current value will remain.
   If the env_properties is NULL the current value will remain.
   If the cur_sv_id is NULL the current value will remain.
   If the new_sv_id is NULL my_id will not be returned.

Algorithm
   This method inits a saveset.

Return Values
   MSSUCC  -- successful completion

History
     Gray Winn    11/02/86    Creation date.
     msm          07/13/92    ANSI-C conversion.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "OMindex.h"

from module    import   GRmod_passon;
from OMrtree   import   get_stat;

method GSstart_transition (IGRlong *msg; struct GRmd_env *path;
                           IGRint *env_properties; struct GRid *cur_sv_id;
                           struct GRid *new_sv_id)
{
IGRlong           om_msg;
IGRint            ret_msg1;
IGRlong           ret_msg;
IGRint            begin;
IGRint            ending;
IGRint            size;
OM_S_MESSAGE      pass_msg;
OM_S_RTREESTAT    stat;
OM_S_CHANSELECT   chansel;
struct 
{
   OM_p_RTREESTAT  stat;
   int             *ret;
} temp;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;
   begin = 0;
   ending = OM_K_MAXINT;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   if (path->md_id.objid != NULL_OBJID)
   {
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
               targetid = path->md_id.objid, 
               targetos = path->md_id.osnum);

      /*
       *  Preallocate the channel to the number of objects within the
       *  R-tree.
       */
   
      om_msg = om$channel_preset (p_chanselect = &chansel, 
               size = stat.rtree_status.misc.key_count);
   }

   /*
    *  Init instance data.
    */

   if (new_sv_id) 
   {
      new_sv_id->objid = my_id;
      new_sv_id->osnum = OM_Gw_current_OS;
   }   
   if (path)  me->path = *path;
   if (cur_sv_id) me->current_sv = *cur_sv_id;
   if (env_properties) 
   {
      me->properties |= *env_properties & GSIS_SV_PROP_MASK;
   }
   return ( om_msg );
}
end implementation GRsvset;
