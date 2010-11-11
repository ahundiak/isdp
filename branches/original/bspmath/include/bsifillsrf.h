/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsifillsrf_include
# define bsifillsrf_include

# ifndef igrtypedef_include
#   include "igrtypedef.h" /* IGR types */
# endif

/* HISTORY */
/* 09/04/91 - Modified BSfillet_kts to include all_cnv_rng and all_cnc_rng */
/* 11/08/91 - Modified BSfillet_grp to include end_pt                      */
/* 12/17/91 - Modified BSfillet_kts to include csurf_par and csurf_dir.    */
/*             These are the convex cusp parameter values and direction    */
/*             indicators which directly correspond to the array of convex */
/*             cusp pseudo surfaces. We need these parameters in two       */
/*             intersection routines to reset center line parameter values */
/*             so that the linking routine can work properly. It is much   */
/*             easier to have access to this information by using these two*/
/*             arrays than extracting the information from the other fields*/
/*             of the structure.                                           */
/* 01/15/92 - Modified BSfillet_grp to double size of surf_ind             */
/* 05/10/93 - Removed information from fillet group structure for 2.4      */
/*            fillet revisions. (No more exterior rolling ball or extend)  */
/*            Add new structure for basic fillet information.              */

struct BSfillet_info
 {
   /* This structure contains basic information that is never modified.*/
   /*  Passing a pointer to this structure allows us to reduce the     */
   /*  number of arguments passed into a fillet subroutine.            */

   struct 
    IGRbsp_surface   *s1, *s2; /* pointers to original B-spline surfaces */
   IGRdouble         rad;      /* fillet radius                          */
   IGRboolean        n1, n2;   /* natural normal indicators              */
   IGRdouble         knot_tol1,/* knot tolerance values for surfaces     */
                     knot_tol2;
 };

struct BSfillet_kts
 {
   IGRint      mult_num[4];    /* number of multiple knots in all four       */
                               /*  directions - this includes the knots at   */
                               /*  degree and num_poles (minimum = 2)        */
   IGRdouble   *all_mult[4];   /* array of pointers to arrays of multiple    */
                               /*  knots in all four directions              */
   IGRint      *all_index[4];  /* array of pointers to arrays of multiple    */
                               /*  knot indexes - these are modified to      */
                               /*  to reflect the corresponding pole indexes */
   IGRboolean  *all_cusp[4];   /* array of pointers to arrays of indicators  */
                               /*  for the multiple knots which correspond   */
                               /*  to cusps                                  */
   IGRint      cvnum[4];       /* number of convex cusp parameter values in  */
                               /*  all four directions                       */
   IGRdouble   *all_convex[4]; /* array of pointers to arrays of convex cusp */
                               /*  parameter values                          */
   IGRint      *cnv_rng_num[4];/* array of pointers to arrays of numbers of  */
                               /*  convex cusp ranges for each cusp value    */
   BSpair      *all_cnv_rng[4];/* array of pointers to arrays of convex cusp */
                               /*  parametric range values (there is a range */
                               /*  for each convex cusp value)               */
   IGRint      ccnum[4];       /* number of concave cusp parameter values in */
                               /*  all four directions                       */
   IGRdouble   *all_concave[4];/* array of pointers to arrays of concave cusp*/
                               /*  parameter values                          */
   IGRint      *cnc_rng_num[4];/* array of pointers to arrays of numbers of  */
                               /*  concave cusp ranges for each cusp value   */
   BSpair      *all_cnc_rng[4];/* array of pointers to arrays of concave cusp*/
                               /*  parametric range values (there is a range */
                               /*  for each concave cusp value)              */
   IGRint      csurf_num[4];   /* number of convex cusp pseudo surface for   */
                               /*  all four directions                       */
   IGRdouble   *csurf_par;     /* array of convex cusp parameter values:     */
                               /*  each parameter value directly corresponds */
                               /*  to a convex cusp pseudo surface           */
   IGRint      *csurf_dir;     /* array of direction indicators:      each   */
                               /*  indicator directly corresponds to the     */
                               /*  direction of the convex cusp for a convex */
                               /*  cusp pseudo surface -- (0)u1, (1)v1,      */
                               /*   (2) u2, (3) v2                           */

   /* Note: If the number in cnv_rng_num or cnc_rng_num is 0, this indicates */
   /*       that the cusp line is entirely convex or concave. If the number  */
   /*       is 1, then there is only one range but it is not from tdegree    */
   /*       to tnum_poles.                                                   */

 };

struct BSfillet_grp
 {
   IGRint      num_pts;       /* number of points in center line group     */
   IGRpoint    *pts;          /* point of center line group                */
   BSpair      *par1, *par2;  /* parameter values corresponding to pts     */
   IGRint      type;          /* fillet surface type:                      */
                              /*  (0) regular fitted fillet                */
                              /*  (1) linear fillet                        */
                              /*  (2) convex cusp fillet/rolling ball/     */
                              /*       pivot point                         */
                              /*  (3) convex cusp fillet/rolling ball/     */
                              /*       pivot side                          */
                              /*  (4) partial sphere                       */
                              /*  (5) convex cusp fillet/interior un-      */
                              /*       supported/no pivot                  */
                              /*  (6) convex cusp fillet/extend/           */

   IGRint      u1endcusp[2],  /* indicators for end cusps                  */
               v1endcusp[2],  /*     (0) no cusp                           */
               u2endcusp[2],  /*     (1) convex cusp                       */
               v2endcusp[2];  /*     (2) concave cusp                      */

   IGRdouble   urng1[2], vrng1[2], /* multiple knot range values which are */
               urng2[2], vrng2[2]; /*  used when creating center lines     */

   IGRint      u1endpar[2],   /* indicators for parameter values at tdegree*/
               v1endpar[2],   /*  and tnum_poles:                          */
               u2endpar[2],   /*  (0) no end parameter value               */
               v2endpar[2];   /*  (1) tdegree    (2) tnum_poles            */

   IGRint      surf_ind[2];   /* For rolling ball case of convex cusp:     */
                              /*  Subscripts of csurf for a group which is */
                              /*  the product of an intersection with a    */
                              /*  convex cusp pseudo surface               */
                              /*  All valid numbers will be > 0            */
                              /*********************************************/
                              /* For extend case of convex cusp:           */
                              /*  Subscripts of esurf1 for a group which   */
                              /*  is the product of an intersection with an*/
                              /*  extend surface                           */

   BSpair      surf_par[2];   /* For rolling ball case of convex cusp:     */
                              /*  If surf_ind[0] > 0, this contains the    */
                              /*  original pseudo surface parameter values */
                              /*  for the group endpoints (if the group is */
                              /*  the product of intersecting two pseudo   */
                              /*  surfaces, these values correspond to the */
                              /*  surface indicated by surf_ind[0])        */
                              /*********************************************/
                              /* For extend case of convex cusp:           */
                              /*  surf_par[0][0] = convex cusp par value   */
                              /*********************************************/
                              /* For group with end at concave cusp:       */
                              /*  surf_par[0][0] and/or surf_par[1][0]  =  */
                              /*  concave cusp par value                   */

   IGRboolean  crv_prob;      /* indicator for group with curvature        */
                              /*  problem                                  */
   IGRboolean  end_pt[2];     /* indicators for fillet which ends in a     */
                              /*  point - these center lines are not to be */
                              /*  merged                                   */
 };

/* struct for special case fillets */
struct BSfillet_int
 {
   IGRint      type;          /* type of intersection curve             */
   struct IGRbsp_curve *int_cv;  /* the intersection curve              */
   IGRpoint    intpts[2];     /* the end points of int_cv               */
   IGRpoint    prjpts[2][2];  /* projection of intpts onto respective pl*/
   BSpair      uv[2][2];      /* the parameters for prjpts              */
   IGRint      pseudo_or_pl[2]; /* which kind of surface was intersected*/
                                /* 1 - offset plane                     */
                                /* 2 - pseudo cylinder                  */
 };

# endif /* bsifillsrf_include */
