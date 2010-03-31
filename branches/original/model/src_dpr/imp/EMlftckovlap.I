/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/

method EMcheckOverlap(IGRlong          *EMmsg; 
                      struct EMSinlist *inlist; 
                      IGRboolean       *does_overlap; 
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
    DLB 07/10/91 Check for removal of an inlist surface.
    DLB 02/08/91 Use EFcheck_overlap.
    DLB 06/16/89 Creation.
*/
{
  IGRlong                OM_stat=OM_S_SUCCESS;
  IGRint                 ii, jj, kk;
  GRobjid                *ssi_id;
  union EMSssi_table     *ssi=NULL;
  struct EMSlftssi_table *my_info=NULL;
  

  *EMmsg = EMS_S_Success;
  *does_overlap = FALSE;

  /*Get the SSI stuff.*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->lft_info;

  /*For every surface of the inlist struct...*/
  for(ii=0; ii<inlist->sflist.num_surfs; ii++)
  {
    /*Is it removed by this state?*/
    ssi_id = my_info->surface_out_ids;

    for(jj=0; jj<my_info->num_composites; jj++)
    {
      for(kk=0; kk<my_info->num_surfaces_out[jj]; kk++, ssi_id++)
      {
        if (inlist->sflist.surf_ids[ii] == *ssi_id)
        {
          *does_overlap = TRUE;
          goto wrapup;
        }
      }
    }

    /*Is it a surface lifted by this state?*/
    for(jj=0; jj<my_info->num_sf_lifted; jj++)
    {
      if (inlist->sflist.surf_ids[ii] == my_info->sf_lifted_ids[jj])
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }
  }

  if (options & EMcheck_overlap_TREAT_SFS_AS_SFMOD) goto wrapup;

  OM_stat = EFcheck_overlap(EMmsg, inlist,
                            my_info->num_sf_affected,
                            my_info->sf_affctd_ids,
                            my_info->num_regions_out,
                            my_info->region_out_ids,
                            0, NULL,
                            my_info->num_eds_rplcd,
                            my_info->ed_rplcd_ids,
                            my_info->num_eds_in,
                            my_info->ed_in_ids,
                            0, NULL,
                            does_overlap,
                            OM_Gw_current_OS, NULL);
  if (!(1 & OM_stat & *EMmsg) || *does_overlap) goto wrapup;

  /*For every edge in the inlist struct...*/
  for(ii=0; ii<inlist->edlist.num_edges; ii++)
  {
    /*Is it affected by a change in common edge connection?*/
    ssi_id = my_info->ed_mcm_ed_ids;
    for(jj=0; jj<my_info->num_eds_wcm_md; jj++, ssi_id += 4)
    {
      if (inlist->edlist.edge_ids[ii] == *ssi_id ||
          inlist->edlist.edge_ids[ii] == *(ssi_id+1))
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }

    /*Again, due to a change in common edge connection?*/    
    ssi_id = my_info->ed_ced_ids;
    ssi_id++;
    for(jj=0; jj<my_info->num_ed_wmv_cm; jj++, ssi_id += 2)
    {
      if (inlist->edlist.edge_ids[ii] == *ssi_id)
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }

    /*And again, due to a change in common edge connection?*/    
    ssi_id = my_info->ed_cm_ed_ids;
    for(jj=0; jj<my_info->num_eds_wcm_eds; jj++, ssi_id += 2)
    {
      if (inlist->edlist.edge_ids[ii] == *ssi_id)
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }
  }

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "lft.ckovlap")
  return(OM_stat);
}
end implementation EMSlift;
