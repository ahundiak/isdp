/*
	I/STRUCT
*/
#include <stdio.h>
#include <math.h>
#include <FI.h>
#include "vs.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "VX_FIproto.h"
#include "vsformproto.h"
/*----------------------------------------------------------------------------*/
int VSf_fit_list( form, gadgets, num_gadgets, x1, y1, x2, y2 )

char		*form ;
int		*gadgets,
		num_gadgets,
		x1,
		y1,
		x2,
		y2 ; {

	/*
	 * This function fits all gadgets in list inside a given area
	 * ( x1,y1 = upper left corner of area, x2,y2 = lower right corner
	 * of area ).
	 */
	int		rc,
			i,
			xmin,
			ymin,
			xmax,
			ymax,
			xmin_tmp,
			ymin_tmp,
			xmax_tmp,
			ymax_tmp,
			width,
			height,
			tmp,
			attr ;
	double		xorg_d,
			yorg_d,
			width_d,
			height_d,
			xmin_tmp_d,
			ymin_tmp_d,
			delta_x,
			delta_y,
			delta ;


#define ROUND( x )\
	((x) - floor( (x) ) >= 0.5 ? ceil( (x) ) : floor( (x) ))

	delta = 0. ;

	/*
	 * Check given area.
	 */
	if( x1 > x2 ) { tmp=x1; x1=x2; x2=tmp; }
	if( y1 > y2 ) { tmp=y1; y1=y2; y2=tmp; }

	/*
	 * Retrieve the smallest and the biggest x and y.
	 */
	rc = VSg_get_layout( form, gadgets[0], &xmin, &ymin, &xmax, &ymax ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	xmax += xmin ;
	ymax += ymin ;

	for( i=1; i<num_gadgets; i++ ) {
		rc = VSg_get_layout( form, gadgets[i], &xmin_tmp, &ymin_tmp,
				     &xmax_tmp, &ymax_tmp ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

		xmax_tmp += xmin_tmp ;
		ymax_tmp += ymin_tmp ;

		if( xmin_tmp > xmax_tmp ) {
			tmp	 = xmin_tmp ;
			xmin_tmp = xmax_tmp ;
			xmax_tmp = tmp ;
		}

		if( ymin_tmp > ymax_tmp ) {
			tmp	 = ymin_tmp ;
			ymin_tmp = ymax_tmp ;
			ymax_tmp = tmp ;
		}

		if( xmin_tmp < xmin ) xmin = xmin_tmp ;
		if( ymin_tmp < ymin ) ymin = ymin_tmp ;
		if( xmax_tmp > xmax ) xmax = xmax_tmp ;
		if( ymax_tmp > ymax ) ymax = ymax_tmp ;
	}

	/*
	 * Adjust area to fit.
	 */
	x1 += 5 ;
	y1 += 5 ;
	x2 -= 5 ;
	y2 -= 5 ;

	/*
	 * Adjust size and location of all gagdets.
	 */
	delta_x = ( double ) ( x2 - x1 ) / ( xmax - xmin ) ;
	delta_y = ( double ) ( y2 - y1 ) / ( ymax - ymin ) ;

	if( delta_x > delta_y ) delta = delta_y ;
	else			delta = delta_x ;

	xorg_d = x1 + (( x2 - x1 ) - ( xmax - xmin ) *delta ) *0.5 ;
	yorg_d = y1 + (( y2 - y1 ) - ( ymax - ymin ) *delta ) *0.5 ;

	for( i=0; i<num_gadgets; i++ ) {
		rc = FIg_get_attr( form, gadgets[i], &attr ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

		if( !( attr & FI_NOT_DISPLAYED ) )
			FIg_erase( form, gadgets[i] ) ;

		rc = VSg_get_layout( form, gadgets[i], &xmin_tmp, &ymin_tmp,
				     &width, &height ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

		width_d    = width  * delta ;
		height_d   = height * delta ;
		xmin_tmp_d = xorg_d + (xmin_tmp - xmin) * delta ;
		ymin_tmp_d = yorg_d + (ymin_tmp - ymin) * delta ;

		xmin_tmp = ROUND( xmin_tmp_d ) ;
		ymin_tmp = ROUND( ymin_tmp_d ) ;
		width	 = ROUND( width_d    ) ;
		height	 = ROUND( height_d   ) ;

		rc = VSg_set_layout( form, gadgets[i], xmin_tmp, ymin_tmp,
				     width, height ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

		if( !( attr & FI_NOT_DISPLAYED ) )
			FIg_display( form, gadgets[i] ) ;
	}

	wrapup :
		return rc ;

} /* VSf_fit_list */
/*----------------------------------------------------------------------------*/
