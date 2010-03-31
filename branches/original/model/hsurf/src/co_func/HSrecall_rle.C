
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/times.h>
#include <sys/time.h>
#include <math.h>

#include <FI.h>
#include "wl.h"

/*  KLUDGE: used to define things like LEFT_BUTTON:  should be removed */
#if defined(ENV5)
#else
#include "tools.h"
#endif

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "msdef.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HStl_global.h"

#include "hsdef.h"
#include "hsmsg.h"
#include "hsmacros.h"

#include "msmacros.h"
#include "msdef.h"
#include "exmacros.h"
#include "exdef.h"
#include "hsmachine.h"

#include "hskyoptypes.h"
#include "HSsara.h"

#include "journal.h"

#include "HSpr_co_func.h"

/*-----------------------
 *  for functions
 *    HSgetMachineInfo
 *    HSassign_edgeII_vlt_to_window
 */

#include "hslight.h"
#include "hsurf.h"
#include "HSpr_dpb_imp.h"

/*---------------------------*/



/* HSrecall_rle.C */
extern int  freed_mem;
static int  HSget_mouse_tap (void);
static void HSwait (double);

#define DEBUG                  0
#define DEBUG2                 0
#define SCALE_DEBUG            0
#define DEBUG_50               0

#define LOAD_WINDOW_ERASE      0

#define DO_FORM                2
#define EXIT                   3

#define OUT_OF_MEMORY          1

#define DOUBLE_LEFT_BUTTON     LEFT_BUTTON+3
#define DOUBLE_MIDDLE_BUTTON   MIDDLE_BUTTON+3
#define DOUBLE_RIGHT_BUTTON    RIGHT_BUTTON+3

#define HORIZONTAL             4

/* remove when $EXNUC/include/journal.h has JNL_STOPSIGN defined */
#define JNL_STOPSIGN           7

static int      xOffset;
static int      xMin;
static int      yOffset;
static int      yMin;
static int      xMax;
static int      yMax;
static int      OldScale = 4;

#ifdef X11
extern FILE     *JNL_echo;
#endif

/*--- HSget_put_block_size --------------------------------------------------*/

/*
DESCRIPTION
      This function returns the number of bytes necessary to hold raster data
      for a call to putpixelblock.

PARAMETERS
      xlo,ylo (IN) - Upper left x,y of raster block (x/y origin).
      xhi,yhi (IN) - Lower right x,y of raster block (x/y end).

GLOBALS USED
      none

RETURN VALUES
      Number of bytes needed for the putpixelblock call.

HISTORY
      --/--/-- Created. -???
      04/29/92 Documented. -Trevor Mink

*/

int HSget_put_block_size ( int xlo,
                           int ylo,
                           int xhi,
                           int yhi )

{
   return ((xhi - xlo + 1) * (yhi - ylo + 1));
}   /* HSget_put_block_size */

#ifdef X11

/*--- animate_predproc -----------------------------------------------------*/

/*
DESCRIPTION
      Called by XgetIfEvent to determine if the appropriate event occurred.

PARAMETERS
      display (IN) - Unused.
      event (IN)   - Contains information about latest event.
      arg (IN)     - Unused.

GLOBALS USED
      none

RETURN VALUES
      1 - KeyPress or ButtonPress occurred.
      0 - No KeyPress or ButtonPress occurred.

HISTORY
      --/--/-- Created. -Trevor Mink
      04/29/92 Documented. -Trevor Mink
*/

Bool animate_predproc ( Display *display,
                        XEvent  *event,
                        char    *arg )

{
   switch (event->type)
   {
      case KeyPress:
         return (1);
      case ButtonPress:
         return (1);
      case ConfigureNotify:
      case DestroyNotify:
      case MapNotify:
      case UnmapNotify:
      default:
         return (0);
   }

}   /* animate_predproc */

/*--- HSXget_button_data ---------------------------------------------------*/

/*
NAME
      HSXget_button_data

KEYWORD
      animate

DESCRIPTION
      This is a function that acts as an X equivalent to the Environ V call
      get_button_data.

PARAMETERS
      w_no (OUT)       - Number of window where button event occurred.
      Transition (OUT) - Type of button tap (SINGLE, DOUBLE, DOWN, etc.)
      button (OUT)     - Which button was hit
      x,y (OUT)        - Location in window of cursor when button was hit.

GLOBALS USED
      EX_win[] - X window array

RETURN VALUES
      none

HISTORY
      08/09/91 Created. - R. Druzynski
      12/20/91 Added Output parameters x and y and removed w_no input.
               - Trevor Mink
*/

void HSXget_button_data ( int *w_no,
                          int *Transition,
                          int *button,
                          int *x,
                          int *y )

{
   int                   status = 1;
   XEvent                report;
   unsigned long         prev_time;
   int                   but_state = 0;
   int                   pan_state;
   int                   state;
   int                   i;
   int                   window;
   int                   found;
   WLuint32              win_no;

   WLuint16              lscreen_no;
   int                   screen_type;
   WLuint32              context_no;
   Display               *win_display;
   struct WLnative_info  native_info;

   found = 0;

   /* If we are on a machine that runs X, we need to get the display from */
   /* the native_info structure                                           */

   WLget_active_screen( &lscreen_no, &screen_type );
   CMget_active_context( lscreen_no, &context_no );

   WLget_native_info_from_context( lscreen_no, context_no, &native_info );
   win_display = native_info.display;

   /* check for any button event */
   if( JNL_journal() || JNL_playback())
   {
      JNL_XPeekIfEvent (win_display, &report, animate_predproc, NULL);
   }
   else
   {
      XPeekIfEvent (win_display, &report, animate_predproc, NULL);
   }

   found = WLget_logical_window(report.xbutton.window, &win_no);

   if (found == WL_SUCCESS)
   {
      *w_no = window = win_no;
      GRXget_button_data (window,
                          button,
                          Transition,
                          x,
                          y,
                          &but_state,
                          &pan_state,
                          &state,
                          animate_predproc);
   }
   else
   {
      *button = RIGHT_BUTTON;
      *Transition = DOUBLE_CLICK;
      *w_no = -1;
   }
}

#endif /* X11 */

/*--- HSget_mouse_tap ------------------------------------------------------*/

/*
NAME
      HSget_mouse_tap

KEYWORD
      animate

DESCRIPTION
      This function loops until the user hits a mouse button. When this happens,
      the event is converted to a number from 0 - 5 depending upon both the
      'Transition' and the 'Button' that was hit.

PARAMETERS
      none

GLOBALS USED
      EXdisplay - X display info.

RETURN VALUES
      0 - Single Click/left button
      1 - Single Click/middle button
      2 - Single Click/right button
      3 - Double Click/left button
      4 - Double Click/middle button
      5 - Double Click/right button (or keypress or stopsign)

HISTORY
      07/06/90 Created. -Trevor Mink
      08/09/91 Added X functionality.   -R. Druzynski
      04/29/92 Documented. -Trevor Mink
*/

static int HSget_mouse_tap (void)

{
#ifdef X11
   XEvent                report;
   int                   window = 0;
   int                   x;
   int                   y;
   int                   stop;

   WLuint16              lscreen_no;
   int                   screen_type;
   WLuint32              context_no;
   Display               *win_display;
   struct WLnative_info  native_info;
   Bool                  got_event;
#else
   int                   Mask = 0x00000000;
   int                   UnNeeded;
#endif

   int                   journaling = FALSE;
   int                   playback = FALSE;

   int                   Button = 0;
   int                   Transition = 0;
   int                   event;
   int                   type;
   int                   num_frames=0;

#ifdef X11
   /* If we are on a machine that runs X, we need to get the display from */
   /* the native_info structure                                           */

   WLget_active_screen( &lscreen_no, &screen_type );
   CMget_active_context( lscreen_no, &context_no );

   WLget_native_info_from_context( lscreen_no, context_no, &native_info );
   win_display = native_info.display;
#endif

   if ( JNL_playback() )
   {
      playback = TRUE;
   }
   else if( JNL_journal() )
   {
      journaling = TRUE;
   }

   IGEresetstop();

   while (TRUE)
   {
      if( playback )
      {
#ifndef X11
         JNL_echo_input( 4, (char *)&event );
         if( event == JNL_INFO_EVENT )
         {
            JNL_echo_input( 4, (char *)&type );
            JNL_echo_input( 4, (char *)&num_frames );
            return( DOUBLE_RIGHT_BUTTON );
         }
         else
         {
            JNL_adjust_echo();
         }
#else
         JNL_read_next_event( &report );
         if( (report.type == JNL_INFO_EVENT ) &&
           (report.xany.serial == JNL_WINDOW_CHANGE) )
         {
            num_frames = report.xany.window;
            return( DOUBLE_RIGHT_BUTTON );
         }
         else
         {
            fseek( JNL_echo, -(sizeof(XEvent )), 1);
         }
#endif
      }
      else
      {
         if (IGEstop())
         {
            IGEresetstop();
            if( journaling )
            {
               JNL_record_info_event( JNL_STOPSIGN, 0, (char *)&num_frames );
            }
            return (DOUBLE_RIGHT_BUTTON);
         }
      }

#ifndef X11
      if( journaling || playback )
      {
         JNL_inq_events (&Mask);
      }
      else
      {
         Inq_events( &Mask );
      }

      if(Mask & BUTTON_EVENT)
      {
         if( journaling || playback )
         {
            JNL_get_button_data (&UnNeeded,
                                 &UnNeeded,
                                 &UnNeeded,
                                 &Button,
                                 &Transition,
                                 &UnNeeded);
         }
         else
         {
            Get_button_data (&UnNeeded,
                             &UnNeeded,
                             &UnNeeded,
                             &Button,
                             &Transition,
                             &UnNeeded);
         }

         break;
      }
      else if (Mask & KEYBOARD_EVENT)
      {
         return (DOUBLE_RIGHT_BUTTON);
      }
   }
   return (Button);
#else
      if( journaling || playback )
      {
        got_event =  JNL_XCheckIfEvent( win_display,
                                        &report,
                                        animate_predproc,
                                        NULL);
      }
      else
      {
         got_event = XCheckIfEvent( win_display,
                                    &report,
                                    animate_predproc,
                                    NULL);
      }

      if( got_event )
      {
         XPutBackEvent( win_display, &report );

         if (report.type == ButtonPress)
         {
            HSXget_button_data (&window, &Transition, &Button, &x, &y);
            break;
         }
         else if (report.type == KeyPress)
         {
            return (DOUBLE_RIGHT_BUTTON);
         }
      }
   }
   return( Button );
#endif
}   /* HSget_mouse_tap */

/*--- HSwait ----------------------------------------------------------------*/

/*
NAME
      HSwait (static)

KEYWORD
      animate

DESCRIPTION
      This function halts execution of current process for 'Seconds' seconds
      of time (approximately) or until the STOP button is tapped. It remains
      in a loop continually checking the time in increments of 1/60 second
      until the time equals or exceeds the argument given or STOP is hit.

PARAMETERS
      Seconds (IN) - Number of seconds to wait.

GLOBALS USED
      none

RETURN VALUES
      none

HISTORY
      04/16/90 Created. -Trevor Mink
*/

static void HSwait ( double Seconds )

{
   double      start_time;
   double      this_time;
   double      Sixtieths;
   struct tms  cur_time;

   Sixtieths = Seconds * 60.0;

   times (&cur_time);
   start_time = (cur_time.tms_stime + cur_time.tms_utime);

   do
   {
      if (IGEstop ())
      {
         break;
      }
      times (&cur_time);
      this_time = (cur_time.tms_stime + cur_time.tms_utime);
   }

   while (this_time - start_time < Sixtieths);

}   /* HSwait */


static struct WLraster_data   frame_data[MAX_FILES];
static struct frame           frames[MAX_FILES];
static int                    num_frames;
static int                    buffer_size[MAX_FILES];
static char                   *buffer[MAX_FILES];

/*--- HSfree_buffers --------------------------------------------------------*/

/*
NAME
      HSfree_buffers

KEYWORD
      animate

DESCRIPTION
      This function frees 'Frames' buffers. If 'RasterBlock' is true, the
      buffers are identified by ints and known by the graphics library.
      Otherwise they're kept track of by the 'buffer' array.

PARAMETERS
      RasterBlocks (IN) - Boolean indicating whether hidden raster format is
                          used.

GLOBALS USED
      buffer_no[] - Array of raster blocks for hidden raster format.
      buffer[] - Array of raster blocks for conventional raster format.
      buffer_size[] - Array of integers for keeping track of image sizes.
      freed_mem - Amount of memory freed in calls to Display Image.

HISTORY
      07/06/90 Created. -Trevor Mink
      10/10/90 Added functionality to free 'RasterBlocks'. -Trevor Mink
      08/09/91 Added X functionality. -R. Druzynski
      04/29/92 Documented. -Trevor Mink
*/

void HSfree_buffers( int RasterBlocks )

{
   int i;

   if( RasterBlocks )
   {
      for (i = 0; i < num_frames; i++)
      {
         WLfree_raster_data( &frame_data[i] );
         if( buffer[i] )
         {
            free( buffer[i] );
            buffer[i] = NULL;
            freed_mem += buffer_size[i];
         }
      }
   }
   else
   {
      for (i = 0; i < num_frames; i++)
      {
         if( buffer[i] )
         {
            free( buffer[i] );
            buffer[i] = NULL;
            freed_mem += buffer_size[i];
         }
      }
   }
}   /* HSfree_buffers */

static IGRboolean BeganAnimate = FALSE;

/*--- HSrecall_rle -----------------------------------------------------------*/

void HSrecall_rle( WLuint32 lwin_no,
                   WLuint32 context_no,
                   char     *file_name,
                   int      num_cycles,
                   int      color_plane,
                   int      animate,
                   int      scale_factor )
/*
NAME
      HSrecall_rle

KEYWORD
      animate

DESCRIPTION
      This function is provided for support of applications which call the old
      function of the same name. The old version did both the setup, the actual
      animate/recall, and the freeing of the buffers at the end. This has been
      divided up.

PARAMETERS
      lwin_no (IN)      - Index of window in which to animate
      context_no (IN)   - Context number of the window
      file_name (IN)    - Filename(s) of animation sequence (Wildcards or
                          tilde allowed)
      num_cycles (IN)   - Number of times to run animation sequence (not
                          include load)
      color_plane (IN)  - Number of planes used for color for the current
                          machine
      animate (IN)      - Boolean indicating animate versus slide show
      scale_factor (IN) - Power of 2 scale of raster image (0 means scale of 1)

GLOBALS USED
      BeganAnimate (static) - Boolean indicating whether animation has begun

RETURN VALUES
      none

HISTORY
      08/16/90 Created. -Trevor Mink
*/
{
   int i;
   int PhongFlag;
   int x;
   int y;
   int use_win_color_table = FALSE;


   if (scale_factor == 0)
   {
      scale_factor = 1;
   }

   scale_factor *= 4;

   HSinq_phong_file (file_name, &PhongFlag, &x, &y);

   /* Read the files into buffers */

   /* Signal HSread_rle_files() NOT to consider the HS_SAVE_IMAGE_8BITS flag */
   if (PhongFlag)
   {
      PhongFlag = EDGEII_TRC;
   }

   /* ----- ---------  ----------  -------- ------------- */
   HSread_rle_files( lwin_no,
                     context_no,
                     file_name,
                     color_plane,
                     animate,
                     scale_factor,
                     1,
                     0.0,
                     0,
                     0,
                     PhongFlag,
                     TRUE,
                     TRUE,
                     use_win_color_table );

   /* delay of 0.0, center on window, no line-by-line, window clear */
   BeganAnimate = FALSE;

   /* For the given number of cycles, call animation function with no-cycle
    * option */
   for (i = 0; i < num_cycles; i++)
   {
      HSrapid_display( lwin_no,
                       context_no,
                       color_plane,
                       animate,
                       TRUE,
                       FALSE,
                       0.0,
                       0.0,
                       FALSE,
                       animate,
                       !PhongFlag,
                       TRUE);

      BeganAnimate = TRUE;
   }
   BeganAnimate = FALSE;

   HSfree_buffers (animate);

}   /* HSrecall_rle */

/*--- HSrapid_display -------------------------------------------------------*/

/*
NAME
      HSrapid_display

KEYWORD
      animate

DESCRIPTION
      This function animates or otherwise displays the sequence of frames
      stored in buffer[0] ... buffer[Frames-1]. It depends on the buffers
      already being full (except for the line-by-line case) and additional
      parameters and statics (see above) being set correctly in
      HSread_rle_files().

PARAMETERS
      w_no (IN)        - Index of window in which to animate
      color_plane (IN) - Number of planes used for color for the current machine
      animate (IN)     - Boolean indicating animate versus slide show
      delay (IN)       - Boolean indicating delay mode or not.
      cycle (IN)       - Boolean indicating whether to continually rerun
                         animation sequence
      FrameDelay (IN)  - Number of seconds to wait between frames
      CycleDelay (IN)  - Number of seconds to wait between after last frame if
                         cycling
      true_color (IN)  - Boolean indicating whether on a true-color machine and
                         in 24 bit display mode
      LineByLine (IN)  - Boolean indicating whether frames were loaded in
                         line-by-line mode which allows speedy animation versus
                         slide show format for special hardware circumstances
                         (SUN or 220)
      WindowErase (IN) - Boolean indicating whether to clear the window after
                         each frame
      Playback (IN)    - Boolean indicating whether MSM called this versus EMS

GLOBALS USED
      none

RETURN VALUES
      0       - Successful animation
      DO_FORM - Bring back form to allow changing certain options and
                re-animating

HISTORY
      07/06/90 Created. -Trevor Mink
*/

int HSrapid_display (WLuint32   lwin_no,
                     WLuint32   context_no,
                     int        color_plane,
                     int        animate,
                     int        delay,
                     int        cycle,
                     double     FrameDelay,
                     double     CycleDelay,
                     short      true_color,
                     int        LineByLine,
                     int        WindowErase,
                     IGRboolean Playback)

{
   int                    i;
   int                    Restart;
   int                    stop = FALSE;
   int                    MouseTap;
   char                   message1[200];
   char                   title_msg[100];
   int                    on_true_color = FALSE;
   int                    frames_to_display=0;
   int                    frame_counter=0;
   struct WLcontext_info  context_info;

   int                    journaling = FALSE;
   int                    jnl_playback = FALSE;

#ifdef X11
   XEvent                 report;
   Display                *win_display;
   struct WLnative_info   native_info;


   /* If we are on a machine that runs X, we need to get the  */
   /* display from  the native_info structure                 */
   WLget_native_info( lwin_no, context_no, &native_info );
   win_display = native_info.display;
#endif

#if DEBUG2
   fprintf (stderr, "w_no = %d\tcolor_plane = %d\tanimate = %d\tdelay = %d\tcycle = %d\t",
          w_no, color_plane, animate, delay, cycle);
   fprintf (stderr, "FrameDelay = %lf\tCycleDelay = %lf\t", FrameDelay, CycleDelay);
   fprintf (stderr, "LineByLine = %d\tFrames = %d\n", LineByLine, Frames);
#endif

   if( JNL_journal() )
   {
      journaling = TRUE;
   }

   if( JNL_playback() )
   {
      jnl_playback = TRUE;
   }

   frame_counter = 0;

   WLget_context_info( context_no, &context_info );
   if( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      on_true_color = TRUE;
   }

   ex$message(in_buff = "", field = ERROR_FIELD);
   if (num_frames > 1)
   {
      if (animate && !BeganAnimate)
      {
         ex$message (msgnumb = HS_I_ReadyToAnimate, buff = message1);
         ex$message (msgnumb = HS_W_NoteTitle, buff = title_msg);

         FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                         title_msg, FI_BLUE, "swiss742", 36.0,
                         message1, FI_BLACK, "swiss742", 18.0,
                         FI_LEFT_JUSTIFIED, 40);
      }
   }

   if( jnl_playback)
   {
      /* if JNL_playback, get number of frames to display before stopping */
      frames_to_display = HSread_num_frames_from_journal( FALSE );
      if( frame_counter == frames_to_display )
      {
         stop = TRUE;
      }
   }
   else
   {
      stop = IGEstop();
   }

   if ( !stop && delay && cycle )
   {
      HSwait (CycleDelay);

      if( jnl_playback )
      {
         if( frame_counter == frames_to_display )
         {
            stop = TRUE;
         }
      }
   }

   /* RECALL/ANIMATE CYCLE: Begin the rapid display of frames in      */
   /* virtual memory by using the putpixelblock or blockrestore function.  */

   WLhide_cursor (lwin_no, 0);
   WLclear_window( lwin_no );

   if( !jnl_playback )
   {
      stop = IGEstop();
      if( stop && journaling )
      {
         JNL_record_info_event( JNL_STOPSIGN, 0, (char *)&frame_counter );
      }
   }

   for (Restart = TRUE; (cycle || (animate && Restart)) && (!stop);)
   {
      for (i = 0; (i < num_frames) && (!stop); i++)
      {
         WLenter_db( lwin_no );

         if (WindowErase)
         {
            WLclear_window( lwin_no );
         }

         WLput_raster_data( lwin_no, context_no, &frame_data[i] );
         frame_counter++;

#if DEBUG2
         fprintf (stderr, "block %d bit_mask = %x at addr: %x restored from (%d, %d) to (%d, %d)\n",
                i, bit_mask, buffer[i],
                frames[i].x_min, frames[i].y_min,
                frames[i].x_max, frames[i].y_max);
#endif

         WLflush (lwin_no);

         WLexit_db (lwin_no);

         if ((i < num_frames - 1) && !Playback)
         {
            if( !jnl_playback )
            {
               stop = IGEstop ();
            }

            /* No delay for last frame or for MSM */
            if ( !stop )
            {
               if (delay && FrameDelay > 0.0 && i < num_frames - 1)
               {
                  HSwait (FrameDelay);
               }
            }

            if( !jnl_playback )
            {
               stop = IGEstop ();
            }

            if( jnl_playback )
            {
               if( frame_counter == frames_to_display )
               {
                  stop = TRUE;
               }
            }

            if ( stop || !delay)
            {
#ifdef X11
               if( journaling || jnl_playback )
               {
                  while( JNL_XCheckTypedEvent( win_display,
                                               ButtonPress,
                                               &report ));

                  JNL_XCheckMaskEvent (win_display,
                                       ButtonReleaseMask,
                                       &report);
               }
               else
               {
                  while( XCheckTypedEvent( win_display,
                                           ButtonPress,
                                           &report ));

                  XCheckMaskEvent (win_display,
                                   ButtonReleaseMask,
                                   &report);
               }
#endif
               ex$message (msgnumb       = HS_P_RestContForm,
                           justification = CENTER_JUS);
               ex$message (msgnumb       = HS_P_StopExit,
                           justification = CENTER_JUS,
                           field         = KEYIN_FIELD );

               if( journaling )
               {
                  JNL_record_info_event( JNL_STOPSIGN,
                                         0,
                                         (char *)&frame_counter );
               }

               IGEresetstop ();

               MouseTap = HSget_mouse_tap();

               ex$message (in_buff = "",
                           field   = PROMPT_FIELD);
               ex$message (in_buff = "",
                           field   = KEYIN_FIELD);

               switch (MouseTap)
               {
                  case LEFT_BUTTON:
                  case DOUBLE_LEFT_BUTTON:
                     /* Re-start animation */
                     Restart = TRUE;
                     stop = FALSE;
                     frame_counter = 0;
                     if( jnl_playback )
                     {
                        frames_to_display = HSread_num_frames_from_journal(
                                                                         FALSE);
                     }
                     goto end_loop;

                  case MIDDLE_BUTTON:
                  case DOUBLE_MIDDLE_BUTTON:
                     /* Continue animation */
                     frame_counter = 0;
                     stop = FALSE;
                     if( jnl_playback )
                     {
                        frames_to_display = HSread_num_frames_from_journal(
                                                                         FALSE);
                     }
                     continue;

                  case RIGHT_BUTTON:
                     WLshow_cursor (lwin_no);
                     WLflush (lwin_no);
                     return (DO_FORM);

                  case DOUBLE_RIGHT_BUTTON:
                     /* Exit animation */
                     goto exit_point;
               }
               break;
            }
         }
      }
      Restart = FALSE;

      if( !jnl_playback )
      {
         stop = IGEstop();
      }

      if (delay && cycle && !stop )
      {
         HSwait (CycleDelay);
      }

      if( !jnl_playback )
      {
         stop = IGEstop();
      }

      if( jnl_playback )
      {
         if( frame_counter == frames_to_display )
         {
            stop = TRUE;
         }
      }

      if ((stop || !delay || !cycle) && !Playback)
      {

   NoOp:
#ifdef X11
         if( journaling || jnl_playback )
         {
            while (JNL_XCheckTypedEvent( win_display,
                                         ButtonPress,
                                         &report));

            JNL_XCheckMaskEvent( win_display,
                                 ButtonReleaseMask,
                                 &report);
         }
         else
         {
            while ( XCheckTypedEvent( win_display,
                                      ButtonPress,
                                      &report));

            XCheckMaskEvent( win_display,
                             ButtonReleaseMask,
                             &report);
         }
#endif
         ex$message (msgnumb       = HS_P_RestContForm,
                     justification = CENTER_JUS);
         ex$message (msgnumb       = HS_P_StopExit,
                     justification = CENTER_JUS,
                     field         = KEYIN_FIELD );

         if( journaling )
         {
            JNL_record_info_event( JNL_STOPSIGN, 0, (char *)&frame_counter );
         }

         IGEresetstop ();
         MouseTap = HSget_mouse_tap ();

         ex$message (in_buff = "",
                     field = PROMPT_FIELD);
         ex$message (in_buff = "",
                     field   = KEYIN_FIELD);

         switch (MouseTap)
         {
            case LEFT_BUTTON:
            case DOUBLE_LEFT_BUTTON:
               /* Re-start animation */
               frame_counter = 0;
               Restart = TRUE;
               stop = FALSE;
               if(jnl_playback)
               {
                  frames_to_display = HSread_num_frames_from_journal( FALSE );
               }
               break;

            case MIDDLE_BUTTON:
            case DOUBLE_MIDDLE_BUTTON:
               /* Continue animation */
               frame_counter = 0;
               Restart = TRUE;
               stop = FALSE;
               if(jnl_playback)
               {
                  frames_to_display = HSread_num_frames_from_journal( FALSE );
               }

               if (!cycle)
               {
                  /* Continue makes no sense in this case */
                  goto NoOp;
               }
               goto end_loop;

            case RIGHT_BUTTON:
               WLshow_cursor (lwin_no);
               WLflush (lwin_no);
               return (DO_FORM);

            case DOUBLE_RIGHT_BUTTON:
               /* Exit animation */
               HSfree_buffers( animate );
               goto exit_point;
         }
      }
end_loop:
      ;
   }

exit_point:
   WLshow_cursor (lwin_no);
   WLflush (lwin_no);

   return (0);

}   /* HSrapid_display */

/*--- HSslide_show ----------------------------------------------------------*/

int HSslide_show ( WLuint32 lwin_no,
                   WLuint32 context_no,
                   char     *file_name,
                   int      cycle,
                   int      color_plane,
                   int      scale_factor,
                   int      delay,
                   double   FrameDelay,
                   double   CycleDelay,
                   int      PhongFlag,
                   int      WindowErase,
                   int      WinColorTable )

/*
NAME
      HSslide_show

KEYWORD
      animate

DESCRIPTION
      This function displays the sequence of frames stored in buffer[0] ...
      buffer[Frames-1]. Unlike HSrapid_display, it does not depend upon the
      buffers being full (except for the line-by-line case) and additional
      parameters and statics (see above) being set correctly in
      HSread_rle_files().

PARAMETERS
      w_no (IN)           - Index of window in which to animate
      context_no (IN)     - Current context number of window
      file_name (IN)      - Filename(s) of animation sequence (Wildcards or
                            tilde allowed)
      cycle (IN)          - Boolean indicating whether to continually rerun
                            animation sequence
      color_plane (IN)    - Number of planes used for color for the current
                            machine
      scale_factor (IN)   - Power of 2 scale of raster image
      delay (IN)          - Boolean indicating delay mode or not
      FrameDelay (IN)     - Number of seconds to wait between frames
      CycleDelay (IN)     - Number of seconds to wait between after last frame
                            if cycling
      PhongFlag (IN)      - Boolean indicating type 27 rle file versus type 29
                            rle
      WindowErase (IN)    - Boolean indicating whether to clear the window after
                            each frame
      WinColorTable (IN)  - Boolean indicating whether to use the file's color-
                            table or the window's.  If 0, use file's; if 1 use
                            window's

GLOBALS USED
      xOffset, xMin, yOffset, yMin, xMax, yMax, OldScale (all statics)

RETURN VALUES
      0       - Successful animation
      DO_FORM - Bring back form to allow changing certain options and
                rerunning slide-show

HISTORY
      07/06/90 Created. -Trevor Mink
*/
{
   int                     Restart;
   char                    ch;
   char                    name[132];
   char                    message1[200];
   char                    title_msg[100];
   char                    file_o_files[132];
   short                   data_type_modifier;
   short                   wds_to_follow;
   short                   stop = FALSE;
   FILE                    *name_file_ptr;
   int                     bufsiz[MAX_FILES];
   int                     status;
   int                     status2;
   int                     len;
   int                     test;
   int                     MouseTap;
   int                     rle_type;
   int                     hdr_planes;
   int                     xlo;
   int                     ylo;
   int                     xhi;
   int                     yhi;
   short                   true_color = FALSE;
   int                     num_planes;
   IGRboolean              OutOfMemory = FALSE;
   IGRboolean              Scannable;
   int                     ii;
   int                     state = EXIT;
   int                     ct_to_use;
   int                     ct_offset = 0;
   int                     frame_counter=0;
   int                     frames_to_display=0;

   struct WLbounds         win_attr;
   struct WLbounds         dummy;  /* dummy variable for call to  */
                                   /* WLget_window_bounds         */

   struct WLcmap_entry     file_cmap[512];
   struct WLcontext_info   context_info;

   int                     jnl_playback = FALSE;
   int                     journaling = FALSE;
   unsigned short          orientation;

#ifdef X11
   XEvent                  report;
   Display                 *win_display;
   struct WLnative_info    native_info;


   /* If we are on a machine that runs X, we need to get the  */
   /* display from  the native_info structure                 */
   WLget_native_info( lwin_no, context_no, &native_info );
   win_display = native_info.display;

#endif

#if DEBUG2
   fprintf (stderr, "HSslide_show\n");
   fprintf (stderr, "w_no = %d\tcolor_plane = %d\tdelay = %d\tcycle = %d\t",
                     w_no, color_plane, delay, cycle);
   fprintf (stderr, "FrameDelay = %lf\tCycleDelay = %lf\t", FrameDelay,
                     CycleDelay);
#endif
#  if defined (XGL)
   WinColorTable = 0;
#  endif

   if( JNL_journal() )
   {
      journaling = TRUE;
   }

   if( JNL_playback() )
   {
      jnl_playback = TRUE;
   }

   frame_counter = 0;
   ct_to_use = WinColorTable;

   if( ct_to_use )
   {
      /* initialize the colormap slot numbers */
      for( ii = 0; ii<512; ii++ )
      {
         file_cmap[ii].slot = ii;
      }
   }

   file_o_files[0] = '\0';

   WLget_context_info( context_no, &context_info );
   if (context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      true_color = PhongFlag;
   }
   else
   {
      true_color = FALSE;
   }

   num_planes = context_info.base_depth;

   WLget_window_bounds( lwin_no, &dummy, &win_attr );

   xlo = ylo = 0;
   xhi = win_attr.width;
   yhi = win_attr.height;

   len = strlen (file_name);
   test = strspn ("*", file_name);
   ch = file_name[len - 1];
   if (test != 0)
   {
      ch = '*';
   }

   if (HSget_file_o_files (file_name, &name_file_ptr, file_o_files) == 1)
   {
      ex$message (msgnumb = HS_I_Directory,
                  type = "%s",
                  var = `file_name `,
                  buff = message1);
      ex$message (msgnumb = HS_W_WarnTitle, buff = title_msg);
      FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                  title_msg, FI_RED, "swiss742", 36.0,
                  message1, FI_BLACK, "swiss742", 18.0,
                  FI_LEFT_JUSTIFIED, 40);
      if (ch != '~')
      {
         EX_rm (file_o_files);
      }
      return (1);
   }

   if( jnl_playback )
   {
      /* if JNL_playback, get number of frames to display before stopping */
      frames_to_display = HSread_num_frames_from_journal( FALSE );
      if( frame_counter == frames_to_display )
      {
         stop = TRUE;
      }
   }

   /* Cycled recall using the putline function */
   WLhide_cursor (lwin_no, 0);
   for (Restart = TRUE; (cycle || Restart) && (!stop);)
   {
      if ( !jnl_playback )
      {
         stop = IGEstop ();
         if( stop && journaling )
         {
            JNL_record_info_event( JNL_STOPSIGN, 0, (char *)&frame_counter );
         }
      }

      if (!stop && delay && cycle)
      {
         HSwait (CycleDelay);
      }

      /* CONVERT CYCLE:                                                */
      /* read through the file pointed to by the name_file_ptr which   */
      /* contains the names of all raster files specified by the user, */
      /* open each file at a time, convert to putpixelblock format and */
      /* close the file before opening the next one. This avoids the   */
      /* problem of exceeding the maximum open files at a time.        */

      status2 = fscanf (name_file_ptr, "%s\n", name);
      stop = FALSE;
      for (num_frames = 0; status2 != EOF && (!stop); num_frames++)
      {

         if (WindowErase)
         {
            WLclear_window( lwin_no );
         }

         /* The following check is made again to guard against any character  */
         /* being appended to the end of the file name read from file of      */
         /* files.  This might happen if the raster file mode was set as      */
         /* executable due to the the behavior of ls function. If an asterisk */
         /* is detected at the end of the file it is simply stripped at this  */
         /* point. This will truncate the last character.                     */

         len = strlen (name);
         if (name[len - 1] == '*')
         {
            name[len - 1] = '\0';
         }
         if (num_frames == MAX_FILES)
         {
            HSfile_error (7);
            status2 = EOF;
            num_frames--;
         }
         else
         {
            status = HSread_rle_header ( name,
                                         file_o_files,
                                         context_no,
                                         lwin_no,
                                         color_plane,
                                         &rle_type,
                                         &Scannable,
                                         &hdr_planes,
                                         num_frames,
                                         &data_type_modifier,
                                         &wds_to_follow,
                                         &frames[num_frames],
                                         scale_factor,
                                         &ct_to_use,
                                         file_cmap,
                                         &ct_offset,
                                         &orientation );

            if (status)
            {
               fclose (name_file_ptr);
               return (status);
            }

            /***********************************************/
            /* Get the buffer size and allocate the buffer */
            /***********************************************/

            status = HSread_raster_data( name,
                                         rle_type,
                                         wds_to_follow,
                                         Scannable,
                                         data_type_modifier,
                                         lwin_no,
                                         context_no,
                                         0,
                                         0,
                                         xlo,
                                         xhi,
                                         ylo,
                                         yhi,
                                         scale_factor,
                                         bufsiz,
                                         TRUE,
                                         WindowErase,
                                         true_color,
                                         color_plane,
                                         num_planes,
                                         hdr_planes,
                                         ct_to_use,
                                         file_cmap,
                                         ct_offset,
                                         orientation );


#if DEBUG
            fprintf (stderr, "Frame %d displayed\n", num_frames);
#endif

            free (buffer[num_frames]);

            /* increment frame counter for journaling */
            frame_counter ++;

            WLflush (lwin_no);

            /* get next file name */
            status2 = fscanf (name_file_ptr, "%s\n", name);

            if (status2 != EOF)
            {
               if( !jnl_playback )
               {
                  stop = IGEstop ();
               }

               if ( !stop )
               {
                  if (delay && FrameDelay > 0.0)
                  {
                     HSwait (FrameDelay);
                  }
               }

               if( !jnl_playback )
               {
                  stop = IGEstop ();
               }

               if( jnl_playback )
               {
                  if( frame_counter == frames_to_display )
                  {
                     stop = TRUE;
                  }
               }

               if (stop || !delay)
               {
#ifdef X11
                  if( journaling || jnl_playback )
                  {
                     while ( JNL_XCheckTypedEvent( win_display,
                                                   ButtonPress,
                                                   &report));

                     JNL_XCheckMaskEvent( win_display,
                                          ButtonReleaseMask,
                                          &report);
                  }
                  else
                  {
                     while ( XCheckTypedEvent( win_display,
                                               ButtonPress,
                                               &report));

                     XCheckMaskEvent( win_display,
                                      ButtonReleaseMask,
                                      &report);
                  }
#endif

                  ex$message ( msgnumb       = HS_P_RestContForm,
                               justification = CENTER_JUS);
                  ex$message ( msgnumb       = HS_P_StopExit,
                               justification = CENTER_JUS,
                               field         = KEYIN_FIELD );

                  if( journaling )
                  {
                     JNL_record_info_event( JNL_STOPSIGN,
                                            0,
                                            (char *)&frame_counter );
                  }

                  IGEresetstop ();

                  MouseTap = HSget_mouse_tap();

                  ex$message (in_buff = "",
                              field   = PROMPT_FIELD);
                  ex$message (in_buff = "",
                              field   = KEYIN_FIELD);

                  switch (MouseTap)
                  {
                     case LEFT_BUTTON:
                     case DOUBLE_LEFT_BUTTON:
                        /* Re-start animation */
                        frame_counter = 0;
                        Restart = TRUE;
                        stop = FALSE;

                        if( jnl_playback )
                        {
                           frames_to_display =
                                      HSread_num_frames_from_journal( FALSE );
                        }

                        goto end_loop2;

                     case MIDDLE_BUTTON:
                     case DOUBLE_MIDDLE_BUTTON:
                        /* Continue animation */
                        frame_counter = 0;
                        stop = FALSE;
                        if(jnl_playback )
                        {
                           frames_to_display =
                                      HSread_num_frames_from_journal( FALSE );
                        }
                        continue;

                     case RIGHT_BUTTON:
                        state = DO_FORM;
                        goto exit_point;

                     case DOUBLE_RIGHT_BUTTON:
                        /* Exit animation */
                        state = EXIT;
                        goto exit_point;
                     }
                  break;
               }
            }   /* end : if( status2 != EOF ) */
         }      /* end : if Frames== MAX_FILES else ... */
      }         /* end : for( Frames = ... */
      Restart = FALSE;

      if( !jnl_playback )
      {
         stop = IGEstop();
      }

      if (delay && cycle && !stop )
      {
         HSwait (CycleDelay);
      }

      if( !jnl_playback )
      {
         stop = IGEstop();
      }

      if( jnl_playback )
      {
         if( frame_counter == frames_to_display )
         {
            stop = TRUE;
         }
      }

      if (stop || !delay || !cycle)
      {
NoOp2:
#ifdef X11
         if( jnl_playback || journaling )
         {
            while (JNL_XCheckTypedEvent( win_display,
                                         ButtonPress,
                                         &report));

            JNL_XCheckMaskEvent( win_display,
                                 ButtonReleaseMask,
                                 &report);
         }
         else
         {
            while (XCheckTypedEvent( win_display,
                                     ButtonPress,
                                     &report));

            XCheckMaskEvent( win_display,
                             ButtonReleaseMask,
                             &report);
         }
#endif

         ex$message ( msgnumb       = HS_P_RestContForm,
                      justification = CENTER_JUS);
         ex$message ( msgnumb       = HS_P_StopExit,
                      justification = CENTER_JUS,
                      field         = KEYIN_FIELD );

         if( journaling )
         {
            JNL_record_info_event( JNL_STOPSIGN, 0, (char *)&frame_counter );
         }

         IGEresetstop ();
         MouseTap = HSget_mouse_tap ();

         ex$message (in_buff = "",
                     field = PROMPT_FIELD);
         ex$message (in_buff = "",
                     field   = KEYIN_FIELD);

         switch (MouseTap)
         {
            case LEFT_BUTTON:
            case DOUBLE_LEFT_BUTTON:
               /* Re-start animation */
               if (OutOfMemory)
               {
                  ex$message ( msgnumb = HS_E_ErrAllocMem,
                               field = ERROR_FIELD);
                  goto NoOp2;
               }
               frame_counter = 0;
               Restart = TRUE;
               stop = FALSE;

               if(jnl_playback)
               {
                  frames_to_display = HSread_num_frames_from_journal( FALSE );
               }
               break;

            case MIDDLE_BUTTON:
            case DOUBLE_MIDDLE_BUTTON:
               /* Continue animation */
               if (OutOfMemory)
               {
                  ex$message (msgnumb = HS_E_ErrAllocMem,
                              field   = ERROR_FIELD);
                  goto NoOp2;
               }
               frame_counter = 0;
               Restart = TRUE;
               stop = FALSE;
               if (!cycle)
               {
                  /* Continue makes no sense in this case */
                  goto NoOp2;
               }
               if( jnl_playback )
               {
                  frames_to_display = HSread_num_frames_from_journal( FALSE );
               }

               goto end_loop2;

            case RIGHT_BUTTON:
               state = DO_FORM;
               goto exit_point;

            case DOUBLE_RIGHT_BUTTON:
               /* Exit animation */
               state = EXIT;
               goto exit_point;
         }
      }
end_loop2:
      /* Go back to the beginning of the file of files */
      fseek (name_file_ptr, 0, 0);
   }      /* end : for( Restart = TRUE; cycle ... */

exit_point:
   fclose (name_file_ptr);
   WLshow_cursor (lwin_no);
   WLflush(lwin_no);

   if( state == DO_FORM)
   {
      return( DO_FORM );
   }
   else
   {
      return(0);
   }

}   /* HSslide_show */

/*
 * If the parameter animate is set to FALSE:
 *
 *   This routine opens the specified files containing raster data
 *   in type29, type26, type10, type15 or type27 format described in SRN 84-007,
 *   converts them into putpixelblock format in the virtual memory and displays
 *   each frame consecutively the specified number of times.
 *
 *   w_no - window where the display will occur.
 *   file_name - three options:
 *        a) a singular, regular path/filename
 *        b) a filename ending with '*' indicates a
 *          wildcard & therefore more than one file
 *          might be displayed.
 *        c) a filename ending with '~' indicates
 *          that the file is a file containing a
 *          list of raster files to be displayed.
 *         num_cycles - the number of times to display a
 *          sequence of raster files.
 *
 * If the parameter animate is set to TRUE:
 *
 *   The routine differs in the following ways and uses the new blockrestore
 *   function instead of putblock. This results in improved animation speeds
 *   on machines with IFB.
 *
 *   1. Convert Cycle:
 *
 *      During the first cycle each frame's type10 raster data is
 *      converted to the putpixelblock format and displayed. The display
 *      is now saved in the virtual memory in the blockrestore
 *      format by the blocksave function.
 *
 *   2. Animate Cycle:
 *
 *      The frames are displayed in a sequence the specified number of
 *      times by using the faster blockrestore function. The speed
 *      increase achieved by this method would be significant in machines
 *      with IFB.
 *
 *
 */

/*---HSread_raster_data------------------------------------------------------*/

/*
NAME
      HSread_raster_data

KEYWORD
      animate

DESCRIPTION
      This function opens the specified file ('name'), reads the raster data
      and displays it to the window given by 'w_no'

PARAMETERS
      name (IN)            - Name of file from which to read raster data
      rle_type (IN)        - Type of run-length encoding used to create file
      wtf (IN)             - Number of 16 bits words to follow for the file
                             header
      Scannable (IN)       - Boolean indicating whether raster file has a header
                             at the beginning of each scanline.
      dtm (IN)             - Data type modifier
      lwin_no (IN)         - Logical window number
      context_no (IN)      - window context number
      MouseX, MouseY (IN)  - x/y button input from user at previous display.
                             Used to center the current image
      xlo,xhi,ylo,yhi (IN) - x,y extents of window
      scale_factor (IN)    - Power of 2 scale of raster image
      bufsiz[] (OUT)       - Number of bytes in buffer
      LineByLine (IN)      - Boolean indicating whether to load one line at
                             a time or all lines together
      WindowErase (IN)     - Boolean indicating whether to clear the window
                             after each frame
      true_color (IN)      - Boolean indicating if machine (edge II) and mode
                             is true_color
      color_plane (IN)     - Number of planes used for color for the current
                             machine
      term_planes (IN)     - Number of bit planes the current machine has
      hdr_planes (IN)      - Number of bit planes (indicated by the file
                             header) of the machine used to create the current
                             raster file
      WinColorTable (IN)   - Boolean letting the function know if the color
                             indices need to be translated to the windows color
                             table.
      cmap_offset (IN)     - Offset of colors stored in colortable, if
                             WinColorTable is false.
      orientation (IN)     - The scanline orientation of the raster data.  This
                             code tells how the scanline is oriented and the
                             location of the file origin.

GLOBALS USED
   (all statics)
      xOffset,
      xMin,
      yOffset,
      yMin,
      xMax,
      yMax,
      OldScale,
      num_frames

   (external)
      freed_mem

RETURN VALUES
      0 - Raster file successfully read
      OUT_OF_MEMORY - Ran out of memory trying to malloc

HISTORY
      06/09/92 Created. -Trevor Mink
*/

int HSread_raster_data (char                *name,
                        int                 rle_type,
                        int                 wtf,
                        IGRboolean          Scannable,
                        int                 dtm,
                        WLuint32            lwin_no,
                        WLuint32            context_no,
                        int                 MouseX,
                        int                 MouseY,
                        int                 xlo,
                        int                 xhi,
                        int                 ylo,
                        int                 yhi,
                        int                 scale_factor,
                        int                 *bufsiz,
                        int                 LineByLine,
                        int                 WindowErase,
                        short               true_color,
                        int                 color_plane,
                        short               term_planes,
                        short               hdr_planes,
                        int                 WinColorTable,
                        struct WLcmap_entry *file_cmap,
                        int                 cmap_offset,
                        unsigned short      orientation )

{
   FILE   *f_ptr;
   int    x_center;
   int    y_center;
   int    HalfX;
   int    HalfY;
   int    Factor;
   int    total_mem;
   int    used_mem;
   int    HeaderSize;


   /* Open file and skip the header block to position to hdr89 */
   f_ptr = fopen(name, "r");

   if (rle_type == TYPE_15)
   {
      fseek(f_ptr, (768 + frames[num_frames].vlt_size *
                  sizeof (struct WLcmap_entry)), 1);
   }
   else if ((rle_type == TYPE_10) || (rle_type == TYPE_26) ||
          (rle_type == TYPE_29) || (rle_type == TYPE_27))
   {
      HeaderSize = (wtf + 2) * 2;
      fseek (f_ptr, HeaderSize, 0);
   }
   else
   {
      fprintf (stderr, "foreign type rle file!!\n");
   }

   /* Find the 'Center of Projection' */
   if (MouseX || MouseY)
   {
      if (OldScale >= 4)
      {
         x_center = MouseX / (OldScale / 4) - xOffset;
         y_center = MouseY / (OldScale / 4) - yOffset;
      }
      else
      {
         if (OldScale == 1)
         {
            Factor = 4;
         }
         else if (OldScale == 0)
         {
            Factor = 8;
         }
         else
         {
            Factor = 2;
         }

         if (xOffset < 0)
         {
            x_center = (MouseX - xOffset) * Factor;
         }
         else
         {
            x_center = MouseX * Factor - xOffset;
         }

         if (yOffset < 0)
         {
            y_center = (MouseY - yOffset) * Factor;
         }
         else
         {
            y_center = MouseY * Factor - yOffset;
         }
      }
   }
   else
   {
      if( orientation & HORIZONTAL  )
      {
         x_center = frames[num_frames].num_cols / 2;
         y_center = frames[num_frames].num_rows / 2;
      }
      else
      {
         y_center = frames[num_frames].num_cols / 2;
         x_center = frames[num_frames].num_rows / 2;
      }
   }

   /* Find non-scaled starting and ending points */
   HalfX = (xhi + 1) / 2;
   HalfY = (yhi + 1) / 2;

   if (scale_factor >= 4)
   {
      xMin = x_center - HalfX / (scale_factor / 4);
      xOffset = -xMin;
      xMax = x_center + (xhi + 1 - HalfX) / (scale_factor / 4);

      yMin = y_center - HalfY / (scale_factor / 4);
      yOffset = -yMin;
      yMax = y_center + (yhi + 1 - HalfY) / (scale_factor / 4);
   }
   else
   {
      if (scale_factor == 1)
      {
         Factor = 4;
      }
      else if (scale_factor == 0)
      {
         Factor = 8;
      }
      else
      {
         Factor = 2;
      }

      xMin = x_center - Factor * HalfX;
      xOffset = -xMin;

      if (xOffset < 0)
      {
         xOffset /= Factor;
      }

      xMax = x_center + Factor * (xhi + 1 - HalfX);
      yMin = y_center - Factor * HalfY;
      yOffset = -yMin;
      if (yOffset < 0)
      {
         yOffset /= Factor;
      }
      yMax = y_center + Factor * (yhi + 1 - HalfY);
   }

   OldScale = scale_factor;

   if( orientation & HORIZONTAL )
   {
      if (xMax > frames[num_frames].num_cols)
      {
         xMax = frames[num_frames].num_cols - 1;
      }
   }
   else
   {
      if (xMax > frames[num_frames].num_rows)
      {
         xMax = frames[num_frames].num_rows - 1;
      }
   }

   /* 'xOffset' may be negative, but not 'xMin' */
   if (xMin < 0)
   {
      /* Convert offset to the current scale */
      if (scale_factor == 0)
      {
         frames[num_frames].x_min = -xMin / 8;
      }
      else
      {
         frames[num_frames].x_min = -xMin * scale_factor / 4;
      }
      xMin = 0;
   }


   if( orientation & HORIZONTAL )
   {
      if (yMax > frames[num_frames].num_rows)
      {
         yMax = frames[num_frames].num_rows - 1;
      }
   }
   else
   {
      if (yMax > frames[num_frames].num_cols)
      {
         yMax = frames[num_frames].num_cols - 1;
      }
   }

   /* 'yOffset' may be negative, but not 'yMin' */
   if (yMin < 0)
   {
      if (scale_factor == 0)
      {
         frames[num_frames].y_min = -yMin * 1 / 8;
      }
      else
      {
         frames[num_frames].y_min = -yMin * scale_factor / 4;
      }
      yMin = 0;
   }

   if (scale_factor >= 4)
   {
      frames[num_frames].x_max = frames[num_frames].x_min + (xMax - xMin + 1) *
                                 scale_factor / 4 - 1;
      frames[num_frames].y_max = frames[num_frames].y_min + (yMax - yMin + 1) *
                                 scale_factor / 4 - 1;
   }
   else if (scale_factor == 2)
   {
      frames[num_frames].x_max = frames[num_frames].x_min +
                                 (xMax - xMin + 1) / 2 - 1;
      frames[num_frames].y_max = frames[num_frames].y_min +
                                 (yMax - yMin + 1) / 2 - 1;
   }
   else if (scale_factor == 1)
   {
      frames[num_frames].x_max = frames[num_frames].x_min +
                                 (xMax - xMin + 1) / 4 - 1;
      frames[num_frames].y_max = frames[num_frames].y_min +
                                 (yMax - yMin + 1) / 4 - 1;
   }
   else
   {
      frames[num_frames].x_max = frames[num_frames].x_min +
                                 (xMax - xMin + 1) / 8 - 1;
      frames[num_frames].y_max = frames[num_frames].y_min +
                                 (yMax - yMin + 1) / 8 - 1;
   }

#if DEBUG
   fprintf (stderr, "x_center = %d\ty_center = %d\n", x_center, y_center);
   fprintf (stderr, "xOffset = %d\tyOffset = %d\n", xOffset, yOffset);
   fprintf (stderr, "xMin = %d\tyMin = %d\txMax = %d\tyMax = %d\n",
            xMin, yMin, xMax, yMax);
   fprintf (stderr, "xhi = %d\tyhi = %d\n", xhi, yhi);
   fprintf (stderr, "num_rows = %d\tnum_cols = %d\n",
            frames[num_frames].num_rows, frames[num_frames].num_cols);
   fprintf (stderr, "frame.x_min,y_min = (%d, %d)\tframe.x_max,y_max = (%d, %d)\n",
            frames[num_frames].x_min, frames[num_frames].y_min,
            frames[num_frames].x_max, frames[num_frames].y_max);
#endif

   /* figure size of buffers needed to store image data */
   if (LineByLine)
   {
      HSset_LineByLine_on (lwin_no,
                           context_no,
                           0xff,
                           frames[num_frames].x_min,
                           frames[num_frames].x_max,
                           frames[num_frames].y_min,
                           frames[num_frames].y_max);

      switch (rle_type)
      {
         case TYPE_10:
         case TYPE_15:
         case TYPE_26:
         case TYPE_29:
            bufsiz[num_frames] = xhi - xlo + 128;
            break;
         case TYPE_27:
            if( orientation & HORIZONTAL )
            {
               bufsiz[num_frames] = xhi - xlo + 128;
            }
            else
            {
               bufsiz[num_frames] = yhi - ylo + 128;
            }
            break;
      }

      /* Erase the window before the first frame or on 'WindowErase' option */
      if (WindowErase)
      {
         WLclear_window( lwin_no );
      }
      WLhide_cursor( lwin_no, 0 );
   }
   else
   {
      /* Make sure buffering is done so the full image can be stored */
      HSset_LineByLine_off ();
      bufsiz[num_frames] = HSget_put_block_size (frames[num_frames].x_min,
                                                 frames[num_frames].y_min,
                                                 frames[num_frames].x_max + 3,
                                                 frames[num_frames].y_max + 3);
   }

   if (true_color)
   {
      /* Recalling a RGB file on a true color machine, use a buffer of longs */
      bufsiz[num_frames] *= 4;
   }
   else if (color_plane == 9)
   {
      /* recalling a RENDERING FILE on a GX/GZ machine; use a buffer of  */
      /* shorts                                                          */
      bufsiz[num_frames] *= 2;
   }

   HSget_vm_stats ((unsigned long *)&total_mem,
                   (unsigned long *)&used_mem,
                   (unsigned long *)NULL);

   if (total_mem - used_mem + freed_mem >= HS_DSPLIMG_TILER_RESERVE)
   {
      buffer[num_frames] = (char *)malloc(bufsiz[num_frames]);

#if SCALE_DEBUG
      fprintf (stderr, "bufsiz[%d] = %d\n", num_frames, bufsiz[num_frames]);
#endif

      if (buffer[num_frames])
      {
         memset(buffer[num_frames], 0, bufsiz[num_frames]);
      }
      else
      {
         /* Should send an error message here that memory is gone */
         ex$message(msgnumb = HS_E_ErrAllocMem, field = ERROR_FIELD);
         return(OUT_OF_MEMORY);
      }
   }
   else
   {
      ex$message (msgnumb = HS_E_ErrAllocMem, field = ERROR_FIELD);
      return(OUT_OF_MEMORY);
   }

   switch (rle_type)
   {
      case TYPE_29:
      case TYPE_26:
      case TYPE_10:
      case TYPE_15:
         /* Takes care of the 4 types of index rle raster data */
         HSformat_indexed (f_ptr,
                           frames[num_frames].num_cols,
                           scale_factor,
#if defined (XGL)
8,
#else
                           hdr_planes,
#endif
                           term_planes,
                           buffer[num_frames],
                           xMin,
                           yMin,
                           xMax,
                           yMax,
                           rle_type,
                           Scannable,
                           dtm,
                           WinColorTable,
                           file_cmap,
                           cmap_offset,
                           orientation );
         break;
      case TYPE_27:
         HSformat_type27 (f_ptr,
                          color_plane,
                          frames[num_frames].num_cols,
                          scale_factor,
                          buffer[num_frames],
                          xMin,
                          yMin,
                          xMax,
                          yMax,
#if defined (XGL)
1,
#else
                          true_color,
#endif
                          orientation );
         break;
   }   /* end: switch */
   fclose (f_ptr);

   return (0);

}   /* HSread_raster_data */

/*---HSread_rle_files---------------------------------------------------------*/


/*
NAME
      HSread_rle_file

KEYWORD
      animate

DESCRIPTION
      This function is used for display images for single frame as well as for
      animating multiple images. For animation, it serves to display the images
      for their initial loading and load them for subsequent animation by
      HSrapid_display. For single images, it is called singularly for each display.

PARAMETERS
      lwin_no (IN)        - Logical window number
      context_no (IN)     - window context number
      file_name (IN)      - Filename(s) of animation sequence (Wildcards or
                            tilde allowed)
      color_plane (IN)    - Number of planes used for color for the current
                            machine
      animate (IN)        - Boolean indicating animation loading versus single
                            frame display
      scale_factor (IN)   - Power of 2 scale of raster image
      delay (IN)          - Boolean indicating delay mode or not
      FrameDelay (IN)     - Number of seconds to wait between frames
      MouseX, MouseY (IN) - x/y button input from user at previous display.
                            Used to center the current image
      PhongFlag (IN)      - Boolean indicating type 27 rle file versus type 29
                            rle
      LineByLine (IN)     - Boolean indicating whether frames were loaded in
                            line-by-line mode which allows speedy animation
                            versus slide show format for special hardware
                            circumstances (SUN or 220)
      WindowErase (IN)    - Boolean indicating whether to clear the window
                            after each frame
      WinColorTable (IN)  - If 0, use the colortable stored in the file, else
                            use the window's colortable.
GLOBALS USED
      frames[] (static) - Array of structure containing header information for
                          images
      Frames (static)   - Number of images loaded

RETURN VALUES
      0    - Load of single frame display was successful
      EXIT - User stopped, then exitted amidst loading. Some frames may be
             loaded.

HISTORY
      09/08/88 Created. -Kash J. Rangan
      08/27/91 Added X functionality. -R. Druzynski
*/

int HSread_rle_files( WLuint32 lwin_no,
                      WLuint32 context_no,
                      char     *file_name,
                      int      color_plane,
                      int      animate,
                      int      scale_factor,
                      int      delay,
                      double   FrameDelay,
                      int      MouseX,
                      int      MouseY,
                      int      PhongFlag,
                      int      LineByLine,
                      int      WindowErase,
                      int      WinColorTable)

{
   char                   ch;
   char                   name[132];
   char                   message1[200];
   char                   title_msg[100];
   char                   file_o_files[132];
   short                  data_type_modifier;
   short                  wds_to_follow;
   short                  stop = FALSE;
   FILE                   *name_file_ptr;
   int                    bufsiz[MAX_FILES];
   int                    status;
   int                    status2;
   int                    len;
   int                    test;
   int                    MouseTap;
   int                    rle_type;
   int                    hdr_planes;
   int                    xlo;
   int                    ylo;
   int                    xhi;
   int                    yhi;
   int                    display_flags;
   short                  true_color = FALSE;
   short                  OutOfMemory = FALSE;
   IGRboolean             Scannable;
   int                    xdiff;
   int                    ydiff;

   int                    ct_to_use;
   int                    frame_counter = 0;
   int                    num_frames_displayed = 0;
   int                    load_stop = FALSE;

   struct WLbounds        win_attr;
   struct WLbounds        junk;
   struct WLcontext_info  context_info;
   int                    on_true_color = FALSE;
   struct WLcmap_entry    file_cmap[512];
   int                    ct_offset = 0;
   int                    pixel_size;
   int                    journaling = FALSE;
   int                    jnl_playback = FALSE;

   unsigned short         orientation;

#if TIMING
   extern long            clock ();
   long                   time1;
   long                   time2;
   double                 delta;
#endif


#if DEBUG
   fprintf (stderr, "lwin_no,color_plane,animate,scale_factor,delay\n");
   fprintf (stderr, "%d,  %d,       %d,    %d,        %d\n",
            w_no, color_plane, animate, scale_factor, delay);
   fprintf (stderr, "FrameDelay = %f\n", FrameDelay);
   fprintf (stderr, "MouseX,MouseY,PhongFlag,LineByLine,WindowErase\n");
   fprintf (stderr, "%d,   %d,   %d,      %d,      %d\n",
            MouseX, MouseY, PhongFlag, LineByLine, WindowErase);
#endif

/*****************************************************************
 *
 *  In XGL, we always use the windows colortable, but if this comes
 *  up true and the rasterdata is index, the rasterdata's colortable
 *  will not get loaded into WL, and we won't know how to map the
 *  colors  (Mike 1/22/96)
 *
 */ 

#  if defined (XGL)
   WinColorTable = 0;
#  endif

   /* determine if journaling or playback mode is on */
   if( JNL_journal() )
   {
      journaling = TRUE;
   }
   else if( JNL_playback() )
   {
      jnl_playback = TRUE;
   }

   /* For playback, read next event.  If event is an info event and type is   */
   /* JNL_STOP, then a stop event happened.  To distinguish between a stop    */
   /* during loading and a stop during playback, check for a negative number  */
   /* of frames.  If number of frames is negative, stop hit during loading.   */
   if ( jnl_playback )
   {
      num_frames_displayed = HSread_num_frames_from_journal( TRUE );
      if ( (num_frames_displayed > 0) && (num_frames_displayed <= MAX_FILES) )
      {
         load_stop = TRUE;
      }
   }

   /* we need to be able to change the colortable to use if the file has more */
   /* planes than the machine supports.  Use a dummy variable for this.       */

   ct_to_use = WinColorTable;

   file_o_files[0] = '\0';

   /*------------------------------------------------------------
    *
    * If XGL, get the depth of the data from hdr_planes, else get
    * it from WLget_raster_size.  Mike (1/11/96)
    *
    */

#  if defined (XGL)
   pixel_size = (hdr_planes-1)/8 + 1;
#  else
   WLget_raster_size( lwin_no, 1, 1, &pixel_size);
#  endif

   /* determine if on a true-color machine and which mode (8 or 24 bit) */
   WLget_context_info( context_no, &context_info );
   if( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      on_true_color = TRUE;
      hs$get_shading_flags (save_image_flags = (IGRuint *)&display_flags);
      true_color = PhongFlag && (!(display_flags & HS_SAVE_IMAGE_8BIT) ||
                                  (PhongFlag == EDGEII_TRC || PhongFlag == TYPE_27));
   }

   WLget_window_bounds( lwin_no, &junk, &win_attr );

   xlo = 0;
   ylo = 0;
   xhi = win_attr.width;
   yhi = win_attr.height;

   len = strlen (file_name);
   test = strspn ("*", file_name);
   ch = file_name[len - 1];

   if (test != 0)
   {
      ch = '*';
   }

   if (HSget_file_o_files (file_name, &name_file_ptr, file_o_files) == 1)
   {
      ex$message (msgnumb = HS_I_Directory,
                  type    = "%s",
                  var     = `file_name `,
                  buff    = message1);
      ex$message (msgnumb = HS_W_WarnTitle,
                  buff    = title_msg);

      FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                  title_msg, FI_RED, "swiss742", 36.0,
                  message1, FI_BLACK, "swiss742", 18.0,
                  FI_LEFT_JUSTIFIED, 40);

      if (ch != '~')
      {
         EX_rm (file_o_files);
      }

      return (1);
   }

   /* CONVERT CYCLE:                                                */
   /* read through the file pointed to by the name_file_ptr which   */
   /* contains the names of all raster files specified by the user, */
   /* open each file at a time, convert to putpixelblock format and */
   /* close the file before opening the next one. This avoids the   */
   /* problem of exceeding the maximum open files at a time.        */

   status2 = fscanf (name_file_ptr, "%s\n", name);
   stop = FALSE;

   WLclear_window( lwin_no );

   for (num_frames = 0; status2 != EOF; num_frames++)
   {

      /* The following check is made again to guard against any * character   */
      /* appended at the end of the file name read from file of files. This   */
      /* might happen if the raster file mode was set as executable due to    */
      /* the behavior of the ls function. If an asterisk is detected at the   */
      /* end of the file it is simply stripped at this point. This will only  */
      /* truncate the last character.                                         */
      len = strlen (name);
      if (name[len - 1] == '*')
      {
         name[len - 1] = '\0';
      }

      if (num_frames == MAX_FILES)
      {
         HSfile_error( 7 );
         status2 = EOF;
         num_frames--;
      }
      else
      {
         status = HSread_rle_header( name,
                                     file_o_files,
                                     context_no,
                                     lwin_no,
                                     color_plane,
                                     &rle_type,
                                     &Scannable,
                                     &hdr_planes,
                                     num_frames,
                                     &data_type_modifier,
                                     &wds_to_follow,
                                     &frames[num_frames],
                                     scale_factor,
                                     &ct_to_use,
                                     file_cmap,
                                     &ct_offset,
                                     &orientation);
#  if defined (XGL)
   pixel_size = (hdr_planes-1)/8 + 1;
#  endif

         if (status)
         {
            WLclear_window( lwin_no );
            return (status);
         }

         WLflush(lwin_no);
         status = HSread_raster_data( name,
                                      rle_type,
                                      wds_to_follow,
                                      Scannable,
                                      data_type_modifier,
                                      lwin_no,
                                      context_no,
                                      MouseX,
                                      MouseY,
                                      xlo,
                                      xhi,
                                      ylo,
                                      yhi,
                                      scale_factor,
                                      bufsiz,
                                      LineByLine,
                                      WindowErase,
                                      true_color,
                                      color_plane,
                                      context_info.base_depth,
                                      hdr_planes,
                                      ct_to_use,
                                      file_cmap,
                                      ct_offset,
                                      orientation );

         if (status == OUT_OF_MEMORY)
         {
            OutOfMemory = TRUE;
            goto NoOp3;
         }

#if DEBUG
         fprintf (stderr, "Image extents are...\n");
         fprintf (stderr, "min:(%d, %d)\tmax:(%d, %d)\n",
                  frames[num_frames].x_min, frames[num_frames].y_min,
                  frames[num_frames].x_max, frames[num_frames].y_max);
#endif

         /* Display each frame */

         if (!LineByLine)
         {
            if (WindowErase)
            {
               WLclear_window( lwin_no );
            }
            WLhide_cursor (lwin_no, 0);

#if DEBUG2
            fprintf (stderr, "Calling putpixelblock() with...\n");
            fprintf (stderr, "min:(%d, %d)\tmax:(%d, %d)\n",
                   frames[num_frames].x_min, frames[num_frames].y_min,
                   frames[num_frames].x_max, frames[num_frames].y_max);
#endif

            /* need to assign buffer data to a WLraster_data structure */

            xdiff = (frames[num_frames].x_max - frames[num_frames].x_min) + 1;
            ydiff = (frames[num_frames].y_max - frames[num_frames].y_min) + 3;

            WLcreate_raster_data( lwin_no,
                                  context_no,
                                  &frame_data[num_frames],
                                  frames[num_frames].x_min,
                                  frames[num_frames].y_min,
                                  xdiff,
                                  ydiff,
                                  pixel_size * 8,
                                  WL_SLOW_BUFFER,
                                  buffer[num_frames] );

            WLput_raster_data( lwin_no,
                               context_no,
                               &frame_data[num_frames] );
            frame_counter++;

         }
         else
         {
            frame_counter++;
            free( buffer[num_frames] );
         }

         /* if animating, re-save in proper format */

         if ((animate && LineByLine))
         {
            /* To avoid wrap-around, make sure frame data is not larger
             * than destination window. */

            if (frames[num_frames].y_max - frames[num_frames].y_min > yhi)
            {
               frames[num_frames].y_max = yhi;
               frames[num_frames].y_min = ylo;
            }

            if (frames[num_frames].x_max - frames[num_frames].x_min > xhi)
            {
               frames[num_frames].x_max = xhi;
               frames[num_frames].x_min = xlo;
            }

            /* Convert the displayed frame into proper format in virtual
             * memory. */

            xdiff = (frames[num_frames].x_max - frames[num_frames].x_min);
            ydiff = (frames[num_frames].y_max - frames[num_frames].y_min);

            buffer_size[num_frames] =  xdiff * ydiff * pixel_size;
            buffer[num_frames] = (char *)malloc( xdiff * ydiff * pixel_size);

            if( buffer[num_frames] )
            {
               if( freed_mem > 0 )
               {
                  freed_mem -= buffer_size[num_frames];
                  if( freed_mem < 0)
                  {
                     freed_mem = 0;
                  }
               }
            }

#if defined(ENV5)
            /* At this time, Environ V double buffering DOES NOT work with */
            /* getrasterblock and restorerasterblock on an EDGEII.  Use    */
            /* slow buffering if compiling with Environ V.                 */

            WLcreate_raster_data( lwin_no,
                                  context_no,
                                  &frame_data[num_frames],
                                  frames[num_frames].x_min,
                                  frames[num_frames].y_min,
                                  xdiff,
                                  ydiff,
                                  pixel_size * 8,
                                  WL_SLOW_BUFFER,
                                  buffer[num_frames] );
#else
            WLcreate_raster_data( lwin_no,
                                  context_no,
                                  &frame_data[num_frames],
                                  frames[num_frames].x_min,
                                  frames[num_frames].y_min,
                                  xdiff,
                                  ydiff,
                                  pixel_size * 8,
                                  WL_FAST_BUFFER,
                                  buffer[num_frames] );
#endif
            WLget_raster_data( lwin_no,
                               context_no,
                               &frame_data[num_frames] );

#if DEBUG2
        fprintf (stderr, "buffer_no[%d] = %x saved from (%d, %d) to (%d, %d)\n",
                          Frames,
                          buffer_no[num_frames],
                          frames[num_frames].x_min,
                          frames[num_frames].y_min,
                          frames[num_frames].x_max,
                          frames[num_frames].y_max);
#endif
         }      /* end of if( animate ) */

         WLshow_cursor (lwin_no);
         WLflush (lwin_no);

#if DEBUG
         fprintf (stderr, "Frame %d displayed\n", Frames);
#endif
      }   /* end : if Frames== MAX_FILES else ... */

      /* get next file name */
      status2 = fscanf ( name_file_ptr, "%s\n", name );

      if( !jnl_playback )
      {
         stop = IGEstop();
      }

      if (!stop)
      {
         if (delay && FrameDelay > 0.0 && num_frames > 0)
         {
            HSwait (FrameDelay);
         }
      }

      /* Check for STOP hit during the wait */

      if( jnl_playback && load_stop )
      {
         if( num_frames_displayed == frame_counter )
         {
            stop = TRUE;
         }
      }
      else if( !jnl_playback )
      {
         stop = IGEstop();
         if( stop && journaling )
         {
            frame_counter *= -1;
            JNL_record_info_event( JNL_STOPSIGN,
                                   0,
                                  (char *)&frame_counter );
         }
      }

      if (stop && animate)
      {
NoOp3:
         ex$message (msgnumb = HS_P_ContAnimExit, justification = CENTER_JUS);
         IGEresetstop ();
         stop = FALSE;

         MouseTap = HSget_mouse_tap ();
         ex$message (in_buff = "", field = PROMPT_FIELD);
         switch (MouseTap)
         {
            case LEFT_BUTTON:
            case DOUBLE_LEFT_BUTTON:
               if (num_frames == 0)
               {
                  /* No animate for one frame */
                  goto NoOp3;
               }
               num_frames++;
               break;
            case MIDDLE_BUTTON:
            case DOUBLE_MIDDLE_BUTTON:
               if (OutOfMemory)
               {
                  /* Can't continue to load; out of memory */
                  ex$message (msgnumb = HS_E_ErrAllocMem, field = ERROR_FIELD);
                  goto NoOp3;
               }

               if ( jnl_playback )
               {
                  num_frames_displayed = HSread_num_frames_from_journal( TRUE );
                  if ( (num_frames_displayed > 0) &&
                       (num_frames_displayed <= MAX_FILES) )
                  {
                     load_stop = TRUE;
                  }
               }
               frame_counter = 0;
               continue;
            case RIGHT_BUTTON:
            case DOUBLE_RIGHT_BUTTON:
               /* exit animate/slide-show */
               fclose (name_file_ptr);
               if (ch != '~')
               {
                  EX_rm (file_o_files);
               }

               WLclear_window( lwin_no );
               HSfree_buffers( animate );
               return (EXIT);
            }
         break;
      }
      IGEresetstop ();
      stop = FALSE;
   }
   fclose (name_file_ptr);

   if (ch != '~')
   {
      EX_rm (file_o_files);
   }

   return(0);

}   /* HSread_rle_files */


/*---HSread_num_frames_from_journal-------------------------------------------*/


/*
NAME
      HSread_num_frames_from_journal

KEYWORD
      animate

DESCRIPTION
      This function is used to read the number of frames to be displayed from
      the journal file and return that number.

PARAMETERS
      load_stop (OUT) - lets caller know if number of frames to display is for
                        loading or displaying.

GLOBALS USED
      none

RETURN VALUES
      number of frames

HISTORY
      08/23/93 Created.   Bob Druzynski
*/


int HSread_num_frames_from_journal(IGRboolean  load_stop )
{

#ifndef X11
   int   event;
   int   type;
   int   num_frames=0;


   JNL_echo_input( 4, (char *)&event );
   if( event == JNL_INFO_EVENT )
   {
      /* if info event */
      JNL_echo_input( 4, (char *)&type );
      if( type == JNL_STOPSIGN )
      {
         /* if stopsign event */
         JNL_echo_input( 4, (char *)&num_frames );

         if( load_stop )
         {
            if( num_frames < 0 )
            {
               /* if loading and not all files loaded */
               num_frames =  ABS(num_frames);
            }
            else if( num_frames > 0)
            {
               /* if loading files and all the files in the list are to be   */
               /* loaded, reset the journal file and return num_frames +     */
               /* max_files                                                  */
               JNL_adjust_echo();
               JNL_adjust_echo();
               JNL_adjust_echo();
               num_frames += MAX_FILES;
            }
         }
      }
      else
      {
         JNL_adjust_echo();
         JNL_adjust_echo();
      }
   }
   else
   {
      JNL_adjust_echo();
   }
   return( num_frames );

#else

   XEvent   journal_info;
   int      num_frames = 0;

   JNL_read_next_event( &journal_info );

   if( (journal_info.type == JNL_INFO_EVENT ) &&
       (journal_info.xany.serial == JNL_WINDOW_CHANGE) )
   {
      /* stopsign event */

      num_frames = journal_info.xany.window;

      if( load_stop )
      {
         if( num_frames < 0 )
         {
            /* if loading and not all files loaded */
            num_frames =  ABS(num_frames);
         }
         else if( num_frames > 0)
         {
            /* if loading files and all the files in the list are to be   */
            /* loaded, reset the journal file and return num_frames +     */
            /* max_files                                                  */
            num_frames += MAX_FILES;
            fseek( JNL_echo, -(sizeof( XEvent )), 1);
         }
      }
   }
   else
   {
      /* need to "jump back" in the file */
      fseek( JNL_echo, -(sizeof( XEvent )), 1);
   }

   return( num_frames );

#endif
}

