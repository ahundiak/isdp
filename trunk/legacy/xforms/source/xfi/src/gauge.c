#include "FImin.h"
#include "FIgauge.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


void _FI_gauge_fill_rect (struct FIgauge_obj  *gauge,
                          int                  rect,
                          int                  translated_color)
{
  int xlo = gauge->FIgadget.xlo;
  int ylo = gauge->FIgadget.ylo;
  int xhi = gauge->FIgadget.xhi;
  int yhi = gauge->FIgadget.yhi;
  Window window = XWINDOW ( gauge );


  if ( rect == 0 )
    {
      return;
    }

  XSetForeground ( _FI_display, _FI_gc, translated_color );

  if ( gauge->FIgauge.type == FI_HORIZONTAL )
    {
      xlo = xlo + ( ( rect - 1 ) *
	( gauge->FIgauge.rect_width + gauge->FIgauge.space_width )) + 1;

      xhi = xlo + gauge->FIgauge.rect_width;

      XFillRectangle ( _FI_display, window, _FI_gc, xlo, ylo + 1,
					 xhi - xlo - 1, yhi - 1 - ylo );
    }
  else	/** FI_VERTICAL **/
    {
      ylo = yhi - (( rect - 1 ) * gauge->FIgauge.space_width ) -
			 ( rect * gauge->FIgauge.rect_width ) + 1;

      yhi = ylo + gauge->FIgauge.rect_width;

      XFillRectangle ( _FI_display, window, _FI_gc, xlo + 1, ylo,
				 	xhi - 1 - xlo, yhi - ylo - 1 );
    }
}


int _FI_gauge_set_value (struct FIgauge_obj  *gauge,
                         double               value)
{
  int		last_rect = gauge->FIgauge.current_rect;
  Window	window = XWINDOW ( gauge );
  int		Xscreen = XSCREEN ( gauge );
  int		current_rect;
  double	high_value = gauge->FIrange.high_value;
  int		translated_form_bgcolor;
  int		translated_gauge_color;
  int		xx;


  if ( value < 0 )
    {
      gauge->FIgadget.value = 0;
    }
  else if ( value > high_value )
    {
      gauge->FIgadget.value = high_value;
    }
  else
    {
      gauge->FIgadget.value = value;
    }

  if ( value > 0.0 )
    {
      gauge->FIgauge.current_rect = gauge->FIgadget.value /
		( high_value / gauge->FIgauge.minor_increments );
    }
  else
    {
      gauge->FIgauge.current_rect = 0;
    }


  if ( gauge->FIgauge.current_rect >
				 gauge->FIgauge.minor_increments - 1 )
    {
      gauge->FIgauge.current_rect = gauge->FIgauge.minor_increments;
    }

  current_rect = gauge->FIgauge.current_rect;

  if (	( IT_IS_DISPLAYED (gauge))		&&
	 gauge->FIgadget.form->displayed	&&
	 ( window != None )			 )
    {
      if ( current_rect != last_rect )
	{
	  translated_form_bgcolor = FI_translate_color ( Xscreen,
						 ERASE_COLOR ( gauge ));

	  if ( last_rect > current_rect )
	    {
	      for ( xx = last_rect; xx > current_rect; xx-- )
		{
		  _FI_gauge_fill_rect ( gauge, xx,
					 translated_form_bgcolor );
		}
	    }
	  else
	    {
	           /**************************************************/
	           /*** Change to make gauges show up on 2- and 4- ***/
	           /*** color screens.		     -JAJ:11/16/90 ***/
	           /**************************************************/

	      translated_gauge_color = _FI_g_find_contrasting_on_color
			 ( Xscreen, FI_translate_color ( Xscreen,
						 ON_COLOR ( gauge )),
			   translated_form_bgcolor );

	      for ( xx = last_rect; xx <= current_rect; xx++ )
		{
		  _FI_gauge_fill_rect ( gauge, xx,
					 translated_gauge_color );
		}
	     }

           /* sml:01-18-94:TR 249400065                         */
           /*  Add check before flushing.  Don't flush if       */
           /*  initially displaying gadget.  OK to flush if     */
           /*  updating      */
           if (!_FI_dont_flush)
             XFlush ( _FI_display );
	}
    }

  /* Pass on data to directed gadget */

  _FI_g_pass_data ( (struct FIgadget_obj *)gauge );

  return ( FI_SUCCESS );
}


void _FI_gauge_get_area (struct FIgauge_obj  *gauge,
                         int                 *xlo,
                         int                 *ylo,
                         int                 *xhi,
                         int                 *yhi)
{
  int	offset;

  offset = ( gauge->FIgauge.minor_increments *
				 gauge->FIgauge.rect_width ) +
	     (( gauge->FIgauge.minor_increments - 1 ) *
					 gauge->FIgauge.space_width );

  *xlo = gauge->FIgadget.xlo;
  *yhi = gauge->FIgadget.yhi;

  if ( gauge->FIgauge.type == FI_HORIZONTAL )
    {
      *xhi = *xlo + offset;
      *ylo = gauge->FIgadget.ylo;
    }
  else
    {
      *xhi = gauge->FIgadget.xhi;
      *ylo = *yhi - offset;
    }
}



int _FI_gauge_display (struct FIgauge_obj  *gauge,
                       Window               window)
{
  float lminor = gauge->FIgauge.minor_increments;
  int	Xscreen = XSCREEN ( gauge );

  int	xlo = gauge->FIgadget.xlo;
  int	ylo = gauge->FIgadget.ylo;
  int	yhi = gauge->FIgadget.yhi;
  int	xhi = gauge->FIgadget.xhi;

  int	xx;
  int	color;
  int	rect_width;
  int	space_width;

  float length;
  float division;
  int	translated_gauge_color;
  XGCValues gc_values;


  if ( ! _FI_is_in_clip_rectangle ( & gauge->FIgadget ) )
    {
      return ( FI_SUCCESS );
    }

	/* Calculate Values */

  if ( gauge->FIgauge.type == FI_HORIZONTAL )
    {
      length = xhi - xlo;
    }
  else
    {
      length = yhi - ylo;
    }

  division = length / lminor;

  gauge->FIgauge.space_width = ( division * GAUGE_SPACE_RATIO ) + 0.5;

  gauge->FIgauge.rect_width = (division - gauge->FIgauge.space_width) + 0.5;

  gauge->FIgauge.current_rect = gauge->FIgadget.value /
				 ( gauge->FIrange.high_value / lminor );

  rect_width = gauge->FIgauge.rect_width;
  space_width = gauge->FIgauge.space_width;

	  /* Display */

  if ( IT_IS_HILITED ( gauge ))
    {
      color = FI_GLINT;
    }
  else
    {
      color = OFF_COLOR ( gauge );
    }

  translated_gauge_color = _FI_g_find_contrasting_on_color ( Xscreen,
	 FI_translate_color ( Xscreen, color ),
	 FI_translate_color ( Xscreen, ERASE_COLOR ( gauge )));

  gc_values.line_width = 0;
  gc_values.foreground = translated_gauge_color;

	/* Set color to form's bgcolor because erasing gauge */

  XChangeGC ( _FI_display, _FI_gc, GCLineWidth | GCForeground,
						 &gc_values );

  if ( gauge->FIgauge.type == FI_HORIZONTAL )
    {
      for ( xx = 0; xx < lminor; xx++ )
	{
	  xhi = xlo + rect_width;
	  _FI_rect_draw_box ( window, xlo, ylo, xhi, yhi );
	  xlo += ( space_width + rect_width );
	}
    }
  else
    {
      for ( xx = 0; xx < lminor; xx++ )
	{
	  ylo = yhi - rect_width;
	  _FI_rect_draw_box ( window, xlo, ylo, xhi, yhi );
	  yhi -= ( space_width + rect_width );
	}
    }

	/**************************************************/
	/*** Change to make gauges show up on 2- and 4- ***/
	/*** color screens.		  -JAJ:11/16/90 ***/
	/**************************************************/

  translated_gauge_color = _FI_g_find_contrasting_on_color ( Xscreen,
	FI_translate_color ( Xscreen, ON_COLOR ( gauge )),
	FI_translate_color ( Xscreen, ERASE_COLOR ( gauge )) );

	/* Fill in the rectangles */

  for ( xx = 1; xx < gauge->FIgauge.current_rect + 1; xx++ )
    {
      _FI_gauge_fill_rect ( gauge, xx, translated_gauge_color );
    }

  if ( IT_IS_DISABLED ( gauge ))
    {
      int		xxlo, yylo, xxhi, yyhi;

      gc_values.stipple	   = _FIpix_gray50_array [Xscreen];
      gc_values.fill_style = FillStippled;
      gc_values.foreground = FI_translate_color ( Xscreen,
					 ERASE_COLOR ( gauge ));
      XChangeGC ( _FI_display, _FI_gc,
		GCForeground | GCFillStyle | GCStipple, &gc_values );

      _FI_gauge_get_area ( gauge, &xxlo, &yylo, &xxhi, &yyhi );

      XFillRectangle ( _FI_display, window, _FI_gc, xxlo, yylo,
					 xxhi - xxlo, yyhi - yylo );

      XSetFillStyle ( _FI_display, _FI_gc, FillSolid );
    }

  return ( FI_SUCCESS );
}


int _FI_gauge_erase (struct FIgauge_obj  *gauge,
                     Window               window)
{
  int xlo, ylo, xhi, yhi;

  _FI_gauge_get_area ( gauge, &xlo, &ylo, &xhi, &yhi );

  XFillRectangle ( _FI_display, window, _FI_gc, xlo, ylo,
				xhi - xlo + 1, yhi - ylo + 1 );

  return ( FI_SUCCESS );
}
