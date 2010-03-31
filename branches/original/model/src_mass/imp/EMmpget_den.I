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

method EMget_density (IGRlong *EMmsg;
                      IGRdouble *density)

{
  IGRlong stat_OM; 
   
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  *density = ME.EMSmassprop->density;

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMget_density");
  return (stat_OM);
}
end implementation EMSmassprop;
