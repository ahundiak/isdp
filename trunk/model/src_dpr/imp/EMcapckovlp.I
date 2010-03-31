class implementation EMSsfcapsf;

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

  07/14/92  : AMD : Creation

*/



method EMcheckOverlap(IGRlong          *EMmsg; 
                      struct EMSinlist *inlist; 
                      IGRboolean       *does_overlap; 
                      IGRushort options)

{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  union EMSssi_table      *ssi=NULL;
  struct EMScapssi_table  *my_info=NULL;
  IGRint                  ii, jj;
  GRobjid                 *ssi_id;

  *EMmsg = EMS_S_Success;

  *does_overlap = TRUE;

  if (options & EMcheck_overlap_TREAT_SFS_AS_SFMOD) goto wrapup;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->cap_info;

  for(ii=0; ii<inlist->edlist.num_edges; ii++)
  {
   ssi_id = my_info->edges_connected;
   for(jj=0; jj<my_info->num_edges; jj++, ssi_id++)
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
  EMWRAPUP(*EMmsg, OM_stat, "EMSsfcapsf.EMchkOvlap")
  return(OM_stat);
}
end implementation EMSsfcapsf;
