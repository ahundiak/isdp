#include "FImin.h"
#include "FIgraphic.h"
#include "FIline.h"


#include "XFIproto_pri.h"
#include "XFIproto_pub.h"




void _FI_graphic_activate (struct FIgraphic_instance *graph)
{
   if (graph->line_style == 0xffffffff)
	  graph->list_len = 0;
   else
   {
	  int tst_bit = 0x00008000, last_bit, len = 1, style = graph->line_style;
	  if (! graph->dash_list)
		 graph->dash_list = malloc (16 * sizeof (char));

	  memset (graph->dash_list, 0, 16);

	  last_bit = tst_bit & style;

	  while (tst_bit)
	  {
		 if (last_bit != (tst_bit & style))
			len++;

		 graph->dash_list[len - 1]+= 2;
		 last_bit = tst_bit & style;
		 last_bit >>= 1;
		 tst_bit >>= 1;
	  }

	  if (len % 2)	/* if ODD */
	  {
		 graph->dash_list[0]+= graph->dash_list[len - 1];
		 len--;
	  }
	  graph->list_len = len;
   }
}


/* CHUNN check for vertical and horizontal */

void _FI_line_draw_line (struct FIline_obj  *line,
                         int                 Xscreen,
                         Window              window,
                         int                 off_color,
                         int                 shadow_color,
                         int                 glint_color)
{
   int xlo = line->FIgadget.xlo;
   int ylo = line->FIgadget.ylo;
   int xhi = line->FIgadget.xhi;
   int yhi = line->FIgadget.yhi;

   int line_weight = line->FIgraphic.line_weight;
   XGCValues gc_values;
   unsigned int gc_value_mask = GCLineWidth | GCForeground;

   /** X11-4/27/90-A dash list is not an Env.V enable pattern! **/

   if (line->FIgraphic.list_len)
   {
	  gc_value_mask |= GCLineStyle;
	  gc_values.line_style = LineOnOffDash;
	  XSetDashes (_FI_display, _FI_gc, 0, line->FIgraphic.dash_list, line->FIgraphic.list_len);
   }

   gc_values.line_width = line_weight + 1;

   if (IT_IS_HILITED(line))
	  gc_values.foreground = FI_translate_color (Xscreen, glint_color);
   else
	  gc_values.foreground = FI_translate_color (Xscreen, off_color);

   XChangeGC (_FI_display, _FI_gc, gc_value_mask, &gc_values);

   XDrawLine (_FI_display, window, _FI_gc, xlo, ylo, xhi, yhi);

   /* Draw effect if set */

   if (line->FIgadget.effect == FI_3D_LINE)
   {
	  int offset;

      /* Calculate the best shadow and glint line weight */

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

	  gc_values.foreground = FI_translate_color (Xscreen, glint_color);

	  gc_value_mask = GCForeground | GCLineWidth;
	  XChangeGC (_FI_display, _FI_gc, gc_value_mask, &gc_values);

	  if (line->FIgadget.ylo == line->FIgadget.yhi)
	  {
         /* Draw shadow around line */

		 XDrawLine (_FI_display, window, _FI_gc, xlo, ylo - offset, xhi, yhi - offset);

		 XSetForeground (_FI_display, _FI_gc, FI_translate_color (Xscreen, shadow_color));

         /* Draw hilite around line */

		 XDrawLine (_FI_display, window, _FI_gc, xlo, ylo + offset, xhi, yhi + offset);
	  }
	  else
	  {
         /* Draw shadow around line */

		 XDrawLine (_FI_display, window, _FI_gc, xlo - offset, ylo, xhi - offset, yhi);

		 XSetForeground (_FI_display, _FI_gc, FI_translate_color (Xscreen, shadow_color));

         /* Draw hilite around line */

		 XDrawLine (_FI_display, window, _FI_gc, xlo + offset, ylo, xhi + offset, yhi);
	  }
   }

   /* reset linestyle */

   if (line->FIgraphic.list_len)
	  XSetLineAttributes (_FI_display, _FI_gc, 0, LineSolid, CapButt, JoinBevel);
}


int _FI_line_display (struct FIline_obj  *line,
                      Window              window)
{
   if (! _FI_is_in_clip_rectangle (& (line->FIgadget)))
	  return (FI_SUCCESS);

   _FI_line_draw_line (line, line->FIgadget.form->Xscreen, window, line->FIgadget.off_color, FI_SHADOW, FI_GLINT);
   return (FI_SUCCESS);	/* dmb:03/27/91:Added */

}


int _FI_line_erase (struct FIline_obj  *line,
                    Window              window)
{
   int form_bgcolor = ERASE_COLOR(line);

   _FI_line_draw_line (line, line->FIgadget.form->Xscreen, window, form_bgcolor, form_bgcolor, form_bgcolor);
   return (FI_SUCCESS);	/* dmb:03/27/91:Added */

}
