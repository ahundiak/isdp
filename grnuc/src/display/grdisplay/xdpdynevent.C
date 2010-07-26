#if defined(  X11 )
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "OMlimits.h"
#include "ex.h"
#include"exmacros.h"
#include "dpdef.h"
#include "wl.h"
#include "tools.h"
#include <sys/time.h>
#include <sys/select.h>

extern int select(int, fd_set *, fd_set *, fd_set *, struct timeval * );

extern Display *EXdisplay;

#define PRESS 1
#define REL 0

static int 	pan_x,pan_y;

/*----- GRXget_button_data --------------------------------------------------------*/

void GRXget_button_data( IGRint lwin_no, 
                         IGRint *button, 
                         IGRint *transition, 
                         IGRint *x, 
                         IGRint *y, 
                         IGRint *but_state, 
                         IGRint *pan_state, 
                         IGRint *state, 
                         Bool (*predproc_ptr)() )

/*
DESCRIPTION
	This function gets the latest button event (it waits for one if necessary),
	from the given window ('hwwin_no'), and returns codes for the button and the
	type of button tap, as well as altering the state of the button (but_state)
	and another state ('state') used for a function in this file (NEDPdynevent()).

PARAMETERS
	lwin_no (IN) - logical window number
	button (OUT) - The button that was pressed.
	transition (OUT) - The type of button click (SINGLE, DOUBLE, DOWN, DOUBLE_DOWN).
	x, y (OUT,OUT) - x,y position of the cursor in the window when button was snapped.
	but_state (IN/OUT) - Keeps state of button (PRESS versus RELease).
	pan_state - NOT USED in this function. Remove at earliest convenience.
	state (OUT) - Used for Change View Dynamically (NEDPdynevent()).

GLOBALS USED
	Display EXdisplay;

RETURN VALUES
	none

NOTES
	If called apart from View Dynamics, call with *pan_state set to 0 (RELease).

HISTORY
	01/06/92 Created.
		Trevor Mink
*/

{
	struct timeval timer;
	XEvent 	event_data;
	int status;
        Window root, child;
	int root_x,root_y;
   	unsigned int key_butt;
   	unsigned long prev_time;
        WLuint32 base_context_no;
        struct WLnative_info native_info;

        WLget_window_base_context( lwin_no, &base_context_no );
        WLget_native_info( lwin_no, base_context_no, &native_info );

	timer.tv_sec=0;
	timer.tv_usec=135000;
        if(*but_state== PRESS)
        {
	      	status= XCheckWindowEvent(EXdisplay,native_info.base_win,
              		(ButtonReleaseMask),&event_data);
		if (status)
		{
			*but_state=REL;
			*state=WAIT;
			return;
		}
		else
	        {
			XQueryPointer(EXdisplay,native_info.base_win,
			        &root,&child,&root_x,&root_y,x,y,&key_butt);
			if(key_butt & Button1Mask)
				*button=LEFT_BUTTON;
			if(key_butt & Button2Mask)
				*button=MIDDLE_BUTTON;
			if(key_butt & Button3Mask)
				*button=RIGHT_BUTTON;
			*transition=DOWN;
		        *but_state=PRESS;
		}
	}
	else
	{
		if (XCheckIfEvent(EXdisplay,&event_data,predproc_ptr,NULL))
		{
			XPutBackEvent(EXdisplay,&event_data);
		}
		else
		{
			*transition = UP;
			*button = LEFT_BUTTON;
			return;
		} 

                XPeekIfEvent(EXdisplay,&event_data,predproc_ptr,NULL);
                if((event_data.type==KeyPress) ||
                   (
                     (
                       (event_data.type == ConfigureNotify) ||
                       (event_data.type == DestroyNotify) ||
		       (event_data.type == MapNotify) ||
                       (event_data.type == UnmapNotify) 
                     ) 
                   ) ||
                   ((event_data.type == ButtonPress)&&
		    (event_data.xany.window!=native_info.base_win))
                  )
                {
                          *button = -1;
                                       /* This is set to -1 so that NEDPdynevent               
                                          does not use the value in button to 
                                          determine the state again -Shridar */
                          *state=DP_EXIT;
			  return;
                }
		XWindowEvent(EXdisplay,native_info.base_win,
			ButtonPressMask,&event_data);

		    	*transition=DOWN;
			*button=event_data.xbutton.button-1;
			prev_time=event_data.xbutton.time;
			*but_state=PRESS;
	                select(1,NULL,NULL,NULL,&timer);
			timer.tv_usec=135000;
                        *x = pan_x=event_data.xbutton.x;
                        *y = pan_y = event_data.xbutton.y;

			do
			{
 		   		status= XCheckWindowEvent(EXdisplay,native_info.base_win,
                               		ButtonReleaseMask,&event_data);
			}
			while( event_data.xbutton.time < prev_time );
			if(status && (event_data.xbutton.time >= prev_time))
			{
				*transition=SINGLE_CLICK;
				*but_state=REL;
			        *button=event_data.xbutton.button-1;
			        prev_time=event_data.xbutton.time;
	                        select(1,NULL,NULL,NULL,&timer);
				timer.tv_usec=135000;

                                status=XCheckWindowEvent(EXdisplay,
				       native_info.base_win,ButtonPressMask,
                                       &event_data);
				/* If button event but not the same button... */
				/* Put event back and exit */
				if( status &&
					event_data.xbutton.button-1 != *button )
				{
					XPutBackEvent(EXdisplay,&event_data);
					return;
				}
                                if(status  && (event_data.xbutton.time >= prev_time))
                                {
	                            	*transition=DOWN;
                                    	*but_state=PRESS;
                                    	*button=event_data.xbutton.button-1;
			            	prev_time=event_data.xbutton.time;
	                            	select(1,NULL,NULL,NULL,&timer);
				    	timer.tv_usec=135000;
					do
					{
                                    	status=XCheckWindowEvent(EXdisplay,
                                              native_info.base_win,
                                              ButtonReleaseMask,&event_data);
					}
					while( event_data.xbutton.time < prev_time );

                                    	if(status && (event_data.xbutton.time >= prev_time))
                                    	{
						*transition=DOUBLE_CLICK;
						*but_state=REL;
						*button=event_data.xbutton.button-1;
					}
				}
			}
	}

} /* GRXget_button_data */

IGRint	NEDPdynevent(lwin_no,state,pan_state,pan_point,but_state)

  IGRint	lwin_no;
  IGRint	*state;
  IGRint	*pan_state;
  IGRint	*pan_point;
  IGRint 	*but_state;
{
   IGRint x;
   IGRint y;
   IGRint button = 0;
   IGRint transition = 0;
   XEvent report;
   Bool ignore_noexpose();
   Bool predproc();


/* This Logic of waiting and putting back events is poor, should be rewritten when
everyone is done making changes to this J. Underwood */   
	if (XCheckIfEvent(EXdisplay,&report,ignore_noexpose,NULL))
	{
		XPutBackEvent(EXdisplay,&report);
	}
	else
	{
		*state=WAIT;
		goto wrapup;
	} 
       XPeekIfEvent(EXdisplay,&report,ignore_noexpose,NULL);
       if ((report.type==ButtonPress) || (report.type==ButtonRelease) ||
	   (report.type==MotionNotify) || (report.type==EnterNotify) ||
           (report.type==LeaveNotify) || (report.type==FocusIn) ||
           (report.type==FocusOut) || (report.type==ColormapNotify) ||
           (report.type==Expose))
       {
		GRXget_button_data( lwin_no, &button, &transition, &x, &y,
			but_state, pan_state, state, predproc );
                x=pan_x;
		y=pan_y;
		switch (button)
		{
		case LEFT_BUTTON:

			switch (transition)
			{

			case DOWN:
				*state = ZOOM_IN;
				break;

			case UP:
				*state = WAIT;
				break;

			default:
				*state = DP_EXIT;
				break;
			}
			break;

		case RIGHT_BUTTON:

			switch (transition)
			{
			case DOWN:
				*state = ZOOM_OUT;
				break;

			case UP:
				*state = WAIT;
				break;

			default:
				*state = DP_EXIT;
				break;
			}
			break;

		case MIDDLE_BUTTON:

			switch (transition)
			{
			case DOUBLE_CLICK:
				if (*pan_state)
				{
					*pan_state = FALSE;
				}
				else
				{
					*pan_state = TRUE;
				}
				*state = CHANGE_STATE;
				break;

			case DOWN:
				if (*pan_state)
				{
					pan_point[0] = x;
					pan_point[1] = y;
					*state = PAN;
				}
				else
				{
					*state = ROTATE;
				}
				break;

			case UP:
				*state = WAIT;
				break;

			default:
				*state = DP_EXIT;
				break;
			}
			break;

		default:
			break;

		} /* end of switch (button)  */
	}
        else
           	    *state=DP_EXIT;
	if (*state != DP_EXIT)
	{
		/*  Get_button_data(&win_no,&x,&y,&button,&transition,&timetag); */
	}
wrapup:
	return(1);
}

Bool  predproc(display,event,arg)
Display *display;
XEvent *event;
char *arg;
{
   switch(event->type)
  {
     case KeyPress:
            return(1);
     case ButtonPress:
            return(1);
     case ConfigureNotify:
     case DestroyNotify  :
     case MapNotify      :
     case UnmapNotify    :
            return(1);
     default:
            return(0);
  }
}



Bool  ignore_noexpose(display,event,arg)
Display *display;
XEvent *event;
char *arg;
{
   switch(event->type)
  {
     case NoExpose:
     case GraphicsExpose:
            return(0);
     default:
            return(1);
  }
}
#endif
