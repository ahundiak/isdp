/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSto_cpx 

Description
   This method will connect the graphics objects to_cpx channel to
   the members channel.

   *msg          IGRlong              return code

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
    Gray Winn    12/02/86    Creation date.
    mrm          07/07/89    Use override to connect - allows cells to be
                             defined using rigid components.
    msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

from GRconnector import GRflexconn;

method GSto_cpx (IGRlong *msg)
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRlong           connect_flag;
IGRint            i;
unsigned int      count;
IGRlong           index;
IGRchar           *buffer;
OM_S_CHANSELECT   chansel;
struct GRid       my_GRid;


   *msg = MSSUCC;
   index = OM_K_MAXINT;
   buffer = (IGRchar *)NULL;
   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   if (! (me->properties & GSIS_CPX_CONNECT))
   {
      /*
       *  Get the objects.
       */
   
      om_msg = om$get_channel_count (object = me, p_chanselect = &chansel, 
               count = &count);

      if ((om_msg & 1) && count)
      {
         if (buffer = om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) 
                                 * count))
         {
            om_msg = om$get_channel_objects (object = me, 
                     p_chanselect = &chansel, 
                     list = (OM_S_OBJECT_LINKAGE *) buffer, size = count, 
                     count = &count);

            if (om_msg & 1)
            {
               /*
                *  Disconnect all the objects from the members channel.
                */
   
               om_msg = om$send(msg = message Root.wild_disconnect 
                        (chansel), targetid = my_id);

               me->properties |= GSIS_CPX_CONNECT;
      
               for (i = 0; i < count; ++i)
               {
                  /*
                   *  Send the GRflexconn message to the graphics objects.
                   */

/*                connect_flag = 0;    / * NO OVERRIDE */
                  connect_flag = 1;    /* OVERRIDE */
                  om_msg = om$send(
                           msg = message GRconnector.GRflexconn (&ret_msg, 
                           &connect_flag, &my_GRid, &index, &index),
                     targetid = ((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid,
                     targetos = ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum);
               }
            }
         }
      }
   }

   if (buffer) om$dealloc (ptr = buffer);
   return (OM_S_SUCCESS);
}
end implementation GRsvset;
