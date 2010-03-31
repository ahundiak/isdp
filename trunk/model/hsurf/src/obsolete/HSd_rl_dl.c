
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

#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "hsmath.h"

#include "HSpr_display.h"


#define	right 1
#define left 0

struct x_struct
	{
	int	actual, next;
	int	running;
	int	dxy;
	int	jump;
	};

static int	count;

#define EDGE_DELTA	2

/*---RASTERIZE_EDGE-------------------------------------------------------*/
	
#define RASTERIZE_EDGE( x, z, side, xs, zs )						\
											\
	{										\
											\
	/*										\
	 *  if jump = -1 then the slope was steep enough so that there would 		\
	 *  always be no more than a single step in x.					\
	 */										\
	 										\
	if( x.jump == -1 )								\
		{									\
		xs = x.running;								\
											\
		zs.sign = z.sign;							\
		zs.active = z.active;							\
		zs.running = z.running;							\
		zs.d_whole = z.d_whole;							\
		zs.d_fract = z.d_fract;							\
											\
		cb = active_window->cbuf + (offset = y * active_window->x_dits + xs + 1);	\
		zb = active_window->zbuf + offset;					\
											\
		if( (*zb & 0x7fffffff) >= z.active )					\
			{								\
			*cb = element_parms.color;					\
			*zb = HS_BACKGROUND_Z;						\
			}								\
											\
		x.actual += x.dxy;							\
		x.running = x.actual >> 16;						\
		Fixed_add( z );								\
		}									\
	else										\
		{									\
											\
		/*									\
		 *  JUMP is non-negative, therefore, we can assume that we might	\	
		 *  have a step in x greater than 1					\
		 */									\
	 										\
		dx = ABS( (x.next >> 16) - x.running );					\
											\
		count = dx + ((y != tile->ya) ? x.jump : 0);				\
											\
		x.actual = x.next;							\
		x.next += x.dxy;							\
											\
		cb = active_window->cbuf +						\
			(offset = y * active_window->x_dits + x.running + 1);		\
		zb = active_window->zbuf + offset;					\
											\
		/*									\
		 *  If we are doing the left edge of the trapezoid and the edge		\
		 *  angles to the left, or we are doing the right edge of the		\
		 *  trapezoid and it angles to the right, then the first pixel		\
		 *  is the interior pixel						\
		 */									\
		 									\
		if( side == left )							\
			{								\
			if( x.dxy < 0 )							\
				{							\
				xs = x.running;						\
											\
				zs.sign = z.sign;					\
				zs.active = z.active;					\
				zs.running = z.running;					\
				zs.d_whole = z.d_whole;					\
				zs.d_fract = z.d_fract;					\
				}							\
			}								\
		else									\
			{								\
			if( x.dxy >= 0 )						\
				{							\
				xs = x.running;						\
											\
				zs.sign = z.sign;					\
				zs.active = z.active;					\
				zs.running = z.running;					\
				zs.d_whole = z.d_whole;					\
				zs.d_fract = z.d_fract;					\
				}							\
			}								\
											\
											\
		do /* for all pixels on same row */					\
			{								\
											\
			/*								\
			 *  Do hidden line test for new pixel				\
			 */								\
			 								\
			if( (*zb & 0x7fffffff) >= z.active )				\
				{							\
				*cb = element_parms.color;				\
				*zb = HS_BACKGROUND_Z;					\
				}							\
											\
			/*								\
			 *  If we are doing the right edge and it is angling to the 	\
			 *  left, or we are doing the left edge and it is angling	\
			 *  to the right, then the last pixel is interior		\
			 *  count will be = 0 on the last pixel				\
			 */								\
			 								\
			if( count == 0 )						\
				if( side == right )					\
					{						\
					if( x.dxy < 0 )					\
						{					\
						xs = x.running;				\
											\
						zs.sign = z.sign;			\
						zs.active = z.active;			\
						zs.running = z.running;			\
						zs.d_whole = z.d_whole;			\
						zs.d_fract = z.d_fract;			\
						}					\
					}						\
				else							\
					{						\
					if( x.dxy >= 0 )				\
						{					\
						xs = x.running;				\
											\
						zs.sign = z.sign;			\
						zs.active = z.active;			\
						zs.running = z.running;			\
						zs.d_whole = z.d_whole;			\
						zs.d_fract = z.d_fract;			\
						}					\
					}						\
											\
			Fixed_add( z );							\
											\
			if( x.dxy < 0 )							\
				{							\
				x.running--;						\
				cb--;							\
				zb--;							\
				}							\
			else								\
				{							\
				x.running++;						\
				cb++;							\
				zb++;							\
				}							\
			}								\
		while( count-- > 0 );							\
											\
		}									\
	}
	
/*---HSraster_lines_delete-----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSraster_lines_delete( struct trapezoid *tile )
#else
	void HSraster_lines_delete( tile )

	struct trapezoid	*tile;	/*  trapezoids data  */
#endif

	{
	int			x0, x1, x2, x3;
	int			z0, z1, z2, z3;
	struct HSfixedpt	z, z_left, z_right, z_start, z_stop;
	int			y;
	int			dx_left, dx_right, dx, dy;
	struct x_struct		x_left, x_right;
	int			x_stop=0, x_start=0, offset;
	HScbuf			*cb;
	HSzbuf			*zb;
	
	/*
	 *  Perform min/max test on vertices for display region
	 */

	if( tile->x0 < active_window->x_min ) active_window->x_min = tile->x0;
	if( tile->x1 > active_window->x_max ) active_window->x_max = tile->x1;
	if( tile->x2 < active_window->x_min ) active_window->x_min = tile->x2;
	if( tile->x3 > active_window->x_max ) active_window->x_max = tile->x3;
	
	if( tile->yb < active_window->y_min ) active_window->y_min = tile->yb == 0 ? tile->yb : tile->yb - 1;
	if( tile->ya > active_window->y_max ) active_window->y_max = tile->ya + 1;

	if( tile->x0 < active_window->x_min_rl ) active_window->x_min_rl = tile->x0;
	if( tile->x1 > active_window->x_max_rl ) active_window->x_max_rl = tile->x1;
	if( tile->x2 < active_window->x_min_rl ) active_window->x_min_rl = tile->x2;
	if( tile->x3 > active_window->x_max_rl ) active_window->x_max_rl = tile->x3;
	
	if( tile->yb < active_window->y_min_rl ) active_window->y_min_rl = tile->yb == 0 ? tile->yb : tile->yb - 1;
	if( tile->ya > active_window->y_max_rl ) active_window->y_max_rl = tile->ya + 1;
	
	/*
	 *  The x coordinates of the vertices are already <11:5>, copy them to
	 *  long variables and shift left 11 to make them <16:16>.  This alloactive_window
	 *  us to do integer arithmetic in interpolating the x's
	 */
	 
	x0 = tile->x0;     x1 = tile->x1;
	x2 = tile->x2;     x3 = tile->x3;
	
	z0 = tile->z0;           z1 = tile->z1;
	z2 = tile->z2;           z3 = tile->z3;
	
	/*
	 *  Calculate dx/dy
	 */
	 
	if( (dy = tile->ya - tile->yb) == 0 )
		{
		x_left.dxy = 0;
		x_right.dxy = 0;
		}
	else
		{
		x_left.dxy = (x0 - x2) / dy;
		x_right.dxy = (x1 - x3) / dy;
		}
		
	/*
	 *   Calculate dz/?.  If dx/dy is less than 1.0 then use dz/dy, and if dx/dy 
	 *   greater than 1.0 then use dz/dx.
	 */
	 
	dx_left = (x0 >> 16) - (x2 >> 16);
	dx_right = (x1 >> 16) - (x3 >> 16);
	
	dx_left = ABS( dx_left );
	dx_right = ABS( dx_right );
	 
	if( dx_left > dy )
		{
		round_to_x( tile->x0, tile->x2, z0, z2, &z0, &z2 );
		
		fixed_divide(	(z0 - z2),
				dx_left,
				&z_left.sign,
				&z_left.d_whole,
				&z_left.d_fract );
				
		z_left.running = 0x40000000;
		
		x_left.jump = ABS( x_left.dxy ) >> 17;
		}
	else
		{
		if( dy == 0 )
			{
			z_left.sign = 1;
			z_left.d_whole = 0;
			z_left.d_fract = 0;
			z_left.running = 0;
			}
		else
			{
			fixed_divide(	(z0 - z2),
					dy,
					&z_left.sign,
					&z_left.d_whole,
					&z_left.d_fract );
					
			z_left.running = 0x40000000;
			}
			
		x_left.jump = -1;
		}
	
	if( ABS( dx_right ) > dy )
		{
		round_to_x( tile->x1, tile->x3, z1, z3, &z1, &z3 );
		
		fixed_divide(	(z1 - z3),
				dx_right,
				&z_right.sign,
				&z_right.d_whole,
				&z_right.d_fract );
				
		z_right.running = 0x40000000;
		
		x_right.jump = ABS( x_right.dxy ) >> 17;
		}
	else
		{
		if( dy == 0 )
			{
			z_right.sign = 1;
			z_right.d_whole = 0;
			z_right.d_fract = 0;
			z_right.running = 0;
			}
		else
			{
			fixed_divide(	(z1 - z3),
					dy,
					&z_right.sign,
					&z_right.d_whole,
					&z_right.d_fract );
					
			z_right.running = 0x40000000;
			}
			
		x_right.jump  = -1;
		}
	
	/*
	 *  load initial values for z
	 */
	 	
	z_left.active = z2;
	z_right.active = z3;
	
	y = tile->yb;
	
	x_left.actual = x2;
	x_right.actual = x3;
	
	x_left.running = x2 >> 16;
	x_right.running = x3 >> 16;
	
	x_left.next = x2;
	x_right.next = x3;

	while( y <= tile->ya )
		{
		RASTERIZE_EDGE( x_left,  z_left,  left,  x_start, z_start );
		RASTERIZE_EDGE( x_right, z_right, right, x_stop,  z_stop );
				
		if( y == tile->ya ) x_stop = x1 >> 16;

		if( (dx = x_stop - x_start) > 0 )
			{
			fixed_divide( (z_stop.active - z_start.active),
					dx,
					&z.sign,
					&z.d_whole,
					&z.d_fract );
					
			z.active = z_start.active;
			z.running = z_start.running;
			
			x_start++;
			Fixed_add( z );
			
			zb = active_window->zbuf + (offset = y * active_window->x_dits + x_start + 1);
			cb = active_window->cbuf + offset;
			
			while( x_start < x_stop )
				{
				if( (*zb & 0x7fffffff) >= z.active )
					{
					*cb = element_parms.color;
					*zb = HS_BACKGROUND_Z;
					}

				x_start++;
				Fixed_add( z );
				
				cb++;
				zb++;
				}
			}
			
		y++;
		}
	}

/*---HSsilly_lines_delete-----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSsilly_lines_delete( int line_color, int bg_color )
#else
	void HSsilly_lines_delete( line_color, bg_color )

	int				line_color, bg_color;
#endif

	{
	line_color = bg_color;
	}
