/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/
#include "OMmacros.h"

#define INCREMENT 50 

method EMgetOutInfo(IGRlong           *EMmsg; 
                    struct EMSoutlist *outlist; 
                    IGRushort options)
/*
Description
    This message will return the out information for this state by adding it
    to the existing outlist.  This includes the surfaces of the state that
    were removed (if any). 

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        outlist  - contains surf/loop/edge ids that have been removed so far.
                   This structure may be passed this info aready in it.  
                   The memory may be malloc'd or realloc'd as necessary.
        options - none at the moment.

History
    DLB 07/08/91 Check for num_sf_lifted before putting in outlist.rnglist.
    DLB 07/01/91 Put the lifted surface in outlist.rnglist.
    DLB 02/13/91 Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  num_repl_info;
  union EMSssi_table      *ssi=NULL;
  struct EMSlftssi_table  *my_info=NULL;
  extern IGRlong          EFget_outinfo_from_lpinfo();
  extern void             EFalloc_list();


  *EMmsg = EMS_S_Success;

  /*Get out info for this state.*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->lft_info;

  if (my_info->num_sf_lifted)
  {
    num_repl_info = outlist->rnglist.num_repl_info;
  
    if (num_repl_info)
    {
      outlist->rnglist.replace_info = (struct EMSreplace_info *)
       om$realloc(ptr = (char *) outlist->rnglist.replace_info,
                  size = (num_repl_info + 1) * sizeof(struct EMSreplace_info));
  
    } 
    else
    {
      outlist->rnglist.replace_info = (struct EMSreplace_info *)
                              om$malloc(size = sizeof(struct EMSreplace_info));
    }
    if (! outlist->rnglist.replace_info)
    {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
    
    outlist->rnglist.replace_info[num_repl_info].replacing_id = 
                                                     my_info->sf_lifted_ids[0];
    outlist->rnglist.num_repl_info += 1;
  }  

  OM_stat = EFget_outinfo_from_lpinfo(EMmsg,
                                      my_info->num_composites,
                                      my_info->num_surfaces_out,
                                      my_info->surface_out_ids,
                                      my_info->num_sf_affected,
                                      my_info->sf_affctd_ids,
                                      my_info->num_regions_in,
                                      my_info->num_regions_out,
                                      my_info->region_in_ids,
                                      my_info->region_out_ids,
                                      outlist, OM_Gw_current_OS, NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (my_info->num_eds_rplcd)
  {
    EFalloc_list(EMmsg, &outlist->edlist.edge_ids, outlist->edlist.num_edges,
                 &outlist->edlist.array_size,
                 my_info->num_eds_rplcd, INCREMENT, NULL); 
    if (!(1 & *EMmsg)) goto wrapup;                 

    /*Now add the edges out.*/
    OM_BLOCK_MOVE(my_info->ed_rplcd_ids, 
                  &outlist->edlist.edge_ids[outlist->edlist.num_edges],
                  my_info->num_eds_rplcd * sizeof(GRobjid));
    outlist->edlist.num_edges += my_info->num_eds_rplcd;
  }

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "lft.EMgetOutInfo")
  return(OM_stat);
}
end implementation EMSlift;
