/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/

method EMconnectTopology(IGRlong           *EMmsg; 
                         IGRchar           **list; 
                         IGRushort options)
/*
Description
    This message either disconnects or connects the topology created by this
    node to the active topology.

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        options - EMconnect_top_DISCONNECT reconnect already diconnected
                  topology. If not set the topology will be disconnected.
                  EMconnect_top_FREE_ONLY - free the list structure ONLY. 

History
    DLB 02/05/91 Use cont_top function.
    DLB 07/27/89 Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  union EMSssi_table      *ssi=NULL;
  struct EMSboolssi_table *my_info=NULL;


  *EMmsg = EMS_S_Success;

  if (options & EMconnect_top_DISCONNECT)
  {
    /*Disconnect my created topology (part edges!)*/
    OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

    my_info = &ssi->bool_info;
    OM_stat = EFconnect_topology(EMmsg,
                                 my_info->num_surfaces,
                                 my_info->num_regions_in,
                                 my_info->region_in_ids,
                                 my_info->num_regions_out,
                                 my_info->region_out_ids,
                                 0,
                                 NULL,
                                 NULL,
                                 NULL,
                                 list, OM_Gw_current_OS, options);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }
  else
  {
    OM_stat = EFconnect_topology(EMmsg,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 list, OM_Gw_current_OS, options);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "sfb.contop")
  return(OM_stat);
}
end implementation EMSsfboolean;
