/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/

method EMcheckOverlap(IGRlong *EMmsg; 
                      struct EMSinlist *inlist; 
                      IGRboolean *does_overlap; 
                      IGRushort options)
/*
Description
    This message will determine if this tree node has an overlap of
    surfaces/topology based on the inlist.

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        inlist  - contains surf/loop/edge ids that have been added so far. 
        does_overlap - TRUE if an overlap is detected.
        options - EMcheck_overlap_TREAT_SFS_AS_SFMOD - if specified, treat
                  the ids in the sflist as surfs modified.

History
    DLB 02/08/91 Use EFcheck_overlap function.
    DLB 10/18/89 Was specifying mf_info for the EMSssi_table union struct.
                 Should be rnd_info.
    DLB 06/08/89 Creation.
*/
{
  IGRlong                OM_stat=OM_S_SUCCESS;
  union EMSssi_table     *ssi=NULL;
  struct EMSrndssi_table *my_info=NULL;


  *EMmsg = EMS_S_Success;

  *does_overlap = FALSE;

  if (options & EMcheck_overlap_TREAT_SFS_AS_SFMOD) goto wrapup;

  /*Get the SSI stuff.*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->rnd_info;
  OM_stat = EFcheck_overlap(EMmsg, inlist,
                            my_info->num_surfaces,
                            my_info->surface_ids,
                            my_info->num_regions_out,
                            my_info->region_out_ids,
                            0, NULL,
                            my_info->num_edges_out,
                            my_info->edge_out_ids,
                            my_info->num_edges_in,
                            my_info->edge_in_ids,
                            0, NULL,
                            does_overlap,
                            OM_Gw_current_OS, NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "sfrnd.EMckOvlap")
  return(OM_stat);
}
end implementation EMSsfround;
