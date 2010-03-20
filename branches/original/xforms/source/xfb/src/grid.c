/***********************************

		grid.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/**************************/
/* */
/* This file contains all the grid related functions */
/* */
/* Programmer: */
/* Mack Draper */
/* */
/* Date: June 4, 1990 */
/* */
/**************************/


#include <stdio.h>
#include "FI.h"
#include "NFBpriv.h"
#include "FEI.h"

#include <X11/Xlib.h>

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"


extern Form work_form;
extern Display *display;
extern GC xfb_GC;
extern int hilite_plane;

extern struct dpb_struct dpb;


static void erase_grid_on_work_form();

/*************************************************************************/
void display_grid_on_work_form(void)
{
  int x_size, y_size;
  int x_loop, y_loop;
  int x_pos, y_pos;
  int dot_loop;
  int x, y;
  Window window;
  XWindowAttributes window_attr;
  int (*my_translate_color)();
  XGCValues gc_values;
  int gc_value_mask;

  if (work_form == NULL)
    return;

  /* GMD   2/11/92 */

  gc_value_mask = GCLineStyle;
  gc_values.line_style = LineSolid;
  XChangeGC (display, xfb_GC, gc_value_mask, &gc_values);

  FIf_get_window (work_form, &window);
  XGetWindowAttributes (display, window, &window_attr);

  x_size = window_attr.width;
  y_size = window_attr.height;

  FI_get_env (FI_TRANSLATE_COLOR, &my_translate_color);
  XSetForeground (display, xfb_GC, (*my_translate_color)( 0, FI_WHITE ));

  x_loop = x_size / dpb.grid_sub_units;
  y_loop = y_size / dpb.grid_sub_units;
  dot_loop = dpb.grid_master_units / dpb.grid_sub_units;

  y_pos = dpb.grid_sub_units;

  for (y = 0; y < y_loop; y++)
  {
    x_pos = dpb.grid_sub_units;

    for (x = 0; x < x_loop; x++)
    {
      if ((x % dot_loop == 0) &&
          (y % dot_loop == 0))
      {
        XDrawLine (display, window, xfb_GC, x_pos - 2, y_pos,
            x_pos + 2, y_pos);

        XDrawLine (display, window, xfb_GC, x_pos, y_pos - 2,
            x_pos, y_pos + 2);
      }
      else
        XDrawLine (display, window, xfb_GC, x_pos, y_pos, x_pos, y_pos);

      x_pos += dpb.grid_sub_units;
    }

    y_pos += dpb.grid_sub_units;
  }
  XFlush (display);
}

/*-----------------------------------------------------------------------*/

static void erase_grid_on_work_form(void)
{
  int x_size, y_size;

  if (work_form == NULL)
    return;

  FIf_get_size (work_form, &x_size, &y_size);

  FIf_paint_area (work_form, 0, 0, x_size, y_size);
}

/*-----------------------------------------------------------------------*/

void toggle_grid_mode(void)
{
  if (dpb.grid_flag == 0)
    dpb.grid_flag = 1;
  else
    dpb.grid_flag = 0;

  if (work_form != NULL)
    if (dpb.grid_flag == 1)
      display_grid_on_work_form();
    else
      erase_grid_on_work_form();
}

/*----------------------------------------------------------------------*/

/* ARGSUSED */
void window_event_grid_check (int form_label,
                             int event,
                             Form form)
{
  if ((event == FI_REFRESH) ||
      (event == FI_DISPLAY))
  {
    if (work_form != NULL)
    {
      if (dpb.grid_flag == 1)
      {
        display_grid_on_work_form();
      }
    }
  }

  return;
}
