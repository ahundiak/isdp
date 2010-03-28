class implementation DPvd;

#include <stdio.h>
#include <math.h>
#include "bsdefs.h"
#include "OMmacros.h"
#include "exdef.h"
#include "exlocale.h"
#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "igrdef.h"
#include "go.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igewinmacros.h"

#include "DPvd.h"

#if defined( X11 )
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <sys/time.h>

extern Display *EXdisplay;

extern struct timeval EXtimeout;

#define MAP_X_BUTTON \
   switch ( xevent.xbutton.button ) \
   { \
      case Button1: *button = DPvd_LEFT_MOUSE; break; \
      case Button2: *button = DPvd_MIDDLE_MOUSE; break; \
      case Button3: *button = DPvd_RIGHT_MOUSE; break; \
   }

#endif



static char control_key[2];
static put_control_key_to_jnl;
		  
void DPvd_put_control_key_to_jnl()
/* 
   Because there is no way in ENV5 to check the 2 control keys and put
   them back in the event queue, we remember that we have consumed 2 control
   keys when checking the (C2,C3) buttons. Later we need to call this routine
   (after recording the DPvd_JNL_END) to put these non-C2,C3 control keys to 
   the journal file so that journal playback will work. 

   In the X11 case, the unused event can be put back to the event queue,
   so no need to used this special treatment.
*/
{
    IGRchar count = 1;
    
    if(put_control_key_to_jnl)
    {
#if defined( ENV5 )
	JNL_record_event ( KEYBOARD_EVENT );
	JNL_record_input ( 1, (char *) &count );
	JNL_record_input ( count, (char *) &control_key[0]);
	JNL_record_event ( KEYBOARD_EVENT );
	JNL_record_input ( 1, (char *) &count );
	JNL_record_input ( count, (char *) &control_key[1]);
#endif
	put_control_key_to_jnl = FALSE;
    }
}


/*--- DPvd_get_next_event ----------------------------------------*/

int DPvd_get_next_event(int mouse_movement, WLuint32 lwin_no,
			int *button, int *transition, int *x, int *y, 
                        int *hwwin)

/*
NAME
	DPvd_get_next_event

DESCRIPTION
	This function returns the next event from the appropriate event queue.
        Depending on the parameters it may either return only button
        events or also each mouse movement (when no button state
        has changed).
        It will only report button events from the mouse buttons
        and the buttons C2, B2, C3 (or PF1,shift PF1, PF2) respectivly.
        If any other event is found, the routine will put the
        event back onto the queue and return with 0.
       

SYNOPSIS
        extern int DPvd_get_next_event(int mouse_movement, WLuint32 lwin_no,
	                int *button, int *transition, int *x, int *y, 
                        int *hwwin);

PARAMETERS
        mouse_movement (IN) - FALSE, only button events are reported,
                              TRUE, also each mouse movement is reported.
        button (OUT)        - button which changed state or NO_BUTTON, if no button
                              has changed state (that is only mouse movement).
        transition (OUT)    - UP, DOWN,SINGLE_CLICK, DOUBLE_CLICK (if button state
                              has changed, else not used )
        x, y  (OUT)         - the integer screen position of the mouse
        lwin_no (OUT)       - the logical window number of the window
                              where the mouse position was in.
        hwwin (OUT)         - the hardware window number of the window
                              where the mouse position was in.

GLOBALS USED
	none

RETURN VALUES
        OM_S_SUCCESS - if the event was recognized
        other        - unknown event.

NOTES
        ** compare $GRNUC/src/co/displayco/DPvw_dyn.I

HISTORY
	06/08/93    G.Werner
	            Creation Date
	06/18/93    R.Burkhart
	            Adding Function Keys
	            Adding X11 Source
	08/23/93    T.Wang
	            Don't catch the B2 ( ) event.
*/

{
    static unsigned char *keyb_buf = NULL;
    static int bufsize;
    int count;
    IGRint in_window,key_button;

#if defined( X11 )
    int status;
    OMuword win_os;
    OM_S_OBJID win_oid;
    XEvent xevent, myevent, sec_event, saved_events[5];
    KeySym key_symb, sec_key_symb;
    Time prev_time;
    extern unsigned int EX_button_state;

#elif defined( ENV5 )
    int t_hwwin, t_button, t_transition, t_x, t_y;
    IGRint events, timetag;
    struct EX_logkbd_buf log_kbd;
    short event2;
#endif

    if ( ex$peek_event_queue() )
    {
       return( 0 );
    }

#if defined( X11 )
    while(TRUE)
    {
        if ( XPending( EXdisplay ) )
        {
           XNextEvent( EXdisplay, &xevent );
           if ( ( xevent.type == ButtonPress ) ||
                ( xevent.type == ButtonRelease ) )
           {
              if( EX_trans_win( xevent.xbutton.window, &lwin_no,
                               &win_os, &win_oid ) != 0 )
              {
                 XPutBackEvent( EXdisplay,&xevent );
                 return( 0 );
              }
           }

    
	if (xevent.type == ButtonRelease)	
	{ 
	    *transition=DPvd_UP;
	    /* get the (x,y) position */
	    *x = xevent.xbutton.x;
	    *y = xevent.xbutton.y;
	    /* get the mouse button */
	    MAP_X_BUTTON;
	    /* get the hardware window */
	    *hwwin =(int) xevent.xbutton.window;
	    /* get log. window number */
	    EX_trans_win ( *hwwin, &lwin_no, &win_os, &win_oid);
	    return OM_S_SUCCESS;
	}
	else if(xevent.type == ButtonPress)	
	{ 
            saved_events[0] = xevent;
	    /* get the (x,y) position */
	    *x = xevent.xbutton.x;
	    *y = xevent.xbutton.y;
	    /* get the mouse button */
	    MAP_X_BUTTON;
	    /* get the hardware window */
	    *hwwin =(int) xevent.xbutton.window;
	    /* get log. window number */
	    EX_trans_win ( *hwwin, &lwin_no, &win_os, &win_oid);

            *transition=DPvd_DOWN;
  	    EXtimeout.tv_usec=150000;
	    prev_time=xevent.xbutton.time;
            EX_button_state = xevent.xbutton.state;
            select(1,0,0,0,&EXtimeout);
	    EXtimeout.tv_usec=150000;
	    status= XCheckWindowEvent(EXdisplay,xevent.xbutton.window,
                                  		ButtonReleaseMask,&myevent);
	    if(status && (((unsigned int)myevent.xbutton.time - 
                            (unsigned int) prev_time)< 150))
	    {
                saved_events[1] = myevent;
		*transition=DPvd_SINGLE_CLICK;
    		prev_time=myevent.xbutton.time;
		select(1,0,0,0,&EXtimeout);
	        EXtimeout.tv_usec=150000;
   	        status=XCheckWindowEvent(EXdisplay, xevent.xbutton.window,
                                   		ButtonPressMask,&myevent);
  		if(status && (((unsigned int)myevent.xbutton.time -
                                               (unsigned int) prev_time)< 150))
                {
                   saved_events[2] = myevent;
	           *transition=DPvd_DOUBLE_DOWN;
		   prev_time=myevent.xbutton.time;
	           select(1,0,0,0,&EXtimeout);
		   EXtimeout.tv_usec=150000;
                   status=XCheckWindowEvent(EXdisplay,
                                        xevent.xbutton.window,
                                              ButtonReleaseMask,&myevent);
  		   if(status && (((unsigned int)myevent.xbutton.time -
                                             (unsigned int) prev_time)< 150))
               	   {
                       saved_events[3] = myevent;
		       *transition=DPvd_DOUBLE_CLICK;
		   }
	       }
	    }

            /* We are not handling double clicks, so no */
            /* need to keep these events, put them back */ 
            if ( *transition == DPvd_DOUBLE_CLICK )
            {
		XPutBackEvent(EXdisplay,&saved_events[3]);
		XPutBackEvent(EXdisplay,&saved_events[2]);
		XPutBackEvent(EXdisplay,&saved_events[1]);
		XPutBackEvent(EXdisplay,&saved_events[0]);
            }
            else
	    if(status && (((int)myevent.xbutton.time - (int) prev_time)> 150))
	    {
		/*if time difference > 150 need to out it back*/
		XPutBackEvent(EXdisplay,&myevent);
	    }
	}
	else  if (xevent.type == MotionNotify)
	  /* mouse motion event */ 
	{
	    if(! mouse_movement) continue;
            WLmouse_position(lwin_no, x, y, &in_window,&key_button);
	    *button = NO_BUTTON;
	}
	else  if (xevent.type == KeyPress)
	  /* check, if  function key input (C2,C3,...) */ 
	{
	    key_symb = XKeycodeToKeysym( EXdisplay, xevent.xkey.keycode, 0 );
	    switch (key_symb)
	    {
	      case XK_F2 :
		*button = C2;
		return OM_S_SUCCESS;
	      case XK_F3 :
		*button = C3;
		return OM_S_SUCCESS;

#ifdef NOTUSED
	/* 08/23/93, T.Wang: Don't catch B2 event */

	      case XK_Shift_L :
	      case XK_Shift_R :
		XNextEvent( EXdisplay, &sec_event );
	        if (xevent.type != KeyPress)
		{
		    /* no key except shift */
		    XPutBackEvent( EXdisplay,&sec_event );
		    XPutBackEvent( EXdisplay,&xevent );
     	       	    return 0; /* go out of dynamics */
		}
		else
		{
		    sec_key_symb = XKeycodeToKeysym( EXdisplay, sec_event.xkey.keycode, 0 );
		    if(sec_key_symb == XK_F2)
		    {
			*button = B2;
			return OM_S_SUCCESS;
		    }
		    else
		    {
			/* any other combination of SHIFT and key */
			XPutBackEvent( EXdisplay,&sec_event );
			XPutBackEvent( EXdisplay,&xevent );
			return 0; /* go out of dynamics */
		    }
		}
		break;
#endif
	      
	      default:
		/* other function keys will be put back to queue */
		XPutBackEvent(EXdisplay,&xevent);
		return 0; /*  other key, go out of dynamics */
	    }    
       }

       else if( ( XPending(EXdisplay) == 0 )||( xevent.type == EnterNotify )
               ||( xevent.type == FocusIn ) ||( xevent.type == LeaveNotify )
               ||( xevent.type == FocusOut )||( xevent.type == ColormapNotify )
               ||( xevent.type == Expose )  ||( xevent.type == NoExpose ) 
               ||( xevent.type == GraphicsExpose ) 
               ||( xevent.type == KeyRelease ) )
       {
           /* no event or not interested in such event */
           if(! mouse_movement) continue;
           WLmouse_position(lwin_no, x, y, &in_window,&key_button);
           *button = NO_BUTTON;
       }
       else if ( ( xevent.type == ConfigureNotify ) ||
                 ( xevent.type == DestroyNotify )   ||
                 ( xevent.type == UnmapNotify )     ||
                 ( xevent.type == ReparentNotify ) )
       {
	  DPhandle_event( &xevent );
	  *button = DPvd_WINDOW_EVENT;
	  return OM_S_SUCCESS;
       }
       else
       {
	   XPutBackEvent(EXdisplay,&xevent);
	   return 0; /* return, because of unknown event */
       }
       }
       else
       {
           /* no event or not interested in such event */
           if(! mouse_movement) continue;
           WLmouse_position(lwin_no, x, y, &in_window,&key_button);
           *button = NO_BUTTON;
       }
        
	
	 return OM_S_SUCCESS;
    }


  
#elif defined( ENV5 )
   while( TRUE )
   {
      Inq_events( &events );
      
      if ( events & BUTTON_EVENT )  
      {
         Inq_button_data( hwwin, x, y, button, transition, &timetag);
         if( *hwwin < 0 )
         {
            return( FALSE );
         }
         
         switch ( *transition )
         {
             case UP: *transition = DPvd_UP; break;
             case DOWN: *transition = DPvd_DOWN; break;
             case SINGLE_CLICK: *transition = DPvd_SINGLE_CLICK; break;
             case DOUBLE_DOWN: *transition = DPvd_DOUBLE_DOWN; break;
             case DOUBLE_CLICK: *transition = DPvd_DOUBLE_CLICK; break;
             case TRIPLE_DOWN: *transition = DPvd_TRIPLE_DOWN; break;
             case UP_DOWN_UP: *transition = DPvd_UP_DOWN_UP; break;
             case UP_DOWN: *transition = DPvd_UP_DOWN; break;
         }

         switch( *button )
         {
            case LEFT_BUTTON: *button = DPvd_LEFT_MOUSE; break;
            case MIDDLE_BUTTON: *button = DPvd_MIDDLE_MOUSE; break;
            case RIGHT_BUTTON: *button = DPvd_RIGHT_MOUSE; break;
         }

         if ( *transition == DPvd_UP )
         {
            Get_button_data( hwwin, x, y, button, transition, &timetag );
         }
         else if ( DPvd_get_active_window_id( *hwwin, NULL ) == TRUE )
         {
             if(*transition == DPvd_DOWN || *transition == DPvd_SINGLE_CLICK)
             {
		 Get_button_data( hwwin, x, y, button, &t_transition, &timetag );
             }
	     else if ( (*button == DPvd_LEFT_MOUSE) && (*transition == DPvd_DOUBLE_CLICK) )
	     {   
		 return(FALSE);
	     }
	     else /* ignore all other button events in the window */
	     { 
		 Get_button_data( &t_hwwin, &t_x, &t_y, &t_button, &t_transition, &timetag );
		 continue;
	     }
	 }
	 else /* outside window button event */
	 {
	     return(FALSE);
	 }
      }
      else if ( events & MOTION_EVENT )
      {
         /* mouse motion event */ 
         if (! mouse_movement)
         {
            continue;
         }

         WLmouse_position( lwin_no, x, y, &in_window,&key_button );
         *button = NO_BUTTON;
      }
      else if ( events & KEYBOARD_EVENT )
      {
         /* check, if  function key input (C2,C3,...) */ 
         /* get keyboard buffer only one time, because of no change of adress or size */
         if (keyb_buf == NULL)
         {
            Inq_keyboard_buffer( &keyb_buf, &bufsize );
         }

         Inq_keyboard_data( &count );

         /* if keyb_buf == FE (function keys), than we must check the second event */
         if ( keyb_buf[0] == 0XFE )
         {
	     Get_keyboard_data(&count);
	     control_key[0] = keyb_buf[0];
	     Get_keyboard_data(&count);
	     control_key[1] = keyb_buf[0];

	     put_control_key_to_jnl = FALSE;

            switch( keyb_buf[0] )
            {
               case KEY_IN_C2 :
	          *button = C2;
                  return OM_S_SUCCESS;
               case KEY_IN_C3 :
                  *button = C3;
		  Get_keyboard_data(&count);
                  return OM_S_SUCCESS;

#ifdef NOTUSED
	/* 08/23/93, T.Wang: Don't catch B2 event */
              case KEY_IN_B2 :
                  *button = B2;
                  return OM_S_SUCCESS;
#endif

               default:
                  /* other function keys will be put back to queue */
		  event2 = keyb_buf[0];
                  EX_translate_funckey1( event2, &log_kbd, EX_LINE_MODE );
		  put_control_key_to_jnl = TRUE;
                  return 0; /*  other function key, go out of dynamics */
            }
         }
         else
         {
            /* any other keyin, (may be esc) - go out of dynamics */
	    return 0; 
         }
      }	
      else if ( (events == 0) || (events & TIMER_EVENT) )
      {
         if (! mouse_movement)
         {
            continue;
         }

         WLmouse_position(lwin_no, x, y, &in_window,&key_button);
         *button = NO_BUTTON;
      }
      else if(events & (REFRESH_EVENT | DELETE_EVENT | COVER_EVENT | COLLAPSE_EVENT))
      {
	  DPhandle_event();
	  *button = DPvd_WINDOW_EVENT;
	  return OM_S_SUCCESS;
      }
      else 
      {
         return 0; /* return, because of unknown event */
      }

      return OM_S_SUCCESS;
   }

#else
#error " A windowing system must be defined"
#endif

} /* DPvd_get_next_event */

end implementation DPvd;

