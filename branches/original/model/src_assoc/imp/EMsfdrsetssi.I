/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfregmod;

#include "OMmacros.h"

method EMresetSSI(IGRlong *EMmsg)
/*
Description
    This message will reset the SSI instance data to zero.

Return Values    
    EMSS_S_Success if all is well.

Notes

History
    DLB 10/29/90 Creation.
*/
{
  *EMmsg = EMS_S_Success;

  ME.EMSsfregmod->num_surfaces = 0;

  om$vla_set_dimension(varray = ME.EMSdpr->ids, size = 0);
  om$vla_set_dimension(varray = ME.EMSsfregmod->in_out, size = 0);

  return(OM_S_SUCCESS);
}
end implementation EMSsfregmod;
