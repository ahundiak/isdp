/* #######################    APOGEE COMPILED   ######################## */
/*
Name :
   GScopy 

Abstract :
   This method is used to make a copy of the original objects.  This 
   method disconnects the original object. The objects are copied to 
   the target_env.

   *msg           IGRlong           return code 
   *target_env    GRmd_env          Environment to copy objects to.
   matrix         IGRmatrix         Matrix defining transformation.
   *owner_id      GRid              Owner object.

Return Values:
   MSSUCC  -- successful completion
   MSFAIL  -- failure

Notes:
   The owner_id argument may be NULL.  If the argument is NULL then 
   the copies are connected to the graphics set.  If it is not NULL
   it must contain the object id of the save set.

History:
     11/02/86 Gray Winn        Creation date.
     07/10/92 msm              ANSI-C conversion.
     06/17/93 Carlos M. Diaz   Print error if copy fails (xerox related).
*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "grgsmacros.h"

method GScopy (IGRlong *msg; struct GRmd_env *target_env; 
               IGRmatrix matrix; struct GRid *owner_id)
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRint            count;
IGRint            i;
IGRint            properties;
IGRint            created_sv;
IGRchar           *buffer;
struct GRid       go_id;
struct GRid       sv_id;
struct GRmd_env   temp_env;
OM_S_CHANSELECT   chansel;
OM_S_CHANSELECT   to_owners;

   *msg = MSSUCC;
   ret_msg = MSSUCC;
   buffer = (IGRchar *)NULL;
   temp_env = me->path;
   created_sv = FALSE;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";
   to_owners.type = OM_e_name;
   to_owners.u_sel.name = "GRgrset.to_owners";
   go_id.osnum = target_env->md_id.osnum;

   /*
    *  Get the objects.
    */

   om_msg = om$get_channel_count (object = me, p_chanselect = &chansel, 
            count = (IGRuint *) &count);

   if ((om_msg & 1) && count)
   {
      if (buffer = om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) * count))
      {
         om_msg = om$get_channel_objects (object = me, 
                  p_chanselect = &chansel, 
                  list = (OM_S_OBJECT_LINKAGE *) buffer, size = count, 
                  count = (IGRuint *) &count);
      }else
      {
         om_msg = 0;
      }
   }
   
   if (!count)
   {
      /* 
       *  No objects.
       */

      return (OM_S_SUCCESS);
   }else if (om_msg & 1)
   {
      if (owner_id)
      {
         if (owner_id->osnum == target_env->md_id.osnum)
         {
            sv_id = *owner_id;

            /*
             *  Delete my self.
             */

            om_msg = om$send(msg = message Root.delete (NULL), 
                     targetid = my_id);
         }else 
         {
            *msg = MSFAIL;
            om_msg = OM_E_ABORT;
         }
      }else if (OM_Gw_current_OS == target_env->md_id.osnum)
      {
         /*
          *  This saveset can be used do not construct a new save set.
          */
            
         sv_id.objid = my_id;
         sv_id.osnum = OM_Gw_current_OS;
         me->path = *target_env;  
         me->properties = 0; /* Set to writable */
         om_msg = om$send(msg = message Root.wild_disconnect (chansel),
                  targetid = my_id);
      }else
      {
         /*
          *  This save set can not be used a new save set must be
          *  constructed in the target environment.
          */

         sv_id.osnum = target_env->md_id.osnum;
         om_msg = gr$gsinit ( msg = &ret_msg,
                  p_objid = &sv_id.objid,
                  osnum = target_env->md_id.osnum);

         /*
          *  Send the init message to the new save set.
          *  Preset the channel size to the number of elements on the
          *  original save set.
          */

         om_msg = om$send (
                  msg = message GRsvset.GSsvinit (&ret_msg,
                  target_env, &properties, &count),
                  targetid = sv_id.objid, 
                  targetos = sv_id.osnum);

         created_sv = TRUE;
   
         /*
          *  Move all owners from this saveset to the new
          *  save set.
          */

         om_msg = om$send (
                  msg = message Root.move_chan (to_owners,
                  my_id, OM_Gw_current_OS, to_owners),
                  targetid = sv_id.objid,
                  targetos = sv_id.osnum);

         /*
          *  Delete my self.
          */

         om_msg = om$send(msg = message Root.delete (NULL), 
                  targetid = my_id);
      }

      /*
       *  Loop for each component
       */

      for (i=0; (i < count) /*&& (om_msg & ret_msg & 1)*/; ++i)
      {
         if (matrix)
         {
            /*
             *  Copy and transform the object.
             */

            om_msg = om$send(
                     msg = message GRgraphics.GRcptform (&ret_msg, 
                     &temp_env, matrix, target_env, &go_id.objid),
                     targetid = ((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid,
                     targetos = ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum);
         }else
         {
            /*
             *  Make a copy of each member.
             */

            om_msg = om$send(mode = OM_e_wrt_object,
                     msg = message GRgraphics.GRcopy (&ret_msg, &temp_env,
                     target_env, &go_id.objid),
                     targetid = ((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid,
                     targetos = ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum);
         }
   
         if (om_msg & ret_msg & 1)
         {
            /*
             *  Add the object to the graphics set.
             */
            om_msg = om$send(msg = message GRgrset.GSadd (&ret_msg,
                     &go_id, NULL),
                     senderid = NULL_OBJID,
                     targetid = sv_id.objid, targetos = sv_id.osnum);
         }
         else
         { 
            printf("\n******** Error copying element id: %d in space: %d\n",
            		((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid,
            		((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum);
         }
      } /* end of for loop for components */
   }

   if (created_sv)
   {
      om_msg = om$send (msg = message GRsvset.GSunpreset(&ret_msg),
               targetid = sv_id.objid,
               targetos = sv_id.osnum);
   }

   if (buffer) om$dealloc (ptr = buffer);
   return ( om_msg );
}
end implementation GRsvset;
