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
#if !HS14
#include "hsmath.h"
#endif

#include "HSpr_display.h"


/*
 *  Prototype declaration for static functions
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

static void HPadd_weight_east_west __((HScbuf *cb, 
					  int color));
					  
static void HPadd_weight_north_south __((HScbuf *cb, 
					    int color));
					    
static void HPadd_weight __((void));

static int HPset_weight_steps __((int dx, 
				  int dy));



#if defined(__cplusplus)
}
#endif


#undef __

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
	static void HPadd_weight_east_west( HScbuf *cb, int color )
#else
	static void HPadd_weight_east_west( cb, color )

	HScbuf		*cb;
	int		color;
#endif

	{
	int		i;
	HScbuf		*cb1, *cb2;


	cb1 = cb2 = cb;
		
	/*
	 *  Add ACTIVE_WIDTH pixels of weight
	 */
	 
	i = VWIDTH;
	while( --i )
		{
		cb1 += (xstep);		
		*cb1 = (color);

		/*
		 *  Just in case the width is odd
		 */
		 
		if( !(--i) ) break;

		cb2 -= (xstep);
		*cb2 = (color);
		}
	}
	
/*---HPadd_weight_north_south-------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HPadd_weight_north_south( HScbuf *cb, int color )
#else
	static void HPadd_weight_north_south( cb, color )

	HScbuf		*cb;
	int		color;
#endif

	{
	int		i;
	HScbuf		*cb1, *cb2;
	
	cb1 = cb2 = cb;

	/*
	 *  Add ACTIVE_WIDTH pixels of weight
	 */
	 
	i = VWIDTH;
	while( --i )
		{
		cb1 += (ystep);		
		*cb1 = (color);

		/*
		 *  Just in case the width is odd
		 */
		 
		if( !(--i) ) break;

		cb2 -= (ystep);
		*cb2 = (color);
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

/*---HSstart_dzine-----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSstart_dzine( struct polyline_vertex *start_point )
#else
	void	HSstart_dzine( start_point )

	struct polyline_vertex	*start_point;
#endif

	{
	current_vertex = *start_point;
	
	xdits = active_window->x_dits;	
	
	VWIDTH = (int)element_parms.visible_weight;
	
	vstyle_index = 0;
	vstyle_length = 0.0;
	}
	
/*---HScontinue_dzine--------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HScontinue_dzine( struct polyline_vertex *next_vertex )
#else
	void HScontinue_dzine( next_vertex )

	struct polyline_vertex	*next_vertex;
#endif

	{
	int				x1, x2;	
	int				y1, y2;
	
	int				x3, x4;
	
	int				dx, dy;
	int				ydir, xdir;
	
	register HScbuf			*cb;

	
#	if DEBUG
		fprintf( stderr, "HPstart_dzine(%1d)\n", ++c1 );
		fprintf( stderr, "   %4d %4d %x\n", 
			current_vertex.x >> 16, current_vertex.y, current_vertex.z );
		fprintf( stderr, "   %4d %4d %x\n", 
			next_vertex->x >> 16, next_vertex->y, next_vertex->z );
#	endif

	/*
	 *  clipping
	 */

	p0 = current_vertex;
	p1 = *next_vertex;

	x1 = p0.x;     
	y1 = p0.y;     
		
	x2 = p1.x;     
	y2 = p1.y;     
		
				
	if( (dy = ABS(y2 - y1) + 1) == 0 )
		{
		dx = x2 - x1;
		}
	else
		{
		dx = ( x2 - x1 ) / dy;
		}
	
	HPset_weight_steps( (x2-x1), (y2-y1) );
	
	ydir = y1 < y2 ? 1 : -1;
			
	for( ;y1 != y2+ydir; y1+=ydir )
		{
		x3 = x1 >> 16;
		x1 += dx;	
		x4 = x1 >> 16;
		
		cb = active_window->cbuf + (y1 * active_window->x_dits + x3);

		xdir = x3 < x4 ? 1 : -1;
		
		for( ;x3 != x4+xdir; x3+=xdir )
			{
			HSset_style( x3, y1 );

			if( !(vstyle_index & 1) )
				{
				cb[0] = element_parms.color;
				
				(*add_weight)( cb, element_parms.color );
				}
						
			
			cb += (xdir);
			}
		}
				
	/*
	 *  Move second vertice to first
	 */
			 
	current_vertex = *next_vertex;
	}

