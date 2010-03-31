# ifndef emssfdef_include
# define emssfdef_include 1

/* Note this file and EMSsfdef.h are mirrors (cause they were
 * merged. The ifndef "XXXX" should be the same in EMSsfdef.h
 * else people including these two files could end up with double
 * definitions :SAM Oct 11, 1995
 *
 * The mirrors were made because the NT file system is case 
 * insensitive
 * 
 */
 
 /* The following is brought over from emssfdef.h */

# define EMfreeform_surface 0
# define EMcylinder 1
# define EMcone 2
# define EMelliptical_cylinder 3
# define EMelliptical_cone 4
# define EMsphere 5
# define EMellipsoid 6
# define EMtorus 7
# define EMpcylinder 8
# define EMpcone 9
# define EMproject 10
# define EMrevol   11

/*
 * The following is a list of geomtric modification types.
 */
# define EMSuniformTransformation       0
# define EMSnonuniformTransformation    1
# define EMSdistortion                  2
# define EMSscale_of_1                  3

/* The following brought over from EMSsfdef.h :SAM Oct 11, 1995 */

/*
 * Planarity options
 */
# define EMS_O_NOTPLANAR    0
# define EMS_O_ISPLANAR     1
# define EMS_O_CHECKPLANAR  2

# endif /* emssfdef_include */

