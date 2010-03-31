#include <stdio.h>
#include <math.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"

#include "mapower.h"
#include "maptsxfor.h"

/*-----------------------
 *
 *   for function
 *      fixed_divid
 */
 
#include "HSpr_display.h"

/*----------------------*/



static int count = 0;
static int pcount = 0;

/*
 *  Rendering Attribute information
 */

static double	element_color[3];
static double	light_vector[3];
static double	light_location[8][3];
static double	light_direction[8][3];
static double	finish, zscale;
static double	ambient_contribution[3];
static int      transparent;

/*---HPset_rendering_attributes----------------------------------------*/

void  HPset_rendering_attributes(int *t)

   {
   int	i;

   if( t != NULL ) transparent = *t;

   element_color[0] = (double)(HPglobal.color_table[element_parms.color][0] >> 8);
   element_color[1] = (double)(HPglobal.color_table[element_parms.color][1] >> 8);
   element_color[2] = (double)(HPglobal.color_table[element_parms.color][2] >> 8);

   ambient_contribution[0] = (element_color[0] * (double)HPglobal.ambient_light.red) / 255.0;
   ambient_contribution[1] = (element_color[1] * (double)HPglobal.ambient_light.green) / 255.0;
   ambient_contribution[2] = (element_color[2] * (double)HPglobal.ambient_light.blue) / 255.0;

   finish = (double)(HPglobal.elem_finish >> 1);

   for( i=0; i<active_window->num_lights; i++ )
      {
      if( element_parms.front_facing_facet )
         {
         light_direction[i][0] = -active_window->light_sources[i].direction[0];
         light_direction[i][1] = -active_window->light_sources[i].direction[1];
         light_direction[i][2] = -active_window->light_sources[i].direction[2];
         }
      else
         {
         light_direction[i][0] = active_window->light_sources[i].direction[0];
         light_direction[i][1] = active_window->light_sources[i].direction[1];
         light_direction[i][2] = active_window->light_sources[i].direction[2];
         }

      light_location[i][0] = active_window->light_sources[i].location[0];
      light_location[i][1] = active_window->light_sources[i].location[1];
      light_location[i][2] = active_window->light_sources[i].location[2];
      }

   zscale =  (tiling_parms.maximum_z /( active_window->z_max - active_window->z_min));
   }

/*
 *  Macros for the HSURF rasterizer functions
 */
 
static double	view_dir[3] = { 0.0, 0.0, 1.0 };

static void MIRROR_VECTOR( IGRvector axis, 
                           IGRvector vec, 
                           IGRvector mirror_vec )
   {
   IGRdouble temp;
 
   temp = axis[0]*vec[0] + axis[1]*vec[1] + axis[2]*vec[2];
 
   mirror_vec[0] = 2.0 * (temp * axis[0]) - vec[0];
   mirror_vec[1] = 2.0 * (temp * axis[1]) - vec[1];
   mirror_vec[2] = 2.0 * (temp * axis[2]) - vec[2];
   }
 
static unsigned char dtoc( double a )
   {
   if( a < 0.0 ) return 0;
   if( a > 255.0 ) return 255;
   return (unsigned char)a;
   }

/*---TRANSLUCENT----------------------------------------------------------------*/
 
/*
 *  Perform the translucency test.  Will work for both wide and narrow spacing.
 *  In the wide case, uses the pattern buffer, trans_pat6.  For narrow spacing
 *  we exclusive or the x and y value, look at the first bit, and if it is
 *  set, turn the pixel on.
 */
 

#define TRANSLUCENT( x, y )     ( \
        (transparent) && \
        ((tiling_parms.processing_mode & HS_PMODE_TRANS_1x1) ? \
                 ((x ^ y) & 1) : (!trans_pat6[y%6][x%6])) \
                                )

/*---SetPixelColor-------------------------------------------------*/

static void SetPixelColor( int x,  
                           int y,
                           int z,
                           double nx,
                           double ny,
                           double nz,
                           unsigned char *cb )

   {
   long		msg, i;
   double	l_dot_n, r_dot_v, r_dot_v_n;
   double	diffuse;
   double	specular;
   IGRvector	normal, reflect;
   double	dist, dist2;
   double	light_contribution[3];

   if( TRANSLUCENT(x,y) ) return;

   normal[0] = nx;
   normal[1] = ny;
   normal[2] = nz;

   light_contribution[0] = 0.0;
   light_contribution[1] = 0.0;
   light_contribution[2] = 0.0;

   for( i=0; i<active_window->num_lights; i++ )
      {
      switch( active_window->light_sources[i].flags & HS_LIGHT_TYPE ) 
         {
         case HS_LIGHT_POINT:
            light_vector[0] = light_location[i][0] - (double)y;
            light_vector[1] = light_location[i][1] - (double)x;
            light_vector[2] = light_location[i][2] - (double)z/zscale;

            dist2 = (light_vector[0] * light_vector[0]) + 
                    (light_vector[1] * light_vector[1]) +
                    (light_vector[2] * light_vector[2]);

            dist = sqrt( dist2 );

            light_vector[0] /= dist;
            light_vector[1] /= dist;
            light_vector[2] /= dist;
            break;

         case HS_LIGHT_PARALLEL:
            light_vector[0] = light_direction[i][0];
            light_vector[1] = light_direction[i][1];
            light_vector[2] = light_direction[i][2];
            break;
         }

      MAdotvc( &msg, normal, light_vector, &l_dot_n );
      MIRROR_VECTOR( normal, light_vector, reflect );
      MAdotvc( &msg, reflect, view_dir, &r_dot_v );
      if( element_parms.front_facing_facet )
         r_dot_v = -reflect[2];
      else
         r_dot_v = reflect[2];

      r_dot_v_n = MApower( &msg, &r_dot_v, &finish );

      diffuse = l_dot_n * HPglobal.elem_diff_refl;
      specular = r_dot_v_n * HPglobal.elem_spec_refl * 255.0;

      if( diffuse < 0.0 ) diffuse = 0.0;	if( diffuse > 1.0 ) diffuse = 1.0;
      if( specular < 0.0 ) specular = 0.0;	if( specular > 255.0 ) specular = 255.0;

      light_contribution[0] += (element_color[0] * diffuse + specular);
      light_contribution[1] += (element_color[1] * diffuse + specular);
      light_contribution[2] += (element_color[2] * diffuse + specular);
      }

   light_contribution[0] /= (double)active_window->num_lights;
   light_contribution[1] /= (double)active_window->num_lights;
   light_contribution[2] /= (double)active_window->num_lights;

   cb[0] = dtoc(light_contribution[0] + ambient_contribution[0] );
   cb[1] = dtoc(light_contribution[1] + ambient_contribution[1] );
   cb[2] = dtoc(light_contribution[2] + ambient_contribution[2] );
   }

/*---INIT_Z_VARIABLES-------------------------------------------------*/

/*
 *  Before interpolating from left to right on a trapezoid scanline, we
 *  initialize a third set of z values equal to the value of the left most
 *  edge of the trapezoid at the given scanline.  We do this wo we can
 *  maintain the edge values while interpolating between
 */
 
#define INIT_Z_VARIABLES \
 \
   { \
   rzc.active = rza.active; \
   rzc.running = rza.running; \
   }
	
/*---INIT_X_VARIABLES-------------------------------------------------*/

/*
 *  Establish the value of x at the endpoints of a scanline.  When interpolating
 *  from top to bottom of a trapezoid, the x's are maintained in a <16:16>
 *  format to maximize precision, therefore, the values have to be shifted 16
 *  to the right to get the whole value of x
 */

#define INIT_X_VARIABLES \
 \
   { \
   xleft = rxa >> 16; \
   xright = rxb >> 16; \
   }

	
/*---INIT_SHADE_VARIABLES---------------------------------------------*/

/*
 *  Before interpolating from left to right on a trapezoid scanline, we
 *  initialize a third set of shade values equal to the value of the left most
 *  edge of the trapezoid at the given scanline.  We do this wo we can
 *  maintain the edge values while interpolating between
 */
 
#define INIT_SHADE_VARIABLES \
 \
   { \
   rnxc = rnxa; \
   rnyc = rnya; \
   rnzc = rnza; \
   }

/*---CALC_DZ_DX-------------------------------------------------------*/

/*
 *  Calculate the change in z with respect to x for rasterizing horizonal
 *  scanline.  Use the fixed point functions for z interpolation
 */
 
#define CALC_DZ_DX \
 \
   { \
   if( (dxc = xright - xleft) == 0 ) \
      { \
      rzc.sign = 1; \
      rzc.d_whole = 0; \
      rzc.d_fract = 0; \
      } \
   else \
      { \
      fixed_divide((rzb.active - rza.active), \
                   dxc, \
                   &rzc.sign, \
                   &rzc.d_whole, \
                   &rzc.d_fract ); \
      } \
   }


/*---CALC_DSHADE_DX---------------------------------------------------*/

/*
 *  Calculate the change in shade with respect to x for rasterizing horizonal
 *  scanline.
 */

#define CALC_DSHADE_DX \
 \
   { \
   if( (dx = xright - xleft) == 0 ) \
      { \
      dnxc = 0.0; \
      dnyc = 0.0; \
      dnzc = 0.0; \
      } \
   else \
      { \
      dnxc = (rnxb - rnxc) / (double)dx; \
      dnyc = (rnyb - rnyc) / (double)dx; \
      dnzc = (rnzb - rnzc) / (double)dx; \
      } \
   }

/*---CALC_BUFFER_ADDRESSES--------------------------------------------*/

/*
 *  Calculate the address in the z and color buffer of the left most pixel of 
 *  the current row
 */

#define CALC_BUFFER_ADDRESSES \
 \
   { \
   zb = (HSzbuf *)active_window->zbuf + (offset = y * active_window->x_dits + xleft); \
   cb = (HScbuf *)active_window->cbuf + (offset * 3); \
   }

/*---MIN_MAX_TEST----------------------------------------------------*/

/*
 *  Perform min/max test on the x and y coordinates of the trapezoid.
 */
	 
#define MIN_MAX_TEST \
 \
   { \
   if (tile->x0 < active_window->x_min) active_window->x_min = tile->x0; \
   if (tile->x1 > active_window->x_max) active_window->x_max = tile->x1; \
   if (tile->x2 < active_window->x_min) active_window->x_min = tile->x2; \
   if (tile->x3 > active_window->x_max) active_window->x_max = tile->x3; \
 \
   if (tile->yb < active_window->y_min) active_window->y_min = tile->yb; \
   if (tile->ya > active_window->y_max) active_window->y_max = tile->ya; \
   }

/*---MOVE_TO_NEXT_ROW(_SHADING)-------------------------------------------

/*
 *  After having completed rasterizing a scanline, compute the starting and
 *  ending x, z and shade of the next scanline.  Fill up in called to fill
 *  any holes caused by large steps in x.  Two macros are maintained here
 *  because some rasterizes dont need a shade, and therefore only need to
 *  compute the x and z of the next scanline.
 */
 
#define MOVE_TO_NEXT_ROW_SHADING \
 \
   { \
   rxa += dxa; \
   Fixed_add( rza ); \
 \
   rnxa += dnxa; \
   rnya += dnya; \
   rnza += dnza; \
 \
   FILL_UP ( (y+1) ) \
 \
   rxb += dxb; \
   Fixed_add( rzb ); \
 \
   rnxb += dnxb; \
   rnyb += dnyb; \
   rnzb += dnzb; \
   }

/*---MOVE_NEXT_PIXEL(_SHADE)------------------------------------------*/

/*
 *  compute the z, (shade) of the next pixel in the scanline
 */
 
#define MOVE_NEXT_PIXEL_SHADE \
 \
   { \
   Fixed_add( rzc ); \
 \
   rnxc += dnxc; \
   rnyc += dnyc; \
   rnzc += dnzc; \
 \
   zb++; \
   cb += 3; \
   }

/*---CHECK_BRIGHT_EDGES-------------------------------------*/

/*
 *  These macros check for bright edges.  A bright edge occurs when you have
 *  two trapezoids who share the same edge, and the darker hides the brighter
 *  and the brighter is rasterized after the darker.  The solution is that
 *  when two trapezoids are within a tolerance of each other on a given pixel
 *  you save the z of the closer but display the color of the darker.  The
 *  algorithm is designed to attempt to keep this within the shades of the 
 *  same base color.
 */
 
/*
 *  NOTE:
 *    I've commented out the bright edge stuff until I can deterine how
 *  it will be done in this case
 */
 
#define CHECK_BRIGHT_EDGES( x ) \
 \
   { \
   if( *zb >= rzc.active ) \
      { \
      if( (*zb - rzc.active) <= 1 ) \
         { \
         /*ds = *cb - new_color_entry; \
         if( ds < 0 || ds >= tiling_parms.number_shades )*/ \
            { \
            SetPixelColor( x, y, rzc.active, rnxc, rnyc, rnzc, cb ); \
            } \
         } \
      else \
         { \
         SetPixelColor( x, y, rzc.active, rnxc, rnyc, rnzc, cb ); \
         } \
       \
      *zb = rzc.active; \
      } \
   else \
      {    \
      if( (rzc.active - *zb) <= 1 ) \
         { \
         /*ds = *cb - new_color_entry; \
         if( ds < 0 || ds >= tiling_parms.number_shades )*/ \
            { \
            SetPixelColor( x, y, rzc.active, rnxc, rnyc, rnzc, cb ); \
            } \
         } \
      } \
   }

/*---CHECK_BRIGHT_TOP_BOTTOM(_SHADE)(_TRANS)--------------------------*/

/*
 *  For trapezoids, we always check the first and last pixel of a scanline for
 *  bright edges, but we also need to check the entire first and last scanline.
 *  This macro does that.  This macro comes in six versions, regular, with
 *  shade, plus the above three repeated for translucency.
 */
 
#define CHECK_BRIGHT_TOP_BOTTOM_SHADE \
 \
   { \
   INIT_SHADE_VARIABLES \
   INIT_Z_VARIABLES \
   INIT_X_VARIABLES \
 \
   CALC_DZ_DX \
   CALC_DSHADE_DX \
 \
   CALC_BUFFER_ADDRESSES \
    \
   for( x = xleft; x <= xright; x++ ) \
      { \
 \
      /* \
       *  If the z of the pixel stored in the z \
       *  buffer is greater than or equal to the z \
       *  of the new pixel then the new pixel \
       *  replaces the old pixel in then z buffer \
       *  and color buffer \
       */ \
 \
      CHECK_BRIGHT_EDGES( x ) \
      MOVE_NEXT_PIXEL_SHADE \
      } \
   }
 
/*---CALC_DXDY_DZDY(_DSDY)-------------------------------------------*/

/*
 *  Calculate the delta change in x, z and shade for a single step in y.  
 *  If the y coordinate are equal, then set the deltas to 0.
 */

#define	CALC_DXDY_DZDY_DSDY \
 \
   { \
   if( ( dy = tile->ya - tile->yb ) == 0 ) \
      { \
      dxa = 0; \
      dxb = 0; \
 \
      dnxa = 0.0; \
      dnya = 0.0; \
      dnza = 0.0; \
 \
      dnxb = 0.0; \
      dnyb = 0.0; \
      dnzb = 0.0; \
 \
      rza.sign = 1; \
      rza.d_whole = 0; \
      rza.d_fract = 0; \
      rza.running = 0; \
 \
      rzb.sign = 1; \
      rzb.d_whole = 0; \
      rzb.d_fract = 0; \
      rzb.running = 0; \
      } \
   else \
      { \
      dxa = ( tile->x0 - tile->x2 ) / dy; \
      dxb = ( tile->x1 - tile->x3 ) / dy; \
 \
      dnxa = (rnxc - rnxa) / (double)dy; \
      dnya = (rnyc - rnya) / (double)dy; \
      dnza = (rnzc - rnza) / (double)dy; \
 \
      dnxb = (rnxd - rnxb) / (double)dy; \
      dnyb = (rnyd - rnyb) / (double)dy; \
      dnzb = (rnzd - rnzb) / (double)dy; \
 \
      fixed_divide((tile->z0 - tile->z2), \
                   dy, \
                   &rza.sign, \
                   &rza.d_whole, \
                   &rza.d_fract ); \
 \
      rza.running = 0x40000000; \
 \
      fixed_divide((tile->z1 - tile->z3), \
                   dy, \
                   &rzb.sign, \
                   &rzb.d_whole, \
                   &rzb.d_fract ); \
 \
      rzb.running = 0x40000000; \
      } \
 \
   rza.active = tile->z2; \
   rzb.active = tile->z3; \
 \
   rxa = tile->x2 + 32768; \
   rxb = tile->x3 + 32768; \
   }
	
/*---FILL_UP----------------------------------------------------------*/

/*
NAME
	FILL_UP: Local macro
	
KEYWORD
	HSplot
	rasterizer
	
DESCIPTION
	This macro prevent a "saw tooth" effect that occasionally occurs
	during rasterization.  What this does is fill in a scanline between
	the current position of the left and right edge of the trapezoid.
	I don't quite remember how the saw tooth effect is generated.

PARAMETERS
	y:  Index to the current scanline
	
GLOBALS USED
	HPband_info: global structure
		y_dits: referenced to make sure we don't go past the
		      : edge of the viewport

HISTORY
	??/??/??	M. Lanier
		Created
*/

#define FILL_UP( y ) \
 \
   { \
   if( y >= 0 && y <= HPband_info.y_dits ) \
      { \
      if( rxb < rxa && ((y)-1) != tile->ya ) \
         { \
         if( (dxc = rxa - rxb) == 0 ) \
            { \
            rzc.sign = 1; \
            rzc.d_whole = 0; \
            rzc.d_fract = 0; \
 \
            dnxc = 0.0; \
            dnyc = 0.0; \
            dnzc = 0.0; \
            } \
         else \
            { \
            fixed_divide((rza.active - rzb.active), \
                         dxc, \
                         &rzc.sign, \
                         &rzc.d_whole, \
                         &rzc.d_fract ); \
 \
            dnxc = (rnxa - rnxb) / (double)dxc; \
            dnyc = (rnya - rnyb) / (double)dxc; \
            dnzc = (rnza - rnzb) / (double)dxc; \
            } \
 \
         rzc.running = 0x40000000; \
         rzc.active = rzb.active; \
 \
         xleft = rxb >> 16; \
         xright = rxa >> 16; \
 \
         zb = (HSzbuf *)active_window->zbuf + (offset = (y) * \
                 active_window->x_dits + xleft); \
         cb = (HScbuf *)active_window->cbuf + (offset * 3); \
 \
         for( x=xleft; x<=xright; x++ ) \
            { \
            if( *zb >= rzc.active ) \
               { \
               *zb = rzc.active; \
               SetPixelColor( x, y, rzc.active, rnxc, rnyc, rnzc, cb ); \
               } \
 \
            MOVE_NEXT_PIXEL_SHADE \
            } \
         } \
      } \
   }
	
#define ROUND16(x)	((x) >> 16)

/*---HPsmooth_shade_opaque_phong----------------------------------------------*/

/*
NAME
	HPsmooth_shade_opaque_phong
	
KEYWORD
	HSplot
	rasterizer
	smooth shading
	opaque
	
DESCRIPTION
	This function rasterizes the given trapezoid, producing an opaque
	smooth shaded image of the trapezoid.
	
PARAMETERS
	tile	:(IN) : structure containing the trapezoid
	
GLOBALS USED
	HPband_info: global structure
		y_dits:  Used to clip the trapezoid
		org_y :  Used to translate the trapezoid when banding
	element_parms: global structure
		color :  Active color of the object, applied to the trapezoid

ALGORITHM
	Use linear interpolation, with y as the constant, to compute the x, z and shade
	of both edges of the trapezoid.  Again using linear interpolation, fill
	in the scanline between the two edges, using their current value for the
	scanline.

FUNCTIONS CALLED

HISTORY
	??/??/??	M. Lanier
		Created
*/

void HPsmooth_shade_opaque_phong (struct trapezoid *tile,
                                  double nx0, double ny0, double nz0,
                                  double nx1, double ny1, double nz1,
                                  double nx2, double ny2, double nz2,
                                  double nx3, double ny3, double nz3,
                                  double w0, double w1, double w2, double w3,
                                  double u0, double u1, double u2, double u3,
                                  double v0, double v1, double v2, double v3 )

   {
   int			rxa, rxb, dxa, dxb;
   int			dxc;
   int			dx, dy;

   int			offset;

   struct HSfixedpt	rza, rzb, rzc;
   
   register int		x, y;
   register int		xleft, xright;
   
   register HSzbuf	*zb;
   register HScbuf	*cb;

   double		rnxa, rnya, rnza, dnxa, dnya, dnza;
   double		rnxb, rnyb, rnzb, dnxb, dnyb, dnzb;
   double		rnxc, rnyc, rnzc, dnxc, dnyc, dnzc;
   double		rnxd, rnyd, rnzd, dnxd, dnyd, dnzd;

HPset_rendering_attributes(NULL);
/*
fprintf(stderr, "Trapezoid %d: in HPsmooth_shade_opaque_phong\n", ++count );
fprintf( stderr, "  p0 -- %5d %5d %f %12d - %5.2f %5.2f %5.2f\n",
ROUND16( tile->x2 ), tile->yb, (double)tile->z2/zscale tile->z2, nx0, ny0, nz0 );
fprintf( stderr, "  p1 -- %5d %5d %f %12d - %5.2f %5.2f %5.2f\n",
ROUND16( tile->x3 ), tile->yb, (double)tile->z3/zscale tile->z3, nx1, ny1, nz1 );
fprintf( stderr, "  p2 -- %5d %5d %f %12d - %5.2f %5.2f %5.2f\n",
ROUND16( tile->x0 ), tile->ya, (double)tile->z0/zscale tile->z0, nx2, ny2, nz2 );
fprintf( stderr, "  p3 -- %5d %5d %f %12d - %5.2f %5.2f %5.2f\n",
ROUND16( tile->x1 ), tile->ya, (double)tile->z1/zscale tile->z1, nx3, ny3, nz3 );
*/

   /*
    *  Translate trap to the zbuffer origin
    */
	 
   tile->ya -= HPband_info.org_y;
   tile->yb -= HPband_info.org_y;

   if( tile->ya < 0 ) return;
   if( tile->yb > HPband_info.y_dits ) return;

   MIN_MAX_TEST

   rnxa = nx0;     rnya = ny0;     rnza = nz0;
   rnxb = nx1;     rnyb = ny1;     rnzb = nz1;
   rnxc = nx2;     rnyc = ny2;     rnzc = nz2;
   rnxd = nx3;     rnyd = ny3;     rnzd = nz3;

   CALC_DXDY_DZDY_DSDY
	
   y = tile->yb;

   if( y >= 0 && y <= HPband_info.y_dits )
      {
      CHECK_BRIGHT_TOP_BOTTOM_SHADE
      }
		
   MOVE_TO_NEXT_ROW_SHADING
	
   for( y++; y < tile->ya; y++ )
      {
      INIT_SHADE_VARIABLES
      INIT_Z_VARIABLES
      INIT_X_VARIABLES

      CALC_DZ_DX
      CALC_DSHADE_DX

      if( y >= 0 && y <= HPband_info.y_dits )
         {
         CALC_BUFFER_ADDRESSES
         CHECK_BRIGHT_EDGES( xleft )
         MOVE_NEXT_PIXEL_SHADE

         for( x = xleft+1; x < xright; x++ )
            {

            /*
             *  If the z of the pixel stored in the z
             *  buffer is greater than or equal to the z
             *  of the new pixel then the new pixel
             *  replaces the old pixel in then z buffer 
             *  and color buffer
             */

            if( *zb >= rzc.active )
               {
               *zb = rzc.active;
               SetPixelColor( x, y, rzc.active, rnxc, rnyc, rnzc, cb );
               }
	
            MOVE_NEXT_PIXEL_SHADE
            }

         if( x == xright ) CHECK_BRIGHT_EDGES( x )
         }
	
      MOVE_TO_NEXT_ROW_SHADING		
      }

   if( y >= 0 && y <= HPband_info.y_dits )
   if( y <= tile->ya ) CHECK_BRIGHT_TOP_BOTTOM_SHADE
   }
