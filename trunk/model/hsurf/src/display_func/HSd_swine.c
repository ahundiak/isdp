#include <stdio.h>
#if defined (ENV5)
#include "gpipe.h"
#endif
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "hsmath.h"
#include "hsmacdef.h"
#include "HSd_macros.h"
#include "HStl_global.h" 

#include "HSpr_display.h"


static	int	xdits;

#define	xstep	1
#define ystep	(xdits)

/*
 *  style  stuff
 */
 
static	int	vstyle_index = 0;
static	double	vstyle_length = 0.0;
static	int	xold, yold;

static int	VWIDTH = 1;

static void	(*add_weight)() = NULL;

#define	PSIZE_D		3.59
#define	PSIZE_HV	2.54

static double	pixel_size_diag	= PSIZE_D;
static double	pixel_size_hovt	= PSIZE_HV;

static struct	polyline_vertex		current_vertex;
static struct	polyline_vertex		p0, p1;

static struct	ifb_vertices
		{
		int	x, y;
		long	z_whole, z_fract;
		};
		
#define DEBUG	0

#if DEBUG
static int	c1 = 0;
#endif

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

/* NOTE: How to prototype a function pointer
static void __((*add_weight));*/

static void HPadd_weight_east_west __((HSzbuf *zb, 
				       HScbuf *cb, 
					  int color));
					  
static void HPadd_weight_north_south __((HSzbuf *zb, 
					 HScbuf *cb, 
					    int color));
					    
static void HPadd_weight __((void));

static int HPset_weight_steps __((int dx, 
				  int dy));


#if defined(__cplusplus)
}
#endif


#undef __

/*---HSset_style---------------------------------------------------------*/

#define	HSset_style( x, y )						\
									\
	{								\
	if( xold != ROUND16(x) && yold != (y) )				\
		{							\
		vstyle_length += pixel_size_diag;			\
		}							\
	else								\
		{							\
		vstyle_length += pixel_size_hovt;			\
		}							\
									\
	if( vstyle_length >= element_parms.v_pattern[vstyle_index] )	\
		{							\
		vstyle_length -= element_parms.v_pattern[vstyle_index++];	\
		if( element_parms.v_pattern[vstyle_index] == 0.0 )	\
			 vstyle_index = 0;				\
		}							\
									\
	xold = ROUND16(x);						\
	yold = (y);							\
	}
	
/*---HPadd_weight_east_west-------------------------------------------------------*/

/*
 *  Add weight to the edge horizonally.  
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static void HPadd_weight_east_west( HSzbuf *zb, 
					    HScbuf *cb, 
					       int color )
#else
	static void HPadd_weight_east_west( zb, cb, color )

	HSzbuf		*zb;
	HScbuf		*cb;
	int		color;
#endif

	{
	int		i;
	HScbuf		*cb1, *cb2;
	HSzbuf		*zb1, *zb2, z;


	cb1 = cb2 = cb;
	zb1 = zb2 = zb;
	
	z = *zb;
		
	/*
	 *  Add ACTIVE_WIDTH pixels of weight
	 */
	 
	i = VWIDTH;
	while( --i )
		{
		cb1 += (xstep);
		zb1 += (xstep);
		
		if( !(zb1 < active_window->zbuf || zb1 > (HSzbuf *)active_window->cbuf) )
			{
			*cb1 = (color);
			*zb1 = z;
			}

		/*
		 *  Just in case the width is odd
		 */
		 
		if( !(--i) ) break;

		cb2 -= (xstep);
		zb2 -= (xstep);

		if( !(zb2 < active_window->zbuf || zb2 > (HSzbuf *)active_window->cbuf) )
			{
			*cb2 = (color);
			*zb2 = z;
			}
		}
	}
	
/*---HPadd_weight_north_south-------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HPadd_weight_north_south( HSzbuf *zb, 
					      HScbuf *cb, 
					         int color )
#else
	static void HPadd_weight_north_south( zb, cb, color )

	HSzbuf		*zb;
	HScbuf		*cb;
	int		color;
#endif

	{
	int		i;
	HScbuf		*cb1, *cb2;
	HSzbuf		*zb1, *zb2, z;
	
	cb1 = cb2 = cb;
	zb1 = zb2 = zb;
	
	z = *zb;	

	/*
	 *  Add ACTIVE_WIDTH pixels of weight
	 */
	 
	i = VWIDTH;
	while( --i )
		{
		cb1 += (ystep);
		zb1 += (ystep);
		
		if( !(zb1 < active_window->zbuf || zb1 > (HSzbuf *)active_window->cbuf) )
			{
			*cb1 = (color);
			*zb1 = z;
			}

		/*
		 *  Just in case the width is odd
		 */
		 
		if( !(--i) ) break;

		cb2 -= (ystep);
		zb2 -= (ystep);

		if( !(zb2 < active_window->zbuf || zb2 > (HSzbuf *)active_window->cbuf) )
			{
			*cb2 = (color);
			*zb2 = z;
			}
		}
	}

/*---HPadd_weight-------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HPadd_weight(void)
#else
	static void HPadd_weight()
#endif

	{
	}
		
/*---HPset_weight_steps---------------------------------------------------*/
 
#if defined(__STDC__) || defined(__cplusplus)
	static int	HPset_weight_steps( int dx, int dy )
#else
	static int	HPset_weight_steps( dx, dy )

	int		dx, dy;
#endif

	{
	int	ady, adx;
	
	ady = dy < 0 ? -dy : dy;
	adx = dx < 0 ? -dx : dx;

	adx = ROUND16( adx );
	
	if( VWIDTH <= 1 )
		add_weight = HPadd_weight;
	else
		if( adx <= ady )
			add_weight = HPadd_weight_east_west;
		else
			add_weight = HPadd_weight_north_south;

	return(0);
	}

/*---HSstart_swine-----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSstart_swine( struct polyline_vertex *start_point )
#else
	void	HSstart_swine( start_point )

	struct polyline_vertex	*start_point;
#endif

	{
	current_vertex = *start_point;
	
	xdits = active_window->x_dits;	

	
	VWIDTH = (int)element_parms.visible_weight;
	
	vstyle_index = 0;
	vstyle_length = 0.0;
	
	if( current_vertex.x < active_window->x_min ) active_window->x_min = current_vertex.x;
	if( current_vertex.x > active_window->x_max ) active_window->x_max = current_vertex.x;
			
	if( current_vertex.y < active_window->y_min ) active_window->y_min = current_vertex.y;
	if( current_vertex.y > active_window->y_max ) active_window->y_max = current_vertex.y;
	}

	
/*---HScontinue_swine--------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HScontinue_swine( struct polyline_vertex *next_vertex )
#else
	void HScontinue_swine( next_vertex )

	struct polyline_vertex	*next_vertex;
#endif

	{
	int				x1, x2;	
	int				y1, y2;
	
	int				x3, x4;
	
	int				dx, dy;
	int				ydir, xdir;
	int				offset;
	
	struct	HSfixedpt		z1, z2;
	register HSzbuf			*zb;
	register HScbuf			*cb;

	
#	if DEBUG
		fprintf( stderr, "HPstart_swine(%1d)\n", ++c1 );
		fprintf( stderr, "   %4d %4d %x\n", 
			current_vertex.x >> 16, current_vertex.y, current_vertex.z );
		fprintf( stderr, "   %4d %4d %x\n", 
			next_vertex->x >> 16, next_vertex->y, next_vertex->z );
#	endif

	if( next_vertex->x < active_window->x_min ) active_window->x_min = next_vertex->x;
	if( next_vertex->x > active_window->x_max ) active_window->x_max = next_vertex->x;
			
	if( next_vertex->y < active_window->y_min ) active_window->y_min = next_vertex->y;
	if( next_vertex->y > active_window->y_max ) active_window->y_max = next_vertex->y;

	p0 = current_vertex;
	p1 = *next_vertex;

	x1 = p0.x;     
	y1 = p0.y;     
	z1.active = p0.z;
		
	x2 = p1.x;     
	y2 = p1.y;     
	z2.active = p1.z;
		
	/*
	 *  Calculate delta change along vector
	 */

	if( (dx = ((x2 - x1) >> 16) + 1) == 0 )
		{
		z2.d_whole = z2.active - z1.active;
		z2.sign = 1;
		z2.d_fract = 0;
		}
	else
		{
		fixed_divide(	(z2.active - z1.active),
				dx,
				&z2.sign,
				&z2.d_whole,
				&z2.d_fract );
		}
				
	if( (dy = ABS(y2 - y1) + 1) == 0 )
		{
		dx = x2 - x1;
		}
	else
		{
		dx = ( x2 - x1 ) / dy;
		}
				
	if( (dy = ABS(y2 - y1)) == 0 )
		{
		z1.d_whole = z2.active - z1.active;
		z1.sign = 1;
		z1.d_fract = 0;
		}
	else
		{
		fixed_divide(	(z2.active - z1.active),
				dy,
				&z1.sign,
				&z1.d_whole,
				&z1.d_fract );
						
		z1.running = 0x40000000;
		}
	
	HPset_weight_steps( (x2-x1), (y2-y1) );
	
	ydir = y1 < y2 ? 1 : -1;

	for( ;y1 != y2+ydir; y1+=ydir )
		{
		x3 = x1 >> 16;
		z2.active = z1.active;
		z2.running = z1.running;
		x1 += dx;	
		x4 = x1 >> 16;
		Fixed_add( z1 );

		zb = active_window->zbuf + (offset = y1 * active_window->x_dits + x3);
		cb = active_window->cbuf +  offset;

		xdir = x3 < x4 ? 1 : -1;
		
		for( ;x3 != x4+xdir; x3+=xdir )
			{
			HSset_style( x3, y1 );
	
			if( (vstyle_index & 1) != element_parms.v_pat_on_off )
			if( *zb >= z2.active )
				{
				*zb = element_parms.delete ? HS_BACKGROUND_Z : z2.active;
				*cb = element_parms.color;
								
				(*add_weight)( zb, cb, element_parms.color );
				}
						
			Fixed_add( z2 );
					
			zb += xdir;			
			cb += xdir;
			}
		}
				
	/*
	 *  Move second vertice to first
	 */
			 
	current_vertex = *next_vertex;
	}

