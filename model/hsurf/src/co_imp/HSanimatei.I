class implementation HSanimate;



#define CHECK_RETURN_CODES    0

#define RUN                   1
#define CANCEL                4

#define QUIT                  3
#define PHONG_FILE            4
#define NO_ACTION             5
#define FULL_SCREEN           6

#define SAVE                  0
#define DISPLAY               1
#define RETURN                '\r'

#define OLD_FILES             4000
#define GET_A_WINDOW          4001
#define GET_A_BOUNDARY        4002
#define GET_A_FENCE           4003
#define VALIDATE_OVERWRITE    4004
#define GET_SCALE_FACTOR      4005
#define INVALID_SCALE_FACTOR  4006
#define NOT_ENOUGH_PLANES     4007

/* the four different configurations of windows and number of files */
#define MULT_EXIST            4008
#define MULT_NEW              4009
#define SINGLE_EXIST          4010
#define SINGLE_NEW            4011

/* two states for check_window_flags return values */
#define USE_EXIST             4012
#define USE_FULL              4013

/* states detailing if a window has been selected yet when exiting */
#define WIN_EXIT              4014
#define NO_WIN_EXIT           4015

#define SINGLE_FRAME          0
#define MULTIPLE_FRAMES       1

#define DO_FORM               2

#define FENCE_DYN             2112

/* Gadget Titles */
#define WINDOW_TITLE          12
#define SCALE_TITLE           15

/* Toggles */
#define CYCLE                 19
#define CLEAR_WINDOW          29

/* Fields */
#define ERROR_FIELD           10
#define WINDOW_FIELD          16
#define FRAME_DELAY           20
#define CYCLE_DELAY           21
#define SCALE_FIELD           23

/* Groups */
#define ANIMATION_GROUP       24
#define FRAME_DELAY_GROUP     26
#define CYCLE_DELAY_GROUP     27
#define DISPLAY_OPT_GROUP     32
#define TIME_DELAY_GROUP      33
#define RGB_DISPLAY_GROUP     36
#define CT_USE_GROUP          41
#define WINDOW_USE_GROUP      42

/* Buttons */
#define SLIDESHOW             17
#define TIME_DELAY            18
#define ANIMATION             22
#define SINGLE_STEP           28
#define SPEED_BUTTON          30
#define APPEARANCE_BUTTON     31
#define DISP_24_BIT           34
#define DISP_8_BIT            35
#define WINDOW_CT             37
#define FILE_CT               38
#define FULL_SCREEN_WIN       39
#define EXISTING_WIN          40


#define FALSE                 0
#define TRUE                  1

#define APPEARANCE            0
#define SPEED                 1

#define DO_24_BIT             0
#define DO_8_BIT              1

#define USE_FULL_SCREEN       0
#define USE_EXISTING          1

#define USE_FILES_CT          0
#define USE_WINDOW_CT         1

#define DEBUG                 0

/* remove when checking in file */
#define JNL_STOPSIGN          7


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <FI.h>

#include "wl.h"
#include "cm.h"

#ifndef ENV5
#include <tools.h>
#endif

#include "igrtypedef.h"

#include "HStl_window.h"
#include "OMerrordef.h"

#include "igewindef.h"
#include "igewinmacros.h"
#include "igr.h"

#include "fontdef.h"
#include "font.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "godef.h"

#include "msdef.h"
#include "msmacros.h"

#include "igecolmacros.h"

#include "hsdef.h"
#include "hsurferrpriv.h"
#include "hsmsg.h"
#include "hsmacros.h"
#include "hsmachine.h"

#include "griodef.h"
#include "griomacros.h"

#include "journal.h"

#include "ECmsg.h"

/*-----------------------
 *  for function
 *     HScheck_hardware_support
 */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_global.h"
#include "HStl_element.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

/*--------------------------
 *  for functions
 *     HScapture_image
 *     HSfile_error
 *     HSfree_buffers
 *     HSget_num_frames
 *     HSinit_heartbeat
 *     HSinq_phong_file
 *     HSnot_enough_planes_for_RGB
 *     HSrapid_display
 *     HSread_rle_files
 *     HSslide_show
 *     HSinit_full_screen_window
 *     HSdelete_full_screen_window
 */

%safe 
#include "HSpr_co_func.h"
%endsafe

/*------------------------------
 *  for function
 *     HSgetMachineInfo
 */
 
#include "hsurf.h"
#include "HSpr_dpb_imp.h"
 
/*------------------------------*/

#ifdef X11
extern FILE     *JNL_echo;
#endif

/*--------------------------------------------------------------------------*/


#define _start 0
#define _zoom 1
#define _form_display 2
#define _get_filename 3
#define _validate_filename 4
#define _get_boundary 5
#define _determine_window 6
#define _load_frames 7
#define _get_window 8
#define _get_fence_pt1 9
#define _get_fence_pt2 10

method initialize_instance_data ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRint                 true_color=FALSE;
   IGRuint                flags = 0;
   WLuint16               lscreen_no;
   int                    type_of_screen;
   WLuint32               context_no;
   struct WLcontext_info  context_info;
   int                    on_sgi = FALSE;


   me->converted_win = FALSE;

   WLget_active_screen( &lscreen_no, &type_of_screen );
   CMget_active_context( lscreen_no, &context_no );
   WLget_context_info( context_no, &context_info );

   if( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      /* true color machine */
      true_color = 1;
   }

   hs$get_shading_flags( save_image_flags = &flags );

   me->planes = context_info.base_depth;
   me->win_no = 0;
   me->get_window = FALSE;
   me->context_no = WL_DEFAULT_CONTEXT;
 
   /* This piece of instance data will be used to show whether */
   /* the buffers are filled                                   */

   me->using_fence = FALSE;
   me->do_form = FALSE;

   /* Start initializing the instance data using the flags in the dpb */
   if( HS_DIS_IMAGE_SLIDE & flags )
   {
      me->animate = TRUE;
   }
   else
   {
      me->animate = FALSE;
   }

   if( HS_DIS_IMAGE_NEW_WIN & flags )
   {
      me->win_to_use = USE_EXISTING;
   }
   else
   {
      me->win_to_use = USE_FULL_SCREEN;
   }

   if( HS_DIS_IMAGE_FILE_CT & flags )
   {
      me->ct_to_use = USE_WINDOW_CT;
   }
   else
   {
      me->ct_to_use = USE_FILES_CT;
   }

   if( HS_DIS_IMAGE_DELAY & flags )
   {
      me->delay = FALSE;
   }
   else
   {
      me->delay = TRUE;
   }

   if( HS_DIS_IMAGE_CYCLE & flags )
   {
      me->cycle = FALSE;
   }
   else
   {
      me->cycle = TRUE;
   }

   if( HS_DIS_IMAGE_SCALE_FOUR & flags )
   {
      me->scale_factor = 16;
   }
   else if( HS_DIS_IMAGE_SCALE_TWO & flags )
   {
      me->scale_factor = 8;
   }
   else if( HS_DIS_IMAGE_SCALE_ONE & flags )
   {
      me->scale_factor = 4;
   }
   else if( HS_DIS_IMAGE_SCALE_ONE_HALF & flags )
   {
      me->scale_factor = 2;
   }
   else if( HS_DIS_IMAGE_SCALE_ONE_QUARTER & flags )
   {
      me->scale_factor = 1;
   }
   else if( HS_DIS_IMAGE_SCALE_ONE_EIGHTH & flags )
   {
      me->scale_factor = 0;
   }

   hs$get_display_image_delays(cycle_delays =  me->CycleDelay,
                               frame_delays =  me->FrameDelay);

   if (true_color)
   {
      if (flags & HS_SAVE_IMAGE_8BIT)
      {
         me->Optimize = DO_8_BIT;
      }
      else
      {
         me->Optimize = DO_24_BIT;
      }
   }
   else
   {
      if (flags & HS_DIS_IMAGE_SPEED)
      {
         me->Optimize = APPEARANCE;
      }
      else
      {
         me->Optimize = SPEED;
      }
   }

   if( HS_DIS_IMAGE_CLEAR & flags )
   {
      me->WindowErase = FALSE;
   }
   else
   {
      me->WindowErase = TRUE;
   }

quit:
  return OM_S_SUCCESS;
}

method init_form_display ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   Form                   form_ptr;
   char                   string[17];
   struct var_list        var_list1[2];
   IGRlong                which_error;
   IGRlong                msg;
   IGRlong                ret_bytes;
   int                    Row;
   WLuint16               lscreen_no;
   int                    type_of_screen;
   WLuint32               context_no;
   struct WLcontext_info  context_info;
   IGRuint                flags;
   int                    true_color = FALSE;


   form_ptr = me->forms[0].form_ptr;

   var_list1[0].var            = GRAGAD_NAME;
   var_list1[0].var_ptr        = string;
   var_list1[0].num_bytes      = 17;
   var_list1[0].bytes_returned = &ret_bytes;
   var_list1[1].var            = END_PARAM;

   dp$inq_set_gragad( msg          = &msg,
                      inq0_set1    = 0,
                      osnum        = me->win_ids[0].osnum,
                      gragad_objid = me->win_ids[0].objid,
                      which_error  = &which_error,
                      var_list     = var_list1);


   /* determine screen depth and type of machine */
   WLget_active_screen( &lscreen_no, &type_of_screen );
   CMget_active_context( lscreen_no, &context_no );
   WLget_context_info( context_no, &context_info );

   if( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      /* true color machine */
      true_color = TRUE;
   }

   if (true_color)
   {
      FIg_erase(form_ptr, DISPLAY_OPT_GROUP);
      
      if ( me->phong_flag )   /* type 27 data file */
      {
         if( me->using_fence || !me->animate ) /* means 'buffers_filled' */
         {
            FIg_disable(form_ptr, RGB_DISPLAY_GROUP);
         }
         else
         {
            FIg_enable( form_ptr, RGB_DISPLAY_GROUP );
         }

         if (me->Optimize == DO_24_BIT)
         {
            FIg_set_state_on(form_ptr, DISP_24_BIT );
         }
         else
         {
            FIg_set_state_on(form_ptr, DISP_8_BIT );
         }
      }
      else            /* index data type */
      {
         hs$get_shading_flags( save_image_flags = &flags );

         me->Optimize = DO_8_BIT;

#if defined( OPENGL )
         me->win_to_use = USE_EXISTING;
         FIg_set_state_on( form_ptr, EXISTING_WIN);
         FIg_disable( form_ptr, WINDOW_USE_GROUP);
#endif
         flags = flags | HS_SAVE_IMAGE_8BIT;  /* set flag for 8 bit mode */
         hs$put_shading_flags(save_image_flags = &flags);

         FIg_disable(form_ptr, RGB_DISPLAY_GROUP);
      }
   }
   else
   {
      FIg_erase(form_ptr, RGB_DISPLAY_GROUP);

      /* 'me->using_fence' here means buffers_filled */
      if( (me->planes <= 5) && (me->animate) && (!me->using_fence) )
      {
         FIg_enable( form_ptr, DISPLAY_OPT_GROUP );

         if( me->Optimize == APPEARANCE )
         {
            FIg_set_state_on( form_ptr, APPEARANCE_BUTTON  );
         }
         else
         {
            FIg_set_state_off( form_ptr, SPEED_BUTTON );
         }
      }
      else
      {
         FIg_disable( form_ptr, DISPLAY_OPT_GROUP );
      }
   }

   if( me->phong_flag || !me->using_fence )
   {
      /* !me->using_fence means the buffers haven'n been filled, thus no */
      /* window has been selected to fill in the name of.                */
      FIg_erase( form_ptr, WINDOW_FIELD );
      FIg_erase( form_ptr, WINDOW_TITLE );
   }
   else
   {
      FIg_display( form_ptr, WINDOW_FIELD );
      FIg_display( form_ptr, WINDOW_TITLE );
      FIfld_set_text( form_ptr, WINDOW_FIELD, 0, 0, string, FALSE );
   }

   if( me->animate )
   {
      FIg_set_state_on( form_ptr, ANIMATION );
   }
   else
   {
      FIg_set_state_on( form_ptr, SLIDESHOW );
   }

   if( me->cycle )
   {
      FIg_set_state_off( form_ptr, CYCLE );
   }
   else
   {
      FIg_set_state_on( form_ptr, CYCLE );
   }

   switch( me->scale_factor )
   {
      case 0:    Row = 3;
                 break;
      case 1:    Row = 4;
                 break;
      case 2:    Row = 5;
                 break;
      case 4:    Row = 0;
                 break;
      case 8:    Row = 1;
                 break;
      case 16:   Row = 2;
                 break;
      default:   Row = 0;
                 break;
   }

   FIfld_set_select( form_ptr, SCALE_FIELD, Row, 0, FALSE );

   if( me->delay )
   {
      FIg_set_state_on( form_ptr, TIME_DELAY );

      FIg_display( form_ptr, FRAME_DELAY_GROUP );
      FIg_set_value( form_ptr, FRAME_DELAY, me->FrameDelay[me->animate] );
      if( me->cycle )
      {
         FIg_display( form_ptr, CYCLE_DELAY_GROUP );
         FIg_set_value( form_ptr, CYCLE_DELAY, me->CycleDelay[me->animate] );
      }
      else
      {
         FIg_erase( form_ptr, CYCLE_DELAY_GROUP );
      }
   }
   else
   {
      FIg_set_state_on( form_ptr, SINGLE_STEP );

      FIg_erase( form_ptr, FRAME_DELAY_GROUP );
      FIg_erase( form_ptr, CYCLE_DELAY_GROUP );
   }

   if( me->WindowErase )
   {
      FIg_set_state_off( form_ptr, CLEAR_WINDOW );
   }
   else
   {
      FIg_set_state_on( form_ptr, CLEAR_WINDOW );
   }

   if( me->win_to_use == USE_FULL_SCREEN )
   {      
      FIg_set_state_on( form_ptr, FULL_SCREEN_WIN );
   }
   else
   {
      FIg_set_state_on( form_ptr, EXISTING_WIN );
   }

   if( me->phong_flag )
   {
      /* true color files do not have a colortable stored with them */ 
      me->ct_to_use = USE_WINDOW_CT;
      FIg_set_state_on( form_ptr, WINDOW_CT );
   }
   else
   {
      if( me->ct_to_use == USE_FILES_CT )
      {
         FIg_set_state_on( form_ptr, FILE_CT );
      }
      else
      {
         FIg_set_state_on( form_ptr, WINDOW_CT );
      }
   }

   if( me->do_form )
   {
      FIg_disable( form_ptr, ANIMATION_GROUP );
      FIg_disable( form_ptr, SCALE_FIELD );
      FIg_disable( form_ptr, WINDOW_USE_GROUP );
      FIg_disable( form_ptr, CT_USE_GROUP );
   }
   else if( me->SingleFrame )
   {
      /* disable all gadgets except the window selection and colortable */
      /* selection gadgets                                              */

      FIg_disable( form_ptr, SCALE_FIELD );
      FIg_disable( form_ptr, SCALE_TITLE );

      FIg_disable( form_ptr, ANIMATION_GROUP );
      FIg_disable( form_ptr, FRAME_DELAY_GROUP );
      FIg_disable( form_ptr, CYCLE_DELAY_GROUP);
      FIg_disable( form_ptr, DISPLAY_OPT_GROUP );
      FIg_disable( form_ptr, TIME_DELAY_GROUP );
      FIg_disable( form_ptr, RGB_DISPLAY_GROUP );
      FIg_disable( form_ptr, TIME_DELAY_GROUP );
      FIg_disable( form_ptr, CYCLE );
      FIg_disable( form_ptr, CLEAR_WINDOW );

#if defined( OPENGL)
      if( !me->phong_flag)
      {
         /*
            Temporary kludge to avoid having a full screen indexed window
            on a SGI machine.  Remove when fix for full screen indexe window
            code is avialable.
          */
         me->win_to_use = USE_EXISTING;
         FIg_set_state_on( form_ptr, EXISTING_WIN);
         FIg_disable(form_ptr, WINDOW_USE_GROUP);
      }
#endif
   
   }
   else
   {
      FIg_enable( form_ptr, ANIMATION_GROUP );
      FIg_enable( form_ptr, SCALE_FIELD );

#if !defined( OPENGL )
      FIg_enable( form_ptr, WINDOW_USE_GROUP );
#endif

      if( me->phong_flag )
      {
         /* no colortable stored with the file, so deactivate buttons */
         FIg_disable( form_ptr, CT_USE_GROUP );
      }
      else
      {
         FIg_enable( form_ptr, CT_USE_GROUP );
      }
   }
   me->do_form = FALSE;

quit:
  return OM_S_SUCCESS;
}

method load_filename_prompt ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRint message_no;

   me->win_no = 0;
   switch ( me->mytype )
   {
      case SAVE :
         message_no = HS_P_EntImgToSave;
         break;

      case DISPLAY :
         message_no = HS_P_EntImgToDisplay;
         break;

      default :
         message_no = 0;
         break;
   }  /* end: switch */

   ex$message( msgnumb = message_no, buff = me->prompt );

quit:
  return OM_S_SUCCESS;
}

method load_window_prompt ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRint message_no;

   switch ( me->mytype )
   {
      case SAVE :
         message_no = HS_P_SelWinToSave;
         break;

      case DISPLAY :
         message_no = HS_P_SelWinForImg;
         break;

      default :
         message_no = 0;
         break;

   }  /* end: switch */

   ex$message( msgnumb = message_no, buff = me->prompt );

quit:
  return OM_S_SUCCESS;
}

method load_cmd_name_message ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRint message_no;

   switch ( me->mytype )
   {
      case SAVE :
         message_no = HSM_M_SaveImg;
         break;

      case DISPLAY :
         message_no = HSM_M_DisplayImg;
         break;

      default :
         message_no = 0;
         break;
   }  /* end: switch */

   ex$message( msgnumb = message_no, field=MESSAGE_FIELD );

quit:
  return OM_S_SUCCESS;
}

method get_num_frames ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   if( HSget_num_frames( me->filename ) > 1 )
   {
      me->SingleFrame = FALSE;
      *sts = MULTIPLE_FRAMES;
   }
   else
   {
      me->animate       = FALSE;
      me->delay         = TRUE;
      me->FrameDelay[0] = 0.0;
      me->cycle         = FALSE;
      me->Optimize      = SPEED;         /* This will set up line-by-line */
                                         /* interpolated zoom             */
      me->SingleFrame   = TRUE;
      me->scale_factor  = 4;             /* With single image, scale must  */
                                         /* start at 1                     */
      *sts = SINGLE_FRAME;
   }

   ex$message( in_buff = "", field = PROMPT_FIELD );
quit:
  return OM_S_SUCCESS;
}

method wait_for_button ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   int                  BButton;
   int                  Transition;
   int                  window;
   WLuint32             lwin_no;
   struct echo_button   button;
   Form                 form_ptr;
   int                  stop = FALSE;
   int                  event;
   int                  type;
   int                  num_frames = 0;
   char                 buffer[10];
   int                  num_bytes = 10;
   int                  resp;
   int                  journaling = FALSE;
   int                  playback = FALSE;
#ifndef X11
   int                  Mask = 0x00000000;
   int                  UnNeeded;
#else
   Bool                 animate_predproc();
   XEvent               report;
   XEvent               journal_info;
   Display              *win_display;
   struct WLnative_info native_info;
   Bool                 got_event;

   /* If we are on a machine that runs X, we need to get the display from */
   /* the native_info structure                                           */

   WLget_native_info( me->win_no, me->context_no, &native_info );
   win_display = native_info.display;
#endif

   if( JNL_journal() )
   {
      journaling = TRUE;
   }
   if (JNL_playback())
   {
      playback = TRUE;
   }

   /* Prompt the user for left or right (zoom in or out) */
   ex$message ( msgnumb       = HS_P_InterpolatedZoom,
                justification = CENTER_JUS );
   ex$message ( msgnumb       = HS_P_RestoreExit, 
                justification = CENTER_JUS, 
                field         = KEYIN_FIELD );

   IGEresetstop();

   while( TRUE )
   {
      if( playback )
      {
#ifndef X11
         JNL_echo_input( 4, (char *)&event );
         if( event == JNL_INFO_EVENT )
         {
            JNL_echo_input( 4, (char *)&type );
            JNL_echo_input( 4, (char *)&num_frames );
            stop = TRUE;
         }
         else
         {
            JNL_adjust_echo();
         }
#else
         JNL_read_next_event( &journal_info );

         if( (journal_info.type == JNL_INFO_EVENT ) &&
             (journal_info.xany.serial == JNL_WINDOW_CHANGE) )
         {
            /* stopsign event */
            num_frames = journal_info.xany.window;
            stop = TRUE;
         }
         else
         {
            /* need to "jump back" in the file */
            fseek( JNL_echo, -(sizeof( XEvent )), 1);
         }
#endif
      }
      else
      {
         if( IGEstop() )
         {
            stop = TRUE;
            if( journaling )
            {
               JNL_record_info_event( JNL_STOPSIGN, 0, (char *)&num_frames );
            }
         }
      }
    
      if( stop)
      {
         if( me->win_to_use == USE_FULL_SCREEN )
         {
            *sts = FULL_SCREEN;
         }
         else
         {
            *sts = QUIT;
         }
         break;
      }

#ifndef X11
      if( journaling || playback )
      {
         JNL_inq_events( &Mask );
      }
      else
      {
         Inq_events( &Mask );
      }

      if( Mask & BUTTON_EVENT )
      {
         if( journaling || playback )
         {
            JNL_get_button_data( (int *)&window,
                                 &me->x,
                                 &me->y,
                                 &BButton,
                                 &Transition,
                                 &UnNeeded);
         }
         else
         {
            Get_button_data( (int *)&window,
                             &me->x,
                             &me->y,
                             &BButton,
                             &Transition,
                             &UnNeeded);
         }

         WLget_logical_window( window, &lwin_no);
         if( lwin_no != me->win_no )
         {
#else
      if( journaling || playback )
      {
         got_event = JNL_XCheckIfEvent( win_display, &report, animate_predproc, NULL);
      }
      else
      {
         got_event = XCheckIfEvent( win_display, &report, animate_predproc, NULL);
      }
      if( got_event )
      {
         XPutBackEvent( win_display, &report );
         if(report.type == ButtonPress )
         {
            HSXget_button_data( (int *)&lwin_no,
                             &Transition,
                             &BButton,
                             &me->x, 
                             &me->y );

            if(( lwin_no == -1 ) ||( lwin_no != me->win_no ))

            {
#endif
            if( me->win_to_use == USE_FULL_SCREEN )
            {
               *sts = FULL_SCREEN;
            }
            else
            {
               *sts = QUIT;
            }
            break; /* Out of while( TRUE ) loop */
         }         /* end if(window !=... */
         else if( lwin_no == me->win_no )
         {
            *sts = BButton;
            switch( BButton )
            {
               case LEFT_BUTTON:
                  if( me->scale_factor == 0 )
                  {
                     me->scale_factor = 1;
                  }
                  else
                  {
                     if( me->scale_factor < 16 )
                     {
                        me->scale_factor *= 2;
                     }
                     else
                     {
                        /* WARNING message here that scale is max already */
                        ex$message( msgnumb = HS_W_ScaleAlreadyMax );
                        sleep( 3 );
                        ex$message( in_buff = "",
                                    field   = ERROR_FIELD );
                        *sts = NO_ACTION;
                     }
                  }
                  break;
               case RIGHT_BUTTON:
                  if( me->scale_factor > 0 )
                  {
                     me->scale_factor /= 2;
                  }
                  else
                  {
                     /* WARNING message here that scale is min already */
                     ex$message( msgnumb = HS_W_ScaleAlreadyMin );

                     sleep( 3 );

                     ex$message( in_buff = "",
                                 field   = ERROR_FIELD );

                     *sts = NO_ACTION;
                  }
                  break;
               case MIDDLE_BUTTON:
                  break;
            }
            break; /* Out of while( TRUE ) loop */
         }
#ifndef X11
      }
      else if( Mask & KEYBOARD_EVENT )
      {
         ex$wait_for_input(  response = &resp,
                                 mode = EX_ALL_CHAR_MODE, 
                               buffer = buffer,
                                 byte = &num_bytes); 

         if (buffer[0] == RETURN)
         {
            me->x = 0;
            me->y = 0;
            me->scale_factor = 4;
            *sts = MIDDLE_BUTTON;
         }

         Clear_keyboard_data();
         break; /* Out of while( TRUE ) loop */
      }
   }
#else
         }
         else if( report.type == KeyPress)
         {
            ex$wait_for_input(  response = &resp,
                                    mode = EX_ALL_CHAR_MODE, 
                                  buffer = buffer,
                                    byte = &num_bytes); 

            if (buffer[0] == RETURN)
            {
               me->x = 0;
               me->y = 0;
               me->scale_factor = 4;
               *sts = MIDDLE_BUTTON;
            }

            break; /* Out of while( TRUE ) loop */
         }
      }
   }
#endif

   ex$message ( in_buff       = " ", 
                justification = CENTER_JUS, 
                field         = KEYIN_FIELD );

quit:
  return OM_S_SUCCESS;
}

method process_filename_keyin ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRint    test;
   IGRint    len;
   IGRint    depth;
   FILE      *fp;
   int       screen_type;
   WLuint32  context_no;
   WLuint16  lscreen_no;


   if ( strlen( me->event1.event.keyin ) != 0 )
   {
      strcpy( me->filename, me->event1.event.keyin );

      me->x = 0;
      me->y = 0;

      test = strspn( "*", me->filename );
      len = strlen( me->filename );

      if ( (me->mytype == DISPLAY) )
      {
         status = HSinq_phong_file( me->filename,
                                    &me->phong_flag,
                                    &me->x_pixels,
                                    &me->y_pixels );

         if( status )
         {
            *sts = OM_W_WARNING;
         }
         else if( !me->phong_flag )
         {
            *sts = OLD_FILES;
         }
         else
         {
            WLget_active_screen( &lscreen_no, &screen_type);
            CMget_active_context( lscreen_no, &context_no );
            WLget_context_depth( context_no, &depth );

            if (  depth < 3 )
            {
               HSnot_enough_planes_for_RGB();
               *sts = NOT_ENOUGH_PLANES;
               return(1);
            }

            *sts = OLD_FILES;
            if ( (test == 0) && (me->filename[len-1] != '~') )
            {
               me->delay = TRUE;
               me->animate = FALSE;
               me->CycleDelay[0] = 0.0;
               me->cycle = FALSE;
            }
         }                        /* end: else... */
      }                           /* end: if( me->my_type == display */
      else
      {
         if ( (me->filename[len-1] == '~') || (test != 0) )
         {
            HSfile_error(8);
            *sts = OM_W_WARNING;
         }
         else if ( (fp = (FILE *)fopen( me->filename, "r" ) ) )
         {
            fclose( fp );
            *sts = VALIDATE_OVERWRITE;
         }
         else
         {
            *sts = GET_A_BOUNDARY;
         }
      }                           /* end: else         */
   }                              /* end: if strlen... */
   else
   {
      /* user entered NULL string */
      *sts = OM_W_WARNING;
   }
quit:
  return OM_S_SUCCESS;
}

method process_overwrite_keyin ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRchar ch;

   if ( strlen( me->event1.event.keyin ) != 0 )
   {
      ch = me->event1.event.keyin[0];
      ch &= 0xDF; /* Force input to upper case. */
  
      switch (ch)
      {
         case 'Y':
            *sts = OM_S_SUCCESS;
            break;

         default :

            *sts = OM_W_WARNING;

      }  /* end: switch */

   } /* end if strlen(-) != 0 */
   else
   {
      /* user entered NULL string */
      *sts = OM_S_SUCCESS;
   }

quit:
  return OM_S_SUCCESS;
}

method process_boundary_keyin ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRchar ch;

   me->using_fence = FALSE;
   if ( strlen(me->event1.event.keyin ) != 0 )
   {
      ch = me->event1.event.keyin[0];
      ch &= 0xDF;   /* force input to upper case */

      if ( ch == 'W' )
      {
         *sts = GET_A_WINDOW;
      }
      else
      {
         me->using_fence = TRUE;
         *sts = GET_A_FENCE;
      }
   }
   else
   {
      *sts = GET_A_WINDOW;
   }
quit:
  return OM_S_SUCCESS;
}

method save_image ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   char             buffer[100];
   struct var_list  var_list1[2];
   IGRlong          which_error;
   IGRlong          msg;
   IGRlong          ret_bytes;
   IGRint           xl;
   IGRint           yl;
   IGRint           dx;
   IGRint           dy;
   WLuint16         lscreen_no;
   int              type_of_screen;
   
   struct WLbounds  win_attr;
   struct WLbounds  dummy;     /* dummy variable for WLget_window_bounds call */

   /* get the window to save */
   var_list1[0].var            = WIN_NO;
   var_list1[0].var_ptr        = (IGRchar *)&me->win_no;
   var_list1[0].num_bytes      = sizeof( IGRint );
   var_list1[0].bytes_returned = &ret_bytes;      
   var_list1[1].var            = END_PARAM;

   dp$inq_set_gragad( msg          = &msg,
                      inq0_set1    = 0,
                      osnum        = me->win_ids[0].osnum,
                      gragad_objid = me->win_ids[0].objid,
                      which_error  = &which_error,
                      var_list     = var_list1 );

   /* get that windows context. It is necessary to get the window's context  */
   /* rather than the screen's context, because we may have indexed/8 bit    */
   /* windows on a machine that is true color. ( i.e raster hidden line, NC, */
   /* and FEM all create/convert windows to 8-bit when on true color machines*/
   WLget_window_base_context( me->win_no, &me->context_no);

   if ( me->using_fence )
   {
      xl = me->bound_pts[0];
      yl = me->bound_pts[1];

      dx = me->bound_pts[3] - xl + 1;
      dy = me->bound_pts[4] - yl + 1;
   }
   else
   {
      WLget_window_bounds( me->win_no, &dummy, &win_attr );
      WLflush( me->win_no);
      xl = 0;
      yl = 0;
      dx = win_attr.width;
      dy = win_attr.height;
   }

   ex$message ( msgnumb = HS_I_SavingImg, buff = buffer );
   HSinit_heartbeat( buffer );

   WLhide_cursor( me->win_no, 0 );
   WLflush( me->win_no );

#if DEBUG
   fprintf( stderr, "xl = %d\tyl = %d\tdx (delta_x) = %d\tdy (delta_y) = %d\n",
            xl, yl, dx, dy );
#endif
   status = HScapture_image( me->filename, 
                             xl,
                             yl,
                             dx,
                             dy,
                             me->win_no,
                             me->context_no );

   WLshow_cursor( me->win_no );
   WLflush( me->win_no );

   if ( status == 1 )
   {
      HSfile_error(status);
   }
   else if( status == 2 )
   {
      ex$message( msgnumb = HS_E_InvWindow );
   }
   else
   {
      ex$message( msgnumb = HS_I_ImgSaved );
      sleep( 3 );
      ex$message( in_buff = "", field = ERROR_FIELD );
   }
   return( OM_S_SUCCESS );

quit:
  return OM_S_SUCCESS;
}

method establish_window ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   struct var_list        var_list1[2];
   IGRlong                which_error;
   IGRlong                msg;
   IGRlong                ret_bytes;
   IGRint                 x_dits;
   IGRint                 y_dits;
   int                    ignore_true_color=TRUE;
   IGRuint                flags = 0;
   WLuint16               lscreen_no;
   int                    type_of_screen;
   WLuint32               context_no;
   struct WLcontext_info  context_info;
#ifdef X11
   XEvent               report;
   Display              *win_display;
   struct WLnative_info native_info;

   /* If we are on a machine that runs X, we need to get the display from */
   /* the native_info structure                                           */

   WLget_native_info( me->win_no, me->context_no, &native_info );
   win_display = native_info.display;
#endif


   /* determine mode of operation ( true_color or indexed ) */
   WLget_active_screen( &lscreen_no, &type_of_screen );
   CMget_active_context( lscreen_no, &context_no );
   WLget_context_info( context_no, &context_info );

   if( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      /* true color machine */
      hs$get_shading_flags( save_image_flags = &flags );
      if (flags & HS_SAVE_IMAGE_8BIT)
      {
         ignore_true_color = TRUE;
         me->converted_win = TRUE;
      }
      else
      {
         ignore_true_color = FALSE;
         me->converted_win = FALSE;
      }
   }

   if ( me->win_to_use == USE_FULL_SCREEN )
   {
      if( !me->win_no )
      {
         HSinit_full_screen_window( &me->context_no,
                                    &me->win_no,
                                    &x_dits,
                                    &y_dits,
                                    ignore_true_color );
      }
   } 
   else 
   {
      if( !me->win_no )
      {
         var_list1[0].var             = WIN_NO;
         var_list1[0].var_ptr         = (IGRchar *)&me->win_no;
         var_list1[0].num_bytes       = sizeof( IGRint );
         var_list1[0].bytes_returned  = &ret_bytes;
         var_list1[1].var             = END_PARAM;

         dp$inq_set_gragad( msg          = &msg,
                            inq0_set1    = 0,
                            osnum        = me->win_ids[0].osnum,
                            gragad_objid = me->win_ids[0].objid,
                            which_error  = &which_error,
                            var_list     = var_list1);

         me->context_no = context_no;

         /* If machine is true color and 8-bit mode is selected, convert */
         /* window                                                       */

         /*---------------------------------------------------------------
          *
          *  If the platform is XGL, then don't convert the window to 8bit
          *  for any reason.  The XGL allows us to display 8bit raster
          *  data in a 24bit window.  There's a good reason.  (Mike 1/11/96)
          *
          */

#        if ! defined (XGL)

         if( ( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR ) &&
             ( ignore_true_color == TRUE ) )
         {
            HSconvert_to_indexed_context( me->win_no,
                                          me->win_ids[0].objid,
                                          me->win_ids[0].osnum );

            /* need to make sure we have the proper window and context number */
            /* after the conversion                                           */

            var_list1[0].var             = WIN_NO;
            var_list1[0].var_ptr         = (IGRchar *)&me->win_no;
            var_list1[0].num_bytes       = sizeof( IGRint );
            var_list1[0].bytes_returned  = &ret_bytes;
            var_list1[1].var             = END_PARAM;

            dp$inq_set_gragad( msg          = &msg,
                               inq0_set1    = 0,
                               osnum        = me->win_ids[0].osnum,
                               gragad_objid = me->win_ids[0].objid,
                               which_error  = &which_error,
                               var_list     = var_list1);

            WLget_window_base_context( me->win_no, &me->context_no);         

#           ifdef X11
            /* Get the native info */
            WLget_native_info( me->win_no, me->context_no, &native_info );

            /* need to read any events off the event queue if on X */
            JNL_XWindowEvent( native_info.display,
                              native_info.base_win,
                              StructureNotifyMask,
                              &report );
#        endif /* X11 */
         }
#     endif /* XGL */
      }
   }
quit:
  return OM_S_SUCCESS;
}

method fill_buffers ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   char                   buffer[100];
   int                    start_msg;
   IGRint                 true_color=FALSE;
   struct WLcontext_info  context_info;

   WLget_context_info( me->context_no, &context_info ); 
   if( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      /* true color machine */
      true_color = TRUE;
   }

   if ( me->animate )
   {
      start_msg = HS_I_RdCvtAnim;
   }
   else
   {
      start_msg = HS_I_RdCvtDspl;
   }

   ex$message( in_buff = "", field = PROMPT_FIELD );
   ex$message( msgnumb = start_msg, buff = buffer );

   HSinit_heartbeat( buffer );

   WLclear_window( me->win_no );
   WLflush( me->win_no );

   if( me->animate || me->SingleFrame )
   {
      if( me->SingleFrame )
      {
         WLclear_window( me->win_no );
      }
      if ( me->using_fence )
      {
         /* buffers are already filled, set status to 0 */
         status = 0;
      }
      else
      {
         if ( true_color )
         {
            status = HSread_rle_files(  me->win_no,
                                        me->context_no,
                                        me->filename,
                                        me->planes,
                                        me->animate,
                                        me->scale_factor,
                                        me->delay,
                                        me->FrameDelay[me->animate],
                                        me->x,
                                        me->y,
                                        me->phong_flag,
                                        (me->Optimize==DO_24_BIT) ||
                                            me->SingleFrame,
                                        me->WindowErase,
                                        me->ct_to_use );
         }
         else
         {
            status = HSread_rle_files(  me->win_no, 
                                        me->context_no,
                                        me->filename,
                                        me->planes,
                                        me->animate,
                                        me->scale_factor,
                                        me->delay,
                                        me->FrameDelay[me->animate],
                                        me->x,
                                        me->y,
                                        me->phong_flag,
                                        (me->Optimize==SPEED) ||
                                         me->SingleFrame,
                                        me->WindowErase,
                                        me->ct_to_use );
         }
      }
      if( (me->animate ) && (status != QUIT) )
      {
         /* buffers filled */
         me->using_fence = TRUE;
      }
      else
      {
         /* exit hit during buffer filling sequence */
         me->using_fence = FALSE;
      }
   } 
   else
   {
      status = HSslide_show(  me->win_no,
                              me->context_no,
                              me->filename,
                              me->cycle, 
                              me->planes,
                              me->scale_factor,
                              me->delay, 
                              me->FrameDelay[me->animate], 
                              me->CycleDelay[me->animate],
                              me->phong_flag,
                              me->WindowErase,
                              me->ct_to_use);
      if( status == DO_FORM )
      {
         me->do_form = TRUE;
      }

      me->using_fence = FALSE;
   }

   if( status && ( status != QUIT ) && ( status != DO_FORM ) )
   {
      HSfile_error( status );
   }

   *sts = status;

quit:
  return OM_S_SUCCESS;
}

method check_data ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   if( me->do_form )
   {
      *sts = DO_FORM;
   }
   else if( me->get_window )
   {
      if( me->SingleFrame )
      {
         if( me->win_to_use == USE_EXISTING )
         {
            *sts = SINGLE_EXIST;
         }
         else
         {
            *sts = SINGLE_NEW;
         }
      }
      else
      {
         if( me->win_to_use == USE_EXISTING )
         {
            *sts = MULT_EXIST;
         }
         else
         {
            *sts = MULT_NEW;
         }
      }
   }
   else
   {
      *sts = 0;
   }
quit:
  return OM_S_SUCCESS;
}

method animate ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   int                    success_msg;
   IGRint                 true_color=FALSE;
   struct WLcontext_info  context_info;

   if( (me->animate ) && (me->using_fence) )
   {
     /* animation sequence and buffers are filled */
      WLget_context_info( me->context_no, &context_info );
      if( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
      {
         /* true color machine */
         true_color = TRUE;
      }

      *sts = HSrapid_display(  me->win_no,
                               me->context_no,
                               me->planes,
                               me->animate,
                               me->delay,
                               me->cycle,
                               me->FrameDelay[me->animate], 
                               me->CycleDelay[me->animate], 
                               (me->Optimize == DO_24_BIT),
                               (me->Optimize==SPEED),
                               me->WindowErase,
                               FALSE);

      if( *sts == DO_FORM )
      {
         me->do_form = TRUE;
      }
      else
      {
         me->do_form = FALSE;

         /* Free the buffers */
         if (true_color)
         {
            if( (me->animate) || (me->Optimize == DO_8_BIT) || (me->cycle) )
            {
               HSfree_buffers( (me->Optimize == DO_24_BIT) && ( me->animate ) );
            }
         }
         else
         {
            if( (me->animate) || (me->Optimize == APPEARANCE) || (me->cycle) )
            {
               HSfree_buffers( (me->Optimize == SPEED) && ( me->animate ) );
            }
         }

         /* This piece of instance data will be used as 'buffer_filled' */
         /*                       for displaying                        */
         me->using_fence = FALSE;

         success_msg = HS_I_ImgAnimated;
         ex$message( msgnumb = success_msg );
         sleep( 3 );
         ex$message( in_buff = "", field = ERROR_FIELD );
      }
   }
   else if( me->animate )
   {
      /* buffers need to be freed if partially filled */
      if (true_color)
      {
         if( (me->animate) || (me->Optimize == DO_8_BIT) || (me->cycle) )
         {
            HSfree_buffers( (me->Optimize == DO_24_BIT) && ( me->animate ) );
         }
      }
      else
      {
         if( (me->animate) || (me->Optimize == APPEARANCE) || (me->cycle) )
         {
            HSfree_buffers( (me->Optimize == SPEED) && ( me->animate ) );
         }
      }
   }
quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;

   IGRint                 success_msg;
   IGRlong                msg;
   char                   string[6];
   double                 delay;
   int                    sel_flag;
   int                    r_pos;
   int                    Row;
   int                    depth;

   WLuint16               lscreen_no;
   int                    type_of_screen;
   WLuint32               context_no;
   struct WLcontext_info  context_info;
   int                    true_color = FALSE;

   switch( gadget_label )
   {
      case CLEAR_WINDOW:
         me->WindowErase = (me->WindowErase) ? FALSE : TRUE;
         break;

      case SPEED_BUTTON:
         me->Optimize = SPEED;
         break;

      case APPEARANCE_BUTTON:
         me->Optimize = APPEARANCE;
         break;

      case DISP_8_BIT:
         me->Optimize = DO_8_BIT;
         me->planes = 8;
#if DEBUG
         fprintf(stderr, "*** number of planes in FORM_NOT = %d\n", me->planes);
#endif

#if defined(OPENGL)
         me->win_to_use = USE_EXISTING;
         FIg_set_state_on( form_ptr, EXISTING_WIN);
         FIg_disable(form_ptr, WINDOW_USE_GROUP);
#endif
         break;

      case DISP_24_BIT:
         me->Optimize =  DO_24_BIT;
#if DEBUG
         fprintf(stderr, "*** number of planes in FORM_NOT = %d\n", me->planes);
#endif
         break;

      case SCALE_FIELD:
         FIfld_get_active_row( form_ptr, SCALE_FIELD, &Row, &r_pos );
         me->scale_factor = 1;
         switch( Row )
         {
         case 0:
            me->scale_factor = 4;
            break;
         case 1:
            me->scale_factor = 8;
            break;
         case 2:
            me->scale_factor = 16;
            break;
         case 3:
            me->scale_factor = 0;
            break;
         case 4:
            me->scale_factor = 1;
            break;
         case 5:
            me->scale_factor = 2;
            break;
         }
         break;

      case SLIDESHOW:
         me->animate = FALSE;

         FIg_disable(form_ptr, RGB_DISPLAY_GROUP);

         FIg_set_state_off( form_ptr, FRAME_DELAY_GROUP );

#if defined(OPENGL)
         /* force SGI to use existing windows if displaying indexed files */
         if( !me->phong_flag )
         {
            me->win_to_use = USE_EXISTING;
            FIg_set_state_on( form_ptr, EXISTING_WIN);
            FIg_disable(form_ptr, WINDOW_USE_GROUP);
         }
#endif
         if( me->delay )
         {
            FIg_set_value( form_ptr, FRAME_DELAY, me->FrameDelay[me->animate] );
         }

         if( me->cycle )
         {
            FIg_set_value( form_ptr, CYCLE_DELAY, me->CycleDelay[me->animate] );
         }
         break;

      case ANIMATION:
         me->animate = TRUE;
         FIg_set_state_on( form_ptr, FRAME_DELAY_GROUP );

         if( me->delay )
         {
            FIg_set_value( form_ptr, FRAME_DELAY, me->FrameDelay[me->animate] );
         }

         if( me->cycle )
         {
            FIg_set_value( form_ptr, CYCLE_DELAY, me->CycleDelay[me->animate] );
         }

         /* need to set the mode for image display - 8 or 24 bit - on true color machines */
         /* determine screen depth and type of machine */
         WLget_active_screen( &lscreen_no, &type_of_screen );
         CMget_active_context( lscreen_no, &context_no );
         WLget_context_info( context_no, &context_info );

         if( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
         {
            /* true color machine */
            true_color = TRUE;
         }

         if (true_color)
         {
            if( me->using_fence || !me->phong_flag )
            {
               /* if 'buffers_filled' or files are an indexed type */
               FIg_disable(form_ptr, RGB_DISPLAY_GROUP);
#if defined( OPENGL)
               /*
                  at this time, disable window choice group when in indexed
                  mode and on SGI.
               */
               if( !me->phong_flag )
               {
                  FIg_disable( form_ptr, WINDOW_USE_GROUP);
                  me->win_to_use = USE_EXISTING;
               }
#endif
            }
            else
            {
               FIg_enable( form_ptr, RGB_DISPLAY_GROUP );
            }

            if (me->Optimize == DO_24_BIT)
            {
               FIg_set_state_on(form_ptr, DISP_24_BIT );
            }
            else
            {
               FIg_set_state_on(form_ptr, DISP_8_BIT );

#if defined( OPENGL)
               FIg_disable( form_ptr, WINDOW_USE_GROUP);
               me->win_to_use = USE_EXISTING;
#endif
            }
         }
         break;

      case SINGLE_STEP:
         me->delay = FALSE;
         FIg_erase( form_ptr, FRAME_DELAY_GROUP );
         FIg_erase( form_ptr, CYCLE_DELAY_GROUP );
         FIg_erase( form_ptr, CYCLE );
         break;

      case TIME_DELAY:
         me->delay = TRUE;

         FIg_display( form_ptr, FRAME_DELAY_GROUP );
         FIg_set_value( form_ptr, FRAME_DELAY, me->FrameDelay[me->animate] );
         if( me->cycle )
         {
            FIg_display( form_ptr, CYCLE_DELAY_GROUP );
            FIg_set_value( form_ptr, CYCLE_DELAY, me->CycleDelay[me->animate] );
         }
         else
         {
            FIg_erase( form_ptr, CYCLE_DELAY_GROUP );
         }
         break;

      case CYCLE:
         me->cycle = ( ( me->cycle ) ? FALSE : TRUE );
         if( me->cycle && me->delay )
         {
            FIg_display( form_ptr, CYCLE_DELAY_GROUP );
            FIg_set_value( form_ptr, CYCLE_DELAY, me->CycleDelay[me->animate] );
         }
         else
         {
            FIg_erase( form_ptr, CYCLE_DELAY_GROUP );
         }
         break;

      case FRAME_DELAY:
         FIfld_get_text( form_ptr, FRAME_DELAY, 0, 0, 10, string, &sel_flag, 
                         &r_pos );
         sscanf( string, "%lf", &delay );
         if( delay >= 0.0 )
         {
            me->FrameDelay[me->animate] = delay;
         }
         else
         {
            FIg_set_value( form_ptr, FRAME_DELAY, me->CycleDelay[me->animate] );
         }
         break;

      case CYCLE_DELAY:
         FIfld_get_text( form_ptr, CYCLE_DELAY, 0, 0, 10, string, &sel_flag,
                         &r_pos );
         sscanf( string, "%lf", &delay );
         if( delay >= 0.0 )
         {
            me->CycleDelay[me->animate] = delay;
         }
         else
         {
            FIg_set_value( form_ptr, CYCLE_DELAY, me->CycleDelay[me->animate] );
         }
         break;

      case WINDOW_CT:
         me->ct_to_use = USE_WINDOW_CT;
         break;

      case FILE_CT:
         me->ct_to_use = USE_FILES_CT;
         break;

      case FULL_SCREEN_WIN:
         me->win_to_use = USE_FULL_SCREEN;
         break;

      case EXISTING_WIN:
         me->win_to_use = USE_EXISTING;
         break;

      case CANCEL:
         FIg_set_state_off( form_ptr, CANCEL );
         (void)FIf_erase( form_ptr );

         if( me->using_fence )
         {
            /* Free the buffers */
            if( me->animate || (me->Optimize == APPEARANCE) || me->cycle )
            {
               HSfree_buffers( ( (me->Optimize == SPEED) || me->animate ) );
            }

            /* This piece of instance data will be used as 'buffer_filled' */
            /*                     for displaying                          */

            me->using_fence = FALSE;
         }

         success_msg = HS_I_ImgAnimated;

         me->get_window = FALSE;
         me->do_form  = FALSE;

         ex$message( msgnumb = success_msg );
         sleep( 3 );
         ex$message( in_buff = "", field = ERROR_FIELD );

         _move_on;
         break;

      case RUN:
         FIg_set_state_off( form_ptr, RUN );
         (void)FIf_erase( form_ptr );
         status = om$send( targetid = my_id,
                            msg     = message HSanimate.save_form_data( &msg ));
         me->get_window = TRUE;
         _move_on;
         break;

      default:
         break;
   }
quit:
  return OM_S_SUCCESS;
}

method restore_colors ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   if( me->context_no != WL_DEFAULT_CONTEXT )
   {
      if( me->mytype == DISPLAY )
      {
         ige$configure_color_table( context_no = me->context_no );
      }
   }
quit:
  return OM_S_SUCCESS;
}

method process_fence_pt ( IGRint *sts; IGRint which_pt )
{
  int		  status = OM_S_SUCCESS;

   struct var_list  var_list1[3];
   IGRlong          num_pts;
   IGRlong          which_error;
   IGRlong          msg;
   IGRlong          ret_bytes;
   IGRshort         matrix_type;
   IGRdouble        rotation[4][4];
   IGRdouble        temp;


   *sts = OM_S_SUCCESS;

   if ( which_pt == 0 )
   {
      /* first fence point => save it and the window it is in */
      me->bound_pts[0] = me->event1.event.button.x;
      me->bound_pts[1] = me->event1.event.button.y;
      me->bound_pts[2] = me->event1.event.button.z;

      me->num_win_ids = 1;
      me->win_ids[0].objid = me->event1.event.button.objid;
      me->win_ids[0].osnum = me->event1.event.button.osnum;
   }
   else
   {
      /* second fence point => save it and transform both to the viewport (dits) */
      me->bound_pts[3] = me->event1.event.button.x;
      me->bound_pts[4] = me->event1.event.button.y;
      me->bound_pts[5] = me->event1.event.button.z;

      var_list1[0].var            = WLD_TO_VIEWPORT;
      var_list1[0].var_ptr        = (IGRchar *) rotation;
      var_list1[0].num_bytes      = 16 * sizeof(IGRdouble);
      var_list1[0].bytes_returned = &ret_bytes;      
                  
      var_list1[1].var = END_PARAM;

      dp$inq_set_gragad( msg          = &msg,
                         inq0_set1    = 0, 
                         osnum        = me->win_ids[0].osnum,
                         gragad_objid = me->win_ids[0].objid,
                         which_error  = &which_error,
                         var_list     = var_list1 );

      num_pts = 2;
      MAtypemx( &msg, rotation, &matrix_type );
      MAoptsxform( &msg, &num_pts, &matrix_type, rotation, me->bound_pts,
                   me->bound_pts );

#if DEBUG
      fprintf(stderr,"transformed %lf %lf %lf %lf\n", me->bound_pts[0],
         me->bound_pts[1], me->bound_pts[3], me->bound_pts[4] );
#endif

      /* order min,max x and y */
      if ( me->bound_pts[1] > me->bound_pts[4] )
      {
         temp = me->bound_pts[4];
         me->bound_pts[4] = me->bound_pts[1];
         me->bound_pts[1] = temp;
      }

      if ( me->bound_pts[0] > me->bound_pts[3] )
      {  
         temp = me->bound_pts[3];
         me->bound_pts[3] = me->bound_pts[0];
         me->bound_pts[0] = temp;
      }                
   }  /* end: else */
quit:
  return OM_S_SUCCESS;
}

method dynamics ( int dynamics ; int * sts )
{
  int		  status = OM_S_SUCCESS;

   struct GRevent *dyn_events[2];

   switch ( dynamics )
   {

      case FENCE_DYN :
         dyn_events[0] = &me->event1;
         dyn_events[1] = &me->my_event;

         DYrbblock( dyn_events, &me->ActiveDisplay );
         break;

      default :
         *sts = om$send( mode     = OM_e_wrt_message,
                         msg      = message CEO_LOCATE.dynamics( dynamics, 
                                                                 sts ),
                         targetid = my_id );

      }  /* end: switch */

quit:
  return OM_S_SUCCESS;
}

method delete_window ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   WLclear_window( me->win_no );

   HSdelete_full_screen_window( me->win_no );
   me->win_no = 0;
   *sts = OM_S_SUCCESS;

quit:
  return OM_S_SUCCESS;
}

method save_form_data ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRuint                flags = 0;
   IGRint                 true_color = FALSE;
   struct WLcontext_info  context_info;
   int                    type_of_screen;
   WLuint16               lscreen_no;
   WLuint32               context_no;

   /* determine machine and mode */
   WLget_active_screen( &lscreen_no, &type_of_screen );
   CMget_active_context( lscreen_no, &context_no );
   WLget_context_info( context_no, &context_info );

   if( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      /* true color machine */
      true_color = TRUE;
   }

   hs$get_shading_flags( save_image_flags = &flags);

   /* Make sure that the flags set in get_num_frames for the single frame */
   /* mode are not saved                                                  */ 
   if( !me->SingleFrame )
   {
      if ( me->animate )
      {
         flags = flags | HS_DIS_IMAGE_SLIDE;
      }
      else
      {
         flags = flags & ~HS_DIS_IMAGE_SLIDE;
      }

      if ( me->cycle )
      {
         flags = flags & ~HS_DIS_IMAGE_CYCLE;
      }
      else
      {
         flags = flags | HS_DIS_IMAGE_CYCLE;
      }

      if ( me->delay )
      {
         flags = flags & ~HS_DIS_IMAGE_DELAY;
      }
      else
      {
         flags = flags | HS_DIS_IMAGE_DELAY;
      }

      if ( !me->WindowErase )
      {
         flags = flags | HS_DIS_IMAGE_CLEAR;
      }
      else
      {
         flags = flags & ~HS_DIS_IMAGE_CLEAR;
      }

      if ( true_color )
      {
         if ( me->Optimize == DO_8_BIT )
         {
            flags = flags | HS_SAVE_IMAGE_8BIT;
         }
         else
         {
            flags = flags & ~HS_SAVE_IMAGE_8BIT;
         }
      }
      else
      {
         if ( me->Optimize == SPEED )
         {
            flags = flags & ~HS_DIS_IMAGE_SPEED;
         }
         else
         {
            flags = flags | HS_DIS_IMAGE_SPEED;
         }
      }

      flags = flags & ~HS_DIS_IMAGE_SCALE;   /* clear scaling flags for */
                                             /* value reassignment      */
      if( me->scale_factor == 4 )
      {
         flags = HS_DIS_IMAGE_SCALE_ONE | flags;
      }
      else if( me->scale_factor == 8 )
      {
         flags = HS_DIS_IMAGE_SCALE_TWO | flags;
      }
      else if( me->scale_factor == 16 )
      {
         flags = HS_DIS_IMAGE_SCALE_FOUR | flags;
      }
      else if( me->scale_factor == 1 )
      {
         flags = HS_DIS_IMAGE_SCALE_ONE_QUARTER | flags;
      }
      else if( me->scale_factor == 2 )
      {
         flags = HS_DIS_IMAGE_SCALE_ONE_HALF | flags;
      }
      else if( me->scale_factor == 0 )
      {
         flags = HS_DIS_IMAGE_SCALE_ONE_EIGHTH | flags;
      }

      /* set the delay values */
      hs$set_display_image_delays(cycle_delays = me->CycleDelay,
                                  frame_delays = me->FrameDelay);

   }

   if ( me->win_to_use )
   {
      flags = flags | HS_DIS_IMAGE_NEW_WIN;
   }
   else
   {
      flags = flags & ~HS_DIS_IMAGE_NEW_WIN;
   }

   if ( me->ct_to_use )
   {
      flags = flags | HS_DIS_IMAGE_FILE_CT;
   }
   else
   {
      flags = flags & ~HS_DIS_IMAGE_FILE_CT;
   }

   hs$put_shading_flags( save_image_flags = &flags);

quit:
  return OM_S_SUCCESS;
}

method check_window ( long * sts )
{
  int		  status = OM_S_SUCCESS;


   if( !me->win_no )
   {
      *sts = GET_A_WINDOW;
   }
   else
   {
      *sts = 0;
WLflush( me->win_no);
   }
quit:
  return OM_S_SUCCESS;
}

method erase_window ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   int   msg;

   if(me->converted_win)
   {
      HSrestore_window_context( me->win_no,
                                me->win_ids[0].objid,
                                me->win_ids[0].osnum);
   }

   WLclear_window( me->win_no );
   WLflush( me->win_no );

   IGEresetstop();

   dp$gen_update( msg   = &msg,
                  osnum = me->win_ids[0].osnum,
                  objid = me->win_ids[0].objid);

   ex$message( msgnumb = EMS_I_ClearStatusField );

quit:
  return OM_S_SUCCESS;
}

method check_window_flags ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   if ( me->win_to_use == USE_EXISTING )
   {
      *sts = USE_EXIST;
   }
   else
   {
      *sts = USE_FULL;
   }
quit:
  return OM_S_SUCCESS;
}

method check_if_selected ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   WLuint16               lscreen_no;
   int                    type_of_screen;
   struct WLcontext_info  context_info;

   if ( !me->win_no )
   {
      /* To call restore_colors in the terminate function, a context needs to */
      /* be defined in the me->context_no field                               */

      WLget_active_screen( &lscreen_no, &type_of_screen );
      CMget_active_context( lscreen_no, &me->context_no );

      *sts = NO_WIN_EXIT;
   }
   else
   {
      /* check type of machine and what mode */
      WLget_context_info( me->context_no, &context_info );

      if( ( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR) &&
          (me->Optimize == DO_8_BIT ) )
      {
         /* need to convert window back to a 24 bit context */
         HSrestore_window_context( me->win_no,
                                   me->win_ids[0].objid,
                                   me->win_ids[0].osnum );

      }

      *sts = WIN_EXIT;
   }
quit:
  return OM_S_SUCCESS;
}

end implementation HSanimate;
