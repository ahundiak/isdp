#include "FImin.h"
#include "FItog.h"
#include "FItext.h"

#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

int _FI_tog_display (struct FItog_obj  *toggle_obj,
                     Window             window)
{
   int	xlo = toggle_obj->FIgadget.xlo;
   int	ylo = toggle_obj->FIgadget.ylo;
   int	xhi = toggle_obj->FIgadget.xhi;
   int	yhi = toggle_obj->FIgadget.yhi;
   int	puck_width = PUCK_WIDTH;
   int	puck_bezel_width = PUCK_BEZEL_WIDTH;
   int	Xscreen = XSCREEN(toggle_obj);
   Font font_id = toggle_obj->FIgadget.font_id;
   int	state_on = toggle_obj->FIgadget.value;

   int	toggle_height;
   int	toggle_width;
   int	puck_x_offset;
   int	puck_y_offset;
   int	puck_height;
   int	new_x;
   int	new_y;
   int	got_clipped = FALSE;
   unsigned long edge_color, t_l_color, b_r_color, color;
   unsigned long face_color = FI_translate_color (Xscreen, FI_FACE);
   unsigned long med_grey = FI_translate_color (Xscreen, FI_MED_GREY);
   unsigned long lt_grey = FI_translate_color (Xscreen, FI_LT_GREY);
   XRectangle clip_rect;
   XRectangle disabled_clip_rect;
   XGCValues gc_values;

   if (! _FI_is_in_clip_rectangle (& (toggle_obj->FIgadget)))
     {
	  return ( FI_SUCCESS );
     }

   toggle_width  = xhi - xlo;
   toggle_height = yhi - ylo;

   puck_height = toggle_height - (2 * TOGGLE_BEZEL_WIDTH) - 4;

   /*** modify puck bezel width if the toggle's width 	***/
   /***  is smaller than 75 pixels 			***/

   if (toggle_width < 75)
   {
	  puck_bezel_width = 2;
	  puck_width = 10;
   }

   if (toggle_height < 20)
     {
	  puck_bezel_width = 1;
     }

   if (state_on)
   {
	  puck_x_offset = xhi - TOGGLE_BEZEL_WIDTH - puck_width - 2;

	  new_x = xlo + toggle_width / 2 - toggle_obj->FIgadget.on_font_width / 2 - (puck_width / 2);

	  new_y = ylo + (toggle_height / 2) - (toggle_obj->FIgadget.on_font_height / 2);
	  new_x--;
   }
   else
   {
	  puck_x_offset = xlo + TOGGLE_BEZEL_WIDTH + 2;

	  new_x = xlo + toggle_width / 2 - toggle_obj->FIgadget.font_width / 2 + (puck_width / 2);

	  new_y = ylo + (toggle_height / 2) - (toggle_obj->FIgadget.font_height / 2);

      /* Chunn modify xlocation */

	  new_x += 3;
   }

   puck_y_offset = ylo + TOGGLE_BEZEL_WIDTH + 2;

   if (IT_IS_DISABLED(toggle_obj))
   {
	  t_l_color = face_color;
	  b_r_color = face_color;
   }
   else
   {
	  t_l_color = FI_translate_color (Xscreen, FI_SHADOW);
	  b_r_color = FI_translate_color (Xscreen, FI_GLINT);
   }

   if (state_on)
     {
	  color = FI_translate_color (Xscreen, ON_COLOR(toggle_obj));
     }
   else
     {
	  color = FI_translate_color (Xscreen, OFF_COLOR(toggle_obj));
     }

   if (IT_IS_HILITED(toggle_obj))
   {
	  edge_color = FI_translate_color (Xscreen, FI_GLINT);
	  color = edge_color;
   }
   else
   {
	  edge_color = FI_translate_color (Xscreen, FI_EDGE);
   }

   _FI_draw_bezel (window, xlo, ylo, xhi, yhi, TOGGLE_BEZEL_WIDTH, t_l_color, FI_translate_color (Xscreen, IT_IS_DISABLED(toggle_obj) ? FI_LT_GREY : FI_MED_GREY), b_r_color, edge_color, SQUARE);

   _FI_draw_bezel (window, puck_x_offset, puck_y_offset, puck_x_offset + puck_width, puck_y_offset + puck_height, puck_bezel_width, b_r_color, face_color, t_l_color, edge_color, CHAMFERED);

   gc_values.foreground = color;

   if (IT_IS_DISABLED(toggle_obj))
     gc_values.background = lt_grey;
   else
     gc_values.background = med_grey;

   XChangeGC (_FI_display, _FI_gc, (unsigned long) GCForeground | GCBackground, &gc_values);

   /* Set the clipping area to the inside of the toggle */

   xlo += TOGGLE_BEZEL_WIDTH + 1;
   ylo += TOGGLE_BEZEL_WIDTH + 1;
   xhi -= TOGGLE_BEZEL_WIDTH - 1;
   yhi -= TOGGLE_BEZEL_WIDTH - 1;

   if (state_on)
   {
	  clip_rect.x = xlo - 1;
	  clip_rect.y = ylo;
   }
   else
   {
	  clip_rect.x = xlo + puck_width + 1;
	  clip_rect.y = ylo;
   }
   clip_rect.width = xhi - xlo - puck_width - 2;
   clip_rect.height = yhi - ylo;

   if (_FI_form_clipping_on)
     {
	  _FI_adjust_clip_rectangle (&clip_rect);
     }

   if (IT_HAS_TEXT(toggle_obj))
   {
	  XSetClipRectangles (_FI_display, _FI_gc, 0, 0, &clip_rect, 1, Unsorted);
	  got_clipped = TRUE;
	  if (state_on)
	  {
		 _FI_g_draw_text ((struct FIgadget_obj *)toggle_obj, xlo - 1, ylo, xhi - puck_width - 4, yhi, toggle_obj->FItog.on_text, toggle_obj->FItog.on_num_lines, toggle_obj->FIgadget.on_font_height, BORDERS, NO_ERASE);
	  }
	  else
	  {
		 _FI_g_draw_text ((struct FIgadget_obj *)toggle_obj, xlo + puck_width + 1, ylo,
           xhi - 2, yhi, toggle_obj->FIgadget.text,
          (int) toggle_obj->FIgadget.num_lines,
           toggle_obj->FIgadget.font_height, BORDERS, NO_ERASE);
	  }
   }
   else	/* SYMBOLS */
   {
	  if (state_on && IT_HAS_ON_SYMBOL(toggle_obj))
	  {
		 struct FIsym_instance *sym = & toggle_obj->FIgadget.on_symbol_ptr;
		 unsigned int scaled_width = sym->sym_width * toggle_obj->FIgadget.sym_width_scale_factor;
		 unsigned int scaled_height = sym->sym_height * toggle_obj->FIgadget.sym_height_scale_factor;

		 if ((scaled_width > clip_rect.width) || (scaled_height > clip_rect.height))
		 {
			XSetClipRectangles (_FI_display, _FI_gc, 0, 0, &clip_rect, 1, Unsorted);
			got_clipped = TRUE;
		 }
		 new_y = ylo + (yhi - ylo - scaled_height) / 2;
		 new_x = xlo + (xhi - xlo - puck_width - scaled_width) / 2;
		 _FI_sym_draw (window, new_x, new_y, font_id, &toggle_obj->FIgadget.on_symbol_ptr, toggle_obj->FIgadget.sym_width_scale_factor, toggle_obj->FIgadget.sym_height_scale_factor, Xscreen);
	  }
	  else if (! state_on && IT_HAS_OFF_SYMBOL(toggle_obj))
	  {
		 struct FIsym_instance *sym = & toggle_obj->FIgadget.symbol_ptr;
		 int scaled_width = sym->sym_width * toggle_obj->FIgadget.sym_width_scale_factor;
		 int scaled_height = sym->sym_height * toggle_obj->FIgadget.sym_height_scale_factor;

		 if ((scaled_width > (int)clip_rect.width) || (scaled_height > (int)clip_rect.height))
		 {
			XSetClipRectangles (_FI_display, _FI_gc, 0, 0, &clip_rect, 1, Unsorted);
			got_clipped = TRUE;
		 }

		 new_y = ylo + (yhi - ylo - scaled_height) / 2;
		 new_x = xlo + (xhi - xlo + puck_width - scaled_width) / 2;

		 _FI_sym_draw (window, new_x, new_y, font_id, &toggle_obj->FIgadget.symbol_ptr, toggle_obj->FIgadget.sym_width_scale_factor, toggle_obj->FIgadget.sym_height_scale_factor, Xscreen);
	  }
   }

   if (IT_IS_DISABLED(toggle_obj) && ((toggle_obj->FIgadget.attr_mask & FI_NO_DITHERING) == 0))
   {
      /***  XGCValues gc_values;  dmb:03/15/91:Already declared  ***/

	  unsigned long gc_value_mask = GCForeground | GCFillStyle | GCStipple;

	  gc_values.stipple = _FIpix_gray50_array [Xscreen];
	  gc_values.fill_style = FillStippled;
	  gc_values.foreground = FI_translate_color (Xscreen, FI_DK_FACE);
	  XChangeGC (_FI_display, _FI_gc, gc_value_mask, &gc_values);

	  /***************************************************/
	  /* sml:02-19-93                                    */
	  /* change clip area to dither gadget's entire area */
	  /***************************************************/
	 	  disabled_clip_rect.x = toggle_obj->FIgadget.xlo;
		  disabled_clip_rect.y = toggle_obj->FIgadget.ylo;
		  disabled_clip_rect.width = toggle_obj->FIgadget.xhi - toggle_obj->FIgadget.xlo;
 		  disabled_clip_rect.height = toggle_obj->FIgadget.yhi - toggle_obj->FIgadget.ylo;
		  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &disabled_clip_rect,
						 1, Unsorted );

	  if (state_on)
            {
		 XFillRectangle (_FI_display, window, _FI_gc, xlo + 3, ylo + 3, xhi - xlo - puck_width - 10, yhi - ylo - 6);
            }

	  else
            {
		 XFillRectangle (_FI_display, window, _FI_gc, xlo + puck_width + 5, ylo + 3, xhi - xlo - puck_width - 10, yhi - ylo - 6);
            }

	 	 /***************************************************/
 		 /* sml:02-19-93                                    */
		 /* set it back to general clip area                */
	 	 /***************************************************/
		if (_FI_form_clipping_on)
		{
		  disabled_clip_rect.x = _FI_clip_xlo;
		  disabled_clip_rect.y = _FI_clip_ylo;
		  disabled_clip_rect.width = _FI_clip_xhi - _FI_clip_xlo;
		  disabled_clip_rect.height = _FI_clip_yhi - _FI_clip_ylo;
		  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &disabled_clip_rect,
						 1, Unsorted );
		}
		else
		{
		  XSetClipMask(_FI_display, _FI_gc, None);
		}

	  XSetFillStyle (_FI_display, _FI_gc, FillSolid);
   }

   if (got_clipped)
      {
	  _FI_clipping_off ((struct FIgadget_obj *)toggle_obj);
      }
   return (FI_SUCCESS);	/* dmb:03/27/91:Added */
}


void _FI_tog_track_mouse (struct FItog_obj  *toggle_obj,
                          Window             window,
                          int               *complete,
                          double            *value)
{
   *value = toggle_obj->FIgadget.value = ! toggle_obj->FIgadget.value;

   _FI_tog_display (toggle_obj, window);

   XFlush (_FI_display);

   *complete = TRUE;
}

void _FI_tog_delete (struct FItog_obj *toggle_obj)
{
   if (IT_HAS_TEXT(toggle_obj))
     {
	  _FI_s_free ( (char *) toggle_obj->FItog.on_text);
     }
   toggle_obj->FItog.on_text = 0;
}

/* dmb:10/10/92:Change floats to doubles for ANSI */
int _FI_tog_adjust (struct FItog_obj  *toggle_obj,
                    double             delta_x,
                    double             delta_y)
{
   int dummy;

   _FI_generic_adjust ((struct FIgadget_obj *)toggle_obj, delta_x, delta_y);

   if (IT_HAS_TEXT(toggle_obj))
   {
	  unsigned char *on_text = toggle_obj->FItog.on_text;
      /*** int      font_type = toggle_obj->FIgadget.font_type;	***/
      /*** int      font_id   = toggle_obj->FIgadget.font_id;	***/

	/***********************************************************/
	/*** ALERT !  ALERT !  STOP !  LOOK !  LISTEN !		 ***/
	/***********************************************************/
	/*** _FI_g_change_text MAY CHANGE GADGET'S font_id !!!	 ***/
	/*** _FI_g_change_text MAY CHANGE GADGET'S font_type !!! ***/
	/***********************************************************/

	  _FI_g_change_text ((struct FIgadget_obj *)toggle_obj, delta_y);

	  if (on_text)
	  {
         /* CHUNN NEW FONT */

		 FI_calc_text (toggle_obj->FIgadget.font_id,
            (char *)on_text,
			toggle_obj->FItog.on_text_length,
			&toggle_obj->FIgadget.on_font_height,
			&toggle_obj->FIgadget.on_font_width,
			&dummy,
			toggle_obj->FIgadget.font_type );
	  }

      /* Set dummy = 0 means do not calculate width of largest string */

	  dummy = 0;

      /* CHUNN NEW FONT */

	  _FI_mlt_get_lines (toggle_obj->FIgadget.text,
		(int *)&toggle_obj->FIgadget.num_lines,
        &dummy,
		(int)&toggle_obj->FIgadget.font_id,
		toggle_obj->FIgadget.font_type );

	  _FI_mlt_get_lines (on_text,
        (int *)&toggle_obj->FItog.on_num_lines,
		&dummy,
        (int)&toggle_obj->FIgadget.font_id,
		toggle_obj->FIgadget.font_type );

   }
   else
   {
	  _FI_g_change_symbol ((struct FIgadget_obj *)toggle_obj);
      _FI_g_load_symbol ((struct FIgadget_obj *)toggle_obj);
   }
   return (FI_SUCCESS);
}


int _FI_tog_activate (struct FItog_obj *toggle_obj)
{
   if (IT_HAS_TEXT(toggle_obj))
   {
	  int dummy;

      /*** int      font_type = toggle_obj->FIgadget.font_type;	***/
      /*** int      font_id   = toggle_obj->FIgadget.font_id;	***/

	/***********************************************************/
	/*** ALERT !  ALERT !  STOP !  LOOK !  LISTEN !		 ***/
	/***********************************************************/
	/*** _FI_g_change_text MAY CHANGE GADGET'S font_id !!!	 ***/
	/*** _FI_g_change_text MAY CHANGE GADGET'S font_type !!! ***/
	/***********************************************************/

	  _FI_g_change_text ((struct FIgadget_obj *)toggle_obj, 1.0);

      /* calculate the on text */

      /* CHUNN NEW FONT */

	  FI_calc_text (toggle_obj->FIgadget.font_id,
       (char *) toggle_obj->FItog.on_text, toggle_obj->FItog.on_text_length,
       &toggle_obj->FIgadget.on_font_height, &toggle_obj->FIgadget.on_font_width,
       &dummy, toggle_obj->FIgadget.font_type);


      /* Set multi-line flag if text string contains embedded retuns */

      /* Set dummy = 0 means do not calculate width of largest string */

	  dummy = 0;

	  _FI_mlt_get_lines (toggle_obj->FIgadget.text, (int *)&toggle_obj->FIgadget.num_lines, &dummy, toggle_obj->FIgadget.font_id, toggle_obj->FIgadget.font_type);

	  _FI_mlt_get_lines (toggle_obj->FItog.on_text, (int *)&toggle_obj->FItog.on_num_lines, &dummy, toggle_obj->FIgadget.font_id, toggle_obj->FIgadget.font_type);
   }
   else
   {
	  _FI_g_load_symbol ((struct FIgadget_obj *)toggle_obj);
   }
   return (FI_SUCCESS);	/* dmb:03/27/91:Added */
}
