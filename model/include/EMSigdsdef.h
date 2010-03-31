# ifndef EMSigdsdef_include
# define EMSigdsdef_include 1

/*
DESCRIPTION

This file is used in code which translates to and from IGDS.

HISTORY

27 Jul 1988 jBk Genesis.
*/

/* kinds of type 18 and type 19 elements */

# define IGDS_GU_SURFACE_SURFACE_OF_PROJECTION      0
# define IGDS_GU_SURFACE_BOUNDED_PLANE              1
# define IGDS_GU_SURFACE_UNBOUNDED_PLANE            2
# define IGDS_GU_SURFACE_RIGHT_CIRCULAR_CYLINDER    3
# define IGDS_GU_SURFACE_RIGHT_CIRCULAR_CONE        4
# define IGDS_GU_SURFACE_TABULATED_CYLINDER         5
# define IGDS_GU_SURFACE_TABULATED_CONE             6
# define IGDS_GU_SURFACE_CONVOLUTE                  7
# define IGDS_GU_SURFACE_SURFACE_OF_REVOLUTION      8
# define IGDS_GU_SURFACE_WARPED_SURFACE             9

# define IGDS_GU_SOLID_SOLID_OF_PROJECTION          0
# define IGDS_GU_SOLID_SOLID_OF_REVOLUTION          1
# define IGDS_GU_SOLID_SOLID_BY_BOUNDARY_ELEMENTS   2

/* kinds of type 23 elements */

# define IGDS_GU_CIRC_TRUNC_CONE_general                0
# define IGDS_GU_CIRC_TRUNC_CONE_right_cylinder         1
# define IGDS_GU_CIRC_TRUNC_CONE_cylinder               2
# define IGDS_GU_CIRC_TRUNC_CONE_right_cone             3
# define IGDS_GU_CIRC_TRUNC_CONE_cone                   4
# define IGDS_GU_CIRC_TRUNC_CONE_right_truncated_cone   5
# define IGDS_GU_CIRC_TRUNC_CONE_truncated_cone         6

# endif /* EMSigdsdef_include */
