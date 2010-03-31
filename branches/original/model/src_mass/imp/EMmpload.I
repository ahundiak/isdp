/* ###################   APOGEE COMPILED   ################## */
class implementation EMSmassprop;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "OMmacros.h"
#include "emsmass.h"
#include "csdef.h"

/*
  HISTORY
           gupta     07/06/89     Creation Date
*/

method EMload_mass_prop (IGRlong *EMmsg;
                         IGRboolean validity;
                         IGRdouble *mass_props)

{

  IGRint i, stat_OM;
  
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  ME.EMSmassprop->mp_valid = validity;

  for (i=0; i<NUMB_PROPS; i++)
       ME.EMSmassprop->mass_props[i] = mass_props[i];


  if (me->operation_type == AREA_PROPERTIES)
   {
    for (i=0; i<6; i++) me->p_axes[i] = mass_props[i+5];
   }

  for (i=0; i<3; i++) ME.EMSmassprop->refer_pnt[i] = mass_props[i+2];
  ME.EMSmassprop->axes_orient = PRINCIPAL;

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMload_mass_prop");
  return (stat_OM);
}
end implementation EMSmassprop;
