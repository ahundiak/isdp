/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSpass 

Description
   This method is used for the graphic sets to pass a mesage on to
   all graphics objects that it owns.

   *msg           IGRlong              return code 
   pass_msg       OM_p_MESSAGE         Message to be passed
   *path          struct GRmd_env      Pointer to the data within the 
                                       message which contains the module 
                                       environment.

Notes
   The path argument may be NULL which means the message does not
   need the module environment.

Return Values
   MSSUCC   -  if successful.

History
     Gray Winn    11/02/86    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

method GSpass ( IGRlong         *msg;
                OM_p_MESSAGE    pass_msg;
                struct GRmd_env *path)
{
IGRlong           om_msg;
unsigned int      count;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   om_msg = om$get_channel_count (object= me, p_chanselect = &chansel, 
            count = &count);

   if ((om_msg & 1) && count)
   {
      if (path)
      {
         *path = me->path;
      }

      om_msg = om$send (mode = OM_e_wrt_object, 
               msg = pass_msg, senderid = my_id,
               p_chanselect = &chansel);
   }
   return ( om_msg );
}

end implementation GRsvset;
