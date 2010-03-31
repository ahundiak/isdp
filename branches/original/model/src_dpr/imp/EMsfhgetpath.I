/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfhist;

#include "EMS.h"
#include "EMSdpr.h"

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
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRint          ii;
  OMuint          count;
  GRobjid         owner_id;
  OM_S_CHANSELECT to_owners;  
  OMuword         dumosnum;


  EMmake_chanselect(GRconnector_to_owners, &to_owners);

  /*Get the rest of the path.  I need to send my sender_id on with the
   * send to my owners.  This must be done specially since the sender_id
   * specifies whose channel to send across.  Therefore I must send to 
   * a target id.
   */
  OM_stat = om$get_channel_count(object = me,
                                 p_chanselect = &to_owners,
                                 count = &count);
  if (!(1 & OM_stat)) goto wrapup;                                

  *EMmsg = EMS_I_NoResponse;
  for(ii=0; ii<count; ii++)
  {
    OM_stat = om$get_objid_at_index(object = me,
                                    p_chanselect = &to_owners,
                                    index = ii,
                                    objidaddr = &owner_id,
                                    osnumaddr = &dumosnum);
    if (!(1 & OM_stat)) goto wrapup;

    OM_stat = om$send(msg = message EMSsurface.EMgettreepath(EMmsg,
                            pathlist, pathlist_count, unused),
                      senderid = sender_id,
                      targetid = owner_id);
    if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
    OM_stat = OM_S_SUCCESS;
  }

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfhist.EMgettreepath")
    return(OM_stat);
}
end implementation EMSsfhist;
