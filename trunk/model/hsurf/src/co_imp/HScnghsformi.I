class implementation HScnghsform;



#define	TOGGLE( field )	(field) = ! (field);

#include <stdio.h>
#include <FI.h>
#include "wl.h"

#include "OMminimum.h"
#include "OMtypes.h"
#include "igrtypedef.h"

#include "exdef.h"

#include "fontdef.h"
#include "font.h"

#include "grdpbmacros.h"

#include "igecolmacros.h"

#include "msdef.h"
#include "msmacros.h"

#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hsurferrpriv.h"
#include "HScghs_label.h"
#include "hsurf.h"
#include "hsmsg.h"

#include "vedef.h"
#include "vedpbmacros.h"

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

/* HScnghsformi.I */
static void HScghs_init_symb_fields __((	Form form_ptr, 
					     OMuword osnum, 
				      struct GRhesym *symb, 
					      IGRint color_gadget, 
					      IGRint style_gadget, 
					      IGRint weight_gadget));
					      
static void HScghs_set_display_hidden_lines __((Form form_ptr, 
						 int display_hidden_lines));
						 
static void HScghs_process_style_keyin __((	Form form_ptr, 
				      struct GRhesym *symb, 
					     IGRchar *buff));
					     
static void HScghs_process_weight_keyin __((	Form form_ptr, 
				      struct GRhesym *symb, 
					     IGRchar *buff));
					     
static void HScghs_process_color_keyin __((	Form form_ptr, 
				      struct GRhesym *symb, 
					     IGRchar *buff));

#if defined(__cplusplus)
}
#endif


#undef __

%endsafe

/*---HScghs_init_symb_fields----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HScghs_init_symb_fields( Form form_ptr,
					  OMuword osnum,
				   struct GRhesym *symb,
					   IGRint color_gadget, 
					   IGRint style_gadget, 
					   IGRint weight_gadget )
#else
	static void HScghs_init_symb_fields( form_ptr, osnum, symb, color_gadget, style_gadget, weight_gadget )

	Form           form_ptr;
	OMuword        osnum;
	struct GRhesym *symb;
	IGRint         color_gadget, style_gadget, weight_gadget;
#endif

	{
	IGRchar    buff[40];
	IGRboolean name_from_color;

	if( symb->flags & DPB_USE_ORIG_COLOR )
		{
		ex$message( msgnumb=HS_I_Original, buff=buff );
		}
	else
		{
		name_from_color = ige$get_name_from_color( color = symb->color,
	                                                   name  = buff,
	                                                   mod_osnum = osnum );
					
		if( !name_from_color )
			sprintf( buff, "%hd", symb->color );
		}

	FIg_set_text( form_ptr, color_gadget, buff );

	if( symb->flags & DPB_USE_ORIG_STYLE )
		{
		ex$message( msgnumb=HS_I_Original, buff=buff );
		}
	else
		sprintf( buff, "%d", symb->style );
			
	FIg_set_text( form_ptr, style_gadget, buff );
		 	
	if( symb->flags & DPB_USE_ORIG_WEIGHT )
		{
		ex$message( msgnumb=HS_I_Original, buff=buff );
		}
	else
		sprintf( buff, "%d", symb->weight );
			
	FIg_set_text( form_ptr, weight_gadget, buff );
	}  /* HScghs_init_symb_fields */
		 

/*---HScghs_set_display_hidden_lines----------------------------------------*/

static void HScghs_set_display_hidden_lines ( form_ptr, display_hidden_lines )

Form	form_ptr; 
int	display_hidden_lines;

	{
	FIg_set_state( form_ptr, HS_CHS_DISPLAY_HIDDEN_LINES, display_hidden_lines );
	
	if( display_hidden_lines )
		{
		FIg_display( form_ptr, HS_CHS_HIDDEN_SYMBOLOGY_GROUP );
		}
	else
		{
		FIg_erase( form_ptr, HS_CHS_HIDDEN_SYMBOLOGY_GROUP );
		}

	}  /* HScghs_set_display_hidden_lines *.
				

/*--- HScghs_process_style_keyin----------------------------------------------*/

static void HScghs_process_style_keyin( form_ptr, symb, buff )

	Form           form_ptr;
	struct GRhesym *symb;
	IGRchar        *buff;

	{
	IGRint	ii;
	IGRint	num_matched;
	IGRint	style;
	IGRchar	original[40];
	IGRchar msg_buff[100];

	/* Change to lower case */
	for( ii = 0; ii < strlen(buff); ii++ )
		{
		if ( isupper( buff[ii] ) )
			buff[ii] = tolower( buff[ii] );
		}

	ex$message( msgnumb=HS_I_Original, buff=original );
	if( strcmp( buff, original ) == 0 )
		{
		symb->flags |= DPB_USE_ORIG_STYLE;
		FIg_set_text( form_ptr, HS_CHS_STATUS, " " );
		}
	else
		{
		num_matched = sscanf( buff, "%d", &style );
		if( (num_matched != 1) || ( (style < 0) || (style > 255) ) )
			{
			ex$message( msgnumb=HS_E_BadStyle, buff=msg_buff );
			FIg_set_text(
				form_ptr,
				HS_CHS_STATUS,
				msg_buff );
			}
		else
			{
			symb->style = style;
			symb->flags &= ~DPB_USE_ORIG_STYLE;
			FIg_set_text( form_ptr, HS_CHS_STATUS, " " );
			}
		}
	}  /* HScghs_process_style_keyin */


/*---HScghs_process_weight_keyin-----------------------------------------------*/

static void HScghs_process_weight_keyin( form_ptr, symb, buff )

	Form           form_ptr;
	struct GRhesym *symb;
	IGRchar        *buff;

	{
	IGRint	ii;
	IGRint	num_matched;
	IGRint	weight;
	IGRchar	original[40];
	IGRchar msg_buff[100];

	/* Change to lower case */
	for( ii = 0; ii < strlen(buff); ii++ )
		{
		if ( isupper( buff[ii] ) )
			buff[ii] = tolower( buff[ii] );
		}

	ex$message( msgnumb=HS_I_Original, buff=original );
	if( strcmp( buff, original ) == 0 )
		{
		symb->flags |= DPB_USE_ORIG_WEIGHT;
		FIg_set_text( form_ptr, HS_CHS_STATUS, " " );
		}
	else
		{
		num_matched = sscanf( buff, "%d", &weight );
		if( (num_matched != 1) || ( (weight < 0) || (weight > 31) ) )
			{
			ex$message( msgnumb=HS_E_BadWeight, buff=msg_buff );
			FIg_set_text(
				form_ptr,
				HS_CHS_STATUS,
				msg_buff );
			}
		else
			{
			symb->weight = weight;
			symb->flags &= ~DPB_USE_ORIG_WEIGHT;
			FIg_set_text( form_ptr, HS_CHS_STATUS, " " );
			}
		}

	}  /* HScghs_process_weight_keyin */


/*---HScghs_process_color_keyin-------------------------------------------*/

static void HScghs_process_color_keyin( form_ptr, symb, buff )

	Form           form_ptr;
	struct GRhesym *symb;
	IGRchar        *buff;

	{
	IGRint 		ii;
	IGRboolean	color_from_name;
	IGRshort	color;
	IGRint		num_matched;
	IGRchar		original[40];
	IGRchar msg_buff[100];

	/* Change to lower case */
	for( ii = 0; ii < strlen(buff); ii++ )
		{
		if ( isupper( buff[ii] ) )
			buff[ii] = tolower( buff[ii] );
		}

	ex$message( msgnumb=HS_I_Original, buff=original );
	if( strcmp( buff, original ) == 0 )
		{
		symb->flags |= DPB_USE_ORIG_COLOR;
		FIg_set_text( form_ptr, HS_CHS_STATUS, " " );
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
			ex$message( msgnumb=HS_E_BadColor, buff=msg_buff );
			FIg_set_text(
				form_ptr,
				HS_CHS_STATUS,
				msg_buff );
			}
		else
			{
			symb->color = color;
			symb->flags &= ~DPB_USE_ORIG_COLOR;
			FIg_set_text( form_ptr, HS_CHS_STATUS, " " );
			}
		}
	}  /* HScghs_process_color_keyin */


#define _start 0

method set_defaults ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	Form		form_ptr;


	form_ptr = me->forms[0].form_ptr;	

	/*
	 *  get info from the hsdpb
	 */
	 
	gr$get_hidden_edge_sym( buffer = &me->hidden_symbology );
	gr$get_visible_edge_sym( buffer = &me->visible_symbology );
	gr$get_hidden_so_on( buffer = &me->display_hidden_lines );


	/* Initialize the symbology fields */
	HScghs_init_symb_fields( form_ptr, OM_Gw_current_OS, &me->hidden_symbology,
	                         HS_CHS_HID_COLOR, HS_CHS_HID_STYLE, HS_CHS_HID_WEIGHT );
	HScghs_init_symb_fields( form_ptr, OM_Gw_current_OS, &me->visible_symbology,
	                         HS_CHS_VIS_COLOR, HS_CHS_VIS_STYLE, HS_CHS_VIS_WEIGHT );

	HScghs_set_display_hidden_lines( form_ptr, me->display_hidden_lines );

	quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;

	char		buff[40];
	IGRboolean	name_from_color;
	struct GRhesym	*symb;
	
	switch( gadget_label )
		{
		case HS_CHS_CHECK:
			FIg_reset( form_ptr, gadget_label );
			gr$put_hidden_edge_sym( buffer = &me->hidden_symbology );
			gr$put_visible_edge_sym( buffer = &me->visible_symbology );
			gr$put_hidden_so_on( buffer = &me->display_hidden_lines );
			_put_response( resp=EX_FORM_FINISHED );
			FIf_erase( form_ptr );
			break;
			
		case HS_CHS_CANCEL:
			FIg_reset( form_ptr, gadget_label );
			_put_response( resp=EX_FORM_FINISHED );
			FIf_erase( form_ptr );
			break;
			
		case HS_CHS_CONVERT_WINDOW:
			break;
			
		case HS_CHS_HID_STYLE: case HS_CHS_VIS_STYLE:

			FIg_get_text( form_ptr, gadget_label, buff ); 

			symb = ( gadget_label == HS_CHS_HID_STYLE ) ?
					&me->hidden_symbology : &me->visible_symbology;

			HScghs_process_style_keyin( form_ptr, symb, buff );

			/* 
			 * Update field 
			 */
		 
			if( symb->flags & DPB_USE_ORIG_STYLE )
				{
				ex$message( msgnumb=HS_I_Original, buff=buff );
				}
			else
				sprintf( buff, "%d", symb->style );

			FIg_set_text( form_ptr, gadget_label, buff );
			break;

		   case HS_CHS_HID_WEIGHT: case HS_CHS_VIS_WEIGHT:

			FIg_get_text( form_ptr, gadget_label, buff ); 

			symb = ( gadget_label == HS_CHS_HID_WEIGHT ) ?
					&me->hidden_symbology : &me->visible_symbology;

			HScghs_process_weight_keyin( form_ptr, symb, buff );

			if( symb->flags & DPB_USE_ORIG_WEIGHT )
				{
				ex$message( msgnumb=HS_I_Original, buff=buff );
				}
			else
				sprintf( buff, "%d", symb->weight );

			FIg_set_text( form_ptr, gadget_label, buff );
			break;

		case HS_CHS_HID_COLOR: case HS_CHS_VIS_COLOR:

			FIg_get_text( form_ptr, gadget_label, buff );

			symb = ( gadget_label == HS_CHS_HID_COLOR ) ?
					&me->hidden_symbology : &me->visible_symbology;

			HScghs_process_color_keyin( form_ptr, symb, buff );

			if( symb->flags & DPB_USE_ORIG_COLOR )
				{
				ex$message( msgnumb=HS_I_Original, buff=buff );
				}
			else
				{
				name_from_color = ige$get_name_from_color( 
							color = symb->color,
							name  = buff );

				if( !name_from_color )
					sprintf( buff, "%d", symb->color );
				}

			FIg_set_text( form_ptr, gadget_label, buff );
			break;
			
		case HS_CHS_DISPLAY_HIDDEN_LINES:
			TOGGLE( me->display_hidden_lines );
			HScghs_set_display_hidden_lines( form_ptr, me->display_hidden_lines );
			break;
			
			
		default:
			break;
		}
	quit:
  return OM_S_SUCCESS;
}

end implementation HScnghsform;
