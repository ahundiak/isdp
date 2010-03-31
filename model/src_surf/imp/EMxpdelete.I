/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsplane;

%safe
#include <math.h>
%endsafe

# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"
# include "EMSobjmgrdef.h"
# include "EMSobjmgr.h"

/*
 DESCRIPTION
    This method deletes the cross section plane and if it is the
    active state, it also deletes the edge association info from the 
    instance data of cross section fan manager object. 

 History     

        RC  11/14/88    Creation Date
        AIC 09/09/91    Removed HSURF bundle changes; handled by EMSsubbs
*/

from EMSboundary import EMget_edges;
 
method GRdelete(IGRlong *EMmsg; struct GRmd_env *md_env)
{
  struct GRid            act_st_GRid;
  IGRlong                OM_stat, mthd_stat, rc;
  extern void            EFdel_xsec_assoc_info();  

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
 
  OM_stat = om$send (mode = OM_e_wrt_parent,
                     msg = message EMSxsplane.GRdelete (&mthd_stat,
                      md_env),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxsplane.GRdelete");
   return (OM_stat);
  
}

end implementation EMSxsplane;
