/*----
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPdynamics

          Abstract:   This routine is the interface to all dynamics


----
%SC%

     VALUE = DPdynamics(dyn_fun,addnal_info)


----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------
      (*dyn_fun)()      IGRchar                 pointer to the function
                                                that willhandle dynamics


      *addnal_info      IGRchar                 information to be passed
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

----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------


        This routine will set up the screen for dynamics by enabling only
        the fifth plane.  It will then moniter the mouse position and
        call the appropriate funtion to modify the element and then
        depending on the global flag mod_flag. This routine will be
        terminated by a non-window icon event.

---*/
/*EH*/



class implementation IGEgragad;


#include "grimport.h"
#include "exdef.h"
#include "ex.h"

#include "wl.h"

#include "exmacros.h"
#include "igetypedef.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "gr.h"
#include "dppriv.h"
#include "madef.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "execmsg.h"
#include "igeterm.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "SSdef.h"
#include "SS.h"
#include "SSmacros.h"

/* prototype include files */
#include "dpdynamics.h"
#include "dpdynsup.h"
#include "maidmx.h"
#include "GRdpbfunc.h"

extern int NDexec_batch( IGRint, IGRint );


extern IGRint DPdyn_set_up(
    struct DP_information       *dp_info,
    struct DPgad_in_win         *win_info,
    IGRint                      *win,
    IGRint                      *num_win,
    IGRint                      *num_gra_gad );

extern int	SSIsActive( void );

#include "COgetevent.h"
#include "dpdyncvtpnt.h"

extern IGRboolean dynamics_in_progress;

#if defined( X11 )

extern Display *EXdisplay;

#define input_avail     (JNL_XPending(EXdisplay))

#define INPUT_EVENTS    (0)

#elif defined( ENV5 )

static IGRint event_flags;

#define INPUT_EVENTS    (BUTTON_EVENT | KEYBOARD_EVENT | TIMER_EVENT | MOTION_EVENT)

#define WINDOW_EVENTS   (REFRESH_EVENT | DELETE_EVENT | COVER_EVENT | \
                         COLLAPSE_EVENT)

#define input_avail     (EX_inq_events(&event_flags),(event_flags & INPUT_EVENTS))

#endif


/* This macro cleans up dynamics by calling DPdisp_dyn with the erase flag set to TRUE */
/* This will cause DPdisp_dyn() to either clear the hilite plane -OR- redraw the       */
/* dynamics buffer to clear when using XOR                                             */
#define CLEAN_UP_DYNAMICS( ind, lwin )                                                            \
                                                                                                  \
        DPdisp_dyn( num_of_screens,num_phy_screens,                                               \
                    dynamics_all_windows,actual_cursor,(lwin),objects,                            \
                    buffers,mod_info,out_flags,dp_info,                                           \
                    num_gra_gad,num_objects,num_buffers,                                          \
                    NULL,no_cursor,num_windows,win,(ind),&uor_point,mat,old_dit_point, TRUE );    \
                                                                                                  \
        if ( dyn_fun1 )                                                                           \
        {                                                                                         \
           DPdisp_dyn( num_of_screens,num_phy_screens,                                            \
                       dynamics_all_windows,actual_cursor,(lwin),objects1,                        \
                       buffers1,mod_info,out_flags1,dp_info,                                      \
                       num_gra_gad,num_objects1,num_buffers1,                                     \
                       NULL,no_cursor,num_windows,win,(ind),&uor_point,mat,old_dit_point, TRUE ); \
        }                                                                                         \

/*
 * This macro determines if a constraint type is a keypoint; if it is not, 
 * then we do not want to update the last_point with the constraint point when
 * text is entered during dynamics with SmartSketch (e.g. DX=1,1,0)
 */
#define DP_IS_SSKEYPOINT(ctype)    \
  ( (ctype == SSONELEMENT   ) ||   \
    (ctype == SSCENTER      ) ||   \
    (ctype == SSINTERSECT   ) ||   \
    (ctype == SSFIRSTPOINT  ) ||   \
    (ctype == SSLASTPOINT   ) ||   \
    (ctype == SSKEYPOINT    ) ||   \
    (ctype == SSMIDPOINT    ) ||   \
    (ctype == SSXINTERSECT  ) ||   \
    (ctype == SSHVERTICAL   ) ||   \
    (ctype == SSVHORIZONTAL )    )
    

#if defined( X11 )
extern int DPhandle_event( XEvent * );
#endif 

/*--- DPdynamics ------------------------------------------------------*/

IGRint DPdynamics( 
                          IGRint( *dyn_fun ) (  ),
                          IGRchar * addnal_info,
                          IGRint * flags,
                          IGRint( *dyn_fun1 ) (  ),
                          IGRchar * addnal_info1 )

{
  IGRlong msg;
  IGRlong nret;
  IGRint pnt_status;
  struct GRid mod_id;
  IGRdouble point[3];
  struct EX_button uor_point;
  IGRint old_dit_point[2];
  IGRint dit_point[3];
  IGRlong status, status1 = 0;
  enum GRdpmode disp_mode;
  IGRint i;
  IGRint dyn_x;
  IGRint dyn_y;
  IGRint wfl = 1;
  IGRint old_x = -1;
  IGRint old_y = -1;
  WLuint32 lwin_no = WL_UNDEFINED_WINDOW;
  WLuint32 old_lwin = WL_UNDEFINED_WINDOW;
  IGRint num_objects = 0, num_objects1 = 0;
  IGRint num_buffers = 0, num_buffers1 = 0;
  IGRint cal_on_invld_pnt = FALSE;
  IGRint cal_on_crsr_not_mvd = FALSE;
  IGRint no_cursor = FALSE;
  IGRint actual_cursor = FALSE;
  IGRint exit_on_any_input = FALSE;
  IGRint cleaned_up = TRUE;
  struct DPele_header *buffers, *buffers1;
  struct GRid *objects = NULL, *objects1 = NULL;
  struct GRmdenv_info *mod_info = NULL;
  IGRchar *out_dum3;
  IGRchar in_dum2, in_dum3;
  IGRint in_flags = 0;
  IGRint out_flags = 0, out_flags1 = 0;
  IGRint num_of_screens;
  IGRint num_phy_screens;
  IGRlong bufsize = sizeof( IGRboolean );
  IGRboolean cursor_hidden;
  IGRboolean ovrride = 0;
  IGRboolean dynamics_on;
  IGRboolean dynamics_all_windows;
  IGRboolean dynamics_copy;
  IGRdouble mat[16];
  IGRint win[EX_MAX_WINDOW];
  IGRint index;
  IGRint old_index = 0;
  GRobjid win_id;
  struct DP_information dp_info[EX_MAX_WINDOW];
  struct DPgra_gad window[EX_MAX_WINDOW];
  struct DPgad_in_win win_info[EX_MAX_WINDOW];
  IGRint num_windows;
  IGRint num_gra_gad;
  IGRint quiet_flag;
  IGRint event_sts;

#if defined( X11 )
  XEvent ev;
  int window_event =0;
#endif

  if ( flags )
  {
    /* flag that tells to exit on any input and also used to indicate in */
    /* tracking cursor mode                                          */
    exit_on_any_input = *flags & DP_EXIT_ON_ANY_INPUT;
  }

  if ( exit_on_any_input )
  {
    if ( input_avail || ex$peek_event_queue(  ) )
    {
      return ( 1 );
    }
  }

#if defined( ENV5 )
  if ( !EX_dyn_process_input_event( INPUT_EVENTS ) )
  {
    return ( 1 );
  }
#endif


  if ( flags )
  {
    ovrride = *flags & DP_AUTO_DYN;
  }


  ex$disp_flag( flag = &quiet_flag );


  gr$get_dynamics_on( msg = (IGRint *)(&msg),
                      sizbuf = (IGRint *)(&bufsize),
                      buffer = (IGRchar *)(&dynamics_on),
                      nret = (IGRint *)(&nret ));


  gr$get_dynamics_all_windows( msg = (IGRint *)(&msg),
                               sizbuf = (IGRint *)(&bufsize),
                               buffer = (IGRchar *)(&dynamics_all_windows),
                               nret = (IGRint *)(&nret) );


  if ( ( dynamics_on || ovrride ) && !quiet_flag )
  {

    ige$get_num_screens( num_of_screens = &num_of_screens );

    ige$get_num_phy_screens( num_phy_screens = &num_phy_screens );

    /* 
     * execute the batch queue if the dynamics copy flag is on; this must
     * be done before the dynamics_in_progress flag is set so that the the
     * batch erases and displays the affected elements 
     */

    gr$get_dynamics_copy_flag( msg = (IGRint *)(&msg),
                               sizbuf = (IGRint *)(&bufsize),
                               buffer = (IGRchar *)(&dynamics_copy),
                               nret = (IGRint *)(&nret) );
    if ( dynamics_copy )
    {
      nd$exec_batch(  );
    }

    dynamics_in_progress = TRUE;

    if ( flags )
    {
      no_cursor = *flags & DP_NO_CURSOR;

      if ( !no_cursor )
      {
        actual_cursor = *flags & DP_ACTUAL_CURSOR;
      }

      if ( *flags & DP_CUR_NOT_CHG )
      {
        cal_on_crsr_not_mvd = TRUE;
      }

      if ( *flags & DP_IGN_INV_PNT )
      {
        cal_on_invld_pnt = TRUE;
      }

      if ( *flags & DP_USE_WIN_FLAG )
      {
        dynamics_all_windows = ( *flags & DP_ALL_WINDOWS );
      }
    }

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

    disp_mode = GRhd;
    ex$get_cur_mod( id = &mod_id.objid, osnum = &mod_id.osnum );
    uor_point.osnum = mod_id.osnum;

    /*
     * get all the window objects that are connected to this module's channel 
     */
    /*
     * this function calls WLenter_dynamics() 
     */
    DPdyn_set_up( dp_info, win_info, win, &num_windows, &num_gra_gad );

    /* continue until a non-window icon event happens  */
    old_dit_point[0] = -1;
    old_dit_point[1] = -1;
    cursor_hidden = FALSE;
    while ( !ex$peek_event_queue(  ) && ( vsd_empty ) )
    {
        if ( exit_on_any_input )
        {
          break;
        }

#if defined( X11 )
        if ( !input_avail )
        {
          window_event = 0;
        }
        else
        {
          JNL_XPeekEvent( EXdisplay, &ev );
          while ( ev.type == NoExpose ) 
          {
             XNextEvent( EXdisplay, &ev );
             JNL_XPeekEvent( EXdisplay, &ev );
          }
          if ( ev.type == Expose ||
               ev.type == VisibilityNotify ||
               ev.type == GravityNotify ||
               ev.type == ReparentNotify ||
               ev.type == ConfigureNotify ||
               ev.type == MapNotify ||
               ev.type == UnmapNotify ||
               ev.type == DestroyNotify ||
               ev.type == ClientMessage )
          {
             window_event = 1;
          }
          else
          {
             window_event = 0;
          }

          if ( window_event )
          {
             /* Exit dynamics and set the drawing mode */
             for ( i = 0; i < num_windows; i++ )
             {
                WLexit_dynamics( win[i] );
             }
          }
#elif defined( ENV5 )
      if ( input_avail )
      {
        for ( i = 0; i < num_windows; i++ )
        {
           WLexit_dynamics( win[i] );
        }
#endif
        event_sts = EX_dyn_process_input_event( INPUT_EVENTS );
        DPdyn_set_up( dp_info, win_info, win, &num_windows, &num_gra_gad );

        if ( !event_sts )
        {
          /*
           *  SMART MOUSE support for precision delta keyins (i.e. DX= )
           */
          if (ss$is_active())
          {
#if defined( ENV5 )
            if (event_flags & KEYBOARD_EVENT )
#else
            if (ev.type == KeyPress )
#endif
            {
              /*
               *  update the last point parm in the DPB with Smart Point
               *  in the event that a delta keying event is about to
               *  be requested.
               */
              if (SSLastAvailable && DP_IS_SSKEYPOINT(SSLastConstraintType))
              {
                struct EX_button button;
                gr$get_last_point( buffer = (IGRchar *)(&button) );
                button.x = SSLastConstraintPoint [0];
                button.y = SSLastConstraintPoint [1];
                button.z = SSLastConstraintPoint [2];
                gr$put_last_point( buffer = (IGRchar *)(&button) );

                /* this next step is critical!  we have to pretend the last
		 * constraint never happened so that when co$getevent calls
		 * SSCheckEvent, it will not undo the results of the delta
		 * keyin command (whose event it will have received )
		 */
                SSLastAvailable = FALSE;
                break;
              }
         }
#if defined( ENV5 )
            else if (event_flags & BUTTON_EVENT)
#else
            else if (ev.type == ButtonPress )
#endif
            {
              break;
            }
          }
          break;
        }
      }      /* end: if (input_avail) */

#if defined( X11 )
      if ( window_event )
#elif defined( ENV5 )
      if ( event_flags & WINDOW_EVENTS )
#endif
      {
        /* an window icon event occured  */
        DPset_message_disp( FALSE );

        /* turn off dynamics in WL to handle the event properly */
        for ( i = 0; i < num_windows; i++ )
        {
          WLexit_dynamics( win[i] );
        }

        /* call the routine that handles the window icon events */
#if defined( X11 )
        DPhandle_event( &ev );
#elif defined( ENV5 )
        DPhandle_event(  );
#endif

        /* reset dynamics in all of the windows => remember that this */
        /* calls WLenter_dynamics                                     */
        DPdyn_set_up( dp_info, win_info, win, &num_windows, &num_gra_gad );
        cursor_hidden = FALSE;
      }
      else
      {
        /* check the current mouse position   */
        WLmouse_win_position ( &lwin_no, &dyn_x, &dyn_y, &wfl );

        if ( ( ( dyn_x != old_x      ) || 
               ( dyn_y != old_y      ) ||
               ( lwin_no != old_lwin ) || 
               ( cal_on_crsr_not_mvd ) ) &&
             ( wfl != 0 ) )
        {
          old_x = dyn_x;
          old_y = dyn_y;

          /* Is the mouse in a window associated with this module?  */
          if ( DPdyn_ret_index( dyn_x, dyn_y, lwin_no, num_windows, 
                                dp_info, win_info, &index, &win_id ) )
          {
            if ( old_lwin != lwin_no )
            {
              /* the cursor changed windows */
              if ( !( dynamics_all_windows ) )
              {
                if ( !cleaned_up )
                {
                  CLEAN_UP_DYNAMICS( old_index, old_lwin );
                  cleaned_up = TRUE;
                }
              }
              cursor_hidden = FALSE;
            }

            /* convert point  */
            point[0] = ( IGRdouble ) dyn_x;
            point[1] = ( IGRdouble ) dyn_y;

            uor_point.objid = win_id;
            uor_point.window = lwin_no;
            pnt_status = DPdyn_conv_pnt( &msg,
                                          dp_info[index].gragad, 
                                          point,
                                          dit_point,
                                         &uor_point,
                                          mod_id.osnum );

            if ( pnt_status || cal_on_invld_pnt )
            {
              if ( ( old_dit_point[0] != dit_point[0] ||
                     old_dit_point[1] != dit_point[1] ) ||
                     cal_on_crsr_not_mvd )
              {
                if ( !cursor_hidden )
                {
                  if ( !actual_cursor )
                  {
                    WLhide_cursor( lwin_no, TRUE );
                    cursor_hidden = TRUE;
                  }
                  WLflush( lwin_no );
                }

                /* erase the old buffer */
                if ( !cleaned_up )
                {
                  CLEAN_UP_DYNAMICS( old_index, old_lwin );
                  cleaned_up = TRUE;
                  cursor_hidden = FALSE;
                }

                old_dit_point[0] = dit_point[0];
                old_dit_point[1] = dit_point[1];

                status = (*dyn_fun)( addnal_info, 
                                    &uor_point,
                                     dp_info[index].gragad->rotation,
                                    &objects, 
                                    &num_objects,
                                    &buffers,
                                    &num_buffers,
                                    &in_flags, 
                                    &in_dum2, 
                                    &in_dum3,
                                    &out_flags,
                                    &mod_info, 
                                    &out_dum3 );

                /* call the second dynamics */
                if ( dyn_fun1 )
                {
                  status1 = (*dyn_fun1)( addnal_info1, 
                                        &uor_point,
                                         dp_info[index].gragad->rotation,
                                        &objects1, 
                                        &num_objects1,
                                        &buffers1,
                                        &num_buffers1,
                                        &in_flags, 
                                        &in_dum2, 
                                        &in_dum3,
                                        &out_flags1, 
                                        &mod_info, 
                                        &out_dum3 );
                }

                if ( status == DP_EXIT_DYNAMICS )
                {
                  goto wrapup;
                }

                if ( status & 1 )
                {
                  cleaned_up = FALSE;

                  DPdisp_dyn( num_of_screens, 
                              num_phy_screens,
                              dynamics_all_windows,
                              actual_cursor,
                              lwin_no, 
                              objects, 
                              buffers, 
                              mod_info, 
                              out_flags,
                              dp_info,
                              num_gra_gad,
                              num_objects,
                              num_buffers,
                              NULL, 
                              no_cursor,
                              num_windows, 
                              win, 
                              index, 
                             &uor_point,
                              mat, 
                              dit_point,
                              FALSE );

                  if ( dyn_fun1 && ( status1 & 1 ) )
                  {
                    out_flags1 |= DP_DONT_ERASE;

                    DPdisp_dyn( num_of_screens, num_phy_screens,
                                dynamics_all_windows, actual_cursor,
                                lwin_no, objects1, buffers1, mod_info,
                                out_flags1, dp_info, num_gra_gad,
                                num_objects1, num_buffers1, NULL, 
                                no_cursor, num_windows, win, index,
                                &uor_point, mat, dit_point, FALSE );
                  }
                  /*
                   * CALL SMART SKETCH: does nothing if !ss$is_active()
                   */
		  if (ss$is_active())
		  {
		    extern int SSSketch( struct EX_button * );
                    SSSketch(&uor_point);
		  }
                }

                if ( cursor_hidden )
                {
                  if ( !actual_cursor )
                  {
                    WLshow_cursor( lwin_no );
                    cursor_hidden = TRUE;
                  }
                  WLflush( lwin_no );
                }
              }       /* end of if (old_dit_point)  */
            }  /* end of if (pnt_status  */
          }
          else
          {
            /* !!! redraw buffer in old window !!! */
            if ( old_lwin != lwin_no )
            {
              if ( !cleaned_up )
              {
                CLEAN_UP_DYNAMICS( old_index, old_lwin );
                cleaned_up = TRUE;
                cursor_hidden = FALSE;
              }
            }
          }

          old_index = index;
          old_lwin = lwin_no;
        }
        else
        {
          /* either the cursor did not move or we are in a border */
          /* if not in window clean up windows  */
          if ( wfl == 0 )
          {
            if ( !cleaned_up )
            {
              CLEAN_UP_DYNAMICS( old_index, old_lwin );
              cleaned_up = TRUE;
              cursor_hidden = FALSE;
            }
          }
        }

      }   /* end of else of event flags */

    } /* end of while input avail */

wrapup:

    /* this must be before 'dynamics_in_progress' is set to FALSE */
    if ( !cleaned_up )
    {
      CLEAN_UP_DYNAMICS( index, lwin_no );
      cleaned_up = TRUE;
      cursor_hidden = FALSE;
    }

    for ( i = 0; i < num_gra_gad; i++ )
    {
      WLexit_dynamics( dp_info[i].win_no );
      WLshow_cursor( dp_info[i].win_no );
    }

    dynamics_in_progress = FALSE;
    ex$message( msgnumb = EX_S_Clear );
    DPset_message_disp( FALSE );

  }

  return ( 1 );

}  /* DPdynamics */

IGRint DPdynflags( msg, set_inq, dyn_on, all_windows )


   IGRlong *msg;
   IGRboolean *set_inq;
   IGRboolean *dyn_on;
   IGRboolean *all_windows;

{
   IGRlong nret;
   IGRlong bufsize = sizeof( IGRboolean );

   if ( !( *set_inq ) )
   {
      if ( dyn_on )
      {
         gr$put_dynamics_on( msg = (IGRint *)(&msg),
                             sizbuf = (IGRint *)(&bufsize),
                             buffer = (IGRchar *)(dyn_on) );
      }

      if ( all_windows )
      {
         gr$put_dynamics_all_windows( msg = (IGRint *)(&msg),
                                      sizbuf = (IGRint *)(&bufsize),
                                      buffer = (IGRchar *)(all_windows) );
      }
   }
   else
   {
      if ( dyn_on )
      {
         gr$get_dynamics_on( msg = (IGRint *)(&msg),
                             sizbuf = (IGRint *)(&bufsize),
                             buffer = (IGRchar *)(dyn_on),
                             nret = (IGRint *)(&nret) );
      }

      if ( all_windows )
      {
         gr$get_dynamics_all_windows( msg = (IGRint *)(&msg),
                                      sizbuf = (IGRint *)(&bufsize),
                                      buffer = (IGRchar *)(all_windows),
                                      nret = (IGRint *)(&nret) );
      }

   }

   return ( 1 );

}/* DPdynflags  */


end implementation IGEgragad;
