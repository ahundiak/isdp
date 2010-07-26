/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GS_and_operation 

Description
   This method will perform a logical AND of this save set and the
   graphics set passed in gs_id.  This will become the resulting
   save set.

   *msg          IGRlong            return code
   *gs_id        struct GRid        The object id of the graphics set.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    07/07/87    Creation date.
     msm          07/13/92    ANSI-C conversion.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "grgs.h"
#include "grgsmacros.h"

method GS_and_operation (IGRlong *msg; struct GRid *gs_id)
{
IGRlong              om_msg;
IGRlong              ret_msg;
unsigned int         count1;
IGRint               count2;
IGRint               i,j;
OM_S_OBJECT_LINKAGE  *buffer1;
struct GRobj_env     *buffer2;
OM_S_CHANSELECT      chansel;
struct GRid          go_id;
struct GRid          sv_id;
         
   *msg = MSSUCC;
   buffer1 = (OM_S_OBJECT_LINKAGE *)NULL;
   buffer2 = (struct GRobj_env *)NULL;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Send the GSenv_compare message to graphics set.
    *  This method will return a save set.
    */

   om_msg = om$send (
            msg = message GRgrset.GSenv_compare ( &ret_msg,
            &me->path, &me->properties, &sv_id),
            targetid = gs_id->objid, targetos = gs_id->osnum);

   if (om_msg & ret_msg & 1)
   {
      /*
       *    Get the graphics objects
       */      

      om_msg = om$get_channel_count (object = me, p_chanselect = &chansel, 
               count = &count1);

      if ((om_msg & 1) && count1)
      {
         if (buffer1 = (OM_S_OBJECT_LINKAGE *) om$malloc(
                        size = sizeof(OM_S_OBJECT_LINKAGE) * count1))
         {
            om_msg = om$get_channel_objects (object = me, 
                     p_chanselect = &chansel, list = buffer1, 
                     size = count1, count = &count1);
         }else
         {
            om_msg = 0;
         }
      }else
      {  
         om_msg = 0;
      }
      
      if (om_msg & 1)
      {
         /*
          *  Empty all graphics objects
          */

         om_msg = om$send (
                  msg = message GRgrset.GSempty (&ret_msg, NULL, NULL),
                  targetid = my_id);

         if (om_msg & ret_msg & 1)
         {
            /*
             *  Get the total number of objects owned by the save set.
             */

            om_msg = om$send (
                     msg = message GRgrset.GSinqcount (&ret_msg, &count2),
                     targetid = sv_id.objid, targetos = sv_id.osnum);

            if (om_msg & ret_msg & 1)
            {
               if (buffer2 = (struct GRobj_env *)om$malloc (size = 
                              sizeof(struct GRobj_env) * count2))
               {
                  om_msg = om$send (
                           msg = message GRgrset.GSget_object (&ret_msg, 
                           buffer2, sizeof(struct GRobj_env) * count2,
                           &i, NULL, OM_K_MAXINT),
                           targetid = sv_id.objid, targetos = sv_id.osnum);
   
                  for (i=0; i < count1; ++i)
                  {
                     for (j=0; j < count2; ++j)
                     {
                        if (buffer1[i].S_objid == buffer2[j].obj_id.objid)
                        {
                           /*
                            *  Send the GSadd message to that graphic obj.
                            */
   
                           go_id.objid = buffer1[i].S_objid;
                           go_id.osnum = buffer1[i].osnum;

                           om_msg = om$send (
                                    msg = message GRgrset.GSadd (&ret_msg,
                                    &go_id, NULL),
                                    targetid = my_id);
                        }
                     }
                  }
               }
            }
         }
      }
   }else
   {
      /*
       *  A save set with this environment did not exist thus 
       *  dissolve this save set.
       */

      om_msg = om$send (msg = message GRgrset.GSdissolve (msg),
               targetid = my_id);
   }
   if (buffer1) om$dealloc (ptr = buffer1);
   if (buffer2) om$dealloc (ptr = buffer2);
   return(om_msg);
}
end implementation GRsvset;
