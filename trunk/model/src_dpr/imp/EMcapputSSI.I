class implementation EMSsfcapsf;

#include "EMSopt.h"
#include "OMmacros.h"

from EMSloop import EMset_props;

method EMputSSI( IGRlong *EMmsg; 
                 union EMSssi_table *ssi)

/*

DESCRIPTION

This method stores the save state info in its packed form in the
instance data of this object.

RETURN VALUES
 
EMmsg - EMSS_S_Success if all is well.

HISTORY

  11/10/92  :  AMD  :  Creation

*/

{
  IGRlong                   sts;
  IGRint                    i;
  struct EMScapssi_table     *my_info;
  void                      EFcvrt_to_from_tag();


  /* Initialize */

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  i = 0;

  if (NOT ssi) return EMS_S_Success;

  my_info = &ssi->cap_info;

  /* Compute the size needed for SSI */
 
  i += my_info->num_edges;

  /* Expand the vla for SSI */
 
  sts = om$vla_set_dimension(varray = ME.EMSdpr->ids,
                              size = i);
  if (!(1 & sts)) goto wrapup;   
 
  /* Put the edges connected */

  i = 0;
  if (my_info->num_edges)
  {
    OM_BLOCK_MOVE(my_info->edges_connected,
                  &ME.EMSdpr->ids[i],
                  my_info->num_edges* sizeof(GRobjid));
    i += my_info->num_edges;
  }

  ME.EMSsfcapsf->num_edges = my_info->num_edges;
  
wrapup:

  EMWRAPUP(*EMmsg, sts, "EMSsfcapsf.EMputSSI")
  return(sts);
}
end implementation EMSsfcapsf;
