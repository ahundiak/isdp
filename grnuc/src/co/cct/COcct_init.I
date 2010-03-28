class implementation COcctform;
/*
 *   Filename:   COcct_init.I
 *   Programmer:   C. M. Jablonski
 *   Creation Date:   June 1990
 *
 *   This file contains the routines used to initialize the Build Color Table
 *   command object:
 *
 *   (COget_raster_data_struct) - gets the raster data structures to manipulate
 *
 *   (GRCreColorTb_button_intercept_routine)   - button intercept routine
 *
 *   (GRCreColorTb_window_event_routine)   - window event routine
 *
 *   (GRCreColorTb_continuous_routine)   - continuous routine
 *
 *   get_color_data      - determines the color-shade configuration
 *              and etets dependent parameters
 *
 *   initialize_GRCreColorTb   - determines hardware type and initializes the forms
 *              accordingly
 *
 *   window_event_method   - enables window planes, checks configuration,
 *              updates configuration and current color
 *
 *   sleep   - performs the required actions when the command goes to sleep
 *        like restoring the color table and updating the Active Drawing
 *        Parameters form
 *
 *   wakeup_GRCreColorTb - called at command wake up 
 *
 *   get_form_gadget_locations - fills the instance data up with the gadget sizes
 *      and locations.
 *
 *   History:
 *        scw  06/23/92  Added static ANSI C prototypes
 */

#include <math.h>
#include <stdio.h>
#include "cct.h"

#include "OMmacros.h"
#include "OMprimitives.h"

#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"

#include "igecolordef.h"
#include "igecolmacros.h"

#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpcodef.h"
#include "dpcomacros.h"
#include "cm.h"

#ifdef X11
#include <limits.h>
#endif

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif


#if defined(__cplusplus)
}
#endif
#undef __


/* Static Variables */
static int      new_window = TRUE;
static int      was_converted_to_window = TRUE;
static int      new_window_buff_size = -1;
%endsafe

static int   CCT_original_gamma_compensate;
static int   CCT_original_num_ramp_colors;
static int   CCT_original_user_cube_size;
static struct WLraster_data    DITHERED_COLOR_image;
static struct WLraster_data    LOGICAL_COLOR_image;
static struct WLraster_data    HUE_SAT_BLOCK_image;
static struct WLraster_data    LUM_RANGE_image;
static struct WLraster_data    CROSS_HAIRS_image;

from APPcolor import   load_color_table;

IGRint COget_raster_data_struct( 
   IGRint raster,
   struct WLraster_data **raster_data_ptr )
{
/*
NAME
   COget_raster_data_struct
DESCRIPTION
   This gets the raster data structure to manipulate and draw
PARAMETERS
   raster (in) - which structure to return
   raster_data_ptr (out) - returned ptr to raster struct
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   switch (raster)
   {
      case LOGICAL_COLOR:
         *raster_data_ptr = &LOGICAL_COLOR_image;
         break;
      case DITHERED_COLOR:
         *raster_data_ptr = &DITHERED_COLOR_image;
         break;
      case HUE_SAT_BLOCK:
         *raster_data_ptr = &HUE_SAT_BLOCK_image;
         break;
      case LUM_RANGE:
         *raster_data_ptr = &LUM_RANGE_image;
         break;
      case CROSS_HAIRS:
         *raster_data_ptr = &CROSS_HAIRS_image;
         break;
      default:
         *raster_data_ptr = NULL;
         return( FALSE );
   }
   return( TRUE );
}
/*----- GRCreColorTb_button_intercept_routine ---------------------------------------*/
void GRCreColorTb_button_intercept_routine ( 
   Form   fp,      /* Pointer to the form      */
   int   xpos,       /* Coordinates of the event   */
   int   ypos,      /* Coordinates of the event   */
   int   button_number,   /* Button identifier      */
   int   transition,   /* Transition identifier   */
   int   time_tag )   /* Time data         */

{
/*
NAME
   GRCreColorTb_button_intercept_routine
DESCRIPTION
   this is the function called to intercept button pushes
PARAMETERS
   Form   fp,       Pointer to the form      
   int   xpos,        Coordinates of the event   
   int   ypos,       Coordinates of the event   
   int   button_number,    Button identifier      
   int   transition,    Transition identifier   
   int   time_tag )    Time data         
RETURN VALUES
   none
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   unsigned int    cmd_oid;
   unsigned short  cmd_os;

   FIf_get_cmd_oid_os ( fp, &cmd_oid, &cmd_os );
   om$send (   senderid   = cmd_oid,
         targetid   = cmd_oid,
         targetos   = cmd_os,
         msg      = message COcctform.button_intercept_method 
            ( fp, xpos, ypos, button_number, transition, time_tag ) );
}

/*----- GRCreColorTb_window_event_routine -------------------------------------------*/
void GRCreColorTb_window_event_routine (
   int   f_label,
   int   event,
   Form   fp )

{
/*
NAME
   GRCreColorTb_window_event_routine
DESCRIPTION
   This is the function called for getting window events
PARAMETERS
   f_label (in) - the label of the form
   event (in) - the event that happened to the form
   fb (in) - the form ptr
RETURN VALUES
   none
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   unsigned int      cmd_oid;
   unsigned short      cmd_os;

   FIf_get_cmd_oid_os ( fp, &cmd_oid, &cmd_os );

   om$send (   senderid   = cmd_oid,
         targetid   = cmd_oid,
         targetos   = cmd_os,
         msg      = message COcctform.window_event_method (
                  f_label, event, fp ) );
}

/*----- GRCreColorTb_continuous_routine ---------------------------------------------*/
void GRCreColorTb_continuous_routine ( 
   int      form_label,
   int      gadget_label,
   double      value,
   Form      fp )

{
/*
NAME
   GRCreColorTb_continuous_routine
DESCRIPTION
   The function called for continuous notification of gadget changes like
   when you hold a slider button down.
PARAMETERS
   form_label (in) = the label of the form
   gadget_label (in) - the gadget label (gotton from form builder)
   value (in) - the current value
   fp (in) - the form pointer
   
RETURN VALUES
   none
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   unsigned int      cmd_oid;
   unsigned short      cmd_os;

   FIf_get_cmd_oid_os ( fp, &cmd_oid, &cmd_os );

   om$send (   senderid   = cmd_oid,
         targetid   = cmd_oid,
         targetos   = cmd_os,
         msg      = message COcctform.form_notification (
                  form_label, gadget_label, value, fp ) );
}

/*----- get_color_data ---------------------------------------*/

method get_color_data ( int * sts; int change_original_values )

/*
 * ABSTRACT:   get_color_data checks and initialises the color
 *      and shade values, the color table and the reserved colors.
 *
PARAMATERS
   sts (out) - the status of the method
   original (in) - whether to copy into the original values (TRUE) or
                   just the modified ones (FALSE)
 * HISTORY:   01/11/88  Created.         C. M. Jablonski
 */

{
  int        status = OM_S_SUCCESS;

   IGRint      i;
   IGRshort   num_names, num_colors;
   IGRshort   menu_phys_slot;
   
   /* read and save the color names */
   num_names = 0;
   ige$read_color_names(num_names = &num_names, names = me->modified_names ); 

   status = om$vla_set_dimension(   varray   = me->modified_names,
               size   = num_names );
   status = ige$read_color_names(   num_names   = &num_names,
               names      = me->modified_names );

   /* read the color table */
   num_colors = 0;
   ige$read_color_table(   num_colors   = &num_colors,
            colors      = me->modified_ctbl,
            flags      = IGE_READ_BACKGROUND|IGE_READ_HIGHLIGHT|PACKED_COLORS );

   status = om$vla_set_dimension(   varray   = me->modified_ctbl,
               size   = num_colors );

   ige$read_color_table(   num_colors   = &num_colors,
            colors      = me->modified_ctbl,
            flags      = IGE_READ_BACKGROUND|IGE_READ_HIGHLIGHT|PACKED_COLORS );


   me->num_colors = num_colors;

   if (change_original_values)
   {
      status = om$vla_set_dimension(   varray   = me->orig_names,
                  size   = num_names );
            
      status = ige$read_color_names(   num_names   = &num_names,
                  names      = me->orig_names );

      status = om$vla_set_dimension(   varray   = me->orig_ctbl,
                  size   = num_colors );

      /* copy the table */
      for ( i = 0; i < num_colors; i++ )
      {
         me->orig_ctbl[i] = me->modified_ctbl[i];
      }
   
      /* pack in the physical slot for menu bg fg and hl. these will not change */
      ige$get_FI_COLOR_phys_slot( context_no = me->context_no, FI_DEFINE = FI_BLACK, phys_slot_num = &menu_phys_slot);
      WLpack_index_colorref( menu_phys_slot, &me->menu_bg, TRUE);

      ige$get_FI_COLOR_phys_slot( context_no = me->context_no, FI_DEFINE = FI_LT_GREY, phys_slot_num = &menu_phys_slot);
      WLpack_index_colorref( menu_phys_slot, &me->menu_fg, TRUE);

      ige$get_FI_COLOR_phys_slot( context_no = me->context_no, FI_DEFINE = FI_OFF_WHITE, phys_slot_num = &menu_phys_slot);
      WLpack_index_colorref( menu_phys_slot, &me->menu_hl, TRUE);
   }
   return( OM_S_SUCCESS );
}


/*----- initialize_GRCreColorTb ----------------------------------------------*/

method initialize_GRCreColorTb ( int * sts )

/*
 * ABSTRACT:   Initialize_GRCreColorTb is called during form initialization.
 *      It attaches the necessary routines, determines the color shade
 *      configuration, initializes the color pallet parameters, and
 *      activates the current color.
 *
 * HISTORY:   01/11/88  Created.         C. M. Jablonski
 */

{
   IGRint         status = OM_S_SUCCESS;
   IGRint         depth;
   IGRdouble   gamma[3];
   IGRint          form_mask;
   struct IGRdisplay   disbuf;
   IGRushort  cct_flags;
   int screen_type;

   WLget_active_screen( &me->lscreen_no, &screen_type );
   WLget_screen_depth( me->lscreen_no, FALSE /*hilite_used*/, &depth );

   /*Kludge to avoid multiple display of forms in X , (Ignores the first two display events ) */
   me->ignore_X_display = 3;

   /* form will come up save/restore */
   me->converted_to_window = FALSE;

   /* make sure we have enough bit planes for non Save/Restore forms */
   if ( depth < 3 )
   {
      /* erase the Convert to Window gadget if the form is coming */
      /* up on a virtual screen that doesn't have enough planes   */
      /* The Save/Restore form will have enough planes because of */
      /* the S/R VLT.                                             */
      FIg_erase( me->forms[CCT_FORM_LABEL].form_ptr, FI_CVT_TO_PERM_WIN );
   }

   /*** TAKE THIS OUT WHEN BLDG 11 FIXES WORKSHEET #11-9099 ***/
   /*This KLUDGE DOES NOT WORK FOR X FORMS IF THE FORM IS NOT DISPLAYED YET ***/
#ifndef X11
/*   if ( depth < 8 )*/
/*   {*/
/*      FIf_cvrt_to_perm_win( me->forms[CCT_FORM_LABEL].form_ptr );*/
/*      FIf_erase( me->forms[CCT_FORM_LABEL].form_ptr );*/
/*      me->converted_to_window = TRUE;*/
/*   }*/
#endif

   gr$get_active_display( buffer = &disbuf );
   me->old_active_color = disbuf.color;

   /* Attach the window event routine to the form */
   FIf_set_window_event_routine( me->forms[CCT_FORM_LABEL].form_ptr, GRCreColorTb_window_event_routine ); 

   /* Attach the button intercept routine to the form */
   FIf_set_button_intercept_routine( me->forms[CCT_FORM_LABEL].form_ptr, GRCreColorTb_button_intercept_routine );

   /* Attach the continuous routine to the sliders */
   FIg_set_continuous_routine( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_PAGE, GRCreColorTb_continuous_routine );
   FIg_set_continuous_routine( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_RED, GRCreColorTb_continuous_routine );
   FIg_set_continuous_routine( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_GREEN, GRCreColorTb_continuous_routine );
   FIg_set_continuous_routine( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_BLUE, GRCreColorTb_continuous_routine );
   FIg_set_continuous_routine( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_HUE, GRCreColorTb_continuous_routine );
   FIg_set_continuous_routine( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_LUMINANCE, GRCreColorTb_continuous_routine );
   FIg_set_continuous_routine( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_SATURATION, GRCreColorTb_continuous_routine ); 

   /* Initialize parameters */
   me->hit_check_box = FALSE;
   sprintf(me->file_name, "%s", "");
   dp$codpb_get_cct_data( cct_flags = &cct_flags, ctable_filename = me->file_name );
   me->slider_maximum = (cct_flags & CCT_SLIDER_RANGE)    ? 255.0            : 100.0;
   me->name_mode = (cct_flags & CCT_COLOR_NAME_MODE) ? NAME_RENAME_MODE : NAME_SELECT_MODE;
   me->file_type = (cct_flags & CCT_FILE_TYPE)       ? IGDS_COLORS      : IGE_COLORS;

   ige$set_inq_colortable_parameters( inq0_set1 = 0, gamma_correction = gamma,
      num_ramp_colors = &(CCT_original_num_ramp_colors),
      user_cube_size = &(CCT_original_user_cube_size) );
   if ( gamma[0]!=1.0 || gamma[1]!=1.0 || gamma[2]!=1.0 )
   {
      CCT_original_gamma_compensate = TRUE;
   }
   else 
   {
      CCT_original_gamma_compensate = FALSE;
   }

   om$send( msg = message COcctform.set_slider_maximum( me->slider_maximum ), targetid = my_id );

   /* initialize static variables for window_event method */
   new_window = TRUE;
   new_window_buff_size = -1;
   return( status );
}

/*----- window_event_method --------------------------------------------------*/
method window_event_method ( int f_label; int event; Form fp )

/*
 * ABSTRACT:   Window_event_method is called upon each window event.  It checks
 *      and updates the color-shade configuration and updates the color
 *      pallet, and it updates the current color.
 *
 * HISTORY:   01/11/88  Created.         C. M. Jablonski
 */

{
   IGRint          sts = TRUE;
   IGRlong         msg;
   struct IGEcontext_info IGEcontext_info;
   OMuword         mod_os;
   IGRint          form_mask;
   IGRint          option_form_active = FALSE;
   int             status = OM_S_SUCCESS;
   int             buff_size;

   FIf_get_attr( me->forms[CCT_FORM_LABEL].form_ptr, &form_mask );
   if (form_mask & FI_SAVE_RESTORE)
   {
#if defined ( DEBUG_CCT )
      printf("COcctform:window_event_method save_restore = TRUE\n");
#endif       
      me->converted_to_window = FALSE;
   }
   else 
   {
#if defined ( DEBUG_CCT )
      printf("COcctform:window_event_method save_restore = FALSE\n");
#endif       
      me->converted_to_window = TRUE;
   }

   FIg_get_state( me->forms[CCT_FORM_LABEL].form_ptr, BUTTON_OPTIONS, &option_form_active );

   sts = WLget_screen_depth( me->lscreen_no, FALSE /*hilite_used*/, &IGEcontext_info.table_depth );
   /*SAME KLUDGE AS BEFORE BUT FOR X FORMS (BDG 11 WORK SHEET) */
#ifdef X11
   if (IGEcontext_info.table_depth == 5)
   {
      if (!me->converted_to_window)
      {
         FIf_cvrt_to_perm_win( me->forms[CCT_FORM_LABEL].form_ptr );
         me->converted_to_window = TRUE; 
      }
   }

   if (((event == FI_CHANGED_SIZE) && (me->ignore_X_display == 0)) ||
       (event == FI_UNCOLLAPSE) || (event == FI_DISPLAY) || (event == FI_CHANGED_LOCATION)  )
#else
   if ((event == FI_DISPLAY) || (event == FI_UNCOLLAPSE) || (event == FI_CHANGED_LOCATION) ||
       (event == FI_CHANGED_SIZE) || (event == FI_REFRESH))
#endif
   {
      if ((new_window) || (was_converted_to_window != me->converted_to_window))
      {
         if (me->converted_to_window && !was_converted_to_window)
         {
#if defined ( DEBUG_CL )
            printf("COcctform:window_event_method removing logical win %d\n",me->lwin_no);
#endif       
            CMremove_form_from_wl(me->lscreen_no, me->lwin_no, me->context_no);
         }
         /* only do these things when you have a new window */
         FIf_get_window(me->forms[CCT_FORM_LABEL].form_ptr, &me->hwin_no);
         ex$get_cur_mod(osnum = &mod_os);
         CMadd_form_to_wl(me->hwin_no, TRUE/*share*/, NULL_OBJID, mod_os, !me->converted_to_window/*save_restore*/, 
            &me->lscreen_no, &me->context_no, &me->lwin_no );
      }

      WLget_raster_size( me->lwin_no, 1, 1, &buff_size);
      if (new_window)
      {
         new_window_buff_size = buff_size;
         om$send(msg   = message COcctform.get_form_gadget_locations( &msg ),
            targetid   = my_id );
      }
      else
      {
         if ((event == FI_CHANGED_SIZE) || (new_window_buff_size != buff_size))
         {
            /* if window changed size or the depth of the window changed (like on an 
               edgeII when 8 bit save restore is converted to 9 bit window) recompute */
            new_window_buff_size = buff_size;
            om$send(msg   = message COcctform.get_form_gadget_locations( &msg ),
               targetid   = my_id );
            WLfree_raster_data( &DITHERED_COLOR_image );
            WLfree_raster_data( &LOGICAL_COLOR_image );
            WLfree_raster_data( &HUE_SAT_BLOCK_image );
            WLfree_raster_data( &LUM_RANGE_image );
            WLfree_raster_data( &CROSS_HAIRS_image );
            /* for fast buffer can't check buffer to see if created or not */
            CROSS_HAIRS_image.lras_no = 0xFFFF;
         }
      }

      /* if the raster buffers haven't been allocated... allocate them */
      if (!DITHERED_COLOR_image.buffer)
      {
         sts = WLcreate_raster_data( me->lwin_no, me->context_no, &DITHERED_COLOR_image, 
            me->dithered_color_x + 2, me->dithered_color_y + 2, 
            me->dithered_color_width - 2, me->dithered_color_height - 2, 
            buff_size * 8, WL_SLOW_BUFFER, (char *) NULL);

         if (sts != WL_SUCCESS) 
         {
#if defined ( DEBUG_CCT )
            printf("COcctform.window_event_method WLcreate_raster_data error %d\n",sts);
#endif
            sts = FALSE;
            goto wrapup;
         }
      }
      if (!LOGICAL_COLOR_image.buffer)
      {
         sts = WLcreate_raster_data( me->lwin_no, me->context_no, &LOGICAL_COLOR_image, 
            0, 0, 
            (int) (me->log_col_gad[0].width - 2.0), (int) (me->log_col_gad[0].height - 2.0), 
            buff_size * 8, WL_SLOW_BUFFER, (char *) NULL);
         if (sts != WL_SUCCESS) 
         {
#if defined ( DEBUG_CCT )
            printf("COcctform.window_event_method WLcreate_raster_data error %d\n",sts);
#endif
            sts = FALSE;
            goto wrapup;
         }
      }
      if (!HUE_SAT_BLOCK_image.buffer)
      {
         sts = WLcreate_raster_data( me->lwin_no, me->context_no, &HUE_SAT_BLOCK_image, 
            me->hue_sat_block_x + 2, me->hue_sat_block_y + 2, 
            me->hue_sat_block_width - 2, me->color_height - 2, 
            buff_size * 8, WL_SLOW_BUFFER, (char *) NULL);
         if (sts != WL_SUCCESS) 
         {
#if defined ( DEBUG_CCT )
            printf("COcctform.window_event_method WLcreate_raster_data error %d\n",sts);
#endif
            sts = FALSE;
            goto wrapup;
         }
      }
      if (!LUM_RANGE_image.buffer)
      {
         sts = WLcreate_raster_data( me->lwin_no, me->context_no, &LUM_RANGE_image, 
            me->lum_range_x + 2, me->lum_range_y + 2, 
            me->lum_range_width - 2, me->color_height - 2, 
            buff_size * 8, WL_SLOW_BUFFER, (char *) NULL);
         if (sts != WL_SUCCESS) 
         {
#if defined ( DEBUG_CCT )
            printf("COcctform.window_event_method WLcreate_raster_data error %d\n",sts);
#endif
            sts = FALSE;
            goto wrapup;
         }
      }
      if (CROSS_HAIRS_image.lras_no == 0xFFFF)
      {
         sts = WLcreate_raster_data( me->lwin_no, me->context_no, &CROSS_HAIRS_image, 
            me->hue_sat_block_x + 2, me->hue_sat_block_y + 2, 19, 19, 
            buff_size * 8, WL_FAST_BUFFER, (char *) NULL);
         if (sts != WL_SUCCESS) 
         {
#if defined ( DEBUG_CCT )
            printf("COcctform.window_event_method WLcreate_raster_data error %d\n",sts);
#endif
            sts = FALSE;
            goto wrapup;
         }
      }

      if ((new_window) || (was_converted_to_window != me->converted_to_window))
      {
         /* Get the color data */
         if (new_window)
         {
            /* first time through */
            om$send(msg      = message COcctform.get_color_data( &sts, TRUE ),
               targetid   = my_id );
            om$send(   msg      = message COcctform.set_current_color( FALSE, me->old_active_color, FALSE ),
               targetid   = my_id );
         }
         else  
         {
            /* second time through */
            om$send(msg      = message COcctform.get_color_data( &sts, FALSE ),
               targetid   = my_id );
         }

         om$send( msg      = message COcctform.draw_color_pallet( &msg ), 
                  targetid = my_id );         

         /* recompute the raster data since new window */
         om$send( msg      = message COcctform.draw_hue_sat_block( &msg, TRUE ),
                  targetid = my_id );

         new_window = FALSE;
         was_converted_to_window = me->converted_to_window;
      }
      else
      {
         om$send( msg      = message COcctform.draw_color_pallet( &msg ), 
                  targetid = my_id );         

         if (event != FI_CHANGED_SIZE)
         {
            /* same window/same size so just put the old raster block */
            om$send( msg      = message COcctform.draw_hue_sat_block( &msg, FALSE ),
               targetid = my_id );
         }
         else
         {
            /* same window/different size so make new raster block */
            om$send( msg      = message COcctform.draw_hue_sat_block( &msg, TRUE ),
               targetid = my_id );
         }
      }

      om$send( msg      = message COcctform.update_active_color_display( &msg ),
               targetid = my_id );

      if ( option_form_active )
      {
            /* display the options subform */
            om$send( msg      = message COcctform.display_form_by_label ( OPTIONS_SUBFORM_LABEL, &status ),
                     targetid = my_id );
      }

#if defined ( X11 )
      if (event == FI_DISPLAY)
      {
         me->ignore_X_display = 0;
      }
#endif

   }
#if defined ( X11 )
   else
   {
      if (event == FI_CHANGED_SIZE)
      {
         if (me->ignore_X_display > 0)
         {
            me->ignore_X_display--;
         }
      }
   }
#endif
wrapup:
   return( sts );
}

/*--- sleep ------------------------------------------------------------*/

method sleep( int pos )

/*
 * ABSTRACT:   The sleep method is overridden so that the color table can be
 *      restored, if required, before the form is erased in the CEO sleep
 *      method.  Using an 'at sleep' doesn't result in this sequence.  The
 *      Active Drawing Parameters form is also updated after the form is
 *      erased, because it doesn't update if a Save/Restore form is 
 *              begin displayed.
 *
 * HISTORY:   10/22/90  Created.         S.P. Rogers
 */

{
   IGRint      sts = TRUE;
   IGRint      user_cube_size, num_ramp_colors, changed;
   IGRlong      msg;
   IGRdouble  gamma[3];
   struct IGRdisplay disbuf;
   IGRushort  cct_flags;

   if ( ! me->hit_check_box )
   {
      /* restore color table before form is taken down */
      om$send( msg      = message COcctform.restore_color_table( &sts ),
               targetid = my_id );
   }
     
   /* the code of this message will bring down the form */
   om$send( mode     = OM_e_wrt_message,
            msg      = message CEO.sleep( pos ),
            targetid = my_id );

   if ( ! me->converted_to_window )
   {
      /* update the Active Drawing Parameters form because */
      /* the changes made while the Save/Restore form was  */
      /* up didn't show up                                 */
      gr$get_active_display( buffer = &disbuf );
      gr$put_active_display( buffer = &disbuf );
   }

   if (!me->hit_check_box)
   {
      gr$get_active_display( buffer = &disbuf );
      disbuf.color = me->old_active_color;
      gr$put_active_display( buffer = &disbuf );

      ige$set_inq_colortable_parameters( inq0_set1 = 0, gamma_correction = gamma,
         num_ramp_colors = &(num_ramp_colors),
         user_cube_size = &(user_cube_size) );
      changed = FALSE;
      if ( (CCT_original_num_ramp_colors != num_ramp_colors) || (CCT_original_user_cube_size != user_cube_size))
      {
         ige$set_inq_colortable_parameters( inq0_set1 = 1, num_ramp_colors = &(CCT_original_num_ramp_colors),
            user_cube_size = &(CCT_original_user_cube_size) );
         changed = TRUE;
      }
      if ( ((gamma[0]!=1.0 || gamma[1]!=1.0 || gamma[2]!=1.0 ) && (CCT_original_gamma_compensate == FALSE)) ||
           ((gamma[0]==1.0 && gamma[1]==1.0 && gamma[2]==1.0 ) && (CCT_original_gamma_compensate == TRUE)) )
      { 
         /* cancelled form and had switched gamma_compensate=>switch back */
         om$send(msg      = message COcctform.toggle_compensation( &msg ), 
            targetid   = my_id );
      }
      else if (changed)
      {
         ige$configure_color_table();
      }
   }
   else
   {
      /* set the dpb information so next time command is brought up 
         (even after saving file) the toggles and file name will be the
         same */
      cct_flags = 0;
      cct_flags |= (me->slider_maximum == 255.0) ? CCT_SLIDER_RANGE : 0;
      cct_flags |= (me->name_mode == NAME_RENAME_MODE) ? CCT_COLOR_NAME_MODE : 0;
      cct_flags |= (me->file_type == IGDS_COLORS) ? CCT_FILE_TYPE : 0;
      dp$codpb_set_cct_data( cct_flags = cct_flags, ctable_filename = me->file_name );
   }

   CMremove_form_from_wl(me->lscreen_no, me->lwin_no, me->context_no);

   WLfree_raster_data( &DITHERED_COLOR_image );
   WLfree_raster_data( &LOGICAL_COLOR_image );
   WLfree_raster_data( &HUE_SAT_BLOCK_image );
   WLfree_raster_data( &LUM_RANGE_image );
   WLfree_raster_data( &CROSS_HAIRS_image );
   /* for fast buffer can't check buffer to see if created or not */
   CROSS_HAIRS_image.lras_no = 0xFFFF;
   return( OM_S_SUCCESS );
}

/*----- wakeup_GRCreColorTb ----------------------------------------------*/

method wakeup_GRCreColorTb ( int * sts )

/*
 * ABSTRACT:   Initialize_GRCreColorTb is called during form initialization.
 *      It attaches the necessary routines, determines the color shade
 *      configuration, initializes the color pallet parameters, and
 *      activates the current color.
 *
 * HISTORY:   01/11/88  Created.         C. M. Jablonski
 */

{
   struct IGRdisplay   disbuf;
   IGRint          form_mask;

   gr$get_active_display( buffer = &disbuf );
   me->old_active_color = disbuf.color;
   new_window = TRUE;
   /* for fast buffer can't check buffer to see if created or not */
   CROSS_HAIRS_image.lras_no = 0xFFFF;
   FIf_get_attr( me->forms[CCT_FORM_LABEL].form_ptr, &form_mask );
   if (form_mask & FI_SAVE_RESTORE)
   {
      was_converted_to_window = FALSE;
   }
   else 
   {
      was_converted_to_window = TRUE;
   }


   return( OM_S_SUCCESS );
}

/*----- get_form_gadget_locations ----------------------------------------------*/

method get_form_gadget_locations ( int * sts )

/*
   get_form_gadget_locations
DESCRIPTION
   gets the gadget locations and sizes and puts them into the instance data
HISTORY
*/

{
   double x, y, floor_x, floor_y, width, height;
   int gadget, index;

   for (index = 1; index < 67; index ++)
   {
      switch (index)
      {
         case 65:
            gadget = 113;
            break;
         case 66:
            gadget = 114;
            break;
         default:
            gadget = COLOR_PALLET_0_0 + index - 1;
            break;
      }
/* 53093 do a FIg_get_location for ints instead!!!!!!!!!!!!!!!!!!! */
      FIg_get_dlocation( me->forms[CCT_FORM_LABEL].form_ptr, gadget, &x, &y);
      FIg_get_dsize( me->forms[CCT_FORM_LABEL].form_ptr, gadget, &width, &height);
      floor_x = floor( x );
      floor_y = floor( y );
      me->log_col_gad[index].width = (short) (width + (x - floor_x));
      me->log_col_gad[index].height = (short) (height + (y - floor_y));
      me->log_col_gad[index].x = (short) floor_x;
      me->log_col_gad[index].y = (short) floor_y;
      if (index == 1)
      {
         me->log_col_gad[0].width = me->log_col_gad[index].width;
         me->log_col_gad[0].height = me->log_col_gad[index].height;
         me->log_col_gad[0].x = me->log_col_gad[index].x;
         me->log_col_gad[0].y = me->log_col_gad[index].y;
      }
      else
      {
         if (me->log_col_gad[index].width > me->log_col_gad[0].width)
         { 
            me->log_col_gad[0].width = me->log_col_gad[index].width;
         } 
         if (me->log_col_gad[index].height > me->log_col_gad[0].height)
         { 
            me->log_col_gad[0].height = me->log_col_gad[index].height;
         } 
      }
      
#if defined ( DEBUG_CCT )
      printf("%d %d x=%lf y=%lf w=%lf h=%lf\n",index/8,index%8,
         me->log_col_gad[index].x,me->log_col_gad[index].y,me->log_col_gad[index].width,me->log_col_gad[index].height);
#endif
   }   

/*   FIg_get_dlocation( me->forms[CCT_FORM_LABEL].form_ptr, COLOR_PALLET_0_0, */
/*      &me->logical_color_x, &me->logical_color_y);*/
/*   FIg_get_dsize( me->forms[CCT_FORM_LABEL].form_ptr, COLOR_PALLET_0_0, */
/*      &me->logical_color_width, &me->logical_color_height);*/
/*   floor_x = floor( me->logical_color_x );*/
/*   floor_y = floor( me->logical_color_y );*/
/*   me->logical_color_width = floor(me->logical_color_width + (me->logical_color_x - floor_x));*/
/*   me->logical_color_height = floor(me->logical_color_height + (me->logical_color_y - floor_y));*/
/*   me->logical_color_x = floor_x;*/
/*   me->logical_color_y = floor_y;*/
/**/
/*   FIg_get_dlocation( me->forms[CCT_FORM_LABEL].form_ptr, COLOR_PALLET_1_1, */
/*      &logical_color_x1, &logical_color_y1);*/
/*   logical_color_x1 = floor( logical_color_x1 );*/
/*   logical_color_y1 = floor( logical_color_y1 );*/
/**/
/*   me->logical_color_space_width = logical_color_x1 - me->logical_color_x - me->logical_color_width;*/
/*   me->logical_color_space_height = logical_color_y1 - me->logical_color_y - me->logical_color_height;*/

   FIg_get_dlocation( me->forms[CCT_FORM_LABEL].form_ptr, RECTANGLE_DITHERED_COLOR, 
      &me->dithered_color_x, &me->dithered_color_y);
   FIg_get_dsize( me->forms[CCT_FORM_LABEL].form_ptr, RECTANGLE_DITHERED_COLOR, 
      &me->dithered_color_width, &me->dithered_color_height);
   floor_x = floor( me->dithered_color_x );
   floor_y = floor( me->dithered_color_y );
   me->dithered_color_width = floor(me->dithered_color_width + (me->dithered_color_x - floor_x));
   me->dithered_color_height = floor(me->dithered_color_height + (me->dithered_color_y - floor_y));
   me->dithered_color_x = floor_x;
   me->dithered_color_y = floor_y;

   FIg_get_dlocation( me->forms[CCT_FORM_LABEL].form_ptr, RECTANGLE_SOLID_COLOR, 
      &me->solid_color_x, &me->solid_color_y);
   FIg_get_dsize( me->forms[CCT_FORM_LABEL].form_ptr, RECTANGLE_SOLID_COLOR, 
      &me->solid_color_width, &me->solid_color_height);
   floor_x = floor( me->solid_color_x );
   floor_y = floor( me->solid_color_y );
   me->solid_color_width = floor(me->solid_color_width + (me->solid_color_x - floor_x));
   me->solid_color_height = floor(me->solid_color_height + (me->solid_color_y - floor_y));
   me->solid_color_x = floor_x;
   me->solid_color_y = floor_y;

   FIg_get_dlocation( me->forms[CCT_FORM_LABEL].form_ptr, RECTANGLE_HUE_SAT, 
      &me->hue_sat_block_x, &me->hue_sat_block_y);
   FIg_get_dsize( me->forms[CCT_FORM_LABEL].form_ptr, RECTANGLE_HUE_SAT, 
      &me->hue_sat_block_width, &me->color_height);
   floor_x = floor( me->hue_sat_block_x );
   me->hue_sat_block_width = floor(me->hue_sat_block_width + (me->hue_sat_block_x - floor_x));
   me->hue_sat_block_x = floor_x;
   me->hue_sat_block_y = floor( me->hue_sat_block_y );

   FIg_get_dlocation( me->forms[CCT_FORM_LABEL].form_ptr, RECTANGLE_LUM_RANGE, 
      &me->lum_range_x, &me->lum_range_y);
   FIg_get_dsize( me->forms[CCT_FORM_LABEL].form_ptr, RECTANGLE_LUM_RANGE, 
      &me->lum_range_width, &me->color_height);
   floor_x = floor( me->lum_range_x );
   floor_y = floor( me->lum_range_y );
   me->lum_range_width = floor(me->lum_range_width + (me->lum_range_x - floor_x));
   me->color_height = floor(me->color_height + (me->lum_range_y - floor_y));
   me->lum_range_x = floor_x;
   me->lum_range_y = floor_y;

   return( OM_S_SUCCESS );
}

end implementation COcctform;
