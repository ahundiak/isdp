class implementation EMSsfunitesf;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/

method EMgetOutInfo(IGRlong           *EMmsg; 
                    struct EMSoutlist *outlist; 
                    IGRushort options)
/*
Description
    This message will return the out information for this state by adding it
    to the existing outlist.  This includes the surfaces of the state that
    were removed. 

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        outlist  - contains surf/loop/edge ids that have been removed so far.
                   This structure may be passed this info aready in it.  
                   The memory may be malloc'd or realloc'd as necessary.
        options - none at the moment.

HISTORY

  07/14/92  :  AMD  :  Creation

*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  union EMSssi_table      *ssi=NULL;
  struct EMSunssi_table *my_info=NULL;
  extern IGRlong          EFget_outinfo_from_lpinfo();
  

  *EMmsg = EMS_S_Success;

  /*Get out info for this state. */
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->un_info;
  OM_stat = EFget_outinfo_from_lpinfo(EMmsg,
                                      my_info->num_composites,
                                      my_info->num_surfaces_out,
                                      my_info->surface_out_ids,
                                      NULL,
                                      NULL,
				      NULL,
                                      NULL,
				      NULL,
                                      NULL,
                                      outlist, OM_Gw_current_OS, NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "EMSsfunitesf.getOutInfo")

  return(OM_stat);
}
end implementation EMSsfunitesf;
