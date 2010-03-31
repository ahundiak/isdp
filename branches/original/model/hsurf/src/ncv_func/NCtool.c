
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $

HISTORY

        Sudha   07/27/93        Modified for BSprototypes ansification
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "wl.h"

#include "hnmilling.h"
#include "hnerror.h"
#include "hntool.h"
#include "hnorient.h"
#include "hntoolpath.h"
#include "bserr.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hsdisplay.h"
#include "hstiler.h"
#include "hnmill.h"

#include "HSpr_ncv_fun.h"

/*-----------------------
 *  for function
 *     get_curve_sampling_points
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
#include "bscvarreval.h"

/*------------------------*/

#define PI           3.14159
#define DEBUG_CURVE  FALSE

#define ZERO_TOL     1.0e-5

#define ABS(x)       ( ( x > 0.0 ) ? ( x ) : ( - x ) )              \

#define NORMALIZE(vector)                                           \
{                                                                   \
   length = sqrt( (vector[0]*vector[0]) + (vector[1]*vector[1]) +   \
             (vector[2]*vector[2]) );                               \
   vector[0] /= length;                                             \
   vector[1] /= length;                                             \
   vector[2] /= length;                                             \
}

#define CROSS(va, vb, result)                                       \
{                                                                   \
   result[0] =   ( va[1] * vb[2] ) - ( va[2] * vb[1] );             \
   result[1] =   ( va[2] * vb[0] ) - ( va[0] * vb[2] );             \
   result[2] =   ( va[0] * vb[1] ) - ( va[1] * vb[0] );             \
}

#define AVERAGE(va, vb, result)                                     \
{                                                                   \
   result[0] =   va[0] + vb[0];                                     \
   result[1] =   va[1] + vb[1];                                     \
   result[2] =   va[2] + vb[2];                                     \
   NORMALIZE( result )                                              \
}


/**********************
 * EXTERNAL VARIABLES *
 **********************/

extern double  sqrt(), cos(), sin(), acos();

extern struct NC_error_flags    NCerror_flags;
extern struct NC_shading_parms  NCshading;
extern struct NC_tool_data      NCtool_data;
extern struct NC_tool_arrays    NCtool_arrays;
extern struct NC_tool_orient    NCtool_orient;
extern struct NC_toolpath_data  NCtoolpath_data;
extern struct NC_window_parms   NCwindow;


/*******************
 * LOCAL VARIABLES *
 *******************/

static IGRdouble *curve_points;   /* the tool-curve point array.  Points here */
                                  /* are represented by parameterized (u,r)   */
                                  /* coordinates.  This array is used when    */
                                  /* generating a new tool and when           */
                                  /* regenerating a tool after an orientation */
                                  /* change.                                  */

static IGRint    max_rad_index;   /* the index of the sample point at the     */
                                  /* tool's maximum radius                    */

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

/* NCtool.c */
static void generate_tool_xsect __(( IGRpoint   xsect,
                                     IGRint     num_curve_points,
                                     IGRdouble  *curve_points,
                                     IGRdouble  *ppt,
                                     IGRdouble  *rpt));

static void generate_facet_normals __(( void ));

static void generate_vertex_normals __(( void ));

static void generate_linestring_vertex_normals __(( void ));

static void alloc_tool_vars __(( IGRint num_xsect,
                                 IGRint num_points ));

#if defined(__cplusplus)
}
#endif


#undef __


/*-----NCcleanup_tool---------------------------------------------------------*/

void NCcleanup_tool(void)

/*
 * ABSTRACT:   NCcleanup_tool frees all data associated with the tool.
 *
 * HISTORY:   07/20/88   Created.         C. M. Jablonski
 *
 */

{
   if (NCtool_arrays.profile)
   {
      free (NCtool_arrays.profile);
      NCtool_arrays.profile = NULL;
   }

   if (NCtool_arrays.profnorm)
   {
      free (NCtool_arrays.profnorm);
      NCtool_arrays.profnorm = NULL;
   }

   if (NCtool_arrays.profind)
   {
      free (NCtool_arrays.profind);
      NCtool_arrays.profind = NULL;
   }

   if (NCtool_arrays.xsect)
   {
      free (NCtool_arrays.xsect);
      NCtool_arrays.xsect = NULL;
   }

   if (NCtool_arrays.fnorm)
   {
      free (NCtool_arrays.fnorm);
      NCtool_arrays.fnorm = NULL;
   }

   if (NCtool_arrays.vnorm)
   {
      free (NCtool_arrays.vnorm);
      NCtool_arrays.vnorm = NULL;
   }

   if (NCtool_arrays.txm)
   {
      free (NCtool_arrays.txm);
      NCtool_arrays.txm = NULL;
   }

   if (NCtool_arrays.tvm)
   {
      free (NCtool_arrays.tvm);
      NCtool_arrays.tvm = NULL;
   }

   if (NCtool_arrays.tfm)
   {
      free (NCtool_arrays.tfm);
      NCtool_arrays.tfm = NULL;
   }

   if (NCtool_arrays.orig_prof_edge)
   {
      free (NCtool_arrays.orig_prof_edge);
      NCtool_arrays.orig_prof_edge = NULL;
   }

   if (NCtool_arrays.orig_dp)
   {
      free (NCtool_arrays.orig_dp);
      NCtool_arrays.orig_dp = NULL;
   }

   if (NCtool_arrays.orig_start_pt)
   {
      free (NCtool_arrays.orig_start_pt);
      NCtool_arrays.orig_start_pt = NULL;
   }

   if (NCtool_arrays.orig_start_norm)
   {
      free (NCtool_arrays.orig_start_norm);
      NCtool_arrays.orig_start_norm = NULL;
   }

   if (NCtool_arrays.orig_end_pt)
   {
      free (NCtool_arrays.orig_end_pt);
      NCtool_arrays.orig_end_pt = NULL;
   }

   if (NCtool_arrays.orig_end_norm)
   {
      free (NCtool_arrays.orig_end_norm);
      NCtool_arrays.orig_end_norm = NULL;
   }

   if (NCtool_arrays.dest_prof_edge)
   {
      free (NCtool_arrays.dest_prof_edge);
      NCtool_arrays.dest_prof_edge = NULL;
   }

   if (NCtool_arrays.dest_dp)
   {
      free (NCtool_arrays.dest_dp);
      NCtool_arrays.dest_dp = NULL;
   }

   if (NCtool_arrays.dest_start_pt)
   {
      free (NCtool_arrays.dest_start_pt);
      NCtool_arrays.dest_start_pt = NULL;
   }

   if (NCtool_arrays.dest_start_norm)
   {
      free (NCtool_arrays.dest_start_norm);
      NCtool_arrays.dest_start_norm = NULL;
   }

   if (NCtool_arrays.dest_end_pt)
   {
      free (NCtool_arrays.dest_end_pt);
      NCtool_arrays.dest_end_pt = NULL;
   }

   if (NCtool_arrays.dest_end_norm)
   {
      free (NCtool_arrays.dest_end_norm);
      NCtool_arrays.dest_end_norm = NULL;
   }

   if (NCtool_arrays.minpind)
   {
      free (NCtool_arrays.minpind);
      NCtool_arrays.minpind = NULL;
   }

   if (curve_points)
   {
      free (curve_points);
      curve_points = NULL;
   }
}


/*-----generate_tool_xsect----------------------------------------------------*/

static void generate_tool_xsect( IGRpoint   xsect,
                                 IGRint     num_curve_points,
                                 IGRdouble  *curve_points,
                                 IGRdouble  *ppt,
                                 IGRdouble  *rpt )

/*
 * ABSTRACT:
 *      Generate_tool_xsect generates a cross-section of the tool.  The given
 *      xsect vector is a vector in the plane of the desired cross section.
 *      The routine uses this vector to translate the (u,r) coordinates of
 *      the profile points in the active tool buffer into (x,y,z) world
 *      coordinates.  For each (u,r) point, two (x,y,z) coordinates are
 *      generated: one using (xsect) and one using (-xsect).  This gives us
 *      both halves of the cross-section curve from just the one tool curve.
 *      The two halves of the cross-section curve are returned in the given
 *      point arrays.
 *
 * HISTORY:   07/20/88   Created.         C. M. Jablonski
 *
 */

{
   register int  index;
   IGRdouble     rx;
   IGRdouble     ry;
   IGRdouble     rz;

   /* calculate world coordinates for each point in the profile curve and its */
   /* reflection over the tool axis.  This loop basically translates the      */
   /* (u,r) point parameters into (x,y,z) world coordinate values and stores  */
   /* them in the return arrays.                                              */

   for ( index=0; index<(2*num_curve_points); index+=2 )
   {
      /* calculate the x-coordinates of the points */
      rx = (curve_points[index+1] * xsect[0]);
      *ppt = NCtoolpath_data.curr_location[0] + rx +
                                (curve_points[index] * NCtool_orient.axis[0]);
      *(rpt++) = *(ppt++) - 2*rx;

      /* calculate the y-coordinates of the points */
      ry = (curve_points[index+1] * xsect[1]);
      *ppt = NCtoolpath_data.curr_location[1] + ry +
                                (curve_points[index] * NCtool_orient.axis[1]);
      *(rpt++) = *(ppt++) - 2*ry;

      /* calculate the z-coordinates of the points */
      rz = (curve_points[index+1] * xsect[2]);
      *ppt = NCtoolpath_data.curr_location[2] + rz +
                                (curve_points[index] * NCtool_orient.axis[2]);
      *(rpt++) = *(ppt++) - 2*rz;
   }
}


/*-----generate_facet_normals-------------------------------------------------*/

static void generate_facet_normals(void)

/*
 * ABSTRACT:  Generate_facet_normals generates the normal to each FACET in xsect
 *            and stores it in fnorm.
 *
 * HISTORY:   08/20/88   Created.         C. M. Jablonski
 *
 */

{
   IGRint     xindex;
   IGRint     pindex;
   IGRint     curr_pt;
   IGRdouble  length;
   IGRpoint   to_prev_pt;
   IGRpoint   to_next_xs;


   /*
    * Calculate normals for each cross-section.
    */

   for ( xindex = 0; xindex < 2 * NCtool_data.num_xsect; xindex++ )
   {
      /* set the direction to the next xsect */
      to_next_xs[0] = NCtool_arrays.xsect[(((xindex + 1) % 
                                          (2 * NCtool_data.num_xsect)) *
                                          NCtool_data.num_curve_points) +
                                          max_rad_index][0] -
                      NCtool_arrays.xsect[(xindex *
                                          NCtool_data.num_curve_points) +
                                          max_rad_index][0];

      to_next_xs[1] = NCtool_arrays.xsect[(((xindex + 1) %
                                          (2 * NCtool_data.num_xsect)) *
                                          NCtool_data.num_curve_points) +
                                          max_rad_index][1] -
                      NCtool_arrays.xsect[(xindex *
                                          NCtool_data.num_curve_points) +
                                          max_rad_index][1];

      to_next_xs[2] = NCtool_arrays.xsect[(((xindex + 1) %
                                          (2 * NCtool_data.num_xsect)) *
                                          NCtool_data.num_curve_points) +
                                          max_rad_index][2] -
                      NCtool_arrays.xsect[(xindex *
                                          NCtool_data.num_curve_points) +
                                          max_rad_index][2];
      NORMALIZE( to_next_xs )

      /* calculate normals for each point in the cross-section */
      for ( pindex = 1; pindex < NCtool_data.num_curve_points; pindex++ )
      {
         /* set the direction to the previous point */
         curr_pt = (xindex * NCtool_data.num_curve_points) + pindex;
         to_prev_pt[0] = NCtool_arrays.xsect[curr_pt - 1][0] -
                         NCtool_arrays.xsect[curr_pt][0];

         to_prev_pt[1] = NCtool_arrays.xsect[curr_pt - 1][1] -
                         NCtool_arrays.xsect[curr_pt][1];

         to_prev_pt[2] = NCtool_arrays.xsect[curr_pt - 1][2] -
                         NCtool_arrays.xsect[curr_pt][2];

         CROSS( to_next_xs, to_prev_pt, NCtool_arrays.fnorm[curr_pt] )
         NORMALIZE( NCtool_arrays.fnorm[curr_pt] )
      }
   }
}


/*-----generate_vertex_normals------------------------------------------------*/

static void generate_vertex_normals(void)

/*
 * ABSTRACT: Generate_vertex_normals generates the normal to each POINT in xsect
 *           and stores it in vnorm.  Each vertex normal is calculated by 
 *           averaging the normals of two facets that are diagonally adjacent
 *           at that vertex.
 *
 * HISTORY:   08/22/88   Created.         C. M. Jablonski
 *
 */

{
   IGRint      xindex;
   IGRint      pindex;
   IGRint      prev_xindex;
   IGRdouble   length;

   /*
    * Calculate the normal to the tip of the tool, and store it in the first
    * row of vnorm.
    */

   AVERAGE( NCtool_arrays.fnorm[1],
            NCtool_arrays.fnorm[(NCtool_data.num_xsect *
                                 NCtool_data.num_curve_points) + 1],
            NCtool_arrays.vnorm[0] )

   for ( pindex = NCtool_data.num_curve_points;
         pindex < (2 * NCtool_data.num_xsect * NCtool_data.num_curve_points);
         pindex += NCtool_data.num_curve_points )
   {
      NCtool_arrays.vnorm[pindex][0] = NCtool_arrays.vnorm[0][0];
      NCtool_arrays.vnorm[pindex][1] = NCtool_arrays.vnorm[0][1];
      NCtool_arrays.vnorm[pindex][2] = NCtool_arrays.vnorm[0][2];
   }


   /* calculate normals for each cross-section */
   for ( xindex = 0; xindex < 2 * NCtool_data.num_xsect; xindex++ )
   {
      prev_xindex = (xindex - 1 + (2 * NCtool_data.num_xsect)) % 
                    (2 * NCtool_data.num_xsect);

      /* calculate normals for each point in the cross-section */
      for ( pindex = 1; pindex < (NCtool_data.num_curve_points - 1); pindex++ )
      {
         AVERAGE( NCtool_arrays.fnorm[(xindex * NCtool_data.num_curve_points) +
                                  pindex],
                  NCtool_arrays.fnorm[(prev_xindex * 
                                  NCtool_data.num_curve_points) + pindex + 1],
                  NCtool_arrays.vnorm[(xindex * NCtool_data.num_curve_points) +
                                  pindex] )
      }

      /* calculate the normal to the topmost point of the xsect */
      if (NCtool_data.open_ended)
      {
         AVERAGE( NCtool_arrays.fnorm[(xindex * NCtool_data.num_curve_points) +
                                  pindex],
                  NCtool_arrays.fnorm[(prev_xindex *
                                  NCtool_data.num_curve_points) + pindex],
                  NCtool_arrays.vnorm[(xindex * NCtool_data.num_curve_points) +
                                  pindex] )
      }
      else
      {
         NCtool_arrays.vnorm[(xindex*NCtool_data.num_curve_points)+pindex][0]=
                             - NCtool_arrays.vnorm[0][0];
         NCtool_arrays.vnorm[(xindex*NCtool_data.num_curve_points)+pindex][1]=
                             - NCtool_arrays.vnorm[0][1];
         NCtool_arrays.vnorm[(xindex*NCtool_data.num_curve_points)+pindex][2]=
                             - NCtool_arrays.vnorm[0][2];
      }
   }
}


/*-----generate_linestring_vertex_normals-------------------------------------*/

static void generate_linestring_vertex_normals(void)

/*
 * ABSTRACT:  Generate_linestring_vertex_normals generates the normal to each
 *            POINT in xsect and stores it in vnorm.  Each vertex normal is
 *            calculated by averaging the normals of two facets that are
 *            adjacent along an edge containing the given vertex.
 *
 * HISTORY:   08/22/88   Created.         C. M. Jablonski
 *
 */

{
   IGRint      xindex;
   IGRint      pindex;
   IGRint      prev_xindex;
   IGRdouble   length;


   /*
    * Calculate the normal to the tip of the tool, and store it in the first
    * row of vnorm.
    */

   AVERAGE( NCtool_arrays.fnorm[1],
            NCtool_arrays.fnorm[(NCtool_data.num_xsect *
                                 NCtool_data.num_curve_points) + 1],
            NCtool_arrays.vnorm[0] )

   for ( pindex = NCtool_data.num_curve_points;
         pindex < (2 * NCtool_data.num_xsect * NCtool_data.num_curve_points);
         pindex += NCtool_data.num_curve_points )
   {
      NCtool_arrays.vnorm[pindex][0] = NCtool_arrays.vnorm[0][0];
      NCtool_arrays.vnorm[pindex][1] = NCtool_arrays.vnorm[0][1];
      NCtool_arrays.vnorm[pindex][2] = NCtool_arrays.vnorm[0][2];
   }


   /* calculate normals for each cross-section */
   for ( xindex = 0; xindex < 2 * NCtool_data.num_xsect; xindex++ )
   {
      prev_xindex = (xindex - 1 + (2 * NCtool_data.num_xsect)) %
                    (2 * NCtool_data.num_xsect);

      /* calculate normals for each point in the cross-section */
      for ( pindex = 1; pindex < NCtool_data.num_curve_points; pindex++ )
      {
         AVERAGE( NCtool_arrays.fnorm[(xindex * NCtool_data.num_curve_points) +
                                  pindex],
                  NCtool_arrays.fnorm[(prev_xindex *
                                  NCtool_data.num_curve_points) + pindex],
                  NCtool_arrays.vnorm[(xindex * NCtool_data.num_curve_points) +
                                  pindex] )
      }
   }
}


/*-----alloc_tool_vars--------------------------------------------------------*/

static void alloc_tool_vars( IGRint num_xsect,
                             IGRint num_points )

/*
 * ABSTRACT:   alloc_tool_vars allocates tool-related data structures.
 *
 * HISTORY:   07/20/88   Created.         C. M. Jablonski
 *
 */

{
   if ((NCtool_arrays.profile = (IGRpoint *)malloc( 4 * 
                            (num_points + num_xsect) * sizeof(IGRpoint))) &&

       (NCtool_arrays.profnorm = (IGRpoint *)malloc( 4 *
                            (num_points + num_xsect) * sizeof(IGRpoint))) &&

       (NCtool_arrays.profind = (IGRint *)  malloc( 4 *
                            (num_points + num_xsect) * sizeof(IGRint))) &&

       (NCtool_arrays.xsect = (IGRpoint *)malloc( 2 *
                             num_xsect * num_points * sizeof(IGRpoint))) &&

       (NCtool_arrays.fnorm = (IGRpoint *)malloc( 2 *
                             num_xsect * num_points * sizeof(IGRpoint))) &&

       (NCtool_arrays.vnorm = (IGRpoint *)malloc( 2 *
                             num_xsect * num_points * sizeof(IGRpoint))) &&

       (NCtool_arrays.txm = (IGRpoint *)malloc( 2 *
                             num_xsect * num_points * sizeof(IGRpoint))) &&

       (NCtool_arrays.tfm = (IGRpoint *)malloc( 2 *
                             num_xsect * num_points * sizeof(IGRpoint))) &&

       (NCtool_arrays.tvm = (IGRpoint *)malloc( 2 *
                             num_xsect * num_points * sizeof(IGRpoint))) &&

       (NCtool_arrays.orig_dp = (IGRdouble *)malloc( 2 *
                             num_xsect * num_points * sizeof(IGRdouble))) &&

       (NCtool_arrays.dest_dp = (IGRdouble *)malloc( 2 *
                             num_xsect * num_points * sizeof(IGRdouble))) &&

       (NCtool_arrays.orig_prof_edge = (IGRint *)malloc( 8 *
                            (num_points - 1) * num_xsect * sizeof(IGRint))) &&

       (NCtool_arrays.orig_start_pt = (IGRpoint *)malloc( 6 *
                            (num_points + num_xsect) * sizeof(IGRpoint))) &&

       (NCtool_arrays.orig_start_norm = (IGRpoint *)malloc( 6 *
                            (num_points + num_xsect) * sizeof(IGRpoint))) &&

       (NCtool_arrays.orig_end_pt = (IGRpoint *)malloc( 6 *
                            (num_points + num_xsect) * sizeof(IGRpoint))) &&

       (NCtool_arrays.orig_end_norm = (IGRpoint *)malloc( 6 *
                            (num_points + num_xsect) * sizeof(IGRpoint))) &&

       (NCtool_arrays.dest_prof_edge = (IGRint *)malloc( 8 *
                            (num_points - 1) * num_xsect * sizeof(IGRint))) &&

       (NCtool_arrays.dest_start_pt = (IGRpoint *)malloc( 6 *
                            (num_points + num_xsect) * sizeof(IGRpoint))) &&

       (NCtool_arrays.dest_start_norm = (IGRpoint *)malloc( 6 *
                            (num_points + num_xsect) * sizeof(IGRpoint))) &&

       (NCtool_arrays.dest_end_pt = (IGRpoint *)malloc( 6 *
                            (num_points + num_xsect) * sizeof(IGRpoint))) &&

       (NCtool_arrays.dest_end_norm = (IGRpoint *)malloc( 6 *
                            (num_points + num_xsect) * sizeof(IGRpoint))) &&

       (NCtool_arrays.minpind = (IGRint *)malloc( 2 *
                             num_xsect * sizeof(IGRpoint))))
   {
      NCerror_flags.memory_fault = FALSE;
   }
   else
   {
      NCerror_flags.memory_fault = TRUE;
   }
}


/*-----NCinit_tool_vars-------------------------------------------------------*/

void NCinit_tool_vars(void)

/*
 * ABSTRACT:   Initialize_tool_vars initializes tool-related data structures.
 *
 * HISTORY:   07/20/88   Created.         C. M. Jablonski
 *
 */

{
   IGRint     index;
   IGRdouble  ca;
   IGRdouble  sa;
   IGRdouble  angle;
   IGRdouble  length;
   IGRpoint   xsect_vect;

   /*
    * Set up the xsect matrix, which will contain all the tool cross-sections 
    * in world coordinates.
    */

   /* Using the orientation vectors, calculate all the cross-sections */
   for ( index=0; index < NCtool_data.num_xsect; index++ )
   {
      /* calculate the angle between the "xsect_vect" vector and the xsect 
       * vector
       */
      angle = (IGRdouble)(index * PI) / (IGRdouble)NCtool_data.num_xsect;
      ca = cos(angle);
      sa = sin(angle);

      /* calculate the xsect vector (in the plane of the cross-section) */
      xsect_vect[0] = (ca * NCtool_orient.xsect[0]) +
                                           (sa * NCtool_orient.perp[0]);
      xsect_vect[1] = (ca * NCtool_orient.xsect[1]) +
                                           (sa * NCtool_orient.perp[1]);
      xsect_vect[2] = (ca * NCtool_orient.xsect[2]) +
                                           (sa * NCtool_orient.perp[2]);
      NORMALIZE(xsect_vect)

      generate_tool_xsect ( xsect_vect,
                            NCtool_data.num_curve_points,
                            curve_points,
                            NCtool_arrays.xsect[index * 
                                               NCtool_data.num_curve_points],
                            NCtool_arrays.xsect[(index + 
                                                NCtool_data.num_xsect) *
                                                NCtool_data.num_curve_points] );
   }

   /* transform to viewing coordinates */
   transform_points( FALSE,
                     2 * NCtool_data.num_curve_points * NCtool_data.num_xsect,
                     (IGRdouble *)NCtool_arrays.xsect,
                     0 );

   /* generate the normals to all the cross section facets */
   generate_facet_normals();

   /* generate vertex normals */
   if (NCtool_data.linestring)
   {
      generate_linestring_vertex_normals();
   }
   else
   {
      generate_vertex_normals();
   }

   /* initialize the five-axis profile edge arrays */
   for( index = 0;
      index < (8 * NCtool_data.num_xsect * (NCtool_data.num_curve_points - 1));
      index++ )
   {
      NCtool_arrays.orig_prof_edge[index] = NO_PROFILE_POINT;
      NCtool_arrays.dest_prof_edge[index] = NO_PROFILE_POINT;
   }

   /* initialize the five-axis dot product arrays */
   for ( index = 0;
         index < (2 * NCtool_data.num_xsect * NCtool_data.num_curve_points);
         index++ )
   {
      NCtool_arrays.orig_dp[index] = NO_DOT_PRODUCT;
      NCtool_arrays.dest_dp[index] = NO_DOT_PRODUCT;
   }
}


/*-----NCchange_active_tool---------------------------------------------------*/

void NCchange_active_tool( struct IGRbsp_curve *newtool_curve )

/*
 * ABSTRACT:   Updates all tool data.
 *
 * HISTORY:   07/20/88   Created.         C. M. Jablonski
 *
 */

{
   IGRint     index;
   IGRint     cp_index;
   IGRint     num_cvpoints;
   IGRint     num_xsect;

   IGRlong    rc;

   IGRpoint   hyp, vect;
   IGRpoint   tool_axis;
   IGRpoint   tool_xsect;
   IGRpoint   tool_perp;
   IGRpoint   *prof_points;
   IGRpoint   pt2;

   IGRdouble  max_radius;
   IGRdouble  rad;
   IGRdouble  angle;
   IGRdouble  length;
   IGRdouble  *cvpoints;
   IGRdouble  rotation[3][3];


   /* cleanup memory from the previous tool */
   NCcleanup_tool();

   /* set the linestring flag */
   NCtool_data.linestring = (newtool_curve->order == 2);

   /*
    * Tile the profile curve.
    */

   get_curve_sampling_points ( newtool_curve,
                               NCwindow.win_tol,
                               &num_cvpoints,
                               &cvpoints );

   if (prof_points = (IGRpoint *)malloc(num_cvpoints * sizeof(IGRpoint)))
   {


#if DEBUG_CURVE
{
      fprintf(stderr, "Just before tiling call...\n" );

      print_curve( newtool_curve, 0 );

      fprintf( stderr, "WIN_TOL=%f\n", NCwindow.win_tol );
      fprintf( stderr, "List of grid points:\n" );

      for( index=0; index<num_cvpoints; index++ )
      {
         fprintf( stderr, "%17.9lf \n", cvpoints[index] );
      }
}
#endif

      BScvarreval( &rc,
                   newtool_curve,
                   cvpoints,
                   num_cvpoints,
                   0,
                   (IGRdouble *)prof_points );

      if (rc != BSSUCC)
      {
         fprintf(stderr,
                 "Error in tool curve tiler: BScvarreval returned %ld\n", rc);
      }


      /*
       * Translate profile curve to origin.
       */

      vect[0] = - prof_points[0][0];
      vect[1] = - prof_points[0][1];
      vect[2] = - prof_points[0][2];

      translate_points ( vect, num_cvpoints, prof_points );

       /*
       * Rotate profile curve to current orientation.
       */

      /* derive a basis from the new tool's coordinate system */
      vect[0] = 0.0;
      vect[1] = 0.0;
      vect[2] = 1.0;
      generate_orthogonal_basis( vect, tool_xsect, tool_axis, tool_perp );

      /* create matrix to rotate new tool axis to z_axis. NOTE: will need to */
      /* substitute whichever coordinate axis produces NCtool_orient.axis    */
      /* when rotated through NCtool_orient.rotation                         */
      create_rotation_matrix( tool_perp, tool_xsect, tool_axis, rotation );

      /* rotate profile curve so that (imaginary) axis is on z_axis.         */
      /* (see NOTE)                                                          */
      rotate_points( rotation, num_cvpoints, prof_points );

      /* rotate profile curve to current orientation */
      rotate_points( NCtool_orient.rotation, num_cvpoints, prof_points );

      /*
       * Translate profile curve to current location.
       */

      translate_points ( NCtoolpath_data.curr_location,
                         num_cvpoints,
                         prof_points );


#ifdef DEBUG
{
      fprintf(stderr,"axis[0]=%f\taxis[1]=%f\taxis[2]=%f\n",
                      NCtool_orient.axis[0],
                      NCtool_orient.axis[1],
                      NCtool_orient.axis[2]);
      fprintf(stderr,"xsect[0]=%f\txsect[1]=%f\txsect[2]=%f\n",
                      NCtool_orient.xsect[0],
                      NCtool_orient.xsect[1],
                      NCtool_orient.xsect[2]);
      fprintf(stderr,"perp[0]=%f\tperp[1]=%f\tperp[2]=%f\n",
                      NCtool_orient.perp[0],
                      NCtool_orient.perp[1],
                      NCtool_orient.perp[2]);
}
#endif
      /*
       * Calculate the active tool buffer's profile point parameters.
       */

      /* set the number of curve points */
      NCtool_data.num_curve_points = num_cvpoints;

      max_radius = 0.0;
      max_rad_index = 1;
      cp_index = 0;

      if (curve_points = (IGRdouble *)malloc(2 * sizeof(IGRdouble) *
                                             NCtool_data.num_curve_points))
      {

#if DEBUG_CURVE
{
         fprintf(stderr,"in  world X world Y world Z  X wrt 0 Y wrt 0 Z wrt 0");
         fprintf(stderr,"     U       R\n");
         fprintf(stderr,"=== ======= ======= =======  ======= ======= =======");
         fprintf(stderr,"  ======= =======\n");
}
#endif
         /* Convert the (x,y,z) world coordinates for each point into (u,r)  */
         /* coordinates                                                      */
         for (index = 0; index < num_cvpoints; index++)
         {
            hyp[0] = prof_points[index][0] - prof_points[0][0];
            hyp[1] = prof_points[index][1] - prof_points[0][1];
            hyp[2] = prof_points[index][2] - prof_points[0][2];

            /* Calculate the distance along the axis */
            curve_points[cp_index++] = ( (hyp[0]*NCtool_orient.axis[0]) +
                                         (hyp[1]*NCtool_orient.axis[1]) +
                                         (hyp[2]*NCtool_orient.axis[2]) );

            /* Calculate the tool radius at that point */
            rad = (hyp[0]*hyp[0]) + (hyp[1]*hyp[1]) + (hyp[2]*hyp[2]) -
                  (curve_points[cp_index - 1] * curve_points[cp_index - 1]);

            if (ABS(rad)>ZERO_TOL)
            {
               curve_points[cp_index++] = sqrt( ABS(rad) );
            }
            else
            {
               curve_points[cp_index++] = 0.0;
            }

#if DEBUG_CURVE
{
            fprintf(stderr,"%3d%8.4f%8.4f%8.4f %8.4f%8.4f%8.4f %8.4f%8.4f\n",
                           index,
                           prof_points[index][0],
                           prof_points[index][1],
                           prof_points[index][2],
                           hyp[0],
                           hyp[1],
                           hyp[2],
                           curve_points[cp_index-2],
                           curve_points[cp_index-1]);
}
#endif

            if ((index > 0) &&
                (ABS(curve_points[cp_index - 1] - 
                                 curve_points[cp_index - 3]) < ZERO_TOL) &&
                (ABS(curve_points[cp_index - 2] -
                                 curve_points[cp_index - 4]) < ZERO_TOL))
            {
               /* duplicate profile point */
               NCtool_data.num_curve_points--;
               cp_index -= 2;
#if DEBUG_CURVE
{
               fprintf(stderr,"^^^^^ THIS SAMPLE POINT WAS IGNORED ^^^^^\n");
}
#endif
            }
            else
            {
               /* Check the index of maximum width */
               if ( curve_points[cp_index - 1] >= max_radius )
               {
                  max_radius = curve_points[cp_index - 1];
                  max_rad_index = (cp_index / 2) - 1;
               }

               /* Save the second sample point for calculating the critical */
               /* cosine                                                    */
               if (cp_index == 4)
               {
                  pt2[0] = prof_points[index][0];
                  pt2[1] = prof_points[index][1];
                  pt2[2] = prof_points[index][2];
               }
            }
         }

#if DEBUG_CURVE
{
         fprintf(stderr,"\nTHE FINAL SAMPLE POINT LIST IS:\n");
         for (index = 0; index < NCtool_data.num_curve_points; index++)
         {
            fprintf(stderr,"U[%d]=%f, R[%d]=%f\n", index,
                                                   curve_points[index*2],
                                                   index,
                                                   curve_points[index*2+1]);
         }
}
#endif

         /*
          * Save the tool height.
          */

         NCtool_data.height = curve_points[(NCtool_data.num_curve_points - 1)
                                            * 2];

         /*
          * Set the open_ended flag.
          */

         if (curve_points[NCtool_data.num_curve_points * 2 - 1] == 0.0)
         {
            if (curve_points[NCtool_data.num_curve_points * 2 - 2] !=
                curve_points[NCtool_data.num_curve_points * 2 - 4])
            {
               NCtool_data.open_ended = FALSE;
            }
            else
            {
               NCtool_data.num_curve_points--;
               NCtool_data.open_ended = TRUE;
            }
         }
         else
         {
            NCtool_data.open_ended = TRUE;
         }

         /*
          * Calculate the cosine of the critical angle.  If the angle between
          * the path curve and the axis is less than this critical angle, then
          * it will be necessary to use modified profile projection for the
          * swept volume.  If, on the other hand, the angle is greater, then
          * we can use standard profile projection.
          */

         hyp[0] = pt2[0] - prof_points[0][0];
         hyp[1] = pt2[1] - prof_points[0][1];
         hyp[2] = pt2[2] - prof_points[0][2];
         NORMALIZE(hyp);

         NCtool_data.critical_cosine = hyp[0] * NCtool_orient.axis[0] +
                                       hyp[1] * NCtool_orient.axis[1] +
                                       hyp[2] * NCtool_orient.axis[2];

         if (NCtool_data.critical_cosine<ZERO_TOL)
         {
            NCtool_data.critical_cosine = ZERO_TOL;
         }

         /*
          * Calculate the number of cross-sections, (tile the maximum radius).
          * NOTE: the number of cross-sections must be divisible by 2 for
          * build_profile to work properly.
          */

         length = (max_radius - NCwindow.win_tol) / max_radius;
         if (length < -1.0)
         {
            angle = PI;
         }
         else
         {
            angle = acos(length);
         }

         num_xsect = PI / (2.0 * angle);
         NCtool_data.num_xsect = (IGRint)(num_xsect / 2) * 2;

         if (NCtool_data.num_xsect < 2)
         {
            NCtool_data.num_xsect = 2;
         }

         /*
          * Calculate the cosine to be used as a tolerance when generating
          * five-axis swept volume facets.
          */

         NCtool_data.fax_facet_cosine =
               cos(((PI / 2.0) - (PI / ((IGRdouble)(NCtool_data.num_xsect)))));


         /*
          * Allocate tool-related data structures.
          */

         alloc_tool_vars( NCtool_data.num_xsect, NCtool_data.num_curve_points );


         /*
          * Initialize tool-related data structures.
          */

         if (!NCerror_flags.memory_fault)
         {
            NCinit_tool_vars();
         }
      }
      else
      {
         /* could not allocate curve_points */
         NCerror_flags.memory_fault = TRUE;
      }

      free (prof_points);
   }
   else
   {
      /* could not allocate prof_points */
      NCerror_flags.memory_fault = TRUE;
   }

   /* free the local memory */
   free (cvpoints);
}
