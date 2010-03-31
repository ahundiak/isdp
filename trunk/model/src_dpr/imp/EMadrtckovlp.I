class implementation EMSsfaddraft;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/


/*

DESCRIPTION

    This message will determine if this tree node has an overlap of
    surfaces/topology based on the inlist or outlist.

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        inlist  - contains surf/loop/edge ids that have been added/removed  so
                  far.          
        does_overlap - TRUE if an overlap is detected.
        options - EMcheck_overlap_TREAT_SFS_AS_SFMOD - if specified, treat
                  the ids in the sflist as surfs modified.

    For the special case of a non-intersecting boolean (disjoint or hollow),
    this method will always report an overlap.  

    For the special case of a non-intersection intersect plane - save side,
    this method will always report an overlap.


HISTORY

  02/14/93  : Nirmal: Creation

*/



method EMcheckOverlap(IGRlong          *EMmsg; 
                      struct EMSinlist *inlist; 
                      IGRboolean       *does_overlap; 
                      IGRushort options)

{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  union EMSssi_table      *ssi=NULL;
  struct EMSaddraftssi_table   *my_info=NULL;
  IGRint                  ii, jj, kk;
  GRobjid                 *ssi_id;

  *EMmsg = EMS_S_Success;

  *does_overlap = TRUE;


  if (options & EMcheck_overlap_TREAT_SFS_AS_SFMOD) goto wrapup;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->addrft_info;

  for(ii=0; ii<inlist->sflist.num_surfs; ii++)
  {
    /* Is it removed by this state? */
    ssi_id = my_info->surface_out_ids;

    for(jj=0; jj<my_info->num_composites; jj++)
      for(kk=0; kk<my_info->num_surfaces_out[jj]; kk++, ssi_id++)
        if (inlist->sflist.surf_ids[ii] == *ssi_id)
        {
          *does_overlap = TRUE;
          goto wrapup;
        }
  }

  /*For every edge in the inlist struct...*/
  for(ii=0; ii<inlist->edlist.num_edges; ii++)
  {
    /*Is it in the edges diconnected list?*/
    ssi_id = my_info->old_commedge_pairs1;
    for(jj=0; jj<my_info->num_old_commedge_pairs; jj++, ssi_id++)
    {
      if (inlist->edlist.edge_ids[ii] == *ssi_id)
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }      

    ssi_id = my_info->old_commedge_pairs2;
    for(jj=0; jj<my_info->num_old_commedge_pairs; jj++, ssi_id++)
    {
      if (inlist->edlist.edge_ids[ii] == *ssi_id)
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }      
  }

wrapup:

  *does_overlap = TRUE; 

  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "EMSsfaddraft.EMchkOvlap")
  return(OM_stat);
}
end implementation EMSsfaddraft;
