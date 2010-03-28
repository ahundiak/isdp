/*----
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPtxdynamics

          Abstract:   This routine is the dynamics interface to text


----
%SC%

     VALUE = DPtxdynamics(dyn_fun,addnal_info)


----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------
      (*dyn_fun)()	IGRchar			pointer to the function
                                                that will handle dynamics


      *addnal_info	IGRchar			information to be passed
                                                to dyn_fun

----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------      -----------------      --------------------------

----
%MD%

     MODULES INVOKED:

        None

----
%NB%

      NOTES:   None

----
%CH%

       AET   05/29/86   : Creation date
       Satish 07/12/95  : Fixed the cleaned_up flags and reversed the order
			  of display and erasure of the buffer to resolve
			  grid locking. TR#119524713.

----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------


        This routine will set up the screen for dynamics by enabling only
        the fifth plane.  It will then moniter the mouse position and
        call the appropriate funtion to modify the element and then
        this routine will display the element in all of one window
        depending on the global flag mod_flag. This routine will be
        terminated by a non-window icon event.

---*/
/*EH*/



class implementation IGEgragad;

#include "grimport.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "dppriv.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "madef.h"
#include "msdef.h"
#include "msmacros.h"
#include "execmsg.h"
#include "igeterm.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "exlocale.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "wl.h"
#include "fi.h"

/* prototype files */
#include "dptxdynamics.h"
#include "GRdpbfunc.h"
#include "RAPinlisnri.h"
#include "dpdyncvtpnt.h"
#include "dpdynsup.h"


#include "maidmx.h"

extern IGRint DPdyn_set_up(
    struct DP_information       *dp_info,
    struct DPgad_in_win         *win_info,
    IGRint                      *win,
    IGRint                      *num_win,
    IGRint                      *num_gra_gad );

extern IGRboolean dynamics_in_progress;
static IGRint win[EX_MAX_WINDOW];
static IGRint num_windows;

#if defined( ENV5 )
static IGRint event_flags;

#elif defined( X11 )
extern Display *EXdisplay;

extern int DPhandle_event( XEvent * );

#define EX_WIN_MASK (ButtonPressMask | ButtonReleaseMask | \
                     KeyPressMask    |  EnterWindowMask  | \
                     LeaveWindowMask | \
                     ExposureMask     |  StructureNotifyMask )

#define  input_avail     (JNL_XPending(EXdisplay))

/* special event mask for text dynamics honored by EXNUC */
#define INPUT_EVENTS     0x08880000

#endif

#if defined( ENV5 )
#define INPUT_EVENTS	(BUTTON_EVENT | TIMER_EVENT)

#define WINDOW_EVENTS	(REFRESH_EVENT | DELETE_EVENT | COVER_EVENT | \
			COLLAPSE_EVENT )

#define	input_avail	(EX_inq_events(&event_flags),(event_flags & INPUT_EVENTS))

#endif

/* The following function turns the dynamics drawing mode on/off */
/* in the dynamics drawing windows                               */

IGRint DPtxdyn_set_drawing_mode( WLuint32 mode )
{
   int i;
   
   for ( i = 0; i< num_windows; i++)
   {
      WLset_dynamics_drawing_mode( win[i], mode );
   }
}
   


IGRint DPtxdynamics( 
   IGRint( *dyn_fun )(),
   IGRchar *addnal_info,
   IGRchar *dummy1,
   IGRchar *dummy2,
   IGRchar *dummy3 )


{
   IGRlong msg;
   IGRint nret;
   IGRint bufsize = sizeof( IGRboolean );
   struct GRid mod_id;
   IGRdouble point[3];
   struct EX_button uor_point;
   IGRint old_dit_point[2];
   IGRint dit_point[3];
   IGRint first_char = TRUE;
   IGRint char_status;
   IGRint status;
   IGRint out_flags = 0; /*initialized to zero - Sat*/
   IGRlong pnt_status = 0;
   enum GRdpmode disp_mode;
   IGRint i;
   IGRint dyn_x;
   IGRint dyn_y;
   IGRint wfl = 1;
   IGRint old_x = -1;
   IGRint old_y = -1;
   IGRint num_of_screens;
   IGRint num_phy_screens;
   IGRboolean done = FALSE;
   IGRboolean dynamics_all_windows;
   IGRboolean char_flag = FALSE;
   IGRboolean point_flag = FALSE;
   IGRboolean valid_window = FALSE;
   IGRint num_objects = 0;
   IGRint num_buffers = 0;
   struct DPele_header *buffers;
   struct GRid *objects = NULL;  /* Purify fix */
   struct DPviewind *viewind;
   IGRboolean cursor_hidden;
   IGRdouble mat[16];
   IGRint index = 0;
   IGRint old_index = 0;
   IGRint cleaned_up = TRUE;
   GRobjid win_id;
   struct DP_information dp_info[EX_MAX_WINDOW];
   struct DPgra_gad window[EX_MAX_WINDOW];
   struct DPgad_in_win win_info[EX_MAX_WINDOW];
   IGRint num_gra_gad;
   IGRint quiet_flag;
   struct EX_logkbd_buf char_buf;
   WLuint32 lwin_no = WL_UNDEFINED_WINDOW;
   WLuint32 old_lwin = WL_UNDEFINED_WINDOW;
   int event_sts;
#if defined( X11 )
   XEvent ev;
#endif

   if ( !EX_dyn_process_input_event( INPUT_EVENTS ) )
   {
      return ( 1 );
   }

   ex$disp_flag( flag = &quiet_flag );

   if ( quiet_flag )
   {
      goto wrapup;
   }

   dynamics_in_progress = TRUE;
   DPset_text_dyn( TRUE );

   gr$get_dynamics_all_windows( msg = ( IGRint * ) & msg,
                                sizbuf = &bufsize,
                                buffer = ( IGRchar * ) & dynamics_all_windows,
                                nret = &nret );


   ige$get_num_screens( num_of_screens = &num_of_screens );

   ige$get_num_phy_screens( num_phy_screens = &num_phy_screens );


   dp_info[0].gragad = &window[0];
   dp_info[0].is_hidden_line = FALSE;
   dp_info[0].is_update = FALSE;
   dp_info[0].is_fit = FALSE;
   dp_info[0].hline_info = NULL;
   dp_info[0].hl_tiler = NULL;
   for ( i = 1; i < EX_MAX_WINDOW; i++ )
   {
      dp_info[i] = dp_info[0];
      dp_info[i].gragad = &window[i];
   }


   MAidmx( &msg, mat );

   old_dit_point[0] = -1;
   old_dit_point[1] = -1;
   disp_mode = GRhd;
   ex$get_cur_mod( id = &mod_id.objid, osnum = &mod_id.osnum );
   uor_point.osnum = mod_id.osnum;


   /* get all the window objects that are connected to this module's channel */
   DPdyn_set_up( dp_info, win_info, win, &num_windows, &num_gra_gad );
   cursor_hidden = FALSE;

   /* continue until a non-window icon event happens  */
   while ( !ex$peek_event_queue(  ) && !done )
   {

      if ( input_avail )
      {
         for ( i = 0; i < num_windows; i++ )
         {
            WLexit_dynamics( win[i] );
         }

         event_sts = EX_dyn_process_input_event( INPUT_EVENTS );
         DPdyn_set_up( dp_info, win_info, win, &num_windows, &num_gra_gad );
         if ( !event_sts )
         {
            break;
         }

      }
#if defined( X11 )
      if ( JNL_XCheckMaskEvent( EXdisplay, ExposureMask | VisibilityChangeMask
                                | StructureNotifyMask, &ev ) )
#elif defined( ENV5 )
      if ( ( event_flags ) & ( WINDOW_EVENTS ) )
#endif

      {
         /* a window icon event occured  */

         for ( i = 0; i < num_windows; i++ )
         {
            WLexit_dynamics( win[i] );
         }

         DPset_message_disp( FALSE );

         /* call the routine that handles the window icon events   */

#if defined( X11 )
         DPhandle_event( &ev );
#elif defined( ENV5 )
         DPhandle_event();
#endif

         /* need to see which windows are still on the module channel  */
         /* remember that this function calls WLenter_dynamics()       */
         DPdyn_set_up( dp_info, win_info, win, &num_windows, &num_gra_gad );

         cursor_hidden = FALSE;

      }
      else
      {

#if defined( X11 )
         if ( JNL_XCheckMaskEvent( EXdisplay, KeyPressMask, &ev ) )
#elif defined( ENV5 )
         if ( event_flags & KEYBOARD_EVENT )
#endif
         {

            if ( first_char )
            {
#if defined( X11 )
               char_status = EX_get_kybd_data( &ev, &char_buf, EX_ALL_ASCII_MODE, 1 );
#elif defined( ENV5 )
               char_status = EX_get_kybd_data( &char_buf, EX_ALL_ASCII_MODE, 1 );
#endif
               RAP_get_keyboard_data( char_buf.data.buffer, char_buf.nbytes );
               first_char = FALSE;
            }
            else
            {
#if defined( X11 )
               char_status = EX_get_kybd_data( &ev, &char_buf, EX_ALL_ASCII_MODE, 0 );
#elif defined( ENV5 )
               char_status = EX_get_kybd_data( &char_buf, EX_ALL_ASCII_MODE, 0 );
#endif
               RAP_get_keyboard_data( char_buf.data.buffer, char_buf.nbytes );
            }

            if ( char_status == 1 )
            {
               char_flag = TRUE;
            }
            else
            {
               if ( ( char_status == 2 ) || ( char_status == 3 ) )
               {
                  done = TRUE;
               }
            }


         }

         /* check the current mouse position   */
         if ( JNL_playback(  ) )
         {
            valid_window = FALSE;
            uor_point.objid = NULL_OBJID;
            lwin_no = old_lwin;
            wfl = FALSE;
            dyn_x = old_x;
            dyn_y = old_y;
         }
         else
         {
            WLmouse_win_position( &lwin_no, &dyn_x, &dyn_y, &wfl );
         }

         /* check to see if cursor has moved  */

         if ( ( dyn_x != old_x ) || ( dyn_y != old_y ) || (wfl != 0))
         {
  
            old_x = dyn_x;
            old_y = dyn_y;

            if ( DPdyn_ret_index( dyn_x, dyn_y, lwin_no, num_windows, dp_info, win_info, &index, &win_id ) )
            {
               valid_window = TRUE;

	       /* If buffer has been cleaned, display it - Sat */

               if (( cleaned_up ) || ( lwin_no != old_lwin ) )
               {
                  DPdisp_dyn( num_of_screens, num_phy_screens,
                              dynamics_all_windows, FALSE,
                              old_lwin, objects, buffers, NULL, out_flags, dp_info,
                              num_gra_gad, num_objects, num_buffers,
                              viewind, FALSE, num_windows, win, old_index, &uor_point, mat,
                              old_dit_point, FALSE); 
                  cleaned_up = FALSE;
               }

               /* convert point  */

               point[0] = ( IGRdouble ) dyn_x;
               point[1] = ( IGRdouble ) dyn_y;

               uor_point.objid = win_id;
               uor_point.window = lwin_no;

               pnt_status = DPdyn_conv_pnt( &msg,
                                            dp_info[index].gragad, point,
                                            dit_point, &uor_point, mod_id.osnum );


               if ( ( old_dit_point[0] != dit_point[0] ||
                      old_dit_point[1] != dit_point[1] ) && pnt_status )
               {
                  point_flag = TRUE;
               }
            }
            else
            {
               uor_point.objid = NULL_OBJID;
               valid_window = FALSE;
            }
         }

         if ( char_flag || ( point_flag && pnt_status ) && !done )
         {
            if ( !cursor_hidden && valid_window )
            {
               WLhide_cursor( lwin_no, TRUE );
               cursor_hidden = TRUE;
            }

            old_dit_point[0] = dit_point[0];
            old_dit_point[1] = dit_point[1];

            out_flags = 0;
            viewind = NULL;

            if ( char_flag )
            {
               status = (*dyn_fun)( addnal_info, &uor_point, &point_flag,
                                    char_buf.data.buffer, char_buf.nbytes, &char_flag,
                                    dp_info[index].gragad->rotation,
                                    &objects, &num_objects, &buffers, &num_buffers,
                                    &out_flags, &viewind );
            }
            else
            {
               status = (*dyn_fun)( addnal_info, &uor_point, &point_flag,
                                    char_buf.data.buffer, 0, &char_flag,
                                    dp_info[index].gragad->rotation,
                                    &objects, &num_objects, &buffers, &num_buffers,
                                    &out_flags, &viewind );

            }

            if ( status )
            {
               if ( ( valid_window ) ||  ( point_flag ) )
               {
		  cleaned_up = TRUE;

                  if ( !cursor_hidden )
                  {
                     WLhide_cursor( lwin_no, TRUE );
                  }
		  

                  DPdisp_dyn( num_of_screens, num_phy_screens,
                              dynamics_all_windows, FALSE,
                              lwin_no, objects, buffers, NULL, out_flags, dp_info,
                              num_gra_gad, num_objects, num_buffers,
                              viewind, FALSE, num_windows, win, index, &uor_point, mat,
                              dit_point, TRUE ); 

               }     /* end of if (char_flag && valid_win....  */

            }        /* end of if ((*dyn_fun)     */
            else
            {
               if ( !cleaned_up )
               {
                  DPdisp_dyn( num_of_screens, num_phy_screens,
                              dynamics_all_windows, FALSE,
                              lwin_no, objects, buffers, NULL, out_flags, dp_info,
                              num_gra_gad, num_objects, num_buffers,
                              viewind, FALSE, num_windows, win, index, &uor_point, mat,
                              dit_point, TRUE );
                  cleaned_up = TRUE;
                  cursor_hidden = FALSE;
               }
               else
               {
                  if ( cursor_hidden )
                  {
                     WLshow_cursor( lwin_no );
                     WLflush( lwin_no );
   
                     cursor_hidden = FALSE;
                  }
               }
            }
         }

         if ( ( !valid_window ) || ( !pnt_status ) ) 
         {
            /* Clean up windows */
  
               DPdisp_dyn( num_of_screens, num_phy_screens,
                           dynamics_all_windows, FALSE,
                           old_lwin, objects, buffers, NULL, out_flags, dp_info,
                           num_gra_gad, num_objects, num_buffers,
                           viewind, FALSE, num_windows, win, old_index, &uor_point, mat,
                           old_dit_point, TRUE );
               cursor_hidden = FALSE;
               cleaned_up = TRUE;
         }

         old_index = index;
         old_lwin = lwin_no;
         }      /* end of else of event flags  */

      char_flag = FALSE;
      point_flag = FALSE;
   }    /* end of while input avail  */

wrapup:
   if ( !cleaned_up )
   {
      DPdisp_dyn( num_of_screens, num_phy_screens,
                  dynamics_all_windows, FALSE,
                  old_lwin, objects, buffers, NULL, out_flags, dp_info,
                  num_gra_gad, num_objects, num_buffers,
                  viewind, FALSE, num_windows, win, old_index, &uor_point, mat,
                  old_dit_point, TRUE );
   }

   for ( i = 0; i < num_windows; i++ )
   {
      WLexit_dynamics( win[i] );
      WLshow_cursor( win[i] );
      win[i] = WL_UNDEFINED_WINDOW;
   }

   num_windows = 0;
   dynamics_in_progress = FALSE;
   DPset_text_dyn( FALSE );
   ex$message( msgnumb = EX_S_Clear );
   DPset_message_disp( FALSE );

   return ( 1 );

}  /* DPtxdynamics */

end implementation IGEgragad;
