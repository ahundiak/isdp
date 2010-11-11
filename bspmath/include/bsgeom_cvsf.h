/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsgeom_cvsf_include
# define bsgeom_cvsf_include

# ifndef igrtypedef_include
#   include "igrtypedef.h" /* IGR types */
# endif

# ifndef igr_include
#   include "igr.h" /* IGR types */
# endif

#define BSINF_PLANE  -1
#define BSRECT_PLANE  0
#define BSSPHERE      1
#define BSFULL_CYL    2
#define BSFULL_CONE   3
#define BSPART_CYL    4
#define BSPART_CONE   5
#define BSTORUS       6
#define BSPART_TORUS  7
#define BSPART_SPHERE 8
#define BSSF_OF_PROJ  97
#define BSSF_OF_REV   98
#define BSGEN_BSP_SF  99

struct BSgeom_bsp_surf
{
   IGRboolean   geom_prop; /* flag indicating if geometric properties of
                              surface follow.  If not, they are calculated
                              in routine.
                                 TRUE = geometric properties and B-spline
                                        representation follow
                                 FALSE = B-spline representation follows    */

   IGRshort     type;      /* indicate type of surface:
                     -1 (BSINF_PLANE)......infinite plane
                      0 (BSRECT_PLANE).....rectangular plane
                      1 (BSSPHERE).........sphere
                      2 (BSFULL_CYL).......rt angle, circular cylinder
                      3 (BSFULL_CONE)......rt angle, circular cone
                      4 (BSPART_CYL).......partial rt angle, circular cylinder
                      5 (BSPART_CONE)......partial rt angle, circular cone
                      6 (BSTORUS)..........torus
                      7 (BSPART_TORUS).....partial torus
                      8 (BSPART_SPHERE)....partial sphere
                     97 (BSSF_OF_PROJ).....surface of projection
                     98 (BSSF_OF_REV)......surface of revolution
                     99 (BSGEN_BSP_SF).....general B-spline surface         */

   IGRboolean   bounded;   /* flag indicating if surface is bounded.
                                 TRUE = bounded
                                 FALSE = infinite                           

                              for partial sphere, partial cone and partial 
                              cylinder, if bounded = FALSE, it is assumed to
                              be infinite in both u and v direction.
                                                                            */
   IGRdouble    urange[2]; /* u parametric range (if bounded = TRUE)        */
   IGRdouble    vrange[2]; /* v parametric range (if bounded = TRUE)        */

   IGRboolean   reg_constr;/* Read ONLY if geom_prop = TRUE !!!
                              flag indicating if B-spline representation of
                              surface is regularly constructed :
                                1 = B-spline is regularly constructed surface
                                0 = B-spline is irregularly constructed surface

                              NOTE : For cylinder/partial cylinder, 
                                     cone/partial cone and surface of revolu-
                                     tion, if quad_sf->reg_constr = FALSE, 
                                     the B-spline representation of surface
                                     defines a surface constructed irregularly 
                                     but geometric properties define a 
                                     regularly constructed system.

                                     For torus/partial torus, the geometric
                                     properties correlates to the B-spline
                                     representation and reg_constr bit is
                                     set accordingly.

                              For rectangular plane, reg_constr is always
                              set = TRUE.

                              For sphere/partial sphere reg_constr is always
                              set = TRUE.

                              For cylinder/partial cylinder, if cylinder is 
                              a right-handed system w.r.t. vector from center
                              of base circle to center of top circle of, 
                              cylinder set reg_constr = TRUE.

                              For cone/partial cone, if cone is a right-handed
                              system w.r.t. vector from center of base circle
                              to center of top circle of cone, set reg_constr
                              = TRUE.

                              For surface of projection, reg_constr is always
                              set = TRUE.

                              For surface of revolution, if surface is a
                              right-handed system w.r.t. vector from center 
                              of base to center of top, set reg_constr = TRUE.

                              For torus and partial torus, if direction of
                              revolution is the opposite direction of the
                              normal vector (defining a right-handed circle)
                              of the base circle, reg_constr = TRUE.        */

   IGRshort    gencv_ind;  /* flag indicating whether generating curve
                              of surface is along u or v parameter.
                                 0 = u is generating curve  
                                 1 = v is generating curve               
                              Note: This flag is meaningful only for torus, 
                              partial torus, surface of revolution, and
                              surface of projection.

                              The sphere/partial sphere is assumed to have
                              u direction generating curve and v direction
                              of revolution.                                */

/*    GEOMETRIC PROPERTIES :
      ====================

         If the geometric properties are entered by user, they MUST be 
         such that the properties define a regularly constructed system 
         (even if the B-spline representation is not a regularly constructed
         system.)  (See NOTE  above.)  */

   IGRpoint     pt1;
   IGRpoint     pt2; 
   IGRpoint     pt3;
   IGRpoint     pt4;
   IGRpoint     pt5;
   IGRpoint     pt6;
   IGRpoint     pt7;

   IGRvector    vec1; 
   IGRvector    vec2;
   IGRvector    vec3;
   IGRvector    vec4;
   IGRvector    vec5;

   IGRdouble    len1; 
   IGRdouble    len2;
   IGRdouble    len3;
   IGRdouble    len4;
   IGRdouble    len5;
   IGRdouble    len6;

   IGRshort     flag1;

   struct
     IGRbsp_surface *bspsf; /* B-spline representation of surface           */

   struct
     IGRbsp_curve   *sfgen_cv; /* B-spline generator curve 
                                   (for surface of revolution and
                                    surface of projection ONLY!!)           */


/*
   DESCRIPTION OF PROPERTIES TO FILL FOR EACH TYPE OF SURFACE
   ==========================================================


   INFINITE PLANE (-1) :
      pt1..........point on plane
      vec1.........normal vector of plane


   RECTANGULAR PLANE (0) :
      pt1..........bottom left point of plane
      pt2..........bottom right point of plane
      pt3..........top left point of plane
      pt4..........top right point of plane
      vec1.........normal unit vector of plane
      vec2.........unit vector from pt1 to pt2
      vec3.........unit vector from pt1 to pt3
      len1.........distance from pt1 to pt2
      len2.........distance from pt1 to pt3
 

   SPHERE (1) :
      pt1..........center
      pt2..........point at top pole such that vector from center to pt2
                   defines a right-oriented sphere with respect to 
                   direction of revolution in B-spline representation
      pt3..........middle point (u par = 0.5, v par = 0.0)
      pt4..........point at bottom pole (opposite top pole)
      vec1.........unit vector from center to top pole of sphere
      vec2.........unit vector from center to middle point
      vec3.........unit vector from center to bottom pole of sphere
      len1.........radius


   FULL CYLINDER - rt angle, circular (2) :
      pt1..........base center
      pt2..........top center
      pt3..........base start point
      vec1.........unit vector from base center to top center
                   (height unit vector)
      vec2.........unit vector from base center to base start point
      len1.........radius
      len2.........height


   FULL CONE - rt angle, circular (3) :
      pt1..........base center
      pt2..........top center
      pt3..........base start point
      pt4..........top start point
      pt5..........tip point
      vec1.........unit vector from base center to top center
                   (height unit vector)
      vec2.........unit vector from base or top center to base or top 
                   start point
      len1.........radius of base 
      len2.........radius of top 
      len3.........height
      len4.........half angle
      len5.........slant height
      flag1........flag indicating if top or base of cone is degenerte
                   (the tip of the cone)
                      0 : neither top nor base is degenerate
                      1 : top is degenerate
                      2 : base is degenerte

   PARTIAL CYLINDER - rt angle, circular (4) :
      pt1..........base center
      pt2..........top center
      pt3..........base start point
      pt4..........base end point
      vec1.........unit vector from base center to top center
                   (height unit vector)
      vec2.........unit vector from base center to base start point
      vec3.........unit vector from base center to base end point
      len1.........radius
      len2.........height
      len3.........sweep angle


   PARTIAL CONE - rt angle, circular (5) :
      pt1..........base center
      pt2..........top center
      pt3..........base start point
      pt4..........top start point
      pt5..........tip point 
      pt6..........base end point
      pt7..........top end point
      vec1.........unit vector from base center to top center
                   (height unit vector)
      vec2.........unit vector from base or top center to base or top
                   start point
      vec3.........unit vector from base or top center to base or top
                   end point
      len1.........radius of base
      len2.........radius of top
      len3.........height
      len4.........half angle
      len5.........slant height
      len6.........sweep angle
      flag1........flag indicating if top or base of cone is degenerate
                   (the tip of the cone)
                      0 : neither top nor base is degenerate
                      1 : top is degenerate
                      2 : base is degenerte

   FULL TORUS (6) :
      pt1..........point on axis line (projection of base circle center)
      pt2..........base circle center
      pt3..........base circle start point
      vec1.........axis vector
      vec2.........vector from projection of base circle center onto axis 
                   line to base circle center
      vec3.........vector normal to base circle (defining rt-handed circle)
      vec4.........base circle start vector
      len1.........base circle radius
      len2.........revolution radius at base circle center

   PARTIAL TORUS (7) :
      pt1..........point on axis line
      pt2..........base center
      pt3..........base start point
      pt4..........base end point
      vec1.........axis vector
      vec2.........vector from projection of base circle center onto axis 
                   line to base circle center
      vec3.........vector normal to base circle (defining rt-handed circle)
      vec4.........base start unit vector
      vec5.........base end unit vector
      len1.........base radius
      len2.........revolution radius at base circle center
      len3.........base sweep angle
      len4.........torus sweep angle

   PARTIAL SPHERE (8) :
      pt1..........center
      pt2..........point at top pole such that vector from center to pt2
                   defines a right-oriented sphere with respect to 
                   direction of revolution
      pt3..........generating arc start point
      pt4..........generating arc end point
      pt5..........mid point of generating arc
      pt6..........mid point of ending arc
      vec1.........unit vector from center to top pole of sphere
      vec2.........vector normal to generating arc 
      vec3.........vector from center to start point of generating arc
      vec4.........vector from center to end point of generating arc
      vec5.........vector from center in direction of generating arc that
                   is perpendicular to axis line.
      len1.........radius
      len2.........generating arc sweep angle
      len3.........revolution sweep angle

   SURFACE OF PROJECTION (97) :
      sfgen_cv.....generator curve
      pt1..........point on surface
      vec1.........projection vector
      len1.........length of projection


   SURFACE OF REVOLUTION (98) :
      sfgen_cv.....generator curve
      pt1..........point on axis 
      vec1.........axis unit vector
      len1.........sweep angle
*/

};


/****************************************************************************/
#define BSPOINT         0
#define BSLINE          1
#define BSCIRCLE        2
#define BSELLIPSE       3
#define BSPARAB_ARC     4
#define BSHYPER_ARC     5
#define BSCIRC_ARC      6
#define BSELLIP_ARC     7
#define BSGEN_BSP_CV    8
#define BSINF_LINE      9
#define BS3DLINESTR     10
#define BS2DLINESTR     11

struct BSgeom_bsp_curve
{
   IGRboolean      geom_prop; /* flag indicatng if geometric properties of
                                 curve follows                            */
   IGRboolean      bscv_flag; /* flag indicating if b-spline curve struc-
                                 ture is filled                           */
   IGRshort        type;      /* indicate type of intersection curve 
                                  0 (BSPOINT)...........point
                                  1 (BSLINE)............line
                                  2 (BSCIRCLE)..........circle
                                  3 (BSELLIPSE).........ellipse
                                  4 (BSPARAB_ARC).......parabolic arc
                                  5 (BSHYPER_ARC).......hyperbolic arc
                                  6 (BSCIRC_ARC)........circular arc
                                  7 (BSELLIP_ARC).......elliptical arc
                                  8 (BSGEN_BSP_CV)......general b-spline curve
                                  9 (BSINF_LINE)........infinite line
                                 10 (BS3DLINESTR).......3-D linestring 
                                 11 (BS2DLINESTR).......2-D linestring */
/* GEOMETRIC PROPERTIES  */
   IGRpoint        pt1;
   IGRpoint        pt2;
   IGRpoint        pt3;
   IGRpoint        pt4;
   IGRpoint        pt5;

   IGRvector       vec1;
   IGRvector       vec2;
   IGRvector       vec3;
   IGRvector       vec4;
   IGRvector       vec5;

   IGRdouble       len1;
   IGRdouble       len2;
   IGRdouble       len3;
   IGRdouble       len4;

   IGRint          int1;

   IGRdouble       *array1;

   struct
    IGRbsp_curve *bspcv; /* B-spline representation curve                  */



/*
   DESCRIPTION OF PROPERTIES TO FILL FOR EACH TYPE OF CURVE
   ========================================================


   POINT (0) :
      pt1..........point

   
   LINE (1) :
      pt1.........point 1
      pt2.........point 2
      vec1........unit vector from pt1 to pt2
      len1........length of line


   CIRCLE (2) :
      pt1.........center
      pt2.........point on circle
      vec1........normal unit vector
      vec2........unit vector from center to point on circle
      len1........radius


   ELLIPSE (3) :
      pt1.........center
      pt2.........point on semi-axis1
      pt3.........point on semi-axis2
      pt4.........start point 
      vec1........normal unit vector
      vec2........unit vector from center to point on semi-axis1
      vec3........unit vector from center to point on semi-axis2
      vec4........unit vector from center to start point
      len1........length of semi-axis1
      len2........length of semi-axis2
      len3........start angle

   PARABOLIC ARC (4) :
      pt1.........point 1
      pt2.........vertex
      pt3.........point2
      vec1........normal unit vector
      vec2........tangent unit vector at point 1
      vec3........tangent unit vector at point 2


   HYPERBOLIC ARC (5) :
      pt1.........point 1 (of one branch)
      pt2.........vertex (of one branch)
      pt3.........point 2 (of one branch)
      pt4.........center point (point of intersection of asymtotes)
      vec1........normal unit vector
      vec2........tangent unit vector at point 1
      vec3........tangent unit vector at point 2
      vec4........unit vector from center along 1st asymtote of one branch
      vec5........unit vector from center along 2nd asymtote of one branch


   CIRCULAR ARC (6) :
      pt1.........center
      pt2.........start point
      pt3.........end point
      vec1........normal unit vector
      vec2........unit vector from center to start point
      vec3........unit vector from center to end point
      len1........radius
      len2........sweep angle


   ELLIPTICAL ARC (7) :
      pt1.........center   
      pt2.........point on semi-axis1
      pt3.........point on semi-axis2
      pt4.........start point
      pt5.........end point
      vec1........normal unit vector
      vec2........unit vector from center to semi-axis1
      vec3........unit vector from center to semi-axis2
      vec4........unit vector from center to start point
      vec5........unit vector from center to end point
      len1........length of semi-axis1
      len2........length of semi-axis2       
      len3........start angle
      len4........sweep angle


   GENERAL B-SPLINE CURVE (8) :
      none

   INFINITE LINE (9) :
      pt1..........point on infinite line
      vec1.........vector indicating direction of inf. line

   3-D LINESTRING (10) :
      int1.........number of points in linestring
      array1.......array of points in linestring

   2-D LINESTRING (11) :
      int1.........number of points in linestring
      array1.......array of points in linestring
         
*/


};

# endif /* bsgeom_cvsf_include */
