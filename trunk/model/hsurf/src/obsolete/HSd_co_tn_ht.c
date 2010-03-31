
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

/*		Apogee compliant		*/

#include "stdlib.h"
#include "igrtypedef.h"
#include "igr.h"

#include "hsmath.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HSd_macros.h"

#include "HSpr_display.h"

extern unsigned char trans_pat6[6][6];
extern unsigned char patterns[4][16][4];

/*---GET_PIXEL_COLOR------------------------------------------------------------*/

#define GET_PIXEL_COLOR( x, y, shade )  ( dither & 1 ) ? c1 : c2
	
/*---FILL_UP--------------------------------------------------------------------*/

#define FILL_UP( y )								\
										\
	{									\
	if( rxb < rxa && ((y)-1) != tile->ya )					\
		{								\
	 	if( (dxc = rxa - rxb) == 0 )					\
			{							\
			rzc.sign = 1;						\
			rzc.d_whole = 0;					\
			rzc.d_fract = 0;					\
			}							\
		else								\
			{							\
			fixed_divide(	(rza.active - rzb.active),		\
					dxc,					\
					&rzc.sign,				\
					&rzc.d_whole,				\
					&rzc.d_fract );				\
			}							\
										\
		rzc.running = 0x40000000;					\
		rzc.active = rzb.active;					\
										\
		xleft = rxb >> 16;						\
		xright = rxa >> 16;						\
										\
		zb = active_window->zbuf + (offset = (y) *			\
			active_window->x_dits + xleft);				\
		cb = active_window->cbuf + offset;				\
										\
		dither = patterns[ xleft % 4 ][ shade ][ y % 4 ];		\
										\
		for( x=xleft; x<=xright; x++ )					\
			{							\
			if( TRANSLUCENT( x, y ) )				\
			if( *zb >= rzc.active )					\
				{						\
				*zb = rzc.active;				\
				*cb =  GET_PIXEL_COLOR( x, y, rsc );		\
		 		}						\
										\
			MOVE_NEXT_PIXEL_DITHER					\
			}							\
		}								\
	}
	
/*---HSconstant_shade_trans_half------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSconstant_shade_trans_half( struct trapezoid *tile )
#else
	void HSconstant_shade_trans_half( tile )

	struct trapezoid	*tile;	/*  trapezoids data  */
#endif

	{
	int			rxa, rxb, dxa, dxb;		
								
	int			shade, c1, c2, new_color_entry;	
	char			dither;				
								
	int			dxc;				
	int			dy, ds;				
								
	int			offset;				
								
	struct HSfixedpt	rza, rzb, rzc;			
								
	register int		x, y;				
	register int		xleft, xright;			
								
	register HSzbuf		*zb;				
	register HScbuf		*cb;

	MIN_MAX_TEST

	shade = tile->shade0 ^ 0xff;
	
	/*
	 *  Scale the shade
	 */

	shade = ( shade * tiling_parms.apparent_shades ) >> 8;
	
	c1 = element_parms.color + (shade >> 4);
	c2 = c1 + 1;
	
	shade %= 16;
	
	CALC_DXDY_DZDY
		
	y = tile->yb;
	
	CHECK_BRIGHT_TOP_BOTTOM_DITHER_TRANS
	MOVE_TO_NEXT_ROW
	
	for( y++; y < tile->ya; y++ )
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
		
	if( y <= tile->ya )	
		CHECK_BRIGHT_TOP_BOTTOM_DITHER_TRANS
	}

