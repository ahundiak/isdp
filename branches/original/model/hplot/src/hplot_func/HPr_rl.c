#include "stdio.h"
#if defined (CLIX)
#include "gpipe.h"
#endif
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hsmath.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HPglobal.h"
#include "HStl_global.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"


/*-----------------------
 *
 *   for function
 *      fixed_divid
 */
 
#include "HSpr_display.h"

/*----------------------*/




/*
 *  Prototype declaration for static functions
 */
 
#if defined(__STDC__) || defined(__cplusplus)

#if defined(__cplusplus)
extern "C" {
#endif

static mark_edge( int x, 
		  int wasx, 
		  int y, 
		  int intens, 
	       HSzbuf active_z, 
		  int zpf, 
		  int chg_z );

static void do_interior_pixels( HScbuf *pix_col, 
				HSzbuf *pix_z, 
				HSzbuf active_z, 
				   int y, 
				   int zpf, 
				   int step_factor, 
				   int weight, 
		      struct trapezoid *tile );

#if defined(__cplusplus)
}
#endif

#else

static mark_edge();
static void do_interior_pixels();

#endif


#define vis_intens 0
#define hid_intens 200
#define xstep      1
#define ystep      active_window->x_dits
#define MAX_Z      2147483640

static int line_color;
static int bg_color;

/*---SET_COL--------------------------------------------------------------*/

/*
NAME
	SET_COL: Macro
	
KEYWORDS
	HSplot
	RHL2
	macros
	rasterizer
		
DESCRIPTION
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#define SET_COL(intens, chg_z)                                            \
                                                                          \
  {                                                                       \
  set_col = pix_col - (step_factor * 2);                                  \
  set_z   = pix_z - step_factor;                                          \
                                                                          \
  for (i = 0; i <= weight; i++)                                           \
    {                                                                     \
    for (j = 0; j <= weight; j++)                                         \
      {                                                                   \
      set_col_pt = set_col + (j * 2);                                     \
                                                                          \
      if (set_col_pt >= active_window->cbuf                               \
       && set_col_pt <= active_window->cbuf + num_pixels)                 \
        if ((set_col_pt[0] == bg_color)                                   \
         || ((int) *(set_z + j) - (int) active_z > zpf))                  \
          {                                                               \
          set_col_pt[0] = line_color;                                     \
          set_col_pt[1] = (intens);                                       \
          if ((chg_z))                                                    \
            *(set_z + j) = active_z;                                      \
          } /* end if */                                                  \
      } /* end for j */                                                   \
                                                                          \
    set_col += (ystep * 2);                                               \
    set_z   += ystep;                                                     \
    } /* end for i */                                                     \
                                                                          \
  } /* end SET_COL */


/*---mark_edge------------------------------------------------------------*/

/*
NAME
	mark_edge: static
	
KEYWORDS
	HSplot
	RHL2
	rasterizer
	static
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	static mark_edge( int x, 
			  int wasx, 
			  int y, 
			  int intens, 
		       HSzbuf active_z, 
			  int zpf, 
			  int chg_z )	  
#else
	static mark_edge (x, wasx, y, intens, active_z, zpf, chg_z)
	  int    x;
	  int    wasx;
	  int    y;
	  int    intens;
	  HSzbuf active_z;
	  int    zpf;
	  int    chg_z;
#endif

  {
  int xleft, xright, offset;
  int step_factor;
  int weight;
  int i, j;
  int num_pixels;

  HScbuf *pix_col, *set_col, *set_col_pt;
  HSzbuf *pix_z, *set_z;

  num_pixels = active_window->x_dits * active_window->y_dits * 2;

  if (x < wasx)
    {
    xleft = x;
    xright = wasx - 1;
    }

  else if (x > wasx)
    {
    xleft = wasx + 1;
    xright = x;
    }

  else
    {
    xleft = x;
    xright = x;
    }

  pix_z = active_window->zbuf + (offset = y * active_window->x_dits + xleft);
  pix_col = active_window->cbuf + (offset * 2);
	
  weight = (int) element_parms.visible_weight;

  step_factor = (weight / 2) * (xstep + ystep);

  while (xleft++ <= xright) 
    {
    SET_COL (intens, chg_z) 

    pix_col += 2;
    pix_z++;
    } /* end while */
 
  } /* end mark_edge */


/*---DO_EDGE_PIXELS--------------------------------------------------------*/

/*
NAME
	DO_EDGE_PIXELS: Macro
	
KEYWORDS
	HSplot
	rasterizer
	RHL2
	macro
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#define DO_EDGE_PIXELS(was)              			          \
								          \
  {			         				          \
  if (*zb >= rzc.active)					          \
    mark_edge (x, (was), y, vis_intens, rzc.active, zpf, TRUE);           \
                                                                          \
  else if (*(zb - xstep) >= rzc.active		                          \
        || *(zb - ystep) >= rzc.active				          \
        || *(zb + xstep) >= rzc.active				          \
        || *(zb + ystep) >= rzc.active)				          \
    mark_edge (x, (was), y, vis_intens, rzc.active, zpf, FALSE);          \
                                                                          \
  else	                                                                  \
    mark_edge (x, (was), y, hid_intens, rzc.active, zpf, FALSE);          \
								          \
  Fixed_add (rzc);						          \
								          \
  zb++;								          \
  cb += 2;                                                                \
  x++;								          \
  } /* end DO_EDGE_PIXELS */
	

/*---do_interior_pixels---------------------------------------------------------------------*/

/*
NAME
	do_interior_pixels: static
	
KEYWORDS
	HSplot
	rasterizer
	RHL2
	static
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	static void do_interior_pixels( HScbuf *pix_col, 
					HSzbuf *pix_z, 
					HSzbuf active_z, 
					   int y, 
					   int zpf, 
					   int step_factor, 
					   int weight, 
			      struct trapezoid *tile )		      
#else
	static void do_interior_pixels (pix_col, pix_z, active_z, y, zpf, step_factor, weight, tile)
	  HScbuf *pix_col;
	  HSzbuf *pix_z, active_z;
	  int    y;
	  int    zpf;
	  int    step_factor;
	  int    weight;
	  struct trapezoid *tile;
#endif

  {
  int i, j;
  int num_pixels;

  HScbuf *set_col, *set_col_pt;
  HSzbuf *set_z;

  num_pixels = active_window->x_dits * active_window->y_dits * 2;

  if (*pix_z >= active_z)
    {
    if ((y == tile->yb && tile->id & TOP_EDGE)
     || (y == tile->ya && tile->id & BOTTOM_EDGE))
      SET_COL (vis_intens, TRUE)

    else if (*pix_z - active_z > zpf)
      pix_col[1] = hid_intens; /* Hide a visible pixel. */

    *pix_z = active_z;
    }	/* end if (*pix_z >= active_z) */

  else if ((y == tile->yb && tile->id & TOP_EDGE)
        || (y == tile->ya && tile->id & BOTTOM_EDGE))
    SET_COL (hid_intens, FALSE)
  } /* end do_interior_pixels */

/*---HPraster_edges-----------------------------------------------*/

/*
NAME
	HPraster_edges
	
KEYWORDS
	HSplot
	RHL2
	rasterizer
	
DESCRIPTION
	Rasterizer trapezoid for RHL2 display
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void HPraster_edges (struct trapezoid *tile)
#else
	void HPraster_edges (tile)
	  struct trapezoid *tile;  /* trapezoids data */
#endif

  {
  int  rxa, rxb, dxa, dxb;
  int  dxc;
  int  dy;
  int  x, y;
  int  offset;
  int  was_xleft, was_xright;
  int  new_bound;
  int  weight;
  int  step_factor;
  int  rz_factor;
  int  zpf, zpf2;
  int  i_rza, i_rzb;

  register int xleft, xright;

  struct HSfixedpt rza, rzb, rzc;

  HScbuf *cb;
  HSzbuf *zb;

  tile->ya -= HPband_info.org_y;
  tile->yb -= HPband_info.org_y;

  if (tile->ya < 0
   || tile->yb > HPband_info.y_dits)
    return;

  line_color = element_parms.color;
  bg_color = 0;

  /*
   * Modify the dimensions of the active window if necessary.
   */
  if (tile->x0 < active_window->x_min) active_window->x_min = tile->x0;
  if (tile->x1 > active_window->x_max) active_window->x_max = tile->x1;
  if (tile->x2 < active_window->x_min) active_window->x_min = tile->x2;
  if (tile->x3 > active_window->x_max) active_window->x_max = tile->x3;
  if (tile->yb < active_window->y_min) active_window->y_min = tile->yb;
  if (tile->ya > active_window->y_max) active_window->y_max = tile->ya;

  /*
   * Calculate the delta change in the variables for a single step in y.  If the 
   * y coordinates are equal, set the deltas to 0.
   */
  if ((dy = tile->ya - tile->yb) == 0)
    {
    dxa = 0;
    dxb = 0;

    rza.sign = 1;
    rza.d_whole = 0;
    rza.d_fract = 0;
    rza.running = 0;

    rzb.sign = 1;
    rzb.d_whole = 0;
    rzb.d_fract = 0;
    rzb.running = 0;
    } /* end if */

  else
    {
    dxa = (tile->x0 - tile->x2) / dy;
    dxb = (tile->x1 - tile->x3) / dy;

    fixed_divide ((tile->z0 - tile->z2),
		  dy,
		  &rza.sign,
		  &rza.d_whole,
		  &rza.d_fract);

    rza.running = 0x40000000;

    fixed_divide ((tile->z1 - tile->z3),
		  dy,
		  &rzb.sign,
		  &rzb.d_whole,
		  &rzb.d_fract );

    rzb.running = 0x40000000;
    } /* end else */

  rza.active = tile->z2;
  rzb.active = tile->z3;
  rxa = tile->x2 + 32768;
  rxb = tile->x3 + 32768;
		
  weight = (int) element_parms.visible_weight;

  step_factor = (weight / 2) * (xstep + ystep);

  zpf = MAX_Z / (active_window->dit_clip_range[5] - active_window->dit_clip_range[2]);
  zpf *= 5;

  i_rza = (int) rza.d_whole;
  i_rzb = (int) rzb.d_whole;
  rz_factor = i_rza > i_rzb ? i_rza : i_rzb;
  if (weight & 1)
    zpf2 = rz_factor * ((weight + 1) / 2 + 1);
  else
    zpf2 = rz_factor * (weight / 2 + 1);
  if (zpf2 < 0)
    zpf2 /= -2;

  zpf = zpf > zpf2 ? zpf : zpf2;

  was_xleft  = rxa >> 16;
  was_xright = rxb >> 16;

  for (y = tile->yb; y <= tile->ya; y++)
    {
    /*
     * Before interpolating from left to right on a trapezoid scanline,
     * initialize the third set of z values equal to the value of the left-
     * most edge of the trapezoid at the given scanline. We do this so we
     * can maintain the edge values while interpolating.
     */
    rzc.active = rza.active;
    rzc.running = rza.running;

    /*
     *  Establish the value of x at the endpoints of a scanline.  When interpolating
     *  from top to bottom of a trapezoid, the x's are maintained in a <16:16>
     *  format to maximize precision, therefore, the values have to be shifted 16
     *  to the right to get the whole value of x
     */
    xleft = rxa >> 16;
    xright = rxb >> 16;

    /*
     *  Calculate the change in z with respect to x for rasterizing horizontal
     *  scanlines. Use the fixed point functions for z interpolation.
     */
    if ((dxc = xright - xleft) == 0)
      {
      rzc.sign = 1;
      rzc.d_whole = 0;
      rzc.d_fract = 0;
      }

    else
      {
      fixed_divide((rzb.active - rza.active),
		   dxc,
		   &rzc.sign,
		   &rzc.d_whole,
		   &rzc.d_fract);
      }

    /* y-clip */
    if (y > 0
     && y < HPband_info.y_dits)
      {
      zb = active_window->zbuf + (offset = y * active_window->x_dits + xleft);
      cb = active_window->cbuf + (offset * 2);
		
      x = xleft;
      if (tile->id & LEFT_EDGE)
        DO_EDGE_PIXELS (was_xleft)

      for (; x < xright; x++)
        {
        do_interior_pixels (cb, zb, rzc.active, y, zpf, step_factor, weight, tile);
        cb += 2;
        zb++;

        Fixed_add (rzc);
        } /* end for */

      if (tile->id & RIGHT_EDGE)
        DO_EDGE_PIXELS (was_xright)

      else
        {
        do_interior_pixels (cb, zb, rzc.active, y, zpf, step_factor, weight, tile);
        cb += 2;
        zb++;

        Fixed_add (rzc);
        } /* end else */

      } /* end y-clip */

    rxa += dxa;
    Fixed_add (rza);

    rxb += dxb;
    Fixed_add (rzb);

    was_xleft = xleft;

    was_xright = xright;
    } /* end for y */

  new_bound = active_window->x_min - (weight << 16);
  if (new_bound < 0)
    active_window->x_min = 0;
  else
    active_window->x_min = new_bound;

  new_bound = active_window->x_max + (weight << 16);
  if (new_bound > active_window->x_dits << 16)
    active_window->x_max = active_window->x_dits << 16;
  else
    active_window->x_max = new_bound;

  new_bound = active_window->y_min - weight;
  if (new_bound < 0)
    active_window->y_min = 0;
  else
    active_window->y_min = new_bound;

  new_bound = active_window->y_max + weight;
  if (new_bound > active_window->y_dits)
    active_window->y_max = active_window->y_dits;
  else
    active_window->y_max = new_bound;
  } /* end HSraster_edges */
