class implementation EMSsfcapsf;

#include "EMS.h"

/*

DESCRIPTION

  This method will allocate the ssi_table structure and return its pointer.

Return values 
  EMmsg - EMS_S_Success if all is well
  ssi - pointer to ssi_table structure of size specified in 'size'.


HISTORY

  11/14/92  :  AMD  :  Creation

*/


method EMgetSSIbuffer( IGRlong *EMmsg; 
                       union EMSssiSizeData *size;
                       union EMSssi_table **ssi)

{
  IGRlong                 sts;
  IGRint                  num_in_out;
  IGRint                  num_bytes;
  struct EMScapssi_size    *my_size;

  /* Initialize */

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  my_size = &size->cap_info;
  *ssi = NULL;

  /* Calculate the size of the buffer */

  num_bytes = sizeof(union EMSssi_table);   /* Space for pointers etc.    */

  num_bytes += my_size->num_edges * sizeof(GRobjid);     

  /* Allocate the buffer */

  *ssi = (union EMSssi_table *) om$malloc(size = num_bytes);
  if(! *ssi) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

  /* Partition the buffer */
  {
    IGRint                      *int_ptr;
    GRobjid                     *objid_ptr;
    struct EMScapssi_table       *my_info;
    union EMSssi_table          *ssi_ptr;


    /* Set int_ptr just below the header */

    ssi_ptr = *ssi;
    my_info = &ssi_ptr->cap_info;
    int_ptr = (IGRint *) (ssi_ptr + 1);

/*
    Assign the integer pointers 
    my_info->num_edges = int_ptr;
*/
    
    /* Assign the objid pointers */
    objid_ptr = (GRobjid *) int_ptr;
    my_info->edges_connected = objid_ptr;

  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSsfcapsf EMgetSSIbuffer")
  return(sts);
}

end implementation EMSsfcapsf;
