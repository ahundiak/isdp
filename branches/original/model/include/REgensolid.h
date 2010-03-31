#ifndef REgensolid_h
#define REgensolid_h 1

/*
  This include file contains the recomputation information and type 
  definition for the class EMSgensolid. Please make sure when adding types
  to see that the same have not been defined at a parent level. 

  EMS_ASsolid_by_offsetting_surface       24
  EMS_ASsurface_to_plane_solid_of_proj    25
  EMS_ASthinwall_from_compsurf            43
  EMS_ASsolid_proj_by_trim_st_end_plane   51
  EMS_ASsolid_proj_by_trim_end_plane      52
  EMS_ASsolid_proj_by_sym_dist      	  53
  EMS_ASsolid_by_offsetting_surface1      54
  EMS_ASsurface_to_plane_solid_of_proj1   55
History:
 PP: 11/4/91 : Trying to make some sense of the info spread out in 
               different include files.
*/

#define EMS_ASsolid_by_offsetting_surface       24
#define EMS_ASsolid_by_offsetting_surface1      54
#define EMS_ASthinwall_from_compsurf            43


/* Recompute info for offset surface. */

/* 
  This structure is defined in REgencompsf.h and is included here for
  the sake of completeness.

  #define EMS_NATURAL_NORMAL  1
  #define EMS_TRIMMING        2

  struct EMSoffset_surface
  {
    unsigned long   props;
  };
*/

#define EMS_ASsurface_to_plane_solid_of_proj    25
#define EMS_ASsurface_to_plane_solid_of_proj1   55
#define EMS_ASsolid_proj_by_trim_st_end_plane   51
#define EMS_ASsolid_proj_by_trim_end_plane      52
#define EMS_ASsolid_proj_by_sym_dist   	  	53

#endif
