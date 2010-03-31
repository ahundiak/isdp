/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

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
  union EMSssi_table    *ssi;
  IGRboolean            add_sender=TRUE;


  *EMmsg = EMS_S_Success;    

  ssi = NULL;
  if (EFisAncestryValid(EMmsg, sender_id, OM_Gw_current_OS, 
                        OPP_EMSsubbs_class_id, FALSE))
  {
    /*The sender is a surface so see if it one this state added.*/
    OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

    if (!ssi->lft_info.num_sf_lifted ||
        sender_id != ssi->mf_info.surface_ids[0])
    {
      /*Sender is an added surface.*/
      add_sender = FALSE;
    }       
  }                            

  if (add_sender)
  {
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
    if (ssi) om$dealloc(ptr = ssi);
    EMWRAPUP(*EMmsg, OM_stat, "EMSlift.EMgettreepath")
    return(OM_stat);
}
end implementation EMSlift;
