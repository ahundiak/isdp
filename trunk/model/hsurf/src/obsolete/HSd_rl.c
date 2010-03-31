
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

/*		Apogee compliant		*/


/*#include "hsurf_import.h"*/
#include "stdlib.h"
#include "igrtypedef.h"
#include "igr.h"

#include "hsmath.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "stdio.h"

#include "HSpr_display.h"

#define xstep    1
#define ystep    active_window->x_dits
#define MAX_Z    2147483640
#define H_FACTOR 0.25

/*
 *  Prototype declarations for static functions
 */

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static mark_edge __((int x, 
		     int wasx, 
		     int y, 
		     int color,
		  HSzbuf active_z, 
		     int zpf, 
		     int chg_z));
		     
static void do_interior_pixels __((HScbuf *pix_col, 
				   HSzbuf *pix_z, 
				   HSzbuf active_z, 
				      int y, 
				      int color, 
				      int zpf, 
				      int last_color, 
				      int num_shades, 
				      int h_c_f, 
				      int step_factor, 
				      int weight, 
			 struct trapezoid *tile));

#if defined(__cplusplus)
}
#endif


#undef __


/*---SET_COL--------------------------------------------------------------*/

#define SET_COL( clr, chg_z )                                             \
                                                                          \
  {                                                                       \
  set_col = pix_col - step_factor;                                        \
  set_z   = pix_z - step_factor;                                          \
                                                                          \
  for (i = 0; i <= weight; i++)                                           \
    {                                                                     \
    for (j = 0; j <= weight; j++)                                         \
      {                                                                   \
      if ((*(set_col + j) == 0)                                           \
       || ((int) *(set_z + j) - (int) active_z > zpf))                    \
        {                                                                 \
        if (set_col + j >= active_window->cbuf                            \
         && set_col + j <= active_window->cbuf + num_pixels)              \
          {                                                               \
          *(set_col + j) = (clr);                                         \
          if ((chg_z))                                                    \
            *(set_z + j) = active_z;                                      \
          }                                                               \
        } /* end if */                                                    \
      } /* end for j */                                                   \
                                                                          \
    set_col += ystep;                                                     \
    set_z   += ystep;                                                     \
    } /* end for i */                                                     \
                                                                          \
  } /* end SET_COL */


/*---mark_edge------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static mark_edge( int x,
			  int wasx,
			  int y,
			  int color,
		       HSzbuf active_z,
			  int zpf,
			  int chg_z )
#else
	static mark_edge( x, wasx, y, color, active_z, zpf, chg_z )

	int	x;
	int	wasx;
	int	y;
	int	color;
	HSzbuf	active_z;
	int	zpf;
	int	chg_z;
#endif

  {
  int xleft, xright, offset;
  int step_factor;
  int weight;
  int i, j;
  int num_pixels;

  HScbuf *pix_col, *set_col;
  HSzbuf *pix_z, *set_z;

  num_pixels = active_window->x_dits * active_window->y_dits;

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
  pix_col = active_window->cbuf + offset;
	
  weight = (int) element_parms.visible_weight;

  step_factor = (weight / 2) * (xstep + ystep);

  while (xleft++ <= xright) 
    {
    SET_COL( color, chg_z ) 

    pix_col++;
    pix_z++;
    } /* end while */
 
  } /* end mark_edge */


/*---DO_EDGE_PIXELS--------------------------------------------------------*/

#define DO_EDGE_PIXELS( was )            			          \
								          \
  {			         				          \
  if (*zb >= rzc.active)					          \
    mark_edge (x, (was), y, element_parms.color, rzc.active, zpf, TRUE);  \
                                                                          \
  else if (*(zb - xstep) >= rzc.active		                          \
        || *(zb - ystep) >= rzc.active				          \
        || *(zb + xstep) >= rzc.active				          \
        || *(zb + ystep) >= rzc.active)				          \
    mark_edge (x, (was), y, element_parms.color, rzc.active, zpf, FALSE); \
                                                                          \
  else	                                                                  \
    mark_edge (x, (was), y, element_parms.color + h_c_f, rzc.active, zpf, \
               FALSE);                                                    \
								          \
  Fixed_add (rzc);						          \
								          \
  zb++;								          \
  cb++;								          \
  x++;								          \
  } /* end DO_EDGE_PIXELS */
	

/*---do_interior_pixels------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void do_interior_pixels( HScbuf *pix_col,
					HSzbuf *pix_z,
					HSzbuf active_z,
					   int y,
					   int color,
					   int zpf,
					   int last_color,
					   int num_shades,
					   int h_c_f,
					   int step_factor,
					   int weight,
			      struct trapezoid *tile )
#else
	static void do_interior_pixels (pix_col, pix_z, active_z, y, color, zpf,
	                                last_color, num_shades, h_c_f, step_factor,
	                                weight, tile)

	HScbuf			*pix_col;
	HSzbuf			*pix_z;
	HSzbuf			active_z;
	int			y;
	int			color;
	int			zpf;
	int			last_color;
	int			num_shades;
	int			h_c_f;
	int			step_factor;
	int			weight;
	struct trapezoid	*tile;
#endif

  {
  int i, j;
  int num_pixels;

  HScbuf *set_col;
  HSzbuf *set_z;

  num_pixels = active_window->x_dits * active_window->y_dits;

  if (*pix_z >= active_z)
    {
    if ((y == tile->yb && tile->id & TOP_EDGE)
     || (y == tile->ya && tile->id & BOTTOM_EDGE))
      SET_COL( color, TRUE )

    else
      {
      /* Hide a visible pixel. */
      if (*pix_col > 0
       && *pix_z - active_z > zpf)
        {
        /* Ensure that the pixel is not already hidden. */
        for (i = tiling_parms.base_color; i <= last_color; i += num_shades)
          if (*pix_col == i)
            {
            *pix_col = *pix_col + h_c_f;
            break;
            }
        } /* end if */

      } /* end else */

    *pix_z = active_z;
    }	/* end if (*pix_z >= active_z) */

  else if ((y == tile->yb && tile->id & TOP_EDGE)
        || (y == tile->ya && tile->id & BOTTOM_EDGE))
    SET_COL( color + h_c_f, FALSE )
  } /* end do_interior_pixels */

/*---HSraster_edges-----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSraster_edges( struct trapezoid *tile )
#else
	void HSraster_edges( tile )

	struct trapezoid *tile;  /*  trapezoids data  */
#endif

  {
  int  rxa, rxb, dxa, dxb;
  int  dxc;
  int  dy;
  int  x, y;
  int  offset;
  int  was_xleft, was_xright;
  int  num_shades;
  int  weight, weight_factor;
  int  step_factor;
  int  h_c_f; /* hidden color factor */
  int  last_color;
  int  rz_factor;
  int  zpf, zpf2;
  int  i_rza, i_rzb;
   
  register int xleft, xright;

  struct HSfixedpt rza, rzb, rzc;

  HScbuf *cb;
  HSzbuf *zb;

  /*
   * Modify the dimensions of the active window if necessary.
   */
  if (tile->x0 < active_window->x_min_rl) active_window->x_min_rl = tile->x0;
  if (tile->x1 > active_window->x_max_rl) active_window->x_max_rl = tile->x1;
  if (tile->x2 < active_window->x_min_rl) active_window->x_min_rl = tile->x2;
  if (tile->x3 > active_window->x_max_rl) active_window->x_max_rl = tile->x3;
  if (tile->yb < active_window->y_min_rl) active_window->y_min_rl = tile->yb;
  if (tile->ya > active_window->y_max_rl) active_window->y_max_rl = tile->ya;

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
		  &rzb.d_fract);

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

  num_shades = tiling_parms.number_shades;
  if (num_shades == 1)
    h_c_f = 0;
  else
    {
    h_c_f = (num_shades - 1) - (int) (H_FACTOR * (num_shades - 1) + 0.5);
    if (h_c_f == 0)
      h_c_f = 1;
    }

  last_color = (tiling_parms.number_colors - 1) * num_shades + 1;

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
     * Establish the value of x at the endpoints of a scanline.  When interpolating
     * from top to bottom of a trapezoid, the x's are maintained in a <16:16>
     * format to maximize precision, therefore, the values have to be shifted 16
     * to the right to get the whole value of x
     */
    xleft = rxa >> 16;
    xright = rxb >> 16;

    /*
     * Calculate the change in z with respect to x for rasterizing horizontal
     * scanlines. Use the fixed point functions for z interpolation.
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

    zb = active_window->zbuf + (offset = y * active_window->x_dits + xleft);
    cb = active_window->cbuf + offset;
		
    x = xleft;
    if (tile->id & LEFT_EDGE)
      DO_EDGE_PIXELS( was_xleft )

    for (; x < xright; x++)
      {
      do_interior_pixels (cb, zb, rzc.active, y, element_parms.color, zpf, last_color,
                          num_shades, h_c_f, step_factor, weight, tile);
      cb++;
      zb++;

      Fixed_add (rzc);
      }

    if (tile->id & RIGHT_EDGE)
      DO_EDGE_PIXELS( was_xright )

    else
      {
      do_interior_pixels (cb, zb, rzc.active, y, element_parms.color, zpf, last_color,
                          num_shades, h_c_f, step_factor, weight, tile);
      cb++;
      zb++;

      Fixed_add (rzc);
      }

    rxa += dxa;
    Fixed_add (rza);

    rxb += dxb;
    Fixed_add (rzb);

    was_xleft = xleft;

    was_xright = xright;
    } /* end for y */

  weight_factor = (weight + 1) / 2;

  active_window->x_min_rl = active_window->x_min_rl >> 16;
  active_window->x_max_rl = active_window->x_max_rl >> 16;

  active_window->x_min_rl -= weight_factor;
  if (active_window->x_min_rl < 0)
    active_window->x_min_rl = 0;

  active_window->x_max_rl += weight_factor;
  if (active_window->x_max_rl > active_window->x_dits)
    active_window->x_max_rl = active_window->x_dits;

  active_window->y_min_rl -= weight_factor;
  if (active_window->y_min_rl < 0)
    active_window->y_min_rl = 0;

  active_window->y_max_rl += weight_factor;
  if (active_window->y_max_rl > active_window->y_dits)
    active_window->y_max_rl = active_window->y_dits;
		
  if (active_window->x_min_rl < (active_window->x_min >> 16))
    active_window->x_min = active_window->x_min_rl << 16;

  if (active_window->x_max_rl > (active_window->x_max >> 16))
    active_window->x_max = active_window->x_max_rl << 16;

  if (active_window->y_min_rl < active_window->y_min)
    active_window->y_min = active_window->y_min_rl;

  if (active_window->y_max_rl > active_window->y_max)
    active_window->y_max = active_window->y_max_rl;

  active_window->x_min_rl = active_window->x_dits << 16;
  active_window->y_min_rl = active_window->y_dits;
  active_window->x_max_rl = 0;
  active_window->y_max_rl = 0;
  } /* end HSraster_edges */
