#include "FImin.h"
#include "FIbtn.h"
#include "FIseq.h"
#include "FItext.h"


#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

int _FI_btn_display (struct FIbtn_obj  *button_obj,
                     Window             window)
{
  struct FIform_obj *form	 = button_obj->FIgadget.form;
  int		     xlo	 = button_obj->FIgadget.xlo;
  int		     ylo	 = button_obj->FIgadget.ylo;
  int		     xhi	 = button_obj->FIgadget.xhi;
  int		     yhi	 = button_obj->FIgadget.yhi;
  Font		     font_id     = button_obj->FIgadget.font_id;
  int		     state_on	 = button_obj->FIgadget.value;
  int		     font_height = button_obj->FIgadget.font_height;
  int	  	     Xscreen	 = form->Xscreen;
  unsigned char     *text 	 = button_obj->FIgadget.text;

  int	edge_color;
  int	t_l_color;
  int	b_r_color;
  int	color;
  int	face;
  int	bezel;
  int	got_clipped = FALSE;
  XRectangle rect;
  XGCValues gc_values;
  XRectangle clip_rect;


  if ( ! _FI_is_in_clip_rectangle ( & button_obj->FIgadget ) )
    {
      return ( FI_SUCCESS );
    }

	/* Set color for bezel and text/icon */

  if ( state_on )
    {
      t_l_color = FI_SHADOW;
      b_r_color = FI_GLINT;
      face = FI_DK_FACE;
      color = ON_COLOR ( button_obj ) ;
    }
  else
    {
      t_l_color = FI_GLINT;
      b_r_color = FI_SHADOW;
      face = FI_FACE;
      color = OFF_COLOR ( button_obj );
    }

	/*** Set to be wire-frame look because	***/
	/*** the button is disabled.		***/

  if ( IT_IS_DISABLED ( button_obj ) )
    {
      t_l_color = FI_FACE;
      b_r_color = FI_FACE;
    }

	/*** Set the edge color ***/

  if ( IT_IS_HILITED ( button_obj ) )
    {
      edge_color = FI_GLINT;
      color = FI_GLINT;
    }
  else
    {
      edge_color = FI_EDGE;
    }

  /*** Check for label less than prompt field because		***/
  /*** control bars and buttons on scroll gadget need smaller	***/
  /*** bezel for the buttons 					***/

  if ( IT_IS_CONTROL ( button_obj ) )
    {
      bezel = CBAR_BEZEL_WIDTH;
    }
  else
    {
      bezel = BUTTON_BEZEL_WIDTH;
    }


  /*** If the gadgets is smaller than 10 pixels then	***/
  /*** make the bezel have a 0 pixel shelf		***/

  if ( ((xhi - xlo) < 10) || ((yhi - ylo) < 10) )
    {
      bezel = 0;
    }

  _FI_draw_bezel ( window, xlo, ylo, xhi, yhi, bezel,
		FI_translate_color ( Xscreen, t_l_color ),
		FI_translate_color ( Xscreen, face ),
		FI_translate_color ( Xscreen, b_r_color),
		FI_translate_color ( Xscreen, edge_color),
		CHAMFERED );

	/* Set color to color */

  gc_values.foreground = FI_translate_color ( Xscreen, color );
  gc_values.background = FI_translate_color ( Xscreen, face );
  XChangeGC ( _FI_display, _FI_gc,
	(unsigned long) GCForeground | GCBackground, &gc_values );

  /* Clip to inside of button */

  rect.x = xlo + bezel;
  rect.y = ylo + bezel;
  rect.width  = xhi - xlo - (2 * bezel);
  rect.height = yhi - ylo - (2 * bezel);

  if ( _FI_form_clipping_on )
     {
      _FI_adjust_clip_rectangle ( &rect );
     }

  if ( IT_HAS_TEXT ( button_obj ) )
    {
      XSetClipRectangles ( _FI_display, _FI_gc, 0, 0,
				&rect, 1, Unsorted );
      got_clipped = TRUE;

      if ( state_on )			 /* GMD 6/21/91 */
	{
          XSetBackground ( _FI_display, _FI_gc, 
			FI_translate_color ( Xscreen, FI_MED_GREY ) );
	}
      else
	{
          XSetBackground ( _FI_display, _FI_gc, 
			FI_translate_color ( Xscreen, FI_LT_GREY ) );
	}

      _FI_g_draw_text ( (struct FIgadget_obj *)button_obj, xlo, ylo, xhi, yhi, text,
			button_obj->FIgadget.num_lines, font_height,
			BORDERS, NO_ERASE );
    }
  else
    {
      int width  = xhi - xlo;
      int height = yhi - ylo;
      int new_x;
      int new_y;

     /* Display bottom symbol */

      if ( IT_HAS_OFF_SYMBOL(button_obj) )
	{
	  struct FIsym_instance *sym = & button_obj->FIgadget.symbol_ptr;
	  unsigned int  scaled_width = sym->sym_width *
				button_obj->FIgadget.sym_width_scale_factor;
	  unsigned int scaled_height = sym->sym_height *
			       button_obj->FIgadget.sym_height_scale_factor;

	  new_x = xlo + (width - scaled_width) / 2 + 1;
	  new_y = ylo + (height - scaled_height) / 2 + 1;

	  if ( ( scaled_width > rect.width )	||
	       ( scaled_height > rect.height )	 )
	    {
	      XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &rect,
							1, Unsorted );
	      got_clipped = TRUE;
	    }

	  _FI_sym_draw ( window, new_x, new_y, font_id, sym,
			 button_obj->FIgadget.sym_width_scale_factor,
			 button_obj->FIgadget.sym_height_scale_factor, Xscreen);
	}

      if ( button_obj->FIbtn.menu_button )
	{
	  if (state_on)
	    {
	      XSetForeground ( _FI_display, _FI_gc,
		 FI_translate_color ( Xscreen, ON_COLOR2 ( button_obj ) ) );
	    }
	  else
	    {
	      XSetForeground ( _FI_display, _FI_gc,
		 FI_translate_color ( Xscreen, OFF_COLOR2 ( button_obj ) ));
	    }
	}

     /* Display top symbol */
     /* Why is this here? Do buttons really have on symbols */

      if ( IT_HAS_ON_SYMBOL ( button_obj ) )
	{
	  struct FIsym_instance *sym = & button_obj->FIgadget.on_symbol_ptr;

	  new_x = xlo + ( width / 2  ) - ( sym->sym_width / 2 );
	  new_y = ylo + ( height / 2 ) - ( sym->sym_height / 2 );

	  if (  (! got_clipped)				 &&
		((sym->sym_width > rect.width)   ||
		 (sym->sym_height > rect.height)  )	  )
	    {
	      XSetClipRectangles ( _FI_display, _FI_gc, 0, 0,
					&rect, 1, Unsorted );
	      got_clipped = TRUE;
	    }

	  _FI_sym_draw ( window, new_x, new_y, font_id, sym,
			 button_obj->FIgadget.sym_width_scale_factor,
			 button_obj->FIgadget.sym_height_scale_factor, Xscreen);
	}
    }

  if ( IT_IS_DISABLED( button_obj )					&&
	( (button_obj->FIgadget.attr_mask & FI_NO_DITHERING) == 0)	 )
    {
      int		texture_offset = bezel + 3;
      unsigned long	gc_value_mask;

      if ( state_on )
        {
	  color = FI_DK_FACE;
  	}
      else
        {
	  color = FI_FACE;
  	}

      gc_value_mask = GCStipple | GCForeground | GCFillStyle;
      gc_values.foreground = FI_translate_color ( Xscreen, color );
      gc_values.stipple = _FIpix_gray50_array[Xscreen];
      gc_values.fill_style = FillStippled;
      XChangeGC ( _FI_display, _FI_gc, gc_value_mask, &gc_values );

	  /***************************************************/
	  /* sml:02-19-93                                    */
	  /* change clip area to dither gadget's entire area */
	  /***************************************************/
	 	  clip_rect.x = button_obj->FIgadget.xlo;
		  clip_rect.y = button_obj->FIgadget.ylo;
		  clip_rect.width = button_obj->FIgadget.xhi - button_obj->FIgadget.xlo;
 		  clip_rect.height = button_obj->FIgadget.yhi - button_obj->FIgadget.ylo;
		  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &clip_rect,
						 1, Unsorted );

      XFillRectangle ( _FI_display, window, _FI_gc,
			xlo + texture_offset,
			ylo + texture_offset,
			xhi - xlo - ( 2 * texture_offset ),
			yhi - ylo - ( 2 * texture_offset ) + 2 );

	 	 /***************************************************/
 		 /* sml:02-19-93                                    */
		 /* set it back to general clip area                */
	 	 /***************************************************/
		if (_FI_form_clipping_on)
		{
		  clip_rect.x = _FI_clip_xlo;
		  clip_rect.y = _FI_clip_ylo;
		  clip_rect.width = _FI_clip_xhi - _FI_clip_xlo;
		  clip_rect.height = _FI_clip_yhi - _FI_clip_ylo;
		  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &clip_rect,
						 1, Unsorted );
		}
		else
		{
		  XSetClipMask(_FI_display, _FI_gc, None);
		}

      XSetFillStyle ( _FI_display, _FI_gc, FillSolid );
    }

  if ( got_clipped )
    {
      _FI_clipping_off ( (struct FIgadget_obj *)button_obj );	/** Reset the clipping **/
    }

  return ( FI_SUCCESS );
}



/******************************************************************/
/*** _FI_btn_track_mouse: changed from "void" to "int"		***/
/*** Returns: FI_SUCCESS JAJ:09/05/90				***/
/*** 	FI_NO_SUCH_FORM - means form apparently got		***/
/*** 			  deleted by notification routine	***/
/***    FI_NO_SUCH_GADGET - means gadget apparently got		***/
/*** 			    deleted by notification routine	***/
/******************************************************************/

int _FI_btn_track_mouse (struct FIbtn_obj  *button_obj,
                         Window             window,
                         int               *complete,
                         double            *value)
{
  struct FIform_obj *form = button_obj->FIgadget.form;
  int		    label = button_obj->FIgadget.label;
  int		    status;


  *complete = TRUE;

  *value = button_obj->FIgadget.value = ! button_obj->FIgadget.value;

  _FI_btn_display ( button_obj, window );

  XFlush ( _FI_display );

  if ( label == FI_RESET )
    {
      _FI_g_reset ( (struct FIgadget_obj *)form->group );
    }
  else if ( label == FI_CVT_TO_PERM_WIN )
    {
      FIf_cvrt_to_perm_win ( (Form) form);
    }

  /*** CHUNN remove this in the redesign. 	***/
  /*** This is a KLUDGE for field		***/

  else if ( label == -1 )
    {
      _FI_fld_track_hscrl ( (struct FIfld_obj *)button_obj->FIgadget.user_pointer,
				FI_BACKWARD );
      *complete = FALSE;
    }
  else if ( label == -2 )
    {
      _FI_fld_track_hscrl ( (struct FIfld_obj *)button_obj->FIgadget.user_pointer,
				FI_FORWARD );
      *complete = FALSE;
    }

  /****************  CHUNN end KLUDGE  ***********************/


  if ( button_obj->FIbtn.auto_pop_up )
    {
      *complete = FALSE;

     /* Notify */

      if ( form->notification_routine )
	{
					/*** JAJ:01/20/92 ***/
	  _FI_notification_type = FI_COMPLETION_NOTIFICATION;

		/***************************************************/
	        /**** RECORD the notification before DOING it	****/
	        /**** JAJ:08/30/90				****/
	        /***************************************************/

	  if ( _FI_record_notification_routine )
	    {
	      _FI_record_notification_routine ( form->form_label,
						label, *value, form );
	    }

	        /***************************************************/
	        /**** Call the form's notification routine	****/
	        /***************************************************/

	  form->notification_routine ( form->form_label, label,
						*value, form);

        /*****************************************************/
        /**** make sure form and/or gadget were not	 ****/
        /**** deleted by the form's notification routine ****/
        /**** -- JAJ:08/30/90				 ****/
        /*****************************************************/

	  status = FIg_is_valid ( (Form)form, label );

	  if ( status != FI_SUCCESS )
	    {
	      return ( status );
	    }
	}

     /* Pop back up(set to 0)*/

      if ( label != FI_RESET )
        {
	   *value = button_obj->FIgadget.value = 0;
  	}

     /* Get window number because it might have changed */

      window = form->Xwindow;

      if ( (window != None) && form->displayed && (label != FI_RESET) )
	{
	  _FI_btn_display ( button_obj, window );
	  XFlush ( _FI_display );
	}
    }

  if ( label == FI_HELP )
    {
      FI_activate_help ( (Form)form );
    }

  if ( ! *complete )
    {
      _FI_g_common ( (struct FIgadget_obj *)button_obj );
    }
  return ( FI_SUCCESS );
}


/* dmb:10/10/92:Change floats to doubles for ANSI */
int _FI_btn_adjust (struct FIbtn_obj  *button_obj,
                    double             delta_x,
                    double             delta_y)
{
  _FI_generic_adjust ( (struct FIgadget_obj *)button_obj, delta_x, delta_y );

  if ( IT_HAS_TEXT(button_obj) )
    {
      int dummy = 0;

        /***********************************************************/
        /*** ALERT !  ALERT !  STOP !  LOOK !  LISTEN !          ***/
        /***********************************************************/
        /*** _FI_g_change_text MAY CHANGE GADGET'S font_id !!!   ***/
        /*** _FI_g_change_text MAY CHANGE GADGET'S font_type !!! ***/
        /***********************************************************/

      _FI_g_change_text ( (struct FIgadget_obj *)button_obj, delta_y );

      _FI_mlt_get_lines (   button_obj->FIgadget.text,
			  (int *)& button_obj->FIgadget.num_lines,
			  & dummy,
			    button_obj->FIgadget.font_id,
			    button_obj->FIgadget.font_type );
    }
  else
    {
      _FI_g_change_symbol ( (struct FIgadget_obj *)button_obj );
      _FI_g_load_symbol ( (struct FIgadget_obj *)button_obj );	/*** GMD:08/28/91 ***/
    }
  return ( FI_SUCCESS );
}



int _FI_btn_activate (struct FIbtn_obj *button_obj)
{
  if ( IT_HAS_TEXT ( button_obj ) )
    {
	/*** Set dummy to 0 meaning don't calculate 	***/
	/*** width of largest string.			***/

      int dummy = 0;

        /***********************************************************/
        /*** ALERT !  ALERT !  STOP !  LOOK !  LISTEN !          ***/
        /***********************************************************/
        /*** _FI_g_change_text MAY CHANGE GADGET'S font_id !!!   ***/
        /*** _FI_g_change_text MAY CHANGE GADGET'S font_type !!! ***/
        /***********************************************************/

      _FI_g_change_text ( (struct FIgadget_obj *)button_obj, 1.0 );

      _FI_mlt_get_lines (  button_obj->FIgadget.text,
			 (int *) & button_obj->FIgadget.num_lines,
			 & dummy,
			   button_obj->FIgadget.font_id,
			   button_obj->FIgadget.font_type );
    }
  else
    {
      _FI_g_load_symbol ((struct FIgadget_obj *)button_obj);
    }

  return ( FI_SUCCESS );
}
