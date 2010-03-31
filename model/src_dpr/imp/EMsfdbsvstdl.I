/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfrembnd;

#include "EMS.h"
/* IF_NULL_OBJID, om$dimension_of */
# include "OMmacros.h"

/*
HISTORY

 August, 1991  :  AMD  :  Creation

*/

method EMsavestatedelete (IGRlong *EMmsg; struct GRmd_env *my_env;
                          union EMSssi_table *ssi)
{
ME.EMSsfregmod->num_surfaces = 0;
ME.EMSsfrembnd->num_composites = 0;
ME.EMSsfrembnd->num_edges = 0;
*EMmsg = EMS_S_Success;
return (OM_S_SUCCESS);

}
end implementation EMSsfrembnd;
