/* $Id: VDCmdMeas.sl,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdmeasure/cmd/VDCmdMeas.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdMeas.sl,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:56  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.3  1996/11/16  15:55:24  pinnacle
# Replaced: vdmeasure/cmd/VDCmdMeas.sl for:  by v241_int for vds.241
#
# Revision 1.2  1996/11/11  16:20:42  pinnacle
# Replaced: vdmeasure/cmd/VDCmdMeas.sl for:  by v241_int for vds.241
#
# Revision 1.1  1996/11/08  21:48:08  pinnacle
# Created: vdmeasure/cmd/VDCmdMeas.sl by v241_int for vds.241
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/08/96        mf              creation date
 *	11/16/96	mf		first revision.
 ***************************************************************************/

/* *****************************************************************************

	CLASS NAME :	VDCmdMeas

	ABSTRACT   :	I/VDS distance between two objects.

***************************************************************************** */

command_string	"Measure Distance Between Elements", 0, VDMeDiBe
command_table	"vds.cmd"
class		VDCmdMeas
super_class	COmeasure
product_name	"$VDS"
status_display	"MeasDist", "-1", "-1"
form		"LinReadout", 2002, 0, "520", "105"

start_state	START

specification

#include	"growner.h"
#include	"vdmeasure.h"

instance {

	IGRboolean			Typ[4];
	struct		VDmeasure	Mea;
	IGRint				FormDisplayable;
}

implementation

#include	<stdio.h>
#include	<string.h>
#include	"AS_status.h"
#include	"grmacros.h"
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"dpstruct.h"
#include	"dpdef.h"
#include	"dpmacros.h"
#include	"comeasure.h"

#include	"v_miscmacros.h"
#include	"vdAPIequips.h"
#include	"vdmeasure.h"
#include	"vdmeaprotos.h"

#include	"VDmsg.h"

from	GRgraphics	import	GRaddwrng, GRdelete, GRremwrng;

state_table

#include	"comisc.h"
#include	"VDmsg.h"

/* ************************************************************************** */
state	*
	on	EX_RESTART
		do	clear_fields
		do	is_form_displayed
			on MSSUCC
			do	update_meas_form
			state	START
		state	START
/* ************************************************************************** */
at init
	do	VDinitMeasure ( &me->ret )
	do	display_active_parms ( &me->ret, CO_ABSOLUTE | CO_APPARENT )
	do	VDstatusDisplayAccess ( 1 )

at wakeup
	do	display_mode	GRhhd
	do	display_first_located_object
	do	VDstatusDisplayButton ( &me->ret )
	do	update_meas_form

at sleep
	do	erase_hilite
	do	status_display_button ( 0 )

at delete	
	do	VDcleanMeasure ( &me->ret )
	do	VDstatusDisplayAccess ( 0 )
	do	VDstatusDisplayButton ( &me->ret )
/* ************************************************************************** */
state START
	message_key		VD_S_MEASURE_DISTANCE
	execute			VDcleanMeasure (&me->ret)
	execute			VDstatusDisplayAccess ( 1 )
	execute			VDstatusDisplayButton (&me->ret)

	on ELSE							state FIRST
/* ************************************************************************** */
state FIRST
	prompt_key		VD_P_MEAS_OBJ1
	accept_key		VD_M_MEAS_OBJ1
	locate_eligible		"+GRcurve,GRlbsys,EMSsurface"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
                       	 	 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                       	 	 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

	on EX_BACK_UP						state START
	on EX_RJT_MOVEON					state FIRST
	on EX_DATA		do clear_fields
				do display_mode GRhhd
				do VDstoreObject (0,&me->ret)	state SECND
/* ************************************************************************** */
state SECND
	prompt_key		VD_P_MEAS_OBJ2
	accept_key		VD_M_MEAS_OBJ2
	locate_eligible		"+GRcurve,GRlbsys,EMSsurface"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
                        	 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                        	 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

	on EX_BACK_UP						state FIRST
	on EX_RJT_MOVEON					state SECND
	on EX_DATA		do VDstoreObject (1,&me->ret)	state PLANE
/* ************************************************************************** */
state PLANE
	prompt_key		VD_P_MEAS_PLAN
	accept_key		VD_M_MEAS_PLAN
	locate_eligible		"+EMSplane"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
                         	LC_FLEX_COMP   | LC_FLEX_OWNER  |
                         	LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

	on EX_BACK_UP						state SECND
	on EX_RJT_MOVEON					state SUPPO
	on EX_DATA		do VDstoreObject (2, &me->ret)	state SUPPO
/* ************************************************************************** */
state SUPPO
	prompt_key		VD_P_MEAS_SUPP
	accept_key		VD_M_MEAS_SUPP
	locate_eligible		"+EMSsurface"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
                        	 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                        	 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

	on EX_BACK_UP						state PLANE
	on EX_RJT_MOVEON					state COMPUTE
	on EX_DATA		do VDstoreObject (3,&me->ret)	state COMPUTE
/* ************************************************************************** */
state COMPUTE
	status_key		VD_S_EVAL_DIST
	prompt			" "
	accept			" "
	execute			VDstatusDisplayAccess ( 0 )
	execute			VDstatusDisplayButton ( &me->ret )
	execute			VDevalMeasure (&me->ret)

			on VD_E_EVAL_DIST
				do status_key VD_E_EVAL_DIST
				do VDcleanMeasure (&me->ret)	state START

	status_key		VD_P_MEAS_AGAIN
	execute			calc_delta_prev_current (&me->ret)
	execute			display_line (&me->ret)
	execute			VDdispatchMeasure (&me->ret)

	filter			get_event
	on EX_DATA		do VDcleanMeasure (&me->ret)	state START
	on EX_BACK_UP						state COMPUTE
	on ELSE			do VDcleanMeasure (&me->ret)	state EXIT
/* ************************************************************************** */
state EXIT
	status			" "
	prompt			" "
	accept			" "

	on ELSE							state terminate
/* ************************************************************************** */

/* ************************************************************************** */
action	update_cursor_fields 	extern
/* ************************************************************************** */

/* ************************************************************************** */
action	display_line
{
	if (me->draw_mode == PLACE_LINE) {

		/* Put curve in RANGE TREE */
		status = om$send ( msg = message GRgraphics.GRaddwrng
					( sts, &me->mod_env ),
				   targetid = me->Mea.Ocrv.obj_id.objid,
				   targetos = me->Mea.Ocrv.obj_id.osnum );
		as$status ( msg    = "GRgraphics.GRaddwrng",
			    test   = (!(status & 0x00000001 & (*sts))),
			    action = GOTO_VALUE,
			    value  = quit );

		/* Display curve */
		gr$display_object ( object_id = &me->Mea.Ocrv.obj_id,
				    md_env    = &me->mod_env,
				    mode      = GRbd );
	}
}
/* ************************************************************************** */

/* ************************************************************************** */
action	VDinitMeasure ( IGRlong *msg )
{
	IGRint		i;
	IGRlong		siz=sizeof(struct GRmd_env), ret;
	GRspacenum	ActiveOs;

	status = gr$get_module_env ( msg    = msg,
				     sizbuf = &siz,
				     buffer = &me->mod_env,
				     nret   = &ret );
        as$status ( msg    = "gr$get_module_env()",
                    test   = (!(status & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = quit );
	ActiveOs = me->mod_env.md_id.osnum;

	/* Initialize some instances */
	for ( i=0; i<4; i++ )	me->Typ[i]	= FALSE;
	me->Mea.prop				= VD_MEAS_CURV;
	for ( i=0; i<4; i++ ) {
		me->Mea.Iobj[i].obj_id.objid	= NULL_OBJID;
		me->Mea.Iobj[i].obj_id.osnum	= ActiveOs;
		me->Mea.Iobj[i].mod_env		= me->mod_env;
	}
	for ( i=0; i<6; i++ )	me->Mea.Ipnt[i]	= 0.0;
	for ( i=0; i<2; i++ ) {
		me->Mea.Iwin[i].objid		= NULL_OBJID;
		me->Mea.Iwin[i].osnum		= ActiveOs;
	}
	me->Mea.Odst				= 0.0;
	for ( i=0; i<6; i++ )	me->Mea.Opnt[i]	= 0.0;
	me->Mea.Ocrv.obj_id.objid		= NULL_OBJID;
	me->Mea.Ocrv.obj_id.osnum		= ActiveOs;
	me->Mea.Ocrv.mod_env			= me->mod_env;

	/* Clear form fields */
	status = om$send ( msg	    = message VDCmdMeas.clear_fields ( msg ),
			   targetid = my_id );
        as$status ( msg    = "VDCmdMeas.clear_fields()",
                    test   = (!(status & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = quit );
}
/* ************************************************************************** */

/* ************************************************************************** */
action	VDstatusDisplayAccess (	IGRint	flag	)
{
	if (flag == 0)	me->FormDisplayable = 0;
	else		me->FormDisplayable = 1;

	status = OM_S_SUCCESS;
	goto quit;
}
/* ************************************************************************** */

/* ************************************************************************** */
action	VDstatusDisplayButton (	IGRlong	*msg	)
{
	status = om$send ( msg	    = message VDCmdMeas.status_display_button
						( me->FormDisplayable ),
			   targetid = my_id );
        as$status ( msg    = "VDCmdMeas.status_display_button()",
                    test   = (!(status & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = quit );
}
/* ************************************************************************** */

/* ************************************************************************** */
action	VDcleanMeasure ( IGRlong *msg )
{

	/* Delete measure line|curve (if needed) */
	if (  (me->Mea.Ocrv.obj_id.objid != NULL_OBJID)
	   && (me->draw_mode != PLACE_LINE) ) {

		status = om$send ( msg = message GRgraphics.GRdelete
					( msg, &me->Mea.Ocrv.mod_env ),
				   targetid = me->Mea.Ocrv.obj_id.objid,
				   targetos = me->Mea.Ocrv.obj_id.osnum );
		as$status ( msg    = "GRgraphics.GRdelete",
	                    test   = (!(status & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = quit );
	}

	/* Call VDinitMeasure method */
	status = om$send ( msg	    = message VDCmdMeas.VDinitMeasure ( msg ),
			   targetid = my_id );
        as$status ( msg    = "VDCmdMeas.VDinitMeasure()",
                    test   = (!(status & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = quit );

}
/* ************************************************************************** */

/* ************************************************************************** */
action	VDstoreObject ( IGRint idx; IGRlong *msg )
{
	*msg = MSFAIL;
	if (idx > 4)	goto quit;
	
	me->Typ[idx] = TRUE;
	me->Mea.Iobj[idx].obj_id
	= me->event1.located_object[0].located_obj;
	me->Mea.Iobj[idx].mod_env
	= me->event1.located_object[0].module_info;
	if (idx < 2) {
		me->Mea.Ipnt[3*idx+0]	= me->event1.event.button.x;
		me->Mea.Ipnt[3*idx+1]	= me->event1.event.button.y;
		me->Mea.Ipnt[3*idx+2]	= me->event1.event.button.z;
		me->Mea.Iwin[idx].osnum	= me->event1.event.button.osnum;
		me->Mea.Iwin[idx].objid	= me->event1.event.button.objid;
	}

	status = OM_S_SUCCESS;
	*msg   = MSSUCC;
}
/* ************************************************************************** */

/* ************************************************************************** */
action	VDevalMeasure ( IGRlong *msg )
{

	/* Check objects list */
	*msg = MSFAIL;
	if	( (me->Typ[0] == FALSE) || (me->Typ[1] == FALSE) )
		goto quit;

	/* Set additional properties (if needed) */
	if (me->Typ[2] == TRUE)	me->Mea.prop |= VD_MEAS_PLAN;
	if (me->Typ[3] == TRUE)	me->Mea.prop |= VD_MEAS_SUPP;

	/* Compute measure */
	status = VDcomputeDistance ( msg,  &me->Mea );
	if (!(status & 0x00000001 & (*msg))) {
		*msg = VD_E_EVAL_DIST;
		goto quit;
	}

	/* Store start point */
	me->event1.response		= DATA;
	me->event1.event.button.x	=  me->Mea.Opnt[0];
	me->event1.event.button.y	=  me->Mea.Opnt[1];
	me->event1.event.button.z	=  me->Mea.Opnt[2];
	me->event1.subtype		= DATA;
	status = om$send ( msg = message VDCmdMeas.store_base_event ( msg ),
			   targetid = my_id );
	as$status ( msg    = "VDCmdMeas.store_base_event",
		    test   = (!(status & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = quit );

	/* Store end point */
	me->event1.response		= DATA;
	me->event1.event.button.x	=  me->Mea.Opnt[3];
	me->event1.event.button.y	=  me->Mea.Opnt[4];
	me->event1.event.button.z	=  me->Mea.Opnt[5];
	me->event1.subtype		= DATA;
	status = om$send ( msg = message VDCmdMeas.store_current_event ( msg ),
			   targetid = my_id );
	as$status ( msg    = "VDCmdMeas.store_current_event",
		    test   = (!(status & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = quit );

	/* Store distance */
	me->form_fields[CUMULATIVE_MEAS_IND] += me->Mea.Odst;
	me->form_fields[CURRENT_MEAS_IND] = me->Mea.Odst;
	me->display_field |= GR_COMEAS_DISPLAY_CURRENT_DISTANCE;

	/* Remove measure line|curve from RTREE */
	status = om$send ( msg = message GRgraphics.GRremwrng
					( msg, &me->Mea.Ocrv.mod_env ),
			   targetid = me->Mea.Ocrv.obj_id.objid,
			   targetos = me->Mea.Ocrv.obj_id.osnum );
        as$status ( msg    = "GRgraphics.GRremwrng",
                    test   = (!(status & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = quit );

	/* Modify module env to be out of RTREE */
	me->Mea.Ocrv.mod_env.md_id.objid = NULL_OBJID;
}
/* ************************************************************************** */

/* ************************************************************************** */
action	VDdispatchMeasure ( IGRlong *msg )
{
	/* Is STATUS FORM displayed */
	status = om$send ( msg = message VDCmdMeas.is_form_displayed ( msg ),
			   targetid = my_id );
	as$status ( msg    = "VDCmdMeas.is_form_displayed",
		    action = GOTO_VALUE,
		    value  = quit );

	/* No STATUS FORM displayed */
	if	(*msg == MSFAIL) {

		status = om$send ( msg = message VDCmdMeas.clear_channels
							( msg ),
				   targetid = my_id );
		as$status ( msg    = "VDCmdMeas.clear_channels",
			    action = GOTO_VALUE,
			    value  = quit );

		status = om$send ( msg = message VDCmdMeas.update_cursor_fields
							( msg ),
				   targetid = my_id );
		as$status ( msg    = "VDCmdMeas.VDupdateCursorFields",
			    action = GOTO_VALUE,
			    value  = quit );
	}

	/* Yes STATUS FORM displayed */
	else if (*msg == MSSUCC) {

		status = om$send ( msg = message VDCmdMeas.update_meas_form
							( msg ),
				   targetid = my_id );
		as$status ( msg    = "VDCmdMeas.update_meas_form",
			    action = GOTO_VALUE,
			    value  = quit );

		status = om$send ( msg = message VDCmdMeas.clear_channels
							( msg ),
				   targetid = my_id );
		as$status ( msg    = "VDCmdMeas.clear_channels",
			    action = GOTO_VALUE,
			    value  = quit );

		status = om$send ( msg = message VDCmdMeas.erase_hilite
							( msg ),
				   targetid = my_id );
		as$status ( msg    = "VDCmdMeas.erase_hilite",
			    action = GOTO_VALUE,
			    value  = quit );
	}

	*msg = MSSUCC;
}
/* ************************************************************************** */
