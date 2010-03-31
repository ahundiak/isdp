/*
 * This macro calculates the size of the RMT buffer. (Size is an IGRint)
 * This is a private macro and must only be used inside a regionmod method.
 */
#omdef ems$getRMTsize(size,
		      num_composites = 0,
		      num_surfaces,
		      num_in_out)
{
  IGRint	header_size,
		num_counters,
		count_size,
		num_objects,
		object_size,
		pad_size;

  /*
   * Allow 10 bytes for padding.
   */
  pad_size = 10;

  /*
   * Get the size of the empty structure.
   */
  header_size = sizeof(struct EMSregmod_table);

  /*
   * Get the number of counter elements in counter arrays:
   * num_surfs_out -- num_composites
   * num_regions_in -- num_surfaces
   * num_regions_out -- num_surfaces
   */
  num_counters = num_composites + 2 * num_surfaces;
  count_size = num_counters * sizeof(IGRint);

  /*
   * Get the size of the object id arrays
   */
  num_objects = num_composites + num_surfaces + num_in_out;
  object_size = num_objects * sizeof(GRobjid);

  size = header_size + count_size + object_size + pad_size;
}
#endomdef


/*
 * This macro allocates a RMT buffer. It is a private macro and must
 * only be used inside a regionmod method. (rmt is a pointer to
 * EMSregmod_table)
 */
#omdef ems$getRMTbuffer(rmt,
			num_composites = 0,
			num_surfs_out = 0,
			num_surfaces,
			num_reg_in,
			num_reg_out)
{
  IGRint			num_in_out;
  IGRint			size;
  IGRint			*int_ptr;
  GRobjid			*objid_ptr;
  struct EMSregmod_table	*rmt_ptr;

  num_in_out = num_surfs_out + num_reg_in + num_reg_out;
  ems$getRMTsize(size = size,
		 num_composites = num_composites,
		 num_surfaces = num_surfaces,
		 num_in_out = num_in_out);

  rmt = (struct EMSregmod_table *) om$malloc (size = size);
  if(rmt)
  {
    /*
     * Set int_ptr just below the header.
     */
    rmt_ptr = rmt;
    rmt_ptr ++;
    int_ptr = (IGRint *) rmt_ptr;

    /*
     * Assign the integer pointers.
     */
    rmt->num_surfaces_out = int_ptr;
    int_ptr += num_composites;
    rmt->num_regions_in = int_ptr;
    int_ptr += num_surfaces;
    rmt->num_regions_out = int_ptr;
    int_ptr += num_surfaces;

    /*
     * Assign the objid pointers.
     */
    objid_ptr = (GRobjid *) int_ptr;
    rmt->composite_ids = objid_ptr;
    objid_ptr += num_composites;
    rmt->surface_ids = objid_ptr;
    objid_ptr += num_surfaces;
    rmt->surface_out_ids = objid_ptr;
    objid_ptr += num_surfs_out;
    rmt->region_in_ids = objid_ptr;
    objid_ptr += num_reg_in;
    rmt->region_out_ids = objid_ptr;
  }
}
#endomdef
