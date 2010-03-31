
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $
*/

class              HSzddd
super_class        HSwindow
command_object     HSM_M_DeleteDetailDisplay ,0,HLDlDtDs
synonym            "Dump Overrides"          ,1,HLDmHdSy
product_name       "$MODEL"
start_state        start

specification

instance
	{
	IGRint		mode;
	IGRint		switch1;
	
	IGRchar		window_name[GRNAME_SIZE];
	}

state_table

#include "hsmsg.h"

implementation

#define CHECK_RETURN_CODES 0

#define	DELETE_MODE	0
#define	DUMP_MODE	1

#include <stdio.h>
#include <string.h>
#include "wl.h"

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "hsmsg.h"

/*----------------------------
 *  for function
 *     HScollect_hidden_symbology_overrides
 */
 
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

%safe
#include "HSpr_co_func.h"
%endsafe

/*---------------------------*/

at wakeup	do display_mode_title


/*---default transitions for all states---------------------------*/

state *
	on EX_RJT_MOVEON state .
	on EX_RESTART    state start
	on EX_BACK_UP    state -

/*---start--(state)-----------------------------------------------*/

state start
	on CMD_TYPE = 0
		do	set_delete_mode
		state	get_window

	on CMD_TYPE = 1
		do	set_dump_mode
		state	get_window


/*---get_window-----------------------------------------*/

state get_window

	prompt_key	HS_P_SelWin
	filter		get_event

	on EX_DATA or EX_STRING
		do get_selected_window( sts, 0, 1, 0, 0 )
		
			on SUCCESS
				do get_window_name
				state get_elements


			on ELSE
				state .
				
		state .


/*---get_elements---------------------------------------*/

state get_elements

	prompt_key			HS_P_GetGroupEIV
	accept_key			HS_P_SingleAccept
	relocate_key			HS_E_Relocate
	gslocate_spec_prompt1_key	HS_P_AcceptGroup
	locate_display			"ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
	locate_properties		"LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	locate_owner			"LC_READ | LC_REF_OBJECTS"
	unhilight_mode			"GRhe"
	gslocate_num_inputs		0
	locate_class			"GRgraphics"
	filter				gs_locate_noauto

	on EX_RJT_MOVEON
		do spawn_elements_in_view
		state .

	on EX_DATA or EX_OBJID
		do process
		do display_mode_title
		state .
			
	on EX_BACK_UP
		state get_window



/*---get_window_name-------------------------------------------------------*/

action get_window_name

	{
	struct var_list		var_list[2];
	IGRlong			bytes_returned;
	IGRlong			which_error;
	IGRlong			msg;

	var_list[0].var            = GRAGAD_NAME;
	var_list[0].var_ptr        = me->window_name;
	var_list[0].num_bytes      = sizeof( me->window_name );
	var_list[0].bytes_returned = &bytes_returned;
	
	var_list[1].var            = END_PARAM;

	dp$inq_set_gragad( msg = &msg,
		     inq0_set1 = 0,
		         osnum = me->win_ids[0].osnum,
		  gragad_objid = me->win_ids[0].objid,
		   which_error = &which_error,
		      var_list = var_list );
	}
		
/*---spawn_elements_in_view--------------------------------------------*/

action spawn_elements_in_view

/*
 * DESCRIPTION
 * 	This action puts the necessary information on the input queue to
 * 	cause the "Elements in View" input generator to be executed.  It
 * 	will not spawn the input generator if the status display form
 * 	is being displayed.
 */

	{
	IGRlong	msg;
	IGRlong	size;
	int	response;
	IGRint	status_form_displayed;
	IGRchar	command_key[30];
	
  	status_form_displayed = FALSE;
	if( me->status_display_form_ptr )
		FIf_is_displayed( me->status_display_form_ptr, &status_form_displayed );

	if ( status_form_displayed )
		*sts = OM_W_WARNING;
	else
		{
		*sts = OM_S_SUCCESS;

 		size = strlen( me->window_name ) + 1;
		response = EX_STRING;
		
		ex$putque( msg = &msg,
		      response = &response,
			  byte = &size,
			buffer = (IGRchar *)me->window_name );
			  
		strcpy( command_key, "GRSlEInV" );
		size = strlen( command_key ) + 1;
		response = EX_CMD_KEY;
	
		ex$putque( msg = &msg,
		      response = &response,
			  byte = &size,
			buffer =  command_key );
		}
	}


/*---which_state----------------------------------------------------*/

action	which_state

	{
	*sts = me->switch1;
	}


/*---set_delete_mode---------------------------------------------*/

action	set_delete_mode

	{
	me->mode = DELETE_MODE;
	}	

/*---set_dump_mode---------------------------------------------*/

action	set_dump_mode

	{
	me->mode = DUMP_MODE;
	}	

/*---display_mode_title----------------------------------------------*/

action display_mode_title

	{
	/*
	switch( me->mode )
		{
		case DELETE_MODE:
			break;
			
		case DUMP_MODE:
			ex$message( in_buff="Dump Overrides", field=MESSAGE_FIELD );
			break;
		}
	*/
	ex$message( msgnumb=HSM_M_DeleteDetailDisplay, field=MESSAGE_FIELD );
	}

/*---process-----------------------------------------------------*/

action	process

	{
	struct GRid		my_GRid;
	struct var_list		var_list[2];
	IGRdouble		rotation[16];
	IGRint			which_error;
	IGRlong			bytes_returned, msg;

	my_GRid.objid = my_id;
	my_GRid.osnum = OM_Gw_current_OS;

	var_list[0].var			= VW_ROT_NO_CON;  /* rotation matrix w/out reference plane */
	var_list[0].var_ptr		= (char *)rotation;
	var_list[0].num_bytes		= sizeof( IGRdouble ) * 16;
	var_list[0].bytes_returned	= &bytes_returned;

	var_list[1].var			= END_PARAM;
	var_list[1].var_ptr		= NULL;
	var_list[1].num_bytes		= 0;
	var_list[1].bytes_returned	= NULL;

	status = dp$inq_set_gragad( msg	= &msg,
			      inq0_set1 = 0,
				  osnum = me->win_ids[0].osnum,
			   gragad_objid = me->win_ids[0].objid,
			    which_error = &which_error,
			       var_list = var_list );

	HScollect_hidden_symbology_overrides( 
		&my_GRid, 
		&me->win_ids[0], 
		&me->located_chansel,
		me->mode,
		rotation );
	}
