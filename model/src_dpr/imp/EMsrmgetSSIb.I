/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfregmod;

#include "EMS.h"
method EMgetSSIbuffer(IGRlong *EMmsg; union EMSssiSizeData *size;
                      union EMSssi_table **ssi)
/*
Description
  This method will allocate the ssi_table structure and return its pointer.

Return values 
  EMmsg - EMS_S_Success if all is well
  ssi - pointer to ssi_table structure of size specified in 'size'.

History
  SM  11-Feb-88 Modified to take care of the edges modified.
  DLB 11/02/87  Changed name of structure to EMSssi_table for vers. 1.1.0
  AIC xx/xx/87  Creation.
*/
{
  IGRlong               sts;
  IGRint                num_in_out;
  IGRint                num_bytes;
  struct EMSsfssi_size  *my_size;


  /* Initialize*/
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  my_size = &size->sf_info;
  *ssi = NULL;

  /* Calculate the size of the buffer*/
  num_bytes = sizeof(union EMSssi_table);   /*Space for pointers etc.     */
  num_bytes += (my_size->num_surfaces * 2 +
	       my_size->num_regions + my_size->num_edges_out) *
               sizeof(IGRint);
  num_bytes += (my_size->num_surfaces +     /*Space for surf ids mod      */
                my_size->num_regions_in +   /*Space for loops in per surf */
                my_size->num_regions_out +
		my_size->num_regions +
		my_size->num_edges_in +
		my_size->num_edges_out +
		my_size->num_edges_copied * 2) *
                sizeof(GRobjid);

  /* Allocate the buffer*/
  *ssi = (union EMSssi_table *) om$malloc(size = num_bytes);
  if(! *ssi){*EMmsg = EMS_E_NoDynamicMemory;  goto wrapup;}

  /* Partition the buffer*/
  {
    IGRint                   *int_ptr;
    GRobjid                  *objid_ptr;
    struct EMSsfssi_table    *my_info;
    union EMSssi_table       *ssi_ptr;


    /* Set int_ptr just below the header.*/
    ssi_ptr = *ssi;
    my_info = &ssi_ptr->sf_info;
    int_ptr = (IGRint *) (ssi_ptr + 1);

    /* Assign the integer pointers.*/
    my_info->num_regions_in = int_ptr;
    int_ptr += my_size->num_surfaces;

    my_info->num_regions_out = int_ptr;
    int_ptr += my_size->num_surfaces;

    my_info->num_edges_in = int_ptr;
    int_ptr += my_size->num_edges_out;

    my_info->num_edges_out = int_ptr;
    int_ptr += my_size->num_regions;

    objid_ptr = (GRobjid *) int_ptr;

    /* Assign the objid pointers.*/
    my_info->surface_ids = objid_ptr;
    objid_ptr += my_size->num_surfaces;

    my_info->region_in_ids = objid_ptr;
    objid_ptr += my_size->num_regions_in;

    my_info->region_out_ids = objid_ptr;
    objid_ptr += my_size->num_regions_out;

    my_info->region_ids = objid_ptr;
    objid_ptr += my_size->num_regions;

    my_info->edge_in_ids = objid_ptr;
    objid_ptr += my_size->num_edges_in;

    my_info->edge_out_ids = objid_ptr;
    objid_ptr += my_size->num_edges_out;

    my_info->ed_cp_ed_ids = objid_ptr;
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSsfregmod.EMgetSSIbuffer")
  return(sts);
}
end implementation EMSsfregmod;
