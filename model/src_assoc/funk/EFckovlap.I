/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
class implementation EMSdpr;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/

IGRlong EFcheck_overlap(EMmsg, inlist,
                        num_sfs,
                        sfs,
                        num_lps_out,
                        lps_out,
                        num_lps_mod,
                        lps_mod,
                        num_eds_rem,
                        eds_rem,
                        num_eds_added,
                        eds_added,
                        num_eds_copied,
                        eds_copied,
                        does_overlap,
                        osnum, options)
IGRlong           *EMmsg; 
struct EMSinlist  *inlist; 
IGRint            num_sfs;
GRobjid           *sfs;
IGRint            *num_lps_out;
GRobjid           *lps_out;
IGRint            num_lps_mod;
GRobjid           *lps_mod;
IGRint            num_eds_rem;
GRobjid           *eds_rem;
IGRint            *num_eds_added;
GRobjid           *eds_added;
IGRint            num_eds_copied;
GRobjid           *eds_copied;
IGRboolean        *does_overlap; 
OMuword           osnum;
IGRushort options;
/*
Description
    This function will determine if this tree node has an overlap of
    surfaces/topology based on the inlist or outlist.

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        inlist  - contains surf/loop/edge ids that have been added/removed so
                  far.  

        does_overlap - TRUE if an overlap is detected.
        options - NONE so far.

History
    DLB 02/08/91    Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  ii, jj, kk;
  GRobjid                 *ssi_id;
  extern IGRboolean       EFis_edge_owned_by_edlp();


  *EMmsg = EMS_S_Success;

  *does_overlap = FALSE;

  /*For every surface of the inlist struct, see if it is also a surface
   * modified by this state.
   */ 
  for(ii=0; ii<inlist->sflist.num_surfs; ii++)
  {
    for(jj=0; jj<num_sfs; jj++)
    {
      if (inlist->sflist.surf_ids[ii] == sfs[jj])
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }
  }

  /*For every loop in the inlist struct, see if it is also a loop removed
   * by this state.
   */  
  for(ii=0; ii<inlist->lplist.num_loops; ii++)
  {
    ssi_id = lps_out;
    for(jj=0; jj<num_sfs; jj++)
    {
      for(kk=0; kk<num_lps_out[jj]; kk++, ssi_id++)
      {
        if (inlist->lplist.loop_ids[ii] == *ssi_id)
        {
          *does_overlap = TRUE;
          goto wrapup;
        }
      }
    }

    /*Is it a modified loop by this state?*/
    ssi_id = lps_mod;
    for(jj=0; jj<num_lps_mod; jj++, ssi_id++)
    {
      if (inlist->lplist.loop_ids[ii] == *ssi_id)
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }      

    /*Does it own (either directly or indirectly) an ADDED edge?
     * This may be a redundant check in some cases.
     */
    ssi_id = eds_added;
    for(jj=0; jj<num_eds_rem; jj++)
    {
      for(kk=0; kk<num_eds_added[jj]; kk++, ssi_id++)
      {
        if (EFis_edge_owned_by_edlp(EMmsg, *ssi_id, 
                                    inlist->lplist.loop_ids[ii], osnum))
        {
          *does_overlap = TRUE;
          goto wrapup;
        }
        else if (!(1 & *EMmsg)) goto wrapup;
      }        
    }
  }
  
  /*For every edge in the list struct...*/
  for(ii=0; ii<inlist->edlist.num_edges; ii++)
  {
    /*Is it a removed edge by this state?*/
    ssi_id = eds_rem;
    for(jj=0; jj<num_eds_rem; jj++, ssi_id++)
    {
      if (inlist->edlist.edge_ids[ii] == *ssi_id)
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }      

    /*Is it owned (directly or indirectly) by a removed loop?*/
    ssi_id = lps_out;
    for(jj=0; jj<num_sfs; jj++)
    {
      for(kk=0; kk<num_lps_out[jj]; kk++, ssi_id++)
      {
        /*See if it owns and an edge (directly/indirectly)*/
        if (EFis_edge_owned_by_edlp(EMmsg, inlist->edlist.edge_ids[ii],
                                    *ssi_id, osnum))
        {
          *does_overlap = TRUE;
          goto wrapup;
        }
        else if (!(1 & *EMmsg)) goto wrapup;
      }
    }

    /*Is it removed due to a copy?*/
    ssi_id = eds_copied;
    for(jj=0; jj<num_eds_copied; jj++, ssi_id += 2)
    {
      if (inlist->edlist.edge_ids[ii] == *ssi_id)
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }
  }      

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFcheck_overlap")
  return(OM_stat);
}
end implementation EMSdpr;
