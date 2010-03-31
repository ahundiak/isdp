/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "EMSmsgdef.h"

method EMgetSSIsize(IGRlong              *EMmsg;
                    union EMSssiSizeData *size)

{
  IGRint                 i, j;
  struct EMSrndssi_size  *my_size;

  *EMmsg = EMS_S_Success;

  i = 0;
  my_size = &size->rnd_info;
  my_size->num_surfaces = (IGRint) ME.EMSsfregmod->in_out[i++];

  my_size->num_regions_in = 0;
  my_size->num_regions_out = 0;
  my_size->num_edges_in = 0;

  for(j=0; j<my_size->num_surfaces; j++, i++)
   {
    my_size->num_regions_in += (IGRint) ME.EMSsfregmod->in_out[i];
   }
  for(j=0; j<my_size->num_surfaces; j++, i++)
   {
    my_size->num_regions_out += (IGRint) ME.EMSsfregmod->in_out[i];
   }

  my_size->num_edges_out = (IGRint) ME.EMSsfregmod->in_out[i++];

  for(j=0; j<my_size->num_edges_out; j++, i++)
   {
    my_size->num_edges_in += (IGRint) ME.EMSsfregmod->in_out[i];
   }

  my_size->num_edges_rounded = (IGRint) ME.EMSsfregmod->in_out[i++];

  return(OM_S_SUCCESS);
}

end implementation EMSsfround;
