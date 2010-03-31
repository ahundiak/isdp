/* ###################   APOGEE COMPILED   ################## */
class implementation EMSnatedge;

# include "EMSmsgdef.h"     /* EMS error code   */
# include "EMSlogic.h"      /* EMSmsgReport     */
# include "EMStypedef.h"    /* EMSmsgReport     */
# include "EMScmacros.h"    /* EMSmsgReport     */

method EMget_natural_edges(IGRlong *EMmsg; IGRint edge_num;
                           GRobjid *buffer; IGRint buffer_size;
                           GRobjid **nat_edge_ids; IGRint *num_nat_edges)
{
  IGRlong   sts;

  /*
   * Initilize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if(edge_num == (IGRint)(ME.EMSnatedge->location & 0x3))
  {
    /*
     * Add me to the list
     */
    if(nat_edge_ids) (*nat_edge_ids)[*num_nat_edges] = my_id;
    *num_nat_edges += 1;

    /*
     * There's no need to continue looking.
     */
    sts = OM_I_STOP_SENDING;
  }

wrapup:
  EMSmsgReport(sts, "EMSnatedge.EMget_natural_edges", FALSE);
  if EMSmsgReport(*EMmsg, "EMSnatedge.EMget_natural_edges", FALSE)
    sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSnatedge;
