
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

#include <stdlib.h>
#include <stdio.h>

#include "igrtypedef.h"
#include "igr.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "hsmath.h"
#include "HSd_fixedpt.h"

#include "HSpr_display.h"

static struct	polyline_vertex		current_vertex;

static struct	ifb_vertices
		{
		int	x, y;
		long	z_whole, z_fract;
		};
		
static struct ifb_vertices	verts[2];

#define DEBUG	0


/*---HSstart_polyline_rop-----------------------------------------------------------------*/

/*
NAME
    HSstart_polyline_rop
    
DESCRIPTION
    Initializes the first vertex of the local polyline segment variable
    with the first vertex of the polyline.
    
PARAMETERS
    start_point: (IN):  Polyline vertex structure
    
GLOBALS USED
    active_window
    
HISTORY
    ??/??/??   M. Lanier
        Created
        
    2/2/93     M. Lanier
        WL Converted
*/

void	HSstart_polyline_rop( struct polyline_vertex *start_point )

    {
#   if DEBUG
    fprintf( stderr, "HSstart_polyline_rop\n" );
    fprintf( stderr, "   start_point --- %d %d %d\n", start_point->x >> 16, 
        start_point->y, start_point->z );
#   endif

    current_vertex = *start_point;

    /*  Update the image buffer range box  */
    	
    if( current_vertex.x < active_window->x_min ) active_window->x_min = current_vertex.x;
    if( current_vertex.x > active_window->x_max ) active_window->x_max = current_vertex.x;
			
    if( current_vertex.y < active_window->y_min ) active_window->y_min = current_vertex.y;
    if( current_vertex.y > active_window->y_max ) active_window->y_max = current_vertex.y;			
    }
	
/*---HScontinue_polyline_rop--------------------------------------------------------------*/

/*
NAME
    HScontinue_polyline_rop
    
DESCRIPTION
    Given the next vertex, use the previous saved vertex to form a
    polyline segment.  Use a Breshenham to rasterize the segment,
    perform per/pixel visibility test, and insert it into the z/image buffer
    
PARAMETERS
    next_vertex: (IN):  Next vertex in the polyline.
    
GLOBALS USED
    active_window

HISTORY
    ??/??/??    M. Lanier
        Created
        
    2/2/93      M. Lanier
        WL Converted
*/

void HScontinue_polyline_rop( struct polyline_vertex *next_vertex )

    {
    int				x1, x2;	
    int				y1, y2;
    
    int				x3, x4;
    
    int				dx, dy;
    int				direction;
    int				offset;
	
    struct HSfixedpt		z1, z2;
    register HSzbuf		*zb;
    register HScbuf		*cb;
	
#    if DEBUG
        fprintf( stderr, "HScontinue_polyline_rop\n" );
        fprintf( stderr, "   next_vertex --- %d %d %d\n", next_vertex->x >> 16, 
            next_vertex->y, next_vertex->z );
#    endif

    /*
     *  Perform min/max test on vertices
     */
             
    if( next_vertex->x < active_window->x_min ) active_window->x_min = next_vertex->x;
    if( next_vertex->x > active_window->x_max ) active_window->x_max = next_vertex->x;
            
    if( next_vertex->y < active_window->y_min ) active_window->y_min = next_vertex->y;
    if( next_vertex->y > active_window->y_max ) active_window->y_max = next_vertex->y;
            
    /*
     *  Move vertices into real variables.  Make sure that
     *  x1 <= x2;
     */
             
    if( current_vertex.x < next_vertex->x )
        {
        x1 = current_vertex.x;     
        y1 = current_vertex.y;     
        z1.active = current_vertex.z;
        
        x2 = next_vertex->x;     
        y2 = next_vertex->y;     
        z2.active = next_vertex->z;
        }
    else
        {
        x1 = next_vertex->x;     
        y1 = next_vertex->y;     
        z1.active = next_vertex->z;
        
        x2 = current_vertex.x;     
        y2 = current_vertex.y;     
        z2.active = current_vertex.z;
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
        fixed_divide(    (z2.active - z1.active),
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
        fixed_divide(    (z2.active - z1.active),
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
        
        zb = active_window->zbuf + 
            (offset = y1 * active_window->x_dits + x3);
        cb = active_window->cbuf + offset;

        for( ;x3 <= x4; x3++ )
            {
            if( *zb >= z2.active )
                {
                *zb = element_parms.delete ?
                    HS_BACKGROUND_Z : z2.active;
                    
                *cb = element_parms.color;
                }
                        
            Fixed_add( z2 );
                    
            zb++;
            cb++;
            }
        }
                
    /*
     *  Move second vertice to first
     */
             
    current_vertex = *next_vertex;
    }

#if defined (ENV5)
/*---HSstart_polyline_ifb-----------------------------------------------------------------*/

/*
NAME
	HSstart_polyline_ifb
	
KEYWORDS
	POLYLINE
	RASTERIZER
	IFB
	
DESCRIPTION
	Initialize the first vertex of a new polyline for IFB display
	
ARGUMENTS
	start_point: (IN): polyline structure containing the first vertex of a 
	                   contiguous polyline.
	                   
HISTORY
	??/??/??	M. Lanier
		Created
*/

void    HSstart_polyline_ifb( struct polyline_vertex *start_point )

    {
#   if DEBUG
    fprintf( stderr, "HSstart_polyline_ifb\n" );
    fprintf( stderr, "   start_point --- %d %d %d\n", start_point->x >> 16, 
        start_point->y, start_point->z );
#   endif

    verts[0].x = start_point->x >> 16;
    verts[0].y = start_point->y;
    verts[0].z_whole = start_point->z;
    verts[0].z_fract = 0;
    }
    
/*---HScontinue_polyline_ifb--------------------------------------------------------------*/

/*
NAME
	HScontinue_polyline_ifb
	
KEYWORDS
	POLYLINE
	RASTERIZER
	IFB
	
DESCRIPTION
	Given the next vertex of the polyline, join with the previous and form
	a line segment, which is rasterized and displayed by the IFB
	function sh_linestr.
	
ARGUMENTS
	next_vertex: (IN): polyline structure containing the next vertex of a 
	                   contiguous polyline.
	                   
HISTORY
	??/??/??	M. Lanier
		Created
*/

void HScontinue_polyline_ifb( struct polyline_vertex *next_vertex )

    {
    struct HSfixedpt    z;
    int            delta;
    int            dx, dy;
    
#   if DEBUG
    fprintf( stderr, "HScontinue_polyline_ifb\n" );
    fprintf( stderr, "   next_vertex --- %d %d %d\n", next_vertex->x >> 16, 
        next_vertex->y, next_vertex->z );
#   endif

    verts[1].x = next_vertex->x >> 16;
    verts[1].y = next_vertex->y;
    
    dx = ABS( (verts[1].x - verts[0].x) );
    dy = ABS( (verts[1].y - verts[0].y) );
    
    delta = dx > dy ? dx : dy;
    
    if( delta == 0 )
        {
        z.d_whole = 0;
        z.d_fract = 0;
        z.sign = 0;
        }
    else
        {
        fixed_divide(    (next_vertex->z - verts[0].z_whole),
                delta,
                &z.sign,
                &z.d_whole,
                &z.d_fract );
        }
        
    verts[1].z_whole = z.d_whole * z.sign;
    verts[1].z_fract = z.d_fract;

/*
fprintf( stderr, "sh_linestr----------------\n" );
fprintf( stderr, "   %d      \n", active_window->hwin_no );
fprintf( stderr, "   %d %d %d\n", verts[0].x, verts[0].y, verts[0].z_whole );
fprintf( stderr, "   %d %d %d\n", verts[1].x, verts[1].y, verts[1].z_whole );
*/

    sh_linestr( active_window->hwin_no, verts, 2 );
        
    verts[0].x = next_vertex->x >> 16;
    verts[0].y = next_vertex->y;
    verts[0].z_whole = next_vertex->z;
    verts[0].z_fract = 0;
    }
#else
void    HSstart_polyline_ifb( struct polyline_vertex *start_point )
   {
   printf( "STUB: HSstart_polyline_ifb\n" );
   }
void HScontinue_polyline_ifb( struct polyline_vertex *next_vertex )
   {
   printf( "STUB: HScontinue_polyline_ifb\n" );
   }
#endif
