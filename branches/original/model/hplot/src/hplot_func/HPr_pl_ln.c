#include <stdio.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPdef.h"
#if !HS14
#include "hsmath.h"
#endif
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

static int CLIP(long x0, 
		long y0, 
		long x1, 
		long y1, 
		 int y );

#if defined(__cplusplus)
}
#endif

#else

static int CLIP();

#endif

static struct	polyline_vertex		current_vertex;
static struct	polyline_vertex		p0, p1;

static struct	ifb_vertices
		{
		int	x, y;
		long	z_whole, z_fract;
		};
		
#define DEBUG	0

/*---HPstart_polyline-----------------------------------------------------------------*/

/*
NAME
	HPstart_polyline
	
KEYWORDS
	HSplot
	polyline
	rasterizer
	
DECSRIPTION
	Accepts the first vertex of a polyline and saves it until the next one
	is recieved
	
PARAMETERS
	start_point	:(IN) :  The coordinates of the first vertex
	
GLOBALS USED
	current_vertex: Static local to this source, used for saving the first
			or previous vertex.
	HPband_info: global structure
		org_y:  Used to translate the polyline to the band viewport
		
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void HPstart_polyline (struct polyline_vertex *start_point)
#else
	void	HPstart_polyline( start_point )

	struct polyline_vertex	*start_point;
#endif

	{
#	if DEBUG
	fprintf( stderr, "HPstart_polyline\n" );
	fprintf( stderr, "   start_point --- %d %d %d\n", start_point->x >> 16, 
		start_point->y, start_point->z );
#	endif

	current_vertex = *start_point;
	
	/*
	 *  Translate point to the zbuffer origin
	 */
	 
	current_vertex.y -= HPband_info.org_y;
	}

/*---CLIP--------------------------------------------------------*/

/*
NAME
	CLIP: static
	
KEYWORDS
	HSplot
	polyline
	clipping
	rasterizer
	
DESCRIPTION
	Given the endpoints of a polyline segment, compute the x 
	intersection of the segment with either side of the viewport
	
PARAMETERS
	x0, y0: x/y coordinates of the starting vertex of the polyline segment
	x1, y1: x/y coordinates of the ending vertex of the polyline segment
	y     : y coordinate of the edge of the viewport to clip against

GLOBALS USED
	-none-
	
HISTORY
	??/??/??	M. Lanier
		Create
*/

#if defined(__STDC__) || defined(__cplusplus)
	static int CLIP(long x0, 
			long y0, 
			long x1, 
			long y1, 
			 int y )
#else
	static int	CLIP( x0, y0, x1, y1, y )

	long	x0, y0;
	long	x1, y1;
	int	y;
#endif

	{
	int	dx1, dy1, dy0;

	dx1 = x1 - x0;
	dy1 = y1 - y0;
	dy0 = y - y0;

	if( dy1 == 0 ) return( x0 );

	dx1 /= dy1;
	dx1 *= dy0;
	dx1 += x0;

	return( dx1 );
	}
	
/*---HPcontinue_polyline--------------------------------------------------------------*/

/*
NAME
	HPcontinue_polyline
	
KEYWORDS
	HSplot
	polyline
	rasterizer
	question coding
	
DESCRIPTION
	Given the current and previous vertex of a segment of a polyline, interpolate
	to rasterize the segment and write into the z/image buffer
	
PARAMETERS
	next_vertex	:(IN) : Ending vertex of the polyline segment
	
GLOBALS USED
	HPband_info   : global structure
		org_y : Used to translate the polyline segment to the band viewport
		y_dits: width of the viewport in pixels. Used for clipping the
			polyline segment on the right side.
	current_vertex: coordinates of the previous vertex, or starting point 
		        of the polyline segment
	active_window : global structure
		zbuf  :  Address of the zbuffer
		cbuf  :  Address of the image buffer
		xdits : height of the viewport
	element_parms : global structure
		delete: If we are in delete mode (for plotting???)
		color : The active color of the polyline
		
NOTES
	QUESTION: Why should I check the delete mode if we are plotting???
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void HPcontinue_polyline (struct polyline_vertex *next_vertex)
#else
	void HPcontinue_polyline( next_vertex )

	struct polyline_vertex	*next_vertex;
#endif

	{
	int				x1, x2;	
	int				y1, y2;
	
	int				x3, x4;
	
	int				dx, dy;
	int				direction;
	int				offset;
	
	struct	HSfixedpt		z1, z2;
	register HSzbuf			*zb;
	register HScbuf			*cb;

	
	/*int	ABS();*/

#	if DEBUG
		fprintf( stderr, "HPcontinue_polyline\n" );
		fprintf( stderr, "   next_vertex --- %d %d %d\n", next_vertex->x >> 16, 
			next_vertex->y, next_vertex->z );
#	endif

	/*
	 *  Translate point to the zbuffer origin
	 */
	 
	next_vertex->y -= HPband_info.org_y;
	
	/*
	 *  clipping
	 */

	p0 = current_vertex;
	p1 = *next_vertex;

	if( p0.y < 0 )
		{
		p0.y = 0;
		p0.x = CLIP( current_vertex.x, current_vertex.y, 
			     next_vertex->x, next_vertex->y,
			     (int)0 );
		}

	if( p0.y > HPband_info.y_dits )
		{
		p0.y = HPband_info.y_dits;
		p0.x = CLIP( current_vertex.x, current_vertex.y, 
			     next_vertex->x, next_vertex->y,
			     HPband_info.y_dits );
		}

	if( p1.y < 0 )
		{
		p1.y = 0;
		p1.x = CLIP( current_vertex.x, current_vertex.y, 
			     next_vertex->x, next_vertex->y,
			     (int)0 );
		}

	if( p1.y > HPband_info.y_dits )
		{
		p1.y = HPband_info.y_dits;
		p1.x = CLIP( current_vertex.x, current_vertex.y, 
			     next_vertex->x, next_vertex->y,
			     HPband_info.y_dits );
		}

	/*
	 *  End clipping
	 */

	/*
	 *  Move vertices into real variables.  Make sure that
	 *  x1 <= x2;
	 */
			 
	if( p0.x < p1.x )
		{
		x1 = p0.x;     
		y1 = p0.y;     
		z1.active = p0.z;
		
		x2 = p1.x;     
		y2 = p1.y;     
		z2.active = p1.z;
		}
	else
		{
		x1 = p1.x;     
		y1 = p1.y;     
		z1.active = p1.z;
		
		x2 = p0.x;     
		y2 = p0.y;     
		z2.active = p0.z;
		}
		
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
				
	direction = y1 < y2 ? 1 : -1;
			
	for( ;y1 != y2+direction; y1+=direction )
		{
		x3 = x1 >> 16;
		z2.active = z1.active;
		z2.running = z1.running;
		x1 += dx;	
		x4 = x1 >> 16;
		Fixed_add( z1 );
		
		zb = active_window->zbuf + (offset = y1 * active_window->x_dits + x3);
		cb = active_window->cbuf + (offset * 2);

		for( ;x3 <= x4; x3++ )
			{
			if( *zb >= z2.active )
				{
				*zb = element_parms.delete ?
					HS_BACKGROUND_Z : z2.active;
					
				cb[0] = element_parms.color;
				cb[1] = 0;
				}
						
			Fixed_add( z2 );
					
			zb++;
			cb += 2;
			}
		}
				
	/*
	 *  Move second vertice to first
	 */
			 
	current_vertex = *next_vertex;
	}
