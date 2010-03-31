
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/


/*#include "hsurf_import.h"*/
#include "stdlib.h"
#include "igrtypedef.h"
#include "igr.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "hsmath.h"
#include "HSd_fixedpt.h"
#include "stdio.h"

#include "HSpr_display.h"


#define	right  1
#define left   0
#define	xstep  1
#define ystep  active_window->x_dits

#define Fixed_add_pt( z )			\
						\
	{					\
	z->running += z->d_fract;		\
	z->active += ( z->d_whole * z->sign );	\
						\
	if( z->running < 0 )			\
		{				\
		z->active += z->sign;		\
		z->running &= ZMASK;		\
		}				\
	}

struct x_struct
	{
	int	actual, next;
	int	running;
	int	dxy;
	int	jump;
	};

#define EDGE_DELTA	2

#define	FRONT_FACING	0x01
#define	BACK_FACING	0x02
#define BOTH_FACING	0x03
#define FACE_MASK	0x03
#define	EDGE_EDGE	0x04
#define EDGE_MASK	0x07
#define MARK_MASK	0x0f
#define DISPLAY_ME	0x40
#define VISIBLE		0x80

#define	ZMASK		0x7fffffff
#define	OMASK		0x80000000

static count;

static int		y;
static int		d1, d2;
static HScbuf		*cb;
static HSzbuf		*zb;


/*		Apogee compliant		*/

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

static RASTERIZE_EDGE __((struct x_struct *x, 
			 struct HSfixedpt *z,
				      int side, 
				      int *xs, 
			 struct HSfixedpt *zs, 
				      int ya));

#if defined(__cplusplus)
}
#endif


#undef __

/*---RASTERIZE_EDGE-------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static RASTERIZE_EDGE( struct x_struct *x, 
			      struct HSfixedpt *z,
					   int side, 
					   int *xs, 
			      struct HSfixedpt *zs, 
					   int ya )
#else
	static RASTERIZE_EDGE( x, z, side, xs, zs, ya )

	struct x_struct		*x;
	struct HSfixedpt	*z;
	int			side;
	int			*xs;
	struct HSfixedpt	*zs;
	int			ya;
#endif

	{
	int	offset, dx;

	/*
	 *  if jump = -1 then the slope was steep enough so that there would 
	 *  always be no more than a single step in x.
	 */

	if( x->jump == -1 )
		{
		*xs = x->running;

		zs->sign = z->sign;
		zs->active = z->active;
		zs->running = z->running;
		zs->d_whole = z->d_whole;
		zs->d_fract = z->d_fract;

		cb = active_window->cbuf + (offset = y * active_window->x_dits + *xs + 1);
		zb = active_window->zbuf +  offset;

		if( !(*zb & OMASK) || !(*cb & EDGE_EDGE))
			{
			if( (*zb & ZMASK) >= z->active )
				{
				*cb = d1 | EDGE_EDGE;
				*zb = z->active | OMASK;
				}
			}
		else
			if( (*zb & ZMASK) >= z->active )
				{
				if( ((*zb & ZMASK) - z->active) <= EDGE_DELTA )
					d2 = d1 | *cb;
				else
					d2 = d1;

				*cb = d2 | EDGE_EDGE;
				*zb = z->active | OMASK;
				}
			else
				{
				if( (z->active - (*zb & ZMASK)) <= EDGE_DELTA )
					*cb = *cb | d1;
				}

		x->actual += x->dxy;
		x->running = x->actual >> 16;
		Fixed_add_pt( z );
		}
	else
		{

		/*
		 *  JUMP is non-negative, therefore, we can assume that we might
		 *  have a step in x greater than 1
		 */

		dx = ABS( (x->next >> 16) - x->running );

		count = dx + ((y != ya) ? x->jump : 0);

		x->actual = x->next;
		x->next += x->dxy;

		cb = active_window->cbuf + (offset = y * active_window->x_dits + x->running + 1);
		zb = active_window->zbuf +  offset;

		/*
		 *  If we are doing the left edge of the trapezoid and the edge
		 *  angles to the left, or we are doing the right edge of the
		 *  trapezoid and it angles to the right, then the first pixel
		 *  is the interior pixel
		 */

		if( side == left )
			{
			if( x->dxy < 0 )
				{
				*xs = x->running;

				zs->sign = z->sign;
				zs->active = z->active;
				zs->running = z->running;
				zs->d_whole = z->d_whole;
				zs->d_fract = z->d_fract;
				}
			}
		else
			{
			if( x->dxy >= 0 )
				{
				*xs = x->running;

				zs->sign = z->sign;
				zs->active = z->active;
				zs->running = z->running;
				zs->d_whole = z->d_whole;
				zs->d_fract = z->d_fract;
				}
			}

		do /* for all pixels on same row */
			{

			/*
			 *  Do hidden line test for new pixel
			 */

			if( !(*zb & OMASK) || !(*cb & EDGE_EDGE) )
				{
				if( (*zb & ZMASK) >= z->active )
					{
					*cb = d1 | EDGE_EDGE;
					*zb = z->active | OMASK;
					}
				}
			else
				if( (*zb & ZMASK) >= z->active )
					{
					if( ((*zb & ZMASK) - z->active) <= EDGE_DELTA )
						d2 = d1 | *cb;
					else
						d2 = d1;

					*zb = z->active | OMASK;
					*cb = d2 | EDGE_EDGE;
					}
				else
					{
					if( (z->active - (*zb & ZMASK)) <= EDGE_DELTA )
						*cb = *cb | d1;
					}

			/*
			 *  If we are doing the right edge and it is angling to the
			 *  left, or we are doing the left edge and it is angling
			 *  to the right, then the last pixel is interior
			 *  count will be = 0 on the last pixel
			 */

			if( count == 0 )
			if( side == right )
				{
				if( x->dxy < 0 )
					{
					*xs = x->running;

					zs->sign = z->sign;
					zs->active = z->active;
					zs->running = z->running;
					zs->d_whole = z->d_whole;
					zs->d_fract = z->d_fract;
					}
				}
			else
				{
				if( x->dxy >= 0 )
					{
					*xs = x->running;

					zs->sign = z->sign;
					zs->active = z->active;
					zs->running = z->running;
					zs->d_whole = z->d_whole;
					zs->d_fract = z->d_fract;
					}
				}

			Fixed_add_pt( z );

			if( x->dxy < 0 )
				{
				x->running--;
				cb--;
				zb--;
				}
			else
				{
				x->running++;
				cb++;
				zb++;
				}
			}
		while( count-- );
		}
	}
	
/*---HSraster_lines_rop-----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSraster_lines_rop( struct trapezoid *tile )
#else
	void HSraster_lines_rop( tile )

	struct trapezoid	*tile;	/*  trapezoids data  */
#endif

	{
	int			x0, x1, x2, x3;
	int			z0, z1, z2, z3;
	int			dx_left, dx_right, dx, dy;
	int			x_stop, x_start, offset;
	struct HSfixedpt	z, z_left, z_right, z_start, z_stop;
	struct x_struct		x_left, x_right;


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
	 
	x0 = tile->x0;	 x1 = tile->x1;
	x2 = tile->x2;	 x3 = tile->x3;
	
	z0 = tile->z0;	 z1 = tile->z1;
	z2 = tile->z2;	 z3 = tile->z3;
	
	d1 = ( tile->id & 0x10 ) ? BACK_FACING : FRONT_FACING;
	
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
		
		fixed_divide(	
			(z0 - z2),
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
			fixed_divide(	
				(z0 - z2),
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
		
		fixed_divide(	
				(z1 - z3),
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
			fixed_divide(	
					(z1 - z3),
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
		RASTERIZE_EDGE( &x_left,  &z_left,  left,  &x_start, &z_start, (int)tile->ya );
		RASTERIZE_EDGE( &x_right, &z_right, right, &x_stop,  &z_stop,  (int)tile->ya );
				
		if( y == tile->ya ) x_stop = x1 >> 16;

		if( (dx = x_stop - x_start) > 0 )
			{
			fixed_divide( 
					(z_stop.active - z_start.active),
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
				if( y == tile->ya || y == tile->yb )
					{
					if( !(*zb & OMASK) || !(*cb & EDGE_EDGE))
						{
						if( (*zb & ZMASK) >= z.active )
							{
							*cb = d1 | EDGE_EDGE;
							*zb = z.active | OMASK;
							}
						}
					else
						if( (*zb & ZMASK) >= z.active )
							{
							if( ((*zb & ZMASK) - z.active) <= EDGE_DELTA )
								d2 = d1 | *cb;
							else
								d2 = d1;
								
							*cb = d2 | EDGE_EDGE;
							*zb = z.active | OMASK;
							}
						else
							{
							if( (z.active - (*zb & ZMASK)) <= EDGE_DELTA )
								*cb = *cb | d1;
							}
					}
				else
					{		
					if( (*zb & ZMASK) >= z.active )
						{
						*cb = d1;
						*zb = z.active | OMASK;
						}
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
	
/*---round_to_x----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void round_to_x( int x0,
		    int x1,
		    int z0,
		    int z1,
		    int *za,
		    int *zb )
#else
	void round_to_x( x0, x1, z0, z1, za, zb )

	int	x0;
	int	x1;
	int	z0;
	int	z1;
	int	*za;
	int	*zb;
#endif

	{
	struct HSfixedpt	z2, z3;
	int			dx;
	
	if( (dx = (x0 >> 1) - (x1 >> 1)) == 0 )
		{
		z2.sign = 1;
		z2.d_whole = 0;
		z2.d_fract = 0;
		z2.running = 0;
		}
	else
		{
		fixed_divide(	
				(z1 - z0),
				dx,
				&z2.sign,
				&z2.d_whole,
				&z2.d_fract );
					
			z2.running = 0x40000000;
		}
			
	z3.sign = z2.sign;
	z3.d_whole = z2.d_whole;
	z3.d_fract = z2.d_fract;
	z3.running = z2.running;
		
	z2.active = z0;
	z3.active = z1;
		
	fixed_mult( &z2, ((x0 >> 1) & 0xf) );
	fixed_mult( &z3, ((x1 >> 1) & 0xf) );
		
	*za = z2.active;
	*zb = z3.active;
	}

/*---fixed_mult-----------------------------------------------------------*/
 
#if defined(__STDC__) || defined(__cplusplus)
	void fixed_mult( struct HSfixedpt *z, int n )
#else
	void fixed_mult( z, n )

	struct HSfixedpt	*z;
	int			n;
#endif

	{
	int	zr, zf;
	
	n++;
	
	zr = z->running >> 5;
	zf = z->d_fract >> 5;
	
	zr += zf * n;
	
	z->running = (zr << 5) & ZMASK;
	
	z->active += z->sign * ( zr >> 26 );
	z->active += ( z->d_whole * z->sign * n );
	}
	
/*---trans_1---------------------------------------------------------------*/

#define	trans_1( zn, cn )	\
	( !(*zn & OMASK) && ( ((*zb & ZMASK) < *zn) || (bg_color == *cn) ) )
	
/*---trans_2---------------------------------------------------------------*/

#define	trans_2( zn, cn )	\
	( (*zn & OMASK) && (((*cb & FACE_MASK) + (*cn & FACE_MASK)) == BOTH_FACING) )
	
/*---HSsilly_lines_rop-----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSsilly_lines_rop( int line_color, int bg_color )
#else
	void HSsilly_lines_rop( line_color, bg_color )

	int	line_color, bg_color;
#endif

	{
	HScbuf		*cb_base, *set_col, *sc;
	HSzbuf		*zb_base, *set_z, *sz;
	
	HScbuf		*first_pos, *last_pos;

	int		weight, weight_factor;
	int		x, y;
	int		xdits;
	int		step_factor;
	int		i, j, k;
  	int		offset;

	/*
	 * The following was added by SRa on 8/5/87 to fix a bug where
	 * memory was being corrupted when active_window->y_min_rl = 0.
	 */

	if( active_window->y_min_rl == 0 ) active_window->y_min_rl = 1;

	/*
	 *  Start at the bottom of the sub-region and move up
	 */

	active_window->x_min_rl = active_window->x_min_rl >> 16;
	active_window->x_max_rl = active_window->x_max_rl >> 16;
	
	active_window->x_min_rl &= 0xfffffffe;

	xdits = active_window->x_dits;
   
	weight = (int) element_parms.visible_weight;
	weight_factor = (weight + 1) >> 1;

	/*
	 *  Get address of pixel in color-buffer at left side of
	 *  of region, for the given y
	 */		
			
	cb_base   = active_window->cbuf + (offset = active_window->y_min_rl * xdits + active_window->x_min_rl);
	zb_base   = active_window->zbuf + offset;
	
	first_pos = active_window->cbuf;
	last_pos  = active_window->cbuf + ((active_window->x_dits + 1) * (active_window->y_dits + 1));

	y = active_window->y_max_rl - active_window->y_min_rl + 1;
	if( y < 0 ) y = 0;
	while( y-- )
		{
		cb = cb_base;
		zb = zb_base;

		x = active_window->x_max_rl - active_window->x_min_rl + 2;
		while( x-- )
			{
			if( (*zb & OMASK) && (*cb & MARK_MASK) )
				{
				if( (trans_1((zb-xstep), (cb-xstep)))	||
				    (trans_1((zb+ystep), (cb+ystep)))	||
				    (trans_1((zb+xstep), (cb+xstep)))	||
				    (trans_1((zb-ystep), (cb-ystep)))	||
				    ((*cb & 0x7) == 7)			||
				    (trans_2((zb-xstep), (cb-xstep)))	||
				    (trans_2((zb-ystep), (cb-ystep)))	||
				    (trans_2((zb+ystep), (cb+ystep)))	||
				    (trans_2((zb+xstep), (cb+xstep))))
					*cb |= VISIBLE;
				}				

			cb++;
			zb++;
			}
		
		cb_base += ystep;
		zb_base += ystep;
		}
		
	cb_base = active_window->cbuf + offset;
	zb_base = active_window->zbuf + offset;

	step_factor = (weight >> 1) * xstep + (weight >> 1) * ystep;
	y = active_window->y_max_rl - active_window->y_min_rl + 1;
	if( y < 0 ) y = 0;
	while( y-- )
		{
		cb = cb_base;
		zb = zb_base;
		
		x = active_window->x_max_rl - active_window->x_min_rl + 2;
		while( x-- )
			{
			if( *zb & OMASK )
				{
				if( *cb & VISIBLE )
					{
					set_col = cb - step_factor;
					set_z   = zb - step_factor;
					
					*cb = line_color;
					*zb &= ZMASK;
					
					i = weight + 1;
					while( i-- )
						{
						sc = set_col;
						sz = set_z;
						
						j = weight + 1;
						
						if( sc < first_pos )
							{
							k = (first_pos - sc) / sizeof( sc );
							j -= k;
							sc += k;
							if( j < 0 ) j = 0;
							} else
							
						if( (sc+weight) > last_pos )
							{
							k = ((sc+weight) - last_pos) / sizeof( sc );
							j -= k;
							if( j < 0 ) j = 0;
							}
							
						while( j-- )
							{

							/*
							 *  If this is not a core pixel or
							 *  pixels z is greater than that of the core
							 *  pixel. 
							 */
								 
							if( !(*sc & VISIBLE) )
								{
								*sc = DISPLAY_ME;
								if(*sz > (*zb & ZMASK))
									*sz = *zb | OMASK;
								else
									*sz = *sz | OMASK;
								}
									
							sc++;
							sz++;
							}

						set_col += ystep;
						set_z   += ystep;
						}
					}
				else
					{
					if( !(*cb & DISPLAY_ME) )
						{
						*cb = bg_color; 
						*zb &= ZMASK;
						}
					}
				}

			zb++;
			cb++;
			}
		
		cb_base += ystep;
		zb_base += ystep;
		}
		
	/*
	 *  Now go back and clear the sign bits of the z's
	 *  Adjust the last pass region range box for addition of line
	 *  weight
	 */
	 
	active_window->x_min_rl -= weight_factor;
	if( active_window->x_min_rl < 0 ) active_window->x_min_rl = 0;

	active_window->x_max_rl += weight_factor;
	if( active_window->x_max_rl > xdits ) active_window->x_max_rl = xdits;

	active_window->y_min_rl -= weight_factor;
	if( active_window->y_min_rl < 0 ) active_window->y_min_rl = 0;

	active_window->y_max_rl += weight_factor;
	if( active_window->y_max_rl > active_window->y_dits )
		active_window->y_max_rl = active_window->y_dits;
		
	/*
	 *  Modify the object range box for any addition due to
	 *  line weight
	 */
	 	
	if( active_window->x_min_rl < (active_window->x_min >> 16) )
		active_window->x_min = active_window->x_min_rl << 16;

	if( active_window->x_max_rl > (active_window->x_max >> 16) )
		active_window->x_max = active_window->x_max_rl << 16;

	if( active_window->y_min_rl < active_window->y_min )
		active_window->y_min = active_window->y_min_rl;

	if( active_window->y_max_rl > active_window->y_max )
		active_window->y_max = active_window->y_max_rl;

	/*
	 *  Get address of pixel in color-buffer at left side of
	 *  of region, for the given y
	 */		
			
	cb_base   = active_window->cbuf + (offset = active_window->y_min_rl * xdits + active_window->x_min_rl);
	zb_base   = active_window->zbuf + offset;
	
	y = active_window->y_max_rl - active_window->y_min_rl + 1;
	if( y < 0 ) y = 0;
	while( y-- )
		{
		zb = zb_base;
		cb = cb_base;

		x = active_window->x_max_rl - active_window->x_min_rl + 2;
		while( x-- )
			{
			if( *zb & OMASK )
				{
				if( *cb & DISPLAY_ME )
					*cb = line_color;
				else
					*cb = bg_color;
				}
				
			*zb &= ZMASK;
			
			zb++;
			cb++;
			}
		
		zb_base += ystep;
		cb_base += ystep;
		}
		
	/*
	 *  Reset min_rl/max_rl and trapezoid count
	 */

	active_window->x_min_rl = active_window->x_dits << 16;
	active_window->y_min_rl = active_window->y_dits;
	active_window->x_max_rl = 0;
	active_window->y_max_rl = 0;
	}


