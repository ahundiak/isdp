class implementation HSchsform;



#define CHECK_RETURN_CODES 0

#define	SAVE_AND_EXECUTE	4001
#define	IGNORE_AND_EXECUTE	4002

#define ON	1
#define OFF	0

#define	TOGGLE( field )	(field) = ! (field);

#include <stdlib.h>
#include <math.h>

#include "igrtypedef.h"

#include "OMtypes.h"
#include "OMfile_types.h"
#include "stdio.h"

#include "exdef.h"

#include "fontdef.h"
#include "font.h"

#include "grdpbmacros.h"

#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#include "msdef.h"
#include "msmacros.h"

#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hsurferrpriv.h"

#include "vedef.h"
#include "vedpbmacros.h"

#include "igrdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"

#include "igecolmacros.h"

#include "vewinmacros.h"
#include "VEsomacros.h"

#include "hsmessage.h"

/*--------------------------
 *  for function
 *     HSlvhl_collect_element
 */
 
#include <stdio.h>
#include <FI.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "growner.h"
#include "dpstruct.h"
#include "bs.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "godef.h"
#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hswinmacros.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"
#include "HStl_global.h"
#include "HSlvhl.h"
#include "HSpvhl.h"
#include "HSplot.h"
#include "HSpr_lvhl.h"

/*---------------------------*/

from VEgragad import VEprocess;
from IGEgragad import DPgen_update;

				
/*---HSchs_set_tracing-------------------------------------------------------*/

static void	HSchs_set_tracing( form_ptr, mode )

Form	form_ptr;
int	mode;

	{
	FIg_set_state( form_ptr, HS_CHS_TRACING, mode );
	
	if( mode == ON )
		{
		FIg_display( form_ptr, HS_CHS_TRACING_TOLERANCE );
		FIg_display( form_ptr, HS_CHS_TRACING_TOLERANCE_TITLE );
		}
	else
		{
		FIg_erase( form_ptr, HS_CHS_TRACING_TOLERANCE );
		FIg_erase( form_ptr, HS_CHS_TRACING_TOLERANCE_TITLE );
		}
	}

/*---HSchs_set_gapping-------------------------------------------------------*/

static void	HSchs_set_gapping( form_ptr, mode )

Form	form_ptr;
int	mode;

	{
	FIg_set_state( form_ptr, HS_CHS_GAPPING, mode );
	
	if( mode == ON )
		{
		FIg_display( form_ptr, HS_CHS_GAPPING_DISTANCE );
		FIg_display( form_ptr, HS_CHS_GAPPING_DISTANCE_TITLE );
		}
	else
		{
		FIg_erase( form_ptr, HS_CHS_GAPPING_DISTANCE );
		FIg_erase( form_ptr, HS_CHS_GAPPING_DISTANCE_TITLE );
		}
	}

/*---HSchs_set_resolution----------------------------------------------------*/

static void	HSchs_set_resolution(	form_ptr,
					resolution, 
					tracing,
					gapping )

Form		form_ptr;
unsigned char	resolution;
unsigned char	tracing;
unsigned char	gapping;

	{
	IGRchar msgbuff[50];

	switch( resolution )
		{
		case HS_VHL_LOW_RES:
			ex$message( msgnumb = HS_I_Low, buff = msgbuff );
			FIg_set_text( form_ptr, HS_CHS_RESOLUTION, msgbuff );
			break;
			
		case HS_VHL_MEDIUM_RES:
			ex$message( msgnumb = HS_I_Medium, buff = msgbuff );
			FIg_set_text( form_ptr, HS_CHS_RESOLUTION, msgbuff );
			break;
			
		case HS_VHL_HIGH_RES:
			ex$message( msgnumb = HS_I_High, buff = msgbuff );
			FIg_set_text( form_ptr, HS_CHS_RESOLUTION, msgbuff );
			break;
		}
		
	/*
	 *  if resolution is not high then lock tracing and gapping to off
	 */
	 
	if( resolution == HS_VHL_HIGH_RES )
		{
		FIg_enable( form_ptr, HS_CHS_TRACING );
		FIg_enable( form_ptr, HS_CHS_GAPPING );
		
		HSchs_set_tracing( form_ptr, tracing );
		HSchs_set_gapping( form_ptr, gapping );		
		}
	else
		{
		HSchs_set_tracing( form_ptr, OFF );
		HSchs_set_gapping( form_ptr, OFF );

		FIg_disable( form_ptr, HS_CHS_TRACING );
		FIg_disable( form_ptr, HS_CHS_GAPPING );
		}
	}


#define _start 0
#define _get_window 1
#define _get_elements 2

method check_for_old_files ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	OMuword		i;
	IGRboolean	cont_conversion=TRUE;
	int		p_num=0;
        IGRchar		HSmessage[310], HSmsg1[60], HSmsg2[60],
			HSmsg3[60], HSmsg4[60],HSmsg5[60];

	for (i=2;((cont_conversion)&&(i<=OM_Gw_maxOS));i++)
	{
		if (OM_GA_OSDs[i]) /* if valid object space */
		{
			/* get the os type to see if converted 1.* file */
			om$set_os_type( 	osnum = i,
						p_num = &p_num,
						flag = 0 );
			if (p_num==HL_CVT_TO_20)
			{
				ex$message ( msgnumb = HS_W_ConvertedFile1, buff = HSmsg1 );
				ex$message ( msgnumb = HS_W_ConvertedFile2, buff = HSmsg2 );
				ex$message ( msgnumb = HS_W_ConvertedFile3, buff = HSmsg3 );
				ex$message ( msgnumb = HS_W_ConvertedFile4, buff = HSmsg4 );
				ex$message ( msgnumb = HS_W_ConvertedFile5, buff = HSmsg5 );

				sprintf(HSmessage,"%s %s %s %s %s",
					HSmsg1,HSmsg2,HSmsg3,HSmsg4,HSmsg5);

				ex$message ( msgnumb = HS_W_WarnTitle, buff = HSmsg1 );
				
#ifndef X11
				cont_conversion=FI_confirm_box( 
				  FI_CURRENT_SCREEN, -1, -1, 
				  HSmsg1, FI_RED, "swiss742", 36.0,
	                          HSmessage, FI_BLACK, "swiss742", 18.0,
	                          FI_LEFT_JUSTIFIED,FI_ACCEPT|FI_CANCEL,40);
#else
				cont_conversion=HFI_confirm_box( 
				  FI_CURRENT_SCREEN, -1, -1, 
				  HSmsg1, FI_RED, "swiss742", 36.0,
	                          HSmessage, FI_BLACK, "swiss742", 18.0,
	                          FI_LEFT_JUSTIFIED,FI_ACCEPT|FI_CANCEL,40);
#endif
				break;
			}
		}
	}
	if (cont_conversion) *sts=OM_S_SUCCESS;
	else *sts=OM_W_WARNING;
quit:
  return OM_S_SUCCESS;
}

method spawn_elements_in_view ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong	msg;
	IGRlong	size;
	int response;
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

method validate_window ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong         msg;
	IGRlong         ret_bytes;
	IGRlong         which_error;
	IGRint          flags;
	struct var_list var_list[2];

	*sts = OM_S_SUCCESS;

	/* get the name, flags and view volume of the window */
	var_list[0].var            = GRAGAD_FLAGS;
	var_list[0].var_ptr        = (IGRchar *) &flags;
	var_list[0].num_bytes      = sizeof( IGRint );
	var_list[0].bytes_returned = &ret_bytes;
	var_list[1].var            = END_PARAM;

	dp$inq_set_gragad( msg          = &msg,
	                   inq0_set1    = 0,
	                   osnum        = me->win_ids[0].osnum,
	                   gragad_objid = me->win_ids[0].objid,
	                   which_error  = &which_error,
	                   var_list     = var_list );

	if ( flags & IS_PERSP )
	   {
	   ex$message( msgnumb = HS_E_PerspNotAllowed );
	   *sts = OM_W_WARNING;
	   }
	else if ( !(flags & IS_ACTIVE) )
	   {
	   ex$message( msgnumb = HS_E_CollapsedNotAllowed );
	   *sts = OM_W_WARNING;
	   }

	return( OM_S_SUCCESS );
	quit:
  return OM_S_SUCCESS;
}

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

	FIg_set_text( me->form_ptr, HS_CHS_WINDOW_NAME, me->window_name );
	quit:
  return OM_S_SUCCESS;
}

method get_dpb_info ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	unsigned int	flags;
	
	/*
	 *  get info from the hsdpb
	 */
	 
	hs$get_shading_flags( vhl_flags = &flags );

	me->resolution = flags & HS_VHL_RESOLUTION;
	me->clip_to_fence = flags & HS_VHL_CLIP_TO_FENCE ? TRUE : FALSE;
	me->process_wireframe = flags & HS_VHL_PROCESS_WIREFRAME ? TRUE : FALSE;
	me->delete_overrides = flags & HS_VHL_DELETE_OVERRIDES ? TRUE : FALSE;
	me->process_tangent = flags & HS_VHL_DONT_PROCESS_TANGENT ? FALSE : TRUE;
	
	/*
	 *  get info from the vedpb
	 */
	 
	ve$get_dpb_flags( flags = &flags );
	
	me->tracing = flags & VE_VHL_NO_TRACE ? FALSE : TRUE;
	me->gapping = flags & VE_VHL_GAPPING_LINES ? TRUE : FALSE;
	
	ve$get_gapping_distance( gapping_distance = &me->gapping_distance );
	ve$get_trace_tol( trace_tol = &me->tracing_tolerance );
	quit:
  return OM_S_SUCCESS;
}

method set_dpb_info ( long * sts )
{	
  int		  status = OM_S_SUCCESS;

	unsigned int	flags;


	/*
	 *  put info to the hsdpb
	 */
	 
	hs$get_shading_flags( vhl_flags = &flags );

	flags &= ~(HS_VHL_RESOLUTION | 
		   HS_VHL_CLIP_TO_FENCE | 
		   HS_VHL_PROCESS_WIREFRAME |
	           HS_VHL_DELETE_OVERRIDES |
	           HS_VHL_DONT_PROCESS_TANGENT);
	
	flags |= me->resolution;
	flags |= me->clip_to_fence ? HS_VHL_CLIP_TO_FENCE : 0;
	flags |= me->process_wireframe ? HS_VHL_PROCESS_WIREFRAME : 0;
	flags |= me->delete_overrides ? HS_VHL_DELETE_OVERRIDES : 0;
	flags |= me->process_tangent ? 0 : HS_VHL_DONT_PROCESS_TANGENT;

	hs$put_shading_flags( vhl_flags = &flags );

	/*
	 *  get info from the vedpb
	 */
	 
	ve$get_dpb_flags( flags = &flags );
		
	flags &= ~(VE_VHL_NO_TRACE |
		   VE_VHL_GAPPING_LINES);
			   
	flags |= me->tracing ? 0 : VE_VHL_NO_TRACE;
	flags |= me->gapping ? VE_VHL_GAPPING_LINES : 0;

	status = ve$set_dpb_flags( flags = flags );

	ve$set_gapping_distance( gapping_distance = me->gapping_distance );
	ve$set_trace_tol( trace_tol = me->tracing_tolerance );
	quit:
  return OM_S_SUCCESS;
}

method form_init ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	char		buff[40];
	
	me->status_display_form_ptr = (char *)me->form_ptr;
		
	/*
	 *  Initialize data fields
	 */

	sprintf( buff, "%lf", me->tracing_tolerance );
	FIg_set_text( me->form_ptr, HS_CHS_TRACING_TOLERANCE, buff );
	
	sprintf( buff, "%lf", me->gapping_distance );
	FIg_set_text( me->form_ptr, HS_CHS_GAPPING_DISTANCE, buff );
	
	FIg_set_text( me->form_ptr, HS_CHS_WINDOW_NAME, me->window_name );
	
	FIg_set_state( me->form_ptr, HS_CHS_CLIP_TO_FENCE, me->clip_to_fence );

	FIg_set_state( me->form_ptr, HS_CHS_PROCESS_WIREFRAME, me->process_wireframe );

	FIg_set_state( 	me->form_ptr, HS_CHS_DELETE_OVERRIDES, !(me->delete_overrides) );

	FIg_set_state( 	me->form_ptr, HS_CHS_PROCESS_TANGENT_EDGES, !(me->process_tangent) );

	/*
	 *  set the resolution, which will also set the state of, tracing and
	 *  gapping
	 */
	 	
	HSchs_set_resolution( 
		me->form_ptr, 
		me->resolution, 
		me->tracing, 
		me->gapping );
	quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;

	char		buff[40], high[40], medium[40], low[40];
	IGRlong		msg;
	IGRlong		size;
	int 		response;
	
	switch( gadget_label )
		{
		case HS_CHS_CHECK:
			FIg_reset( form_ptr, gadget_label );
			me->switch1 = SAVE_AND_EXECUTE;
			_put_response( resp=EX_FORM_FINISHED );
			FIf_erase( form_ptr );
			break;
			
		case HS_CHS_CANCEL:
			FIg_reset( form_ptr, gadget_label );
			me->switch1 = IGNORE_AND_EXECUTE;
			_put_response( resp=EX_FORM_FINISHED );
			FIf_erase( form_ptr );
			break;
			
		case HS_CHS_TANGENT_EDGES:
			/* call the Toggle Tangent Edge Command */
			FIg_reset( form_ptr, gadget_label );
			strcpy( buff, "MDTgTnEdDs" );
			size = strlen( buff ) + 1;
			response = EX_CMD_KEY;
	
			ex$putque( msg = &msg,
			      response = &response,
				  byte = &size,
				buffer =  buff );
			break;

		case HS_CHS_PROCESS_TANGENT_EDGES:
			TOGGLE( me->process_tangent );
			break;

		case HS_CHS_CLIP_TO_FENCE:
			TOGGLE( me->clip_to_fence );
			break;
			
		case HS_CHS_PROCESS_WIREFRAME:
			TOGGLE( me->process_wireframe );
			break;
			
		case HS_CHS_RESOLUTION:
			FIg_get_text( me->form_ptr, HS_CHS_RESOLUTION, buff );
			ex$message( msgnumb = HS_I_High, buff = high );
			ex$message( msgnumb = HS_I_Medium, buff = medium );
			ex$message( msgnumb = HS_I_Low, buff = low );
			
			if ( strcmp(low, buff) == 0 )
				HSchs_set_resolution( 
					me->form_ptr, 
					me->resolution=HS_VHL_LOW_RES, 
					me->tracing, 
					me->gapping );
			else if( strcmp(medium, buff) == 0 )
				HSchs_set_resolution( 
					me->form_ptr, 
					me->resolution=HS_VHL_MEDIUM_RES, 
					me->tracing, 
					me->gapping );
			else
				HSchs_set_resolution( 
					me->form_ptr, 
					me->resolution=HS_VHL_HIGH_RES, 
					me->tracing, 
					me->gapping );

			break;
			
		case HS_CHS_TRACING:
			TOGGLE( me->tracing );
			HSchs_set_tracing( me->form_ptr, me->tracing );
			break;
			
		case HS_CHS_TRACING_TOLERANCE:
			FIg_get_text( me->form_ptr, HS_CHS_TRACING_TOLERANCE, buff );
			sscanf( buff, "%lf", &me->tracing_tolerance);
			break;
			
		case HS_CHS_GAPPING:
			TOGGLE( me->gapping );
			HSchs_set_gapping( me->form_ptr, me->gapping );
			break;
			
		case HS_CHS_GAPPING_DISTANCE:
			FIg_get_text( me->form_ptr, HS_CHS_GAPPING_DISTANCE, buff );
			sscanf( buff, "%lf", &me->gapping_distance );
			break;
			
		case HS_CHS_DELETE_OVERRIDES:
			TOGGLE( me->delete_overrides );
			break;

		default:
			break;
		}
	quit:
  return OM_S_SUCCESS;
}

method HSchs_init ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	me->form_ptr = (Form)me->status_display_form_ptr;
	me->status_display_form_ptr = NULL;
	quit:
  return OM_S_SUCCESS;
}

method HSchs_wakeup ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRboolean temp_flag = TRUE;

	gr$get_associative_flag( buffer = &me->assoc_flag );

	if ( ! me->assoc_flag )
	   {
	   /* turn associativity on */
	   gr$put_associative_flag( buffer = &temp_flag );
	   }

	/* hilight associativity button */
	GRdisplay_associative_button( TRUE );
	quit:
  return OM_S_SUCCESS;
}

method HSchs_sleep ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRboolean temp_flag = FALSE;

	if ( ! me->assoc_flag )
	   {
	   /* turn associativity off */
	   gr$put_associative_flag( buffer = &temp_flag );
	   }

	/* unhilight associativity button */
	GRdisplay_associative_button( FALSE );
	quit:
  return OM_S_SUCCESS;
}

method HSchs_delete ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	quit:
  return OM_S_SUCCESS;
}

method process ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRint		msg, rstat;
	struct GRid	my_GRid;
	IGRuint 	flags;
	struct var_list	var_list[2];
	IGRint		gragad_flags[2];
	IGRlong		bytes_returned;
	IGRlong		which_error;
	IGRboolean	display_hidden_lines;
	IGRchar		error_msg[150];
	IGRchar		title_msg[100];


        /* synchronize the bits in the drawing views that indicate */
	/* whether the user want tangent edges displayed or not    */
        GRdv_sync_tan_ed_disp_func( &msg, &me->win_ids[0], FALSE, NULL );

	my_GRid.objid = my_id;
	my_GRid.osnum = OM_Gw_current_OS;

	/*
	 *  Make sure the hiding bit is on because Projected Edges
	 *  could have turned it off.
	 */

	hs$get_shading_flags( vhl_flags = &flags );
	flags |= HS_VHL_HIDING;
	hs$put_shading_flags( vhl_flags = &flags );

	/* clear the prompt field */
      	ex$message( field = PROMPT_FIELD, in_buff = " " );

	rstat = TRUE;
	if( me->resolution == HS_VHL_HIGH_RES )
		{
      		ve$make_win_ve( msg = &msg,
                      		win_id = me->win_ids[0].objid,
                      		win_os = me->win_ids[0].osnum );

		/* send interactive VEprocess message to the VEgragad */
		*sts = om$send( msg      = message VEgragad.VEprocess( &msg,
                                                             		&my_GRid,
                                                             		&me->located_chansel,
                                                             		FALSE,
									TRUE ),
                      		targetid = me->win_ids[0].objid,
                      		targetos = me->win_ids[0].osnum );
                      		
		rstat = (*sts == OM_S_SUCCESS);
		}  /* end: if (high resolution) */
	else
		{
		VEsetup_soo_view( me->win_ids[0].objid, me->win_ids[0].osnum );

		gr$get_hidden_so_on( buffer = &display_hidden_lines );
		
		rstat = HSlvhl_collect_elements( 
				&my_GRid, 
				&me->win_ids[0], 
				&me->located_chansel,
				me->resolution,
				display_hidden_lines,
				FALSE,
				FALSE,
				me->process_wireframe,
				me->clip_to_fence,
				TRUE,
				(unsigned short)1021,
				(unsigned short)1022,
				(unsigned short)1023,
				me->delete_overrides,
				FALSE,
				FALSE,
				me->process_tangent );
				
		if( !rstat )
			{
			ex$message( buff = error_msg,
				 msgnumb = HS_I_NoneProcessed );
			ex$message( buff = title_msg,
				 msgnumb = HS_W_WarnTitle );
	 
			FI_message_box( FI_CURRENT_SCREEN, 
					-1, -1,
					title_msg, 
					FI_RED, 
					"swiss742", 36.0,
					error_msg, 
					FI_BLACK, 
					"swiss742", 18.0,
					FI_LEFT_JUSTIFIED, 
					40 );
			}
		}

	if( rstat )
		{
			
		/* turn off rule line display for the window */

		var_list[0].var            = GRAGAD_FLAGS;
		var_list[0].var_ptr        = (IGRchar *) gragad_flags;
		var_list[0].num_bytes      = sizeof(IGRint) * 2;
		var_list[0].bytes_returned = &bytes_returned;
		var_list[1].var            = END_PARAM;

		gragad_flags[0] = gragad_flags[1] = DP_NO_RULE_LINES;

		dp$inq_set_gragad( msg = &msg,
			     inq0_set1 = 1,
			         osnum = me->win_ids[0].osnum,
			  gragad_objid = me->win_ids[0].objid,
			   which_error = &which_error,
			      var_list = var_list );

		dp$gen_update( msg = &msg,
		             osnum = me->win_ids[0].osnum,
		             objid = me->win_ids[0].objid );
		}
	quit:
  return OM_S_SUCCESS;
}

end implementation HSchsform;
