#include "FImin.h"
#include "FItext.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/* ARGSUSED */
int _FI_txt_erase (struct FItext_obj *text_obj,
                   Window            window)
{
int y_adjust;

   /* Move the text down if it is an XFontserver font */
   /*           GMD 9/5/91                            */

   if (text_obj->FIgadget.font_type > 0)  /* XFontserver font */
      y_adjust = (text_obj->FIgadget.font_height / 5) + 2;
   else
      y_adjust = 0;

   /* GMD 1/7/92   Started using ERASE_COLOR macro  */

   XSetForeground (_FI_display, _FI_gc, FI_translate_color (XSCREEN(text_obj) ,
                                             ERASE_COLOR (text_obj)));
   XSetBackground (_FI_display, _FI_gc,
             FI_translate_color (XSCREEN(text_obj), ERASE_COLOR (text_obj)));

   _FI_g_draw_text ( (struct FIgadget_obj *)text_obj,
		(int) text_obj->FIgadget.xlo,
		(int) ( text_obj->FIgadget.ylo + y_adjust ),
		(int) text_obj->FIgadget.xhi,
		(int) ( text_obj->FIgadget.yhi + y_adjust ),
		text_obj->FIgadget.text,
		text_obj->FIgadget.num_lines,
		text_obj->FIgadget.font_height,
		NO_BORDERS, ERASE );

  return ( FI_SUCCESS );
}


int _FI_txt_display (struct FItext_obj *text_obj,
                     Window            window)
{
   int color;
   int xlo = text_obj->FIgadget.xlo;
   int ylo = text_obj->FIgadget.ylo;
   int xhi = text_obj->FIgadget.xhi;
   int yhi = text_obj->FIgadget.yhi;
   int	y_adjust;

   /* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

   unsigned char *string = text_obj->FIgadget.text;
  XRectangle clip_rect;


   if (! _FI_is_in_clip_rectangle (& (text_obj->FIgadget)) || ! string)
     {
	  return ( FI_SUCCESS );
     }

   if (IT_IS_HILITED(text_obj))
      {
	  color = FI_GLINT;
      }
   else
      {
	  color = OFF_COLOR(text_obj);
      }

   XSetForeground (_FI_display, _FI_gc, FI_translate_color (XSCREEN(text_obj) , color));
   XSetBackground (_FI_display, _FI_gc,
             FI_translate_color (XSCREEN(text_obj), ERASE_COLOR(text_obj))); /* GMD
                                                                     3/11/92 */

   /* Move the text down if it is an XFontserver font */
   /*           GMD 9/5/91                            */

   if (text_obj->FIgadget.font_type > 0)  /* XFontserver font */
      y_adjust = (text_obj->FIgadget.font_height / 5) + 2;
   else
      y_adjust = 0;


   _FI_g_draw_text ( (struct FIgadget_obj *)text_obj,
			xlo,
			ylo + y_adjust,
			xhi,
			yhi + y_adjust,
			string,
			text_obj->FIgadget.num_lines,
			text_obj->FIgadget.font_height,
			NO_BORDERS, NO_ERASE);


   if (IT_IS_DISABLED(text_obj) && ((text_obj->FIgadget.attr_mask & FI_NO_DITHERING) == 0))
   {
	  XGCValues gc_values;
	  unsigned long gc_value_mask = GCForeground | GCFillStyle | GCStipple;

	  gc_values.foreground = FI_translate_color (XSCREEN(text_obj) , ERASE_COLOR(text_obj));
	  gc_values.stipple = _FIpix_gray75_array [XSCREEN(text_obj)];
	  gc_values.fill_style = FillStippled;
	  XChangeGC (_FI_display, _FI_gc, gc_value_mask, &gc_values);

	  /***************************************************/
	  /* sml:02-19-93                                    */
	  /* change clip area to dither gadget's entire area */
	  /***************************************************/
	 	  clip_rect.x = text_obj->FIgadget.xlo;
		  clip_rect.y = text_obj->FIgadget.ylo + y_adjust;
		  clip_rect.width = text_obj->FIgadget.xhi - text_obj->FIgadget.xlo;
 		  clip_rect.height = text_obj->FIgadget.yhi -
text_obj->FIgadget.ylo + y_adjust;
		  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &clip_rect,
						 2, Unsorted );

	  XFillRectangle (_FI_display, window, _FI_gc, xlo, ylo + y_adjust,
                                   xhi - xlo + 3, yhi - ylo + 3 + y_adjust);

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

	  XSetFillStyle (_FI_display, _FI_gc, FillSolid);
   }

  return ( FI_SUCCESS );
}


/* dmb:10/10/92:Change floats to doubles for ANSI */
int _FI_txt_adjust (struct FItext_obj *text_obj,
                    double            delta_x,
                    double            delta_y)
{
   int just = text_obj->FIgadget.justification;
   int largest_width;
   int mlt_offset;

   /* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

   unsigned char *string = text_obj->FIgadget.text;

   if (just == FI_LEFT_JUSTIFIED)
   {
	  text_obj->FIgadget.xlo = (float)((double)text_obj->FIgadget.xlo * delta_x);
	  text_obj->FIgadget.ylo = (float)((double)text_obj->FIgadget.ylo * delta_y);
   }
   else if (just == FI_RIGHT_JUSTIFIED)
   {
	  text_obj->FIgadget.xhi = (float)((double)text_obj->FIgadget.xhi * delta_x);
	  text_obj->FIgadget.yhi = (float)((double)text_obj->FIgadget.yhi * delta_y);
   }

   /* Set for single line text */

   text_obj->FIgadget.text_length = FI_strlen ((char *)string, text_obj->FIgadget.font_type);

   /* Change bodysize */

   _FI_g_change_text ((struct FIgadget_obj *)text_obj, delta_y);

   text_obj->FIgadget.largest_width = 1;

   /* CHUNN NEW FONT */

   _FI_mlt_get_lines (string,
     (int *)&text_obj->FIgadget.num_lines,
     (int *)&text_obj->FIgadget.largest_width,
     (int)text_obj->FIgadget.font_id,
     (int)text_obj->FIgadget.font_type);

   largest_width = text_obj->FIgadget.largest_width;

   mlt_offset = MLT_OFFSET(text_obj);

   if (just == FI_LEFT_JUSTIFIED)
   {
	  text_obj->FIgadget.xhi = text_obj->FIgadget.xlo + largest_width;
	  text_obj->FIgadget.yhi = text_obj->FIgadget.ylo + mlt_offset;
   }
   else if (just == FI_RIGHT_JUSTIFIED)
   {
	  text_obj->FIgadget.xlo = text_obj->FIgadget.xhi - largest_width;
	  text_obj->FIgadget.ylo = text_obj->FIgadget.yhi - mlt_offset;
   }
   else if (just == FI_CENTER_JUSTIFIED)
   {
	  float center_x = CENTER_X(text_obj->FIgadget.xlo, text_obj->FIgadget.xhi);
	  int half_font_width = largest_width / 2;

	  center_x = (float)((double)center_x * delta_x);

      /* Take off decimal precision */

	  center_x = (int) center_x;

	  text_obj->FIgadget.xlo = center_x - half_font_width;
	  text_obj->FIgadget.xhi = center_x + half_font_width;

	  text_obj->FIgadget.ylo = (float)((double)text_obj->FIgadget.ylo * delta_y);
	  text_obj->FIgadget.yhi = text_obj->FIgadget.ylo + mlt_offset;
   }
  return ( FI_SUCCESS );
}


int _FI_txt_activate (struct FItext_obj *text_obj)
{
   _FI_g_change_text ((struct FIgadget_obj *)text_obj, 1.0);

   /*** Set largest_width to 1 meaning 	***/
   /*** calculate the largest width 	***/

   text_obj->FIgadget.largest_width = 1;

   /* CHUNN NEW FONT */

   _FI_mlt_get_lines (text_obj->FIgadget.text,
     (int *)&text_obj->FIgadget.num_lines,
     (int *)&text_obj->FIgadget.largest_width,
     (int)text_obj->FIgadget.font_id,
     (int)text_obj->FIgadget.font_type);

   text_obj->FIgadget.xhi = text_obj->FIgadget.xlo +
			 text_obj->FIgadget.largest_width;

   text_obj->FIgadget.yhi = text_obj->FIgadget.ylo + MLT_OFFSET(text_obj);

  return ( FI_SUCCESS );
}
