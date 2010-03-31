/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/

method EMconnectTopology(IGRlong *EMmsg; 
                         IGRchar **list;
                         IGRushort options)
/*
Description
    This message either disconnects or connects the topology created by this
    node to the active topology.

Return Values    
    EMS_S_Success if all is well.

Notes
    About parameters:
        options - EMconnect_top_DISCONNECT reconnect already diconnected
                  topology. If not set the topology will be disconnected.
                  EMconnect_top_FREE_ONLY - free the list structure ONLY. 

History
    DLB 06/01/91 Use EFconnect_topology function.
    DLB 07/27/89 Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  union EMSssi_table      *ssi=NULL;
  struct EMSstchssi_table *my_info=NULL;


  *EMmsg = EMS_S_Success;

  if (options & EMconnect_top_DISCONNECT)
  {
    /*Disconnect my created topology (part edges!)*/

    /*Get the SSI stuff.*/
    OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

    my_info = &ssi->stch_info;

    OM_stat = EFconnect_topology(EMmsg,
                                 NULL,
                                 NULL, 
                                 NULL, 
                                 NULL,
                                 NULL,
                                 my_info->num_edges_out,
                                 my_info->edges_out,
                                 my_info->num_edges_in,
                                 my_info->edges_in,
                                 list, OM_Gw_current_OS, options);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }
  else
  {
    /*Reconnect the part edge.*/
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
  EMWRAPUP(*EMmsg, OM_stat, "stch.contop")
  return(OM_stat);
}
end implementation EMSsfstitch;
