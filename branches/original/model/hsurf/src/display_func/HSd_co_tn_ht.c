
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

#include "stdlib.h"

/*  This function is a ramp rasterizer  */
/*  It is not WL converted  */

/*  Apogee compliant */

#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"

#include "hsmath.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HSd_macramp.h"

#include "HSpr_display.h"

extern unsigned char trans_pat6[6][6];
extern unsigned char patterns[4][16][4];

static int		shade, c1, c2, new_color_entry, c3, c4;
static char		dither;					

/*---GET_PIXEL_COLOR-------------------------------------------*/

int GET_PIXEL_COLOR( int x, int y, int shade )
   {
   int   c;

   if( (x >= 230 && x <= 250) && (y >= 100 && y <= 120) )
      c = ( dither & 1 ) ? c3 : c4;
   else
      c = ( dither & 1 ) ? c1 : c2;
      
   return(c);
   }
	
/*---FILL_UP---------------------------------------------------*/

#define FILL_UP( y )						\
								\
    {								\
    if( rxb < rxa && ((y)-1) != trap->ya ) 			\
        {							\
        if( (dxc = rxa - rxb) == 0 )				\
            {							\
            rzc.sign = 1;					\
            rzc.d_whole = 0;					\
            rzc.d_fract = 0;					\
            }							\
        else							\
            {							\
            fixed_divide( (rza.active - rzb.active),		\
                          dxc,					\
                          &rzc.sign,				\
                          &rzc.d_whole,				\
                          &rzc.d_fract );			\
            }							\
								\
        rzc.running = 0x40000000;				\
        rzc.active = rzb.active;				\
								\
        xleft = rxb >> 16;					\
        xright = rxa >> 16;					\
								\
        zb = active_window->zbuf + (offset = (y) *		\
                active_window->x_dits + xleft);			\
        cb = active_window->cbuf + offset;			\
								\
        dither = patterns[ xleft % 4 ][ shade ][ y % 4 ];	\
								\
        for( x=xleft; x<=xright; x++ )				\
            {							\
            if( TRANSLUCENT( x, y ) )				\
            if( *zb >= rzc.active )				\
                {						\
                *zb = rzc.active;				\
                *cb =  GET_PIXEL_COLOR( x, y, rsc );		\
                }						\
								\
            MOVE_NEXT_PIXEL_DITHER				\
            }							\
        }							\
    }

/*---HSconstant_shade_trans_half------------------------------*/

/*
NAME
   HSconstant_shade_trans_half
  
KEYWORDS
   RASTERIZER
   RAMPS
   
DESCRIPTION
   Given a trapezoid structure, rasterize for halftone, constant
   translucent display
   
ARGUMENTS
   trap: (IN): trapezoid structure
   
HISTORY
   ??/??/??      M. Lanier
      Created	
*/

void HSconstant_shade_trans_half( struct trapezoid *trap )


    {
    int			rxa, rxb, dxa, dxb;			
									
									
    int			dxc;					
    int			dy, ds;					
									
    int			offset;					
									
    struct HSfixedpt	rza, rzb, rzc;
									
    register int	x, y;					
    register int	xleft, xright;				
									
    register HSzbuf	*zb;					
    register HScbuf	*cb, rsc = 0;

    MIN_MAX_TEST

    shade = trap->shade0 ^ 0xff;
	
    /*
     *  Scale the shade
     */

    shade = ( shade * tiling_parms.apparent_shades ) >> 8;
	
    c1 = element_parms.color + (shade >> 4);
    c2 = c1 + 1;
    c3 = c1 + 10;
    c4 = c3 + 1;
	
    shade %= 16;

    CALC_DXDY_DZDY	
		
    y = trap->yb;
	
    CHECK_BRIGHT_TOP_BOTTOM_DITHER_TRANS
    MOVE_TO_NEXT_ROW
	
    for( y++; y < trap->ya; y++ )
        {
        INIT_Z_VARIABLES
        INIT_X_VARIABLES
        CALC_DZ_DX
		
        CALC_BUFFER_ADDRESSES
		
        dither = patterns[ xleft % 4 ][ shade ][ y % 4 ];

        CHECK_BRIGHT_EDGES_TRANS( xleft )
		
        MOVE_NEXT_PIXEL_DITHER
		
        for( x = xleft+1; x < xright; x++ )
            {

            /*
             *  If the z of the pixel stored in the z
             *  buffer is greater than or equal to the z
             *  of the new pixel then the new pixel
             *  replaces the old pixel in then z buffer 
             *  and color buffer
             */

            if( TRANSLUCENT( x, y ) )
            if( *zb >= rzc.active )
                {
                *zb = rzc.active;
                *cb = GET_PIXEL_COLOR( x, y, rsc );
                }
	
            MOVE_NEXT_PIXEL_DITHER
            }

        if( x == xright ) CHECK_BRIGHT_EDGES_TRANS( x )

        MOVE_TO_NEXT_ROW				
        }
		
    if( y <= trap->ya )	
        CHECK_BRIGHT_TOP_BOTTOM_DITHER_TRANS
    }


