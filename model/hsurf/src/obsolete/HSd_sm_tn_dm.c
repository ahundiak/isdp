
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

/*		Apogee com[pliant		*/

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

/*---GET_PIXEL_COLOR---------------------  --------------------------------*/

#ifdef PSUEDO_COLOR
/*get dithered color*/
#define GET_PIXEL_COLOR( x, y, shade )	\
	HRindex_rgb(x,y,(element_parms.red*shade)>>24, \
			(element_parms.green*shade)>>24, \
			(element_parms.blue*shade)>>24); 
#else
#define GET_PIXEL_COLOR( x, y, shade )	\
	element_parms.color + (shade >> 16);
#endif

/*---FILL_UP------------------------------------------------------------*/

#define FILL_UP( y )							\
									\
	{								\
	if( rxb < rxa && ((y)-1) != tile->ya )				\
		{							\
	 	if( (dxc = rxa - rxb) == 0 )				\
			{						\
			dsc = 0;					\
									\
			rzc.sign = 1;					\
			rzc.d_whole = 0;				\
			rzc.d_fract = 0;				\
			}						\
		else							\
			{						\
			dsc = ( rsa - rsb ) / dxc;			\
									\
			fixed_divide(	(rza.active - rzb.active),	\
					dxc,				\
					&rzc.sign,			\
					&rzc.d_whole,			\
					&rzc.d_fract );			\
			}						\
									\
		rzc.running = 0x40000000;				\
		rzc.active = rzb.active;				\
									\
		xleft = rxb >> 16;					\
		xright = rxa >> 16;					\
									\
		zb = active_window->zbuf +				\
			(offset = (y) * active_window->x_dits + xleft);	\
		cb = active_window->cbuf + offset;			\
									\
		rsc = rsb;						\
									\
		for( x=xleft; x<=xright; x++ )				\
			{						\
			if( TRANSLUCENT( x, y ) )			\
			if( *zb >= rzc.active )				\
				{					\
				*zb = rzc.active;			\
				*cb = GET_PIXEL_COLOR( x, y, rsc );	\
		 		}					\
									\
			MOVE_NEXT_PIXEL_SHADE				\
			}						\
		}							\
	}
		
/*---HSsmooth_shade_trans_direct----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSsmooth_shade_trans_direct( struct trapezoid *tile )
#else
	void HSsmooth_shade_trans_direct( tile )

	struct trapezoid	*tile;	/*  trapezoids data  */
#endif

	{
	int			rxa, rxb, dxa, dxb;
	int			rsa, rsb, dsa, dsb;
						
	int			new_color_entry;
	int			dxc;		

	int			rsc, rsd, dsc;	
	int			dx, dy, ds;	

	int			offset;		
						
	struct HSfixedpt	rza, rzb, rzc;	
						
	register int		x, y;		
	register int		xleft, xright;	
						
	register HSzbuf		*zb;		
	register HScbuf		*cb;

	MIN_MAX_TEST

	/*
	 *  Scale the shade.  NOTE what should be done is divide by 255 and shift left 16.  
	 *  The "<< 8" implies a division by 256 and shift by 16, which has a small error.  
	 *  You could be as much as a shade off.
	 */

#ifdef PSUEDO_COLOR
	rsa = (tile->shade2)<<16;
	rsb = (tile->shade3)<<16;
	rsc = (tile->shade0)<<16;
	rsd = (tile->shade1)<<16;
#else
	rsa = ( (tile->shade2 ^ 0xff) * tiling_parms.apparent_shades ) << 8;
	rsb = ( (tile->shade3 ^ 0xff) * tiling_parms.apparent_shades ) << 8;
	rsc = ( (tile->shade0 ^ 0xff) * tiling_parms.apparent_shades ) << 8;
	rsd = ( (tile->shade1 ^ 0xff) * tiling_parms.apparent_shades ) << 8;
#endif

	CALC_DXDY_DZDY_DSDY
	
	y = tile->yb;
	
	CHECK_BRIGHT_TOP_BOTTOM_SHADE_TRANS
	MOVE_TO_NEXT_ROW_SHADING
	
	for( y++; y < tile->ya; y++ )
		{
		INIT_SHADE_VARIABLES
		INIT_Z_VARIABLES
		INIT_X_VARIABLES

		CALC_DZ_DX
		CALC_DSHADE_DX

		CALC_BUFFER_ADDRESSES

		CHECK_BRIGHT_EDGES_TRANS( xleft )

		MOVE_NEXT_PIXEL_SHADE
		
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
	
			MOVE_NEXT_PIXEL_SHADE
			}

		if( x == xright ) CHECK_BRIGHT_EDGES_TRANS( x )
	
		MOVE_TO_NEXT_ROW_SHADING		
		}
		
	if( y <= tile->ya )	
		CHECK_BRIGHT_TOP_BOTTOM_SHADE_TRANS
	}
