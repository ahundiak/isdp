class implementation HSsdpform;




#include "OMminimum.h"
#include "OMtypes.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "stdio.h"

#include "exdef.h"

#include "fontdef.h"
#include "font.h"

#include "grdpbmacros.h"

#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"

#include "msdef.h"
#include "msmacros.h"

#include "hsdef.h"
#include "hsmacros.h"
#include "hsurferrpriv.h"

#include "vedef.h"
#include "vedpbmacros.h"

#include "igecolmacros.h"
#include "hsmacdef.h"
#include "hsmsg.h"

#include "hslight.h"

/*--------------------------
 *  for functions
 *     HSget_dpb_super
 *     HSget_light_objid_and_os
 *     HSget_light
 */
 
#include <stdio.h>
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "HSpr_dpb_imp.h"

/*---------------------------*/


#define ON	1
#define OFF	0
#define MAX_WINDOWS 256
#define EXIT_WITHOUT_UPDATE 10

#define	TOGGLE( field )	(field) = (field) ? FALSE : TRUE;

extern OMuword OPP_HSgragad_class_id;

from HSlghtsrc import HStoggle_displayability;
from IGEgragad import DPgen_update;

%safe

/*
 *  Prototype declaration for static functions
 */

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HSsdpformi.I */
static void HSsdp_set_display_hidden_lines __((
					Form form_ptr, 
					 int mode));

#if defined(__cplusplus)
}
#endif


#undef __

%endsafe


/*---HSsdp_set_display_hidden_lines----------------------------------------*/

static void HSsdp_set_display_hidden_lines ( form_ptr, mode )

Form	form_ptr; 
int	mode;

/*
DESCRIPTION
	This function is used to either display or hide the gadgets used for 
	setting the hidden line parameters in Set Display Parameters.

PARAMETERS
	form_ptr (IN) - a pointer to the set display parameters form
	mode (IN) -     display(ON) or hide(OFF) the gadgets

GLOBALS USED
	none

RETURN VALUES
	none

HISTORY
	06/15/91	R.Druzynski 
		Creation date
*/
	{
	FIg_set_state( form_ptr, HS_SDP_DISPLAY_HIDDEN_LINES, mode );
	
	if( mode == ON )
		{
		FIg_display( form_ptr, HS_SDP_COLOR );
		FIg_display( form_ptr, HS_SDP_COLOR_TITLE );
		FIg_display( form_ptr, HS_SDP_STYLE );
		FIg_display( form_ptr, HS_SDP_STYLE_TITLE );
		FIg_display( form_ptr, HS_SDP_WEIGHT );
		FIg_display( form_ptr, HS_SDP_WEIGHT_TITLE );
		FIg_display( form_ptr, HS_SDP_HIDDEN_SYMBOLOGY_TITLE );
		}
	else
		{
		FIg_erase( form_ptr, HS_SDP_COLOR );
		FIg_erase( form_ptr, HS_SDP_COLOR_TITLE );
		FIg_erase( form_ptr, HS_SDP_STYLE );
		FIg_erase( form_ptr, HS_SDP_STYLE_TITLE );
		FIg_erase( form_ptr, HS_SDP_WEIGHT );
		FIg_erase( form_ptr, HS_SDP_WEIGHT_TITLE );
		FIg_erase( form_ptr, HS_SDP_HIDDEN_SYMBOLOGY_TITLE );
		}
	}
				

#define _start 0

method set_defaults ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	char			buff[40];
	IGRboolean		name_from_color;
	Form			form_ptr;
	IGRuchar	far;

	form_ptr = me->forms[0].form_ptr;	
	me->max_styles = 255;

	/*
	 *  get info from the hsdpb
	 */
	 
	gr$get_hidden_edge_sym( buffer = &me->hidden_symbology );
	gr$get_hidden_so_on( buffer = &me->display_hidden_lines );

	/*
	 *  Initialize the color
	 */

	if( me->hidden_symbology.flags & DPB_USE_ORIG_COLOR )
		{
		ex$message( msgnumb=VE_I_Original, buff=buff );
		}
	else
		{
		name_from_color = ige$get_name_from_color(
					color = me->hidden_symbology.color,
					name  = buff );
					
		if( !name_from_color )
			sprintf( buff, "%hd", me->hidden_symbology.color );
		}

	FIg_set_text( form_ptr, HS_SDP_COLOR, buff );

	/* 
	 *  Initialize the style
	 */		 

	if( me->hidden_symbology.flags & DPB_USE_ORIG_STYLE )
		{
		ex$message( msgnumb=VE_I_Original, buff=buff );
		}
	else
		sprintf( buff, "%d", me->hidden_symbology.style );
			
	FIg_set_text( form_ptr, HS_SDP_STYLE, buff );
		 	
	/*
	 *  Initialize the weight
	 */
	
	if( me->hidden_symbology.flags & DPB_USE_ORIG_WEIGHT )
		{
		ex$message( msgnumb=VE_I_Original, buff=buff );
		}
	else
		sprintf( buff, "%d", me->hidden_symbology.weight );
			
	FIg_set_text( form_ptr, HS_SDP_WEIGHT, buff );
		 
	
	/*
	 *  Initialize the Hidden Line/Symbology fields
	 */
	 
	HSsdp_set_display_hidden_lines( form_ptr, me->display_hidden_lines );

	/*
	 *  Initialize the polygon_generation_tolerance field and
	 *  the transparency_grid field
	 */

	hs$get_shading_tolerance(tolerance = &me->polygon_generation_tol);
	hs$get_trans_grid( trans_grid = &me->transparency_grid);

	sprintf(buff, "%f", me->polygon_generation_tol);
	FIfld_set_text(form_ptr, HS_SDP_POLY_GENERATION_TOL, 0, 0, buff, 0);

	if (me->transparency_grid == HS_GRID_WIDE)
		FIg_set_state_on(form_ptr, HS_SDP_TRANSPARENCY_GRID);
	else
		FIg_set_state_off(form_ptr, HS_SDP_TRANSPARENCY_GRID);

	/*
	 *  Initialize the depth_cue_intensity slider
	 */

	hs$get_depth_cues(far_depth_cue = &far );
	me->depth_cue_intensity = (far/255.0) * 100.0;

	FIg_set_value(form_ptr, HS_SDP_DEPTH_CUE, me->depth_cue_intensity);

	/*
	 * Initialize the Shaded Wireframe Display toggle
	 */

	hs$get_shading_flags( shading_flags = &me->shaded_display );
	me->old_shaded_display = me->shaded_display;

	if ( me->shaded_display & HS_SHADING_STYLED_WIRE )
		FIg_set_state_off(form_ptr, HS_SDP_SHADED_WIREFRAME);
	else
		FIg_set_state_on(form_ptr, HS_SDP_SHADED_WIREFRAME);

	/*
	 * Initialize the Light Source Display toggle
	 */

	if ( me->shaded_display & HS_SHADING_LIGHT_SOURCE_UNDISPLAY )
		FIg_set_state_on(form_ptr, HS_SDP_LIGHT_SRC_DISPLAY);
	else
		FIg_set_state_off(form_ptr, HS_SDP_LIGHT_SRC_DISPLAY);

	/*
	 *	Erase the Stereo Eye Seperation field until implemented
	 */

	FIg_erase( form_ptr, HS_SDP_STEREO_EYE_TITLE );
	FIg_erase( form_ptr, HS_SDP_STEREO_EYE_SEP );
	FIg_erase( form_ptr, HS_SDP_STEREO_BRACKET );
	FIg_erase( form_ptr, HS_SDP_STEREO_WIREFRAME );
	FIg_erase( form_ptr, HS_SDP_STEREO_HIDDEN_LINE );
	FIg_erase( form_ptr, HS_SDP_STEREO_SHADING );
	FIg_erase( form_ptr, HS_SDP_STEREO_RENDERING );

        /*
         *  Erase the shaded wireframe toggle
         */

        FIg_erase( form_ptr, HS_SDP_SHADED_WIREFRAME );	
        FIg_erase( form_ptr, HS_SDP_SHADED_WIREFRAME_TITLE );	
        FIg_erase( form_ptr, HS_SDP_SHADED_WIREFRAME_LEGEND );	
        FIg_erase( form_ptr, HS_SDP_SHADED_WIREFRAME_BRACES );	

	quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;

	char			buff[40], original[40], msg_buff[100];
	IGRboolean		color_from_name;
	IGRshort		color;
	IGRint			num_matched;
	IGRint			i;
	IGRboolean		name_from_color;
	IGRint			style, weight;
	IGRuchar	far;
	IGRdouble		ShadeTol;
	int			sel_flag, r_pos;

	switch( gadget_label )
		{
		case HS_SDP_CHECK:
			FIg_reset( form_ptr, gadget_label );

			/*
			 *  put info to the hsdpb
			 */
	 
			gr$put_hidden_edge_sym( buffer = &me->hidden_symbology );
			gr$put_hidden_so_on( buffer = &me->display_hidden_lines );
			hs$put_shading_tolerance(tolerance = me->polygon_generation_tol);
			hs$put_shading_flags( shading_flags = &me->shaded_display);
			hs$set_trans_grid(trans_grid = me->transparency_grid);

			far = (IGRchar)((me->depth_cue_intensity * 2.55) + 0.5);
			hs$set_depth_cues(far_depth_cue = far); 

			_put_response( resp=EX_FORM_FINISHED );
			FIf_erase( form_ptr );
			break;
			
		case HS_SDP_CANCEL:
			FIg_reset( form_ptr, gadget_label );
			_put_response( resp=EXIT_WITHOUT_UPDATE );
			FIf_erase( form_ptr );
			break;
			
		case HS_SDP_CONVERT_WINDOW:
			break;
			
		case HS_SDP_STYLE:

			FIg_get_text( form_ptr, gadget_label, buff ); 

			/* 
			 * Change to lower case 
			 */
		 
			for( i=0; i<strlen(buff); i++ )
				if( ( (IGRint)(buff[i]) > 64 ) && ( (IGRint)(buff[i]) < 91 ) )
					buff[i] |= 32;

			ex$message( msgnumb=VE_I_Original, buff=original );
			if( strcmp( buff, original ) == 0 )
				{
				me->hidden_symbology.flags |= DPB_USE_ORIG_STYLE;
				FIg_set_text( form_ptr, HS_SDP_STATUS, " " );
				}
			else
				{
				num_matched = sscanf( buff, "%d", &style );
				if( (num_matched != 1) || ( (style < 0) || (style > me->max_styles) ) )
					{
					ex$message( msgnumb=VE_E_BadStyle, buff=buff );
					FIg_set_text(
						form_ptr,
						HS_SDP_STATUS,
						buff );
				}
				else
					{
					me->hidden_symbology.style = style;
					me->hidden_symbology.flags &= ~DPB_USE_ORIG_STYLE;
					FIg_set_text( form_ptr, HS_SDP_STATUS, " " );
					}
				}

			/* 
			 * Update field 
			 */
		 
			if( me->hidden_symbology.flags & DPB_USE_ORIG_STYLE )
				{
				ex$message( msgnumb=VE_I_Original, buff=buff );
				}
			else
				sprintf( buff, "%d", me->hidden_symbology.style );

			FIg_set_text( form_ptr, HS_SDP_STYLE, buff );

			break;

		   case HS_SDP_WEIGHT:

			FIg_get_text( form_ptr, gadget_label, buff ); 

			/* 
			 * Change to lower case 
			 */
		 
			for( i=0; i<strlen(buff); i++ )
				if( ( (IGRint)(buff[i]) > 64 ) && ( (IGRint)(buff[i]) < 91 ) )
					buff[i] |= 32;

			ex$message( msgnumb=VE_I_Original, buff=original );
			if( strcmp( buff, original ) == 0 )
				{
				me->hidden_symbology.flags |= DPB_USE_ORIG_WEIGHT;
				FIg_set_text( form_ptr, HS_SDP_STATUS, " " );
				}
			else
				{
				num_matched = sscanf( buff, "%d", &weight );
				if ((num_matched != 1) || ( (weight < 0) || (weight > 31) ) )
					{
					ex$message( msgnumb=VE_E_BadWeight, buff=buff );
					FIg_set_text(
						form_ptr,
						HS_SDP_STATUS,
						buff );
					}
				else
					{
					me->hidden_symbology.weight = weight;
					me->hidden_symbology.flags &= ~DPB_USE_ORIG_WEIGHT;
					FIg_set_text( form_ptr, HS_SDP_STATUS, " " );
					}
				}

			/* 
			 * Update field 
			 */
		 
			if( me->hidden_symbology.flags & DPB_USE_ORIG_WEIGHT )
				{
				ex$message( msgnumb=VE_I_Original, buff=buff );
				}
			else
				sprintf( buff, "%d", me->hidden_symbology.weight );

			FIg_set_text( form_ptr, HS_SDP_WEIGHT, buff );
	
			break;

		case HS_SDP_COLOR:

			/* 
			 * Get rid of leading/trailing blanks from input, change 
			 * characters to lower case, then try to convert name to 
			 * color code. 
			 */
		 
			FIg_get_text( form_ptr, gadget_label, buff );

			for( i=0; i<strlen(buff); i++ )
				if( ( (IGRint)(buff[i]) > 64 ) && ( (IGRint)(buff[i]) < 91 ) )
					buff[i] |= 32;

			ex$message( msgnumb=VE_I_Original, buff=original );
			if( strcmp( buff, original ) == 0 )
				{
				me->hidden_symbology.flags |= DPB_USE_ORIG_COLOR;
				FIg_set_text( form_ptr, HS_SDP_STATUS, " " );
				}
			else
				{
				color_from_name = ige$get_color_from_name( 
								color = &color,
								name  = buff );

				num_matched = 1;
				if( !color_from_name )
					{			
					/* 
					 * Couldn't find color, so assume keyin was a number 
					 */
				 
					num_matched = sscanf( buff, "%hd", &color );
					}

				if( (num_matched != 1) || (color < 0) || (color > 511) )
					{
					ex$message( msgnumb=VE_E_BadColor, buff=buff );
					FIg_set_text(
						form_ptr,
						HS_SDP_STATUS,
						buff );
					}
				else
					{
					me->hidden_symbology.color = color;
					me->hidden_symbology.flags &= ~DPB_USE_ORIG_COLOR;
					FIg_set_text( form_ptr, HS_SDP_STATUS, " " );
					}
				}

			/* Update field */


			if( me->hidden_symbology.flags & DPB_USE_ORIG_COLOR )
				{
				ex$message( msgnumb=VE_I_Original, buff=buff );
				}
			else
				{
				name_from_color = ige$get_name_from_color( 
							color = me->hidden_symbology.color,
							name  = buff );

				if( !name_from_color )
					sprintf( buff, "%d", me->hidden_symbology.color );
				}

			FIg_set_text( form_ptr, HS_SDP_COLOR, buff );
			break;
			
		case HS_SDP_DISPLAY_HIDDEN_LINES:
			TOGGLE( me->display_hidden_lines );
			HSsdp_set_display_hidden_lines( form_ptr, me->display_hidden_lines );
			break;
			
		case HS_SDP_DEPTH_CUE:
			me->depth_cue_intensity = value;
			break;

		case HS_SDP_TRANSPARENCY_GRID:
			me->transparency_grid = (me->transparency_grid == HS_GRID_WIDE) ?
				HS_GRID_NARROW : HS_GRID_WIDE;
			break;

		case HS_SDP_POLY_GENERATION_TOL:
			FIfld_get_text( form_ptr, HS_SDP_POLY_GENERATION_TOL, 
					0, 0, 10, buff, &sel_flag, &r_pos );
			sscanf(buff, "%lf", &ShadeTol );

			if ( ShadeTol < SHADE_TOL_LOWER || ShadeTol > SHADE_TOL_UPPER ) {
				sprintf( buff, "%lf", me->polygon_generation_tol );
				ex$message( msgnumb = HS_E_InvTol, buff = msg_buff );
				FIg_set_text( form_ptr, HS_SDP_STATUS, msg_buff );
				sleep( 3 );

				msg_buff[0] = '\0';
				FIg_set_text( form_ptr, HS_SDP_STATUS, msg_buff );
				FIfld_set_text( form_ptr, HS_SDP_POLY_GENERATION_TOL,
						 0, 0, buff, 0 );	
			} else
				me->polygon_generation_tol = ShadeTol;
			break;

                case HS_SDP_SHADED_WIREFRAME:
			me->shaded_display ^= HS_SHADING_STYLED_WIRE;
			break;

		case HS_SDP_LIGHT_SRC_DISPLAY:
			me->shaded_display ^= HS_SHADING_LIGHT_SOURCE_UNDISPLAY;
			break;

		default:
			break;
		}
	quit:
  return OM_S_SUCCESS;
}

method process ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	OM_S_OBJID 		dpb_id, light_id;
	OMuword    		dpb_os, light_os;
	int			msg;
	IGRint			i;

	if ( (me->shaded_display & HS_SHADING_LIGHT_SOURCE_UNDISPLAY) !=
	     (me->old_shaded_display & HS_SHADING_LIGHT_SOURCE_UNDISPLAY) )
		{
		/* display of light source graphics has changed */
		HSget_dpb_super( &dpb_id, &dpb_os );

		for( i = 0; i < MAX_LIGHTS; i++ )
			{
			*sts = HSget_light_objid_and_os( i, dpb_id, dpb_os, &light_id, &light_os );

			if( *sts == OM_S_SUCCESS )
				{
				*sts = om$send(	msg = message HSlghtsrc.HStoggle_displayability( &msg ),
						targetid = light_id, targetos = light_os );
				}
	
			}
		}

	ex$message( msgnumb       = HS_I_UpdShdWin,
	            justification = CENTER_JUS,
	            field         = KEYIN_FIELD );
	sleep( 3 );
	ex$message( field = KEYIN_FIELD, in_buff = "" );

	*sts = OM_S_SUCCESS;  /* to make COB happy */
	quit:
  return OM_S_SUCCESS;
}

end implementation HSsdpform;
