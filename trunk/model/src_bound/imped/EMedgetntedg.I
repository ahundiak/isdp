/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
method EMget_natural_edges(IGRlong *EMmsg; IGRint edge_num;
                           GRobjid *buffer; IGRint buffer_size;
                           GRobjid **nat_edge_ids; IGRint *num_nat_edges)
{
  *EMmsg = EMS_S_Success;
  return(OM_S_SUCCESS);
}

end implementation EMSedge;
