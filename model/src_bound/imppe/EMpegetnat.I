/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
# include "EMSmsgdef.h"     /* EMS error code   */
# include "EMSlogic.h"      /* IS               */

method EMget_natural_edges(IGRlong *EMmsg; IGRint edge_num;
                           GRobjid *buffer; IGRint buffer_size;
                           GRobjid **nat_edge_ids; IGRint *num_nat_edges)
{
  IGRlong           sts;
  IGRint            num_existing_nat_edges;
  OM_S_CHANSELECT   to_edge;

  /*
   * Initialize
   */
  num_existing_nat_edges = *num_nat_edges;
  to_edge.type = OM_e_addr;
  to_edge.u_sel.addr = &ME.EMSbd_owner->to_comps;

  /*
   * If I am on the natural edge, put me in the list.
   */
  sts = om$send(msg = OPPmargs, p_chanselect = &to_edge);
  if(sts IS OM_I_STOP_SENDING) sts = OM_S_SUCCESS;
  if((*num_nat_edges > num_existing_nat_edges) && nat_edge_ids)
    (*nat_edge_ids)[num_existing_nat_edges] = my_id;

  return(sts);
}

end implementation EMSpartedge;
