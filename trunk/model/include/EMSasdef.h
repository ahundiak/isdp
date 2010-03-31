#ifndef EMSasdef_h
#define EMSasdef_h 1

/*
 * Surface/solid types that are associative. These types are also used in
 * the EMSparams structure to pick the right member of the union inside
 * the structure.
 */

#define EMS_ASno_type                           0
#define EMS_ASfillet_surface                    8 
#define EMS_ASsurface_of_revolution             10
#define EMS_ASsurface_of_projection             11
#define EMS_ASsphere_by_center_and_radius       12
#define EMS_AScone_by_axis_and_diameters        13
#define EMS_ASfillet_by_surfaces_and_radii      19
#define EMS_AStorus_by_axis_center_and_radius   21
#define EMS_ASsolid_by_capping_surface          23
#define EMS_ASsolid_by_offsetting_surface       24
#define EMS_ASsurface_to_plane_solid_of_proj    25
#define EMS_AS_DUMMY1                           26
#define EMS_ASfitted_surface                    27 
#define EMS_ASsurface_by_offsetting_surface     28
#define EMS_ASdrafted_surface                   29
#define EMS_ASextracted_partial_surface         30
#define EMS_ASright_elliptical_cylinder         31
#define EMS_ASright_elliptical_cone             32
#define EMS_ASellipsoid_by_foci_axis_len        33
#define EMS_ASellipsoid_by_center_axis_radius   34
#define EMS_AS_DUMMY2                           38
#define EMS_ASround                             39
#define EMS_ASchamfer                           40
#define EMS_ASround_uniform                     41
#define EMS_ASchamfer_uniform                   42
#define EMS_ASthinwall_from_compsurf            43
#define EMS_AScylinder                          101
#define EMS_ASgenbs_type                        999


/*
 * Special defined constants which have some history behind them.
 */

#define ASSOC 1

#define ASSOC_FRANCE 1 

                /* 
                 * If the associative system by France is present
                 * then this should be set to 1 else it is set to 0.
                 */

#define ASSOC_SURF 1
                /*
                 * If EMS needs to be compiled without Associative
                 * surfaces and solids. This code is intended to be used
                 * at places where existing code has to be modified/added to
                 * support associative surfaces/solids. For this option
                 * to be turned on ASSOC_FRANCE needs to be set to 1.
                 */

#endif

