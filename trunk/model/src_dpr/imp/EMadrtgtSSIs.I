class implementation EMSsfaddraft;


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

  02/10/1992  :  Nirmal  :  Creation


*/


method EMgetSSIsize(IGRlong *EMmsg; union EMSssiSizeData *size)

{
  IGRint                  i, j;
  struct EMSaddraftssi_size    *my_size;
  *EMmsg = EMS_S_Success;

  my_size = &size->addrft_info;

  /* Have num composites modified in instance data */

  my_size->num_composites = ME.EMSsfaddraft->num_composites;

  /* Get num surfs out per composite from vla */

  my_size->num_surfaces_out = 0;

  for(i = 0; i < my_size->num_composites; i ++)
    my_size->num_surfaces_out += ME.EMSsfregmod->in_out[i];

  /* Have num disconnected edges modified in instance data */
  my_size->num_old_commedge_pairs = ME.EMSsfaddraft->num_old_commedge_pairs ;
  my_size->num_new_commedge_pairs = ME.EMSsfaddraft->num_new_commedge_pairs ;

 return (OM_S_SUCCESS);

}

end implementation EMSsfaddraft;
