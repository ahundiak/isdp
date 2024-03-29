/***********************************************/
/* fpi.c, $Revision: 1.27 $           */
/***********************************************/

#include "FImin.h"

#include <stdio.h>
#include <sys/errno.h>
#include <setjmp.h> /* dmb:09/24/92: Causes problems on Sun now... */
#include "FIgroup.h"
#include "MI.h"

#include "MIdef.h"
#include "MSext.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

		/******************************************/
		/*** Put all the window-creation code	***/
		/*** in a common function.		***/
		/************************ JAJ:02/12/92	***/
int _FI_make_Xwindow (struct FIform_obj   *fp)
{
  Window		window;
  XSetWindowAttributes	win_values;
  unsigned long		value_mask;
  XWMHints		wm_hints;
  XClassHint		cl_hints;
  int			xx;
/*  int			atom; */
  Atom			atom;

  XVisualInfo	vTemplate, *visualList;
  Visual		*correct_visual;
  int			visualsMatched; /* visual_index;*/
  int			current_screen; /*, status;*/
  int			correct_depth, rootDepth;


  /* ISDP add a check for NULL pointers */
  if (fp == NULL) {
    return ( FI_NO_SUCH_FORM);
  }


  value_mask = CWBackPixel | CWEventMask | CWColormap | CWSaveUnder |
                              CWBorderPixmap;  /* add for depth > 8 */
  win_values.background_pixel = FI_translate_color ( fp->Xscreen,
							 fp->bgcolor );
  win_values.event_mask = FI_EVENT_MASK;
  win_values.border_pixmap = None;	/* for depth > 8 */
/*
  win_values.colormap = DefaultColormap ( _FI_display, fp->Xscreen );
*/

  win_values.colormap = _FI_cmap_array[fp->Xscreen];

  win_values.save_under = ( fp->attr_mask & FI_SAVE_UNDER ) ?
							 True : False;

  /*sml:06-22-92	Check if depth of active screen is 8 bits */
  /*				or less.  If not, create a window with a  */
  /*				visual with depth of 8; else use current  */
  /*				depth.									  */

  /* sml:06-22-92	fp->Xscreen is active screen because it   */
  /*                is set before calling _FI_make_Xwindow    */
/*******
  status = _FI_get_active_screen(&current_screen);
  if (status != 0) 
  {
	current_screen = DefaultScreen(_FI_display);
  }
*******/

  current_screen = fp->Xscreen;
  rootDepth = DefaultDepth(_FI_display, current_screen);

  if (rootDepth > 8) /* form needs to be 8 bits or less */
  {
    vTemplate.screen = current_screen;
    vTemplate.depth = 8; 
    vTemplate.class = PseudoColor; /* add for depth > 8 */

    visualList = XGetVisualInfo(_FI_display, 
    			VisualScreenMask | VisualDepthMask 
				| VisualClassMask, /* add for depth > 8 */
  				&vTemplate, &visualsMatched);

		/*****************************************************/
		/* sml:10-14-94:TR 249406875                         */
		/*  if no visuals of depth 8, get first visual       */
		/*  for this screen (no other restrictions).         */
		/*****************************************************/

	if (visualsMatched == 0)
	{
      visualList = XGetVisualInfo(_FI_display, 
    			VisualScreenMask, /* look for this screen only */ 
  				&vTemplate, &visualsMatched);

	  if (visualsMatched == 0) /* abort for sure here */
		return(0);
	}

    correct_visual = visualList[0].visual;
	correct_depth = visualList[0].depth;

  }
  else
  {
	correct_visual = CopyFromParent;
	correct_depth = rootDepth;
  }

  window = FI_create_window ( _FI_display,
		RootWindow ( _FI_display, current_screen ),
		fp->xlo, fp->ylo,
		MAX ( fp->min_xsize,(int)( fp->xhi - fp->xlo )),
		MAX ( fp->min_ysize,(int)( fp->yhi - fp->ylo )),
		0, correct_depth, 
		InputOutput, correct_visual, value_mask, &win_values );

  if ( window == None )
    {
      return ( FI_NO_WINDOWS_AVAIL );
    }

  fp->Xwindow = window;

	/*** GMD 2/12/92  - Set the XM_DELETE_WINDOW atom in	***/
	/*** the window manager protocols so that when an MWM	***/
	/*** close operation is requested by the operator,	***/
	/*** it will call our FI_process_event loop instead	***/
	/*** of exiting the application immediately.            ***/

  atom = XInternAtom ( _FI_display, "WM_DELETE_WINDOW", False );
  XSetWMProtocols ( _FI_display, window, &atom, 1 );


  fp->Xgc = XCreateGC ( _FI_display, window, None, None );
  _FI_gc = fp->Xgc;

				/*** JAJ:02/14/92 ***/
  fp->Xgc_text = XCreateGC ( _FI_display, window, None, None );
  _FI_text_gc = fp->Xgc_text;


  for ( xx = 0; xx < MAX_WINDOW; xx++ )
    {
      if ( _FI_index_to_Xwindow[xx] == None )
	{
	  _FI_index_to_Xwindow[xx] = window;
	  FI_forms[xx]= fp;
	  break;
	}
	/*************************************************************/
	/* sml:03-31-94:NO TR                                        */
    /*  Quit if no FI_forms slots are available                  */
	/*  We don't clean up after this, but we didn't in other     */
	/*  similar situations anyway.                               */
	/*************************************************************/
	if (xx == MAX_WINDOW) /* looked at all slots; none available */
	{
	  fprintf(stderr, "XFORMS:  Maximum number of form windows exceeded\n");
	  return ( FI_NO_WINDOWS_AVAIL );
    }
  }
  /* X11-4/13/90-Tell the window manager about its initial state */

  fp->collapse_pos_not_set = FALSE;

  wm_hints.flags = StateHint | InputHint | IconPixmapHint;
  wm_hints.input = True;

  if ( fp->attr_mask & FI_DISPLAY_COLLAPSED )
    {
      wm_hints.initial_state = IconicState;
    }
  else
    {
      wm_hints.initial_state = NormalState;
    }

	/* X11-4/13/90-Tell the window manager what to do */

  XStoreName ( _FI_display, fp->Xwindow, fp->name );
  XSetIconName ( _FI_display, fp->Xwindow, "FORM");

/* Wait until collapse icon info is set before calling this function */
/*     GMD 10/10/91                                                  */
/*
  XSetWMHints ( _FI_display, window, &wm_hints );
*/
  cl_hints.res_name = "forms";
  cl_hints.res_class = "Forms";
  XSetClassHint ( _FI_display, window, &cl_hints );


	/**********************/
	/* set collapse stuff */
	/**********************/

  wm_hints.icon_pixmap = None;

  if ( fp->collapse_icon_file  &&  fp->collapse_icon_file[0] )
    {
      int symbol_id, index;

      FI_find_symbol_path_and_id ( FI_data,
			 fp->collapse_icon_file, &symbol_id );

      if ( symbol_id != -1 )
	{
          index = fp->collapse_icon_index;

          if ( _FI_symbols[symbol_id].sym_slot[index].bitmap != 0 )  
                                                    /* symbol in slot */
            {
               wm_hints.icon_pixmap = 
		    XCreateBitmapFromData ( _FI_display, window,
		    _FI_symbols[symbol_id].sym_slot[index].bitmap,
		    _FI_symbols[symbol_id].sym_slot[index].sym_width,
		    _FI_symbols[symbol_id].sym_slot[index].sym_height );
            }
	}
    }

  XSetWMHints ( _FI_display, window, &wm_hints );

  _FI_f_set_window_attr ( window, fp->Xscreen );

  return ( FI_SUCCESS );
}

/* This function displays the form at the location stored in */
/* form's instance */

int FIf_display (Form form_ptr)
{
  XSizeHints sz_hints;
  XWMHints *wmHints;
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  int displayed;
  XEvent event;
  int map_has_not_occurred;

  /* ISDP add a check for NULL pointers */
  if (form == NULL) {
    return ( FI_NO_SUCH_FORM);
  }

  if ( FI_display_mode == FALSE )
    {
      return ( FI_QUIET_MODE_ON );
    }

  FIf_is_displayed ( form_ptr, &displayed );

  if (( form->Xwindow != None ) && ( displayed == 0 ))
    {
	/*** JAJ:02/13/92 ***/ /* dmb:10/08/92:Added cast for safety */
      if ( (int) form->screen == FI_CURRENT_SCRN )
	{
	  FIf_set_Xscreen ( form_ptr, FI_CURRENT_SCRN, 0 );
	}

         /* GMD 4/2/91 */

         form->displayed = 1;

      sz_hints.flags = USPosition | USSize | PMinSize | PMaxSize;
      sz_hints.x =  form->xlo;
      sz_hints.y =  form->ylo;
      sz_hints.width  = form->xhi - form->xlo;
      sz_hints.height = form->yhi - form->ylo;

      if (( form->attr_mask & FI_NOT_RESIZABLE ) ||
          ( form->attr_mask & FI_SAVE_RESTORE ))
	{
	  sz_hints.max_width = sz_hints.width;
	  sz_hints.max_height = sz_hints.height;
	  sz_hints.min_width = sz_hints.width;
	  sz_hints.min_height = sz_hints.height;
	}
      else
	{
	  sz_hints.max_width  = form->max_xsize;
	  sz_hints.max_height = form->max_ysize;
	  sz_hints.min_width  = form->min_xsize;
	  sz_hints.min_height = form->min_ysize;
	}

      /***********************************************************
      XSetNormalHints ( _FI_display, form->Xwindow, &sz_hints );
      ***********************************************************/

      XSetWMNormalHints ( _FI_display, form->Xwindow, &sz_hints );

         /* GMD 10/10/91   perform a GetWMHints before calling     */
         /*                SetWMHints                              */

      if ( ! ( wmHints = XGetWMHints ( _FI_display, form->Xwindow )) )
	{
	  wmHints = XAllocWMHints ();
	}

      wmHints->flags |= StateHint;
      wmHints->initial_state =
		    (( form->attr_mask & FI_DISPLAY_COLLAPSED ) &&
		    ( form->attr_mask & FI_WITHDRAWN )) ? IconicState :
		    NormalState;

      XSetWMHints ( _FI_display, form->Xwindow, wmHints );
      XFree (( caddr_t ) wmHints );

      XSetZoomHints ( _FI_display, form->Xwindow, &sz_hints );

      /* GMD 3/13/92  Check to see if the screen this form is on   */
      /*              has had its stipple pixmaps loaded in.       */
      /*              If not, then load them in.           �        */

      if (_FIpix_gray12_array [form->Xscreen] == (Pixmap) NULL)
         _FI_create_pixmaps (form->Xwindow, form->Xscreen);

     /*** X11-4/13/90-Window attributes should already be set up   ***/
     /*** in the _FI_f_new routine and flush all events pertaining ***/
     /*** to the window.					    ***/

      XSync ( _FI_display, False );
      FI_map_raised ( _FI_display, form->Xwindow );

/*
   First, wait for a map event to be placed on the queue.
   Then, force the drawing of the form to occur here in the FIf_display
   code, rather than waiting to display it as the expose event is generated.
   Also I am setting the initial_form_display flag here.
         GMD 1/8/92                                                        */

      XSync (_FI_display, False);

      if (!(form->attr_mask & FI_DISPLAY_COLLAPSED))
      {
         map_has_not_occurred = 1;
          
         while ( map_has_not_occurred )
         {
			/************************************************/
			/* JAJ:09-27-93	Get events for this window only */
			/*   Use XWindowEvent, not FI_next_event        */
			/************************************************/
			/* sml:TR 249305874: Use FI_window_event        */
            /*XWindowEvent*/ FI_window_event ( _FI_display, form->Xwindow,
			   SubstructureNotifyMask, &event );
            if ( event.type == MapNotify )
	      {
                map_has_not_occurred = 0;
	      }

            FI_process_event (&event, 1);
         }

         FIf_paint_area ((Form)form, 0, 0, (int)form->xhi, (int)form->yhi);
         form->initial_form_display = 1;
      }

      if ( form->attr_mask & FI_WITHDRAWN ) /* <pds-10/9/91> */
	{
          _FI_forms_active++;	/* Need to do a better job here */
		                /* this will not work in the long run */
		                /* GMD 3/6/91 */
	
	  form->attr_mask &= ~FI_WITHDRAWN; /* <pds-10/9/91> */
	}

       /* If the form is a save/restore form, then start a private  */
       /* event loop that will service only the events that pertain */
       /* to this form's window.  GMD 3/10/92                       */

       /* Had to add the ConfigureNotify and Expose events because  */
       /* these are actions that the window manager can perform.    */
       /* If these actions were not permitted, then the forms       */
       /* display could get messed up in certain circumstances.     */
       /* Another way to prevent this would be to use GrabPointer   */
       /* but there is not a good way to implement nesting of a     */
       /* GrabPointer call.   GMD 3/10/92                           */


       if (form->attr_mask & FI_SAVE_RESTORE)
       {
          if (FI_lock_SR_in_Display)   /* GMD 4/20/92 */
          {
          int SaveRestoreCount;
          XEvent event;
          
             SaveRestoreFormsDisplayed++;
             SaveRestoreFormsArray [SaveRestoreFormsDisplayed] = form_ptr;
             SaveRestoreCount = SaveRestoreFormsDisplayed;

             do
             {
                FI_next_event (_FI_display, &event);


                if ((event.xany.window == form->Xwindow) ||
                    (event.type == ConfigureNotify) ||
                   (event.type == Expose))
                   FI_process_event ( &event, 0 );
             }
             while (SaveRestoreCount == SaveRestoreFormsDisplayed);
          }
          else
          {
             SaveRestoreFormsDisplayed++;
             SaveRestoreFormsArray [SaveRestoreFormsDisplayed] = form_ptr;
          }
       }
    }
  else
    {
     return ( FI_SUCCESS );
    }

  /* Set the start seq because the label is greater then 0 */

  /* Moved this functionality to FI_process_event expose event */
  /* because the expose event was causeing the field to drop   */
  /* out of sequencing it it was called here.                  */
  /*          GMD 10/28/91                                     */

/*****************************************************
  if ( form->seq_label > 0 )
    {
      FIg_start_seq ( form_ptr, form->seq_label );
    }
******************************************************/

  return ( FI_SUCCESS );
}



/* This function erases the form's window */

int FIf_erase (Form form_ptr)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  Window window = form->Xwindow;
  XEvent event;
  int unmap_has_not_occurred;

/** <pds-10/9/91>
  FIf_is_displayed ( form_ptr, &displayed );
**/
  /* ISDP add a check for NULL pointers */
  if (form == NULL) {
    return ( FI_NO_SUCH_FORM);
  }

  if ( window != None && form->displayed )
    {
     /* X11-4/13/90-Get rid of form from screen */

      if (form->attr_mask & FI_DISPLAY_COLLAPSED)
      {
        FI_withdraw_window (_FI_display, window, form->Xscreen);
      }
      else
      {
        FI_unmap_window ( _FI_display, window );
      }

      _FI_forms_active--;
      form->collapse_pos_not_set = TRUE;
      form->attr_mask |= FI_WITHDRAWN;	/** <pds-10/9/91> **/

/*
   Wait for the unmap event to be placed on the queue, then process it.
         GMD 1/9/92                                                        */

       XSync (_FI_display, False);

       if (!(form->attr_mask & FI_DISPLAY_COLLAPSED))
       {
          unmap_has_not_occurred = 1;

          while (unmap_has_not_occurred)
          {
			/************************************************/
			/* JAJ:09-27-93	Get events for this window only */
			/*   Use XWindowEvent, not FI_next_event        */
			/************************************************/
			/* sml:TR 249305874: Use FI_window_event        */
            /*XWindowEvent*/ FI_window_event ( _FI_display, window,
			   SubstructureNotifyMask, &event );
            if ( event.type == UnmapNotify )
              {
                unmap_has_not_occurred = 0;
              }
             FI_process_event (&event, 1);
          }
       }

       /* If the form is a save/restore form, then decrement the   */
       /* SaveRestoreFormsDisplayed counter.   GMD 3/10/92         */

       if (form->attr_mask & FI_SAVE_RESTORE)
          SaveRestoreFormsDisplayed -= 1;
    }
  /* GMD 4/2/91 */

  form->displayed = 0;

  XSync (_FI_display, False);

  return ( FI_SUCCESS );
}


int _FI_default_function (void)
{
  return ( TRUE );
}

/* dmb:08/25/92:Added for ANSI type checking */
/* ARGSUSED */
int _FI_default_process_data_function (int data_type,
                                       char *data_string,
                                       Form form)
{
  return ( TRUE );
}

/* dmb:08/25/92:Added for ANSI type checking */
/* ARGSUSED */
int _FI_default_set_window_attr_function (Window window_number)
{
  return ( TRUE );
}

/* dmb:08/25/92:Added for ANSI type checking */
/* ARGSUSED */
int _FI_default_activate_help_function (Form form)
{
  return ( TRUE );
}

int FIf_process_point (Form          form_ptr,
                       int           xpos,
                       int           ypos,
                       int           button,
                       unsigned int  state,
                       Time          ttag)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  Window		window;
  struct FIgadget_obj * gadget = NULL;
  double		value = 0.0;
  int			complete = FALSE;
  int			status;

  /* ISDP add a check for NULL pointers */
  if (form == NULL) {
    return ( FI_NO_SUCH_FORM);
  }
  window = form->Xwindow;

  /* If not middle button then return */

  if ( button != _FI_select_button )  /* GMD 1/14/92 */
    {
      return ( FI_ILLEGAL_VALUES );
    }

  /* find gadget that claims the point */

  _FI_g_find_gadget ( form->group, xpos, ypos, &gadget );

  if ( gadget )
    {
      value = gadget->FIgadget.value;

     /* Send form input here to notify user */
     /* gadget selected */

      if ( form->initial_notification_routine &&
	   ( gadget->FIgadget.attr_mask & FI_INITIAL_NOTIFY ) &&
	   ( gadget->FIgadget.label > 0 ))	/* GMD 10/30/90 */
	{
	  int save_gadget_label = gadget->FIgadget.label;

					/*** JAJ:01/20/92 ***/
	  _FI_notification_type = FI_INITIAL_NOTIFICATION;

	  form->initial_notification_routine ( form->form_label,
			 gadget->FIgadget.label, value, form_ptr );

	  status = FIg_is_valid ( (Form)form, save_gadget_label );

	  if ( status != FI_SUCCESS )
	    {
	      return ( FI_SUCCESS );
	    }

          /* GMD 3/30/92  -  Insure that you have the right gadget pointer */

          _FI_g_find_gadget ( form->group, xpos, ypos, &gadget );
	}

      status = _FI_g_track_mouse ( gadget, window, xpos, ypos,
						 &complete, &value );
      if ( status != FI_SUCCESS )
	{
	  return ( FI_SUCCESS );
	}

	/* If gadget completed then call notification routine */

      if ( complete )
	{
	  if ( form->notification_routine			&&
		 ( ! ( gadget->FIgadget.attr_mask &
				 FI_NO_COMPLETE_NOTIFY ))	&&
		 ( gadget->FIgadget.label > 0 )      )/* GMD 10/30/90 */
				        /* prevent scroll bars used */
				        /* in field gadgets, etc. */
				        /* from calling notification */
	    {
	      int save_gadget_label = gadget->FIgadget.label;

		/**************************************************/
		/* Put in a patch here to fix the damn scroll bar */
		/* which returns bogus values when any of its	  */
		/* buttons are pressed, or when the puck is	  */
		/* dragged to the top or bottom of the trough.	  */
		/* 8/13/90 - GMD				  */
		/**************************************************/

	      if ( gadget->FIgadget.type == FI_SCROLL )
		{
		  value = gadget->FIgadget.value;
		}

					/*** JAJ:01/20/92 ***/
	      _FI_notification_type = FI_COMPLETION_NOTIFICATION;

	      if ( _FI_record_notification_routine )
		{
		  _FI_record_notification_routine ( form->form_label,
			    gadget->FIgadget.label, value, form_ptr );
		}

	      form->notification_routine ( form->form_label,
			     gadget->FIgadget.label, value, form_ptr );

	      status = FIg_is_valid ( (Form)form, save_gadget_label );
	      if ( status != FI_SUCCESS )
		{
		  return FI_SUCCESS;
		}
	    }
	}
    }
  else if ( form->button_event_routine )
    {
      form->button_event_routine ( form->form_label, xpos, ypos,
					button, state, ttag, form_ptr );
    }

  return ( FI_SUCCESS );
}


int FIf_paint_area (Form form_ptr,
                    int  xlo,
                    int  ylo,
                    int  xhi,
                    int  yhi)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  Window window;
  XRectangle clip_rect;

  /* ISDP add a check for NULL pointers */
  if (form == NULL) {
    return ( FI_NO_SUCH_FORM);
  }
  window = form->Xwindow;

  if (( window == None ) || ( form->displayed == 0 ))
    {
      return ( FI_FORM_NOT_DISPLAYED );
    }

  /* Set up clipping */

  _FI_form_clipping_on = TRUE;

  _FI_clip_xlo = xlo;
  _FI_clip_ylo = ylo;
  _FI_clip_xhi = xhi;
  _FI_clip_yhi = yhi;

  /* X11-4/13/90-Adjust the clip region to the appropriate box */

  clip_rect.x = xlo;
  clip_rect.y = ylo;
  clip_rect.width = xhi - xlo;
  clip_rect.height = yhi - ylo;
  XSetClipRectangles ( _FI_display, form->Xgc, 0, 0, &clip_rect,
						 1, Unsorted );

  /* GMD   10/17/91    This may clear up field text overwrite problem */

  _FI_gc = form->Xgc;
  _FI_text_gc = form->Xgc_text;	/*** JAJ:02/14/92 ***/

  _FI_f_paint ( form );

  /* X11-4/13/90-Adjust the clip region to entire form */

  XSetClipMask ( _FI_display, form->Xgc, None );
  _FI_form_clipping_on = FALSE;

  XFlush ( _FI_display );

  return ( FI_SUCCESS );
}

/*  New Function --- GMD 11/5/91                                      */
/*  FI_get_last_paint_area returns the global variables that were set */
/*  the last time that FIf_paint_area was called.  This will          */
/*  primarily be used when the window_event_routine is called, and    */
/*  the application needs to know what portion of the form to refresh */
/*  its special graphics on.                                          */

FI_get_last_paint_area (int *xlo,
                        int *ylo,
                        int *xhi,
                        int *yhi)
{
  *xlo = _FI_clip_xlo;
  *ylo = _FI_clip_ylo;
  *xhi = _FI_clip_xhi;
  *yhi = _FI_clip_yhi;

  return ( FI_SUCCESS );
}


/* ARGSUSED */
Bool _FI_flush_destroy (Display *display,
                        XEvent *event,
                        Window *wind)
{
  if (( event->type == DestroyNotify )			&&
	 ( event->xdestroywindow.window == *wind )	 )
    {
      return ( True );
    }
  else
    {
      return ( False );
    }
}


int FIf_cvrt_to_perm_win (Form form_ptr)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  /* ISDP add a check for NULL pointers */
  if (form == NULL) {
    return ( FI_NO_SUCH_FORM);
  }

  if ( form->attr_mask & FI_SAVE_RESTORE )
    {
     /** X11-5/17/90-Create a new window with save_under flag set **/

      int window_index;
      Window wind_arg;
      unsigned long value_mask;
      XSetWindowAttributes set_win_attr;
      XWindowAttributes win_attr;
      XWMHints *wm_hints;
      XSizeHints norm_hints, zoom_hints;
      XClassHint cl_hints;
      XEvent evt;
      int display_flag;
	  Atom atom;

	  /*******************************************************/
	  /* sml:03-31-94:NO TR                                  */
	  /*  check window index here to see if form window is   */
	  /*  in FI_forms array.  If not, forget it.             */
	  /*******************************************************/

	  window_index = _FI_Xwindow_to_index ( form->Xwindow );
	  if (window_index < 0)
	  {
		return(FI_NO_SUCH_FORM);
	  }

      /* GMD   3/10/92  Fix for nested Save/Restore forms */

      FIf_is_displayed ((Form)form, &display_flag);

      if (display_flag)
         SaveRestoreFormsDisplayed--;

      form->attr_mask &= ~ FI_SAVE_RESTORE;

/*      window_index = _FI_Xwindow_to_index ( form->Xwindow ); */

      XGetWindowAttributes ( _FI_display, form->Xwindow, &win_attr );
      wm_hints = XGetWMHints ( _FI_display, form->Xwindow );

     /* ps,dmb:03/08/91:We should probably use XGetWMNormalHints or 
      XGetWMSizeHints because these two are obsolete*/

      XGetNormalHints ( _FI_display, form->Xwindow, &norm_hints );
      XGetZoomHints ( _FI_display, form->Xwindow, &zoom_hints );

      FI_destroy_window ( _FI_display, form->Xwindow );
      wind_arg = form->Xwindow;

     /** Remove this destroy event or else this form is toast **/

      while ( ! FI_check_if_event ( _FI_display, &evt, _FI_flush_destroy,
					 ( char *) &wind_arg ))
	{
	     /** Wait **/
	};

      set_win_attr.background_pixel = FI_translate_color (
					 form->Xscreen, form->bgcolor );
      set_win_attr.save_under = False;
      set_win_attr.event_mask = FI_EVENT_MASK;
      set_win_attr.colormap = _FI_cmap;

      value_mask = CWBackPixel | CWSaveUnder | CWEventMask | CWColormap;

      form->Xwindow = FI_create_window ( _FI_display,
			RootWindow ( _FI_display, form->Xscreen ),
			form->xlo, form->ylo,
			MAX ( form->min_xsize,form->orig_xsize ),
			MAX ( form->min_ysize,form->orig_ysize ),
			0,
			DefaultDepth ( _FI_display,form->Xscreen ),
			InputOutput, CopyFromParent,
			value_mask, &set_win_attr );



	  /*** SML 04-19-93	Do this here since window was       ***/
	  /*** destroyed to make a permanent window             ***/
      /***                                                  ***/
	  /*** GMD 2/12/92  - Set the XM_DELETE_WINDOW atom in	***/
	  /*** the window manager protocols so that when an MWM	***/
	  /*** close operation is requested by the operator,	***/
	  /*** it will call our FI_process_event loop instead	***/
	  /*** of exiting the application immediately.            ***/

	  atom = XInternAtom ( _FI_display, "WM_DELETE_WINDOW", False );
 	  XSetWMProtocols ( _FI_display, form->Xwindow, &atom, 1 );


      wm_hints->flags |= StateHint;
      wm_hints->initial_state = NormalState;

      XStoreName ( _FI_display, form->Xwindow, form->name );
      XSetIconName ( _FI_display, form->Xwindow, "FORM");

      /************************************************************
      XSetNormalHints ( _FI_display, form->Xwindow, &norm_hints );
      ************************************************************/

      XSetWMNormalHints ( _FI_display, form->Xwindow, &norm_hints );

      XSetZoomHints ( _FI_display, form->Xwindow, &zoom_hints );
      XSetWMHints ( _FI_display, form->Xwindow, wm_hints );
      XFree ((caddr_t)wm_hints );

      cl_hints.res_name = "forms";
      cl_hints.res_class = "Forms";
      XSetClassHint ( _FI_display, form->Xwindow, &cl_hints );

      _FI_index_to_Xwindow[window_index]= form->Xwindow;

     /* Call this so fei can modify the window */

      _FI_f_set_window_attr ( form->Xwindow, form->Xscreen );

      FIg_disable ( (Form)form, FI_CVT_TO_PERM_WIN );

	  /********************************************************/
	  /* sml:12-02-93 TR 249301795                            */
	  /*  Fix problem with forms being displayed in distorted */
	  /*  shapes and sizes in PDM.  This happens when you     */
	  /*  call FIf_cvrt_to_perm_win before FIf_display        */
	  /*                                                      */
	  /*  So check if the form is displayed or not before     */
      /*  mapping it.  If it's not displayed, it will be      */
	  /*  mapped when it is displayed.                        */
	  /********************************************************/

	  if (display_flag == TRUE)
	  {
        FI_map_window ( _FI_display, form->Xwindow );

/* sml:02-21-94 Need to unguard this after PLOAD */
/*#if (defined(sun) || defined(sparc) && defined(SYSV)) || (defined(mips))*/
		/**************************************************/
		/* sml:02-21-94:TR 249400327                      */
		/*  FIf_cvrt_to_perm_win causes EMS crash.        */
		/*  Call window event routine here to cause       */
		/*  FI_DISPLAY code to be executed after          */
		/*  destroying the window.                        */
		/**************************************************/
		if (form->window_event_routine)
		{
		  form->window_event_routine(form->form_label, FI_DISPLAY, form);
		}
/*#endif*/
	  }
    }

  return ( FI_SUCCESS );
}


/*** This function sets the location of the form relative ***/
/*** to the virtual screen 				  ***/

int FIf_set_location (Form form_ptr,
                      int  xpos,
                      int  ypos)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  int xsize;
  int ysize;

  /* ISDP add a check for NULL pointers */
  if (form == NULL) {
    return (FI_NO_SUCH_FORM);
  }
  xsize = form->xhi - form->xlo;
  ysize = form->yhi - form->ylo;

  /* if location is not different return */
  if ( ( form->xlo == xpos ) && ( form->ylo == ypos ) )
    {
      return ( FI_SUCCESS );
    }

  form->xlo = xpos;
  form->ylo = ypos;
  form->xhi = xpos + xsize;
  form->yhi = ypos + ysize;

  _FI_f_adjust_location ( form->Xscreen, & form->xlo, & form->ylo,
				& form->xhi, & form->yhi );

  /* Set the orig location */

  form->orig_xlo = xpos;
  form->orig_ylo = ypos;

  /* move the window now if possible */

  _FI_f_modify_window ( form );

  return ( FI_SUCCESS );
}



/* MEMORY */

/* This function creates a form and returns the form pointer */

int _FI_f_new (int                 label,
               char               *form_name,
               int               (*notification_routine)(),
               struct FIform_obj **form)
{
  FILE			*fin = ( FILE *) NULL;
  int			form_version;
  int			num_gadgets = FI_GRP_ALLOC_SIZE;
  int			num_gadgets_on_form;
  int			xx;
  struct FIgroup_obj  *	group;
  struct FIform_obj   *	fp;
  jmp_buf		env;
  /**XSizeHints		sz_hints;**/
  int			status;
  int			form_xsize, form_ysize;

printf("FI_F_new 1\n");

  *form = NULL;

  /* error handling */

  if ( xx = setjmp ( env ))
    {
      return ( xx );
    }
printf("FI_F_new 2\n");

  /* create form structure */

  *form = (struct FIform_obj *) calloc ( 1, sizeof (struct FIform_obj));
printf("FI_F_new 3\n");

  if ( ! *form )
    {
      *form = NULL;
      return ( FI_NO_MEMORY );
    }

  /* Assign local form pointer to reduce code */

  fp = *form;
  fp->form_label = label;
  fp->notification_routine = notification_routine;
  fp->Xwindow = None;
  fp->Xscreen = DefaultScreen ( _FI_display );
  fp->Xgc = None;
  fp->screen = FI_CURRENT_SCREEN;
  fp->bgcolor = FI_LT_GREY;
  fp->min_xsize = 10;
  fp->min_ysize = 10;
  fp->max_xsize = FI_current_screen_width;
  fp->max_ysize = FI_current_screen_height;
  fp->begin_label = BEGIN_USER_LABEL;
  fp->begin_neg_label = -1;

  /* GMD 4/2/91 */
  fp->displayed = 0;

  /*** read in the form file, if specified ***/
printf("FI_F_new 4\n");

  if ( form_name[0])
    {
      char *ch;

      if (( ch = strrchr ( form_name, '/')) == NULL )
	{
		/* find form's complete path */

	  if ( FI_find_form ( FI_data, form_name ))
	    {
		_FI_s_free ( ( char *) *form );
		*form = NULL;
		return ( FI_FORM_FILE_NOT_FOUND );
	    }
	  _FI_s_rep ( &fp->name, form_name );
	}
      else
	{
	  strcpy ( FI_data, form_name );
	  _FI_s_rep ( &fp->name, ++ch );
	}

     /* read the form's instance from disk */

      if ( fin = fopen ( FI_data, "r"))
	{
	  _FI_read_enter ( fin, env );

	  status = _FI_f_load_form ( *form, &num_gadgets,
					 &form_version );

	  if ( status )
	    {
		fclose ( fin );
		_FI_s_free ( ( char *) *form );
		*form = NULL;
		return ( status );
	    }
	}
      else
	{
	  _FI_s_free ( ( char *) *form );
	  *form = 0;

	  if ( errno == ENOENT )
	    {
		return ( FI_FORM_FILE_NOT_FOUND );
	    }
	  else
	    {
		return ( FI_FORM_FILE_OPEN_DENIED );
	    }
	}

	/***  Only shrink the form, due to precious screen ***/
	/***  "real estate" on a large screen 		   ***/

      /***************************************************************
      if ( ( fp->screen_width >= FI_current_screen_width )	||
	   ( fp->screen_height >= FI_current_screen_height )	 )
	{
	 fp->adjusted_size = TRUE;
	}
      ***************************************************************/
    }
  else	/** No form name given **/
    {
	/*** This is set so that when the form	***/
	/*** is saved it will store the current	***/
	/*** screen size in its instance	***/

      fp->initial_creation = TRUE;

     /* Set name to null because dynamically created */

      _FI_s_rep ( &fp->name, "");
    }
printf("FI_F_new 5\n");

  /** <pds-10/9/91> Initialize private attribute **/

  fp->attr_mask |= FI_WITHDRAWN;

	/***  If the form was created on a different size screen, ***/
	/*** then  scale the gadgets to the proportional values.  ***/

/****************************************************************
  if ( fp->adjusted_size )
    {
      int width  = fp->xhi - fp->xlo;
      int height = fp->yhi - fp->ylo;

      dx = (float) FI_current_screen_width / (float) fp->screen_width;
      dy = (float) FI_current_screen_height / (float) fp->screen_height;

      fp->xlo = (short) ( fp->xlo * dx );
      fp->ylo = (short) ( fp->ylo * dy );
      width   =  width * dx;
      height  =  height * dy;
      fp->xhi = (short) ( fp->xlo + width  );
      fp->yhi = (short) ( fp->ylo + height );
    }
*******************************************************************/

  /* X11-4/13/90-Create the Xwindow here and not in display */

  /* X11-4/13/90-Create the Xwindow here and not in display */

		/******************************************/
		/*** Put all the window-creation code	***/
		/*** in a common function.		***/
		/************************ JAJ:02/12/92	***/
printf("FI_F_new 6\n");
  status = _FI_make_Xwindow ( fp );
printf("FI_F_new 7\n");

  if ( status != FI_SUCCESS )
    {
      return ( status );
    }

  /* Create the group for all gadgets on the form */

  group = (struct FIgroup_obj *) calloc ( 1,
					 sizeof (struct FIgroup_obj ));
  if ( ! group )
    {
      fclose ( fin );
      return ( FI_NO_MEMORY );
    }

  num_gadgets_on_form = num_gadgets;
printf("FI_F_new 8\n");

  if ( num_gadgets == 0 )
    {
      num_gadgets = FI_GRP_ALLOC_SIZE;
    }

  if ( _FI_grp_alloc ( group, num_gadgets ))
    {
      fclose ( fin );
      _FI_s_free ( ( char *) *form );
      *form = NULL;
      return ( FI_NO_MEMORY );
    }

  group->FIgadget.form = *form;
  group->FIgadget.type = FI_GROUP;

  fp->group = group;

  /* If no gadgets on form then return */

  if ( num_gadgets_on_form == 0 )
    {
      fclose ( fin );
      fp->activated = TRUE;
      return ( FI_SUCCESS );
    }
printf("FI_F_new 9\n");

  if ( form_name[0])
    {
     /* read gadgets from disk */
printf("FI_F_new 9a\n");

      _FI_f_load_gadgets ( *form, form_version );
printf("FI_F_new 9b\n");

     /* send an activate to all the gadgets */

      _FI_g_activate ( (struct FIgadget_obj *)group );
printf("FI_F_new 9c\n");
      fp->activated = TRUE;

      fclose ( fin );
printf("FI_F_new 9d\n");

	/*** If the form was created on a different size screen, ***/
	/*** then scale the gadgets to the proportional values.  **/
      /****************************************************
      if ( fp->adjusted_size )
        {
printf("FI_F_new 9e\n");
	   _FI_g_adjust_size ( group, dx, dy );
printf("FI_F_new 9f\n");
        }
      ****************************************************/
    }

	/**********************  JAJ:11/11/91	***/
	/*** Do Automatic form scaling stuff	***/
	/******************************************/
  if (  ( ( FI_auto_scale_factor_x != 1.0 ) ||
          ( FI_auto_scale_factor_y != 1.0 )  ) &&   /* jaj:08-03-93   */
        !(fp->attr_mask & FI_NOT_RESIZABLE)   ) /* add this condition */
    {                                           /* for 21-inch screen */
      form_xsize = MAX ( 10, fp->orig_xsize );
      form_ysize = MAX ( 10, fp->orig_ysize );

      form_xsize = (int) ( form_xsize * FI_auto_scale_factor_x );
      form_ysize = (int) ( form_ysize * FI_auto_scale_factor_y );
printf("FI_F_new 9g\n");

      FIf_set_size ( (Form) fp, form_xsize, form_ysize );
printf("FI_F_new 9h\n");

      fp->orig_xlo = (short) ( fp->orig_xlo * FI_auto_scale_factor_x );
      fp->orig_ylo = (short) ( fp->orig_ylo * FI_auto_scale_factor_y );

printf("FI_F_new 9i\n");
      FIf_set_location ( (Form) fp, (int) fp->orig_xlo,
				    (int) fp->orig_ylo );

printf("FI_F_new 9j\n");
      fp->orig_xsize = form_xsize;
      fp->orig_ysize = form_ysize;
    }
printf("FI_F_new 10\n");

  return ( FI_SUCCESS );
}



int FIf_new (int    label,
             char  *form_name,
             int ( *notification_routine ) (),
             Form  *form)
{
  int status;
  int	form_index;

printf(">>> FIf_new 1\n");

  /* dmb:03/24/91:was (struct FIform_obj *) - changed to make SMART happy*/
  status = _FI_f_new ( label, form_name, notification_routine,
					 (struct FIform_obj **) form );

  /* If bad status returned then, return immediately the status */
printf(">>> FIf_new 2\n");

  if ( status )
    {
      return ( status );
    }

     /* Form was created correctly; add to form list */

	/*** JAJ:11/08/91 -- Need to break this call up into	***/
	/*** two statements, so ACC compiler will re-evaluate	***/
	/*** ".gadgets" address after _FI_form_list changes	***/
	/*** after realloc in _FI_grp_get_next_slot ().		***/

  form_index = _FI_grp_get_next_slot ( _FI_form_list );

  _FI_form_list->FIgroup.gadgets[ form_index ] =
				(struct FIgadget_obj * ) *form;
printf(">>> FIf_new 3\n");

  return ( FI_SUCCESS );
}



/* This function sets the size of the form */

int FIf_set_size (Form form_ptr,
                  int  xsize,
                  int  ysize)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  
  /* store current form sizes for scaling */

  int form_xlo;
  int form_ylo;
  int form_xhi;
  int form_yhi;

  /* ISDP Add check for null pointer */
  if (form == NULL) {
    return FI_NO_SUCH_FORM;
  }
  form_xlo = form->xlo;
  form_ylo = form->ylo;
  form_xhi = form->xhi;
  form_yhi = form->yhi;

  xsize = MAX ( 10, xsize );
  ysize = MAX ( 10, ysize );

  /* if size is not different return */

  /* dmb:04/15/91:The -1s cure the panel menu location bug:Why?? */
  if (  ( xsize == ( form_xhi - form_xlo - 1 ) ) 	&&
	 ( ysize == ( form_yhi - form_ylo - 1 ) )	 )
    {
	return ( FI_SUCCESS );
    }

  form->xhi = form_xlo + xsize;
  form->yhi = form_ylo + ysize;


  /* if form size already set up then send message to gadgets */

  if ( ! ( form->attr_mask & FI_NOT_SCALABLE ) )
    {
      float delta_x;
      float delta_y;

      if (( form_xhi > form_xlo ) && ( form_yhi > form_ylo ))
	{
	  delta_x = (float) xsize / (float) ( form_xhi - form_xlo );
	  delta_y = (float) ysize / (float) ( form_yhi - form_ylo );

	  if ( delta_x == 0.0 )
	    {
		delta_x = 1.0;
	    }

	  if ( delta_y == 0.0 )
	    {
		delta_y = 1.0;
	    }

	  _FI_g_adjust_size ( (struct FIgadget_obj *)form->group, delta_x, delta_y );
	}
    }

  _FI_f_adjust_location ( form->Xscreen, & form->xlo,
			 & form->ylo, & form->xhi, & form->yhi );

  /* move the window now if possible */

  _FI_f_modify_window ( form );

  return ( FI_SUCCESS );
}


/* This function deletes the form and frees all memory */
/* associated with the form */

int _FI_f_delete (struct FIform_obj *form)
{
  int slot, xx;
  int window_index;

  /* ISDP add a check for NULL pointers */
  if (form == NULL) {
    return (FI_NO_SUCH_FORM);
  }
	/*** X11-6/22/90-This removes it from the form list,	***/
	/***  so in the event code it will never find the form	***/
	/***  and can't call this routine a second time. If	***/
	/***  another client destroys the window, then this	***/
	/***  code will be called to clean up.			***/

  window_index = _FI_Xwindow_to_index ( form ->Xwindow );

  if ( window_index >= 0 )
    {
      FI_forms [ window_index ] = 0;
      /* sml:04-04-94:NO TR     Xerox problem             */
      /*  remove corresponding window for this form       */
      _FI_index_to_Xwindow [ window_index ] = None;
    }
  /***************************************************
    else
    {
      printf ("FORMS error: _FI_f_delete\n");
    }
  ***************************************************/

  form->Xwindow = None;	/* Prevent gadget erasing */

  if ( form->window_event_routine )
    {
     form->window_event_routine ( form->form_label, FI_DELETE,
						 (Form) form );
    }


  /*** Pass false because the group doesn't need	 ***/
  /*** to be re-calculated				 ***/

  _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) form->group,
					_FI_g_delete, FALSE, 0 );

  /* delete form's group */

  /* NOTE Do not call _FI_grp_delete */

  if ( form->group->FIgroup.gadgets )
    {
      _FI_s_free ( ( char *) form->group->FIgroup.gadgets );
    }

  _FI_s_free ( ( char *) form->group );

  /* free memory associated with form */

  _FI_s_free ( form->name );

  /*** JAJ:03/15/91 ***/
  _FI_s_free ( form->person );
  /*** form->person = 0;  ***/

  _FI_s_free ( form->collapse_icon_file );

  if ( form->num_desc )
    {
     /* Loop and free description */

      for ( xx = 0; xx < form->num_desc; xx++ )
         {
	   _FI_s_free ( form->description[xx]);
         }

      _FI_s_free ( ( char *) form->description );
    }

  /* free memory associated with the child node */

  if ( form->child_node )
    {
      if ( form->child_node->childForm )
           {
		 _FI_s_free ( ( char *) form->child_node->childForm );
           }

      _FI_s_free ( ( char *) ((struct FIform_obj *) form)->child_node );
    }

  if ( form->Xgc )
    {
      XFreeGC ( _FI_display, form->Xgc );
    }

  if ( form->Xgc_text )		/*** JAJ:02/14/92 ***/
    {
      XFreeGC ( _FI_display, form->Xgc_text );
    }

  /* Find the slot where the form is */

  slot = _FI_grp_get_slot ( _FI_form_list, (struct FIgadget_obj *)form );

  /* Free this location */

  if ( slot > -1 )
    {
      _FI_form_list->FIgroup.gadgets[slot]= 0;
    }

			/*** JAJ:01/20/92 ***/
  if ( form->menu_user_pointer )
    {
      free ( form->menu_user_pointer );
    }

  _FI_s_free ( ( char *) form );

  return ( FI_SUCCESS );
}


int FIf_delete (Form form)
{
  /* ISDP add a check for NULL pointers */
  if (form == NULL) {
    return ( FI_SUCCESS);
  }

  if ( ((struct FIform_obj *) form )->Xwindow != None )
    {
      FIf_erase ( form );
      FI_destroy_window ( _FI_display,
			 ((struct FIform_obj *) form )->Xwindow );
      XSync ( _FI_display, False );
    }

  return ( _FI_f_delete ( (struct FIform_obj *) form ));
}



/******************************* JAJ:09/05/90	****/
/**** This is used to verify that		****/
/**** the form pointer passed in is valid.	****/
/**** NOTE: this doesn't recognize MENUS!!!!	****/
/***************************************************/

int FIf_is_valid (Form form_ptr)
{
  int ii;
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  struct FIform_obj *temp_form;

  /* ISDP add a check for NULL pointers */
  if (form == NULL) {
    return ( FI_NO_SUCH_FORM);
  }

  for ( ii = 0; ii < (int)_FI_form_list->FIgroup.size; ii++ )
    {
      temp_form = (struct FIform_obj *)
				 _FI_form_list->FIgroup.gadgets[ii];

      if ( temp_form && ( temp_form == form ))
	{
	  return ( FI_SUCCESS );
	}
    }

  return ( FI_NO_SUCH_FORM );

}	/*** int FIf_is_valid () ***/



/********************************* JAJ:09/05/90	  **********/
/**** This is used to verify that the form ptr		****/
/**** and gadget label passed in were still valid.	****/
/**** NOTE: this doesn't recognize MENUS!!!!		****/
/***********************************************************/

int FIg_is_valid (Form form_ptr,
                  int  gadget_label)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  struct FIgadget_obj *gadget;
  int status;

  /* ISDP Note valid now fails for null pointer */
  status = FIf_is_valid ( (Form) form );

  if ( status == FI_NO_SUCH_FORM )
    {
     return ( FI_NO_SUCH_FORM );
    }

  gadget = (struct FIgadget_obj *)_FI_g_get_id ( form, gadget_label );

  if ( ! gadget )
    {
    return ( FI_NO_SUCH_GADGET );
    }

  return ( FI_SUCCESS );

}  /*** int FIg_is_valid () ***/



/* This function retrieves the pointer to the form's GC */
int FIf_get_GC (Form   form_ptr,
                GC    *form_GC)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  /* ISDP add a check for NULL pointers */
  if (form == NULL) {
    return ( FI_NO_SUCH_FORM);
  }
  
  *form_GC = form->Xgc;

  return ( FI_SUCCESS );
}



int FI_set_auto_scaling_factors (double scale_factor_x,
                                 double scale_factor_y)
{
  if (	( scale_factor_x > 0.0 )	&&
  	( scale_factor_y > 0.0 )	 )
    {
      FI_auto_scale_factor_x = scale_factor_x;
      FI_auto_scale_factor_y = scale_factor_y;

      return ( FI_SUCCESS );
    }
  else
    {
      return ( FI_ILLEGAL_VALUES );
    }
}



int FI_get_auto_scaling_factors (double *scale_factor_x,
                                 double *scale_factor_y)
{
  * scale_factor_x = FI_auto_scale_factor_x ;
  * scale_factor_y = FI_auto_scale_factor_y ;

  return ( FI_SUCCESS );
}




/*** JAJ:01/20/92 ***/
int FI_get_form_menu_type (Form    form_menu,
                           int    *form_menu_type)
{
  int			  sts, menu_type;
  struct FIform_obj	* form_ptr = (struct FIform_obj *) form_menu;

  sts = FIf_is_valid ( form_menu );

  if ( sts != FI_SUCCESS )
    {
      return ( sts );
    }

  if ( form_ptr->menu_user_pointer )
    {
      menu_type = ( (struct menu_info_st *)
			form_ptr->menu_user_pointer)->menu_type;

      if ( menu_type == BAR_MENU )
	{
	  * form_menu_type = FI_BAR_MENU_TYPE;
	}
      else if ( menu_type == PANEL_MENU )
	{
	  * form_menu_type = FI_PANEL_MENU_TYPE;
	}
      else if ( menu_type == POCKET_MENU )
	{
	  * form_menu_type = FI_POCKET_MENU_TYPE;
	}
      else if ( menu_type == FI_TEAR_OFF_BAR_MENU_TYPE )
	{
	  * form_menu_type = FI_TEAR_OFF_BAR_MENU_TYPE;
	}
      else /* if ( menu_type == FI_TEAR_OFF_PANEL_MENU_TYPE ) */
	{
	  * form_menu_type = FI_TEAR_OFF_PANEL_MENU_TYPE;
	}
    }
  else	/*** it's not a menu ***/
    {
      * form_menu_type = FI_FORM_TYPE;
    }

  return ( FI_SUCCESS );
}


/*** JAJ:01/20/92 ***/
int FI_get_num_forms_menus (int *num_forms_menus)
{
  int	ii;
  int	count = 0;

  for ( ii = 0 ; ii < (int)_FI_form_list->FIgroup.size ; ii++ )
    {
      if ( _FI_form_list->FIgroup.gadgets[ii] )
	{
	  count++;
	}
    }

  * num_forms_menus = count;

  return ( FI_SUCCESS );
}


/*** JAJ:01/20/92 ***/
int FI_get_forms_menus (Form     forms_menus_array[],
                        int     *num_forms_menus)
{
  int	ii;
  int	array_index = 0;

  for ( ii = 0 ; ii < (int)_FI_form_list->FIgroup.size ; ii++ )
    {
      if ( _FI_form_list->FIgroup.gadgets[ii] )
	{
	  forms_menus_array[array_index] = (Form)
				_FI_form_list->FIgroup.gadgets[ii] ;
	  array_index++;
	}
    }

  * num_forms_menus = array_index;

  return ( FI_SUCCESS );
}

/* GMD 4/20/92 */

Form FI_get_save_restore_form(void)
{
   if (SaveRestoreFormsDisplayed)
      return (SaveRestoreFormsArray[SaveRestoreFormsDisplayed]);
   else
      return (0);
}

/* GMD 4/20/92 */

int FI_set_SR_lockout(void)
{
   FI_lock_SR_in_Display = 1;

   return (FI_SUCCESS);
}

/* GMD 4/20/92 */

Form FI_get_form_by_window (Window window)
{
int window_index;
Form my_form;

   window_index = _FI_Xwindow_to_index (window);

   if (window_index == -1)
      return (NULL);
   else
   {
      my_form = (Form)FI_forms[window_index];
      return (my_form);
   }
}

/* ---------------------------------------------------------------
 * Special status routines for ISDP programs
 */
int FI_get_isdp_status(int *i1, int *i2, int *i3, int *i4, int *i5, int *i6)
{
  int i,cnt,max;

  /* Windows */
  max = -1;
  for(i = 0, cnt = 0; i < MAX_WINDOW; i++) {
    if (FI_forms[i] != NULL) {
      cnt++;
      max = i;
    }
  }
  *i1 = MAX_WINDOW;
  *i2 = cnt;
  *i3 = max;

  /* Forms */
  max = -1;
  for(i = 0, cnt = 0; i < _FI_form_list->FIgroup.size; i++) {
    if (_FI_form_list->FIgroup.gadgets[i] != NULL) {
      cnt++;
      max = i;
    }
  }
  *i4 = _FI_form_list->FIgroup.size;
  *i5 = cnt;
  *i6 = cnt;

  return 1;
}




