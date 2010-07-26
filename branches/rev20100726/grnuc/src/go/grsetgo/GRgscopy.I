/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GScopy

Description
   This method is used to make a copy of the original objects.  This 
   method disconnects the original object. The objects are copied to 
   the target_env.

   *msg           IGRlong           return code 
   *target_env    GRmd_env          Environment to copy objects to.
   matrix         IGRmatrix         Matrix defining transformation.
   *owner_id      GRid              Owner object.

Notes
   The owner_id argument may be NULL.  If the argument is NULL then 
   the copies are connected to the graphics set.  If it is not NULL
   it must contain the object id of the save set.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "grgsmacros.h"

from GRsvset   import GSsvinit, GSunpreset;

method GScopy (IGRlong *msg; struct GRmd_env *target_env; 
                IGRmatrix matrix; struct GRid *owner_id)
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRint            i;
unsigned int      count;
IGRint            created_sv;
IGRint            env_properties;
IGRint            gs_count;
IGRchar           *buffer;
struct GRid       copy_id;
struct GRid       my_GRid;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   ret_msg = MSSUCC;
   buffer = (IGRchar *)NULL;
   env_properties = 0;
   created_sv = FALSE;
   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_sets";

   me->properties &= (0xffffffff ^ GRIS_BACKGROUND_DISPLAY);

   /*
    *  Get the save sets on the members channel.
    */

   om_msg = om$get_channel_count (object = me, p_chanselect = &chansel, 
            count = &count);

   if ((om_msg & 1) && count)
   {
      if (buffer = om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) * count))
      {
         om_msg = om$get_channel_objects (object = me, 
                  p_chanselect = &chansel, 
                  list = (OM_S_OBJECT_LINKAGE *) buffer, size = count, 
                  count = &count);

         if (om_msg & 1)
         {
            if (owner_id)
            {
               copy_id = *owner_id;
            }else
            {
               copy_id.osnum = target_env->md_id.osnum;
               om_msg = gr$gsinit (msg = &ret_msg, p_chanselect = &chansel,
                        p_objid = &copy_id.objid,
                        osnum = target_env->md_id.osnum);

               if (om_msg & ret_msg & 1)
               {
                  /*
                   *  Get the number of objects on the graphics set.
                   */

                  om_msg = gr$gsinqcount (msg = &ret_msg,
                           count = &gs_count, object_id = &my_GRid);

                  /*
                   *  Init the save set.
                   */   

                  om_msg = om$send (
                           msg = message GRsvset.GSsvinit(&ret_msg,
                           target_env, &env_properties, &gs_count),
                           targetid = copy_id.objid,
                           targetos = copy_id.osnum);

                  created_sv = TRUE;
               }
            }

            for (i=0; (i < count) && (om_msg & *msg &1); ++i)
            {
               /*
                *  Send the copy message to each saveset.
                */
         
               om_msg = om$send(
                        msg = message GRgrset.GScopy (msg, target_env, 
                        matrix, &copy_id),
                     targetid = ((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid,
                     targetos = ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum);
            }
         }
      }
   }

   if (created_sv)
   {
      om_msg = om$send (
               msg = message GRsvset.GSunpreset(&ret_msg),
               targetid = copy_id.objid,
               targetos = copy_id.osnum);
   }

   if (buffer) om$dealloc (ptr = buffer);
   return ( om_msg );
}
end implementation GRgrset;
