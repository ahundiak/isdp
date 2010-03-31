
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

#include <stdlib.h>
#include <stdio.h>

#if defined( ENV5 )
#include "gpipe.h"
#include "EG.h"
#endif

#include "igrtypedef.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"

#define DEBUG    0
#define POINT_SIZE    3    
#define ZERO_TOL    0.00001


/*---HSdraw_point_ROP--------------------------------------------------------------*/

/*
NAME
    HSdraw_point_ROP
    
DESCRIPTION
    Given the vertex of a point, enter the point into the
    image buffer
    
GLOBALS
    element_parms
    active_window
    
HISTORY
    ??/??/??    M. Lanier
        Created
        
    2/2/93      M. Lanier
        WL Converted
        
*/

void HSdraw_point_ROP( point )

struct polyline_vertex    *point;

    {
    int                offset;
    
    register HSzbuf    *zb;
    register HScbuf    *cb;
    
    int                x, y;
    
    int                x0, y0;
    int                x1, y1;

    int                point_size;

#   if DEBUG
    printf( "HSdraw_point_ROP\n" );
    printf( "   point --- %d %d %d\n", point->x, point->y, point->z );
#   endif

    point_size = element_parms.visible_weight;

    if (point_size < POINT_SIZE) point_size = POINT_SIZE;

    x0 = (point->x >> 16) - (point_size / 2);
    y0 =  point->y        - (point_size / 2);
        
    x1 = x0 + point_size;
    y1 = y0 + point_size;
        
    if( point->x < active_window->x_min ) active_window->x_min = x0 << 16;
    if( point->x > active_window->x_max ) active_window->x_max = x1 << 16;
            
    if( point->y < active_window->y_min ) active_window->y_min = y0;
    if( point->y > active_window->y_max ) active_window->y_max = y1;
            
    for( y=y0; y<=y1; y++ )
        {
        zb = active_window->zbuf + (offset = y * active_window->x_dits + x0);
        cb = active_window->cbuf + offset;
            
        for( x=x0; x<=x1; x++ )
            {
            if( *zb >= point->z )
                {
                *zb = element_parms.delete ?
                    HS_BACKGROUND_Z : point->z;
    
                *cb = element_parms.color;
                }
                    
            cb++;
            zb++;
            }
        }
    }

/*---HSdraw_point_IFB--------------------------------------------------------------*/

void HSdraw_point_IFB( struct polyline_vertex  *point )

	{
	}	

