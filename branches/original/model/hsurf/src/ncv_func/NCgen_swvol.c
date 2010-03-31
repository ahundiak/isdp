
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:39 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "wl.h"

#include "hnmilling.h"
#include "hnorient.h"
#include "hntiming.h"
#include "hntool.h"
#include "hntoolpath.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hsdisplay.h"
#include "hstiler.h"
#include "hnmill.h"

#include "HSpr_ncv_fun.h"

/*----------------------------
 *  for functions
 *     HSset_facet_normal
 *     clip_and_shade
 *     transform_points
 */

#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*---------------------------------*/

#define COUNT_EDGES       FALSE
#define DO_ORIGIN_SWVOL   TRUE
#define DO_DEST_SWVOL     TRUE
#define ZERO_TOL          1.0e-5
#define PI                3.14159


#define ABS(x)      (((x) > 0.0) ? (x) : -(x))
#define MAX(x, y)   (((x) > (y)) ? (x) : (y))

#define NORMALIZE(vector)                                              \
{                                                                      \
   length = sqrt((vector[0] * vector[0]) + (vector[1] * vector[1]) +   \
                 (vector[2] * vector[2]));                             \
   if (ABS(length >= ZERO_TOL))                                        \
   {                                                                   \
      vector[0] /= length;                                             \
      vector[1] /= length;                                             \
      vector[2] /= length;                                             \
   }                                                                   \
   else                                                                \
   {                                                                   \
      vector[0] = 0.0;                                                 \
      vector[1] = 0.0;                                                 \
      vector[2] = 0.0;                                                 \
      length = 0.0;                                                    \
   }                                                                   \
}

#define CROSS(va, vb, result)                                          \
{                                                                      \
   result[0] =   (va[1] * vb[2]) - (va[2] * vb[1]);                    \
   result[1] =   (va[2] * vb[0]) - (va[0] * vb[2]);                    \
   result[2] =   (va[0] * vb[1]) - (va[1] * vb[0]);                    \
}

#define AVERAGE(va, vb, result)                                        \
{                                                                      \
   result[0] =   va[0] + vb[0];                                        \
   result[1] =   va[1] + vb[1];                                        \
   result[2] =   va[2] + vb[2];                                        \
   NORMALIZE( result )                                                 \
}

#define ADVANCE_XINDEX(xindex, adv)                                    \
{                                                                      \
   xindex += adv;                                                      \
   if (xindex < 0)                                                     \
   {                                                                   \
      xindex += (2 * NCtool_data.num_xsect);                           \
   }                                                                   \
   else                                                                \
   {                                                                   \
      xindex %= (2 * NCtool_data.num_xsect);                           \
   }                                                                   \
}

#define SAVE_POINTS                                                    \
{                                                                      \
   xsect_index = ((xindex + index_offset1) %                           \
                 (2 * NCtool_data.num_xsect)) *                        \
                 NCtool_data.num_curve_points + pindex;                \
   NCtool_arrays.profile[num_profile_points][0] =                      \
                             NCtool_arrays.xsect[xsect_index][0];      \
   NCtool_arrays.profile[num_profile_points][1] =                      \
                             NCtool_arrays.xsect[xsect_index][1];      \
   NCtool_arrays.profile[num_profile_points][2] =                      \
                             NCtool_arrays.xsect[xsect_index][2];      \
   if (NCshading.active_shading_style == NCshading.SMOOTH_SHADING)     \
   {                                                                   \
      NCtool_arrays.profnorm[num_profile_points][0] =                  \
                             NCtool_arrays.vnorm[xsect_index][0];      \
      NCtool_arrays.profnorm[num_profile_points][1] =                  \
                             NCtool_arrays.vnorm[xsect_index][1];      \
      NCtool_arrays.profnorm[num_profile_points][2] =                  \
                             NCtool_arrays.vnorm[xsect_index][2];      \
      NCtool_arrays.profind[num_profile_points] = xsect_index;         \
   }                                                                   \
   num_profile_points++;                                               \
}

#define SAVE_POINTS2                                                   \
{                                                                      \
   xsect_index = ((xindex + index_offset1) %                           \
                  (2 * NCtool_data.num_xsect)) *                       \
                  NCtool_data.num_curve_points + pindex;               \
   NCtool_arrays.profile[profindex][0] =                               \
                         NCtool_arrays.xsect[xsect_index][0];          \
   NCtool_arrays.profile[profindex][1] =                               \
                         NCtool_arrays.xsect[xsect_index][1];          \
   NCtool_arrays.profile[profindex][2] =                               \
                         NCtool_arrays.xsect[xsect_index][2];          \
   if (NCshading.active_shading_style == NCshading.SMOOTH_SHADING)     \
   {                                                                   \
      NCtool_arrays.profnorm[profindex][0] =                           \
                         NCtool_arrays.vnorm[xsect_index][0];          \
      NCtool_arrays.profnorm[profindex][1] =                           \
                         NCtool_arrays.vnorm[xsect_index][1];          \
      NCtool_arrays.profnorm[profindex][2] =                           \
                         NCtool_arrays.vnorm[xsect_index][2];          \
      NCtool_arrays.profind[profindex] = xsect_index;                  \
   }                                                                   \
   profindex--;                                                        \
}


/**********************
 * EXTERNAL VARIABLES *
 **********************/

/*extern double sqrt(), cos(), acos();*/

extern struct NC_tool_data       NCtool_data;
extern struct NC_tool_arrays     NCtool_arrays;
extern struct NC_tool_orient     NCtool_orient;
extern struct NC_toolpath_data   NCtoolpath_data;
extern struct NC_shading_parms   NCshading;


/*******************
 * LOCAL VARIABLES *
 *******************/

static IGRint    num_profile_points;          /* the number of profile points */

static IGRint    num_fax_orig_profile_points; /* the number of points in the  */
                                              /* five-axis origin profile     */

static IGRint    num_fax_dest_profile_points; /* the number of points in the  */
                                              /* five-axis destination profile*/

static IGRint    index_offset1;
static IGRint    index_offset2;
static IGRint    fax_offset_diff;       /* the index offsets.  Index_offset1  */
                                        /* is the index of the first half of  */
                                        /* this xsect, while index_offset2 is */
                                        /* the index of the second half of    */
                                        /* this xsect and the offset diff is  */
                                        /* used to match starting and ending  */
                                        /* tools for fax swept volumes.       */

static IGRboolean   tool_moving_down;   /* the toolpath direction flag.  TRUE */
                                        /* means the tool is moving in a      */
                                        /* direction opposite its axis; FALSE */
                                        /* means it is moving in a direction  */
                                        /* along its axis                     */

#if COUNT_EDGES
static IGRint       inter_ct;
static IGRint       intra_ct;
static IGRboolean   same_xsect;
static IGRchar      inter_xsect[100];
static IGRchar      intra_xsect[100];
#endif

/*
 *  Prototype declaration for static functions
 */


#if defined (__)
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* NCgen_swvol.c */
static void get_path_curve __(( IGRdouble *path_curve ));

static void get_next_profile_point __(( IGRint      *xindex,
                                        IGRint      *pindex,
                                        IGRint      inc,
                                        IGRboolean  check_max ));

static void generate_modified_profile __(( IGRpoint  perp,
                                           IGRpoint  path_cv ));

static void generate_standard_profile __(( void ));

static void adjust_profile_normals __(( IGRpoint path_cv ));

static void restore_profile_normals __(( void ));

static void sweep_out_tool __(( IGRboolean bottom_half ));

static void generate_tax_side_facets __(( void ));

static void cap_standard_start __(( IGRpoint norm ));

static void cap_modified_start __(( IGRpoint norm ));

static void cap_standard_end __(( IGRpoint nva ));

static void cap_modified_end __(( IGRpoint nva ));

static void set_index_offset __(( IGRpoint    path_curve,
                                  IGRpoint    perp_vect,
                                  IGRboolean  *adjust_pc ));

static void NCbuild_tax_swept_volume __(( void ));

static void find_profile_points __(( IGRdouble  *orig_lo,
                                     IGRdouble  *orig_hi,
                                     IGRdouble  *end_lo,
                                     IGRdouble  *end_hi,
                                     IGRdouble  *orig_norm_lo,
                                     IGRdouble  *orig_norm_hi,
                                     IGRdouble  *end_norm_lo,
                                     IGRdouble  *end_norm_hi,
                                     IGRdouble  *orig_dp_lo,
                                     IGRdouble  *orig_dp_hi,
                                     IGRdouble  *end_dp_lo,
                                     IGRdouble  *end_dp_hi,
                                     IGRint     *orig_edge1,
                                     IGRint     *orig_edge2,
                                     IGRint     *end_edge1,
                                     IGRint     *end_edge2 ));

static void generate_toleranced_facet __(( IGRdouble *orig_lo,
                                           IGRdouble *orig_hi,
                                           IGRdouble *end_lo,
                                           IGRdouble *end_hi,
                                           IGRdouble *orig_norm_lo,
                                           IGRdouble *orig_norm_hi,
                                           IGRdouble *end_norm_lo,
                                           IGRdouble *end_norm_hi ));

static void NCtile_fax_tool __(( IGRdouble  *first_orient,
                                 IGRdouble  *second_orient,
                                 IGRpoint   *start_profile_point_array,
                                 IGRpoint   *start_profile_normal_array,
                                 IGRpoint   *end_profile_point_array,
                                 IGRpoint   *end_profile_normal_array,
                                 IGRint     *edge_matrix,
                                 IGRdouble  *dot_product_matrix ));

static void NCbuild_fax_swept_volume __(( void ));

#if defined(__cplusplus)
}
#endif


#undef __


/*-----get_path_curve--------------------------------------------------------*/

static void get_path_curve( IGRdouble *path_curve )


/*
 * ABSTRACT:   Get_path_curve calculates the path curve from the tool and
 *             toolpath data.
 *
 * HISTORY:   11/01/89  Created   C. M. Jablonski
 *
 */

{
   IGRpoint   curr_top_loc;
   IGRpoint   next_top_loc;

   path_curve[0] = NCtoolpath_data.next_location[0] -
                                            NCtoolpath_data.curr_location[0];
   path_curve[1] = NCtoolpath_data.next_location[1] -
                                            NCtoolpath_data.curr_location[1];
   path_curve[2] = NCtoolpath_data.next_location[2] -
                                            NCtoolpath_data.curr_location[2];

   if ((ABS(path_curve[0]) < ZERO_TOL) &&
       (ABS(path_curve[1]) < ZERO_TOL) &&
       (ABS(path_curve[2]) < ZERO_TOL))
   {
      curr_top_loc[0] = NCtool_data.height * NCtoolpath_data.curr_orient_vec[0];
      curr_top_loc[1] = NCtool_data.height * NCtoolpath_data.curr_orient_vec[1];
      curr_top_loc[2] = NCtool_data.height * NCtoolpath_data.curr_orient_vec[2];
      next_top_loc[0] = NCtool_data.height * NCtoolpath_data.next_orient_vec[0];
      next_top_loc[1] = NCtool_data.height * NCtoolpath_data.next_orient_vec[1];
      next_top_loc[2] = NCtool_data.height * NCtoolpath_data.next_orient_vec[2];

      path_curve[0] = next_top_loc[0] - curr_top_loc[0];
      path_curve[1] = next_top_loc[1] - curr_top_loc[1];
      path_curve[2] = next_top_loc[2] - curr_top_loc[2];
   }
}


/*-----get_next_profile_point-------------------------------------------------*/

static void get_next_profile_point( IGRint      *xindex,
                                    IGRint      *pindex,
                                    IGRint      inc,
                                    IGRboolean  check_max )

/*
 * ABSTRACT:   get_next_point calculates the direction to the next point in the
 *             profile curve and updates the corresponding indices.
 *
 * HISTORY:   07/23/88  Created.            C. M. Jablonski
 *            10/04/89  Added xpvec and tests for diagonal.   C. M. Jablonski
 *
 */

{
   IGRint      new_x;
   IGRint      new_p;
   IGRdouble   length;
   IGRpoint    xvec;
   IGRpoint    pvec;
   IGRpoint    xpvec;
   IGRpoint    testvec;
   IGRboolean  new_xsect;

   /* set up the possible next indices */
   new_x = *xindex;
   ADVANCE_XINDEX( new_x, inc )
   new_p = *pindex + 1;

   /* set up the test vectors */
   xvec[0] =
       NCtool_arrays.txm[new_x * NCtool_data.num_curve_points + *pindex][0] -
       NCtool_arrays.txm[(*xindex) * NCtool_data.num_curve_points + *pindex][0];
   xvec[1] =
       NCtool_arrays.txm[new_x * NCtool_data.num_curve_points + *pindex][1] -
       NCtool_arrays.txm[(*xindex) * NCtool_data.num_curve_points + *pindex][1];
   xvec[2] = 0.0;

   pvec[0] =
       NCtool_arrays.txm[(*xindex) * NCtool_data.num_curve_points + new_p][0] -
       NCtool_arrays.txm[(*xindex) * NCtool_data.num_curve_points + *pindex][0];
   pvec[1] =
       NCtool_arrays.txm[(*xindex) * NCtool_data.num_curve_points + new_p][1] -
       NCtool_arrays.txm[(*xindex) * NCtool_data.num_curve_points + *pindex][1];
   pvec[2] = 0.0;

   xpvec[0] =
       NCtool_arrays.txm[new_x * NCtool_data.num_curve_points + new_p][0] -
       NCtool_arrays.txm[(*xindex) * NCtool_data.num_curve_points + *pindex][0];
   xpvec[1] =
       NCtool_arrays.txm[new_x * NCtool_data.num_curve_points + new_p][1] -
       NCtool_arrays.txm[(*xindex) * NCtool_data.num_curve_points + *pindex][1];
   xpvec[2] = 0.0;

   /* normalize the test vectors.  This is VERY important. */
   NORMALIZE( xvec )
   NORMALIZE( pvec )
   NORMALIZE( xpvec )


   /*
    * Perform the "max x with positive y" test.  The next point in the profile
    * curve will be the one with a positive y value that has a greater x value.
    */

   /* first, compare xvec to pvec */
   if ( (check_max && (xvec[0] > pvec[0])) || 
        (!check_max && !(xvec[0] > pvec[0])) )
   {
      if ((xvec[1]+ZERO_TOL) > 0.0)
      {
         /* the next point is on the next cross-section */
         testvec[0] = xvec[0];
         testvec[1] = xvec[1];
         testvec[2] = xvec[2];
         new_xsect = TRUE;
      }
      else
      {
         /* the next point is the next point on the current cross section */
         testvec[0] = pvec[0];
         testvec[1] = pvec[1];
         testvec[2] = pvec[2];
         new_xsect = FALSE;
      }
   }
   else
   {
      if ((pvec[1]+ZERO_TOL) > 0.0)
      {
         /* the next point is the next point on the current cross section */
         testvec[0] = pvec[0];
         testvec[1] = pvec[1];
         testvec[2] = pvec[2];
         new_xsect = FALSE;
      }
      else
      {
         /* the next point is on the next cross-section */
         testvec[0] = xvec[0];
         testvec[1] = xvec[1];
         testvec[2] = xvec[2];
         new_xsect = TRUE;
      }
   }

   /* second, compare the result to xpvec */
   if ( (check_max && (testvec[0] > xpvec[0])) ||
        (!check_max && !(testvec[0] > xpvec[0])) )
   {
      if ((testvec[1]+ZERO_TOL) > 0.0)
      {
         if (new_xsect)
         {
            /* the next point is on the next cross-section */
            *xindex = new_x;
            NCtool_arrays.minpind[((*xindex + index_offset1) %
                                   (2 * NCtool_data.num_xsect))] = *pindex;
         }
         else
         {
            /* the next point is on the current cross-section */
            *pindex = new_p;
         }
      }
      else
      {  /* the next point is diagonally adjacent to the current one */
         *pindex = new_p;
         *xindex = new_x;
         NCtool_arrays.minpind[((*xindex + index_offset1) %
                                (2 * NCtool_data.num_xsect))] = *pindex;
      }
   }
   else
   {
      if ((xpvec[1]+ZERO_TOL) > 0.0)
      {  /* the next point is diagonally adjacent to the current one */
         *pindex = new_p;
         *xindex = new_x;
         NCtool_arrays.minpind[((*xindex + index_offset1) %
                                (2 * NCtool_data.num_xsect))] = *pindex;
      }
      else
      {
         if (new_xsect)
         {  /* the next point is on the next cross-section */
            *xindex = new_x;
            NCtool_arrays.minpind[((*xindex + index_offset1) %
                                  (2 * NCtool_data.num_xsect))] = *pindex;
         }
         else
         {  /* the next point is on the current cross-section */
            *pindex = new_p;
         }
      }
   }
}


/*-----generate_modified_profile------------------------------------------------------------*/

static void generate_modified_profile( IGRpoint perp,
                                       IGRpoint path_cv )

/*
 * ABSTRACT:   Generates a profile for the tool for the given path_curve
 *             direction.  Stores the profile as a set of points in the
 *             profile array, with the first and last point being equal.
 *             Also returns the size of the profile array in num_profile_points.
 *
 * HISTORY:   07/23/88   Created.         C. M. Jablonski
 *
 */

{
   IGRint     xindex;
   IGRint     pindex;
   IGRint     increment;
   IGRint     pmin;
   IGRint     initial_xindex;
   IGRint     final_xindex;
   IGRint     total_points;
   IGRint     xsect_index;
   IGRint     profindex;
   IGRdouble  rotation[3][3];
   IGRdouble  length;
   IGRpoint   axis;


   /*
    * Calculate the rotation matrix necessary to transform txm such that
    * the path curve becomes the z-axis.
    */

   CROSS(path_cv, perp, axis)
   NORMALIZE(axis)

   create_rotation_matrix ( perp, axis, path_cv, rotation );

#if FALSE
{
   fprintf(stderr,"perp = \t%f\t%f\t%f\n", perp[0], perp[1], perp[2]);
   fprintf(stderr,"axis = \t%f\t%f\t%f\n", axis[0], axis[1], axis[2]);
   fprintf(stderr,"p_cv = \t%f\t%f\t%f\n\n", path_cv[0], path_cv[1],
                   path_cv[2]);
   fprintf(stderr,"rot  = \t%f\t%f\t%f\n", rot[0][0], rot[0][1], rot[0][2]);
   fprintf(stderr,"       \t%f\t%f\t%f\n", rot[1][0], rot[1][1], rot[1][2]);
   fprintf(stderr,"       \t%f\t%f\t%f\n\n", rot[2][0], rot[2][1], rot[2][2]);
}
#endif

   /*
    * Set up the Temporary X-section Matrix.  It will equal the xsect matrix,
    * but be revolved so that the cross section most nearly perpendicular to 
    * the path curve is in column 0, translated so that the tip of the tool
    * (location) is at the origin and rotated so that path_curve is the z_axis.
    */

   total_points = 2 * NCtool_data.num_xsect * NCtool_data.num_curve_points;

   copy_points ( total_points,
                 total_points,
                 index_offset1 * NCtool_data.num_curve_points,
                 NCtool_arrays.xsect,
                 total_points,
                 0,
                 NCtool_arrays.txm );

   translate_points ( NCtoolpath_data.curr_location,
                      total_points,
                      NCtool_arrays.txm );

   rotate_points ( rotation,
                   total_points,
                   NCtool_arrays.txm );


   /*
    * Find the index of the point with the minimum y-value.  It will be
    * somewhere on that cross-section which is in the plane of the path curve.
    * NOTE: use the direction of the path curve relative to the axis (up or
    * down) to determine which half of the cross section will contain the
    * point with the minimum y value.
    */

   if ( tool_moving_down )
   {
      initial_xindex = xindex = NCtool_data.num_xsect * 3 / 2;
      final_xindex = NCtool_data.num_xsect / 2;
      increment = 1;
   }
   else
   {
      initial_xindex = xindex = NCtool_data.num_xsect / 2;
      final_xindex = NCtool_data.num_xsect * 3 / 2;
      increment = -1;
   }

   /* get the index of the point with the minimum y-value */
   pmin = 0;
   for ( pindex=0; pindex<NCtool_data.num_curve_points; pindex++ )
   {
      if((NCtool_arrays.txm[xindex * NCtool_data.num_curve_points + pindex][1] -
          NCtool_arrays.txm[xindex * NCtool_data.num_curve_points + pmin][1]) <
          ZERO_TOL )
      {
         pmin = pindex;
      }
   }

   pindex = pmin;

   /*
    * Get the first half of the profile curve.
    */

   /* we now know the first point in the profile, so save it */
   num_profile_points = 0;
   SAVE_POINTS

   /* save pindex as the minimum point index for this xsect */
   NCtool_arrays.minpind[((xindex + index_offset1) %
                         (2 * NCtool_data.num_xsect))] = pindex;


   /*
    * Find profile points until we hit either the top of the tool or the
    * cross-section opposite the one at which we started.
    */

   while ( (pindex < (NCtool_data.num_curve_points-1)) &&
           (xindex != final_xindex) )
   {
      get_next_profile_point( &xindex, &pindex, increment, TRUE );
      SAVE_POINTS
   }


   /*
    * If necessary, complete the profile by tracing along the top of the tool.
    */

   if (NCtool_data.open_ended)
   {
      while (xindex != final_xindex)
      {
         ADVANCE_XINDEX( xindex, increment )
         SAVE_POINTS
         NCtool_arrays.minpind[((xindex + index_offset1) % 
                               (2 * NCtool_data.num_xsect))] = pindex;
      }
   }

   /*
    * Get the second half of the profile curve.  Although we are calculating
    * points from the tip up, we have reversed the profile array indices so we
    * are storing the points in the proper locations.
    */

   /* initialize the txm pointers */
   xindex = initial_xindex;
   pindex = pmin;
   increment = -increment;
   num_profile_points = num_profile_points * 2 - 1;
   profindex = num_profile_points - 1;

   /* we know the first point in the profile, so save it */
   SAVE_POINTS2


   /*
    * Find profile points until we hit either the top of the tool or the
    * cross-section opposite the one at which we started.
    */

   while ( (pindex < (NCtool_data.num_curve_points-1)) &&
           (xindex != final_xindex) )
   {
      get_next_profile_point( &xindex, &pindex, increment, FALSE );
      SAVE_POINTS2
   }


   /*
    * If necessary, complete the profile by tracing along the top of the tool.
    */

   if (NCtool_data.open_ended)
   {
      while (xindex != final_xindex)
      {
         ADVANCE_XINDEX( xindex, increment )
         SAVE_POINTS2
         NCtool_arrays.minpind[((xindex + index_offset1) % 
                               (2 * NCtool_data.num_xsect))] = pindex;
      }
   }
}


/*-----generate_standard_profile------------------------------------------------------------*/

static void generate_standard_profile(void)

/*
 * ABSTRACT:   Generates a standard profile for the tool.  This profile equals
 *      the perpendicular cross-section, and this cross section already
 *      exists in xsect, so all we need to do is copy those points out of
 *      xsect and store them in the profile array.
 *
 * HISTORY:   07/23/88   Created.         C. M. Jablonski
 *
 */

{
   register int  pindex;
   IGRint        xsect_index;


   /* copy the first half of the cross-section */
   copy_points( NCtool_data.num_curve_points,
                2 * NCtool_data.num_xsect * NCtool_data.num_curve_points,
                index_offset1 * NCtool_data.num_curve_points,
                NCtool_arrays.xsect,
                2 * NCtool_data.num_curve_points,
                0,
                NCtool_arrays.profile );

   /* if smooth shading, copy the vertex normals */
   if (NCshading.active_shading_style == NCshading.SMOOTH_SHADING)
   {
      copy_points( NCtool_data.num_curve_points,
                   2 * NCtool_data.num_xsect * NCtool_data.num_curve_points,
                   index_offset1 * NCtool_data.num_curve_points,
                   NCtool_arrays.vnorm,
                   2 * NCtool_data.num_curve_points,
                   0,
                   NCtool_arrays.profnorm );

      for ( pindex=0; pindex<NCtool_data.num_curve_points; pindex++ )
      {
         NCtool_arrays.profind[pindex] = pindex + index_offset1 * 
                                         NCtool_data.num_curve_points;
      }
   }

   /* copy the other half of the cross-section */
   if (NCtool_data.open_ended)
   {
      for ( pindex=0; pindex<NCtool_data.num_curve_points; pindex++ )
      {
         xsect_index = pindex + index_offset2 * NCtool_data.num_curve_points;
         NCtool_arrays.profile[2*NCtool_data.num_curve_points-pindex-1][0] =
                                         NCtool_arrays.xsect[xsect_index][0];
         NCtool_arrays.profile[2*NCtool_data.num_curve_points-pindex-1][1] =
                                         NCtool_arrays.xsect[xsect_index][1];
         NCtool_arrays.profile[2*NCtool_data.num_curve_points-pindex-1][2] =
                                         NCtool_arrays.xsect[xsect_index][2];

         /* if smooth shading, copy the vertex normals */
         if (NCshading.active_shading_style == NCshading.SMOOTH_SHADING)
         {
            NCtool_arrays.profnorm[2*NCtool_data.num_curve_points-pindex-1][0] 
                                         = NCtool_arrays.vnorm[xsect_index][0];
            NCtool_arrays.profnorm[2*NCtool_data.num_curve_points-pindex-1][1]
                                         = NCtool_arrays.vnorm[xsect_index][1];
            NCtool_arrays.profnorm[2*NCtool_data.num_curve_points-pindex-1][2]
                                         = NCtool_arrays.vnorm[xsect_index][2];
            NCtool_arrays.profind[2*NCtool_data.num_curve_points-pindex-1] =
                                         xsect_index;
         }
      }

      num_profile_points = 2 * NCtool_data.num_curve_points;
   }
   else
   {
      /* don't duplicate the point at the top of the tool */
      for ( pindex=0; pindex<NCtool_data.num_curve_points; pindex++ )
      {
         xsect_index = pindex + index_offset2 * NCtool_data.num_curve_points;
         NCtool_arrays.profile[2*NCtool_data.num_curve_points-pindex-2][0] =
                                         NCtool_arrays.xsect[xsect_index][0];
         NCtool_arrays.profile[2*NCtool_data.num_curve_points-pindex-2][1] =
                                         NCtool_arrays.xsect[xsect_index][1];
         NCtool_arrays.profile[2*NCtool_data.num_curve_points-pindex-2][2] =
                                         NCtool_arrays.xsect[xsect_index][2];

         /* if smooth shading, copy the vertex normals */
         if (NCshading.active_shading_style == NCshading.SMOOTH_SHADING)
         {
            NCtool_arrays.profnorm[2*NCtool_data.num_curve_points-pindex-2][0] =
                                         NCtool_arrays.vnorm[xsect_index][0];
            NCtool_arrays.profnorm[2*NCtool_data.num_curve_points-pindex-2][1] =
                                         NCtool_arrays.vnorm[xsect_index][1];
            NCtool_arrays.profnorm[2*NCtool_data.num_curve_points-pindex-2][2] =
                                         NCtool_arrays.vnorm[xsect_index][2];
            NCtool_arrays.profind[2*NCtool_data.num_curve_points-pindex-2] =
                                         xsect_index;
         }
      }

      num_profile_points = 2 * NCtool_data.num_curve_points - 1;
   }
}


/*-----adjust_profile_normals-------------------------------------------------*/

static void adjust_profile_normals( IGRpoint path_cv )

/*
 * ABSTRACT:   Adjust_profile_normals adjusts the normals of the profile points
 *      so thst there will be a smooth transition between the shades
 *      on the sides of the swept volume and the shades at the end.
 *
 * HISTORY:   08/24/88   Created.         C. M. Jablonski
 *
 */

{
   IGRint     index;
   IGRpoint   to_prev;
   IGRpoint   to_next;
   IGRpoint   tmp1;
   IGRpoint   tmp2;
   IGRdouble  length;


   /* adjust the normal of the first (= last) point in the profile */
   /* determine the normal from the previous point in the profile */
   to_prev[0] = NCtool_arrays.profile[num_profile_points - 2][0] -
                                                  NCtool_arrays.profile[0][0];
   to_prev[1] = NCtool_arrays.profile[num_profile_points - 2][1] -
                                                  NCtool_arrays.profile[0][1];
   to_prev[2] = NCtool_arrays.profile[num_profile_points - 2][2] -
                                                  NCtool_arrays.profile[0][2];
   CROSS( path_cv, to_prev, tmp1 )

   if ( (ABS(tmp1[0])>ZERO_TOL) ||
        (ABS(tmp1[1])>ZERO_TOL) ||
        (ABS(tmp1[2])>ZERO_TOL))
   {
      NORMALIZE( tmp1 )

      /* determine the normal from the next point in the profile */
      to_next[0] = NCtool_arrays.profile[1][0] - NCtool_arrays.profile[0][0];
      to_next[1] = NCtool_arrays.profile[1][1] - NCtool_arrays.profile[0][1];
      to_next[2] = NCtool_arrays.profile[1][2] - NCtool_arrays.profile[0][2];
      CROSS( to_next, path_cv, tmp2 )
      if ((ABS(tmp2[0])>ZERO_TOL) ||
          (ABS(tmp2[1])>ZERO_TOL) ||
          (ABS(tmp2[2])>ZERO_TOL))
      {
         NORMALIZE( tmp2 )

         /* average the two to get the adjusted normal */
         AVERAGE( tmp1, tmp2, NCtool_arrays.vnorm[NCtool_arrays.profind[0]] )
      }
   }

   /* adjust normals for the rest of the profile points */
   if (NCtool_data.linestring)
   {
      for ( index = 1; index < (num_profile_points - 1); index++ )
      {
         if ((2 * index) < num_profile_points)
         {
            /* determine the normal from the previous point in the profile */
            to_prev[0] = NCtool_arrays.profile[index - 1][0] -
                                               NCtool_arrays.profile[index][0];
            to_prev[1] = NCtool_arrays.profile[index - 1][1] -
                                               NCtool_arrays.profile[index][1];
            to_prev[2] = NCtool_arrays.profile[index - 1][2] -
                                               NCtool_arrays.profile[index][2];
            CROSS( path_cv, to_prev, tmp1 )
            if ((ABS(tmp1[0])>ZERO_TOL) ||
                (ABS(tmp1[1])>ZERO_TOL) ||
                (ABS(tmp1[2])>ZERO_TOL))
            {
               NCtool_arrays.vnorm[NCtool_arrays.profind[index]][0] = tmp1[0];
               NCtool_arrays.vnorm[NCtool_arrays.profind[index]][1] = tmp1[1];
               NCtool_arrays.vnorm[NCtool_arrays.profind[index]][2] = tmp1[2];
               NORMALIZE( NCtool_arrays.vnorm[NCtool_arrays.profind[index]] )
            }
         }
         else
         {
            /* determine the normal from the next point in the profile */
            to_next[0] = NCtool_arrays.profile[index + 1][0] -
                                               NCtool_arrays.profile[index][0];
            to_next[1] = NCtool_arrays.profile[index + 1][1] -
                                               NCtool_arrays.profile[index][1];
            to_next[2] = NCtool_arrays.profile[index + 1][2] -
                                               NCtool_arrays.profile[index][2];
            CROSS( to_next, path_cv, tmp1 )

            if ((ABS(tmp1[0])>ZERO_TOL) ||
                (ABS(tmp1[1])>ZERO_TOL) ||
                (ABS(tmp1[2])>ZERO_TOL))
            {
               NCtool_arrays.vnorm[NCtool_arrays.profind[index]][0] = tmp1[0];
               NCtool_arrays.vnorm[NCtool_arrays.profind[index]][1] = tmp1[1];
               NCtool_arrays.vnorm[NCtool_arrays.profind[index]][2] = tmp1[2];
               NORMALIZE( NCtool_arrays.vnorm[NCtool_arrays.profind[index]] )
            }
         }
      }
   }
   else
   {
      for ( index = 1; index < (num_profile_points - 1); index++ )
      {
         /* determine the normal from the previous point in the profile */
         to_prev[0] = NCtool_arrays.profile[index - 1][0] -
                                               NCtool_arrays.profile[index][0];
         to_prev[1] = NCtool_arrays.profile[index - 1][1] -
                                               NCtool_arrays.profile[index][1];
         to_prev[2] = NCtool_arrays.profile[index - 1][2] -
                                               NCtool_arrays.profile[index][2];
         CROSS( path_cv, to_prev, tmp1 )

         if ((ABS(tmp1[0])>ZERO_TOL) ||
             (ABS(tmp1[1])>ZERO_TOL) ||
             (ABS(tmp1[2])>ZERO_TOL))
         {
            NORMALIZE( tmp1 )

            /* determine the normal from the next point in the profile */
            to_next[0] = NCtool_arrays.profile[index + 1][0] -
                                               NCtool_arrays.profile[index][0];
            to_next[1] = NCtool_arrays.profile[index + 1][1] -
                                               NCtool_arrays.profile[index][1];
            to_next[2] = NCtool_arrays.profile[index + 1][2] -
                                               NCtool_arrays.profile[index][2];
            CROSS( to_next, path_cv, tmp2 )

            if ((ABS(tmp2[0])>ZERO_TOL) ||
                (ABS(tmp2[1])>ZERO_TOL) ||
                (ABS(tmp2[2])>ZERO_TOL))
            {
               NORMALIZE( tmp2 )

               /* average the two to get the adjusted normal */
               AVERAGE( tmp1,
                        tmp2,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[index]] )
            }
         }
      }
   }
}


/*-----restore_profile_normals-----------------------------------------------------*/

static void restore_profile_normals(void)

/*
 * ABSTRACT:   Restore_profile_normals restores the normals of the profile
 *             points to their original values.
 *
 * HISTORY:   08/24/88   Created.         C. M. Jablonski
 *
 */

{
register int    index;

   for ( index = 0; index < (num_profile_points - 1); index++ )
   {
      NCtool_arrays.vnorm[NCtool_arrays.profind[index]][0] =
                                              NCtool_arrays.profnorm[index][0];
      NCtool_arrays.vnorm[NCtool_arrays.profind[index]][1] =
                                              NCtool_arrays.profnorm[index][1];
      NCtool_arrays.vnorm[NCtool_arrays.profind[index]][2] =
                                              NCtool_arrays.profnorm[index][2];
   }
}


/*-----sweep_out_tool--------------------------------------------------------*/

static void sweep_out_tool( IGRboolean bottom_half )

/*
 * ABSTRACT: Sweep_out_tool generates the facets of the tool itself.  The
 *           vertices are taken directly from XSECT, so XSECT is assumed to be
 *           in viewing coordinates.  The MINPIND (minimum point index) array
 *           determines which facets of the tool will be generated.  Each entry
 *           in MINPIND corresponds to half of a cross section in XSECT, and
 *           the value in MINPIND is the index of a point on that
 *           half-cross-section that is in the profile.  If multiple points 
 *           from that half-cross-section are in the profile, then the value
 *           is the minimum of the indexes of those points.  If no points of
 *           that half-cross-section are in the profile then the value in
 *           MINPIND is the index of the point nearest the top of the tool
 *           (= NCtool_data.num_curve_points - 1).  So MINPIND divides XSECT
 *           into two parts: the part made up of facets "above" the MINPIND
 *           values, and the part made up of facets "below" the MINPIND values.
 *           This routine can generate facets for either part, depending on the
 *           value of the "bottom_half" parameter.
 *
 * HISTORY:   07/23/88   Created.         C. M. Jablonski
 *
 */

{
   IGRint  xindex;
   IGRint  nxindex;
   IGRint  pindex;
   IGRint  this_xsect;
   IGRint  next_xsect;
   IGRint  thispt;
   IGRint  nextpt;


   /* Generate and process the tool's side facet loops. */
   for ( xindex=0; xindex<(2 * NCtool_data.num_xsect); xindex++ )
   {
      /* this_xsect will point to the beginning of each cross-section */
      this_xsect = xindex * NCtool_data.num_curve_points;

      /* set next_xsect to point to the beginning of the next cross-section */
      nxindex = (xindex + 1) % (2 * NCtool_data.num_xsect);
      next_xsect = nxindex * NCtool_data.num_curve_points;

      if (bottom_half)
      {
         /*
          * Build facets out of those points whose indexes are less than the value
          * in minpind, (the "bottom half" of the tool).
          */
         for ( pindex=1; ((pindex<=NCtool_arrays.minpind[xindex]) ||
                          (pindex<=NCtool_arrays.minpind[nxindex]));
               pindex++ )
         {
            /* thispt will point to each point in the cross section starting */
            /* at this_xsect */

            thispt = this_xsect + pindex;

            if (ABS(NCtool_arrays.fnorm[thispt][2]) > ZERO_TOL)
            {
               /* nextpt will point to each point in the cross section */
               /* starting at next_xsect */
               nextpt = next_xsect + pindex;

               /* set the facet normal */
               HSset_facet_normal( NCtool_arrays.fnorm[thispt][0],
                                   NCtool_arrays.fnorm[thispt][1],
                                   NCtool_arrays.fnorm[thispt][2] );

               /* create the facet loop */
               if (NCtool_data.linestring)
               {
                  HSadd_dexel_vertex( NCtool_arrays.xsect[thispt][0],
                                      NCtool_arrays.xsect[thispt][1],
                                      NCtool_arrays.xsect[thispt][2],
                                      1.0,
                                      NCtool_arrays.vnorm[thispt][0],
                                      NCtool_arrays.vnorm[thispt][1],
                                      NCtool_arrays.vnorm[thispt][2] );

                  HSadd_dexel_vertex( NCtool_arrays.xsect[thispt-1][0],
                                      NCtool_arrays.xsect[thispt-1][1],
                                      NCtool_arrays.xsect[thispt-1][2],
                                      1.0,
                                      NCtool_arrays.vnorm[thispt][0],
                                      NCtool_arrays.vnorm[thispt][1],
                                      NCtool_arrays.vnorm[thispt][2] );

                  HSadd_dexel_vertex( NCtool_arrays.xsect[nextpt-1][0],
                                      NCtool_arrays.xsect[nextpt-1][1],
                                      NCtool_arrays.xsect[nextpt-1][2],
                                      1.0,
                                      NCtool_arrays.vnorm[nextpt][0],
                                      NCtool_arrays.vnorm[nextpt][1],
                                      NCtool_arrays.vnorm[nextpt][2] );

                  HSadd_dexel_vertex( NCtool_arrays.xsect[nextpt][0],
                                      NCtool_arrays.xsect[nextpt][1],
                                      NCtool_arrays.xsect[nextpt][2],
                                      1.0,
                                      NCtool_arrays.vnorm[nextpt][0],
                                      NCtool_arrays.vnorm[nextpt][1],
                                      NCtool_arrays.vnorm[nextpt][2] );
               }
               else
               {
                  HSadd_dexel_vertex( NCtool_arrays.xsect[thispt][0],
                                      NCtool_arrays.xsect[thispt][1],
                                      NCtool_arrays.xsect[thispt][2],
                                      1.0,
                                      NCtool_arrays.vnorm[thispt][0],
                                      NCtool_arrays.vnorm[thispt][1],
                                      NCtool_arrays.vnorm[thispt][2] );

                  HSadd_dexel_vertex( NCtool_arrays.xsect[thispt-1][0],
                                      NCtool_arrays.xsect[thispt-1][1],
                                      NCtool_arrays.xsect[thispt-1][2],
                                      1.0,
                                      NCtool_arrays.vnorm[thispt-1][0],
                                      NCtool_arrays.vnorm[thispt-1][1],
                                      NCtool_arrays.vnorm[thispt-1][2] );

                  HSadd_dexel_vertex( NCtool_arrays.xsect[nextpt-1][0],
                                      NCtool_arrays.xsect[nextpt-1][1],
                                      NCtool_arrays.xsect[nextpt-1][2],
                                      1.0,
                                      NCtool_arrays.vnorm[nextpt-1][0],
                                      NCtool_arrays.vnorm[nextpt-1][1],
                                      NCtool_arrays.vnorm[nextpt-1][2] );

                  HSadd_dexel_vertex( NCtool_arrays.xsect[nextpt][0],
                                      NCtool_arrays.xsect[nextpt][1],
                                      NCtool_arrays.xsect[nextpt][2],
                                      1.0,
                                      NCtool_arrays.vnorm[nextpt][0],
                                      NCtool_arrays.vnorm[nextpt][1],
                                      NCtool_arrays.vnorm[nextpt][2] );
               }

               /* process the facet loop */
               clip_and_shade();
            }
         }
      }
      else
      {
         /*
          * Build facets out of those points whose indexes are greater than the value
          * in minpind, (the "top half" of the tool).
          */
         for ( pindex=1; ((pindex<=NCtool_arrays.minpind[xindex]) ||
                          (pindex<=NCtool_arrays.minpind[nxindex]));
               pindex++ );

         for ( ; pindex<NCtool_data.num_curve_points; pindex++ )
         {
            /* thispt will point to each point in the cross section starting */
            /* at this_xsect */
            thispt = this_xsect + pindex;

            /* nextpt will point to each point in the cross section starting */
            /* at next_xsect */
            nextpt = next_xsect + pindex;

            if (ABS(NCtool_arrays.fnorm[thispt][2]) > ZERO_TOL)
            {
               /* set the facet normal */
               HSset_facet_normal( NCtool_arrays.fnorm[thispt][0],
                                   NCtool_arrays.fnorm[thispt][1],
                                   NCtool_arrays.fnorm[thispt][2] );

               /* create the facet loop */
               if (NCtool_data.linestring)
               {
                  HSadd_dexel_vertex( NCtool_arrays.xsect[thispt][0],
                                      NCtool_arrays.xsect[thispt][1],
                                      NCtool_arrays.xsect[thispt][2],
                                      1.0,
                                      NCtool_arrays.vnorm[thispt][0],
                                      NCtool_arrays.vnorm[thispt][1],
                                      NCtool_arrays.vnorm[thispt][2] );

                  HSadd_dexel_vertex( NCtool_arrays.xsect[thispt-1][0],
                                      NCtool_arrays.xsect[thispt-1][1],
                                      NCtool_arrays.xsect[thispt-1][2],
                                      1.0,
                                      NCtool_arrays.vnorm[thispt][0],
                                      NCtool_arrays.vnorm[thispt][1],
                                      NCtool_arrays.vnorm[thispt][2] );

                  HSadd_dexel_vertex( NCtool_arrays.xsect[nextpt-1][0],
                                      NCtool_arrays.xsect[nextpt-1][1],
                                      NCtool_arrays.xsect[nextpt-1][2],
                                      1.0,
                                      NCtool_arrays.vnorm[nextpt][0],
                                      NCtool_arrays.vnorm[nextpt][1],
                                      NCtool_arrays.vnorm[nextpt][2] );

                  HSadd_dexel_vertex( NCtool_arrays.xsect[nextpt][0],
                                      NCtool_arrays.xsect[nextpt][1],
                                      NCtool_arrays.xsect[nextpt][2],
                                      1.0,
                                      NCtool_arrays.vnorm[nextpt][0],
                                      NCtool_arrays.vnorm[nextpt][1],
                                      NCtool_arrays.vnorm[nextpt][2] );
               }
               else
               {
                  HSadd_dexel_vertex( NCtool_arrays.xsect[thispt][0],
                                      NCtool_arrays.xsect[thispt][1],
                                      NCtool_arrays.xsect[thispt][2],
                                      1.0,
                                      NCtool_arrays.vnorm[thispt][0],
                                      NCtool_arrays.vnorm[thispt][1],
                                      NCtool_arrays.vnorm[thispt][2] );

                  HSadd_dexel_vertex( NCtool_arrays.xsect[thispt-1][0],
                                      NCtool_arrays.xsect[thispt-1][1],
                                      NCtool_arrays.xsect[thispt-1][2],
                                      1.0,
                                      NCtool_arrays.vnorm[thispt-1][0],
                                      NCtool_arrays.vnorm[thispt-1][1],
                                      NCtool_arrays.vnorm[thispt-1][2] );

                  HSadd_dexel_vertex( NCtool_arrays.xsect[nextpt-1][0],
                                      NCtool_arrays.xsect[nextpt-1][1],
                                      NCtool_arrays.xsect[nextpt-1][2],
                                      1.0,
                                      NCtool_arrays.vnorm[nextpt-1][0],
                                      NCtool_arrays.vnorm[nextpt-1][1],
                                      NCtool_arrays.vnorm[nextpt-1][2] );

                  HSadd_dexel_vertex( NCtool_arrays.xsect[nextpt][0],
                                      NCtool_arrays.xsect[nextpt][1],
                                      NCtool_arrays.xsect[nextpt][2],
                                      1.0,
                                      NCtool_arrays.vnorm[nextpt][0],
                                      NCtool_arrays.vnorm[nextpt][1],
                                      NCtool_arrays.vnorm[nextpt][2] );
               }

               /* process the facet loop */
               clip_and_shade();
            }
         }
      }
   }
}


/*-----generate_tax_side_facets------------------------------------------------------------*/

static void generate_tax_side_facets(void)

/*
 * ABSTRACT:   generate_tax_side_facets creates and processes the facets on the
 *             sides of the swept volume using the profile array.  After
 *             defining each facet, this routine calls clip_and_shade which
 *             converts the facet into trapezoids with intensities.
 *
 * HISTORY:   08/10/88   Created.         C. M. Jablonski
 *
 */

{
   register int  from_lo;
   register int  from_hi;
   register int  to_lo;
   register int  to_hi;
   IGRdouble     length;
   IGRpoint      edge1;
   IGRpoint      edge2;
   IGRpoint      norm;

   for ( from_lo   = 0,
         from_hi   = 1,
         to_lo   = num_profile_points,
         to_hi   = num_profile_points + 1;

         from_hi   < num_profile_points;

         from_lo++,
         from_hi++,
         to_lo++,
         to_hi++ )
   {
      /* cross two surface vectors to find the facet normal */
      edge1[0] = NCtool_arrays.profile[from_lo][0] -
                 NCtool_arrays.profile[to_hi][0];
      edge1[1] = NCtool_arrays.profile[from_lo][1] -
                 NCtool_arrays.profile[to_hi][1];
      edge1[2] = NCtool_arrays.profile[from_lo][2] -
                 NCtool_arrays.profile[to_hi][2];

      edge2[0] = NCtool_arrays.profile[to_lo][0] -
                 NCtool_arrays.profile[from_hi][0];
      edge2[1] = NCtool_arrays.profile[to_lo][1] -
                 NCtool_arrays.profile[from_hi][1];
      edge2[2] = NCtool_arrays.profile[to_lo][2] -
                 NCtool_arrays.profile[from_hi][2];

      CROSS(edge2, edge1, norm)

      if ((ABS(norm[0])>ZERO_TOL) ||
          (ABS(norm[1])>ZERO_TOL) ||
          (ABS(norm[2])>ZERO_TOL))
      {
         NORMALIZE( norm )

         if (ABS(norm[2]) > ZERO_TOL)
         {
            /* set the facet normal */
            HSset_facet_normal( norm[0], norm[1], norm[2] );

            /* create the facet loop */
            if (NCshading.active_shading_style != NCshading.SMOOTH_SHADING)
            {
               HSadd_dexel_vertex( NCtool_arrays.profile[from_hi][0],
                                   NCtool_arrays.profile[from_hi][1],
                                   NCtool_arrays.profile[from_hi][2],
                                   1.0 );

               HSadd_dexel_vertex( NCtool_arrays.profile[from_lo][0],
                                   NCtool_arrays.profile[from_lo][1],
                                   NCtool_arrays.profile[from_lo][2],
                                   1.0 );

               HSadd_dexel_vertex( NCtool_arrays.profile[to_lo][0],
                                   NCtool_arrays.profile[to_lo][1],
                                   NCtool_arrays.profile[to_lo][2],
                                   1.0 );

               HSadd_dexel_vertex( NCtool_arrays.profile[to_hi][0],
                                   NCtool_arrays.profile[to_hi][1],
                                   NCtool_arrays.profile[to_hi][2],
                                   1.0 );
            }
            else if (NCtool_data.linestring)
            {
               /*
                * Linestrings are extremely tricky, bacause we have to check
                * each pair of profile points.  If the pair is from the same
                * cross-section, we set the normals to generate a 
                * constant-looking facet.  If the two points are from different
                * cross-sections, we need to set the normals to generate a
                * smooth-looking facet.
                */

               if ((from_hi * 2) < num_profile_points)
               {
                  /* doing first half of the profile curve */
                  HSadd_dexel_vertex(
                         NCtool_arrays.profile[from_hi][0],
                         NCtool_arrays.profile[from_hi][1],      
                         NCtool_arrays.profile[from_hi][2],
                         1.0,
                         NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][0],
                         NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][1],
                         NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][2]
                          );

                  if ((NCtool_arrays.profind[from_hi] - 
                       NCtool_arrays.profind[from_lo]) == 1)
                  {
                     /* both points are from the same xsect, so use SAME  */
                     /* normal as hi points */
                     HSadd_dexel_vertex(
                        NCtool_arrays.profile[from_lo][0],
                        NCtool_arrays.profile[from_lo][1],
                        NCtool_arrays.profile[from_lo][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][2]
                      );

                     HSadd_dexel_vertex(
                        NCtool_arrays.profile[to_lo][0],
                        NCtool_arrays.profile[to_lo][1],
                        NCtool_arrays.profile[to_lo][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][2]
                      );
                  }
                  else
                  {
                     /* the points are from different xsects, so use DIFFERENT*/
                     /* normals */
                     HSadd_dexel_vertex(
                        NCtool_arrays.profile[from_lo][0],
                        NCtool_arrays.profile[from_lo][1],
                        NCtool_arrays.profile[from_lo][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][2]
                      );

                     HSadd_dexel_vertex(
                        NCtool_arrays.profile[to_lo][0],
                        NCtool_arrays.profile[to_lo][1],
                        NCtool_arrays.profile[to_lo][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][2]
                      );
                  }

                  HSadd_dexel_vertex(
                        NCtool_arrays.profile[to_hi][0],
                        NCtool_arrays.profile[to_hi][1],
                        NCtool_arrays.profile[to_hi][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][2]
                      );
               }
               else
               {
                  /* doing second half of the profile curve */
                  if ((NCtool_arrays.profind[from_lo] - 
                       NCtool_arrays.profind[from_hi]) == 1)
                  {
                     /* both points are from the same xsect, so use SAME   */
                     /* normals */
                     HSadd_dexel_vertex(
                        NCtool_arrays.profile[from_hi][0],
                        NCtool_arrays.profile[from_hi][1],
                        NCtool_arrays.profile[from_hi][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][2]
                      );

                     HSadd_dexel_vertex(
                        NCtool_arrays.profile[from_lo][0],
                        NCtool_arrays.profile[from_lo][1],
                        NCtool_arrays.profile[from_lo][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][2]
                      );

                     HSadd_dexel_vertex(
                        NCtool_arrays.profile[to_lo][0],
                        NCtool_arrays.profile[to_lo][1],
                        NCtool_arrays.profile[to_lo][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][2]
                      );

                     HSadd_dexel_vertex(
                        NCtool_arrays.profile[to_hi][0],
                        NCtool_arrays.profile[to_hi][1],
                        NCtool_arrays.profile[to_hi][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][2]
                      );
                  }
                  else
                  {
                     /* the points are from different xsects, so use DIFFERENT*/
                     /* normals */
                     HSadd_dexel_vertex(
                        NCtool_arrays.profile[from_hi][0],
                        NCtool_arrays.profile[from_hi][1],
                        NCtool_arrays.profile[from_hi][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][2]
                      );

                     HSadd_dexel_vertex(
                        NCtool_arrays.profile[from_lo][0],
                        NCtool_arrays.profile[from_lo][1],
                        NCtool_arrays.profile[from_lo][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][2]
                      );

                     HSadd_dexel_vertex(
                        NCtool_arrays.profile[to_lo][0],
                        NCtool_arrays.profile[to_lo][1],
                        NCtool_arrays.profile[to_lo][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_lo]][2]
                      );

                     HSadd_dexel_vertex(
                        NCtool_arrays.profile[to_hi][0],
                        NCtool_arrays.profile[to_hi][1],
                        NCtool_arrays.profile[to_hi][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[from_hi]][2]
                      );
                  }
               }
            }
            else
            {
               HSadd_dexel_vertex( NCtool_arrays.profile[from_hi][0],
                                   NCtool_arrays.profile[from_hi][1],
                                   NCtool_arrays.profile[from_hi][2],
                                   1.0,
                                   NCtool_arrays.profnorm[from_hi][0],
                                   NCtool_arrays.profnorm[from_hi][1],
                                   NCtool_arrays.profnorm[from_hi][2] );

               HSadd_dexel_vertex( NCtool_arrays.profile[from_lo][0],
                                   NCtool_arrays.profile[from_lo][1],
                                   NCtool_arrays.profile[from_lo][2],
                                   1.0,
                                   NCtool_arrays.profnorm[from_lo][0],
                                   NCtool_arrays.profnorm[from_lo][1],
                                   NCtool_arrays.profnorm[from_lo][2] );

               HSadd_dexel_vertex( NCtool_arrays.profile[to_lo][0],
                                   NCtool_arrays.profile[to_lo][1],
                                   NCtool_arrays.profile[to_lo][2],
                                   1.0,
                                   NCtool_arrays.profnorm[from_lo][0],
                                   NCtool_arrays.profnorm[from_lo][1],
                                   NCtool_arrays.profnorm[from_lo][2] );

               HSadd_dexel_vertex( NCtool_arrays.profile[to_hi][0],
                                   NCtool_arrays.profile[to_hi][1],
                                   NCtool_arrays.profile[to_hi][2],
                                   1.0,
                                   NCtool_arrays.profnorm[from_hi][0],
                                   NCtool_arrays.profnorm[from_hi][1],
                                   NCtool_arrays.profnorm[from_hi][2] );
            }

            /* process the facet loop */
            clip_and_shade();
         }
      }
   }
}


/*-----cap_standard_start------------------------------------------------------------*/

static void cap_standard_start( IGRpoint norm )

/*
 * ABSTRACT:   Cap_standard_start generates and processes the facet necessary
 *             to cap off the starting end of a standard swept volume.
 *
 * HISTORY:   08/10/88   Created.         C. M. Jablonski
 *
 */

{
   register int   index;


   /* set the FACET normal.  This is necessary so that the tiler can  */
   /* determine whether it is front- or back-facing. */
   HSset_facet_normal( norm[0], norm[1], norm[2] );

   /* create the facet loop. */
   if (NCshading.active_shading_style == NCshading.SMOOTH_SHADING)
   {
      /* NOTE: each vertex will have the normal pointing to the SIDE of the */
      /* swept volume.  This will ensure that the edges have the right      */
      /* shading, and will not affect the actual shape of the swept volume. */

      for ( index=0; index<num_profile_points; index++ )
         HSadd_dexel_vertex(
                     NCtool_arrays.profile[index][0],
                     NCtool_arrays.profile[index][1],
                     NCtool_arrays.profile[index][2],
                     1.0,
                     NCtool_arrays.vnorm[NCtool_arrays.profind[index]][0],
                     NCtool_arrays.vnorm[NCtool_arrays.profind[index]][1],
                     NCtool_arrays.vnorm[NCtool_arrays.profind[index]][2] );
   }
   else
   {
      for ( index=0; index<num_profile_points; index++ )
         HSadd_dexel_vertex(
                     NCtool_arrays.profile[index][0],
                     NCtool_arrays.profile[index][1],
                     NCtool_arrays.profile[index][2],
                     1.0 );
   }

   /* process the facet loop */
   clip_and_shade();
}


/*-----cap_modified_start------------------------------------------------------------*/

static void cap_modified_start( IGRpoint norm )

/*
 * ABSTRACT:   Cap_modified_start generates and processes the facets necessary
 *      to cap off the starting end of a standard swept volume.  It can't
 *      use one big facet because, unlike the standard profile, the modified
 *      profile curve is not planar.  Instead, it covers the end with a set
 *      of triangles that have profile[0] as their common apex.
 *
 * HISTORY:   08/10/88   Created.         C. M. Jablonski
 *
 */

{
   register int   index;


   /* create and process each triangle, using the first point as the apex.   */

   if (NCshading.active_shading_style == NCshading.SMOOTH_SHADING)
   {
      /* NOTE: each vertex will have the normal pointing to the SIDE of the  */
      /*       swept volume.  This will ensure that the edges have the right */
      /*       shading, and will not affect the actual shape of the swept    */
      /*       volume.                                                       */

      for ( index=2; index<(num_profile_points-1); index++ )
      {
         /* set the FACET normal.  This is necessary so that the tiler can   */
         /* determine whether it is front- or back-facing.                   */

         HSset_facet_normal( norm[0], norm[1], norm[2] );

         HSadd_dexel_vertex( NCtool_arrays.profile[0][0],
                             NCtool_arrays.profile[0][1],
                             NCtool_arrays.profile[0][2],
                             1.0,
                             NCtool_arrays.vnorm[NCtool_arrays.profind[0]][0],
                             NCtool_arrays.vnorm[NCtool_arrays.profind[0]][1],
                             NCtool_arrays.vnorm[NCtool_arrays.profind[0]][2] );

         HSadd_dexel_vertex(
                        NCtool_arrays.profile[index-1][0],
                        NCtool_arrays.profile[index-1][1],
                        NCtool_arrays.profile[index-1][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[index-1]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[index-1]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[index-1]][2]
                        );

         HSadd_dexel_vertex( NCtool_arrays.profile[index][0],
                        NCtool_arrays.profile[index][1],
                        NCtool_arrays.profile[index][2],
                        1.0,
                        NCtool_arrays.vnorm[NCtool_arrays.profind[index]][0],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[index]][1],
                        NCtool_arrays.vnorm[NCtool_arrays.profind[index]][2] );

         clip_and_shade();
      }
   }
   else
   {
      for ( index=2; index<(num_profile_points-1); index++ )
      {
         /* set the FACET normal.  This is necessary so that the tiler can   */
         /* determine whether it is front- or back-facing.                   */

         HSset_facet_normal( norm[0], norm[1], norm[2] );

         HSadd_dexel_vertex( NCtool_arrays.profile[0][0],
                             NCtool_arrays.profile[0][1],
                             NCtool_arrays.profile[0][2],
                             1.0 );

         HSadd_dexel_vertex( NCtool_arrays.profile[index-1][0],
                             NCtool_arrays.profile[index-1][1],
                             NCtool_arrays.profile[index-1][2],
                             1.0 );

         HSadd_dexel_vertex( NCtool_arrays.profile[index][0],
                             NCtool_arrays.profile[index][1],
                             NCtool_arrays.profile[index][2],
                             1.0 );

         clip_and_shade();
      }
   }
}


/*-----cap_standard_end-------------------------------------------------------*/

static void cap_standard_end( IGRpoint nva )

/*
 * ABSTRACT:   Cap_standard_end generates and processes the facets necessary
 *             to cap off the destination end of a standard swept volume.
 *
 * HISTORY:   08/10/88   Created.         C. M. Jablonski
 *
 */

{
   register int   index;


   /* set minpind and tool_moving_down so that we only generate tiles for */
   /* the half of the tool that is outside the swept volume               */

   if (index_offset1 < index_offset2)
   {
      for ( index=0; index<index_offset1; index++ )
      {
         NCtool_arrays.minpind[index] = 0;
      }

      for ( index=index_offset1; index<=index_offset2; index++ )
      {
         NCtool_arrays.minpind[index] = NCtool_data.num_curve_points - 1;
      }

      for ( index=index_offset2+1; index<2*NCtool_data.num_xsect; index++ )
      {
         NCtool_arrays.minpind[index] = 0;
      }
   }
   else
   {
      for ( index=0; index<=index_offset2; index++ )
      {
         NCtool_arrays.minpind[index] = NCtool_data.num_curve_points - 1;
      }

      for ( index=index_offset2+1; index<index_offset1; index++ )
      {
         NCtool_arrays.minpind[index] = 0;
      }

      for ( index=index_offset1; index<2*NCtool_data.num_xsect; index++ )
      {
         NCtool_arrays.minpind[index] = NCtool_data.num_curve_points - 1;
      }
   }

   /* sweep out the destination end */
   sweep_out_tool( TRUE );

   /*
    * Cap the top of the section we just swept out.
    */

   if (NCtool_data.open_ended)
   {
      /* set the shading style */
      HSset_dexel_shading_style( NCshading.CONSTANT_SHADING );

      if (ABS(nva[2]) > ZERO_TOL)
      {
         /* set the facet normal */
         HSset_facet_normal( nva[0], nva[1], nva[2] );

         /* create the facet loop */
         if (index_offset1 < index_offset2)
         {
            for( 
             index = ((index_offset2 + 1) * NCtool_data.num_curve_points) - 1;
             index >= ((index_offset1 + 1) * NCtool_data.num_curve_points) - 1;
             index -= NCtool_data.num_curve_points )
            {
               HSadd_dexel_vertex(NCtool_arrays.xsect[index][0],
                                  NCtool_arrays.xsect[index][1],
                                  NCtool_arrays.xsect[index][2],
                                  1.0 );
            }
         }
         else
         {
            for(index = ((index_offset2 + 1) * NCtool_data.num_curve_points)-1;
                index >= NCtool_data.num_curve_points - 1;
                index -= NCtool_data.num_curve_points )
            {
               HSadd_dexel_vertex(NCtool_arrays.xsect[index][0],
                                  NCtool_arrays.xsect[index][1],
                                  NCtool_arrays.xsect[index][2],
                                  1.0 );
            }

            for (
             index = ((2*NCtool_data.num_xsect)*NCtool_data.num_curve_points)-1;
             index >= ((index_offset1 + 1) * NCtool_data.num_curve_points) - 1;
             index -= NCtool_data.num_curve_points )
            {
               HSadd_dexel_vertex(NCtool_arrays.xsect[index][0],
                                  NCtool_arrays.xsect[index][1],
                                  NCtool_arrays.xsect[index][2],
                                  1.0 );
            }
         }
         /* process the facet loop */
         clip_and_shade();
      }
      /* reset the shading style */
      HSset_dexel_shading_style( NCshading.active_shading_style );
   }
}


/*-----cap_modified_end-------------------------------------------------------*/

static void cap_modified_end( IGRpoint nva )

/*
 * ABSTRACT:   Cap_modified_end generates and processes the facets necessary
 *             to cap off the destination end of a modified swept volume.
 *
 * HISTORY:   08/10/88   Created.         C. M. Jablonski
 *
 */

{
   register int   index;

   /* minpind was set by generate_modified_profile, so go ahead and sweep */
   sweep_out_tool( tool_moving_down );

   /* if necessary, cap the top of area we just swept out */
   if ( (!tool_moving_down) &&
        (NCtool_data.open_ended) &&
        (ABS(nva[2]) > ZERO_TOL))
   {
      /* set the shading style */
      HSset_dexel_shading_style( NCshading.CONSTANT_SHADING );

      /* set the facet normal */
      HSset_facet_normal( nva[0], nva[1], nva[2] );

      /* create the facet loop */
      for (
        index = ( 2 * NCtool_data.num_xsect * NCtool_data.num_curve_points) - 1;
        index > 0;
        index -= NCtool_data.num_curve_points )
      {
         HSadd_dexel_vertex( NCtool_arrays.xsect[index][0],
                             NCtool_arrays.xsect[index][1],
                             NCtool_arrays.xsect[index][2],
                             1.0 );
      }

      /* process the facet loop */
      clip_and_shade();

      /* reset the shading style */
      HSset_dexel_shading_style( NCshading.active_shading_style );
   }
}


/*-----set_index_offset-------------------------------------------------------*/

static void set_index_offset( IGRpoint    path_curve,
                              IGRpoint    perp_vect,
                              IGRboolean  *adjust_pc )

/*
 * ABSTRACT:   Set_index_offset determines the index offset between the path
 *             curve and the original orientation.  This is the index of the
 *             cross-section that is most nearly perpendicular to the path
 *             curve.
 *
 * HISTORY:   08/11/88   Created.         C. M. Jablonski
 *
 */

{
   IGRint     index_offset;
   IGRdouble  length;
   IGRdouble  angle;
   IGRdouble  index_delta;
   IGRpoint   testvect;

   /* cross the axis and path curve to get a perpendicular vector */

   CROSS( NCtool_orient.axis, path_curve, perp_vect )

   if ((ABS(perp_vect[0])<ZERO_TOL) &&
       (ABS(perp_vect[1])<ZERO_TOL) &&
       (ABS(perp_vect[2])<ZERO_TOL))
   {
      perp_vect[0] = NCtool_orient.xsect[0];
      perp_vect[1] = NCtool_orient.xsect[1];
      perp_vect[2] = NCtool_orient.xsect[2];
      *adjust_pc = FALSE;
   }
   else
   {
      NORMALIZE( perp_vect )
      *adjust_pc = TRUE;
   }

   /* calculate the angle between the NCtool_orient.xsect vector and the xs */
   /* vector                                                                */
   length = perp_vect[0]*NCtool_orient.xsect[0] +
            perp_vect[1]*NCtool_orient.xsect[1] +
            perp_vect[2]*NCtool_orient.xsect[2];

   if (length <= -1.0)
   {
      angle = PI;
   }
   else if (length >= 1.0)
   {
      angle = 0.0;
   }
   else
   {
      angle = acos(length);
   }

   /* translate this angle into an index offset */
   index_delta = PI / (IGRdouble)NCtool_data.num_xsect;
   index_offset = (angle / index_delta) + 0.5;


   /* if necessary, adjust the index offset to compensate for direction */
   CROSS ( NCtool_orient.xsect, perp_vect, testvect )

   if ( (index_offset > 0) &&
        ((testvect[0]*NCtool_orient.axis[0] +
          testvect[1]*NCtool_orient.axis[1] +
          testvect[2]*NCtool_orient.axis[2]) > 0.0 ) )
   {
      index_offset = 2 * NCtool_data.num_xsect - index_offset;
   }

   index_offset1 = index_offset;
   index_offset2 = (index_offset + NCtool_data.num_xsect) % 
                   (2 * NCtool_data.num_xsect);
}


/*-----NCbuild_tax_swept_volume-----------------------------------------------*/

static void NCbuild_tax_swept_volume(void)

/*
 * ABSTRACT:   Generates a linear swept volume using the active tool and 
 *             location data.
 *
 * HISTORY:   07/23/88   Created.         C. M. Jablonski
 *
 */

{
   IGRdouble   length;
   IGRdouble   ca;
   IGRpoint    path_curve;
   IGRpoint    perp_vect;
   IGRpoint    nvpp;
   IGRpoint    nvpc;
   IGRpoint    nva;
   IGRpoint    temp_pt[6];
   IGRboolean  standard_projection;
   IGRboolean  adjust_pc;

   /* calculate the path curve */
   get_path_curve( path_curve );

   /* set the index offsets */
   set_index_offset( path_curve, perp_vect, &adjust_pc );

   /*
    * Determine by the cosine of the angle between the path curve and the axis
    * whether we can use standard profile projection for this path curve.
    */

   ca = NCtool_orient.axis[0] * path_curve[0] +
        NCtool_orient.axis[1] * path_curve[1] +
        NCtool_orient.axis[2] * path_curve[2];

   length = sqrt((path_curve[0] * path_curve[0]) +
                 (path_curve[1] * path_curve[1]) +
                 (path_curve[2] * path_curve[2]));
   ca /= length;
   if (ca < 0.0)
   {
      ca = -ca;
      tool_moving_down = TRUE;
   }
   else
   {
      tool_moving_down = FALSE;
   }

   standard_projection = ( ca <= NCtool_data.critical_cosine );


   /*
    * Transform the vectors into viewing coordinates.  This is done by taking
    * four temp points, transforming them into viewing coordinates, and then
    * taking the differences between these transformed points as the vectors.
    */

   /* define the points in world coordinates */
   temp_pt[0][0] = NCtoolpath_data.curr_location[0];
   temp_pt[0][1] = NCtoolpath_data.curr_location[1];
   temp_pt[0][2] = NCtoolpath_data.curr_location[2];

   temp_pt[1][0] = temp_pt[0][0] + NCtool_orient.axis[0];
   temp_pt[1][1] = temp_pt[0][1] + NCtool_orient.axis[1];
   temp_pt[1][2] = temp_pt[0][2] + NCtool_orient.axis[2];

   temp_pt[2][0] = temp_pt[0][0] + perp_vect[0];
   temp_pt[2][1] = temp_pt[0][1] + perp_vect[1];
   temp_pt[2][2] = temp_pt[0][2] + perp_vect[2];

   temp_pt[3][0] = NCtoolpath_data.next_location[0];
   temp_pt[3][1] = NCtoolpath_data.next_location[1];
   temp_pt[3][2] = NCtoolpath_data.next_location[2];

   /* transform the points into viewing coordinates. NOTE: No Perspective. */
   transform_points ( FALSE, 4, (IGRdouble *)temp_pt, 0 );

   /* get the axis in viewing coordinates (normalized) */
   nva[0] = temp_pt[1][0] - temp_pt[0][0];
   nva[1] = temp_pt[1][1] - temp_pt[0][1];
   nva[2] = temp_pt[1][2] - temp_pt[0][2];
   NORMALIZE(nva)

   /* get the profile plane in viewing coordinates (normalized) */
   nvpp[0] = temp_pt[2][0] - temp_pt[0][0];
   nvpp[1] = temp_pt[2][1] - temp_pt[0][1];
   nvpp[2] = temp_pt[2][2] - temp_pt[0][2];
   NORMALIZE(nvpp)

   /* get the path curve in viewing coordinates.  DO NOT NORMALIZE (yet). */
   nvpc[0] = temp_pt[3][0] - temp_pt[0][0];
   nvpc[1] = temp_pt[3][1] - temp_pt[0][1];
   nvpc[2] = temp_pt[3][2] - temp_pt[0][2];


   /*
    * Calculate the profile curves.
    */

   if (standard_projection)
   {
      /* generate the profile as the perpendicular cross-section */
      generate_standard_profile();
   }
   else
   {
      /* generate the profile as a subset of points in all cross sections */
      generate_modified_profile ( nvpp, nvpc );
   }


   /*
    * Adjust the normals of the profile points so that there will be a smooth
    * transition between the side facets and the tool sweep.
    */

   if (NCshading.active_shading_style == NCshading.SMOOTH_SHADING)
   {
      adjust_profile_normals( nvpc );
   }

   /*
    * Calculate the projected profile points and normals (viewing coordinates).
    */

   copy_points( 2*num_profile_points,
                2*num_profile_points,
                0,
                NCtool_arrays.profile,
                2*num_profile_points,
                num_profile_points,
                NCtool_arrays.profile );

   translate_points( nvpc,
                     num_profile_points,
                     (IGRpoint *)NCtool_arrays.profile[num_profile_points] );

   /*
    * Translate the xsect matrix to the destination end of the path curve.
    */

   translate_points ( nvpc,
                      2 * NCtool_data.num_curve_points * NCtool_data.num_xsect,
                      NCtool_arrays.xsect );


   /*
    * Normalize the path curve.
    */

   NORMALIZE(nvpc)


   /*
    * Generate and process the facet loops for the sides of the swept volume.
    */

   generate_tax_side_facets();


   /*
    * Redefine NVPC to be perpendicular to and on the opposite side of the axis.
    */

   if (adjust_pc)
   {
      CROSS( nva, nvpp, nvpc )
   }
   else
   {
      nvpc[0] = -nvpc[0];
      nvpc[1] = -nvpc[1];
      nvpc[2] = -nvpc[2];
   }


   /*
    * Complete the swept volume.
    */

   if (standard_projection)
   {
      /* cap the destination end of the swept volume */
      cap_standard_end( nva );

      /* cap the starting end of the swept volume */
      cap_standard_start( nvpc );
   }
   else
   {
      /* cap the destination end of the swept volume */
      cap_modified_end( nva );

      /* cap the starting end of the swept volume */
      cap_modified_start( nvpc );
   }

   /*
    * Restore the normals of the profile points to their original values.
    */

   if (NCshading.active_shading_style == NCshading.SMOOTH_SHADING)
   {
      restore_profile_normals();
   }
}

/*-----find_profile_points--------------------------------------------------------*/

static void find_profile_points( IGRdouble  *orig_lo,
                                 IGRdouble  *orig_hi,
                                 IGRdouble  *end_lo,
                                 IGRdouble  *end_hi,
                                 IGRdouble  *orig_norm_lo,
                                 IGRdouble  *orig_norm_hi,
                                 IGRdouble  *end_norm_lo,
                                 IGRdouble  *end_norm_hi,
                                 IGRdouble  *orig_dp_lo,
                                 IGRdouble  *orig_dp_hi,
                                 IGRdouble  *end_dp_lo,
                                 IGRdouble  *end_dp_hi,
                                 IGRint     *orig_edge1,
                                 IGRint     *orig_edge2,
                                 IGRint     *end_edge1,
                                 IGRint     *end_edge2 )

/*
 * ABSTRACT:   Find_profile_points uses the angle between the given normals and
 *             the path curve of the points to determine whether the edge
 *             crosses either the origin or destination path curve.
 *
 * HISTORY:   10/04/88   Created.         C. M. Jablonski
 *
 */

{
   IGRpoint    lo_delta;
   IGRpoint    hi_delta;
   IGRpoint    orig_delta;
   IGRpoint    end_delta;
   IGRpoint    orig_norm_delta;
   IGRpoint    end_norm_delta;
   IGRdouble   length;
   IGRboolean  orig_prof;
   IGRboolean  end_prof;
   IGRdouble   prof_delta;

   /* calculate the delta vectors */
   lo_delta[0] = end_lo[0] - orig_lo[0];
   lo_delta[1] = end_lo[1] - orig_lo[1];
   lo_delta[2] = end_lo[2] - orig_lo[2];
   hi_delta[0] = end_hi[0] - orig_hi[0];
   hi_delta[1] = end_hi[1] - orig_hi[1];
   hi_delta[2] = end_hi[2] - orig_hi[2];

   NORMALIZE(lo_delta);
   NORMALIZE(hi_delta);

   /* determine the dot products of the origin normals and deltas */
   if (*orig_dp_lo == NO_DOT_PRODUCT)
   {
      *orig_dp_lo = (lo_delta[0] * orig_norm_lo[0]) +
                    (lo_delta[1] * orig_norm_lo[1]) +
                    (lo_delta[2] * orig_norm_lo[2]);
   }

   if (*orig_dp_hi == NO_DOT_PRODUCT)
   {
      *orig_dp_hi = (hi_delta[0] * orig_norm_hi[0]) +
                    (hi_delta[1] * orig_norm_hi[1]) +
                    (hi_delta[2] * orig_norm_hi[2]);
   }

   /* determine the dot products of the end normals and deltas */
   if (*end_dp_lo == NO_DOT_PRODUCT)
   {
      *end_dp_lo = (lo_delta[0] * end_norm_lo[0]) +
                   (lo_delta[1] * end_norm_lo[1]) +
                   (lo_delta[2] * end_norm_lo[2]);
   }

   if (*end_dp_hi == NO_DOT_PRODUCT)
   {
      *end_dp_hi = (hi_delta[0] * end_norm_hi[0]) +
                   (hi_delta[1] * end_norm_hi[1]) +
                   (hi_delta[2] * end_norm_hi[2]);
   }

   /* determine the signs of the angles between the vertex normals and  */
   /* the average delta vector                                          */

   orig_prof = (((*orig_dp_lo < 0.0) && (*orig_dp_hi >= 0.0)) ||
                ((*orig_dp_lo >= 0.0) && (*orig_dp_hi < 0.0)));
   end_prof = (((*end_dp_lo < 0.0) && (*end_dp_hi >= 0.0)) ||
               ((*end_dp_lo >= 0.0) && (*end_dp_hi < 0.0)));

#if COUNT_EDGES
{
   if (orig_prof && end_prof)
   {
      if (same_xsect)
      {
         intra_xsect[intra_ct++] = 'X';
         intra_xsect[intra_ct++] = '+';
      }
      else
      {
         inter_xsect[inter_ct++] = ' ';
         inter_xsect[inter_ct++] = 'X';
      }
   }
   else if (orig_prof)
   {
      if (same_xsect)
      {
         intra_xsect[intra_ct++] = '\\';
         intra_xsect[intra_ct++] = '+';
      }
      else
      {
         inter_xsect[inter_ct++] = ' ';
         inter_xsect[inter_ct++] = '\\';
      }
   }
   else if (end_prof)
   {
      if (same_xsect)
      {
         intra_xsect[intra_ct++] = '/';
         intra_xsect[intra_ct++] = '+';
      }
      else
      {
         inter_xsect[inter_ct++] = ' ';
         inter_xsect[inter_ct++] = '/';
      }
   }
   else
   {
      if (same_xsect)
      {
         intra_xsect[intra_ct++] = '-';
         intra_xsect[intra_ct++] = '+';
      }
      else
      {
         inter_xsect[inter_ct++] = ' ';
         inter_xsect[inter_ct++] = '|';
      }
   }
}
#endif

   /* find any profile points */
   if (orig_prof || end_prof)
   {
      orig_delta[0] = orig_hi[0] - orig_lo[0];
      orig_delta[1] = orig_hi[1] - orig_lo[1];
      orig_delta[2] = orig_hi[2] - orig_lo[2];
      end_delta[0] = end_hi[0] - end_lo[0];
      end_delta[1] = end_hi[1] - end_lo[1];
      end_delta[2] = end_hi[2] - end_lo[2];
      orig_norm_delta[0] = orig_norm_hi[0] - orig_norm_lo[0];
      orig_norm_delta[1] = orig_norm_hi[1] - orig_norm_lo[1];
      orig_norm_delta[2] = orig_norm_hi[2] - orig_norm_lo[2];
      end_norm_delta[0] = end_norm_hi[0] - end_norm_lo[0];
      end_norm_delta[1] = end_norm_hi[1] - end_norm_lo[1];
      end_norm_delta[2] = end_norm_hi[2] - end_norm_lo[2];

      /* save any profile point on the origin segment */
      if (orig_prof)
      {
         /* find the profile delta along the segment */
         prof_delta = ABS(*orig_dp_lo) / (ABS(*orig_dp_lo) + ABS(*orig_dp_hi));

         /* save the profile point */
         NCtool_arrays.orig_start_pt[num_fax_orig_profile_points][0] =
                orig_lo[0] + orig_delta[0] * prof_delta;
         NCtool_arrays.orig_start_pt[num_fax_orig_profile_points][1] =
                orig_lo[1] + orig_delta[1] * prof_delta;
         NCtool_arrays.orig_start_pt[num_fax_orig_profile_points][2] =
                orig_lo[2] + orig_delta[2] * prof_delta;

         /* save the profile point's normal */
         NCtool_arrays.orig_start_norm[num_fax_orig_profile_points][0] =
                orig_norm_lo[0] + orig_norm_delta[0] * prof_delta;
         NCtool_arrays.orig_start_norm[num_fax_orig_profile_points][1] =
                orig_norm_lo[1] + orig_norm_delta[1] * prof_delta;
         NCtool_arrays.orig_start_norm[num_fax_orig_profile_points][2] =
                orig_norm_lo[2] + orig_norm_delta[2] * prof_delta;
         NORMALIZE(NCtool_arrays.orig_start_norm[num_fax_orig_profile_points]);

         /* save the projected profile point */
         NCtool_arrays.orig_end_pt[num_fax_orig_profile_points][0] =
                end_lo[0] + end_delta[0] * prof_delta;
         NCtool_arrays.orig_end_pt[num_fax_orig_profile_points][1] =
                end_lo[1] + end_delta[1] * prof_delta;
         NCtool_arrays.orig_end_pt[num_fax_orig_profile_points][2] =
                end_lo[2] + end_delta[2] * prof_delta;

         /* save the projected profile point's normal */
         NCtool_arrays.orig_end_norm[num_fax_orig_profile_points][0] =
                end_norm_lo[0] + end_norm_delta[0] * prof_delta;
         NCtool_arrays.orig_end_norm[num_fax_orig_profile_points][1] =
                end_norm_lo[1] + end_norm_delta[1] * prof_delta;
         NCtool_arrays.orig_end_norm[num_fax_orig_profile_points][2] =
                end_norm_lo[2] + end_norm_delta[2] * prof_delta;
         NORMALIZE(NCtool_arrays.orig_end_norm[num_fax_orig_profile_points]);

/***
fprintf(stderr, "PROJECTED PROFILE POINT[%d] = %f, %f, %f\n",
num_fax_orig_profile_points,
NCtool_arrays.orig_end_pt[num_fax_orig_profile_points][0],
NCtool_arrays.orig_end_pt[num_fax_orig_profile_points][1],
NCtool_arrays.orig_end_pt[num_fax_orig_profile_points][2]);
fprintf(stderr, "PROJECTED PROFILE NORMAL[%d] = %f, %f, %f\n",
num_fax_orig_profile_points,
NCtool_arrays.orig_end_norm[num_fax_orig_profile_points][0],
NCtool_arrays.orig_end_norm[num_fax_orig_profile_points][1],
NCtool_arrays.orig_end_norm[num_fax_orig_profile_points][2]);
***/

         /* mark the edges */
         *orig_edge1 = *orig_edge2 = num_fax_orig_profile_points;
         num_fax_orig_profile_points++;
      }

      /* save any profile point on the dest segment */
      if (end_prof)
      {
         /* find the profile delta along the segment */
         prof_delta = ABS(*end_dp_lo) / (ABS(*end_dp_lo) + ABS(*end_dp_hi));

         /* save the projected profile point */
         NCtool_arrays.dest_start_pt[num_fax_dest_profile_points][0] =
                        orig_lo[0] + orig_delta[0] * prof_delta;
         NCtool_arrays.dest_start_pt[num_fax_dest_profile_points][1] =
                        orig_lo[1] + orig_delta[1] * prof_delta;
         NCtool_arrays.dest_start_pt[num_fax_dest_profile_points][2] =
                        orig_lo[2] + orig_delta[2] * prof_delta;

         /* save the projected profile point's normal */
         NCtool_arrays.dest_start_norm[num_fax_dest_profile_points][0] =
                        orig_norm_lo[0] + orig_norm_delta[0] * prof_delta;
         NCtool_arrays.dest_start_norm[num_fax_dest_profile_points][1] =
                        orig_norm_lo[1] + orig_norm_delta[1] * prof_delta;
         NCtool_arrays.dest_start_norm[num_fax_dest_profile_points][2] =
                        orig_norm_lo[2] + orig_norm_delta[2] * prof_delta;
         NORMALIZE(NCtool_arrays.dest_start_norm[num_fax_dest_profile_points]);

         /* save the profile point */
         NCtool_arrays.dest_end_pt[num_fax_dest_profile_points][0] =
                        end_lo[0] + end_delta[0] * prof_delta;
         NCtool_arrays.dest_end_pt[num_fax_dest_profile_points][1] =
                        end_lo[1] + end_delta[1] * prof_delta;
         NCtool_arrays.dest_end_pt[num_fax_dest_profile_points][2] =
                        end_lo[2] + end_delta[2] * prof_delta;

         /* save the profile point's normal */
         NCtool_arrays.dest_end_norm[num_fax_dest_profile_points][0] =
                        end_norm_lo[0] + end_norm_delta[0] * prof_delta;
         NCtool_arrays.dest_end_norm[num_fax_dest_profile_points][1] =
                        end_norm_lo[1] + end_norm_delta[1] * prof_delta;
         NCtool_arrays.dest_end_norm[num_fax_dest_profile_points][2] =
                        end_norm_lo[2] + end_norm_delta[2] * prof_delta;
         NORMALIZE(NCtool_arrays.dest_end_norm[num_fax_dest_profile_points]);

         /* mark the edges */
         *end_edge1 = *end_edge2 = num_fax_dest_profile_points;
         num_fax_dest_profile_points++;
      }
   }
}


/*-----generate_toleranced_facet--------------------------------------------------------*/

static void generate_toleranced_facet( IGRdouble *orig_lo,
                                       IGRdouble *orig_hi,
                                       IGRdouble *end_lo,
                                       IGRdouble *end_hi,
                                       IGRdouble *orig_norm_lo,
                                       IGRdouble *orig_norm_hi,
                                       IGRdouble *end_norm_lo,
                                       IGRdouble *end_norm_hi )

/*
 * ABSTRACT:  Generate_toleranced_facet creates a facet between the given
 *            starting and ending line segments.  The number of sub_facets
 *            generated is toleranced to the angle between the line segments.
 *
 * HISTORY:   10/04/88   Created.         C. M. Jablonski
 *
 */

{
   IGRpoint    start_lo;
   IGRpoint    start_hi;
   IGRpoint    stop_lo;
   IGRpoint    stop_hi;
   IGRpoint    lo_vect;
   IGRpoint    hi_vect;
   IGRpoint    orig_vect;
   IGRpoint    end_vect;
   IGRpoint    orig_x;
   IGRpoint    end_x;
   IGRpoint    orig_norm_avg;
   IGRpoint    end_norm_avg;
   IGRpoint    lv;
   IGRpoint    hv;
   IGRpoint    tmp;
   IGRpoint    start_normlo;
   IGRpoint    start_normhi;
   IGRpoint    stop_normlo;
   IGRpoint    stop_normhi;
   IGRpoint    lo_norm_vect;
   IGRpoint    hi_norm_vect;
   IGRpoint    adj_orig_normlo;
   IGRpoint    adj_orig_normhi;
   IGRpoint    adj_end_normlo;
   IGRpoint    adj_end_normhi;
   IGRpoint    edge1;
   IGRpoint    edge2;
   IGRpoint    norm;
   IGRpoint    perp;
   IGRdouble   angle;
   IGRdouble   length;
   IGRdouble   findex;
   IGRdouble   facet_tol;
   IGRdouble   cosine;
   IGRboolean  orig_length;
   IGRboolean  end_length;
   IGRboolean  lo_length;
   IGRboolean  hi_length;
   IGRint      index;
   IGRint      num_sub_facets;

   /* calculate the facet vectors */
   lv[0] = lo_vect[0] = end_lo[0] - orig_lo[0];
   lv[1] = lo_vect[1] = end_lo[1] - orig_lo[1];
   lv[2] = lo_vect[2] = end_lo[2] - orig_lo[2];
   NORMALIZE(lv);
   lo_length = (length > ZERO_TOL);

   hv[0] = hi_vect[0] = end_hi[0] - orig_hi[0];
   hv[1] = hi_vect[1] = end_hi[1] - orig_hi[1];
   hv[2] = hi_vect[2] = end_hi[2] - orig_hi[2];
   NORMALIZE(hv);
   hi_length = (length > ZERO_TOL);

   orig_vect[0] = orig_hi[0] - orig_lo[0];
   orig_vect[1] = orig_hi[1] - orig_lo[1];
   orig_vect[2] = orig_hi[2] - orig_lo[2];
   NORMALIZE(orig_vect);
   orig_length = (length > ZERO_TOL);

   end_vect[0] = end_hi[0] - end_lo[0];
   end_vect[1] = end_hi[1] - end_lo[1];
   end_vect[2] = end_hi[2] - end_lo[2];
   NORMALIZE(end_vect);
   end_length = (length > ZERO_TOL);

   if ((lo_length || hi_length) && (orig_length || end_length))
   {
      CROSS(orig_vect, lv, tmp);
      CROSS(lv, tmp, orig_x);
      CROSS(end_vect, lv, tmp);
      CROSS(lv, tmp, end_x);
      if ((orig_length > ZERO_TOL) &&
          (end_length > ZERO_TOL) &&
          (ABS(cosine = ((orig_x[0] * end_x[0]) +
               (orig_x[1] * end_x[1]) +
               (orig_x[2] * end_x[2]))) < 1.0))
      {
         angle = acos(cosine);

         /* use the twist angle to determine the number of sub-facets */

         findex = (IGRint)((2.0 * angle / PI) * NCtool_data.num_xsect);
         facet_tol = (IGRdouble)(num_sub_facets = (MAX((findex + 1), 1)));
      }
      else
      {
/***
fprintf(stderr, "\nBAD COSINE\n");
fprintf(stderr, "ORIG_LO = %f, %f, %f\n", orig_lo[0], orig_lo[1], orig_lo[2]);
fprintf(stderr, "ORIG_HI = %f, %f, %f\n", orig_hi[0], orig_hi[1], orig_hi[2]);
fprintf(stderr, "ORIG_VECT = %f, %f, %f\n", orig_vect[0], orig_vect[1], orig_vect[2]);
fprintf(stderr, "END_LO = %f, %f, %f\n", end_lo[0], end_lo[1], end_lo[2]);
fprintf(stderr, "END_HI = %f, %f, %f\n", end_hi[0], end_hi[1], end_hi[2]);
fprintf(stderr, "END_VECT = %f, %f, %f\n", end_vect[0], end_vect[1], end_vect[2]);
***/
         facet_tol = (IGRdouble)(num_sub_facets = 1);
      }

      /* calculate the adjusted normals */
      if (lo_length)
      {
         CROSS(lo_vect, orig_norm_lo, perp);
         CROSS(perp, lo_vect, adj_orig_normlo);
         NORMALIZE(adj_orig_normlo);

         CROSS(lo_vect, end_norm_lo, perp);
         CROSS(perp, lo_vect, adj_end_normlo);
         NORMALIZE(adj_end_normlo);
      }
      else
      {
         adj_orig_normlo[0] = orig_norm_lo[0];
         adj_orig_normlo[1] = orig_norm_lo[1];
         adj_orig_normlo[2] = orig_norm_lo[2];

         adj_end_normlo[0] = end_norm_lo[0];
         adj_end_normlo[1] = end_norm_lo[1];
         adj_end_normlo[2] = end_norm_lo[2];
      }

      if (hi_length)
      {
         CROSS(hi_vect, orig_norm_hi, perp);
         CROSS(perp, hi_vect, adj_orig_normhi);
         NORMALIZE(adj_orig_normhi);

         CROSS(hi_vect, end_norm_hi, perp);
         CROSS(perp, hi_vect, adj_end_normhi);
         NORMALIZE(adj_end_normhi);
      }
      else
      {
         adj_orig_normhi[0] = orig_norm_hi[0];
         adj_orig_normhi[1] = orig_norm_hi[1];
         adj_orig_normhi[2] = orig_norm_hi[2];

         adj_end_normhi[0] = end_norm_hi[0];
         adj_end_normhi[1] = end_norm_hi[1];
         adj_end_normhi[2] = end_norm_hi[2];
      }


      /* determine the normal interpolation vectors */
      lo_norm_vect[0] = adj_end_normlo[0] - adj_orig_normlo[0];
      lo_norm_vect[1] = adj_end_normlo[1] - adj_orig_normlo[1];
      lo_norm_vect[2] = adj_end_normlo[2] - adj_orig_normlo[2];
      hi_norm_vect[0] = adj_end_normhi[0] - adj_orig_normhi[0];
      hi_norm_vect[1] = adj_end_normhi[1] - adj_orig_normhi[1];
      hi_norm_vect[2] = adj_end_normhi[2] - adj_orig_normhi[2];

      /* determine the average origin and destination vertex normals */
      AVERAGE( adj_orig_normlo, adj_orig_normhi, orig_norm_avg );
      AVERAGE( adj_end_normlo, adj_end_normhi, end_norm_avg );

      /* create the sub-facets */
      for (index = 0; index < num_sub_facets; index++)
      {
/***
HSset_dexel_color(TRUE, ((index % 2) + 3), &dummy);
***/
         findex = (IGRdouble)index;
         start_lo[0] = orig_lo[0] + ((findex / facet_tol) * lo_vect[0]);
         start_lo[1] = orig_lo[1] + ((findex / facet_tol) * lo_vect[1]);
         start_lo[2] = orig_lo[2] + ((findex / facet_tol) * lo_vect[2]);

         stop_lo[0] = orig_lo[0] + (((findex + 1.0) / facet_tol) * lo_vect[0]);
         stop_lo[1] = orig_lo[1] + (((findex + 1.0) / facet_tol) * lo_vect[1]);
         stop_lo[2] = orig_lo[2] + (((findex + 1.0) / facet_tol) * lo_vect[2]);

         start_hi[0] = orig_hi[0] + ((findex / facet_tol) * hi_vect[0]);
         start_hi[1] = orig_hi[1] + ((findex / facet_tol) * hi_vect[1]);
         start_hi[2] = orig_hi[2] + ((findex / facet_tol) * hi_vect[2]);

         stop_hi[0] = orig_hi[0] + (((findex + 1.0) / facet_tol) * hi_vect[0]);
         stop_hi[1] = orig_hi[1] + (((findex + 1.0) / facet_tol) * hi_vect[1]);
         stop_hi[2] = orig_hi[2] + (((findex + 1.0) / facet_tol) * hi_vect[2]);

         start_normlo[0] = adj_orig_normlo[0] + 
                                      ((findex / facet_tol) * lo_norm_vect[0]);
         start_normlo[1] = adj_orig_normlo[1] +
                                      ((findex / facet_tol) * lo_norm_vect[1]);
         start_normlo[2] = adj_orig_normlo[2] +
                                      ((findex / facet_tol) * lo_norm_vect[2]);

         stop_normlo[0] = adj_orig_normlo[0] +
                              (((findex + 1.0) / facet_tol) * lo_norm_vect[0]);
         stop_normlo[1] = adj_orig_normlo[1] +
                              (((findex + 1.0) / facet_tol) * lo_norm_vect[1]);
         stop_normlo[2] = adj_orig_normlo[2] +
                              (((findex + 1.0) / facet_tol) * lo_norm_vect[2]);

         start_normhi[0] = adj_orig_normhi[0] +
                                      ((findex / facet_tol) * hi_norm_vect[0]);
         start_normhi[1] = adj_orig_normhi[1] +
                                      ((findex / facet_tol) * hi_norm_vect[1]);
         start_normhi[2] = adj_orig_normhi[2] +
                                      ((findex / facet_tol) * hi_norm_vect[2]);

         stop_normhi[0] = adj_orig_normhi[0] +
                              (((findex + 1.0) / facet_tol) * hi_norm_vect[0]);
         stop_normhi[1] = adj_orig_normhi[1] +
                              (((findex + 1.0) / facet_tol) * hi_norm_vect[1]);
         stop_normhi[2] = adj_orig_normhi[2] +
                              (((findex + 1.0) / facet_tol) * hi_norm_vect[2]);

         /* cross two surface vectors to find the facet normal */
         edge1[0] = start_lo[0] - stop_hi[0];
         edge1[1] = start_lo[1] - stop_hi[1];
         edge1[2] = start_lo[2] - stop_hi[2];

         edge2[0] = stop_lo[0] - start_hi[0];
         edge2[1] = stop_lo[1] - start_hi[1];
         edge2[2] = stop_lo[2] - start_hi[2];

/***
fprintf(stderr, "START_LO=%f, %f, %f\n", start_lo[0], start_lo[1], start_lo[2]);
fprintf(stderr, "START_HI=%f, %f, %f\n", start_hi[0], start_hi[1], start_hi[2]);
fprintf(stderr, "STOP_LO=%f, %f, %f\n", stop_lo[0], stop_lo[1], stop_lo[2]);
fprintf(stderr, "STOP_HI=%f, %f, %f\n", stop_hi[0], stop_hi[1], stop_hi[2]);
fprintf(stderr, "EDGE1=%f, %f, %f\n", edge1[0], edge1[1], edge1[2]);
fprintf(stderr, "EDGE2=%f, %f, %f\n", edge2[0], edge2[1], edge2[2]);
***/

         CROSS(edge2, edge1, norm)
         if ((ABS(norm[0]) > ZERO_TOL) ||
             (ABS(norm[1]) > ZERO_TOL) ||
             (ABS(norm[2]) > ZERO_TOL))
         {
            NORMALIZE( norm )

            if (ABS(norm[2]) > ZERO_TOL)
            {
               /* determine the proper facet normal direction */
               if (((findex < (facet_tol / 2.0)) &&
                    (((norm[0] * orig_norm_avg[0]) +
                      (norm[1] * orig_norm_avg[1]) +
                      (norm[2] * orig_norm_avg[2])) < 0.0)) ||
                   ((findex >= (facet_tol / 2.0)) &&
                    (((norm[0] * end_norm_avg[0]) +
                      (norm[1] * end_norm_avg[1]) +
                      (norm[2] * end_norm_avg[2])) < 0.0)))
               {
                  norm[0] *= -1.0;
                  norm[1] *= -1.0;
                  norm[2] *= -1.0;
               }
/***
fprintf(stderr, "NORMAL(%d:%d)=%f, %f, %f\n", index, num_sub_facets, norm[0], norm[1], norm[2]);
***/

               /* set the facet normal */
               HSset_facet_normal( norm[0], norm[1], norm[2] );

               /* create the facet loop */
               HSadd_dexel_vertex( start_hi[0],
                                   start_hi[1],
                                   start_hi[2],
                                   1.0,
                                   start_normhi[0],
                                   start_normhi[1],
                                   start_normhi[2] );

               HSadd_dexel_vertex( start_lo[0],
                                   start_lo[1],
                                   start_lo[2],
                                   1.0,
                                   start_normlo[0],
                                   start_normlo[1],
                                   start_normlo[2] );

               HSadd_dexel_vertex( stop_lo[0],
                                   stop_lo[1],
                                   stop_lo[2],
                                   1.0,
                                   stop_normlo[0],
                                   stop_normlo[1],
                                   stop_normlo[2] );

               HSadd_dexel_vertex( stop_hi[0],
                                   stop_hi[1],
                                   stop_hi[2],
                                   1.0,
                                   stop_normhi[0],
                                   stop_normhi[1],
                                   stop_normhi[2] );

               /* process the facet loop */
               clip_and_shade();
            }
/***
else
{
   fprintf(stderr, "SKIPPING NORMAL=%f, %f, %f\n", norm[0], norm[1], norm[2]);
}
***/
         }
/***
else
{
   fprintf(stderr, "DEGENERATE NORMAL=%f, %f, %f\n", norm[0], norm[1], norm[2]);
   fprintf(stderr, "\tEDGE1=%f, %f, %f\n", edge1[0], edge1[1], edge1[2]);
   fprintf(stderr, "\tEDGE2=%f, %f, %f\n", edge2[0], edge2[1], edge2[2]);
}
***/
      }
   }
}


/*-----NCtile_fax_tool--------------------------------------------------------*/

static void NCtile_fax_tool( IGRdouble  *first_orient,
                             IGRdouble  *second_orient,
                             IGRpoint   *start_profile_point_array,
                             IGRpoint   *start_profile_normal_array,
                             IGRpoint   *end_profile_point_array,
                             IGRpoint   *end_profile_normal_array,
                             IGRint     *edge_matrix,
                             IGRdouble  *dot_product_matrix )

/*
 * ABSTRACT:   Sweeps out the tool halves at the start and end of the five-axis
 *      swept volume.
 *
 * HISTORY:   10/26/89   Created.         C. M. Jablonski
 *
 */

{
   IGRint      edge1;
   IGRint      vertex_cnt;
   IGRint      xindex;
   IGRint      nxindex;
   IGRint      pindex;
   IGRint      this_xsect;
   IGRint      next_xsect;
   IGRint      dest_xsect;
   IGRint      next_dest_xsect;
   IGRint      curr_lo;
   IGRint      curr_hi;
   IGRint      next_lo;
   IGRint      next_hi;
   IGRint      dest_lo;
   IGRint      dest_hi;
   IGRint      dest_next_lo;
   IGRint      dest_next_hi;


   for (xindex = 0; xindex < (2 * NCtool_data.num_xsect); xindex++)
   {
      /* this_xsect will point to the beginning of each cross-section */
      this_xsect = xindex * NCtool_data.num_curve_points;

      /* next_xsect will point to the beginning of the next cross-section */
      nxindex = (xindex + 1) % (2 * NCtool_data.num_xsect);
      next_xsect = nxindex * NCtool_data.num_curve_points;

      /* dest_xsect will point to the beginning of the destination */
      /* cross-section                                             */
      nxindex = xindex + fax_offset_diff + (2 * NCtool_data.num_xsect);
      nxindex %= (2 * NCtool_data.num_xsect);
      dest_xsect = nxindex * NCtool_data.num_curve_points;

      /* next_dest_xsect will point to the beginning of the next destination */
      /* cross-section                                                       */
      nxindex = xindex + fax_offset_diff + (2 * NCtool_data.num_xsect) + 1;
      nxindex %= (2 * NCtool_data.num_xsect);
      next_dest_xsect = nxindex * NCtool_data.num_curve_points;

      for (pindex = 1; pindex < NCtool_data.num_curve_points; pindex++)
      {
         curr_hi = this_xsect + pindex;
         curr_lo = curr_hi - 1;
         next_hi = next_xsect + pindex;
         next_lo = next_hi - 1;

         dest_hi = dest_xsect + pindex;
         dest_lo = dest_hi - 1;
         dest_next_hi = next_dest_xsect + pindex;
         dest_next_lo = dest_next_hi - 1;

         edge1 = ((((xindex + 1) % (2 * NCtool_data.num_xsect)) *
                    (NCtool_data.num_curve_points - 1)) + pindex - 1) * 4;


         /*
          * Generate the facet at the starting end of the swept volume.
          */

         vertex_cnt = 0;
         HSset_facet_normal( NCtool_arrays.tfm[curr_hi][0],
                             NCtool_arrays.tfm[curr_hi][1],
                             NCtool_arrays.tfm[curr_hi][2] );

         /* lower left corner point */
         if (dot_product_matrix[curr_lo] <= 0.0)
         {
            HSadd_dexel_vertex( NCtool_arrays.txm[curr_lo][0],
                                NCtool_arrays.txm[curr_lo][1],
                                NCtool_arrays.txm[curr_lo][2],
                                1.0,
                                NCtool_arrays.tvm[curr_lo][0],
                                NCtool_arrays.tvm[curr_lo][1],
                                NCtool_arrays.tvm[curr_lo][2] );
            vertex_cnt++;
         }

         /* left edge point */
         if (edge_matrix[edge1] != NO_PROFILE_POINT)
         {
            HSadd_dexel_vertex(
                            start_profile_point_array[edge_matrix[edge1]][0],
                            start_profile_point_array[edge_matrix[edge1]][1],
                            start_profile_point_array[edge_matrix[edge1]][2],
                            1.0,
                            start_profile_normal_array[edge_matrix[edge1]][0],
                            start_profile_normal_array[edge_matrix[edge1]][1],
                            start_profile_normal_array[edge_matrix[edge1]][2] );
            vertex_cnt++;
         }

         /* upper left corner point */
         if (dot_product_matrix[curr_hi] <= 0.0)
         {
            HSadd_dexel_vertex( NCtool_arrays.txm[curr_hi][0],
                                NCtool_arrays.txm[curr_hi][1],
                                NCtool_arrays.txm[curr_hi][2],
                                1.0,
                                NCtool_arrays.tvm[curr_hi][0],
                                NCtool_arrays.tvm[curr_hi][1],
                                NCtool_arrays.tvm[curr_hi][2] );
            vertex_cnt++;
         }

         /* top edge point */
         if (edge_matrix[edge1 + 1] != NO_PROFILE_POINT)
         {
            HSadd_dexel_vertex(
                        start_profile_point_array[edge_matrix[edge1 + 1]][0],
                        start_profile_point_array[edge_matrix[edge1 + 1]][1],
                        start_profile_point_array[edge_matrix[edge1 + 1]][2],
                        1.0,
                        start_profile_normal_array[edge_matrix[edge1 + 1]][0],
                        start_profile_normal_array[edge_matrix[edge1 + 1]][1],
                        start_profile_normal_array[edge_matrix[edge1 + 1]][2] );
            vertex_cnt++;
         }

         /* upper right corner point */
         if (dot_product_matrix[next_hi] <= 0.0)
         {
            HSadd_dexel_vertex( NCtool_arrays.txm[next_hi][0],
                                NCtool_arrays.txm[next_hi][1],
                                NCtool_arrays.txm[next_hi][2],
                                1.0,
                                NCtool_arrays.tvm[next_hi][0],
                                NCtool_arrays.tvm[next_hi][1],
                                NCtool_arrays.tvm[next_hi][2] );
            vertex_cnt++;
         }

         /* right edge point */
         if (edge_matrix[edge1 + 2] != NO_PROFILE_POINT)
         {
            HSadd_dexel_vertex(
                        start_profile_point_array[edge_matrix[edge1 + 2]][0],
                        start_profile_point_array[edge_matrix[edge1 + 2]][1],
                        start_profile_point_array[edge_matrix[edge1 + 2]][2],
                        1.0,
                        start_profile_normal_array[edge_matrix[edge1 + 2]][0],
                        start_profile_normal_array[edge_matrix[edge1 + 2]][1],
                        start_profile_normal_array[edge_matrix[edge1 + 2]][2] );
            vertex_cnt++;
         }

         /* lower right corner point */
         if (dot_product_matrix[next_lo] <= 0.0)
         {
            HSadd_dexel_vertex( NCtool_arrays.txm[next_lo][0],
                                NCtool_arrays.txm[next_lo][1],
                                NCtool_arrays.txm[next_lo][2],
                                1.0,
                                NCtool_arrays.tvm[next_lo][0],
                                NCtool_arrays.tvm[next_lo][1],
                                NCtool_arrays.tvm[next_lo][2] );
            vertex_cnt++;
         }

         /* bottom edge point */
         if (edge_matrix[edge1 + 3] != NO_PROFILE_POINT)
         {
            HSadd_dexel_vertex(
                        start_profile_point_array[edge_matrix[edge1 + 3]][0],
                        start_profile_point_array[edge_matrix[edge1 + 3]][1],
                        start_profile_point_array[edge_matrix[edge1 + 3]][2],
                        1.0,
                        start_profile_normal_array[edge_matrix[edge1 + 3]][0],
                        start_profile_normal_array[edge_matrix[edge1 + 3]][1],
                        start_profile_normal_array[edge_matrix[edge1 + 3]][2] );
            vertex_cnt++;
         }

         /* process the origin start facet loop */
         if (vertex_cnt) clip_and_shade();

         /*
          * Generate the facet for the end of the swept volume.
          */

         vertex_cnt = 0;
         HSset_facet_normal( NCtool_arrays.fnorm[dest_hi][0],
                             NCtool_arrays.fnorm[dest_hi][1],
                             NCtool_arrays.fnorm[dest_hi][2] );

         /* lower left corner point */
         if (dot_product_matrix[curr_lo] >= 0.0)
         {
            HSadd_dexel_vertex( NCtool_arrays.xsect[dest_lo][0],
                                NCtool_arrays.xsect[dest_lo][1],
                                NCtool_arrays.xsect[dest_lo][2],
                                1.0,
                                NCtool_arrays.vnorm[dest_lo][0],
                                NCtool_arrays.vnorm[dest_lo][1],
                                NCtool_arrays.vnorm[dest_lo][2] );
            vertex_cnt++;
         }

         /* left edge point */
         if (edge_matrix[edge1] != NO_PROFILE_POINT)
         {
            HSadd_dexel_vertex(end_profile_point_array[edge_matrix[edge1]][0],
                               end_profile_point_array[edge_matrix[edge1]][1],
                               end_profile_point_array[edge_matrix[edge1]][2],
                               1.0,
                               end_profile_normal_array[edge_matrix[edge1]][0],
                               end_profile_normal_array[edge_matrix[edge1]][1],
                               end_profile_normal_array[edge_matrix[edge1]][2]);
            vertex_cnt++;
         }

         /* upper left corner point */
         if (dot_product_matrix[curr_hi] >= 0.0)
         {
            HSadd_dexel_vertex( NCtool_arrays.xsect[dest_hi][0],
                                NCtool_arrays.xsect[dest_hi][1],
                                NCtool_arrays.xsect[dest_hi][2],
                                1.0,
                                NCtool_arrays.vnorm[dest_hi][0],
                                NCtool_arrays.vnorm[dest_hi][1],
                                NCtool_arrays.vnorm[dest_hi][2] );
            vertex_cnt++;
         }

         /* top edge point */
         if (edge_matrix[edge1 + 1] != NO_PROFILE_POINT)
         {
            HSadd_dexel_vertex(
                          end_profile_point_array[edge_matrix[edge1 + 1]][0],
                          end_profile_point_array[edge_matrix[edge1 + 1]][1],
                          end_profile_point_array[edge_matrix[edge1 + 1]][2],
                          1.0,
                          end_profile_normal_array[edge_matrix[edge1 + 1]][0],
                          end_profile_normal_array[edge_matrix[edge1 + 1]][1],
                          end_profile_normal_array[edge_matrix[edge1 + 1]][2] );
            vertex_cnt++;
         }

         /* upper right corner point */
         if (dot_product_matrix[next_hi] >= 0.0)
         {
            HSadd_dexel_vertex( NCtool_arrays.xsect[dest_next_hi][0],
                                NCtool_arrays.xsect[dest_next_hi][1],
                                NCtool_arrays.xsect[dest_next_hi][2],
                                1.0,
                                NCtool_arrays.vnorm[dest_next_hi][0],
                                NCtool_arrays.vnorm[dest_next_hi][1],
                                NCtool_arrays.vnorm[dest_next_hi][2] );
            vertex_cnt++;
         }

         /* right edge point */
         if (edge_matrix[edge1 + 2] != NO_PROFILE_POINT)
         {
            HSadd_dexel_vertex(
                          end_profile_point_array[edge_matrix[edge1 + 2]][0],
                          end_profile_point_array[edge_matrix[edge1 + 2]][1],
                          end_profile_point_array[edge_matrix[edge1 + 2]][2],
                          1.0,
                          end_profile_normal_array[edge_matrix[edge1 + 2]][0],
                          end_profile_normal_array[edge_matrix[edge1 + 2]][1],
                          end_profile_normal_array[edge_matrix[edge1 + 2]][2] );
            vertex_cnt++;
         }

         /* lower right corner point */
         if (dot_product_matrix[next_lo] >= 0.0)
         {
            HSadd_dexel_vertex( NCtool_arrays.xsect[dest_next_lo][0],
                                NCtool_arrays.xsect[dest_next_lo][1],
                                NCtool_arrays.xsect[dest_next_lo][2],
                                1.0,
                                NCtool_arrays.vnorm[dest_next_lo][0],
                                NCtool_arrays.vnorm[dest_next_lo][1],
                                NCtool_arrays.vnorm[dest_next_lo][2] );
            vertex_cnt++;
         }

         /* bottom edge point */
         if (edge_matrix[edge1 + 3] != NO_PROFILE_POINT)
         {
            HSadd_dexel_vertex(
                          end_profile_point_array[edge_matrix[edge1 + 3]][0],
                          end_profile_point_array[edge_matrix[edge1 + 3]][1],
                          end_profile_point_array[edge_matrix[edge1 + 3]][2],
                          1.0,
                          end_profile_normal_array[edge_matrix[edge1 + 3]][0],
                          end_profile_normal_array[edge_matrix[edge1 + 3]][1],
                          end_profile_normal_array[edge_matrix[edge1 + 3]][2] );
            vertex_cnt++;
         }

         /* process the origin end facet loop */
         if (vertex_cnt) clip_and_shade();
      }
   }


   /*
    * If necessary, cap the top of the tool.
    */

   if (NCtool_data.open_ended)
   {
      /* set the shading style */
      HSset_dexel_shading_style( NCshading.CONSTANT_SHADING );

      /* cap the top at the start */
      if (ABS(first_orient[2]) > ZERO_TOL)
      {
         HSset_facet_normal(first_orient[0], first_orient[1], first_orient[2]);

         /* create the facet loop */
         vertex_cnt = 0;
         for ( xindex = 1; xindex <= (2 * NCtool_data.num_xsect); xindex++ )
         {
            pindex = (xindex * NCtool_data.num_curve_points) - 1;
            edge1 = (4 * ((xindex * (NCtool_data.num_curve_points - 1)) - 1)) +
                    1;
            if (edge_matrix[edge1] != NO_PROFILE_POINT)
            {
               HSadd_dexel_vertex(
                             start_profile_point_array[edge_matrix[edge1]][0],
                             start_profile_point_array[edge_matrix[edge1]][1],
                             start_profile_point_array[edge_matrix[edge1]][2],
                             1.0);
               vertex_cnt++;
            }

            if (dot_product_matrix[pindex] <= 0.0)
            {
               HSadd_dexel_vertex( NCtool_arrays.txm[pindex][0],
                                   NCtool_arrays.txm[pindex][1],
                                   NCtool_arrays.txm[pindex][2],
                                   1.0 );
               vertex_cnt++;
            }
         }

         /* process the facet loop */
         if (vertex_cnt) clip_and_shade();
      }

      /* cap the top at the end */
      if (ABS(second_orient[2]) > ZERO_TOL)
      {
         HSset_facet_normal(second_orient[0],
                            second_orient[1],
                            second_orient[2]);

         /* create the facet loop */
         vertex_cnt = 0;
         for ( xindex = 1; xindex <= (2 * NCtool_data.num_xsect); xindex++ )
         {
            pindex = (xindex * NCtool_data.num_curve_points) - 1;
            edge1 = (4 * ((xindex * (NCtool_data.num_curve_points - 1)) - 1)) +
                    1;
            if (edge_matrix[edge1] != NO_PROFILE_POINT)
            {
               HSadd_dexel_vertex(
                                end_profile_point_array[edge_matrix[edge1]][0],
                                end_profile_point_array[edge_matrix[edge1]][1],
                                end_profile_point_array[edge_matrix[edge1]][2],
                                1.0);
               vertex_cnt++;
            }

            if (dot_product_matrix[pindex] >= 0.0)
            {
               nxindex = (((xindex + fax_offset_diff +
                           (2 * NCtool_data.num_xsect)) %
                           (2 * NCtool_data.num_xsect)) *
                           NCtool_data.num_curve_points) - 1;
               HSadd_dexel_vertex( NCtool_arrays.xsect[nxindex][0],
                                   NCtool_arrays.xsect[nxindex][1],
                                   NCtool_arrays.xsect[nxindex][2],
                                   1.0 );
               vertex_cnt++;
            }
         }

         /* process the facet loop */
         if (vertex_cnt) clip_and_shade();
      }

      /* reset the shading style */
      HSset_dexel_shading_style( NCshading.active_shading_style );
   }
}


/*-----NCbuild_fax_swept_volume-----------------------------------------------*/

static void NCbuild_fax_swept_volume(void)

/*
 * ABSTRACT:   Generates a five-axis linear swept volume using the active tool
 *             and location and orientation data.
 *
 * HISTORY:   07/23/88   Created.         C. M. Jablonski
 *
 */

{
   IGRint      total_points;
   IGRint      xindex;
   IGRint      nxindex;
   IGRint      pindex;
   IGRint      this_xsect;
   IGRint      next_xsect;
   IGRint      dest_xsect;
   IGRint      next_dest_xsect;
   IGRint      curr_lo;
   IGRint      curr_hi;
   IGRint      next_hi;
   IGRint      dest_lo;
   IGRint      dest_hi;
   IGRint      dest_next_hi;
   IGRint      edge1;
   IGRint      edge2;
   IGRint      edge3;
   IGRint      i;
   IGRint      j;
   IGRpoint    path_curve;
   IGRpoint    perp_vect;
   IGRpoint    orig_loc;
   IGRpoint    orig_orient;
   IGRpoint    first_orient;
   IGRpoint    second_orient;
   IGRpoint    temp_pt[6];
   IGRboolean  first_adjust_pc;
   IGRboolean  second_adjust_pc;
   IGRdouble   length;
   IGRint      top_fax_orig_profile_edge[2];
   IGRint      top_fax_dest_profile_edge[2];


   top_fax_orig_profile_edge[0] = NO_PROFILE_POINT;
   top_fax_orig_profile_edge[1] = NO_PROFILE_POINT;
   top_fax_dest_profile_edge[0] = NO_PROFILE_POINT;
   top_fax_dest_profile_edge[1] = NO_PROFILE_POINT;

   /* calculate the path curve */
   get_path_curve( path_curve );

   /* Determine the original index offset */
   set_index_offset( path_curve, perp_vect, &first_adjust_pc );
   fax_offset_diff = index_offset1;

   /* Save the vertex and normal arrays for the current orientation */
   total_points = 2 * NCtool_data.num_xsect * NCtool_data.num_curve_points;
   copy_points ( total_points,
                 total_points,
                 0,
                 NCtool_arrays.xsect,
                 total_points,
                 0,
                 NCtool_arrays.txm );

   copy_points ( total_points,
                 total_points,
                 0,
                 NCtool_arrays.fnorm,
                 total_points,
                 0,
                 NCtool_arrays.tfm );

   copy_points ( total_points,
                 total_points,
                 0,
                 NCtool_arrays.vnorm,
                 total_points,
                 0,
                 NCtool_arrays.tvm );

   /* Save the current position */
   orig_loc[0] = NCtoolpath_data.curr_location[0];
   orig_loc[1] = NCtoolpath_data.curr_location[1];
   orig_loc[2] = NCtoolpath_data.curr_location[2];
   orig_orient[0] = NCtoolpath_data.curr_orient_vec[0];
   orig_orient[1] = NCtoolpath_data.curr_orient_vec[1];
   orig_orient[2] = NCtoolpath_data.curr_orient_vec[2];

   /* Move the tool to the end of the step */
   NCupdate_toolpath_position();
   NCinit_tool_vars();

   /* Restore the current location */
   NCtoolpath_data.curr_location[0] = orig_loc[0];
   NCtoolpath_data.curr_location[1] = orig_loc[1];
   NCtoolpath_data.curr_location[2] = orig_loc[2];

   /* Set the index offset */
   set_index_offset( path_curve, perp_vect, &second_adjust_pc );

   /* Determine the difference in offsets */
   fax_offset_diff -= index_offset1;
   fax_offset_diff *= -1;

   /* Determine the origin and destination profiles */
   num_fax_orig_profile_points = num_fax_dest_profile_points = 0;

   for (xindex = 0; xindex < (2 * NCtool_data.num_xsect); xindex++)
   {
      /* this_xsect will point to the beginning of each cross-section */
      this_xsect = xindex * NCtool_data.num_curve_points;

      /* set next_xsect to point to the beginning of the next cross-section */
      nxindex = (xindex + 1) % (2 * NCtool_data.num_xsect);
      next_xsect = nxindex * NCtool_data.num_curve_points;

      /* set dest_xsect to point to the beginning of the destination   */
      /* cross-section                                                 */
      nxindex = xindex + fax_offset_diff + (2 * NCtool_data.num_xsect);
      nxindex %= (2 * NCtool_data.num_xsect);
      dest_xsect = nxindex * NCtool_data.num_curve_points;

      /* set next_dest_xsect to point to the beginning of the next  */
      /* destination cross-section                                  */
      nxindex = xindex + fax_offset_diff + (2 * NCtool_data.num_xsect) + 1;
      nxindex %= (2 * NCtool_data.num_xsect);
      next_dest_xsect = nxindex * NCtool_data.num_curve_points;

#if COUNT_EDGES
{
      inter_ct = intra_ct = 0;
}
#endif

      for (pindex = 1; pindex < NCtool_data.num_curve_points; pindex++)
      {
         curr_hi = this_xsect + pindex;
         curr_lo = curr_hi - 1;
         next_hi = next_xsect + pindex;
         dest_hi = dest_xsect + pindex;
         dest_lo = dest_hi - 1;
         dest_next_hi = next_dest_xsect + pindex;
         edge1 = ((xindex * (NCtool_data.num_curve_points - 1)) +
                   pindex - 1) * 4;
         edge2 = ((((xindex + 1) % (2 * NCtool_data.num_xsect)) *
                    (NCtool_data.num_curve_points - 1)) + pindex) * 4;
         edge3 = ((((xindex + 1) % (2 * NCtool_data.num_xsect)) *
                    (NCtool_data.num_curve_points - 1)) + pindex - 1) * 4;


#if COUNT_EDGES
{
         same_xsect = TRUE;
}
#endif
         /* find any profile points on the edge between hi and lo points on */
         /* the current xsect                                               */
         find_profile_points( NCtool_arrays.txm[curr_lo],
                              NCtool_arrays.txm[curr_hi],
                              NCtool_arrays.xsect[dest_lo],
                              NCtool_arrays.xsect[dest_hi],
                              NCtool_arrays.tvm[curr_lo],
                              NCtool_arrays.tvm[curr_hi],
                              NCtool_arrays.vnorm[dest_lo],
                              NCtool_arrays.vnorm[dest_hi],
                              &NCtool_arrays.orig_dp[curr_lo],
                              &NCtool_arrays.orig_dp[curr_hi],
                              &NCtool_arrays.dest_dp[curr_lo],
                              &NCtool_arrays.dest_dp[curr_hi],
                              &NCtool_arrays.orig_prof_edge[edge1 + 2],
                              &NCtool_arrays.orig_prof_edge[edge3],
                              &NCtool_arrays.dest_prof_edge[edge1 + 2],
                              &NCtool_arrays.dest_prof_edge[edge3] );

#if COUNT_EDGES
{
         same_xsect = FALSE;
}
#endif
         /* find any profile points on the edge between the current and next
            xsect */
         if (pindex < (NCtool_data.num_curve_points - 1))
         {
            find_profile_points( NCtool_arrays.txm[curr_hi],
                                 NCtool_arrays.txm[next_hi],
                                 NCtool_arrays.xsect[dest_hi],
                                 NCtool_arrays.xsect[dest_next_hi],
                                 NCtool_arrays.tvm[curr_hi],
                                 NCtool_arrays.tvm[next_hi],
                                 NCtool_arrays.vnorm[dest_hi],
                                 NCtool_arrays.vnorm[dest_next_hi],
                                 &NCtool_arrays.orig_dp[curr_hi],
                                 &NCtool_arrays.orig_dp[next_hi],
                                 &NCtool_arrays.dest_dp[curr_hi],
                                 &NCtool_arrays.dest_dp[next_hi],
                                 &NCtool_arrays.orig_prof_edge[edge2 + 3],
                                 &NCtool_arrays.orig_prof_edge[edge3 + 1],
                                 &NCtool_arrays.dest_prof_edge[edge2 + 3],
                                 &NCtool_arrays.dest_prof_edge[edge3 + 1] );
         }
         else
         {
            find_profile_points( NCtool_arrays.txm[curr_hi],
                                 NCtool_arrays.txm[next_hi],
                                 NCtool_arrays.xsect[dest_hi],
                                 NCtool_arrays.xsect[dest_next_hi],
                                 NCtool_arrays.tvm[curr_hi],
                                 NCtool_arrays.tvm[next_hi],
                                 NCtool_arrays.vnorm[dest_hi],
                                 NCtool_arrays.vnorm[dest_next_hi],
                                 &NCtool_arrays.orig_dp[curr_hi],
                                 &NCtool_arrays.orig_dp[next_hi],
                                 &NCtool_arrays.dest_dp[curr_hi],
                                 &NCtool_arrays.dest_dp[next_hi],
                                 top_fax_orig_profile_edge,
                                 &NCtool_arrays.orig_prof_edge[edge3 + 1],
                                 top_fax_dest_profile_edge,
                                 &NCtool_arrays.dest_prof_edge[edge3 + 1] );

            if (top_fax_orig_profile_edge[1] == NO_PROFILE_POINT)
            {
               top_fax_orig_profile_edge[1] = top_fax_orig_profile_edge[0];
            }
            if (top_fax_dest_profile_edge[1] == NO_PROFILE_POINT)
            {
               top_fax_dest_profile_edge[1] = top_fax_dest_profile_edge[0];
            }
         }
      }
#if COUNT_EDGES
{
      intra_xsect[intra_ct++] = '\0';
      inter_xsect[inter_ct++] = '\0';
      fprintf(stderr, "XSECT[%d]:\t%s\n\t\t%s\n", xindex, intra_xsect,
                      inter_xsect);
}
#endif
   }

   /* define the orig and dest tool orientations in world coordinates */
   temp_pt[0][0] = NCtoolpath_data.curr_location[0];
   temp_pt[0][1] = NCtoolpath_data.curr_location[1];
   temp_pt[0][2] = NCtoolpath_data.curr_location[2];
   temp_pt[1][0] = temp_pt[0][0] + orig_orient[0];
   temp_pt[1][1] = temp_pt[0][1] + orig_orient[1];
   temp_pt[1][2] = temp_pt[0][2] + orig_orient[2];
   temp_pt[2][0] = temp_pt[0][0] + NCtoolpath_data.curr_orient_vec[0];
   temp_pt[2][1] = temp_pt[0][1] + NCtoolpath_data.curr_orient_vec[1];
   temp_pt[2][2] = temp_pt[0][2] + NCtoolpath_data.curr_orient_vec[2];

   /* transform the points into viewing coordinates. NOTE: No Perspective. */
   transform_points ( FALSE, 3, (IGRdouble *)temp_pt, 0 );

   /* get the orientations in viewing coordinates (normalized) */
   first_orient[0] = temp_pt[1][0] - temp_pt[0][0];
   first_orient[1] = temp_pt[1][1] - temp_pt[0][1];
   first_orient[2] = temp_pt[1][2] - temp_pt[0][2];
   NORMALIZE(first_orient)

   second_orient[0] = temp_pt[2][0] - temp_pt[0][0];
   second_orient[1] = temp_pt[2][1] - temp_pt[0][1];
   second_orient[2] = temp_pt[2][2] - temp_pt[0][2];
   NORMALIZE(second_orient)

#if DO_ORIGIN_SWVOL
{
   /* Sweep out the tool halves at the origin and destination */
   NCtile_fax_tool( first_orient, second_orient,
                    NCtool_arrays.orig_start_pt,
                    NCtool_arrays.orig_start_norm,
                    NCtool_arrays.orig_end_pt,
                    NCtool_arrays.orig_end_norm,
                    NCtool_arrays.orig_prof_edge,
                    NCtool_arrays.orig_dp );

   /* Build side facets by joining profile edges */
   for ( xindex = 0;
      xindex < (8 * NCtool_data.num_xsect * (NCtool_data.num_curve_points - 1));
      xindex += 4 )
   {
      for (i = 0; i < 4; i++)
      {
         if (NCtool_arrays.orig_prof_edge[xindex + i] != NO_PROFILE_POINT)
         {
            for (j = i + 1; j < 4; j++)
            {
               if (NCtool_arrays.orig_prof_edge[xindex + j] != NO_PROFILE_POINT)
               {
                  generate_toleranced_facet(
                     NCtool_arrays.orig_start_pt[NCtool_arrays.orig_prof_edge[xindex + i]],
                     NCtool_arrays.orig_start_pt[NCtool_arrays.orig_prof_edge[xindex + j]],
                     NCtool_arrays.orig_end_pt[NCtool_arrays.orig_prof_edge[xindex + i]],
                     NCtool_arrays.orig_end_pt[NCtool_arrays.orig_prof_edge[xindex + j]],
                     NCtool_arrays.orig_start_norm[NCtool_arrays.orig_prof_edge[xindex + i]],
                     NCtool_arrays.orig_start_norm[NCtool_arrays.orig_prof_edge[xindex + j]],
                     NCtool_arrays.orig_end_norm[NCtool_arrays.orig_prof_edge[xindex + i]],
                     NCtool_arrays.orig_end_norm[NCtool_arrays.orig_prof_edge[xindex + j]] );

                  NCtool_arrays.orig_prof_edge[xindex + j] = NO_PROFILE_POINT;
               }
            }
            NCtool_arrays.orig_prof_edge[xindex + i] = NO_PROFILE_POINT;
         }
      }
   }

   /* Build the top facets */
   if ((top_fax_orig_profile_edge[0] != NO_PROFILE_POINT) && 
       (top_fax_orig_profile_edge[1] != NO_PROFILE_POINT))
   {
      generate_toleranced_facet(
                    NCtool_arrays.orig_start_pt[top_fax_orig_profile_edge[0]],
                    NCtool_arrays.orig_start_pt[top_fax_orig_profile_edge[1]],
                    NCtool_arrays.orig_end_pt[top_fax_orig_profile_edge[0]],
                    NCtool_arrays.orig_end_pt[top_fax_orig_profile_edge[1]],
                    first_orient,
                    first_orient,
                    second_orient,
                    second_orient );
   }
}
#endif

#if (DO_ORIGIN_SWVOL && DO_DEST_SWVOL)
{
   NCdexelize_swvol();
}
#endif

#if DO_DEST_SWVOL
{
   /* Sweep out the tool halves at the origin and destination */
   NCtile_fax_tool( first_orient,
                    second_orient,
                    NCtool_arrays.dest_start_pt,
                    NCtool_arrays.dest_start_norm,
                    NCtool_arrays.dest_end_pt,
                    NCtool_arrays.dest_end_norm,
                    NCtool_arrays.dest_prof_edge,
                    NCtool_arrays.dest_dp );

   /* Build side facets by joining profile edges */
   for ( xindex = 0;
         xindex < (8 * NCtool_data.num_xsect * 
                                        (NCtool_data.num_curve_points - 1));
         xindex += 4 )
   {
      for (i = 0; i < 4; i++)
      {
         if (NCtool_arrays.dest_prof_edge[xindex + i] != NO_PROFILE_POINT)
         {
            for (j = i + 1; j < 4; j++)
            {
               if (NCtool_arrays.dest_prof_edge[xindex + j] != NO_PROFILE_POINT)
               {
                  generate_toleranced_facet(
                     NCtool_arrays.dest_start_pt[NCtool_arrays.dest_prof_edge[xindex + i]],
                     NCtool_arrays.dest_start_pt[NCtool_arrays.dest_prof_edge[xindex + j]],
                     NCtool_arrays.dest_end_pt[NCtool_arrays.dest_prof_edge[xindex + i]],
                     NCtool_arrays.dest_end_pt[NCtool_arrays.dest_prof_edge[xindex + j]],
                     NCtool_arrays.dest_start_norm[NCtool_arrays.dest_prof_edge[xindex + i]],
                     NCtool_arrays.dest_start_norm[NCtool_arrays.dest_prof_edge[xindex + j]],
                     NCtool_arrays.dest_end_norm[NCtool_arrays.dest_prof_edge[xindex + i]],
                     NCtool_arrays.dest_end_norm[NCtool_arrays.dest_prof_edge[xindex + j]] );

                  NCtool_arrays.dest_prof_edge[xindex + j] = NO_PROFILE_POINT;
               }
            }
            NCtool_arrays.dest_prof_edge[xindex + i] = NO_PROFILE_POINT;
         }
      }
   }

   /* Build the top facets */
   if ((top_fax_dest_profile_edge[0] != NO_PROFILE_POINT) && (top_fax_dest_profile_edge[1] != NO_PROFILE_POINT))
   {
      generate_toleranced_facet(
                     NCtool_arrays.dest_start_pt[top_fax_dest_profile_edge[0]],
                     NCtool_arrays.dest_start_pt[top_fax_dest_profile_edge[1]],
                     NCtool_arrays.dest_end_pt[top_fax_dest_profile_edge[0]],
                     NCtool_arrays.dest_end_pt[top_fax_dest_profile_edge[1]],
                     first_orient,
                     first_orient,
                     second_orient,
                     second_orient );
   }
}
#endif

   /* re-initialize the five-axis dot product arrays */
   for ( xindex = 0;
         xindex < (2 * NCtool_data.num_xsect * NCtool_data.num_curve_points);
         xindex++ )
   {
      NCtool_arrays.orig_dp[xindex] = NO_DOT_PRODUCT;
      NCtool_arrays.dest_dp[xindex] = NO_DOT_PRODUCT;
   }
}


/*-----NCbuild_swept_volume--------------------------------------------------------*/

void NCbuild_swept_volume(void)

/*
 * ABSTRACT: Generates a swept volume using the current tool and toolpath data.
 *
 * HISTORY:  08/28/89   Created.         C. M. Jablonski
 *
 */

{
   IGRpoint   tip_path_curve;
   IGRpoint   top_path_curve;
   IGRpoint   pc_diff;
   IGRpoint   start_top_loc;
   IGRpoint   end_top_loc;

START_NC_TIMING(NCtd_BUILD_SWVOL)

   if (NCtoolpath_data.five_axis)
   {
      /* calculate the path curves for the top and middle of the tool */
      start_top_loc[0] = NCtoolpath_data.curr_location[0] +
                         NCtool_data.height *
                         NCtoolpath_data.curr_orient_vec[0];
      start_top_loc[1] = NCtoolpath_data.curr_location[1] +
                         NCtool_data.height *
                         NCtoolpath_data.curr_orient_vec[1];
      start_top_loc[2] = NCtoolpath_data.curr_location[2] +
                         NCtool_data.height *
                         NCtoolpath_data.curr_orient_vec[2];

      end_top_loc[0] = NCtoolpath_data.next_location[0] +
                       NCtool_data.height *
                       NCtoolpath_data.next_orient_vec[0];
      end_top_loc[1] = NCtoolpath_data.next_location[1] +
                       NCtool_data.height *
                       NCtoolpath_data.next_orient_vec[1];
      end_top_loc[2] = NCtoolpath_data.next_location[2] +
                       NCtool_data.height *
                       NCtoolpath_data.next_orient_vec[2];

      top_path_curve[0] = end_top_loc[0] - start_top_loc[0];
      top_path_curve[1] = end_top_loc[1] - start_top_loc[1];
      top_path_curve[2] = end_top_loc[2] - start_top_loc[2];

      tip_path_curve[0] = NCtoolpath_data.next_location[0] -
                                              NCtoolpath_data.curr_location[0];
      tip_path_curve[1] = NCtoolpath_data.next_location[1] -
                                              NCtoolpath_data.curr_location[1];
      tip_path_curve[2] = NCtoolpath_data.next_location[2] -
                                              NCtoolpath_data.curr_location[2];

      pc_diff[0] = top_path_curve[0] - tip_path_curve[0];
      pc_diff[1] = top_path_curve[1] - tip_path_curve[1];
      pc_diff[2] = top_path_curve[2] - tip_path_curve[2];

      if ((ABS(pc_diff[0]) > ZERO_TOL) ||
          (ABS(pc_diff[1]) > ZERO_TOL) ||
          (ABS(pc_diff[2]) > ZERO_TOL))
      {
         NCbuild_fax_swept_volume();

#if COUNT_EDGES
{
   fprintf(stderr, "\n\"/\" = ORIGIN PROFILE,  \"\\\" = DESTINATION PROFILE\n");
   fprintf(stderr, "NUM_XSECT=%d, NUM_CURVE_POINTS=%d\n",
                    NCtool_data.num_xsect, NCtool_data.num_curve_points );
   fprintf(stderr, "NUM_ORIG_PROFILE_POINTS=%d, NUM_DEST_PROFILE_POINTS=%d\n\n",
                   num_fax_orig_profile_points, num_fax_dest_profile_points);
}
#endif

      }
      else
      {
         NCbuild_tax_swept_volume();
      }
   }
   else
   {
      NCbuild_tax_swept_volume();
   }

STOP_NC_TIMING(NCtd_BUILD_SWVOL)
}
