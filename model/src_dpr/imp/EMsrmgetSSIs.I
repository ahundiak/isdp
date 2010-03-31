/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfregmod;

#include "EMS.h"
#include "OMmacros.h"

method EMgetSSIsize(IGRlong *EMmsg; union EMSssiSizeData *size)
/*
Description
  This method fills the EMSsfssi_size structure so that EMgetSSibuffer
  may be called to malloc the exact size of the buffer.

Return values
  size - pointer to the structure
  EMmsg - Since only simple code exists here, EMS_S_Success is always 
          returned.

Notes
  This method assumes that the referenced instance data has valid values.

History
  SM  11-Feb-88 Modified to take care of edges modified.
  DLB 11/02/87  Modified structure name for version 1.1.0
  AIC xx/xx/87  Creation
*/  
{
  IGRint                i, j, vla_size;
  struct EMSsfssi_size  *my_size;


  *EMmsg = EMS_S_Success;

  my_size = &size->sf_info;

  /*Have num surface ids in instance data.*/
  my_size->num_surfaces = ME.EMSsfregmod->num_surfaces;

  /*Get total num regions in and out*/  
  my_size->num_regions_in = 0;
  my_size->num_regions_out = 0;

  for(i = 0; i < my_size->num_surfaces; i ++)
    my_size->num_regions_in += ME.EMSsfregmod->in_out[i];

  for(j = 0; j < my_size->num_surfaces; j ++, i ++)
    my_size->num_regions_out +=  ME.EMSsfregmod->in_out[i];

  if( (vla_size = om$dimension_of(varray = ME.EMSsfregmod->in_out))
      > i)
   {
     my_size->num_regions = ME.EMSsfregmod->in_out[i++];
     my_size->num_edges_out = ME.EMSsfregmod->in_out[i++];
     my_size->num_edges_in = 0;
     for(j = 0; j < my_size->num_edges_out; j ++, i ++)
        my_size->num_edges_in += (IGRint) ME.EMSsfregmod->in_out[i];
   }
  else
   {
     my_size->num_regions = 0;
     my_size->num_edges_in = 0;
     my_size->num_edges_out = 0;
   }

  i+= my_size->num_regions;
  if( (vla_size = om$dimension_of(varray = ME.EMSsfregmod->in_out))
      > i)
     my_size->num_edges_copied = ME.EMSsfregmod->in_out[i++];
  else
     my_size->num_edges_copied = 0;

  return(OM_S_SUCCESS);
}

end implementation EMSsfregmod;
