#include "hsurf_import.h"
#include <stdio.h>
#include <FI.h>
#include "HSlvhl_label.h"
#include "HSlvhl_info.h"

/*---HSactivate_deactivate_hidden_edge_fields--------------------------*/

static	HSactivate_deactivate_hidden_edge_fields( form_ptr, lvhl_info )

Form			*form_ptr;
struct HSlvhl_info	*lvhl_info;

	{
	if( lvhl_info->display_hidden )
		{
		FIfld_set_mode( form_ptr, RV_HIDDEN_COLOR,  0, FI_INSERT );
		FIfld_set_mode( form_ptr, RV_HIDDEN_WEIGHT, 0, FI_INSERT );
		FIfld_set_mode( form_ptr, RV_HIDDEN_STYLE,  0, FI_INSERT );

		FIg_enable( form_ptr, RV_HIDDEN_COLOR );
		FIg_enable( form_ptr, RV_HIDDEN_WEIGHT );
		FIg_enable( form_ptr, RV_HIDDEN_STYLE );

		if( !lvhl_info->generate_soos )
			{
			FIfld_set_mode( form_ptr, RV_HIDDEN_LAYER,  0, FI_INSERT );
			FIg_enable( form_ptr, RV_HIDDEN_LAYER );
			}
		}
	else
		{
		FIfld_set_mode( form_ptr, RV_HIDDEN_COLOR,  0, FI_REVIEW );
		FIfld_set_mode( form_ptr, RV_HIDDEN_WEIGHT, 0, FI_REVIEW );
		FIfld_set_mode( form_ptr, RV_HIDDEN_STYLE,  0, FI_REVIEW );
		FIfld_set_mode( form_ptr, RV_HIDDEN_LAYER,  0, FI_REVIEW );

		FIg_disable( form_ptr, RV_HIDDEN_COLOR );
		FIg_disable( form_ptr, RV_HIDDEN_WEIGHT );
		FIg_disable( form_ptr, RV_HIDDEN_STYLE );
		FIg_disable( form_ptr, RV_HIDDEN_LAYER );
		}
	}
	
/*---HSactivate_deactivate_layer_fields--------------------------------*/

static	HSactivate_deactivate_layer_fields( form_ptr, lvhl_info )

Form			*form_ptr;
struct HSlvhl_info	*lvhl_info;

	{
	if( !lvhl_info->generate_soos )
		{
		FIfld_set_mode( form_ptr, RV_VISIBLE_LAYER, 0, FI_INSERT );
		FIg_enable( form_ptr, RV_VISIBLE_LAYER );
		FIg_enable( form_ptr, RV_LAYER_TEXT );
		
		if( lvhl_info->display_hidden )
			{
			FIfld_set_mode( form_ptr, RV_HIDDEN_LAYER,  0, FI_INSERT );
			FIg_enable( form_ptr, RV_HIDDEN_LAYER );
			}
		}
	else
		{
		FIfld_set_mode( form_ptr, RV_VISIBLE_LAYER, 0, FI_REVIEW );
		FIfld_set_mode( form_ptr, RV_HIDDEN_LAYER,  0, FI_REVIEW );

		FIg_disable( form_ptr, RV_VISIBLE_LAYER );
		FIg_disable( form_ptr, RV_HIDDEN_LAYER );
		FIg_disable( form_ptr, RV_LAYER_TEXT );
		}
	}
	
/*---HSlvhl_notification-----------------------------------------------*/

HSlvhl_notification( form_ptr, gadget_label, lvhl_info )

Form			*form_ptr;
int			gadget_label;
struct HSlvhl_info	*lvhl_info;

	{
	char	buffer[128];
	int	color, tmp;
	int	status;

	switch( gadget_label )
		{	
		case RV_CHECK:
			break;

		case RV_EXECUTE:
			break;

		case RV_RESET:
			HSactivate_deactivate_hidden_edge_fields( form_ptr, lvhl_info );
			HSactivate_deactivate_layer_fields( form_ptr, lvhl_info );
			
			HSlvhl_notification( form_ptr, RV_VISIBLE_COLOR, lvhl_info );
			HSlvhl_notification( form_ptr, RV_HIDDEN_COLOR,  lvhl_info );
			HSlvhl_notification( form_ptr, RV_VISIBLE_STYLE, lvhl_info );
			HSlvhl_notification( form_ptr, RV_HIDDEN_STYLE,  lvhl_info );
			HSlvhl_notification( form_ptr, RV_VISIBLE_WEIGHT,lvhl_info );
			HSlvhl_notification( form_ptr, RV_HIDDEN_WEIGHT, lvhl_info );
			HSlvhl_notification( form_ptr, RV_VISIBLE_LAYER, lvhl_info );
			HSlvhl_notification( form_ptr, RV_HIDDEN_LAYER,  lvhl_info );
			break;

		case RV_CANCEL:
			break;

		case RV_CHANGE:
			break;

		case RV_VISIBLE_COLOR:
		case RV_HIDDEN_COLOR:
			FIg_get_text( form_ptr, gadget_label, buffer );

			if( buffer[0] != 0 )
				{
				if( buffer[0] == 'o' || buffer[0] == 'O' )
					color = -1;
				else
					sscanf( buffer, "%d", &color );
				}
			else
				{
				switch( gadget_label )
					{
					case RV_VISIBLE_COLOR:
						color = lvhl_info->visible_color;
						break;
					
					case RV_HIDDEN_COLOR:
						color = lvhl_info->hidden_color;
						break;
					}
				}

			switch( color )
				{
				case -1:
					sprintf( buffer, "original" );
					break;
					
				case 0:
					sprintf( buffer, "background" );
					break;
					
				case 1:
					sprintf( buffer, "green" );
					break;
					
				case 2:
					sprintf( buffer, "red" );
					break;
					
				case 3:
					sprintf( buffer, "blue" );
					break;
					
				case 4:
					sprintf( buffer, "yellow" );
					break;
					
				default:
					sprintf( buffer, "%d", color );
					break;
				}
		
			FIg_set_text( form_ptr, gadget_label, buffer );
			
			switch( gadget_label )
				{
				case RV_VISIBLE_COLOR:
					lvhl_info->visible_color = color;
					break;
					
				case RV_HIDDEN_COLOR:
					lvhl_info->hidden_color = color;
					break;
				}
			break;

		case RV_VISIBLE_STYLE:
		case RV_HIDDEN_STYLE:
		case RV_VISIBLE_WEIGHT:
		case RV_HIDDEN_WEIGHT:
		case RV_VISIBLE_LAYER:
		case RV_HIDDEN_LAYER:
			FIg_get_text( form_ptr, gadget_label, buffer );

			if( buffer[0] != 0 )
				{
				if( buffer[0] == 'o' || buffer[0] == 'O' )
					tmp = -1;
				else
					sscanf( buffer, "%d", &tmp );
				}
			else
				{
				switch( gadget_label )
					{
					case RV_VISIBLE_STYLE:
						tmp = lvhl_info->visible_style;
						break;

					case RV_HIDDEN_STYLE:
						tmp = lvhl_info->hidden_style;
						break;

					case RV_VISIBLE_WEIGHT:
						tmp = lvhl_info->visible_weight;
						break;

					case RV_HIDDEN_WEIGHT:
						tmp = lvhl_info->hidden_weight;
						break;

					case RV_VISIBLE_LAYER:
						tmp = lvhl_info->visible_layer;
						break;

					case RV_HIDDEN_LAYER:
						tmp = lvhl_info->hidden_layer;
						break;
					}
				}
				
			if( tmp == -1 )
				sprintf( buffer, "original" );
			else
				sprintf( buffer, "%d", tmp );
		
			FIg_set_text( form_ptr, gadget_label, buffer );
			
			switch( gadget_label )
				{
				case RV_VISIBLE_STYLE:
					lvhl_info->visible_style = tmp;
					break;

				case RV_HIDDEN_STYLE:
					lvhl_info->hidden_style = tmp;
					break;

				case RV_VISIBLE_WEIGHT:
					lvhl_info->visible_weight = tmp;
					break;

				case RV_HIDDEN_WEIGHT:
					lvhl_info->hidden_weight = tmp;
					break;

				case RV_VISIBLE_LAYER:
					lvhl_info->visible_layer = tmp;
					break;

				case RV_HIDDEN_LAYER:
					lvhl_info->hidden_layer = tmp;
					break;
				}

			break;
			
		case RV_VECTOR_TYPE:
			lvhl_info->generate_soos = !lvhl_info->generate_soos;
			
			HSactivate_deactivate_layer_fields( form_ptr, lvhl_info );
			break;

		case RV_OPTIMIZATION:
			FIg_get_text( form_ptr, gadget_label, buffer );

			if( buffer[0] != 0 )
				{
				if( buffer[0] >= '0' && buffer[0] <= '9' )
					{
					sscanf( buffer, "%d", &tmp );
fprintf( stderr, "%d\n", tmp );

					if( tmp > 0 )
						lvhl_info->optimization = tmp;
					}
				}
				
			sprintf( buffer, "%1d Mpx", lvhl_info->optimization );
			FIg_set_text( form_ptr, gadget_label, buffer );
			break;

		case RV_VISIBLE_HIDDEN:
			lvhl_info->display_hidden = !lvhl_info->display_hidden;
			
			HSactivate_deactivate_hidden_edge_fields( form_ptr, lvhl_info  );
			break;

		default:
			fprintf( stderr, "unknown command\n" );
			break;

		}
	}

