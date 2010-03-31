/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

#include "EMS.h"
#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/

from EMSboundary import EMgetsurface_info;

method EMcheckOverlap(IGRlong *EMmsg;
                      struct EMSinlist *inlist;
                      IGRboolean *does_overlap; IGRushort options)
/*
Description
    This message will determine if this tree node has an overlap of
    surfaces/topology based on the inlist.

Return Values    
    EMS_S_Success if all is well.

Notes
    About parameters:
        inlist  - contains surf/loop/edge ids that have been added so far. 
        does_overlap - TRUE if an overlap is detected.
        options - EMcheck_overlap_TREAT_SFS_AS_SFMOD - if specified, treat
                  the ids in the sflist as surfs modified.

History
    DLB 12/10/92 If I'm not a solid class or I have no edges connected
                 then force an overlap.
    DLB 10/22/89 Added edges connected check.
    DLB 06/08/89 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            i, j, k;
  GRobjid           *ssi_id, surf_id;
  union EMSssi_table      *ssi=NULL;
  struct EMSstchssi_table *my_info=NULL;
  IGRboolean              EFis_edge_owned_by_edlp();
  extern OMuword          OPP_EMSsolid_class_id;


  *EMmsg = EMS_S_Success;

  if (!EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, OPP_EMSsolid_class_id,
                         FALSE))
  {
    *does_overlap = TRUE;
    goto wrapup;
  }                         

  *does_overlap = FALSE;

  /*Get the SSI stuff.*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->stch_info;

  if (!my_info->num_edges_connected) 
  {
    *does_overlap = TRUE;
    goto wrapup;
  }

  /*For every edge added by this state, see if its owning surface is in
   * the inlist.
   */ 
  ssi_id = my_info->edges_in;
  for(i=0; i<my_info->num_edges_out; i++)
  {
    for(j=0; j<my_info->num_edges_in[i]; j++, ssi_id++)
    {
      surf_id = NULL_OBJID;
      OM_stat = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg,
                              &surf_id, NULL),
                        targetid = *ssi_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      for(k=0; k<inlist->sflist.num_surfs; k++)
      {
        if (inlist->sflist.surf_ids[k] == surf_id)
        {
          *does_overlap = TRUE;
          goto wrapup;
        }
      }
    }
  }      

  /*For every loop in the inlist struct...*/
  for(i=0; i<inlist->lplist.num_loops; i++)
  {
    /*Does it own either directly or indirectly an ADDED edge?*/
    ssi_id = my_info->edges_in;
    for(j=0; j<my_info->num_edges_out; j++)
    {
      for(k=0; k<my_info->num_edges_in[j]; k++, ssi_id++)
      {
        if (EFis_edge_owned_by_edlp(EMmsg, *ssi_id,
                                    inlist->lplist.loop_ids[i],
                                    OM_Gw_current_OS))
        {
          *does_overlap = TRUE;
          goto wrapup;
        }
        else if (!(1 & *EMmsg)) goto wrapup;
      }        
    }
  }

  /*For every edge in the inlist struct...*/
  for(i=0; i<inlist->edlist.num_edges; i++)
  {
    /*Is it a removed edge by this state?*/
    ssi_id = my_info->edges_out;
    for(j=0; j<my_info->num_edges_out; j++, ssi_id++)
    {
      if (inlist->edlist.edge_ids[i] == *ssi_id)
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }      

    /*Is it a connected edge by this state?*/
    ssi_id = my_info->edges_connected;
    for(j=0; j<my_info->num_edges_connected; j++, ssi_id++)
    {
      if (inlist->edlist.edge_ids[i] == *ssi_id)
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }      
  }
  
  wrapup:
    if (ssi) om$dealloc(ptr = ssi);
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfstitch.EMcheckOverlap")
    return(OM_stat);
}
end implementation EMSsfstitch;
