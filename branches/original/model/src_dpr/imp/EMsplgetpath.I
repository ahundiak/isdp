/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "EMSdpr.h"

extern OMuword OPP_EMSsubbs_class_id;

method EMgettreepath(IGRlong *EMmsg; GRobjid **pathlist; 
                     IGRint *pathlist_count; IGRboolean unused)
/*
Description
   This method will return the tree path from the lowermost tree node
   (primitive) to the active dpr state.

Return Values
   EMS_S_Success    if all is well

Notes
   The initial sender of this method MUST set pathlist = NULL and
   pathlist_count = 0 

History
   DLB 06/11/89  Creation
*/
{
  IGRlong               OM_stat=OM_S_SUCCESS;


  *EMmsg = EMS_S_Success;    

  if (!EFisAncestryValid(EMmsg, sender_id, OM_Gw_current_OS, 
                         OPP_EMSsubbs_class_id, FALSE))
  {
    /*The sender is not surface so the sender will be added.*/
    EFrealloc_if_needed(EMmsg, pathlist, *pathlist_count,
                        TREE_PATH_BUFF_INCR, sizeof(GRobjid)); 
    if (!(1 & *EMmsg)) goto wrapup;

    (*pathlist)[*pathlist_count] = sender_id;
    (*pathlist_count)++;
  }                            

  /*Get the rest of the path.*/
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsurface.EMgettreepath(EMmsg,
                          pathlist, pathlist_count, unused),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfsplit.EMgettreepath")
    return(OM_stat);
}
end implementation EMSsfsplit;
