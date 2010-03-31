class implementation SKconstraint;

#include <stdio.h>
#include "EMSopt.h"

method SKgetprops(IGRlong *EMmsg; IGRushort *props)
{
 *EMmsg = EMS_S_Success;
 *props = ME.SKconstraint->props;
 return (OM_S_SUCCESS);
}

method SKchgprops(IGRlong *EMmsg; IGRshort action; IGRushort props)
{
  IGRlong           OM_stat;

  /* ********************************************************** */

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  switch (action)
   {
    case EMS_O_OFF:
     ME.SKconstraint->props &= ~props;
     break;

    case EMS_O_ON:
     ME.SKconstraint->props |= props;
     break;
    
    case EMS_O_SET:
     ME.SKconstraint->props = props;
     break;

    default:
     *EMmsg = EMS_E_InvalidArg;

   }
 
   EMWRAPUP (*EMmsg, OM_stat, "SKconstraint.SKchgprops");
   return (OM_stat);
}

end implementation SKconstraint;
