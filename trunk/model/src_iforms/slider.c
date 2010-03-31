#include "FImin.h"
#include "FIslider.h"

#include <stdio.h>

/* #define DEBUG_PRINT(x)  x  */
#define DEBUG_PRINT(x)


void _FI_snap_value ( gadget, value, max_value )
  struct FIgadget_obj * gadget;
  double	      * value;
  double		max_value;
{
  float  increment	= gadget->FIrange.increment;
  double low_value	= gadget->FIrange.low_value;

  double temp_double;
  int	 temp_int;


  DEBUG_PRINT ( fprintf ( stderr, "\n_FI_snap_value:\n"  ); )
  DEBUG_PRINT ( fprintf ( stderr,
    "low = %5.2lf, high = %5.2lf, *value = %5.2lf, inc = %5.2f\n",
    low_value, gadget->FIrange.high_value, *value, increment );  )


  /*********************** JAJ:07/01/91 ****/
  if (  increment <= ( (float) 0.000001 )  )
    {
      DEBUG_PRINT ( fprintf ( stderr,
			"Changing 0.00 increment to 1.00  !\n" ); )

      /*increment = (float) 1.0;*/
      increment = (float) 0.000001;
    }

  temp_double = (double) ( ( * value - low_value ) / increment );
  temp_int = (int) temp_double;

  if (  ( temp_double - (double) temp_int )  >= 0.5 )
    {
      temp_int ++;
    }

  /************************************************/
  /* sml:12-20-93:TR 249305768                    */
  /* Slider value changes sign when slider value  */
  /* is very large ( > 21,000) and increment is   */
  /* very small.                                  */
  /* This is a precision problem between doubles  */
  /* and ints.  When you have 21999.99999/.00001, */
  /* it's OK as a double but becomes negative as  */
  /* an int.                                      */
  /************************************************/

  /* if temp_int and temp_double not nearly the same, sign changed */
  if (ABS(temp_double - temp_int) > 1)
  {
	/* use temp_double */
	* value = (double) ( ((double) temp_double) * increment ) + low_value ;
  }
  else /* sign hasn't changed, so use temp_int */
  {
	* value = (double) ( ((double) temp_int) * increment ) + low_value ;
  }

  if ( * value > max_value )
    {
      * value = max_value ;
    }

  DEBUG_PRINT ( fprintf ( stderr,
    "temp_double = %5.2lf, temp_int = %d,   FINAL *value = %5.2lf\n\n",
    temp_double, temp_int, *value );	)

} /*** void _FI_snap_value ( gadget, value, max_value ) ***/



void _FI_format_string ( gadget, string, value )
  struct FIgadget_obj * gadget;
  char * string;
  double value;
{
  int xx;
  int field_width = gadget->FIrange.field_width;

  if ( value < 0.0 )
    {
      field_width++;
    }

  sprintf( string, "%-*.*lf", field_width,
			gadget->FIrange.decimal_accuracy, value );

  xx = strlen ( string ) - 1;

  if ( string[xx] == ' ' )
    {
	for ( ;; )
	  {
		string[xx--] = NULL;
		if ( string[xx] != ' ' )
		  break;
	  }
    }
}



void _FI_sld_erase_button ( slider, window, current_xlo, current_ylo )
  struct FIsld_obj * slider;
  int    window;
  int    current_xlo;
  int    current_ylo;
{
  int button_size   = slider->FIslider.button_size;
  int slider_width  = slider->FIgadget.xhi - slider->FIgadget.xlo;
  int slider_height = slider->FIgadget.yhi - slider->FIgadget.ylo;
  int  vs 	    = (int)VS_NO ( slider );

  int begin;
  int slot_offset;
  int area_xlo;
  int area_ylo;
  int area_xhi;
  int area_yhi;


  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
        int current_xhi   = current_xlo + button_size;
        int last_xlo      = slider->FIslider.last_button_xlo;
        int last_xhi      = last_xlo + button_size;

 	area_ylo = current_ylo;
	area_yhi = area_ylo + slider_height;

	if ( last_xlo < current_xlo )
	  {
		area_xlo = last_xlo;

		area_xhi = MIN ( last_xhi, current_xlo );
	  }
	else
	  {
		area_xhi = last_xhi;

		area_xlo = MAX ( last_xlo, current_xhi );
	  }

	area_yhi++;
    }
  else
    {
	int current_yhi;

        int last_ylo     = slider->FIslider.last_button_ylo;
        int last_yhi     = last_ylo + button_size;

	current_ylo -= button_size;
	current_yhi  = current_ylo + button_size;

 	area_xlo = current_xlo;
	area_xhi = area_xlo + slider_width;

	if ( last_ylo < current_ylo )
	  {
		area_ylo = last_ylo;

		area_yhi = MIN ( last_yhi, current_ylo );
	  }
	else
	  {
		area_yhi = last_yhi;

		area_ylo = MAX ( last_ylo, current_yhi );
	  }

	area_xhi++;
    }

	/**********************/
	/* erase the old area */
	/**********************/

  fgcolor ( window, FI_translate_color ( vs, ERASE_COLOR ( slider ) ) );

  hidecursor ( window );

  rectf ( window, area_xlo, area_ylo, area_xhi, area_yhi );


	/************************/
	/* Draw slot for slider */
	/************************/

  fgcolor ( window, _FI_g_find_contrasting_on_color ( vs,
		    FI_translate_color ( vs, FI_BLACK ),
		    FI_translate_color ( vs, ERASE_COLOR(slider) ) ) );

  slot_offset = slider->FIslider.slot_offset;

  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
	begin = area_ylo + slot_offset;

    	rectf ( window, area_xlo, begin, area_xhi,
					begin + SLIDER_SLOT_THICKNESS );
    }
  else
    {
	begin = area_xlo + slot_offset;

	rectf ( window, begin, area_ylo, begin + SLIDER_SLOT_THICKNESS,
							area_yhi );
    }

  showcursor ( window );
  flushbuffer ( window );
}



/**************************************************************
double _FI_sld_get_inverse ( slider, value )
  struct FIsld_obj * slider;
  double value;
{
  return ( slider->FIrange.high_value	- value	+
				slider->FIrange.low_value );
}
**************************************************************/



void _FI_sld_display_button ( slider, window, xpos, ypos )
  struct FIsld_obj * slider;
  int    window;
  int    xpos;
  int    ypos;
{
  int  vs 		= (int)VS_NO ( slider );
  int  xlo 		= slider->FIgadget.xlo;
  int  ylo 		= slider->FIgadget.ylo;
  int  xhi 		= slider->FIgadget.xhi;
  int  yhi 		= slider->FIgadget.yhi;
  int  button_size 	= slider->FIslider.button_size;

  int  color;
  int  new_x;
  int  new_y;
  int  dummy1, dummy2;
  int  edge_color;
  int  t_l_color;
  int  b_r_color;
  int  button_xlo;
  int  button_ylo;
  int  button_xhi;
  int  button_yhi;
  int  init_font_height;
  int  init_font_width;

  double value;


  if ( ( xpos == 0 ) && ( ypos == 0 ) )
    {
	return;
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

    /* save position */

  slider->FIslider.last_button_xlo = button_xlo;
  slider->FIslider.last_button_ylo = button_ylo;


  if ( IT_IS_DISABLED ( slider ) )
    {
	t_l_color = FI_FACE;
        b_r_color = FI_FACE;
    }
  else
    {
        t_l_color = FI_GLINT;
        b_r_color = FI_SHADOW;
    }

  if ( IT_IS_HILITED ( slider ) )
    {
	color 	   = FI_GLINT;
    	edge_color = FI_GLINT;
    }
  else
    {
	color 	   = OFF_COLOR ( slider );
        edge_color = FI_EDGE;
    }

  hidecursor ( window );

    /* Draw button on slider */

  _FI_draw_bezel ( window, button_xlo, button_ylo, button_xhi,
    		     button_yhi, BUTTON_BEZEL_WIDTH,
	             FI_translate_color ( vs, t_l_color ),
	             FI_translate_color ( vs, FI_FACE ),
	             FI_translate_color ( vs, b_r_color ),
	             FI_translate_color ( vs, edge_color ), CHAMFERED );


    /* Draw the number on the button */

  fgcolor ( window, FI_translate_color ( vs, color ) );

  _FI_snap_value ( (struct FIgadget_obj *) slider,
			 &slider->FIgadget.value,
			 slider->FIrange.high_value );

/**************************************
  if ( DISPLAY_MAX_MIN( slider ) )
    {
	/ * Take the inverse of value * /

      value = _FI_sld_get_inverse ( slider, slider->FIgadget.value );
    }
  else
    {
*****************************************/

      value = slider->FIgadget.value ;

/*****
    }
*****/

  _FI_format_string ( (struct FIgadget_obj *) slider, FI_data, value );

/* CHUNN NEW FONT */

  FI_calc_text ( slider->FIgadget.font_id, FI_data,
		strlen( FI_data ), &init_font_height,
		&init_font_width, &dummy1, slider->FIgadget.font_type );

  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
        new_x  = button_xlo + ( button_size / 2 )
					  - ( init_font_width  / 2 );

        new_y  = button_ylo + ( ( yhi - ylo ) / 2 )
					  - ( init_font_height / 2 );
    }
  else
    {
        new_x  = button_xlo + ( ( xhi - xlo ) /  2 )
					  - ( init_font_width  / 2 );

        new_y  = button_ylo + ( button_size / 2 )
					  - ( init_font_height / 2 );
    }

  if ( DISPLAY_VALUE ( slider ) )
    {
      FI_draw_text ( window, slider->FIgadget.font_id,
	  	         FI_data, strlen( FI_data ),
	  	         new_x, new_y, init_font_height,
	  	         &dummy1, &dummy2, slider->FIgadget.font_type );
    }

    /* Dither out the button */

  if ( IT_IS_DISABLED ( slider ) )
    {
	int offset = BUTTON_BEZEL_WIDTH + 2;

        pushattributes ( window );

	fgcolor ( window, FI_translate_color ( vs, FI_FACE ) );
   	texture ( window, _FIgray50 );
	rectf   ( window, button_xlo + offset, button_ylo + offset,
			  button_xhi - offset, button_yhi - offset );

        popattributes ( window );
    }

  showcursor ( window );
  flushbuffer ( window );

} /*** void _FI_sld_display_button ( )  ***/



void _FI_sld_get_btn_location ( slider, value, xpos, ypos )
  struct FIsld_obj * slider;
  double  value;
  int    * xpos;
  int    * ypos;
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
      percentage = 1.0 ;
    }

/******* JAJ:06/26/91 **********************/
  if ( DISPLAY_MAX_MIN ( slider ) )
    {
      percentage = (double) 1.0 - percentage;
    }
/******* JAJ:06/26/91 **********************/


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


void _FI_sld_calc_display_low_high ( slider, display_low, display_high )
  struct FIsld_obj * slider;
  int 		   * display_low;
  int 		   * display_high;
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



int _FI_sld_erase( slider, window )
  struct FIsld_obj * slider;
  int    window;
{
  int  xlo	= slider->FIgadget.xlo;
  int  ylo	= slider->FIgadget.ylo;
  int  xhi	= slider->FIgadget.xhi;
  int  yhi 	= slider->FIgadget.yhi;

  int  temp_xlo 	= xlo;
  int  temp_xhi 	= xhi;
  int  temp_ylo 	= ylo;
  int  temp_yhi 	= yhi;
  int  vs 		= (int)VS_NO ( slider );
  int  type 		= slider->FIslider.type;
  int  low_clear 	= slider->FIslider.low_clear;
  int  high_clear 	= slider->FIslider.high_clear;
  int  display_high;
  int  display_low;


  if ( IT_IS_NOT_DISPLAYABLE ( slider ) )
    {
      return ( FI_SUCCESS );
    }

  _FI_sld_calc_display_low_high ( slider,
					& display_low, & display_high );

    /* Only clear area needed */

  fgcolor ( window, FI_translate_color ( vs, ERASE_COLOR (slider) ) );

  if ( type == FI_HORIZONTAL )
    {
	if ( ! ( display_low ) )
	  temp_xlo += low_clear;

	if ( ! ( display_high ) )
	  temp_xhi -= high_clear;
    }
  else
    {
	if ( ! ( display_low ) )
	  temp_yhi -= low_clear;

	if ( ! ( display_high ) )
	  temp_ylo += high_clear;
    }

  rectf ( window, temp_xlo, temp_ylo, temp_xhi, temp_yhi );

  return ( FI_SUCCESS );

} /*** _FI_sld_erase () ***/



int _FI_sld_display ( slider, window )
  struct FIsld_obj * slider;
  int    window;
{
  int  xlo	= slider->FIgadget.xlo;
  int  ylo	= slider->FIgadget.ylo;
  int  xhi	= slider->FIgadget.xhi;
  int  yhi 	= slider->FIgadget.yhi;

  int  slider_width  	= xhi - xlo;
  int  slider_height 	= yhi - ylo;
  int  vs 		= (int)VS_NO ( slider );
  int  type 		= slider->FIslider.type;
  int  low_clear 	= slider->FIslider.low_clear;
  int  high_clear 	= slider->FIslider.high_clear;
  int  font_id   	= slider->FIgadget.font_id;
  int  font_height 	= slider->FIgadget.font_height;
  int  display_high;
  int  display_low;

  int  new_x;
  int  new_y;
  int  xpos;
  int  ypos;
  int  begin;
  int  dummy1, dummy2;
  int  slot_offset;
  int  center_offset;

  _FI_sld_calc_display_low_high ( slider,
				& display_low, & display_high );

	/**************************/
	/* Only clear area needed */
	/**************************/
  _FI_sld_erase ( slider, window );

	/************************/
	/* Draw slot for slider */
	/************************/

  fgcolor ( window, _FI_g_find_contrasting_on_color ( vs,
		    FI_translate_color ( vs, FI_BLACK ),
		    FI_translate_color ( vs, ERASE_COLOR(slider) ) ) );

  slot_offset = slider->FIslider.slot_offset;

  if ( type == FI_HORIZONTAL )
    {
	begin = ylo + slot_offset;

    	rectf ( window, xlo + low_clear,  begin,
		xhi - high_clear, begin + SLIDER_SLOT_THICKNESS );
    }
  else
    {
	begin = xlo + slot_offset;

	rectf ( window, begin, ylo + high_clear,
	        begin + SLIDER_SLOT_THICKNESS, yhi - low_clear );
    }

    /* Draw text */

  fgcolor ( window, FI_translate_color ( vs, ON_COLOR ( slider ) ) );

  center_offset = ( slider_height / 2 ) - ( font_height / 2 );

  if ( type == FI_HORIZONTAL )
    {
       new_y = ylo + center_offset;

       if ( display_low )
         {
	    new_x = xlo;

	    FI_draw_text ( window, font_id, slider->FIslider.low_str,
	  	          strlen(slider->FIslider.low_str),
	  	          new_x, new_y, font_height, &dummy1, &dummy2,
			  slider->FIgadget.font_type );
         }

	/*** If the slider is reversed, then displaying	***/
	/*** the HIGH_VALUE means displaying the LOW	***/

       if ( display_high )
         {
	    new_x  = xhi - slider->FIslider.high_font_width;

	    FI_draw_text ( window, font_id, slider->FIslider.high_str,
	  	          strlen(slider->FIslider.high_str),
	  	          new_x, new_y, font_height, &dummy1, &dummy2,
			  slider->FIgadget.font_type );
         }
    }
  else		/* VERTICAL */
    {
       /* If the slider is reversed then displaying the LOW_VALUE
    	  means displaying the HIGH */

       if ( display_low )
         {
	    new_x = xlo + ( slider_width / 2 )
			   - ( slider->FIslider.low_font_width / 2 );

	    new_y = yhi - font_height;

	    FI_draw_text ( window, font_id, slider->FIslider.low_str,
	  	          strlen(slider->FIslider.low_str),
	  	          new_x, new_y, font_height, &dummy1, &dummy2,
			  slider->FIgadget.font_type );
         }

       if ( display_high )
         {
	    new_x = xlo + ( slider_width / 2 )
			- ( slider->FIslider.high_font_width / 2 );

	    new_y = ylo;

	    FI_draw_text ( window, font_id, slider->FIslider.high_str,
	  	          strlen(slider->FIslider.high_str),
	  	          new_x, new_y, font_height, &dummy1, &dummy2,
			  slider->FIgadget.font_type );
         }
    }

    /* Dither out all the parts but the button */

  if ( IT_IS_DISABLED ( slider ) )
    {
        pushattributes ( window );

	fgcolor ( window, FI_translate_color ( vs,
					ERASE_COLOR ( slider ) ) );

   	texture ( window, _FIgray12 );
	rectf   ( window, xlo, ylo, xhi, yhi );

        popattributes ( window );
    }

  _FI_sld_get_btn_location ( slider, slider->FIgadget.value,
						&xpos, &ypos );

  _FI_sld_display_button ( slider, window, xpos, ypos );

  return ( FI_SUCCESS );
}



void _FI_sld_calc ( slider )
  struct FIsld_obj * slider;
{
  int xlo 	       = slider->FIgadget.xlo;
  int ylo 	       = slider->FIgadget.ylo;
  int xhi 	       = slider->FIgadget.xhi;
  int yhi	       = slider->FIgadget.yhi;

  int dummy1, dummy2;
  int font_height;

  double  low_value;
  double  high_value;

  if ( DISPLAY_MAX_MIN ( slider ) )
    {
	low_value  = slider->FIrange.high_value;
	high_value = slider->FIrange.low_value;
    }
  else
    {
	low_value  = slider->FIrange.low_value;
	high_value = slider->FIrange.high_value;
    }

    /* calculate the width of the low and high values */

  _FI_format_string ( (struct FIgadget_obj *) slider,
			slider->FIslider.low_str, low_value );

    /* This call get the font_height and the other don't need to  */

/* CHUNN NEW FONT */

  FI_calc_text ( slider->FIgadget.font_id, slider->FIslider.low_str,
    			 strlen( slider->FIslider.low_str),
		         &slider->FIgadget.font_height,
			 &slider->FIslider.low_font_width, &dummy1,
			  slider->FIgadget.font_type );

  font_height = slider->FIgadget.font_height;

  _FI_format_string ( (struct FIgadget_obj *) slider,
				slider->FIslider.high_str, high_value );

  FI_calc_text ( slider->FIgadget.font_id, slider->FIslider.high_str,
 		     strlen( slider->FIslider.high_str),
		    &dummy1, &slider->FIslider.high_font_width, &dummy2,
		     slider->FIgadget.font_type );

  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
      int font_width;
      int low_font_width  = slider->FIslider.low_font_width;
      int high_font_width = slider->FIslider.high_font_width;

      slider->FIslider.low_clear  = low_font_width  +
					SLIDER_TEXT_CLEARANCE;

      slider->FIslider.high_clear = high_font_width +
					SLIDER_TEXT_CLEARANCE;

       /* Calculate the button size */

      font_width = MAX ( high_font_width, low_font_width );

      slider->FIslider.button_size = font_width +
				( 2 * SLIDER_TEXT_CLEARANCE ) +
				( 2 * BUTTON_BEZEL_WIDTH );

      if ( slider->FIslider.button_size < SLIDER_MIN_BTN_WIDTH )
	{
   	  slider->FIslider.button_size = SLIDER_MIN_BTN_WIDTH;
	}

      slider->FIrange.slot_width = xhi - xlo -
				slider->FIslider.low_clear -
				slider->FIslider.high_clear -
				slider->FIslider.button_size;

      slider->FIslider.slot_offset = ( ( yhi - ylo ) / 2.0 ) -
					 ( SLIDER_SLOT_THICKNESS / 2 );
    }
  else
    {
      slider->FIslider.low_clear  = font_height +
					SLIDER_TEXT_CLEARANCE;

      slider->FIslider.high_clear = font_height +
					SLIDER_TEXT_CLEARANCE;

       /* Calculate the button size */

      slider->FIslider.button_size = font_height +
				( 2 * SLIDER_TEXT_CLEARANCE ) +
				( 2 * BUTTON_BEZEL_WIDTH );

      if ( slider->FIslider.button_size < SLIDER_MIN_BTN_WIDTH )
	{
   	  slider->FIslider.button_size = SLIDER_MIN_BTN_WIDTH;
	}

      slider->FIrange.slot_width = yhi - ylo -
			slider->FIslider.low_clear -
			slider->FIslider.high_clear -
			slider->FIslider.button_size;

      slider->FIslider.slot_offset = ( ( xhi - xlo) / 2.0 ) -
					( SLIDER_SLOT_THICKNESS / 2 );
    }

  slider->FIslider.last_button_xlo = 0;
  slider->FIslider.last_button_ylo = 0;
}




/* CHUNN there is a problem journaling sliders because they use
   mouse position instead of button data.  Dials also */

void _FI_sld_calc_value ( slider, xpos, ypos )
  struct FIsld_obj * slider;
  int    xpos;
  int    ypos;
{
  int   xlo 		= slider->FIgadget.xlo;
  int   yhi 		= slider->FIgadget.yhi;

  int   low_clear	= slider->FIslider.low_clear;

  double low_value 	= slider->FIrange.low_value;
  double high_value 	= slider->FIrange.high_value;

  float range		= high_value - low_value;
  float slot_size 	= slider->FIrange.slot_width;

  float percentage;

  DEBUG_PRINT ( fprintf ( stderr, "\n_FI_sld_calc_value:\n" ); )

  if ( slider->FIslider.type == FI_HORIZONTAL )
    {
      percentage = ( (float)(xpos - xlo - low_clear) ) / slot_size;
    }
  else
    {
      percentage = FABS( (float)(( ypos - yhi + low_clear ) / slot_size ) );
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

	/* Make sure value is in range */

  if ( slider->FIgadget.value > high_value )
    {
      slider->FIgadget.value = high_value;
    }
  else if ( slider->FIgadget.value < low_value )
    {
      slider->FIgadget.value = low_value;
    }

} /*** void _FI_sld_calc_value ( )  ***/



void _FI_sld_adjust_location ( slider, xpos, ypos )
  struct FIsld_obj * slider;
  int    *xpos;
  int    *ypos;
{
  int   xlo 		= slider->FIgadget.xlo;
  int   ylo 		= slider->FIgadget.ylo;
  int   xhi 		= slider->FIgadget.xhi;
  int   yhi 		= slider->FIgadget.yhi;

  int   low_clear	= slider->FIslider.low_clear;
  int   high_clear	= slider->FIslider.high_clear;
  int   button_size 	= slider->FIslider.button_size;
  int   half_button 	= button_size / 2;

  int   low;
  int   high;

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
  else		/* VERTICAL */
    {
	low  = yhi - low_clear;
	high = ylo + high_clear + button_size;

	*xpos = xlo;
	*ypos += half_button;

	if ( *ypos < high )
	  {
		*ypos = high;
	  }
	else if ( *ypos > low )

	  {
		*ypos = low;
	  }
    }
}



void _FI_sld_track_mouse ( slider, window, xpos, ypos, trans,
						complete, value )
  struct FIsld_obj * slider;
  int		 window;
  int		 xpos;
  int		 ypos;
  int		 trans;
  int		*complete;
  double	*value;
{
  double saved_value;

  int   xlo 		= slider->FIgadget.xlo;
  int   ylo 		= slider->FIgadget.ylo;
  int   xhi 		= slider->FIgadget.xhi;
  int   yhi 		= slider->FIgadget.yhi;
  int   type 		= slider->FIslider.type;
  int   first_time_out 	= TRUE;
  int   last_xpos 	= 0;
  int   last_ypos 	= 0;

  double old_value 	= slider->FIgadget.value;
  double current_value 	= old_value;

  int   work_status;
  int   slider_x_area;
  int   slider_y_area;
  int   transition;

  long  event;

  double return_value;


  /*******************************************************/
  /* sml:TR 249305898:double click on slider causes hang */
  /*  filter out all events but DOWN and SINGLE_CLICK    */
  /*******************************************************/
  if (trans != SINGLE_CLICK && trans != DOWN)
  {
	trans = SINGLE_CLICK;
  }


	/* Calculate the area around the slider */

  if ( type == FI_HORIZONTAL )
    {
	slider_x_area = ( xhi - xlo ) / 4;
	slider_y_area = ( yhi - ylo );
    }
  else
    {
	slider_x_area = ( xhi - xlo );
	slider_y_area = ( yhi - ylo ) / 4;
    }


  for ( ;; )
    {
      Inq_events ( &event );

        /* If the up button was incountered then exit */

      if ( event & BUTTON_EVENT )
	{
	  int button, ttag;

/*
 *  rather than inquiring the button data, which does not remove the
 *  event from the queue, get the button data, which DOES remove the
 *  event from the queue and process the data if it is a Button UP.
 *  If any other event was getting into the queue, like and UP_DOWN_UP
 *  we hung in an infinite loop because it never got popped off and
 *  that's all we would see, forever.  Mike Lanier 8/13/96
 *
	  Inq_button_data ( &window, &xpos, &ypos, &button,
					  &transition, &ttag );
*/

          /* Eat UP button event */

          Get_button_data ( &window, &xpos, &ypos, &button,
                            &transition, &ttag );

/*
 *  add test for UP_DOWN_UP in addition to UP.  If I don't, the way
 *  things are coded, we can do UP_DOWN_UP and get the cursor locked
 *  to the slider, then have to do DOWN then UP to get it to release
 *  the slider..  Mike Lanier 8/13/96
 */
	  if ( transition == UP || transition == UP_DOWN_UP )
	    {

		/* Set the value based on the UP location */
                /* But only if the button position is in  */
                /* the valid area.   GMD 11/28/90         */

                if ( ( xpos >= ( xlo - slider_x_area ) ) &&
	             ( xpos <= ( xhi + slider_x_area ) ) &&
	             ( ypos >= ( ylo - slider_y_area ) ) &&
	             ( ypos <= ( yhi + slider_y_area ) ) )
                {
  		   _FI_sld_adjust_location( slider, &xpos, &ypos );

		   _FI_sld_calc_value( slider, xpos, ypos );
                }

		break;
	    }
	}

	/* A single click location is passed in */

      if ( trans == DOWN )
	{
	  Mouseposition ( window, &xpos, &ypos, &work_status );
	}

      if ( ( xpos >= ( xlo - slider_x_area ) ) &&
	   ( xpos <= ( xhi + slider_x_area ) ) &&
	   ( ypos >= ( ylo - slider_y_area ) ) &&
	   ( ypos <= ( yhi + slider_y_area ) ) )
	{
	  first_time_out = TRUE;

	  if ( type == FI_HORIZONTAL )
	    {
	      if ( ( xpos == last_xpos )  || ( xpos > /*=*/ xhi )  ||
					     ( xpos < /*=*/ xlo )  )
		{
		  continue;
		}
	    }
	  else if ( type == FI_VERTICAL )
	    {
	      if ( ( ypos == last_ypos )  || ( ypos > /*=*/ yhi )   ||
					     ( ypos < /*=*/ ylo )   )
		{
		  continue;
		}
	    }

	  last_xpos = xpos;
	  last_ypos = ypos;

			/* Adjust the button location */

	  _FI_sld_adjust_location ( slider, &xpos, &ypos );

 		        /* Calculate the new value */

	  _FI_sld_calc_value ( slider, xpos, ypos );

			/* Erase old button and display new button */

	  _FI_sld_erase_button ( slider, window, xpos, ypos );

	  _FI_sld_display_button ( slider, window, xpos, ypos );

			/* If rop machine make scrolling smoother */

	  if ( FI_rop_machine )
	    {
		vsync ( window );
		vsync ( window );
	    }

	}
      else
	{
	  if ( first_time_out )
	    {
		/* reset because out of range */

		slider->FIgadget.value = old_value;

		hidecursor ( window );

		_FI_sld_display ( slider, window );

		showcursor ( window );
		flushbuffer ( window );

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
      	    /* Call continuous notification routine */

	    /* Modify value before calls */

	  saved_value = slider->FIgadget.value;

	/***********************
	  if ( DISPLAY_MAX_MIN ( slider ) )
	    {
	       return_value = slider->FIgadget.value
			= _FI_sld_get_inverse ( slider, return_value );
	    }
	***********************/

	  if ( slider->FIrange.cont_routine )
	    {
	       slider->FIrange.cont_routine
				( slider->FIgadget.form->form_label,
	    			  slider->FIgadget.label, return_value,
				  slider->FIgadget.form );
	    }

   	    /* Pass on data to directed gadget */

	  _FI_g_pass_data ( slider );

		    /* Change value back */

	  slider->FIgadget.value = saved_value;
	}

      current_value = return_value;

		/* return if single click */

      if ( trans == SINGLE_CLICK )
	{
	  break;
	}

    }  /*** for loop ***/

	/* Snap button to value */

  _FI_sld_get_btn_location ( slider, slider->FIgadget.value,
					   &xpos, &ypos );

  DEBUG_PRINT ( fprintf ( stderr,
   "_FI_sld_track_mouse (after event loop): btn xpos = %d, ypos = %d\n",
	xpos, ypos );)

  _FI_sld_erase_button ( slider, window, xpos, ypos );

  _FI_sld_display_button ( slider, window, xpos, ypos );

	/* save value */

  saved_value = slider->FIgadget.value;

	/* modify value */

/**************************************
  if ( DISPLAY_MAX_MIN ( slider ) )
    {
      slider->FIgadget.value = _FI_sld_get_inverse ( slider,
					slider->FIgadget.value );
    }
**************************************/

  _FI_format_string ( (struct FIgadget_obj *) slider,
				FI_data , slider->FIgadget.value );

  *value = atof( FI_data );

	/* Pass on data to directed gadget */

  _FI_g_pass_data ( slider );	/*** JAJ:01/21/91 ***/

	/* Change value back */

  slider->FIgadget.value = saved_value;

  *complete = TRUE;

} /*** void _FI_sld_track_mouse ( ) ***/




int _FI_sld_adjust ( slider, delta_x, delta_y )
  struct FIsld_obj * slider;
  float	delta_x;
  float	delta_y;
{
  _FI_generic_adjust ( slider, delta_x, delta_y );

  _FI_g_change_text ( slider, delta_y  );

  _FI_sld_calc ( slider );

  return ( FI_SUCCESS );
}



int _FI_sld_activate ( slider )
  struct FIsld_obj * slider;
{
  _FI_g_change_text ( slider, 1.0  );

  _FI_sld_calc ( slider );

  return ( FI_SUCCESS );
}



void _FI_sld_get_value ( slider, value )
  struct FIsld_obj * slider;
  double * value;
{
/******************************
  if ( DISPLAY_MAX_MIN( slider ) )
    {
      / * Take the inverse of value * /

      *value = _FI_sld_get_inverse ( slider, slider->FIgadget.value );
    }
  else
    {
********************************/

      *value = slider->FIgadget.value;

/*******
    }
*******/
}



void _FI_sld_set_value ( slider, value )
  struct FIsld_obj * slider;
  double value;
{
  int   window = WIN_NO ( slider );

	/* If the same value then return */

  if ( value == slider->FIgadget.value )
    {
      return;
    }

	/* format the value */

  _FI_format_string ( (struct FIgadget_obj *) slider, FI_data, value );

  value = atof( FI_data );

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


/*********************
  if ( DISPLAY_MAX_MIN( slider ) )
    {
	    / * Take the inverse of value * /

      slider->FIgadget.value
	= _FI_sld_get_inverse ( slider, slider->FIgadget.value );
    }
*************************/


  if ( ( IT_IS_DISPLAYED ( slider ) ) && ( window != -1 ) )
    {
	hidecursor ( window );

	_FI_sld_display ( slider, window );

	showcursor  ( window );
	flushbuffer ( window );
    }

	/* Pass on data to directed gadget */

  _FI_g_pass_data ( slider );
}

