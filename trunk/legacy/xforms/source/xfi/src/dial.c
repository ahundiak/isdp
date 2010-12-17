#include "FImin.h"
#include "FIdial.h"
#include <math.h>
#include <values.h>   /* dmb:09/29/92: Added for M_PI in ANSI */
#include <stdio.h>
#include <FImacros.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/* #define DEBUG_PRINT(x)   x  */
#define DEBUG_PRINT(x)


void _FI_dial_draw_ticks (struct FIdial_obj  *dial,
                          Window              window)
{
  int Xscreen	  = XSCREEN ( dial );
  int center_x	  = dial->FIdial.center_x;
  int center_y	  = dial->FIdial.center_y;
  int tick_length = dial->FIdial.tick_length;
  double offset	  = dial->FIdial.offset;
  int xlo;
  int ylo;
  int xhi;
  int yhi;
  int tick_offset;

  double value;
  double angle;
  double increment;
  XGCValues gc_values;
  unsigned int value_mask = GCLineWidth;

  int translated_zero_tick_color;
  int translated_reg_tick_color;



	/*********************************************************/
	/** Change to make tick marks show up on 2 and 4 color	**/
	/** screens.			- JAJ 11/16/90		**/
	/*********************************************************/

  translated_zero_tick_color =
	_FI_g_find_contrasting_on_color ( Xscreen,
		FI_translate_color ( Xscreen, FI_RED ),
		FI_translate_color ( Xscreen, ERASE_COLOR ( dial ) ) );

  translated_reg_tick_color =
	_FI_g_find_contrasting_on_color ( Xscreen,
		FI_translate_color ( Xscreen, FI_BLACK ),
		FI_translate_color ( Xscreen, ERASE_COLOR ( dial ) ) );


  tick_offset = dial->FIdial.needle_length + NEEDLE_MARGIN;

  /* Draw increment tick marks */

  gc_values.line_width = 2;
  XChangeGC ( _FI_display, _FI_gc, value_mask, &gc_values );

  if ( dial->FIdial.minor_tick_inc > 0 )
    {
	/* Calculate the increment in radians */

      increment = TWO_PI / (float) dial->FIdial.minor_tick_inc;

      for ( value = 0.0; value < TWO_PI - 0.05; value += increment )
	{
	  if ( value == 0.0 )
	    {
	      XSetForeground ( _FI_display, _FI_gc,
				translated_zero_tick_color );
	    }

	  angle = value * dial->FIdial.direction + offset;

	  xlo = center_x + ( tick_offset * cos (angle) );
	  ylo = center_y - ( tick_offset * sin (angle) );

	  xhi = center_x + ((tick_offset + tick_length) * cos (angle));
	  yhi = center_y - ((tick_offset + tick_length) * sin (angle));

	  if ( ABS(center_x - xlo) < TOLERANCE )
	    {
	      xlo = center_x;
	    }

	  if ( ABS(center_x - xhi) < TOLERANCE )
	    {
	      xhi = center_x;
	    }

	  if ( ABS(center_y - ylo) < TOLERANCE )
	    {
	      ylo = center_y;
	    }

	  if ( ABS(center_y - yhi) < TOLERANCE )
	    {
	      yhi = center_y;
	    }

	  XDrawLine ( _FI_display, window, _FI_gc, xlo, ylo, xhi, yhi );

	  if ( value == 0.0 )
	    {
	      XSetForeground ( _FI_display, _FI_gc,
				translated_reg_tick_color );
	    }
	}
    }
}



void _FI_dial_draw_needle (struct FIdial_obj  *dial,
                           Window              window,
                           double              needle_value,
                           int                 point_color,
                           int                 needle_color,
                           int                 erasing)
{
  int	Xscreen		= XSCREEN ( dial );
  int	needle_length	= dial->FIdial.needle_length;
  int	center_x	= dial->FIdial.center_x;
  int	center_y	= dial->FIdial.center_y;
  double angle		= (needle_value / dial->FIdial.scale) *
			   dial->FIdial.direction + dial->FIdial.offset;
  int	begin_text_x	= center_x - needle_length * cos (angle) / 2;
  int	begin_text_y	= center_y + needle_length * sin (angle) / 2;

  int	needle_end_x;
  int	needle_end_y;
  int	color;
  int	text_x;
  int	text_y;
  int	dummy1, dummy2;
  int	offset;

  char		value[32];
  XGCValues	gc_values;
  unsigned int	value_mask = GCLineWidth | GCForeground | GCBackground;
  XRectangle	rect;


	/* Set clipbox area for the inside of the dial bezel */

  if ( ! _FI_form_clipping_on )
    {
      offset = TOTAL_BORDER + 1;
      rect.x = (int) dial->FIgadget.xlo + offset;
      rect.y = (int) dial->FIgadget.ylo + offset;
      rect.width = (int) dial->FIgadget.xhi - (int) dial->FIgadget.xlo -
						     ( 2 * offset );
      rect.height =(int) dial->FIgadget.yhi - (int) dial->FIgadget.ylo -
						     ( 2 * offset );

      XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &rect,
						1, Unsorted );
    }

	  /* Draw center point */

  /** No support of a weighted point *******************************
   gc_values.line_width = 4;
   gc_values.foreground = FI_translate_color( Xscreen, point_color);
   XChangeGC(_FI_display, _FI_gc, value_mask, &gc_values);

   XDrawPoint(_FI_display, window, _FI_gc, center_x, center_y);
  ******************************************************************/

  XSetForeground ( _FI_display, _FI_gc,
			FI_translate_color ( Xscreen, point_color) );

  XFillRectangle ( _FI_display, window, _FI_gc,
				center_x - 2, center_y - 2, 5, 5 );

	/* Draw needle */

  if ( IT_IS_HILITED(dial) && ! erasing )
    {
      color = FI_GLINT;
    }
  else
    {
      color = needle_color;
    }

  gc_values.line_width = 2;
  gc_values.foreground = FI_translate_color ( Xscreen, color );

						     /* GMD 6/21/91 */
  gc_values.background = FI_translate_color ( Xscreen, FI_LT_GREY );

  XChangeGC ( _FI_display, _FI_gc, value_mask, &gc_values );

  needle_end_x = center_x + ( needle_length * cos (angle) );
  needle_end_y = center_y - ( needle_length * sin (angle) );

	/* Convert needle_value to radians */

  if ( ABS ( needle_end_x - center_x ) < TOLERANCE )
     {
	  needle_end_x = center_x;
     }

  if ( ABS(needle_end_y - center_y) < TOLERANCE )
     {
	  needle_end_y = center_y;
     }

  XDrawLine ( _FI_display, window, _FI_gc, center_x, center_y,
				needle_end_x, needle_end_y );

	/* Draw text by needle point */

  if ( DISPLAY_VALUE(dial) )
    {
	/* Draw current value */

      text_x = begin_text_x;
      text_y = begin_text_y;

      _FI_snap_value ( (struct FIgadget_obj *)dial, &needle_value,
			(double)( dial->FIdial.scale * TWO_PI ) );

      _FI_format_string ( (struct FIgadget_obj *)dial, value, needle_value );


      FI_calc_text ( dial->FIgadget.font_id, value, strlen (value),
			&dial->FIgadget.font_height,
			&dial->FIgadget.font_width,
			&dummy1, dial->FIgadget.font_type );

      text_x -= dial->FIgadget.font_width / 2;
      text_y -= dial->FIgadget.font_height / 2;

      FI_draw_text ( window, dial->FIgadget.font_id, value,
			strlen (value), text_x, text_y,
			dial->FIgadget.font_height, &dummy1, &dummy2,
			dial->FIgadget.font_type);
    }

  if ( DISPLAY_HIGH_VALUE(dial) )
    {
      char value2[32];

	/* Draw high value under init value */

      text_x = begin_text_x;
      text_y = begin_text_y;

      _FI_format_string ( (struct FIgadget_obj *)dial, value,
			(double) (dial->FIdial.scale * TWO_PI) );

      sprintf ( value2, "(%s)", value );

      FI_calc_text ( dial->FIgadget.font_id, value2,
			strlen (value2), &dial->FIgadget.font_height,
			&dial->FIgadget.font_width, &dummy1,
			dial->FIgadget.font_type );

      text_x -= dial->FIgadget.font_width / 2;
      text_y -= dial->FIgadget.font_height / 2;
      text_y += dial->FIgadget.font_height + 2;

      FI_draw_text ( window, dial->FIgadget.font_id, value2,
			strlen (value2), text_x, text_y,
			dial->FIgadget.font_height,
			&dummy1, &dummy2, dial->FIgadget.font_type);
    }

  _FI_clipping_off ((struct FIgadget_obj *)dial);
}



void _FI_dial_draw_bezels (struct FIdial_obj *dial)
{
  int xlo	= dial->FIgadget.xlo;
  int ylo	= dial->FIgadget.ylo;
  int xhi	= dial->FIgadget.xhi;
  int yhi	= dial->FIgadget.yhi;
  Window window = XWINDOW ( dial );
  int Xscreen	= XSCREEN ( dial );

  unsigned long shadow_color;
  unsigned long glint_color;
  unsigned long edge_color;
  unsigned long face_color = FI_translate_color ( Xscreen, FI_FACE);


  if ( IT_IS_DISABLED ( dial ) )
    {
      shadow_color = face_color;
      glint_color = face_color;
    }
  else
    {
      shadow_color = FI_translate_color ( Xscreen, FI_SHADOW);
      glint_color = FI_translate_color ( Xscreen, FI_GLINT);
    }

  if ( IT_IS_HILITED ( dial ) )
    {
      edge_color = FI_translate_color ( Xscreen, FI_GLINT );
    }
  else
    {
      edge_color = FI_translate_color ( Xscreen, FI_EDGE );
    }

  if ( (int) dial->FIdial.border_style == FI_DIAL_SHELF_BORDER )
    {
      int offset = DIAL_BEZEL + DIAL_SHELF;

	/* Draw outer border */

      _FI_draw_bezel ( window, xlo, ylo, xhi, yhi, DIAL_BORDER,
			glint_color, face_color, shadow_color,
			edge_color, SQUARE );

	/* draw inner bezel */

      _FI_draw_bezel ( window, xlo + offset, ylo + offset,
			xhi - offset, yhi - offset, DIAL_BORDER,
			shadow_color, face_color, glint_color,
			edge_color, CHAMFERED );
    }
  else
    {
	/* Clear total dial area */

      XSetForeground ( _FI_display, _FI_gc,
		FI_translate_color ( Xscreen, ERASE_COLOR ( dial ) ) );

      XFillRectangle ( _FI_display, window, _FI_gc,
			xlo, ylo, xhi - xlo, yhi - ylo );
    }
}



int _FI_dial_display (struct FIdial_obj  *dial,
                      Window              window)
{
  int offset = TOTAL_BORDER + 1;

  int xlo	= dial->FIgadget.xlo + offset;
  int ylo	= dial->FIgadget.ylo + offset;
  int xhi	= dial->FIgadget.xhi - offset;
  int yhi	= dial->FIgadget.yhi - offset;
  XRectangle rect;
  XRectangle clip_rect;

  if ( ! _FI_is_in_clip_rectangle ( & dial->FIgadget ) )
    {
      return ( FI_SUCCESS );
    }

  rect.x = dial->FIgadget.xlo;
  rect.y = dial->FIgadget.ylo;
  rect.width  = dial->FIgadget.xhi - dial->FIgadget.xlo;
  rect.height = dial->FIgadget.yhi - dial->FIgadget.ylo;

  if ( _FI_form_clipping_on )
    {
      _FI_adjust_clip_rectangle ( &rect );	/** Due to text **/
    }

  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &rect, 1, Unsorted );

  _FI_dial_draw_bezels ( dial );

	/* Set clipbox area for the inside of the dial bezel */

  rect.x = xlo;
  rect.y = ylo;
  rect.width  = xhi - xlo;
  rect.height = yhi - ylo;

  if ( _FI_form_clipping_on )
    {
      _FI_adjust_clip_rectangle ( &rect );	/** Due to text **/
    }

  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &rect, 1, Unsorted );

  _FI_dial_draw_ticks ( dial, window );

  _FI_dial_draw_needle ( dial, window, dial->FIgadget.value,
			FI_BLACK, OFF_COLOR(dial) , 0 );

  if ( IT_IS_DISABLED ( dial ) )
    {
       XGCValues gc_values;
       unsigned long gc_value_mask = GCForeground | GCFillStyle | GCStipple;

      gc_values.stipple = _FIpix_gray50_array [XSCREEN (dial)];
      gc_values.fill_style = FillStippled;

      if ( (int) dial->FIdial.border_style == FI_DIAL_SHELF_BORDER )
	{
	  gc_values.foreground = FI_translate_color ( XSCREEN(dial),
							    FI_FACE );
	}
      else
	{
	  gc_values.foreground = FI_translate_color ( XSCREEN(dial),
						ERASE_COLOR(dial) );
	}

      XChangeGC ( _FI_display, _FI_gc, gc_value_mask, &gc_values );

	  /***************************************************/
	  /* sml:02-19-93                                    */
	  /* change clip area to dither gadget's entire area */
	  /***************************************************/
	 	  clip_rect.x = dial->FIgadget.xlo;
		  clip_rect.y = dial->FIgadget.ylo;
		  clip_rect.width = dial->FIgadget.xhi - dial->FIgadget.xlo;
 		  clip_rect.height = dial->FIgadget.yhi - dial->FIgadget.ylo;
		  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &clip_rect,
						 1, Unsorted );

      XFillRectangle ( _FI_display, window, _FI_gc,
				xlo, ylo, xhi - xlo, yhi - ylo );

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

  return ( FI_SUCCESS );
}



void _FI_dial_draw_new_needle (struct FIdial_obj  *dial,
                               double              last_value,
                               double              new_value)
{
  Window window = XWINDOW(dial);
  int erase_color = ERASE_COLOR(dial);


	/* erase old value */

  if ( (int) dial->FIdial.border_style == FI_DIAL_SHELF_BORDER )
    {
      _FI_dial_draw_needle ( dial, window, last_value,
					FI_FACE, FI_FACE, 1 );
    }
  else
    {
      _FI_dial_draw_needle ( dial, window, last_value,
					erase_color, erase_color, 1 );
    }

  _FI_dial_draw_ticks ( dial, window );

  _FI_dial_draw_needle ( dial, window, new_value,
				FI_BLACK, OFF_COLOR(dial), 0 );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
  if (!_FI_dont_flush)
    XFlush ( _FI_display );
}



void _FI_dial_track_mouse (struct FIdial_obj  *dial,
                           Window              window,
                           int                 xpos,
                           int                 ypos,
                           int                *complete,
                           double             *value)
{
  int	xlo		= dial->FIgadget.xlo;
  int	ylo		= dial->FIgadget.ylo;
  int	xhi		= dial->FIgadget.xhi;
  int	yhi		= dial->FIgadget.yhi;
  double original_value	= dial->FIgadget.value;
  double last_value	= dial->FIgadget.value;
  int	dial_area;
  int	button_pressed;
  int	grab;

#if (defined(i386) || defined(sparc) || defined(sun) && defined(SYSV)) || defined(mips)
  extern unsigned int _FI_last_button_transition;
#endif
	/* Calculate the area around the dial */

  if ( (xhi - xlo) < (yhi - ylo) )
    {
      dial_area = xhi - xlo;
    }
  else
    {
      dial_area = yhi - ylo;
    }

#if (defined(i386) || defined(sparc) || defined(sun) && defined(SYSV)) || defined(mips)
  /*************************************************/
  /* sml:02-14-94:TRs 249400227 and TR249400184    */
  /* Transitions are not handled correctly         */
  /* Check if you have SINGLE CLICK passed in and  */
  /* handle that case.                             */
  /*************************************************/
  if (_FI_last_button_transition == SINGLE_CLICK)
  {
    button_pressed = 0;
    _FI_last_button_transition = 0;
      if ( (xpos >= (xlo - dial_area)) &&
	   (xpos <= (xhi + dial_area)) &&
	   (ypos >= (ylo - dial_area)) &&
	   (ypos <= (yhi + dial_area))	)
	{
	  last_value = dial->FIgadget.value;

	  _FI_dial_find_angle_in_radians ( dial, xpos, ypos );
	}
      else
	{
	  dial->FIgadget.value = original_value;
	}
	
      if ( last_value != dial->FIgadget.value )
	{
	  _FI_dial_draw_new_needle ( dial, last_value,
					dial->FIgadget.value );
	}
  }
else /* trans not a SINGLE CLICK */
  {
#endif
  grab = FI_grab_pointer ( _FI_display, window, True,
			ButtonMotionMask | PointerMotionHintMask,
			GrabModeAsync, GrabModeAsync,
			window, None, CurrentTime );

  button_pressed = ( grab == GrabSuccess );

  while ( button_pressed )
    {
       Window root, child;
       int root_x, root_y;
       unsigned int keys_buttons_mask;
       XEvent event;

       /* GMD 1/24/92 */
       FI_mask_event ( _FI_display, ButtonPressMask | ButtonReleaseMask |
		       ButtonMotionMask | PointerMotionHintMask, &event );

      if ( event.type == ButtonPress || event.type == ButtonRelease )
	{
	  if ( event.xbutton.window == window )
	    {
	      xpos = event.xbutton.x;
	      ypos = event.xbutton.y;
	    }
	  button_pressed = 0;
	}
      else	/** Motion Notify **/
	{
          /* GMD 1/24/92 */
	  while ( FI_check_mask_event ( _FI_display, ButtonMotionMask,
							&event) )
	    {
	        /** Remove all from queue **/ ;
	    }
			

	   XQueryPointer ( _FI_display, window, &root, &child,
				&root_x, &root_y, &xpos, &ypos,
				&keys_buttons_mask );
	}

	/* Check to see if around the dial */

      if ( (xpos >= (xlo - dial_area)) &&
	   (xpos <= (xhi + dial_area)) &&
	   (ypos >= (ylo - dial_area)) &&
	   (ypos <= (yhi + dial_area))	)
	{
	  last_value = dial->FIgadget.value;

	  _FI_dial_find_angle_in_radians ( dial, xpos, ypos );
	}
      else
	{
	  dial->FIgadget.value = original_value;
	}

      if ( last_value != dial->FIgadget.value )
	{
	  _FI_dial_draw_new_needle ( dial, last_value,
					dial->FIgadget.value );

		/* Continuous notify */

	  if ( dial->FIrange.cont_routine )
	    {
	      dial->FIrange.cont_routine (
			dial->FIgadget.form->form_label,
			dial->FIgadget.label,
			dial->FIgadget.value,
			dial->FIgadget.form );
	    }

		/* Pass on data to directed gadget */

	  _FI_g_pass_data ((struct FIgadget_obj *)dial);

	  last_value = dial->FIgadget.value;
	}
    }

  if ( grab == GrabSuccess )
    {
      FI_ungrab_pointer ( _FI_display, CurrentTime );
    }

#if (defined(i386) || defined(sparc) || defined(sun) && defined(SYSV)) || defined(mips)
} /* end else if transition not a SINGLE_CLICK passed in */
#endif
  last_value = dial->FIgadget.value;

  _FI_snap_value ( (struct FIgadget_obj *)dial, &dial->FIgadget.value,
			(double)( dial->FIdial.scale * TWO_PI ) );

  DEBUG_PRINT ( fprintf ( stderr, "DIAL:  value (deg) = %lf\n",
                                        dial->FIgadget.value ); )

  DEBUG_PRINT ( fprintf ( stderr, "DIAL:  max_value = %lf\n",
                            (double)( dial->FIdial.scale * TWO_PI ) );)

        /**************************************  JAJ:07/01/91   ***/
        /*** "Roll over" the high value back to the low value   ***/
        /***  ( .00001 is used because a dial with high=360     ***/
        /***     thinks it's really 360.000004 )                ***/
        /**********************************************************/
  if ( ( ( (double) dial->FIdial.scale * TWO_PI ) -
                        dial->FIgadget.value )   <=   (double) 0.00001 )
    {
      DEBUG_PRINT ( fprintf ( stderr,
        "\nDIAL:  ROLL OVER (1) to low value = %5.2lf\n\n",
        dial->FIrange.low_value );)

      dial->FIgadget.value = dial->FIrange.low_value;
    }

  if ( last_value != dial->FIgadget.value )
    {
      _FI_dial_draw_new_needle ( dial, last_value,
					dial->FIgadget.value );
      _FI_g_pass_data ( (struct FIgadget_obj *)dial );
    }

  /* Turn clipping off */

  _FI_clipping_off ((struct FIgadget_obj *)dial);

  *value = dial->FIgadget.value;

  *complete = TRUE;
}



void _FI_dial_modify_radian_value (double *rad_value)
{
  while ( *rad_value < 0.0 )
    {
      *rad_value += TWO_PI;
    }

  while ( *rad_value >= TWO_PI )
    {
      *rad_value -= TWO_PI;
    }
}


void _FI_dial_find_angle_in_radians (struct FIdial_obj  *dial,
                                     int                 xpos,
                                     int                 ypos)
{
	/* Find the angle in radians */

  if ( ( dial->FIdial.center_x == xpos )	&&
       ( dial->FIdial.center_y == ypos ) 	 )
    {
	/*** If they poked in the exact center of the dial,	***/
	/*** then just return, to avoid "atan2" errors.		***/
      return ;
    }

  dial->FIdial.angle =
		atan2 ( (float) ( dial->FIdial.center_y - ypos ),
			(float) ( xpos - dial->FIdial.center_x ) );

  dial->FIgadget.value =
		    ( dial->FIdial.angle - dial->FIdial.offset )
			              * dial->FIdial.direction;

  _FI_dial_modify_radian_value ( &dial->FIgadget.value );


  DEBUG_PRINT ( fprintf ( stderr, "DIAL:  value (RAD) = %lf\n",
				dial->FIgadget.value ); )

  DEBUG_PRINT ( fprintf ( stderr, "DIAL:  dial->FIdial.scale = %f\n",
			    ( dial->FIdial.scale ) );)

	/**************************************  JAJ:07/01/91	***/
	/*** "Roll over" the high value back to the low value	***/
	/***  ( .00001 is used because a dial with high=360	***/
	/***     thinks it's really 360.000004 )		***/
	/**********************************************************/
  if ( ( TWO_PI - dial->FIgadget.value ) <= (double) 0.00001 )
    {
      DEBUG_PRINT ( fprintf ( stderr,
	"\nDIAL:  ROLL OVER to low value = %5.2lf\n\n",
	dial->FIrange.low_value );)

      dial->FIgadget.value = dial->FIrange.low_value;
    }


	/*** convert the radian value to degrees ***/

  dial->FIgadget.value *= dial->FIdial.scale ;
}



void _FI_dial_calc (struct FIdial_obj *dial)
{
  int width  = dial->FIgadget.xhi - dial->FIgadget.xlo;
  int height = dial->FIgadget.yhi - dial->FIgadget.ylo;

	/* Calculate the angle of initial value.		 */
	/* Value is initially in degrees; convert to radians.	*/

  dial->FIdial.angle = ( dial->FIgadget.value *
		(float) dial->FIdial.direction ) + dial->FIdial.offset;

	/* Calculate the needle length */

  dial->FIdial.needle_length = ( width > height ) ?
		(short) ( height / 2 ) : (short) ( width / 2 );

  dial->FIdial.tick_length = (short) ( dial->FIdial.needle_length / 8 );

  dial->FIdial.needle_length -= TOTAL_BORDER + ( 2 * NEEDLE_MARGIN ) +
					dial->FIdial.tick_length;

  dial->FIdial.center_x = dial->FIgadget.xlo + width / 2;
  dial->FIdial.center_y = dial->FIgadget.ylo + height / 2;
}


/* dmb:10/10/92:Change floats to doubles for ANSI */
int _FI_dial_adjust (struct FIdial_obj  *dial,
                     double              delta_x,
                     double              delta_y)
{
  _FI_generic_adjust ( (struct FIgadget_obj *)dial, delta_x, delta_y );

  _FI_g_change_text ( (struct FIgadget_obj *)dial, delta_y );

  _FI_dial_calc ( dial );

  return ( FI_SUCCESS );
}



int _FI_dial_activate (struct FIdial_obj *dial)
{
  _FI_g_change_text ( (struct FIgadget_obj *)dial, 1.0 );

  _FI_dial_calc ( dial );

  return ( FI_SUCCESS );
}



void _FI_dial_set_value (struct FIdial_obj  *dial,
                         double              value)
{
  Window window		= XWINDOW ( dial );
  double last_value	= dial->FIgadget.value;
  double max_value	= dial->FIdial.scale * TWO_PI;


  if ( value == dial->FIgadget.value )
    {
      return;
    }

  if ( value < 0.0 )
    {
      dial->FIgadget.value = 0.0;
    }
  else if ( value > max_value )
    {
      dial->FIgadget.value = max_value;
    }
  else
    {
      dial->FIgadget.value = value;
    }

  if (	( IT_IS_DISPLAYED(dial))	 && ( window != None )	 &&
	  dial->FIgadget.form->displayed  			  )
    {
      int erase_color;


      if ( (int) dial->FIdial.border_style == FI_DIAL_SHELF_BORDER )
	{
	  erase_color = FI_FACE;
	}
      else
	{
	  erase_color = ERASE_COLOR ( dial );
	}

      _FI_dial_draw_needle ( dial, window, last_value, erase_color,
						erase_color, 1 );

      _FI_dial_draw_ticks ( dial, window );

      _FI_dial_draw_needle ( dial, window, dial->FIgadget.value,
				FI_BLACK, OFF_COLOR(dial) , 0 );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
      if (!_FI_dont_flush)
        XFlush ( _FI_display );
    }

	/* Pass on data to directed gadget */

  _FI_g_pass_data ( (struct FIgadget_obj *)dial );
}
