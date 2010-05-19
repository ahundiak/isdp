class implementation COcctform;

/*
 *   Filename:   COcct_input.I
 *   Programmer:   C. M. Jablonski
 *   Creation Date:   June 1990
 *
 *   This file contains the routines used to process form input:
 *
 *   (CCTget_text)   - routine to read text data
 *
 *   button_intercept_method   - intercepts button data and processes
 *              pallet selections.
 *
 *   form_notification   - OVERRIDE METHOD: recieves and processes data 
 *
 *   History:
 *
 *		HF	04/01/98	VDS TR # 179800890
 *					Override of method form_notification() ONLY !!!
 */

#if defined ( X11 )
#define DOWN 1
#define SINGLE_CLICK 2
#endif

#include <stdio.h>
#include <stdlib.h>

#include "cct.h"
#include "cctmsg.h"

#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"

#include "igecolordef.h"
#include "igecolmacros.h"

#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMminimum.h"
#include "OMmacros.h"

// #define VD_DEBUG
// #include  "VDdebug.h"


/*----- form_notification ----------------------------------------------------*/
method form_notification ( int form_label; int gadget_label; double value; Form fp )
{
   IGRint    status = OM_S_SUCCESS;
   IGRlong    msg;
   IGRdouble  form_red,form_green,form_blue,form_hue,form_lum,form_sat;
   IGRdouble color_code, page;
   IGRint max_num_pages;
   IGRchar   *text;
   IGRshort   short_color;
   struct IGEcol_names   colorname;
   IGRshort   num_names;
   struct IGRdisplay   disbuf;

//   __enterMethod ( name = "form_notification", argfmt = "my_id = [%d,%d], fp = %#x",
//		   args = `OM_Gw_current_OS, my_id, fp` );

   switch ( form_label )
   {
      case OPTIONS_SUBFORM_LABEL:

         /* invoke the options form notification routine */
         om$send(   msg      = message COcctform.options_form_notification 
            ( form_label, gadget_label, value, fp ),
         targetid   = my_id );

         break;

      case CCT_FORM_LABEL:

         /* Clear any messages */
         ex$message(in_buff = "", field = ERROR_FIELD);
         om$send(   msg      = message COcctform.clear_message_field( CCT_FORM_LABEL ),
         targetid   = my_id );

         switch ( gadget_label )
         {
            case KEYIN_RED:
               FIg_get_value ( fp, KEYIN_RED, &form_red);
            case SCROLL_RED:
               if (gadget_label==SCROLL_RED)
               {
                  FIg_get_value ( fp, SCROLL_RED, &form_red);
               }

               /* determine the new red value */
               me->curr_red = form_red / me->slider_maximum;

               /* Update the active color display */
               om$send( msg      = message COcctform.update_active_color_display( &msg ),
                        targetid   = my_id );
               break;
            case KEYIN_GREEN:
               FIg_get_value ( fp, KEYIN_GREEN, &form_green);
            case SCROLL_GREEN:
               if (gadget_label==SCROLL_GREEN) 
               {
                  FIg_get_value ( fp, SCROLL_GREEN, &form_green);
               }

               /* determine the new green value */
               me->curr_green = form_green / me->slider_maximum;

               /* Update the active color display */
               om$send( msg      = message COcctform.update_active_color_display( &msg ),
                        targetid = my_id );
               break;
            case KEYIN_BLUE:
               FIg_get_value ( fp, KEYIN_BLUE, &form_blue);
            case SCROLL_BLUE:
               if (gadget_label==SCROLL_BLUE) 
               {
                  FIg_get_value ( fp, SCROLL_BLUE, &form_blue);
               }

               /* determine the new blue value */
               me->curr_blue = form_blue / me->slider_maximum;

               /* Update the active color display */
               om$send( msg      = message COcctform.update_active_color_display( &msg ),
                        targetid = my_id );
               break;

            case SCROLL_HUE:
            case SCROLL_LUMINANCE:
            case SCROLL_SATURATION:
               FIg_get_value ( fp, SCROLL_HUE, &form_hue);
               FIg_get_value ( fp, SCROLL_LUMINANCE, &form_lum);
               FIg_get_value ( fp, SCROLL_SATURATION, &form_sat);

               /* set the hue lum and sat */
               me->curr_hue = (IGRdouble) (form_hue / me->slider_maximum) * 359.99;
               me->curr_luminance = (IGRdouble) form_lum / me->slider_maximum;
               me->curr_saturation = (IGRdouble) form_sat / me->slider_maximum;

               /* modify the current color */
               rgb_from_hls( &(me->curr_red), &(me->curr_green), &(me->curr_blue),
                  me->curr_hue, me->curr_luminance, me->curr_saturation);

               /* Update the active color display */
               om$send( msg      = message COcctform.update_active_color_display( &msg ),
                        targetid = my_id );
               break;
            case KEYIN_HUE:
            case KEYIN_LUMINANCE:
            case KEYIN_SATURATION:
               FIg_get_value ( fp, KEYIN_HUE, &form_hue);
               FIg_get_value ( fp, KEYIN_LUMINANCE, &form_lum);
               FIg_get_value ( fp, KEYIN_SATURATION, &form_sat);

               /* set the hue lum and sat */
               me->curr_hue = (IGRdouble) (form_hue / me->slider_maximum) * 359.99;
               me->curr_luminance = (IGRdouble) form_lum / me->slider_maximum;
               me->curr_saturation = (IGRdouble) form_sat / me->slider_maximum;

               /* modify the current color */
               rgb_from_hls( &(me->curr_red), &(me->curr_green), &(me->curr_blue),
                  me->curr_hue, me->curr_luminance, me->curr_saturation);

               /* Update the active color display */
               om$send(msg      = message COcctform.update_active_color_display( &msg ),
                  targetid   = my_id );
               break;
            case KEYIN_COLOR_CODE:
               FIg_get_value( fp, KEYIN_COLOR_CODE, &color_code);
               om$send(msg    = message COcctform.set_current_color( TRUE, (IGRint) color_code, TRUE ), 
                        targetid = my_id );   
               om$send(msg      = message COcctform.update_active_color_display( &msg ),
                        targetid   = my_id );
               break;
            case KEYIN_PAGE:
               FIg_get_value( fp, KEYIN_PAGE, &page);
            case SCROLL_PAGE:
               if (gadget_label==SCROLL_PAGE) 
               {
                  FIg_get_value( fp, SCROLL_PAGE, &page);
               }
               max_num_pages = (me->num_colors - 2) / 64;
               if (((me->num_colors - 2) % 64) != 0)
               {
                  max_num_pages++;
               }
               
               if (page < 1.0 )
               {
                  page = 1.0;
                  FIg_set_value( fp, KEYIN_PAGE, page);
                  FIg_set_value( fp, SCROLL_PAGE, page);
               }
               
               if (page > (IGRdouble) (max_num_pages) )
               {
                  page = (IGRdouble) (max_num_pages);
                  FIg_set_value( fp, KEYIN_PAGE, page);
                  FIg_set_value( fp, SCROLL_PAGE, page);
               }
      
               if ((page - 1.0) != (IGRdouble) (me->curr_color_page) )
               {
                  /* page is different from current page */
                  me->curr_color_page = (IGRint) (page - 1.0);
                  om$send(msg      = message COcctform.draw_color_pallet( &msg ), 
                           targetid   = my_id );
                  om$send(msg      = message COcctform.update_active_color_display( &msg ),
                           targetid   = my_id );
               }   
               break;
            case KEYIN_NAME:
               /* Get the text string */
               text = CCTget_text ( fp, gadget_label );
               if (strlen(text) > 23)
               { 
                  /* truncate a name to 23 chars null terminated */
                  text[23] = 0;
               }
               
               /* determine whether to select a new color or rename the current color */
               if ( me->name_mode == NAME_SELECT_MODE )
               {
                  /* get the color number */
                  status = ige$get_color_from_name(name = text, color = &short_color );
                  
                  /* check the color number */
                  if ((short_color >= 0) && (short_color <= me->num_colors - 1) && (status == TRUE))
                  {
                     /* make this the current color */
                     om$send(msg      = message COcctform.set_current_color( TRUE, (IGRint) short_color, TRUE ),
                        targetid   = my_id );
                     /* Update the active color display */
                     om$send(msg      = message COcctform.update_active_color_display( &msg ),
                        targetid   = my_id );
                  }
                  else
                  {
                     /* bad color name, so print warning */
                     ex$message( msgnumb = CT_E_UnknownColorName); 
#if defined ( DEBUG_CCT )
                     printf("COcct_input.I: unknown color name\n");
#endif
                     /* reset the name field */
                     FIfld_set_text( fp, KEYIN_NAME, 0, 0, me->curr_colname, FALSE);
                  }
               }
               else
               {
                  /* rename the current color */
                  if ( (me->curr_color == 0) || (me->curr_color == me->num_colors - 1) )
                  {
                     ex$message( msgnumb = CT_E_CannotRenameReserved);
#if defined ( DEBUG_CCT )
                     printf("COcct_input.I: reserve color can't be renamed\n");
#endif
                     /* reset the name field */
                     FIfld_set_text(fp, KEYIN_NAME, 0, 0, me->curr_colname, FALSE);
                  }
                  else
                  {
                     /* see if name already exists */
                     if (ige$get_color_from_name(name = text, color = &short_color))
                     {  /* name already exists */
                        ex$message( msgnumb = CT_E_NameAlreadyExists ); 
#if defined ( DEBUG_CCT )
                        printf("COcct_input.I: name already exists\n");
#endif
                        /* reset the name field */
                        FIfld_set_text( fp, KEYIN_NAME, 0, 0, me->curr_colname, FALSE);
                     }
                     else
                     {
                        /* initialize the color name structure to saved color value (log color - 1)*/
                        colorname.index = me->curr_color - 1;
                        sprintf( colorname.name, "%s", text );
               
                        /* modify the color name */
                        ige$modify_color_names( num_names = 1, names = &colorname);
                        
                        num_names =0;
                        ige$read_color_names(num_names = &num_names, names = me->modified_names);
                        status=om$vla_set_dimension(varray = me->modified_names, size = num_names );
               
                        /* save the new name in instance data */
                        sprintf( me->curr_colname, "%s", text );
                     }
                  }
               }
            
               /* re-justify the field */
               FIfld_set_active_char( fp, gadget_label, 0, 0, 0 );
      
               break;

            case BUTTON_OPTIONS:
               /* save the current color first */
               om$send(msg    = message COcctform.set_current_color( TRUE, me->curr_color, FALSE ), 
                        targetid = my_id );   
               /* if not ramp, don't display num ramp colors */
               if (!IGEget_using_ramp_mode())
               {
                  FIg_erase( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, TEXT_NUM_RAMP_COLORS);
                  FIg_erase( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, KEYIN_NUM_RAMP_COLORS);
                  FIg_erase( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, SCROLL_NUM_RAMP_COLORS);
               }
               /* display the options subform */
               om$send( msg      = message COcctform.display_form_by_label ( OPTIONS_SUBFORM_LABEL, &status ),
                        targetid = my_id );
         
               /* initialize the options subform */
               om$send( msg      = message COcctform.initialize_GRCreColorTbOp( &status ),
                        targetid = my_id );
         
               break;

            case FI_CVT_TO_PERM_WIN:

                  /* set the converted-to-window flag */
                  me->converted_to_window = TRUE;
                  break;

            case FI_CANCEL:

#ifdef X11
/*53093 needed?maybe: if so in the init too*/ /*XSetSubwindowMode(EXdisplay,EXgc[EX_scr[me->hwin_no]],ClipByChildren);*/
#endif
	      _move_on;
	      
	      if ( fp )		// ++++++++++ HF: 04/01/98 TR # 179800890
	      {
		FIf_delete ( fp ); fp = NULL;

		if ( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr )
		{
		  FIf_delete ( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr );
		  me->forms[OPTIONS_SUBFORM_LABEL].form_ptr = NULL;
		}
	      }			// ----------: 04/01/98 TR # 179800890

	      break;

            case FI_ACCEPT:
#ifdef X11
/*53093 needed?*/ /* XSetSubwindowMode(EXdisplay,EXgc[EX_scr[me->hwin_no]],ClipByChildren);*/
#endif
               /* save the current color also.  get the active color since me->curr_color may be 
                  modded to be within num_colors */
               gr$get_active_display( buffer = &disbuf );
               om$send( msg      = message COcctform.set_current_color( TRUE, (IGRint) disbuf.color, FALSE ),
                        targetid = my_id );
         
               me->hit_check_box = TRUE;

               _move_on;

	       if ( fp )		// ++++++++++ HF: 04/01/98 TR # 179800890
	       {
		 FIf_delete ( fp ); fp = NULL;

		 if ( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr )
		 {
		   FIf_delete ( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr );
		   me->forms[OPTIONS_SUBFORM_LABEL].form_ptr = NULL;
		 }
	       }			// ----------: 04/01/98 TR # 179800890

               break;
            } /* END switch ( gadget_label ) */

   } /* END switch ( form_label ) */

quit:

//   __exitMethod  ( name = "form_notification", argfmt = "my_id = [%d,%d], status = %#x",
//		   args = `OM_Gw_current_OS, my_id, status` );

   return( OM_S_SUCCESS );

} /* END form_notification */

end implementation COcctform;
