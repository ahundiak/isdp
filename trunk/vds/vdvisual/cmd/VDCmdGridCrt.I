/* $Id: VDCmdGridCrt.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/cmd / VDCmdGridCrt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdGridCrt.I,v $
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

	This function change a normal window to a window grid.

	Arguments :
	-----------

	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *gragad	Id of window ( gragad ) to
						change in window grid.
	IN	struct GRobj_env *cs_obj	Coordinate system where planes
						set is.
	OUT	int		 axis_gragad_X	Axis of coordinate system to
						display in X window
						(0->x, 1->y, 2->z).
	OUT	int		 axis_gragad_Y	Axis of coordinate system to
						display in Y window
						(0->x, 1->y, 2->z).

	Note :
	------

	The given gragad is deleted.
*/

#include <stdio.h>
#include "growner.h"
#include "AS_status.h"
#include "OMerrordef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "msdef.h"
#include "DIdef.h"
#include "expression.h"
#include "expmacros.h"
#include "nddef.h"
#include "asmacros.h"
#include "exmacros.h"
#include "madef.h"

#define AS_DEBUG 1

from NDnode	import NDconnect,
		       NDs_compute_node ;

extern struct GRid	NULL_GRID ;

extern int	DPerase() ;
extern long	VDcopyView() ;
extern short	MAidmx();
extern void	drawWnGridBorder() ;

/*
 * Default size of gragad which display view.
 */
#define MIN_X_DEFAULT	0.08
#define MIN_Y_DEFAULT	0.
#define MAX_X_DEFAULT	1.
#define MAX_Y_DEFAULT	0.92

#define SPACE	0.0045

/*----------------------------------------------------------------------------*/
long VDcreateWindowGrid( msg, gragad, cs_obj, axis_gragad_X, axis_gragad_Y )

long		 *msg ;
struct GRid	 *gragad ;	/* Gragad to change in window grid.	      */
struct GRobj_env *cs_obj ;	/* Coordinate system where planes set is.     */
int		 axis_gragad_X ;/* Axis of coordinate system (cs_obj) to      */
				/* display in X window (0->x, 1->y, 2->z).    */
int		 axis_gragad_Y ;/* Axis of coordinate system (cs_obj) to      */
				/* display in Y window (0->x, 1->y, 2->z).    */

/*.VDcreateWindowGrid*/{

	long			which_error,
				num_bytes,
				BSrc ;
	int			sts, i,
				flag,
				ggView_min_x_dep,
				ggView_min_y_dep,
				ggView_max_x_dep,
				ggView_max_y_dep ;
	double			min_x = MIN_X_DEFAULT,
				min_y = MIN_Y_DEFAULT,
				max_x = MAX_X_DEFAULT,
				max_y = MAX_Y_DEFAULT,
				ggView_min_x_indep,
				ggView_max_y_indep,
				r,
				display_depth[6] ;
	IGRuint			count;
	struct var_list 	var_list[3] ;
	struct gragad_inst	gragad_inst ;
	struct GRid		gragad_grid[3],
				window,
				parents[3] ;
	struct GRmd_env 	md_env ;
	struct DPdit_range	dit_range ;
	char			name[DI_PATH_MAX],
				gragad_name[DI_PATH_MAX] ;
	OM_S_CHANSELECT 	chandef ;
	OM_S_OBJECT_LINKAGE	channel_object ;

	chandef.type		= OM_e_name ;
	chandef.u_sel.name	= "IGEgadget.to_parent" ;

	/*"Gragad to modify in window grid : [%d,%d]\n", gragad->osnum, gragad->objid*/

	/*
	 * Retrieve instance data of gragad gadget.
	 */
	var_list[0].var 		= GRAGAD_INST_STRUCT ;
	var_list[0].var_ptr		= (char *) &gragad_inst ;
	var_list[0].num_bytes		= sizeof( struct gragad_inst ) ;
	var_list[0].bytes_returned	= &num_bytes ;

	var_list[1].var 		= GRAGAD_NAME ;
	var_list[1].var_ptr		= (char *) gragad_name ;
	var_list[1].num_bytes		= sizeof( gragad_name ) ;
	var_list[1].bytes_returned	= &num_bytes ;

	var_list[2].var 		= END_PARAM ;

	sts = om$send( msg	= message IGEgragad.DPinquire( msg,
							       &which_error,
							       var_list ),
		       senderid = NULL_OBJID,
		       targetid = gragad->objid,
		       targetos = gragad->osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*"Gragad name : %s\n", gragad_name*/

	/*
	 * Retrieve graphic window where gragad gadget is.
	 */
	sts = om$get_channel_objects( osnum	   = gragad->osnum,
				      objid	   = gragad->objid,
				      p_chanselect = &chandef,
				      list	   = &channel_object,
				      size	   = 1,
				      count	   = &count ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*"Number of object on 'to_parent' channel : %d\n", count*/

	window.osnum = channel_object.osnum ;
	window.objid = channel_object.S_objid ;

	/*"Window of gragad : [%d,%d]\n", window.osnum, window.objid*/

	/*
	 * Erase gragad gadget.
	 */
	dit_range.xlo = gragad_inst.min_x_dep ;
	dit_range.ylo = gragad_inst.min_y_dep ;

	dit_range.xhi = gragad_inst.max_x_dep ;
	dit_range.yhi = gragad_inst.max_y_dep ;

	if( !DPerase( msg, &gragad_inst.win_no, &dit_range ) ) {
		/*|ERROR in DPerase*/
		sts = OM_E_ABORT ;
		goto wrapup ;
	}

	/*
	 * Delete gragad gadget.
	 */
	sts = om$send( msg	= message IGEgragad.delete( 1 ),
		       senderid = NULL_OBJID,
		       targetid = gragad->objid,
		       targetos = gragad->osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*
	 * Construct three gragad gadgets like this :
	 *
	 *		-------------------------
	 *		|<- XG ->		|
	 *		-------------------------
	 *		|	|		|
	 *		|	|		|
	 *		|	|		|
	 *		|	|		|
	 *		|gragad |  gragad 0	|
	 *		|  2	|		|
	 *		|	|		|
	 *		|	|		|
	 *		|	|		|
	 *		|-----------------------|  ^
	 *		|xxxxxxx|		|  |
	 *		|xxxxxxx|  gragad 1	|  YG
	 *		|xxxxxxx|		|  |
	 *		-------------------------  v
	 *
	 *
	 *	The gadget #0 display the view ( class VDgragadGrid ).
	 *	The gadget #1 display the plane set which is on
	 *	X window direction ( class VDggxyGrid ).
	 *	The gadget #2 display the plane set which is on
	 *	Y window direction ( class VDggxyGrid ).
	 *
	 *	First calcul XG and YG which delimit the size of the gragad
	 *	view like this :
	 *
	 *	- if the lenght is bigger than the height of the window then
	 *	  XG is equal to 8% of the lenght and YG is calculated to
	 *	  have the same size of XG, otherwise YG is equal to 8% of
	 *	  the height and XG is calculated to have the same size of YG.
	 *
	 */

	/*|Calculate size of gragad view*/

	if( gragad_inst.max_x_dep > gragad_inst.max_y_dep ) {
		/*|Lenght of window bigger*/

		r = (double) gragad_inst.max_x_dep /
		    (double) gragad_inst.max_y_dep ;

		ggView_min_x_indep = MIN_X_DEFAULT ;
		ggView_max_y_indep = 1. - ( r * ggView_min_x_indep ) ;

	} else {
		/*|Height of window bigger*/

		r = (double) gragad_inst.max_y_dep /
		    (double) gragad_inst.max_x_dep ;

		ggView_max_y_indep = MAX_Y_DEFAULT ;
		ggView_min_x_indep = ( 1 - ggView_max_y_indep ) * r ;
	}

	/*"min x = %g\n", ggView_min_x_indep*/
	/*"max y = %g\n", ggView_max_y_indep*/

	if( ggView_min_x_indep >= 1. ) {
		/*|Cannot display view, recalculate min x*/
		ggView_min_x_indep = MIN_X_DEFAULT ;
		/*"min x = %g\n", ggView_min_x_indep*/
	}

	if( ggView_max_y_indep <= 0. ) {
		/*|Cannot display view, recalculate max y*/
		ggView_max_y_indep = MAX_Y_DEFAULT ;
		/*"max y = %g\n", ggView_max_y_indep*/
	}

	for( i=2; i>=0; i-- ) {

		/*"Construct gragad n'%d\n", i*/

		strcpy( name, gragad_name ) ;

		if( i == 0 ) {
			strcat( name, "_GRID" ) ;
			min_x = ggView_min_x_indep ;
			min_y = MIN_Y_DEFAULT ;
			max_x = MAX_X_DEFAULT ;
			max_y = ggView_max_y_indep ;
		}
		if( i == 1 ) {
			strcat( name, "_X"    ) ;
			min_x = ggView_min_x_indep ;
			min_y = ggView_max_y_indep + SPACE ;
			max_x = 1.  ;
			max_y = 1.  ;
		}
		if( i == 2 ) {
			strcat( name, "_Y"    ) ;
			min_x = 0.  ;
			min_y = 0.  ;
			max_x = ggView_min_x_indep - SPACE ;
			max_y = ggView_max_y_indep ;
		}

		/*"\tName : %s\n", name*/
		/*|\tSize*/
		/*"\tmin x : %g\n", min_x*/
		/*"\tmin y : %g\n", min_y*/
		/*"\tmax x : %g\n", max_x*/
		/*"\tmax y : %g\n", max_y*/

		sts = om$construct( classname	= "IGEgragad",
				    osnum	= gragad->osnum,
				    obj_osnum	= gragad->osnum,
				    p_objid	= &gragad_grid[i].objid,
				    msg 	= message IGEgragad.gragad_cons(
								     msg,
								     name,
								     min_x,
								     min_y,
								     max_x,
								     max_y ) ) ;

		as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
		as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

		gragad_grid[i].osnum = gragad->osnum ;

		/*"\tgragad construct : [%d,%d]\n", gragad_grid[i].osnum, gragad_grid[i].objid*/

		/*
		 * Set view the same as original gragad.
		 */
		sts = VDcopyView( msg,
				  &gragad_inst.gragad,
				  &gragad_grid[i] ) ;

		as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
		as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

		/*
		 * Add gragad gadgets to graphic window.
		 */
		sts = om$send( msg	= message IGEgragad.add_gadget(
							  msg,
							  &gragad_grid[i].objid,
							  1 ),
			       senderid = NULL_OBJID,
			       targetid = window.objid,
			       targetos = window.osnum ) ;

		as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
		as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

		/*
		 * Change class of the gragad to override methods.
		 */
		sts = om$change_class( classname = (i==0) ? "VDgragadGrid" :
							    "VDggxyGrid",
				       osnum	 = gragad_grid[i].osnum,
				       objid	 = gragad_grid[i].objid ) ;

		as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	}

	/*
	 * Retrieve/Create ASsource of given coordinate system.
	 */
	sts = as$make_source( go_grid		= cs_obj->obj_id,
			      mod_env		= &cs_obj->mod_env,
			      as_grid		= &parents[0] ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*"ASsource of coordinate system : [%d,%d]\n", parents[0].osnum, parents[0].objid*/

	/*
	 * Set parent to gragad #0 ( gragad which display the view ).
	 *
	 * Parent #0 : The coordinate system where planes set is.
	 */
	sts = om$send( msg	= message NDnode.NDconnect( 1,
							    parents,
							    NULL_GRID,
							    ND_NEW ),
		       senderid = NULL_OBJID,
		       targetid = gragad_grid[0].objid,
		       targetos = gragad_grid[0].osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*
	 * Set parents to gragad #1 ( gragad on X direction ) :
	 *
	 * Parent #0 : The view displayed ( gragad #0 ).
	 * Parent #1 : The coordinate system where planes set is.
	 * Parent #2 : The axis of coordinate system (parent #1) to
	 *	       display (0->x, 1->y, 2->z).
	 */
	parents[1] = parents[0] ;
	parents[0] = gragad_grid[0] ;

	parents[2].osnum = parents[0].osnum ;

	sts = exp$create( exp_name	= NULL,
			  exp_value	= (double) axis_gragad_X,
			  p_exp_id	= &parents[2].objid,
			  osnum 	= parents[2].osnum,
			  type_rq	= EXP_DOUBLE ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*"Expression created for gragad X : [%d,%d]\n", parents[2].osnum, parents[2].objid*/

	sts = om$send( msg	= message NDnode.NDconnect( 3,
							    parents,
							    NULL_GRID,
							    ND_NEW ),
		       senderid = NULL_OBJID,
		       targetid = gragad_grid[1].objid,
		       targetos = gragad_grid[1].osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*
	 * Set parents to gragad #2 ( gragad on Y direction ) :
	 *
	 * Parent #0 : The view displayed ( gragad #0 ).
	 * Parent #1 : The coordinate system where planes set is.
	 * Parent #2 : The axis of coordinate system (parent #1) to
	 *	       display (0->x, 1->y, 2->z).
	 */
	sts = exp$create( exp_name	= NULL,
			  exp_value	= (double) axis_gragad_Y,
			  p_exp_id	= &parents[2].objid,
			  osnum 	= parents[2].osnum,
			  type_rq	= EXP_DOUBLE ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*"Expression created for gragad Y : [%d,%d]\n", parents[2].osnum, parents[2].objid*/

	sts = om$send( msg	= message NDnode.NDconnect( 3,
							    parents,
							    NULL_GRID,
							    ND_NEW ),
		       senderid = NULL_OBJID,
		       targetid = gragad_grid[2].objid,
		       targetos = gragad_grid[2].osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*
	 * Set max display depth and update gragad X and Y ( The update window
	 * is perfomed on method NDcompute_node ).
	 */
	ex$get_cur_mod( id	= &md_env.md_id.objid,
			osnum	= &md_env.md_id.osnum ) ;

	md_env.md_env.matrix_type = MAIDMX ;
	MAidmx( &BSrc, md_env.md_env.matrix ) ;

	flag = FRONT_CLIP	|
	       BACK_CLIP	|
	       WORLD_COOR	|
	       SETIN		;

	display_depth[2] = IGE_DESIGN_LIMITS_MIN ;
	display_depth[5] = IGE_DESIGN_LIMITS_MAX ;

	for( i=1; i<3; i++ ) {

		sts = om$send( msg	= message IGEgragad.DPview_vol(
								 msg,
								 flag,
								 NULL,
								 NULL,
								 NULL,
								 NULL,
								 display_depth,
								 NULL,
								 NULL,
								 NULL,
								 NULL,
								 NULL,
								 NULL,
								 NULL,
								 FALSE ),
			       senderid = gragad_grid[i].objid,
			       targetid = gragad_grid[i].objid,
			       targetos = gragad_grid[i].osnum ) ;

		as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
		as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

		sts = om$send( msg	= message NDnode.NDs_compute_node(
								      msg,
								      ND_COMP,
								      &md_env ),
			       senderid = NULL_OBJID,
			       targetid = gragad_grid[i].objid,
			       targetos = gragad_grid[i].osnum ) ;

		as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
		as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;
	}

	/*
	 * draw border of gragad view.
	 */
	sts = om$send( msg	= message IGEgragad.dep_extents(
							    msg,
							    &ggView_min_x_dep,
							    &ggView_min_y_dep,
							    &ggView_max_x_dep,
							    &ggView_max_y_dep ),
			senderid = NULL_OBJID,
			targetid = gragad_grid[0].objid,
			targetos = gragad_grid[0].osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	drawWnGridBorder( gragad_inst.win_no,
			  ggView_min_x_dep,
			  ggView_min_y_dep,
			  ggView_max_x_dep,
			  ggView_max_y_dep ) ;

	wrapup :
		*msg = ( *msg & sts & 1 ) ? MSSUCC : MSFAIL ;

	return sts ;

} /* VDcreateWindowGrid */
/*----------------------------------------------------------------------------*/

end implementation IGEgragad ;
