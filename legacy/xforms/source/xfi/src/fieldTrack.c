#include "FImin.h"

#include <stdio.h>

#include "FIappl.h"
#include "FEI.h"
#include "FIseq.h"
#include "FIscroll.h"
#include "FIbtn.h"
#include "FImcf.h"
#include "FIfield.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


extern int _FI_fld_new_event;
extern int _FI_fld_new_event_value;
extern Form _FI_fld_new_form;
extern int _FI_fld_new_gadget;
extern int _FI_fld_new_xpos;
extern int _FI_fld_new_ypos;
extern int _FI_fld_new_event_status;

/***********************************************************/
/*  Function _FI_initialize_fld_new_values                 */
/*    This function initializes static variables used to   */
/*    compute what event/gadget caused a field to be       */
/*    notified.                                            */
/*  sml:11-01-93  created                                  */
/***********************************************************/

void _FI_initialize_fld_new_values()
{
      _FI_fld_new_event = -1;
      _FI_fld_new_event_value = -1;
	  _FI_fld_new_form = 0;
      _FI_fld_new_gadget = -1;
      _FI_fld_new_xpos = -1;
      _FI_fld_new_ypos = -1;
      _FI_fld_new_event_status = -1;
}






/*********************************************************************/
/***  _FI_fld_track_mouse:   changed from "void" to "int"          ***/
/***  Returns:  FI_SUCCESS                          JAJ:08/31/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_track_mouse (struct FIfld_obj  *field,
                         Window             window,
                         int                xpos,
                         int                ypos,
                         int               *complete,
                         double            *value)
{
  int status = FI_SUCCESS;

	  /******************************************/
	  /* sml:11-01-93   Set values for          */
 	  /*  determining what caused field notify  */
      /******************************************/

  _FI_fld_new_event = ButtonPress;
  _FI_fld_new_form = (Form) (FI_forms[_FI_Xwindow_to_index (window)]);
  _FI_fld_new_event_value = _FI_select_button;
  _FI_fld_new_xpos = xpos;
  _FI_fld_new_ypos = ypos;

  if ( field->FIfield.list_id					  &&
       field->FIfield.flags.popup_list				  &&
	( xpos >= field->FIgadget.xhi - ROLL_THROUGH_SYM_WIDTH )   )
    {
      field->FIfield.list_id->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;

      _FI_fld_display ( field->FIfield.list_id, window );

      _FI_list_up = TRUE;
    }

  if (	field->FIfield.mode == FI_SINGLE_SELECT		 ||
	field->FIfield.mode == FI_MULTI_SELECT		  )
    {
	/*** For single-select and multi-select columns of a MCF  ***/
	/*** to receive notifications.				  ***/

      if ( field->FIfield.flags.is_a_col )
	{
	  _FI_poke_inside_mcf = 0;
	}

      status = _FI_fld_toggle_select_flag ( field, window,
					xpos, ypos, complete, value );
      if ( status != FI_SUCCESS )
	{
	  goto quit;
	}

      if ( field->FIfield.flags.is_a_col			   &&
	  ! ( field->FIgadget.attr_mask & FI_NO_COMPLETE_NOTIFY )   )
	{
          XFlush ( _FI_display );

	  status = _FI_fld_notify ( field, *value );

	  if ( status != FI_SUCCESS )
	    {
	      goto quit;
	    }
	}
    }
  else
    {
      if ( field->FIfield.mode != FI_REVIEW )
	{
	  _FI_fld_adjust_row_col ( field, xpos, ypos );
	}

		/***********************/
		/* loop for more input */
		/***********************/

      XSelectInput ( _FI_display, window, FI_EVENT_MASK |
		FocusChangeMask | EnterWindowMask | LeaveWindowMask );

      status = _FI_fld_track_kbd ( field, FI_FORWARD, 0 );

      if ( status != FI_SUCCESS )
	{
	  goto quit;
	}
      /*************************************************************/
      /* sml:03-02-94 TR 249400372 Getting expose for deleted win. */
      /*   Do this after status check instead of before            */
      /*************************************************************/
      XSelectInput ( _FI_display, window, FI_EVENT_MASK );

    }

	/****************************************/
	/* Take down the assoc list if it is up */
	/****************************************/

  if ( _FI_list_up	&&	! field->FIfield.flags.is_a_list )
    {
      _FI_fld_process_displayed_list ( field->FIfield.list_id );
    }

  if (    field->FIfield.flags.is_a_col			&&
	( field->FIfield.mode == FI_INSERT	||
	  field->FIfield.mode == FI_APPEND 	 )	 )
    {
      *complete = TRUE;
    }
  else
    {
      *complete = FALSE;
    }

quit:
  return ( status );
}


/*********************************************************************/
/***  _FI_fld_track_kbd:    changed from "void" to "int"           ***/
/***  Returns:  FI_SUCCESS                          JAJ:08/31/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_track_kbd (struct FIfld_obj  *field,
                       int                direction,
                       int                prev_gadget_label)
{
  Window	window = XWINDOW ( field );
  int		complete, status, next_in_seq, xx;
  int		prev_in_seq = 0;
  int		delete_status;
  int		current_label = (int) field->FIgadget.label;
  double	value;
  Form		form = (Form) field->FIgadget.form;
  struct FImcf_obj *mcfield;


  if ( field->FIfield.flags.is_a_col )
    {
      mcfield = (struct FImcf_obj *) field->FIgadget.group;
    }
  else
    {
      mcfield = NULL;
    }

  if ( field->FIfield.mode != FI_REVIEW )
    {
      if ( field->FIgadget.next_in_seq > 0 || prev_gadget_label > 0 )
	{
	  _FI_g_hilite ( (struct FIgadget_obj *)field );
	}
      else if ( mcfield )
	{
		/*** <pds-1/9/90> This had to be added so that	***/
		/*** the MCF would hilite on initial poke,	***/
		/*** if it was sequenced.			***/

	  if ( mcfield->FIgadget.next_in_seq > 0 )
	    {
	      _FI_g_hilite ( (struct FIgadget_obj *)mcfield );
	    }
	}

      if ( direction == FI_FORWARD )
	{
	  field->FIgadget.prev_in_seq = prev_gadget_label;
	}

      prev_in_seq = field->FIgadget.prev_in_seq;
    }

	/**************************/
	/* Track the keyboard now */
	/**************************/

  if (	field->FIfield.mode == FI_INSERT	||
	field->FIfield.mode == FI_APPEND	 )
    {
		/*************************/
		/* create line if needed */
		/*************************/

      if ( field->FIfield.buffer_size == 0 )
	{
	  _FI_fld_set_buffer ( field, 1, 1 );

	  if ( field->FIfield.flags.is_a_col == 0 )
	    {
	      _FI_fld_add_to_line ( (struct FIfld_obj *)field, 0, 1 );
	    }
	  else
	    {
	      for ( xx = 0; xx < (int)mcfield->FImcf.ncol; xx++ )
		{
		  _FI_fld_add_to_line ( (struct FIfld_obj *)mcfield->FIgroup.gadgets[xx],
								0, 1 );
		}
	    }
	}

	/*** <pds-1/11/90> If the there is a MCF, then use	***/
	/*** a different track keyboard routine.  This has to	***/
	/*** set up the sequencing to the other rows, and then	***/
	/*** call _FI_fld_track_keyboard ().			***/

      if ( mcfield )
	{
	  _FI_mcf_Reason_for_notify = 1;	/** Not a CR **/
	  _FI_poke_inside_mcf = 0;

	  complete = 1;		/* Force input loop to be entered */
				/* GMD 10/30/90 */

	  _FI_mcf_track_keyboard ( mcfield, window, &complete, &value,
						&delete_status );

	  if ( delete_status != FI_SUCCESS )
	    {
	      return ( delete_status );
	    }

	  status = 0; /*** already handled sequencing, turn it off ***/
	}
      else	/*** Do old-stuff if field ***/
	{
	  status = _FI_fld_track_keyboard ( field, window, &complete,
					&value, &delete_status );

	  if ( delete_status != FI_SUCCESS )
	    {
	      return ( delete_status );
	    }

		/*** X11-5/22/90 - When erasing the cursor,	***/
		/*** the focus does not matter.			***/

	  _FI_fld_draw_cursor ( field, window, 1, FI_MED_GREY,
		_FI_fld_get_line_ON_COLOR ( field, field->FIfield.ar ));

		/******************************************************/
		/***  Map 2 fix  -   GMD ( Angela Raby ? ) 7/12/91  ***/
		/***  Make contents of field line snap back to	    ***/
		/***  left hand side.				    ***/
		/******************************************************/

	  if (    field->FIfield.flags.lrs  		&&
                ( field->FIfield.nvr == 1  )		&&
              ! ( field->FIfield.flags.is_a_col )	&&
                ( field->FIfield.coff > 0 )		 )
	    {
              field->FIfield.ac -= field->FIfield.coff;
              field->FIfield.coff = 0;

              _FI_fld_refresh_row ( field, window, field->FIfield.ar );
	    }
		/***--------  Map 2 fix (end )	--------***/

	  if ( field->FIfield.flags.required == 1 )
	    {
	      _FI_fld_refresh_row ( field, window, field->FIfield.ar );
	    }

	  XFlush ( _FI_display );
	}
    }
				/***** Single or Multi Select *****/
  else if ( field->FIfield.mode != FI_REVIEW )
    {
      status = _FI_fld_track_keyboard2 ( field, window, &complete,
					&value, &delete_status );

      if ( delete_status != FI_SUCCESS )
	{
	  return ( delete_status );
	}
    }
  else	/*** FI_REVIEW, previously only had "status = 1;" ***/
    {
      if ( field->FIfield.flags.popup_list		&&
	   IT_IS_DISPLAYED ( field->FIfield.list_id )	 )
	{
	  status = _FI_fld_track_keyboard ( field, window, &complete,
					&value, &delete_status );

	  if ( delete_status != FI_SUCCESS )
	    {
	      return ( delete_status );
	    }
	}
      else
	{
		 status = 1;
	}
    }

  /**************************************************************/
  /* Note: Don't do the rest of this stuff if it is REVIEW mode */
  /**************************************************************/

  if ( field->FIfield.mode != FI_REVIEW )
    {
      if (	field->FIgadget.next_in_seq > 0		||
		prev_gadget_label > 0			 )
	{
	  _FI_g_unhilite ( (struct FIgadget_obj *)field );
	}
      else if ( mcfield && (! complete || status ))
	{
	    /*** <pds-1/9/90> Added same condition to unhilite MCF. ***/
	    /*** 'status' means that it will be sequenced!          ***/

	  if (	mcfield->FIgadget.next_in_seq > 0	||
		prev_gadget_label > 0			 )
	    {
	      _FI_g_unhilite ( (struct FIgadget_obj *)mcfield );
	    }
	}

		/*******************/
		/* verify the data */
		/*******************/

      _FI_fld_verify_data ( field );
      _FI_fld_justify_data ( field );

		/******************************/
		/* Notify application of data */
		/******************************/

      if ( ! ( field->FIgadget.attr_mask & FI_NO_COMPLETE_NOTIFY ) )
	{
	  delete_status = _FI_fld_call_notify ( field, &complete,
					(double) field->FIfield.ar );

	  if ( delete_status != FI_SUCCESS )
	    {
	      return ( delete_status );
	    }
	}

     /***********************************************************/
     /* If sequencing is the cause of the notification, then    */
     /* make sure the the associated list is taken down before  */
     /* proceeding.						*/
     /***********************************************************/


	/*** Take down the assoc list if it is up ***/


      if ( _FI_list_up  &&  field->FIfield.list_id  && ( status != 0 ) )
	{
	  _FI_fld_process_displayed_list ( field->FIfield.list_id );
	}

      next_in_seq = field->FIgadget.next_in_seq;

		/**************************************************/
		/*** Based on the keyboard mapping, go to	***/
		/*** either next or prev in sequence.		***/
		/**************************************************/

      if ( ( status > 0 )  &&  ( next_in_seq > 0 ) )
	{
	  struct FIgadget_obj *gadget = _FI_g_get_id ( 
               (struct FIform_obj *)form, next_in_seq );
	  if ( ! gadget )
	    {
	      return ( FI_SUCCESS );
	    }

	  if (  gadget->FIgadget.form->initial_notification_routine  &&
	      ( gadget->FIgadget.attr_mask & FI_INITIAL_NOTIFY )      )
	    {
	      int		 save_gadget_label;
	      struct FIform_obj *save_form;

	      save_gadget_label = gadget->FIgadget.label;
	      save_form = gadget->FIgadget.form;

					/*** JAJ:01/20/92 ***/
	      _FI_notification_type = FI_INITIAL_NOTIFICATION;

	      gadget->FIgadget.form->initial_notification_routine (
				      gadget->FIgadget.form->form_label,
				      gadget->FIgadget.label,
				      gadget->FIgadget.value,
				      gadget->FIgadget.form );

	      delete_status = FIg_is_valid ( (Form)save_form,
						save_gadget_label );

	      if ( delete_status != FI_SUCCESS )
		{
		  return ( delete_status );
		}
	    }

	  delete_status = _FI_g_track_kbd ( gadget, FI_FORWARD,
							current_label );
	  if ( delete_status != FI_SUCCESS )
	    {
	      return ( delete_status );
	    }
	}
      else if (  ( status < 0 )  &&  ( prev_in_seq > 0 )  )
	{
	  struct FIgadget_obj *gadget = _FI_g_get_id (
               (struct FIform_obj *) form, prev_in_seq );
	  if ( ! gadget )
	    {
	      return ( FI_SUCCESS );
	    }

	  if (  gadget->FIgadget.form->initial_notification_routine  &&
	      ( gadget->FIgadget.attr_mask & FI_INITIAL_NOTIFY )      )
	    {
	      int save_gadget_label;
	      struct FIform_obj *save_form;

	      save_gadget_label = gadget->FIgadget.label;
	      save_form = gadget->FIgadget.form;

					/*** JAJ:01/20/92 ***/
	      _FI_notification_type = FI_INITIAL_NOTIFICATION;

	      gadget->FIgadget.form->initial_notification_routine (
				      gadget->FIgadget.form->form_label,
				      gadget->FIgadget.label,
				      gadget->FIgadget.value,
				      gadget->FIgadget.form );

		/**************************************************/
		/*** make sure form and/or gadget were not      ***/
		/*** deleted by the form's notification routine ***/
		/***************************** -- JAJ:08/30/90 ****/

	      delete_status = FIg_is_valid ( (Form)save_form,
						save_gadget_label );

	      if ( delete_status != FI_SUCCESS )
		{
		  return ( delete_status );
		}
	    }

	  delete_status = _FI_g_track_kbd ( gadget, FI_BACKWARD,
						current_label );

	  if ( delete_status != FI_SUCCESS )
	    {
	      return ( delete_status );
	    }
	}
    }
  return ( FI_SUCCESS );
}


/*********************************************************************/
/***  _FI_fld_track_keyboard:   added "delete_status" argument     ***/
/***  delete_status =  FI_SUCCESS                   JAJ:08/31/90   ***/
/***          = FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***          = FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_track_keyboard (struct FIfld_obj  *field,
                            Window             window,
                            int               *complete,
                            double            *value,
                            int               *delete_status)
{
  XEvent	event;
  Window	focus_win, root, child;
  int       revert_to;
  int		my_event;
  int		ii, count, xpos, ypos, button, status, root_x, root_y;
  int		temp_ac = 0, temp_coff = 0;
  int		has_focus = 0;
  unsigned int	keys_buttons_mask;
  unsigned char data[256];
  struct FIform_obj *fp = field->FIgadget.form;


  XGetInputFocus ( _FI_display, &focus_win, &revert_to );

  if ( focus_win == PointerRoot )
    {
      XQueryPointer ( _FI_display, window, &root, &child,
		&root_x, &root_y, &xpos, &ypos, &keys_buttons_mask );

      has_focus = POINT_IN_RECT ( root_x, root_y, fp->xlo, fp->ylo,
				fp->xhi, fp->yhi );
    }
  else if ( focus_win == None )
    {
      XSetInputFocus ( _FI_display, window, RevertToParent,
							CurrentTime );
      has_focus = True;
    }
  else
    {
	/************************************************/
	/** Decide whether the window has focus or not **/
	/************************************************/

      has_focus = ( focus_win == window );
    }

  *delete_status = FI_SUCCESS;

  if ( field->FIfield.mode != FI_REVIEW )
    {
      if (  field->FIfield.flags.clear				&&
	  ( field->FIfield.buffer[field->FIfield.ar].line )	 )
	{
	  field->FIfield.buffer[field->FIfield.ar].line[0] = '\0';

	  field->FIfield.ac = 0;
	  field->FIfield.coff = 0;
	  _FI_fld_refresh_row ( field, window, field->FIfield.ar );

	  XFlush ( _FI_display );
	}

      _FI_fld_draw_cursor ( field, window, has_focus,
		_FI_fld_get_line_ON_COLOR ( field, field->FIfield.ar ),
		FI_MED_GREY );

      XFlush ( _FI_display );
    }

  my_event = TRUE;

  while ( my_event )
    {
      /* replaces XNextEvent   GMD 10/23/91 */
      FI_next_event ( _FI_display, &event );

      if ( event.xany.window == window )
	{
	  switch ( event.type )
	    {
	      case KeyPress:

		if ( ( field->FIfield.mode == FI_REVIEW )	      ||
/******************/
/* I/Forms didn't */
/* have this ===> */ ( field->FIfield.flags.popup_list && _FI_list_up) )
/* condition here */
/******************/

		  {
		    FI_get_keyboard_data ( (char *)data, &count,
					field->FIgadget.font_type );
		  }
		else
		  {
	  /******************************************/
	  /* sml:11-01-93   Set values for          */
 	  /*  determining what caused field notify  */
      /******************************************/

		  _FI_fld_new_event = KeyPress;
		  _FI_fld_new_form = (Form)(field->FIgadget.form);
		  _FI_fld_new_xpos = -1;
		  _FI_fld_new_ypos = -1;
	
		    if ( ! field->FIfield.flags.no_echo )
		      {
				/**********************/
				/** Erase the cursor **/
				/**********************/

			_FI_fld_draw_cursor ( field, window, has_focus,
						FI_MED_GREY,
				_FI_fld_get_line_ON_COLOR ( field,
						field->FIfield.ar )  );
		      }

		    /**************************************************
		    if ( field->FIfield.flags.required == 1 )
		      {
			_FI_fld_refresh_row ( field, window,
						field->FIfield.ar );
		      }
		    **************************************************/

		    ii = 0;

			/** X11-4/25/90-Each keypress is one event **/
		    count = 1;

		    status = FI_map_character ( &event.xkey, (char *) data );

		  
		  /***************************************/
		  /*  set data for FIfld_get_notify_info */
		  /***************************************/

		  _FI_fld_new_event_value = data[ii];

		    if ( ( status == 0 )		 ||
			 ( data[0] != FI_IGNORE_CHAR )    )
		      {
		        FI_get_keyboard_data ( (char *)data, &count,
					field->FIgadget.font_type );
		      }

		    if ( status  && ( count == 1 ) )
		      {
			/*********************************/
			/* character has special meaning */
			/*********************************/

		    count = 0;

		    switch ( data[ii] )
		      {
			case FI_IGNORE_CHAR:

			  break;


			case FI_UP:

			  if (( ! field->FIfield.flags.no_echo ) &&
                              (FI_push_mode_flag == 0))
			    {
			      _FI_fld_verify_data ( field );
			      _FI_fld_justify_data ( field );

			      *delete_status =
					_FI_fld_previous ( field, 1 );

			      if ( *delete_status != FI_SUCCESS )
				{
				  return ( 0 );
				}
			    }
			  break;


			case FI_DOWN:

			  if (( ! field->FIfield.flags.no_echo ) &&
                              ( FI_push_mode_flag == 0))
			    {
			      _FI_fld_verify_data ( field );
			      _FI_fld_justify_data ( field );

			      *delete_status = _FI_fld_next( field, 1 );

			      if ( *delete_status != FI_SUCCESS )
				{
				  return ( 0 );
				}
			    }
			  break;


			case FI_LEFT:

			  if (( ! field->FIfield.flags.no_echo ) &&
                              (FI_push_mode_flag == 0))
			    {
			      if ( field->FIfield.flags.right_to_left )
				{
				  *delete_status =
					  _FI_fld_forward ( field, 1 );
				}
			      else
				{
				  *delete_status =
					  _FI_fld_back ( field, 1 );
				}

				/*** if the gadget/form was ***/
				/*** deleted, then return   ***/
			      if ( *delete_status != FI_SUCCESS )
				{
				  return ( 0 );
				}
			    }
			  break;


			case FI_RIGHT:

			  if (( ! field->FIfield.flags.no_echo ) &&
                              (FI_push_mode_flag == 0))
			    {
			      if ( field->FIfield.flags.right_to_left )
				{
				  *delete_status =
					      _FI_fld_back ( field, 1 );
				}
			      else
				{
				  *delete_status =
					  _FI_fld_forward ( field, 1 );
				}

				/*** if the gadget/form was ***/
				/*** deleted, then return   ***/
			      if ( *delete_status != FI_SUCCESS )
				{
				  return ( 0 );
				}
			    }
			  break;


			case FI_BOL:

			  if ( ! field->FIfield.flags.no_echo )
			    {
			      _FI_fld_bol ( field );
			    }
			  break;


			case FI_EOL:

			  if ( ! field->FIfield.flags.no_echo )
			    {
			      *delete_status = _FI_fld_eol ( field );
			      if ( *delete_status != FI_SUCCESS )
				{
				  return ( 0 );
				}
			    }
			  break;


			case FI_DEL:

			  if ( ! field->FIfield.flags.no_echo )
			    {
			      _FI_fld_delete_char ( field );
			    }
			  break;


			case FI_BS_DEL:

			  if ( ! field->FIfield.flags.no_echo )
			    {
			      *delete_status = _FI_fld_back_space ( field );

				/*** if the gadget/form was ***/
				/*** deleted, then return   ***/
			      if ( *delete_status != FI_SUCCESS )
				{
				  return ( 0 );
				}
			    }
			  else if ( field->FIfield.ac )
			    {
			      int index;

				/*** <pds-12/13/89> This is ***/
				/*** needed for 16-bit text.***/

			      index = FI_move_index (
					    (char *) field->FIfield.buffer[
						field->FIfield.ar].line,
					    0, field->FIfield.ac - 1,
					    field->FIgadget.font_type );

			      field->FIfield.buffer[field->FIfield.ar].
						      line[index]= '\0';

			      field->FIfield.ac--;
			    }
			  break;


			case FI_KILL_LINE:

			  if ( ! field->FIfield.flags.no_echo )
			    {
			      _FI_fld_delete_line ( field );
			    }
			  break;


			case FI_RESTORE:

			  if ( ! field->FIfield.flags.no_echo )
			    {
			      *delete_status =
					_FI_fld_undelete ( field );

				/*** if the gadget/form was ***/
				/*** deleted, then return   ***/
			      if ( *delete_status != FI_SUCCESS )
				{
				  return ( 0 );
				}
			    }
			  break;


			case FI_LOWER_CASE:
			case FI_UPPER_CASE:

			  if ( ! field->FIfield.flags.no_echo )
			    {
			      *delete_status = _FI_fld_change_case (
					field,
					  ( data[ii] == FI_UPPER_CASE )
							    ? 1 : 0 );

				/*** if the gadget/form was ***/
				/*** deleted, then return   ***/
			      if ( *delete_status != FI_SUCCESS )
				{
				  return ( 0 );
				}
			    }
			  break;


			case FI_TRANSPOSE:

			  if ( ! field->FIfield.flags.no_echo )
			    {
			      *delete_status =
					_FI_fld_transpose ( field );

				/*** if the gadget/form was ***/
				/*** deleted, then return   ***/
			      if ( *delete_status != FI_SUCCESS )
				{
				  return ( 0 );
				}
			    }
			  break;


			case FI_NEXT_IN_SEQ:
                          if (FI_push_mode_flag)     /* GMD 3/23/92 */
                             FI_push_mode_flag = 0;
			  return ( 1 );
			  /** break;    ACC gives warning **/


			case FI_PREV_IN_SEQ:
                          if (FI_push_mode_flag)     /* GMD 3/23/92 */
                             FI_push_mode_flag = 0;
			  return ( -1 );
			  /** break;    ACC gives warning **/

                         /* GMD 2/14/92     Added push mode to fields */

                          case FI_TOG_PUSH_MODE:
                            if (FI_push_mode_flag == 0)
                            {
                               FI_push_mode_flag = 1;
                               FI_push_mode_ac = field->FIfield.ac;
                               FI_push_mode_count = 0;
                            }
                            else
                            {
                               FI_push_mode_flag = 0;
                               field->FIfield.ac =
                                   FI_push_mode_ac + FI_push_mode_count;
                               if (field->FIfield.ac > (field->FIfield.coff +
                                                        field->FIfield.nvc - 1))
                               {
                                  field->FIfield.coff += 
                                       (field->FIfield.ac -
                                        (field->FIfield.coff +
                                         field->FIfield.nvc - 1));
                                  _FI_fld_refresh_row (field, window,
                                                       field->FIfield.ar );    
                               }
                            }
                            break;

			default:
			  break;
		      }

		    ii ++;
		  }
				  
		while ( ii < count )
		  {
		    if ( data[ii] == CR )
		      {
			ii++;

			status = _FI_fld_add_CR ( field, delete_status);

			if ( *delete_status != FI_SUCCESS )
			  {
			    return ( 0 );
			  }

			if ( status )
			  {
			    if ( field->FIfield.flags.is_a_col )
			      {
				*complete = TRUE;
			      }
			    else
			      {
				*complete = FALSE;
			      }

			    if ( field->FIfield.flags.no_echo )
			      {
				_FI_fld_draw_cursor ( field, window,
					has_focus,
					_FI_fld_get_line_ON_COLOR (
						field,
						field->FIfield.ar ),
					FI_MED_GREY );
			      }

			    my_event = FALSE;

			    XFlush ( _FI_display );

							/* FI_CR_HIT */
			    _FI_mcf_Reason_for_notify = 0;

			    return ( 2 );
			  }
		      }
		    else
		      {
			*delete_status = _FI_fld_add_char ( field,
						      &data[ii], &ii );

			if ( *delete_status != FI_SUCCESS )
			  {
			    return ( 0 );
			  }
		      }
		  }	/** End of while ( ii < count )**/

		/*** <pds-2/23/90> Don't redraw the cursor	***/
		/*** if FIfld_erase_cursor( ) was called.	***/

		if ( field->FIfield.flags.no_echo )
		  {
		    temp_ac = field->FIfield.ac;
		    field->FIfield.ac = 0;
		  }

		if ( ( field->FIfield.mode != FI_REVIEW )	&&
			! _FI_mcf_break_navigation		 )
		  {
		    _FI_fld_draw_cursor ( field, window, has_focus,
				_FI_fld_get_line_ON_COLOR ( field,
						field->FIfield.ar ),
				FI_MED_GREY );
		  }

		XFlush ( _FI_display );

		if ( field->FIfield.flags.no_echo )
		  {
		    field->FIfield.ac = temp_ac;
		  }
	      }
	    break;	/*** case ( event.type == KeyPress ) ***/


	  case ButtonPress:
	    {
	      struct FIgadget_obj *gadget_id;
	      struct FImcf_obj	  *mcfield;
	      struct FIgadget_obj *mcf_gadget;
              int skip_last_test;

	  /******************************************/
	  /* sml:11-01-93   Set values for          */
 	  /*  determining what caused field notify  */
      /******************************************/

	  _FI_fld_new_event = ButtonPress;
	  _FI_fld_new_form = (Form) (FI_forms[_FI_Xwindow_to_index (window)]);
	  _FI_fld_new_event_value = event.xbutton.button;
	  _FI_fld_new_xpos = event.xbutton.x;
	  _FI_fld_new_ypos = event.xbutton.y;
	  _FI_fld_new_gadget = -1;

              /* GMD 4/14/92    Implement push mode */

              if (FI_push_mode_flag)
                 FI_push_mode_flag = 0;

	      if ( event.xbutton.button == _FI_select_button ) /* GMD 1/14/92 */
		{
		  xpos = event.xbutton.x;
		  ypos = event.xbutton.y;
		  button = event.xbutton.button;

		  if ( field->FIfield.flags.is_a_col )	/* MCF column */
		    {
		      mcfield = (struct FImcf_obj *)
						field->FIgadget.group;

		      if ( _FI_g_find_gadget ( (struct FIgroup_obj *)mcfield, xpos, ypos,
							&mcf_gadget ) )
			{
			  _FI_poke_inside_mcf = 1;
			}
		      else
			{
			  _FI_poke_inside_mcf = 0;
			}
		    }

		  status = _FI_fld_find_gadget ( field, xpos, ypos,
							&gadget_id );
		  if ( status )
		    {
			/**************************************/
			/* point belongs to one of my gadgets */
			/**************************************/

		      if ( gadget_id == (struct FIgadget_obj *) field )
			{
			  if (    field->FIfield.list_id	    &&
				( xpos >= field->FIgadget.xhi -
					 ROLL_THROUGH_SYM_WIDTH )   &&
			         field->FIfield.flags.popup_list     )
			    {
			      field->FIfield.list_id->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;
			      _FI_fld_display ( field->FIfield.list_id,
						window );

			      _FI_list_up = TRUE;
			    }

			  _FI_fld_verify_data ( field );
			  _FI_fld_justify_data ( field );

			  if ( ( field->FIfield.flags.by_line == 1 )  &&
			    field->FIgadget.form->notification_routine )
			    {
				/* Notify application of data */

			      *delete_status = _FI_fld_notify ( field,
					(double) field->FIfield.ar );

			      if ( *delete_status != FI_SUCCESS )
				{
				  return ( 0 );
				}
			    }

			  if ( field->FIfield.mode != FI_REVIEW )
			    {
			      _FI_fld_draw_cursor ( field, window,
						has_focus, FI_MED_GREY,
					_FI_fld_get_line_ON_COLOR (
					   field, field->FIfield.ar ) );

			      /** Drawing the cursor will handle this **
			      if ( field->FIfield.flags.required == 1 )
				{
				  _FI_fld_refresh_row ( field, window,
						field->FIfield.ar );
				}
			      *****************************************/

			      _FI_fld_adjust_row_col ( field,
							xpos, ypos );
			    }

		       /*** added check for FI_REVIEW--JAJ:12/18/91 ***/
		      if ( ( field->FIfield.mode != FI_REVIEW ) &&
		           field->FIfield.flags.clear  &&
			       field->FIfield.buffer[field->FIfield.ar].line )
			    {
			      field->FIfield.buffer[field->FIfield.ar].line[0] = '\0';

			      field->FIfield.ac = 0;
			      field->FIfield.coff = 0;

			      _FI_fld_refresh_row ( field, window,
						field->FIfield.ar );
			    }
			}
                      else
                      {
                        skip_last_test = 0;   /* GMD 10/10/91 */

                        if (field->FIfield.hscrl)    /* GMD 10/10/91 */
                        {
		           if ( gadget_id == (struct FIgadget_obj *)
					      field->FIfield.hscrl[0] )
			   {
			      _FI_fld_track_hscrl ( field, FI_BACKWARD );
                              skip_last_test = 1;
			   }
		           else if ( gadget_id == (struct FIgadget_obj *)
					      field->FIfield.hscrl[1] )
			   {
			      _FI_fld_track_hscrl ( field, FI_FORWARD );
                              skip_last_test = 1;
			   }
                        }
		        
                        if (!skip_last_test)
			{
			  *delete_status = _FI_g_track_mouse (
						gadget_id, window,
						xpos, ypos,
						complete, value );

			  if ( *delete_status != FI_SUCCESS )
			    {
			      return ( 0 );
			    }

			  if ( gadget_id == (struct FIgadget_obj *)
						field->FIfield.list_id )
			    {
			      *value = (double) field->FIfield.ar;
			    }

			/*******************************************/
			/* This test is new.  It's used to prevent */
			/* the field from staying active when a    */
			/* popup-associated list is dismissed.     */
			/*******************************************/

			  if (  field->FIfield.flags.popup_list       &&
			      ( field->FIgadget.prev_in_seq <= 0 )    &&
			      ( field->FIgadget.next_in_seq <= 0 )    &&
			   IT_IS_NOT_DISPLAYED(field->FIfield.list_id) )
			    {
			      my_event = 0;
			    }
			}
                      }

		      if ( field->FIfield.flags.no_echo )
			{
			  temp_ac = field->FIfield.ac;
			  temp_coff = field->FIfield.coff;
			  field->FIfield.coff = 0;
			  field->FIfield.ac = 0;
			}

		      if ( ( field->FIfield.mode != FI_REVIEW )       &&
			   ( ! field->FIfield.flags.popup_list  ||
			     ! _FI_list_up			 )     )
			{
			  _FI_fld_draw_cursor ( field, window,
					has_focus,
					_FI_fld_get_line_ON_COLOR (
						field,
						field->FIfield.ar ),
					FI_MED_GREY );
			}

		      if ( field->FIfield.flags.no_echo )
			{
			  field->FIfield.ac = temp_ac;
			  field->FIfield.coff = temp_coff;
			}

		      XFlush ( _FI_display );
		    }
		  else	/* not my point */
		    {
		       my_event = FALSE;
                       /* GMD 1/24/92 */
		       FI_put_back_event ( _FI_display, &event );
		    }
		}
	      else	/* Button != _FI_select_button */
		{
		  my_event = FALSE;
                  /* GMD 1/24/92 */
		  FI_put_back_event ( _FI_display, &event );
		}
	    }
	    break;	/*** case ( event.type == ButtonPress ) ***/


	  case Expose:

	    FI_process_event (&event, 0 );

	    _FI_fld_draw_cursor ( field, window, has_focus,
		_FI_fld_get_line_ON_COLOR ( field, field->FIfield.ar ),
		FI_MED_GREY );

	    break;	/*** case ( event.type == Expose ) ***/


		/*****************************************************/
		/*** X11-4/28/90 - Let main event loop handle this ***/
		/*** ( will be the next event ) and discontinue    ***/
		/*** tracking the keyboard.			   ***/
		/*****************************************************/


	    case ConfigureNotify:
	    case ClientMessage:
	    case UnmapNotify:

	      my_event = FALSE;
              /* GMD 1/24/92 */
	      FI_put_back_event ( _FI_display, &event );
	      break;


	    case EnterNotify:	/* Only selected when Pointer Root */

	      XGetInputFocus ( _FI_display, &focus_win, &revert_to );
	      if ( focus_win == PointerRoot )
		{
		  has_focus = True;
		}
	      else if ( focus_win == None )
		{
		  XSetInputFocus ( _FI_display, window, RevertToNone,
							CurrentTime );
		  has_focus = True;
		}
	      else  /** Decide whether the window has focus or not **/
		{
		  has_focus = ( focus_win == window );
		}

		/******************************************/
		/** There's NO BREAK here so continue... **/
		/******************************************/

	    case FocusIn:

	      if ( event.type == FocusIn )
		{
		  has_focus = True;
		}

	      _FI_fld_draw_cursor ( field, window, has_focus,
				    _FI_fld_get_line_ON_COLOR ( field,
						    field->FIfield.ar ),
				    FI_MED_GREY );
	      break;


	    case LeaveNotify:	/* Only selected when Pointer Root */

	      XGetInputFocus ( _FI_display, &focus_win, &revert_to );
	      if ( focus_win == PointerRoot )
		{
		  has_focus = False;
		}
	      else /** Decide whether the window has focus or not **/
		{
		  has_focus = ( focus_win == window );
		}

		/******************************************/
		/** There's NO BREAK here so continue... **/
		/******************************************/

	    case FocusOut:

	      if ( event.type == FocusOut )
		{
		  has_focus = 0;
		}

		/*****************************************************/
		/** X11-5/21/90 - Dim the cursor when I lose focus. **/
		/** Also don't allow any button events.		    **/
		/*****************************************************/

	      _FI_fld_draw_cursor ( field, window, 1, FI_MED_GREY,
				    _FI_fld_get_line_ON_COLOR ( field,
						  field->FIfield.ar ) );

	      _FI_fld_draw_cursor ( field, window, has_focus,
				    _FI_fld_get_line_ON_COLOR ( field,
						    field->FIfield.ar ),
				    FI_MED_GREY );
	      break;

	    }	/** END switch event.type **/

	} /*** if ( event.xany.window == window ) ***/
      else
	{
		/*** Event relating to another window which	***/
		/*** the client needs to handle.		***/

	  /******************************************************/
	  /* sml:TR ???    05-23-94                             */
	  /* Fix problem with cursor not being displayed in     */
	  /*   PDM software.                                    */
	  /* This handles the case of having NoExpose events    */
	  /*   when some field has focus.  Now we don't         */
	  /*   undisplay the cursor and remove focus.  Instead  */
	  /*   we stay in the field.                            */
	  /* So add this if statement for the following two     */
	  /*   lines of code.                                   */
	  /******************************************************/
	  if (event.type != NoExpose)
	  {
	    my_event = FALSE;
	    /* GMD 1/24/92 */
	    FI_put_back_event ( _FI_display, &event );
          }
	}

      if (   field->FIfield.flags.popup_list			&&
	   ( field->FIfield.mode == FI_REVIEW )			&&
	   IT_IS_NOT_DISPLAYED ( field->FIfield.list_id )	 )
	{
	  my_event = FALSE;
	}
    }

  *complete = FALSE;

  _FI_mcf_Reason_for_notify = 1;	/* FI_CR_NOT_HIT */

  /* Erase popup associated list */

					/*** JAJ:01/22/92 ***/
  if ( field->FIfield.flags.popup_list && field->FIfield.list_id )
    {
      _FI_g_erase ( (struct FIgadget_obj *) field->FIfield.list_id );
    }

  return ( 0 );
}



/*********************************************************************/
/***  _FI_fld_track_keyboard2:   added "delete_status" argument    ***/
/***  delete_status =  FI_SUCCESS                   JAJ:08/31/90   ***/
/***          = FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***          = FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_track_keyboard2 (struct FIfld_obj  *field,
                             Window             window,
                             int               *complete,
                             double            *value,
                             int               *delete_status)
{
  XEvent	event;
  int		status, my_event, ii, count, x, y;
  unsigned char data[256];

  /**********************************************************/
  /* sml:02-24-93											*/
  /*		initialize *delete_status in case you return	*/
  /*	 	return on a CR, TAB, BS, or SPACE				*/
  /**********************************************************/
  *delete_status = FI_SUCCESS;

  my_event = TRUE;

  while ( my_event )
    {
      /* replaces XNextEvent   GMD 10/23/91 */
      FI_next_event ( _FI_display, &event );

      if ( event.xany.window == window )
	{
	  switch ( event.type )
	    {
	      case KeyPress:
		{
		  ii = 0;
		  count = 1;

		  while ( ii < count )
		    {
		    status = FI_map_character(&event.xkey, (char *) &(data[ii]));
		      if ( ( data[ii]== TAB ) || ( data[ii]== CR ) )
			{
			  XFlush ( _FI_display );

			  return ( 1 );
			}
		      else if ( data[ii]== BS )
			{
			  XFlush ( _FI_display );

			  return (-1 );
			}
		      else if ( data[ii]== SPACE )
			{
			  ii++;

			  _FI_fld_get_xy ( field, field->FIfield.ac -
						field->FIfield.coff,
						&x, &y );

			  *delete_status = _FI_fld_toggle_select_flag (
							field, window,
							x, y, complete,
							value );

			  if ( *delete_status != FI_SUCCESS )
			    {
			      return ( 0 );
			    }
			}
		      else
			{
              /* dmb:09/30/92:Added event */
			  status = FI_map_character ( (XKeyEvent *)&event, (char *)&data[ii] );

			  if ( status )
			    {
				/*********************************/
				/* character has special meaning */
				/*********************************/

			      switch ( data[ii++] )
				{
				  case FI_UP:

				    *delete_status =
					  _FI_fld_previous ( field, 1 );

				    if ( *delete_status != FI_SUCCESS )
				      {
					return ( 0 );
				      }
				    break;


				  case FI_DOWN:

				    *delete_status =
					      _FI_fld_next ( field, 1 );

				    if ( *delete_status != FI_SUCCESS )
				      {
					return ( 0 );
				      }
				    break;


				  case FI_LEFT:

				    _FI_fld_scrl_back ( field, 1 );
				    break;

				  case FI_RIGHT:
				    _FI_fld_scrl_forward ( field, 1 );
				    break;
				}
			    }
			  else  /** character has NO special meaning **/
			    {
			      ii++;
			    }
			}
		    } /*** while ( i < count ) ***/
		}
	        break;	/*** case ( event.type == KeyPress ) ***/

	    }	/** End switch ( event.type ) **/

	} /*** if ( event.xany.window == window )  ***/
      else
	{
		/*** Event relating to another window which	***/
		/*** the client needs to handle.		***/

	  my_event = FALSE;
          /* GMD 1/24/92 */
	  FI_put_back_event ( _FI_display, &event );
	}
    }

  return ( 0 );
}



/*====================================================================*/

void _FI_fld_track_hscrl (struct FIfld_obj  *field,
                          int                direction)
{
  XEvent event;
  int no_event, button_released;

  no_event = TRUE;

  _FI_g_set_state ( (struct FIgadget_obj *)field->FIfield.hscrl[direction], 1.0 );

  _FI_generic_timer ( (double) 0.5, 1 );

  /* GMD 1/24/92 */
  button_released = FI_check_mask_event ( _FI_display, ButtonReleaseMask,
							&event );

  while ( ! _FI_generic_timer ( (double) 0.0, 0 ) && ! button_released )
    {
      XSync ( _FI_display, False );

      /* GMD 1/24/92 */
      button_released = FI_check_mask_event ( _FI_display,
					ButtonReleaseMask, &event );
    }

  while ( no_event )
    {
      if ( direction )
	{
	  _FI_fld_scrl_forward ( field, 1 );
	}
      else
	{
	  _FI_fld_scrl_back ( field, 1 );
	}

      if ( button_released )
	{
	  no_event = FALSE;
	}
      else
	{
	  XSync ( _FI_display, False );

          /* GMD 1/24/92 */
	  button_released = FI_check_mask_event ( _FI_display,
			ButtonReleaseMask | ButtonPressMask, &event );
	}
    }

  _FI_g_set_state ( (struct FIgadget_obj *)field->FIfield.hscrl[direction], 0.0 );
}



/********************************************************************/
/* Function:  int FIfld_get_notify_info                             */
/*                                                                  */
/*  sml:11-01-93 created                                            */
/*                                                                  */
/* If you call this function inside a field's (maybe a MCF too)     */
/* notification routine, it will check how the field was notified.  */
/* That allows the developer to determine whether to execute the    */
/* notification code.                                               */
/*                                                                  */
/* int FIfld_get_notify_info (int *event, int *event_value,         */
/* 		Form *form, int *gad_label)                                 */
/*                                                                  */
/* *event			O	Event type (KEYBOARD_EVENT, BUTTON_EVENT)   */
/*                                                                  */
/* *event_value	O	The value of the event (character code or       */
/*						button number)                              */
/*                                                                  */
/* *Form			O	The form on which the event occurred        */
/*                                                                  */
/* *gad_label		O	The gadget label selected                   */
/*                                                                  */
/*                                                                  */
/* Return codes:                                                    */
/*                                                                  */
/* 	FI_SELECTED_KEYBOARD				returned with KEYBOARD event        */
/*	FI_SELECTED_MOUSE_BUTTON	returned with BUTTON event          */
/*	FI_SELECTED_ASSOCIATED_LIST	returned with BUTTON event          */
/*	FI_NOT_FIELD_GADGET			returned when function is called    */
/*								outside context of fld notification */
/*                                                                  */
/********************************************************************/

int FIfld_get_notify_info(	int *event,
							int *event_value,
							Form *form,
							int *gad_label)
{
  struct FIgroup_obj * group;
  int sts;


  *event = _FI_fld_new_event;
  *event_value = _FI_fld_new_event_value;
  *form = _FI_fld_new_form;
  
  if (*event == ButtonPress && 
   _FI_fld_new_event_status != FI_SELECTED_ASSOCIATED_LIST)
	sts = FI_SELECTED_MOUSE_BUTTON;
  else if (*event == KeyPress)
	sts = FI_SELECTED_KEYBOARD;
  else 
	sts = _FI_fld_new_event_status; /*FI_SELECTED_UNKNOWN_ACTION;*/

  if (*event == ButtonPress && 
	_FI_fld_new_event_status == FI_SELECTED_ASSOCIATED_LIST)
  {
	*gad_label = _FI_fld_new_gadget;
  }
  else if (*event == ButtonPress && 
	_FI_fld_new_event_status != FI_SELECTED_ASSOCIATED_LIST)
  {
    /* sml:06-17-94: add this check; may have selected non-form window */
    /* sml:07-07-94:check if form is still valid; may have been deleted */
    if (*form && (FIf_is_valid(*form) == FI_SUCCESS))
    {
	group = (struct FIgroup_obj *) _FI_g_get_id((struct FIform_obj *) *form, FI_FORM_GROUP);
	if (group)
	{
	  struct FIgadget_obj *gadget = NULL;
	  struct FIgadget_obj *child_gadget = NULL;

	  if (_FI_g_find_parent_gadget(group, _FI_fld_new_xpos, 
			_FI_fld_new_ypos, &gadget))
	  {
		*gad_label = gadget->FIgadget.label;
		
		if (gadget->FIgadget.type == FI_FIELD)
		{
		  if (_FI_g_find_gadget(group, _FI_fld_new_xpos,
			_FI_fld_new_ypos, &child_gadget))
		  {
			if (child_gadget->FIgadget.type == FI_FIELD)
			{
			  struct FIfld_obj *field = (struct FIfld_obj *)child_gadget;

/*			  if ( (struct FIfld_obj *) child_gadget->FIfield.flags.is_a_list)*/
			  if ( field->FIfield.flags.is_a_list)
			  {
				sts = FI_SELECTED_ASSOCIATED_LIST;
			  }
			}
		  }
		}
	  }
	  else 
	  {
		*gad_label = -1;
	  }
	}
      } /* end if form not NULL and the ptr is valid */
      else /* sml:06-17-94: else selected non-form window */
                        /* sml:07-07-94: or form has been deleted */
      {
        *gad_label = -1;
      }
  }
  else if (*event == KeyPress)
  {
	*gad_label = _FI_fld_new_gadget;	
  }  
  else
  {
	*gad_label = -1;
  }
  return(sts);
}
