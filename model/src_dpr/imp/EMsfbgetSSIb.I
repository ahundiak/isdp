/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

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
  DLB 11/02/87  Changed name of structure to EMSssi_table for vers. 1.1.0
  AIC xx/xx/87  Creation.
*/
{
  IGRlong                 sts;
  IGRint                  num_in_out;
  IGRint                  num_bytes;
  struct EMSboolssi_size  *my_size;


  /*Initialize*/
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  my_size = &size->bool_info;
  *ssi = NULL;

  /*Calculate the size of the buffer.*/
  num_bytes = sizeof(union EMSssi_table);   /*Space for pointers etc.     */
  num_bytes += (my_size->num_composites +   /*Space for num sfs out/comp  */
                my_size->num_surfaces_out + /*Space for comp index/surf   */
                2 * my_size->num_surfaces)  /*Space for num lps in-out/sf */
                * sizeof(IGRint);

  num_bytes += (my_size->num_composites +   /*Space for composite ids mod */
                my_size->num_surfaces_out + /*Space for surf ids out      */
                my_size->num_surfaces +     /*Space for surfs id modified */
                my_size->num_regions_in +   /*Space for lp ids in per sf  */
                my_size->num_regions_out)   /*Space for lp ids out per sf */
                * sizeof(GRobjid);     

  /*Allocate the buffer.*/
  *ssi = (union EMSssi_table *) om$malloc(size = num_bytes);
  if(! *ssi) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

  /*Partition the buffer.*/
  {
    IGRint                      *int_ptr;
    GRobjid                     *objid_ptr;
    struct EMSboolssi_table     *my_info;
    union EMSssi_table          *ssi_ptr;


    /*Set int_ptr just below the header.*/
    ssi_ptr = *ssi;
    my_info = &ssi_ptr->bool_info;
    int_ptr = (IGRint *) (ssi_ptr + 1);

    /*Assign the integer pointers.*/
    my_info->num_surfaces_out = int_ptr;
    int_ptr += my_size->num_composites;

    my_info->composite_indices = int_ptr;
    int_ptr += my_size->num_surfaces_out;

    my_info->num_regions_in = int_ptr;
    int_ptr += my_size->num_surfaces;

    my_info->num_regions_out = int_ptr;
    int_ptr += my_size->num_surfaces;

    /*Assign the objid pointers.*/
    objid_ptr = (GRobjid *) int_ptr;
    my_info->composite_ids = objid_ptr;

    objid_ptr += my_size->num_composites;
    my_info->surface_out_ids = objid_ptr;

    objid_ptr += my_size->num_surfaces_out;
    my_info->surface_ids = objid_ptr;

    objid_ptr += my_size->num_surfaces;
    my_info->region_in_ids = objid_ptr;

    objid_ptr += my_size->num_regions_in;
    my_info->region_out_ids = objid_ptr;
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSsfboolean EMgetSSIbuffer")
  return(sts);
}

end implementation EMSsfboolean;
