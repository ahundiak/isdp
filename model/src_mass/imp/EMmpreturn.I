/* ###################   APOGEE COMPILED   ################## */
class implementation EMSmassprop;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "OMmacros.h"
#include "emsmass.h"

/*
  HISTORY
           gupta     07/06/89     Creation Date
*/

method EMretn_mass_prop (IGRlong *EMmsg;
                         IGRboolean *validity;
                         IGRdouble *mass_props)

{

  IGRint i, stat_OM;
  
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  *validity = ME.EMSmassprop->mp_valid;

  for (i=0; i<NUMB_PROPS; i++)
       mass_props[i] = ME.EMSmassprop->mass_props[i];

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMretn_mass_prop");
  return (stat_OM);
}
end implementation EMSmassprop;
