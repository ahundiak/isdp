
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

/* polygon busting and filling */


#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "hsmath.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "HSpr_pbust_f.h"

/*--------------------------
 *  for function
 *     HSdraw_trapezoid
 */

#include "HSpr_display.h"

/*------------------------------
 *  for functions
 *     HRalloc_span_trap
 *     HRalloc_trapezoid_uv
 *     HRbucket_sort
 *     HRbucket_sort_trapezoid
 */

#include "HSpr_render.h"

/*-------------------------------*/

#define DEBUG		0
#define PHDEBUG		0
#define TEXTURE_DEBUG	0
#define TEXTURE2_DEBUG	0

/*
#define WITHIN_TOLERANCE( y1, y2, tol )	((FABS(((y2)-(y1))) <= (tol)))
*/

#define MAXFLOAT	((float)3.4028234663852892e+38)
#define BUBSIZE		9
#define IROUND(n)	((unsigned char) (n + 0.5))
#define XZROUND(n)	((unsigned long) (n + 0.5))
#define	YROUND(n)	((int) (n + 0.5))
#define XENDROUND(n)	((long) (n + 0.5))
#define UVROUND(n)	((long) (n + 0.5))
#define	PHLROUND(n)	((int) (n + 0.5))
#define	PHSROUND(n)	((short) (n + 0.5))
#define	FEMSIZE		88      /* size of fem edge data structure */
#define PHONGSIZE	120     /* size of parallel Phong edge data structure
                                 * (was 104) */
#define PHONGWSIZE	136     /* size of perspective Phong edge data
                                 * structure (was 120) */
#define PHONGWTEXTURE	152

#if HR_NORMAL_SIZE == 16
#define PHROUND	PHSROUND
#else
#define PHROUND PHLROUND
#endif

extern struct HRspan_trapezoid *HRalloc_span_trap ();

/**********************
 * LOCAL DECLARATIONS *
 **********************/

/*
 *  Prototype declaration for static functions
 */

/* HStl_pbust.c */

extern void HPsmooth_shade_opaque_phong (
                               struct trapezoid *trap,
                               double normx0, double normy0, double normz0, 
                               double normx1, double normy1, double normz1,
                               double normx2, double normy2, double normz2, 
                               double normx3, double normy3, double normz3,
                               double w0, double w1, double w2, double w3,
                               double u0, double u1, double u2, double u3,
                               double v0, double v1, double v2, double v3);

static void HSform_phong_trap (
                       unsigned long yhigh, unsigned long ylow,
                       unsigned long x1high, unsigned long x1low,
                       unsigned long x2high, unsigned long x2low,
                       unsigned long z1high, unsigned long z1low,
                       unsigned long z2high, unsigned long z2low,
                       int rhlmark,
                       double normx0, double normy0, double normz0, 
                       double normx1, double normy1, double normz1,
                       double normx2, double normy2, double normz2, 
                       double normx3, double normy3, double normz3,
                       double w0, double w1, double w2, double w3,
                       double u0, double u1, double u2, double u3,
                       double v0, double v1, double v2, double v3);

static void HSform_fem_trap (unsigned long yhigh,
                             unsigned long ylow,
                             unsigned long x1high,
                             unsigned long x1low,
                             unsigned long x2high,
                             unsigned long x2low,
                             unsigned long z1high,
                             unsigned long z1low,
                             unsigned long z2high,
                             unsigned long z2low,
                             unsigned char s1high,
                             unsigned char s1low,
                             unsigned char s2high,
                             unsigned char s2low,
                             long u1low,
                             long u1high,
                             long u2low,
                             long u2high,
                             long v1low,
                             long v1high,
                             long v2low,
                             long v2high,
                             int femark);


static void HSform_render_trap (int xlow,
                                int xhigh,
                                int y0,
                                int y1,
                                int y2,
                                int y3,
                                double z0,
                                double z1,
                                double z2,
                                double z3,
                                int normx0,
                                int normy0,
                                int normz0,
                                int normx1,
                                int normy1,
                                int normz1,
                                int normx2,
                                int normy2,
                                int normz2,
                                int normx3,
                                int normy3,
                                int normz3,
                                double w0,
                                double w1,
                                double w2,
                                double w3,
                                HRuv u0,
                                HRuv u1,
                                HRuv u2,
                                HRuv u3,
                                HRuv v0,
                                HRuv v1,
                                HRuv v2,
                                HRuv v3);

static int HSy0findpivot ( struct HSpb_edge * ml,
                           int *list,
                           int i,
                           int j,
                           int dim);

static int HSy0partition (struct HSpb_edge * ml,
                          int *list,
                          int left,
                          int right,
                          double pivot,
                          int dim);

static int HSx0findpivot (struct HSpb_master * ml1,
                          struct HSpb_edge * ml2,
                          int *list,
                          int i,
                          int j,
                          int dim);

static int HSx0partition (struct HSpb_master * ml1,
                          struct HSpb_edge * ml2,
                          int *list,
                          int left,
                          int right,
                          double pivot0,
                          double pivot1,
                          int dim);

/* Statics */

static int edge_dim;    /* size of fem edge data structure */
static double xTolerance;


/*--- HSform_fem_trap --------------------------------------------------------*/

static void HSform_fem_trap (unsigned long yhigh,
                             unsigned long ylow,
                             unsigned long x1high,
                             unsigned long x1low,
                             unsigned long x2high,
                             unsigned long x2low,
                             unsigned long z1high,
                             unsigned long z1low,
                             unsigned long z2high,
                             unsigned long z2low,
                             unsigned char s1high,
                             unsigned char s1low,
                             unsigned char s2high,
                             unsigned char s2low,
                             long u1low,
                             long u1high,
                             long u2low,
                             long u2high,
                             long v1low,
                             long v1high,
                             long v2low,
                             long v2high,
                             int femark)

/*
NAME
   HSform_fem_trap (static)

KEYWORD
   polybuster

DESCRIPTION
   This function creates a trapezoid structure from the given data & displays it
   when doing FEM shading.

PARAMETERS
   ylow,yhigh (IN) - top and bottom extents of trapezoid.
   x1low,x1high,x2low,x2high (IN) - x values at four corners of trapezoid.
   z1low,z1high,z2low,z2high (IN) - z values at four corners of trapezoid.
   s1low,s1high,s2low,s2high (IN) - Fem color values at four corners of 
                                    trapezoid.
   u1low,u1high,u2low,u2high (IN) - Parametric u values at four corners of 
                                    trapezoid.
   v1low,v1high,v2low,v2high (IN) - Parametric v values at four corners of 
                                    trapezoid.
   femark (IN) - Bit map of side(s) (if any) of trapezoid which need edge 
                                    marking.

GLOBALS USED
   none.

RETURN VALUES
   none.

HISTORY
   --/--/-- Created. -???
      02/08/92 Documented. -Trevor Mink
*/

   {
   struct hsfem_trapezoid trap;

   trap.id = femark;    /* edge markings for FEM rasterizer */
   trap.ya = yhigh;
   trap.yb = ylow;
   trap.x0 = x1high;
   trap.x1 = x2high;
   trap.x2 = x1low;
   trap.x3 = x2low;
   trap.z0 = z1high;
   trap.z1 = z2high;
   trap.z2 = z1low;
   trap.z3 = z2low;
   trap.u0 = u1high;
   trap.u1 = u2high;
   trap.u2 = u1low;
   trap.u3 = u2low;
   trap.v0 = v1high;
   trap.v1 = v2high;
   trap.v2 = v1low;
   trap.v3 = v2low;
   trap.shade0 = s1high;
   trap.shade1 = s2high;
   trap.shade2 = s1low;
   trap.shade3 = s2low;

   HSdraw_trapezoid ((struct trapezoid *) (&trap));
   }

static int iswap_v;
static double dswap_v;

#define	ISWAP(x,y)	\
	{		\
	iswap_v = x;	\
	x = y;		\
	y = iswap_v;	\
	}

#define	DSWAP(x,y)	\
	{		\
	dswap_v = x;	\
	x = y;		\
	y = dswap_v;	\
	}

static int tcount = 0;

/*---HSform_phong_trap---------------------------------------------*/

static void HSform_phong_trap (
                       unsigned long yhigh, unsigned long ylow,
                       unsigned long x1high, unsigned long x1low,
                       unsigned long x2high, unsigned long x2low,
                       unsigned long z1high, unsigned long z1low,
                       unsigned long z2high, unsigned long z2low,
                       int rhlmark,
                       double normx0, double normy0, double normz0, 
                       double normx1, double normy1, double normz1,
                       double normx2, double normy2, double normz2, 
                       double normx3, double normy3, double normz3,
                       double w0, double w1, double w2, double w3,
                       double u0, double u1, double u2, double u3,
                       double v0, double v1, double v2, double v3)

   {
   struct trapezoid	trap;

/*
   fprintf( stderr, "-------------------------------------------------\n" );
   fprintf( stderr, "p0: %6.2f %6.2f %6.2f - %5.2f %5.2f %5.2f - %4.2f %4.2f\n",
      x0/65535.0, ylow, z0, normx0, normy0, normz0, u0, v0 );
   fprintf( stderr, "p1: %6.2f %6.2f %6.2f - %5.2f %5.2f %5.2f - %4.2f %4.2f\n",
      x1/65535.0, ylow, z1, normx1, normy1, normz1, u1, v1 );
   fprintf( stderr, "p2: %6.2f %6.2f %6.2f - %5.2f %5.2f %5.2f - %4.2f %4.2f\n",
      x2/65535.0, yhigh, z2, normx2, normy2, normz2, u2, v2 );
   fprintf( stderr, "p3: %6.2f %6.2f %6.2f - %5.2f %5.2f %5.2f - %4.2f %4.2f\n",
      x3/65535.0, yhigh, z3, normx3, normy3, normz3, u3, v3 );
*/

   trap.id = rhlmark;   /* visibility edge marks for rhl */
   if (element_parms.front_facing_facet != 0) trap.id |= 0x10;

   trap.ya = yhigh;
   trap.yb = ylow;
   trap.x0 = x1high;
   trap.x1 = x2high;
   trap.x2 = x1low;
   trap.x3 = x2low;
   trap.z0 = z1high;
   trap.z1 = z2high;
   trap.z2 = z1low;
   trap.z3 = z2low;

   (*active_window->rasterizer[active_window->active_zbuffer])( &trap,
                                normx0, normy0, normz0,
                                normx1, normy1, normz1,
                                normx2, normy2, normz2,
                                normx3, normy3, normz3,
                                w0, w1, w2, w3,
                                u0, u1, u2, u3,
                                v0, v1, v2, v3 );
   }

/*--- HSform_render_trap -----------------------------------------------*/

static void HSform_render_trap (int xlow, int xhigh,
                                int y0, int y1,
                                int y2, int y3,
                                double z0, double z1,
                                double z2, double z3,
                                int normx0, int normy0,
                                int normz0, int normx1,
                                int normy1, int normz1,
                                int normx2, int normy2,
                                int normz2, int normx3,
                                int normy3, int normz3,
                                double w0, double w1,
                                double w2, double w3,
                                HRuv u0, HRuv u1,
                                HRuv u2, HRuv u3,
                                HRuv v0, HRuv v1,
                                HRuv v2, HRuv v3)

/*
NAME
   HSform_render_trap (static)

KEYWORD
   polybuster

DESCRIPTION
   This function sends off vertical trapezoids for use in bucket sort 
   for Phong/Watkins shading.  NOTE: Trapezoids are turned sideways for 
   Rendering.

PARAMETERS
   xlow,xhigh (IN) - left and right extents of trapezoid.
   y0,y1,y2,y3 (IN) - y values at four corners of trapezoid.
   z0,z1,z2,z3 (IN) - z values at four corners of trapezoid.
   normx0,normy0,normz0,
   normx1,normy1,normz1,
   normx2,normy2,normz2,
   normx3,normy3,normz3 (IN) - 3d normals at the fours corners of the trapezoid.
   w0,w1,w2,s3 (IN) - W values for perspective at the four corners of the 
                      trapezoid.
   u0,u1,u2,u3 (IN) - Parametric u values at four corners of trapezoid (for 
                      texture).
   v0,v1,v2,v3 (IN) - Parametric v values at four corners of trapezoid (for 
                      texture).

GLOBALS USED
   none.

RETURN VALUES
   none.

HISTORY
   --/--/-- Created. -???
      02/08/92 Documented. -Trevor Mink
*/
   {
   struct HRspan_trapezoid *trap;
   IGRint dx;
   struct HRtrapezoid_uv *p, *HRalloc_trapezoid_uv ();
   double d_y, d_lo;

#  if TEXTURE_DEBUG
   fprintf (stderr, "u0 = %lf u1 = %lf u2 = %lf u3 = %lf\n", u0, u1, u2, u3);
   fprintf (stderr, "v0 = %lf v1 = %lf v2 = %lf v3 = %lf\n", v0, v1, v2, v3);
#  endif

   /* if the trap is a vertical line, toss it */
   if ((dx = (xhigh - xlow)) == 0) return;

   /* if the X-Min of the trap is less than the current scan-line, toss it */

   if (xlow < rendering_globals.scan_line) return;

   /*
    * If the surface that is being tiled has already had some trapezoids
    * reclaimed because memory was running out, only send out trapezoids 
    * that will sort to the current scanline.
    */

   if ((rendering_globals.cur_traps_reclaimed) && 
       (xlow != rendering_globals.scan_line))
      return;

   trap = HRalloc_span_trap ();

   if (!trap) return;   /* couldn't allocate trapezoid structure */

   /* assign the fields */

   if (!active_window->perspective)
      {
      w0 = 0.0;
      w1 = 0.0;
      w2 = 0.0;
      w3 = 0.0;
      }

      {
      int trap_no;

      trap_no = ++tcount;
      if (!element_parms.front_facing_facet)
         trap_no *= -1;

      trap->deltas = (struct HRspan_deltas *) trap_no;
      }

   if (ROUND16 (y1) < ROUND16 (y0))
      {
      ISWAP (y0, y1);
      DSWAP (z0, z1);
      }

   if (ROUND16 (y3) < ROUND16 (y2))
      {
      ISWAP (y2, y3);
      DSWAP (z2, z3);
      }

   trap->nexty = NULL;
   trap->nextz = NULL;

   trap->attr = &rendering_globals.cur_surf->rend_parms;

   trap->x_max = xhigh;
   trap->y_lo = y0;
   trap->y_hi = y1;
   trap->z_lo = z0;
   trap->z_hi = z1;

   trap->w_lo = w0;
   trap->w_hi = w1;

   trap->nx_lo = normx0;
   trap->ny_lo = normy0;
   trap->nz_lo = normz0;
   trap->nx_hi = normx1;
   trap->ny_hi = normy1;
   trap->nz_hi = normz1;

   /*
    * if the surface does not have a texture map attached then set the tparms
    * field to NULL.  Else allocate memory and calculate u/v deltas
    */

   if (trap->attr->surface_texture == NULL || 
       trap->attr->surface_texture->Fname[0] == 0)
      {
      trap->tparms = NULL;
      }
   else
      {
      trap->tparms = p = HRalloc_trapezoid_uv ();

      p->u_lo = u0;
      p->u_hi = u1;
      p->v_lo = v0;
      p->v_hi = v1;

      p->du_lo_dx = (u2 - u0) / (HRuv) dx;
      p->du_hi_dx = (u3 - u1) / (HRuv) dx;

      p->dv_lo_dx = (v2 - v0) / (HRuv) dx;
      p->dv_hi_dx = (v3 - v1) / (HRuv) dx;

      d_y = y2 - y0;
      d_lo = (double) dx;
      d_lo = sqrt ((d_lo * d_lo + d_y * d_y));
      d_lo = (double) dx / d_lo;

      p->du_dx = p->du_lo_dx * (HRuv) d_lo;
      p->dv_dx = p->dv_lo_dx * (HRuv) d_lo;

#     if TEXTURE2_DEBUG
      fprintf (stderr, "du_lo_dx = %f\tdu_hi_dx = %f\tdu_dx = %lf\n",
               p->du_lo_dx, p->du_hi_dx, p->du_dx);
      fprintf (stderr, "dv_lo_dx = %f\tdv_hi_dx = %f\tdv_dx = %lf\n",
               p->dv_lo_dx, p->dv_hi_dx, p->dv_dx);
#      endif

#     if TEXTURE_DEBUG
      fprintf (stderr, "xlow, xhigh = %d, %d\ty0,1,2,3 = %d, %d, %d, %d\n",
               xlow, xhigh, (y0 >> 16), (y1 >> 16), (y2 >> 16), (y3 >> 16));
      fprintf (stderr, "u_lo, u_hi = %f, %f\tv_lo, v_hi = %f, %f\n",
               p->u_lo, p->u_hi, p->v_lo, p->v_hi);
      fprintf (stderr, "du_dx = %f\tdv_dx = %f\n", p->du_dx, p->dv_dx);
#     endif

      if ((y1 - y0) > (y3 - y2))
         p->du_dy = (u1 - u0) / (HRuv) ((y1 - y0 + 0x10000) >> 16);
      else
         p->du_dy = (u3 - u2) / (HRuv) ((y3 - y2 + 0x10000) >> 16);

#     if TEXTURE_DEBUG
      fprintf (stderr, "y0, y1, y2, y3 = %d, %d, %d, %d\n", y0, y1, y2, y3);
      fprintf (stderr, "v0, v1, v2, v3 = %d, %d, %d, %d\n", v0, v1, v2, v3);
#     endif

      if ((y1 - y0) > (y3 - y2))
         p->dv_dy = (v1 - v0) / (HRuv) (((y1 - y0) + 0x10000) >> 16);
      else
         p->dv_dy = (v3 - v2) / (HRuv) (((y3 - y2) + 0x10000) >> 16);

#     if TEXTURE2_DEBUG
      fprintf (stderr, "du_dy, dv_dy = %f, %f\n", p->du_dy, p->dv_dy);
#     endif
      }

   /*
    * Calculate the deltas with respect to x
    */

   if ((y1 - y0) > (y3 - y2))
      trap->dz_dy = (z1 - z0) / (y1 - y0);
   else
      trap->dz_dy = (z3 - z2) / (y3 - y2);

   if ((y1 - y0) > (y3 - y2))
      trap->dw_dy = (w1 - w0) / (y1 - y0);
   else
      trap->dw_dy = (w3 - w2) / (y3 - y2);

   trap->dz_lo_dx = (z2 - z0) / (double) dx;
   trap->dz_hi_dx = (z3 - z1) / (double) dx;

   trap->dy_lo_dx = (y2 - y0) / dx;
   trap->dy_hi_dx = (y3 - y1) / dx;

   trap->dw_lo_dx = (w2 - w0) / dx;
   trap->dw_hi_dx = (w3 - w1) / dx;

   trap->dnx_lo_dx = (normx2 - normx0) / dx;
   trap->dnx_hi_dx = (normx3 - normx1) / dx;

   trap->dny_lo_dx = (normy2 - normy0) / dx;
   trap->dny_hi_dx = (normy3 - normy1) / dx;

   trap->dnz_lo_dx = (normz2 - normz0) / dx;
   trap->dnz_hi_dx = (normz3 - normz1) / dx;

#  if PHDEBUG
   fprintf (stderr, "x_max = %d\n", trap->x_max);
   fprintf (stderr, "y_lo = %d(%f), y_hi = %d(%f)\n", 
      trap->y_lo, trap->y_lo / 65536.0, trap->y_hi, trap->y_hi / 65536.0);
   fprintf (stderr, "z_lo = %f, dz_dy = %f(end=%f), dz_lo_dx = %f\n", 
      trap->z_lo, trap->dz_dy, 
      (trap->z_lo + ((trap->y_hi - trap->y_lo) * trap->dz_dy)), 
      trap->dz_lo_dx);
   fprintf (stderr, "nx_lo, ny_lo, nz_lo: %d %d(%d) %d\n", 
      trap->nx_lo, trap->ny_lo, normy0, trap->nz_lo);
   fprintf (stderr, "nx_hi, ny_hi, nz_hi: %d %d(%d) %d\n", 
      trap->nx_hi, trap->ny_hi, normy1, trap->nz_hi);
   fprintf (stderr, "dnx_lo_dx, dny_lo_dx, dnz_lo_dx: %d %d %d\n", 
      trap->dnx_lo_dx, trap->dny_lo_dx, trap->dnz_lo_dx);
   fprintf (stderr, "dnx_hi_dx, dny_hi_dx, dnz_hi_dx: %d %d %d\n", 
      trap->dnx_hi_dx, trap->dny_hi_dx, trap->dnz_hi_dx);
#  endif

   HRbucket_sort_trapezoid (trap, xlow);
   }

/*---form_trap--------------------------------------------------------*/

void form_trap (unsigned long yhigh, unsigned long ylow,
                       unsigned long x1high, unsigned long x1low,
                       unsigned long x2high, unsigned long x2low,
                       unsigned long z1high, unsigned long z1low,
                       unsigned long z2high, unsigned long z2low,
                       unsigned char s1high, unsigned char s1low,
                       unsigned char s2high, unsigned char s2low,
                       int rhlmark)

/*
NAME
   form_trap

KEYWORD
   polybuster

DESCRIPTION
   This function creates a trapezoid structure from the given data & 
   displays it.

PARAMETERS
   ylow,yhigh (IN) - top and bottom extents of trapezoid.
   x1low,x1high,x2low,x2high (IN) - x values at four corners of trapezoid.
   z1low,z1high,z2low,z2high (IN) - z values at four corners of trapezoid.
   s1low,s1high,s2low,s2high (IN) - Fem color values at four corners of 
                                    trapezoid.
   rhlmark (IN) - Bit map of side(s) (if any) of trapezoid which need 
                                    edge marking.

GLOBALS USED
   none.

RETURN VALUES
   none.

HISTORY
   --/--/-- Created. -???
      02/08/92 Documented. -Trevor Mink
*/
   {
   struct trapezoid trap;

   /* fprintf( stderr, "%1d\n", ++tcount ); */

   trap.id = rhlmark;   /* visibility edge marks for rhl */
   if (element_parms.front_facing_facet != 0) trap.id |= 0x10;
   trap.ya = yhigh;
   trap.yb = ylow;
   trap.x0 = x1high;
   trap.x1 = x2high;
   trap.x2 = x1low;
   trap.x3 = x2low;
   trap.z0 = z1high;
   trap.z1 = z2high;
   trap.z2 = z1low;
   trap.z3 = z2low;
   trap.shade0 = s1high;
   trap.shade1 = s2high;
   trap.shade2 = s1low;
   trap.shade3 = s2low;

   HSdraw_trapezoid (&trap);
   }

/*--- linefill ------------------------------------------------------*/

static void linefill (struct HSpb_master * ptr1,
                      struct HSpb_master * ptr2,
                      int dim,
                      int si)

/*
NAME
   linefill

KEYWORD
   polybuster

DESCRIPTION
   This function forms a valid trapezoid from a trapezoid which is skewed 
   such that the sides are within less than a pixel of each other.

PARAMETERS
   ptr1,ptr2 (IN/OUT) - The two vertices at the top of the degenerate trapezoid.
   dim (IN) - Size (in bytes) of the vertex structure.
   si (IN) - Shading intensity.

GLOBALS USED
   none.

RETURN VALUES
   none.

HISTORY
   --/--/-- Created. -???
      02/08/92 Documented. -Trevor Mink
*/
   {
   short yhi, ylo;
   int femark = 0;
   struct HSpb_master *temp;
   unsigned int z1hi = 0, z1lo = 0, z2hi = 0, z2lo = 0, x1hi, x1lo, x2hi, x2lo;
   unsigned char i1hi, i1lo, i2hi, i2lo;

#  if TEXTURE_DEBUG
   fprintf (stderr, "Within linefill: u0, u1 = %lf\tu2, u3 = %lf\tv0, v1 = %lf, v2, v3 = %lf\n",
    ptr1->u, ptr1->u, ptr2->u, ptr2->u, ptr1->v, ptr1->v, ptr2->v, ptr2->v);
#  endif

   /* determine edge marking for this degenerate trapezoid */
   if (ptr1->mrk & 2)
      femark = 15;
   /* make ptr1 the vert with smallest x */
   if (ptr1->pt[0] > ptr2->pt[0])
      {
      temp = ptr1;
      ptr1 = ptr2;
      ptr2 = temp;
      }
   ylo = yhi = ptr1->pt[1];
   x1lo = x1hi = XZROUND (ptr1->pt[0]);
   x2lo = x2hi = XZROUND (ptr2->pt[0]);

   if (si)
      {
      i1lo = i1hi = IROUND (ptr1->pt[si]);
      i2lo = i2hi = IROUND (ptr2->pt[si]);
      }
   else
      {
      i1lo = i1hi = i2lo = i2hi = 0;
      }
   if (dim > 32)
      {
      z1lo = z1hi = XZROUND (ptr1->pt[2]);
      z2lo = z2hi = XZROUND (ptr2->pt[2]);
      }

   if (element_parms.facet_type == FEM_TILE)
      HSform_fem_trap ((unsigned long) yhi, (unsigned long) ylo,
                       (unsigned long) x1hi, (unsigned long) x1lo,
                       (unsigned long) x2hi, (unsigned long) x2lo,
                       (unsigned long) z1hi, (unsigned long) z1lo,
                       (unsigned long) z2hi, (unsigned long) z2lo,
                       i1hi, i1lo,
                       i2hi, i2lo,
                       UVROUND (ptr1->u_pt), UVROUND (ptr1->u_pt),
                       UVROUND (ptr2->u_pt), UVROUND (ptr2->u_pt),
                       UVROUND (ptr1->v_pt), UVROUND (ptr1->v_pt),
                       UVROUND (ptr2->v_pt), UVROUND (ptr2->v_pt),
                       femark);

   else 
   if (element_parms.facet_type == RENDERED)
      HSform_render_trap ((int) ylo, (int) yhi,
                          (int) x1lo, (int) x2lo,
                          (int) x1hi, (int) x2hi,
                          ptr1->pt[2], ptr2->pt[2],
                          ptr1->pt[2], ptr2->pt[2],
                          PHROUND (ptr1->pt[4]), PHROUND (ptr1->u_pt),
                          PHROUND (ptr1->v_pt), PHROUND (ptr2->pt[4]),
                          PHROUND (ptr2->u_pt), PHROUND (ptr2->v_pt),
                          PHROUND (ptr1->pt[4]), PHROUND (ptr1->u_pt),
                          PHROUND (ptr1->v_pt), PHROUND (ptr2->pt[4]),
                          PHROUND (ptr2->u_pt), PHROUND (ptr2->v_pt),
                          0.0, 0.0, 0.0, 0.0,
             (HRuv) ptr1->u, (HRuv) ptr2->u, (HRuv) ptr1->u, (HRuv) ptr2->u,
            (HRuv) ptr1->v, (HRuv) ptr2->v, (HRuv) ptr1->v, (HRuv) ptr2->v);

   else 
   if (tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
      HSform_phong_trap ((unsigned long) yhi, (unsigned long) ylo,
                         (unsigned long) x1hi, (unsigned long) x1lo,
                         (unsigned long) x2hi, (unsigned long) x2lo,
                         (unsigned long) z1hi, (unsigned long) z1lo,
                         (unsigned long) z2hi, (unsigned long) z2lo,
                         femark,
                         ptr1->pt[4], ptr1->u_pt, ptr1->v_pt, 
                         ptr2->pt[4], ptr2->u_pt, ptr2->v_pt,
                         ptr1->pt[4], ptr1->u_pt, ptr1->v_pt, 
                         ptr2->pt[4], ptr2->u_pt, ptr2->v_pt,
                         0.0, 0.0, 0.0, 0.0,
                         ptr1->u, ptr2->u, ptr1->u, ptr2->u,
                         ptr1->v, ptr2->v, ptr1->v, ptr2->v);

   else
      form_trap ((unsigned long) yhi, (unsigned long) ylo,
                 (unsigned long) x1hi, (unsigned long) x1lo,
                 (unsigned long) x2hi, (unsigned long) x2lo,
                 (unsigned long) z1hi, (unsigned long) z1lo,
                 (unsigned long) z2hi, (unsigned long) z2lo,
                 i1hi, i1lo,
                 i2hi, i2lo,
                 femark);
   }

/*--- vector_to_edge -------------------------------------------------*/

static void vector_to_edge (struct HSpb_master * ml1,
                            struct HSpb_edge * ml2,
                            int *nvert,
                            int *list1,
                            int *list2,
                            int dim,
                            int si)
/*
NAME
        vector_to_edge

KEYWORD
        polybuster

DESCRIPTION
        This function produces a list of edges from the list of vectors.
 	It then computes a slope and x-intercept for each edge.
        Note the following:
                1) All edges point downward
                2) Horizontal lines are removed; the value of nvert may change
                3) Lines are considered in the form x = my + b
                   (vertical lines have slope zero; horizontal lines have no
  		    slope, but they have already been removed)

PARAMETERS
        ml1 (IN) - List of vertices (linked list implemented as an array).
        ml2 (OUT) - List of edges (linked list implemented as an array).
        nvert (IN/OUT) - Number of vertices in current polygon.
        list1,list2 (IN) - Array containing linked list indices for ml1 and ml2.
        dim (IN) - Size (in bytes) of vertex structure.
        si (IN) - Index of shading intensity with pt[] entry of vertex structure (0 means not there).

GLOBALS USED
        none.

RETURN VALUES
        none.

HISTORY
        --/--/-- Created. -???
        02/08/92 Documented. -Trevor Mink
*/
   {
   register struct HSpb_master *mlptr1, *next, *last;
   register struct HSpb_edge *mlptr2, *last_mlptr2;
   int n;
   int i;

   n = 0;
   mlptr1 = ml1;
   mlptr2 = ml2;
   last_mlptr2 = ml2;
   last_mlptr2->y0 = -1.0;
   mlptr2->mesh_mark = 0;
   for (i = 0; i < *nvert; i++)
      {
#if DEBUG
      fprintf (stderr, "mlptr1->pt[1] = %f\n", mlptr1->pt[1]);
#endif
      last = (struct HSpb_master *) ((int) ml1 + mlptr1->blink * dim);
      if (mlptr1->pt[1] < last->pt[1])
         {
         list1[n] = n;
         mlptr2->x0 = mlptr1->pt[0];
         mlptr2->y0 = mlptr1->pt[1];
         mlptr2->x1 = last->pt[0];
         mlptr2->y1 = last->pt[1];
         if (element_parms.facet_type == FEM_TILE)
            {
            mlptr2->u0 = mlptr1->u_pt;
            mlptr2->v0 = mlptr1->v_pt;
            mlptr2->u1 = last->u_pt;
            mlptr2->v1 = last->v_pt;
            }
         if (element_parms.facet_type == RENDERED ||
             tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
            {
            mlptr2->u0 = mlptr1->pt[4];
            mlptr2->u1 = last->pt[4];
            mlptr2->v0 = mlptr1->u_pt;
            mlptr2->v1 = last->u_pt;
            mlptr2->nz0 = mlptr1->v_pt;
            mlptr2->nz1 = last->v_pt;
            if (active_window->perspective)
               {
               mlptr2->w0 = mlptr1->pt[3];
               mlptr2->w1 = last->pt[3];
               }
            /* texture stuff */
/*				if( element_parms.facet_type = RENDERED_TEXTURED )
             */ 
               {
               mlptr2->u0_texture = mlptr1->u;
               mlptr2->v0_texture = mlptr1->v;
               mlptr2->u1_texture = last->u;
               mlptr2->v1_texture = last->v;
#if TEXTURE_DEBUG
               fprintf (stderr, "vector_to_edge: mlptr1->u = %lf\tmlptr1->v = %lf\tlast->u = %lf\tlast->v = %lf\n",
                        mlptr1->u, mlptr1->v, last->u, last->v);
#endif
               }
            }
         /* mark edge for mesh */
         if (mlptr1->mrk & 1)
            mlptr2->mesh_mark = 1;
#if DEBUG
         fprintf (stderr, "last; mesh_mark for edge %d = %d\n", n,
                  mlptr2->mesh_mark);
         fprintf (stderr, "last: y0 and y1: %f %f\n", mlptr2->y0, mlptr2->y1);
         fprintf (stderr, "last: nx0, ny0, nz0: %f %f %f\n", mlptr2->u0,
                  mlptr2->v0, mlptr2->nz0);
         fprintf (stderr, "last: nx1, ny1, nz1: %f %f %f\n", mlptr2->u1,
                  mlptr2->v1, mlptr2->nz1);
#endif
         if (si)
            {
            mlptr2->islope = (last->pt[si] - mlptr1->pt[si]) /
               (last->pt[1] - mlptr1->pt[1]);
            }
         if (dim > 32)
            {
            mlptr2->zslope = (last->pt[2] - mlptr1->pt[2]) /
               (last->pt[1] - mlptr1->pt[1]);
            list2[n] = i;
            }
         n++;
         last_mlptr2 = (struct HSpb_edge *) ((int) mlptr2);
         mlptr2 = (struct HSpb_edge *) ((int) mlptr2 + edge_dim);
         mlptr2->mesh_mark = 0;
         }

      next = (struct HSpb_master *) ((int) ml1 + mlptr1->flink * dim);

      if (mlptr1->pt[1] < next->pt[1])
         {
         list1[n] = n;
         mlptr2->x0 = mlptr1->pt[0];
         mlptr2->y0 = mlptr1->pt[1];
         mlptr2->x1 = next->pt[0];
         mlptr2->y1 = next->pt[1];
         if (element_parms.facet_type == FEM_TILE)
            {
            mlptr2->u0 = mlptr1->u_pt;
            mlptr2->v0 = mlptr1->v_pt;
            mlptr2->u1 = next->u_pt;
            mlptr2->v1 = next->v_pt;
            }
         if (element_parms.facet_type == RENDERED ||
             tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
            {
            mlptr2->u0 = mlptr1->pt[4];
            mlptr2->u1 = next->pt[4];
            mlptr2->v0 = mlptr1->u_pt;
            mlptr2->v1 = next->u_pt;
            mlptr2->nz0 = mlptr1->v_pt;
            mlptr2->nz1 = next->v_pt;
            if (active_window->perspective)
               {
               mlptr2->w0 = mlptr1->pt[3];
               mlptr2->w1 = next->pt[3];
               }
            /* texture stuff */
/*				if( element_parms.facet_type = RENDERED_TEXTURED )
             */ 
               {
               mlptr2->u0_texture = mlptr1->u;
               mlptr2->v0_texture = mlptr1->v;
               mlptr2->u1_texture = next->u;
               mlptr2->v1_texture = next->v;
#if TEXTURE_DEBUG
               fprintf (stderr, "vector_to_edge: mlptr1->u = %lf\tmlptr1->v = %lf\tnext->u = %lf\tnext->v = %lf\n",
                        mlptr1->u, mlptr1->v, next->u, next->v);
#endif
               }
            }
         /* mark edge for mesh */
         if (mlptr1->mrk & 2)
            mlptr2->mesh_mark = 1;
#if DEBUG
         fprintf (stderr, "next; mesh_mark for edge %d = %d\n", n,
                  mlptr2->mesh_mark);
         fprintf (stderr, "next: y0 and y1: %f %f\n", mlptr2->y0, mlptr2->y1);
         fprintf (stderr, "next: nx0, ny0, nz0: %f %f %f\n", mlptr2->u0,
                  mlptr2->v0, mlptr2->nz0);
         fprintf (stderr, "next: nx1, ny1, nz1: %f %f %f\n", mlptr2->u1,
                  mlptr2->v1, mlptr2->nz1);
#endif
         if (si)
            {
            mlptr2->islope = (next->pt[si] - mlptr1->pt[si]) /
               (next->pt[1] - mlptr1->pt[1]);
            }
         if (dim > 32)
            {
            mlptr2->zslope = (next->pt[2] - mlptr1->pt[2]) /
               (next->pt[1] - mlptr1->pt[1]);
            list2[n] = i;
            }
         n++;
         last_mlptr2 = (struct HSpb_edge *) ((int) mlptr2);
         mlptr2 = (struct HSpb_edge *) ((int) mlptr2 + edge_dim);
         mlptr2->mesh_mark = 0;
         }

      /* check for marked, horizontal edge */

      if (mlptr1->pt[1] == next->pt[1])

         /*
          * ignore marked horizontal edge if the endpoints collapse to the
          * same <x,y>
          */
         if ((mlptr1->mrk & 2) && (mlptr1->pt[0] != next->pt[0]))
            linefill (mlptr1, next, dim, si);

#if DEBUG
      fprintf (stderr, "loop; mesh_mark for edge %d = %d\n", n,
               last_mlptr2->mesh_mark);
#endif
      mlptr1 = (struct HSpb_master *) ((int) mlptr1 + dim);
      }

   /*
    * ml1[i].pt[0] contains the x-intercept ml1[i].pt[1] contains the slope
    * in xy plane ml1[i].pt[2] contains the z-intercept ml2[i].zslope
    * contains the slope in yz plane ml2[i].islope contains the slope in
    * intensity
    */

   mlptr1 = ml1;
   mlptr2 = ml2;
   for (i = 0; i < n; i++)
      {
      mlptr1->pt[1] = (mlptr2->x1 - mlptr2->x0) /
         (mlptr2->y1 - mlptr2->y0);
      mlptr1->pt[0] = mlptr2->x0 - mlptr1->pt[1] * mlptr2->y0;
      if (si)
         {
         next = (struct HSpb_master *) ((int) ml1 + list2[i] * dim);
         mlptr1->pt[-2] = next->pt[si] - mlptr2->islope * mlptr2->y0;
         }
      if (dim > 32)
         {
         next = (struct HSpb_master *) ((int) ml1 + list2[i] * dim);
         mlptr1->pt[-1] = next->pt[2] - mlptr2->zslope * mlptr2->y0;
         }
      mlptr1 = (struct HSpb_master *) ((int) mlptr1 + dim);
      mlptr2 = (struct HSpb_edge *) ((int) mlptr2 + edge_dim);
      }
   if (dim > 32)
      {
      mlptr1 = ml1;
      for (i = 0; i < n; i++)
         {
         if (si)
            {
            mlptr1->pt[si] = mlptr1->pt[-2];
            }
         mlptr1->pt[2] = mlptr1->pt[-1];
         mlptr1 = (struct HSpb_master *) ((int) mlptr1 + dim);
         }
      }
   *nvert = n;
   }

/*--- HSy0findpivot -----------------------------------------------------*/

static int HSy0findpivot (struct HSpb_edge * ml,
                          int *list,
                          int i,
                          int j,
                          int dim)
/*
NAME
        HSy0findpivot (static)

KEYWORD
        polybuster

DESCRIPTION
        This function finds the pivot point in the quicksort algorithm between indices
        'i' and 'j' of edge list 'ml'.

PARAMETERS
        ml (IN) - List of edges (linked list implemented as an array).
        list (IN) - Array containing linked list indices for ml.
        i,j (IN) - Indices which indicate the part of the list current being sorted (recursive alg.).
        dim (IN) - Size (in bytes) of vertex structure.

GLOBALS USED
        none.

RETURN VALUES
        -1	-> Failed
        Between	i and j -> Index in 'list' which will index 'ml'.

HISTORY
        --/--/-- Created. -???
        02/08/92 Documented. -Trevor Mink
*/
   {
   register struct HSpb_edge *mlptr;
   double firstkey;
   register int k;

   mlptr = (struct HSpb_edge *) ((int) ml + list[i] * edge_dim);
   firstkey = mlptr->y0;
   for (k = i + 1; k <= j; k++)
      {
      mlptr = (struct HSpb_edge *) ((int) ml + list[k] * edge_dim);
      if (mlptr->y0 > firstkey)
         return (k);
      else if (mlptr->y0 < firstkey)
         return (i);
      }
   return (-1);
   }

/*--- HSy0partition -----------------------------------------------------*/

static int HSy0partition (struct HSpb_edge * ml,
                          int *list,
                          int left,
                          int right,
                          double pivot,
                          int dim)
/*
NAME
        HSy0partition (static)

KEYWORD
        polybuster

DESCRIPTION
        This function partitions the edge list by dividing the entries into two groups
        based upon the comparison (greater than/less than) of their y0 value to the pivot value.

PARAMETERS
        ml (IN) - List of edges (linked list implemented as an array).
        list (IN) - Array containing linked list indices for ml.
        left,right (IN) - Indices which indicate the part of the list current being sorted (recursive alg.).
        pivot (IN) - Pivotal value around which to partition.
        dim (IN) - Size (in bytes) of vertex structure.

GLOBALS USED
        none.

RETURN VALUES
        Index at which the pivot value ended up.

HISTORY
        --/--/-- Created. -???
        02/08/92 Documented. -Trevor Mink
*/
   {
   register struct HSpb_edge *mlptr;
   int tmp;
   register int l, r;

   l = left;
   r = right;
   do
      {
      tmp = list[l];
      list[l] = list[r];
      list[r] = tmp;
      mlptr = (struct HSpb_edge *) ((int) ml + list[l] * edge_dim);
      while (mlptr->y0 < pivot)
         {
         l++;
         mlptr = (struct HSpb_edge *) ((int) ml + list[l] * edge_dim);
         }
      mlptr = (struct HSpb_edge *) ((int) ml + list[r] * edge_dim);
      while (mlptr->y0 >= pivot)
         {
         r--;
         mlptr = (struct HSpb_edge *) ((int) ml + list[r] * edge_dim);
         }
      }
   while (l <= r);
   return (l);
   }

/*--- sorty0 ------------------------------------------------------------*/

static void sorty0 (struct HSpb_edge * ml,
                    int *list,
                    int i,
                    int j,
                    int dim)

/*
NAME
        sorty0

KEYWORD
        polybuster

DESCRIPTION
        This function uses the quicksort algorithm to sort the list 'ml' by y0.

PARAMETERS
        ml (IN) - List of edges (linked list implemented as an array).
        list (IN) - Array containing linked list indices for ml.
        i,j (IN) - Indices which indicate the part of the list current being sorted (recursive alg.).
        dim (IN) - Size (in bytes) of vertex structure.

GLOBALS USED
        none.

RETURN VALUES
        Index at which the pivot value ended up.

HISTORY
        --/--/-- Created. -???
        02/08/92 Documented. -Trevor Mink
*/
   {
   register struct HSpb_edge *mlptr0, *mlptr1;
   double pivot;
   int pivotindex;
   register int k;
   int size, flag, low;
   int tmp;

   size = j - i;

   if (size < BUBSIZE)
      {
      low = i;
      size += low;
      do
         {
         flag = 0;
         for (i = size; i > low; i--)
            {
            j = i - 1;
            mlptr0 = (struct HSpb_edge *)
               ((int) ml + list[i] * edge_dim);
            mlptr1 = (struct HSpb_edge *)
               ((int) ml + list[j] * edge_dim);
            if (mlptr0->y0 < mlptr1->y0)
               {
               tmp = list[i];
               list[i] = list[j];
               list[j] = tmp;
               flag++;
               }
            }
         low++;
         }
      while (flag);
      }
   else
      {
      pivotindex = HSy0findpivot (ml, list, i, j, dim);
      if (pivotindex != -1)
         {
         mlptr0 = (struct HSpb_edge *)
            ((int) ml + list[pivotindex] * edge_dim);
         pivot = mlptr0->y0;
         k = HSy0partition (ml, list, i, j, pivot, dim);
         if ((k != i) && (k < j))
            sorty0 (ml, list, k, j, dim);
         k--;
         if ((k != j) && (i < k))
            sorty0 (ml, list, i, k, dim);
         }
      }
   }

/*--- HSx0findpivot --------------------------------------------------------*/

static int HSx0findpivot (struct HSpb_master * ml1,
                          struct HSpb_edge * ml2,
                          int *list,
                          int i,
                          int j,
                          int dim)
/*
NAME
        HSx0findpivot (static)

KEYWORD
        polybuster

DESCRIPTION
        This function finds the pivot point in the quicksort algorithm between indices
        'i' and 'j' of edge list 'ml'.

PARAMETERS
        ml (IN) - List of edges (linked list implemented as an array).
        list (IN) - Array containing linked list indices for ml.
        i,j (IN) - Indices which indicate the part of the list current being sorted (recursive alg.).
        dim (IN) - Size (in bytes) of vertex structure.

GLOBALS USED
        none.

RETURN VALUES
        -1	-> Failed
        Between	i and j -> Index in 'list' which will index 'ml'.

HISTORY
        --/--/-- Created. -???
        02/08/92 Documented. -Trevor Mink
*/
   {
   register struct HSpb_master *ml1ptr0, *ml1ptr1;
   register struct HSpb_edge *ml2ptr;
   double firstkey;
   register int k;

   ml2ptr = (struct HSpb_edge *) ((int) ml2 + list[i] * edge_dim);
   firstkey = ml2ptr->x0;
   for (k = i + 1; k <= j; k++)
      {
      ml2ptr = (struct HSpb_edge *) ((int) ml2 + list[k] * edge_dim);
      if (ml2ptr->x0 > firstkey)
         {
         return (k);
         }
      else
         {
         if (ml2ptr->x0 < firstkey)
            {
            return (i);
            }
         else
            {
            ml1ptr0 = (struct HSpb_master *)
               ((int) ml1 + list[i] * dim);
            ml1ptr1 = (struct HSpb_master *)
               ((int) ml1 + list[k] * dim);
            if (ml1ptr1->f1.xendpt > ml1ptr0->f1.xendpt)
               return (k);
            else if (ml1ptr1->f1.xendpt < ml1ptr0->f1.xendpt)
               return (i);
            }
         }
      }
   return (-1);
   }

/*--- HSx0partition ----------------------------------------------------*/

static int HSx0partition (struct HSpb_master * ml1,
                          struct HSpb_edge * ml2,
                          int *list,
                          int left,
                          int right,
                          double pivot0,
                          double pivot1,
                          int dim)

/*
NAME
        HSx0partition (static)

KEYWORD
        polybuster

DESCRIPTION
        This function partitions the edge list by dividing the entries into two groups
        based upon the comparison (greater than/less than) of their x0 value to the pivot value.

PARAMETERS
        ml (IN) - List of edges (linked list implemented as an array).
        list (IN) - Array containing linked list indices for ml.
        left,right (IN) - Indices which indicate the part of the list current being sorted (recursive alg.).
        pivot (IN) - Pivotal value around which to partition.
        dim (IN) - Size (in bytes) of vertex structure.

GLOBALS USED
        none.

RETURN VALUES
        Index at which the pivot value ended up.

HISTORY
        --/--/-- Created. -???
        02/08/92 Documented. -Trevor Mink
*/
   {
   register struct HSpb_master *ml1ptr;
   register struct HSpb_edge *ml2ptr;
   register int l, r;
   int tmp;

   l = left;
   r = right;
   do
      {
      tmp = list[l];
      list[l] = list[r];
      list[r] = tmp;
      ml2ptr = (struct HSpb_edge *) ((int) ml2 + list[l] * edge_dim);
      while (ml2ptr->x0 < pivot0)
         {
         l++;
         ml2ptr = (struct HSpb_edge *) ((int) ml2 + list[l] * edge_dim);
         }
      while (ml2ptr->x0 == pivot0)
         {
         ml1ptr = (struct HSpb_master *) ((int) ml1 + list[l] * dim);
         if (ml1ptr->f1.xendpt < pivot1)
            {
            l++;
            ml2ptr = (struct HSpb_edge *) ((int) ml2 + list[l] * edge_dim);
            }
         else
            break;
         }
      ml2ptr = (struct HSpb_edge *) ((int) ml2 + list[r] * edge_dim);
      while (ml2ptr->x0 > pivot0)
         {
         r--;
         ml2ptr = (struct HSpb_edge *) ((int) ml2 + list[r] * edge_dim);
         }
      while (ml2ptr->x0 == pivot0)
         {
         ml1ptr = (struct HSpb_master *) ((int) ml1 + list[r] * dim);
         if (ml1ptr->f1.xendpt >= pivot1)
            {
            r--;
            ml2ptr = (struct HSpb_edge *) ((int) ml2 + list[r] * edge_dim);
            }
         else
            break;
         }
      }
   while (l <= r);
   return (l);
   }

/*--- sortx0 -------------------------------------------------------------*/

static void sortx0 (struct HSpb_master * ml1,
                    struct HSpb_edge * ml2,
                    int *list,
                    int i,
                    int j,
                    int dim)

/*
NAME
        sortx0

KEYWORD
        polybuster

DESCRIPTION
        This function uses the quicksort algorithm to sort the list 'ml' by x0,
        secondarily by x1.

PARAMETERS
        ml (IN) - List of edges (linked list implemented as an array).
        list (IN) - Array containing linked list indices for ml.
        i,j (IN) - Indices which indicate the part of the list current being sorted (recursive alg.).
        dim (IN) - Size (in bytes) of vertex structure.

GLOBALS USED
        none.

RETURN VALUES
        none.

HISTORY
        --/--/-- Created. -???
        02/08/92 Documented. -Trevor Mink
*/
   {
   register struct HSpb_master *ml1ptr0, *ml1ptr1;
   register struct HSpb_edge *ml2ptr0, *ml2ptr1;
   register int k;
   double pivot0, pivot1;
   int pivotindex;
   int size, flag, low;
   int tmp;

   size = j - i;

   if (size < BUBSIZE)
      {
      low = i;
      size += low;
      do
         {
         flag = 0;
         for (i = size; i > low; i--)
            {
            j = i - 1;
            ml2ptr0 = (struct HSpb_edge *)
               ((int) ml2 + list[i] * edge_dim);
            ml2ptr1 = (struct HSpb_edge *)
               ((int) ml2 + list[j] * edge_dim);
            if (WITHIN_TOLERANCE (ml2ptr0->x0, ml2ptr1->x0, xTolerance))
               {
               ml1ptr0 = (struct HSpb_master *)
                  ((int) ml1 + list[i] * dim);
               ml1ptr1 = (struct HSpb_master *)
                  ((int) ml1 + list[j] * dim);
               if (ml1ptr0->f1.xendpt < ml1ptr1->f1.xendpt)
                  {
                  tmp = list[j];
                  list[j] = list[j + 1];
                  list[j + 1] = tmp;
                  flag++;
                  }
               }
            else if (ml2ptr0->x0 < ml2ptr1->x0)
               {
               tmp = list[i];
               list[i] = list[j];
               list[j] = tmp;
               flag++;
               }
            }
         low++;
         }
      while (flag);
      }
   else
      {
      pivotindex = HSx0findpivot (ml1, ml2, list, i, j, dim);
      if (pivotindex != -1)
         {
         ml1ptr0 = (struct HSpb_master *)
            ((int) ml1 + list[pivotindex] * dim);
         ml2ptr0 = (struct HSpb_edge *)
            ((int) ml2 + list[pivotindex] * edge_dim);
         pivot0 = ml2ptr0->x0;
         pivot1 = ml1ptr0->f1.xendpt;
         k = HSx0partition (ml1, ml2, list, i, j, pivot0,
                            pivot1, dim);
         if ((k != i) && (k < j))
            sortx0 (ml1, ml2, list, k, j, dim);
         k--;
         if ((k != j) && (i < k))
            sortx0 (ml1, ml2, list, i, k, dim);
         }
      }
   }

/*--- findxint ---------------------------------------------------------*/

static void findxint (struct HSpb_master * ml1,
                      struct HSpb_edge * ml2,
                      int *list,
                      int n,
                      double yscan,
                      int dim)

/*
NAME
        findxint

KEYWORD
        polybuster

DESCRIPTION
        This functions finds the x-intercepts with the value of yscan for the list of edges.
        Yscan is the yhigh for the set of trapezoids about to be drawn.

PARAMETERS
        ml1 (IN) - List of vertices.
        ml2 (IN) - List of edges.
        list (IN) - Array containing linked list indices for 'ml1' and 'ml2'.
        n (IN) - Number of edges active at this time (should be an even number).
        yscan (IN) - Indicates bottom of trapezoid(s).
        dim (IN) - Size (in bytes) of the vertex structure.

GLOBALS USED
        none.

RETURN VALUES
        none.

HISTORY
        --/--/-- Created. -???
        Summer 89 Also finds u and v intercepts with the value of yscan -?. ?????
        09/28/89 Interpolates w's now too. -?. ??????
        02/08/92 Documented. -Trevor Mink
*/
   {
   register struct HSpb_master *ml1ptr;
   register struct HSpb_edge *ml2ptr;
   register int i;

   for (i = 0; i < n; i++)
      {
      ml1ptr = (struct HSpb_master *) ((int) ml1 + list[i] * dim);
      ml2ptr = (struct HSpb_edge *) ((int) ml2 + list[i] * edge_dim);

      /* special case if yscan == endpoint of edge */

      if (yscan == ml2ptr->y1)
         {
         ml1ptr->f1.xendpt = ml2ptr->x1;
         if ((element_parms.facet_type == FEM_TILE) ||
             (element_parms.facet_type == RENDERED) ||
             tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
            {
            ml1ptr->u_pt = ml2ptr->u1;
            ml1ptr->v_pt = ml2ptr->v1;
            }
         if (element_parms.facet_type == RENDERED ||
             tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
            {
            if (active_window->perspective)
               ml1ptr->pt[3] = ml2ptr->w1;
            ml1ptr->pt[4] = ml2ptr->nz1;
/*				if( element_parms.facet_type == RENDERED_TEXTURED )
             */ 
               {
               ml1ptr->u = ml2ptr->u1_texture;
               ml1ptr->v = ml2ptr->v1_texture;
#if TEXTURE_DEBUG
               fprintf (stderr, "x,yscan, y1 = ( %lf, %lf, %lf )\n",
                        ml2ptr->x1, yscan, ml2ptr->y1);
               fprintf (stderr, "u, v = ( %lf, %lf )\n", ml1ptr->u, ml1ptr->v);
#endif
               }
            }
         }
      else
         {
         ml1ptr->f1.xendpt = ml1ptr->pt[1] * yscan + ml1ptr->pt[0];
         if ((element_parms.facet_type == FEM_TILE) ||
             (element_parms.facet_type == RENDERED) ||
             tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
            {
            ml1ptr->u_pt = (((yscan - ml2ptr->y0) /
                             (ml2ptr->y1 - ml2ptr->y0)) *
                            (ml2ptr->u1 - ml2ptr->u0)) + ml2ptr->u0;
            ml1ptr->v_pt = (((yscan - ml2ptr->y0) /
                             (ml2ptr->y1 - ml2ptr->y0)) *
                            (ml2ptr->v1 - ml2ptr->v0)) + ml2ptr->v0;
            }
         if (element_parms.facet_type == RENDERED ||
             tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
            {
            if (active_window->perspective)
               ml1ptr->pt[3] = (((yscan - ml2ptr->y0) /
                                 (ml2ptr->y1 - ml2ptr->y0)) *
                                (ml2ptr->w1 - ml2ptr->w0)) + ml2ptr->w0;
            ml1ptr->pt[4] = (((yscan - ml2ptr->y0) /
                              (ml2ptr->y1 - ml2ptr->y0)) *
                             (ml2ptr->nz1 - ml2ptr->nz0)) + ml2ptr->nz0;
/*				if( element_parms.facet_type == RENDERED_TEXTURED )
             */ 
               {
                /* ml2ptr->u0_texture = */ ml1ptr->u = (((yscan - ml2ptr->y0) /
                                                (ml2ptr->y1 - ml2ptr->y0)) *
                                (ml2ptr->u1_texture - ml2ptr->u0_texture)) +
                  ml2ptr->u0_texture;
                /* ml2ptr->v0_texture = */ ml1ptr->v = (((yscan - ml2ptr->y0) /
                                                (ml2ptr->y1 - ml2ptr->y0)) *
                                (ml2ptr->v1_texture - ml2ptr->v0_texture)) +
                  ml2ptr->v0_texture;
#if TEXTURE_DEBUG
               fprintf (stderr, "Busting edge at vertex %x from (%lf, %lf) to (%lf, %lf)\n",
                    ml1ptr, ml1ptr->pt[0], yscan, ml1ptr->f1.xendpt, yscan);
               fprintf (stderr, "x,yscan, y1 = ( %lf, %lf, %lf )\n",
                        ml1ptr->f1.xendpt, yscan, ml2ptr->y1);
               fprintf (stderr, "u, v = ( %lf, %lf )\n",
                        ml1ptr->u, ml1ptr->v);
#endif
               }
            }
         }
      }
   }

/*--- do_fill -----------------------------------------------------------*/

static void do_fill (struct HSpb_master * ml1,
                     struct HSpb_edge * ml2,
                     int *list,
                     double yscan,
                     int n,
                     int *start,
                     int dim,
                     int si)

/*
NAME
        do_fill

KEYWORD
        polybuster

DESCRIPTION
        This function forms the current set of trapezoids for the list of edges.
        It then removes from the linked list those edges that no longer need
        to be considered.

PARAMETERS
        ml1 (IN) - List of vertices.
        ml2 (IN) - List of edges.
        yscan (IN) - Indicates bottom of trapezoid(s).
        n (IN) - Number of edges active at this time (should be an even number).
        start (OUT) - Index of Edge at which to begin constructing trapezoids.
        dim (IN) - Size (in bytes) of the vertex structure.
        si (IN) - Shading intensity.

GLOBALS USED
        none.

RETURN VALUES
        none.

HISTORY
        --/--/-- Created. -???
        02/08/92 Documented. -Trevor Mink
*/
   {
   register int i;
   register struct HSpb_master *ml1ptr0, *ml1ptr1;
   register struct HSpb_edge *ml2ptr0, *ml2ptr1;
   struct HSpb_master *next;
   int femark, unmark0, unmark1;
   int init_fem_mark = 0;
   double ylow, yhigh;
   double x1low, x2low, x1high, x2high;
   double z1low, z2low, z1high, z2high;
   double i1low, i2low, i1high, i2high;
   double u1low = 0, u2low = 0, v1low = 0, v2low = 0, nz1low = 0, nz2low = 0;
   double w1low = 0, w2low = 0;
   double text_u1low = 0, text_u2low = 0, text_v1low = 0, text_v2low = 0;

   for (i = 0; i < n; i += 2)
      {
      ml1ptr0 = (struct HSpb_master *) ((int) ml1 + list[i] * dim);
      ml1ptr1 = (struct HSpb_master *) ((int) ml1 + list[i + 1] * dim);
      ml2ptr0 = (struct HSpb_edge *) ((int) ml2 + list[i] * edge_dim);
      ml2ptr1 = (struct HSpb_edge *) ((int) ml2 + list[i + 1] * edge_dim);
      ylow = ml2ptr0->y0;
      yhigh = yscan;
      x1low = ml2ptr0->x0;
      x2low = ml2ptr1->x0;
      x1high = ml1ptr0->f1.xendpt;
      x2high = ml1ptr1->f1.xendpt;

      if (element_parms.facet_type == FEM_TILE)
         {
         u1low = ml2ptr0->u0;
         u2low = ml2ptr1->u0;
         v1low = ml2ptr0->v0;
         v2low = ml2ptr1->v0;
         }

      if (element_parms.facet_type == RENDERED ||
          tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
         {
         u1low = ml2ptr0->u0;
         u2low = ml2ptr1->u0;
         v1low = ml2ptr0->v0;
         v2low = ml2ptr1->v0;
         nz1low = ml2ptr0->nz0;
         nz2low = ml2ptr1->nz0;
         if (active_window->perspective)
            {
            w1low = ml2ptr0->w0;
            w2low = ml2ptr1->w0;
            }

         text_u1low = ml2ptr0->u0_texture;
         text_u2low = ml2ptr1->u0_texture;
         text_v1low = ml2ptr0->v0_texture;
         text_v2low = ml2ptr1->v0_texture;
#        if TEXTURE_DEBUG
         fprintf (stderr, "do_fill: text_u1low = %lf\ttext_u2low = %lf\ttext_v1low = %lf\ttext_v2low = %lf\n",
                     text_u1low, text_u2low, text_v1low, text_v2low);
#        endif
         }

      if (si)
         {
         i1low = ml2ptr0->islope * ylow + ml1ptr0->pt[si];
         i2low = ml2ptr1->islope * ylow + ml1ptr1->pt[si];
         i1high = ml2ptr0->islope * yhigh + ml1ptr0->pt[si];
         i2high = ml2ptr1->islope * yhigh + ml1ptr1->pt[si];
         }
      else
         {
         i1low = 0;
         i1high = 0;
         i2low = 0;
         i2high = 0;
         }

      if (dim > 32)
         {
         z1low = ml2ptr0->zslope * ylow + ml1ptr0->pt[2];
         z2low = ml2ptr1->zslope * ylow + ml1ptr1->pt[2];
         z1high = ml2ptr0->zslope * yhigh + ml1ptr0->pt[2];
         z2high = ml2ptr1->zslope * yhigh + ml1ptr1->pt[2];
         }
      else
         {
         z1low = 0;
         z1high = 0;
         z2low = 0;
         z2high = 0;
         }

      /* see if any edges need to be removed from the list */

      unmark0 = 0;
      if (ml2ptr0->y1 == yhigh)
         {
         if (ml1ptr0->blink != -1)
            {
            next = (struct HSpb_master *) ((int) ml1 + ml1ptr0->blink * dim);
            next->flink = ml1ptr0->flink;
            }
         else
            *start = ml1ptr0->flink;

         if (ml1ptr0->flink != -1)
            {
            next = (struct HSpb_master *) ((int) ml1 + ml1ptr0->flink * dim);
            next->blink = ml1ptr0->blink;
            }
         }
      else
         {
         ml2ptr0->x0 = x1high;
         if (element_parms.facet_type == FEM_TILE)
            {
            ml2ptr0->u0 = ml1ptr0->u_pt;
            ml2ptr0->v0 = ml1ptr0->v_pt;
            }

         if (element_parms.facet_type == RENDERED ||
             tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
            {
            ml2ptr0->u0 = ml1ptr0->u_pt;
            ml2ptr0->v0 = ml1ptr0->v_pt;
            ml2ptr0->nz0 = ml1ptr0->pt[4];

            if (active_window->perspective) ml2ptr0->w0 = ml1ptr0->pt[3];

            ml2ptr0->u0_texture = ml1ptr0->u;
            ml2ptr0->v0_texture = ml1ptr0->v;

#           if TEXTURE_DEBUG
            fprintf (stderr, "do_fill: vertex is at addr %x\tml2ptr0->u0_texture = %lf\tv0_texture = %lf\n",
                     ml1ptr1, ml2ptr0->u0_texture, ml2ptr0->v0_texture);
#           endif
            }
         unmark0 = 0x0d;
         }

      unmark1 = 0;
      if (ml2ptr1->y1 == yhigh)
         {
         if (ml1ptr1->blink != -1)
            {
            next = (struct HSpb_master *)((int) ml1 + ml1ptr1->blink * dim);
            next->flink = ml1ptr1->flink;
            }
         else
            *start = ml1ptr1->flink;

         if (ml1ptr1->flink != -1)
            {
            next = (struct HSpb_master *)((int) ml1 + ml1ptr1->flink * dim);
            next->blink = ml1ptr1->blink;
            }
         }
      else
         {
         ml2ptr1->x0 = x2high;
         if (element_parms.facet_type == FEM_TILE)
            {
            ml2ptr1->u0 = ml1ptr1->u_pt;
            ml2ptr1->v0 = ml1ptr1->v_pt;
            }

         if (element_parms.facet_type == RENDERED ||
             tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
            {
            ml2ptr1->u0 = ml1ptr1->u_pt;
            ml2ptr1->v0 = ml1ptr1->v_pt;
            ml2ptr1->nz0 = ml1ptr1->pt[4];

            if (active_window->perspective) ml2ptr1->w0 = ml1ptr1->pt[3];

            ml2ptr1->u0_texture = ml1ptr1->u;
            ml2ptr1->v0_texture = ml1ptr1->v;

#           if TEXTURE_DEBUG
            fprintf (stderr, "do_fill: ml2ptr1->u0_texture = %lf\tv0_texture = %lf\n",
                     ml2ptr1->u0_texture, ml2ptr1->v0_texture);
#           endif
            }
         unmark1 = 0x0d;
         }

      ml2ptr0->y0 = yhigh;
      ml2ptr1->y0 = yhigh;

      /* construct HSpb_edge markings to pass to traps */

      femark = init_fem_mark;

      if (ml2ptr0->mesh_mark & 1) femark |= 8;
      if (ml2ptr1->mesh_mark & 1) femark |= 1;

      femark = femark | (ml2ptr0->mesh_mark & 2) | (ml2ptr1->mesh_mark & 2);

      if (unmark0 == 0) femark |= (ml2ptr0->mesh_mark & 4);
      if (unmark1 == 0) femark |= (ml2ptr1->mesh_mark & 4);

      /* unmark horizontal edges at ylow */

      if (unmark0) ml2ptr0->mesh_mark = ml2ptr0->mesh_mark & unmark0;
      if (unmark1) ml2ptr1->mesh_mark = ml2ptr1->mesh_mark & unmark1;

#     if DEBUG
      fprintf (stderr, "left x0, y0, x1, y1: %f %f %f %f\n", x1low,
               ylow, x1high, yhigh);
      fprintf (stderr, "left nx0, ny0, nz0: %f %f %f\n", u1low, v1low, nz1low);
      fprintf (stderr, "left nx1, ny1, nz1: %f %f %f\n", ml1ptr0->u_pt,
               ml1ptr0->v_pt, ml1ptr0->pt[4]);
      fprintf (stderr, "right x0, x1: %f %f\n", x2low, x2high);
      fprintf (stderr, "right nx0, ny0, nz0: %f %f %f\n", u2low, v2low, nz2low);
      fprintf (stderr, "right nx1, ny1, nz1: %f %f %f\n", ml1ptr1->u_pt,
               ml1ptr1->v_pt, ml1ptr1->pt[4]);
      fprintf (stderr, "0mesh_mark = %d\n", ml2ptr0->mesh_mark);
      fprintf (stderr, "1mesh_mark = %d\n", ml2ptr1->mesh_mark);
      fprintf (stderr, "femark = %d\n", femark);
#     endif

      if (element_parms.facet_type == FEM_TILE)
         {
         if (x1high <= x2high)
            HSform_fem_trap ((unsigned long) yhigh,
                             (unsigned long) ylow,
                             XZROUND (x1high), XZROUND (x1low),
                             XZROUND (x2high), XZROUND (x2low),
                             XZROUND (z1high), XZROUND (z1low),
                             XZROUND (z2high), XZROUND (z2low),
                             IROUND (i1high), IROUND (i1low),
                             IROUND (i2high), IROUND (i2low),
                             UVROUND (u1low), UVROUND (ml1ptr0->u_pt),
                             UVROUND (u2low), UVROUND (ml1ptr1->u_pt),
                             UVROUND (v1low), UVROUND (ml1ptr0->v_pt),
                             UVROUND (v2low), UVROUND (ml1ptr1->v_pt),
                             femark);
         else
            HSform_fem_trap ((unsigned long) yhigh,
                             (unsigned long) ylow,
                             XZROUND (x2high), XZROUND (x1low),
                             XZROUND (x1high), XZROUND (x2low),
                             XZROUND (z2high), XZROUND (z1low),
                             XZROUND (z1high), XZROUND (z2low),
                             IROUND (i2high), IROUND (i1low),
                             IROUND (i1high), IROUND (i2low),
                             UVROUND (u1low), UVROUND (ml1ptr1->u_pt),
                             UVROUND (u2low), UVROUND (ml1ptr0->u_pt),
                             UVROUND (v1low), UVROUND (ml1ptr1->v_pt),
                             UVROUND (v2low), UVROUND (ml1ptr0->v_pt),
                             femark);
         }

      else 
      if (tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS)
         {
         if (x1high <= x2high)
             HSform_phong_trap((unsigned long) yhigh, (unsigned long) ylow,
                               XZROUND (x1high), XZROUND (x1low),
                               XZROUND (x2high), XZROUND (x2low),
                               XZROUND (z1high), XZROUND (z1low),
                               XZROUND (z2high), XZROUND (z2low),
                               femark,
                               u1low, v1low, nz1low, 
                               u2low, v2low, nz2low,
                               ml1ptr0->u_pt, ml1ptr0->v_pt, ml1ptr0->pt[4], 
                               ml1ptr1->u_pt, ml1ptr1->v_pt, ml1ptr1->pt[4],
                               w1low, w2low, ml1ptr0->pt[3], ml1ptr1->pt[3],
                               text_u1low, text_u2low, ml1ptr0->u, ml1ptr1->u,
                               text_v1low, text_v2low, ml1ptr0->v, ml1ptr1->v);
         else
            HSform_phong_trap ((unsigned long) yhigh, (unsigned long) ylow,
                               XZROUND (x2high), XZROUND (x1low),
                               XZROUND (x1high), XZROUND (x2low),
                               XZROUND (z2high), XZROUND (z1low),
                               XZROUND (z1high), XZROUND (z2low),
                               femark,
                               u1low, v1low, nz1low, 
                               u2low, v2low, nz2low,
                               ml1ptr1->u_pt, ml1ptr1->v_pt, ml1ptr1->pt[4], 
                               ml1ptr0->u_pt, ml1ptr0->v_pt, ml1ptr0->pt[4],
                               w1low, w2low, ml1ptr1->pt[3], ml1ptr0->pt[3],
                               text_u1low, text_u2low, ml1ptr0->u, ml1ptr1->u,
                               text_v1low, text_v2low, ml1ptr0->v, ml1ptr1->v);
         }

      else 
      if (element_parms.facet_type == RENDERED )
         {
#        if TEXTURE_DEBUG
         fprintf (stderr, "x1high = %d\tx2high = %d\n", x1high, x2high);
#        endif

         if (x1high <= x2high)
            HSform_render_trap ((int) ylow, (int) yhigh,
                                PHLROUND (x1low), PHLROUND (x2low),
                                PHLROUND (x1high), PHLROUND (x2high),
                                z1low, z2low,
                                z1high, z2high,
                                PHROUND (u1low), PHROUND (v1low),
                                PHROUND (nz1low), PHROUND (u2low),
                                PHROUND (v2low), PHROUND (nz2low),
                                PHROUND (ml1ptr0->u_pt), 
                                PHROUND (ml1ptr0->v_pt),
                                PHROUND (ml1ptr0->pt[4]), 
                                PHROUND (ml1ptr1->u_pt),
                                PHROUND (ml1ptr1->v_pt), 
                                PHROUND (ml1ptr1->pt[4]),
                                w1low, w2low, ml1ptr0->pt[3], ml1ptr1->pt[3],
                                (HRuv) text_u1low, (HRuv) text_u2low, 
                                (HRuv) ml1ptr0->u, (HRuv) ml1ptr1->u,
                                (HRuv) text_v1low, (HRuv) text_v2low, 
                                (HRuv) ml1ptr0->v, (HRuv) ml1ptr1->v);
         else
            HSform_render_trap ((int) ylow, (int) yhigh,
                                PHLROUND (x1low), PHLROUND (x2low),
                                PHLROUND (x2high), PHLROUND (x1high),
                                z1low, z2low,
                                z2high, z1high,
                                PHROUND (u1low), PHROUND (v1low),
                                PHROUND (nz1low), PHROUND (u2low),
                                PHROUND (v2low), PHROUND (nz2low),
                                PHROUND (ml1ptr1->u_pt), 
                                PHROUND (ml1ptr1->v_pt),
                                PHROUND (ml1ptr1->pt[4]), 
                                PHROUND (ml1ptr0->u_pt),
                                PHROUND (ml1ptr0->v_pt), 
                                PHROUND (ml1ptr0->pt[4]),
                                w1low, w2low, ml1ptr1->pt[3], ml1ptr0->pt[3],
                                (HRuv) text_u1low, (HRuv) text_u2low, 
                                (HRuv) ml1ptr0->u, (HRuv) ml1ptr1->u,
                                (HRuv) text_v1low, (HRuv) text_v2low, 
                                (HRuv) ml1ptr0->v, (HRuv) ml1ptr1->v);
         }

      else 
         {
         if (x1high <= x2high)
            form_trap ((unsigned long) yhigh,
                       (unsigned long) ylow,
                       XZROUND (x1high), XZROUND (x1low),
                       XZROUND (x2high), XZROUND (x2low),
                       XZROUND (z1high), XZROUND (z1low),
                       XZROUND (z2high), XZROUND (z2low),
                       IROUND (i1high), IROUND (i1low),
                       IROUND (i2high), IROUND (i2low), femark);
         else
            form_trap ((unsigned long) yhigh,
                       (unsigned long) ylow,
                       XZROUND (x2high), XZROUND (x1low),
                       XZROUND (x1high), XZROUND (x2low),
                       XZROUND (z2high), XZROUND (z1low),
                       XZROUND (z1high), XZROUND (z2low),
                       IROUND (i2high), IROUND (i1low),
                       IROUND (i1high), IROUND (i2low), femark);
         }
      }
   }

/*--- intersecting ----------------------------------------------------*/

static int intersecting (struct HSpb_master * ml,
                         int *list,
                         int n,
                         int ylo,
                         int yhi,
                         int *pt,
                         int dim)
/*
NAME
        intersecting

KEYWORD
        polybuster

DESCRIPTION
        This function checks to see if any of the edges in the list intersect.

PARAMETERS
        ml (IN) - List of vertices at top of each edge.
        list (IN) - Contains the indices which form a linked list of the 'ml' array.
        n (IN) - Number of edges active at this time (should be an even number).
        ylo,yhi (IN) - Indicates top and bottom of trapezoid(s).
        pt (OUT) - Index of the first edge of the first intersection found.
        dim (IN) - Size (in bytes) of the vertex structure.

GLOBALS USED
        none.

RETURN VALUES
        1 -> Intersection found.
        0 -> No intersections.
        
HISTORY
        --/--/-- Created. -???
        11/13/89 Added tolerance test for y.		C. M. Jablonski
        02/08/92 Documented. -Trevor Mink
*/
   {
   register struct HSpb_master *mlptr0, *mlptr1;
   register int i;
   int ytmp;

   for (i = 0; i < n - 1; i++)
      {
      mlptr0 = (struct HSpb_master *) ((int) ml + list[i] * dim);
      mlptr1 = (struct HSpb_master *) ((int) ml + list[i + 1] * dim);
      if ((XENDROUND (mlptr0->f1.xendpt) >> 16) > (XENDROUND (mlptr1->f1.xendpt) >> 16))
         {
         ytmp = YROUND ((mlptr1->pt[0] - mlptr0->pt[0]) /
                        (mlptr0->pt[1] - mlptr1->pt[1]));
         if ((ytmp != ylo) && (ytmp != yhi))
            {
            *pt = i;
            return (1);
            }
         }
      }

   return (0);
   }

/*--- poly_bust ----------------------------------------------------------*/

void poly_bust (int nvert,
           struct HSpb_master * ml1,
           struct HSpb_edge * ml2,
           int *intr1,
           int *intr2,
           int dim,
           int shade)
/*
NAME
        poly_bust

KEYWORD
        polybuster

DESCRIPTION
        This function checks to see if any of the edges in the list intersect.

PARAMETERS
        nvert (IN) - Number of vertices in current polygon.
        ml1 (IN) - List of vertices.
        ml2 (IN) - List of edges.
        intr1,intr2 (IN) - Contains the indices which form a linked list of the 'ml1' and 'ml2' arrays.
        dim (IN) - Size (in bytes) of the vertex structure.
        shade (IN) - A flag indicating whether the lists are formatted for 2D, 3D, or 4D (0,1, or 2).

GLOBALS USED
        none.

RETURN VALUES
        none.

HISTORY
        --/--/-- Created. -???
        02/08/92 Documented. -Trevor Mink
*/
   {
   register struct HSpb_master *ml1ptr0, *ml1ptr1;
   register struct HSpb_edge *ml2ptr0, *ml2ptr1;
   register int i, j;
   int itemp, ylo;
   int start;
   double yscan;
   double scanstk[100];
   int sp;
   int shade_index;

   if (nvert == 1)
      { /* this shouldn't happen, but ... */
#if DEBUG
      printf ("HSpbust warning: single vertex polygon.\n");
#endif
      return;
      }

   /*
    * Scale dis_tol by same scaling as x coords (after scaling from world to
    * viewport)
    */
   xTolerance = element_parms.dis_tol * active_window->wv_scale * 65536.0;

   if (shade)
      shade_index = 4;
   else
      shade_index = 0;

   switch (dim)
      {
      case 0:
         dim = 32;
         edge_dim = 32;
         break;
      case 1:
         dim = 96;      /* was 80 */
         edge_dim = 56;
         break;
      case 2:
         dim = 96;      /* was 80 */
         edge_dim = FEMSIZE;
         break;
      case 3:
         dim = 96;      /* was 80 */
         if (active_window->perspective /* && element_parms.facet_type ==
                 RENDERED_TEXTURED */ )
            edge_dim = PHONGWTEXTURE;
         else if (active_window->perspective || TRUE    /* element_parms.facet_ty
                                                         * pe ==
                      RENDERED_TEXTURED */ )
            edge_dim = PHONGWSIZE;
         else
            edge_dim = PHONGSIZE;
         break;
         }
   vector_to_edge (ml1, ml2, &nvert, intr1, intr2, dim, shade_index);
   if (!nvert)
      { /* this could happen if all edges are horizontal */
      return;
      }
   sorty0 (ml2, intr1, 0, nvert - 1, dim);

   /* thread a linked list based on the sorted indices */

   for (i = 1; i < nvert - 1; i++)
      {
      ml1ptr0 = (struct HSpb_master *) ((int) ml1 + intr1[i] * dim);
      ml1ptr0->flink = intr1[i + 1];
      ml1ptr0->blink = intr1[i - 1];
      }
   ml1ptr0 = (struct HSpb_master *) ((int) ml1 + intr1[0] * dim);
   ml1ptr0->flink = intr1[1];
   ml1ptr0->blink = -1;
   ml1ptr0 = (struct HSpb_master *) ((int) ml1 + intr1[nvert - 1] * dim);
   ml1ptr0->flink = -1;
   ml1ptr0->blink = intr1[nvert - 2];

   start = intr1[0];
   for (;;)
      {
      if (start == -1)  /* check for an empty list */
         break;

      i = start;
      j = 0;
      yscan = MAXFLOAT;

      /*
       * build a list of edges to be considered for this pass and determine
       * the proper cutoff value (yscan)
       */

      ml2ptr0 = (struct HSpb_edge *) ((int) ml2 + start * edge_dim);
      ylo = YROUND (ml2ptr0->y0);
#if DEBUG
      fprintf (stderr, "ml2ptr0->y0 = %f\n", ml2ptr0->y0);
      fprintf (stderr, "ml2ptr0->y1 = %f\n", ml2ptr0->y1);
#endif
      while (i != -1)
         {
         ml1ptr0 = (struct HSpb_master *) ((int) ml1 + i * dim);
         ml2ptr1 = (struct HSpb_edge *) ((int) ml2 + i * edge_dim);
#if DEBUG
         fprintf (stderr, "ml2ptr1->y0 = %f\n", ml2ptr1->y0);
         fprintf (stderr, "ml2ptr1->y1 = %f\n", ml2ptr1->y1);
#endif
         if (ml2ptr1->y0 == ml2ptr0->y0)
            {
            intr2[j] = i;
            j++;
            }
         else
            {
            if (yscan > ml2ptr1->y0)
               yscan = ml2ptr1->y0;
            break;
            }
         if (yscan > ml2ptr1->y1)
            yscan = ml2ptr1->y1;

         i = ml1ptr0->flink;
         }

      sp = 0;   /* Start with an empty stack */

      do
         {
         /* Calculate and sort x-intercepts at the current yscan */
         findxint (ml1, ml2, intr2, j, yscan, dim);
         sortx0 (ml1, ml2, intr2, 0, j - 1, dim);

         /* stack yscan values until there are no more intersections */
         while (intersecting (ml1, intr2, j, ylo, YROUND (yscan), &itemp, dim))
            {
            i = itemp;
            if (sp == 100)
               {
#if DEBUG
               fprintf (stderr, "HSpbust error: stack full, too many intersections.\n");
#endif
               return;
               }
            scanstk[sp++] = yscan;

            /* Calculate a new yscan based upon the two edges that intersect */
            ml1ptr0 = (struct HSpb_master *) ((int) ml1 + intr2[i] * dim);
            ml1ptr1 = (struct HSpb_master *) ((int) ml1 + intr2[i + 1] * dim);
            yscan = (ml1ptr1->pt[0] - ml1ptr0->pt[0]) /
               (ml1ptr0->pt[1] - ml1ptr1->pt[1]);

            /* Calculate x-intercepts for the new yscan, then sort them */
            findxint (ml1, ml2, intr2, j, yscan, dim);
            sortx0 (ml1, ml2, intr2, 0, j - 1, dim);

            ml1ptr0->f1.xendpt = ml1ptr1->f1.xendpt;
            }

         /*
          * do a fill, unstack a yscan value, and check for intersections
          * again.  Repeat until we are at the yscan value we determined
          * before any intersections were found.
          */
         do_fill (ml1, ml2, intr2, yscan, j, &start, dim, shade_index);
         ylo = YROUND (yscan);

         /* If stack is empty stop here */
         if (!sp)
            break;
         yscan = scanstk[--sp]; /* Pop the stack */
         }

      while (TRUE);
      }

   }    /* poly_bust */
