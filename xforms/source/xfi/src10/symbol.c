#include "FImin.h"
#include "FIsym.h"
#include "FImacros.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/**********************************************************************/

int _FI_sym_display (struct FIsym_obj  *symbol_obj,
                     Window             window)
{
   int color, Xscreen = XSCREEN(symbol_obj);
   XGCValues gc_values;

   if (IT_IS_HILITED(symbol_obj))
     {
	  color = FI_GLINT;
     }
   else
     {
	  color = OFF_COLOR(symbol_obj);
     }

   gc_values.foreground = FI_translate_color (Xscreen, color);
   gc_values.background = FI_translate_color (Xscreen, ERASE_COLOR(symbol_obj));
   XChangeGC (_FI_display, _FI_gc, (unsigned long) GCForeground | GCBackground, &gc_values);

   if ( IT_HAS_OFF_SYMBOL ( symbol_obj ) )
   {
	  _FI_sym_draw ( window,
		(int) symbol_obj->FIgadget.xlo +
		      (int) (symbol_obj->FIgadget.symbol_ptr.xoff *
                         symbol_obj->FIgadget.sym_width_scale_factor),
		(int) symbol_obj->FIgadget.ylo +
		      (int) (symbol_obj->FIgadget.symbol_ptr.yoff *
                         symbol_obj->FIgadget.sym_height_scale_factor),
		symbol_obj->FIgadget.font_id,
		&symbol_obj->FIgadget.symbol_ptr,
		symbol_obj->FIgadget.sym_width_scale_factor,
		symbol_obj->FIgadget.sym_height_scale_factor, Xscreen);
   }

   if (IT_IS_DISABLED(symbol_obj) && ((symbol_obj->FIgadget.attr_mask & FI_NO_DITHERING) == 0))
   {
      /*  XGCValues gc_values;  dmb:03/15/91:Already declared  */

	  unsigned long gc_value_mask = GCForeground | GCFillStyle | GCStipple;

	  gc_values.stipple = _FIpix_gray50_array [Xscreen];
	  gc_values.fill_style = FillStippled;
	  gc_values.foreground = FI_translate_color (Xscreen, ERASE_COLOR(symbol_obj));
	  XChangeGC (_FI_display, _FI_gc, gc_value_mask, &gc_values);

	  XFillRectangle ( _FI_display, window, _FI_gc,
		(int) symbol_obj->FIgadget.xlo +
		      (int) (symbol_obj->FIgadget.symbol_ptr.xoff *
                         symbol_obj->FIgadget.sym_width_scale_factor),
		(int) symbol_obj->FIgadget.ylo +
		      (int) (symbol_obj->FIgadget.symbol_ptr.yoff *
                         symbol_obj->FIgadget.sym_height_scale_factor),
		(int) (symbol_obj->FIgadget.xhi - symbol_obj->FIgadget.xlo),
		(int) (symbol_obj->FIgadget.yhi - symbol_obj->FIgadget.ylo) );

	  XSetFillStyle (_FI_display, _FI_gc, FillSolid);
   }

  return ( FI_SUCCESS );
}

int _FI_sym_erase (struct FIsym_obj  *symbol_obj,
                   Window             window)
{
   int Xscreen = XSCREEN(symbol_obj);
   XGCValues gc_values;

   gc_values.foreground = FI_translate_color (Xscreen, ERASE_COLOR(symbol_obj));
   gc_values.background = FI_translate_color (Xscreen, ERASE_COLOR(symbol_obj));
   XChangeGC (_FI_display, _FI_gc, (unsigned long) GCForeground | GCBackground, &gc_values);

   if ( IT_HAS_OFF_SYMBOL ( symbol_obj ) )
   {
	  _FI_sym_draw ( window,
		(int) symbol_obj->FIgadget.xlo +
		      (int) (symbol_obj->FIgadget.symbol_ptr.xoff *
                         symbol_obj->FIgadget.sym_width_scale_factor),
		(int) symbol_obj->FIgadget.ylo +
		      (int) (symbol_obj->FIgadget.symbol_ptr.yoff *
                         symbol_obj->FIgadget.sym_height_scale_factor),
		symbol_obj->FIgadget.font_id,
		&symbol_obj->FIgadget.symbol_ptr,
		symbol_obj->FIgadget.sym_width_scale_factor,
		symbol_obj->FIgadget.sym_height_scale_factor, Xscreen);
   }
   return ( FI_SUCCESS );
}

/* dmb:10/10/92:Change floats to doubles for ANSI */
int _FI_sym_adjust (struct FIsym_obj  *symbol_obj,
                    double             delta_x,
                    double             delta_y)
{
  /* dmb:10/10/92:Added casts for ANSI */
   symbol_obj->FIgadget.xlo = (float)((double)symbol_obj->FIgadget.xlo * delta_x);
   symbol_obj->FIgadget.ylo = (float)((double)symbol_obj->FIgadget.ylo * delta_y);

   symbol_obj->FIgadget.sym_width_scale_factor = (float)
       ((double)symbol_obj->FIgadget.sym_width_scale_factor * delta_x);
   symbol_obj->FIgadget.sym_height_scale_factor = (float)
       ((double)symbol_obj->FIgadget.sym_height_scale_factor * delta_y);

   symbol_obj->FIgadget.font_width = (float) symbol_obj->FIgadget.symbol_ptr.orig_font_width * symbol_obj->FIgadget.sym_width_scale_factor;

   symbol_obj->FIgadget.font_height = (float) symbol_obj->FIgadget.symbol_ptr.orig_font_height * symbol_obj->FIgadget.sym_height_scale_factor;

   symbol_obj->FIgadget.xhi = symbol_obj->FIgadget.xlo + ((float) symbol_obj->FIgadget.symbol_ptr.orig_font_width * symbol_obj->FIgadget.sym_width_scale_factor);

   symbol_obj->FIgadget.yhi = symbol_obj->FIgadget.ylo + ((float) symbol_obj->FIgadget.symbol_ptr.orig_font_height * symbol_obj->FIgadget.sym_height_scale_factor);

  _FI_g_load_symbol ((struct FIgadget_obj *)symbol_obj);

  return ( FI_SUCCESS );
}


int _FI_sym_activate (struct FIsym_obj *symbol_obj)
{
   _FI_g_load_symbol ((struct FIgadget_obj *)symbol_obj);

   symbol_obj->FIgadget.orig_xsize = symbol_obj->FIgadget.font_width;
   symbol_obj->FIgadget.orig_ysize = symbol_obj->FIgadget.font_height;

   /*** Set font size based on scale factors if form	***/
   /*** was scaled and the symbol was changed this will	***/
   /*** correct the problem 				***/

   symbol_obj->FIgadget.xhi = symbol_obj->FIgadget.xlo + symbol_obj->FIgadget.font_width;

   symbol_obj->FIgadget.yhi = symbol_obj->FIgadget.ylo + symbol_obj->FIgadget.font_height;

   return ( FI_SUCCESS );
}
