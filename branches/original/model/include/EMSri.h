# ifndef EMSri_include
# define EMSri_include

/*
Description
    This include file contains the structures that hold the recompute
    information for DPR nodes.  

Notes
    There does not appear a structure for the booleans.  This is obvious
    since the recompute information for booleans exists on the to_components
    channel.  Note that the savestate operation is a boolean class object.

History 
    DLB 06/02/88 Creation.
*/

/*
 * Special saveside recompute information table.
 */

/* NOTE:
 *
 * There is, and always will be, only one piece of recompute information
 * (the plane).  Therefore, there is no need to get the size of the saveside
 * ri structure since it is already known.
 */

struct EMSsavesideri_table
{
  GRobjid       plane_id;            /* Plane id.            */
};

/*
 * Recompute information table.
 */

union EMSri_table
{
  struct EMSsavesideri_table  saveside_info;
};

#endif
