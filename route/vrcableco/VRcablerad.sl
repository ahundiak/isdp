/* $Id: VRcablerad.sl,v 1.1.1.1 2001/01/04 21:12:41 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcableco/VRcablerad.sl
 *
 * Description:
 *	"Modify cable bend radius" command.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcablerad.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/03/11  17:15:16  pinnacle
# Replaced: vrcableco/VRcablerad.sl for:  by hverstee for route240
#
# Revision 1.4  1996/03/04  22:56:42  pinnacle
# Replaced: vrcableco/VRcablerad.sl for:  by hverstee for route240
#
# Revision 1.3  1996/01/16  20:16:32  pinnacle
# Replaced: vrcableco/VRcablerad.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:19:02  pinnacle
# Replaced: vrcableco/VRcablerad.sl for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	10/10/91	AdZ	creation
 *	12/06/95	tlb		Remove VRcmd.h
 *	01/15/96	tlb		Add VX_FIproto.h
 *
 *************************************************************************/

/* --------------------------------------------------------------------- */
/* CLASS SPECIFICATION */

command_string	VRC_M_MdCbRd,0,VRMdCbRd
class		VRcablerad
super_class	VDB_LOCATE
product_name	"$ROUTE"
command_table	"route.cmd"

start_state	start

/* --------------------------------------------------------------------- */
/* SPECIFICATION AREA */

specification

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "growner.h"

instance
{
	struct	GRobj_env	component;

	IGRdouble		def_sect_radius;
	IGRdouble		def_bend_radius;
	IGRdouble		new_bend_radius;
}

/* --------------------------------------------------------------------- */
/* IMPLEMENTATION AREA */

implementation

#include <math.h>
#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igr.h"
#include "igrtypedef.h"
#include "griodef.h"
#include "go.h"
#include "godef.h"
#include "bstypes.h"
#include "bserr.h"
#include "ex.h"
#include "dp.h"
#include "grio.h"
#include "asbox.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "grmacros.h"
#include "comisc.h"
#include "comiscmac.h"
#include "nddef.h"
#include "ndmacros.h"
#include "VRmsg.h"
#include "AS_status.h"


%safe
#include "VX_FIproto.h"
%endsafe

from	GRvg		import GRgenabsg;
from	VRcable		import VRCbGetProps;
from	VRcable		import VRCbChaBendRad;
from	VRcable		import GRvtadjseg;
from	IGEgragad	import DPinrot;
from	GRgraphics	import GRptproject;
from	GRgraphics	import GRdisplay;

#define AS_DEBUG	1
#define	EPSILON		1.0E-12

extern			GRdisplay_object();

/* --------------------------------------------------------------------- */
/* STATES AREA */

state_table

#include "igrdef.h"
#include "dp.h"
#include "griodef.h" 
#include "VRmsg.h"

state start

	message			" Modify Cable Radius "
	prompt			" Select cable element "
	accept			" Accept / Reject "
	relocate		" Could not find cable element "
	locate_class		" VRcable "
	locate_properties	" LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		" LC_RIGID_COMP | LC_RIGID_OWNER
				| LC_FLEX_COMP | LC_FLEX_OWNER
				| LC_REF_OBJECTS"
	locate_display		" ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT
				| ALL_WINDOWS | LC_ERASE_ALL" 
	mask			"GRm_DATA|GRm_RJT_MOVEON|GRm_OBJID|GRm_BACK_UP"
	filter			locate

	on EX_BACK_UP						state -
	on EX_RJT_MOVEON					state terminate

	on EX_DATA or
	   EX_OBJID  	do VRCb_get_component( &me->ret )
			  on ERROR				state -
			do VRCb_show_bend_radius		state get_radius


state get_radius

	prompt		" Give bend radius or accept default [return] "
	mask		" GRm_DIST | GRm_RJT_MOVEON | GRm_BACK_UP "
	filter		get_event

	on DISTANCE	do VRCb_get_bend_radius( &me->ret )
			 on ERROR				state .
								state get_loc
	
	on EX_RJT_MOVEON					state terminate

	on EX_BACK_UP 						state -


state get_loc
 	execute		VRCb_display( &me->ret, FALSE  ) 

	prompt		" Locate near vertex or key in [a] for all "
	mask		" GRm_STRING | GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP "
	filter		get_event
	
	on EX_STRING	do VRCb_check_response( &me->ret )
			  on RETURN_CODE = FALSE		state error
			do VRCb_change_radius( &me->ret, TRUE )
			  on ERROR
			do status " Event not accepted "	state .
			do VRCb_display( &me->ret, TRUE )	state start

	on EX_DATA	do VRCb_change_radius( &me->ret, FALSE )
	  on ERROR	do status " Event not accepted "	state .
			do VRCb_show_bend_radius		state .

	on EX_BACK_UP	do VRCb_show_bend_radius		state -

	on EX_RJT_MOVEON do VRCb_display( &me->ret, TRUE )	state terminate


state error
	on ELSE		do status " Invalid data "		state -


at delete do VRCb_display( &me->ret, TRUE )

/*----------------------------------------------------------------------------*/
/* method init								     -*/
/*----------------------------------------------------------------------------*/
action init
{

  /*
   * Initialize instances data.
   */
  me->new_bend_radius		= -1.0;
  me->def_bend_radius		= -1.0;

  me->component.obj_id.objid 	= NULL_OBJID ;
  me->component.obj_id.osnum 	= OM_Gw_current_OS;

  status = om$send (    mode     = OM_e_wrt_message,
                        msg      = message VDB_LOCATE.init( type, str_ptr ),
                        targetid = my_id);

  return (status);

} /* init_cmd */ 


/*----------------------------------------------------------------------------*/
/* method VRCb_get_component						     -*/
/*----------------------------------------------------------------------------*/
action VRCb_get_component
{
IGRlong		msg;
  
  *sts = MSSUCC;
  msg = MSSUCC;

  me->component.obj_id  = me->event1.located_object[0].located_obj ;
  me->component.mod_env = me->event1.located_object[0].module_info ;
  /*^
    printf("component : [%d,%d]\n", 	me->component.obj_id.objid,
					me->component.obj_id.osnum );
   */

  /*| Get the default bend radius. */
  status = om$send( msg = message VRcable.VRCbGetProps(
					&msg,
					&me->component.mod_env,
					&me->def_sect_radius,
					&me->def_bend_radius,	
					NULL ),		/* cab length */
		   targetid = me->component.obj_id.objid,
		   targetos = me->component.obj_id.osnum,
		   senderid = NULL_OBJID );
  if( (!(status&1)) || (!(msg&1)) ){
    /*|  store_component: object not found */
    goto wrapup;
  }

  /*" def sect : %f\n", me->def_sect_radius */
  /*" def brad : %f\n", me->def_bend_radius */
  return( OM_S_SUCCESS );

wrapup:

  *sts = MSFAIL;
  return( OM_S_SUCCESS );

} /* VRCb_get_component */


/*----------------------------------------------------------------------------*/
/* method VRCb_get_bend_radius						     -*/
/*----------------------------------------------------------------------------*/
action VRCb_get_bend_radius 
{
IGRchar	msg_fld[100];

  /* initialize variables */
  *sts   = MSSUCC;

  /*" response typ: %d \n", me->event1.response */
  /*" event value : %f \n", me->event1.event.value */

  if( fabs( me->event1.event.value) < EPSILON ){

    /*| accept return response -> set default value */
    if( me->def_bend_radius >= me->def_sect_radius ){

      me->new_bend_radius = me->def_bend_radius;

      if( fabs( me->def_bend_radius - me->def_sect_radius ) < EPSILON ){
	/*| values are nearly equal */
	me->new_bend_radius = 1.0001 * me->def_bend_radius;
      }
    }
    else{
      /*| error message */
      goto wrapup;
    }
  }
  else{
    if( me->event1.event.value < me->def_sect_radius ){
      /*| new bend radius is to small */
      goto wrapup;
    }
    me->new_bend_radius = me->event1.event.value;
  }

  /*" radius : %f \n", me->new_bend_radius */
  return( OM_S_SUCCESS );

wrapup:

  sprintf( msg_fld, "Bend radius is smaller than section radius[%5.2f]",
							me->def_sect_radius );
  UI_status( msg_fld );

  *sts = MSFAIL;
  return( OM_S_SUCCESS );

} /* VRCb_get_bend_radius */ 


/*----------------------------------------------------------------------------*/
/* method VRCb_show_bend_radius						     -*/
/*----------------------------------------------------------------------------*/
action VRCb_show_bend_radius
{
IGRchar		msg_fld[60];

  *sts = MSSUCC;
  msg_fld[0] = '\0';
  /*
   * Initialize instances data.
   */
  if( me->new_bend_radius > 0.0 )
    sprintf( msg_fld," Active bend radius value: %5.2f ", me->new_bend_radius );
  else if( me->def_bend_radius > 0.0 )
    sprintf( msg_fld," Active bend radius value: %5.2f ", me->def_bend_radius );

  UI_status( msg_fld );

return( OM_S_SUCCESS );
} /* VRCb_show_bend_radius */ 


/*----------------------------------------------------------------------------*/
/* method VRCb_change_radius						     -*/
/*----------------------------------------------------------------------------*/

action VRCb_change_radius( int *sts; int global )
{
IGRlong 	msg;		/* return status for method	*/
IGRdouble	EventPnt[3];
IGRdouble	vwmat[16];

  /* initialize variables */
  *sts	= MSSUCC;
  msg	= MSSUCC;

  /*| get input point */
  EventPnt[0] = me->event1.event.button.x;
  EventPnt[1] = me->event1.event.button.y;
  EventPnt[2] = me->event1.event.button.z;

  status = om$send( msg      = message IGEgragad.DPinrot( &msg, vwmat ),
		    targetid = me->event1.event.button.objid,
		    targetos = me->event1.event.button.osnum );
  
  as$status( action = RET_STATUS, value = wrapup );

  /*"global : %d\n", global */
  status = om$send( msg      = message VRcable.VRCbChaBendRad(
					&msg,
					&me->component.mod_env,
					global,
					&me->new_bend_radius,
					EventPnt,
					&(vwmat[8]) ),
		    targetid = me->component.obj_id.objid,
		    targetos = me->component.obj_id.osnum,
		    senderid = NULL_OBJID );

  /*| test msg VRCbChaBendRad */
  as$status( action = RET_STATUS, value = wrapup );

  return( OM_S_SUCCESS );

wrapup:

  *sts = MSFAIL;
  return( OM_S_SUCCESS );
} /* VRCb_change_radius */ 

/*----------------------------------------------------------------------------*/
/* method VRCb_check_response		 				     -*/
/*----------------------------------------------------------------------------*/
action	VRCb_check_response( long *all )  
{

  /*" keyin: <%s>\n", me->event1.event.keyin */

  if( strcmp( "a", me->event1.event.keyin ) == 0 ||
      strcmp( "A", me->event1.event.keyin ) == 0  ) {
	/*| Change all vertices */
	*all = TRUE ;
  }
  else{	/*| Error in input */
	*all = FALSE ;
  }
} 


/*----------------------------------------------------------------------------*/
/* method VRCb_display							     -*/
/*----------------------------------------------------------------------------*/

action  VRCb_display ( int * sts; int disp_mode )
{
  enum GRdpmode	   Mode;

  if( disp_mode ) Mode = me->DisplayMode;
  else		  Mode = GRhhd;

  *sts = MSSUCC;
  if( me->component.obj_id.objid != NULL_OBJID )
  {
    status =
    om$send ( msg = message GRgraphics.GRdisplay
                                 ((IGRlong *) sts,
                                   &me->component.mod_env.md_env.matrix_type,
                                    me->component.mod_env.md_env.matrix,
       	                           &Mode,
       	                           &me->locate_ModuleInfo.md_id ),
	targetid = me->component.obj_id.objid,
	targetos = me->component.obj_id.osnum );

    as$status( action = RET_STATUS, value = wrapup );
  }
  return( OM_S_SUCCESS );

wrapup:
  *sts = MSFAIL;
  return( OM_S_SUCCESS );
}

/*----------------------------------------------------------------------------*/
/* end of file								      */
/*----------------------------------------------------------------------------*/
