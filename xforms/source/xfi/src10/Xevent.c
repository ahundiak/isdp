
#include "../include/FImin.h"
#include "../include/FIseq.h"
#include <stdio.h>

#include "../include/XFIproto_pri.h"
#include "../include/XFIproto_pub.h"



/*******************************************************************/
/*  FIdecode  --  Given an initial up or down state, and a count   */
/*                of state changes, this function generates        */
/*                an Environ V transition state such as            */
/*                SINGLE_CLICK or DOUBLE_CLICK.                    */
/*                Written by Herman Tsai.                          */
/*******************************************************************/

int FIdecode (int start,
              int count)
{
  int starts_down [5];
  int starts_up [3];

  starts_down[0] = DOWN;
  starts_down[1] = SINGLE_CLICK;
  starts_down[2] = DOUBLE_DOWN;
  starts_down[3] = DOUBLE_CLICK;
  starts_down[4] = TRIPLE_DOWN;

  starts_up[0] = UP;
  starts_up[1] = UP_DOWN;
  starts_up[2] = UP_DOWN_UP;

  if ( start == DOWN )
    {
      if ( count < 5 )
	{
          return ( starts_down[count]);
	}
      else
	{
          if ( !( count % 2 ))
	    {
              return ( DOWN );
	    }
          else
	    {
              return ( -1 );
	    }
	}
    }
  else
    {
      if ( count < 3 )
	{
          return ( starts_up[count]);
	}
      else
	{
          if ( !( count % 2 ))
	    {
              return ( UP );
	    }
          else
	    {
              return ( -1 );
	    }
	}
    }
}


/*********************************************************************/
/*    FI_get_transition   -- This function is used to enter a wait   */
/*                           loop and monitor up/down button events. */
/*                           From these events an Environ V          */
/*                           transition state is calculated.  Ex.    */
/*                           SINGLE_CLICK, DOUBLE_CLICK.             */
/*                                      GMD 3/27/91                  */
/*********************************************************************/

#if defined(clipper) 
int FI_get_transition (XEvent *event,
                       unsigned int *trans)
{
  int start, status, count, complete;
  XEvent myevent;
  XEvent event_array[128];
  int ii;


  struct timeval 
    {
      long tv_sec;
      long tv_usec;
    }	FItimeout;


  if ( event->type == ButtonPress )
    {
      start = DOWN;
    }
  else if ( event->type == ButtonRelease )
    {
      start = UP;
    }
  else
    {
      return ( FI_ILLEGAL_VALUES );
    }

  count = 0;
  complete = 0;

  FItimeout.tv_sec = 0;
  FItimeout.tv_usec = 300000;

  while ( !complete )
    {
	/* Wait a half second before checking */
      select ( 1, 0, 0, 0, &FItimeout );

      /* GMD 1/24/92 */
/****
      status = FI_check_mask_event ( _FI_display, ButtonPressMask |
                                          ButtonReleaseMask, &myevent );
****/
      status = FI_check_window_event ( 
				_FI_display, 
				event->xbutton.window,
				ButtonPressMask | ButtonReleaseMask, 
				&myevent );

      if ( status )
	{
          count++;
	}
      else
	{
          complete = 1;
	}

	/*****************************************************/
	/* sml:12-09-93 TR 249305903                         */
	/*  Keep track of the events checked here so we      */
	/*  can put them back on the queue.                  */
	/*****************************************************/
	event_array[count]=myevent;
    }

  *trans = FIdecode ( start, count );

	/*****************************************************/
	/* sml:12-09-93 TR 249305903                         */
	/*  Put events back on the queue.                    */
	/*****************************************************/

  for (ii = 0; ii < count; ii++)
  {
	FI_put_back_event(_FI_display, &event_array[count]); /* count??? */
  }

  return ( FI_SUCCESS );
}
#endif

#ifdef NEW_TRANS
int FI_get_transition (XEvent *event,
                       unsigned int *trans)
{

  XEvent myevent;
  Time prev_time;
  int status;

  struct timeval 
    {
      long tv_sec;
      long tv_usec;
    }	FItimeout;

  *trans=DOWN;
  FItimeout.tv_sec=0;
  FItimeout.tv_usec=150000;
  prev_time=event->xbutton.time;
  select(1,0,0,0,&FItimeout);
  FItimeout.tv_usec=150000;

  status= FI_check_window_event(
			_FI_display,
			event->xbutton.window,
			ButtonReleaseMask,
			&myevent);

  if(status && (((unsigned int)myevent.xbutton.time - 
                            (unsigned int) prev_time)< 150))
  {
	*trans=SINGLE_CLICK;
	prev_time=myevent.xbutton.time;
	select(1,0,0,0,&FItimeout);
	FItimeout.tv_usec=150000;
	status=FI_check_window_event(
			_FI_display, 
			event->xbutton.window,
       		ButtonPressMask,&myevent);
  	
	if(status && (((unsigned int)myevent.xbutton.time -
                           (unsigned int) prev_time)< 150))
    {
      *trans=DOUBLE_DOWN;
	  prev_time=myevent.xbutton.time;
	  select(1,0,0,0,&FItimeout);
	  FItimeout.tv_usec=150000;
      status=FI_check_window_event(_FI_display,
               event->xbutton.window,
               ButtonReleaseMask,
               &myevent);

  	  if(status && (((unsigned int)myevent.xbutton.time -
                         (unsigned int) prev_time)< 150))
      {
		*trans=DOUBLE_CLICK;
    	prev_time=myevent.xbutton.time;
	    select(1,0,0,0,&FItimeout);
		FItimeout.tv_usec=150000;
        status=FI_check_window_event(_FI_display,
                 event->xbutton.window,
                 ButtonPressMask,&myevent);

     	if(status && (((unsigned int)myevent.xbutton.time -
                          (unsigned int) prev_time)< 150))
        {
		  *trans=TRIPLE_DOWN;
		}
	  }
	}
  }
  if(status && (((int)myevent.xbutton.time - (int) prev_time)> 150))
  {
    /*if time difference > 150 need to put it back*/
    FI_put_back_event(_FI_display,&myevent);
  }
  return(FI_SUCCESS);  
}
#endif


/************************************************/
/* sml:02-14-94:TRs 249400227 and 249400184     */
/* #define this change for Solaris and SGI IRIX */
/************************************************/
#if (defined(sun) || defined(i386) || defined(sparc) && defined(SYSV)) || (defined(mips) || defined(hp9000))
int FI_get_transition (XEvent *event,
                       unsigned int *trans)
{

  XEvent myevent;
  Time prev_time;
  int status;

  struct timeval 
    {
      long tv_sec;
      long tv_usec;
    }	FItimeout;

  if  ( event->type == ButtonPress   ) 
  {
    *trans=DOWN;
  	FItimeout.tv_sec=0;
  	FItimeout.tv_usec=150000;
	prev_time=event->xbutton.time;
    select(1,0,0,0,&FItimeout);
	FItimeout.tv_usec=150000;
	status= FI_check_window_event(_FI_display,event->xbutton.window,
                            	  ButtonReleaseMask,&myevent);
	
	if(status && (((unsigned int)myevent.xbutton.time - 
                            (unsigned int) prev_time)< 150))
	{
	  *trans=SINGLE_CLICK;
      prev_time=myevent.xbutton.time;
	  select(1,0,0,0,&FItimeout);
	  FItimeout.tv_usec=150000;
   	  status=FI_check_window_event(_FI_display, event->xbutton.window,
                                   		ButtonPressMask,&myevent);
  	  if(status && (((unsigned int)myevent.xbutton.time -
                                   (unsigned int) prev_time)< 150))
      {
	    *trans=DOUBLE_DOWN;
		prev_time=myevent.xbutton.time;
	    select(1,0,0,0,&FItimeout);
		FItimeout.tv_usec=150000;
        status=FI_check_window_event(_FI_display,
                        event->xbutton.window,
                        ButtonReleaseMask,&myevent);
  		if(status && (((unsigned int)myevent.xbutton.time -
                                 (unsigned int) prev_time)< 150))
        {
		  *trans=DOUBLE_CLICK;
    	  prev_time=myevent.xbutton.time;
	      select(1,0,0,0,&FItimeout);
		  FItimeout.tv_usec=150000;
          status=FI_check_window_event(_FI_display,
                           event->xbutton.window,
                           ButtonPressMask,&myevent);
     	  if(status && (((unsigned int)myevent.xbutton.time -
                              (unsigned int) prev_time)< 150))
          {
		    *trans=TRIPLE_DOWN;
		  }
		}
	  }
    }

    if(status && (((int)myevent.xbutton.time - (int) prev_time)> 150))
    {
      /*if time difference > 150 need to out it back*/
      FI_put_back_event(_FI_display,&myevent);
    }
  }

  return(FI_SUCCESS);
}
#endif

int FI_forms_active (void)
{
  return ( _FI_forms_active );
}



int FI_process_forms (void)
{
  XEvent event;

  while ( _FI_forms_active )
    {
      /* GMD 10/23/91 */
      FI_next_event (_FI_display, &event);

      FI_process_event ( &event, 0 );
    }
  return ( FI_SUCCESS );
}


/* ARGSUSED */
Bool _FI_flush_expose (Display *display,
                       XEvent *event,
                       Window *wind)
{
  if (( event->type == Expose ) && ( event->xexpose.window == *wind ))
    {
      return ( True );
    }
  else
    {
      return ( False );
    }
}

/* ARGSUSED */
Bool _FI_flush_configure (Display *display,
                          XEvent *event,
                          Window *wind)
{
  if (	( event->type == ConfigureNotify )	&&
	( event->xconfigure.window == *wind )	 )
    {
      return ( True );
    }
  else
    {
      return ( False );
    }
}


int FI_process_event (XEvent *event,
                      unsigned int trans)
{
  struct FIform_obj *form = 0;
  struct FIgadget_obj *gadget = 0;
  int	used_event;
  int	window_index;
  int   a, status, type;

#if (defined(i386) || defined(sparc) || defined(sun) && defined(SYSV)) || defined(mips)
  extern int _FI_last_button_transition;
#endif

  used_event = FALSE;

  if ( ! _FI_forms_active )
    {
      return ( used_event );
    }

  window_index = _FI_Xwindow_to_index ( event->xany.window );

  if ( window_index == -1 )
    {
      return ( used_event );
    }
  else
    {
      form = FI_forms[window_index];
    }

  /* The window was found but the form data has already deleted */

  if ( ! form )
    {
      used_event = TRUE;

      if ( event->type == DestroyNotify )
	{
	  _FI_index_to_Xwindow[window_index] = None;
	}

      return ( used_event );
    }

  /* GMD 3/24/92    If one or more save restore forms is active, then  */
  /*                only events meant for the currently active save    */
  /*                restore form should be serviced.  An exception     */
  /*                to this rule is for expose events.                 */

  if (SaveRestoreFormsDisplayed)
  {
  Window my_window;

     FIf_get_window (SaveRestoreFormsArray [SaveRestoreFormsDisplayed], 
                     &my_window);

     if ((my_window != event->xany.window) &&
         (event->type != ConfigureNotify) &&
         (event->type != Expose))
             return (1);    /* Tell application we used the event */
  }

  _FI_gc = form->Xgc;
  _FI_text_gc = form->Xgc_text;	/*** JAJ:02/14/92 ***/

  switch ( event->type )
    {
      case ClientMessage:	/** USER_EVENT **/

        a = XInternAtom (_FI_display, "WM_DELETE_WINDOW", False);

        if (event->xclient.data.l[0] == a)
        {
           /********************************************************/
           /*                                                      */
           /* Check the form to see if it has a FI_CANCEL gadget   */
           /* defined.  If so, then set the cancel button's state  */
           /* to on and call the notify_routine as though the      */
           /* cancel button had been pressed by the operator.      */
           /* Otherwise, do nothing.   GMD 2/12/92                 */
           /*                                                      */
           /********************************************************/

           status = FIg_get_type ((Form)form, FI_CANCEL, &type);

           if (status == FI_SUCCESS)
           {
              FIg_set_state_on ((Form)form, FI_CANCEL);
              FIg_call_notification_routine ((Form)form, FI_CANCEL);
           }

           used_event = TRUE;
           return ( used_event );
        }

	if ( event->xclient.data.l[0] == FI_DATA_OFFSET )
	  {
	    int label;

		/* Process the first gadget in sequence */

		/* If the label is negative, then the form	*/
		/* does not need to start up the sequence again */
		/* if the form is displayed.			*/

		/* Check for less than -10 because -1 has been	*/
		/* used in the past to signify no sequencing.	*/

		/* Good values should be -11 .... -Inf 		*/
		/* because -10 is added to value.		*/

	    label = ABS ( form->seq_label );

	    if ( form->seq_label < -10 )
	      {
		form->seq_label = -1;

		label -= 10;
	      }

	    gadget = _FI_g_get_id ( form, label );

	    if ( gadget )
	      {
		 _FI_g_track_kbd ( gadget, FI_FORWARD, 0 );
	      }
	  }
	break;

      case ButtonPress:	/** BUTTON_EVENT **/

	if ( form->builder_mode )
	  {
	    return ( used_event );
	  }

	if ( form->intercept_routine )
	  {
		/* If the form is set to intercept all button,	*/
		/* then allow all to filter through.		*/

	    used_event = TRUE;

	        /** KLUDGE-MDSX button-1 and transition **/

		/****************************************/
		/* sml:11-16-93 TR 249305903            */
		/*   get the transition here so you can */
		/*   pass it to the button intercept    */
		/*   function                           */
		/****************************************/

		/*******************************************/
		/* sml:02-12-94 TR 24940227 and 249400184  */
		/*  check if don't already have trans      */
		/*******************************************/
#if (defined(i386) || defined(sparc) || defined(sun) && defined(SYSV)) || defined(mips)
		if (trans <= 0)
#endif
		  FI_get_transition(event, &trans);

#if (defined(i386) || defined(sparc) || defined(sun) && defined(SYSV)) || defined(mips)
		_FI_last_button_transition = trans;
#endif

	    form->intercept_routine ( form, event->xbutton.x,
			event->xbutton.y, event->xbutton.button,
		        /** event->xbutton.state **/ trans,
			event->xbutton.time ) ;

	  }
	else if ( event->xbutton.button == _FI_select_button ) /* GMD 1/14/92 */
	  {
	    /* Only allow MIDDLE_BUTTON for forms without intercept */

		 used_event = TRUE;

	  /************************************************/
	  /* sml:02-14-94:TRs 24940227 and 249400184      */
	  /* Single and double clicks are not interpreted */
	  /* correctly.                                   */
	  /************************************************/

#if (defined(i386) || defined(sparc) || defined(sun) && defined(SYSV)) || defined(mips)
	  if (trans <= 0) /* If trans hasn't been passed in, do if part   */
	  {
#endif
	    FIf_process_point ( (Form) form, event->xbutton.x,
					event->xbutton.y,
					(int) event->xbutton.button,
					event->xbutton.state,
					event->xbutton.time ) ;
#if (defined(i386) || defined(sparc) || defined(sun) && defined(SYSV)) || defined(mips)
	  }
	  else /* if have a trans, remember it for later */
	  {
	    _FI_last_button_transition = trans;
	    FIf_process_point ( (Form) form, event->xbutton.x,
					event->xbutton.y,
					(int) event->xbutton.button,
					trans,
					event->xbutton.time ) ;
	  }
#endif

	  }
	break;


      case ConfigureNotify:
	  {
	    XConfigureEvent *conf = & event->xconfigure;
	    XEvent	evt;
	    Window	wind_arg = conf->window, child;
	    float	delta_x, delta_y;
	    int		width = form->xhi - form->xlo;
	    int		height = form->yhi - form->ylo;
	    int		scale_it = 1;
	    int		root_x, root_y;


	    while ( FI_check_if_event ( _FI_display, &evt,
			     _FI_flush_configure, (char *) &wind_arg ) )
	      {
		conf = & evt.xconfigure ;
	      }

	    if (( width == conf->width ) && ( height == conf->height ))
	      {
			/*** Form didn't change size, so	***/
			/*** there's no need to scale it.	***/
		scale_it = 0;
	      }

		/*** Find origin relative to the RootWindow, 	***/
		/*** because conf->x and conf->y are relative	***/
		/*** coordinates based on the parent window.	***/
		/*** "send_event" is 0 when resizing, and x, y	***/
		/*** are relative to the parent.  "send_event"	***/
		/*** is 1 when moving, and x, y are already	***/
		/*** relative to the RootWindow.		***/

	    if ( ! conf->send_event )
	      {
		XTranslateCoordinates ( _FI_display, wind_arg,
			      RootWindow ( _FI_display, form->Xscreen ),
			      0, 0, &root_x, &root_y, &child );
	      }
	    else
	      {
		root_x = conf->x;
		root_y = conf->y;
	      }

	    form->xlo = root_x;
	    form->ylo = root_y;
	    form->xhi = root_x + conf->width;
	    form->yhi = root_y + conf->height;

	    /*********************************************************
	    printf ( "win=%x, x=%d, y=%d, width=%d, height=%d\n",
		form->Xwindow, form->xlo, form->ylo,
		conf->width, conf->height );
	    **********************************************************/

	    if ( form->attr_mask & FI_NOT_SCALABLE )
	      {
		/**************************************************/
		/*** If the form is not scaleable, then make	***/
		/*** sure the control buttons are moved so	***/
		/*** that they're the proper offset from the	***/
		/*** right side of the form.			***/
		/**************************************************/

		struct FIgadget_obj *group = _FI_g_get_id ( form,
							FI_CTRL_GROUP );
		if ( group )
		  {
		    delta_x = conf->width - width;

		    if ( delta_x != 0.0 )
		      {
			_FI_g_change_location ( group,
						(int) delta_x, 0 );
		      }
		  }
	      }
	    else if ( scale_it )
	      {
		/**  This concept is removed ( see fpi.c ) 3/26/91
		form->adjusted_size = FALSE;
		*****************************************************/

		delta_x = (float) conf->width / (float) width;
		delta_y = (float) conf->height / (float) height;

		if ( delta_x == 0.0 )
		  {
		    delta_x = 1.0;
		  }

		if ( delta_y == 0.0 )
		  {
		    delta_y = 1.0;
		  }

		_FI_g_adjust_size ( (struct FIgadget_obj *) form->group,
					delta_x, delta_y );
	      }

	        /* Notify owner to adjust his gadgets */
	    if ( form->window_event_routine )
	      {
		form->window_event_routine ( form->form_label,
						FI_CHANGED_SIZE, form );
	      }

	        /** X11-4/22/90-Form will paint upon Expose event **/
	  }

	used_event = TRUE;
	break;


      case MapNotify:

	used_event = TRUE;
	form->attr_mask &= ~ FI_DISPLAY_COLLAPSED;
	break;


      case DestroyNotify:	/** DELETE_EVENT **/
	used_event = TRUE;
	_FI_index_to_Xwindow[window_index]= None;

	if ( form )
	  {
			/**************************************************/
			/* sml:11-09-93 TR 249305159                      */
			/* Instead of deleting form here, execute         */
			/* FI_CANCEL code                                 */
			/**************************************************/
	     /*_FI_f_delete ( form );*/
		 FIg_set_state_on((Form)form, FI_CANCEL);
		 FIg_call_notification_routine((Form)form, FI_CANCEL);
	  }
	break;


      case UnmapNotify:	/** COLLAPSE_EVENT **/

	used_event = TRUE;
	if ( !( form->attr_mask & FI_WITHDRAWN ))  /* GMD 10/9/91 */
	  {
	    if ( form->window_event_routine )
	      {
		form->window_event_routine ( form->form_label,
						FI_COLLAPSE, form );
	      }

            form->attr_mask |= FI_DISPLAY_COLLAPSED;
	  }
	break;


      case Expose:	/** REFRESH_EVENT **/
	  {
	    Window	wind_arg;
	    int		xlo = event->xexpose.x;
	    int		ylo = event->xexpose.y;
	    int		xhi = event->xexpose.x + event->xexpose.width;
	    int		yhi = event->xexpose.y + event->xexpose.height;
	    int		num = 1;
	    int		ii;
	    XEvent	evt;
	    XRectangle	rects[10];
	    double	area = 0.0;
            XWindowAttributes win_attr; 
	    /********************************************************
	    printf ( "FORMS: Process--Expose ( win = %x )\n",
						form->Xwindow );
	    ********************************************************/

	    used_event = TRUE;
	    wind_arg = event->xexpose.window;

		/* sml:10-16-92	check if window is mapped before exposing*/
	    XGetWindowAttributes(_FI_display, event->xexpose.window, &win_attr);
	    if (win_attr.map_state == IsUnmapped)
	      break;
	    rects[0].x = event->xexpose.x;
	    rects[0].y = event->xexpose.y;
	    rects[0].width = event->xexpose.width;
	    rects[0].height = event->xexpose.height;

		/*** X11-6/13/90 - Flush out the event queue 	***/
		/***  and expand the clip rectangle.		***/

	    while ( FI_check_if_event ( _FI_display, &evt, _FI_flush_expose,
						(char *) &wind_arg ) )
	      {
		_FI_expand_clip_rectangle (	evt.xexpose.x,
						evt.xexpose.y,
						evt.xexpose.width,
						evt.xexpose.height,
					      &xlo, &ylo, &xhi, &yhi );

		if ( num < 10 )
		  {
		    rects[num].x = evt.xexpose.x;
		    rects[num].y = evt.xexpose.y;
		    rects[num].width = evt.xexpose.width;
		    rects[num].height = evt.xexpose.height;
		    num++;
		  }
	      }

			/***********************/
			/*** redraw the form ***/
			/***********************/

          /* Added check for initial_form_display flag   GMD 1/8/92  */

          if (form->initial_form_display)
             form->initial_form_display = 0;
          else
          {
	    if (( num == 1 ) || ( num > 10 ))
	      {
		FIf_paint_area ( (Form) form, xlo, ylo, xhi, yhi );
	      }
	    else
	      {
		for ( ii = 0; ii < num; ii++ )
		  {
		    area += ( (double) rects[ii].width ) *
				( (double) rects[ii].height );
		  }

		if ( area < ( 0.6 * ( xhi - xlo ) * ( yhi - ylo )))
		  {
		    for ( ii = 0; ii < num; ii++ )
		      {
			FIf_paint_area ( (Form) form,
			      (int) rects[ii].x,
			      (int) rects[ii].y,
			      (int) ( rects[ii].x + rects[ii].width ),
			      (int) ( rects[ii].y + rects[ii].height ));
		      }
		  }
		else
		  {
		    FIf_paint_area ( (Form) form, xlo, ylo, xhi, yhi );
		  }
	      }
          }

	        /* Notify owner to refresh his gadgets */

/*********************************************************************/
/*  This window_event_routine call was superfluous.  FIf_paint_area  */
/*  will always generate an FI_DISPLAY window_event_routine.  If we  */
/*  send this one here, it will cause the application to refresh its */
/*  graphics twice.  GMD 11/5/91                                     */
/*********************************************************************/

	      /***************************************************
	      if (form->window_event_routine)
		{
		  form->window_event_routine ( form->form_label,
						FI_REFRESH, form);
		}
	      ***************************************************/

             /* Moved this call from FIf_display to here because the  */
             /* expose event was causing the field gadget to drop out */
             /* of its loop for the FIf_start_seq gadget.             */
             /*         GMD 10/28/91                                  */
 
             /* Set the start seq because the label is greater then 0 */

             if ( form->seq_label > 0 )
             {
	        FIg_start_seq ( (Form)form, form->seq_label );
             }
	  }
	break;

    }	/** END switch **/

  return ( used_event );
}
