#ifndef REswcompsf_h
#define REswcompsf_h 1

/*
  This include file contains the recomputation information and type 
  definition for the class EMSswcompsf. Please make sure when adding types
  to see that the same have not been defined at a parent level. 

  EMS_ASsurface_of_revolution             10
  EMS_ASsurface_of_projection             11
  EMS_ASsurf_of_proj_trim_st_end_plane    12
  EMS_ASsurf_of_proj_trim_end_plane 	  13
  EMS_ASsurf_of_proj_by_sym_dist 	  14
  EMS_ASsurface_of_revolution1            15
  EMS_ASsurface_of_projection1            16

History:
 PP: 11/4/91 : Trying to make some sense of the info spread out in 
               different include files.
 SM: 06/01/92: Added EMS_ASsurface_of_revolution1 to distinguish from the
               EMS_ASsurface_of_revolution. The new type will create planes
               out of any planar surfaces of revolutions.
*/

#define EMS_ASsurface_of_revolution             10
#define EMS_ASsurface_of_projection             11
#define EMS_ASsurf_of_proj_trim_st_end_plane    12
#define EMS_ASsurf_of_proj_trim_end_plane       13
#define EMS_ASsurf_of_proj_by_sym_dist 	  	14
#define EMS_ASsurface_of_revolution1            15
#define EMS_ASsurface_of_projection1            16

#endif
