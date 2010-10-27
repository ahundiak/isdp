/* $Id: VDggxyGridi.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/imp / VDggxyGridi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDggxyGridi.I,v $
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

class implementation VDggxyGrid ;

#include <stdio.h>
#include <math.h>
#include "AS_status.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "nddef.h"
#include "msmacros.h"
#include "expmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "bserr.h"
#include "bstypes.h"

#include "VDmsg.h"


from GRgencs	import GRgetmatrix ;

from expression import NDgive_value;   /* Import for 2.0 */

#define AS_DEBUG 1

/* Prototypes */
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bsdotp.h"

extern void	tellUser() ;

/*----------------------------------------------------------------------------*/
method NDcompute_node( long		*msg ;
		       int		cn_type ;
		       int		count ;
		       struct GRid	list[] ;
		       struct GRmd_env	*md_env )
/*.NDcompute_node*/ {

	long		sts,
			which_error,
			num_bytes;
	BSrc            bsrc ;
	int		i,
			axis_gragad ;
	short		vw_flag ;
	struct var_list var_list[2] ;
	double		wld_vol[6],
			local_to_wld[16],
			cs_origin[3],
			vector[3],
			normV1,
			normV2,
			ref_axis[3],
			view_volume[6],
			display_depth[6],
			old_view_volume[6] ;

	/*"Gragad : [%d,%d]\n", OM_Gw_current_OS, my_id*/
	/*|Parents of gragad*/
	/*"\t0 (gragad view)	     : [%d,%d]\n", list[0].osnum, list[0].objid*/
	/*"\t1 (coordinate system)   : [%d,%d]\n", list[1].osnum, list[1].objid*/
	/*"\t2 (expression for axis) : [%d,%d]\n", list[2].osnum, list[2].objid*/

	/*
	 * Retrieve world volume of gragad view.
	 */
	var_list[0].var 		= WLD_VOLUME ;
	var_list[0].var_ptr		= (char *) wld_vol ;
	var_list[0].num_bytes		= sizeof( double ) * 6 ;
	var_list[0].bytes_returned	= &num_bytes ;

	var_list[1].var 		= END_PARAM ;

	sts = om$send( msg	= message IGEgragad.DPinquire( msg,
							       &which_error,
							       var_list ),
		       targetid = list[0].objid,
		       targetos = list[0].osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*|World volume of parent gragad*/
	/*"min : %f %f %f\n", wld_vol[0], wld_vol[1], wld_vol[2]*/
	/*"max : %f %f %f\n", wld_vol[3], wld_vol[4], wld_vol[5]*/

	/*
	 * Retrieve local-to-world transformation matrix of coordinate system.
	 */
	sts = om$send( msg	= message GRgencs.GRgetmatrix( msg,
							       local_to_wld ),
		       targetid = list[1].objid,
		       targetos = list[1].osnum ) ;

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

	cs_origin[0] = local_to_wld[3]	;
	cs_origin[1] = local_to_wld[7]	;
	cs_origin[2] = local_to_wld[11] ;

	/*
	 * Retrieve axis displayed.
	 */
	sts = om$send( msg	= message VDggxyGrid.get_axis_displayed(
								 msg,
								 &axis_gragad ),
		       targetid = my_id ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*"Axis of coordinate to display : %d\n", axis_gragad*/

	/*
	 * Project first point ( minimum of working view volume )
	 * on the axis of the coordinate system.
	 */
	BSmkvec( &bsrc, vector, cs_origin, wld_vol ) ;
	normV1 = sqrt( BSdotp( &bsrc, vector, vector ) ) ;
	BSnorvec( &bsrc, vector ) ;

	ref_axis[0] = local_to_wld[ axis_gragad   ] ;
	ref_axis[1] = local_to_wld[ axis_gragad+4 ] ;
	ref_axis[2] = local_to_wld[ axis_gragad+8 ] ;

	normV2 = normV1 * BSdotp( &bsrc, ref_axis, vector ) ;

	view_volume[0] = cs_origin[0] + normV2 * ref_axis[0] ;
	view_volume[1] = cs_origin[1] + normV2 * ref_axis[1] ;
	view_volume[2] = cs_origin[2] + normV2 * ref_axis[2] ;

	/*
	 * Project second point ( maximum of working view volume )
	 * on the axis of the coordinate system.
	 */
	BSmkvec( &bsrc, vector, cs_origin, &wld_vol[3] ) ;
	normV1 = sqrt( BSdotp( &bsrc, vector, vector ) ) ;
	BSnorvec( &bsrc, vector ) ;

	normV2 = normV1 * BSdotp( &bsrc, ref_axis, vector ) ;

	view_volume[3] = cs_origin[0] + normV2 * ref_axis[0] ;
	view_volume[4] = cs_origin[1] + normV2 * ref_axis[1] ;
	view_volume[5] = cs_origin[2] + normV2 * ref_axis[2] ;

	/*|World volume of gragad*/
	/*"min : %f %f %f\n", view_volume[0], view_volume[1], view_volume[2]*/
	/*"max : %f %f %f\n", view_volume[3], view_volume[4], view_volume[5]*/

	/*
	 * Set same display depth, otherwise display depth will be set
	 * according to the new view volume. ( display depth should be inside
	 * view volume but new view volume is equal for example to (0,0,A)
	 * (0,0,B) )
	 */
	display_depth[2] = me->gragad.vw_volume[2] ;
	display_depth[5] = me->gragad.vw_volume[5] ;

	/*"Display depth of gragad : %f %f\n", display_depth[2], display_depth[5]*/

	/*
	 * Set new view volume without update.
	 */
	vw_flag = FRONT_CLIP	|
		  BACK_CLIP	|
		  WORLD_COOR	|
		  SETIN 	;

	for( i=0; i<6; i++ ) old_view_volume[i] = me->gragad.vw_volume[i] ;

	sts = om$send( msg	= message IGEgragad.DPview_vol( msg,
								vw_flag,
								NULL,
								NULL,
								NULL,
								view_volume,
								display_depth,
								NULL,
								NULL,
								NULL,
								NULL,
								NULL,
								NULL,
								NULL,
								FALSE ),
		       targetid = my_id ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*
	 * Change 2.0, the display depth is modified by the above message,
	 * so restore it.
	 */
	me->gragad.vw_volume[2] = display_depth[2] ;
	me->gragad.vw_volume[5] = display_depth[5] ;

	/*
	 * If view volume calculated is not equal to old view volume then
	 * update view.
	 */
	if( me->gragad.vw_volume[0] != old_view_volume[0] ||
	    me->gragad.vw_volume[1] != old_view_volume[1] ||
	    me->gragad.vw_volume[3] != old_view_volume[3] ||
	    me->gragad.vw_volume[4] != old_view_volume[4] ) {
		short	update_all = FALSE ;

		/*|Update view*/

		sts = om$send( msg	= message IGEgragad.DPupdate(
								  msg,
								  NULL,
								  &update_all ),
			       targetid = my_id ) ;

		as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
		as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;
	} else {
		/*|Don't update view*/
	}

	wrapup :
		*msg = ( sts & *msg & 1 ) ? MSSUCC : MSFAIL ;

	return sts ;

} /* NDcompute_node */
/*----------------------------------------------------------------------------*/
method DPview_vol( long 	*msg ;
		   short	flags ;
		   short	*ret_flags ;
		   double	*origin ;
		   double	*rotation ;
		   double	*vw_vol ;
		   double	*display_depths ;
		   double	*active_z ;
		   short	*defaults_vol ;
		   short	*def_dis_depths ;
		   double	*new_vw_vol ;
		   double	*new_display_depths ;
		   double	*new_active_z ;
		   double	*new_coor_vol ;
		   short	update )
/*.DPview_vol*/ {

	long	sts ;
	short	sender_is_me = FALSE ;

	/*
	 * If senderid is me, execute message with all parameters. Otherwise
	 * execute message with some parameters.
	 */
	if( ( sender_id == my_id ) &&
	    ( sender_os == OM_Gw_current_OS ) )
		sender_is_me = TRUE ;

	if( !sender_is_me	&
	    !display_depths	&
	    !active_z		&
	    !def_dis_depths	) {
		/*|Cannot execute method*/
		tellUser( 0 ) ;
		*msg = MSSUCC ;
		return OM_S_SUCCESS ;
	}

	sts = om$send( msg	= message IGEgragad.DPview_vol(
							 msg,
							 flags,
							 ret_flags,
					  sender_is_me ? origin 	: NULL,
					  sender_is_me ? rotation	: NULL,
					  sender_is_me ? vw_vol 	: NULL,
							 display_depths,
							 active_z,
					  sender_is_me ? defaults_vol	: NULL,
							 def_dis_depths,
							 new_vw_vol,
							 new_display_depths,
							 new_active_z,
							 new_coor_vol,
							 update ),
		       mode	= OM_e_wrt_message,
		       targetid = my_id ) ;

	return sts ;

} /* DPview_vol */
/*----------------------------------------------------------------------------*/
method DPscroll( long	*msg ;
		 double *wld_points ;
		 short	update )
/*.DPscroll*/ {

	tellUser( 0 ) ;
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* DPscroll */
/*----------------------------------------------------------------------------*/
method DPcenter( long	*msg ;
		 double *wld_points ;
		 short	update )
/*.DPcenter*/ {

	tellUser( 0 ) ;
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* DPcenter */
/*----------------------------------------------------------------------------*/
method DPwnarea( long	*msg ;
		 int	in_flag ;
		 double *wld_points ;
		 short	update )
/*.DPwnarea*/ {

	tellUser( 0 ) ;
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* DPwnarea */
/*----------------------------------------------------------------------------*/
method DPzoom( long	*msg ;
	       short	in_out_flag ;
	       double	*center_pnt ;
	       double	factor ;
	       short	update )
/*.DPzoom*/ {

	tellUser( 0 ) ;
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* DPzoom */
/*----------------------------------------------------------------------------*/
method DPfit( long	*msg ;
	      int	fit_flag )
/*.DPfit*/ {

	tellUser( 0 ) ;
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* DPfit */
/*----------------------------------------------------------------------------*/
method DPset( long		*msg ;
	      long		*which_error ;
	      struct var_list	*varList )
/*.DPset*/ {

	/*
	 * Just set parameters some parameters.
	 */

	long		sts ;
	struct var_list var_list1[2] ;
	struct GRid	parent_gragad ;
	int		tell = FALSE,
			get_parent = TRUE,
			count ;

#define IF_PARAM( param )\
	(varList->var == (param) ? TRUE : FALSE)

	*msg	     = MSSUCC ;
	*which_error = 0 ;
	sts	     = OM_S_SUCCESS ;

	/*"Gragad : [%d,%d]\n", OM_Gw_current_OS, my_id*/

	for( ;!IF_PARAM( END_PARAM ); varList++ ) {

		var_list1[0]	 = *varList ;
		var_list1[1].var = END_PARAM ;

		if( IF_PARAM( GRID_PER_REF_X	) |
		    IF_PARAM( GRID_PER_REF_Y	) |
		    IF_PARAM( UOR_PER_REF_X	) |
		    IF_PARAM( UOR_PER_REF_Y	) |
		    IF_PARAM( GRAGAD_FLAGS	) |
		    IF_PARAM( FONT_OS_PTR	) |
		    IF_PARAM( LEVELS		) ) {

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

			continue ;

		}

		if( IF_PARAM( GRAGAD_NAME ) ) {

			/*"Set parameter to parent gragad : %d\n", varList->var*/

			if( get_parent ) {

				sts = om$send( msg	=
					       message NDnode.NDget_objects(
								 ND_ROOT,
								 &parent_gragad,
								 1,
								 NULL,
								 0,
								 0,
								 &count ),
				       targetid = my_id ) ;

				as$status( sts = sts,  action = GOTO_VALUE,
					   value = wrapup ) ;

				/*"Parent gragad : [%d,%d]\n", parent_gragad.osnum, parent_gragad.objid*/

				get_parent = FALSE ;
			}

			sts = om$send( msg	= message IGEgragad.DPset(
								  msg,
								  which_error,
								  var_list1 ),
				       targetid = parent_gragad.objid,
				       targetos = parent_gragad.osnum ) ;

			as$status( sts = sts,  action = GOTO_VALUE,
				   value = wrapup ) ;
			as$status( sts = *msg, action = GOTO_VALUE,
				   value = wrapup ) ;

			continue ;
		}

		/*"Don't set parameter : %d\n", varList->var*/
		tell = TRUE ;
	}

#undef IF_PARAM

	wrapup :

	if( tell ) tellUser( 0 ) ;

	return sts ;

} /* DPset */
/*----------------------------------------------------------------------------*/
method DProtate( long	*msg ;
		 short	flag ;
		 double *origin ;
		 double *mtx ;
		 short	update )
/*.DProtate*/ {

	long	sts ;

	/*
	 * If senderid isn't me don't execute method.
	 */
	if( ( sender_id != my_id ) ||
	    ( sender_os != OM_Gw_current_OS ) )  {
		tellUser( 0 ) ;
		*msg	     = MSSUCC ;
		return OM_S_SUCCESS ;
	}

	sts = om$send( msg	= message IGEgragad.DProtate( msg,
							      flag,
							      origin,
							      mtx,
							      update ),
		       mode	= OM_e_wrt_message,
		       targetid = my_id ) ;

	return sts ;

} /* DProtate */
/*----------------------------------------------------------------------------*/
method DPcvt_persp( long	*msg ;
		    int 	in_flag )
/*.DPcvt_persp*/ {

	tellUser( 0 ) ;
	*msg	     = MSSUCC ;
	return OM_S_SUCCESS ;

} /* DPcvt_persp */
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
method DPlevels( long	*msg ;
		 int	*levels,
			num_of_entries,
			*level_mask ;
		 short	on_off,
			update ; )
/*.DPlevels*/ {

	long	sts,
		num_bytes,
		num_bytes_ret ;
	int	i,
		j = 0,
		*temp_level = NULL,
		temp_level_mask[32] ;
	short	act_layer ;

	/*
	 * This method is overriden at this level to turn on all layers
	 * given except active layer.
	 */
	if( on_off ) {
		/*|Turn levels ON*/

		/*
		 * Retrieve active layer.
		 */
		num_bytes = sizeof( short ) ;

		gr$get_active_level( msg	= msg,
				     sizbuf	= &num_bytes,
				     buffer	= &act_layer,
				     nret	= &num_bytes_ret ) ;

		/*"Active layer : %d\n", act_layer*/

		/*
		 * Extract active layer from given lists.
		 */
		if( levels ) {
			/*|List of levels to turn on :*/
			/*"Number of levels : %d\n", num_of_entries*/

			temp_level = (int *) malloc( num_of_entries *
						     sizeof( int ) ) ;

			for( i=0, j=0; i<num_of_entries; i++ ) {

				if( levels[i] != act_layer ) {
					/*"\t%d\n", levels[i]*/
					temp_level[j] = levels[i] ;
					j++ ;
				} else
				 {
			/*"\t%d Active level -> Don't turn on\n", levels[i]*/
				 }
			}
		}

		if( level_mask ) {
			for( i=0; i<32; i++ )
				temp_level_mask[i] = level_mask[i] ;

			temp_level_mask[act_layer/32] &=
					~((int) (1 << (act_layer % 32) ) ) ;

			/*"Level mask given for active layer : %d\n", level_mask[act_layer/32]*/
			/*"New level mask : %d\n", temp_level_mask[act_layer/32]*/

		}

		/*
		 * Turn levels on.
		 */
		sts = om$send( msg	= message IGEgragad.DPlevels(
					    msg,
					    levels ? temp_level : NULL,
					    levels ? j : 0,
					    level_mask ? temp_level_mask : NULL,
					    on_off,
					    update ),
			       mode	= OM_e_wrt_message,
			       targetid = my_id ) ;

		if( temp_level ) free( (char *) temp_level ) ;

	} else {
		/*|Turn levels OFF*/

		/*
		 * Turn off all levels given.
		 */
		sts = om$send( msg	= message IGEgragad.DPlevels(
								 msg,
								 levels,
								 num_of_entries,
								 level_mask,
								 on_off,
								 update ),
			       mode	= OM_e_wrt_message,
			       targetid = my_id ) ;
	}

	return sts ;

} /* DPlevels */
/*----------------------------------------------------------------------------*/
method dynamics( long	*msg ;
		 double zoom_factor ;
		 double pan_factor ;
		 double max_rotate_factor ;
		 double stroke_scale_factor )
/*.dynamics*/ {

	tellUser( 0 ) ;
	*msg	     = MSSUCC ;
	return OM_S_SUCCESS ;

} /* dynamics */
/*----------------------------------------------------------------------------*/
method delete( int f_defer_flag )
/*.delete*/ {

	long		sts ;
	int		count ;
	struct GRid	exp ;

	/*"Gragad to delete : [%d,%d]\n", OM_Gw_current_OS, my_id*/

	/*
	 * Delete expression.
	 */
	sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
								&exp,
								1,
								NULL,
								2,
								2,
								&count ),
		       targetid = my_id ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*"Delete expression : [%d,%d]\n", exp.osnum, exp.objid*/

	sts = om$send( msg	= message Root.delete(1),
		       targetid = exp.objid,
		       targetos = exp.osnum ) ;

	wrapup :

		/*
		 * Delete gragad.
		 */
		sts = om$send( msg	= message IGEgragad.delete(1),
			       mode	= OM_e_wrt_message,
			       targetid = my_id ) ;

	return sts ;

} /* delete */
/*----------------------------------------------------------------------------*/
method get_axis_displayed( long 	*msg ;
			   int		*axis )
/*.get_axis_displayed*/ {

	long		sts ;
	int		count ;
	double		axis_DBL ;
	struct GRid	exp ;

	/*"Get axis displayed of gragad : [%d,%d]\n", OM_Gw_current_OS, my_id*/

	*axis = -1 ;

	/*
	 * Retrieve parent expression.
	 */
	sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
								&exp,
								1,
								NULL,
								2,
								2,
								&count ),
		       targetid = my_id ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*"Parent expression : [%d,%d]\n", exp.osnum, exp.objid*/

	/*
	 * Get value of parent expression.
	 */
	/* Change 2.0 : message expression.NDgive_value instead of
	   NDnode.NDgive_value. */
	sts = om$send( msg	= message expression.NDgive_value( &axis_DBL ),
		       targetid = exp.objid,
		       targetos = exp.osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	*axis = (int) axis_DBL ;

	/*"Axis displayed : %d\n", *axis*/

	wrapup :
		*msg = ( sts & 1 & *msg ) ? MSSUCC : MSFAIL ;
		return sts ;

} /* get_axis_displayed */
/*----------------------------------------------------------------------------*/
method change_axis_to_display( long	*msg ;
				int	new_axis )
/*.change_axis_to_display*/ {

	long		sts ;
	int		count ;
	struct GRid	exp ;
	char		syntax[20] ;

	/*"Change axis to display of gragad:[%d,%d]\n",OM_Gw_current_OS, my_id*/

	/*
	 * Retrieve expression parent.
	 */
	sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
								&exp,
								1,
								NULL,
								2,
								2,
								&count ),
		       targetid = my_id ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*"Expression : [%d,%d]\n", exp.osnum, exp.objid*/

	/*"New value : %d\n", new_axis*/

	sprintf( syntax, "%d", new_axis ) ;

	/*
	 * Change value of expression.
	 */
	exp$modify( osnum	= exp.osnum,
		    exp_id	= exp.objid,
		    exp_syntax	= syntax ) ;

	wrapup :

	*msg = ( sts & 1 & *msg ) ? MSSUCC : MSFAIL ;

	return sts ;

} /* change_axis_to_display */
/*----------------------------------------------------------------------------*/
method set_gragad_struct( struct DPgra_gad	*gragad_struct )
/*.set_gragad_struct */ {

	int	gpipe_id ;
	double	display_depth[2] ;

	/*"Change gragad structure of gragad : [%d,%d]\n", OM_Gw_current_OS, my_id*/

	/*
	 * Don't change gpipe id and display depth.
	 */
	gpipe_id		= me->gragad.gpipe_id ;
	display_depth[0]	= gragad_struct->vw_volume[2] ;
	display_depth[1]	= gragad_struct->vw_volume[5] ;

	me->gragad		= *gragad_struct ;

	me->gragad.gpipe_id	= gpipe_id ;
	me->gragad.vw_volume[2] = display_depth[0] ;
	me->gragad.vw_volume[5] = display_depth[1] ;

	return OM_S_SUCCESS ;

} /* set_gragad_struct */
/*----------------------------------------------------------------------------*/

/*  Do not allow shading when window grid is on. This will solve the problem
    of window getting locked when shading a window with grid
 */
method DPshading_allowed( IGRboolean *flag )
{
                       
  ex$message( msgnumb = VD_E_VsCnShWn);
  *flag = FALSE;


 return OM_S_SUCCESS;

}

end implementation VDggxyGrid ;
