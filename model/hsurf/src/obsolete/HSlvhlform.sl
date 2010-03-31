class		HSlvhlform
super_class	HSwindow
command_object	"low-resolution visible hidden line",0,HSLVcHdLn
product_name	"$MODEL"
form		"HSLwVcHdLn",0,0,0,0,1
start_state	select_window


/*---specification-----------------------------------------------*/

specification

#include "HSlvhl_info.h"

instance
	{
	IGRint			switch1;

	struct HSlvhl_info	lvhl_info, lvhl_info_save;
	}

/*---state_table-------------------------------------------------*/

state_table

#include "../include/hsmsg.h"

#define EXIT_COMMAND		4000
#define GENERATE_IMAGE		4001


/*---implementation----------------------------------------------*/

implementation

#define CHECK_RETURN_CODES 1

#define EXIT_COMMAND		4000
#define GENERATE_IMAGE		4001


#include "hsurf_import.h"

#include "tools.h"

#include "stdio.h"
#include "OMerrordef.h"
#include "msdef.h"

#include "igewindow.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "igr.h"

#include "fontdef.h"
#include "font.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "godef.h"

#include "msdef.h"
#include "ms.h"
#include "msmacros.h"

#include "griodef.h"
#include "griomacros.h"

#include "exdef.h"
#include "ex.h"
#include "comiscmac.h"

#include "fidef.h"
#include "fi.h"
#include "FI.h"

#include "exmacros.h"

#include "hsurferrpriv.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsmsg.h"

#include "HStl_global.h"
#include "HSlvhl_label.h"

from HSgragad	import HSlvhl_update;

/*---init------------------------------------------------*/

at init
	do initialize


/*---delete----------------------------------------------*/

at delete
	do delete_cmd


/*---default states--------------------------------------*/

state *
	on EX_RJT_MOVEON state .
	on EX_RESTART    state select_window
	on EX_BACK_UP    state -
	
/*---select_window-------------------------------------------------*/

/*
 *  The user wants to generate vector edges from the raster 
 *  information
 */

state select_window
	message	"Low-Resolution Vector Hidden Line"
	prompt_key	HS_P_SelWin
	filter		get_event

	on EX_DATA or EX_STRING
		do get_selected_window( sts, 0, 1 )
			on SUCCESS
				state service_form
			on ELSE
				state .

		state .
		
	on EX_BACK_UP
		state terminate


/*---service_form----------------------------------------*/

state service_form
	prompt		""
	display_form	0
	filter		wfi

	on EX_BACK_UP or EX_DATA
		state .

	on MOVE_ON
		do which_state
			on RETURN_CODE = EXIT_COMMAND 
				state terminate
				
			on RETURN_CODE = GENERATE_IMAGE
				do erase_form 0
				do generate_image
				state terminate
				
			on ELSE
				state .
		state .


/*---wait_for_event--------------------------------------------------*/

state wait_for_event
	prompt_key	HS_I_MoveOnToContinue
	filter		get_event

	on EX_BACK_UP or EX_RJT_MOVEON or ELSE
		state terminate


/*---initialize------------------------------------------------------*/

action initialize

	{
	Form            form_ptr;

	form_ptr = me->forms[0].form_ptr;

	me->status_display_form_ptr = form_ptr;
	
	me->lvhl_info.display_hidden = 1;
	me->lvhl_info.generate_soos = 0;
		
	me->lvhl_info.visible_color = -1;
	me->lvhl_info.hidden_color = -1;
		
	me->lvhl_info.visible_weight = -1;
	me->lvhl_info.hidden_weight = -1;
		
	me->lvhl_info.visible_style = -1;
	me->lvhl_info.hidden_style = -1;
		
	me->lvhl_info.visible_layer = 1022;
	me->lvhl_info.hidden_layer = 1023;
		
	me->lvhl_info.optimization = 1;
	
	memcpy( &me->lvhl_info_save, &me->lvhl_info, sizeof( struct HSlvhl_info ));
	
	HSlvhl_notification( form_ptr, RV_RESET, &me->lvhl_info );
	}


/*---which_state----------------------------------------------------*/

action	which_state

	{
	*sts = me->switch1;
	}

 
/*----form_notification---------------------------------------------------*/

action form_notification

	{
	Form	  form_ptr;

	form_ptr = me->forms[0].form_ptr;
	
	switch( gadget_label )
		{	
		case RV_RESET:
			memcpy( 
				&me->lvhl_info, 
				&me->lvhl_info_save, 
				sizeof( struct HSlvhl_info ) );
			break;
			
		default:
			break;

		}

	HSlvhl_notification( form_ptr, gadget_label, &me->lvhl_info );

	switch( gadget_label )
		{	
		case RV_CHECK:
			me->switch1 = EXIT_COMMAND;
			_move_on;
			break;

		case RV_EXECUTE:
			me->switch1 = GENERATE_IMAGE;
			_move_on;
			break;

		case RV_CANCEL:
			me->switch1 = EXIT_COMMAND;
			_move_on;
			break;
			
		default:
			break;

		}
	}


/*---delete_cmd---------------------------------------*/

action delete_cmd

	{
	}


/*---generate_image-----------------------------------------*/

/*
 *  set the appropriate styled raster mode and update the window,
 *  once to populate the zbuffer with surfaces and again to
 *  generate the vectors.  At the end, will have to call
 *  HSvhl_write_span() to get the output edges from the temporay
 *  binary file and write them into the model space.  Later will
 *  add SOO support.
 */

action generate_image

	{
	Form		form_ptr;
	IGRlong		msg;
	struct GRid	myself;


	form_ptr = me->forms[0].form_ptr;

	myself.objid = my_id;
	myself.osnum = OM_Gw_current_OS;
	
	sts = om$send( msg = message HSgragad.HSlvhl_update(
							&msg,
							&me->lvhl_info ),
		  targetid = me->win_ids[0].objid,
		  targetos = me->win_ids[0].osnum );
	}
