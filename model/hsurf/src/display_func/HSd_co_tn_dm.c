
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

#include "stdlib.h"

/*  This function is a ramp rasterizer  */
/*  It is not WL converted  */

/*  Appoge  compliant    */

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

/*---GET_PIXEL_COLOR------------------------------------------------------------*/

#define GET_PIXEL_COLOR( x, y, shade )    c1

	
/*---FILL_UP--------------------------------------------------------------------*/

#define FILL_UP( y )                                            \
								\
    {								\
    if( rxb < rxa && ((y)-1) != trap->ya )			\
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
                           &rzc.d_whole,			\
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
                          active_window->x_dits + xleft);	\
        cb = active_window->cbuf + offset;			\
								\
        for( x=xleft; x<=xright; x++ )				\
            {							\
            if( TRANSLUCENT( x, y ) )				\
            if( *zb >= rzc.active )				\
                {						\
                *zb = rzc.active;				\
                *cb = GET_PIXEL_COLOR(x,y,rsc);			\
                }						\
								\
            MOVE_NEXT_PIXEL					\
            }							\
        }							\
    }
	
/*---HSconstant_shade_trans_direct------------------------------------------------------*/

/*
NAME
   HSconstant_shade_trans_direct
   
KEYWORDS
   RASTERIZER
   RAMPS
   
DESCRIPTION
   Given a trapezoid structure, rasterize for direct map, constant
   translucent display
   
ARGUMENTS
   trap: (IN): trapezoid structure
   
HISTORY
   ??/??/??      M. Lanier
      Created	
*/

void HSconstant_shade_trans_direct( struct trapezoid *trap )

    {
    int			rxa, rxb, dxa, dxb;		

    int			c1, new_color_entry;	
    int			dxc;				
    int			dy, ds;				
								
    int			offset;				
								
    struct HSfixedpt	rza, rzb, rzc;			
								
    register int		x, y;				
    register int		xleft, xright;			
								
    register HSzbuf		*zb;				
    register HScbuf		*cb;

    MIN_MAX_TEST

    /*
     *  Scale the shade
     */

    c1 = element_parms.color + 
            (((trap->shade0 ^ 0xff) * tiling_parms.apparent_shades ) >> 8 );
	
    CALC_DXDY_DZDY
		
    y = trap->yb;
	
    CHECK_BRIGHT_TOP_BOTTOM_TRANS
    MOVE_TO_NEXT_ROW
	
    for( y++; y < trap->ya; y++ )
        {
        INIT_Z_VARIABLES
        INIT_X_VARIABLES
        CALC_DZ_DX
		
        CALC_BUFFER_ADDRESSES
	
        x = xleft;
			
        CHECK_BRIGHT_EDGES_TRANS( x )
		
        MOVE_NEXT_PIXEL
		
        for( x = xleft+1; x < xright; x++ )
            {

            /*
             *  If the z of the pixel stored in the z
             *  buffer is greater than or equal to the z
             *  of the new pixel then the new pixel
             *  replaces the old pixel in then z buffer 
             *  and color buffer
             */

            if( TRANSLUCENT( x, y ))
            if( *zb >= rzc.active )
                {
                *zb = rzc.active;
                *cb = GET_PIXEL_COLOR( x, y, rsc );
                }
	
            MOVE_NEXT_PIXEL
            }
	
        if( x == xright ) CHECK_BRIGHT_EDGES_TRANS( x )

        MOVE_TO_NEXT_ROW				
        }
		
    if( y <= trap->ya )	
        CHECK_BRIGHT_TOP_BOTTOM_TRANS
    }


