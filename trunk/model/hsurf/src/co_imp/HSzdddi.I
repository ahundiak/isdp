class implementation HSzddd;



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


#define _start 0
#define _get_window 1
#define _get_elements 2

method get_window_name ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
	quit:
  return OM_S_SUCCESS;
}

method spawn_elements_in_view ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
	quit:
  return OM_S_SUCCESS;
}

method which_state ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	*sts = me->switch1;
	quit:
  return OM_S_SUCCESS;
}

method set_delete_mode ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	me->mode = DELETE_MODE;
	quit:
  return OM_S_SUCCESS;
}

method set_dump_mode ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	me->mode = DUMP_MODE;
	quit:
  return OM_S_SUCCESS;
}

method display_mode_title ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
	quit:
  return OM_S_SUCCESS;
}

method process ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
	quit:
  return OM_S_SUCCESS;
}

end implementation HSzddd;
