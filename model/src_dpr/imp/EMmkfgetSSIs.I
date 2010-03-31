/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmkface;

#include "EMS.h"
#include "EMSmsgdef.h"

/*
   History
            AIC    ???      Creation Date
            RC    06/11/87  Changed due to change in the
                            EMSsfmkface instance data and
                            change in EMSmfssi_table struct
           RC    11/02/87   Modified for version 1.1.0
*/

method EMgetSSIsize(IGRlong *EMmsg; union EMSssiSizeData *size)
{
  IGRint                i, j;
  struct EMSmfssi_size  *my_size;

  *EMmsg = EMS_S_Success;

  my_size = &size->mf_info;
  my_size->num_surfaces = (IGRint) ME.EMSsfregmod->num_surfaces;

  my_size->num_regions_in = 0;
  my_size->num_regions_out = 0;

  for(i = 0; i < my_size->num_surfaces; i ++)
  {
    my_size->num_regions_in += (IGRint) ME.EMSsfregmod->in_out[i];
  }
  for(j = 0; j < my_size->num_surfaces; j ++, i ++)
  {
    my_size->num_regions_out += (IGRint) ME.EMSsfregmod->in_out[i];
  }

  my_size->num_regions = (IGRint) ME.EMSsfmkface->num_regions;
  my_size->num_edges_out = (IGRint) ME.EMSsfmkface->num_edges_out;

  my_size->num_edges_in = 0;
  for(j = 0; j < my_size->num_edges_out; j ++, i ++)
  {
    my_size->num_edges_in += (IGRint) ME.EMSsfregmod->in_out[i];
  }

  my_size->num_edges_copied = (IGRint) ME.EMSsfmkface->num_edges_copied;

  return(OM_S_SUCCESS);
}

end implementation EMSsfmkface;
