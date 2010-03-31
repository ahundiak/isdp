class implementation EMSsfunitesf;


# include "EMS.h"
# include "OMmacros.h"


/*

DESCRIPTION

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

HISTORY

  07/10/1992  :  AMD  :  Creation
  04/15/93    :  WBC  :  Check the vla count of ME.EMSdpr->ids and
                         if it's 0, set both ME.EMSsfunitesf->num_composites
                         and ME.EMSsfunitesf->num_edges to 0 since they are
                         used as array boundaries to index into ME.EMSdpr->ids
                         in the method EMgetSSIsize.  Also, if the vla count
                         of ME.EMSsfregmod->in_out is 0, set
                         ME.EMSsfunitesf->num_composites to 0 since it is
                         used as an array boundary to index into
                         ME.EMSsfregmod->in_out in this method as well as in
                         the method EMgetSSIsize.
*/

method EMgetSSIsize(IGRlong *EMmsg; union EMSssiSizeData *size)

{
  IGRint                  i;
  struct EMSunssi_size    *my_size;
  *EMmsg = EMS_S_Success;

  my_size = &size->un_info;

  if (om$dimension_of(varray = ME.EMSdpr->ids) == 0)
    ME.EMSsfunitesf->num_edges = ME.EMSsfunitesf->num_composites = 0;
  else if (om$dimension_of(varray = ME.EMSsfregmod->in_out) == 0)
    ME.EMSsfunitesf->num_composites = 0;

  /* Have num composites modified in instance data */

  my_size->num_composites = ME.EMSsfunitesf->num_composites;

  /* Get num surfs out per composite from vla */

  my_size->num_surfaces_out = 0;

  for(i = 0; i < my_size->num_composites; i ++)
    my_size->num_surfaces_out += ME.EMSsfregmod->in_out[i];

  /* Have num disconnected edges modified in instance data */
  my_size->num_edges  = 3 * ME.EMSsfunitesf->num_edges;

 return (OM_S_SUCCESS);

}

end implementation EMSsfunitesf;
