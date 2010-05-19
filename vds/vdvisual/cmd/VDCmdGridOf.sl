/* $Id: VDCmdGridOf.sl,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/cmd / VDCmdGridOf.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdGridOf.sl,v $
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/31/97	ah		Get rid of status/quit warnings
 * -------------------------------------------------------------------*/

/*
	I/VDS
	"Turn Window Grid Off" command.
*/
command_string	VDC_M_TrWnGrOf, 0, VDTrWnGrOf
command_table	"vds.cmd"
class		VDCmdGridOf
super_class	VDS_LOCATE
product_name	"$VDS"

specification

instance {
	struct GRid	window ;
}

implementation

#include <stdio.h>
#include "AS_status.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#define AS_DEBUG 1

#define VD_K_ACT_SUCCESS	0x001
#define VD_K_RESTART_CMD	0x002
#define VD_K_NO_WINDOW		0x004
#define VD_K_NO_WN_GRID		0x008

state_table

#include "grmessage.h"
#include "VDmsg.h"

#define VD_K_ACT_SUCCESS	0x001
#define VD_K_RESTART_CMD	0x002
#define VD_K_NO_WINDOW		0x004
#define VD_K_NO_WN_GRID		0x008

state start
	message_key	VD_M_TrWnGrOf
	prompt_key	VD_P_VsIdWnGr
	filter		get_event

	on EX_DATA or EX_STRING
		do store_window( &me->ret )
			on RETURN_CODE = "VD_K_NO_WINDOW"
				do status_key VD_E_VsInvWin	state .
			on RETURN_CODE = "VD_K_NO_WN_GRID"
				do status_key VD_E_VsNoWnGr	state .
			on RETURN_CODE = "VD_K_RESTART_CMD"	state rstCmd

		 do change_window( &me->ret )
			on RETURN_CODE = "VD_K_RESTART_CMD"	state rstCmd
								state .


state rstCmd
	status_key GR_E_ErrEncCmdRst
	on ELSE							state start

/*----------------------------------------------------------------------------*/
action store_window( long *msg )
/*.store_window*/ {

	struct GRid		curMod ;
	long			sts ;
	char			path[80] ,
				path_buf[80] ;
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
	 * See if window is a window grid.
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
		/*|Window is a window grid*/
		*msg = VD_K_ACT_SUCCESS ;
	} else {
		/*|Window isn't a window grid*/
		*msg = VD_K_NO_WN_GRID ;
	}

} /* store_window */
/*----------------------------------------------------------------------------*/
action change_window( long *msg ) 
/*.change_window*/ {
	
	long	sts ;
	
extern long VDchgWnGridToNomWind() ;

// Get rid of warnings
if (status);
if (0) goto quit;


	sts = VDchgWnGridToNomWind( msg,
				    &me->window ) ;
	
	*msg = ( sts & *msg & 1 ) ? VD_K_ACT_SUCCESS : VD_K_RESTART_CMD ;
	
} /* change_window */
/*----------------------------------------------------------------------------*/

