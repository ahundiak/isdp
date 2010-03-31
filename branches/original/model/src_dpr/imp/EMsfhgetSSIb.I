/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfhist;

#include "EMS.h"
method EMgetSSIbuffer(IGRlong *EMmsg; union EMSssiSizeData *size;
                      union EMSssi_table **ssi)
/*
Description
   This method allocates the save state info structure used by the 
   history state.

Return values
   EMmsg - EMS_S_Success if all is well.
   ssi - pointer to the SSI structure.

Notes
   Since the SSI structure for this class is a constant size, there is no
   need to reference 'size' parameter (it may be set to NULL).

History
   DLB  11/06/87  Creation.
*/
{
  IGRlong OM_stat = OM_S_SUCCESS;


  *EMmsg = EMS_S_Success;
  *ssi = NULL;

  /*Allocate the buffer*/
  *ssi = (union EMSssi_table *)om$malloc(size = sizeof(union EMSssi_table));
  if (! *ssi) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

 wrapup:
  EMWRAPUP_MSG(*EMmsg, OM_stat, "In EMSsfhist.EMgetSSIbuffer")
  return(OM_stat);
}
end implementation EMSsfhist;
