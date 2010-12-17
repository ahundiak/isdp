/*
Name
        _FI_draw_bezel

Description
        This function is used to draw bezels around forms and form gadgets.
        It is overridden from IFORMS to provide a cleaner, more Motif-ish
        appearance for EMS 3.

History
        mrm     10/05/93    implemented thin bezel stuff
*/

#include "FImin.h"
#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/* forward reference for the bezel assignment function */
void _FI_assign_bezel_function(Window         window,
                               int            xlo,
                               int            ylo,
                               int            xhi,
                               int            yhi,
                               int            bezel_size,
                               unsigned long  t_l_color,
                               unsigned long  face_color,
                               unsigned long  b_r_color,
                               unsigned long  edge_color,
                               int            type);

static void (*bezel_function)() = _FI_assign_bezel_function;

/*
Name
        _FI_draw_thin_bezel

Description
        This function is used to draw bezels around forms and form gadgets.
        It is overridden from XFORMS to provide a cleaner, more Motif-ish
        appearance for EMS 3.

Notes
        The bezel is pulled in one pixel for gadgets which do not appear to be
        panel or bar menu buttons.  This is done because lots of buttons which
        look okay with the normal border are really overlapping by one pixel.
        The thinner border used here makes that problem obvious, since the
        pixel that overlaps is the only thing to separate the buttons.  In
        fact, the form builder overlaps the control buttons that it places.
        By pulling in a pixel, the problem vanishes.  The appearance of
        gadgets which were correctly placed is not really impacted by single
        pixel gap.

History
        mrm     10/05/93    creation
*/

#define BORDER_WIDTH    1
#define NORMAL_OFFSET   0
#define CONTROL_OFFSET  1
#define BAR_BUTTON_HEIGHT	39
#define PANEL_BUTTON_HEIGHT_1	44
#define PANEL_BUTTON_HEIGHT_2	59

/* ARGSUSED */
void _FI_draw_thin_bezel(Window window,
                         int xlo,
                         int ylo,
                         int xhi,
                         int yhi,
                         int bezel_size,
                         unsigned long t_l_color,
                         unsigned long face_color,
                         unsigned long b_r_color,
                         unsigned long edge_color,
                         int type)
{
    int jj, offset, y;
    unsigned int value_mask = GCLineWidth | GCForeground;
    XGCValues gc_values;

    /* initialize drawing parameters */
    gc_values.line_width = 0;
    gc_values.foreground = face_color;
    XChangeGC (_FI_display, _FI_gc, value_mask, &gc_values);

    /* draw the rectangular face of the bezel */
    XFillRectangle(_FI_display, window, _FI_gc,
                   xlo, ylo, xhi - xlo, yhi - ylo);

    /* check for a disabled button */
    if (t_l_color == b_r_color)
        t_l_color = b_r_color = edge_color;

    /* check whether to spread out for a control gadget */
    y = yhi - ylo;
    if ((y == BAR_BUTTON_HEIGHT) ||
        (y == PANEL_BUTTON_HEIGHT_1) ||
        (y == PANEL_BUTTON_HEIGHT_2))
        offset = NORMAL_OFFSET;
    else
        offset = CONTROL_OFFSET;

    /* draw border */
    for (jj = 0; jj < BORDER_WIDTH; jj++)
    {
        _FI_vertices[0].x = xlo + offset + jj;
        _FI_vertices[0].y = yhi - offset - jj;
        _FI_vertices[1].x = xlo + offset + jj;
        _FI_vertices[1].y = ylo + offset + jj;
        _FI_vertices[2].x = xhi - offset - jj;
        _FI_vertices[2].y = ylo + offset + jj;
        _FI_vertices[3].x = xhi - offset - jj;
        _FI_vertices[3].y = yhi - offset - jj;
        _FI_vertices[4].x = _FI_vertices[0].x;
        _FI_vertices[4].y = _FI_vertices[0].y;
        XSetForeground(_FI_display, _FI_gc, t_l_color);
        XDrawLines(_FI_display, window, _FI_gc, _FI_vertices, 3, 
                   CoordModeOrigin);
        XSetForeground(_FI_display, _FI_gc, b_r_color);
        XDrawLines(_FI_display, window, _FI_gc, &_FI_vertices[2], 3,
                   CoordModeOrigin);
    }
}

/* This function is used to draw bezels on forms and used for gadgets */

void _FI_draw_normal_bezel
                    (Window         window,
                     int            xlo,
                     int            ylo,
                     int            xhi,
                     int            yhi,
                     int            bezel_size,
                     unsigned long  t_l_color,
                     unsigned long  face_color,
                     unsigned long  b_r_color,
                     unsigned long  edge_color,
                     int            type)
{
  int x_l_i; /* left inside coordinate of bezel */
  int x_r_i; /* right inside coordinate of bezel */
  int y_t_i; /* top inside coordinate of bezel */
  int y_b_i; /* bottom inside coordinate of bezel */

  int num_segments = 0;
  int ii;

  unsigned int value_mask = GCLineWidth | GCForeground;
  XGCValues gc_values;
  XSegment segments[8];
  XRectangle rect[2];

  x_l_i = xlo + bezel_size;
  x_r_i = xhi - bezel_size;
  y_t_i = ylo + bezel_size;
  y_b_i = yhi - bezel_size;

  /********************************************************/
  /* sml:08-11-93                                         */
  /* if left side >= right or top >= bottom               */
  /* (if x_l_i >= x_r_i or y_t_i > y_b_i) forget it       */
  /********************************************************/              

  if ( (x_l_i >= x_r_i) || (y_t_i >= y_b_i))
	return;

  gc_values.line_width = 0;
  gc_values.foreground = t_l_color;
  XChangeGC (_FI_display, _FI_gc, value_mask, &gc_values);

  /** X11-4/30/90-Fill top left Rectangles **/

  rect[0].x = xlo;
  rect[0].y = ylo;
  rect[0].width = xhi - xlo + 1;
  rect[0].height = y_t_i - ylo + 1;
  rect[1].x = xlo;
  rect[1].y = ylo;
  rect[1].width = x_l_i - xlo + 1;
  rect[1].height = yhi - ylo + 1;

  XFillRectangles (_FI_display, window, _FI_gc, rect, 2);

  /* Draw face */

  XSetForeground (_FI_display, _FI_gc, face_color);
  XFillRectangle (_FI_display, window, _FI_gc,
      x_l_i + 1, y_t_i + 1, x_r_i - x_l_i - 1, y_b_i - y_t_i - 1 );

  /* Fill in bottom right area */

  XSetForeground (_FI_display, _FI_gc, b_r_color);

  if (bezel_size <= 2)
  {
    rect[0].x = x_l_i;
    rect[0].y = y_b_i;
    rect[0].width = xhi - x_l_i + 1;
    rect[1].x = x_r_i;
    rect[1].y = y_t_i;
    rect[1].height = y_b_i - y_t_i + 1;

    XFillRectangles (_FI_display, window, _FI_gc, rect, 2);
  }
  else if (bezel_size <= 4) /* prevent memory errors */
  {
    int temp;

    for ( ii = 0; ii < bezel_size ; ii++ )
    {
      temp = bezel_size + ii;

      segments[ii].x1 = x_l_i - ii;
      segments[ii].y1 = y_b_i + ii;
      segments[ii].x2 = xhi;
      segments[ii].y2 = segments[ii].y1;
      segments[temp].x1 = x_r_i + ii;
      segments[temp].y1 = y_t_i - ii;
      segments[temp].x2 = segments[temp].x1;
      segments[temp].y2 = y_b_i;
    }
    XDrawSegments (_FI_display, window, _FI_gc, segments, 2 * ii);
  }

  if (edge_color != b_r_color)
  {
    XSetForeground (_FI_display, _FI_gc, edge_color);
  }

  if (type == CHAMFERED)
  { /** Clockwise from top left **/
    /** Octagonal face **/
    _FI_vertices[0].x = x_l_i + 3;
    _FI_vertices[0].y = y_t_i;
    _FI_vertices[1].x = x_r_i - 3;
    _FI_vertices[1].y = y_t_i;
    _FI_vertices[2].x = x_r_i;
    _FI_vertices[2].y = y_t_i + 3;
    _FI_vertices[3].x = x_r_i;
    _FI_vertices[3].y = y_b_i - 3;
    _FI_vertices[4].x = x_r_i - 3;
    _FI_vertices[4].y = y_b_i;
    _FI_vertices[5].x = x_l_i + 3;
    _FI_vertices[5].y = y_b_i;
    _FI_vertices[6].x = x_l_i;
    _FI_vertices[6].y = y_b_i - 3;
    _FI_vertices[7].x = x_l_i;
    _FI_vertices[7].y = y_t_i + 3;
    _FI_vertices[8].x = x_l_i + 3;
    _FI_vertices[8].y = y_t_i;

    XDrawLines (_FI_display, window, _FI_gc, _FI_vertices, 9, CoordModeOrigin);

    num_segments = 4;

    segments[0].x2 = x_l_i + 1;
    segments[0].y2 = y_t_i + 1;
    segments[1].x2 = x_r_i - 1;
    segments[1].y2 = y_b_i - 1;
    segments[2].x1 = xhi;
    segments[2].y1 = ylo;
    segments[2].x2 = x_r_i - 1;
    segments[2].y2 = y_t_i + 1;
    segments[3].x1 = xlo;
    segments[3].y1 = yhi;
    segments[3].x2 = x_l_i + 1;
    segments[3].y2 = y_b_i - 1;

    XDrawRectangle (_FI_display, window, _FI_gc, xlo, ylo, xhi - xlo, yhi - ylo);
  }
  else /** SQUARED **/
  {
    num_segments = 2;
    segments[0].x2 = x_l_i;
    segments[0].y2 = y_t_i;
    segments[1].x2 = x_r_i;
    segments[1].y2 = y_b_i;

    rect[0].x = xlo;
    rect[0].y = ylo;
    rect[0].width = xhi - xlo;
    rect[0].height = yhi - ylo;

    rect[1].x = x_l_i;
    rect[1].y = y_t_i;
    rect[1].width = x_r_i - x_l_i;
    rect[1].height = y_b_i - y_t_i;

    XDrawRectangles (_FI_display, window, _FI_gc, rect, 2);
  }

  segments[0].x1 = xlo;
  segments[0].y1 = ylo;
  segments[1].x1 = xhi;
  segments[1].y1 = yhi;

  XDrawSegments (_FI_display, window, _FI_gc, segments, num_segments);
}

/*
Name
        _FI_assign_bezel_function

Description
        This function determines whether to use normal or thin bezels
        based upon whether an environment variable is set.

History
        mrm     10/19/93    creation
*/

void _FI_assign_bezel_function(Window         window,
                               int            xlo,
                               int            ylo,
                               int            xhi,
                               int            yhi,
                               int            bezel_size,
                               unsigned long  t_l_color,
                               unsigned long  face_color,
                               unsigned long  b_r_color,
                               unsigned long  edge_color,
                               int            type)
{
    char *c = NULL;
    if ((c = getenv("THIN_BEZEL")) && atoi(c))
        bezel_function = _FI_draw_thin_bezel;
    else
        bezel_function = _FI_draw_normal_bezel;
    (*bezel_function)(window, xlo, ylo, xhi, yhi, bezel_size,
                      t_l_color, face_color, b_r_color, edge_color, type);
}

/*
Name
        FI_use_normal_bezel, FI_use_thin_bezel

Description
        These functions may be used to programmatically set the type of bezel
        display.

History
        mrm     10/19/93    creation
*/

void FI_use_normal_bezel()
{
    bezel_function = _FI_draw_normal_bezel;
}

void FI_use_thin_bezel()
{
    bezel_function = _FI_draw_thin_bezel;
}

/*
Name
        _FI_draw_bezel

Description
        This function uses the bezel_function pointer to draw the proper
        type of bezel.

History
        mrm     10/19/93    changed to use bezel_function
*/

void _FI_draw_bezel(Window         window,
                    int            xlo,
                    int            ylo,
                    int            xhi,
                    int            yhi,
                    int            bezel_size,
                    unsigned long  t_l_color,
                    unsigned long  face_color,
                    unsigned long  b_r_color,
                    unsigned long  edge_color,
                    int            type)
{
    (*bezel_function)(window, xlo, ylo, xhi, yhi, bezel_size,
                      t_l_color, face_color, b_r_color, edge_color, type);
}

