/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmove;

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
        options - currently unused.

History
    DLB 06/08/89 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            i, j;
  GRobjid           *ssi_id, surf_id;
  union EMSssi_table     *ssi=NULL;
  struct EMSmvssi_table  *my_info=NULL;


  *EMmsg = EMS_S_Success;

  *does_overlap = FALSE;

  /*Get the SSI stuff.*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->mv_info;

  /*For every surface of the inlist struct, see if it is also a surface
   * modified by this state.
   */ 
  for(i=0; i<inlist->sflist.num_surfs; i++)
  {
    ssi_id = my_info->loop_ids;
    for(j=0; j<my_info->num_loops; j++, ssi_id++)
    {
      OM_stat = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg,
                              &surf_id, NULL),
                        targetid = *ssi_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (inlist->sflist.surf_ids[i] == surf_id)
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }
  }

  wrapup:
    if (ssi) om$dealloc(ptr = ssi);
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfmove.EMcheckOverlap")
    return(OM_stat);
}
end implementation EMSsfmove;
