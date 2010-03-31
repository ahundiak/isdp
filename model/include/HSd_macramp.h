
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:56 $
$Locker:  $
*/

/*  These macros are only good if we are using the ramp rasterizers  */

#ifndef HSd_macramp_include
#define HSd_macramp_include 1

/*
 *  Macros for the HSURF 'ramp' rasterizer functions
 */
 

#define RASTERIZER_VARIABLES							\
										\
	int			rxa, rxb, dxa, dxb;				\
	int			rsa, rsb, dsa, dsb;				\
										\
	int			shade, c1, c2, new_color_entry;			\
	char			dither;						\
										\
	int			dxc, dxd;					\
	int			rsc, rsd, dsc;					\
	int			dx, dy, ds;					\
										\
	int			offset;						\
										\
	struct HSfixedpt	rza, rzb, rzc;					\
										\
	register int		x, y;						\
	register int		xleft, xright;					\
										\
	register HSzbuf		*zb;						\
	register HScbuf		*cb;


#define FEM_VARIABLES								\
										\
	int			rua, rub, ruc, dua, dub, duc;			\
	int			rva, rvb, rvc, dva, dvb, dvc;			\
	int			scaled_intensity;				\
	int			fdx, fd2x, fdy, fd2y;				\


/*---TRANSLUCENT----------------------------------------------------------------*/

/*
 *  Perform the translucency test.  Will work for both wide and narrow spacing.
 *  In the wide case, uses the pattern buffer, trans_pat6.  For narrow spacing
 *  we exclusive or the x and y value, look at the first bit, and if it is
 *  set, turn the pixel on.
 */
 
#define TRANSLUCENT( x, y )	(						\
				((tiling_parms.processing_mode & HS_PMODE_TRANS_1x1) ?	\
				 ((x ^ y) & 1) : (!trans_pat6[y%6][x%6]))	\
				)
				

/*---INIT_Z_VARIABLES-----------------------------------------------------------*/

/*
 *  Before interpolating from left to right on a trapezoid scanline, we
 *  initialize a third set of z values equal to the value of the left most
 *  edge of the trapezoid at the given scanline.  We do this wo we can
 *  maintain the edge values while interpolating between
 */
 
#define INIT_Z_VARIABLES							\
										\
	{									\
	rzc.active = rza.active;						\
	rzc.running = rza.running;						\
	}									\

	
/*---INIT_X_VARIABLES-----------------------------------------------------------*/

/*
 *  Establish the value of x at the endpoints of a scanline.  When interpolating
 *  from top to bottom of a trapezoid, the x's are maintained in a <16:16>
 *  format to maximize precision, therefore, the values have to be shifted 16
 *  to the right to get the whole value of x
 */

#define INIT_X_VARIABLES							\
										\
	{									\
	xleft = rxa >> 16;		 					\
	xright = rxb >> 16;							\
	}

	
/*---INIT_SHADE_VARIABLES-------------------------------------------------------*/

/*
 *  Before interpolating from left to right on a trapezoid scanline, we
 *  initialize a third set of shade values equal to the value of the left most
 *  edge of the trapezoid at the given scanline.  We do this wo we can
 *  maintain the edge values while interpolating between
 */
 
#define INIT_SHADE_VARIABLES							\
										\
	{									\
	rsc = rsa;								\
	}									\

#define INIT_SHADE_VARIABLES_FEM_MESH						\
										\
	{									\
	rsc[0] = rsa[0];rsc[1] = rsa[1];rsc[2] = rsa[2];			\
	}									\


/*---CALC_DZ_DX-----------------------------------------------------------------*/

/*
 *  Calculate the change in z with respect to x for rasterizing horizonal
 *  scanline.  Use the fixed point functions for z interpolation
 */
 
#define CALC_DZ_DX								\
										\
	{									\
	if( (dxc = xright - xleft) == 0 )					\
		{								\
		rzc.sign = 1;							\
		rzc.d_whole = 0;						\
		rzc.d_fract = 0;						\
		}								\
	else									\
		{								\
		fixed_divide(	(rzb.active - rza.active),			\
				dxc, 						\
				&rzc.sign, 					\
				&rzc.d_whole, 					\
				&rzc.d_fract );					\
		}								\
	}


/*---CALC_DSHADE_DX-------------------------------------------------------------*/

/*
 *  Calculate the change in shade with respect to x for rasterizing horizonal
 *  scanline.
 */

#define CALC_DSHADE_DX								\
										\
	{									\
	if( (dx = xright - xleft) == 0 )					\
		{								\
		dsc = 0;							\
		}								\
	else									\
		{								\
		dsc = ( rsb - rsc ) / dx;					\
		}								\
	}
	
#define CALC_DSHADE_DX_FEM_MESH							\
										\
	{									\
	if( (dx = xright - xleft) == 0 )					\
		{								\
		dsc[0] = dsc[1] = dsc[2] = 0;					\
		}								\
	else									\
		{								\
		dsc[0] = ( rsb[0] - rsc[0] ) / dx;				\
		dsc[1] = ( rsb[1] - rsc[1] ) / dx;				\
		dsc[2] = ( rsb[2] - rsc[2] ) / dx;				\
		}								\
	}
	

/*---CALC_FEM_DX---------------------------------------------------------------*/

/*
 *  Calculate the forward differences for percent for this scan line.
 */

#define CALC_FEM_DX								\
										\
	{									\
	if (element_parms.fem_parms.triangle)					\
		{  /* if triangle, use traditional shade interpolation */	\
		CALC_DSHADE_DX							\
		fd2x = 0;							\
		fdx = dsc << 8;							\
		}								\
	else									\
		{								\
		if( (dx = xright - xleft) == 0 )				\
			{							\
			duc = 0;						\
			dvc = 0;						\
			fd2x = 0;						\
			fdx = 0;						\
			}							\
		else								\
			{							\
			duc = ( rub - rua ) / dx;				\
			dvc = ( rvb - rva ) / dx;				\
			fd2x = 2 * element_parms.fem_parms.B * duc * dvc;	\
			fdx =	(element_parms.fem_parms.A * dvc) +		\
				(element_parms.fem_parms.C * duc) +		\
				(element_parms.fem_parms.B * duc * dvc) +	\
				(element_parms.fem_parms.B * dvc * rua) +	\
				(element_parms.fem_parms.B * duc * rva);	\
			if (fdx < 0) fdx += 255;				\
			if (fd2x < 0) fd2x += 255;				\
			fdx -= fd2x;						\
/***										\
fprintf(stderr, "FDX=%d, FD2X=%d, dx=%d\n", fdx, fd2x, dx);			\
fprintf(stderr, " duc=%d, rua=%d, rub=%d, dvc=%d, rva=%d, rvb=%d\n",		\
	duc, rua, rub, dvc, rva, rvb);						\
fprintf(stderr, " rsc=%d (%d) (s=%d), last=%d (s=%d)\n",			\
	rsc, rsc>>16, rsc>>20, (rsc + (dx * (fdx>>8))),				\
	(rsc + (dx * (fdx>>8)))>>20);						\
***/										\
			}							\
		}								\
	}
	

/*---CALC_BUFFER_ADDRESSES------------------------------------------------------*/

/*
 *  Calculate the address in the z and color buffer of the left most pixel of 
 *  the current row
 */

#define CALC_BUFFER_ADDRESSES							\
										\
	{									\
	zb = active_window->zbuf +						\
		(offset = y * active_window->x_dits + xleft);			\
	cb = active_window->cbuf + offset;					\
	}
		

/*---MIN_MAX_TEST--------------------------------------------------------------*/

/*
 *  Perform min/max test on the x and y coordinates of the trapezoid.
 */
	 
#define MIN_MAX_TEST								\
										\
	{									\
	if (trap->x0 < active_window->x_min) active_window->x_min = trap->x0;	\
	if (trap->x1 > active_window->x_max) active_window->x_max = trap->x1;	\
        if (trap->x2 < active_window->x_min) active_window->x_min = trap->x2;	\
	if (trap->x3 > active_window->x_max) active_window->x_max = trap->x3;	\
										\
	if (trap->yb < active_window->y_min) active_window->y_min = trap->yb;	\
	if (trap->ya > active_window->y_max) active_window->y_max = trap->ya;	\
	}

/*---MOVE_TO_NEXT_ROW(_SHADING)(_FEM)------------------------------------------*/

/*
 *  After having completed rasterizing a scanline, compute the starting and
 *  ending x, z and shade of the next scanline.  Fill up in called to fill
 *  any holes caused by large steps in x.  Three macros are maintained here
 *  because some rasterizes dont need a shade, and therefore only need to
 *  compute the x and z of the next scanline, while others need FEM.
 */
 
#define MOVE_TO_NEXT_ROW							\
										\
	{									\
	rxa += dxa;								\
	Fixed_add( rza );							\
										\
	FILL_UP ( (y+1) )							\
										\
	rxb += dxb;								\
	Fixed_add( rzb );							\
	}
	
#define MOVE_TO_NEXT_ROW_SHADING						\
										\
	{									\
	rxa += dxa;								\
	rsa += dsa;								\
	Fixed_add( rza );							\
										\
	FILL_UP ( (y+1) )							\
										\
	rxb += dxb;								\
	rsb += dsb;								\
	Fixed_add( rzb );							\
	}
	
#define MOVE_TO_NEXT_ROW_SHADING_FEM_MESH					\
										\
	{									\
	rxa += dxa;								\
	rsa[0] += dsa[0];							\
	rsa[1] += dsa[1];							\
	rsa[2] += dsa[2];							\
	Fixed_add( rza );							\
										\
	FILL_UP ( (y+1) )							\
										\
	rxb += dxb;								\
	rsb[0] += dsb[0];							\
	rsb[1] += dsb[1];							\
	rsb[2] += dsb[2];							\
	Fixed_add( rzb );							\
	}

#define MOVE_TO_NEXT_ROW_FEM							\
										\
	{									\
	if (element_parms.fem_parms.triangle)					\
		{  /* if triangle, use traditional shade interpolation */	\
		MOVE_TO_NEXT_ROW_SHADING					\
		}								\
	else									\
		{								\
		rxa += dxa;							\
		rua += dua;							\
		rva += dva;							\
		Fixed_add( rza );						\
										\
		fdy += fd2y;							\
		rsa += fdy >> 8;						\
										\
		FILL_UP ( (y+1) )						\
										\
		rxb += dxb;							\
		rub += dub;							\
		rvb += dvb;							\
		Fixed_add( rzb );						\
		}								\
	}
	

/*---MOVE_NEXT_PIXEL(_DITHER)(_SHADE)(_FEM)------------------------------------*/

/*
 *  compute the z, ( dither or shade) of the next pixel in the scanline
 */
 
#define MOVE_NEXT_PIXEL								\
										\
	{									\
	Fixed_add( rzc );							\
										\
	zb++;									\
	cb++;									\
	}

#define MOVE_NEXT_PIXEL_DITHER							\
										\
	{									\
	Fixed_add( rzc );							\
										\
	zb++;									\
	cb++;									\
										\
	dither = CSHIFT( dither );						\
	}

#define MOVE_NEXT_PIXEL_SHADE							\
										\
	{									\
	rsc += dsc;								\
										\
	Fixed_add( rzc );							\
										\
	zb++;									\
	cb++;									\
	}

#define MOVE_NEXT_PIXEL_SHADE_FEM_MESH						\
										\
	{									\
	rsc[0] += dsc[0];							\
	rsc[1] += dsc[1];							\
	rsc[2] += dsc[2];							\
										\
	Fixed_add( rzc );							\
										\
	zb++;									\
	cb++;									\
	}

#define MOVE_NEXT_PIXEL_FEM							\
										\
	{									\
	fdx += fd2x;								\
	rsc += fdx >> 8;							\
										\
	Fixed_add( rzc );							\
										\
	zb++;									\
	cb++;									\
	}


/*---MOVE_BACKWARDS------------------------------------------------------------*/

/*
 * Move backwards from 'from' to 'to' considering both the z/color buffer addresses
 * and the active z value of the current scan line.
 */

#define MOVE_BACKWARDS( from, to )						\
										\
	{									\
	int NonUsedCounter;							\
										\
	for (NonUsedCounter = to; NonUsedCounter < from; NonUsedCounter++)	\
		{								\
		Fixed_subtract( rzc )						\
		zb--;								\
		cb--;								\
		}								\
	}


/*---CHECK_BRIGHT_EDGES--------------------------------------------------------*/

/*
 *  These macros check for bright edges.  A bright edge occurs when you have
 *  two trapezoids who share the same edge, and the darker hides the brighter
 *  and the brighter is rasterized after the darker.  The solution is that
 *  when two trapezoids are within a tolerance of each other on a given pixel
 *  you save the z of the closer but display the color of the darker.  The
 *  algorithm is designed to attempt to keep this within the shades of the 
 *  same base color.
 */
 
#define CHECK_BRIGHT_EDGES( x )							\
										\
	{									\
	if( *zb >= rzc.active )							\
		{								\
		new_color_entry = GET_PIXEL_COLOR( x, y, rsc );			\
										\
		if( (*zb - rzc.active) <= 1 )					\
			{							\
			ds = *cb - new_color_entry;				\
			if( ds < 0 || ds >= tiling_parms.number_shades )	\
				*cb = new_color_entry;				\
			}							\
		else								\
			*cb = new_color_entry;					\
										\
		*zb = rzc.active;						\
 		}								\
	else									\
		{								\
		new_color_entry = GET_PIXEL_COLOR( x, y, rsc );			\
										\
		if( (rzc.active - *zb) <= 1 )					\
			{							\
			ds = *cb - new_color_entry;				\
			if( ds < 0 || ds >= tiling_parms.number_shades )	\
				*cb = new_color_entry;				\
			}							\
		}								\
	}

#define CHECK_BRIGHT_EDGES_TRANS( x )						\
										\
	{									\
	if( TRANSLUCENT( x, y ) )						\
	if( *zb >= rzc.active )							\
		{								\
		new_color_entry = GET_PIXEL_COLOR( x, y, rsc );			\
										\
		if( (*zb - rzc.active) <= 1 )					\
			{							\
			ds = *cb - new_color_entry;				\
			if( ds < 0 || ds >= tiling_parms.number_shades )	\
				*cb = new_color_entry;				\
			}							\
		else								\
			*cb = new_color_entry;					\
										\
		*zb = rzc.active;						\
 		}								\
	else									\
		{								\
		new_color_entry = GET_PIXEL_COLOR( x, y, rsc );			\
										\
		if( (rzc.active - *zb) <= 1 )					\
			{							\
			ds = *cb - new_color_entry;				\
			if( ds < 0 || ds >= tiling_parms.number_shades )	\
				*cb = new_color_entry;				\
			}							\
		}								\
	}

/*---CHECK_BRIGHT_TOP_BOTTOM(_DITHER)(_SHADE)(_TRANS)--------------------------*/

/*
 *  For trapezoids, we always check the first and last pixel of a scanline for
 *  bright edges, but we also need to check the entire first and last scanline.
 *  This macro does that.  This macro comes in six versions, regular, with
 *  dither, and with shade, plus the above three repeated for translucency.
 */
 
#define CHECK_BRIGHT_TOP_BOTTOM							\
										\
	{									\
	INIT_Z_VARIABLES							\
	INIT_X_VARIABLES							\
	CALC_DZ_DX								\
										\
	CALC_BUFFER_ADDRESSES							\
										\
	for( x = xleft; x <= xright; x++ )					\
		{								\
										\
		/*								\
		 *  If the z of the pixel stored in the z			\
		 *  buffer is greater than or equal to the z			\
		 *  of the new pixel then the new pixel				\
		 *  replaces the old pixel in then z buffer 			\
		 *  and color buffer						\
		 */								\
										\
		CHECK_BRIGHT_EDGES( x )						\
		MOVE_NEXT_PIXEL							\
		}								\
	}

#define CHECK_BRIGHT_TOP_BOTTOM_DITHER						\
										\
	{									\
	INIT_Z_VARIABLES							\
	INIT_X_VARIABLES							\
	CALC_DZ_DX								\
										\
	CALC_BUFFER_ADDRESSES							\
										\
	dither = patterns[ xleft % 4 ][ shade ][ y % 4 ];			\
										\
	for( x = xleft; x <= xright; x++ )					\
		{								\
										\
		/*								\
		 *  If the z of the pixel stored in the z			\
		 *  buffer is greater than or equal to the z			\
		 *  of the new pixel then the new pixel				\
		 *  replaces the old pixel in then z buffer 			\
		 *  and color buffer						\
		 */								\
										\
		CHECK_BRIGHT_EDGES( x )						\
		MOVE_NEXT_PIXEL_DITHER						\
		}								\
	}

#define CHECK_BRIGHT_TOP_BOTTOM_SHADE						\
										\
	{									\
	INIT_SHADE_VARIABLES							\
	INIT_Z_VARIABLES							\
	INIT_X_VARIABLES							\
										\
	CALC_DZ_DX								\
	CALC_DSHADE_DX								\
										\
	CALC_BUFFER_ADDRESSES							\
										\
	for( x = xleft; x <= xright; x++ )					\
		{								\
										\
		/*								\
		 *  If the z of the pixel stored in the z			\
		 *  buffer is greater than or equal to the z			\
		 *  of the new pixel then the new pixel				\
		 *  replaces the old pixel in then z buffer 			\
		 *  and color buffer						\
		 */								\
										\
		CHECK_BRIGHT_EDGES( x )						\
		MOVE_NEXT_PIXEL_SHADE						\
		}								\
	}
 
#define CHECK_BRIGHT_TOP_BOTTOM_SHADE_FEM_MESH					\
										\
	{									\
	INIT_SHADE_VARIABLES_FEM_MESH						\
	INIT_Z_VARIABLES							\
	INIT_X_VARIABLES							\
										\
	CALC_DZ_DX								\
	CALC_DSHADE_DX_FEM_MESH							\
										\
	CALC_BUFFER_ADDRESSES							\
										\
	for( x = xleft; x <= xright; x++ )					\
		{								\
										\
		/*								\
		 *  If the z of the pixel stored in the z			\
		 *  buffer is greater than or equal to the z			\
		 *  of the new pixel then the new pixel				\
		 *  replaces the old pixel in then z buffer 			\
		 *  and color buffer						\
		 */								\
										\
		CHECK_BRIGHT_EDGES( x )						\
		MOVE_NEXT_PIXEL_SHADE_FEM_MESH					\
		}								\
	}
 
#define CHECK_BRIGHT_TOP_BOTTOM_TRANS						\
										\
	{									\
	INIT_Z_VARIABLES							\
	INIT_X_VARIABLES							\
	CALC_DZ_DX								\
										\
	CALC_BUFFER_ADDRESSES							\
										\
	for( x = xleft; x <= xright; x++ )					\
		{								\
										\
		/*								\
		 *  If the z of the pixel stored in the z			\
		 *  buffer is greater than or equal to the z			\
		 *  of the new pixel then the new pixel				\
		 *  replaces the old pixel in then z buffer 			\
		 *  and color buffer						\
		 */								\
										\
		CHECK_BRIGHT_EDGES_TRANS( x )					\
		MOVE_NEXT_PIXEL							\
		}								\
	}

#define CHECK_BRIGHT_TOP_BOTTOM_DITHER_TRANS					\
										\
	{									\
	INIT_Z_VARIABLES							\
	INIT_X_VARIABLES							\
	CALC_DZ_DX								\
										\
	CALC_BUFFER_ADDRESSES							\
										\
	dither = patterns[ xleft % 4 ][ shade ][ y % 4 ];			\
										\
	for( x = xleft; x <= xright; x++ )					\
		{								\
										\
		/*								\
		 *  If the z of the pixel stored in the z			\
		 *  buffer is greater than or equal to the z			\
		 *  of the new pixel then the new pixel				\
		 *  replaces the old pixel in then z buffer 			\
		 *  and color buffer						\
		 */								\
										\
		CHECK_BRIGHT_EDGES_TRANS( x )					\
		MOVE_NEXT_PIXEL_DITHER						\
		}								\
	}

#define CHECK_BRIGHT_TOP_BOTTOM_SHADE_TRANS					\
										\
	{									\
	INIT_SHADE_VARIABLES							\
	INIT_Z_VARIABLES							\
	INIT_X_VARIABLES							\
										\
	CALC_DZ_DX								\
	CALC_DSHADE_DX								\
										\
	CALC_BUFFER_ADDRESSES							\
										\
	for( x = xleft; x <= xright; x++ )					\
		{								\
										\
		/*								\
		 *  If the z of the pixel stored in the z			\
		 *  buffer is greater than or equal to the z			\
		 *  of the new pixel then the new pixel				\
		 *  replaces the old pixel in then z buffer 			\
		 *  and color buffer						\
		 */								\
										\
		CHECK_BRIGHT_EDGES_TRANS( x )					\
		MOVE_NEXT_PIXEL_SHADE						\
		}								\
	}

/*---CALC_DXDY_DZDY(_DSDY)(_FEMDY)---------------------------------------------*/

/*
 *  Calculate the delta change in the variables for a single step in y.  If the 
 *  y coordinate are equal, then set the deltas to 0.
 */

#define	CALC_DXDY_DZDY								\
										\
	{									\
	if( ( dy = trap->ya - trap->yb ) == 0 )					\
		{								\
		dxa = 0;							\
		dxb = 0;							\
										\
		rza.sign = 1;							\
		rza.d_whole = 0;						\
		rza.d_fract = 0;						\
		rza.running = 0;						\
										\
		rzb.sign = 1;							\
		rzb.d_whole = 0;						\
		rzb.d_fract = 0;						\
		rzb.running = 0;						\
		}								\
	else									\
		{								\
		dxa = ( trap->x0 - trap->x2 ) / dy;				\
		dxb = ( trap->x1 - trap->x3 ) / dy;				\
										\
		fixed_divide(	(trap->z0 - trap->z2), 				\
				dy, 						\
				&rza.sign, 					\
				&rza.d_whole, 					\
				&rza.d_fract );					\
										\
		rza.running = 0x40000000;					\
										\
		fixed_divide(	(trap->z1 - trap->z3), 				\
				dy, 						\
				&rzb.sign, 					\
				&rzb.d_whole, 					\
				&rzb.d_fract );					\
										\
		rzb.running = 0x40000000;					\
		}								\
										\
	rza.active = trap->z2;							\
	rzb.active = trap->z3;							\
										\
	rxa = trap->x2 + 32768;							\
	rxb = trap->x3 + 32768;							\
	}

#define	CALC_DXDY_DZDY_DSDY							\
										\
	{									\
	if( ( dy = trap->ya - trap->yb ) == 0 )					\
		{								\
		dxa = 0;							\
		dsa = 0;							\
										\
		dxb = 0;							\
		dsb = 0;							\
										\
		rza.sign = 1;							\
		rza.d_whole = 0;						\
		rza.d_fract = 0;						\
		rza.running = 0;						\
										\
		rzb.sign = 1;							\
		rzb.d_whole = 0;						\
		rzb.d_fract = 0;						\
		rzb.running = 0;						\
		}								\
	else									\
		{								\
		dxa = ( trap->x0 - trap->x2 ) / dy;				\
		dsa = ( rsc - rsa ) / dy;					\
										\
		dxb = ( trap->x1 - trap->x3 ) / dy;				\
		dsb = ( rsd - rsb ) / dy;					\
										\
		fixed_divide(	(trap->z0 - trap->z2), 				\
				dy, 						\
				&rza.sign, 					\
				&rza.d_whole, 					\
				&rza.d_fract );					\
										\
		rza.running = 0x40000000;					\
										\
		fixed_divide(	(trap->z1 - trap->z3), 				\
				dy, 						\
				&rzb.sign, 					\
				&rzb.d_whole, 					\
				&rzb.d_fract );					\
										\
		rzb.running = 0x40000000;					\
		}								\
										\
	rza.active = trap->z2;							\
	rzb.active = trap->z3;							\
										\
	rxa = trap->x2 + 32768;							\
	rxb = trap->x3 + 32768;							\
	}

#define	CALC_DXDY_DZDY_DSDY_FEM_MESH						\
										\
	{									\
	if( ( dy = trap->ya - trap->yb ) == 0 )					\
		{								\
		dxa = 0;							\
		dsa[0] = dsa[1] = dsa[2] = 0;					\
		dxb = 0;							\
		dsb[0] = dsb[1] = dsb[2] = 0;					\
										\
		rza.sign = 1;							\
		rza.d_whole = 0;						\
		rza.d_fract = 0;						\
		rza.running = 0;						\
										\
		rzb.sign = 1;							\
		rzb.d_whole = 0;						\
		rzb.d_fract = 0;						\
		rzb.running = 0;						\
		}								\
	else									\
		{								\
		dxa = ( trap->x0 - trap->x2 ) / dy;				\
		dsa[0] = ( rsc[0] - rsa[0] ) / dy;				\
		dsa[1] = ( rsc[1] - rsa[1] ) / dy;				\
		dsa[2] = ( rsc[2] - rsa[2] ) / dy;				\
										\
		dxb = ( trap->x1 - trap->x3 ) / dy;				\
		dsb[0] = ( rsd[0] - rsb[0] ) / dy;				\
		dsb[1] = ( rsd[1] - rsb[1] ) / dy;				\
		dsb[2] = ( rsd[2] - rsb[2] ) / dy;				\
										\
		fixed_divide(	(trap->z0 - trap->z2), 				\
				dy, 						\
				&rza.sign, 					\
				&rza.d_whole, 					\
				&rza.d_fract );					\
										\
		rza.running = 0x40000000;					\
										\
		fixed_divide(	(trap->z1 - trap->z3), 				\
				dy, 						\
				&rzb.sign, 					\
				&rzb.d_whole, 					\
				&rzb.d_fract );					\
										\
		rzb.running = 0x40000000;					\
		}								\
										\
	rza.active = trap->z2;							\
	rzb.active = trap->z3;							\
										\
	rxa = trap->x2 + 32768;							\
	rxb = trap->x3 + 32768;							\
	}

#define	CALC_DXDY_DZDY_FEMDY							\
										\
	{									\
	if (element_parms.fem_parms.triangle)						\
		{  /* if triangle, use traditional shade interpolation */	\
		CALC_DXDY_DZDY_DSDY						\
		}								\
	else									\
		{								\
		if( ( dy = trap->ya - trap->yb ) == 0 )				\
			{							\
			dxa = 0;						\
			dxb = 0;						\
			dua = 0;						\
			dub = 0;						\
			dva = 0;						\
			dvb = 0;						\
										\
			rza.sign = 1;						\
			rza.d_whole = 0;					\
			rza.d_fract = 0;					\
			rza.running = 0;					\
										\
			rzb.sign = 1;						\
			rzb.d_whole = 0;					\
			rzb.d_fract = 0;					\
			rzb.running = 0;					\
			}							\
		else								\
			{							\
			dxa = ( trap->x0 - trap->x2 ) / dy;			\
			dxb = ( trap->x1 - trap->x3 ) / dy;			\
			dua = ( (trap->u0 << 8) - (trap->u2 << 8) ) / dy;	\
			dub = ( (trap->u1 << 8) - (trap->u3 << 8) ) / dy;	\
			dva = ( (trap->v0 << 8) - (trap->v2 << 8) ) / dy;	\
			dvb = ( (trap->v1 << 8) - (trap->v3 << 8) ) / dy;	\
										\
			fixed_divide(	(trap->z0 - trap->z2), 			\
					dy, 					\
					&rza.sign, 				\
					&rza.d_whole, 				\
					&rza.d_fract );				\
										\
			rza.running = 0x40000000;				\
										\
			fixed_divide(	(trap->z1 - trap->z3), 			\
					dy, 					\
					&rzb.sign, 				\
					&rzb.d_whole, 				\
					&rzb.d_fract );				\
										\
			rzb.running = 0x40000000;				\
			}							\
										\
		rza.active = trap->z2;						\
		rzb.active = trap->z3;						\
										\
		rxa = trap->x2 + 32768;						\
		rxb = trap->x3 + 32768;						\
		rua = trap->u2 << 8;						\
		rub = trap->u3 << 8;						\
		rva = trap->v2 << 8;						\
		rvb = trap->v3 << 8;						\
										\
		fd2y = 2 * element_parms.fem_parms.B * dua * dva;			\
		fdy =	(element_parms.fem_parms.A * dva) +				\
			(element_parms.fem_parms.C * dua) +				\
			(element_parms.fem_parms.B * dua * dva) +			\
			(element_parms.fem_parms.B * dva * rua) +			\
			(element_parms.fem_parms.B * dua * rva);			\
		if (fdy < 0) fdy += 255;					\
		if (fd2y < 0) fd2y += 255;					\
		fdy -= fd2y;							\
/***										\
fprintf(stderr, "FDY=%d, FD2Y=%d, dy=%d\n", fdy, fd2y, dy);			\
fprintf(stderr, " dua=%d, u2=%d, u0=%d, dva=%d, v2=%d, v0=%d\n",		\
	dua, trap->u2, trap->u0, dva, trap->v2, trap->v0);			\
fprintf(stderr, " rsa=%d (%d) (s=%d), last=%d (s=%d)\n",			\
	rsa, rsa>>16, rsa>>20, (rsa + (dy * (fdy>>8))),				\
	(rsa + (dy * (fdy>>8)))>>20);						\
***/										\
		}								\
	}

#endif


