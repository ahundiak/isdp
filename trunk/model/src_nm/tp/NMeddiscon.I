class implementation NMedge;

#include "OMmacros.h"

method NDdisconnect(IGRint num; struct GRid *parents)
{
 IGRlong		sts = OM_S_SUCCESS, EMmsg = EMS_S_Success;

 /* If all the parents are getting disconnected, just set numedges = 0 and
    send NDnode.NDdisconnect to myself.
 */
 if(!num && !parents)
  {
   sts = om$vla_set_dimension(varray = ME.NMedge->reverse, size = 0);
   if(!(1&sts)) goto wrapup;

   sts = om$send(mode = OM_e_wrt_message, msg = message NDnodein.NDdisconnect
         (num, parents), targetid = my_id);
   goto wrapup;
  }
 else
   EMmsg = EMS_E_InvalidArg;

wrapup:
EMWRAPUP(EMmsg, sts, "NMedge.NDdisconnect");
return(sts);
}

end implementation NMedge;
