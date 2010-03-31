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
 DESCRIPTION
   This method deletes a cross section state and if it is the active
   state, it also deletes the cross section association info stored
   in the cross_section fan manager instance data.
   
 HISTORY     

        RC     12/09/88      Creation Date

*/

method GRdelete(IGRlong *EMmsg; struct GRmd_env *md_env)
{
  struct GRid      act_st_GRid;
  IGRlong          OM_stat, mthd_stat, rc;
  extern void      EFdel_xsec_assoc_info ();
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  OM_stat = om$send (msg = message EMSsurface.EMgetactiveid (&mthd_stat,
                      &act_st_GRid, NULL),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  if (act_st_GRid.objid == my_id)
  {
    EFdel_xsec_assoc_info (&rc, my_id, OM_Gw_current_OS);
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  } /* if (act_st_GRid.objid == my_id) */
 
  OM_stat = om$send (mode = OM_e_wrt_message,
                     msg = message EMSdpr.GRdelete (&mthd_stat, md_env),
                     targetid = my_id);  
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxsec_st.GRdelete");

   return (OM_stat);
  
}

end implementation EMSxsec_st;
