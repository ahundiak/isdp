
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"
#include "igrtypedef.h"

#include "exsysdep.h"
#include "igetypedef.h"
#include "igr.h"
#include "hsmath.h"
#include "hstiler.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "hnmilling.h"
#include "hntool.h"
#include "hsdisplay.h"
#include "hnmill.h"

#include "HSpr_ncv_fun.h"

/*-----------------------
 *  for functions
 *     HSnegate_facet_normal
 *     HSnormalize_facet_normal
 *     HSset_facet_normal
 *     HSset_front_facing_flag
 *     clip_and_shade
 *     do_const_depth_cueing
 *     do_smooth_depth_cueing
 *     find_const_shades
 *     find_smooth_shades
 *     front_facing_facet
 */

#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*------------------------------
 *  for function
 *     form_trap
 */

#include "hslight.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"
#include "HSpr_pbust_f.h"

/*------------------------------*/


#define IROUND(n)    ((unsigned char) (n + 0.5))
#define XZROUND(n)   ((unsigned long) (n + 0.5))

#ifdef BIG_ENDIAN
#define SHIFT_16(n)  (n = (n) * 65536)
#else
#define SHIFT_16(n)  (((int *) &n)[1] += 0x01000000)
#endif

#define ZERO_TOL     1.0e-5

#define USE_NEG_OF_DOT_PRODUCT   1
#define USE_DOT_PRODUCT          2

#define DEBUG                    0

#define NORMALIZE(vector)                                              \
{                                                                      \
   length = sqrt((vector[0] * vector[0]) + (vector[1] * vector[1]) +   \
            (vector[2] * vector[2]));                                  \
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

extern struct NC_tool_data      NCtool_data;
extern struct NC_tool_arrays    NCtool_arrays;
extern struct NC_shading_parms  NCshading;

/*-----NCtile_tool------------------------------------------------------------*/

void NCtile_tool(void)

/*
 * ABSTRACT:   NCtile_tool tiles the entire tool as it is found in xsect.
 *
 * HISTORY: 09/12/88   Created.                       C. M. Jablonski
 *          12/06/89   Rewritten to increase speed.   M. R. Giesy
 *
 */

{
   IGRboolean       bottom_half = TRUE;
   IGRint           xindex;
   IGRint           nxindex;
   IGRint           pindex;
   IGRint           this_xsect;
   IGRint           next_xsect;
   IGRint           thispt;
   IGRint           nextpt;

   struct HSvertex  face[4];

   IGRint           index;

   IGRpoint         va;
   IGRpoint         vb;
   IGRpoint         norm;

   IGRdouble        length;


   /*****************************************************/
   /* Generate and process the tool's side facet loops. */
   /*****************************************************/

   for ( index = 0; index < (2 * NCtool_data.num_xsect); index++ )
   {
      NCtool_arrays.minpind[index] = NCtool_data.num_curve_points - 1;
   }

#if DEBUG
   fprintf(stderr, "num_xsect = %d\n", NCtool_data.num_xsect);
#endif

   for ( xindex=0; xindex<(2 * NCtool_data.num_xsect); xindex++ )
   {
#if DEBUG
      fprintf(stderr, "xindex = %d\n", xindex);
#endif

      /* this_xsect will point to the beginning of each cross-section */
      this_xsect = xindex * NCtool_data.num_curve_points;

      /* set next_xsect to point to the beginning of the next cross-section */
      nxindex = (xindex + 1) % (2 * NCtool_data.num_xsect);
      next_xsect = nxindex * NCtool_data.num_curve_points;

      if (bottom_half)
      {
         /*
         * Build facets out of those points whose indexes are less than the
         * value in minpind, (the "bottom half" of the tool).
         */

         for ( pindex=1;
               ((pindex<=NCtool_arrays.minpind[xindex]) ||
               (pindex<=NCtool_arrays.minpind[nxindex]));
               pindex++ )
         {
            /* thispt will point to each point in the cross section starting */
            /* at this_xsect                                                 */
            thispt = this_xsect + pindex;

            if (ABS(NCtool_arrays.fnorm[thispt][2]) > ZERO_TOL)
            {
               /* nextpt will point to each point in the cross section 
                  starting at next_xsect */
               nextpt = next_xsect + pindex;

               /* set the facet normal */
               HSset_facet_normal( NCtool_arrays.fnorm[thispt][0],
                                   NCtool_arrays.fnorm[thispt][1],
                                   NCtool_arrays.fnorm[thispt][2] );

               /* create the facet loop */
               if (NCtool_data.linestring)
               {
                  face[0].coord[0] = NCtool_arrays.xsect[thispt][0];
                  face[0].coord[1] = NCtool_arrays.xsect[thispt][1];
                  face[0].coord[2] = NCtool_arrays.xsect[thispt][2];
                  face[0].coord[3] = 1.0;
                  face[0].edge_flag = FALSE;
                  face[0].next =  (struct HSvertex *) &face[1].coord[0];

                  face[1].coord[0] = NCtool_arrays.xsect[thispt-1][0];
                  face[1].coord[1] = NCtool_arrays.xsect[thispt-1][1];
                  face[1].coord[2] = NCtool_arrays.xsect[thispt-1][2];
                  face[1].coord[3] = 1.0;
                  face[1].edge_flag = FALSE;
                  face[1].next = (struct HSvertex *) &face[2].coord[0];

                  face[2].coord[0] = NCtool_arrays.xsect[nextpt-1][0];
                  face[2].coord[1] = NCtool_arrays.xsect[nextpt-1][1];
                  face[2].coord[2] = NCtool_arrays.xsect[nextpt-1][2];
                  face[2].coord[3] = 1.0;
                  face[2].edge_flag = FALSE;
                  face[2].next = (struct HSvertex *) &face[3].coord[0];

                  face[3].coord[0] = NCtool_arrays.xsect[nextpt][0];
                  face[3].coord[1] = NCtool_arrays.xsect[nextpt][1];
                  face[3].coord[2] = NCtool_arrays.xsect[nextpt][2];
                  face[3].coord[3] = 1.0;
                  face[3].edge_flag = FALSE;
                  face[3].next = (struct HSvertex *) &face[0];

                  if (element_parms.doing_vertex_normals)
                  {
                     face[0].norm[0]  = NCtool_arrays.vnorm[thispt][0];
                     face[1].norm[0]  = NCtool_arrays.vnorm[thispt][0];

                     face[0].norm[1]  = NCtool_arrays.vnorm[thispt][1];
                     face[1].norm[1]  = NCtool_arrays.vnorm[thispt][1];

                     face[0].norm[2]  = NCtool_arrays.vnorm[thispt][2];
                     face[1].norm[2]  = NCtool_arrays.vnorm[thispt][2];

                     face[2].norm[0]  = NCtool_arrays.vnorm[nextpt][0];
                     face[3].norm[0]  = NCtool_arrays.vnorm[nextpt][0];

                     face[2].norm[1]  = NCtool_arrays.vnorm[nextpt][1];
                     face[3].norm[1]  = NCtool_arrays.vnorm[nextpt][1];

                     face[2].norm[2]  = NCtool_arrays.vnorm[nextpt][2];
                     face[3].norm[2]  = NCtool_arrays.vnorm[nextpt][2];
                  }
               }
               else
               {
                  face[0].coord[0] = NCtool_arrays.xsect[thispt][0];
                  face[0].coord[1] = NCtool_arrays.xsect[thispt][1];
                  face[0].coord[2] = NCtool_arrays.xsect[thispt][2];
                  face[0].coord[3] = 1.0;
                  face[0].edge_flag = FALSE;
                  face[0].next = (struct HSvertex *) &face[1];

                  face[1].coord[0] = NCtool_arrays.xsect[thispt-1][0];
                  face[1].coord[1] = NCtool_arrays.xsect[thispt-1][1];
                  face[1].coord[2] = NCtool_arrays.xsect[thispt-1][2];
                  face[1].coord[3] = 1.0;
                  face[1].edge_flag = FALSE;
                  face[1].next = (struct HSvertex *) &face[2];

                  face[2].coord[0] = NCtool_arrays.xsect[nextpt-1][0];
                  face[2].coord[1] = NCtool_arrays.xsect[nextpt-1][1];
                  face[2].coord[2] = NCtool_arrays.xsect[nextpt-1][2];
                  face[2].coord[3] = 1.0;
                  face[2].edge_flag = FALSE;
                  face[2].next = (struct HSvertex *) &face[3];

                  face[3].coord[0] = NCtool_arrays.xsect[nextpt][0];
                  face[3].coord[1] = NCtool_arrays.xsect[nextpt][1];
                  face[3].coord[2] = NCtool_arrays.xsect[nextpt][2];
                  face[3].coord[3] = 1.0;
                  face[3].edge_flag = FALSE;
                  face[3].next = (struct HSvertex *) &face[0];

                  if (element_parms.doing_vertex_normals)
                  {
                     face[0].norm[0]  = NCtool_arrays.vnorm[thispt][0];
                     face[0].norm[1]  = NCtool_arrays.vnorm[thispt][1];
                     face[0].norm[2]  = NCtool_arrays.vnorm[thispt][2];

                     face[1].norm[0]  = NCtool_arrays.vnorm[thispt-1][0];
                     face[1].norm[1]  = NCtool_arrays.vnorm[thispt-1][1];
                     face[1].norm[2]  = NCtool_arrays.vnorm[thispt-1][2];

                     face[2].norm[0]  = NCtool_arrays.vnorm[nextpt-1][0];
                     face[2].norm[1]  = NCtool_arrays.vnorm[nextpt-1][1];
                     face[2].norm[2]  = NCtool_arrays.vnorm[nextpt-1][2];

                     face[3].norm[0]  = NCtool_arrays.vnorm[nextpt][0];
                     face[3].norm[1]  = NCtool_arrays.vnorm[nextpt][1];
                     face[3].norm[2]  = NCtool_arrays.vnorm[nextpt][2];
                  }
               }

               /* bust the face and save trapezoids for dexelizing */
               NCtool_pbust(face);
            }
         }
      }
      else
      {
         /*
          * Build facets out of those points whose indexes are greater than
          * the value in minpind, (the "top half" of the tool).
          */
         for ( pindex=1;
               ((pindex<=NCtool_arrays.minpind[xindex]) ||
               (pindex<=NCtool_arrays.minpind[nxindex]));
               pindex++ );

         for ( ; pindex<NCtool_data.num_curve_points; pindex++ )
         {
            /* thispt will point to each point in the cross section starting */
            /* at this_xsect                                                 */
            thispt = this_xsect + pindex;

            /* nextpt will point to each point in the cross section starting */
            /* at next_xsect                                                 */
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
                  face[0].coord[0] = NCtool_arrays.xsect[thispt][0];
                  face[0].coord[1] = NCtool_arrays.xsect[thispt][1];
                  face[0].coord[2] = NCtool_arrays.xsect[thispt][2];
                  face[0].coord[3] = 1.0;
                  face[0].edge_flag = FALSE;
                  face[0].next = (struct HSvertex *) &face[1];

                  face[1].coord[0] = NCtool_arrays.xsect[thispt-1][0];
                  face[1].coord[1] = NCtool_arrays.xsect[thispt-1][1];
                  face[1].coord[2] = NCtool_arrays.xsect[thispt-1][2];
                  face[1].coord[3] = 1.0;
                  face[1].edge_flag = FALSE;
                  face[1].next = (struct HSvertex *) &face[2];

                  face[2].coord[0] = NCtool_arrays.xsect[nextpt-1][0];
                  face[2].coord[1] = NCtool_arrays.xsect[nextpt-1][1];
                  face[2].coord[2] = NCtool_arrays.xsect[nextpt-1][2];
                  face[2].coord[3] = 1.0;
                  face[2].edge_flag = FALSE;
                  face[2].next = (struct HSvertex *) &face[3];

                  face[3].coord[0] = NCtool_arrays.xsect[nextpt][0];
                  face[3].coord[1] = NCtool_arrays.xsect[nextpt][1];
                  face[3].coord[2] = NCtool_arrays.xsect[nextpt][2];
                  face[3].coord[3] = 1.0;
                  face[3].edge_flag = FALSE;
                  face[3].next = (struct HSvertex *) &face[0];

                  if (element_parms.doing_vertex_normals)
                  {
                     face[0].norm[0]  = NCtool_arrays.vnorm[thispt][0];
                     face[1].norm[0]  = NCtool_arrays.vnorm[thispt][0];

                     face[0].norm[1]  = NCtool_arrays.vnorm[thispt][1];
                     face[1].norm[1]  = NCtool_arrays.vnorm[thispt][1];

                     face[0].norm[2]  = NCtool_arrays.vnorm[thispt][2];
                     face[1].norm[2]  = NCtool_arrays.vnorm[thispt][2];

                     face[2].norm[0]  = NCtool_arrays.vnorm[nextpt][0];
                     face[3].norm[0]  = NCtool_arrays.vnorm[nextpt][0];

                     face[2].norm[1]  = NCtool_arrays.vnorm[nextpt][1];
                     face[3].norm[1]  = NCtool_arrays.vnorm[nextpt][1];

                     face[2].norm[2]  = NCtool_arrays.vnorm[nextpt][2];
                     face[3].norm[2]  = NCtool_arrays.vnorm[nextpt][2];
                  }
               }
               else
               {
                  face[0].coord[0] = NCtool_arrays.xsect[thispt][0];
                  face[0].coord[1] = NCtool_arrays.xsect[thispt][1];
                  face[0].coord[2] = NCtool_arrays.xsect[thispt][2];
                  face[0].coord[3] = 1.0;
                  face[0].edge_flag = FALSE;
                  face[0].next = (struct HSvertex *) &face[1];

                  face[1].coord[0] = NCtool_arrays.xsect[thispt-1][0];
                  face[1].coord[1] = NCtool_arrays.xsect[thispt-1][1];
                  face[1].coord[2] = NCtool_arrays.xsect[thispt-1][2];
                  face[1].coord[3] = 1.0;
                  face[1].edge_flag = FALSE;
                  face[1].next = (struct HSvertex *) &face[2];

                  face[2].coord[0] = NCtool_arrays.xsect[nextpt-1][0];
                  face[2].coord[1] = NCtool_arrays.xsect[nextpt-1][1];
                  face[2].coord[2] = NCtool_arrays.xsect[nextpt-1][2];
                  face[2].coord[3] = 1.0;
                  face[2].edge_flag = FALSE;
                  face[2].next = (struct HSvertex *) &face[3];

                  face[3].coord[0] = NCtool_arrays.xsect[nextpt][0];
                  face[3].coord[1] = NCtool_arrays.xsect[nextpt][1];
                  face[3].coord[2] = NCtool_arrays.xsect[nextpt][2];
                  face[3].coord[3] = 1.0;
                  face[3].edge_flag = FALSE;
                  face[3].next = (struct HSvertex *) &face[0];

                  if (element_parms.doing_vertex_normals)
                  {
                     face[0].norm[0]  = NCtool_arrays.vnorm[thispt][0];
                     face[0].norm[1]  = NCtool_arrays.vnorm[thispt][1];
                     face[0].norm[2]  = NCtool_arrays.vnorm[thispt][2];

                     face[1].norm[0]  = NCtool_arrays.vnorm[thispt-1][0];
                     face[1].norm[1]  = NCtool_arrays.vnorm[thispt-1][1];
                     face[1].norm[2]  = NCtool_arrays.vnorm[thispt-1][2];

                     face[2].norm[0]  = NCtool_arrays.vnorm[nextpt-1][0];
                     face[2].norm[1]  = NCtool_arrays.vnorm[nextpt-1][1];
                     face[2].norm[2]  = NCtool_arrays.vnorm[nextpt-1][2];

                     face[3].norm[0]  = NCtool_arrays.vnorm[nextpt][0];
                     face[3].norm[1]  = NCtool_arrays.vnorm[nextpt][1];
                     face[3].norm[2]  = NCtool_arrays.vnorm[nextpt][2];
                  }
               }

               /* bust the face and save the trapezoids for dexelizing */
               NCtool_pbust(face);
            }
         }
      }
   }


   /*******************************************************/
   /* if necessary, cap the top of area we just swept out */
   /*******************************************************/

   if (NCtool_data.open_ended)
   {
      /* set the shading style */
      HSset_dexel_shading_style( NCshading.CONSTANT_SHADING );

      /* set the facet normal */
      va[0] = NCtool_arrays.xsect[(2 * NCtool_data.num_curve_points) + 2][0] -
                              NCtool_arrays.xsect[2][0];
      va[1] = NCtool_arrays.xsect[(2 * NCtool_data.num_curve_points) + 2][1] -
                              NCtool_arrays.xsect[2][1];
      va[2] = NCtool_arrays.xsect[(2 * NCtool_data.num_curve_points) + 2][2] -
                              NCtool_arrays.xsect[2][2];

      vb[0] = NCtool_arrays.xsect[NCtool_data.num_curve_points + 2][0] -
                              NCtool_arrays.xsect[2][0];
      vb[1] = NCtool_arrays.xsect[NCtool_data.num_curve_points + 2][1] -
                              NCtool_arrays.xsect[2][1];
      vb[2] = NCtool_arrays.xsect[NCtool_data.num_curve_points + 2][2] -
                              NCtool_arrays.xsect[2][2];

      CROSS( va, vb, norm )
      NORMALIZE( norm )

      if (ABS(norm[2]) > ZERO_TOL)
      {
         HSset_facet_normal( norm[0], norm[1], norm[2] );

         /* create the facet loop */
         for( index = (2 * NCtool_data.num_xsect * 
                      NCtool_data.num_curve_points) - 1;
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
      }

      /* reset the shading style */
      HSset_dexel_shading_style( NCshading.active_shading_style );
   }
}

/*-----NCtool_pbust---------------------------------------------------------*/

int NCtool_pbust( struct HSvertex face[4] )

{
   unsigned long    x0;
   unsigned long    x1;
   unsigned long    x2;
   unsigned long    x3;

   unsigned long    z0;
   unsigned long    z1;
   unsigned long    z2;
   unsigned long    z3;

   unsigned char    s0;
   unsigned char    s1;
   unsigned char    s2;
   unsigned char    s3;

   IGRdouble        y_change;
   IGRdouble        z_scale;

   IGRint           mi;
   IGRint           mj;
   IGRint           prev_vertex;
   IGRint           next_vertex;
   IGRint           curr_forward;
   IGRint           curr_backward;

   int              temp_y0;
   int              temp_y1;
   int              temp_y2;
   int              temp_y3;

   IGRboolean       done_busting;

   struct HSvertex  busted;


   /* determine front or back-facing */
   HSset_front_facing_flag( element_parms.facet_normal[2] < 0.0 );

   /* calculate shades for each vertex of the face */
   switch (element_parms.facet_type)
   {
      case SMOOTH_SHADE:
         if (element_parms.front_facing_facet)
         {
            find_smooth_shades( face,
                                USE_NEG_OF_DOT_PRODUCT,
                                1.0,
                                1.0,
                                1.0 );
         }
         else
         {
            find_smooth_shades( face,
                                USE_DOT_PRODUCT,
                                1.0,
                                1.0,
                                1.0 );
         }

         /*
          * Apply depth cueing
         */

         if (active_window->depth_cue_on)
         {
            do_smooth_depth_cueing (face, 2);
         }

#if DEBUG
         fprintf(stderr, "did shade calculation...\n");
#endif
         break;

      case CONST_SHADE:

         HSnormalize_facet_normal();

         if (!(element_parms.front_facing_facet))
         {
            HSnegate_facet_normal();
         }

         find_const_shades ( face,
                             USE_NEG_OF_DOT_PRODUCT,
                             1.0,
                             1.0,
                             1.0 );

         /* place calculated shade in every vertex for this loop */

         face[1].norm[0] = face[0].norm[0];
         face[2].norm[0] = face[0].norm[0];
         face[3].norm[0] = face[0].norm[0];

         /*
          * Apply depth cueing
          */

         if (active_window->depth_cue_on)
         {
            do_const_depth_cueing (face, 2);
         }
         break;
   } /* end switch */

   /* bust it -- find the vert w/ min y, create 0, 1, 2 or 3 traps and make */
   /* calls to form_trap                                                    */

   /* determine the vertex with the minimum y value, rounding the y values  */
   /* before comparing                                                      */
   if((temp_y0 = ROUND(face[0].coord[1])) < (temp_y1 = ROUND(face[1].coord[1])))
   {
      mi = 0;
   }
   else
   {
      mi = 1;
   }

   if((temp_y2 = ROUND(face[2].coord[1])) < (temp_y3 = ROUND(face[3].coord[1])))
   {
      mj = 2;
   }
   else
   {
      mj = 3;
   }

   if (face[mi].coord[1] > face[mj].coord[1])
   {
      mi = mj;
   }

   face[0].coord[1] = temp_y0;
   face[1].coord[1] = temp_y1;
   face[2].coord[1] = temp_y2;
   face[3].coord[1] = temp_y3;

#if DEBUG
   for (mj=0; mj < 4; mj++)
   {
      fprintf(stderr, "x[%d] = %f\n", mj, face[mj].coord[0]);
      fprintf(stderr, "y[%d] = %f\n", mj, face[mj].coord[1]);
      fprintf(stderr, "z[%d] = %f\n", mj, face[mj].coord[2]);
      fprintf(stderr, "s[%d] = %f\n", mj, face[mj].norm[0]);
   }
#endif

   /* shift the x values */
   SHIFT_16(face[0].coord[0]);
   SHIFT_16(face[1].coord[0]);
   SHIFT_16(face[2].coord[0]);
   SHIFT_16(face[3].coord[0]);

   /* scale the z values */
   z_scale = tiling_parms.maximum_z /
             (active_window->z_max - active_window->z_min  );

   face[0].coord[2] = (face[0].coord[2] - active_window->z_min) * z_scale;
   face[1].coord[2] = (face[1].coord[2] - active_window->z_min) * z_scale;
   face[2].coord[2] = (face[2].coord[2] - active_window->z_min) * z_scale;
   face[3].coord[2] = (face[3].coord[2] - active_window->z_min) * z_scale;

   /* bust the face into trapezoids */
   next_vertex = (mi + 1) % 4;
   prev_vertex = (mi + 3) % 4;
   curr_forward = curr_backward = mi;
   done_busting = FALSE;

   while (!done_busting)
   {
      /* get rid of horizontal edges forward */
      while ((face[curr_forward].coord[1] == face[next_vertex].coord[1]) &&
            (!(done_busting = (next_vertex == curr_backward))))
      {
         curr_forward = next_vertex;
         next_vertex = (curr_forward + 1) % 4;
      }

      /* get rid of horizontal edges backward */
      while ((face[curr_backward].coord[1] == face[prev_vertex].coord[1]) &&
            (!(done_busting = (curr_forward == prev_vertex))))
      {
         curr_backward = prev_vertex;
         prev_vertex = (curr_backward + 3) % 4;
      }

      if (done_busting)
      {
         break; /* quit if no more busting to do */
      }

      /* bust and interp */
      if (face[prev_vertex].coord[1] <= face[next_vertex].coord[1])
      {
         /* calc change in y at bust point */
         if (face[prev_vertex].coord[1] != face[next_vertex].coord[1])
         {
            y_change = (face[prev_vertex].coord[1] -
                        face[curr_forward].coord[1]) /
                       (face[next_vertex].coord[1] -
                        face[curr_forward].coord[1]);
            /* bust an edge */
            busted.coord[0] = y_change *
                              (face[next_vertex].coord[0] -
                              face[curr_forward].coord[0]) +
                              face[curr_forward].coord[0];

            busted.coord[1] = face[prev_vertex].coord[1];

            busted.coord[2] = y_change *
                              (face[next_vertex].coord[2] -
                              face[curr_forward].coord[2]) +
                              face[curr_forward].coord[2];

            busted.norm[0] =  y_change *
                              (face[next_vertex].norm[0] -
                              face[curr_forward].norm[0]) +
                              face[curr_forward].norm[0];
         }
         else
         {
            busted.coord[0] = face[next_vertex].coord[0];
            busted.coord[1] = face[next_vertex].coord[1];
            busted.coord[2] = face[next_vertex].coord[2];
            busted.norm[0] = face[next_vertex].norm[0];
         }

         /* call form_trap to save the trapezoid for dexelizing */
         if ((face[prev_vertex].coord[0] < face[next_vertex].coord[0]) ||
             (face[curr_backward].coord[0] < face[curr_forward].coord[0]))
         {
            x0 = XZROUND( face[prev_vertex].coord[0] );
            x1 = XZROUND( busted.coord[0] );
            x2 = XZROUND( face[curr_backward].coord[0] );
            x3 = XZROUND( face[curr_forward].coord[0] );

            z0 = XZROUND( face[prev_vertex].coord[2] );
            z1 = XZROUND( busted.coord[2] );
            z2 = XZROUND( face[curr_backward].coord[2] );
            z3 = XZROUND( face[curr_forward].coord[2] );

            s0 = IROUND( face[prev_vertex].norm[0] );
            s1 = IROUND( busted.norm[0] );
            s2 = IROUND( face[curr_backward].norm[0] );
            s3 = IROUND( face[curr_forward].norm[0] );
         }
         else
         {
            x0 = XZROUND( busted.coord[0] );
            x1 = XZROUND( face[prev_vertex].coord[0] );
            x2 = XZROUND( face[curr_forward].coord[0] );
            x3 = XZROUND( face[curr_backward].coord[0] );

            z0 = XZROUND( busted.coord[2] );
            z1 = XZROUND( face[prev_vertex].coord[2] );
            z2 = XZROUND( face[curr_forward].coord[2] );
            z3 = XZROUND( face[curr_backward].coord[2] );

            s0 = IROUND( busted.norm[0] );
            s1 = IROUND( face[prev_vertex].norm[0] );
            s2 = IROUND( face[curr_forward].norm[0] );
            s3 = IROUND( face[curr_backward].norm[0] );
         }

         form_trap( (unsigned long)busted.coord[1],
                    (unsigned long)face[curr_forward].coord[1],
                     x0, x2, x1, x3,
                     z0, z2, z1, z3,
                     s0, s2, s1, s3, 0 );

         /* reset indeces for next bust */
         face[curr_forward].coord[0] = busted.coord[0];
         face[curr_forward].coord[1] = busted.coord[1];
         face[curr_forward].coord[2] = busted.coord[2];
         face[curr_forward].norm[0] = busted.norm[0];

         curr_backward = prev_vertex;
         prev_vertex = (curr_backward + 3) % 4;
      }
      else
      {
         y_change = (face[next_vertex].coord[1] -
                     face[curr_backward].coord[1]) /
                    (face[prev_vertex].coord[1] -
                     face[curr_backward].coord[1]);

         busted.coord[0] = y_change *
                           (face[prev_vertex].coord[0] -
                           face[curr_backward].coord[0]) +
                           face[curr_backward].coord[0];

         busted.coord[1] = face[next_vertex].coord[1];

         busted.coord[2] = y_change *
                           (face[prev_vertex].coord[2] -
                           face[curr_backward].coord[2]) +
                           face[curr_backward].coord[2];

         busted.norm[0] =  y_change *
                           (face[prev_vertex].norm[0] -
                           face[curr_backward].norm[0]) +
                           face[curr_backward].norm[0];

         /* call form_trap to save the trapezoid for dexelizing */
         if ((face[prev_vertex].coord[0] < face[next_vertex].coord[0]) ||
             (face[curr_backward].coord[0] < face[curr_forward].coord[0]))
         {
            x0 = XZROUND( busted.coord[0] );
            x1 = XZROUND( face[next_vertex].coord[0] );
            x2 = XZROUND( face[curr_backward].coord[0] );
            x3 = XZROUND( face[curr_forward].coord[0] );

            z0 = XZROUND( busted.coord[2] );
            z1 = XZROUND( face[next_vertex].coord[2] );
            z2 = XZROUND( face[curr_backward].coord[2] );
            z3 = XZROUND( face[curr_forward].coord[2] );

            s0 = IROUND( busted.norm[0] );
            s1 = IROUND( face[next_vertex].norm[0] );
            s2 = IROUND( face[curr_backward].norm[0] );
            s3 = IROUND( face[curr_forward].norm[0] );
         }
         else
         {
            x0 = XZROUND( face[next_vertex].coord[0] );
            x1 = XZROUND( busted.coord[0] );
            x2 = XZROUND( face[curr_forward].coord[0] );
            x3 = XZROUND( face[curr_backward].coord[0] );

            z0 = XZROUND( face[next_vertex].coord[2] );
            z1 = XZROUND( busted.coord[2] );
            z2 = XZROUND( face[curr_forward].coord[2] );
            z3 = XZROUND( face[curr_backward].coord[2] );

            s0 = IROUND( face[next_vertex].norm[0] );
            s1 = IROUND( busted.norm[0] );
            s2 = IROUND( face[curr_forward].norm[0] );
            s3 = IROUND( face[curr_backward].norm[0] );
         }

         form_trap( (unsigned long) busted.coord[1],
                    (unsigned long) face[curr_backward].coord[1],
                    x0, x2, x1, x3,
                    z0, z2, z1, z3,
                    s0, s2, s1, s3, 0 );

         /* reset indeces for next bust */
         face[curr_backward].coord[0] = busted.coord[0];
         face[curr_backward].coord[1] = busted.coord[1];
         face[curr_backward].coord[2] = busted.coord[2];
         face[curr_backward].norm[0] = busted.norm[0];

         curr_forward = next_vertex;
         next_vertex = (curr_forward + 1) % 4;
      }

      done_busting = (curr_forward == curr_backward);
   }
   return(0);
}
