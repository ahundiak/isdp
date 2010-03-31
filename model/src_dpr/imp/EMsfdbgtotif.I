/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfrembnd;

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

History

 August, 1991  :  AMD  :  Creation

*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  union EMSssi_table      *ssi=NULL;
  struct EMSdbssi_table   *my_info=NULL;
  IGRint                  i, *num_dummy_objs=NULL;
  extern IGRlong          EFget_outinfo_from_lpinfo();


  *EMmsg = EMS_S_Success;

  /*Get out info for this state. */
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->db_info;

  num_dummy_objs = (IGRint *) alloca ( (my_info->num_surfaces)
                    * sizeof (IGRint));

/* Fix for TR#119306766 by vidya */
  for (i=0; i<my_info->num_surfaces; i++)
    num_dummy_objs[i] = 0;
   

  OM_stat = EFget_outinfo_from_lpinfo(EMmsg,
                                      my_info->num_composites,
                                      my_info->num_surfaces_out,
                                      my_info->surface_out_ids,
                                      my_info->num_surfaces,
                                      my_info->surface_ids,
				      num_dummy_objs,
                                      my_info->num_regions_out,
				      NULL,
                                      my_info->region_out_ids,
                                      outlist, OM_Gw_current_OS, NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "EMSsfrembnd.getOutInfo")

  return(OM_stat);
}
end implementation EMSsfrembnd;
