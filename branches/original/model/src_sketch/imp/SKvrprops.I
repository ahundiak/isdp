class implementation SKvariable;

#include "EMSopt.h"

method SKgetprops(IGRlong *EMmsg; IGRushort *props)
{
  *EMmsg = EMS_S_Success;
  *props = ME.SKvariable->props;
  return (OM_S_SUCCESS);
}


method SKchgprops (IGRlong *EMmsg; IGRshort action; IGRushort props)
{
  IGRlong           OM_stat;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  switch (action)
   {
    case EMS_O_OFF:
     ME.SKvariable->props &= ~props;
     break;

    case EMS_O_ON:
     ME.SKvariable->props |= props;
     break;
    
    case EMS_O_SET:
     ME.SKvariable->props = props;
     break;

    default:
     *EMmsg = EMS_E_InvalidArg;

   }
 
  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "SKvariable.SKchgprops");
   return (OM_stat);
}

end implementation SKvariable;
