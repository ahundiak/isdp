#ifndef REshsolid_h
#define REshsolid_h 1

/*
  This include file contains the recomputation information and type 
  definition for the class EMSshsolid. Please make sure when adding types
  to see that the same have not been defined at a parent level. 

History:
  S'kar: 1/6/93 : Recompute Information Structure for thin-wall solids.
*/

struct mult_tk_surfs_views {
   IGRint      num_sfs_per_mult_tks;
   OMuword     best_view_index;
   IGRdouble   uv_point[2];
  };

struct EMSshell_solid {
   IGRushort   props;                /* Properties: For future modifications */
   IGRboolean  is_symmetric, inward; /* indicating flags for offset */
   OMuint      num_mult_tks;         /* number of multiple/special
                                        thicknesses */
   struct mult_tk_surfs_views sfs_views[1]; /* list of size of surface sets 
                                          and  best views for dimensioning 
                                          of multiple thicknesses. Best views
                                          used for fast screen redraw */
  };

#endif
