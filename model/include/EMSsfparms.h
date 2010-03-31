#ifndef EMSsfparms_include
#define EMSsfparms_include 1

#ifndef igrtypedef_include
#include "igrtypedef.h"    
#endif

#ifndef emssfdef_include
#include "emssfdef.h"
#endif

struct EMcone_params 
 {
   IGRpoint base_center; /* center of the base */
   IGRvector height;     /* height vector */
   IGRdouble base_radius; /* radius of the base */
   IGRdouble top_radius; /* radius at the top */
   IGRdouble slant_height; /* slant height */
   IGRdouble area;      /* area of the cylinder */
   IGRdouble volume;   /* volume of the cylinder */
 };

struct EMpartial_cone_params 
 {
   IGRpoint base_center;  /* center of the base */
   IGRvector height;       /* height vector */
   IGRpoint pstart;	   /* start point of base arc */
   IGRpoint pend;          /* end point of base arc */
   IGRdouble sweep_angle;  /* sweep angle */
   IGRdouble area;	   /* area of the partial cone */
   IGRdouble base_radius;  /* radius of the base */
   IGRdouble top_radius;   /* radius at the top */
   IGRdouble slant_height; /* slant height */
 };

struct EMcylinder_params
 {
  IGRpoint base_center; /* center of the base */
  IGRvector height;     /* height vector */
  IGRdouble radius;    /* radius of the base */
  IGRdouble area;      /* area of the cylinder */
  IGRdouble volume;    /* volume of the cylinder */
 };

struct EMpartial_cylinder_params
 {
  IGRpoint base_center;  /* center of the base */
  IGRvector height;      /* height vector */
  IGRpoint pstart;	 /* start point of base arc */
  IGRpoint pend;	 /* end point of base arc */
  IGRdouble sweep_angle; /* sweep_angle */
  IGRdouble area;	 /* area of the partial cylinder */
  IGRdouble radius;      /* radius of the base */
 };

struct EMelliptical_cylinder_params
 {
  IGRpoint base_center; /* base center of the cylinder */
  IGRvector height;     /* height vector of the elliptical cylinder */
  IGRvector semi_major_axis; /* semi major axis vector */
  IGRvector semi_minor_axis; /* semi minor axis vector */
  IGRdouble area; /* Area of the elliptical clylinder */
  IGRdouble volume;
 };

struct EMelliptical_cone_params
 {
  IGRpoint base_center; /* base center of the cylinder */
  IGRvector height;     /* height vector of the elliptical cylinder */
  IGRvector semi_major_axis; /* semi major axis vector */
  IGRvector semi_minor_axis; /* semi minor axis vector */
  IGRdouble scale; /* scaling factor. ratio of the semi major axis of the 
                       top ellipse and the base ellipse (always greater than
                       1 */
  IGRdouble area;  /* area of the elliptical cone */
  IGRdouble volume; /* volume */
 };

struct EMtorus_params
 {
  IGRpoint center;   /* center of the torus */
  IGRvector normal;  /* normal vector to the plane in which the locus of
                        the midpoints of the circular crossection lie */
  IGRdouble major_radius; /* distance from the center to the midpoint of the
                       circular crossection */
  IGRdouble minor_radius; /* radius of the circular crossection */
  IGRdouble area; /* surface area of the torus */
  IGRdouble volume; /* volume of the torus */
 };

struct EMellipsoid_params
 {
  IGRpoint center; /* center of the ellipsoid */
  IGRvector semi_major_axis; /* semi major axis vector of the
                                generating ellipse */
  IGRdouble radius; /* radius of revolution */
  IGRpoint focus0;
  IGRpoint focus1; /* focii of the generating ellipse */ 
  IGRdouble major_axis_length; /* major axis length of the
                                   generating ellipse */
  IGRdouble area; /* surface area of the ellipsoid */
  IGRdouble volume; /* volume of the ellipsoid */
 };


struct EMsphere_params
 {
  IGRpoint center; /* center of the sphere */
  IGRdouble radius; /* radius of the sphere */
  IGRdouble area; /* surface area */
  IGRdouble volume;  /* volume */
 };

struct EMproject_params
 {
  IGRpoint axis_point0;
  IGRpoint axis_point1;
  struct IGRbsp_curve curve;
 };

struct EMrevolve_params
 {
  IGRvector axis;
  IGRdouble start_angle;
  IGRdouble sweep_angle;
  struct IGRbsp_curve curve;
 };

struct EMsurface_params
 {
   union EMparams
    {
      struct EMcone_params cone;
      struct EMpartial_cone_params pcone;
      struct EMcylinder_params cyl;
      struct EMpartial_cylinder_params pcyl;
      struct EMelliptical_cylinder_params elpcyl;
      struct EMelliptical_cone_params elpcone;
      struct EMellipsoid_params elpsd;
      struct EMsphere_params sphere;
      struct EMtorus_params torus;
      struct EMproject_params project;
      struct EMrevolve_params revolve;
    } params;
    GRrange range;
 };

#endif

