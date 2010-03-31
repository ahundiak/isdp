class implementation VEcheform;



#define CHECK_RETURN_CODES 0

#include <stdio.h>
#include <string.h>

#include <FI.h>

#include "exdef.h"

#include "fontdef.h"
#include "font.h"

#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#include "msdef.h"
#include "msmacros.h"

#include "igecolmacros.h"

#include "VEcheform.h"
#include "veerr.h"
#include "vemsg.h"

#include "hsdef.h"
#include "dpstruct.h"

/* prototype files */
#include "VEpr_utilfnc.h"

/*--- VEto_lower ------------------------------------------------------*/

static void VEto_lower( string )

	IGRchar *string;

/*
NAME
	VEto_lower (static)

DESCRIPTION
	This function converts a string to lower case

PARAMETERS
	string (IN/OUT) - the string to convert to lower case

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRint ii;

	for ( ii = 0; ii < strlen(string); ii++ )
	   {
	   if ( ( string[ii] >= 'A' ) && ( string[ii] <= 'Z' ) )
	      string[ii] |= 32;
	   }

	}  /* VEto_lower */


/*--- VEis_string_original --------------------------------------------*/

static IGRboolean VEis_string_original( string )

	IGRchar *string;

/*
NAME
	VEis_string_original (static)

DESCRIPTION
	This function returns TRUE if the character string that is
	passed in is equal to "original" taking into account possible
	language differences.

PARAMETERS
	string (IN) - the string to test for "original"

RETURN VALUES
	TRUE - if the string matches "original"
	FALSE - otherwise

HISTORY
	xx/xx/91   S.P. Rogers
	    Creation Date
*/

	{
	IGRchar original[40];

	ex$message ( buff = original, msgnumb = VE_I_Original );

	VEto_lower( string );
	VEto_lower( original );
	
	return( (strcmp( string, original ) == 0) );

	}  /* VEis_string_original */


/*--- VEcvrt_to_primary -----------------------------------------------*/

static void VEcvrt_to_primary( osnum, value, string )

	OMuword   osnum;
	IGRdouble *value;
	IGRchar   *string;
/*
NAME
	VEcvrt_to_primary (static)

DESCRIPTION
	This function converts a floating point number that is in working
	units to a character string representation that is in primary
	distance units.

PARAMETERS
	osnum (IN) - the module object space
	value (IN) - the value to convert
	string (OUT) - the string representation of 'value'

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong                 msg;
	IGRlong                 num_alias;
	IGRshort                field_size;
	IGRchar                 temp_string[45];
	struct GRIOreadout_spec readout;

	readout.justification     = GRIO_LEFT_JUSTIFY;
	readout.mode              = GRIO_DECIMAL;
	readout.precision         = 7;
	readout.case_type         = GRIO_DEFAULT_CASE;
	readout.leading_zeros     = TRUE;
	readout.trailing_zeros    = FALSE;
	readout.decimal_char      = GRIO_PERIOD;
	readout.thousands_char    = GRIO_NONE;
	readout.intermeas_spacing = 2;
	readout.intrameas_spacing = 1;
	readout.left_fill_char    = ' ';
	readout.alias_displayed   = FALSE;

	num_alias = 1;
	field_size = sizeof( temp_string );

	co$cvt_imp_to_alias( msg           = &msg,
	                     unit_type     = "UOM_DISTANCE",
	                     working_units = value,
	                     num_alias     = &num_alias,
	                     osnum         = osnum,
	                     readout_spec  = &readout,
	                     field_size    = &field_size,
	                     cvt_list      = temp_string );
	
	strcpy( string, temp_string );

	}  /* VEcvrt_to_primary */


/*--- VEdisplay_form_error -----------------------------------------*/

static void VEdisplay_form_error( error, form_ptr )

	IGRint error;
	Form form_ptr;
/*
NAME
	VEdisplay_form_error (static)

DESCRIPTION
	Prints an error message for a few seconds and then clears
	the error field.

PARAMETERS
	error (IN) - the message key of the error to display
	form_ptr (IN) - form_ptr of form to display error message on

GLOBALS USED
	none

HISTORY
	xx/xx/91    S.P. Rogers
	   Creation Date
*/

	{
	char alpha[80];

	ex$message( buff = alpha, msgnumb = error );
	FIfld_set_text( form_ptr, VE_CHE_STATUS_FIELD, 0, 0, alpha, FALSE );
	sleep( 3 );
	FIfld_set_text( form_ptr, VE_CHE_STATUS_FIELD, 0, 0, "", FALSE );

	}  /* VEdisplay_form_error */


/*--- VEset_symbology_fields -----------------------------------------*/

static void VEset_symbology_fields( form_ptr, symb, color_gadget, style_gadget, weight_gadget )

	Form           form_ptr;
	struct GRhesym *symb;
	IGRint         color_gadget, style_gadget, weight_gadget;
	
/*
NAME
	VEset_symbology_fields (static)

DESCRIPTION
	This function sets the color, style, and weight symbology fields
	on the form based on a symbology that is passed in.  If a gadget label
	is passed in as -1, then it is not set.

PARAMETERS
	form_ptr (IN) - the form_ptr of the form
	symb (IN) - the symbology to set
	color_gadget (IN) - the color gadget to set, -1 to not set color
	style_gadget (IN) - the style gadget to set, -1 to not set style
	weight_gadget (IN) - the weight gadget to set, -1 to not set weight

GLOBALS USED
	none

PARAMETERS
	xx/xx/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRchar    alpha[40];
	IGRchar    color_name[100];
	IGRboolean name_from_color;

	if ( color_gadget != -1 )
	   {
	   if ( symb->flags & DPB_USE_ORIG_COLOR )
	      {
	      ex$message ( buff = alpha, msgnumb = VE_I_Original );
	      }
	   else
	      {
	      name_from_color = ige$get_name_from_color( color = symb->color,
	       	                                         name  = color_name );
	      if ( name_from_color )
	         sprintf( alpha, "%s", color_name );
	      else
	         sprintf( alpha, "%d", symb->color );
	      }

	   FIg_set_text( form_ptr, color_gadget, alpha );
	   }
	   	    
	if ( style_gadget != -1 )
	   {
	   if ( symb->flags & DPB_USE_ORIG_STYLE )
	      {
	      ex$message ( buff = alpha, msgnumb = VE_I_Original );
	      }
	   else
	      sprintf( alpha, "%d", symb->style );
	   	   	   
	   FIg_set_text( form_ptr, style_gadget, alpha );
	   }
	   	    	   
	if ( weight_gadget != -1 )
	   {
	   if( symb->flags & DPB_USE_ORIG_WEIGHT )
	      {
	      ex$message ( buff = alpha, msgnumb = VE_I_Original );
	      }
	   else
	      sprintf( alpha, "%d", symb->weight );
	   	   	   
	   FIg_set_text( form_ptr, weight_gadget, alpha );
	   }

	}  /* VEset_symbology_fields */


/*--- VEset_gapping_gadgets ------------------------------------------*/

static void VEset_gapping_gadgets( form_ptr, gapping, disable )

	Form   form_ptr;
	IGRint gapping;
	IGRint disable;

/*
NAME
	VEset_gapping_gadgets (static)

DESCRIPTION
	This function sets the gapping gadgets to their appropriate
	states.

PARAMETERS
	form_ptr (IN) - the form pointer of the form
	gapping (IN) - TRUE, if gapping is on
	disable (IN) - TRUE, if gadgets should be disabled

GLOBALS USED
	none

HISTORY
	xx/xx/91    S.P. Rogers
	   Creation Date
*/

	{

	if ( disable )
	   {
	   FIg_set_state_off( form_ptr, VE_CHE_GAPPING_TOG );
	   FIg_disable( form_ptr, VE_CHE_GAPPING_TOG );
	   FIg_erase( form_ptr, VE_CHE_GAPPING_GROUP );
	   }
	else if ( gapping )
	   {
	   FIg_set_state_on( form_ptr, VE_CHE_GAPPING_TOG );
	   FIg_enable( form_ptr, VE_CHE_GAPPING_TOG );
	   FIg_display( form_ptr, VE_CHE_GAPPING_GROUP );
	   }
	else
	   {
	   FIg_set_state_off( form_ptr, VE_CHE_GAPPING_TOG );
	   FIg_enable( form_ptr, VE_CHE_GAPPING_TOG );
	   FIg_erase( form_ptr, VE_CHE_GAPPING_GROUP );
	   }

	}  /* VEset_gapping_gadgets */


/*--- VEset_tracing_gadgets ------------------------------------------*/

static void VEset_tracing_gadgets( form_ptr, tracing, disable )

	Form   form_ptr;
	IGRint tracing;
	IGRint disable;

/*
NAME
	VEset_tracing_gadgets (static)

DESCRIPTION
	This function sets the tracing gadgets to their appropriate
	states.

PARAMETERS
	form_ptr (IN) - the form pointer of the form
	tracing (IN) - TRUE, if tracing is on
	disable (IN) - TRUE, if the gadgets should be disabled

GLOBALS USED
	none

HISTORY
	xx/xx/91    S.P. Rogers
	   Creation Date
*/

	{

	if ( disable )
	   {
	   FIg_set_state_off( form_ptr, VE_CHE_TRACE_TOG );
	   FIg_disable( form_ptr, VE_CHE_TRACE_TOG );
	   FIg_erase( form_ptr, VE_CHE_TRACING_GROUP );
	   }
	else if ( tracing )
	   {
	   FIg_set_state_on( form_ptr, VE_CHE_TRACE_TOG );
	   FIg_enable( form_ptr, VE_CHE_TRACE_TOG );
	   FIg_display( form_ptr, VE_CHE_TRACING_GROUP );
	   }
	else
	   {
	   FIg_set_state_off( form_ptr, VE_CHE_TRACE_TOG );
	   FIg_enable( form_ptr, VE_CHE_TRACE_TOG );
	   FIg_erase( form_ptr, VE_CHE_TRACING_GROUP );
	   }

	}  /* VEset_tracing_gadgets */


/*--- VEset_exec_mode_gadgets ----------------------------------------*/

static void VEset_exec_mode_gadgets( form_ptr, interactive, disable )

	Form   form_ptr;
	IGRint interactive;
	IGRint disable;

/*
NAME
	VEset_exec_mode_gadgets (static)

DESCRIPTION
	This function sets the execution mode gadgets to their appropriate
	states.

PARAMETERS
	form_ptr (IN) - the form pointer of the form
	interactive (IN) - TRUE, if interactive : FALSE, if batch
	disable (IN) - TRUE, if gadgets should be disabled

GLOBALS USED
	none

HISTORY
	xx/xx/91    S.P. Rogers
	   Creation Date
*/

	{

	if ( disable )
	   {
	   FIg_set_state_off( form_ptr, VE_CHE_EXEC_MODE_TOG );
	   FIg_disable( form_ptr, VE_CHE_EXEC_MODE_TOG );
	   FIg_erase( form_ptr, VE_CHE_BACKGROUND_GROUP );
	   }
	else if ( interactive )
	   {
	   FIg_set_state_off( form_ptr, VE_CHE_EXEC_MODE_TOG );
	   FIg_enable( form_ptr, VE_CHE_EXEC_MODE_TOG );
	   FIg_erase( form_ptr, VE_CHE_BACKGROUND_GROUP );
	   }
	else
	   {
	   FIg_set_state_on( form_ptr, VE_CHE_EXEC_MODE_TOG );
	   FIg_enable( form_ptr, VE_CHE_EXEC_MODE_TOG );
	   FIg_display( form_ptr, VE_CHE_BACKGROUND_GROUP );
	   }

	}  /* VEset_exec_mode_gadgets */


/*--- VEupdate_resolution_info ---------------------------------------*/

static void VEupdate_resolution_info( ve_vhl_flags, hs_vhl_flags, form_ptr, init )

	IGRuint ve_vhl_flags;
	IGRuint hs_vhl_flags;
	Form    form_ptr;
	IGRint  init;

/*
NAME
	VEupdate_resolution_info (static)

DESCRIPTION
	This function will update the form based on the resolution that
	is curently in effect.

PARAMETERS
	ve_vhl_flags (IN) - ve vhl flags word
	hs_vhl_flags (IN) - hs vhl flags word
	form_ptr (IN) - the form pointer of the form
	init (IN) - TRUE, if this is an initialization call

GLOBALS USED
	none

HISTORY
	xx/xx/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRint  disable;
	IGRint  sel_flag;
	IGRchar alpha[50];

	if ( init )
	   {
	   /* load the list associated with the resolution field */
	   ex$message( buff = alpha, msgnumb = VE_I_High );
	   FIfld_set_list_text( form_ptr, VE_CHE_RESOLUTION_LIST, VE_CHE_HIGH_RES_ROW, 0, alpha, FALSE );
	   ex$message( buff = alpha, msgnumb = VE_I_Medium );
	   FIfld_set_list_text( form_ptr, VE_CHE_RESOLUTION_LIST, VE_CHE_MEDIUM_RES_ROW, 0, alpha, FALSE );
	   ex$message( buff = alpha, msgnumb = VE_I_Low );
	   FIfld_set_list_text( form_ptr, VE_CHE_RESOLUTION_LIST, VE_CHE_LOW_RES_ROW, 0, alpha, FALSE );
	   }

	if ( hs_vhl_flags & HS_VHL_HIDING )
	   {
	   /* Running Create Hidden Edges */
	   switch( hs_vhl_flags & HS_VHL_RESOLUTION )
	      {
	      case HS_VHL_LOW_RES :
	         /* set select state of row to FALSE so it can be selected again */
	         FIfld_set_list_select( form_ptr, VE_CHE_RESOLUTION_LIST, VE_CHE_LOW_RES_ROW, 0, FALSE );
	         FIfld_get_list_text( form_ptr, VE_CHE_RESOLUTION_LIST, VE_CHE_LOW_RES_ROW, 0, 50, alpha, &sel_flag );
	         FIg_set_text( form_ptr, VE_CHE_RESOLUTION_LIST, alpha );
	         disable = TRUE;
	         break;

	      case HS_VHL_MEDIUM_RES :
	         /* set select state of row to FALSE so it can be selected again */
	         FIfld_set_list_select( form_ptr, VE_CHE_RESOLUTION_LIST, VE_CHE_MEDIUM_RES_ROW, 0, FALSE );
	         FIfld_get_list_text( form_ptr, VE_CHE_RESOLUTION_LIST, VE_CHE_MEDIUM_RES_ROW, 0, 50, alpha, &sel_flag );
	         FIg_set_text( form_ptr, VE_CHE_RESOLUTION_LIST, alpha );
	         disable = TRUE;
	         break;

	      case HS_VHL_HIGH_RES :
	         /* set select state of row to FALSE so it can be selected again */
	         FIfld_set_list_select( form_ptr, VE_CHE_RESOLUTION_LIST, VE_CHE_HIGH_RES_ROW, 0, FALSE );
	         FIfld_get_list_text( form_ptr, VE_CHE_RESOLUTION_LIST, VE_CHE_HIGH_RES_ROW, 0, 50, alpha, &sel_flag );
	         FIg_set_text( form_ptr, VE_CHE_RESOLUTION_LIST, alpha );
	         disable = FALSE;
	         break;

	      default:
	         disable = FALSE;
	         break;
	      }  /* end: switch */
	   }
	else
	   disable = FALSE;  /* Projected Edges only runs in High Res mode */
	                     /* so the gadgets should not be disabled      */

	VEset_tracing_gadgets( form_ptr, !(ve_vhl_flags & VE_VHL_NO_TRACE), disable );
	VEset_gapping_gadgets( form_ptr, (ve_vhl_flags & VE_VHL_GAPPING_LINES), disable );
	VEset_exec_mode_gadgets( form_ptr, !(ve_vhl_flags & VE_VHL_BATCH_MODE), disable );

	}  /* VEupdate_resolution_info */


/*--- VEprocess_layer_keyin ---------------------------------------------------------*/

static void VEprocess_layer_keyin( keyin, cur_layer, form_ptr, layer_gadget )

	IGRchar   *keyin;
	IGRushort *cur_layer;
	Form      form_ptr;
	IGRint    layer_gadget;

/*
NAME
	VEprocess_layer_keyin (static)

DESCRIPTION
	This function processes a layer keyin by making sure that it is within
	the valid range.

PARAMETERS
	keyin (IN) - the layer keyin
	cur_layer (IN/OUT) - the layer to change
	form_ptr (IN) - the form pointer of the form
	layer_gadget (IN) - the gadget label of the layer field to update

GLOBALS USED
	none

HISTORY
	xx/xx/91    S.P. Rogers
*/

	{
	IGRchar alpha[40];
	IGRint  layer;

	sscanf( keyin, "%d", &layer );
	if ( ( layer >= 0 ) && ( layer <= 1023 ) )
	   *cur_layer = layer;
	else
	   {
	   VEdisplay_form_error( VE_E_BadLayer, form_ptr );
	   sprintf( alpha, "%d", *cur_layer );
	   FIg_set_text( form_ptr, layer_gadget, alpha );
	   }
	}  /* VEprocess_layer_keyin */



#define _start 0
#define _get_window 1
#define _get_elements 2

method save_form_ptr ( long * sts )
{
  int		  status = OM_S_SUCCESS;


	if ( me->status_display_form_ptr )
	   {
	   me->form_ptr = me->status_display_form_ptr;
	   me->status_display_form_ptr = NULL;
	   }

	quit:
  return OM_S_SUCCESS;
}

method form_init ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRchar alpha[50];
	IGRint  sel_flag;
	Form    form_ptr;

	me->status_display_form_ptr = form_ptr = me->form_ptr;

	/* Write window name on form */
	FIg_set_text( form_ptr, VE_CHE_WINDOW_FIELD, me->gragad_name );


	if ( me->mytype == 0 )
	   {
	   /* Running Create Hidden Edges */
	   FIg_display( form_ptr, VE_CHE_CHE_TEXT );
	   FIg_erase( form_ptr, VE_CHE_CPE_TEXT );
	   FIg_display( form_ptr, VE_CHE_HIDDEN_LINE_DISPLAY_TEXT );
	   if ( me->hidden_line_display )
	      {
	      FIg_set_state_on( form_ptr, VE_CHE_HIDDEN_LINE_DISP_TOG );
	      FIg_display( form_ptr, VE_CHE_HIDDEN_LINE_DISP_GROUP );
	      }
	   else
	      {
	      FIg_set_state_off( form_ptr, VE_CHE_HIDDEN_LINE_DISP_TOG );
	      FIg_erase( form_ptr, VE_CHE_HIDDEN_LINE_DISP_GROUP );
	      }
	   }
	else
	   {
	   /* Running Create Projected Edges */
	   FIg_display( form_ptr, VE_CHE_CPE_TEXT );
	   FIg_erase( form_ptr, VE_CHE_CHE_TEXT );
	   FIg_erase( form_ptr, VE_CHE_HIDDEN_LINE_DISPLAY_TEXT );

	   FIg_erase( form_ptr, VE_CHE_HIDDEN_LINE_DISP_TOG );
	   FIg_erase( form_ptr, VE_CHE_HIDDEN_LINE_DISP_GROUP );
	   FIg_erase( form_ptr, VE_CHE_RESOLUTION_TEXT );
	   FIg_erase( form_ptr, VE_CHE_RESOLUTION_LIST );
	   FIg_erase( form_ptr, VE_CHE_GAPPING_TOG );
	   }

	if ( me->hs_vhl_flags & HS_VHL_CLIP_TO_FENCE )
	   FIg_set_state_on( form_ptr, VE_CHE_FENCE_CLIP_TOG );
	else
	   FIg_set_state_off( form_ptr, VE_CHE_FENCE_CLIP_TOG );

	if ( me->hs_vhl_flags & HS_VHL_PROCESS_WIREFRAME )
	   FIg_set_state_on( form_ptr, VE_CHE_CURVE_PROC_TOG );
	else
	   FIg_set_state_off( form_ptr, VE_CHE_CURVE_PROC_TOG );

	if ( me->hs_vhl_flags & HS_VHL_REF_DISPLAY_OFF )
	   FIg_set_state_on( form_ptr, VE_CHE_REF_FILE_DISP_TOG );
	else
	   FIg_set_state_off( form_ptr, VE_CHE_REF_FILE_DISP_TOG );

	if ( me->hs_vhl_flags & HS_VHL_TEXT_COPY )
	   {
	   FIg_set_state_on( form_ptr, VE_CHE_TEXT_COPY_TOG );
	   FIg_display( form_ptr, VE_CHE_TEXT_COPY_GROUP );
	   }
	else
	   {
	   FIg_set_state_off( form_ptr, VE_CHE_TEXT_COPY_TOG );
	   FIg_erase( form_ptr, VE_CHE_TEXT_COPY_GROUP );
	   }

	FIg_set_text( form_ptr, VE_CHE_STATUS_FIELD, "" );

	sprintf( alpha, "%d", me->visible_level );
	FIg_set_text( form_ptr, VE_CHE_VIS_LAYER_FIELD, alpha );

	sprintf( alpha, "%d", me->hidden_level );
	FIg_set_text( form_ptr, VE_CHE_HID_LAYER_FIELD, alpha );

	sprintf( alpha, "%d", me->text_level );
	FIg_set_text( form_ptr, VE_CHE_TEXT_LAYER_FIELD, alpha );

	VEcvrt_to_primary( me->ModuleInfo.md_id.osnum, &me->trace_tol, alpha );
	FIg_set_text( form_ptr, VE_CHE_TRACE_TOL_FIELD, alpha );

	VEcvrt_to_primary( me->ModuleInfo.md_id.osnum, &me->gapping_distance, alpha );
	FIg_set_text( form_ptr, VE_CHE_GAPPING_DISTANCE_FIELD, alpha );

	FIg_set_text( form_ptr, VE_CHE_START_TIME_FIELD, me->start_time );

	FIg_set_text( form_ptr, VE_CHE_RESULTS_NAME_FIELD, me->results_name );
	
	FIg_set_text( form_ptr, VE_CHE_SERVER_NAME_FIELD, me->server );

	FIg_set_text( form_ptr, VE_CHE_USER_NAME_FIELD, me->user_name );

	FIg_set_text( form_ptr, VE_CHE_PASSWORD_FIELD, me->password );

	/* set up batch mode sequence gadgets */
	FIg_set_next_in_seq( form_ptr, VE_CHE_RESULTS_NAME_FIELD, VE_CHE_SERVER_NAME_FIELD );
	FIg_set_next_in_seq( form_ptr, VE_CHE_SERVER_NAME_FIELD, VE_CHE_USER_NAME_FIELD );
	FIg_set_next_in_seq( form_ptr, VE_CHE_USER_NAME_FIELD, VE_CHE_PASSWORD_FIELD );
	FIg_set_next_in_seq( form_ptr, VE_CHE_PASSWORD_FIELD, VE_CHE_RESULTS_NAME_FIELD );

	ex$message( buff = alpha, msgnumb = VE_I_2D );
	FIfld_set_list_text( form_ptr, VE_CHE_DIMENSION_LIST, VE_CHE_2D_ROW, 0, alpha, FALSE );
	ex$message( buff = alpha, msgnumb = VE_I_3D );
	FIfld_set_list_text( form_ptr, VE_CHE_DIMENSION_LIST, VE_CHE_3D_ROW, 0, alpha, FALSE );

	if ( me->hs_vhl_flags & HS_VHL_RESULTS_DIM )
	   {
	   FIfld_get_list_text( form_ptr, VE_CHE_DIMENSION_LIST, VE_CHE_3D_ROW, 0, 50, alpha, &sel_flag );
	   FIg_set_text( form_ptr, VE_CHE_DIMENSION_LIST, alpha );
	   }
	else
	   {
	   FIfld_get_list_text( form_ptr, VE_CHE_DIMENSION_LIST, VE_CHE_2D_ROW, 0, 50, alpha, &sel_flag );
	   FIg_set_text( form_ptr, VE_CHE_DIMENSION_LIST, alpha );
	   }

	VEupdate_resolution_info( me->ve_vhl_flags, me->hs_vhl_flags, form_ptr, TRUE );

	VEset_symbology_fields( form_ptr, &me->visible_symb,
	                        VE_CHE_VIS_COLOR_FIELD, VE_CHE_VIS_STYLE_FIELD, VE_CHE_VIS_WEIGHT_FIELD );

	VEset_symbology_fields( form_ptr, &me->hidden_symb,
	                        VE_CHE_HID_COLOR_FIELD, VE_CHE_HID_STYLE_FIELD, VE_CHE_HID_WEIGHT_FIELD );

	quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;

	IGRint         msg;
	IGRdouble      out_tol;
	IGRchar        res_name[10],alpha[100], warn_message[100], valid_server[100];
	IGRint         style, weight;
	IGRboolean     color_from_name;
	IGRboolean     bad_name;
	IGRboolean     can_exit;
	IGRshort       color;
	IGRint         num_matched;
	IGRint         sel_flag;
	struct GRhesym *symb;

	switch( gadget_label )
	   {
	   case VE_CHE_CHECK_BUTTON :
	      FIg_reset( form_ptr, VE_CHE_CHECK_BUTTON );
	      
	      can_exit = TRUE;
	      if ( me->ve_vhl_flags & VE_VHL_BATCH_MODE )
	         {
	         /* background mode => make sure server, user name and */
	         /* results file name are defined                      */
	         if ( (me->server[0] == '\0') ||
	              (me->user_name[0] == '\0') ||
	              (me->results_name[0] == '\0') )
	            {
	            can_exit = FALSE;
	            ex$message( buff = warn_message, msgnumb = VE_I_FillInFields1 );
	            ex$message( buff = alpha, msgnumb = VE_I_FillInFields2 );
	            strcat( warn_message, " " );
	            strcat( warn_message, alpha );
	            
                    ex$message( buff = alpha, msgnumb = VE_I_WarnTitle);

	            FI_message_box( FI_CURRENT_SCREEN, -1, -1,
	                            alpha, FI_RED, "swiss742", 36.0,
	                            warn_message, FI_BLACK, "swiss742", 18.0,
	                            FI_LEFT_JUSTIFIED, 40 );
	
	            }
	         }

	      if ( can_exit )
	         {
	         /* save instance data */
	         om$send( msg = message VEedgescmds.read_or_set_dpb_data( &msg, 1 ),
	                  targetid = my_id );

	         _put_response( resp = EX_FORM_FINISHED );
	         }

	      break;

	   case VE_CHE_X_BUTTON :
	      FIg_reset( form_ptr, VE_CHE_X_BUTTON );
	      _put_response( resp = EX_FORM_FINISHED );
	      break;

	   case VE_CHE_HIDDEN_LINE_DISP_TOG :
	      me->hidden_line_display = ! me->hidden_line_display;
	      if ( me->hidden_line_display )
	         FIg_display( form_ptr, VE_CHE_HIDDEN_LINE_DISP_GROUP );
	      else
	         FIg_erase( form_ptr, VE_CHE_HIDDEN_LINE_DISP_GROUP );
	      break;

	   case VE_CHE_FENCE_CLIP_TOG :
	      me->hs_vhl_flags ^= HS_VHL_CLIP_TO_FENCE;
	      break;

	   case VE_CHE_TEXT_COPY_TOG :
	      me->hs_vhl_flags ^= HS_VHL_TEXT_COPY;
	      if ( me->hs_vhl_flags & HS_VHL_TEXT_COPY )
	         FIg_display( form_ptr, VE_CHE_TEXT_COPY_GROUP );
	      else
	         FIg_erase( form_ptr, VE_CHE_TEXT_COPY_GROUP );
	      break;

	   case VE_CHE_CURVE_PROC_TOG :
	      me->hs_vhl_flags ^= HS_VHL_PROCESS_WIREFRAME;
	      break;

	   case VE_CHE_TRACE_TOG :
	      me->ve_vhl_flags ^= VE_VHL_NO_TRACE;
	      if ( me->ve_vhl_flags & VE_VHL_NO_TRACE )
	         FIg_erase( form_ptr, VE_CHE_TRACING_GROUP );
	      else
	         FIg_display( form_ptr, VE_CHE_TRACING_GROUP );
	      break;

	   case VE_CHE_REF_FILE_DISP_TOG :
	      me->hs_vhl_flags ^= HS_VHL_REF_DISPLAY_OFF;
	      break;

	   case VE_CHE_GAPPING_TOG :
	      me->ve_vhl_flags ^= VE_VHL_GAPPING_LINES;
	      if ( me->ve_vhl_flags & VE_VHL_GAPPING_LINES )
	         FIg_display( form_ptr, VE_CHE_GAPPING_GROUP );
	      else
	         FIg_erase( form_ptr, VE_CHE_GAPPING_GROUP );
	      break;

	   case VE_CHE_EXEC_MODE_TOG :
	      me->ve_vhl_flags ^= VE_VHL_BATCH_MODE;
	      if ( me->ve_vhl_flags & VE_VHL_BATCH_MODE )
	         {
	         FIg_display( form_ptr, VE_CHE_BACKGROUND_GROUP );
	         FIg_start_seq( form_ptr, VE_CHE_RESULTS_NAME_FIELD );
	         }
	      else
	         FIg_erase( form_ptr, VE_CHE_BACKGROUND_GROUP );
	      break;

	   case VE_CHE_HID_COLOR_FIELD : case VE_CHE_VIS_COLOR_FIELD :
	      symb = ( gadget_label == VE_CHE_HID_COLOR_FIELD ) ?
	                    &me->hidden_symb : &me->visible_symb;

	      FIg_get_text( form_ptr, gadget_label, alpha );
	      if ( VEis_string_original( alpha ) )
	         symb->flags |= DPB_USE_ORIG_COLOR;
	      else
	         {
	         /* see if keyin was a color name */
	         color_from_name = ige$get_color_from_name( color = &color,
	                                                    name  = alpha );
	         num_matched = 1;
	         if (! color_from_name)
	            {
	   	    /* Couldn't find color name, so assume keyin was a number */
	            num_matched = sscanf( alpha, "%hd", &color );
	            }

	         if ( (num_matched != 1) || (color < 0) || (color > 511) )
	            VEdisplay_form_error( VE_E_BadColor, form_ptr );
	         else
	            {
	            symb->flags &= ~DPB_USE_ORIG_COLOR;
	            symb->color = (IGRushort) color;
 	            }
	         }

	      VEset_symbology_fields( form_ptr, symb, gadget_label, -1, -1 );
	      break;

	   case VE_CHE_HID_STYLE_FIELD : case VE_CHE_VIS_STYLE_FIELD :
	      symb = ( gadget_label == VE_CHE_HID_STYLE_FIELD ) ?
	                    &me->hidden_symb : &me->visible_symb;

	      FIg_get_text( form_ptr, gadget_label, alpha );
	      if ( VEis_string_original( alpha ) )
	         symb->flags |= DPB_USE_ORIG_STYLE;
	      else
	         {
	         num_matched = sscanf( alpha, "%d", &style );
	         if ( (num_matched != 1) || ( (style < 0) || (style > 255) ) )
	            VEdisplay_form_error( VE_E_BadStyle, form_ptr );
	         else
	            {
	            symb->flags &= ~DPB_USE_ORIG_STYLE;
	            symb->style = style;
	            }
	         }

	      VEset_symbology_fields( form_ptr, symb, -1, gadget_label, -1 );
	      break;

	   case VE_CHE_HID_WEIGHT_FIELD : case VE_CHE_VIS_WEIGHT_FIELD :
	      symb = ( gadget_label == VE_CHE_HID_WEIGHT_FIELD ) ?
	                    &me->hidden_symb : &me->visible_symb;

	      FIg_get_text( form_ptr, gadget_label, alpha ); 
	      if ( VEis_string_original( alpha ) )
	         symb->flags |= DPB_USE_ORIG_WEIGHT;
	      else
	         {
	         num_matched = sscanf( alpha, "%d", &weight );
	         if ( (num_matched != 1) || ( (weight < 0) || (weight > 31) ) )
	            VEdisplay_form_error( VE_E_BadWeight, form_ptr );
	         else
	            {
	            symb->flags &= ~DPB_USE_ORIG_WEIGHT;
	            symb->weight = weight;
	            }
	         }

	      VEset_symbology_fields( form_ptr, symb, -1, -1, gadget_label );
	      break;

	   case VE_CHE_TRACE_TOL_FIELD :

 	      FIg_get_text( form_ptr, VE_CHE_TRACE_TOL_FIELD, alpha );

	      /* convert user keyin to working units */
	      out_tol = -1.0;
	      co$expreval( msg        = &msg,
	                   expression = alpha,
	                   unit_type  = GRIO_DISTANCE,
	                   result     = &out_tol );

	      if ( out_tol < me->cht )
	         VEdisplay_form_error( VE_E_BadTraceTol, form_ptr );
	      else
	         me->trace_tol = out_tol;

	      /* convert tolerance back to output units and write it to the form */
	      VEcvrt_to_primary( me->ModuleInfo.md_id.osnum, &me->trace_tol, alpha );

	      FIg_set_text( form_ptr, VE_CHE_TRACE_TOL_FIELD, alpha );
	      break;

	   case VE_CHE_GAPPING_DISTANCE_FIELD :

 	      FIg_get_text( form_ptr, VE_CHE_GAPPING_DISTANCE_FIELD, alpha );

	      /* convert user keyin to working units */
	      out_tol = -1.0;
	      co$expreval( msg        = &msg,
	                   expression = alpha,
	                   unit_type  = GRIO_DISTANCE,
	                   result     = &out_tol );

	      if ( out_tol < me->cht )
	         VEdisplay_form_error( VE_E_BadTraceTol, form_ptr );
	      else
	         me->gapping_distance = out_tol;

	      /* convert tolerance back to output units and write it to the form */
	      VEcvrt_to_primary( me->ModuleInfo.md_id.osnum, &me->gapping_distance, alpha );
	      FIg_set_text( form_ptr, VE_CHE_GAPPING_DISTANCE_FIELD, alpha );
	      break;

	   case VE_CHE_VIS_LAYER_FIELD :

	      FIg_get_text( form_ptr, gadget_label, alpha );
	      VEprocess_layer_keyin( alpha, &me->visible_level, form_ptr, gadget_label );
	      break;

	   case VE_CHE_TEXT_LAYER_FIELD :

	      FIg_get_text( form_ptr, gadget_label, alpha );
	      VEprocess_layer_keyin( alpha, &me->text_level, form_ptr, gadget_label );
	      break;

	   case VE_CHE_HID_LAYER_FIELD :

	      FIg_get_text( form_ptr, gadget_label, alpha );
	      VEprocess_layer_keyin( alpha, &me->hidden_level, form_ptr, gadget_label );
	      break;

	   case VE_CHE_RESULTS_NAME_FIELD :

	      /* validate the name somewhat:  check the length and */
	      /* make sure it doesn't have any slashes and that it */
	      /* isn't equal to "." or ".."                        */
	      bad_name = FALSE;

	      FIg_get_text( form_ptr, VE_CHE_RESULTS_NAME_FIELD, alpha );

	      bad_name = ( (strlen( alpha ) > 14) ||
	                   (strchr( alpha, '/' )  != NULL) ||
	                   (strcmp( alpha, "." )  == 0) ||
	                   (strcmp( alpha, ".." ) == 0) );

	      if ( bad_name )
	         {
	         VEdisplay_form_error( VE_E_BadResFname, form_ptr );
	         FIg_set_text( form_ptr, VE_CHE_RESULTS_NAME_FIELD, me->results_name );
	         }
	      else
	         strcpy( me->results_name, alpha );

	      break;

	   case VE_CHE_SERVER_NAME_FIELD :

	      FIg_get_text( form_ptr, VE_CHE_SERVER_NAME_FIELD, alpha );
	      if ( VEvalidate_server_name( alpha, valid_server ) )
	         strcpy( me->server, valid_server );
	      else
	         {
	         VEdisplay_form_error( VE_E_BadServerName, form_ptr );

	         /* keep sequence at this field */
	         FIg_start_seq( form_ptr, VE_CHE_SERVER_NAME_FIELD );
		 }

	      FIg_set_text( form_ptr, VE_CHE_SERVER_NAME_FIELD, me->server );
	      break;

	   case VE_CHE_USER_NAME_FIELD :

	      FIg_get_text( form_ptr, VE_CHE_USER_NAME_FIELD, me->user_name );
	      break;

	   case VE_CHE_PASSWORD_FIELD :

	      FIg_get_text( form_ptr, VE_CHE_PASSWORD_FIELD, me->password );
	      break;

	   case VE_CHE_START_TIME_FIELD :
	      FIg_get_text( form_ptr, VE_CHE_START_TIME_FIELD, me->start_time );
	      break;

	   case VE_CHE_DIMENSION_LIST :

	      FIg_get_text( form_ptr, VE_CHE_DIMENSION_LIST, res_name );
	      ex$message( buff = alpha, msgnumb = VE_I_2D );
	      sel_flag=!(strcmp(alpha,res_name));

	      if ( sel_flag )
	         {
	         me->hs_vhl_flags &= ~HS_VHL_RESULTS_DIM;
	         /* set select state of row to FALSE so it can be selected again */
	         FIfld_set_list_select( form_ptr, VE_CHE_DIMENSION_LIST, VE_CHE_2D_ROW, 0, FALSE );
	         }
	      else
	         {
	         me->hs_vhl_flags |= HS_VHL_RESULTS_DIM;
	         /* set select state of row to FALSE so it can be selected again */
	         FIfld_set_list_select( form_ptr, VE_CHE_DIMENSION_LIST, VE_CHE_3D_ROW, 0, FALSE );
	         }
	      break;

	   case VE_CHE_RESOLUTION_LIST :

	      me->hs_vhl_flags &= ~HS_VHL_RESOLUTION;
	      /* changed to get the text and compare because of record playback just stuffs text instead
	         of changing the active row. */
	      FIg_get_text( form_ptr, VE_CHE_RESOLUTION_LIST, res_name );
	      ex$message( buff = alpha, msgnumb = VE_I_High );
	      sel_flag=!(strcmp(alpha,res_name));
	     
	      if ( sel_flag )
	         me->hs_vhl_flags |= HS_VHL_HIGH_RES;
	      else
	         {
		 ex$message( buff = alpha, msgnumb = VE_I_Medium );
		 FIg_get_text( form_ptr, VE_CHE_RESOLUTION_LIST, res_name );
	         sel_flag=!(strcmp(alpha,res_name));
	         if ( sel_flag )
	            me->hs_vhl_flags |= HS_VHL_MEDIUM_RES;
	         else
	            me->hs_vhl_flags |= HS_VHL_LOW_RES;
	         }

	      VEupdate_resolution_info( me->ve_vhl_flags, me->hs_vhl_flags, form_ptr, FALSE );
	      break;

	   default:
	      break;

	   }  /* end: switch */

	quit:
  return OM_S_SUCCESS;
}

end implementation VEcheform;
