class implementation EMSsfboolfea;

#include "emsdef.h"     
#include "EMSdpr.h"
#include "EMSopt.h"
#include "OMmacros.h"

#if DEBUG
#include "stdio.h"
#endif

method EMmatch(IGRlong             *EMmsg;
               union EMSssi_table  *old_ssi;
               IGRint              old_num_surfs;
               GRobjid             *old_surfs;
               IGRint              new_num_surfs;
               GRobjid             *new_surfs;
               IGRushort   options;
               struct GRmd_env     *env)
/*
Description
    Topology and geometry tag matching code.

Return values
    EMS_S_Success if all is well

History
    09/05/91    DLB     Add env param.
    09/03/91    DLB     Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;
 
  /*Match added surfs*/
  OM_stat = EFmatch_surfs_added(EMmsg,
                                old_num_surfs,
                                old_surfs,
                                new_num_surfs,
                                new_surfs,
                                OM_Gw_current_OS, NULL,
                                env);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                                

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "sfboolfea.match")
  return(OM_stat);
}
end implementation EMSsfboolfea;
