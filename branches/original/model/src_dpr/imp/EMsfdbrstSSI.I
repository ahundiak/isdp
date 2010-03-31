class implementation EMSsfrembnd;

#include "OMmacros.h"

method EMresetSSI(IGRlong *EMmsg)
/*
Description
    This message will reset the SSI instance data to zero.

Return Values    
    EMSS_S_Success if all is well.

Notes

History

    AMD :03/16/93 : Creation

*/
{
  *EMmsg = EMS_S_Success;

  ME.EMSsfregmod->num_surfaces = 0;
  ME.EMSsfrembnd->num_composites = 0;
  ME.EMSsfrembnd->num_edges = 0;

  om$vla_set_dimension(varray = ME.EMSdpr->ids, size = 0);
  om$vla_set_dimension(varray = ME.EMSsfregmod->in_out, size = 0);

  return(OM_S_SUCCESS);
}
end implementation EMSsfrembnd;
