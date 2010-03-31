/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfhist;

#include "EMS.h"
method EMgetSSI(IGRlong *EMmsg; union EMSssi_table **ssi)
/*
Description
   This method gets the SSI table corresponding to the save state
   information stored at the history class state.

Return values
   EMmsg - EMS_S_Success if all is well.
   ssi   - pointer to SSI structure.

Notes
   Since the size of the SSI for this class is a constant, EMgetSSIsize is
   not needed (and is not overridden).  EMgetSSIbuffer is still called to
   ensure ease of conversion if and when the SSI structure is NOT a constant
   size. 

History
   DLB   11/06/87   Creation.   
*/
{
  IGRlong                   OM_stat;
  struct EMShstssi_table    *my_info;  

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  *ssi = NULL;

  /*Get the SSI structure (size is constant).*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSIbuffer(EMmsg, NULL, ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Get the ids from vla.*/
  my_info = &((*ssi)->hst_info);        /*Cut down on indirection.*/

  OM_stat = om$is_objid_valid(objid = ME.EMSdpr->ids[0]);
  if (OM_stat == OM_S_SUCCESS)
    my_info->added_id = ME.EMSdpr->ids[0];
  else
    my_info->added_id = NULL_OBJID;

  OM_stat = om$is_objid_valid(objid = ME.EMSdpr->ids[1]);
  if (OM_stat == OM_S_SUCCESS)
    my_info->added_on = ME.EMSdpr->ids[1];
  else
    my_info->added_on = NULL_OBJID;

  OM_stat = OM_S_SUCCESS;
   
 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsfhist.EMgetSSI")  
  return(OM_stat);
}
end implementation EMSsfhist;
