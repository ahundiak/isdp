/* $Id: VDGridDel.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/imp / VDGridDel.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDGridDel.I,v $
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
# Revision 1.1  1995/07/24  18:43:06  pinnacle
# Created: vdvisual/imp/VDGridDel.I by hverstee for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation IGEgragad ;

#include <stdio.h>
#include "AS_status.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "nddef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "DIdef.h"

#define AS_DEBUG 1

from NDnode	import NDget_objects ;

/*

	Abstract :
	----------

	Given a gragad of a window grid, this function retrieves the gragad
	which display the view.

	Arguments :
	-----------

	OUT	long		*msg		Completion code.
	IN	struct GRid	*gragad 	Gragad of a window grid.
	OUT	struct GRid	*gragad_view	Gragad which display the view.

	Note :
	------

	If the given gragad isn't in a window grid, msg is MSFAIL and
	gragad_view is NULL_OBJID.

*/

/*----------------------------------------------------------------------------*/
long VDgetGragadGrid( msg, gragad, gragad_view )

long		*msg ;
struct GRid	*gragad ;
struct GRid	*gragad_view ;

/*.VDgetGragadGrid*/ {

	int		sts ;
	int		count ;
	OMuword 	classid ;
	struct GRid	gg_view ;

extern OMuword OPP_VDgragadGrid_class_id,
	       OPP_VDggxyGrid_class_id ;

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	gg_view.objid = NULL_OBJID ;
	gg_view.osnum = gragad->osnum ;

	/*
	 * Retrieve class of gragad.
	 */
	om$get_classid( objid	  = gragad->objid,
			osnum	  = gragad->osnum,
			p_classid = &classid ) ;

	/*
	 * See if given gragad is already the gragad which display the view.
	 */
	if( om$is_ancestry_valid( superclassid = OPP_VDgragadGrid_class_id,
				  subclassid   = classid )
				  == OM_S_SUCCESS ) {
		/*|Given gragad is already the gragad view*/
		gg_view  = *gragad ;
		goto wrapup ;
	}

	/*
	 * See if given gragad is in a window grid.
	 */
	if( !(om$is_ancestry_valid( superclassid = OPP_VDggxyGrid_class_id,
				    subclassid	 = classid )
				    == OM_S_SUCCESS ) ) {
		/*|Given gragad is not in window grid*/
		*msg = MSFAIL ;
		goto wrapup ;
	}

	/*
	 * Here the given gragad is a gragad on X or Y window direction, so
	 * retrieve parent #0 which is the gragad which display the view.
	 */
	sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
								&gg_view,
								1,
								NULL,
								0,
								0,
								&count ),
		       senderid = NULL_OBJID,
		       targetid = gragad->objid,
		       targetos = gragad->osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	wrapup :
		*gragad_view = gg_view ;

		/*"Gragad found : [%d,%d]\n", gragad_view->osnum, gragad_view->objid*/

		*msg = ( sts & 1 ) ? MSSUCC : MSFAIL ;

	return sts ;

} /* VDgetGragadGrid */
/*----------------------------------------------------------------------------*/

/*
	Abstract :
	----------

	This function change a window grid to a normal window.

	Arguments :
	-----------

	OUT	long		*msg		Completion code.
	IN	struct GRid	*gragad 	Gragad of a window grid.

	Note :
	------

	The three gragad gadgets of the window grid is deleted and a new
	gragad gadget is constructed.
*/

/*----------------------------------------------------------------------------*/
long VDchgWnGridToNomWind( msg, gragad )

long		*msg ;
struct GRid	*gragad ;

/*.VDchgWnGridToNomWind*/ {

	long			which_error,
				num_bytes ; 
	int			sts, i, cnt ;
	IGRuint			count ;
	struct var_list 	var_list[3] ;
	struct gragad_inst	gragad_inst ;
	char			*name,
				gragad_name[DI_PATH_MAX] ;
	struct GRid		gg[3],
				window,
				new_gg ;
	OM_S_CHANSELECT 	chandef,
				chandef1 ;
	OM_S_OBJECT_LINKAGE	channel_object ;

	chandef.type		= OM_e_name ;
	chandef.u_sel.name	= "IGEgadget.to_parent" ;

	chandef1.type		= OM_e_name ;
	chandef1.u_sel.name	= "IGEgadget.to_children" ;

	/*
	 * Retrieve gragad view.
	 */
	sts = VDgetGragadGrid( msg,
			       gragad,
			       &gg[0] ) ;

	if( (*msg == MSFAIL) && (sts == OM_S_SUCCESS) ) {
		/*|gragad isn't a window grid*/
		*msg = MSSUCC ;
		goto wrapup ;
	}

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*"Gragad to modify in normal window : [%d,%d]\n", gg[0].osnum, gg[0].objid*/

	new_gg.osnum = gg[0].osnum ;

	/*
	 * Retrieve gragad children ( gragad X and Y ) of gragad view.
	 */
	sts = om$send( msg	= message NDnode.NDget_objects( ND_CHILDREN,
								&gg[1],
								2,
								NULL,
								0,
								1,
								&cnt ),
		       senderid = NULL_OBJID,
		       targetid = gg[0].objid,
		       targetos = gg[0].osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*|Gragad children : */
	/*"\t[%d,%d]\n", gg[1].osnum,gg[1].objid*/
	/*"\t[%d,%d]\n", gg[2].osnum,gg[2].objid*/

	/*
	 * Retrieve instance data of gragad view.
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
		       targetid = gg[0].objid,
		       targetos = gg[0].osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*"Gragad name of gragad view : %s\n", gragad_name*/

	/*
	 * Retrieve graphic window where gragad view is.
	 */
	sts = om$get_channel_objects( osnum	   = gg[0].osnum,
				      objid	   = gg[0].objid,
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
	 * Delete all gragad gadget on the window.
	 */
	for( i=2; i>=0; i-- ) {
		sts = om$send( msg	= message IGEgragad.delete( 1 ),
			       senderid = NULL_OBJID,
			       targetid = gg[i].objid,
			       targetos = gg[i].osnum ) ;

		as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	}

	/*
	 * Disconnect all gragads from the window.
	 */
	sts = om$send( msg	= message Root.wild_disconnect( chandef1 ),
		       senderid = NULL_OBJID,
		       targetid = window.objid,
		       targetos = window.osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;

	/*
	 * Construct new gragad gadget.
	 */
	name = &gragad_name[strlen(gragad_name)-5] ;

	if( !strcmp( name, "_GRID" ) )
		gragad_name[strlen(gragad_name)-5] = '\0' ;

	name = gragad_name ;

	/*"name of new gragad : %s\n", name*/

	sts = om$construct( classname	= "IGEgragad",
			    osnum	= new_gg.osnum,
			    obj_osnum	= new_gg.osnum,
			    p_objid	= &new_gg.objid,
			    msg 	= message IGEgragad.gragad_cons(
									msg,
									name,
									0.,
									0.,
									1.,
									1. ) ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*"gragad construct : [%d,%d]\n", new_gg.osnum, new_gg.objid*/

	/*
	 * Set view the same as gragad view.
	 */
	sts = VDcopyView( msg,
			  &gragad_inst.gragad,
			  &new_gg ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*
	 * Add gragad gadget to graphic window.
	 */
	sts = om$send( msg	= message IGEgragad.add_gadget( msg,
								&new_gg.objid,
								1 ),
		       senderid = NULL_OBJID,
		       targetid = window.objid,
		       targetos = window.osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	wrapup :
		*msg = ( sts & 1 & *msg ) ? MSSUCC : MSFAIL ;

	return sts ;

} /* VDchgWnGridToNomWind */
/*----------------------------------------------------------------------------*/

end implementation IGEgragad ;
