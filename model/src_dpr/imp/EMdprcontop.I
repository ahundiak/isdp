/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
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
    DLB 07/27/89 Creation.
*/
{
  if (list) *list = NULL;
  *EMmsg = EMS_S_Success;
  return(OM_S_SUCCESS);
}
end implementation EMSdpr;
