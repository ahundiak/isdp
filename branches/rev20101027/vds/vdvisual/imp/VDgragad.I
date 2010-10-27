/* $Id: VDgragad.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/imp / VDgragad.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDgragad.I,v $
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
# Revision 1.3  1995/11/17  11:39:30  pinnacle
# Replaced: vdvisual/imp/VDgragad.I for:  by rgade for vds.240
#
# Revision 1.2  1995/11/17  05:51:54  pinnacle
# Replaced: vdvisual/imp/VDgragad.I for:  by rgade for vds.240
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

class implementation VDgragadGrid ;

/* **************************************************************************

   History :

   30 Jun 1993    Raju   2.2.0	  Added dummy method NDcompute_node
   17 Nov 1995    Ravi            Added if ( update ) condition in 
                                  DProtate() to avoid infinite loop
                                  for View Independent Text TR#179528186
 ***************************************************************************/

#include <stdio.h>
#include "AS_status.h"
#include "msmacros.h"
#include "exmacros.h"
#include "madef.h"
#include "nddef.h"
#include "msdef.h"
#include "igewinmacros.h"
#include "DIdef.h"

#include "VDmsg.h"

from VDggxyGrid import get_axis_displayed,
		       change_axis_to_display,
		       set_gragad_struct ;

#define AS_DEBUG 1

extern short MAidmx() ;

extern void drawWnGridBorder(),
	    tellUser() ;

/*----------------------------------------------------------------------------*/
method DPupdate( long			*msg ;
		 struct DPdit_range	*range ;
		 short			*update_all )
/*.DPupdate*/ {

	long		BSrc ;
	struct GRid	gragad_children[2] ;
	int		quiet_flag,
			sts, i,
			gragad_count ;
	struct GRmd_env md_env ;

	/*"Gragad : [%d,%d]\n", OM_Gw_current_OS, my_id*/

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	/*
	 * See if window is active.
	 */
	if( !(me->gragad.flags & IS_ACTIVE) ) {
		/*|Window not active*/
		goto wrapup ;
	}

	/*
	 * See if update could be done.
	 */
	if( ex$is_batch() || ige$SR_active() ) {
		/*|Don't do DPupdate*/
		goto wrapup ;
	}

	ex$disp_flag( flag = &quiet_flag ) ;

	if( quiet_flag ) {
		/*|Don't do DPupdate*/
		goto wrapup ;
	}

	if( !range )
		if( IGEstop() ) {
			/*|Don't do DPupdate*/
			goto wrapup ;
		}

	/*
	 * Update view.
	 */
	sts = om$send( msg	= message IGEgragad.DPupdate( msg,
							      range,
							      update_all ),
		       mode	= OM_e_wrt_message,
		       targetid = my_id ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*
	 * Retrieve children gragads ( X and Y gragad ).
	 */
	sts = om$send( msg	= message NDnode.NDget_objects( ND_CHILDREN,
								gragad_children,
								2,
								NULL,
								0,
								1,
								&gragad_count ),
		       targetid = my_id ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*
	 * Retrieve current module env ( because gragad is on current object
	 * space ).
	 */
	ex$get_cur_mod( id	= &md_env.md_id.objid,
			osnum	= &md_env.md_id.osnum ) ;

	md_env.md_env.matrix_type = MAIDMX ;
	MAidmx( &BSrc, md_env.md_env.matrix ) ;

	/*
	 * Update children gragads ( X and Y gragad ). The update window
	 * is perfomed on method NDcompute_node.
	 */
	for( i=0; i<2; i++ ) {
		/*"Update gragad : [%d,%d]\n", gragad_children[i].osnum, gragad_children[i].objid*/

		sts = om$send( msg	= message NDnode.NDs_compute_node(
								      msg,
								      ND_COMP,
								      &md_env ),
			       targetid = gragad_children[i].objid,
			       targetos = gragad_children[i].osnum ) ;

		as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
		as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;
	}

	/*
	 * Draw the border of the gragad.
	 */
	drawWnGridBorder( me->win_no,
			  me->min_x_dep,
			  me->min_y_dep,
			  me->max_x_dep,
			  me->max_y_dep ) ;

	wrapup :
		*msg = ( sts & *msg & 1 ) ? MSSUCC : MSFAIL ;

	return sts ;

} /* DPupdate */
/*----------------------------------------------------------------------------*/
method DPcvt_persp( long	*msg ;
		    int 	in_flag )
/*.DPcvt_persp*/ {

	tellUser( 1 ) ;
	*msg	     = MSSUCC ;
	return OM_S_SUCCESS ;

} /* DPcvt_persp */
/*----------------------------------------------------------------------------*/
method dynamics( long	*msg ;
		 double zoom_factor ;
		 double pan_factor ;
		 double max_rotate_factor ;
		 double stroke_scale_factor )
/*.dynamics*/ {

	tellUser( 2 ) ;
	*msg	     = MSSUCC ;
	return OM_S_SUCCESS ;

} /* dynamics */
/*----------------------------------------------------------------------------*/
method DProtate( long	*msg ;
		 short	flag ;
		 double *origin ;
		 double *mtx ;
		 short	update )
/*.DProtate*/ {

	int		sts,
			i, j,
			count,
			axis_found,
			axis[2] ;
	short		new_flag,
			update_all ;
	double		old_origin[3],
			old_rotation[4][4] ;
	struct GRid	cs_grid,
			me_grid,
			children[2] ;

extern long VDcheckConstWnGrid() ;

	/*"Gragad to rotate : [%d,%d]\n", OM_Gw_current_OS, my_id*/

	/*
	 * Save origin and rotation matrix.
	 */
	for( i=0; i<3; i++ )  old_origin[i] = me->gragad.origin[i] ;
	for( i=0; i<4; i++ )
		for( j=0; j<4; j++ )
			old_rotation[i][j] = me->gragad.rotation[i][j] ;

	/*
	 * Execute method.
	 */
	sts = om$send( msg	= message IGEgragad.DProtate( msg,
							      flag,
							      origin,
							      mtx,
							      FALSE ),
		       mode	= OM_e_wrt_message,
		       targetid = my_id ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*
	 * Retrieve parent coordinate system.
	 */
	sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
								&cs_grid,
								1,
								NULL,
								0,
								0,
								&count ),
		       targetid = my_id ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*
	 * See if window can display correctly planes set with new rotation.
	 */
	me_grid.osnum = OM_Gw_current_OS ;
	me_grid.objid = my_id ;

	sts = VDcheckConstWnGrid( msg,
				  &cs_grid,
				  &me_grid,
				  &axis_found,
				  axis,
				  axis+1 ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	if( !axis_found ) {
		/*|Cannot rotate view*/

		/*
		 * Set old origin and rotation matrix.
		 */
		new_flag = REPLACE_MTX ;

		sts = om$send( msg	= message IGEgragad.DProtate(
							    msg,
							    new_flag,
							    old_origin,
							    &old_rotation[0][0],
							    FALSE ),
		       mode	= OM_e_wrt_message,
		       targetid = my_id ) ;

		as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
		as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

		tellUser( 3 ) ;
	} else {
		/*
		 * Update view.
		 */
		if ( update ) {
		update_all = TRUE ;
		sts = om$send( msg	= message IGEgragad.DPupdate(
								  msg,
								  NULL,
								  &update_all ),
			       mode	= OM_e_wrt_message,
			       targetid = my_id ) ;

		}
		/*
		 * Retrieve gragad children.
		 */
		sts = om$send( msg	= message NDnode.NDget_objects(
								ND_CHILDREN,
								children,
								2,
								NULL,
								0,
								1,
								&count ),
		       targetid = my_id ) ;

		as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

		/*
		 * set new rotation and change the axis of the coordinate
		 * system to display to gragad children X and Y.
		 */
		for( i=0; i<2; i++ ) {
			sts = om$send( msg	= message IGEgragad.DProtate(
									msg,
									flag,
									origin,
									mtx,
									FALSE ),
				       senderid = children[i].objid,
				       targetid = children[i].objid,
				       targetos = children[i].osnum ) ;

			as$status( sts = sts,  action = GOTO_VALUE,
				   value = wrapup ) ;
			as$status( sts = *msg, action = GOTO_VALUE,
				   value = wrapup ) ;

			sts = om$send( msg	= message VDggxyGrid.change_axis_to_display(
								      msg,
								      axis[i] ),
				       targetid = children[i].objid,
				       targetos = children[i].osnum ) ;

			as$status( sts = sts,  action = GOTO_VALUE,
				   value = wrapup ) ;
			as$status( sts = *msg, action = GOTO_VALUE,
				   value = wrapup ) ;

		}

	}

	wrapup :

	return sts ;

} /* DProtate */
/*----------------------------------------------------------------------------*/
method DPset( long		*msg ;
	      long		*which_error ;
	      struct var_list	*varList )
/*.DPset*/ {

	/*
	 * See if want to copy view. In this case, we want to change
	 * GRAGAD_STRUCT.
	 */

	long			sts ;
	int			i,
				tell = FALSE,
				count,
				axis_found,
				axis[2],
				axis_displayed ;
	char			gragad_name[DI_PATH_MAX],
				*_grid ;
	struct var_list 	var_list1[2] ;
	struct DPgra_gad	old_gragad ;
	struct GRid		cs_grid,
				me_grid,
				children[2] ;
	struct GRmd_env 	md_env ;

extern long VDcheckConstWnGrid() ;

	*msg	     = MSSUCC ;
	*which_error = 0 ;
	sts	     = OM_S_SUCCESS ;

	/*"Gragad : [%d,%d]\n", OM_Gw_current_OS, my_id*/

	for( ;varList->var != END_PARAM; varList++ ) {

	 var_list1[0]	  = *varList ;
	 var_list1[1].var = END_PARAM ;

	   switch( varList->var ) {

		case GRAGAD_STRUCT	:

			/*
			 * Save old gragad structure.
			 */
			old_gragad = me->gragad ;

			/*
			 * Set new gragad structure.
			 */
			sts = om$send( msg	= message IGEgragad.DPset(
								    msg,
								    which_error,
								    var_list1 ),
				       mode	= OM_e_wrt_message,
				       targetid = my_id ) ;

			as$status( sts = sts,  action = GOTO_VALUE,
				   value = wrapup ) ;
			as$status( sts = *msg, action = GOTO_VALUE,
				   value = wrapup ) ;

			/*
			 * Retrieve parent coordinate system.
			 */
			sts = om$send( msg	= message NDnode.NDget_objects(
								       ND_ROOT,
								       &cs_grid,
								       1,
								       NULL,
								       0,
								       0,
								       &count ),
				       targetid = my_id ) ;

			as$status( sts = sts,  action = GOTO_VALUE,
				   value = wrapup ) ;

			/*
			 * See if window can display correctly planes set with
			 * new information.
			 */
			me_grid.osnum = OM_Gw_current_OS ;
			me_grid.objid = my_id ;

			sts = VDcheckConstWnGrid( msg,
						  &cs_grid,
						  &me_grid,
						  &axis_found,
						  axis,
						  axis+1 ) ;

			as$status( sts = sts,  action = GOTO_VALUE,
				   value = wrapup ) ;
			as$status( sts = *msg, action = GOTO_VALUE,
				   value = wrapup ) ;

			if( !axis_found ) {
				/*|Cannot modify view*/

				/*
				 * Set old gragad structure.
				 */
				var_list1[0].var_ptr = (char *) &old_gragad ;

				sts = om$send( msg	= message
							  IGEgragad.DPset(
								    msg,
								    which_error,
								    var_list1 ),
					       mode	= OM_e_wrt_message,
					       targetid = my_id ) ;

				as$status( sts = sts,  action = GOTO_VALUE,
					   value = wrapup ) ;
				as$status( sts = *msg, action = GOTO_VALUE,
					   value = wrapup ) ;

				tell = TRUE ;

			} else {
				/*
				 * Retrieve gragad children.
				 */
				sts = om$send( msg	= message
							  NDnode.NDget_objects(
								    ND_CHILDREN,
								    children,
								    2,
								    NULL,
								    0,
								    1,
								    &count ),
					       targetid = my_id ) ;

				as$status( sts = sts,  action = GOTO_VALUE,
					   value = wrapup ) ;

				/*
				 * For gragad childrens X and Y, if axis
				 * displayed is different from axis found,
				 * set new gragad structure and change the axis
				 * of the coordinate system to display.
				 */
				ex$get_cur_mod( id    = &md_env.md_id.objid,
						osnum = &md_env.md_id.osnum ) ;

				md_env.md_env.matrix_type = MAIDMX ;
				MAidmx( msg, md_env.md_env.matrix ) ;

				for( i=0; i<2; i++ ) {
				   sts = om$send( msg	   = message
						  VDggxyGrid.get_axis_displayed(
							      msg,
							      &axis_displayed ),
						  targetid = children[i].objid,
						  targetos = children[i].osnum ) ;

				   as$status( sts   = sts,  action = GOTO_VALUE,
					      value = wrapup ) ;
				   as$status( sts   = *msg, action = GOTO_VALUE,
					      value = wrapup ) ;

				   if( axis_displayed == axis[i] ) continue ;

				   /*
				    * Set new gragad structure and change the
				    * axis of the coordinate system to display.
				    */
				   sts = om$send( msg	   = message
						  VDggxyGrid.set_gragad_struct(
								  &me->gragad ),
						  targetid = children[i].objid,
						  targetos = children[i].osnum ) ;

				   as$status( sts    = sts,
					      action = GOTO_VALUE,
					      value  = wrapup ) ;

				   as$status( sts    = *msg,
					      action = GOTO_VALUE,
					      value  = wrapup ) ;

				   sts = om$send( msg	   = message
						  VDggxyGrid.change_axis_to_display(
								      msg,
								      axis[i] ),
						  targetid = children[i].objid,
						  targetos = children[i].osnum ) ;

				   as$status( sts    = sts,
					      action = GOTO_VALUE,
					      value  = wrapup ) ;

				   as$status( sts    = *msg,
					      action = GOTO_VALUE,
					      value  = wrapup ) ;

				   /*
				    * Update other gragad.
				    */
				   sts = om$send( msg	   = message
						  NDnode.NDs_compute_node(
								      msg,
								      ND_COMP,
								      &md_env ),
						  targetid = children[!i].objid,
						  targetos = children[!i].osnum ) ;

				   as$status( sts    = sts,
					      action = GOTO_VALUE,
					      value  = wrapup ) ;

				   as$status( sts    = *msg,
					      action = GOTO_VALUE,
					      value  = wrapup ) ;
				}
			}
			break ;

		case VIEW_ROTATION	:
		case VIEW_ORIGIN	:
		case VW_VOLUME		:
			tell = TRUE ;
			break ;

		case GRAGAD_NAME	:
			/*
			 * See if name is terminated with '_GRID', ortherwise
			 * add '_GRID' to name.
			 */
			strcpy( gragad_name, var_list1[0].var_ptr ) ;

			/*"Name given by user : %s\n", gragad_name*/

			_grid = &gragad_name[strlen(gragad_name)-5] ;

			if( strcmp( _grid, "_GRID" ) )
				strcat( gragad_name, "_GRID" ) ;

			/*"New name of window : %s\n", gragad_name*/

			var_list1[0].var_ptr   = gragad_name ;
			var_list1[0].num_bytes = strlen( gragad_name ) *
						 sizeof( char ) ;

			*varList = var_list1[0] ;

		default :

			/*"Set parameter to gragad : %d\n", varList->var*/

			sts = om$send( msg	= message IGEgragad.DPset(
								   msg,
								   which_error,
								   var_list1 ),
				       mode	= OM_e_wrt_message,
				       targetid = my_id ) ;

			as$status( sts = sts,  action = GOTO_VALUE,
				   value = wrapup ) ;
			as$status( sts = *msg, action = GOTO_VALUE,
				   value = wrapup ) ;

		}
	}

	if( tell ) tellUser( 4 ) ;

	wrapup :

	return sts ;

} /* DPset */
/*----------------------------------------------------------------------------*/
method DPset_persp( long	*msg ;
		    struct GRid *gg_id ;
		    short	in_flags,
				*ret_flags ;
		    double	*vrp,
				*vpn,
				*vup,
				*eye_pt,
				*coi,
				*vw_angle,
				*near,
				*far,
				*r_vrp,
				*r_vpn,
				*r_vup,
				*r_eye_pt,
				*r_coi,
				*r_vw_angle,
				*r_near,
				*r_far ; )
/*.DPset_persp*/ {

	*msg	= MSSUCC ;
	return	OM_S_SUCCESS ;

} /* DPset_persp */
/*----------------------------------------------------------------------------*/
method NDmove_to_root( long		*msg ;
		       struct GRid	*src_grid ;
		       struct GRmd_env	*md_env )
/*.NDmove_to_root*/ {

	long			sts ;
	struct GRid		me_grid ;

extern long VDchgWnGridToNomWind() ;

	/*
	 * One parent was deleted, so change window grid to normal window.
	 */
	me_grid.osnum = OM_Gw_current_OS ;
	me_grid.objid = my_id ;

	sts = VDchgWnGridToNomWind( msg,
				    &me_grid ) ;

	return sts ;

} /* NDmove_to_root */
/*----------------------------------------------------------------------------*/

/* Dummy method. Just returns success */
method NDcompute_node( long		*msg ;
		       int		cn_type ;
		       int		count ;
		       struct GRid	list[] ;
		       struct GRmd_env	*md_env )
/*.NDcompute_node*/ {

    *msg = MSSUCC;
    return OM_S_SUCCESS;
} /* NDcompute_node */

/*  Do not allow shading when window grid is on. This will solve the problem
    of window getting locked when shading a window with grid.
 */
method DPshading_allowed( IGRboolean *flag )
{

  ex$message( msgnumb = VD_E_VsCnShWn);
  *flag = FALSE;

 return OM_S_SUCCESS;
}


end implementation VDgragadGrid ;
