/********************************

		poke.c

********************************/

/********************************/
/* */
/* These functions allow the operator to enter either one or two */
/* datapoints within a specified window. */
/* */
/* Programmer: Mack Draper */
/* */
/* Date: Nov. 12, 1988 */
/* */
/********************************/

/*
  History
	04-06-92	sml		ANSI-ized, casted function arguments and
						  changed types of some local variables 
	05-07-92	sml		added 2nd arg to FI_process_event; casted
						  func args for ANSI
*/
#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"
#include "FEI.h"
#include "FImgt.h"

#include "FImin.h"
#include "FItext.h"

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"


int global_crosshairs_flag;

Cursor curs = None;
XSegment segs[100];
int Segment_count = 0;

extern struct _FI_sym_st *_FI_symbols;

extern int command_is_active;
extern struct gadget_struct gadget_attr;
extern struct dpb_struct dpb;
extern Form work_form;
extern int Two_vscreens_flag;

extern Form Message_form;

extern GC xfb_GC, dyn_GC, text_GC;
extern XGCValues GC_values, dyn_GC_values;
extern Display *display;


extern int keyin_label;


static int form_width, form_height;

static void Define_field_dynamics();
static void Draw_boundary_areas();
static void Draw_crosshairs();
static void Draw_dyn_box();
static void Draw_dyn_leave_out_top_box();
static void Draw_dyn_lower_left_box();
static void Draw_dyn_lower_right_box();
static void Draw_dyn_upper_left_box();
static void Draw_dyn_upper_right_box();
static void FBf_gadgets_in_point();
static void Move_MCF_dynamics();
/* static void Refresh_window(); */


/******************************************/
/* */
/* Draw_crosshairs() */
/* */
/******************************************/

/* ARGSUSED */
static void Draw_crosshairs (Window window,
                             int x,
                             int y)
{
  segs[Segment_count].x1 = (short) 0;
  segs[Segment_count + 1].x2 = (short) form_width;
  segs[Segment_count + 2].y1 = (short) 0;
  segs[Segment_count + 2].y2 = (short) form_height;

  segs[Segment_count].y1 = segs[Segment_count].y2 =
      segs[Segment_count + 1].y1 = segs[Segment_count + 1].y2 = (short) y;
  segs[Segment_count].x2 = segs[Segment_count + 2].x1 =
      segs[Segment_count + 2].x2 = (short) x;
  segs[Segment_count + 1].x1 = (short)
      (segs[Segment_count + 2].x1 + (int)dyn_GC_values.line_width);

  Segment_count += 3;
}

/*-------------------------------------------------------------------------*/

/***************************************/
/* */
/* Draw_dyn_box() */
/* */
/***************************************/

/* ARGSUSED */
static void Draw_dyn_box (Window window,
                          int x1,
                          int y1,
                          int x2,
                          int y2)
{
  segs[Segment_count].x1 = (short) x1;
  segs[Segment_count].x2 = (short) x2;
  segs[Segment_count].y1 = (short) y1;
  segs[Segment_count].y2 = (short) y1;

  segs[Segment_count + 1].x1 = (short) x1;
  segs[Segment_count + 1].x2 = (short) x1;
  segs[Segment_count + 1].y1 = (short) y1;
  segs[Segment_count + 1].y2 = (short) y2;

  segs[Segment_count + 2].x1 = (short) x1;
  segs[Segment_count + 2].x2 = (short) x2;
  segs[Segment_count + 2].y1 = (short) y2;
  segs[Segment_count + 2].y2 = (short) y2;

  segs[Segment_count + 3].x1 = (short) x2;
  segs[Segment_count + 3].x2 = (short) x2;
  segs[Segment_count + 3].y1 = (short) y2;
  segs[Segment_count + 3].y2 = (short) y1;

  Segment_count += 4;
}

/*-------------------------------------------------------------------------*/

/***************************************************/
/* */
/* Draw_dyn_lower_right_box() */
/* */
/***************************************************/

/* ARGSUSED */
static void Draw_dyn_lower_right_box (Window window,
                                      int x1,
                                      int y1,
                                      int x2,
                                      int y2)
{
  segs[Segment_count].x1 = (short) (x1 + 1);
  segs[Segment_count].x2 = (short) (x2 + 1);
  segs[Segment_count].y1 = (short) y2;
  segs[Segment_count].y2 = (short) y2;

  segs[Segment_count + 1].x1 = (short) x2;
  segs[Segment_count + 1].x2 = (short) x2;
  segs[Segment_count + 1].y1 = (short) y2;
  segs[Segment_count + 1].y2 = (short) (y1 + 1);

  Segment_count += 2;
}

/*-----------------------------------------------------------------------*/

/**************************************************/
/* */
/* Draw_dyn_upper_left_box() */
/* */
/**************************************************/

/* ARGSUSED */
static void Draw_dyn_upper_left_box (Window window,
                                     int x1,
                                     int y1,
                                     int x2,
                                     int y2)
{
  segs[Segment_count].x1 = (short) x1;
  segs[Segment_count].x2 = (short) x2;
  segs[Segment_count].y1 = (short) y1;
  segs[Segment_count].y2 = (short) y1;

  segs[Segment_count + 1].x1 = (short) x1;
  segs[Segment_count + 1].x2 = (short) x1;
  segs[Segment_count + 1].y1 = (short) (y1 + 1);
  segs[Segment_count + 1].y2 = (short) y2;

  Segment_count += 2;
}

/*-------------------------------------------------------------------------*/

/**************************************************/
/* */
/* Draw_dyn_lower_left_box() */
/* */
/**************************************************/

/* ARGSUSED */
static void Draw_dyn_lower_left_box (Window window,
                                     int x1,
                                     int y1,
                                     int x2,
                                     int y2)
{
  segs[Segment_count].x1 = (short) x1;
  segs[Segment_count].x2 = (short) x1;
  segs[Segment_count].y1 = (short) (y1 + 1);
  segs[Segment_count].y2 = (short) y2;

  segs[Segment_count + 1].x1 = (short) x1;
  segs[Segment_count + 1].x2 = (short) (x2 - 1);
  segs[Segment_count + 1].y1 = (short) y2;
  segs[Segment_count + 1].y2 = (short) y2;

  Segment_count += 2;
}

/*-------------------------------------------------------------------------*/

/**************************************************/
/* */
/* Draw_dyn_upper_right_box() */
/* */
/**************************************************/

/* ARGSUSED */
static void Draw_dyn_upper_right_box (Window window,
                                      int x1,
                                      int y1,
                                      int x2,
                                      int y2)
{
  segs[Segment_count].x1 = (short) (x1 + 1);
  segs[Segment_count].x2 = (short) x2;
  segs[Segment_count].y1 = (short) y1;
  segs[Segment_count].y2 = (short) y1;

  segs[Segment_count + 1].x1 = (short) x2;
  segs[Segment_count + 1].x2 = (short) x2;
  segs[Segment_count + 1].y1 = (short) y1;
  segs[Segment_count + 1].y2 = (short) (y2 - 1);

  Segment_count += 2;
}

/*-------------------------------------------------------------------------*/

/******************************************************/
/* */
/* Draw_dyn_leave_out_top_box() */
/* */
/******************************************************/

/* ARGSUSED */
static void Draw_dyn_leave_out_top_box (Window window,
                                        int x1,
                                        int y1,
                                        int x2,
                                        int y2)
{
  segs[Segment_count].x1 = (short) x1;
  segs[Segment_count].x2 = (short) (x2 + 1);
  segs[Segment_count].y1 = (short) y2;
  segs[Segment_count].y2 = (short) y2;

  segs[Segment_count + 1].x1 = (short) x2;
  segs[Segment_count + 1].x2 = (short) x2;
  segs[Segment_count + 1].y1 = (short) y1;
  segs[Segment_count + 1].y2 = (short) y2;

  segs[Segment_count + 2].x1 = (short) x1;
  segs[Segment_count + 2].x2 = (short) x1;
  segs[Segment_count + 2].y1 = (short) y1;
  segs[Segment_count + 2].y2 = (short) y2;

  Segment_count += 3;
}

/*-------------------------------------------------------------------------*/

void CreateBlankCursor (Display *display,
                        Window window)
{
  XColor fore, exact;
  Pixmap pixSrc = XCreatePixmap (display, window, 1, 1, 1),
      pixMask = XCreatePixmap (display, window, 1, 1, 1);

  XAllocNamedColor (display, DefaultColormap(display, 0), "black",
      &fore, &exact);

  curs = XCreatePixmapCursor (display, pixSrc, pixMask, &fore, &fore,
      0, 0);
}

/***********************************************************************/
/* */
/* Calculate_text_size */
/* */
/***********************************************************************/

void Calculate_text_size (char string[2000],
                          char fontname[2000],
                          float bodysize,
                          int *width,
                          int *height)
{
  Font text_font;
  char t_str[2000];
  int x, i;
  float dummy_float;
  int num_lines;
  int longest_length;
  int offset, line_start;
  int ht, wd, ls, font_type;

  /*******************************************************************/
  /* */
  /* First calculate the number of lines from how many \n characters */
  /* are in the string + 1. */
  /* */
  /*******************************************************************/

  x = strlen (string);
  num_lines = 1;
  longest_length = 0;

  if (x == 0) /* NULL string */
  {
    *width = 1;
    *height = 1;
    return;
  }

  for (i = 0; i < x; i++)
    if (string[i] == '\n')
      num_lines++;

  /****************************************/
  /* */
  /* Calculate the font_id for the font */
  /* */
  /****************************************/

  _FI_find_font_id (fontname, bodysize, &text_font, &dummy_float, FI_TEXT, &font_type);

  /*****************************************************************/
  /* */
  /* Loop through all the lines, and remember which one has the */
  /* longest length. */
  /* */
  /*****************************************************************/

  line_start = 0;
  offset = 0;

  for (i = 0; i < num_lines; i++)
  {
    while ((string[offset] != '\n') && (string[offset] != '\0'))
      offset++;

    if (offset != line_start)
    {
      strcpy (t_str, &(string[line_start]));
      t_str[offset - line_start] = '\0';

      _FI_calc_text (text_font, t_str, strlen (t_str), &ht, &wd, &ls, font_type);

      if (wd > longest_length)
        longest_length = wd;
    }
    line_start = offset++;
  }

  *height = ls - (ls / MLT_DIVISOR);
  *height = *height * num_lines;

  *width = longest_length;
}

/*--------------------------------------------------------------------------*/

void FB_mlt_draw (Window window,
                  Font font_id,
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
  FI_calc_text (font_id, "M", 1, &font_height, &font_width, &line_space, font_type);

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
        FI_calc_text (font_id, text, text_length, &font_height, 
            &font_width, &dummy, font_type);

        new_x = center_x - (font_width / 2);
      }
      else
      {
        FI_calc_text (font_id, text, text_length,
            &font_height, &font_width, &dummy, font_type);

        new_x = xpos + max_width - font_width;
      }

      if (font_type == 0)
         XDrawString (display, window, dyn_GC,
             new_x, new_y + font_height,
             text, text_length);
      else
      {
	  FSXDrawText (display, DefaultScreen(display),
                                window, dyn_GC, font_id, text, text_length,
				(double)new_x,
			        (double)(new_y + font_height), 
				&dummy_double, &dummy_double);

          /* restore the line settings for the GC */

/*
          XSetLineAttributes (display, dyn_GC, 1, LineSolid, CapButt, JoinMiter);
*/
          XSetFillStyle (display, dyn_GC, FillSolid);
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

#ifdef THIS_IS_NEVER_REFERENCED
/**********************************************************************/
/* */
/* Refresh_window() */
/* */
/* Routine used to force the refresh of a window, much like */
/* FIf_display() does in the I/FORMS world. */
/* */
/**********************************************************************/

static void Refresh_window (Window window)
{
  XEvent my_event;
  int xsize, ysize;

  my_event.type = Expose;
  my_event.xexpose.type = Expose;
  my_event.xexpose.serial = 0;
  my_event.xexpose.send_event = False;
  my_event.xexpose.display = display;
  my_event.xexpose.window = window;
  my_event.xexpose.x = 0;
  my_event.xexpose.y = 0;
  my_event.xexpose.count = 0;

  FIf_get_size (work_form, &xsize, &ysize);
  my_event.xexpose.width = xsize;
  my_event.xexpose.height = ysize;

  XSendEvent (display, window, True, ExposureMask, &my_event);
}
#endif

/**********************************************************************/
/* */
/* Draw_boundary_areas() */
/* */
/* If boundary display is enabled, this function will be called */
/* prior to each dynamic placement of a gadget. All existing */
/* gadgets on the form which are displayed will have a boundary box */
/* drawn around them. Gadgets whose boundary boxes intersect others */
/* will be drawn in red and will have a dashed appearance. Gadgets */
/* whose boundary boxes do not intersect other boxes will be drawn */
/* in green and will be given a dotted appearance. */
/* */
/* Mack Draper 8/21/90 */
/* */
/**********************************************************************/

static void Draw_boundary_areas(void)
{
  struct boundary_struct
  {
    int gadget;
    int xlo;
    int ylo;
    int xhi;
    int yhi;
    int intersect_flag;
  } bound_list[2000];

  int Total_bound_gadgets;
  int status, x, y, xsize, ysize;
  float value;
  int red, green;
  int dotted, dashed;
  int attr;
  int gdt_type;

  long attr2;
  int (*my_translate_color)();

  /***********************************************************************/
  /* */
  /* Calculate the size of each displayed gadget here, so that you don't */
  /* have to do it later. */
  /* */
  /* This will have to be expanded later for field gadgets, since */
  /* FIg_get_size is not guaranteed to return the correct size for */
  /* field gadgets. */
  /* */
  /***********************************************************************/

  XSetSubwindowMode (display, xfb_GC, IncludeInferiors);

  for (x = 0; x < 2000; x++)
    bound_list[x].intersect_flag = 0;

  Total_bound_gadgets = 0;
  for (x = 11; x < 1000; x++)
  {
    FIg_get_type (work_form, x, &gdt_type);
    status = FIg_get_attr (work_form, x, &attr);
    if ((status == FI_SUCCESS) &&
        ((attr & FI_NOT_DISPLAYED) == 0) &&
        (gdt_type != FI_GROUP))

    {
      bound_list[Total_bound_gadgets].gadget = x;
      FIg_get_location (work_form, x, &(bound_list[Total_bound_gadgets].xlo),
          &(bound_list[Total_bound_gadgets].ylo));
      FIg_get_size (work_form, x, &xsize, &ysize);

      bound_list[Total_bound_gadgets].xhi =
          bound_list[Total_bound_gadgets].xlo + xsize;
      bound_list[Total_bound_gadgets].yhi =
          bound_list[Total_bound_gadgets].ylo + ysize;

      value = dpb.expansion2 / 100.0; /* X factor */
      xsize = (int)(xsize * value);
      value = dpb.expansion3 / 100.0; /* Y factor */
      ysize = (int)(ysize * value);

      bound_list[Total_bound_gadgets].xlo -= xsize / 2;
      bound_list[Total_bound_gadgets].ylo -= ysize / 2;
      bound_list[Total_bound_gadgets].xhi += xsize / 2;
      bound_list[Total_bound_gadgets].yhi += ysize / 2;
      bound_list[Total_bound_gadgets].intersect_flag = 0; /* No intersect */
      Total_bound_gadgets++;

      /*************************************************************/
      /* */
      /* If the gadget is a field, then check to see if it has an */
      /* associated list displayed. If so record its size. */
      /* */
      /*************************************************************/

      if (gdt_type == FI_FIELD)
      {
        FIfld_get_attr (work_form, x, 0, &attr2);

        if ((attr2 & FI_ASSOCIATED_LIST) &&
            (!(attr2 & FI_POPUP_ASSO_LIST)))
        {
          FIfld_get_list_location (work_form, x, 0,
              &(bound_list[Total_bound_gadgets].xlo),
              &(bound_list[Total_bound_gadgets].ylo));
          FIfld_get_list_size (work_form, x, 0, &xsize, &ysize);

          bound_list[Total_bound_gadgets].xhi =
              bound_list[Total_bound_gadgets].xlo + xsize;
          bound_list[Total_bound_gadgets].yhi =
              bound_list[Total_bound_gadgets].ylo + ysize;

          value = dpb.expansion2 / 100.0; /* X factor */
          xsize = (int)(xsize * value);
          value = dpb.expansion3 / 100.0; /* Y factor */
          ysize = (int)(ysize * value);

          bound_list[Total_bound_gadgets].xlo -= xsize / 2;
          bound_list[Total_bound_gadgets].ylo -= ysize / 2;
          bound_list[Total_bound_gadgets].xhi += xsize / 2;
          bound_list[Total_bound_gadgets].yhi += ysize / 2;
          bound_list[Total_bound_gadgets].intersect_flag = 0;
          Total_bound_gadgets++;
        }
      }
    }
  }

  /**********************************************************************/
  /* */
  /* Now loop through all of the displayed gadgets and identify those */
  /* whose boundaries overlap. */
  /* */
  /**********************************************************************/

  if (Total_bound_gadgets > 1)
  {
    for (x = 0; x < (Total_bound_gadgets - 1); x++)
    {
      int xlo1, ylo1, xhi1, yhi1;

      xlo1 = bound_list[x].xlo;
      ylo1 = bound_list[x].ylo;
      xhi1 = bound_list[x].xhi;
      yhi1 = bound_list[x].yhi;

      for (y = x + 1; y < Total_bound_gadgets; y++)
      {
        int xlo2, ylo2, xhi2, yhi2;

        xlo2 = bound_list[y].xlo;
        ylo2 = bound_list[y].ylo;
        xhi2 = bound_list[y].xhi;
        yhi2 = bound_list[y].yhi;

        if (((xlo1 >= xlo2) && (xlo1 <= xhi2)) ||
            ((xhi1 >= xlo2) && (xhi1 <= xhi2)) ||
            ((xlo1 >= xlo2) && (xhi1 <= xhi2)) ||
            ((xlo2 >= xlo1) && (xhi2 <= xhi1)))

          if (((ylo1 >= ylo2) && (ylo1 <= yhi2)) ||
              ((yhi1 >= ylo2) && (yhi1 <= yhi2)) ||
              ((ylo1 >= ylo2) && (yhi1 <= yhi2)) ||
              ((ylo2 >= ylo1) && (yhi2 <= yhi1)))
          {
            bound_list[x].intersect_flag = 1;
            bound_list[y].intersect_flag = 1;
          }
      }
    }
  }

  /*********************************************************************/
  /* */
  /* Now Draw the borders, with color and line style being dependant */
  /* on whether the boundary intersects or not. */
  /* */
  /*********************************************************************/

  FI_get_env (FI_TRANSLATE_COLOR, &my_translate_color);
  red = (*my_translate_color)( 0, FI_RED );
  green = (*my_translate_color)( 0, FI_GREEN );

  dotted = 0x5555;
  dashed = 0xCCCC;

  if (Total_bound_gadgets > 0)
  {
    Window window;

    FIf_get_window (work_form, &window);

    for (x = 0; x < Total_bound_gadgets; x++)
    {
      if (bound_list[x].intersect_flag == 0)
      {
        XSetForeground (display, xfb_GC, green);
        XSetLineAttributes (display, xfb_GC, 0, LineSolid, CapButt,
            JoinRound);
      }
      else
      {
        XSetForeground (display, xfb_GC, red);
        XSetLineAttributes (display, xfb_GC, 0, LineOnOffDash, CapButt,
            JoinRound);
      }

      segs[Segment_count].x1 = (short) bound_list[x].xlo;
      segs[Segment_count].y1 = (short) bound_list[x].ylo;
      segs[Segment_count].x2 = (short) bound_list[x].xhi;
      segs[Segment_count].y2 = (short) bound_list[x].ylo;

      segs[Segment_count + 1].x1 = (short) bound_list[x].xhi;
      segs[Segment_count + 1].y1 = (short) bound_list[x].ylo;
      segs[Segment_count + 1].x2 = (short) bound_list[x].xhi;
      segs[Segment_count + 1].y2 = (short) bound_list[x].yhi;

      segs[Segment_count + 2].x1 = (short) bound_list[x].xhi;
      segs[Segment_count + 2].y1 = (short) bound_list[x].yhi;
      segs[Segment_count + 2].x2 = (short) bound_list[x].xlo;
      segs[Segment_count + 2].y2 = (short) bound_list[x].yhi;

      segs[Segment_count + 3].x1 = (short) bound_list[x].xlo;
      segs[Segment_count + 3].y1 = (short) bound_list[x].yhi;
      segs[Segment_count + 3].x2 = (short) bound_list[x].xlo;
      segs[Segment_count + 3].y2 = (short) bound_list[x].ylo;

      XDrawSegments(display, window, xfb_GC, segs, 4);
    }
    XFlush (display);
    Segment_count = 0;
  }
}


/**************************************************************************/
/* */
/* Get_first_point() */
/* */
/* This function is used to obtain a data point inside the specified */
/* form window. It accomplishes this by drawing two perpendicular lines */
/* which meet at the data point in question. As the mouse moves, these */
/* lines are constantly updated. If the mouse ever leaves the form, then */
/* the lines are immediately erased, and the cursor reappears. */
/* */
/* This routine is commonly used with the second function contained */
/* in this file. In such cases this function is used to anchor the */
/* upper left hand corner of a rectangular box. The second function */
/* serves to locate the lower right hand corner of the box. Its name is */
/* Get_second_point(). Imagine that. */
/* */
/* By the way, this function returns an integer value of two to */
/* indicate success and a value of one to indicate that the operator */
/* wishes to terminate the command instead of entering a data point. */
/* */
/**************************************************************************/

/* ARGSUSED */
int Get_first_point (Window window,
                     int * x_pos,
                     int * y_pos,
                     int box_x,
                     int box_y,
                     int offset_x,
                     int offset_y)
{
  /* initialize to 0 to avoid ANSI warning */
  int x_line_ptr=0;
  int y_line_ptr=0;

  int x_max, y_max, x, y;
  int done;

  int old_x, old_y;
  char t_str[2000];
  /* change from int to Window for ANSI use of XQueryPointer() */
  Window root, child;
  /* change from int to unsigned int for ANSI use of XQueryPointer() */
  unsigned int flags;


  int root_x, root_y;
  int win_x, win_y;

  /* initialize to 0 to avoid ANSI warning */
  int x_bound=0, y_bound=0;

  float value;
  int xsize, ysize, grab;

  XEvent event;
  Window form_window;

  int not_initial_draw = 0;


  FIf_get_size (work_form, &form_width, &form_height);
  x_max = form_width;
  y_max = form_height;

  form_window = window;

  if (!curs)
    CreateBlankCursor (display, form_window);

  grab = XGrabPointer (display, form_window, True,
      (unsigned int)(PointerMotionMask | PointerMotionHintMask),
      GrabModeAsync, GrabModeAsync, form_window, curs, CurrentTime);

  done = !(grab == GrabSuccess);

  old_x = 0;
  old_y = 0;

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    Draw_boundary_areas();
    XFlush (display);

    value = ((dpb.expansion2 / 100.0) * box_x) / 2.0;
    x_bound = (int)value;

    value = ((dpb.expansion3 / 100.0) * box_y) / 2.0;
    y_bound = (int)value;
  }

  while (done == 0)
  {
    XNextEvent (display, &event);

    switch (event.type)
    {
    case MotionNotify:
      while (XCheckMaskEvent (display, PointerMotionMask, &event));
      /*** Remove all from queue ***/

      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &win_x, &win_y, &flags);
      break;

    case ButtonPress:
      if (event.xbutton.button == Button2)
      {
        XQueryPointer (display, form_window, &root, &child,
            &root_x, &root_y, &win_x, &win_y, &flags);

        if ((win_x >= 0) && (win_x < x_max) &&
            (win_y >= 0) && (win_y < y_max))
        {
          if (dpb.grid_flag == 1)
          {
            win_x = ((win_x - offset_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_x += offset_x;
            win_y = ((win_y - offset_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_y += offset_y;
          }

          *x_pos = win_x;
          *y_pos = win_y;
          done = 2; /* success */
        }
      }
      else if (event.xbutton.button == Button3)
      {
        done = 1; /* User aborted command */
      }
      break;

    default : /* Needed to process Button Release from push button */
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
    }

    while (XCheckMaskEvent (display, ExposureMask, &event))
    {
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
    }

    if (done == 0)
    {
      Segment_count = 0;

      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &x, &y, &flags);

      if ((x >= 0) && (x < x_max) && /* Cursor inside window */
      (y >= 0) && (y < y_max))
      {
        if (dpb.grid_flag == 1)
        {
          x = ((x - offset_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
          x += offset_x;
          y = ((y - offset_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
          y += offset_y;
        }

        if ((x != old_x) ||
            (y != old_y))
        {
          if (not_initial_draw)
          {
            /* Erase crosshairs */
            Draw_crosshairs (form_window, old_x - offset_x,
                old_y - offset_y);
            if (box_x != 0)
              Draw_dyn_lower_right_box (window,
                  old_x - offset_x, old_y - offset_y,
                  old_x - offset_x + box_x, old_y - offset_y + box_y);

            if ((dpb.expansion4 == 1) && /* boundary display enabled */
            (box_x != 0) && (box_y != 0))
            {
              Draw_dyn_box (window, x_line_ptr - offset_x - x_bound,
                  y_line_ptr - offset_y - y_bound,
                  x_line_ptr - offset_x + box_x + x_bound,
                  y_line_ptr - offset_y + box_y + y_bound);
            }
          }
          x_line_ptr = x;
          y_line_ptr = y;

          old_x = x;
          old_y = y;

          not_initial_draw = 1;

          /* Display dynamics */

          Draw_crosshairs (form_window, old_x - offset_x,
              old_y - offset_y);
          if (box_x != 0)
            Draw_dyn_lower_right_box (window,
                old_x - offset_x, old_y - offset_y,
                old_x - offset_x + box_x, old_y - offset_y + box_y);

          if ((dpb.expansion4 == 1) && /* boundary display enabled */
          (box_x != 0) && (box_y != 0))
          {
            Draw_dyn_box (window, x_line_ptr - offset_x - x_bound,
                y_line_ptr - offset_y - y_bound,
                x_line_ptr - offset_x + box_x + x_bound,
                y_line_ptr - offset_y + box_y + y_bound);
          }

          XDrawSegments(display, form_window, dyn_GC, segs, Segment_count);
          Segment_count = 0;
          XFlush (display);

          UMSGetByNum (t_str, FB_I_XY, "%d%d", x - offset_x,
              y - offset_y);
          FIfld_set_text (Message_form, 44, 0, 0, t_str, 0);
        }
      }
    }
  }

  /* Erase existing lines */

  Draw_crosshairs (form_window, old_x - offset_x, old_y - offset_y);

  if (box_x != 0)
    Draw_dyn_lower_right_box (window,
        old_x - offset_x, old_y - offset_y,
        old_x - offset_x + box_x, old_y - offset_y + box_y);

  if ((dpb.expansion4 == 1) && /* boundary display enabled */
  (box_x != 0) && (box_y != 0))
  {
    Draw_dyn_box (window, x_line_ptr - offset_x - x_bound,
        y_line_ptr - offset_y - y_bound,
        x_line_ptr - offset_x + box_x + x_bound,
        y_line_ptr - offset_y + box_y + y_bound);
  }
  XDrawSegments(display, form_window, dyn_GC, segs, Segment_count);
  Segment_count = 0;
  XFlush (display);

  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  while (XCheckMaskEvent (display, ButtonPressMask | ButtonReleaseMask, &event))
  {
    /* Eat all button related events */
  }

  if ((dpb.expansion4 == 1) &&
      (work_form != NULL))
  {
    FIf_get_size (work_form, &xsize, &ysize);
    FIf_paint_area (work_form, 0, 0, xsize, ysize);
  }

  if (grab == GrabSuccess)
    XUngrabPointer (display, CurrentTime);

  return (done);
}

/**************************************************************************/
/* */
/* Get_second_point() */
/* */
/* This function is used to obtain a data point inside the specified */
/* form window. It accomplishes this by drawing a box figure inside */
/* the specified window. One point of the box is anchored and must be */
/* specified as an input coordinate pair. */
/* */
/* The other point is obtained by tracking the mouse and returning */
/* its position when the middle mouse button is clicked. While the */
/* mouse is being positioned, a dynamic box will be drawn with the */
/* current mouse point and the anchor point serving as diagonal corners */
/* of the box. */
/* */
/* By the way, this function returns an integer value of two to */
/* indicate success and a value of one to indicate that the operator */
/* wishes to terminate the command instead of entering a data point. */
/* */
/**************************************************************************/

/* ARGSUSED */
int Get_second_point(Window window,
                     int anchor_x,
                     int anchor_y,
                     int * x_low,
                     int * y_low,
                     int * x_high,
                     int * y_high,
                     int width,
                     int style)
{
  int x_line_ptr;
  int y_line_ptr;
  int x_max, y_max, x, y;
  int done;

  int old_x, old_y;
  char t_str[2000];

  /* initialize to 0 to avoid ANSI warning */
  int x_hi=0, x_lo=0, y_hi=0, y_lo=0;

  /* change from int to Window for ANSI use of XQueryPointer() */
  Window root, child;
  /* change from int to unsigned int for ANSI use of XQueryPointer() */
  unsigned int flags;
  XWindowAttributes window_attr;
  int root_x, root_y;
  int win_x, win_y;

  XEvent event;
  int x_bound, y_bound;
  float value;
  int xsize, ysize;
  int grab;
  Window form_window;
  int not_initial_draw = 0;

  old_x = 0;
  old_y = 0;

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    Draw_boundary_areas();
    XFlush (display);
  }

  form_window = window;

  XGetWindowAttributes (display, form_window, &window_attr);
  x_max = window_attr.width;
  y_max = window_attr.height;

  grab = XGrabPointer (display, form_window, True,
      (unsigned int)(PointerMotionMask | PointerMotionHintMask),
      GrabModeAsync, GrabModeAsync, form_window, curs, CurrentTime);

  done = !(grab == GrabSuccess);

  while (done == 0)
  {
    XNextEvent (display, &event);

    if (event.type == MotionNotify)
    {
      while (XCheckMaskEvent (display, PointerMotionMask, &event));
      /*** Remove all from queue ***/
      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &win_x, &win_y, &flags);
    }
    else if (event.type == ButtonPress)
    {
      if (event.xbutton.button == Button2)
      {
        XQueryPointer (display, form_window, &root, &child,
            &root_x, &root_y, &win_x, &win_y, &flags);

        if ((win_x >= 0) && (win_x < x_max) &&
            (win_y >= 0) && (win_y < y_max))
        {
          if (dpb.grid_flag == 1)
          {
            x = (win_x / dpb.grid_sub_units) * dpb.grid_sub_units;
            y = (win_y / dpb.grid_sub_units) * dpb.grid_sub_units;
          }

          if (x >= anchor_x)
          {
            x_lo = anchor_x;
            x_hi = x;
          }
          else
          {
            x_lo = x;
            x_hi = anchor_x;
          }

          if (y >= anchor_y)
          {
            y_lo = anchor_y;
            y_hi = y;
          }
          else
          {
            y_lo = y;
            y_hi = anchor_y;
          }

          *x_low = x_lo;
          *y_low = y_lo;
          *x_high = x_hi;
          *y_high = y_hi;

          done = 2; /* success */
        }
      }
      else if (event.xbutton.button == Button3)
      {
        done = 1; /* User aborted command */
      }
    }
    else
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */

    while (XCheckMaskEvent (display, ExposureMask, &event))
    {
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
    }

    if (done == 0)
    {
      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &x, &y, &flags);

      if ((x >= 0) && (x < x_max) && /* Cursor inside window */
      (y >= 0) && (y < y_max))
      {
        if (dpb.grid_flag == 1)
        {
          x = (x / dpb.grid_sub_units) * dpb.grid_sub_units;
          y = (y / dpb.grid_sub_units) * dpb.grid_sub_units;
        }

        if ((x != old_x) ||
            (y != old_y))
        {
          if (not_initial_draw) /* Erase current dynamics */
          {
            Draw_crosshairs (form_window, old_x, old_y);

            if ((x_lo == anchor_x) &&
                (y_lo == anchor_y))
              Draw_dyn_upper_left_box (form_window,
                  x_lo, y_lo, x_hi, y_hi);

            if ((x_lo == anchor_x) &&
                (y_lo < anchor_y))
              Draw_dyn_lower_left_box (form_window,
                  x_lo, y_lo, x_hi, y_hi);

            if ((x_lo < anchor_x) &&
                (y_lo == anchor_y))
              Draw_dyn_upper_right_box (form_window,
                  x_lo, y_lo, x_hi, y_hi);

            if ((x_lo < anchor_x) &&
                (y_lo < anchor_y))
              Draw_dyn_lower_right_box (form_window,
                  x_lo, y_lo, x_hi, y_hi);

            if (dpb.expansion4 == 1) /* boundary mode set */
            {
              value = ((dpb.expansion2 / 100.0) * (x_hi - x_lo)) / 2.0;
              x_bound = (int)value;

              value = ((dpb.expansion3 / 100.0) * (y_hi - y_lo)) / 2.0;
              y_bound = (int)value;

              Draw_dyn_box (window, x_lo - x_bound, y_lo - y_bound,
                  x_hi + x_bound, y_hi + y_bound);
            }
          }
          not_initial_draw = 1;

          x_line_ptr = x;
          y_line_ptr = y;

          old_x = x;
          old_y = y;

          if (x >= anchor_x)
          {
            x_lo = anchor_x;
            x_hi = x;
          }
          else
          {
            x_lo = x;
            x_hi = anchor_x;
          }

          if (y >= anchor_y)
          {
            y_lo = anchor_y;
            y_hi = y;
          }
          else
          {
            y_lo = y;
            y_hi = anchor_y;
          }

          /* Draw current dynamics */

          Draw_crosshairs (form_window, old_x, old_y);

          if ((x_lo == anchor_x) &&
              (y_lo == anchor_y))
            Draw_dyn_upper_left_box (form_window,
                x_lo, y_lo, x_hi, y_hi);

          if ((x_lo == anchor_x) &&
              (y_lo < anchor_y))
            Draw_dyn_lower_left_box (form_window,
                x_lo, y_lo, x_hi, y_hi);

          if ((x_lo < anchor_x) &&
              (y_lo == anchor_y))
            Draw_dyn_upper_right_box (form_window,
                x_lo, y_lo, x_hi, y_hi);

          if ((x_lo < anchor_x) &&
              (y_lo < anchor_y))
            Draw_dyn_lower_right_box (form_window,
                x_lo, y_lo, x_hi, y_hi);

          if (dpb.expansion4 == 1) /* boundary mode set */
          {
            value = ((dpb.expansion2 / 100.0) * (x_hi - x_lo)) / 2.0;
            x_bound = (int)value;

            value = ((dpb.expansion3 / 100.0) * (y_hi - y_lo)) / 2.0;
            y_bound = (int)value;

            Draw_dyn_box (window, x_lo - x_bound, y_lo - y_bound,
                x_hi + x_bound, y_hi + y_bound);
          }

          XDrawSegments (display, form_window, dyn_GC, segs, Segment_count);
          Segment_count = 0;
          XFlush (display);

          UMSGetByNum (t_str, FB_I_XY, "%d%d", x, y);
          FIfld_set_text (Message_form, 44, 0, 0, t_str, 0);
        }
      }
    }
  }

  /* Erase existing lines */

  Draw_crosshairs (form_window, old_x, old_y);

  if ((x_lo == anchor_x) &&
      (y_lo == anchor_y))
    Draw_dyn_upper_left_box (form_window,
        x_lo, y_lo, x_hi, y_hi);

  if ((x_lo == anchor_x) &&
      (y_lo < anchor_y))
    Draw_dyn_lower_left_box (form_window,
        x_lo, y_lo, x_hi, y_hi);

  if ((x_lo < anchor_x) &&
      (y_lo == anchor_y))
    Draw_dyn_upper_right_box (form_window,
        x_lo, y_lo, x_hi, y_hi);

  if ((x_lo < anchor_x) &&
      (y_lo < anchor_y))
    Draw_dyn_lower_right_box (form_window,
        x_lo, y_lo, x_hi, y_hi);

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    value = ((dpb.expansion2 / 100.0) * (x_hi - x_lo)) / 2.0;
    x_bound = (int)value;

    value = ((dpb.expansion3 / 100.0) * (y_hi - y_lo)) / 2.0;
    y_bound = (int)value;

    Draw_dyn_box (window, x_lo - x_bound, y_lo - y_bound,
        x_hi + x_bound, y_hi + y_bound);
  }

  XDrawSegments (display, form_window, dyn_GC, segs, Segment_count);
  Segment_count = 0;
  XFlush (display);

  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  while (XCheckMaskEvent (display, ButtonPressMask | ButtonReleaseMask, &event))
  {
    /* Eat all button related events */
  }

  if ((dpb.expansion4 == 1) &&
      (work_form != NULL))
  {
    FIf_get_size (work_form, &xsize, &ysize);
    FIf_paint_area (work_form, 0, 0, xsize, ysize);
  }

  if (grab == GrabSuccess)
    XUngrabPointer (display, CurrentTime);

  return (done);
}

/**************************************************************************/
/* */
/* Move_field_box() */
/* */
/* This function is used to obtain a data point inside the specified */
/* form window. It accomplishes this by drawing a box figure inside */
/* the specified window. The size of the field box is known in advance */
/* as well as whether it has an associated list icon, vertical scroll bar */
/* or horizontal scroll buttons. The field will be moved around without */
/* ever changing size. */
/* */
/* By the way, this function returns an integer value of two to */
/* indicate success and a value of one to indicate that the operator */
/* wishes to terminate the command instead of entering a data point. */
/* */
/**************************************************************************/

/* ARGSUSED */
int Move_field_box (Window window,
                    int *x_pos,
                    int *y_pos,
                    int x_size,
                    int y_size,
                    int offset_x,
                    int offset_y,
                    int single_line_mode,
                    int horz_flag,
                    int vert_flag,
                    int icon_flag)
{
  int x_max, y_max, x, y;
  int done;
  int old_x, old_y;
  char t_str[2000];

  /* initialize to 0 to avoid ANSI warning */
  int x_hi=0, x_lo=0, y_hi=0, y_lo=0;

  int icon_size;
  int vert_size;

  /* change from int to Window for ANSI use of XQueryPointer() */
  Window root, child;
  /* change from int to unsigned int for ANSI use of XQueryPointer() */
  unsigned int flags;

  int root_x, root_y;
  int win_x, win_y;

  /* initialize to 0 to avoid ANSI warning */
  int x_bound=0, y_bound=0;
  int actual_xsize=0, actual_ysize=0;

  float value;
  XEvent event;
  int xsize, ysize;
  Window form_window;
  int grab;
  int not_initial_draw = 0;

  FIf_get_size (work_form, &form_width, &form_height);
  x_max = form_width;
  y_max = form_height;

/*    These adjustments were made for Motif field gadgets  GMD 9/30/91
  x_size += 10;
  y_size += 4;
*/
  if (icon_flag)
    icon_size = 12;
  else
    icon_size = 0;

  if (vert_flag)
    vert_size = 15;
  else
    vert_size = 0;

  FIf_get_window (work_form, &form_window);

  if (!curs)
    CreateBlankCursor (display, form_window);

  grab = XGrabPointer (display, form_window, True,
      (unsigned int)(PointerMotionMask | PointerMotionHintMask),
      GrabModeAsync, GrabModeAsync, form_window, curs, CurrentTime);

  done = !(grab == GrabSuccess);

  old_x = 0;
  old_y = 0;

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    Draw_boundary_areas();
    XFlush (display);

    actual_xsize = x_size;
    actual_ysize = y_size;

    if (horz_flag)
      actual_ysize += 15;

    if (icon_flag)
      actual_xsize += 12;

    if (vert_flag)
      actual_xsize += 15;

    value = ((dpb.expansion2 / 100.0) * actual_xsize) / 2.0;
    x_bound = (int)value;
    value = ((dpb.expansion3 / 100.0) * actual_ysize) / 2.0;
    y_bound = (int)value;
  }

  while (done == 0)
  {
    XNextEvent (display, &event);

    switch (event.type)
    {
    case MotionNotify:
      while (XCheckMaskEvent (display, PointerMotionMask, &event));
      /*** Remove all from queue ***/

      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &win_x, &win_y, &flags);
      break;

    case ButtonPress:
      if (event.xbutton.button == Button2)
      {
        XQueryPointer (display, form_window, &root, &child,
            &root_x, &root_y, &win_x, &win_y, &flags);

        if ((win_x >= 0) && (win_x < x_max) &&
            (win_y >= 0) && (win_y < y_max))
        {
          if (dpb.grid_flag == 1)
          {
            win_x = ((win_x - offset_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_x += offset_x;
            win_y = ((win_y - offset_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_y += offset_y;
          }

          *x_pos = win_x;
          *y_pos = win_y;
          done = 2; /* success */
        }
      }
      else if (event.xbutton.button == Button3)
      {
        done = 1; /* User aborted command */
      }
      break;
    }

    while (XCheckMaskEvent (display, ExposureMask, &event))
    {
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
    }

    if (done == 0)
    {
      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &x, &y, &flags);

      if (dpb.grid_flag == 1)
      {
        x = ((x - offset_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
        x += offset_x;
        y = ((y - offset_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
        y += offset_y;
      }

      x_lo = old_x - offset_x;
      x_hi = old_x - offset_x + x_size;
      y_lo = old_y - offset_y;
      y_hi = old_y - offset_y + y_size;

      if ((x != old_x) ||
          (y != old_y))
      {
        if (not_initial_draw)
        {
          /* erase current position */

          Draw_crosshairs (form_window, old_x - offset_x, old_y - offset_y);

          Draw_dyn_lower_right_box (form_window, x_lo, y_lo, x_hi, y_hi);

          if (icon_flag)
          {
            Draw_dyn_lower_right_box (form_window, x_hi, y_lo, x_hi + 12, y_hi);
          }

          if (horz_flag)
          {
            Draw_dyn_lower_right_box (form_window, x_lo, y_hi,
                (x_lo + (x_hi - x_lo + icon_size)),
                y_hi + 15);
          }

          if (vert_flag)
          {
            Draw_dyn_lower_right_box (form_window, x_hi + icon_size, y_lo,
                x_hi + icon_size + vert_size, y_hi);
          }

          if (dpb.expansion4 == 1) /* boundary mode set */
          {
            Draw_dyn_box (form_window,
                old_x - offset_x - x_bound, old_y - offset_y - y_bound,
                old_x - offset_x + actual_xsize + x_bound,
                old_y - offset_y + actual_ysize + y_bound);
          }
        }
        not_initial_draw = 1;

        old_x = x;
        old_y = y;

        x_lo = old_x - offset_x;
        x_hi = old_x - offset_x + x_size;
        y_lo = old_y - offset_y;
        y_hi = old_y - offset_y + y_size;

        /* Draw dynamics */

        Draw_crosshairs (form_window, old_x - offset_x, old_y - offset_y);

        Draw_dyn_lower_right_box (form_window, x_lo, y_lo, x_hi, y_hi);

        if (icon_flag)
        {
          Draw_dyn_lower_right_box (form_window, x_hi, y_lo, x_hi + 12, y_hi);
        }

        if (horz_flag)
        {
          Draw_dyn_lower_right_box (form_window, x_lo, y_hi,
              (x_lo + (x_hi - x_lo + icon_size)),
              y_hi + 15);
        }

        if (vert_flag)
        {
          Draw_dyn_lower_right_box (form_window, x_hi + icon_size, y_lo,
              x_hi + icon_size + vert_size, y_hi);
        }

        if (dpb.expansion4 == 1) /* boundary mode set */
        {
          Draw_dyn_box (form_window,
              old_x - offset_x - x_bound, old_y - offset_y - y_bound,
              old_x - offset_x + actual_xsize + x_bound,
              old_y - offset_y + actual_ysize + y_bound);
        }

        UMSGetByNum (t_str, FB_I_XY, "%d%d", x - offset_x,
            y - offset_y);
        FIfld_set_text (Message_form, 44, 0, 0, t_str, 0);

        XDrawSegments (display, form_window, dyn_GC, segs, Segment_count);
        Segment_count = 0;
        XFlush (display);
      }
    }
  }

  /* Erase existing lines */

  Draw_crosshairs (form_window, old_x - offset_x, old_y - offset_y);

  Draw_dyn_lower_right_box (form_window, x_lo, y_lo, x_hi, y_hi);

  if (icon_flag)
  {
    Draw_dyn_lower_right_box (form_window, x_hi, y_lo, x_hi + 12, y_hi);
  }

  if (horz_flag)
  {
    Draw_dyn_lower_right_box (form_window, x_lo, y_hi,
        (x_lo + (x_hi - x_lo + icon_size)),
        y_hi + 15);
  }

  if (vert_flag)
  {
    Draw_dyn_lower_right_box (form_window, x_hi + icon_size, y_lo,
        x_hi + icon_size + vert_size, y_hi);
  }

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    Draw_dyn_box (form_window,
        old_x - offset_x - x_bound, old_y - offset_y - y_bound,
        old_x - offset_x + actual_xsize + x_bound,
        old_y - offset_y + actual_ysize + y_bound);
  }
  XDrawSegments (display, form_window, dyn_GC, segs, Segment_count);
  Segment_count = 0;
  XFlush (display);

  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  while (XCheckMaskEvent (display, ButtonPressMask | ButtonReleaseMask, &event))
  {
    /* Eat all button related events */
  }

  if (dpb.expansion4 == 1)
  {
    FIf_get_size (work_form, &xsize, &ysize);
    FIf_paint_area (work_form, 0, 0, xsize, ysize);
  }

  if (grab == GrabSuccess)
    XUngrabPointer (display, CurrentTime);

  return (done);
}

/*-----------------------------------------------------------------------*/

static void Move_MCF_dynamics(Window window,
                              int old_x,
                              int offset_x,
                              int old_y,
                              int offset_y,
                              int x_lo,
                              int y_lo,
                              int x_hi,
                              int y_hi,
                              int button_flag,
                              int horz_flag,
                              int vert_flag,
                              int x_bound,
                              int y_bound,
                              int row_select_flag,
                              int icon_size,
                              int vert_size,
                              int actual_xsize,
                              int actual_ysize)
{
  Draw_crosshairs (window, old_x - offset_x, old_y - offset_y);

  if (row_select_flag == 1)
  {
    Draw_dyn_lower_right_box (window, x_lo + 10, y_lo, x_hi, y_hi);
    Draw_dyn_lower_right_box (window, x_lo, y_lo, x_lo + 10, y_hi);
  }
  else
  {
    Draw_dyn_lower_right_box (window, x_lo, y_lo, x_hi - 10, y_hi);
  }

  if (button_flag)
  {
    if (row_select_flag == 1)
      Draw_dyn_leave_out_top_box (window, x_lo + 10, y_hi, x_hi, y_hi + 12);
    else
      Draw_dyn_lower_right_box (window, x_lo, y_hi, x_hi - 10, y_hi + 12);
  }

  if (horz_flag)
  {
    if (row_select_flag == 1)
      Draw_dyn_leave_out_top_box (window,
          x_lo + 10, y_hi + icon_size,
          x_hi, y_hi + icon_size + vert_size);
    else
      Draw_dyn_lower_right_box (window,
          x_lo, y_hi + icon_size,
          x_hi - 10, y_hi + icon_size + vert_size);
  }

  if (vert_flag)
  {
    if (row_select_flag == 1)
    {
      Draw_dyn_lower_right_box (window, x_hi, y_lo, x_hi + vert_size, y_hi);
    }
    else
    {
      Draw_dyn_lower_right_box (window, x_hi - 10, y_lo,
          x_hi - 10 + vert_size, y_hi);
    }
  }

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    Draw_dyn_box (window,
        old_x - offset_x - x_bound, old_y - offset_y - y_bound,
        old_x - offset_x + actual_xsize + x_bound,
        old_y - offset_y + actual_ysize + y_bound);
  }
}

/**************************************************************************/
/* */
/* Move_MCF_box() */
/* */
/* This function is used to obtain a data point inside the specified */
/* form window. It accomplishes this by drawing a box figure inside */
/* the specified window. The size of the mcf box is known in advance */
/* as well as whether it has column scroll buttons, vertical scroll bar */
/* or horizontal scroll bar. The field will be moved around without */
/* ever changing size. */
/* */
/* By the way, this function returns an integer value of two to */
/* indicate success and a value of one to indicate that the operator */
/* wishes to terminate the command instead of entering a data point. */
/* */
/**************************************************************************/

/* ARGSUSED */
int Move_MCF_box (Window window,
                  int *x_pos,
                  int *y_pos,
                  int x_size,
                  int y_size,
                  int offset_x,
                  int offset_y,
                  int single_line_mode,
                  int horz_flag,
                  int vert_flag,
                  int button_flag,
                  int row_select_flag)
{
  int x_max, y_max, x, y;
  int done;

  int old_x, old_y;
  char t_str[2000];
  /* initialize to 0 to avoid ANSI warning */
  int x_hi=0, x_lo=0, y_hi=0, y_lo=0;

  /* change from int to Window for ANSI use of XQueryPointer() */
  Window root, child;
  /* change from int to unsigned int for ANSI use of XQueryPointer() */
  unsigned int flags;

  int root_x, root_y;
  int win_x, win_y;

  int icon_size;
  int vert_size;

  /* initialize to 0 to avoid ANSI warning */
  int x_bound=0, y_bound=0;
  int actual_xsize=0, actual_ysize=0;

  float value;

  XEvent event;
  int xsize, ysize;
  Window form_window;
  int grab;
  int not_initial_draw = 0;

  FIf_get_size (work_form, &form_width, &form_height);
  x_max = form_width;
  y_max = form_height;

  if (button_flag)
    icon_size = 12;
  else
    icon_size = 0;

  if (vert_flag)
    vert_size = 25;
  else
    vert_size = 0;

  FIf_get_window (work_form, &form_window);

  if (!curs)
    CreateBlankCursor (display, form_window);

  grab = XGrabPointer (display, form_window, True,
      (unsigned int)(PointerMotionMask | PointerMotionHintMask),
      GrabModeAsync, GrabModeAsync, form_window, curs, CurrentTime);

  done = !(grab == GrabSuccess);

  old_x = 0;
  old_y = 0;

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    Draw_boundary_areas();
    XFlush (display);

    actual_xsize = x_size;
    actual_ysize = y_size;

    if (button_flag)
      actual_ysize += 15;

    if (horz_flag)
      actual_ysize += 25;

    if (vert_flag)
      actual_xsize += 25;

    value = ((dpb.expansion2 / 100.0) * actual_xsize) / 2.0;
    x_bound = (int)value;
    value = ((dpb.expansion3 / 100.0) * actual_ysize) / 2.0;
    y_bound = (int)value;
  }

  while (done == 0)
  {
    XNextEvent (display, &event);

    switch (event.type)
    {
    case MotionNotify:
      while (XCheckMaskEvent (display, PointerMotionMask, &event));
      /*** Remove all from queue ***/

      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &win_x, &win_y, &flags);
      break;

    case ButtonPress:
      if (event.xbutton.button == Button2)
      {
        XQueryPointer (display, form_window, &root, &child,
            &root_x, &root_y, &win_x, &win_y, &flags);

        if ((win_x >= 0) && (win_x < x_max) &&
            (win_y >= 0) && (win_y < y_max))
        {
          if (dpb.grid_flag == 1)
          {
            win_x = ((win_x - offset_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_x += offset_x;
            win_y = ((win_y - offset_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_y += offset_y;
          }

          if (row_select_flag == 1)
            *x_pos = win_x;
          else
            *x_pos = win_x + 10;

          *y_pos = win_y;
          done = 2; /* success */
        }
      }
      else if (event.xbutton.button == Button3)
      {
        done = 1; /* User aborted command */
      }
      break;
    }

    while (XCheckMaskEvent (display, ExposureMask, &event))
    {
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
    }

    if (done == 0)
    {
      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &x, &y, &flags);

      if ((x >= 0) && (x < x_max) &&
          (y >= 0) && (y < y_max))
      {
        if (dpb.grid_flag == 1)
        {
          x = ((x - offset_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
          x += offset_x;
          y = ((y - offset_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
          y += offset_y;
        }

        x_lo = old_x - offset_x;
        x_hi = old_x - offset_x + x_size;
        y_lo = old_y - offset_y;
        y_hi = old_y - offset_y + y_size;

        if ((x != old_x) ||
            (y != old_y))
        {
          if (not_initial_draw) /* erase dynamics */
          {
            Move_MCF_dynamics (form_window, old_x, offset_x, old_y, offset_y,
                x_lo, y_lo, x_hi, y_hi, button_flag, horz_flag, vert_flag,
                x_bound, y_bound, row_select_flag,
                icon_size, vert_size, actual_xsize, actual_ysize);
          }
          not_initial_draw = 1;

          old_x = x;
          old_y = y;

          x_lo = old_x - offset_x;
          x_hi = old_x - offset_x + x_size;
          y_lo = old_y - offset_y;
          y_hi = old_y - offset_y + y_size;

          /* Draw dynamics */

          Move_MCF_dynamics (form_window, old_x, offset_x, old_y, offset_y,
              x_lo, y_lo, x_hi, y_hi, button_flag, horz_flag, vert_flag,
              x_bound, y_bound, row_select_flag,
              icon_size, vert_size, actual_xsize, actual_ysize);

          XDrawSegments (display, form_window, dyn_GC, segs, Segment_count);
          Segment_count = 0;
          XFlush (display);

          UMSGetByNum (t_str, FB_I_XY, "%d%d", x - offset_x,
              y - offset_y);
          FIfld_set_text (Message_form, 44, 0, 0, t_str, 0);
        }
      }
    }
  }
  /* Erase existing lines */

  Move_MCF_dynamics (form_window, old_x, offset_x, old_y, offset_y,
      x_lo, y_lo, x_hi, y_hi, button_flag, horz_flag, vert_flag,
      x_bound, y_bound, row_select_flag,
      icon_size, vert_size, actual_xsize, actual_ysize);

  XDrawSegments (display, form_window, dyn_GC, segs, Segment_count);
  Segment_count = 0;
  XFlush (display);

  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  while (XCheckMaskEvent (display, ButtonPressMask | ButtonReleaseMask, &event))
  {
    /* Eat all button related events */
  }

  if (dpb.expansion4 == 1)
  {
    FIf_get_size (work_form, &xsize, &ysize);
    FIf_paint_area (work_form, 0, 0, xsize, ysize);
  }

  if (grab == GrabSuccess)
    XUngrabPointer (display, CurrentTime);

  return (done);
}

/*--------------------------------------------------------------------------*/

/* ARGSUSED */
static void Define_field_dynamics (Window window,
                                   int old_x,
                                   int old_y,
                                   int x_lo,
                                   int y_lo,
                                   int x_hi,
                                   int y_hi,
                                   int icon_size,
                                   int icon_flag,
                                   int vert_flag,
                                   int vert_size,
                                   int horz_flag,
                                   int anchor_x,
                                   int anchor_y,
                                   int x_line_ptr,
                                   int y_line_ptr,
                                   int single_line_mode)
{
  Draw_crosshairs (window, x_line_ptr, y_line_ptr);

  if ((x_lo == anchor_x) && (y_lo == anchor_y))
    Draw_dyn_upper_left_box (window, x_lo, y_lo, x_hi, y_hi);

  if ((x_lo == anchor_x) && (y_lo < anchor_y))
    Draw_dyn_lower_left_box (window, x_lo, y_lo, x_hi, y_hi);

  if ((x_lo < anchor_x) && (y_lo == anchor_y))
    Draw_dyn_upper_right_box (window, x_lo, y_lo, x_hi, y_hi);

  if ((x_lo < anchor_x) && (y_lo < anchor_y))
    Draw_dyn_lower_right_box (window, x_lo, y_lo, x_hi, y_hi);

  if (horz_flag)
  {
    if ((x_lo == anchor_x) && (y_lo == anchor_y))
      Draw_dyn_lower_left_box (window, x_lo, y_hi, x_hi, y_hi + 15);

    if ((x_lo == anchor_x) && (y_lo < anchor_y))
      Draw_dyn_lower_left_box (window, x_lo, y_hi, x_hi, y_hi + 15);

    if ((x_lo < anchor_x) && (y_lo == anchor_y))
      Draw_dyn_lower_right_box (window, x_lo, y_hi, x_hi, y_hi + 15);

    if ((x_lo < anchor_x) && (y_lo < anchor_y))
      Draw_dyn_lower_right_box (window, x_lo, y_hi, x_hi, y_hi + 15);
  }

  if (icon_flag)
  {
    if ((x_lo == anchor_x) && (y_lo == anchor_y))
      Draw_dyn_upper_right_box (window, x_hi, y_lo, x_hi + 12, y_hi);

    if ((x_lo == anchor_x) && (y_lo < anchor_y))
      Draw_dyn_lower_right_box (window, x_hi, y_lo, x_hi + 12, y_hi);

    if ((x_lo < anchor_x) && (y_lo == anchor_y))
      Draw_dyn_upper_right_box (window, x_hi, y_lo, x_hi + 12, y_hi);

    if ((x_lo < anchor_x) && (y_lo < anchor_y))
      Draw_dyn_lower_right_box (window, x_hi, y_lo, x_hi + 12, y_hi);
  }

  if (vert_flag)
  {
    if ((x_lo == anchor_x) && (y_lo == anchor_y))
      Draw_dyn_upper_right_box (window, x_hi + icon_size, y_lo,
          x_hi + icon_size + vert_size, y_hi);

    if ((x_lo == anchor_x) && (y_lo < anchor_y))
      Draw_dyn_lower_right_box (window, x_hi + icon_size, y_lo,
          x_hi + icon_size + vert_size, y_hi);

    if ((x_lo < anchor_x) && (y_lo == anchor_y))
      Draw_dyn_upper_right_box (window, x_hi + icon_size, y_lo,
          x_hi + icon_size + vert_size, y_hi);

    if ((x_lo < anchor_x) && (y_lo < anchor_y))
      Draw_dyn_lower_right_box (window, x_hi + icon_size, y_lo,
          x_hi + icon_size + vert_size, y_hi);
  }

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    int actual_xsize, actual_ysize;
    double value;
    int x_bound, y_bound;

    actual_xsize = x_hi - x_lo;
    actual_ysize = y_hi - y_lo;

    if (horz_flag)
      actual_ysize += 15;

    if (icon_flag)
      actual_xsize += 12;

    if (vert_flag)
    {
      if (single_line_mode)
        actual_xsize += 50;
      else
        actual_xsize += 25;
    }

    value = ((dpb.expansion2 / 100.0) * actual_xsize) / 2.0;
    x_bound = (int)value;
    value = ((dpb.expansion3 / 100.0) * actual_ysize) / 2.0;
    y_bound = (int)value;

    Draw_dyn_box (window,
        x_lo - x_bound, y_lo - y_bound,
        x_lo + actual_xsize + x_bound,
        y_lo + actual_ysize + y_bound);
  }
}

/**************************************************************************/
/* */
/* Define_field_box() */
/* */
/* This function is used to obtain a data point inside the specified */
/* form window. It accomplishes this by drawing a box figure inside */
/* the specified window. One point of the box is anchored and must be */
/* specified as an input coordinate pair. */
/* */
/* The other point is obtained by tracking the mouse and returning */
/* its position when the middle mouse button is clicked. While the */
/* mouse is being positioned, a dynamic box will be drawn with the */
/* current mouse point and the anchor point serving as diagonal corners */
/* of the box. */
/* */
/* The dimensions of the box will be in multiples of the font's width */
/* and bodysize. If the user has specified that the field can only */
/* have a single row, then this will be enforced. The operator has */
/* control over the number of columns in the field, regardless. */
/* */
/* By the way, this function returns an integer value of two to */
/* indicate success and a value of one to indicate that the operator */
/* wishes to terminate the command instead of entering a data point. */
/* */
/**************************************************************************/

/* ARGSUSED */
int Define_field_box (Window window,
                      int anchor_x,
                      int anchor_y,
                      int * x_low,
                      int * y_low,
                      int * x_high,
                      int * y_high,
                      int * rows,
                      int * columns,
                      int text_width,
                      int line_spacing,
                      int single_line_mode,
                      int horz_flag,
                      int vert_flag,
                      int icon_flag,
                      int selectable_flag)
{
  int x_line_ptr=0;
  int y_line_ptr=0;
  int x_max, y_max, x, y;
  int done;
  int old_x, old_y;
  char t_str[2000];

  /* initialize to 0 to avoid ANSI warning */
  int x_hi=0, x_lo=0, y_hi=0, y_lo=0;

  /* change from int to Window for ANSI use of XQueryPointer() */
  Window root, child;
  /* change from int to unsigned int for ANSI use of XQueryPointer() */
  unsigned int flags, old_buttons;

  XWindowAttributes window_attr;
  int root_x, root_y;
  int win_x, win_y;

  int r, c;
  int icon_size;
  int vert_size;

  XEvent event;
  int xsize, ysize;
  Window form_window;
  int grab;
  int not_initial_draw = 0;

  if (icon_flag)
    icon_size = 12;
  else
    icon_size = 0;

  if (single_line_mode)
    vert_size = 50;
  else
    vert_size = 25;

  FIf_get_window (work_form, &form_window);

  XGetWindowAttributes (display, form_window, &window_attr);
  x_max = window_attr.width;
  y_max = window_attr.height;

  if (!curs)
    CreateBlankCursor (display, form_window);

  grab = XGrabPointer (display, form_window, True,
      (unsigned int)(PointerMotionMask | PointerMotionHintMask),
      GrabModeAsync, GrabModeAsync, form_window, curs, CurrentTime);

  done = !(grab == GrabSuccess);

  old_x = 0;
  old_y = 0;

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    Draw_boundary_areas();
    XFlush (display);
  }

  while (done == 0)
  {
    XNextEvent (display, &event);

    switch (event.type)
    {
    case MotionNotify:
      while (XCheckMaskEvent (display, PointerMotionMask, &event));
      /*** Remove all from queue ***/

      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &win_x, &win_y, &flags);
      break;

    case ButtonPress:
      if (event.xbutton.button == Button2)
      {

        XQueryPointer (display, form_window, &root, &child,
            &root_x, &root_y, &win_x, &win_y, &old_buttons);

        if ((win_x >= 0) && (win_x < x_max) &&
            (win_y >= 0) && (win_y < y_max))
        {
          if (dpb.grid_flag == 1)
          {
            x = ((win_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
            y = ((win_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
          }
          else
          {
            x = win_x;
            y = win_y;
          }

          if (x >= anchor_x)
          {
            c = (x - anchor_x) / text_width;
            if (c == 0)
              c = 1;
            x_lo = anchor_x;
/*
            x_hi = anchor_x + (c * text_width) + 10;
*/
            x_hi = anchor_x + (c * text_width);
            x_line_ptr = x_hi;
          }
          else
          {
            c = (anchor_x - x) / text_width;
            if (c == 0)
              c = 1;
            x_hi = anchor_x;
/*
            x_lo = anchor_x - (c * text_width) - 10;
*/
            x_lo = anchor_x - (c * text_width);
            x_line_ptr = x_lo;
          }

          if (single_line_mode)
          {
            r = 1;
            if (y >= anchor_y)
            {
              y_lo = anchor_y;
/*
              y_hi = anchor_y + line_spacing + 4;
*/
              y_hi = anchor_y + line_spacing;
              y_line_ptr = y_hi;
            }
            else
            {
              y_hi = anchor_y;
/*
              y_lo = anchor_y - line_spacing - 4;
*/
              y_lo = anchor_y - line_spacing;
              y_line_ptr = y_lo;
            }
          }
          else
          {
            if (y >= anchor_y)
            {
              r = (y - anchor_y) / line_spacing;
              if (r == 0)
                r = 1;
              y_lo = anchor_y;
/*
              y_hi = anchor_y + (r * line_spacing);
*/
              y_line_ptr = y_hi;
            }
            else
            {
              r = (anchor_y - y) / line_spacing;
              if (r == 0)
                r = 1;
              y_hi = anchor_y;
/*
              y_lo = anchor_y - (r * line_spacing) - 4;
*/
              y_lo = anchor_y - (r * line_spacing);
              y_line_ptr = y_lo;
            }
          }
          *x_low = x_lo;
          *y_low = y_lo;
          *x_high = x_hi;
          *y_high = y_hi;

          *rows = r;
          *columns = c;
          done = 2; /* success */
        }
      }
      else if (event.xbutton.button == Button3)
      {
        done = 1; /* User aborted command */
      }
      break;
    }

    while (XCheckMaskEvent (display, ExposureMask, &event))
    {
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
    }

    if (done == 0)
    {
      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &x, &y, &flags);

      if (((x >= 0) && (x < x_max) &&
          (y >= 0) && (y < y_max)) &&
          ((x != old_x) ||
          (y != old_y)))
      {
        if (not_initial_draw)
        {
          /* erase dynamics */
/* fprintf(stderr,"Define_field_dynamics: erase dynamics\n"); */
/* dmb:08/31/92:Original: */
          Define_field_dynamics (form_window, old_x, old_y,
              x_lo, y_lo, x_hi, y_hi,
              icon_size, icon_flag,
              vert_flag, vert_size, horz_flag,
              anchor_x, anchor_y,
              x_line_ptr, y_line_ptr, single_line_mode);
        }
        not_initial_draw = 1;

        old_x = x;
        old_y = y;

        if (x >= anchor_x)
        {
          c = (x - anchor_x) / text_width;
          if (c == 0)
            c = 1;
          x_lo = anchor_x;
/*
          x_hi = anchor_x + (c * text_width) + 10;
*/
          x_hi = anchor_x + (c * text_width);
          x_line_ptr = x_hi;
        }
        else
        {
          c = (anchor_x - x) / text_width;
          if (c == 0)
            c = 1;
          x_hi = anchor_x;
/*
          x_lo = anchor_x - (c * text_width) - 10;
*/
          x_lo = anchor_x - (c * text_width);
          x_line_ptr = x_lo;
        }

        if (single_line_mode)
        {
          r = 1;
          if (y >= anchor_y)
          {
            y_lo = anchor_y;
/*
            y_hi = anchor_y + line_spacing + 4;
*/
            y_hi = anchor_y + line_spacing;
            y_line_ptr = y_hi;
          }
          else
          {
            y_hi = anchor_y;
/*
            y_lo = anchor_y - line_spacing - 4;
*/
            y_lo = anchor_y - line_spacing;
            y_line_ptr = y_lo;
          }
        }
        else
        {
          if (y >= anchor_y)
          {
            r = (y - anchor_y) / line_spacing;
            if (r == 0)
              r = 1;
            y_lo = anchor_y;
/*
            y_hi = anchor_y + (r * line_spacing) + 4;
*/
            y_hi = anchor_y + (r * line_spacing);
            y_line_ptr = y_hi;
          }
          else
          {
            r = (anchor_y - y) / line_spacing;
            if (r == 0)
              r = 1;
            y_hi = anchor_y;
/*
            y_lo = anchor_y - (r * line_spacing) - 4;
*/
            y_lo = anchor_y - (r * line_spacing);
            y_line_ptr = y_lo;
          }
        }

        /* Draw field dynamics */
/* fprintf(stderr,"Define_field_dynamics: Draw field dynamics\n"); */
/* dmb:08/31/92:Original: */
        Define_field_dynamics (form_window, old_x, old_y,
            x_lo, y_lo, x_hi, y_hi,
            icon_size, icon_flag,
            vert_flag, vert_size, horz_flag,
            anchor_x, anchor_y,
            x_line_ptr, y_line_ptr, single_line_mode);
/* */

        XDrawSegments (display, form_window, dyn_GC, segs, Segment_count);
        Segment_count = 0;
        XFlush (display);

        UMSGetByNum (t_str, FB_I_ROWSCOLS, "%d%d", r, c);
        FIfld_set_text (Message_form, 44, 0, 0, t_str, 0);
      }
    }
  }

  /* erase existing dynamics */
/* fprintf(stderr,"Define_field_dynamics: erase existing dynamics\n"); */
/* dmb:08/31/92:Original: */
  Define_field_dynamics (form_window, old_x, old_y, x_lo, y_lo, x_hi, y_hi,
      icon_size, icon_flag, vert_flag, vert_size, horz_flag,
      anchor_x, anchor_y, x_line_ptr, y_line_ptr, single_line_mode);

  XDrawSegments (display, form_window, dyn_GC, segs, Segment_count);
  Segment_count = 0;
  XFlush (display);

  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  while (XCheckMaskEvent (display, ButtonPressMask | ButtonReleaseMask, &event))
  {
    /* Eat all button related events */
  }

  if (dpb.expansion4 == 1)
  {
    FIf_get_size (work_form, &xsize, &ysize);
    FIf_paint_area (work_form, 0, 0, xsize, ysize);
  }

  if (grab == GrabSuccess)
    XUngrabPointer (display, CurrentTime);

  return (done);
}

/**************************************************************************/
/* */
/* Poke_plain_point() */
/* */
/* This function is used to obtain a data point inside the specified */
/* form window. The mouse will be used to enter the point, rather than */
/* crosshairs. So applications which use this function do not call for */
/* a great degree of accuracy. */
/* */
/* By the way, this function returns an integer value of two to */
/* indicate success and a value of one to indicate that the operator */
/* wishes to terminate the command instead of entering a data point. */
/* */
/**************************************************************************/

/* ARGSUSED */
int Poke_plain_point (Window window,
                      int * x_pos,
                      int * y_pos)
{
  int x_max, y_max;
  int done;

  /* change from int to Window for ANSI use of XQueryPointer() */
  Window root, child;
  /* change from int to unsigned int for ANSI use of XQueryPointer() */
  unsigned int flags;

  XWindowAttributes window_attr;
  int root_x, root_y;
  int win_x, win_y;

  XEvent event;
  Window form_window;


  FIf_get_window (work_form, &form_window);

  XGetWindowAttributes (display, form_window, &window_attr);
  x_max = window_attr.width;
  y_max = window_attr.height;

  done = 0;

  while (done == 0)
  {
    XNextEvent (display, &event);

    switch (event.type)
    {
    case ButtonPress:
      if (event.xbutton.button == Button2)
      {
        XQueryPointer (display, form_window, &root, &child,
            &root_x, &root_y, &win_x, &win_y, &flags);

        if ((win_x >= 0) && (win_x < x_max) &&
            (win_y >= 0) && (win_y < y_max))
        {
          *x_pos = win_x;
          *y_pos = win_y;
          done = 2; /* success */
        }
      }
      else if (event.xbutton.button == Button3)
      {
        done = 1; /* User aborted command */
      }
      break;

    default:
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
      break;
    }
  }

  return (done);
}

/**************************************************************************/
/* */
/* Get_endpoint() */
/* */
/* This function is used to obtain a data point inside the specified */
/* form window. It accomplishes this by rubberbanding a line to the */
/* anchor point which is specified. As the mouse moves, these lines are */
/* constantly updated. If the mouse ever leaves the form, then the line */
/* is immediately erased, and the cursor reappears. */
/* */
/* This routine is used to place a line. */
/* */
/* By the way, this function returns an integer value of two to */
/* indicate success and a value of one to indicate that the operator */
/* wishes to terminate the command instead of entering a data point. */
/* */
/**************************************************************************/

/* ARGSUSED */
int Get_endpoint (Window window,
                  int anchor_x,
                  int anchor_y,
                  int * x_pos,
                  int * y_pos)
{
  int x_max, y_max, x, y;
  int done;
  int old_x, old_y;
  char t_str[2000];

  /* change from int to Window for ANSI use of XQueryPointer() */
  Window root, child;
  /* change from int to unsigned int for ANSI use of XQueryPointer() */
  unsigned int flags;

  XWindowAttributes window_attr;
  int root_x, root_y;
  int win_x, win_y;

  XEvent event;
  int xsize, ysize;
  Window form_window;
  int grab;
  int not_initial_draw = 0;

  FIf_get_window (work_form, &form_window);
  XGetWindowAttributes (display, form_window, &window_attr);
  x_max = window_attr.width;
  y_max = window_attr.height;


  if (!curs)
    CreateBlankCursor (display, form_window);

  grab = XGrabPointer (display, form_window, True,
      (unsigned int)(PointerMotionMask | PointerMotionHintMask),
      GrabModeAsync, GrabModeAsync, form_window, curs, CurrentTime);

  done = !(grab == GrabSuccess);

  old_x = 0;
  old_y = 0;

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    Draw_boundary_areas();
    XFlush (display);
  }

  if (gadget_attr.line_style != -1)
    XSetLineAttributes (display, xfb_GC, 0, LineOnOffDash, CapButt,
        JoinRound);
  while (done == 0)
  {
    XNextEvent (display, &event);

    switch (event.type)
    {
    case MotionNotify:
      while (XCheckMaskEvent (display, PointerMotionMask, &event));
      /*** Remove all from queue ***/

      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &win_x, &win_y, &flags);
      break;

    case ButtonPress:
      if (event.xbutton.button == Button2)
      {
        XQueryPointer (display, form_window, &root, &child,
            &root_x, &root_y, &win_x, &win_y, &flags);

        if ((win_x >= 0) && (win_x < x_max) &&
            (win_y >= 0) && (win_y < y_max))
        {
          if (dpb.grid_flag == 1)
          {
            win_x = (win_x / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_y = (win_y / dpb.grid_sub_units) * dpb.grid_sub_units;
          }

          *x_pos = win_x;
          *y_pos = win_y;

          done = 2; /* success */
        }
      }
      else if (event.xbutton.button == Button3)
      {
        done = 1; /* User aborted command */
      }
      break;
    }

    while (XCheckMaskEvent (display, ExposureMask, &event))
    {
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
    }

    if (done == 0)
    {
      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &x, &y, &flags);

      if ((x >= 0) && (x < x_max) && /* Cursor inside window */
      (y >= 0) && (y < y_max))
      {
        if (dpb.grid_flag == 1)
        {
          x = (x / dpb.grid_sub_units) * dpb.grid_sub_units;
          y = (y / dpb.grid_sub_units) * dpb.grid_sub_units;
        }

        if ((x != old_x) ||
            (y != old_y))
        {
          if (not_initial_draw)
          {
            /* erase old_line */

            segs[Segment_count].x1 = (short) anchor_x;
            segs[Segment_count].y1 = (short) anchor_y;
            segs[Segment_count].x2 = (short) old_x;
            segs[Segment_count].y2 = (short) old_y;

            Segment_count++;
          }
          not_initial_draw = 1;

          old_x = x;
          old_y = y;

          /* Draw new line */

          segs[Segment_count].x1 = (short) anchor_x;
          segs[Segment_count].y1 = (short) anchor_y;
          segs[Segment_count].x2 = (short) old_x;
          segs[Segment_count].y2 = (short) old_y;
          Segment_count++;

          XDrawSegments(display, form_window, dyn_GC, segs, Segment_count);
          Segment_count = 0;
          XFlush (display);

          UMSGetByNum (t_str, FB_I_XY, "%d%d", x, y);
          FIfld_set_text (Message_form, 44, 0, 0, t_str, 0);
        }
      }
    }
  }

  /* Erase line */

  segs[Segment_count].x1 = (short) anchor_x;
  segs[Segment_count].y1 = (short) anchor_y;
  segs[Segment_count].x2 = (short) old_x;
  segs[Segment_count].y2 = (short) old_y;
  Segment_count++;

  XDrawSegments(display, form_window, dyn_GC, segs, Segment_count);
  Segment_count = 0;
  XFlush (display);

  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  while (XCheckMaskEvent (display, ButtonPressMask | ButtonReleaseMask, &event))
  {
    /* Eat all button related events */
  }

  if (dpb.expansion4 == 1)
  {
    FIf_get_size (work_form, &xsize, &ysize);
    FIf_paint_area (work_form, 0, 0, xsize, ysize);
  }

  if (grab == GrabSuccess)
    XUngrabPointer (display, CurrentTime);

  return (done);
}

/**************************************************************************/
/* */
/* Poke_symbol_location() */
/* */
/* This function is used to obtain a data point inside the specified */
/* form window. It accomplishes this by drawing two perpendicular lines */
/* which meet at the data point in question. As the mouse moves, these */
/* lines are constantly updated. If the mouse ever leaves the form, then */
/* the lines are immediately erased, and the cursor reappears. */
/* */
/* The function also dynamically moves a selected symbol along with */
/* the crosshairs so that the operator will be able to tell exactly */
/* where his symbol will end up. */
/* */
/* By the way, this function returns an integer value of two to */
/* indicate success and a value of one to indicate that the operator */
/* wishes to terminate the command instead of entering a data point. */
/* */
/**************************************************************************/


/* ARGSUSED */
int Poke_symbol_location (Window window,
                          int * x_pos,
                          int * y_pos,
                          char * filename,
                          int index,
                          int offset_x,
                          int offset_y)
{
  int x_line_ptr, y_line_ptr, x_max, y_max, x, y;
  int done;
  int old_x, old_y;
  char t_str[2000];
  int xoff, yoff;

  Window root, child;
  unsigned int flags;

  int root_x, root_y, win_x, win_y, width, height;

  /* initialize these variables for ANSI to avoid 
	 "potential uninitialized reference" warnings,
	 even though conditional statements guard against this
  */
  int x_bound = 0, y_bound = 0;

  int xsize, ysize;

  XEvent event;
  float value;
  Window form_window;
  int grab;
  int not_initial_draw = 0;
  Font symbol_id;

  Pixmap pixmap;

  FIf_get_size (work_form, &form_width, &form_height);
  x_max = form_width;
  y_max = form_height;

  FIf_get_window (work_form, &form_window);

  if (!curs)
    CreateBlankCursor (display, form_window);

  grab = XGrabPointer (display, form_window, True,
      (unsigned int)(PointerMotionMask | PointerMotionHintMask),
      GrabModeAsync, GrabModeAsync, form_window, curs, CurrentTime);

  done = !(grab == GrabSuccess);

  old_x = 0;
  old_y = 0;


  _FI_find_symbol_path_and_id (t_str, filename, (int *)&symbol_id);

  width = _FI_symbols[symbol_id].sym_slot[index].sym_width;
  height = _FI_symbols[symbol_id].sym_slot[index].sym_height;

  /* sml:06-23-92 */
  /* add index for pixmap member; could have pixmap for each screen */
  pixmap = _FI_symbols[symbol_id].sym_slot[index].pixmap[0];

  xoff = _FI_symbols[symbol_id].sym_slot[index].xoff;
  yoff = _FI_symbols[symbol_id].sym_slot[index].yoff;

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    Draw_boundary_areas();
    XFlush (display);

    value = ((dpb.expansion2 / 100.0) * width) / 2.0;
    x_bound = (int)value;

    value = ((dpb.expansion3 / 100.0) * height) / 2.0;
    y_bound = (int)value;
  }

  while (done == 0)
  {
    XNextEvent (display, &event);

    switch (event.type)
    {
    case MotionNotify:
      while (XCheckMaskEvent (display, PointerMotionMask, &event));
      /*** Remove all from queue ***/

      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &win_x, &win_y, &flags);
      break;

    case ButtonPress:
      if (event.xbutton.button == Button2)
      {
        XQueryPointer (display, form_window, &root, &child,
            &root_x, &root_y, &win_x, &win_y, &flags);

        if ((win_x >= 0) && (win_x < x_max) &&
            (win_y >= 0) && (win_y < y_max))
        {
          if (dpb.grid_flag == 1)
          {
            win_x = ((win_x - offset_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_x += offset_x;
            win_y = ((win_y - offset_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_y += offset_y;
          }

          *x_pos = win_x;
          *y_pos = win_y;
          done = 2; /* success */
        }
      }
      else if (event.xbutton.button == Button3)
      {
        done = 1; /* User aborted command */
      }
      break;
    }

    while (XCheckMaskEvent (display, ExposureMask, &event))
    {
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
    }

    if (done == 0)
    {
      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &x, &y, &flags);

      if ((x >= 0) && (x < x_max) && /* Cursor inside window */
      (y >= 0) && (y < y_max))
      {
        if (dpb.grid_flag == 1)
        {
          x = ((x - offset_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
          x += offset_x;
          y = ((y - offset_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
          y += offset_y;
        }

        if ((x != old_x) ||
            (y != old_y))
        {
          if (not_initial_draw)
          {
            /* Erase dynamics */

            Draw_crosshairs (form_window, old_x - offset_x, old_y - offset_y);

            t_str [0] = (unsigned char)index;
            t_str [1] = '\0';

            if (pixmap != (Pixmap) NULL)
              XCopyPlane (display, pixmap, form_window, dyn_GC, 0, 0,
                  width, height,
                  old_x - offset_x + xoff, old_y - offset_y + yoff, 0x00000001);

            if (dpb.expansion4 == 1) /* boundary display enabled */
            {
              Draw_dyn_box (form_window, old_x - offset_x - x_bound + xoff,
                  old_y - offset_y - y_bound + yoff,
                  old_x - offset_x + width + x_bound + xoff,
                  old_y - offset_y + height + y_bound + yoff);
            }
          }
          not_initial_draw = 1;

          x_line_ptr = x;
          y_line_ptr = y;

          old_x = x;
          old_y = y;

          /* Draw dynamics */

          Draw_crosshairs (form_window, old_x - offset_x, old_y - offset_y);

          t_str [0] = (unsigned char)index;
          t_str [1] = '\0';

          if (pixmap != (Pixmap) NULL)
            XCopyPlane (display, pixmap, form_window, dyn_GC, 0, 0,
                width, height,
                old_x - offset_x + xoff, old_y - offset_y + yoff, 0x00000001);

          if (dpb.expansion4 == 1) /* boundary display enabled */
          {
            Draw_dyn_box (form_window, old_x - offset_x - x_bound + xoff,
                old_y - offset_y - y_bound + yoff,
                old_x - offset_x + width + x_bound + xoff,
                old_y - offset_y + height + y_bound + yoff);
          }

          XDrawSegments(display, form_window, dyn_GC, segs, Segment_count);
          Segment_count = 0;
          XFlush (display);

          UMSGetByNum (t_str, FB_I_XY, "%d%d", x - offset_x,
              y - offset_y);
          FIfld_set_text (Message_form, 44, 0, 0, t_str, 0);
        }
      }
    }
  }

  /* Erase dynamics */

  Draw_crosshairs (form_window, old_x - offset_x, old_y - offset_y);

  t_str [0] = (unsigned char)index;
  t_str [1] = '\0';

  if (pixmap != (Pixmap) NULL)
    XCopyPlane (display, pixmap, form_window, dyn_GC, 0, 0,
        width, height,
        old_x - offset_x + xoff, old_y - offset_y + yoff, 0x00000001);

  if (dpb.expansion4 == 1) /* boundary display enabled */
  {
    Draw_dyn_box (form_window, old_x - offset_x - x_bound + xoff,
        old_y - offset_y - y_bound + yoff,
        old_x - offset_x + width + x_bound + xoff,
        old_y - offset_y + height + y_bound + yoff);
  }
  XDrawSegments(display, form_window, dyn_GC, segs, Segment_count);
  Segment_count = 0;
  XFlush (display);

  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  while (XCheckMaskEvent (display, ButtonPressMask | ButtonReleaseMask, &event))
  {
    /* Eat all button related events */
  }

  if (dpb.expansion4 == 1)
  {
    FIf_get_size (work_form, &xsize, &ysize);
    FIf_paint_area (work_form, 0, 0, xsize, ysize);
  }

  if (grab == GrabSuccess)
    XUngrabPointer (display, CurrentTime);

  return (done);
}

/*--------------------------------------------------------------------------*/

/**************************************************************************/
/* */
/* Poke_text_location() */
/* */
/* This function is used to obtain a data point inside the specified */
/* form window. It accomplishes this by drawing two perpendicular lines */
/* which meet at the data point in question. As the mouse moves, these */
/* lines are constantly updated. If the mouse ever leaves the form, then */
/* the lines are immediately erased, and the cursor reappears. */
/* */
/* The function also dynamically moves a text string along with */
/* the crosshairs so that the operator will be able to tell exactly */
/* where his text will end up. */
/* */
/* By the way, this function returns an integer value of two to */
/* indicate success and a value of one to indicate that the operator */
/* wishes to terminate the command instead of entering a data point. */
/* */
/**************************************************************************/


/* ARGSUSED */
int Poke_text_location (Window window,
                        int * x_pos,
                        int * y_pos,
                        int offset_x,
                        int offset_y,
                        char *string,
                        int justify,
                        char *fontname,
                        float bodysize)
{
  int x_line_ptr;
  int y_line_ptr;
  int x_max, y_max, x, y;
  int done;

  int old_x, old_y;
  char t_str[2000];

  /* change from int to Window for ANSI use of XQueryPointer() */
  Window root, child;
  /* change from int to unsigned int for ANSI use of XQueryPointer() */
  unsigned int flags;

  int root_x, root_y;
  int win_x, win_y;
  int width, height, line_spacing;

  Font text_font;

  XEvent event;

  /* initialize these variables for ANSI to avoid 
	 "potential uninitialized reference" warnings,
	 even though conditional statements guard against this
  */
  int x_bound = 0, y_bound = 0;

  int xsize, ysize;
  float value;
  Window form_window;
  int grab;
  int not_initial_draw = 0;
  int font_type;
  float dummy_float;
  int y_adjust;
  int total_width;

  Calculate_text_size (string, fontname, bodysize, &total_width, &height);

  FIf_get_size (work_form, &form_width, &form_height);
  x_max = form_width;
  y_max = form_height;

  FIf_get_window (work_form, &form_window);

  if (!curs)
    CreateBlankCursor (display, form_window);

  grab = XGrabPointer (display, form_window, True,
      (unsigned int)(PointerMotionMask | PointerMotionHintMask),
      GrabModeAsync, GrabModeAsync, form_window, curs, CurrentTime);

  done = !(grab == GrabSuccess);

  old_x = 0;
  old_y = 0;

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    Draw_boundary_areas();
    XFlush (display);

    value = ((dpb.expansion2 / 100.0) * width) / 2.0;
    x_bound = (int)value;

    value = ((dpb.expansion3 / 100.0) * height) / 2.0;
    y_bound = (int)value;
  }

  _FI_find_font_id (fontname, bodysize, &text_font, &dummy_float,
      FI_TEXT, &font_type);
  _FI_calc_text (text_font, "M", 1, &height, &width, &line_spacing, font_type);

   if (font_type > 0)  /* XFontserver font */
   {
      y_adjust = (height / 5) + 2;
   }
   else
   {
      y_adjust = 0;
      XSetFont (display, dyn_GC, text_font); /* dmb:10/19/92:NEW */
   }

  while (done == 0)
  {
    XNextEvent (display, &event);

    switch (event.type)
    {
    case MotionNotify:
      while (XCheckMaskEvent (display, PointerMotionMask, &event));
      /*** Remove all from queue ***/

      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &win_x, &win_y, &flags);
      break;

    case ButtonPress:
      if (event.xbutton.button == Button2)
      {
        XQueryPointer (display, form_window, &root, &child,
            &root_x, &root_y, &win_x, &win_y, &flags);

        if ((win_x >= 0) && (win_x < x_max) &&
            (win_y >= 0) && (win_y < y_max))
        {
          if (dpb.grid_flag == 1)
          {
            win_x = ((win_x - offset_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_x += offset_x;
            win_y = ((win_y - offset_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_y += offset_y;
          }

          *x_pos = win_x;
          *y_pos = win_y;
          done = 2; /* success */
        }
      }
      else if (event.xbutton.button == Button3)
      {
        done = 1; /* User aborted command */
      }
      break;
    }

    while (XCheckMaskEvent (display, ExposureMask, &event))
    {
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
    }

    if (done == 0)
    {
      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &x, &y, &flags);

      if ((x >= 0) && (x < x_max) && /* Cursor inside window */
      (y >= 0) && (y < y_max))
      {
        if (dpb.grid_flag == 1)
        {
          x = ((x - offset_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
          x += offset_x;
          y = ((y - offset_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
          y += offset_y;
        }

        if ((x != old_x) ||
            (y != old_y))
        {
          if (not_initial_draw)
          {
            /* Erase dynamics */

            Draw_crosshairs (form_window, old_x - offset_x, old_y - offset_y);

            FB_mlt_draw (form_window, text_font, string,
                old_x - offset_x, old_y - offset_y + y_adjust,
                justify, total_width, font_type);

            if (dpb.expansion4 == 1) /* boundary mode set */
            {
              Draw_dyn_box (form_window, old_x - offset_x - x_bound,
                  old_y - offset_y - y_bound,
                  old_x - offset_x + width + x_bound,
                  old_y - offset_y + height + y_bound);
            }
          }
          not_initial_draw = 1;

          x_line_ptr = x;
          y_line_ptr = y;

          old_x = x;
          old_y = y;

          /* Draw dynamics */

          Draw_crosshairs (form_window, old_x - offset_x, old_y - offset_y);

          FB_mlt_draw (form_window, text_font, string,
              old_x - offset_x, old_y - offset_y + y_adjust,
              justify, total_width, font_type);

          if (dpb.expansion4 == 1) /* boundary mode set */
          {
            Draw_dyn_box (form_window, old_x - offset_x - x_bound,
                old_y - offset_y - y_bound,
                old_x - offset_x + width + x_bound,
                old_y - offset_y + height + y_bound);
          }
          XDrawSegments(display, form_window, dyn_GC, segs, Segment_count);
          Segment_count = 0;
          XFlush (display);

          UMSGetByNum (t_str, FB_I_XY, "%d%d", x - offset_x,
              y - offset_y);
          FIfld_set_text (Message_form, 44, 0, 0, t_str, 0);
        }
      }
    }
  }

  /* Erase dynamics */

  Draw_crosshairs (form_window, old_x - offset_x, old_y - offset_y);

  FB_mlt_draw (form_window, text_font, string, old_x - offset_x,
      old_y - offset_y + y_adjust, justify, total_width, font_type);

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    Draw_dyn_box (form_window, old_x - offset_x - x_bound,
        old_y - offset_y - y_bound,
        old_x - offset_x + width + x_bound,
        old_y - offset_y + height + y_bound);
  }
  XDrawSegments(display, form_window, dyn_GC, segs, Segment_count);
  Segment_count = 0;
  XFlush (display);

  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  while (XCheckMaskEvent (display, ButtonPressMask | ButtonReleaseMask, &event))
  {
    /* Eat all button related events */
  }

  if (dpb.expansion4 == 1)
  {
    FIf_get_size (work_form, &xsize, &ysize);
    FIf_paint_area (work_form, 0, 0, xsize, ysize);
  }

  if (grab == GrabSuccess)
    XUngrabPointer (display, CurrentTime);

  return (done);
}

/*--------------------------------------------------------------------------*/

/**************************************************************************/
/* */
/* Move_line_gadget() */
/* */
/* This function is used to obtain a data point inside the specified */
/* form window. It accomplishes this by drawing two perpendicular lines */
/* which meet at the data point in question. As the mouse moves, these */
/* lines are constantly updated. If the mouse ever leaves the form, then */
/* the lines are immediately erased, and the cursor reappears. */
/* */
/* The function also dynamically moves a selected line along with */
/* the crosshairs so that the operator will be able to tell exactly */
/* where his line gadget will end up. */
/* */
/* By the way, this function returns an integer value of two to */
/* indicate success and a value of one to indicate that the operator */
/* wishes to terminate the command instead of entering a data point. */
/* */
/**************************************************************************/

/* ARGSUSED */
int Move_line_gadget (Window window,
                      int * x_pos,
                      int * y_pos,
                      int x_size,
                      int y_size,
                      int offset_x,
                      int offset_y)
{
  int x_line_ptr;
  int y_line_ptr;
  int x_max, y_max, x, y;
  int done;

  int old_x, old_y;
  char t_str[2000];

  /* change from int to Window for ANSI use of XQueryPointer() */
  Window root, child;
  /* change from int to unsigned int for ANSI use of XQueryPointer() */
  unsigned int flags;

  int root_x, root_y;
  int win_x, win_y;

  XEvent event;
  int xsize, ysize;
  Window form_window;
  int grab;
  int not_initial_draw = 0;

  FIf_get_size (work_form, &form_width, &form_height);
  x_max = form_width;
  y_max = form_height;

  FIf_get_window (work_form, &form_window);

  if (!curs)
    CreateBlankCursor (display, form_window);

  grab = XGrabPointer (display, form_window, True,
      (unsigned int)(PointerMotionMask | PointerMotionHintMask),
      GrabModeAsync, GrabModeAsync, form_window, curs, CurrentTime);

  done = !(grab == GrabSuccess);

  old_x = 0;
  old_y = 0;

  if (dpb.expansion4 == 1) /* boundary mode set */
  {
    Draw_boundary_areas();
    XFlush (display);
  }

  while (done == 0)
  {
    XNextEvent (display, &event);

    switch (event.type)
    {
    case MotionNotify:
      while (XCheckMaskEvent (display, PointerMotionMask, &event));
      /*** Remove all from queue ***/

      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &win_x, &win_y, &flags);
      break;

    case ButtonPress:
      if (event.xbutton.button == Button2)
      {
        XQueryPointer (display, form_window, &root, &child,
            &root_x, &root_y, &win_x, &win_y, &flags);

        if ((win_x >= 0) && (win_x < x_max) &&
            (win_y >= 0) && (win_y < y_max))
        {
          if (dpb.grid_flag == 1)
          {
            win_x = ((win_x - offset_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_x += offset_x;
            win_y = ((win_y - offset_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
            win_y += offset_y;
          }

          *x_pos = win_x;
          *y_pos = win_y;
          done = 2; /* success */
        }
      }
      else if (event.xbutton.button == Button3)
      {
        done = 1; /* User aborted command */
      }
      break;
    }

    while (XCheckMaskEvent (display, ExposureMask, &event))
    {
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
    }

    if (done == 0)
    {
      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &x, &y, &flags);

      if ((x >= 0) && (x < x_max) && /* Cursor inside window */
      (y >= 0) && (y < y_max))
      {
        if (dpb.grid_flag == 1)
        {
          x = ((x - offset_x) / dpb.grid_sub_units) * dpb.grid_sub_units;
          x += offset_x;
          y = ((y - offset_y) / dpb.grid_sub_units) * dpb.grid_sub_units;
          y += offset_y;
        }

        if ((x != old_x) ||
            (y != old_y))
        {
          if (not_initial_draw)
          {
            /* Erase dynamics */

            segs[Segment_count].x1 = (short) (old_x - offset_x);
            segs[Segment_count].y1 = (short) (old_y - offset_y);
            segs[Segment_count].x2 = (short) (old_x - offset_x + x_size);
            segs[Segment_count].y2 = (short) (old_y - offset_y + y_size);
            Segment_count++;
          }
          not_initial_draw = 1;

          x_line_ptr = x;
          y_line_ptr = y;

          old_x = x;
          old_y = y;

          /* Draw dynamics */

          segs[Segment_count].x1 = (short) (old_x - offset_x);
          segs[Segment_count].y1 = (short) (old_y - offset_y);
          segs[Segment_count].x2 = (short) (old_x - offset_x + x_size);
          segs[Segment_count].y2 = (short) (old_y - offset_y + y_size);
          Segment_count++;

          XDrawSegments(display, form_window, dyn_GC, segs, Segment_count);
          Segment_count = 0;
          XFlush (display);

          UMSGetByNum (t_str, FB_I_XY, "%d%d", x - offset_x,
              y - offset_y);
          FIfld_set_text (Message_form, 44, 0, 0, t_str, 0);
        }
      }
    }
  }

  /* Erase dynamics */

  segs[Segment_count].x1 = (short) (old_x - offset_x);
  segs[Segment_count].y1 = (short) (old_y - offset_y);
  segs[Segment_count].x2 = (short) (old_x - offset_x + x_size);
  segs[Segment_count].y2 = (short) (old_y - offset_y + y_size);
  Segment_count++;

  XDrawSegments(display, form_window, dyn_GC, segs, Segment_count);
  Segment_count = 0;
  XFlush (display);

  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  while (XCheckMaskEvent (display, ButtonPressMask | ButtonReleaseMask, &event))
  {
    /* Eat all button related events */
  }

  if (dpb.expansion4 == 1)
  {
    FIf_get_size (work_form, &xsize, &ysize);
    FIf_paint_area (work_form, 0, 0, xsize, ysize);
  }

  if (grab == GrabSuccess)
    XUngrabPointer (display, CurrentTime);

  return (done);
}

/*--------------------------------------------------------------------------*/

static void FBf_gadgets_in_point (Form form,
                                  int xpos,
                                  int ypos,
                                  int * num_gadgets,
                                  int gadget_array[100])
{
  int x;
  int status;
  int gadget_type;
  int loc_x, loc_y;
  int x_size, y_size;
  int count;
  int minx, miny, maxx, maxy;
  int xdelta, ydelta;
  float ycalc;
  int line_depth;

  count = 0;

  for (x = 1; x < 1000; x++)
  {
    status = FIg_get_type (form, x, &gadget_type);

    if ((status == FI_SUCCESS) &&
        (gadget_type != FI_GROUP))
    {
      FIg_get_location (form, x, &loc_x, &loc_y);

      FIg_get_size (form, x, &x_size, &y_size);


      if (gadget_type == FI_LINE)
      {

        if (x_size <= 0)
        {
          minx = loc_x + x_size;
          maxx = loc_x;
        }
        else
        {
          minx = loc_x;
          maxx = loc_x + x_size;
        }

        if (y_size <= 0)
        {
          miny = loc_y + y_size;
          maxy = loc_y;
        }
        else
        {
          miny = loc_y;
          maxy = loc_y + y_size;
        }

        if (( minx == maxx ) &&
            ( minx - 10 < xpos ) && ( maxx + 10 > xpos ) &&
            ( miny - 10 < ypos ) && ( maxy + 10 > ypos ))
        {
          gadget_array[count] = x;
          count++;
        }
        else if (( miny == maxy ) &&
            ( miny - 10 < ypos ) && ( maxy + 10 > ypos ) &&
            ( minx - 10 < xpos ) && ( maxx + 10 > xpos ))
        {
          gadget_array[count] = x;
          count++;
        }
        /* not a horizontal or vertical line: */

        else if ((( minx != maxx ) && ( miny != maxy ) &&
            ( minx - 20 ) < xpos ) && ( maxx + 20 > xpos ))
        {
          if (x_size < 0)
            y_size *= -1;

          if (y_size < 0)
          {
            miny -= y_size;
            maxy -= y_size;
          }

          xdelta = maxx - minx;
          ydelta = y_size; /* Is the slope is negative or positive */

          ycalc = ( (float)ydelta / xdelta ) * ( xpos - minx ) + miny;
          if ( (ycalc - ypos) < 20 && (ycalc - ypos) > -20 )
          {
            gadget_array[count] = x;
            count++;
          }
        }
      }
      else
      {

        if ((gadget_type == FI_RECT) ||
            (gadget_type == FI_BEZEL))
        {
          loc_x -= 10;
          if (loc_x < 0)
            loc_x = 0;

          loc_y -= 10;
          if (loc_y < 0)
            loc_y = 0;

          x_size += 20;
          y_size += 20;

          if (((xpos >= loc_x) &&
              (xpos <= loc_x + x_size)) &&
              ((ypos >= loc_y) &&
              (ypos <= loc_y + y_size)))
          {
            if (((xpos >= loc_x + 20) &&
                (xpos <= loc_x + x_size - 20)) &&
                ((ypos >= loc_y + 20) &&
                (ypos <= loc_y + y_size - 20)))
            {
              /* Fell into the interior of the rectangle, so reject */

              status = FIg_get_line_depth (form, x, &line_depth);
              if (line_depth != 2)
              {
                loc_x = 0;
                loc_y = 0;
                x_size = 0;
                y_size = 0;
              }
            }
          }
        }

        if (((xpos >= loc_x) &&
            (xpos <= loc_x + x_size)) &&
            ((ypos >= loc_y) &&
            (ypos <= loc_y + y_size)))
        {
          gadget_array[count] = x;
          count++;
        }
      }
    }
  }

  *num_gadgets = count;
}

/*--------------------------------------------------------------------------*/

void FIf_gadgets_inside_area (Form form,
                              int xlo,
                              int ylo,
                              int xhi,
                              int yhi,
                              int * num_gadgets,
                              int gadget_array[100])
{
  int x;
  int status;
  int gadget_type;
  int loc_x, loc_y;
  int x_size, y_size;
  int count;
  int temp_x, temp_y;

  count = 0;

  for (x = 1; x < 1000; x++)
  {
    status = FIg_get_type (form, x, &gadget_type);

    if ((status == FI_SUCCESS) &&
        (gadget_type != FI_GROUP))
    {
      FIg_get_location (form, x, &loc_x, &loc_y);

      FIg_get_size (form, x, &x_size, &y_size);

      if (gadget_type == FI_LINE)
      {
        if (x_size < 0)
        {
          temp_x = loc_x;
          loc_x += x_size;
          x_size *= -1;
        }

        if (y_size < 0)
        {
          temp_y = loc_y;
          loc_y += y_size;
          y_size *= -1;
        }

        loc_x -= 4;
        loc_y -= 4;

        if (loc_x < 0)
          loc_x = 0;

        if (loc_y < 0)
          loc_y = 0;

        x_size += 10;
        y_size += 10;
      }

      if (((loc_x >= xlo) &&
          ((loc_x + x_size) <= xhi)) &&
          ((loc_y >= ylo) &&
          ((loc_y + y_size) <= yhi)))
      {
        gadget_array[count] = x;
        count++;
      }
    }
  }

  *num_gadgets = count;
}

/*----------------------------------------------------------------------*/

int Poke_point_or_keyin (Window window,
                         int * x_pos,
                         int * y_pos,
                         int * label)
{
int done;
int status;
char number_string[100];
int number_index;
char c[256];
int type;
XEvent event;
int x_max, y_max;

  /* change from int to Window for ANSI use of XQueryPointer() */
  Window root, child;
  /* change from int to unsigned int for ANSI use of XQueryPointer() */
  unsigned int flags;

XWindowAttributes window_attr;
int root_x, root_y;
int win_x, win_y;

  XGetWindowAttributes (display, window, &window_attr);
  x_max = window_attr.width;
  y_max = window_attr.height;

  done = 0;
  number_index = 0;
  *label = 0;

  while ((done == 0) && (*label == 0))
  {
    XNextEvent (display, &event);

    switch (event.type)
    {
    case ButtonPress:
      if (event.xbutton.button == Button2)
      {
        XQueryPointer (display, window, &root, &child,
            &root_x, &root_y, &win_x, &win_y, &flags);

        if ((win_x >= 0) && (win_x < x_max) &&
            (win_y >= 0) && (win_y < y_max))
        {
          *x_pos = win_x;
          *y_pos = win_y;
          done = 2; /* success */
        }
        else  /* GMD 11/12/91 */
        {
           done = 1;
           FI_process_event (&event, 0); /* add 2nd arg for ANSI */
        }
      }
      else if (event.xbutton.button == Button3)
      {
        done = 1; /* User aborted command */
      }
      break;

    case KeyPress:
      _FI_map_character (&event.xkey, c);

      if ((c[0] == 127) ||      /* Delete a character */
          (c[0] == 8)   ||      /* Backspace          */
          (c[0] == 13)  ||      /* Return             */
          (isdigit (c[0])))
      {
         if (isdigit (c[0]))
         {
            number_string[number_index] = c[0];
            number_index++;
            number_string[number_index] = 0;
         }

         if (((c[0] == 127) || (c[0] == 8)) && (number_index > 0))
         {
            number_index--;
            number_string[number_index] = 0;
         }

         if (c[0] == 13)
         {
            *label = atoi (number_string);

            if ((*label >= 1000) || (*label == 0))
            {
               number_string[0] = 0;
               number_index = 0;
               *label = 0;
            }
            else
            {
               status = FIg_get_type (work_form, *label, &type);

               if (status != FI_SUCCESS)
               {
                  number_string[0] = 0;
                  number_index = 0;
                  *label = 0;
               }
               else if ((type == FI_GROUP) &&
                        (command_is_active != DELETE_GADGET))
               {
                  number_string[0] = 0;
                  number_index = 0;
                  *label = 0;
               }
               else
                  done = 2;   /* Success */
            }
         }

         FIfld_set_text (Message_form, 44, 0, 0, number_string, 0);
      }
      break;

    default:
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
      break;
    }
  }

  if (*label != 0) /* User keyed in label */
    done = 2;

  return (done);
}

/*----------------------------------------------------------------------*/

int Select_gadget (int * gadget_label,
                   int * xsize,
                   int * ysize,
                   int * display_flag,
                   int * hilite_flag,
                   int * accept_x,
                   int * accept_y,
                   int mode)
{
  int x;
  int xpos, ypos;
  Window window;
  int not_finished;
  int status;
  int num_gadgets;
  int gadget_array[100];
  int gadget_type;
  int gadget_xsize, gadget_ysize;
  char t_str[2000];
  int attr;
  int temp_mode, label, type;


  FIf_get_window (work_form, &window);

  FIfld_set_mode (Message_form, 44, 0, FI_INSERT);
  keyin_label = 0;

  not_finished = 1;

  temp_mode = mode;
  label = 0;

  while (not_finished)
  {
    if (temp_mode == 0) /* Force operator to poke a point */
    {
      UMSGetByNum (t_str, FB_P_SELGDTKEY, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      FIfld_set_text (Message_form, 44, 0, 0, "", 0);

      status = Poke_point_or_keyin (window, &xpos, &ypos, &label);

      temp_mode = mode;
    }
    else /* Use FB supplied data point */
    {
      status = 2;
      xpos = *accept_x;
      ypos = *accept_y;
    }

    if (status == 2)
    {
      if (label == 0) /* Operator actually poked a location */
      {
        FBf_gadgets_in_point (work_form, xpos, ypos, &num_gadgets,
            gadget_array);

        if (num_gadgets > 0)
        {
          UMSGetByNum (t_str, FB_P_ACCREJGDT, 0);
          FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

          for (x = 0; x < num_gadgets; x++)
          {
            FIg_get_attr (work_form, gadget_array[x], &attr);

            if (attr & FI_NOT_DISPLAYED)
            {
              *display_flag = 0;
              FIg_display (work_form, gadget_array[x]);
            }
            else
              *display_flag = 1;

            if (attr & FI_HILITED)
              *hilite_flag = 1;
            else
              *hilite_flag = 0;

            /* GMD 1/28/92 - Fix problem erasing embossed text gadgets */

            FIg_erase (work_form, gadget_array[x]);
            FIg_hilite (work_form, gadget_array[x]);
            FIg_display (work_form, gadget_array[x]);

            UMSGetByNum (t_str, FB_I_GDTLABEL, "%d", gadget_array[x]);
            FIfld_set_text (Message_form, 44, 0, 0, t_str, 0);

            status = Poke_plain_point (window, &xpos, &ypos);

            if (status == 2)
            {
              *accept_x = xpos;
              *accept_y = ypos;

              *gadget_label = gadget_array[x];

              FIg_get_type (work_form, gadget_array[x], &gadget_type);

              FIg_get_size (work_form, gadget_array[x], &gadget_xsize,
                  &gadget_ysize);
              *xsize = gadget_xsize;
              *ysize = gadget_ysize;

              FIfld_set_mode (Message_form, 44, 0, FI_REVIEW);
              return(2);
            }
            else
            {
              if (*display_flag == 0)
                FIg_erase (work_form, gadget_array[x]);

              if (*hilite_flag == 0)
                FIg_unhilite (work_form, gadget_array[x]);
            }
          }
          FIfld_set_text (Message_form, 44, 0, 0, "", 0);

          if (mode == 1)
            temp_mode = 0;
        }
        else
          if (mode == 1)
            temp_mode = 0;
      }
      else /* Operator keyed in gadget label */
      {
        int save_label;

        save_label = label;
        label = 0;
        FIfld_set_mode (Message_form, 44, 0, FI_REVIEW);

        UMSGetByNum (t_str, FB_P_ACCREJGDT, 0);
        FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

        FIg_get_type (work_form, save_label, &type);

        if (type != FI_GROUP)
        {
          FIg_get_attr (work_form, save_label, &attr);

          if (attr & FI_NOT_DISPLAYED)
          {
            *display_flag = 0;
            FIg_display (work_form, save_label);
          }
          else
            *display_flag = 1;

          if (attr & FI_HILITED)
            *hilite_flag = 1;
          else
            *hilite_flag = 0;

          FIg_hilite (work_form, save_label);
        }

        UMSGetByNum (t_str, FB_I_GDTLABEL, "%d", save_label);
        FIfld_set_text (Message_form, 44, 0, 0, t_str, 0);

		/* sml:08-13-92 don't require an accept for a key-in 
        status = Poke_plain_point (window, &xpos, &ypos);
		*/
		status = 2;

        if (status == 2)
        {
          *accept_x = xpos;
          *accept_y = ypos;

          *gadget_label = save_label;

          FIg_get_type (work_form, save_label, &gadget_type);

          FIg_get_size (work_form, save_label, &gadget_xsize,
              &gadget_ysize);
          *xsize = gadget_xsize;
          *ysize = gadget_ysize;

          FIfld_set_mode (Message_form, 44, 0, FI_REVIEW);
          return(2);
        }
        else
        {
          if (type != FI_GROUP)
          {
            if (*display_flag == 0)
              FIg_erase (work_form, save_label);

            if (*hilite_flag == 0)
              FIg_unhilite (work_form, save_label);
          }
          FIfld_set_mode (Message_form, 44, 0, FI_INSERT);
          FIfld_set_text (Message_form, 44, 0, 0, "", 0);
          label = 0;
        }
      }
    }
    else
    {
      FIfld_set_mode (Message_form, 44, 0, FI_REVIEW);
      return(1);
    }
  }

  return FI_SUCCESS;
}
