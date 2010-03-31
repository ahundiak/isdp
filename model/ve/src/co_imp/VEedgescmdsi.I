class implementation VEedgescmds;



#define	DEBUG			0
#define CHECK_RETURN_CODES	0

#include <stdio.h>
#include <string.h>

#include "exdef.h"

#include "dp.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "dpdef.h"

#include "grdpbmacros.h"

#include "bs.h"
#include "bsparameters.h"

#include "msdef.h"
#include "msmacros.h"

#include "veerr.h"
#include "vemsg.h"
#include "vewinmacros.h"
#include "vedpbmacros.h"

#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"

from IGEgragad import DPhidden_line_allowed;
from VEgragad  import VEprocess, VEsubmit_batch;

/* prototype files */
#include "VEpr_dpb.h"
#include "VEpr_utilimp.h"
#include "VEpr_utilfnc.h"



#define _get_window 0

method put_event_back_on_queue ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong msg;

	ex$putque( msg = &msg,
	           response = &me->event1.response,
	           byte = (IGRlong *)&me->event1.nbytes,
	           buffer =  me->response_data );
			  
	quit:
  return OM_S_SUCCESS;
}

method spawn_elements_in_view ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong msg;
	IGRlong size;
	int     response;
	IGRint  status_form_displayed;
	IGRchar command_key[30];
	
	status_form_displayed = FALSE;
	if ( me->status_display_form_ptr )
	   FIf_is_displayed( me->status_display_form_ptr, &status_form_displayed );

	if ( status_form_displayed )
	   *sts = OM_W_WARNING;
	else
	   {
	   *sts = OM_S_SUCCESS;

	   size = strlen( me->gragad_name ) + 1;
	   response = EX_STRING;
		
	   ex$putque( msg = &msg,
	              response = &response,
	              byte = &size,
	              buffer = me->gragad_name );
			  
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

method fix_cell_locate ( IGRint *sts; IGRint on0_off1 )
{
  int		  status = OM_S_SUCCESS;

	IGRint value;

	if ( on0_off1 == 0 )
	   {
	   /* turn cell component locate on */
	   value = GRclcomplocon( 1 );
	   }
	else
	   {
	   /* turn cell component locate off */
	   value = GRclcomplocon( 0 );
	   }

	quit:
  return OM_S_SUCCESS;
}

method cleanup ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong         msg;

	ex$message( field = ERROR_FIELD, in_buff = " " );
	ex$message( field = KEYIN_FIELD, in_buff = " " );

	dp$erase_hilite( msg = &msg );

	quit:
  return OM_S_SUCCESS;
}

method initialize_instance_data ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong rc;
	IGRint  msg;

	/* get the CHT */
	BSxtractpar( &rc, BSTOLCHRDHT, &me->cht );

	*sts = om$send( targetid = my_id,
	                msg = message VEedgescmds.read_or_set_dpb_data( &msg, 0 ) );

	if ( me->mytype == 0 )
	   me->hs_vhl_flags |= HS_VHL_HIDING;
	else
	   me->hs_vhl_flags &= ~HS_VHL_HIDING;

	return( OM_S_SUCCESS );

	quit:
  return OM_S_SUCCESS;
}

method get_window_by_object_id ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	me->gragad.objid = me->event1.event.value;
	me->gragad.osnum = me->ModuleInfo.md_id.osnum;  /* windows always in master environment */
	quit:
  return OM_S_SUCCESS;
}

method get_selected_window ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong         msg;
	IGRlong         num_id;
	IGRlong         total_found;
	IGRlong         ret_bytes;
	IGRlong         which_error;
	IGRboolean      hidden_line_allowed;
	IGRint          flags;
	struct GRid     wnid[40];
	struct var_list var_list[4];

	*sts = OM_S_SUCCESS;

	if ( me->event1.response == EX_DATA )
	   {
	   /* user hit a data button in a window */
	   me->gragad.objid = me->event1.event.button.objid;
	   me->gragad.osnum = me->event1.event.button.osnum;
	   }
	else
	   {
	   /* user keyed in a window name */
	   num_id = 0;

	   /* get the window id from the string */
	   dp$get_gragad_id( msg         = &msg,
	                     name        = me->event1.event.keyin,
                             array_size  = 40,
                             total_num   = &total_found,
	                     numberofids = &num_id,
	                     found_GRids = wnid,
	                     type_gragad = ALL_GG_CLASSES | GG_WIN_ON );

	      MSG_ERRCHK( msg, "VEnonform:  dp$get_gragad_id failed" );

	   if ( num_id == 0 )
	      {
	      /* Invalid window */
	      *sts = OM_W_WARNING;
	      ex$message( msgnumb = VE_E_WinNotFound );
	      }
	   else if ( num_id == 1 )
	      {
	      me->gragad.objid = wnid[0].objid;
	      me->gragad.osnum = wnid[0].osnum;
	      }
	   else
	      {
	      *sts = OM_W_WARNING;
	      ex$message( msgnumb = VE_E_WinAmbig );
	      }

	   }  /* end: else */

	if ( *sts == OM_S_SUCCESS )
	   {
	   /* check to see if the window supports hidden line */
	   hidden_line_allowed = FALSE;
	   om$send( msg      = message IGEgragad.DPhidden_line_allowed( &hidden_line_allowed ),
	            targetid = me->gragad.objid,
	            targetos = me->gragad.osnum );

	   if ( ! hidden_line_allowed )
	      {
	      *sts = OM_W_WARNING;
	      ex$message( msgnumb = VE_E_NoHiddenLine );
	      }
	   }

	if ( *sts == OM_S_SUCCESS )
	   {
	   /* get the name, flags and view volume of the window */
	   var_list[0].var            = GRAGAD_NAME;
	   var_list[0].var_ptr        = me->gragad_name;
	   var_list[0].num_bytes      = sizeof( me->gragad_name );
	   var_list[0].bytes_returned = &ret_bytes;
	   var_list[1].var            = GRAGAD_FLAGS;
	   var_list[1].var_ptr        = (IGRchar *) &flags;
	   var_list[1].num_bytes      = sizeof( IGRint );
	   var_list[1].bytes_returned = &ret_bytes;
	   var_list[2].var            = VW_VOLUME;
	   var_list[2].var_ptr        = (IGRchar *) me->vvol;
	   var_list[2].num_bytes      = sizeof( IGRdouble ) * 6;
	   var_list[2].bytes_returned = &ret_bytes;
	   var_list[3].var            = END_PARAM;

	   dp$inq_set_gragad( msg          = &msg,
	                      inq0_set1    = 0,
	                      osnum        = me->gragad.osnum,
	                      gragad_objid = me->gragad.objid,
	                      which_error  = &which_error,
	                      var_list     = var_list );

	       MSG_ERRCHK( msg, "VEedgescmds: dp$inq_set_gragad failed" );

	   if ( flags & IS_PERSP )
	      {
	      ex$message( msgnumb = VE_E_PerspNotAllowed );
	      *sts = OM_W_WARNING;
	      }

	   }  /* end: if ( *sts == OM_S_SUCCESS ) */

	quit:
  return OM_S_SUCCESS;
}

method get_background_confirmation ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRchar    temp_buff[80];
	IGRchar    user_message[300];
	IGRchar    title_message[15];

	*sts = OM_S_SUCCESS;

	if ( me->ve_vhl_flags & VE_VHL_BATCH_MODE )
	   {
	   /* see if we can connect to the server */
	   switch ( VEverify_server_connection( me->server, me->user_name, me->password ) )
	      {
	      case 0 :
	         /* everything is ok */
	         *sts = OM_S_SUCCESS;
	         break;

	      case 1 :
	         /* couldn't connect */
	         ex$message( msgnumb = VE_I_CantConnect,
	                     buff    = user_message,
	                     type    = "%s",
	                     var     = `me->server` );

                 ex$message( msgnumb = VE_I_WarnTitle,
                             buff   = title_message );

	         FI_message_box( FI_CURRENT_SCREEN, -1, -1,
	                         title_message, FI_RED, "swiss742", 36.0,
	                         user_message, FI_BLACK, "swiss742", 18.0,
	                         FI_LEFT_JUSTIFIED, 40 );

	         *sts = OM_W_WARNING;
	         break;

	      case 2 :
	         /* server is not a Clipper */
	         ex$message( msgnumb = VE_I_ServerNotClipper,
	                     buff    = user_message )

                 ex$message( msgnumb = VE_I_WarnTitle,
                             buff    = title_message );

	         FI_message_box( FI_CURRENT_SCREEN, -1, -1,
	                         title_message, FI_RED, "swiss742", 36.0,
	                         user_message, FI_BLACK, "swiss742", 18.0,
	                         FI_LEFT_JUSTIFIED, 40 );

	         *sts = OM_W_WARNING;
	         break;
	      }

	   if ( *sts == OM_S_SUCCESS )
	      {
	      /* warn user about the current file being saved */
	      /* and ask him to confirm his intentions        */
	      ex$message( msgnumb = VE_I_SaveWarning1, buff = user_message );
	   
	      ex$message( msgnumb = VE_I_SaveWarning2, buff = temp_buff );
	      strcat( user_message, " " );
	      strcat( user_message, temp_buff );

	      ex$message( msgnumb = VE_I_SaveWarning3, buff = temp_buff );
	      strcat( user_message, " " );
	      strcat( user_message, temp_buff );

	      ex$message( msgnumb = VE_I_SaveWarning4, buff = temp_buff );
	      strcat( user_message, " " );
	      strcat( user_message, temp_buff );

	      if ( ! VEconfirm( user_message ) )
	         *sts = OM_W_WARNING;
	      }

	   }  /* end: if ( submitting batch job ) */

	quit:
  return OM_S_SUCCESS;
}

method read_or_set_dpb_data ( IGRint *sts; IGRint read0_set1; )
{
  int		  status = OM_S_SUCCESS;

	if ( read0_set1 == 0 )
	   {
	   ve$get_last_bg_info( last_server = me->server,
	                        last_user_name = me->user_name,
	                        last_password = me->password,
	                        last_results_file = me->results_name,
	                        last_start_time = me->start_time );

	   ve$get_dpb_flags( flags = &me->ve_vhl_flags );

	   ve$get_gapping_distance( gapping_distance = &me->gapping_distance );

	   ve$get_trace_tol( trace_tol = &me->trace_tol );

	   ve$get_reduction_thresholds( surf_threshold = &me->surf_threshold,
	                                curve_threshold = &me->curve_threshold );

	   hs$get_vhl_layers( vhl_visible_layer = &me->visible_level,
	                      vhl_hidden_layer = &me->hidden_level,
	                      vhl_text_layer = &me->text_level );

	   hs$get_shading_flags( vhl_flags = &me->hs_vhl_flags );

	   gr$get_hidden_edge_sym( buffer = &me->hidden_symb );
	   gr$get_visible_edge_sym( buffer = &me->visible_symb );
	   gr$get_hidden_so_on( buffer = &me->hidden_line_display );
	   }
	else
	   {
	   ve$set_last_bg_info( last_server = me->server,
	                        last_user_name = me->user_name,
	                        last_password = me->password,
	                        last_results_file = me->results_name,
	                        last_start_time = me->start_time );

	   ve$set_dpb_flags( flags = me->ve_vhl_flags );

	   ve$set_gapping_distance( gapping_distance = me->gapping_distance );

	   ve$set_trace_tol( trace_tol = me->trace_tol );

	   ve$set_reduction_thresholds( surf_threshold = me->surf_threshold,
	                                curve_threshold = me->curve_threshold );

	   hs$set_vhl_layers( vhl_visible_layer = me->visible_level,
	                      vhl_hidden_layer = me->hidden_level,
	                      vhl_text_layer = me->text_level );

	   hs$put_shading_flags( vhl_flags = &me->hs_vhl_flags );

	   gr$put_hidden_edge_sym( buffer = &me->hidden_symb );
	   gr$put_visible_edge_sym( buffer = &me->visible_symb );
	   gr$put_hidden_so_on( buffer = &me->hidden_line_display );
	   }

	quit:
  return OM_S_SUCCESS;
}

method process ( IGRint *sts; IGRint batch_mode )
{
  int		  status = OM_S_SUCCESS;

	IGRint       msg;
	struct GRid  my_GRid;

	my_GRid.objid = my_id;
	my_GRid.osnum = OM_Gw_current_OS;

	if ( batch_mode )
	   {
	   /* running HVHL in batch */
	   *sts = om$send( msg      = message VEgragad.VEprocess( &msg,
	                                                          &my_GRid,
	                                                          &me->located_chansel,
	                                                          batch_mode,
	                                                          FALSE ),
	                   targetid = me->gragad.objid,
	                   targetos = me->gragad.osnum );

	      OM_ERRCHK( *sts, "VEedgescmds: VEgragad.VEprocess send failed" );
	   }
	else if ( ((me->hs_vhl_flags & HS_VHL_RESOLUTION) == HS_VHL_HIGH_RES) ||
	          (me->mytype == 1) )
	   {
	   /* running high resolution VHL or Create Projected Edges */
	   
	   *sts = om$send( msg = message VEedgescmds.get_background_confirmation( (IGRlong *)&msg ),
	                   targetid = my_id );

	   if ( msg != OM_S_SUCCESS )
	      return( OM_S_SUCCESS );  /* couldn't connect to server or user didn't want to save file */

	   ve$make_win_ve( msg = (IGRlong *)&msg,
	                   win_id = me->gragad.objid,
	                   win_os = me->gragad.osnum );

	   /* clear the prompt field */
	   ex$message( field = PROMPT_FIELD, in_buff = " " );

	   if ( (me->ve_vhl_flags & VE_VHL_BATCH_MODE) == 0 )
	      {
	      /* send interactive VEprocess message to the VEgragad */
	      *sts = om$send( msg      = message VEgragad.VEprocess( &msg,
	                                                             &my_GRid,
	                                                             &me->located_chansel,
	                                                             batch_mode,
	                                                             FALSE ),
	                      targetid = me->gragad.objid,
	                      targetos = me->gragad.osnum );

	         OM_ERRCHK( *sts, "VEedgescmds: VEgragad.VEprocess send failed" );
	      }
	   else
	      {
	      /* send VEsubmit_batch message to the VEgragad so that it */
	      /* will submit a background job                           */
	      *sts = om$send( msg      = message VEgragad.VEsubmit_batch( &msg,
	                                                                  &my_GRid,
	                                                                  &me->located_chansel,
	                                                                  me->results_name,
	                                                                  me->server,
	                                                                  me->user_name,
	                                                                  me->password,
	                                                                  me->start_time ),
	                      targetid = me->gragad.objid,
	                      targetos = me->gragad.osnum );

	         OM_ERRCHK( *sts, "VEedgescmds: VEgragad.VEsubmit_batch send failed" );

	      }

	   }  /* end: if (high resolution) */
	else
	   {
	   /* running low or medium resolution VHL */
	   HSlvhl_collect_elements( &my_GRid, &me->gragad, &me->located_chansel,
	                            me->hs_vhl_flags & HS_VHL_RESOLUTION,
	                            me->hidden_line_display,
	                            me->hs_vhl_flags & HS_VHL_TEXT_COPY,
	                            me->hs_vhl_flags & HS_VHL_RESULTS_DIM,
	                            me->hs_vhl_flags & HS_VHL_PROCESS_WIREFRAME,
	                            me->hs_vhl_flags & HS_VHL_CLIP_TO_FENCE,
	                            FALSE,  /* output soos */
	                            me->visible_level,
	                            me->hidden_level,
	                            me->text_level,
	                            FALSE, /* delete user symb. overrides */
				    me->hs_vhl_flags & HS_VHL_REF_DISPLAY_OFF,
				    FALSE );
	   }

	quit:
  return OM_S_SUCCESS;
}

end implementation VEedgescmds;
