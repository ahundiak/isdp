class implementation EMSsfrembnd;

#include "EMS.h"
# include "OMmacros.h"

method EMgetSSIsize(IGRlong *EMmsg; union EMSssiSizeData *size)
/*
Description
  This method fills the EMSdbssi_size structure so that EMgetSSibuffer
  may be called to malloc the exact size of the buffer.

Return values
  size - pointer to the structure
  EMmsg - EMS_S_Success for success in evaluating the size of a
            consistent SSI table
          EMS_I_Success for success in evaluating the size of an
            inconsistent SSI table for a boolean with wholly
            removed operands.
          EMS_E_InvalidArg if this boolean's type is unknown
          EMS_E_Fail if analyzing the type fails entirely

Notes
  This method assumes that the referenced instance data has valid values.

History

 August, 1991  :  AMD  :  Creation
 04/15/93      :  WBC  :  Check the vla count of ME.EMSdpr->ids and
                          if it's 0, set ME.EMSsfrembnd->num_edges,
                          ME.EMSsfrembnd->num_composites and
                          ME.EMSsfregmod->num_surfaces to 0 since they are
                          used as array boundaries to index into ME.EMSdpr->ids
                          in the method EMgetSSI.  Also check the vla count of
                          ME.EMSsfregmod->in_out and if it's 0, set
                          ME.EMSsfrembnd->num_composites and
                          ME.EMSsfregmod->num_surfaces to 0 since they are
                          used as array boundaries to index into
                          ME.EMSsfregmod->in_out both in this method and in
                          the method EMgetSSI.
*/

{
  IGRint                  i, j;
  struct EMSdbssi_size    *my_size;
  *EMmsg = EMS_S_Success;

  my_size = &size->db_info;

  if (om$dimension_of(varray = ME.EMSdpr->ids) == 0)
    ME.EMSsfrembnd->num_edges = ME.EMSsfrembnd->num_composites =
    ME.EMSsfregmod->num_surfaces = 0;
  else if (om$dimension_of(varray = ME.EMSsfregmod->in_out) == 0)
    ME.EMSsfrembnd->num_composites = ME.EMSsfregmod->num_surfaces = 0;

  /*Have num composites modified in instance data.*/
  my_size->num_composites = ME.EMSsfrembnd->num_composites;

  /*Get num surfs out per composite from vla.*/
  my_size->num_surfaces_out = 0;
  my_size->num_regions_out = 0;
  for(i = 0; i < my_size->num_composites; i ++)
    my_size->num_surfaces_out += ME.EMSsfregmod->in_out[i];

   /*Have num surfaces modified in instance data.*/
   my_size->num_surfaces = ME.EMSsfregmod->num_surfaces;

   /*Get number of regions removed per surface.*/

   for(j = 0; j < my_size->num_surfaces; j ++, i ++)
     my_size->num_regions_out += ME.EMSsfregmod->in_out[i];

   /*Have num disconnected edges modified in instance data.*/
   my_size->num_edges_disconnected = ME.EMSsfrembnd->num_edges;

   return (OM_S_SUCCESS);
}

end implementation EMSsfrembnd;
