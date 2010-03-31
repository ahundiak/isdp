#include "stdio.h"
#if defined (CLIX)
#include "gpipe.h"
#endif
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPdef.h"
#include "hsmath.h"
#include "HPpr_hplot_f.h"


/*-----------------------
 *
 *   for function
 *      fixed_divid
 */
 
#include "HSpr_display.h"

/*----------------------*/




#define	right	1
#define left	0
#define	xstepz	1
#define ystepz	active_window->x_dits

static int	xstepc;
static int	ystepc;
static int	cink;
static int	intendx;

#define	ZMASK	0x7fffffff

#define	slope_mask 0x10

#if defined(__STDC__) || defined(__cplusplus)
static void HPround_to_x (int x0, 
			int x1, 
			int z0, 
			int z1, 
			int *za, 
			int *zb);

static void HPfixed_mult(struct HSfixedpt *z, 
				    int n);
#else
static void HPround_to_x();
static void HPfixed_mult();
#endif

/*---Fixed_add_pt--------------------------------------------*/

/*
NAME
	Fixed_add_pt: Macro
	
KEYWORDS
	RHL1
	HSplot
	rasterizer
	macro
	
DESCRIPTION
	Perform a fixed point addition, where z in a pointer
	to a fixedpt structure
	
PARAMETERS
	z	:(IN) :  pointer to a fixedpt structure
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#define Fixed_add_pt( z )		 	\
					 	\
	{					\
	z->running += z->d_fract;		\
	z->active += ( z->d_whole * z->sign );	\
						\
	if( z->running < 0 )			\
		{				\
		z->active += z->sign;		\
		z->running &= 0x7fffffff;	\
		}				\
	}

struct x_struct
	{
	int	actual, next;
	int	running;
	int	dxy;
	int	jump;
	};

#define EDGE_DELTA 2

static count;

static int	y;
static int	d1, d2;
static HScbuf	*cb;
static HSzbuf	*zb;


/*
 *  Prototype declaration for static functions
 */
 
#if defined(__STDC__) || defined(__cplusplus)

#if defined(__cplusplus)
extern "C" {
#endif

static RASTERIZE_EDGE    (struct x_struct *x, 
			 struct HSfixedpt *z, 
				      int side, 
				      int slope, 
				      int *xs,
			 struct HSfixedpt *zs, 
				     long ya);

#if defined(__cplusplus)
}
#endif

#else

static RASTERIZE_EDGE();

#endif

/*---HPraster_lines_init-------------------------------------------*/

/*
NAME
	HPraster_lines_init
	
KEYWORDS
	HSplot
	RHL1
	rasterizer
	
DESCRIPTION
	Initialize some variables for RHL1 processing
	
GLOBALS USED
	HPglobal		: global structure
		bytes_per_pixel	: Whether were in 5 or 6 byte/pixel mode
	cink			: image buffer step size
	intendx			: 
	xstepc, ystepc		:
	xstepz, ystepz		:
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void HPraster_lines_init (void)
#else
	void HPraster_lines_init()	
#endif

	{
	cink = HPglobal.bytes_per_pixel == 5 ? 1 : 2;
	intendx = cink - 1;
	xstepc = xstepz * cink;
	ystepc = ystepz * cink;
	}
	
/*---RASTERIZE_EDGE-------------------------------------------------------*/

/*
NAME
	RASTERIZE_EDGE: static
	
KEYWORDS
	HSplot
	edge
	RHL1
	rasterizer
	static
	
DESCRIPTION
	Generate raster data for the edge of the trapezoid

PARAMETERS
	x	: Pointer to a x structure
	z	: Pointer to a z fixedpt structure
	side	: Whether this is the left or right side of the trapezoid
	slope	: 
	xs, zs	: Save the x, z where the edge stepped down to the next
		: scanline
	ya	: index of the current scanline

FUNCTIONS CALLED
	Fixed_add_pt
		
GLOBALS USED
	HPband_info	: global structure
		y_dits	: width of the viewport, used for clipping
	active_window	: global structure
		zbuf,	: Pointer to the z/image buffers
		cbuf	:
		x_dits	: height of the viewport
	d1		: Contains the marks for the edge
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	static RASTERIZE_EDGE    (struct x_struct *x, 
				 struct HSfixedpt *z, 
					      int side, 
					      int slope, 
					      int *xs,
				 struct HSfixedpt *zs, 
					     long ya)
#else
	static RASTERIZE_EDGE( x, z, side, slope, xs, zs, ya  )

	struct x_struct		*x;
	struct HSfixedpt	*z, *zs;
	int			*xs;
	int			side, slope;
	long			ya;
#endif

	{
	int	offset, dx;

	/*
	 *	If jump = -1 then the slope was steep enough so that there would 
	 *	never be more than a single step in x.
	 */
	 
	if( x->jump == -1 )
		{
		*xs = x->running;

		zs->sign = z->sign;
		zs->active = z->active;
		zs->running = z->running;
		zs->d_whole = z->d_whole;
		zs->d_fract = z->d_fract;

		/* Clipping */
		
		if( y > 0 && y < HPband_info.y_dits )
			{
			zb = active_window->zbuf + 
					(offset = y * active_window->x_dits + *xs + 1);
			cb = active_window->cbuf + (offset * cink);

			if( !(*zb & 0x80000000 ) || !(*cb & 4 ) )
				{
				if( (*zb & 0x7fffffff ) >= z->active )
					{
					*cb = d1 | 4 | slope;
					*zb = z->active | 0x80000000;
					}
				}
			else
				if( (*zb & 0x7fffffff ) >= z->active )
					{
					if( (*zb & 0x7fffffff ) - z->active <= EDGE_DELTA )
						d2 = d1 |( *cb & ~slope_mask );
					else
						d2 = d1;

					*cb = d2 | 4 | slope;
					*zb = z->active | 0x80000000;
					}
				else
					if( z->active -( *zb & 0x7fffffff ) <= EDGE_DELTA )
						*cb = *cb | d1;
			}

		x->actual += x->dxy;
		x->running = x->actual >> 16;
		Fixed_add_pt( z );
		}
	else
		{

		/*
		 * JUMP is non-negative, therefore, we can assume that we might
		 * have a step in x greater than 1.
		 */

		dx = ABS((x->next >> 16) - x->running);

		count = dx + (y != ya ? x->jump : 0);

		x->actual = x->next;
		x->next += x->dxy;

		zb = active_window->zbuf + 
			(offset = y * active_window->x_dits + x->running + 1);
		cb = active_window->cbuf + (offset * cink);

		/*
		 *	If we are doing the left edge of the trapezoid and the edge
		 *	angles to the left, or we are doing the right edge of the
		 *	trapezoid and it angles to the right, then the first pixel
		 *	is the interior pixel.
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

			/* Do hidden line test for new pixel. */

			if( y > 0 && y < HPband_info.y_dits )
				if( !(*zb & 0x80000000 ) || !(*cb & 4 ) )
					{
					if( (*zb & 0x7fffffff ) >= z->active )
						{
						*cb = d1 | 4 | slope;
						*zb = z->active | 0x80000000;
						}
					}
				else
					if( (*zb & 0x7fffffff ) >= z->active )
						{
						if( (*zb & 0x7fffffff ) - z->active <= EDGE_DELTA )
							d2 = d1 |( *cb & ~slope_mask );
						else
							d2 = d1;

						*zb = z->active | 0x80000000;
						*cb = d2 | 4 | slope;
						}
					else
						if( z->active -( *zb & 0x7fffffff ) <= EDGE_DELTA )
							*cb = *cb | d1;

			/*
			 *	If we are doing the right edge and it is angling to the
			 *	left, or we are doing the left edge and it is angling
			 *	to the right, then the last pixel is interior. The
			 *	count will be = 0 on the last pixel.
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

			Fixed_add_pt( z  );

			if( x->dxy < 0 )
				{
				x->running--;
				cb -= cink;
				zb--;
				}
			else
				{
				x->running++;
				cb += cink;
				zb++;
				}
			}

		while( count-- > 0 );
		}
	}
	
/*---HPraster_lines-----------------------------------------------*/

/*
NAME
	HPraster_lines
	
KEYWORDS
	HSplot
	RHL1
	rasterizer
	
DESCRIPTION
	Convert the given trapezoid to raster data, formatted for
	RHL1 display
	
PARAMETERS
	tile	: structure containing the trapezoid
	
GLOBALS USED
	HPband_info		: global structure
		org_y		: Used to translate the trapezoid to the band viewport
		y_dits		: Used to clip the trapezoid
	active_window		: global structure
		x_min_rl,	: Will contain the RHL min/max for a group of
		x_max_rl,	: trapezoids.  This is a range that the 2nd
		y_min_rl,	: pass will used, but may not be the same range
		y_max_rl	: used by the paint
		zbuf, cbuf	: Address of the z/image buffer
		x_dits		: height of the viewport
	d1			: Contains the RHL1 marks
	
FUNCTIONS CALLED
	fixed_divide
	HPround_to_x
	RASTERIZE_EDGE
	Fixed_add
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void HPraster_lines (struct trapezoid *tile)
#else
	void	HPraster_lines( tile )

	struct trapezoid	*tile; /* trapezoids data */
#endif

	{
	int			x0, x1, x2, x3;
	int			z0, z1, z2, z3;
	int			dx_left, dx_right, dx, dy;
	int			x_stop, x_start, offset;
	struct HSfixedpt	z, z_left, z_right, z_start, z_stop;
	struct x_struct		x_left, x_right;
	int			left_slope, right_slope;

	/* Translate the trapezoid to the zbuffer origin. */

	tile->ya -= HPband_info.org_y;
	tile->yb -= HPband_info.org_y;

	/* Clipping. */
	
	if( tile->ya < 0 ) return;
	if( tile->yb > HPband_info.y_dits ) return;

	/* Perform min/max test on the vertices for display region. */
	
	if( tile->x0 < active_window->x_min_rl ) active_window->x_min_rl = tile->x0;
	if( tile->x1 > active_window->x_max_rl ) active_window->x_max_rl = tile->x1;
	if( tile->x2 < active_window->x_min_rl ) active_window->x_min_rl = tile->x2;
	if( tile->x3 > active_window->x_max_rl ) active_window->x_max_rl = tile->x3;
		
	if( tile->yb < active_window->y_min_rl ) active_window->y_min_rl = tile->yb;
	if( tile->ya > active_window->y_max_rl ) active_window->y_max_rl = tile->ya;
	
	/*
	 * The x coordinates of the vertices are already <11:5>, copy them to
	 * long variables and shift left 11 to make them <16:16>.	This alloactive_window
	 * us to do integer arithmetic in interpolating the x's
	 */
	 
	x0 = tile->x0;
	x1 = tile->x1;
	x2 = tile->x2;
	x3 = tile->x3;
	
	z0 = tile->z0;
	z1 = tile->z1;
	z2 = tile->z2;
	z3 = tile->z3;
	
	d1 =(  tile->id & 0x10  ) ? 2 : 1;
	
	/* Calculate dx/dy. */

	if( (dy = tile->ya - tile->yb) == 0 )
		{
		x_left.dxy = 0;
		x_right.dxy = 0;
		}
	else
		{
		x_left.dxy =( x0 - x2 ) / dy;
		x_right.dxy =( x1 - x3 ) / dy;
		}
		
	/*
	 * Calculate dz/star.	If dx/dy is less than 1.0, then use dz/dy. If dx/dy 
	 * is greater than 1.0, then use dz/dx.
	 */
	 
	dx_left = (x0 >> 16) - (x2 >> 16);
	dx_right = (x1 >> 16) - (x3 >> 16);
	
	dx_left = ABS(dx_left);
	dx_right = ABS(dx_right);
	 
	left_slope  = dx_left  < dy ? slope_mask : 0;
	right_slope = dx_right < dy ? slope_mask : 0;
	
	if( dx_left > dy )
		{
		HPround_to_x( tile->x0, tile->x2, z0, z2, &z0, &z2 );
		
		fixed_divide(	(z0 - z2 ),
				dx_left,
				&z_left.sign,
				&z_left.d_whole,
				&z_left.d_fract );
							
		z_left.running = 0x40000000;
		
		x_left.jump = ABS(x_left.dxy) >> 17;
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
			fixed_divide(	(z0 - z2 ),
					dy,
					&z_left.sign,
					&z_left.d_whole,
					&z_left.d_fract );
									
			z_left.running = 0x40000000;
			}
					
		x_left.jump = -1;
		}
	
	if( ABS(dx_right) > dy )
		{
		HPround_to_x( tile->x1, tile->x3, z1, z3, &z1, &z3 );
		
		fixed_divide(	(z1 - z3 ),
				dx_right,
				&z_right.sign,
				&z_right.d_whole,
				&z_right.d_fract );
							
		z_right.running = 0x40000000;
			
		x_right.jump = ABS(x_right.dxy) >> 17;
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
			fixed_divide(	(z1 - z3 ),
					dy,
					&z_right.sign,
					&z_right.d_whole,
					&z_right.d_fract );
									
			z_right.running = 0x40000000;
			}
					
		x_right.jump = -1;
		}
	
	/* Load initial values for z. */
	
	z_left.active  = z2;
	z_right.active = z3;
	
	y = tile->yb;
	
	x_left.actual  = x2;
	x_right.actual = x3;
	
	x_left.running  = x2 >> 16;
	x_right.running = x3 >> 16;
	
	x_left.next  = x2;
	x_right.next = x3;

	while( y <= tile->ya )
		{
		RASTERIZE_EDGE( &x_left,  &z_left,  left,  left_slope,	&x_start, &z_start, tile->ya );
		RASTERIZE_EDGE( &x_right, &z_right, right, right_slope, &x_stop,  &z_stop,  tile->ya );
			
		if( y >= 0 && y <= HPband_info.y_dits )
			{
			if( y >= 0 && y <= HPband_info.y_dits )
			if( (dx = x_stop - x_start ) > 0 )
				{
				fixed_divide(	(z_stop.active - z_start.active ),
						dx,
						&z.sign,
						&z.d_whole,
						&z.d_fract );
									
				z.active = z_start.active;
				z.running = z_start.running;
					
				x_start++;
				Fixed_add( z );
					
				zb = active_window->zbuf + 
					(offset = y * active_window->x_dits + x_start + 1);
				cb = active_window->cbuf + (offset * cink);
					
				while( x_start < x_stop )
					{
					if( y == tile->ya || y == tile->yb )
						{
						if( !(*zb & 0x80000000) || !(*cb & 4 ) )
							{
							if( (*zb & 0x7fffffff ) >= z.active )
								{
								*cb = d1 | 4;
								*zb = z.active | 0x80000000;
								}
							}
						else
							if( (*zb & 0x7fffffff ) >= z.active )
								{
								if( ((*zb & 0x7fffffff ) - z.active ) <= EDGE_DELTA  )
									d2 = d1 | *cb;
								else
									d2 = d1;
											
								*cb = d2 | 4;
								*zb = z.active | 0x80000000;
								}
							else
								{
								if( (z.active -( *zb & 0x7fffffff ) ) <= EDGE_DELTA )
									 *cb = *cb | d1;
								}
						}
					else
						{				
						if( (*zb & 0x7fffffff ) >= z.active )
							{
							*cb = d1;
							*zb = z.active | 0x80000000;
							}
						}

					x_start++;
					Fixed_add( z  );
							
					cb += cink;
					zb++;
					}
				}
			}
					
		y++;
		}
	}
	
/*---HPround_to_x----------------------------------------------------------*/

/*
NAME
	HPround_to_x
	
KEYWORDS
	HSplot
	rasterizer
	RHL1
	
DESCRIPTION
	Due to the nature of the RHL1 algorithm, the x must also be a 
	whole number.  Because the z are computed at the fractional x,
	they must be adjusted when the x is rounded to it's whole number
	
PARAMETERS
	x0, x1	:(IN) : The fractional x values
	z0, z1	:(IN) : The z at the fractional x
	za, zb	:(OUT): The z at the whole x
	
FUNCTIONS CALLED
	HPfixed_mult
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HPround_to_x (int x0, 
				int x1, 
				int z0, 
				int z1, 
				int *za, 
				int *zb)	   
#else
	static void HPround_to_x( x0, x1, z0, z1, za, zb  )

	int	x0, x1;
	int	z0, z1;
	int	*za, *zb;
#endif

	{
	struct HSfixedpt	z2, z3;
	int			dx;
	
	if(( dx =( x0 >> 1 ) -( x1 >> 1 ) ) == 0  )
		{
		z2.sign = 1;
		z2.d_whole = 0;
		z2.d_fract = 0;
		z2.running = 0;
		}
	else
		{
		fixed_divide(	
				(z1 - z0 ),
				dx,
				&z2.sign,
				&z2.d_whole,
				&z2.d_fract  );
					
			z2.running = 0x40000000;
		}
			
	z3.sign = z2.sign;
	z3.d_whole = z2.d_whole;
	z3.d_fract = z2.d_fract;
	z3.running = z2.running;
		
	z2.active = z0;
	z3.active = z1;
		
	HPfixed_mult( &z2,( (x0 >> 1 ) & 0xf )  );
	HPfixed_mult( &z3,( (x1 >> 1 ) & 0xf )  );
		
	*za = z2.active;
	*zb = z3.active;
	}

/*---HPfixed_mult-----------------------------------------------------------*/

/*
NAME
	HPfixed_mult
	
KEYWORDS
	HSplot
	rasterizer
	RHL1
	
DESCRIPTION
	Perform a fixed point multiplication on the argument
	
PARAMETERS
	z	:(IN/OUT) : The fixed point number to multiply
	n	:(IN)     : Integer to multiply z by.
	
HISTORY
	??/??/??	M. Lanier
		Created
*/
 
#if defined(__STDC__) || defined(__cplusplus)
	static void HPfixed_mult( struct HSfixedpt *z, 
					     int n)				
#else
	static void HPfixed_mult( z, n  )

	struct HSfixedpt	*z;
	int			n;
#endif

	{
	int	zr, zf;
	
	n++;
	
	zr = z->running >> 5;
	zf = z->d_fract >> 5;
	
	zr += zf * n;
	
	z->running =( zr << 5 ) & ZMASK;
	
	z->active += z->sign *(  zr >> 26  );
	z->active +=(  z->d_whole * z->sign * n  );
	}

/*---trans_1---------------------------------------------------------------*/

/*
NAME
	trans_1: Macro
	
KEYWORDS
	HSplot
	rasterizer
	RHL1
	macro
	
DESCRIPTION
	Perform the type 1 transition test.
	
PARAMETERS
	zn	: Pointer into the zbuffer
	cb	: Pointer into the image buffer
	b_col	: background color
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#define	trans_1( zn, cn, b_col )	\
	(!(*(zn) & 0x80000000 ) && ((*(zb) & 0x7fffffff ) < *(zn) || *(cn) == b_col))

	
/*---trans_2---------------------------------------------------------------*/

/*
NAME
	trans_2: Macro
	
KEYWORDS
	HSplot
	rasterizer
	RHL1
	macro
	
DESCRIPTION
	Perform the type 2 transition test.
	
PARAMETERS
	zn	: Pointer into the zbuffer
	cb	: Pointer into the image buffer
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#define trans_2( zn, cn )	\
	( (*(zn) & 0x80000000 ) && ((*(cb) & 3 ) + (*(cn) & 3) == 3) )
			
/*---HPsilly_lines---------------------------------------------------------*/

/*
NAME
	HPsilly_lines
	
KEYWORDS
	HSplot
	rasterizer
	RHL1
	pass2
	
DESCRIPTION
	Evaluate the RHL1 marks in the image/zbuffer and generate the output
	raster data for the model
	
PARAMTERS
	line_color,	:  Colortable index for the edge and 
	bg_color	:  background (interior) colors.
	
GLOBALS USED
	element_parms		: global structure
		ele_clip_range	: element clip range
		facet_type	: the shading style
	HPband_info		: global structure
		org_y		: used to translate the data to the band viewport
	active_window		: global structure
		x_min_rl,	: The x/y min/max from first pass
		x_max_rl,	: processing.  differs from the
		y_min_rl,	: paint region min/max
		y_max_rl	:
		cbuf, zbuf	: address of the image/zbuffer
		x_dits		: height of the viewport
		
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void HPsilly_lines (int line_color, 
			    int bg_color)		    
#else
	void HPsilly_lines( line_color, bg_color )

	int line_color, bg_color;
#endif

	{
	HScbuf	*cb_base, *set_col;
	HSzbuf	*zb_base, *set_z;
	HScbuf	*first_pos, *last_pos;

	int	weight, weight_factor;
	int	x, y, bedge;
	int	xdits;
	int	step_factor;
	int	i, j, cat, dog;
	int	offset;

	/*
	 * The following was added by SRa on 8/5/87 to fix a bug where
	 * memory was being corrupted when active_window->y_min_rl = 0.
	 */


	bedge = (int)element_parms.ele_clip_range[0] - HPband_info.org_y;
		 
	if( element_parms.facet_type == REV_EDGES ) line_color = 180;

	active_window->x_min_rl = active_window->x_min_rl >> 16;
	active_window->x_max_rl = active_window->x_max_rl >> 16;
	
	active_window->x_min_rl &= 0xfffffffe;

	xdits = active_window->x_dits;
	 
	/* Start at the bottom of the sub-region and move up. */

	/*
	 *	Get address of pixel in color-buffer at left side of
	 *	of region for the given y.
	 */
	 	
	offset = active_window->y_min_rl * xdits + active_window->x_min_rl;

	zb_base = active_window->zbuf + offset;
	cb_base = active_window->cbuf + (offset * cink);

	y = active_window->y_min_rl;
	cat = active_window->y_max_rl - active_window->y_min_rl + 1;
	if( cat <= 0 ) return;
	
	while( cat-- )
		{
		cb = cb_base;
		zb = zb_base;


		if( y == bedge )
		{
		x = active_window->x_min_rl;
		dog = active_window->x_max_rl - active_window->x_min_rl + 1;
		while( dog-- )
			{
			if( zb >= active_window->zbuf && 
			    zb <= (HSzbuf *)active_window->cbuf )
			if( *zb & 0x80000000 && *cb & 0x0f )
			if( trans_1( zb-xstepz, cb-xstepc, bg_color ) ||
			    trans_1( zb+ystepz, cb+ystepc, bg_color ) ||
			    trans_1( zb+xstepz, cb+xstepc, bg_color ) ||
			  /*trans_1( zb-ystepz, cb-ystepc, bg_color ) ||*/
			    (*cb & 0x7) == 7 ||
			    trans_2( zb-xstepz, cb-xstepc ) ||
			  /*trans_2( zb-ystepz, cb-ystepc ) ||*/
			    trans_2( zb+ystepz, cb+ystepc ) ||
			    trans_2( zb+xstepz, cb+xstepc ) )
				*cb |= 0x80;

			cb += cink;
			zb++;
			x++;
			} } else

		if( y == active_window->y_dits || y == (active_window->y_dits-1) )
		{
		x = active_window->x_min_rl;
		dog = active_window->x_max_rl - active_window->x_min_rl + 1;
		while( dog-- )
			{
			if( zb >= active_window->zbuf && 
			    zb <= (HSzbuf *)active_window->cbuf )
			if( *zb & 0x80000000 && *cb & 0x0f )
			if( trans_1( zb-xstepz, cb-xstepc, bg_color ) ||
			  /*trans_1( zb+ystepz, cb+ystepc, bg_color ) ||*/
			    trans_1( zb+xstepz, cb+xstepc, bg_color ) ||
			    trans_1( zb-ystepz, cb-ystepc, bg_color ) ||
			    (*cb & 0x7) == 7 ||
			    trans_2( zb-xstepz, cb-xstepc ) ||
			    trans_2( zb-ystepz, cb-ystepc ) ||
			  /*trans_2( zb+ystepz, cb+ystepc ) ||*/
			    trans_2( zb+xstepz, cb+xstepc ) )
				*cb |= 0x80;
				
			cb += cink;
			zb++;
			x++;
			} } else
			
		{
		x = active_window->x_min_rl;
		dog = active_window->x_max_rl - active_window->x_min_rl + 1;
		while( dog-- )
			{
			if( zb >= active_window->zbuf && 
			    zb <= (HSzbuf *)active_window->cbuf )
			if( *zb & 0x80000000 && *cb & 0x0f )
			if( trans_1( zb-xstepz, cb-xstepc, bg_color ) ||
			    trans_1( zb+ystepz, cb+ystepc, bg_color ) ||
			    trans_1( zb+xstepz, cb+xstepc, bg_color ) ||
			    trans_1( zb-ystepz, cb-ystepc, bg_color ) ||
			    (*cb & 0x7) == 7 ||
			    trans_2( zb-xstepz, cb-xstepc ) ||
			    trans_2( zb-ystepz, cb-ystepc ) ||
			    trans_2( zb+ystepz, cb+ystepc ) ||
			    trans_2( zb+xstepz, cb+xstepc ) )
				*cb |= 0x80;

			cb += cink;
			zb++;
			x++;
			} }
			
		cb_base += ystepc;
		zb_base += ystepz;
		y++;
		}

	weight = (int)element_parms.visible_weight;
	weight_factor = (weight+1) / 2;
	
	/* Adjust the second pass region range box for addition of line weight. */
	
	active_window->x_min_rl -= weight_factor;
	if( active_window->x_min_rl < bedge ) active_window->x_min_rl = bedge;

	active_window->x_max_rl += weight_factor;
	if( active_window->x_max_rl > xdits ) active_window->x_max_rl = xdits;

	active_window->y_min_rl -= weight_factor;
	if( active_window->y_min_rl < bedge ) active_window->y_min_rl = bedge;

	active_window->y_max_rl += weight_factor;
	if( active_window->y_max_rl > active_window->y_dits )
		active_window->y_max_rl = active_window->y_dits;
	 
	/*
	 *	Get address of pixel in color-buffer at left side of
	 *	of region for the given y.
	 */
	 	
	offset = active_window->y_min_rl * xdits + active_window->x_min_rl;

	zb_base = active_window->zbuf + offset;
	cb_base = active_window->cbuf + (offset * cink);
	
	first_pos = cb_base;
	last_pos  = active_window->cbuf +
			(active_window->y_max_rl * xdits * cink + active_window->x_max_rl);


	y = active_window->y_max_rl - active_window->y_min_rl + 1;
	while( y-- )
		{
		cb = cb_base;
		zb = zb_base;

		x = active_window->x_max_rl - active_window->x_min_rl + 1;
		while( x-- )		
			{
			if( zb >= active_window->zbuf && 
			    zb <= (HSzbuf *)active_window->cbuf )
			if( *zb & 0x80000000 )
				{
				if( *cb & 0x80 )
					{
					step_factor = (weight / 2) * xstepz + 
						      (weight / 2) * ystepz;

					set_col = cb - (step_factor * cink);
					set_z   = zb - step_factor;
					
					i = weight;
					while( i-- )
						{
						j = weight;
						while( j-- )
							{
							if( set_col+j*cink >= first_pos &&
							    set_col+j*cink <= last_pos )
								{
									
								/*
 								 * The "if" below checks if the current pixel is not a core pixel or
								 * if the pixel's z-value is greater than that of the current core
								 * pixel. NOTE: If this is an internal pixel then then sign bit of
								 * the z will be set.	With masking out this bit, the z will always be
								 * larger.	Don't clear the sign bit.
								 */
								 
								if( (!(*(set_col+j*cink ) & 0x80 ) ||
								     !(*(set_z+j ) & 0x80000000 ) ) &&
								    (  *(set_z+j ) >( *zb & 0x7fffffff ) ) )
									{
									*(set_col+j*cink ) = 0x40;
									*(set_z+j ) = (*zb & 0x7fffffff ) | 0x80000000;
									}
								}
							}

						set_col += ystepc;
						set_z   += ystepz;
						}
	
					*cb = 0x40;
					}

				else
					if( !(*cb & 0x40 ) ) cb[0] &= 0xbf;
				}

			zb++;
			cb += cink;
			}
		
		cb_base += ystepc;
		zb_base += ystepz;
		}

	/* Now go back and clear the sign bits of the z's. */
	
	zb_base = active_window->zbuf + offset;
	cb_base = active_window->cbuf +( offset * cink );

	y = active_window->y_max_rl - active_window->y_min_rl + 1;
	while( y-- )
		{
		zb = zb_base;
		cb = cb_base;
		
		x = active_window->x_max_rl - active_window->x_min_rl;
		while( x-- )
			{
			if( zb >= active_window->zbuf && 
			    zb <= (HSzbuf *)active_window->cbuf )
			if( *zb & 0x80000000 )
				{
				if( *cb & 0x40 )
					{
					cb[intendx] = 0;
					cb[0] = line_color;
					}
				else
					{
					cb[intendx] = 0;
					cb[0] = bg_color;
					}
				}
							
			*zb &= 0x7fffffff;
					
			zb++;
			cb += cink;
			} /* end for x */
		
		zb_base += ystepz;
		cb_base += ystepc;
		}
			
	/* Reset min_rl/max_rl and trapezoid count. */
	
	active_window->x_min_rl = active_window->x_dits << 16;
	active_window->y_min_rl = active_window->y_dits;
	active_window->x_max_rl = 0;
	active_window->y_max_rl = 0;
	} /* end HPsilly_lines */

