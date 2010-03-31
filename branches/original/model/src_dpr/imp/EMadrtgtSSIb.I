class implementation EMSsfaddraft;

#include "EMS.h"

/*

DESCRIPTION

  This method will allocate the ssi_table structure and return its pointer.

Return values 
  EMmsg - EMS_S_Success if all is well
  ssi - pointer to ssi_table structure of size specified in 'size'.


HISTORY

  02/14/93  :  Nirmal  :  Creation

*/


method EMgetSSIbuffer( IGRlong *EMmsg; 
                       union EMSssiSizeData *size;
                       union EMSssi_table **ssi)

{
  IGRlong                 sts;
  IGRint                  num_in_out;
  IGRint                  num_bytes;
  struct EMSaddraftssi_size    *my_size;

  /* Initialize */

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  my_size = &size->addrft_info;
  *ssi = NULL;

  /* Calculate the size of the buffer */

  num_bytes = sizeof(union EMSssi_table);   /* Space for pointers etc.    */

  num_bytes += (my_size->num_composites +   /* Space for num sfs out/comp */
                my_size->num_surfaces_out)  /* Space for comp index/surf  */
                * sizeof(IGRint);

  num_bytes += (my_size->num_composites +   /*Space for composite ids mod */
                my_size->num_surfaces_out + /*Space for surf ids out      */
                (2 * my_size->num_new_commedge_pairs) +
                (2 * my_size->num_old_commedge_pairs) )
                * sizeof(GRobjid);     

  /* Allocate the buffer */

  *ssi = (union EMSssi_table *) om$malloc(size = num_bytes);
  if(! *ssi) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

  /* Partition the buffer */

  {
    IGRint                      *int_ptr;
    GRobjid                     *objid_ptr;
    struct EMSaddraftssi_table       *my_info;
    union EMSssi_table          *ssi_ptr;


    /* Set int_ptr just below the header */

    ssi_ptr = *ssi;
    my_info = &ssi_ptr->addrft_info;
    int_ptr = (IGRint *) (ssi_ptr + 1);

    /* Assign the integer pointers */

    my_info->num_surfaces_out = int_ptr;
    int_ptr += my_size->num_composites;

    my_info->composite_indices = int_ptr;
    int_ptr += my_size->num_surfaces_out;

    /* Assign the objid pointers */

    objid_ptr = (GRobjid *) int_ptr;
    my_info->composite_ids = objid_ptr;

    objid_ptr += my_size->num_composites;
    my_info->surface_out_ids = objid_ptr;

    objid_ptr += my_size->num_surfaces_out;
    my_info->old_commedge_pairs1 = objid_ptr;

    objid_ptr += my_size->num_old_commedge_pairs;
    my_info->old_commedge_pairs2 = objid_ptr;

    objid_ptr += my_size->num_old_commedge_pairs;
    my_info->new_commedge_pairs1 = objid_ptr;

    objid_ptr += my_size->num_new_commedge_pairs;
    my_info->new_commedge_pairs2 = objid_ptr;
    
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSsfaddraft EMgetSSIbuffer")
  return(sts);
}

end implementation EMSsfaddraft;
