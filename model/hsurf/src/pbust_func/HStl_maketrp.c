
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

/***********************************************
 * This module interfaces with the polybuster. *
 ***********************************************/

#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "exsysdep.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hsmath.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "HSpr_pbust_f.h"

#include "mallocmac.h"


#define DEBUG_PATCH ((tcount > 0))
#define	DEBUG	0

/* shift the double by incrementing its exponent */
#ifdef BIG_ENDIAN
#define		SHIFT_15(n)	(n = (n) * 32768)
#define		SHIFT_16(n)	 (n = (n) * 65536)
#define		SHIFT_31(n)	 (n = (n) *   2147483648)
#else
#define         SHIFT_15(n)     (((int *) &n)[1] += 0x00f00000)
#define         SHIFT_16(n)     (((int *) &n)[1] += 0x01000000)
#define         SHIFT_31(n)     (((int *) &n)[1] += 0x01f00000)
#endif

#define		MAX_VERTICES	20
#define		ML_LAST		0x04
#define		ML_DISCONNECT	0x08

/* scale to keep normals from being exactly equal to 1 or -1 */
#if HR_NORMAL_SIZE == 16
/* it is ((2^15 - 1) / (2^15)) because our normals are signed 16-bit integers */
#define NORMAL_SCALE 0.99996948
#else
/* it is ((2^31 - 1) / (2^31)) because our normals are signed 32-bit integers */
#define NORMAL_SCALE 0.999999999534
#endif

/*	Clipping parameters	*/

#define		CL_DISCONNECT	0x01    /* clipping disconnect flag */
#define		CL_POLY_CLOSE	0x02    /* last polygon vertice to clip */


static struct HSpb_edge *mlist0;        /* Master List double buffer */
static struct HSpb_master *mlist1;

/*  Sorted intersection points represented as index values of the
 *	Master List.
 */

static int *isort0;
static int *isort1;

/*	Parameters for building the Master List -- this list
 *	is double buffered.
 */

static int first;       /* first vertex in sub poly */

static int tcount = 0;

/*---make_trapezoids------------------------------------------------------*/

int make_trapezoids (double x,
                     double y,
                     double z,
                     double w,
                     double intensity,
                     double v_val,
                     double znorm,
                     double u,
                     double v,
                     IGRshort percent,
                     IGRshort edge_mark,
                     int clip_flag)

   {
   register int                i;
   int                         max_list;
   register struct HSpb_master *ml;
   int                         temp_y;
   static int                  next_list;
   static int                  firsttime = 1;
   static int                  firstclip = 1;
   static int                  max_poly;

   /* Save each vertex (x,y) in the Master List.	 */

   /*
    * The firsttime in the polygon clipper memory must be allocated for the
    * Master List, the Sorted intersection list and the output list.
    */

   if (firsttime)
      {
      mlist1 = MALLOCsn( HSpb_master, MAX_VERTICES );
      firsttime = 0;
      clip_flag = 0;
      next_list = 0;
      first = 0;
      max_poly = MAX_VERTICES;
      }

   if (next_list >= max_poly)
      {
      max_poly = max_poly * 10;
      mlist1 = REALLOCsn( mlist1, HSpb_master, max_poly );

      if (!firstclip)
         {
         mlist0 = REALLOCsn( mlist0, HSpb_edge, max_poly );
         isort0 = REALLOCn( isort0, int, max_poly );
         isort1 = REALLOCn( isort1, int, max_poly );
         }
      }

   ml = &mlist1[next_list];
   if (element_parms.facet_type == FEM_TILE ||
       element_parms.facet_type == RASTER_EDGES)
      {
      ml->mrk = edge_mark ? 2 : 0;

      if (next_list > 0)
         if (mlist1[next_list - 1].mrk & 2)
            mlist1[next_list].mrk |= 1;

      ml->pt[4] = (double) (percent >> 7);
      ml->u_pt = intensity;
      ml->v_pt = v_val;

      if (element_parms.facet_type == RASTER_EDGES &&
          tiling_parms.processing_mode & HS_PMODE_SHADED_PLOT)
         {
#        ifndef MICROCODE
         ml->pt[0] = y;
         ml->pt[1] = x;
#        endif
         }
      else
         {
         ml->pt[0] = x;
         ml->pt[1] = y;
         }
      }

   else 
   if (element_parms.facet_type == RENDERED ||
       tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
      {
      ml->pt[4] = intensity;
      ml->u_pt = v_val;
      ml->v_pt = znorm;
      ml->pt[0] = y;
      ml->pt[1] = x;
      ml->pt[3] = w;
      ml->u = u;
      ml->v = v;
      }

   else
      {
      if (tiling_parms.processing_mode & HS_PMODE_SHADED_PLOT)
         {
#        ifndef MICROCODE
         ml->pt[0] = y;
         ml->pt[1] = x;
#        endif
         }
      else
         {
         if (element_parms.facet_type == FEM_MESH)
            {
            /* ml->intensity = intensity; red */
            ml->u_pt = v_val;   /* green */
            ml->v_pt = znorm;   /* blue */
            }

         ml->pt[0] = x;
         ml->pt[1] = y;
         }
      ml->pt[4] = intensity;
      }

   ml->pt[2] = z;
   ml->blink = next_list - 1;
   ml->flink = next_list + 1;
   ml->f1.flag[1] = 0;

   /*
    * When a disconnect is received for a sub-poly, the forward link for the
    * disconnected vertex links back to the first vertex. This is sent by a
    * pmovexx() command.
    */

   if (clip_flag & CL_DISCONNECT)
      {
      if (next_list > 0)
         {
         ml = &mlist1[next_list - 1];
         ml->flink = first;
         mlist1[first].blink = next_list - 1;
         if (ml->mrk & 2) mlist1[first].mrk += 1;
         first = next_list;
         ml->f1.flag[1] = ML_DISCONNECT;
         }
      }

   /*
    * Continue storing vertices in the Master List until the polygon close
    * pclose() has been sent.  i.e. ready to start clipping.
    */

   if (clip_flag & CL_POLY_CLOSE)
      {
      ml = &mlist1[next_list - 1];
      ml->f1.flag[1] = ML_LAST | ML_DISCONNECT;
      ml->flink = first;
      mlist1[first].blink = next_list - 1;
      if (ml->mrk & 2) mlist1[first].mrk += 1;
      max_list = next_list;
      next_list = 0;
      }
   else
      {
      next_list++;
      return (0);
      }

   /*
    * When a Polygon Close is received, build the list of new clipped
    * polygons which will be inserted into the Master List. The polygon is
    * clipped to each boundary.
    */

   /* Allocate enough memory for double buffered sort lists. (only once)  */

   if (firstclip)
      {
      mlist0 = MALLOCsn( HSpb_edge, max_poly );
      isort0 = MALLOCn( int, max_poly );
      isort1 = MALLOCn( int, max_poly );
      firstclip = 0;
      }

   /*
    * Get clipping boundaries and test for trivial accept; Z's will already
    * have been scaled to either 16 or 32 bits
    */

   tcount++;

#  if DEBUG
   if (!(DEBUG_PATCH))
      return;
   fprintf (stderr, "patch number - %1d\n", tcount);
   fprintf (stderr, "  x      y            z          intensity     u     v\n");
   fprintf (stderr, "------ ------ ----------------- ------------ ----- -----\n");
#  endif

   for (i = 0; i < max_list; i++)
      {
      if (mlist1[i].pt[0] != 0.0) SHIFT_16 (mlist1[i].pt[0]);
      if (element_parms.facet_type == FEM_TILE)
         {
         if (mlist1[i].u_pt != 0.0) SHIFT_16 (mlist1[i].u_pt);
         if (mlist1[i].v_pt != 0.0) SHIFT_16 (mlist1[i].v_pt);
         }

         {
         if (element_parms.facet_type == RENDERED)
            {
#           if HR_NORMAL_SIZE == 16
            if (mlist1[i].u_pt != 0.0)
               {
               mlist1[i].u_pt *= NORMAL_SCALE;
               SHIFT_15 (mlist1[i].u_pt);
               }

            if (mlist1[i].v_pt != 0.0)
               {
               mlist1[i].v_pt *= NORMAL_SCALE;
               SHIFT_15 (mlist1[i].v_pt);
               }

            if (mlist1[i].pt[4] != 0.0)
               {
               mlist1[i].pt[4] *= NORMAL_SCALE;
               SHIFT_15 (mlist1[i].pt[4]);
               }
#           else
            if (mlist1[i].u_pt != 0.0)
               {
               mlist1[i].u_pt *= NORMAL_SCALE;
               SHIFT_31 (mlist1[i].u_pt);
               }

            if (mlist1[i].v_pt != 0.0)
               {
               mlist1[i].v_pt *= NORMAL_SCALE;
               SHIFT_31 (mlist1[i].v_pt);
               }

            if (mlist1[i].pt[4] != 0.0)
               {
               mlist1[i].pt[4] *= NORMAL_SCALE;
               SHIFT_31 (mlist1[i].pt[4]);
               }
#           endif
            }
         }

      temp_y = ROUND (mlist1[i].pt[1]);
      mlist1[i].pt[1] = temp_y;

#     if DEBUG
      fprintf (stderr, "%6.1f %6.1f %18.7f %12.8f %5.3f %5.3f\n",
               mlist1[i].pt[0] / 65535.0, mlist1[i].pt[1], mlist1[i].pt[2],
               mlist1[i].pt[4], mlist1[i].u, mlist1[i].v);
#     endif
      }


   if (tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
      poly_bust (max_list, mlist1, mlist0, isort1, isort0, 3, 1);

   else 
   if (element_parms.facet_type == FEM_TILE)
      poly_bust (max_list, mlist1, mlist0, isort1, isort0, 2, 1);

   else 
   if (element_parms.facet_type == RENDERED)
      poly_bust (max_list, mlist1, mlist0, isort1, isort0, 3, 0);

   else 
   if (element_parms.facet_type == FEM_MESH)
      poly_bust (max_list, mlist1, mlist0, isort1, isort0, 4, 1);

   else
      poly_bust (max_list, mlist1, mlist0, isort1, isort0, 1, 1);

   first = 0;
   return (0);
   }
