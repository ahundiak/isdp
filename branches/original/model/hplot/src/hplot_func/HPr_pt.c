#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HPglobal.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"



#define POINT_SIZE	2
#define DEBUG	0


/*---HPdraw_point--------------------------------------------------------------*/

/*
NAME
	HPdraw_point
	
KEYWORDS
	HSplot
	rasterizer
	point
	question coding
	
DESCRIPTION
	Rasterizes a point and places it in the z/image buffer

PARAMETERS
	point	:(IN) :  Coordinates of the point
	
GLOBALS USED
	HPband_info	: global structure
		org_y	: Used to translate the point into the band viewport
		y_dits	: Used to clip the point on the right side of the viewport
	element_parms	: global structure
		delete	: Check delete mode (???)
		color	: active color of the point
	active_window	: global structure
		x_min,
		y_min,
		x_max,
		y_max	: X/Y range of the point
		cbuf	: address of the image buffer
		zbuf	: address of the z buffer
		xdits	: height of the viewport
		
NOTES
	QUESTION: Points are of a fixed side, should they be variable???
	QUESTION: Is it necessary to check the delete mode
		
HISTORY
	??/??/??	M. Lanier
		Created	
*/

#if defined(__STDC__) || defined(__cplusplus)
	void HPdraw_point (struct polyline_vertex *point)
#else
	void HPdraw_point( point )

	struct polyline_vertex	*point;
#endif

	{
	int				offset;
	
	register HSzbuf			*zb;
	register HScbuf			*cb;
	
	int				x, y;
	
	int				x0, y0;
	int				x1, y1;

#	if DEBUG
	printf( "HPdraw_point\n" );
	printf( "   point --- %d %d %d\n", point->x, point->y, point->z );
#	endif

	/*
	 *  Translate point to the zbuffer origin
	 */
	 
	point->y -= HPband_info.org_y;
	
	/*
	 *  clipping
	 */
	 
	if( point->y < 0 ) point->y = 0;
	if( point->y > HPband_info.y_dits ) point->y = HPband_info.y_dits;
	
	/*
	 *  End clipping
	 */
	
	x0 = (point->x >> 16) - (POINT_SIZE / 2);
	y0 =  point->y       - (POINT_SIZE / 2);
		
	x1 = x0 + POINT_SIZE;
	y1 = y0 + POINT_SIZE;
		
	if( point->x < active_window->x_min ) active_window->x_min = x0 << 16;
	if( point->x > active_window->x_max ) active_window->x_max = x1 << 16;
			
	if( point->y < active_window->y_min ) active_window->y_min = y0;
	if( point->y > active_window->y_max ) active_window->y_max = y1;
			
	for( y=y0; y<=y1; y++ )
		{
		zb = active_window->zbuf + (offset = y * active_window->x_dits + x0);
		cb = active_window->cbuf + (offset * 2);
			
		for( x=x0; x<=x1; x++ )
			{
			if( *zb >= point->z )
				{
				*zb = element_parms.delete ?
					HS_BACKGROUND_Z : point->z;
	
				cb[0] = element_parms.color;
				cb[1] = 0;
				}
					
			cb += 2;
			zb++;
			}
		}
	}
