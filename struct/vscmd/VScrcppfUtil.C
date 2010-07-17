/*
	I/STRUCT
*/
#include <stdio.h>
#include <FI.h>
#include <FIdyn.h>
#include "exmacros.h"
#include "griomacros.h"
#include "vscmd.h"
#include "vssectiondef.h"
#include "vsxsfrpldef.h"
#include "vsxsfrpl.h"
#include "vsiomacros.h"
#include "vsformdef.h"
#include "vsformmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "VX_FIproto.h"
#include "vsformproto.h"
#include "vsioproto.h"

extern int VSg_create_line() ;
/*----------------------------------------------------------------------------*/
int VSadjustPlateNumber( form, plate, number )

char	*form ;
int	plate,
	number ; {

	/*
	 * This function set the gadget 'number' in the middle of the
	 * gadget 'plate'.
	 */
	int	rc,
		x_p, y_p, w_p, h_p, x_n, y_n, w_n, h_n ;

	SetProc( VSadjustPlateNumber ); Begin

	rc = VSg_get_layout( form, plate,  &x_p, &y_p, &w_p, &h_p ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	rc = VSg_get_layout( form, number, &x_n, &y_n, &w_n, &h_n ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	x_n = x_p + w_p / 2 - w_n / 2 ;
	y_n = y_p + h_p / 2 - h_n / 2 ;

	rc = FIg_set_location( form,
			       number,
			       x_n,
			       y_n ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	wrapup :
	End
	return rc ;

} /* VSadjustPlateNumber */
/*----------------------------------------------------------------------------*/
int VSgetPlateLines( form, plate, top, bot, lef, rgh )

char	*form ;
int	plate,
	*top,
	*bot,
	*lef,
	*rgh ; {

	/*
	 * This function retrieve the gadget line which are on top, bottom,
	 * left and right of plate.
	 */
	int	rc,
		x1_p, y1_p, x2_p, y2_p,
		num_gadgets,
		*gadgets = NULL ;

	SetProc( VSgetPlateLines ); Begin

	*top = *bot = *lef = *rgh = plate ;

	/*
	 * Retrieve all lines of plates.
	 */
	rc = VSg_get_layout( form, plate, &x1_p, &y1_p, &x2_p, &y2_p ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	x2_p += x1_p ;
	y2_p += y1_p ;

	rc = FIf_find_by_area( form, plate, x1_p, y1_p, x2_p, y2_p,
			       &num_gadgets, &gadgets ) ;
	if( (rc != FI_SUCCESS) || (num_gadgets != 4) ) goto wrapup ;

	/*
	 * The first gadget in the list is the first gadget added to the group.
	 * So set the four lines composing the plate.
	 */
	*top = gadgets[0] ;
	*bot = gadgets[1] ;
	*lef = gadgets[2] ;
	*rgh = gadgets[3] ;

	wrapup :
		__DBGpr_int( "Lines of plate", plate ) ;
		__DBGpr_int( "Top	", *top ) ;
		__DBGpr_int( "Bottom	", *bot ) ;
		__DBGpr_int( "Left	", *lef ) ;
		__DBGpr_int( "Right	", *rgh ) ;

		_FREE( gadgets ) ;

		End
		return rc ;

} /* VSgetPlateLines */
/*----------------------------------------------------------------------------*/
int VSgetPlateSide( form, plate, plate_number, side, line )

char	*form ;
int	plate,
	plate_number,
	side,
	*line ; {

	/*
	 * This function returns the line gadget corresponding of side
	 * (top, bottom, etc.. ) of plate.
	 */
	int	rc,
		top,
		bot,
		lef,
		rgh ;

	SetProc( VSgetPlateSide ); Begin

	/*
	 * Find gadget lines of plate.
	 */
	rc = VSgetPlateLines( form,
			      plate + plate_number,
			      &top,
			      &bot,
			      &lef,
			      &rgh ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	switch( side ) {
		case VS_K_TOP		:
			__DBGpr_com( "Side is TOP"    ) ;
			*line = top ;
			break ;
		case VS_K_BOTTOM	:
			__DBGpr_com( "Side is BOTTOM" ) ;
			*line = bot ;
			break ;
		case VS_K_RIGHT 	:
			__DBGpr_com( "Side is RIGHT"  ) ;
			*line = rgh ;
			break ;
		case VS_K_LEFT		:
			__DBGpr_com( "Side is LEFT"   ) ;
			*line = lef ;
			break ;
		default 		:
			__DBGpr_com( "Side not found" ) ;
			*line = -1 ;
			rc    = FI_NO_SUCH_GROUP ;
			break ;
	}

	wrapup :
	End
	return rc ;

} /* VSgetPlateSide */
/*----------------------------------------------------------------------------*/
int VSsetPlateSize( form, plate, orientation, thickness, widthOrHeight, scale )

char	*form ;
int	plate,
	orientation ;
double	thickness,
	widthOrHeight,
	scale ; {

	/*
	 * This function set the plate size according to the plate orientation :
	 *
	 *	- Horizontal plate : width  = widthOrHeight * scale
	 *			     height = thickness * scale
	 *
	 *	- Vertical plate   : width  = thickness * scale
	 *			     height = widthOrHeight * scale
	 *
	 */

	int	rc,
		top,
		bot,
		lef,
		rgh,
		x_p, y_p, w_p, h_p ;
	double	w_p_d,
		h_p_d ;

	SetProc( VSsetPlateSize ); Begin

	/*
	 * Retrieve the four lines definning the plate.
	 */
	rc = VSgetPlateLines( form, plate, &top, &bot, &lef, &rgh ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Retrieve 'location' of plate.
	 */
	rc = FIg_get_location( form, plate, &x_p, &y_p ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Compute width and height of plate with respect to plate orientation.
	 */
	__DBGpr_dbl( "Thickness     ", thickness     ) ;
	__DBGpr_dbl( "Width / Height", widthOrHeight ) ;

	switch( orientation ) {
		default			: /* Should not get here */
		case VS_K_HORIZONTAL	:
			w_p_d = widthOrHeight * scale ;
			h_p_d = thickness     * scale ;
			break ;

		case VS_K_VERTICAL	:
			w_p_d = thickness     * scale ;
			h_p_d = widthOrHeight * scale ;
			break ;
	}

	w_p = (int) w_p_d ;
	h_p = (int) h_p_d ;

	__DBGpr_int( "X plate	  ", x_p ) ;
	__DBGpr_int( "Y plate	  ", y_p ) ;
	__DBGpr_int( "Width  plate", w_p ) ;
	__DBGpr_int( "Height plate", h_p ) ;

	/*
	 * Set size to 'top' line.
	 */
	rc = VSg_set_layout( form,
			     top,
			     x_p,
			     y_p,
			     w_p,
			     0 ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Set size to 'bottom' line.
	 */
	rc = VSg_set_layout( form,
			     bot,
			     x_p,
			     y_p + h_p,
			     w_p,
			     0 ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Set size to 'left' line.
	 */
	rc = VSg_set_layout( form,
			     lef,
			     x_p,
			     y_p,
			     0,
			     h_p ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Set size to 'right' line.
	 */
	rc = VSg_set_layout( form,
			     rgh,
			     x_p + w_p,
			     y_p,
			     0,
			     h_p ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	wrapup :
	End
	return rc ;

} /* VSsetPlateSize */
/*----------------------------------------------------------------------------*/
int VSfitDrawing( form, plate, nb_of_plates, rectangle )

char	*form ;
int	plate,
	nb_of_plates,
	rectangle ; {

	/*
	 * This function fits the plate inside area of rectangle.
	 */
	int	rc,
		i,
		x1,
		y1,
		x2,
		y2,
		*list = NULL ;

#define NB_COMPONENTS	4	/* 4 lines */

	SetProc( VSfitDrawing ); Begin

	/*
	 * Set size of list.
	 */
	list = _MALLOC( nb_of_plates * NB_COMPONENTS, int ) ;
	if( !list ) {
		rc = FI_NO_MEMORY ;
		goto wrapup ;
	}

	/*
	 * Initialize list.
	 */
	for( i=0; i<nb_of_plates; i++ ) {
		/*
		 * Set plate lines.
		 */
		rc = VSgetPlateLines( form,
				      plate + i,
				      list + i*NB_COMPONENTS,
				      list + i*NB_COMPONENTS +1,
				      list + i*NB_COMPONENTS +2,
				      list + i*NB_COMPONENTS +3	) ;
		if( rc != FI_SUCCESS ) goto wrapup ;
	}

	/*
	 * Get area of rectangle.
	 */
	rc = VSg_get_layout( form, rectangle, &x1, &y1, &x2, &y2 ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	x2 += x1 ;
	y2 += y1 ;

	/*
	 * Fit area.
	 */
	rc = VSf_fit_list( form,
			   list,
			   nb_of_plates * NB_COMPONENTS,
			   x1,
			   y1,
			   x2,
			   y2 ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

#undef NB_COMPONENTS

	wrapup :
		_FREE( list ) ;
		End
		return rc ;

} /* VSfitDrawing */
/*----------------------------------------------------------------------------*/
int VSfindPlate( form, plate, nb_of_plates, line, plate_number, side )

char	*form ;
int	plate,
	nb_of_plates,
	line,
	*plate_number,
	*side ; {

	/*
	 * Given a line this function finds the plate number and the type of
	 * line ( top, bottom, left, right ).
	 */
	int	rc = FI_SUCCESS,
		i,
		top, bot, lef, rgh ;

	SetProc( VSfindPlate ); Begin

	*plate_number = -1 ;
	*side	      = -1 ;

	__DBGpr_int( "line of plate", line ) ;

	for( i=0; i<nb_of_plates; i++ ) {
		rc = VSgetPlateLines( form,
				      plate + i,
				      &top,
				      &bot,
				      &lef,
				      &rgh ) ;
		if( rc != FI_SUCCESS ) break ;

		if( line == top ) {
			__DBGpr_com( "line is TOP"	) ;
			*plate_number = i ;
			*side	      = VS_K_TOP ;
			break ;
		}
		if( line == bot ) {
			__DBGpr_com( "line is BOTTOM"	) ;
			*plate_number = i ;
			*side	      = VS_K_BOTTOM ;
			break ;
		}
		if( line == lef ) {
			__DBGpr_com( "line is LEFT"	) ;
			*plate_number = i ;
			*side	      = VS_K_LEFT ;
			break ;
		}
		if( line == rgh ) {
			__DBGpr_com( "line is RIGHT"	) ;
			*plate_number = i ;
			*side	      = VS_K_RIGHT ;
			break ;
		}
	}
	if( rc == FI_SUCCESS && *plate_number == -1 )
		rc = FI_NO_SUCH_GROUP ;
	End
	return rc ;

} /* VSfindPlate */
/*----------------------------------------------------------------------------*/
#argsused
int VSstickPlate( form, plate, plate_number1, side1, plate_number2, side2,
		  offset, scale )

char	*form ;
int	plate,
	plate_number1,
	side1,
	plate_number2,
	side2 ;
double	offset,
	scale ; {

	/*
	 * Given two plate number and two side, this function sticks
	 * side2 to side1.
	 */
	int	rc,
		line1,
		x_l1, y_l1,
		x_p2, y_p2, h_p2, w_p2,
		x_p1, y_p1, h_p1, w_p1,
		stick_x = FALSE,
		stick_y = FALSE,
		offset_i ;

	SetProc( VSstickPlate ); Begin

	/*
	 * Find gadget line of second plate.
	 */
	rc = VSgetPlateSide( form,
			     plate,
			     plate_number1,
			     side1,
			     &line1 ) ;
	if( rc != FI_SUCCESS || line1 == -1 ) goto wrapup ;

	if( side1 == VS_K_TOP	|| side1 == VS_K_BOTTOM ) stick_y = TRUE ;
	if( side1 == VS_K_RIGHT || side1 == VS_K_LEFT	) stick_x = TRUE ;

	if( stick_x ) __DBGpr_com( "Stick X location of plate 2" ) ;
	if( stick_y ) __DBGpr_com( "Stick Y location of plate 2" ) ;

	/*
	 * Change location of plate 2 to stick to plate 1 with offset.
	 */
	rc = FIg_get_location( form, line1, &x_l1, &y_l1 ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	rc = VSg_get_layout( form, plate + plate_number2, &x_p2, &y_p2,
			     &w_p2, &h_p2 ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	rc = VSg_get_layout( form, plate + plate_number1, &x_p1, &y_p1,
			     &w_p1, &h_p1 ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	__DBGpr_com( "Location of second side" ) ;
	__DBGpr_int( "X line 2", x_l1 ) ;
	__DBGpr_int( "Y line 2", y_l1 ) ;

	__DBGpr_com( "Old layout of plate 2" ) ;
	__DBGpr_int( "X     ", x_p2 ) ;
	__DBGpr_int( "Y     ", y_p2 ) ;
	__DBGpr_int( "Width ", w_p2 ) ;
	__DBGpr_int( "Height", h_p2 ) ;

	x_p2 = stick_x ? ( side2 == VS_K_LEFT ? x_l1 : x_l1 - w_p2 ) : x_p2 ;
	y_p2 = stick_y ? ( side2 == VS_K_TOP  ? y_l1 : y_l1 - h_p2 ) : y_p2 ;

	offset_i = (int) ( offset * scale ) ;

	x_p2 = stick_y ? x_p1 + offset_i	       : x_p2 ;
	y_p2 = stick_x ? y_p1 + h_p1 - offset_i - h_p2 : y_p2 ;

	__DBGpr_com( "New location of plate" ) ;
	__DBGpr_int( "X     ", x_p2 ) ;
	__DBGpr_int( "Y     ", y_p2 ) ;

	rc = FIg_set_location( form,
			       plate + plate_number2,
			       x_p2,
			       y_p2 ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	wrapup :
	End
	return rc ;

} /* VSstickPlate */
/*----------------------------------------------------------------------------*/
void VSfindListToStick( connection, nb_plates, list )

VSxsPlConn	connection[VS_K_MAX_XSPLATES] ;
int		nb_plates ;
int		list[VS_K_MAX_XSPLATES] ; {


	/*
	 * this function returns an ordered list of plates to stick.
	 *
	 * Ex : If we have 3 plates and connections ( 0->1, 2->1 )
	 *	the returned list is 1,0,2. The first element in list, is the
	 *	static plate, the other is the plate to stick.
	 */
	int	i,
		j,
		sizeList,
		statePlate ;
	char	matCon[VS_K_MAX_XSPLATES][VS_K_MAX_XSPLATES] ;

	SetProc( VSfindListToStick ); Begin

#define STATIC	    0
#define CONNECT     1
#define NO_CONNECT -1

	/*
	 * Set all elements of matrix of connection to 0.
	 */
	for( i=0; i<nb_plates; i++ )
		for( j=0; j<nb_plates; j++ )
			matCon[i][j] = 0 ;

	/*
	 * Fill matrix of connection.
	 */
	for( i=0; i<nb_plates; i++ )
		if( i != connection[i].plate2 ) {
			matCon[i][i] = NO_CONNECT ;
		} else {
			matCon[i][connection[i].plate1] = CONNECT ;
		}

	/*
	 * Find static or no connect plate(s).
	 */
	sizeList = 0 ;

	for( i=0; i<nb_plates; i++ ) {

		statePlate = 0 ;

		for( j=0; j<nb_plates; j++ )
			statePlate |= matCon[i][j] ;

		switch( statePlate ) {

			case STATIC	:
				__DBGpr_int( "Static plate", i ) ;
				goto SET ;

			case NO_CONNECT :
				__DBGpr_int( "No connect plate", i ) ;

			SET :
				list[sizeList] = i ;
				sizeList++ ;
				break ;
		}
	}

	/*
	 * Find plate to connect to static plate.
	 */
	for( i=0; i<sizeList; i++ ) {

		__DBGpr_int( "Plate(s) connected to plate", list[i] ) ;

		for( j=0; j<nb_plates; j++ )

			if( matCon[j][list[i]] == CONNECT ) {
				__DBGpr_int( "\tplate", j ) ;
				list[sizeList] = j ;
				sizeList++ ;
			}
	}

#ifdef vsDEBUG
	__DBGpr_com( "List to stick" ) ;
	for( i=0; i<nb_plates; i++ )
		__DBGpr_int( "\tplate", list[i] ) ;
#endif

#undef STATIC
#undef CONNECT
#undef NO_CONNECT

	End

} /* VSfindListToStick */
/*----------------------------------------------------------------------------*/
int VSallPlatesStick( connection, nb_of_plates, plate )

VSxsPlConn	connection[VS_K_MAX_XSPLATES] ;
int		nb_of_plates,
		*plate ; {

	/*
	 * This function returns TRUE, if all plates are stick. Otherwise
	 * returns FALSE and the plate not stick in argument 'plate'.
	 */
	int	i,
		p,
		stick = TRUE ;

	for( p=0; p<nb_of_plates; p++ ) {

		for( i=0; i<nb_of_plates; i++ )
			if( connection[i].plate2 == p ||
			    connection[i].plate1 == p )
			break ;

		if( i == nb_of_plates ) break ;
	}

	if( p != nb_of_plates ) {
		*plate = p ;
		stick  = FALSE ;
	}

	return stick ;

} /* VSallPlatesStick */
/*----------------------------------------------------------------------------*/
int VScreatePlateNumber( form, gadget, number )

char	*form ;
int	gadget,
	number ; {

	/*
	 * This function creates a gadget text which is the number of the plate.
	 */
	int			rc ;
	char			text[VS_K_FI_MAX_CHAR] ;
	struct standard_st	standard_var ;

	/*
	 * Create text gadget.
	 */
	rc = FIg_new( form, FI_TEXT, gadget ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Fill standart structure.
	 *
	 * WARNING : Fill all fields of gadget structure so
	 * FIg_set_standard_variables won't go crazy.
	 */
	sprintf( text, "%d", number ) ;

	standard_var.xlo		= 0 ;
	standard_var.ylo		= 0 ;
	standard_var.xhi		= 0 ;
	standard_var.yhi		= 0 ;
	standard_var.attr_mask		= ( FI_NOT_DISPLAYED |
					    FI_NO_COMPLETE_NOTIFY ) ;
	standard_var.value		= 0.  ;
	standard_var.bodysize		= 15. ;
	standard_var.text		= text ;
	standard_var.help_topic 	= NULL ;
	standard_var.command		= NULL ;
	standard_var.fontname		= "swiss742b" ;
	standard_var.user_pointer	= NULL ;
	standard_var.off_color		= FI_BLACK ;
	standard_var.on_color		= FI_BLACK ;
	standard_var.off_color2 	= FI_BLACK ;
	standard_var.on_color2		= FI_BLACK ;
	standard_var.symbol_index	= 0 ;
	standard_var.symbol_index2	= 0 ;
	standard_var.next_in_seq	= 0 ;

	rc = FIg_set_standard_variables( form,
					 gadget,
					 &standard_var ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Activate gadget.
	 */
	rc = FIg_activate( form, gadget ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	wrapup :
	return rc ;

} /* VScreatePlateNumber */
/*----------------------------------------------------------------------------*/
int VScreatePlates( form, plate0, text0, nb_of_plates, erase_color )

char	*form ;
int	plate0,
	text0,
	nb_of_plates,
	erase_color ; {

	/*
	 * This function creates 'nb_of_plates' plates to be draw on the form.
	 */
	int	rc = FI_SUCCESS,
		i,
		top,
		bot,
		rgh,
		lef ;

#define WIDTH	100
#define HEIGHT	25
#define SPACE	35

	for( i=0; i<nb_of_plates; i++ ) {

		/*
		 * Create gadget text which is the number of the plate.
		 */
		rc = VScreatePlateNumber( form, text0 + i, i ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

		/*
		 * Create plate group.
		 */
		rc = FIg_new( form, FI_GROUP, plate0 + i ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

		/*
		 * Create the 4 gadgets line which define the plate.
		 */
			/*
			 * Top line.
			 */
		rc = VSg_create_line( form,
				      0,
				      SPACE * i,
				      WIDTH,
				      SPACE * i,
				      FI_BLACK,
				      &top ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

			/*
			 * Bottom line.
			 */
		rc = VSg_create_line( form,
				      0,
				      SPACE * i + HEIGHT,
				      WIDTH,
				      SPACE * i + HEIGHT,
				      FI_BLACK,
				      &bot ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

			/*
			 * Left line.
			 */
		rc = VSg_create_line( form,
				      0,
				      SPACE * i,
				      0,
				      SPACE * i + HEIGHT,
				      FI_BLACK,
				      &lef ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

			/*
			 * Right line.
			 */
		rc = VSg_create_line( form,
				      WIDTH,
				      SPACE * i,
				      WIDTH,
				      SPACE * i + HEIGHT,
				      FI_BLACK,
				      &rgh ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

		/*
		 * Add to plate group the four lines created before.
		 */
		rc = FIg_add_to_group( form, top, plate0 + i ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

		rc = FIg_add_to_group( form, bot, plate0 + i ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

		rc = FIg_add_to_group( form, lef, plate0 + i ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

		rc = FIg_add_to_group( form, rgh, plate0 + i ) ;
		if( rc != FI_SUCCESS ) goto wrapup ;

		/*
		 * Set erase color of plate.
		 */
		FIg_set_erase_color( form, plate0 + i, erase_color ) ;
		FIg_set_erase_color( form, text0  + i, erase_color ) ;
	}

#undef WIDTH
#undef HEIGHT
#undef SPACE

	wrapup :
	return rc ;

} /* VScreatePlates */
/*----------------------------------------------------------------------------*/
#argsused
void VSdisplayOffset( form, plate, plate_number1, side1, plate_number2, side2,
		      rectangle, offset, gadget )

char	*form ;
int	plate,
	plate_number1,
	side1,
	plate_number2,
	side2,
	rectangle,
	gadget ;
double	offset ; {

	/*
	 * This function display an offset ( a line and an arrow ) on the form.
	 */
	int	rc,
		line,
		line1,
		line2,
		X_offset,
		x1_l1, y1_l1, x2_l1, y2_l1,
		x1_l2, y1_l2, x2_l2, y2_l2,
		xm_l1, ym_l1,
		xm_l2, ym_l2,
		x1_lo, y1_lo, x2_lo, y2_lo,
		x1_la, y1_la,
		x1_lb, y1_lb, x2_lb, y2_lb,
		erase_color ;

#define SIZE_ARROW 6

	SetProc( VSdisplayOffset ); Begin

	/*
	 * Create gadget group offset.
	 */
	rc = FIg_new( form, FI_GROUP, gadget ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Find left/bottom line gadget of plate number 1.
	 */
	if( side1 == VS_K_TOP || side1 == VS_K_BOTTOM )
		X_offset = TRUE ;
	else	X_offset = FALSE ;

	rc = VSgetPlateSide( form,
			     plate,
			     plate_number1,
			     X_offset ? VS_K_LEFT : VS_K_BOTTOM,
			     &line1 ) ;
	if( rc != FI_SUCCESS || line1 == -1 ) goto wrapup ;

	__DBGpr_int( "Start line offset", line1 ) ;

	/*
	 * Find left/botton line gadget of plate number 2.
	 */
	rc = VSgetPlateSide( form,
			     plate,
			     plate_number2,
			     X_offset ? VS_K_LEFT : VS_K_BOTTOM,
			     &line2 ) ;
	if( rc != FI_SUCCESS || line2 == -1 ) goto wrapup ;

	__DBGpr_int( "End line offset", line2 ) ;

	/*
	 * get layout of two lines found before.
	 */
	rc = VSg_get_layout( form, line1, &x1_l1, &y1_l1, &x2_l1, &y2_l1 ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	x2_l1 += x1_l1 ;
	y2_l1 += y1_l1 ;

	rc = VSg_get_layout( form, line2, &x1_l2, &y1_l2, &x2_l2, &y2_l2 ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	x2_l2 += x1_l2 ;
	y2_l2 += y1_l2 ;

	/*
	 * Create line offset.
	 *
	 *	-----------
	 *	| plate 1 |
	 *	-----------  ---------------
	 *	   line      |		   |
	 *	------------ |	plate 2    |
	 *	   offset    ---------------
	 */
	xm_l1 = (x1_l1 + x2_l1) /2 ;
	ym_l1 = (y1_l1 + y2_l1) /2 ;

	xm_l2 = (x1_l2 + x2_l2) /2 ;
	ym_l2 = (y1_l2 + y2_l2) /2 ;

	if( offset > 0. ) {
		x2_lo = xm_l2 ;
		y2_lo = ym_l2 ;
	} else {
		x2_lo = X_offset ? x2_l2 : xm_l1 ;
		y2_lo = X_offset ? ym_l1 : y2_l2 ;
	}

	x1_lo = X_offset ? x1_l1 : x2_lo ;
	y1_lo = X_offset ? y2_lo : y1_l1 ;

	rc = VSg_create_line( form, x1_lo, y1_lo, x2_lo, y2_lo, FI_BLACK,
			      &line ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	rc = FIg_add_to_group( form, line, gadget ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Create arrow.
	 *
	 *	-----------
	 *	| plate 1 |
	 *	-----------  ---------------
	 *	   line      |		   |
	 *	------------>|	plate 2    |
	 *	   offset    ---------------
	 *
	 *
	 *	 \  <- line 1
	 *	  \
	 *	  /
	 *	 /  <- line 2
	 *
	 */
		/*
		 * line 1.
		 */

	if( X_offset ) {
		x1_la = x2_lo > x1_lo ? x2_lo - SIZE_ARROW :
					x2_lo + SIZE_ARROW ;
		y1_la = y2_lo - SIZE_ARROW ;
	} else {
		y1_la = y2_lo > y1_lo ? y2_lo - SIZE_ARROW :
					y2_lo + SIZE_ARROW ;
		x1_la = x2_lo - SIZE_ARROW ;
	}

	rc = VSg_create_line( form, x1_la, y1_la, x2_lo, y2_lo, FI_BLACK,
			      &line ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	rc = FIg_add_to_group( form, line, gadget ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

		/*
		 * line 2.
		 */

	if( X_offset ) y1_la = y2_lo + SIZE_ARROW ;
	else	       x1_la = x2_lo + SIZE_ARROW ;

	rc = VSg_create_line( form, x1_la, y1_la, x2_lo, y2_lo, FI_BLACK,
			      &line ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	rc = FIg_add_to_group( form, line, gadget ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Create base line.
	 *
	 *	-----------
	 *	| plate 1 |
	 *	-----------  ---------------
	 *	|  line      |		   |
	 *	|----------->|	plate 2    |
	 *	   offset    ---------------
	 *
	 */
	if( offset > 0. ) {
	   x1_lb =  X_offset ? x1_lo : ( x1_lo > xm_l1 ? x1_lo + SIZE_ARROW :
							 x1_lo - SIZE_ARROW ) ;
	   y1_lb = !X_offset ? y1_lo : ( y1_lo > ym_l1 ? y1_lo + SIZE_ARROW :
							 y1_lo - SIZE_ARROW ) ;

	   x2_lb =  X_offset ? x1_lb : xm_l1 ;
	   y2_lb = !X_offset ? y1_lb : ym_l1 ;

	} else {
	   x1_lb =  X_offset ? x2_lo : ( x2_lo > xm_l2 ? x2_lo + SIZE_ARROW :
							 x2_lo - SIZE_ARROW ) ;
	   y1_lb = !X_offset ? y2_lo : ( y2_lo > ym_l2 ? y2_lo + SIZE_ARROW :
							 y2_lo - SIZE_ARROW ) ;

	   x2_lb =  X_offset ? x1_lb : xm_l2 ;
	   y2_lb = !X_offset ? y1_lb : ym_l2 ;
	}

	rc = VSg_create_line( form, x1_lb, y1_lb, x2_lb, y2_lb, FI_BLACK,
			      &line ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	rc = FIg_add_to_group( form, line, gadget ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Change erase color of offset equal to color of rectangle.
	 */
	rc = FIg_get_on_color( form, rectangle, &erase_color ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	rc = FIg_set_erase_color( form, gadget, erase_color ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Change weight of offset equal to 1 pixel.
	 */
	rc = FIg_set_line_weight( form, gadget, 0 ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Display offset.
	 */
	rc = FIg_display( form, gadget ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

#undef SIZE_ARROW

	wrapup : ;
	End

} /* VSdisplayOffset */
/*----------------------------------------------------------------------------*/
int VSupdateAxis( form, g_unit, g_xmiddle, g_xmax, g_ymiddle, g_ymax,
		  rectangle, scale )

char	*form ;
int	g_unit,
	g_xmiddle,
	g_xmax,
	g_ymiddle,
	g_ymax,
	rectangle ;
double	scale ; {

	/*
	 * This function updates axis gadgets ( g_unit, g_xmiddle, g_xmax,
	 * g_ymiddle, g_ymax ) with respect to scale of design.
	 */
	long		msg ;
	int		rc ;
	double		w_fit,
			h_fit,
			xmax,
			ymax,
			factor ;
	struct GRid	curMod ;
	char		*unit,
			text[VS_K_FI_MAX_CHAR] ;

#define SET_VALUE_JUSTIFIED( gadget, value, justification )\
	FIg_set_justification( form, (gadget), (justification) ) ;\
	if( rc != FI_SUCCESS ) goto wrapup ;\
	sprintf( text, "%.2f", (value) ) ;\
	FIg_set_text( form, (gadget), text ) ;\
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Erase gadgets.
	 */
	vs$g_erase_gadgets( form = form,
			    list = `g_unit,
				    g_xmiddle,
				    g_xmax,
				    g_ymiddle,
				    g_ymax` ) ;

	/*
	 * Retrieve current module id.
	 */
	ex$get_cur_mod( id	= &curMod.objid,
			osnum	= &curMod.osnum ) ;

	/*
	 * Retrieve default unit of distance and update gadget 'g_unit' using
	 * a right justification.
	 */
	vs$get_default_unit( msg    = &msg,
			     osnum  = curMod.osnum,
			     p_unit = &unit ) ;

	if( !(msg & 1) ) {
		rc = FI_INVALID_FORMAT ;
		goto wrapup ;
	}

	/*
	 * Retrieve factor of conversion of working unit to active unit.
	 */
	co$cvt_imp_to_wrk( msg	     = &msg,
			   osnum     = curMod.osnum,
			   unit_type = GRIO_DISTANCE,
			   primary   = 1.0,
			   result    = &factor ) ;

	factor = 1.0/factor ;

	rc = FIg_set_justification( form, g_unit, FI_RIGHT_JUSTIFIED ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	rc = FIg_set_text( form, g_unit, unit ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Retrieve size of fitting area.
	 */
	rc = FIg_get_dsize( form, rectangle, &w_fit, &h_fit ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	w_fit -= 10.0 ;
	h_fit -= 10.0 ;

	/*
	 * Compute x and y max with respect to scale and active unit.
	 */
	xmax = ( w_fit / scale ) *factor ;
	ymax = ( h_fit / scale ) *factor ;

	/*
	 * Update X max and X middle using a center justification.
	 */
	SET_VALUE_JUSTIFIED( g_xmax,	xmax,	FI_CENTER_JUSTIFIED ) ;
	SET_VALUE_JUSTIFIED( g_xmiddle, xmax/2, FI_CENTER_JUSTIFIED ) ;

	/*
	 * Update Y max and Y middle using a right justification.
	 */
	SET_VALUE_JUSTIFIED( g_ymax,	ymax,	FI_RIGHT_JUSTIFIED ) ;
	SET_VALUE_JUSTIFIED( g_ymiddle, ymax/2, FI_RIGHT_JUSTIFIED ) ;

	/*
	 * Display gadgets.
	 */
	vs$g_display_gadgets( form = form,
			      list = `g_unit,
				      g_xmiddle,
				      g_xmax,
				      g_ymiddle,
				      g_ymax` ) ;

#undef SET_VALUE_JUSTIFIED

	wrapup :
	return rc ;

} /* VSupdateAxis */
/*----------------------------------------------------------------------------*/
