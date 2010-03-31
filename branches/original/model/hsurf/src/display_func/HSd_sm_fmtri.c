
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

/*		Apogee coompliant		*/

extern int fixed_divide (int, int, int *, int *, int *);

/*#include "hsurf_import.h"*/
#include "stdlib.h"
#include "igrtypedef.h"
#include "wl.h"
#include "hsmath.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HSd_macramp.h"
#include "igecolordef.h"

/*#include "cmmac.h"*/

/*---GET_PIXEL_COLOR------------------------------------------------------------*/

#define GET_PIXEL_COLOR( x, y, color )	\
	IGErgb_to_index( x, y, (color[0] >> 16), (color[1] >> 16), (color[2] >> 16), (cb) ); 

#define yGET_PIXEL_COLOR( x, y, color, cb )	\
	(cb) = IGErgb_to_index( x, y, (color[0] >> 16), (color[1] >> 16), (color[2] >> 16), (cb) ); 

#define zGET_PIXEL_COLOR( x, y, color, cb )	\
	IGErgb_to_index_perf( x, y, (color[0] >> 16), (color[1] >> 16), (color[2] >> 16), (cb) ); 

/*---FILL_UP--------------------------------------------------------------------*/

#define FILL_UP( y )								\
										\
	{									\
	if( rxb < rxa && ((y)-1) != trap->ya )					\
		{								\
	 	if( (dxc = rxa - rxb) == 0 )					\
			{							\
			dsc[0] = dsc[1] = dsc[2] = 0;				\
										\
			rzc.sign = 1;						\
			rzc.d_whole = 0;					\
			rzc.d_fract = 0;					\
			}							\
		else								\
			{							\
			dsc[0] = ( rsa[0] - rsb[0] ) / dxc;			\
			dsc[1] = ( rsa[1] - rsb[1] ) / dxc;			\
			dsc[2] = ( rsa[2] - rsb[2] ) / dxc;			\
										\
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
		zb = active_window->zbuf +					\
			(offset = (y) * active_window->x_dits + xleft);		\
		cb = active_window->cbuf + offset;				\
										\
		rsc[0] = rsb[0];							\
		rsc[1] = rsb[1];							\
		rsc[2] = rsb[2];							\
										\
		for( x=xleft; x<=xright; x++ )					\
			{							\
			if( *zb >= rzc.active )					\
				{						\
				*zb = rzc.active;				\
				*cb = GET_PIXEL_COLOR( x, y, rsc )		\
		 		}						\
										\
			MOVE_NEXT_PIXEL_SHADE_FEM_MESH					\
			}							\
		}								\
	}
	

/*

NAME
   HSsmooth_shade_fem_tritrap

DESCRIPTION
   This function does the rasterizing for the fem triangle.  It was decided
   that this method would not be used for now by fem, but am leaving in case 
   they change their mind.  Constant shading has not been implemented, but 
   sending in the same color values into the 3 corners will implement that.
   By using the compile switch PSUEDO_TRUE_COLOR_FEM_MESH HStil_driver.C will
   emulate the triangle for testing.  Simply place polygon triangles and it
   will use these 3 points as data and stick in colors at the corners.

PARAMETERS
   trap   (IN)    the trapezoid

GLOBALS USED

NOTES
   The format for the triangle is to send in an rgb value with the 3 points of
   the triangle. 
  
HISTORY
   07/28/92   Joel D. Underwood
      Creation Date
*/ 
void HSsmooth_shade_fem_tritrap( trap )

struct hsfem_tritrap	*trap;	/*  trapezoids data  */

	{
	int			rxa, rxb, dxa, dxb;
	int			rsa[3], rsb[3], dsa[3], dsb[3];
						
	int			new_color_entry,cb_red,cb_green,cb_blue;
					
	int			dxc;		
	int			rsc[3], rsd[3], dsc[3];	
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

	rsa[0] = trap->shade2[0] << 16;rsa[1] = trap->shade2[1] << 16;rsa[2] = trap->shade2[2] << 16;
	rsb[0] = trap->shade3[0] << 16;rsb[1] = trap->shade3[1] << 16;rsb[2] = trap->shade3[2] << 16;
	rsc[0] = trap->shade0[0] << 16;rsc[1] = trap->shade0[1] << 16;rsc[2] = trap->shade0[2] << 16;
	rsd[0] = trap->shade1[0] << 16;rsd[1] = trap->shade1[1] << 16;rsd[2] = trap->shade1[2] << 16;

	CALC_DXDY_DZDY_DSDY_FEM_MESH	
	
	y = trap->yb;
	
	CHECK_BRIGHT_TOP_BOTTOM_SHADE_FEM_MESH
	MOVE_TO_NEXT_ROW_SHADING_FEM_MESH
	
	for( y++; y < trap->ya; y++ )
		{
		INIT_SHADE_VARIABLES_FEM_MESH
		INIT_Z_VARIABLES
		INIT_X_VARIABLES

		CALC_DZ_DX
		CALC_DSHADE_DX_FEM_MESH

		CALC_BUFFER_ADDRESSES
		
		CHECK_BRIGHT_EDGES( xleft )

		MOVE_NEXT_PIXEL_SHADE_FEM_MESH
		
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
				*cb = GET_PIXEL_COLOR( x, y, rsc )
 				}
	
			MOVE_NEXT_PIXEL_SHADE_FEM_MESH
			}

		if( x == xright ) CHECK_BRIGHT_EDGES( x )
	
		MOVE_TO_NEXT_ROW_SHADING_FEM_MESH		
		}
		
	if( y <= trap->ya )	
		CHECK_BRIGHT_TOP_BOTTOM_SHADE_FEM_MESH
	}
