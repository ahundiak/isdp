
#include "FImin.h"
#include "FIgraphic.h"
#include "FIrect.h"


#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


void _FI_rect_draw_box (Window  window,
                        int     xlo,
                        int     ylo,
                        int     xhi,
                        int     yhi)
{
   XDrawRectangle (_FI_display, window, _FI_gc, xlo, ylo, xhi - xlo, yhi - ylo);
}


void _FI_rect_draw (struct FIrect_obj  *rect,
                    Window              window,
                    int                 glint_color,
                    int                 shadow_color,
                    int                 gadget_color,
                    int                 fill_color)
{
   int xlo = rect->FIgadget.xlo;
   int ylo = rect->FIgadget.ylo;
   int xhi = rect->FIgadget.xhi;
   int yhi = rect->FIgadget.yhi;
   int Xscreen = XSCREEN(rect);
   int line_weight = rect->FIgraphic.line_weight;
   unsigned long gc_value_mask = GCForeground | GCLineWidth;
   XGCValues gc_values;

   if (rect->FIgadget.effect == FI_FILLED)
   {
	  int left_offset;
	  int right_offset;

      /* Calculate the offsets */

	  left_offset = ((line_weight + 1) / 2);

	  right_offset = ((line_weight + 1) / 2);

	  if ((line_weight + 1) % 2)
		 right_offset++;

	  XSetForeground (_FI_display, _FI_gc, FI_translate_color (Xscreen, fill_color));

	  XFillRectangle (_FI_display, window, _FI_gc, xlo, ylo, xhi - xlo, yhi - ylo);
   }

   /* Draw normal regular line */

   if (IT_IS_HILITED(rect))
	  gc_values.foreground = FI_translate_color (Xscreen, glint_color);
   else
	  gc_values.foreground = FI_translate_color (Xscreen, gadget_color);

   /** X11-4/27/90-A dash list is not an Env.V enable pattern! **/

   if (rect->FIgraphic.list_len)
   {
	  gc_value_mask |= GCLineStyle;
	  gc_values.line_style = LineOnOffDash;
	  XSetDashes (_FI_display, _FI_gc, 0, rect->FIgraphic.dash_list, rect->FIgraphic.list_len);
   }

   gc_values.line_width = line_weight + 1;
   XChangeGC (_FI_display, _FI_gc, gc_value_mask, &gc_values);

   _FI_rect_draw_box (window, xlo, ylo, xhi, yhi);

   if (rect->FIgadget.effect == FI_3D_LINE)
   {
	  int offset;
	  if (line_weight <= 1)
	  {
		 gc_values.line_width = 1;
		 offset = 1;
	  }
	  else if (line_weight <= 4)
	  {
		 gc_values.line_width = 2;
		 offset = 1;
	  }
	  else
	  {
		 gc_values.line_width = 3;
		 offset = 2;
	  }

	  gc_values.foreground = FI_translate_color (Xscreen, shadow_color);
	  gc_value_mask = GCLineWidth | GCForeground;
	  XChangeGC (_FI_display, _FI_gc, gc_value_mask, &gc_values);

	  _FI_rect_draw_box (window, xlo + offset, ylo + offset, xhi + offset, yhi + offset);

	  XSetForeground (_FI_display, _FI_gc, FI_translate_color (Xscreen, glint_color));

	  _FI_rect_draw_box (window, xlo - offset, ylo - offset, xhi - offset, yhi - offset);
   }

   /* reset drawing attributes */

   if (rect->FIgraphic.list_len)
	  XSetLineAttributes (_FI_display, _FI_gc, 0, LineSolid, CapButt, JoinBevel);
}


int _FI_rect_display (struct FIrect_obj  *rect,
                      Window              window)
{
   if (! _FI_is_in_clip_rectangle (& (rect->FIgadget)))
	  return (FI_SUCCESS);

   _FI_rect_draw (rect, window, FI_GLINT, FI_SHADOW, OFF_COLOR(rect) , ON_COLOR(rect));
   return (FI_SUCCESS);	/* dmb:03/27/91:Added */

}



int _FI_rect_erase (struct FIrect_obj  *rect,
                    Window              window)
{
/*
   int erase_color = ERASE_COLOR(rect);

   _FI_rect_draw (rect, window, erase_color, erase_color, erase_color, erase_color);
   return (FI_SUCCESS);	/ * dmb:03/27/91:Added * /
*/
   int line_weight = rect->FIgraphic.line_weight;

   if (IT_IS_NOT_DISPLAYABLE (rect))
      return (FI_SUCCESS);

   XFillRectangle (_FI_display, window, _FI_gc,
      (int) rect->FIgadget.xlo - (((line_weight + 1) / 2) + 1),
      (int) rect->FIgadget.ylo - (((line_weight + 1) / 2) + 1),
      (int) rect->FIgadget.xhi - (int) rect->FIgadget.xlo + 2 +
                    line_weight + 1,
      (int) rect->FIgadget.yhi - (int) rect->FIgadget.ylo + 2 +
                    line_weight + 1);
      
   return (FI_SUCCESS);
}

