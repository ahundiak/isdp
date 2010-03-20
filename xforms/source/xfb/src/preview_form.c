/***********************************

		preview_form.c

***********************************/

/*
  History
	04-28-92	sml		ANSI-ized; removed unused vars; casted func args
*/

/********************************/
/* */
/* These functions allow all gadget labels to be displayed on the work */
/* form. */
/* */
/* Programmer: Mack Draper */
/* */
/* Date: Dec. 14, 1988 */
/* */
/********************************/

#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "FEI.h"    /* GMD 10/5/91 */
#include "NFBpriv.h"
#include "FItext.h"

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"


extern Form work_form;
extern char current_command_string[80];
extern int command_is_active;

extern GC xfb_GC;
extern XGCValues GC_values;
extern Display *display;

void FB_use_xfb_gc_mlt_draw (Window window,
                             int font_id,
                             char *string,
                             int xpos,
                             int ypos,
                             int justify,
                             int max_width,
                             int font_type)
{
  int center_x = xpos + (max_width / 2);
  int new_y = ypos;
  int line_space, font_height, font_width;
  int offset = 0;
  int text_length = 0;
  int dummy, new_x;
  char *text;
  double dummy_double;

  /* if NULL text pointer or NULL string return */

  if (string[0]== (char) NULL)
    return;

  text = string;
  _FI_calc_text (font_id, "M", 1, &font_height, &font_width, &line_space, font_type);

  line_space = line_space - (line_space / MLT_DIVISOR);

  /* Loop and draw strings from "text" */

  for (;;)
  {
    /* Get the token and offset to end of token */

    /* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */
    /* GMD -- added font_type support 2/7/91 */

    if (_FI_mlt_get_token ((unsigned char *)text, &offset, &text_length, font_type))
      break;

    if ((text_length == 1) && (*text == 10)) /* RETURN */
    {
      /* Increment new_y to location of next
line in the multi line string */

      new_y += line_space;
    }
    else
    {
      /* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

      char *ptr = text;
      int ptr_set = 0;

      /* If the string contains a RETURN then change this to "\n" */

      if (text_length > 2)
      {
        int x;

        for (x = 0; x != text_length; x++)
        {
          if ((*ptr == '\\') && (*(ptr+1) == 10)) /* RETURN */
          {
            *ptr = ' ';
            ptr_set = 1;
            break;
          }

          ptr++;
        }
      }

      /* Adjust coordinates based on justification */

      if (justify == FI_LEFT_JUSTIFIED)
      {
        new_x = xpos;
      }
      else if (justify == FI_CENTER_JUSTIFIED)
      {
        _FI_calc_text (font_id, text, text_length, &font_height, 
            &font_width, &dummy, font_type);

        new_x = center_x - (font_width / 2);
      }
      else
      {
        _FI_calc_text (font_id, text, text_length,
            &font_height, &font_width, &dummy, font_type);

        new_x = xpos + max_width - font_width;
      }

      if (font_type == 0)
         XDrawString (display, window, xfb_GC,
             new_x, new_y + font_height,
             (char *) text, text_length);
      else
      {
	  FSXDrawText (display, DefaultScreen(display),
                                window, xfb_GC, font_id, text, text_length,
				(double)new_x - 1.0,
			        (double)new_y + 2.0, 
				&dummy_double, &dummy_double);

          /* restore the line settings for the GC */

/*
          XSetLineAttributes (display, xfb_GC, 1, LineSolid, CapButt, JoinMiter);
*/
          XSetFillStyle (display, xfb_GC, FillSolid);
      }
/*
         FI_draw_text (window, font_id, text, text_length, 
                               new_x, new_y + font_height, &dummy, &dummy,
                               font_type);
*/

      /* Set the character back to a "\" */

      if (ptr_set)
        *ptr = '\\';

    }

    /* Increment text pointer to beginning of next token */

    text += (offset + 1);
  }
}

/*-----------------------------------------------------------------------*/

void FIg_draw_a_label (int label)
{
  int status;
  int type;
  float dummy_float;
  char t_str[256];
  int xsize, ysize;
  int xpos, ypos;
  int xloc, yloc;
  int orient;
/*  int nx, ny;	NOT USED */

  int bgcolor, fgcolor;
  int width, height, line_spacing;
  Window window;

  Font text_font;
  char font_name[400];

  int ht, wd, ls, font_type;
  int (*my_translate_color)();

  strcpy (font_name, "swiss742b.12");

  XSetSubwindowMode (display, xfb_GC, IncludeInferiors);

  _FI_find_font_id ("swiss742b", (float) 12.0, &text_font, &dummy_float,
      FI_TEXT, &font_type);

  _FI_calc_text (text_font, "M", 1, &ht, &wd, &ls, font_type);

  /* GMD 10/5/91    Instead of using hard-coded constants for colors,    */
  /*                which worked on the clipper, query what the actual   */
  /*                color slot is.                                       */

  FI_get_env (FI_TRANSLATE_COLOR, &my_translate_color);

  bgcolor = (*my_translate_color)(0, FI_BLACK);
  fgcolor = (*my_translate_color)(0, FI_YELLOW);

/*      No longer needed --    GMD 10/5/91
  XSetFont (display, xfb_GC, text_font);
*/
  FIf_get_window (work_form, &window);

  status = FIg_get_type (work_form, label, &type);

  if (status == FI_SUCCESS)
  {
    if (type != FI_GROUP)
    {
      FIg_get_size (work_form, label, &xsize, &ysize);
      FIg_get_location (work_form, label, &xpos, &ypos);

      sprintf (t_str, "%d", label);

/*
      Calculate_text_size (t_str, "swiss742b", (float)12.0,
          &width, &height);
*/
      _FI_calc_text (text_font, t_str, strlen (t_str), &height, &width,
                    &line_spacing, font_type);

      if (type == FI_SLIDER)
      {
        FIg_get_orientation (work_form, label, &orient);

        if (orient == FI_VERTICAL)
        {
          xsize -= 10;
        }
        else
        {
          ysize = height + 6;
        }
      }

      if (type == FI_MULTI_COL)
      {
        FIg_get_size (work_form, label, &xsize, &ysize);
      }

      xloc = xpos + xsize;
      yloc = ypos + ysize;

      XSetForeground (display, xfb_GC, bgcolor); /* FI_BLACK */

      XFillRectangle (display, window, xfb_GC,
          xloc - width - 6, yloc - height - 6,
          width + 6, height + 6);
      XSetForeground (display, xfb_GC, fgcolor); /* FI_YELLOW */

/*  GMD 10/5/91  --  Obsolete now that XFontserver fonts are being used
      XDrawString (display, window, xfb_GC,
          xloc - width - 3, yloc - 5,
          t_str, strlen (t_str));
*/

/*
   _FI_draw_text (window, text_font, t_str, strlen (t_str),
                 xloc - width - 3, yloc - 5, &nx, &ny, font_type);
*/

      FB_use_xfb_gc_mlt_draw (window, text_font, t_str, xloc - width - 3, yloc - 5,
                              FI_LEFT_JUSTIFIED, 50, font_type);

      XFlush (display);
    }
  }
}


/*------------------------------------------------------------------------*/

void execute_preview_form(void)
{
  int status, x;
  int type;

  if (work_form == NULL)
  {
    command_is_active = 0;
    strcpy(current_command_string, "None");
  }
  else
  {
    for (x = 1; x < 1000; x++)
    {
      status = FIg_get_type (work_form, x, &type);

      if (status == FI_SUCCESS)
      {
        if (type != FI_GROUP)
        {
          FIg_draw_a_label (x);
        }
      }
    }
  }

  command_is_active = 0;
  strcpy (current_command_string, "None");
}

/*------------------------------------------------------------------------*/

void kill_preview_form (void)
{
}

