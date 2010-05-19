/* $Id: VDCmdGridOn.sl,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/cmd / VDCmdGridOn.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdGridOn.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/31  21:01:32  pinnacle
# UnInit warning
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/01/06  16:25:48  pinnacle
# Replaced: vdvisual/cmd/VDCmdGridOn.sl by tdumbach r#
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
 *	10/31/97	ah		status/quit warnings
 * -------------------------------------------------------------------*/

/*
	I/VDS
	"Turn Window Grid On" command.
*/
command_string	VDC_M_TrWnGrOn, 0, VDTrWnGrOn
command_table	"vds.cmd"
class		VDCmdGridOn
super_class	VDS_LOCATE
product_name	"$VDS"

specification

#include "growner.h"

instance {
	struct GRobj_env	csGrid ;	/* cs of grid planes.	      */
	struct GRid		window ;	/* Window to change in window */
						/* grid.		      */
	int			x_window ;	/* Axis of coordinate system  */
						/* to display in the X window */
						/* 0->x, 1->y, 2->z.          */
	int			y_window ;	/* Axis of coordinate system  */
						/* to display in the Y window */
						/* 0->x, 1->y, 2->z.          */
}

implementation

#include <stdio.h>
#include "AS_status.h"
#include "csmacros.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "dpdef.h"
#include "dp.h"
#include "madef.h"
#include "bserr.h"
#include "bstypes.h"


/* PROTOTYPES */
#include "maidmx.h"
#include "bscrossp.h"

from IGEgragad	import DPinquire ;
from GRgencs	import GRgetmatrix ;

#define AS_DEBUG 1

#define VD_K_ACT_SUCCESS	0x001
#define VD_K_RESTART_CMD	0x002
#define VD_K_NO_WINDOW		0x004
#define VD_K_CANNOT_CHG_WINDOW	0x008
#define VD_K_NO_PARA_VIEW	0x010
#define VD_K_ALREADY_WN_GRID 	0x020

state_table

#include "grmessage.h"
#include "VDmsg.h"

#define VD_K_ACT_SUCCESS	0x001
#define VD_K_RESTART_CMD	0x002
#define VD_K_NO_WINDOW		0x004
#define VD_K_CANNOT_CHG_WINDOW	0x008
#define VD_K_NO_PARA_VIEW	0x010
#define VD_K_ALREADY_WN_GRID 	0x020

state start
	message_key 	VD_M_TrWnGrOn
	prompt_key	VD_P_VsIdCSRj
	accept_key	VD_P_AccRej
	locate_class	"GRcoords"
	mask		"GRm_DATA | GRm_STRING | GRm_OBJID | GRm_RJT_MOVEON"
	filter		locate

	on EX_RJT_MOVEON do get_active_cs( &me->ret )
			on RETURN_CODE = "VD_K_RESTART_CMD"
								state rstCmd
								state get_window
	on EX_DATA	 do store_cs				state get_window


state get_window
	prompt_key	VD_P_VsIdWin
	filter		get_event

	on EX_BACK_UP						state start

	on EX_DATA or EX_STRING
		do store_window( &me->ret )
			on RETURN_CODE = "VD_K_NO_WINDOW"
				do status_key VD_E_VsInvWin	state .
			on RETURN_CODE = "VD_K_NO_PARA_VIEW"
				do status_key VD_E_VsNoPrWin	state .
			on RETURN_CODE = "VD_K_ALREADY_WN_GRID"
				do status_key VD_E_VsAlrWnGr	state .
			on RETURN_CODE = "VD_K_RESTART_CMD"	state rstCmd

		 do check_construction( &me->ret )
			on RETURN_CODE = "VD_K_CANNOT_CHG_WINDOW"
				do status_key VD_E_VsCnStWnGr	state .
			on RETURN_CODE = "VD_K_RESTART_CMD"	state rstCmd
		 do construct_window( &me->ret )
		 	on RETURN_CODE = "VD_K_RESTART_CMD"	state rstCmd
								state start

state rstCmd
	status_key GR_E_ErrEncCmdRst
	on ELSE state start

/*----------------------------------------------------------------------------*/
action get_active_cs( long *msg )
/*.get_active_cs*/ {

	long		sts;
	BSrc		bsrc ;
	struct GRid	curMod ;

// Get rid of warnings
if (status);
if (0) goto quit;

	/*
	 * Retrieve current OS.
	 */
	ex$get_cur_mod( id	= &curMod.objid,
			osnum	= &curMod.osnum ) ;

	/*"Current OS : %d\n", curMod.osnum*/

	me->csGrid.obj_id.osnum = curMod.osnum ;
 
	/*
	 * Retrieve active coordinate system.
	 */
	sts = cs$get_active_info( msg	= msg,
				  osnum = me->csGrid.obj_id.osnum,
				  objid = &me->csGrid.obj_id.objid ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;
	
	me->csGrid.mod_env.md_id = curMod ;
	me->csGrid.mod_env.md_env.matrix_type = MAIDMX ;
	MAidmx( &bsrc, me->csGrid.mod_env.md_env.matrix ) ;
	
	/*"Active CS : [%d,%d]\n", me->csGrid.obj_id.osnum, me->csGrid.obj_id.objid*/

	wrapup :
		*msg = ( sts & *msg & 1 ) ? VD_K_ACT_SUCCESS :
					    VD_K_RESTART_CMD ;

} /* get_active_cs */
/*----------------------------------------------------------------------------*/
action store_cs
/*.store_cs*/ {

// Get rid of warnings
if (status);
if (0) goto quit;


	me->csGrid.obj_id  = me->event1.located_object[0].located_obj ;
	me->csGrid.mod_env = me->event1.located_object[0].module_info ;

	/*"CS located : [%d,%d]\n", me->csGrid.obj_id.osnum, me->csGrid.obj_id.objid*/

} /* store_cs */
/*----------------------------------------------------------------------------*/
action store_window( long *msg )
/*.store_window*/ {

	struct GRid		curMod ;
	long			sts,
				num_bytes,
				which_error ;
	char			path[80] ,
				path_buf[80] ;
	struct var_list 	var_list[2] ;
	int			window_flag ;
	OMuword			window_classid ;
	
extern OMuword OPP_VDgragadGrid_class_id,
	       OPP_VDggxyGrid_class_id ;

// Get rid of warnings
if (status);
if (0) goto quit;

	if( me->event1.response == EX_DATA ) {
		/*
		 * Window was identified.
		 */
		me->window.objid = me->event1.event.button.objid ;
		me->window.osnum = me->event1.event.button.osnum ;
	} else {
		/*
		 * Keyin window name, so retrieve window ID.
		 */
		ex$get_cur_mod( id	= &curMod.objid,
				osnum	= &curMod.osnum ) ;

		/*"Current OS : %d\n", curMod.osnum*/

		di$give_pathname( osnum    = curMod.osnum,
				  pathname = path ) ;

		DIstmcpy( path_buf, path,"views","regviews","GRviews", NULL ) ;

		sts = di$translate( objname	= me->event1.event.keyin,
				    path	= path_buf,
				    p_objid	= &me->window.objid,
				    p_osnum	= &me->window.osnum  ) ;

	       if( sts == DIR_W_NAME_NOT_FOUND ) {
			*msg = VD_K_NO_WINDOW ;
			return OM_S_SUCCESS ;
	       }
	}

	/*"Window : [%d,%d]\n", me->window.osnum, me->window.objid*/
	
	/*
	 * See if window isn't already a window grid.
	 */
	om$get_classid( objid	  = me->window.objid,
		        osnum	  = me->window.osnum,
		        p_classid = &window_classid ) ;
		        
	if( ( om$is_ancestry_valid( superclassid = OPP_VDgragadGrid_class_id,
				    subclassid   = window_classid ) 
				    == OM_S_SUCCESS ) ||
	    ( om$is_ancestry_valid( superclassid = OPP_VDggxyGrid_class_id,
				    subclassid   = window_classid ) 
				    == OM_S_SUCCESS ) ) {
		/*|Window already a window grid*/
		*msg = VD_K_ALREADY_WN_GRID ;
		return OM_S_SUCCESS ;
	}

	/*
	 * See if window contains a parallel view.
	 */
	var_list[0].var			= GRAGAD_FLAGS ;
	var_list[0].var_ptr		= (char *) &window_flag ;
	var_list[0].num_bytes		= sizeof( int ) ;
	var_list[0].bytes_returned	= &num_bytes ;

	var_list[1].var			= END_PARAM ;

	sts = om$send( msg      = message IGEgragad.DPinquire( msg,
						               &which_error,
						               var_list ),
		       targetid = me->window.objid,
		       targetos = me->window.osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;
	
	if( window_flag & IS_PERSP ) {
		/*|Window is a view perspective*/
		*msg = VD_K_NO_PARA_VIEW ;
		return OM_S_SUCCESS ;
	}

	wrapup :
		*msg = ( sts & *msg & 1 ) ? VD_K_ACT_SUCCESS :
					    VD_K_RESTART_CMD ;

} /* store_window */
/*----------------------------------------------------------------------------*/
action check_construction( long *msg )
/*.check_construction*/ {

	struct var_list 	var_list[2] ;
	long			sts,
				num_bytes,
				which_error;
	BSrc                    bsrc;
	int			x_window_found = FALSE,
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
	BScrossp( &bsrc, (vec1), (vec2), crossp ) &&\
	(crossp[0] == 0.) &&\
	(crossp[1] == 0.) &&\
	(crossp[2] == 0.)

	/*
	 * This method test if two axis of the coordinate system
	 * are parallel to the window direction ( X and Y ) defined in base CS.
	 *
	 *	-------------------
	 *	|     Window	  |
	 *	-------------------
	 *	|		  |
	 *	|   ^ Y 	  |
	 *	|   |		  |
	 *	|   |		  |
	 *	|    ---> X	  |
	 *	-------------------
	 *
	 */

// Get rid of warnings
if (status);
if (0) goto quit;


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
			  targetid = me->window.objid,
			  targetos = me->window.osnum ) ;

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
		       targetid = me->csGrid.obj_id.objid,
		       targetos = me->csGrid.obj_id.osnum ) ;

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
		me->x_window = 0 ;
		x_window_found = TRUE ;
	}

	if( !x_window_found )
		if( PARALLEL_VECTOR( X, y_cs ) ) {
			/*|y axis equivalent to X window direction*/
		me->x_window = 1 ;
			x_window_found = TRUE ;
		}


	if( !x_window_found )
		if( PARALLEL_VECTOR( X, z_cs ) ) {
			/*|z axis equivalent to X window direction*/
		me->x_window = 2 ;
			x_window_found = TRUE ;
		}

	/*
	 * Find if one axis of the coordinate system is parallel to
	 * the window direction Y.
	 */
	if( PARALLEL_VECTOR( Y, x_cs ) ) {
		/*|x axis equivalent to Y window direction*/
		me->y_window = 0 ;
		y_window_found = TRUE ;
	}

	if( !y_window_found )
		if( PARALLEL_VECTOR( Y, y_cs ) ) {
			/*|y axis equivalent to Y window direction*/
			me->y_window = 1 ;
			y_window_found = TRUE ;
		}

	if( !y_window_found )
		if( PARALLEL_VECTOR( Y, z_cs ) ) {
			/*|z axis equivalent to Y window direction*/
			me->y_window = 2 ;
			y_window_found = TRUE ;
		}

	/*
	 * Check if the two axis parallel was found.
	 */
	if( !y_window_found || !x_window_found ) {
		/*|Cannot change window to window grid*/
		*msg = VD_K_CANNOT_CHG_WINDOW ;
		return OM_S_SUCCESS ;
	}
	
#undef PARALLEL_VECTOR

	wrapup :
		*msg = ( *msg & sts & 1 ) ? VD_K_ACT_SUCCESS :
					    VD_K_RESTART_CMD ;

} /* check_construction */
/*----------------------------------------------------------------------------*/
action construct_window( long *msg ) 
/*.construct_window*/ {
	
	long 	sts ;
	
	extern long VDcreateWindowGrid() ;

// Get rid of warnings
if (status);
if (0) goto quit;
	
	/*
	 * Construct window grid.
	 */
	sts = VDcreateWindowGrid( msg,
				  &me->window,
				  &me->csGrid,
				  me->x_window,
				  me->y_window ) ;
				  
	*msg = ( sts & *msg & 1 ) ? VD_K_ACT_SUCCESS :
				    VD_K_RESTART_CMD ;
				    
} /* construct_window */
/*----------------------------------------------------------------------------*/


