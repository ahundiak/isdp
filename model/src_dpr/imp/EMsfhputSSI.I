/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfhist;

#include "EMS.h"
#include "OMmacros.h"

method EMputSSI(IGRlong *EMmsg; union EMSssi_table *ssi)
/*
Description
    This method stores the information in the SSI struct into the 
    save state vla of state.

Return values 
    EMmsg - EMS_S_Success if all is well.

History
    DLB   11/06/87    Creation.
*/
{
  IGRlong                   OM_stat;
  struct EMShstssi_table    *my_info;


  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  my_info = &ssi->hst_info;   /*Cut down on indirection.*/

  /*Expand and fill the vla.*/
  OM_stat = om$vla_set_dimension(varray = ME.EMSdpr->ids,
                                 size = 2);
  if (! (1 & OM_stat)) goto wrapup;

  ME.EMSdpr->ids[0] = my_info->added_id;
  ME.EMSdpr->ids[1] = my_info->added_on;

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsfhist.EMputSSI")
  return(OM_stat);
}
end implementation EMSsfhist;
