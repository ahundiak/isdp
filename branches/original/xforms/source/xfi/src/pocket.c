#include "FImin.h"

#include <stdio.h>
#include "MIdef.h"
#include "MIext.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

static struct FIbtn_obj *_MI_last_button;


void _MI_setup_pocket (struct FIform_obj *menu)
{
  int	xpos, ypos;
  int	width;
  int	height;
  int	adjusted_width = FALSE;
  int	adjusted_height = FALSE;
  XSetWindowAttributes win_attr;

	/** X11-6/12/90-Adjust the window so it ***/
	/*** does not produce any Expose events ***/

  if (menu->attr_mask & FI_SAVE_RESTORE)
  {
     menu->attr_mask &= ~FI_SAVE_RESTORE; 
  }

  /* Don't want to make the popup window a Save/Restore window,    */
  /* or it will go into an event handling loop during FIf_display  */
  /* instead of using its own event handling loop.                 */
  /*         GMD 3/10/92                                           */

  win_attr.save_under = True;
  XChangeWindowAttributes ( _FI_display, menu->Xwindow,
	     	            CWSaveUnder, &win_attr );

/*
  if ( ! ( menu->attr_mask & FI_SAVE_RESTORE ) )
    {
      XSetWindowAttributes win_attr;

      win_attr.save_under = True;
      XChangeWindowAttributes ( _FI_display, menu->Xwindow,
				 CWSaveUnder, &win_attr );

      menu->attr_mask |= FI_SAVE_RESTORE;
    }
*/

  menu->attr_mask |= FI_NOT_RESIZABLE | FI_LINE_BORDER;

  xpos = menu->xlo;
  ypos = menu->ylo;

  FIf_get_size ((Form) menu, &width, &height );

  if ( ( xpos + width ) >= ( FI_current_screen_width - 1 ) )
    {
      adjusted_width = TRUE;
    }

  if ( ( ypos + height ) >= ( FI_current_screen_height - 1 ) )
    {
      adjusted_height = TRUE;
    }

  if ( _MI_last_button )
    {
	/*** Move location of pocket menu to be centered ***/
	/*** over last active button.			 ***/

	/* Calculate the button width and height */

      width = _MI_last_button->FIgadget.xhi -
				 _MI_last_button->FIgadget.xlo;

      height = _MI_last_button->FIgadget.yhi -
				 _MI_last_button->FIgadget.ylo;

	/*** Offset the form so that the cursor is	***/
	/*** over the center of the last acitve button. ***/

      if ( ! adjusted_width )
	{
          xpos -= ( _MI_last_button->FIgadget.xlo + ( width / 2 ));
	}

      if ( ! adjusted_height )
	{
          ypos -= ( _MI_last_button->FIgadget.ylo + ( height / 2 ));
	}

      FIf_set_location ((Form) menu, xpos, ypos );
    }
  else
    {
      if ( ! adjusted_width )
	{
	  xpos -= width / 2;
	}

      if ( ! adjusted_height )
	{
	  ypos -= height / 2;
	}

      FIf_set_location ((Form) menu, xpos, ypos );
    }
}


/*** X11-6/18/90-The purpose of this predicate routine is	***/
/*** to remove the events listed, and to only remove expose	***/
/*** events for the FORMS system.				***/

/* ARGSUSED */
static Bool _MI_pocket_predicate (Display  *display,
                                  XEvent   *evt,
                                  char     *arg)
{
  if (	( evt->type == ButtonPress ) || ( evt->type == KeyPress ) ||
	( evt->type == MotionNotify )				   )
    {
      return ( True );
    }

  if ( ( (evt->type == Expose) || (evt->type == ConfigureNotify) )  &&
	     ( _FI_Xwindow_to_index ( evt->xexpose.window ) != -1 )  )
    {
      return ( True );
    }

  return ( False );
}


void _MI_process_pocket (struct FIform_obj *menu)
{
  struct FIbtn_obj *button	= NULL;
  struct FIbtn_obj *old_button	= NULL;
  struct FIbtn_obj *notify_button = NULL;
  XEvent	    event;
  Window	    window = menu->Xwindow, bwindow, root;
  int		    xpos, ypos, root_x, root_y;
  unsigned int	    state;


  XSelectInput ( _FI_display, window, FI_EVENT_MASK | KeyPressMask |
		     PointerMotionMask | PointerMotionHintMask );

  /* Loop until button event */

  while ( 1 )
    {
      char	dummy;
      int	btn_num;

      /* GMD 1/24/92 */
      FI_if_event ( _FI_display, &event, _MI_pocket_predicate, &dummy );

      if ( event.type == ButtonPress )
	{
	  bwindow = event.xbutton.window;
	  xpos = event.xbutton.x;
	  ypos = event.xbutton.y;
	  btn_num = event.xbutton.button;
         

	  if ((bwindow == window) && (btn_num == _FI_select_button)) /* GMD 1/14/92 */
	    {
		/* Send point to pocket */

	      button = NULL;

	      _FI_g_find_gadget ( menu->group, xpos, ypos, 
				(struct FIgadget_obj **) &button );
	      if ( button )
		{
		  _FI_g_set_state ( (struct FIgadget_obj *) button,
							DOWN_STATE );
		  _MI_last_button = button;

			/* Set button to be notified once	*/
			/* the menu is erased.			*/

		  notify_button = button;
		  break;
		}
	      else
	        {
	          if ( old_button )
		    {
		      _FI_g_set_state ((struct FIgadget_obj *)
						 old_button, UP_STATE );
		      old_button = NULL;
		    }
	          break;
	        }
	    }
	  else
	    {
	      if ( old_button )
		{
		  _FI_g_set_state ((struct FIgadget_obj *) old_button,
							 UP_STATE );
		  old_button = NULL;
		}
	      break;
	    }
	}
      else if ( event.type == KeyPress )
	{
	  bwindow = event.xkey.window;
	  xpos = event.xkey.x;
	  ypos = event.xkey.y;
	  button = NULL;

	  _FI_g_find_gadget ( menu->group, xpos, ypos,
			         (struct FIgadget_obj **) &button );

	  if ( button )
	    {
	      _FI_g_set_state ((struct FIgadget_obj *) button,
							 DOWN_STATE );

	      if (  old_button   && ( old_button != button ) )
		{
		  _FI_g_set_state ((struct FIgadget_obj *) old_button,
							 UP_STATE );
		}
	      old_button = button;
	    }
	  else
	    {
	      if ( old_button )
		{
		  _FI_g_set_state ((struct FIgadget_obj *) old_button,
							 UP_STATE );
		  old_button = NULL;
		}
	    }
	}
      else if ( event.type == MotionNotify )
	{
		/** Remove all from queue **/
                /* GMD  1/24/92 */
	  while ( FI_check_mask_event ( _FI_display, ButtonMotionMask,
						 &event ))
	    {
		;
	    }

	  FI_query_pointer ( _FI_display, window, &root, &bwindow,
			 &root_x, &root_y, &xpos, &ypos, &state );

	  button = NULL;

	  _FI_g_find_gadget ( menu->group, xpos, ypos,
		         (struct FIgadget_obj **) &button );

	  if ( button && ( button != _MI_last_button ) )
	    {
	      _FI_g_set_state ((struct FIgadget_obj *) button,
						 DOWN_STATE );

	      if ( _MI_last_button )
		{
		  _FI_g_set_state ((struct FIgadget_obj *)
					 _MI_last_button, UP_STATE );
		}

	      _MI_last_button = button;
	    }
	}
      else /** Expose or ConfigureNotify Event **/
	{
	  FI_process_event ( &event, 0 );

	  if (( event.type == Expose )		&&
	      ( event.xany.window == window )	 )
	    {
	      FI_query_pointer ( _FI_display, window, &root, &bwindow,
			 &root_x, &root_y, &xpos, &ypos, &state );

	      button = NULL;
	      _FI_g_find_gadget ( menu->group, xpos, ypos, 
				(struct FIgadget_obj **) &button );

	      if ( button )
		{
		  _FI_g_set_state ((struct FIgadget_obj *) button,
							DOWN_STATE );
		  old_button = button;
		}
	    }
	}
    } /** END while ( 1 )**/

  XSelectInput ( _FI_display, window, FI_EVENT_MASK );

  FIf_erase ((Form) menu );

	  /* Pop up button that was selected */

  if ( button )
    {
      _FI_g_set_state ((struct FIgadget_obj *) button, UP_STATE );
    }


  /**********************************************************/
  /*** If the pocket menu has a notification routine,	  ***/
  /*** then call if ( for R.D. Holland ). -- JAJ:02/06/91 ***/
  /**********************************************************/

	/* mrm:10/7/91:check notify_button before it is referenced */

  if ( notify_button )
    {
      _FI_g_common ( (struct FIgadget_obj *)notify_button );

	/*** GMD 10/30/90 prevent scroll bars used in field	***/
	/*** gadgets, etc. from calling notification.		***/

      if ( menu->notification_routine &&
           !( notify_button->FIgadget.attr_mask &
					 FI_NO_COMPLETE_NOTIFY ) &&
	    ( notify_button->FIgadget.label > 0 )		  )
	{
	  double value = notify_button->FIgadget.value;

					/*** JAJ:01/20/92 ***/
	  _FI_notification_type = FI_COMPLETION_NOTIFICATION;

	/**********************************************************/
	/*** record the input before doing it, so that if	***/
	/*** the notification routine calls itself, the		***/
	/*** input will be recorded in the proper order		***/
	/*** -- JAJ:06/26/90					***/
	/**********************************************************/

	  if ( _FI_record_notification_routine )
	    {
	      _FI_record_notification_routine ( menu->form_label,
			notify_button->FIgadget.label, value, menu );
	    }

	     /**********************************************/
	     /**** Call the menu's notification routine	****/
	     /**********************************************/

	  menu->notification_routine ( menu->form_label,
			notify_button->FIgadget.label, value, menu );
	}
    }
}


  /**********************************************************/
  /*** Reset the _MI_last_button variable ( a "static" in ***/
  /*** pocket.c )			JAJ:05/14/91	  ***/
  /**********************************************************/

void _MI_reset_mi_last_button (void)
{
  _MI_last_button = NULL;
}
