
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

/*		Apoge  compliant		*/

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


/*---GET_PIXEL_COLOR------------------------------------------------------------*/

#ifdef PSUEDO_COLOR
/*get the dithered color*/
#define GET_PIXEL_COLOR( x, y, shade )	\
	HRindex_rgb(x,y,(element_parms.red*shade)>>24, \
			(element_parms.green*shade)>>24, \
			(element_parms.blue*shade)>>24); 
#else
#define GET_PIXEL_COLOR( x, y, shade )	c1
#endif

	
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
		for( x=xleft; x<=xright; x++ )					\
			{							\
			if( *zb >= rzc.active )					\
				{						\
				*zb = rzc.active;				\
				*cb = GET_PIXEL_COLOR(x,y,rsc);			\
		 		}						\
										\
			MOVE_NEXT_PIXEL						\
			}							\
		}								\
	}
	
/*---HSconstant_shade_opaque_direct------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSconstant_shade_opaque_direct( struct trapezoid *tile )
#else
	void HSconstant_shade_opaque_direct( tile )

	struct trapezoid	*tile;	/*  trapezoids data  */
#endif

	{
	int			rxa, rxb, dxa, dxb;		

#ifdef PSUEDO_COLOR
	int			rsc;
#endif

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

#ifdef PSUEDO_COLOR
	rsc = (tile->shade0) << 16;
#else
	c1 = element_parms.color + 
		(((tile->shade0 ^ 0xff) * tiling_parms.apparent_shades ) >> 8 );
#endif
	
	CALC_DXDY_DZDY
		
	y = tile->yb;
	
	CHECK_BRIGHT_TOP_BOTTOM
	MOVE_TO_NEXT_ROW
	
	for( y++; y < tile->ya; y++ )
		{
		INIT_Z_VARIABLES
		INIT_X_VARIABLES
		CALC_DZ_DX
		
		CALC_BUFFER_ADDRESSES
		
		x = xleft;
			
		CHECK_BRIGHT_EDGES( x )
		
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

			if( *zb >= rzc.active )
				{
				*zb = rzc.active;
				*cb = GET_PIXEL_COLOR( x, y, rsc );
				}
	
			MOVE_NEXT_PIXEL
			}
	
		if( x == xright ) CHECK_BRIGHT_EDGES( x )

		MOVE_TO_NEXT_ROW				
		}
		
	if( y <= tile->ya )	
		CHECK_BRIGHT_TOP_BOTTOM
	}

