
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $
*/

/*
   This file defines and implements the following commands:

              Save Image, Display Image

   The command table entries for the commands should be:

             "Save Image", HSSvIm, HSanimate, 0
             "Display Image", HSDsIm, HSanimate, 1
*/
class              HSanimate
super_class        HSwindow
command_string     HSM_M_SaveImg,0,HSSvIm
synonym            HSM_M_DisplayImg,1,HSDsIm
form               "HSDisplImage",0,0,0,0
product_name       "$MODEL"
start_state        start

specification

instance
{
   struct GRevent  my_event;
   IGRchar         filename[200];
   IGRdouble       bound_pts[6];
   IGRint          planes;
   IGRboolean      using_fence;  /* Doubles as indicator of whether buffers */
                                 /* need filling                            */
   IGRint          phong_flag;
   IGRint          x_pixels;
   IGRint          y_pixels;
   IGRint          scale_factor;
   WLuint32        win_no;
   IGRint          x;
   IGRint          y;
   IGRint          do_form;
   IGRint          animate;
   IGRint          delay;
   IGRint          cycle;
   IGRdouble       FrameDelay[2];
   IGRdouble       CycleDelay[2];
   IGRint          WindowErase;
   IGRint          Optimize;     /* Doubles as indicator of display type for */
                                 /* edgeII                                   */
   IGRint          SingleFrame;
   WLuint32        context_no;
   IGRint          get_window;
   IGRint          win_to_use;
   IGRint          ct_to_use;
   IGRint          converted_win;
}

implementation

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

state_table

#ifndef ENV5
#include <tools.h>
#endif
#include "hsmsg.h"

#define SAVE                 0
#define DISPLAY              1

#define QUIT                 3
#define PHONG_FILE           4
#define NO_ACTION            5
#define FULL_SCREEN          6

#define OLD_FILES            4000
#define GET_A_WINDOW         4001
#define GET_A_BOUNDARY       4002
#define GET_A_FENCE          4003
#define VALIDATE_OVERWRITE   4004
#define GET_SCALE_FACTOR     4005
#define INVALID_SCALE_FACTOR 4006
#define NOT_ENOUGH_PLANES    4007

#define MULT_EXIST           4008
#define MULT_NEW             4009
#define SINGLE_EXIST         4010
#define SINGLE_NEW           4011

#define USE_EXIST            4012
#define USE_FULL             4013

#define WIN_EXIT             4014
#define NO_WIN_EXIT          4015

#define SINGLE_FRAME         0
#define MULTIPLE_FRAMES      1

#define FENCE_DYN            2112

#define FALSE                0
#define TRUE                 1

#define DO_FORM              2

#define LEFT_BUTTON          0
#define MIDDLE_BUTTON        1
#define RIGHT_BUTTON         2


from HSgragad  import HSgg_construct;

at init
   do initialize_instance_data

at sleep
   do restore_colors

state *         /* default transitions for all states */
   on EX_RJT_MOVEON state .
   on EX_RESTART    state start
   on EX_BACK_UP    state -

state start
   on CMD_TYPE = 0 or CMD_TYPE = 1
      state get_filename
   on ELSE
      state terminate

state zoom
prompt_key HS_P_InterpolatedZoom
execute wait_for_button

   on RETURN_CODE = RIGHT_BUTTON or RETURN_CODE = LEFT_BUTTON or 
                      RETURN_CODE = MIDDLE_BUTTON
      do establish_window
      do fill_buffers
         on RETURN_CODE = 0
            state .
         on ELSE
            do erase_window
            do restore_colors
            state terminate
      state .
   on RETURN_CODE = FULL_SCREEN
      do delete_window
      state terminate
   on RETURN_CODE = NO_ACTION
      state .
   on RETURN_CODE = QUIT
      do erase_window
      do restore_colors
      state terminate
   on ELSE
      state terminate

state form_display
prompt ""
execute init_form_display
display_form   0
filter wfi

   on MOVE_ON
      do check_data
         on RETURN_CODE = DO_FORM
            state .
         on RETURN_CODE = MULT_EXIST
            state determine_window
         on RETURN_CODE = MULT_NEW
            do establish_window
            do fill_buffers
            do animate
            do check_data
               on RETURN_CODE = DO_FORM
                  state .
               on RETURN_CODE = 0 or RETURN_CODE = QUIT
                  do delete_window
                  state terminate
               on ELSE
                  do delete_window
                  state terminate
            state .
         on RETURN_CODE = SINGLE_EXIST
            state determine_window
         on RETURN_CODE = SINGLE_NEW
            do establish_window
            do fill_buffers
               on RETURN_CODE = 0
                  state zoom
               on RETURN_CODE = QUIT
                  do delete_window
                  state terminate
               on ELSE
                  state .
            state .
         on RETURN_CODE = 0
            do check_if_selected
               on RETURN_CODE = WIN_EXIT
                  do check_window_flags
                     on RETURN_CODE = USE_EXIST
                        do erase_window
                        do restore_colors
                        state terminate
                     on ELSE
                        do delete_window
                        state terminate
                  state .
               on RETURN_CODE = NO_WIN_EXIT
                  state terminate
            state .
         on ELSE
            state .
      state.    

state get_filename
execute load_cmd_name_message
execute load_filename_prompt
filter  get_event

   on EX_STRING
      do process_filename_keyin
         on RETURN_CODE = OLD_FILES
            do get_num_frames
            state form_display
         on RETURN_CODE = VALIDATE_OVERWRITE
            state validate_filename
         on RETURN_CODE = GET_A_BOUNDARY
            state get_boundary
         on ELSE
            state .
      state .

state validate_filename
prompt_key HS_P_Overwrite
filter     get_event

   on EX_STRING
      do process_overwrite_keyin
         on SUCCESS
            state get_boundary
         on ELSE
            state get_filename
      state .

   on EX_RJT_MOVEON
      state get_boundary

state get_boundary
prompt_key HS_P_SaveWinOrFence
filter     get_event

   on EX_STRING
      do process_boundary_keyin
         on RETURN_CODE = GET_A_WINDOW
            state get_window
         on RETURN_CODE = GET_A_FENCE
            state get_fence_pt1
      state .

   on EX_RJT_MOVEON
      state get_window

state determine_window
execute check_window

   on RETURN_CODE = GET_A_WINDOW
      state get_window
   on ELSE
      state load_frames

state load_frames
execute get_num_frames

   on RETURN_CODE = MULTIPLE_FRAMES
      do establish_window
      do fill_buffers
      do animate
      do check_data
         on RETURN_CODE = DO_FORM
            state form_display
         on RETURN_CODE = 0 or RETURN_CODE = QUIT
            do erase_window
            do restore_colors
            state terminate
         on ELSE
            do erase_window
            do restore_colors
            state terminate
      state .
   on RETURN_CODE = SINGLE_FRAME
      do establish_window
      do fill_buffers
         on RETURN_CODE = 0
            state zoom
         on RETURN_CODE = QUIT
            do erase_window
            do restore_colors
            state terminate
         on ELSE
            do erase_window
            do restore_colors
            state terminate
      state .
   on ELSE
      state terminate

state get_window
execute load_window_prompt
filter  get_event

   on EX_STRING or EX_DATA
      do get_selected_window( sts, 0, 1, 0, 0 )
         on SUCCESS
            on CMD_TYPE = SAVE
               do save_image
               state get_filename
            on CMD_TYPE = DISPLAY
               state load_frames
            on ELSE
               state terminate
            state .
         on ELSE
            state .
      state .
   on ELSE
      state .

state get_fence_pt1
prompt_key HS_P_EnterULLR
filter     get_event

   on EX_DATA
      do process_fence_pt( sts, 0 )
      state get_fence_pt2

state get_fence_pt2
prompt_key HS_P_EnterULLR
dynamics   FENCE_DYN
filter     get_event

   on EX_DATA
      do process_fence_pt( sts, 1 )
      do save_image
      state get_filename

/*--- HSanimate.initialize_instance_data -------------------------------------*/

action initialize_instance_data
/*
NAME
   HSanimate.initialize_instance_data

KEYWORD
   animate

DESCRIPTION
   This function initializes the Ÿdata for setting the gadgets on the 
   Display Image form and for displaying the image if a single frame.

PARAMETERS
   none

GLOBALS USED
   none

FUNCTIONS CALLED
   hs$get_shading_flags   - used to determine settings from previous call.
   WLget_active_screen    - used to determine the active screen number.
   CMget_active_context   - used to get the active context for the screen.
   WLget_context_info     - used to get the context depth of the active screen.


HISTORY
   --/--/-- Created. -???
   01/13/92   Bob Druzynski
      Added ability to set data to previous calls values
*/
{
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

} /* initialize_instance_data */


/*--- HSanimate.init_form_display --------------------------------------------*/

action init_form_display
/*
NAME
   HSanimate.init_form_display

KEYWORD
   animate

DESCRIPTION
   This method initializes the forms "gadgets" for display.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   --/--/-- Created. -???
   01/13/91   Bob Druzynski
      Added new Row value for a 1/8 scale field in me->scale_factor.
*/
{
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

} /* init_form_display */

/*--- HSanimate.load_filename_prompt -----------------------------------------*/

action load_filename_prompt
/*
NAME
   HSanimate.load_filename_prompt

KEYWORD
   animate

DESCRIPTION
   This action loads a file name prompt based on which command is being run

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   --/--/-- Created. -???
*/
{
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

} /* load_filename_prompt */

/*--- HSanimate.load_window_prompt -------------------------------------------*/

action load_window_prompt
/*
NAME
   HSanimate.load_window_prompt

KEYWORD
   animate

DESCRIPTION
   This action loads a window prompt based on which command is being run.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   --/--/-- Created. -???
*/
{
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

} /* load_window_prompt */

/*--- HSanimate.load_cmd_name_message ----------------------------------------*/

action load_cmd_name_message
/*
NAME
   HSanimate.load_cmd_name_message

KEYWORD
   animate

DESCRIPTION
   This action loads a command name prompt based on which command
   is being run.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   --/--/-- Created. -???
*/
{
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

} /* load_cmd_name_message */

/*--- HSanimate.get_num_frames -----------------------------------------------*/

action get_num_frames
/*
NAME 
   HSanimate.get_num_frames

KEYWORD
   animate

DESCRIPTION
   action get_num_frames returns whether the number of frames is single 
   or multiple.
PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   04/11/90 Created. -Trevor Mink
*/
{
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
} /* get_num_frames */

/*--- HSanimate.wait_for_button ----------------------------------------------*/

action wait_for_button
/*
NAME
   HSanimate.wait_for_button

KEYWORD
   animate

DESCRIPTION
   Action wait_for_button prompts the user to "zoom-in" or "zoom_out" 
   then waits for the user to indicate which to do by tapping either the 
   right or left mouse button.  The action sends back a return code that 
   indicates which button was hit.
 
PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   sts - code indicating which button was hit

HISTORY
   04/17/90 Created. -Trevor Mink
   09/03/91 Added X functionality - Bob Druzynski
      
*/
{
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

} /* wait_for_button */

/*--- HSanimate.process_filename_keyin ---------------------------------------*/

action process_filename_keyin
/*
NAME
   HSanimate.process_filename_keyin

KEYWORD
   animate

DESCRIPTION
   This action processes a filename that was keyed in.  The *sts parameter
   is set to the state that should be entered next if a valid filename was
   entered.  Otherwise, *sts is set to OM_W_WARNING and an error message
   is displayed.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   sts - next state to be entered

HISTORY
   --/--/-- Created. -???
   09/03/91 Added X funcionality. -Bob Druzynski
*/
{
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
} /* process_filename_keyin */

/*--- HSanimate.process_overwrite_keyin --------------------------------------*/

action process_overwrite_keyin
/*
NAME
   HSanimate.process_overwrite_keyin

KEYWORD
   animate

DESCRIPTION
   This action processes a response to a file overwrite prompt.  It sets
   *sts to OM_S_SUCCESS if the response was to overwrite the file or
   OM_W_WARNING if the response was to not   overwrite the file.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   sts - OM_S_SUCCESS or OM_W_WARNING

HISTORY
   --/--/-- Created. -???
*/
{
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

}  /* process_overwrite_keyin */

/*--- HSanimate.process_boundary_keyin ---------------------------------------*/

action process_boundary_keyin
/*
NAME
   HSanimate.process_boundary_keyin

KEYWORD
   animate

DESCRIPTION
   This action processes a response to the "Save Window or Fence" prompt.
   If the response was to save an entire window, *sts is set to 
   GET_A_WINDOW.  Otherwise, *sts is set to GET_A_FENCE.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   sts - GET_A_WINDOW or GET_A_FENCE

HISTORY
   --/--/-- Created. -???
*/
{
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
}  /* process_boundary_keyin */

/*--- HSanimate.save_image ---------------------------------------------------*/

action save_image
/*
NAME
   HSanimate.save_image

KEYWORD
   save_image

DESCRIPTION
   This action saves an image.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   --/--/-- Created. -???
   09/03/91   Bob Druzynski
      Added X functionality
*/
{
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

} /* save_image */

/*--- HSanimate.establish_window ---------------------------------------------*/

action establish_window
/*
NAME
   HSanimate.establish_window

KEYWORD
   animate

DESCRIPTION
   This action establishes a window to display the image(s) on.  If the
   object field "win_to_use" is set to USE_FULL_SCREEN, a full screen window
   with the active context is set up.  Otherwise, a window is selected from 
   those on the screen.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   --/--/-- Created. -???
   08/07/91   Bob Druzynski
      Added ability to determine machine and mode of display.
   09/03/91   Bob Druzynski
      Added X functionality.
   05/25/93   Bob Druzynski
      Added check to win_to_use field rather than phong_file field (for 2.4).
*/
{
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
} /* establish_window */

/*--- HSanimate.fill_buffers -------------------------------------------------*/

action fill_buffers
/*
NAME
   HSanimate.fill_buffers

KEYWORD
   animate

DESCRIPTION
   fill_buffers() fills the buffers necessary to do animate/slide-show for
   an image or series of images.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   07/09/90 Adapted from recall_image which this action replaces. -Trevor Mink
   08/09/91   Bob Druzynski
      Added code for 8 or 24 bit display.
   09/03/91   Bob Druzynski
      Added X functionality.
*/
{
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

} /* fill_buffers */

/*--- HSanimate.check_data ---------------------------------------------------*/

action check_data

/*
NAME
   HSanimate.check_data

KEYWORD
   animate

DESCRIPTION
   Check_data returns whether a form should be displayed or not.  It serves
   as transition function for the state table.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   sts - DO_FORM or 0.

HISTORY
   --/--/-- Created. -???
*/
{
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
} /* check_data */

/*--- HSanimate.animate ------------------------------------------------------*/

action animate
/*
NAME
   HSanimate.animate

KEYWORD
   animate

DESCRIPTION
   animate calls a function which does animate/slide-show for the image 
   or series of images already buffered by 'fill_buffers'.
 
PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   07/09/90 Created from recall_images. -Trevor Mink
*/
{
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
} /* animate */

/*--- HSanimate.form_notification --------------------------------------------*/

action form_notification
/*
NAME
   HSanimate.form_notification

KEYWORD
   animate

DESCRIPTION
   This routine is where the Forms Interface sends back data from the user
   hitting a data point on an object on the form. The gadget number is
   returned in the form_data structure.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   see description above

HISTORY
   --/--/-- Created. -???
   01/13/92   Bob Druzynski
      Added state for a 1/8 scale factor and the ability to save 
      changed states of gadgets
*/
{
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
} /* form_notification */

/*--- HSanimate.restore_colors -----------------------------------------------*/

action restore_colors
/*
NAME
   HSanimate.restore_colors

KEYWORD
   animate

DESCRIPTION
   This action restores the EMS color table to its original state after
   an image or series of images has been recalled.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   --/--/-- Created. -???
*/
{
   if( me->context_no != WL_DEFAULT_CONTEXT )
   {
      if( me->mytype == DISPLAY )
      {
         ige$configure_color_table( context_no = me->context_no );
      }
   }
}  /* restore_colors */

/*--- HSanimate.process_fence_pt ---------------------------------------------*/

action process_fence_pt( IGRint *sts; IGRint which_pt )
/*
NAME
   HSanimate.process_fence_pt

KEYWORD
   animate

DESCRIPTION
   This action processes the fence points entered when defining the window
   region to save.  When the second point is entered, the two points are
   transformed to DITS and stored in me->bound_pts.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   see description above

HISTORY
   --/--/-- Created. -???
*/
{
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
}  /* process_fence_pt */

/*--- HSanimate.dynamics -----------------------------------------------------*/

action dynamics
/*
NAME
   HSanimate.dynamics

KEYWORD
   animate

DESCRIPTION
   This action performs the fence rubberbanding.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   --/--/-- Created. -???
*/
{
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

}  /* dynamics */

/*--- HSanimate.delete_window-------------------------------------------*/

action delete_window
/*
NAME
   HSanimate.delete_window

KEYWORD
   animate

DESCRIPTION
   This action deletes a full screen window if one was used to display 
   an image or set of images.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   see description above

HISTORY
   --/--/-- Created. -Trevor Mink
   08/09/91   Bob Druzynski
      Added code determine machine and display mode.
   09/03/91   Bob Druzynski
      Added X functionality.
   05/24/93   Bob Druzynski
      Changed name to delete_window since RGB and indexed files can now use
      full screen windows.  Changed delete call to the new function 
      HSdelete_full_screen_window.
*/
{
   WLclear_window( me->win_no );

   HSdelete_full_screen_window( me->win_no );
   me->win_no = 0;
   *sts = OM_S_SUCCESS;

} /* delete_window */

/*--- HSanimate.save_form_data -----------------------------------------------*/

action save_form_data
/*
NAME
   HSanimate.save_form_data

KEYWORD
   animate

DESCRIPTION
   This action is used to save the parameters set in the Display Image
   form by the user for subsequent calls to Display Image.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   01/08/92 Created. -R. Druzynski
*/
{
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

} /* end save_form_data */

/*---- HSanimate.check_window ----------------------------------------------*/

action check_window

/*
NAME
   HSanimate.check_window

KEYWORD
   animate

DESCRIPTION
   This action serves as a transition function for the state table.  If the
   me->window field is set, then a window does not need to be chosen.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   05/24/93 Created. -R. Druzynski
*/

{

   if( !me->win_no )
   {
      *sts = GET_A_WINDOW;
   }
   else
   {
      *sts = 0;
WLflush( me->win_no);
   }
}

/*---- HSanimate.erase_window ----------------------------------------------*/

action erase_window

/*
NAME
   HSanimate.erase_window

KEYWORD
   animate

DESCRIPTION
   This action is used to erase the window when leaving the Display Image
   command.  It is used mainly as a cosmetic action.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   06/01/93 Created. -R. Druzynski
*/

{
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

}

/*---- HSanimate.check_window_flags -----------------------------------------*/

action check_window_flags

/*
NAME
   HSanimate.check_window_flags

KEYWORD
   animate

DESCRIPTION
   This action is used to determine whether the window used for displaying 
   images is a full screen window or an existing window.  This action is a
   bridge action for the state table.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   06/01/93 Created. -R. Druzynski
*/

{
   if ( me->win_to_use == USE_EXISTING )
   {
      *sts = USE_EXIST;
   }
   else
   {
      *sts = USE_FULL;
   }
}

/*---- HSanimate.check_if_selected -----------------------------------------*/

action check_if_selected

/*
NAME
   HSanimate.check_if_selected

KEYWORD
   animate

DESCRIPTION
   This action is used to determine, on exiting, if a window has been selected
   yet.  This action is a bridge action for the state table.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   06/03/93 Created. -R. Druzynski
*/

{
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
}
