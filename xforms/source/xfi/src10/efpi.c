#include "FImin.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/**********************************************************/
/*** This returns the screen number of the Xscreen	***/
/*** where the mouse pointer currently resides.		***/
/*** Sent in by Bob Tracy ( tracyre@infonode.ingr.com ) ***/
/************************************ JAJ:02/12/92   ******/

int _FI_get_active_screen (int *xscreen)
{
  int		nscreens;
  Window	root, w1, w2;
  int		rx, ry, wx, wy;
  unsigned	int kb;
  int		ii;

    /* determine which screen the pointer is in */

  nscreens = ScreenCount ( _FI_display );

  for ( ii = 0; ii < nscreens; ii++ )
    {
      root = RootWindow ( _FI_display, ii );

      if ( XQueryPointer ( _FI_display, root, &w1, &w2,
				&rx, &ry, &wx, &wy, &kb) )
	{
	  *xscreen = ii;
	  return ( 0 );
	}
    }

  /* no screen matches up with the pointer? */

  return ( -1 );
}

/* DISPLAY */

int FIf_is_displayed (Form  form,
                      int  *status)
{
  struct FIform_obj * form_ptr = (struct FIform_obj *) form;
  XWindowAttributes attr;

  if ( form_ptr->Xwindow == None )
    {
      *status = FALSE;
    }
  else
    {

      XGetWindowAttributes ( _FI_display, form_ptr->Xwindow, &attr );

      *status = ( (attr.map_state != IsUnmapped) ? TRUE : FALSE );
    }

  return ( FI_SUCCESS );
}



int FIf_set_window_event_routine (Form   form,
                                  int  (*routine) ())
{
  ((struct FIform_obj *) form)->window_event_routine = routine;
  return ( FI_SUCCESS );
}



int FIf_get_window_event_routine (Form   form,
                                  int (**routine) ())
{
  *routine = ((struct FIform_obj *) form)->window_event_routine;
  return ( FI_SUCCESS );
}



int FIf_set_button_intercept_routine (Form   form,
                                      int  (*routine) ())
{
  ((struct FIform_obj *) form)->intercept_routine = routine;

  return ( FI_SUCCESS );
}



int FIf_get_button_intercept_routine (Form    form,
                                      int  (**routine)())
{
  *routine = ((struct FIform_obj *) form)->intercept_routine;

  return ( FI_SUCCESS );
}


/** OBSOLETE **/
int FIf_set_window_icon_routine (Form   form,
                                 int  (*routine)())
{
  ((struct FIform_obj *) form)->window_icon_routine = routine;
  return ( FI_SUCCESS );
}



int FIf_set_initial_notification_routine (Form   form,
                                          int  (*routine)())
{
  ((struct FIform_obj *) form)->initial_notification_routine = routine;
  return ( FI_SUCCESS );
}



int FIf_get_initial_notification_routine (Form    form,
                                          int  (**routine)())
{
  *routine = ((struct FIform_obj *) form)->initial_notification_routine;
  return ( FI_SUCCESS );
}



int FIf_set_button_event_routine (Form   form,
                                  int  (*routine)())
{
  ((struct FIform_obj *) form)->button_event_routine = routine;
  return ( FI_SUCCESS );
}



int FIf_get_button_event_routine (Form    form,
                                  int  (**routine)())
{
  *routine = ((struct FIform_obj *) form)->button_event_routine;
  return ( FI_SUCCESS );
}



int FIf_set_notification_routine (Form   form,
                                  int  (*routine)())
{
  ((struct FIform_obj *) form)->notification_routine = routine;
  return ( FI_SUCCESS );
}



int FIf_get_notification_routine (Form    form,
                                  int  (**routine)())
{
  *routine = ((struct FIform_obj *) form)->notification_routine;
  return ( FI_SUCCESS );
}



/* This function returns the window number of the form */

int FIf_get_window (Form     form,
                    Window  *window)
{
  *window = ((struct FIform_obj *) form)->Xwindow;

  if ( *window == None )
    {
      return ( FI_FORM_NOT_DISPLAYED );
    }
  else
    {
      return ( FI_SUCCESS );
    }
}



int FIf_set_resize_off (Form form_ptr)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  int displayed;

  FIf_is_displayed ( form_ptr, &displayed );

  if ( ( form->Xwindow != None ) && displayed )
    {
      XSizeHints hints;

      hints.min_width = form->xhi - form->xlo;
      hints.min_height = form->yhi - form->ylo;
      hints.max_width = hints.min_width;
      hints.max_height = hints.min_height;
      hints.flags = PMinSize | PMaxSize;
      XSetNormalHints ( _FI_display, form->Xwindow, &hints);
      XSetZoomHints ( _FI_display, form->Xwindow, &hints);
      return ( FI_SUCCESS );
    }
  else
    {
      return ( FI_FORM_NOT_DISPLAYED );
    }
}


int FIf_set_resize_on (Form form_ptr)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  int displayed;

  FIf_is_displayed ( form_ptr, &displayed );

  if ( ( form->Xwindow != None ) && displayed )
    {
      XSizeHints hints;

      hints.flags = PMinSize | PMaxSize;
      hints.min_width = form->min_xsize;
      hints.min_height = form->min_ysize;
      hints.max_width = form->max_xsize;
      hints.max_height = form->max_ysize;
      XSetNormalHints ( _FI_display, form->Xwindow, &hints);
      XSetZoomHints ( _FI_display, form->Xwindow, &hints);

      return ( FI_SUCCESS );
    }
  else
    {
      return ( FI_FORM_NOT_DISPLAYED );
    }
}



/** status 0 if uncollapsed, 1 if anything else **/

int FIf_is_collapsed (Form  form_ptr,
                      int  *status)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  if ( form->Xwindow == None )
    {
      *status = FALSE;
    }
  else
    {
      *status = !(form->attr_mask & FI_WITHDRAWN) && !form->displayed;
    }
  return ( FI_SUCCESS );
}


int FIf_collapse (Form form_ptr)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  if (! ( form->attr_mask & FI_DISPLAY_COLLAPSED ) &&
      ( form->Xwindow != None ) &&  !(form->attr_mask & FI_WITHDRAWN))
  {
	/** <pds-1/11/91> won't work on a withdrawn window */

    /***********************************
 _FI_f_un_collapse ( form, FALSE );
 ***********************************/

    FI_iconify_window ( _FI_display, form->Xwindow, form->Xscreen);
  }
  form->attr_mask |= FI_DISPLAY_COLLAPSED;

  return ( FI_SUCCESS );
}



int FIf_uncollapse (Form form_ptr)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  if ( ( form->attr_mask & FI_DISPLAY_COLLAPSED ) &&
      ( form->Xwindow != None ) && !(form->attr_mask & FI_WITHDRAWN))
  {
    /***********************************
 _FI_f_un_collapse ( form, FALSE );
 ***********************************/

    FI_map_window ( _FI_display, form->Xwindow );
  }
  form->attr_mask &= ~ FI_DISPLAY_COLLAPSED;

  return ( FI_SUCCESS );
}


/* MEMORY */

int FIf_set_orig_location (Form form_ptr,
                           int xlo,
                           int ylo)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  form->orig_xlo = xlo;
  form->orig_ylo = ylo;

  return ( FI_SUCCESS );
}



int FIf_get_orig_location (Form  form_ptr,
                           int  *xlo,
                           int  *ylo)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  *xlo = form->orig_xlo;
  *ylo = form->orig_ylo;

  return ( FI_SUCCESS );
}



int FIf_set_orig_size (Form  form_ptr,
                       int   xsize,
                       int   ysize)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  form->orig_xsize = xsize;
  form->orig_ysize = ysize;

  return ( FI_SUCCESS );
}



int FIf_get_orig_size (Form  form_ptr,
                       int  *xsize,
                       int  *ysize)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  *xsize = form->orig_xsize;
  *ysize = form->orig_ysize;

  return ( FI_SUCCESS );
}



int FIf_set_seq_on (Form form)
{
  ((struct FIform_obj *) form)->seq_off = FALSE;
  return ( FI_SUCCESS );
}


int FIf_set_seq_off (Form form)
{
  ((struct FIform_obj *) form)->seq_off = TRUE;
  return ( FI_SUCCESS );
}


int FIf_get_seq (Form  form,
                 int  *seq_flag)
{
  *seq_flag = ! ((struct FIform_obj *) form)->seq_off;
  return ( FI_SUCCESS );
}


int FIf_find_gadget (Form  form_ptr,
                     int   group_label,
                     int   xpos,
                     int   ypos,
                     int  *label)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  struct FIgadget_obj *search_gadget;
  struct FIgroup_obj *group;

  group = (struct FIgroup_obj *) _FI_g_get_id ( form, group_label );

  if ( ! group )
  {
    return ( FI_NO_SUCH_GROUP );
  }

  if ( _FI_g_find_gadget (group, xpos, ypos, &search_gadget) )
  {
    *label = search_gadget->FIgadget.label;
    return ( FI_SUCCESS );
  }

  return ( FI_NO_SUCH_GADGET );
}


/* This function retrieves the attributes mask of the form */

int FIf_get_attr (Form   form,
                  long  *form_mask)
{
	/** <pds-10/9/91> Turn off private attribute **/

  *form_mask = ((struct FIform_obj *) form)->attr_mask & ~FI_WITHDRAWN;
  return ( FI_SUCCESS );
}


/* This function sets up the form with the appropriate */
/* attributes specified in the form mask */

int FIf_set_attr (Form  form_ptr,
                  int   form_mask)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  if ( ( form->attr_mask & FI_SAVE_RESTORE) &&
      ! (form_mask & FI_SAVE_RESTORE) )
  {
    /*** Convert the form if it was SAVE_RESTORE ***/
    /*** and turning off that attribute ***/

    FIf_cvrt_to_perm_win (form_ptr);
  }

  if ((form_mask & FI_SAVE_RESTORE) &&
      (!(form->attr_mask & FI_SAVE_RESTORE)))
  {
    /* Convert to save_under. Form may have been created dynamically
       and not yet mapped. Should this check whether the form is
       already displayed? The manual page seems to indicate that it
       is probably okay to do this to a mapped window, but it may not
       have any immediate effect. mrm 10/8/91
    */
    XSetWindowAttributes xattr;

    xattr.save_under = TRUE;
    XChangeWindowAttributes(_FI_display, form->Xwindow, CWSaveUnder,
        &xattr);
  }

	/** <pds-10/9/91> Restore private attributes **/

  form->attr_mask = form_mask | (form->attr_mask & FI_WITHDRAWN);

  return ( FI_SUCCESS );
}



/* This function resets all the gadgets on the form */

int FIf_reset (Form form)
{
  _FI_g_reset ((struct FIgadget_obj *)((struct FIform_obj *)form)->group);
  return ( FI_SUCCESS );
}



int FIf_get_user_pointer (Form    form,
                          char  **user_pointer)
{
  *user_pointer = ((struct FIform_obj *) form)->user_pointer;

  return ( FI_SUCCESS );
}


int FIf_set_user_pointer (Form   form,
                          char  *user_pointer)
{
  ((struct FIform_obj *) form)->user_pointer = user_pointer;

  return ( FI_SUCCESS );
}



/* This function returns the xpos and ypos of the form */
/* relative to the virtual screen */

int FIf_get_location (Form  form_ptr,
                      int  *xpos,
                      int  *ypos)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  *xpos = form->xlo;
  *ypos = form->ylo;

  return ( FI_SUCCESS );
}


int FIf_set_collapse_location (Form  form_ptr,
                               int   xpos,
                               int   ypos)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  form->collapse_icon_xpos = xpos;
  form->collapse_icon_ypos = ypos;

  if ( form->Xwindow != None )
  {
    XWMHints *hints;

    if ((hints = XGetWMHints (_FI_display, form->Xwindow)) == NULL)
       hints = XAllocWMHints ();
    hints->flags |= IconPositionHint;
    hints->icon_x = form->collapse_icon_xpos;
    hints->icon_y = form->collapse_icon_ypos;
    XSetWMHints ( _FI_display, form->Xwindow, hints);
    XFree ((caddr_t)hints);
  }
  else
  {
    form->collapse_pos_not_set = TRUE;
  }

  return ( FI_SUCCESS );
}



int FIf_get_collapse_location (Form  form_ptr,
                               int  *xpos,
                               int  *ypos)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  *xpos = form->collapse_icon_xpos;
  *ypos = form->collapse_icon_ypos;

  return ( FI_SUCCESS );
}



int FIf_set_collapse_symbol (Form  form_ptr,
                             char *fontfile,
                             int   symindex)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  _FI_s_rep ( & form->collapse_icon_file, fontfile);

  form->collapse_icon_index = symindex;

  if ( form->Xwindow != None )
  {
    int status;
    int symbol_id;
    int index;

    status = FI_find_symbol_path_and_id ( FI_data,
        form->collapse_icon_file, &symbol_id );

    if ( symbol_id != -1 )
    {
      XWMHints *get_hints;

      /** X11-5/2/90-Remove the referrence to the old pixmap **/

      get_hints = XGetWMHints ( _FI_display, form->Xwindow );

      if ( get_hints != None )
      {
        if ( get_hints->icon_pixmap != None )
        {
          XFreePixmap ( _FI_display, get_hints->icon_pixmap );
        }
      }
      else
         get_hints = XAllocWMHints ();

      /** X11-5/2/90-Create new symbol **/

      index = form->collapse_icon_index;

      if ( _FI_symbols[symbol_id].sym_slot[index].bitmap )
      /* symbol in slot */
      {
        get_hints->icon_pixmap = 
            XCreateBitmapFromData ( _FI_display, form->Xwindow,
            _FI_symbols[symbol_id].sym_slot[index].bitmap,
            _FI_symbols[symbol_id].sym_slot[index].sym_width,
            _FI_symbols[symbol_id].sym_slot[index].sym_height);
      }
      else
      {
        get_hints->icon_pixmap = None;
      }
                       /* Fix TR 249301834 */
	  if (get_hints)   /* sml:09-24-93 add check for get_hints */
	  {
        get_hints->flags |= IconPixmapHint;

        XSetWMHints ( _FI_display, form->Xwindow, get_hints );
        XFree ((caddr_t)get_hints);
	  }
    }
    else
    {
	  /*********************************************/
	  /* sml:01-11-94 Purify error                 */
	  /*  Initialize this structure                */
	  /*********************************************/
      XWMHints *get_hints = (XWMHints *)None;

      /** X11-5/2/90-Remove the referrence to the old pixmap **/

      get_hints = XGetWMHints ( _FI_display, form->Xwindow);

      if ( get_hints != None )
      {
        if ( get_hints->icon_pixmap != None )
        {
          XFreePixmap ( _FI_display, get_hints->icon_pixmap );
        }
        XFree ((caddr_t)get_hints);
      }
      else
         get_hints = XAllocWMHints ();

                       /* Fix TR 249301834 */
	  if (get_hints)   /* sml:09-24-93 add check for get_hints */
	  {
        get_hints->icon_pixmap = None;

        get_hints->flags |= IconPixmapHint;

        XSetWMHints ( _FI_display, form->Xwindow, get_hints );
        XFree ((caddr_t)get_hints);
	  }
      return ( FI_LOAD_FONT_ERROR );
    }
  }
  return ( FI_SUCCESS );
}



int FIf_get_collapse_symbol (Form  form_ptr,
                             char  fontfile[],
                             int  *symindex)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  strcpy (fontfile, form->collapse_icon_file);

  *symindex = form->collapse_icon_index;

  return ( FI_SUCCESS );
}


int FIf_set_min_size (Form form_ptr,
                      int  xsize,
                      int  ysize)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  int displayed;

  form->min_xsize = xsize;
  form->min_ysize = ysize;

  FIf_is_displayed ( form_ptr, &displayed );

  if ( ( form->Xwindow != None ) && displayed )
  {
    XSizeHints hints;

    hints.flags = PMinSize;
    hints.min_width = xsize;
    hints.min_height = ysize;
    XSetNormalHints ( _FI_display, form->Xwindow, &hints );
    XSetZoomHints ( _FI_display, form->Xwindow, &hints );
  }

  return ( FI_SUCCESS );
}



int FIf_get_min_size (Form  form_ptr,
                      int  *min_xsize,
                      int  *min_ysize)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  *min_xsize = form->min_xsize;
  *min_ysize = form->min_ysize;

  return ( FI_SUCCESS );
}



int FIf_set_max_size (Form  form_ptr,
                      int   xsize,
                      int   ysize)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  int displayed;

  form->max_xsize = xsize;
  form->max_ysize = ysize;

  FIf_is_displayed ( form_ptr, &displayed );

  if ( (form->Xwindow != None ) && displayed )
  {
    XSizeHints hints;

    hints.flags = PMaxSize;
    hints.max_width = xsize;
    hints.max_height = ysize;
    XSetNormalHints ( _FI_display, form->Xwindow, &hints );
    XSetZoomHints ( _FI_display, form->Xwindow, &hints );
  }

  return ( FI_SUCCESS );
}



int FIf_get_max_size (Form  form_ptr,
                      int  *max_xsize,
                      int  *max_ysize)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  *max_xsize = form->max_xsize;
  *max_ysize = form->max_ysize;

  return ( FI_SUCCESS );
}



int FIf_set_start_seq (Form  form_ptr,
                       int   gadget_label)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  XEvent event;

  form->seq_label = gadget_label;

  if ( form->Xwindow != None )
  {
    /* X11-4/17/90-Signal forms with a clent message */

    event.xclient.type = ClientMessage;
    event.xclient.window = form->Xwindow;
    event.xclient.message_type = 32;
    event.xclient.format = 32;
    event.xclient.data.l[0] = FI_DATA_OFFSET;
    
    /* GMD 1/24/92 */
    FI_send_event ( _FI_display, form->Xwindow, False, None, &event );
  }

  return ( FI_SUCCESS );
}



int FIf_get_start_seq (Form  form_ptr,
                       int  *gadget_label)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  *gadget_label = form->seq_label;

  return ( FI_SUCCESS );
}


/* This function returns the next available(not in use)*/
/* POSITIVE gadget label for the form. */

int FIf_get_next_label (Form  form_ptr,
                        int  *next_label)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  for (*next_label = form->begin_label;
      _FI_grp_is_label_used_within_group (form->group, *next_label);
      (*next_label) ++)
  {
  }

  form->begin_label = *next_label;

  return ( FI_SUCCESS );
}



/* This function gets the size of the form */

int FIf_get_size (Form form_ptr,
                  int *xsize,
                  int *ysize)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  *xsize = form->xhi - form->xlo;
  *ysize = form->yhi - form->ylo;

  return ( FI_SUCCESS );
}



int FIf_get_screen (Form  form,
                    int  *screen)
{
  *screen = ((struct FIform_obj *) form)->Xscreen;

  return ( FI_SUCCESS );
}



int FIf_get_name (Form form,
                  char name[])
{
  strcpy ( name, ((struct FIform_obj *) form)->name );

  return ( FI_SUCCESS );
}



int FIf_get_label (Form  form,
                   int  *form_label)
{
  *form_label = ((struct FIform_obj *) form)->form_label;

  return ( FI_SUCCESS );
}



int FIf_set_label (Form  form,
                   int   form_label)
{
  ((struct FIform_obj *) form)->form_label = form_label;

  return ( FI_SUCCESS );
}



int FIf_set_scaling_on (Form form)
{
  ((struct FIform_obj *) form)->attr_mask &= ~ FI_NOT_SCALABLE;
  return ( FI_SUCCESS );
}



int FIf_set_scaling_off (Form form)
{
  ((struct FIform_obj *) form)->attr_mask |= FI_NOT_SCALABLE;
  return ( FI_SUCCESS );
}



int FIf_get_scaling (Form  form,
                     int  *scaling_flag)
{
  *scaling_flag = ! (((struct FIform_obj *) form)->attr_mask &
      FI_NOT_SCALABLE );

  return ( FI_SUCCESS );
}


/** OBSOLETE **/
int FIf_set_window_level (Form  form_ptr,
                          int   level)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;

  if ( form->Xwindow == None )
  {
    form->level = level;
    return ( FI_SUCCESS );
  }
  else
  {
    return ( FI_FORM_DISPLAYED );
  }
}


/* ARGSUSED */
int FIf_set_screen (Form  form_ptr,
                    int   screen)
{
  /* dmb:04/17/92:FIf_set_Xscreen replaces this function */
  /* dmb:04/17/92:Removed obsolete code to work around mkptypes bug */
  return ( FI_SUCCESS );
}



/*** JAJ:02/12/92 ***/
int FIf_set_Xscreen (Form   form,
                     int    logical_screen,
                     int    absolute_screen)
{
  struct FIform_obj	* form_ptr = (struct FIform_obj *) form;
  int			  form_displayed;
  int			  sts, new_xscreen;
  double                  x_scale_factor, y_scale_factor;

  FIf_is_displayed ( form, & form_displayed );

  if ( form_displayed )
    {
      return ( FI_FORM_DISPLAYED );
    }
  else
    {
      form_ptr->screen = logical_screen;

      if (logical_screen == FI_CURRENT_SCRN)
	{
	    sts = _FI_get_active_screen ( & new_xscreen );
	    if ( sts )
	      {
		new_xscreen = DefaultScreen ( _FI_display );
	      }
	}
      else if (logical_screen == FI_DEFAULT_SCRN)
	    new_xscreen = DefaultScreen ( _FI_display );
      else if (logical_screen == FI_HARDCODED_SCRN)
      {
	    if ( absolute_screen >= 0
			/* && ( absolute_screen <=7 ) */	 )
	      {
	        new_xscreen = absolute_screen;
	      }
	    else
	      {
	        return ( FI_ILLEGAL_VALUES );
	      }
      }
      else
	  return ( FI_ILLEGAL_VALUES );

      if ( new_xscreen == form_ptr->Xscreen )
	{
		/*** Don't need to do anything else ***/
	  return ( FI_SUCCESS );
	}

      form_ptr->Xscreen = new_xscreen;

      if ( form_ptr->Xwindow != None )
	{
	  Window	window_arg;
          XEvent	evt;
	  int		window_index;

	/*** X11-6/22/90-This removes it from the form list,	***/
	/***  so in the event code it will never find the form	***/
	/***  and can't call this routine a second time. If	***/
	/***  another client destroys the window, then this	***/
	/***  code will be called to clean up.			***/

	  window_index = _FI_Xwindow_to_index ( form_ptr->Xwindow );

	  if ( window_index >= 0 )
	    {
	      FI_forms [ window_index ] = 0;
	    }

	  XDestroyWindow ( _FI_display, form_ptr->Xwindow );
          window_arg = form_ptr->Xwindow;

	  form_ptr->Xwindow = None;

	  XSync ( _FI_display, False );

		/*** Remove this destroy event or else this	***/
		/*** form will have it's new window ptr		***/
		/*** zero'ed out later on -- JAJ:02/18/92	***/
		/*** use FI_check_if_event sml:11-17-93     ***/
	  while ( ! FI_check_if_event ( _FI_display, &evt,
			 (Bool (*)())_FI_flush_destroy, ( char *) &window_arg )  )
	    {
		/** Wait **/
	    };
	}

      if ( form_ptr->Xgc )
	{
	  XFreeGC ( _FI_display, form_ptr->Xgc );
	}

      if ( form_ptr->Xgc_text )	/*** JAJ:02/14/92 ***/
	{
	  XFreeGC ( _FI_display, form_ptr->Xgc_text );
	}

      sts = _FI_make_Xwindow ( form_ptr );

      if ( sts != FI_SUCCESS )
	{
	  return ( sts );
	}

	/*************************************************************/
	/* sml:10-01-93 Fix TR 249301977                             */
	/*   Fix problem with divide by zero if message              */
	/*   box is displayed on screen other than primary X screen. */
	/*   Check if orig_x/ysize exist to avoid divide by zero.    */
	/*   Also check if form has width or height while I'm here.  */
	/*************************************************************/

	if (form_ptr->orig_xsize != 0 && form_ptr->orig_xsize != 0 &&
		form_ptr->xhi != form_ptr->xlo && form_ptr->yhi != form_ptr->ylo)
	{
      x_scale_factor = (form_ptr->xhi - form_ptr->xlo) / form_ptr->orig_xsize;
      y_scale_factor = (form_ptr->yhi - form_ptr->ylo) / form_ptr->orig_ysize;
      
      if ((x_scale_factor < 0.95)  ||
          (x_scale_factor > 1.05)  ||
          (y_scale_factor < 0.95)  ||
          (y_scale_factor > 1.05))
      {
         FIg_activate (form, 0);   /* By re-activating all gadgets on   */
                                   /* the form, you will insure that    */
                                   /* any scaled forms will delete      */
                                   /* their current scaled symbols      */
                                   /* and recreate new scaled symbols   */
                                   /* which are located on the new      */
                                   /* screen.    GMD 3/11/92            */
      } /* if scale factors not close to 1 */
	} /* else form has height and width and orig sizes != 0 */
  }
  
  return ( FI_SUCCESS );
}  /*** int FIf_set_Xscreen  ***/


/*** JAJ:02/12/92 ***/
int FIf_get_Xscreen (Form   form,
                     int   *logical_screen,
                     int   *absolute_screen)
{
  struct FIform_obj	* form_ptr = (struct FIform_obj *) form;
  
  * logical_screen	= form_ptr->screen;
  * absolute_screen	= form_ptr->Xscreen;

  return ( FI_SUCCESS );

}  /*** int FIf_get_Xscreen  ***/

/* This function returns the background color of the form */

int FIf_get_color (Form  form,
                   int  *color)
{
  *color = ((struct FIform_obj *) form)->bgcolor;

  return ( FI_SUCCESS );
}


/* This function sets the background color of the form */

int FIf_set_color (Form  form,
                   int   color)
{
  ((struct FIform_obj *) form)->bgcolor = color;

  return ( FI_SUCCESS );
}
