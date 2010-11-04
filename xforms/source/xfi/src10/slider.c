#include "FImin.h"
#include "FIslider.h"

#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/* #define DEBUG_PRINT(x)  x  */
#define DEBUG_PRINT(x)

extern unsigned int _FI_last_button_transition;

void _FI_snap_value (struct FIgadget_obj  *gadget,
                     double               *value,
                     double                max_value)
{
  float  increment	= gadget->FIrange.increment;
  double low_value	= gadget->FIrange.low_value;

  double temp_double;
  int	 temp_int;


  DEBUG_PRINT ( fprintf ( stderr, "\n_FI_snap_value:\n"  ); )
  DEBUG_PRINT ( fprintf ( stderr,
    "low = %5.2lf, high = %5.2lf, *value = %5.2lf, inc = %5.2f\n",
    low_value, gadget->FIrange.high_value, *value, increment );  )


					/*** JAJ:07/01/91 ****/
  if (  increment <= ( (float) 0.000001 )  )
    {
      DEBUG_PRINT ( fprintf ( stderr,
			"Changing 0.00 increment to 1.00  !\n" ); )

      increment = (float) 1.0;
    }

  temp_double = (double) ( ( * value - low_value ) / increment );
  temp_int = (int) temp_double;

  if (  ( temp_double - (double) temp_int )  >= 0.5 )
    {
      temp_int ++;
    }

  * value = (double) ( ((double) temp_int) * increment ) + low_value ;

  if ( * value > max_value )
    {
      * value = max_value ;
    }

  DEBUG_PRINT ( fprintf ( stderr,
    "temp_double = %5.2lf, temp_int = %d,   FINAL *value = %5.2lf\n\n",
    temp_double, temp_int, *value );	)

} /*** void _FI_snap_value ( gadget, value, max_value ) ***/



void _FI_format_string (struct FIgadget_obj  *gadget,
                        char                 *string,
                        double                value)
{
  int xx;
  int field_width = gadget->FIrange.field_width;


  if ( value < 0.0 )
    {
      field_width++;
    }

  sprintf ( string, "%-*.*lf", field_width,
			gadget->FIrange.decimal_accuracy, value );

	/******************************************/
	/* strip spaces off the end of the string */
	/******************************************/

  for ( xx = strlen (string) - 1; ( xx > 0 ) && ( string[xx] == ' ' ) ;
								xx-- )
    {
      string[xx]= '\0';
    }
}



void _FI_sld_erase_button (struct FIsld_obj  *slider,
                           Window             window,
                           int                current_xlo,
                           int                current_ylo)
{
  int button_size   = slider->FIslider.button_size;
  int slider_width  = slider->FIgadget.xhi - slider->FIgadget.xlo;
  int slider_height = slider->FIgadget.yhi - slider->FIgadget.ylo;
  int begin;
  int slot_offset;
  int area_xlo;
  int area_ylo;
  int area_xhi;
  int area_yhi;


  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
      int current_xhi	= current_xlo + button_size;
      int last_xlo	= slider->FIslider.last_button_xlo;
      int last_xhi	= last_xlo + button_size;

      area_ylo = current_ylo;
      area_yhi = area_ylo + slider_height + 2;

      if ( last_xlo < current_xlo )
	{
	  area_xlo = last_xlo;

	  area_xhi = MIN(last_xhi, current_xlo) + 1;	/* +1 new */
	}
      else
	{
	  area_xhi = last_xhi + 1;	/* +1 new */
 
	  area_xlo = MAX(last_xlo, current_xhi);
	}
    }
  else	/** FI_VERTICAL **/
    {
      int current_yhi;
      int last_ylo = slider->FIslider.last_button_ylo;
      int last_yhi = last_ylo + button_size;

      current_ylo -= button_size;
      current_yhi = current_ylo + button_size;

      area_xlo = current_xlo;
      area_xhi = area_xlo + slider_width + 2;

      if ( last_ylo < current_ylo )
	{
	  area_ylo = last_ylo;

	  area_yhi = MIN(last_yhi, current_ylo) + 1;	/* +1 new */
	}
      else
	{
	  area_yhi = last_yhi + 1;	/* new */

	  area_ylo = MAX ( last_ylo, current_yhi );
	}
    }

	/**********************/
	/* erase the old area */
	/**********************/

  XSetForeground ( _FI_display, _FI_gc,
	FI_translate_color ( XSCREEN(slider), ERASE_COLOR(slider)) );

  XFillRectangle ( _FI_display, window, _FI_gc,
	area_xlo, area_ylo, area_xhi - area_xlo, area_yhi - area_ylo );


	/************************/
	/* Draw slot for slider */
	/************************/

  XSetForeground ( _FI_display, _FI_gc,
	_FI_g_find_contrasting_on_color ( XSCREEN(slider),
	  FI_translate_color ( XSCREEN(slider), FI_BLACK),
	  FI_translate_color (XSCREEN(slider) , ERASE_COLOR(slider))) );

  slot_offset = slider->FIslider.slot_offset;

  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
      begin = area_ylo + slot_offset;

      XFillRectangle ( _FI_display, window, _FI_gc,
			area_xlo, begin, area_xhi - area_xlo,
			SLIDER_SLOT_THICKNESS );
    }
  else
    {
      begin = area_xlo + slot_offset;

      XFillRectangle ( _FI_display, window, _FI_gc,
			begin, area_ylo,
			SLIDER_SLOT_THICKNESS, area_yhi - area_ylo );
    }

  /** X11-6/15/90-REDUNDANT because you're just         ***/
  /** going to redisplay it anyway and THEN flush *********
  XFlush ( _FI_display );
  ********************************************************/
}



void _FI_sld_display_button (struct FIsld_obj  *slider,
                             Window             window,
                             int                xpos,
                             int                ypos)
{
  int Xscreen	  = XSCREEN(slider);
  int xlo	  = slider->FIgadget.xlo;
  int ylo	  = slider->FIgadget.ylo;
  int xhi	  = slider->FIgadget.xhi;
  int yhi	  = slider->FIgadget.yhi;
  int button_size = slider->FIslider.button_size;

  int color;
  int new_x;
  int new_y;
  int dummy1, dummy2;
  int edge_color;
  int t_l_color;
  int b_r_color;
  int button_xlo;
  int button_ylo;
  int button_xhi;
  int button_yhi;
  int init_font_height;
  int init_font_width;

  double value;
  XRectangle clip_rect;

  if ( (xpos == 0) && (ypos == 0) )
    {
	return ;
    }

  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
      button_xlo = xpos;
      button_ylo = ylo;
      button_xhi = button_xlo + button_size;
      button_yhi = yhi;
    }
  else
    {
      button_xlo = xlo;
      button_yhi = ypos;
      button_ylo = button_yhi - button_size;
      button_xhi = xhi;
    }

	/*****************/
	/* save position */
	/*****************/

  slider->FIslider.last_button_xlo = button_xlo;
  slider->FIslider.last_button_ylo = button_ylo;


  if ( IT_IS_DISABLED(slider) )
    {
      t_l_color = FI_FACE;
      b_r_color = FI_FACE;
    }
  else
    {
      t_l_color = FI_GLINT;
      b_r_color = FI_SHADOW;
    }

  if ( IT_IS_HILITED(slider) )
    {
      color = FI_GLINT;
      edge_color = FI_GLINT;
    }
  else
    {
      color = OFF_COLOR(slider);
      edge_color = FI_EDGE;
    }

	/*************************/
	/* Draw button on slider */
	/*************************/

  _FI_draw_bezel ( window, button_xlo, button_ylo,
		button_xhi, button_yhi, BUTTON_BEZEL_WIDTH,
		FI_translate_color ( Xscreen, t_l_color ),
		FI_translate_color ( Xscreen, FI_FACE ),
		FI_translate_color ( Xscreen, b_r_color ),
		FI_translate_color ( Xscreen, edge_color ), CHAMFERED );


	/*********************************/
	/* Draw the number on the button */
	/*********************************/

  XSetForeground ( _FI_display, _FI_gc,
				FI_translate_color (Xscreen, color) );
  XSetBackground ( _FI_display, _FI_gc,
			   FI_translate_color ( Xscreen, FI_LT_GREY ) );

  _FI_snap_value ( (struct FIgadget_obj *) slider,
			&slider->FIgadget.value,
			slider->FIrange.high_value );

  value = slider->FIgadget.value;

  _FI_format_string ( (struct FIgadget_obj *) slider, FI_data, value );


  FI_calc_text ( slider->FIgadget.font_id, FI_data, strlen (FI_data),
		&init_font_height, &init_font_width, &dummy1,
		slider->FIgadget.font_type );

  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
      new_x = button_xlo + (button_size / 2) - (init_font_width / 2);
      new_y = button_ylo + ((yhi - ylo) / 2) - (init_font_height / 2);
    }
  else
    {
      new_x = button_xlo + ((xhi - xlo) / 2) - (init_font_width / 2);
      new_y = button_ylo + (button_size / 2) - (init_font_height / 2);
    }

  if ( DISPLAY_VALUE(slider) )
    {
      FI_draw_text ( window, slider->FIgadget.font_id,
			FI_data, strlen ( FI_data ),
			new_x, new_y, init_font_height,
			&dummy1, &dummy2, slider->FIgadget.font_type);
    }


	/**********************************************/
	/* Dither out the button ( if it's disabled ) */
	/**********************************************/

  if ( IT_IS_DISABLED(slider) )
    {
      int	offset = BUTTON_BEZEL_WIDTH + 2;
      XGCValues gc_values;
      unsigned long gc_value_mask = GCForeground | GCFillStyle |
							GCStipple;

      gc_values.stipple		= _FIpix_gray50_array [Xscreen];
      gc_values.fill_style	= FillStippled;
      gc_values.foreground	= FI_translate_color (Xscreen, FI_FACE);
      XChangeGC ( _FI_display, _FI_gc, gc_value_mask, &gc_values );

	  /***************************************************/
	  /* sml:02-19-93                                    */
	  /* change clip area to dither gadget's entire area */
	  /***************************************************/
	  clip_rect.x = button_xlo + offset;
	  clip_rect.y = button_ylo + offset;
	  clip_rect.width = button_xhi - button_xlo - offset;
 	  clip_rect.height = button_yhi - button_ylo - offset ;
	  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &clip_rect,
						 1, Unsorted );

      XFillRectangle ( _FI_display, window, _FI_gc,
			button_xlo + offset,
			button_ylo + offset,
			button_xhi - button_xlo - offset,
			button_yhi - button_ylo - offset );

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

  /** X11-6/15/90-Don't want this here because in the ..g_display **/
  /** it will cause a flush.   ************************************
  XFlush(_FI_display);
  *****************************************************************/
}



void _FI_sld_get_btn_location (struct FIsld_obj  *slider,
                               double             value,
                               int               *xpos,
                               int               *ypos)
{
  int	  low_clear 	= slider->FIslider.low_clear;
  int	  xlo 		= slider->FIgadget.xlo;
  int	  ylo 		= slider->FIgadget.ylo;
  int	  yhi 		= slider->FIgadget.yhi;
  double  low_value	= slider->FIrange.low_value;
  double  percentage;
  int	  btn_offset;	
  double  sld_range	= slider->FIrange.high_value - low_value ;

    /* Determine button location */

  
  if ( sld_range != 0.0 )
    {
      percentage = ( value - low_value ) / sld_range ;
    }
  else
    {
	/**********************************************************/
	/*** If slider goes from X to X ( range of 0 ) pretend	***/
	/*** it's at it's maximum. [ Put in for Bryan Potter. ] ***/
	/**********************************************************/

      percentage = 1.0 ;
    }

  if ( DISPLAY_MAX_MIN ( slider ) )
    {
      percentage = (double) 1.0 - percentage;
    }

  btn_offset = slider->FIrange.slot_width * percentage;


  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
	*ypos = ylo;
   	*xpos = xlo + low_clear + btn_offset;
    }
  else
    {
	*xpos = xlo;
   	*ypos = yhi - low_clear - btn_offset;
    }
}



void _FI_sld_calc_display_low_high (struct FIsld_obj  *slider,
                                    int               *display_low,
                                    int               *display_high)
{
  * display_low  = FALSE;
  * display_high = FALSE;

  if ( DISPLAY_MAX_MIN ( slider ) )
    {
	if ( DISPLAY_LOW_VALUE( slider ) )
	  {
	    * display_high = TRUE;
	  }

	if ( DISPLAY_HIGH_VALUE( slider ) )
	  {
	    * display_low  = TRUE;
	  }
    }
  else
    {
	if ( DISPLAY_LOW_VALUE( slider ) )
	  {
	    * display_low  = TRUE;
	  }

	if ( DISPLAY_HIGH_VALUE( slider ) )
	  {
	    * display_high = TRUE;
	  }
    }

} /*** _FI_sld_calc_display_low_high ( ) ***/



int _FI_sld_erase (struct FIsld_obj  *slider,
                   Window             window)
{
  int temp_xlo		= slider->FIgadget.xlo;
  int temp_ylo		= slider->FIgadget.ylo;
  int temp_xhi		= slider->FIgadget.xhi;
  int temp_yhi		= slider->FIgadget.yhi;
  int low_clear 	= slider->FIslider.low_clear;
  int high_clear	= slider->FIslider.high_clear;
  int display_low;
  int display_high;


  if ( ! _FI_is_in_clip_rectangle (& (slider->FIgadget)) )
    {
      return ( FI_SUCCESS );
    }

  _FI_sld_calc_display_low_high ( slider, & display_low,
					  & display_high );

	/**************************/
	/* Only clear area needed */
	/**************************/

  XSetForeground ( _FI_display, _FI_gc,
			FI_translate_color ( XSCREEN(slider),
						ERASE_COLOR(slider) ) );

  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
      if ( ! display_low )
	{
	  temp_xlo += low_clear;
	}

      if ( ! display_high )
	{
	  temp_xhi -= high_clear;
	}
    }
  else
    {
      if ( ! display_low )
	{
	  temp_yhi -= low_clear;
	}

      if ( ! display_high )
	{
	  temp_ylo += high_clear;
	}
    }

  XFillRectangle ( _FI_display, window, _FI_gc,
			temp_xlo, temp_ylo,
			temp_xhi - temp_xlo + 1,
			temp_yhi - temp_ylo + 1);

  return ( FI_SUCCESS );
}



int _FI_sld_display (struct FIsld_obj *slider,
                     Window            window)
{
  int xlo	= slider->FIgadget.xlo;
  int ylo	= slider->FIgadget.ylo;
  int xhi	= slider->FIgadget.xhi;
  int yhi	= slider->FIgadget.yhi;

  int slider_width	= xhi - xlo;
  int slider_height	= yhi - ylo;
  int Xscreen		= XSCREEN(slider);
  int type		= slider->FIslider.type;
  int low_clear 	= slider->FIslider.low_clear;
  int high_clear	= slider->FIslider.high_clear;
  int font_id		= slider->FIgadget.font_id;
  int font_height	= slider->FIgadget.font_height;
  int display_high;
  int display_low;

  int new_x;
  int new_y;
  int xpos;
  int ypos;
  int begin;
  int dummy1;
  int dummy2;
  int slot_offset;
  int center_offset;
  XRectangle clip_rect;

  if ( ! _FI_is_in_clip_rectangle (& (slider->FIgadget)) )
    {
      return ( FI_SUCCESS );
    }

  _FI_sld_calc_display_low_high ( slider, & display_low,
					  & display_high );

	/***************************************************/
	/* Only clear slider area that needs to be cleared */
	/***************************************************/

  _FI_sld_erase ( slider, window );


	/************************/
	/* Draw slot for slider */
	/************************/

  XSetForeground ( _FI_display, _FI_gc,
		_FI_g_find_contrasting_on_color ( Xscreen,
				FI_translate_color (Xscreen, FI_BLACK),
		FI_translate_color (Xscreen, ERASE_COLOR(slider) ) ) );


  slot_offset = slider->FIslider.slot_offset;

  if ( type == FI_HORIZONTAL )
    {
      begin = ylo + slot_offset;

      XFillRectangle ( _FI_display, window, _FI_gc,
			xlo + low_clear,
			begin,
			xhi - (xlo + low_clear) - high_clear,
			SLIDER_SLOT_THICKNESS );
    }
  else
    {
      begin = xlo + slot_offset;

      XFillRectangle ( _FI_display, window, _FI_gc,
			begin,
			ylo + high_clear,
			SLIDER_SLOT_THICKNESS,
			yhi - (ylo + high_clear) - low_clear );
    }

	/*************/
	/* Draw text */
	/*************/

  XSetForeground ( _FI_display, _FI_gc,
		FI_translate_color ( Xscreen, ON_COLOR(slider) ) );

  XSetBackground ( _FI_display, _FI_gc,
		FI_translate_color ( Xscreen, ERASE_COLOR (slider) ) );

  center_offset = ( slider_height - font_height ) / 2 ;

  if ( type == FI_HORIZONTAL )
    {
      new_y = ylo + center_offset;

      if ( display_low )
	{
	  new_x = xlo;

	  FI_draw_text ( window, font_id, slider->FIslider.low_str,
				strlen ( slider->FIslider.low_str ),
				new_x, new_y, font_height,
				&dummy1, &dummy2,
				slider->FIgadget.font_type);
	}

	/*** If the slider is reversed then displaying		***/
	/*** the HIGH_VALUE means displaying the LOW value.	***/

      if ( display_high )
	{
	  new_x = xhi - slider->FIslider.high_font_width;

	  FI_draw_text ( window, font_id, slider->FIslider.high_str,
				strlen ( slider->FIslider.high_str ),
				new_x, new_y, font_height,
				&dummy1, &dummy2,
				slider->FIgadget.font_type);
	}
    }
  else	/* VERTICAL */
    {
	/*** If the slider is reversed then displaying		***/
	/*** the LOW_VALUE means displaying the HIGH value.	***/

      if ( display_low )
	{
	  new_x = xlo + (slider_width / 2) -
			(slider->FIslider.low_font_width / 2);;

	  new_y = yhi - font_height;

	  FI_draw_text ( window, font_id, slider->FIslider.low_str,
				strlen ( slider->FIslider.low_str ),
				new_x, new_y, font_height,
				&dummy1, &dummy2,
				slider->FIgadget.font_type);
	}

      if ( display_high )
	{
	  new_x = xlo + (slider_width / 2) -
			(slider->FIslider.high_font_width / 2);;
	  new_y = ylo;

	  FI_draw_text ( window, font_id, slider->FIslider.high_str,
				strlen ( slider->FIslider.high_str ),
				new_x, new_y, font_height,
				&dummy1, &dummy2,
				slider->FIgadget.font_type);
	}
    }

	/***********************************************/
	/*** Dither out all the parts but the button ***/
	/***********************************************/

  if ( IT_IS_DISABLED(slider) )
    {
      XGCValues gc_values;
      unsigned long gc_value_mask =
				GCForeground | GCFillStyle | GCStipple;

      gc_values.stipple = _FIpix_gray12_array[
                  ((struct FIform_obj *)slider->FIgadget.form)->Xscreen];

      gc_values.fill_style = FillStippled;
      gc_values.foreground = FI_translate_color ( Xscreen,
						ERASE_COLOR(slider));

      XChangeGC (_FI_display, _FI_gc, gc_value_mask, &gc_values);

	  /***************************************************/
	  /* sml:02-22-93                                    */
	  /* change clip area to dither gadget's entire area */
	  /***************************************************/
	  clip_rect.x = slider->FIgadget.xlo;
	  clip_rect.y = slider->FIgadget.ylo;
	  clip_rect.width = slider->FIgadget.xhi - slider->FIgadget.xlo;
 	  clip_rect.height = slider->FIgadget.yhi - slider->FIgadget.ylo;
	  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &clip_rect,
						 1, Unsorted );

      XFillRectangle ( _FI_display, window, _FI_gc, xlo, ylo,
						xhi - xlo, yhi - ylo );

	 	 /***************************************************/
 		 /* sml:02-22-93                                    */
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

      XSetFillStyle (_FI_display, _FI_gc, FillSolid);
    }

  _FI_sld_get_btn_location ( slider, slider->FIgadget.value,
							&xpos, &ypos );

  _FI_sld_display_button (slider, window, xpos, ypos);

  return ( FI_SUCCESS );
}



void _FI_sld_calc (struct FIsld_obj *slider)
{
  int xlo	= slider->FIgadget.xlo;
  int ylo	= slider->FIgadget.ylo;
  int xhi	= slider->FIgadget.xhi;
  int yhi	= slider->FIgadget.yhi;

  int dummy1, dummy2;
  int font_height;

  double low_value;
  double high_value;


  if ( DISPLAY_MAX_MIN(slider) )
    {
      low_value	 = slider->FIrange.high_value;
      high_value = slider->FIrange.low_value;
    }
  else
    {
      low_value  = slider->FIrange.low_value;
      high_value = slider->FIrange.high_value;
    }

	/**************************************************/
	/* calculate the width of the low and high values */
	/**************************************************/

  _FI_format_string ( (struct FIgadget_obj *) slider,
			slider->FIslider.low_str, low_value );


  /******************************************************/
  /* This call gets the font_height of the "low str";	*/
  /* the other "high str" font height is the same.	*/
  /******************************************************/

  FI_calc_text ( slider->FIgadget.font_id, slider->FIslider.low_str,
			strlen (slider->FIslider.low_str),
			&slider->FIgadget.font_height,
			&slider->FIslider.low_font_width,
			&dummy1, slider->FIgadget.font_type);

  font_height = slider->FIgadget.font_height;

  _FI_format_string ( (struct FIgadget_obj *) slider,
			slider->FIslider.high_str, high_value );

  FI_calc_text ( slider->FIgadget.font_id, slider->FIslider.high_str,
			strlen (slider->FIslider.high_str),
			&dummy1, &slider->FIslider.high_font_width,
			&dummy2, slider->FIgadget.font_type );

  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
      int font_width;
      int low_font_width  = slider->FIslider.low_font_width;
      int high_font_width = slider->FIslider.high_font_width;

      slider->FIslider.low_clear  = low_font_width +
					SLIDER_TEXT_CLEARANCE;

      slider->FIslider.high_clear = high_font_width +
					SLIDER_TEXT_CLEARANCE;

	/*****************************/
	/* Calculate the button size */
	/*****************************/

      font_width = MAX (high_font_width, low_font_width );

      slider->FIslider.button_size = font_width +
				(2 * SLIDER_TEXT_CLEARANCE) +
				(2 * BUTTON_BEZEL_WIDTH);

      if ( slider->FIslider.button_size < SLIDER_MIN_BTN_WIDTH )
	{
	  slider->FIslider.button_size = SLIDER_MIN_BTN_WIDTH;
	}

      slider->FIrange.slot_width = xhi - xlo -
				slider->FIslider.low_clear -
				slider->FIslider.high_clear -
				slider->FIslider.button_size;

      slider->FIslider.slot_offset = ((yhi - ylo) / 2.0) -
					(SLIDER_SLOT_THICKNESS / 2);
    }
  else
    {
      slider->FIslider.low_clear  = font_height + SLIDER_TEXT_CLEARANCE;
      slider->FIslider.high_clear = font_height + SLIDER_TEXT_CLEARANCE;

	/*****************************/
	/* Calculate the button size */
	/*****************************/

      slider->FIslider.button_size = font_height +
				(2 * SLIDER_TEXT_CLEARANCE) +
				(2 * BUTTON_BEZEL_WIDTH);

      if ( slider->FIslider.button_size < SLIDER_MIN_BTN_WIDTH )
	{
	  slider->FIslider.button_size = SLIDER_MIN_BTN_WIDTH;
	}

      slider->FIrange.slot_width = yhi - ylo -
				slider->FIslider.low_clear -
				slider->FIslider.high_clear -
				slider->FIslider.button_size;

      slider->FIslider.slot_offset = ((xhi - xlo) / 2.0) -
					(SLIDER_SLOT_THICKNESS / 2);
    }

  slider->FIslider.last_button_xlo = 0;
  slider->FIslider.last_button_ylo = 0;
}




/* CHUNN there is a problem journaling sliders because they use	*/
/* mouse position instead of button data. Dials also		*/

void _FI_sld_calc_value (struct FIsld_obj  *slider,
                         int                xpos,
                         int                ypos)
{
  int xlo		= slider->FIgadget.xlo;
  int yhi		= slider->FIgadget.yhi;
  int low_clear		= slider->FIslider.low_clear;
  double low_value	= slider->FIrange.low_value;
  double high_value	= slider->FIrange.high_value;
  float range		= high_value - low_value;
  float slot_size	= slider->FIrange.slot_width;
  float percentage;


  DEBUG_PRINT ( fprintf ( stderr, "\n_FI_sld_calc_value:\n" ); )

  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
      percentage = ((float) (xpos - xlo - low_clear)) / slot_size;
    }
  else
    {
      percentage = FABS( (float)((ypos - yhi + low_clear)/ slot_size));
    }

  /******* JAJ:06/26/91 **********************/
  if ( DISPLAY_MAX_MIN ( slider ) )
    {
      percentage = (float) 1.0 - percentage;
    }
  /******* JAJ:06/26/91 **********************/

  slider->FIgadget.value = low_value + range * percentage;

  DEBUG_PRINT ( fprintf ( stderr,
        "low = %5.2lf, high = %5.2lf, %% = %5.2f, value = %5.2lf\n",
        low_value, high_value, percentage, slider->FIgadget.value ); )

	/*******************************/
	/* Make sure value is in range */
	/*******************************/

  if ( slider->FIgadget.value > high_value )
    {
      slider->FIgadget.value = high_value;
    }
  else if ( slider->FIgadget.value < low_value )
    {
      slider->FIgadget.value = low_value;
    }

}  /*** void _FI_sld_calc_value ( )  ***/



void _FI_sld_adjust_location (struct FIsld_obj  *slider,
                              int               *xpos,
                              int               *ypos)
{
  int	xlo		= slider->FIgadget.xlo;
  int	ylo		= slider->FIgadget.ylo;
  int	xhi		= slider->FIgadget.xhi;
  int	yhi		= slider->FIgadget.yhi;
  int	low_clear	= slider->FIslider.low_clear;
  int	high_clear	= slider->FIslider.high_clear;
  int	button_size	= slider->FIslider.button_size;
  int	half_button	= button_size / 2;
  int	low;
  int	high;


  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
      low  = xlo + low_clear;
      high = xhi - high_clear - button_size;

      *ypos = ylo;
      *xpos -= half_button;

      if ( *xpos < low )
        {
	  *xpos = low;
        }
      else if ( *xpos > high )
        {
	  *xpos = xhi - high_clear - button_size;
        }

    }
  else	/* VERTICAL */
    {
      low  = yhi - low_clear;
      high = ylo + high_clear + button_size;

      *xpos = xlo;
      *ypos += half_button;

      if ( *ypos < high )
	{
	  *ypos = high;
	}
      else if (*ypos > low)
	{
	  *ypos = low;
	}
    }
}



void _FI_sld_track_mouse (struct FIsld_obj  *slider,
                          Window             window,
                          int                xpos,
                          int                ypos,
                          int               *complete,
                          double            *value)
{
  int	xlo		= slider->FIgadget.xlo;
  int	ylo		= slider->FIgadget.ylo;
  int	xhi		= slider->FIgadget.xhi;
  int	yhi		= slider->FIgadget.yhi;
  int	type		= slider->FIslider.type;
  int	first_time_out	= TRUE;
  int	last_xpos	= slider->FIslider.last_button_xlo;
  int	last_ypos	= slider->FIslider.last_button_ylo;

  double old_value	= slider->FIgadget.value;
  double current_value	= old_value;

  int	slider_x_area;
  int	slider_y_area;
  int	button_pressed;
  int	grab;
  double return_value;
  double saved_value;


	/********************************************************/
	/* Calculate the area around the slider, which the user */
	/* can poke in and still control the slider.		*/
	/********************************************************/

  if ( type == FI_HORIZONTAL )
    {
      slider_x_area = (xhi - xlo) / 4;
      slider_y_area = (yhi - ylo);
    }
  else
    {
      slider_x_area = (xhi - xlo);
      slider_y_area = (yhi - ylo) / 4;
    }

#if (defined(i386) || defined(sparc) || defined(sun) && defined(SYSV)) || defined(mips)
  /*************************************************************/
  /* sml:02-04-94:TR 249400xxx                                 */
  /*  Check if the button press and release have been eaten by */
  /*  EXNUC.  If so, don't look for a release now.             */
  /*************************************************************/
  if (_FI_last_button_transition == SINGLE_CLICK)
  {
    button_pressed = 0;
    _FI_last_button_transition = 0;
    _FI_sld_adjust_location ( slider, &xpos, &ypos ); 
    _FI_sld_calc_value ( slider, xpos, ypos );
    _FI_sld_erase_button ( slider, window, xlo, ylo );
    XFlush(_FI_display);
  }
else
  {
#endif
  grab = FI_grab_pointer ( _FI_display, window, True,
	      (unsigned int) (ButtonMotionMask | PointerMotionHintMask),
		GrabModeAsync, GrabModeAsync,
		window, None, CurrentTime );

  button_pressed = (grab == GrabSuccess);

  while ( button_pressed )
    {
      XEvent	   event;
      Window	   root, child;
      int	   root_x, root_y;
      unsigned int keys_buttons_mask;

      /* GMD 1/24/92 */
      FI_mask_event ( _FI_display,
			ButtonPressMask | ButtonReleaseMask |
			ButtonMotionMask | PointerMotionHintMask,
			&event);

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
	        /** Remove all from queue **/
	    }

	  FI_query_pointer ( _FI_display, window, &root, &child,
				&root_x, &root_y, &xpos, &ypos,
				&keys_buttons_mask );
	}

	/************************************************/
	/* Set the value based on the UP location	*/
	/* But only if the button position is in	*/
	/* the valid area. GMD 11/28/90			*/
	/************************************************/

      if ( (xpos >= (xlo - slider_x_area))	&&
	   (xpos <= (xhi + slider_x_area))	&&
	   (ypos >= (ylo - slider_y_area))	&&
	   (ypos <= (yhi + slider_y_area))	 )
	{
	  first_time_out = TRUE;

	  if ( type == FI_HORIZONTAL )
	    {
	      if ((xpos == last_xpos) || (xpos >= xhi) || (xpos <= xlo))
		{
		  continue;
		}
	    }
	  else	/** type == FI_VERTICAL **/
	    {
	      if ((ypos == last_ypos) || (ypos >= yhi) || (ypos <= ylo))
		{
		  continue;
		}
	    }

	  last_xpos = xpos;
	  last_ypos = ypos;


                 /******************************/
		/* Adjust the button location */
		/******************************/

	  _FI_sld_adjust_location ( slider, &xpos, &ypos );


		/***************************/
		/* Calculate the new value */
		/***************************/


	  _FI_sld_calc_value ( slider, xpos, ypos );


		/*******************************************/
		/* Erase old button and display new button */
		/*******************************************/

	  _FI_sld_erase_button ( slider, window, xpos, ypos );

	  _FI_sld_display_button ( slider, window, xpos, ypos );

	  XFlush (_FI_display);
	}
      else
	{
	  if ( first_time_out )
	    {
		/************************************************/
		/* Reset, because user poked outside of 	*/
		/* slider's active mouse cursor tracking area.	*/
		/************************************************/

	      slider->FIgadget.value = old_value;

	      _FI_sld_display ( slider, window );

	      XFlush (_FI_display);

	      first_time_out = FALSE;
	    }
	}

      _FI_snap_value ( (struct FIgadget_obj *) slider,
				&slider->FIgadget.value,
				 slider->FIrange.high_value );

      _FI_format_string ( (struct FIgadget_obj *) slider,
				FI_data, slider->FIgadget.value );

      return_value = atof ( FI_data );

      if ( return_value != current_value )
	{
		/****************************************/
		/* Call continuous notification routine */
		/****************************************/

		/*****************************/
		/* Modify value before calls */
		/*****************************/

	  saved_value = slider->FIgadget.value;

	  if ( slider->FIrange.cont_routine )
	    {
	      slider->FIrange.cont_routine (
				slider->FIgadget.form->form_label,
				slider->FIgadget.label,
				return_value,
				slider->FIgadget.form );
	     }

		/***********************************/
		/* Pass on data to directed gadget */
		/***********************************/

	  _FI_g_pass_data ((struct FIgadget_obj *)slider);

		/*********************/
		/* Change value back */
		/*********************/

	  slider->FIgadget.value = saved_value;
	}

      current_value = return_value;

    }	/** END while(button_pressed) **/

  if ( grab == GrabSuccess )
    {
      FI_ungrab_pointer ( _FI_display, CurrentTime );
    }


	/************************/
	/* Snap button to value */
	/************************/

  _FI_sld_get_btn_location ( slider, slider->FIgadget.value,
						&xpos, &ypos );

  _FI_sld_erase_button ( slider, window, xpos, ypos );

#if (defined(i386) || defined(sparc) || defined(sun) && defined(SYSV)) || defined(mips)
} /* end else if trans not SINGLE_CLICK */
#endif
  DEBUG_PRINT ( fprintf ( stderr,
   "_FI_sld_track_mouse (after event loop): btn xpos = %d, ypos = %d\n",
	xpos, ypos );)

  _FI_sld_display_button ( slider, window, xpos, ypos );

  XFlush (_FI_display);

	/**************/
	/* save value */
	/**************/

  saved_value = slider->FIgadget.value;


	/***********************************/
	/* Pass on data to directed gadget */
	/***********************************/

  _FI_format_string ( (struct FIgadget_obj *) slider,
				FI_data, slider->FIgadget.value );

  *value = atof ( FI_data );

  _FI_g_pass_data ( (struct FIgadget_obj *)slider );


	/*********************/
	/* Change value back */
	/*********************/

  slider->FIgadget.value = saved_value;

  *complete = TRUE;

} /*** void _FI_sld_track_mouse ( ) ***/


/* dmb:10/10/92:Change floats to doubles for ANSI */
int _FI_sld_adjust (struct FIsld_obj *slider,
                    double            delta_x,
                    double            delta_y)
{
  _FI_generic_adjust ( (struct FIgadget_obj *)slider, delta_x, delta_y );

  _FI_g_change_text ( (struct FIgadget_obj *)slider, delta_y );

  _FI_sld_calc ( slider );

  return ( FI_SUCCESS );
}



int _FI_sld_activate (struct FIsld_obj *slider)
{
  _FI_g_change_text ( (struct FIgadget_obj *)slider, 1.0 );

  _FI_sld_calc ( slider );

  return ( FI_SUCCESS );
}



void _FI_sld_set_value (struct FIsld_obj  *slider,
                        double             value)
{
  Window window = XWINDOW(slider);
  int	 x, y;

	/*********************************/
	/* If the same value then return */
	/*********************************/

  if ( value == slider->FIgadget.value )
    {
      return;
    }

	/********************/
	/* format the value */
	/********************/

  _FI_format_string ( (struct FIgadget_obj *) slider, FI_data, value );

  value = atof ( FI_data );

  if ( value > slider->FIrange.high_value )
    {
      slider->FIgadget.value = slider->FIrange.high_value;
    }
  else if ( value < slider->FIrange.low_value )
    {
      slider->FIgadget.value = slider->FIrange.low_value;
    }
  else
    {
      slider->FIgadget.value = value;
    }


  if (	( IT_IS_DISPLAYED(slider) )		&&
	  slider->FIgadget.form->displayed	&&
	( window != None )			 )
    {
      _FI_sld_get_btn_location ( slider, slider->FIgadget.value,
							&x, &y );

      _FI_sld_erase_button ( slider, window, x, y );

      _FI_sld_display_button ( slider, window, x, y );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
      if (!_FI_dont_flush)
        XFlush ( _FI_display );
    }

	/***********************************/
	/* Pass on data to directed gadget */
	/***********************************/

  _FI_g_pass_data ( (struct FIgadget_obj *)slider );
}
