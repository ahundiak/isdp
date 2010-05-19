/* $Id: VDGridCnWn.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/imp / VDGridCnWn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDGridCnWn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation IGEgragad ;

/*
	Abstract :
	----------

	This function test if two axis of the given coordinate system
	are parallel to the given window direction ( X and Y ) defined in
	base CS.

		-------------------
		|     Window	  |
		-------------------
		|		  |
		|   ^ Y 	  |
		|   |		  |
		|   |		  |
		|    ---> X	  |
		-------------------

	Arguments :
	-----------

	OUT	long		*msg		Completion code.
	IN	struct GRid	*cs_grid	Id of coordinate system.
	IN	struct GRid	*window 	ID of window.
	OUT	int		*axis_found	TRUE, if two axis are
						parallel.
	OUT	int		*x_axis 	Axis of coordinate system
						equivalent to X.
						(0->x, 1->y, 2->z ).
	OUT	int		*y_axis 	Axis of coordinate system
						equivalent to Y.
						(0->x, 1->y, 2->z ).

	Note :
	------

	- 'x_axis' and 'y_axis' could be NULL.

	- If no axis was found , axis_found = FALSE and x_axis = y_axis = -1.
*/

#include <stdio.h>
#include "AS_status.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"

from GRgencs	import GRgetmatrix ;

#define AS_DEBUG 1

extern short BScrossp() ;

/*----------------------------------------------------------------------------*/
long VDcheckConstWnGrid( msg, cs_grid, window, axis_found, x_axis, y_axis )

long		*msg ;
struct GRid	*cs_grid,
		*window ;
int		*axis_found,
		*x_axis,
		*y_axis ;

/*.VDcheckConstWnGrid*/ {

	struct var_list 	var_list[2] ;
	long			sts,
				num_bytes,
				which_error,
				BSrc ;
	int			x_window = 0,
				y_window = 0,
				x_window_found = FALSE,
				y_window_found = FALSE ;
	double			X[3],
				Y[3],
				x_cs[3],
				y_cs[3],
				z_cs[3],
				wld_to_view[16],
				local_to_wld[16],
				crossp[3] ;

#define PARALLEL_VECTOR( vec1, vec2 ) \
	BScrossp( &BSrc, (vec1), (vec2), crossp ) &&\
	(crossp[0] == 0.) &&\
	(crossp[1] == 0.) &&\
	(crossp[2] == 0.)

	/*
	 * Retrieve wld-to-view transformation matrix.
	 */
	var_list[0].var 		= WLD_TO_VIEW ;
	var_list[0].var_ptr		= (IGRchar *) wld_to_view ;
	var_list[0].num_bytes		= 16 * sizeof( double ) ;
	var_list[0].bytes_returned	= &num_bytes ;

	var_list[1].var 		= END_PARAM ;

	sts = om$send( msg	= message IGEgragad.DPinquire( msg,
							       &which_error,
							       var_list ),
			  senderid = window->objid,
			  targetid = window->objid,
			  targetos = window->osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*^
		printf( "wld-to-view transformation matrix of window\n" ) ;
		for( i=0; i<4; i++ )
		    printf( "\t%f %f %f %f\n", wld_to_view[i*4],
					       wld_to_view[i*4+1],
					       wld_to_view[i*4+2],
					       wld_to_view[i*4+3] ) ;
	*/

	X[0] = wld_to_view[0] ;
	X[1] = wld_to_view[1] ;
	X[2] = wld_to_view[2] ;

	Y[0] = wld_to_view[4] ;
	Y[1] = wld_to_view[5] ;
	Y[2] = wld_to_view[6] ;

	/*|Window direction*/

	/*"X : %f %f %f\n", X[0], X[1], X[2]*/
	/*"Y : %f %f %f\n", Y[0], Y[1], Y[2]*/

	/*
	 * Retrieve local-to-world transformation matrix of coordinate system.
	 */
	sts = om$send( msg	= message GRgencs.GRgetmatrix( msg,
							       local_to_wld ),
		       senderid = cs_grid->objid,
		       targetid = cs_grid->objid,
		       targetos = cs_grid->osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*^
		printf( "local-to-wld transformation of coordinate system\n" ) ;
		for( i=0; i<4; i++ )
		    printf( "\t%f %f %f %f\n", local_to_wld[i*4],
					       local_to_wld[i*4+1],
					       local_to_wld[i*4+2],
					       local_to_wld[i*4+3] ) ;
	*/

	x_cs[0] = local_to_wld[0] ;
	x_cs[1] = local_to_wld[4] ;
	x_cs[2] = local_to_wld[8] ;

	y_cs[0] = local_to_wld[1] ;
	y_cs[1] = local_to_wld[5] ;
	y_cs[2] = local_to_wld[9] ;

	z_cs[0] = local_to_wld[2] ;
	z_cs[1] = local_to_wld[6] ;
	z_cs[2] = local_to_wld[10] ;

	/*
	 * Find if one axis of the coordinate system is parallel to
	 * the window direction X.
	 */
	if( PARALLEL_VECTOR( X, x_cs ) ) {
		/*|x axis equivalent to X window direction*/
		x_window = 0 ;
		x_window_found = TRUE ;
	}

	if( !x_window_found )
		if( PARALLEL_VECTOR( X, y_cs ) ) {
			/*|y axis equivalent to X window direction*/
			x_window = 1 ;
			x_window_found = TRUE ;
		}


	if( !x_window_found )
		if( PARALLEL_VECTOR( X, z_cs ) ) {
			/*|z axis equivalent to X window direction*/
			x_window = 2 ;
			x_window_found = TRUE ;
		}

	/*
	 * Find if one axis of the coordinate system is parallel to
	 * the window direction Y.
	 */
	if( PARALLEL_VECTOR( Y, x_cs ) ) {
		/*|x axis equivalent to Y window direction*/
		y_window = 0 ;
		y_window_found = TRUE ;
	}

	if( !y_window_found )
		if( PARALLEL_VECTOR( Y, y_cs ) ) {
			/*|y axis equivalent to Y window direction*/
			y_window = 1 ;
			y_window_found = TRUE ;
		}

	if( !y_window_found )
		if( PARALLEL_VECTOR( Y, z_cs ) ) {
			/*|z axis equivalent to Y window direction*/
			y_window = 2 ;
			y_window_found = TRUE ;
		}

	/*
	 * Check if the two axis parallel was found.
	 */
	if( !y_window_found || !x_window_found ) {
		/*|One or no axis parallel to window direction*/
		x_window = -1 ;
		y_window = -1 ;
		*axis_found = FALSE ;
	} else {
		/*|Two axis parallel to window direction*/
		*axis_found = TRUE ;
	}

#undef PARALLEL_VECTOR

	wrapup :
		if( !(*msg & sts & 1) ) {
			*axis_found = FALSE ;
			x_window = -1 ;
			y_window = -1 ;
		}

		if( x_axis ) *x_axis = x_window ;
		if( y_axis ) *y_axis = y_window ;


	return sts ;

} /* VDcheckConstWnGrid */
/*----------------------------------------------------------------------------*/

end implementation IGEgragad ;
