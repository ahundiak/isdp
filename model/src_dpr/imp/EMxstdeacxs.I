/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsec_st;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "EMSssi.h"
#include "OMprimitives.h"
#include "OMmacros.h"

/*

History
        RC        12/07/88       Creation Date
*/

method EMdeact_xsection (
  IGRlong         *EMmsg; 
  IGRshort        *option;
  struct GRmd_env *md_env;
  GRobjid         **display_ids;
  IGRint          *display_count)
{
  IGRlong      OM_stat;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  OM_stat = om$send (msg = message EMSdpr.EMdeactivate (EMmsg,
                      option, md_env, display_ids, display_count),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxsec_st.EMdeact_xsec");
   return (OM_stat);                                           
}

end implementation EMSxsec_st;
