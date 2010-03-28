class implementation COcctform;

/*
 *   Filename:   COcct_option.I
 *   Programmer:   C. M. Jablonski
 *   Creation Date:   July 1990
 *
 *   This file contains the routines that interface with the options subform:
 *
 *   initialize_GRCreColorTbOp   - initializes the form gadgets
 *
 *   options_form_notification   - notification method for the options
 *                 subform
 *   History:
 */


#include "stdio.h"
#include "cct.h"
#include "cctmsg.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

/* Static Variables */
static int   OPTION_original_gamma_compensate;
static double   original_slider_maximum;
static int   original_name_mode;
static int   original_file_type;
static IGRchar  *original_file_name;
static int   original_user_cube_size;
static IGRint   original_num_ramp_colors;
/*----- initialize_GRCreColorTbOp --------------------------------------------*/
method initialize_GRCreColorTbOp ( int * sts )

/*
 * ABSTRACT:   Initialize_GRCreColorTbOp is called during form initialization.
 *      It initializes the gadget states.
 *
 * HISTORY:   07/02/90  Created.         C. M. Jablonski
 *            08/16/93  Changed options toggles to opposite with forms standard.
 *                                       Joel D. Underwood
 */

{
   IGRdouble   gamma[3];
   IGRchar     cube_size[15];
   IGRdouble   num_ramp_colors_double;
   struct IGEcontext_info IGEcontext_info;

/*** TAKE THIS OUT WHEN BLDG 11 FIXES WORKSHEET #11-9099 ***/
   IGEload_context( me->context_no, &IGEcontext_info );
   if ( IGEcontext_info.table_depth <= 5 )
   {
      /* 5 or less planes no save restore */
      FIf_cvrt_to_perm_win( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr );
   }

   /* set the gadget states */
   ige$set_inq_colortable_parameters( inq0_set1 = 0, gamma_correction = gamma,
      num_ramp_colors = &(original_num_ramp_colors),
      user_cube_size = &(original_user_cube_size) );
   switch (original_user_cube_size)
   {
      case IGE_USER_CUBE_SIZE_DEFAULT:
         strcpy(cube_size, "Default");
         break;
      case IGE_USER_CUBE_SIZE_MAX:
         strcpy(cube_size, "Maximum");
         break;
      case IGE_USER_CUBE_SIZE_MAX_MINUS_1:
         strcpy(cube_size, "Maximum - 1");
         break;
      case IGE_USER_CUBE_SIZE_MIN:
         strcpy(cube_size, "Minimum");
         break;
      case IGE_USER_CUBE_SIZE_MIN_PLUS_1:
         strcpy(cube_size, "Minimum + 1");
         break;
   }
   FIfld_set_text( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, KEYIN_CUBE_SIZE, 0, 0, cube_size, FALSE);
   
   num_ramp_colors_double = (IGRdouble) original_num_ramp_colors;
   FIg_set_value( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, KEYIN_NUM_RAMP_COLORS, num_ramp_colors_double);
   FIg_set_value( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, SCROLL_NUM_RAMP_COLORS, num_ramp_colors_double);

   if ( gamma[0]!=1.0 || gamma[1]!=1.0 || gamma[2]!=1.0 )
   {
      OPTION_original_gamma_compensate = TRUE;
      FIg_set_state( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, TOGGLE_GAMMA_COMPENSATE, FALSE);
   }
   else 
   {
      OPTION_original_gamma_compensate = FALSE;
      FIg_set_state( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, TOGGLE_GAMMA_COMPENSATE, TRUE);
   }

   original_slider_maximum = me->slider_maximum;
   FIg_set_state( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, TOGGLE_SCROLL_RANGE, (me->slider_maximum == 100.0));

   original_name_mode = me->name_mode;
   FIg_set_state( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, TOGGLE_NAME_MODE, 
      (me->name_mode != NAME_SELECT_MODE));

   if (original_file_name)
   {
      free( original_file_name );
   }
   original_file_name = (IGRchar *) malloc( (sizeof(IGRchar) * strlen(me->file_name)) + 1 );
   
   if (original_file_name && me->file_name)
   {
      strcpy( original_file_name, me->file_name );
   }
   FIfld_set_text( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, KEYIN_FILE_NAME, 0, 0, me->file_name, FALSE);

   original_file_type = me->file_type;
   FIg_set_state( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, TOGGLE_FILE_TYPE, (me->file_type != IGE_COLORS));

   return( OM_S_SUCCESS );
}

/*----- options_form_notification --------------------------------------------*/
method options_form_notification ( int form_label; int gadget_label; double value; Form fp )
{
   int     sts;
   char      *text;
   char      COmessage[100],COwarn[100];
   extern char   *CCTget_text();
   long   msg;
   double   new_max;
   IGRdouble curr_gamma_compensate, num_ramp_colors_double;
   IGRint num_ramp_colors_int, user_cube_size, changed;
   struct IGRdisplay   disbuf;
   struct IGEcontext_info IGEcontext_info;
   IGRboolean save = TRUE;

   IGEload_context( me->context_no, &IGEcontext_info );

   /* clear the message field */
   om$send(   msg      = message COcctform.clear_message_field( OPTIONS_SUBFORM_LABEL ),
         targetid   = my_id );

   switch ( gadget_label )
   {
      case KEYIN_CUBE_SIZE:
      case KEYIN_NUM_RAMP_COLORS:
      case SCROLL_NUM_RAMP_COLORS:
      case TOGGLE_GAMMA_COMPENSATE:
         /* do these only at the end */
         break;

      case TOGGLE_SCROLL_RANGE:
         /* toggle the slider range */
         new_max = (me->slider_maximum == 100.0) ? 255.0 : 100.0;
         om$send( msg      = message COcctform.set_slider_maximum ( new_max ),
                  targetid = my_id );
         break;

      case TOGGLE_NAME_MODE:
         me->name_mode = (me->name_mode == NAME_SELECT_MODE) ? NAME_RENAME_MODE : NAME_SELECT_MODE;
         break;

      case KEYIN_FILE_NAME:
         /* Get the text string */
         text = CCTget_text ( fp, gadget_label );
         strcpy( me->file_name, text );
         break;
   
      case BUTTON_ATTACH:
         /* verify the filename */
         if ((strlen(me->file_name) == 0) || !DPchek_clr_tbl(me->file_name))
         {
            om$send( msg      = message COcctform.print_message( OPTIONS_SUBFORM_LABEL, CT_E_InvalidFileName ),
                     targetid = my_id );
         }
         else
         {
            DPload_clr_tbl( me->file_name, &me->file_type );
            /* update color table and mappings */
            om$send( msg      = message COcctform.get_color_data( &sts, FALSE ),
                     targetid = my_id );
            om$send(   msg      = message COcctform.print_message(
               OPTIONS_SUBFORM_LABEL, CT_I_ColorTableLoaded ),
               targetid   = my_id );
         }
         break;

      case BUTTON_SAVE:
         /* verify the filename */
         if (strlen(me->file_name) == 0)      /* filename does not exist */
         {
            om$send(   msg      = message COcctform.print_message(
               OPTIONS_SUBFORM_LABEL, CT_E_InvalidFileName ),
               targetid   = my_id );
         }
         else
         {
            if (me->file_type == IGDS_COLORS) /* cannot save in IGDS format */
            {
               om$send( msg      = message COcctform.print_message(OPTIONS_SUBFORM_LABEL, CT_I_SavedWrongFormat),
                        targetid = my_id );
            }
            else 
            {
               save = TRUE;
               if (DPchek_clr_tbl(me->file_name))
               {
                  /* a file exists with this name, ask if overwrite desired */
                  ex$message ( msgnumb = CT_W_WarnTitle, buff = COwarn );
                  ex$message ( msgnumb = CT_W_FilExsAcptOvrwrt, buff = COmessage );

                  save = FI_confirm_box( FI_CURRENT_SCREEN, -1, -1,
                            COwarn, FI_RED, "swiss742", 36.0,
                            COmessage, FI_BLACK, "swiss742", 18.0,
                            FI_LEFT_JUSTIFIED, FI_ACCEPT | FI_CANCEL, 40 );

               }

               if (save)
               {
                  if (DPsave_clr_tbl( me->file_name )) /* if valid filename */
                  {
                     /* successful save */
                     om$send( msg      = message COcctform.print_message(OPTIONS_SUBFORM_LABEL, CT_I_ColorTableSaved),
                              targetid = my_id );
                  }
                  else                  
                  {
                     /* Invalid file name */
                     om$send( msg      = message COcctform.print_message(OPTIONS_SUBFORM_LABEL, CT_E_ColorTableNotSaved),
                              targetid = my_id );
                  }
               }
               else                  
               {
                  /* didn't want to overwrite */
                  om$send( msg      = message COcctform.print_message(OPTIONS_SUBFORM_LABEL, CT_E_ColorTableNotSaved),
                           targetid = my_id );
               }
            }
         }
         break;

      case TOGGLE_FILE_TYPE:
         /* toggle the file type */
         if (me->file_type == IGE_COLORS)
         {
            me->file_type = IGDS_COLORS;
#if defined (DEBUG_CCT)
            printf("COcctform.options_form_notification: file_type now = %d (IGDS_COLORS)\n",me->file_type);
#endif
         }
         else
         {
            me->file_type = IGE_COLORS;
#if defined (DEBUG_CCT)
            printf("COcctform.options_form_notification: file_type now = %d (IGE_COLORS)\n",me->file_type);
#endif
         }
         break;

      case FI_CANCEL:
         /* restore the original values */
         me->name_mode = original_name_mode;
         me->file_type = original_file_type;
         if (original_file_name && me->file_name)
         {
            /* if allocated then copy into file_name */
            strcpy( me->file_name, original_file_name );
         }
         om$send( msg      = message COcctform.set_slider_maximum ( original_slider_maximum ),
                  targetid = my_id );
         om$send( msg       = message COcctform.erase_form_by_label ( OPTIONS_SUBFORM_LABEL, 1, &sts ),
                  targetid  = my_id );

         /* reattach original color table file.  This may not be the original color table if a different
            one was saved on top of it with same name.  Saving operations are permanent. */
         if ((strlen(original_file_name) > 0) && DPchek_clr_tbl(original_file_name))
         {
            DPload_clr_tbl( me->file_name, &me->file_type );
            /* update my data structures with the new default colors */
            om$send( msg      = message COcctform.get_color_data( &sts, FALSE ),
                     targetid = my_id );
         }
         

         /* update the active color; don't draw pallet if new page, will draw pallet below unconditionaly */
         /* get the active color since me->curr_color may have been modded to be within num_colors */
         gr$get_active_display( buffer = &disbuf );
         om$send( msg      = message COcctform.set_current_color( FALSE, (IGRint) disbuf.color, FALSE ),
                  targetid = my_id );
         
         /* draw the color pallet for new color table or if compensated */
         om$send( msg      = message COcctform.draw_color_pallet( &msg ),
                  targetid = my_id );
            
         /* update the active color display */
         om$send( msg = message COcctform.update_active_color_display( &msg ),
            targetid = my_id );

         /* pop up the options button */
         FIg_set_state_off ( me->forms[CCT_FORM_LABEL].form_ptr, BUTTON_OPTIONS );
         break;

      case FI_ACCEPT:
         text = CCTget_text ( fp, KEYIN_CUBE_SIZE );
         changed = FALSE; 
         user_cube_size = original_user_cube_size;
         if ((!strcmp(text, "Default")) && (original_user_cube_size != IGE_USER_CUBE_SIZE_DEFAULT))
         {
            user_cube_size = IGE_USER_CUBE_SIZE_DEFAULT;
            changed = TRUE;
         }
         else if ((!strcmp(text, "Maximum")) && (original_user_cube_size != IGE_USER_CUBE_SIZE_MAX))
         {
            user_cube_size = IGE_USER_CUBE_SIZE_MAX;
            changed = TRUE;
         }
         else if ((!strcmp(text, "Maximum - 1")) && (original_user_cube_size != IGE_USER_CUBE_SIZE_MAX_MINUS_1))
         {
            user_cube_size = IGE_USER_CUBE_SIZE_MAX_MINUS_1;
            changed = TRUE;
         }
         else if ((!strcmp(text, "Minimum")) && (original_user_cube_size != IGE_USER_CUBE_SIZE_MIN))
         {
            user_cube_size = IGE_USER_CUBE_SIZE_MIN;
            changed = TRUE;
         }
         else if ((!strcmp(text, "Minimum + 1")) && (original_user_cube_size != IGE_USER_CUBE_SIZE_MIN_PLUS_1))
         {
            user_cube_size = IGE_USER_CUBE_SIZE_MIN_PLUS_1;
            changed = TRUE;
         }

         FIg_get_value ( fp, KEYIN_NUM_RAMP_COLORS, &num_ramp_colors_double);
         num_ramp_colors_int = (IGRint) num_ramp_colors_double;
         if (num_ramp_colors_int != original_num_ramp_colors)
         {
            changed = TRUE;
         }
         
         if (changed)
         {
            ige$set_inq_colortable_parameters( inq0_set1 = 1,
               num_ramp_colors = &(num_ramp_colors_int),
               user_cube_size = &(user_cube_size));
         }

         FIg_get_value( me->forms[OPTIONS_SUBFORM_LABEL].form_ptr, TOGGLE_GAMMA_COMPENSATE, &curr_gamma_compensate);

         /* erase the form */
         om$send ( msg      = message COcctform.erase_form_by_label ( OPTIONS_SUBFORM_LABEL, 1, &sts ),
                   targetid = my_id );
         
         /* update the active color; don't draw pallet if new page, will draw pallet below unconditionaly */
         /* get the active color since me->curr_color may have been modded to be within num_colors */
         gr$get_active_display( buffer = &disbuf );
         om$send( msg      = message COcctform.set_current_color( FALSE, (IGRint) disbuf.color, FALSE ),
                  targetid = my_id );
         
         if (OPTION_original_gamma_compensate == curr_gamma_compensate)
         {
            om$send(msg      = message COcctform.toggle_compensation( &msg ), 
               targetid   = my_id );
            om$send(msg      = message COcctform.draw_hue_sat_block( &msg, TRUE ),
               targetid   = my_id );
         }
         else
         {
            if (changed)
            {
               ige$configure_color_table();
               om$send(msg      = message COcctform.draw_hue_sat_block( &msg, TRUE ),
                  targetid   = my_id );
            }
         }
         
         /* draw the color pallet for new color table or if compensated */
         om$send( msg      = message COcctform.draw_color_pallet( &msg ),
                  targetid = my_id );
            
         /* update the active color display */
         om$send( msg = message COcctform.update_active_color_display( &msg ),
            targetid = my_id );

         /* pop up the options button */
         FIg_set_state_off ( me->forms[CCT_FORM_LABEL].form_ptr, BUTTON_OPTIONS );
         break;
      
   } /* END switch ( gadget_label ) */
      
   return( OM_S_SUCCESS );
} /* END form_notification */


end implementation COcctform;
