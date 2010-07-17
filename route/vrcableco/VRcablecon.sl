/* $Id: VRcablecon.sl,v 1.2 2001/02/20 01:11:55 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcableco/VRcablecon.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcablecon.sl,v $
 *	Revision 1.2  2001/02/20 01:11:55  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
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
# Revision 1.7  1996/03/04  22:56:02  pinnacle
# Replaced: vrcableco/VRcablecon.sl for:  by hverstee for route240
#
# Revision 1.6  1996/02/02  18:49:50  pinnacle
# Replaced: ./vrcableco/VRcablecon.sl for:  by azuurhou for route240
#
# Revision 1.4  1996/02/01  22:49:48  pinnacle
# Replaced: ./vrcableco/VRcablecon.sl for:  by azuurhou for route240
#
# Revision 1.3  1996/01/16  20:16:18  pinnacle
# Replaced: vrcableco/VRcablecon.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:18:56  pinnacle
# Replaced: vrcableco/VRcablecon.sl for:  by r240_int for route240
#
 *
 * History:
 *	04/25/90   	AdZ		creation
 *	12/06/95	tlb		Remove VRcmd.h
 *	01/15/96	tlb		Add VX_FIproto.h
 *
 *************************************************************************/

/* --------------------------------------------------------------------- */
/* CLASS SPECIFICATION */

class		VRcablecon
super_class	"VDB_LOCATE"
command_string	VRC_M_CnCb,0,VRCnCb
product_name	"$ROUTE"
command_table	"route.cmd"

form		"VRCbConnect",0,0,"-1","-1"
form		"VRCbSkPara",1,0,"-1","-1"

start_state	start

/* --------------------------------------------------------------------- */
/* SPECIFICATION AREA */

specification

#include <stdio.h>

#include "growner.h"
#include "dpstruct.h"
#include "VRcabledef.h"

instance
{
	struct	VRcable_data		*Cable_Data;
	variable struct	VRcable_data	Cable_List[0];
	IGRint				Max_List;

	struct	GRid		CONN_PNTS[2];
	struct	GRid		EQUIP[2];

	IGRint			NumVRRCompObjects;

	variable struct	GRobj_env	VRRCompObjects[1];	/* Tubes objects */
	variable struct	GRobj_env	ResVRRCompObjects[1];

	IGRint			Sketch_Par;

	struct	IGRpolyline	line;
	variable IGRdouble	my_pnts[300];

	IGRint			cur_elmt;
	IGRint			max_elmt;

	IGRdouble		start_pnt[3];
	IGRdouble		start_vec[3];

	IGRdouble		end_pnt[3];
	IGRdouble		end_vec[3];
	IGRint			my_label;

	IGRboolean		If_First_Point;
	IGRdouble		Z_Window[3];

	IGRboolean		If_Rway_Point;
	IGRdouble		Rway_start_pnt[3];
	IGRdouble		Rway_end_pnt[3];
	IGRdouble		Rway_start_vec[3];

	IGRchar			work_dir[CABLE_MAX_TXT];
}

/* --------------------------------------------------------------------- */
/* IMPLEMENTATION AREA */

implementation
/* 
 * include files
 */
#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "OMtypes.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "FI.h"
#include "CIforms.h"
#include "ODE.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "msdef.h"
#include "msmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "EC_S.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"

#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"

#include "grgs.h"		/* group set includes */
#include "grgsmacros.h"

#include "bstypes.h"
#include "growner.h"
#include "VRdimdef.h"
#include "VRcabledef.h"
#include "AS_status.h"
#include "vrdbgmacros.h"
#include "vrcablec_pto.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define	AS_DEBUG	1
/*
 * defined form 	./config/english/forms
 */
#define	CABLE_FORM	0
#define	DRAW_FORM	1
/* 
 * Available Gadgets 
 *
 * predefined are :
 *	FI_CANCEL	( 4 )
 *	FI_RESET	( 3 )
 *	FI_EXECUTE	( 2 )
 *	FI_ACCEPT	( 1 )
 *	FI_MSG_FIELD	( 10 )
 */
#define	MCF1		12	/* colomn table  */
#define	L_CBSK_LOC	15	/* locate botton */
#define	L_CBSK_TRA	16	/* trace botton  */
/*
 * calling external functions
 */

/* --------------------------------------------------------------------- */
/* STATES AREA */
/* --------------------------------------------------------------------- */

state_table
#include "VRcabledef.h"
#include "VRmsg.h"

state *

   on EX_RJT_MOVEON						state start
   on EX_RESTART						state start
   on EX_BACK_UP						state -


state start

   execute	VRCbInit( &me->ret )
		  on ERROR	do status "Error in Set Up"	state terminate
   execute	VRCbEraseSketch( &me->ret )
   execute	VRCbRetrieveFile( &me->ret )

   on ELSE							state select


state select

   execute	VRCbDisplayTable( &me->ret )

   message_key	VR_M_CnCb
   prompt_key	VR_P_SelConPnts
   filter	get_event

   on GR_UNKNOWN_TYPE.VRCAB_FORM_INFO	do VRCbSetReturn( &me->ret )
	on RETURN_CODE = VRCAB_CANCEL	do VRCbExitTable( &me->ret )	state terminate
	on RETURN_CODE = VRCAB_ACCEPT	
    		do VRCbDefElements( &me->ret )	on ERROR	state .
		do VRCbEraseTable(&me->ret) 	on ERROR	state .
		do VRCbInitLine( &me->ret )	on ERROR 	state .
		do VRCbDisplaySketch( &me->ret )		state N_PNT
								state .

   on EX_BACK_UP or EX_RJT_MOVEON				state .

   on EX_DATA							state .

state N_PNT

   execute	VRCbHilightEquip( &me->ret )

   prompt_key	VR_P_GivNextPnt
   dynamics	VRCAB_LINEDYN
   filter	get_event


   on GR_UNKNOWN_TYPE.VRCAB_FORM_INFO	do VRCbSetReturn( &me->ret )
	on RETURN_CODE = VRCAB_LOCATE				state PNT_LOC
	on RETURN_CODE = VRCAB_DIGID				state .
								state .

   on EX_RJT_MOVEON		do VRCbEndLine( &me->ret )	
				  on ERROR				state det_error
				do VRCbUnhilightEquip( &me->ret )	state select

   on EX_BACK_UP		do VRCbPopPnt( &me->ret )
				do VRCbDisplayLine( &me->ret )
	on ERROR		do VRCbUnhilightEquip( &me->ret )	state select
									state .
   on DATA			do VRCbPushPnt( &me->ret )
				do VRCbDisplayLine( &me->ret )
	on ERROR						state det_error
								state .

state PNT_LOC

   prompt_key		VR_P_IdComp	
   dynamics		VRCAB_HIL_EQUIP
   locate_class		"VRRComp"
   accept_key		VR_P_AccRejectComponent	
   relocate_key		VR_E_NoObjLoc	
   locate_owner		"LC_RIGID_COMP"
   filter		locate

   on GR_UNKNOWN_TYPE.VRCAB_FORM_INFO	do VRCbSetReturn( &me->ret )
	on RETURN_CODE = VRCAB_DIGID				state N_PNT
								state .

   on EX_DATA or EX_OBJID	do VRCbGetComp( &me->ret )
	on VRCAB_RWAY_COMP						state N_LOC_C
	on ERROR		do VRCbDisplaySketch( &me->ret )	state N_PNT
				do VRCbDisplayLine( &me->ret )	
	on ERROR						state det_error
								state .

   on EX_RJT_MOVEON		do VRCbDisplaySketch( &me->ret )	state N_PNT

   on EX_BACK_UP		do VRCbPopPnt( &me->ret )
				do VRCbDisplayLine( &me->ret )	
	on ERROR		do VRCbUnhilightEquip( &me->ret )	state select
									state .

state N_LOC_C

   prompt_key	VR_P_AccRejectComponent	
   dynamics	VRCAB_RWAY_PNT
   filter	get_event

   on GR_UNKNOWN_TYPE.VRCAB_FORM_INFO	do VRCbSetReturn( &me->ret )
	on RETURN_CODE = VRCAB_LOCATE	do VRCbPopPnt( &me->ret )	state PNT_LOC
	on RETURN_CODE = VRCAB_DIGID	do VRCbPopPnt( &me->ret )	state N_PNT
									state .

   on EX_RJT_MOVEON		do VRCbDisplayLine( &me->ret )
	on ERROR						state det_error
								state PNT_LOC

   on EX_DATA			do VRCbPushPnt( &me->ret )
				do VRCbDisplayLine( &me->ret )
	on ERROR						state det_error
								state PNT_LOC

state det_error

   status_key	VR_S_InvDataType	
   dynamics	VRCAB_HIL_EQUIP
   on ELSE							state -


/* ---------------------------------------------------------------------- */
/* VR_CABLE_ERASE_SKETCH */
/* ---------------------------------------------------------------------- */
action VRCbEraseSketch		extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_DISPLAY_SKETCH */
/* ---------------------------------------------------------------------- */
action VRCbDisplaySketch	extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_SET_RETURN */
/* ---------------------------------------------------------------------- */
action VRCbSetReturn		extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_EXIT_TABLE */
/* ---------------------------------------------------------------------- */
action	VRCbExitTable		extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_DISPLAY_TABLE */
/* ---------------------------------------------------------------------- */
action	VRCbDisplayTable	extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_ERASE_TABLE */
/* ---------------------------------------------------------------------- */
action	VRCbEraseTable		extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_GET_COMPONENT */
/* ---------------------------------------------------------------------- */
action	VRCbGetComp		extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_INIT 							- */
/* ---------------------------------------------------------------------- */
action	VRCbInit		extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_DEFINE_ELEMENTS 						- */
/* ---------------------------------------------------------------------- */
/* 
 * find the object of the connection points and
 * create the interaction for drawing the connection
 * depending on the draw type
 */
action  VRCbDefElements		extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_RETRIEVE_FILE 						- */
/* ---------------------------------------------------------------------- */
/*
 * get all the data from the ASCII file, select those which aren't displayed
 * and display these in the Cable Connect Points table
 */
action	VRCbRetrieveFile	extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_INIT_LINE 							- */
/* ---------------------------------------------------------------------- */
action VRCbInitLine( int *sts )	extern 

/* ---------------------------------------------------------------------- */
/* VR_CABLE_END_LINE 							- */
/* ---------------------------------------------------------------------- */
action VRCbEndLine( int *sts )	extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_PUSH_POINT 							- */
/* ---------------------------------------------------------------------- */
action VRCbPushPnt		extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_POP_POINT 							- */
/* ---------------------------------------------------------------------- */
action VRCbPopPnt		extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_ADD_POINT 							- */
/* ---------------------------------------------------------------------- */
action VRCbAddPnt( int    *sts;
		   double *pnt; ) extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_DISPLAY_LINE 						- */
/* ---------------------------------------------------------------------- */
action VRCbDisplayLine( int *sts ) extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_HILIGHT_EQUIPMENT						- */
/* ---------------------------------------------------------------------- */
action VRCbHilightEquip( int *sts ) extern

/* ---------------------------------------------------------------------- */
/* VR_CABLE_UNHILIGHT_EQUIPMENT						- */
/* ---------------------------------------------------------------------- */
action VRCbUnhilightEquip( int *sts ) extern

/* ---------------------------------------------------------------------- */
/* FORM_NOTIFICATION 							- */
/* ---------------------------------------------------------------------- */

action	form_notification
/*
 *	int	form_label	: the label of the form
 *	int	gadget_label	: the label of the gadget
 *	double	fld_value	: the value of the gadget
 *	Form	form_ptr	: pointer to the form
 */
/*.form_not*/	
{
IGRchar		errMsg[CABLE_MAX_TXT];
IGRchar		CableName[CABLE_MAX_TXT];
IGRint		i, row, col, dummy, sel_flag;
/*
 * clean up the message area ( if used )
 */
	/*" gadget_label : %d\n", gadget_label */

	strcpy( errMsg, " " );
	status = FIg_set_text(	me->forms[0].form_ptr,	FI_MSG_FIELD, errMsg);

	if( status != FI_SUCCESS ){
		printf("\nCable Connection: fct FIg_set_text() sts = %d\n", status);
		me->state = _terminate;
		return ( OM_I_STOP_SENDING );
	}

	me->my_label = gadget_label;

	switch( gadget_label ){

	case L_CBSK_LOC :

		/*" Sketch_Par : %d \n", me->Sketch_Par */
		if( me->Sketch_Par == VRCAB_LOCATE ){
		    status = FIg_set_state_off( me->forms[1].form_ptr, L_CBSK_LOC );
		    if( status != FI_SUCCESS ){
			printf("\nCable Sketch: fct FIg_set_state_off() sts = %d\n", status);
			me->state = _terminate;
			return ( OM_I_STOP_SENDING );
		    }
		    me->Sketch_Par = VRCAB_DIGID;
		}
		else{
		    /*| Set state on */
		    me->Sketch_Par	= VRCAB_LOCATE;
		}
		me->my_label = me->Sketch_Par;
		/*" Sketch_Par : %d \n", me->Sketch_Par */
		break;

	case FI_ACCEPT: 

	   	if( me->Cable_Data == NULL ){
		  me->my_label = VRCAB_MCF1 ;
		  strcpy( errMsg, "Select Connection Point " );
		  FIg_set_text(	me->forms[0].form_ptr,	FI_MSG_FIELD, errMsg);
		}

		break;
          
	case FI_CANCEL:     

		break;

	case MCF1:
	/*
	 * get active colomn and row
	 */
	        status = FImcf_get_active_col( me->forms[0].form_ptr, gadget_label, &col, &dummy );
		if( status != FI_SUCCESS ){
			printf("\nCable Connection: fct FImcf_get_active_col() sts = %d\n", status);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		}
		status = FIfld_get_active_row( me->forms[0].form_ptr, gadget_label, &row, &dummy);

		if( status != FI_SUCCESS ){
			printf("\nCable Connection: fct FIfld_get_active_row() sts = %d\n", status);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		}
	/*
	 * get text of the five colomns 
	 */
		CableName[0] = '\0';
		FIfld_get_text(me->forms[0].form_ptr, gadget_label, row, 0,
				CABLE_MAX_TXT, (unsigned char*)CableName,
				&sel_flag, &dummy );

		__DBGpr_str(" CableName ", CableName );

		/*| get active text */
		me->Cable_Data = NULL ;

		if( ! strlen( CableName)){
		  __DBGpr_com(" Selected empty Row ...");
		  break ;
		}

		for(i=0; i<me->Max_List; i++ ){
		 if( me->Cable_List[i].not_displayed ){
		  if( ! strcmp( CableName, me->Cable_List[i].CableNameStr )) {
		    
		    me->Cable_Data = &(me->Cable_List[i]);
		    me->Cable_Data->start_index = FALSE;
		    if( col == 4 ) me->Cable_Data->start_index = TRUE;

		    FIfld_set_select( me->forms[0].form_ptr, MCF1,
					 row, col, TRUE );
		    break;
		  }
		 }
		}

		if( me->Cable_Data != NULL ){
		  __DBGpr_str(" CableName  ", me->Cable_Data->CableNameStr );
		  __DBGpr_str(" Equipment1  ", me->Cable_Data->Equipment1Str );
		  __DBGpr_str(" Equipment2  ", me->Cable_Data->Equipment2Str );
		  __DBGpr_str(" ConnectPnt1 ", me->Cable_Data->ConnectPnt1Str );
		  __DBGpr_str(" ConnectPnt2 ", me->Cable_Data->ConnectPnt2Str );
		  __DBGpr_dbl(" Sect_radius ", me->Cable_Data->BendRadius );
		  __DBGpr_dbl(" Bend_radius ", me->Cable_Data->SectRadius );
		  __DBGpr_int(" Start_index ", me->Cable_Data->start_index );
		}
		break;

	default:
		me->my_label = VRCAB_UNDEF;
		/*" not active gadget label : %d \n", gadget_label */
		break;

	} /* END switch ( gadget_label ) */
/*
 * give information back to state table 
 */
	if(( me->my_label != VRCAB_UNDEF ) &&
	   ( me->my_label != VRCAB_MCF1 ))
		_put_response( resp = VRCAB_FORM_INFO );

} /* END form_notification() */


/* ---------------------------------------------------------------------- */
/* DYNAMICS */
/* ---------------------------------------------------------------------- */

action dynamics
/*.dynamics*/
{
IGRint		cur_size;

	/* increment before dynamics */
	cur_size = om$dimension_of( varray = me->my_pnts );
	/*" cur_size : %d\n", cur_size */
	if( me->cur_elmt + 3 >= cur_size ){
	   me->max_elmt = cur_size + VRCAB_INCRBUF;
	   status = om$vla_set_dimension( varray = me->my_pnts,
					  size = me->max_elmt );
	   as$status( action = RET_STATUS );
	}

	/*" num pnts : %d \n", me->line.num_points */
	switch( dynamics ){

	case	VRCAB_LINEDYN:
		status = VRCbDynamics(	me->Cable_Data,
					me->my_pnts,
					me->line.num_points,
					&me->ActiveDisplay,
					me->Z_Window,
					my_id,
					me->If_First_Point,
					me->start_pnt,
					me->start_vec,
					NULL );
		break;
	case	VRCAB_RWAY_PNT:
		status = VRCbDynamics(  me->Cable_Data,
					me->my_pnts,
					me->line.num_points,
					&me->ActiveDisplay,
					me->Z_Window,
					my_id,
					TRUE,
					me->Rway_start_pnt,
					me->Rway_start_vec,
					me->Rway_end_pnt );
		break;
	default:
		status = om$send(msg = message CEO.dynamics( dynamics, sts ),
					mode = OM_e_wrt_message,
					targetid = my_id );
		as$status();
	} /* end switch */
}

