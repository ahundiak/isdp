/***********************************

		create_seq.c

***********************************/

/*
  History
	04-28-92	sml		ANSI-ized, changed types of funcs args
	05-06-92	sml		added 2nd arg for FI_process_event; 
						  changed local arg type for ANSI
*/

/*************************************/
/* */
/* This file contains all of the functions pertaining to the */
/* "copy gadget" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Mar. 28, 1989 */
/* */
/*************************************/

#include <math.h>
#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"
#include "FEI.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

struct seq_struct seq_list[1001];
int Total_gadgets;

int num_displayed_gadgets;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern Form Message_form;
extern int command_is_active;
extern char current_command_string[80];
extern struct gadget_struct gadget_attr;
extern int Two_vscreens_flag;

extern GC xfb_GC;
extern XGCValues GC_values;
extern hilite_plane;
extern Display *display;

extern int font_count;
extern Font Font_array[200];
extern Cursor curs;

extern GC dyn_GC;
extern GC dyn_GC_values;
extern int Segment_count;
extern XSegment segs[100];

#define TYPEFACE_LIST_FLD 22

static void Draw_dynamic_arrow();
/* static void Insure_only_one_sequence(); */

/*************************************************************************/
/* */
/* kill_create_sequence() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to CREATE_SEQ indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_create_sequence(void)
{
  char t_str[256];

  if (command_is_active == CREATE_SEQUENCE)
  {
     command_is_active = 0;
     strcpy (current_command_string, "None");

     FIfld_set_text (Message_form, 11, 0, 0, "", 0);
     FIfld_set_text (Message_form, 22, 0, 0, "", 0);
     FIfld_set_text (Message_form, 44, 0, 0, "", 0);

     UMSGetByNum (t_str, FB_P_SELCOM, 0);
     FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

     seq_list[1000].xlo[0] = 0;
     seq_list[1000].ylo[0] = 0;

     if (work_form != NULL) /* Form already displayed */
     {
        FIf_set_builder_mode_off ((struct FIform_obj *)work_form);
     }
  }
}


/*-----------------------------------------------------------------------*/

void Draw_arrow (int color,
                 int x1,
                 int y1,
                 int x2,
                 int y2,
                 int index)
{
  double angle;
  int xdelta, ydelta;
  int xdelta2, ydelta2;
  int Point1_x, Point1_y, Point2_x, Point2_y;

  if (x1 == x2)
  {
    if (y1 < y2)
    {
      Point1_x = x2 - 8;
      Point1_y = y2 - 13;
      Point2_x = x2 + 8;
      Point2_y = y2 - 13;
    }
    else
    {
      Point1_x = x2 - 8;
      Point1_y = y2 + 13;
      Point2_x = x2 + 8;
      Point2_y = y2 + 13;
    }
  }
  else if (y1 == y2)
  {
    if (x1 < x2)
    {
      Point1_x = x2 - 13;
      Point1_y = y2 - 8;
      Point2_x = x2 - 13;
      Point2_y = y2 + 8;
    }
    else
    {
      Point1_x = x2 + 13;
      Point1_y = y2 - 8;
      Point2_x = x2 + 13;
      Point2_y = y2 + 8;
    }
  }
  else
  {
    angle = atan2 ((double)(abs (y2 - y1)), (double)(abs (x2 - x1)));

    xdelta = (int) (cos (.52 - angle) * 15);

    xdelta *= -1;

    ydelta = (int) (sin (.52 - angle) * 15);

    ydelta *= -1;

    xdelta2 = (int) (sin (1.05 - angle) * 15);

    ydelta2 = (int) (cos (1.05 - angle) * 15);

    if (((x2 - x1) < 0) && ((y2 - y1) > 0))
    {
      ydelta *= -1;
      ydelta2 *= -1;
      xdelta *= -1;
      xdelta2 *= -1;
    }
    else if (((x2 - x1) < 0) && ((y2 - y1) < 0))
    {
      xdelta *= -1;
      xdelta2 *= -1;
    }
    else if (((x2 - x1) > 0) && ((y2 - y1) > 0))
    {
      ydelta *= -1;
      ydelta2 *= -1;
    }

    Point1_x = x2 + xdelta;
    Point1_y = y2 + ydelta;
    Point2_x = x2 - xdelta2;
    Point2_y = y2 + ydelta2;
  }

  gadget_attr.x_pos = x2;
  gadget_attr.y_pos = y2;

  seq_list[index].line_color = color;
  seq_list[index].xlo[0] = x1;
  seq_list[index].ylo[0] = y1;
  seq_list[index].xhi[0] = x2;
  seq_list[index].yhi[0] = y2;

  seq_list[index].xlo[1] = x2;
  seq_list[index].ylo[1] = y2;
  seq_list[index].xhi[1] = Point1_x;
  seq_list[index].yhi[1] = Point1_y;

  seq_list[index].xlo[2] = x2;
  seq_list[index].ylo[2] = y2;
  seq_list[index].xhi[2] = Point2_x;
  seq_list[index].yhi[2] = Point2_y;
}

/*------------------------------------------------------------------------*/

/* ARGSUSED */
static void Draw_dynamic_arrow (Window window,
                                int x1,
                                int y1,
                                int x2,
                                int y2)
{
  double angle;
  int xdelta, ydelta;
  int xdelta2, ydelta2;

  segs[Segment_count].x1 = x1;
  segs[Segment_count].y1 = y1;
  segs[Segment_count].x2 = x2;
  segs[Segment_count].y2 = y2;

  if (x1 == x2)
  {
    if (y1 < y2)
    {
      segs[Segment_count + 1].x1 = x2;
      segs[Segment_count + 1].y1 = y2;
      segs[Segment_count + 1].x2 = x2 - 8;
      segs[Segment_count + 1].y2 = y2 - 13;

      segs[Segment_count + 2].x1 = x2;
      segs[Segment_count + 2].y1 = y2;
      segs[Segment_count + 2].x2 = x2 + 8;
      segs[Segment_count + 2].y2 = y2 - 13;
    }
    else
    {
      segs[Segment_count + 1].x1 = x2;
      segs[Segment_count + 1].y1 = y2;
      segs[Segment_count + 1].x2 = x2 - 8;
      segs[Segment_count + 1].y2 = y2 + 13;

      segs[Segment_count + 2].x1 = x2;
      segs[Segment_count + 2].y1 = y2;
      segs[Segment_count + 2].x2 = x2 + 8;
      segs[Segment_count + 2].y2 = y2 + 13;
    }
  }
  else if (y1 == y2)
  {
    if (x1 < x2)
    {
      segs[Segment_count + 1].x1 = x2;
      segs[Segment_count + 1].y1 = y2;
      segs[Segment_count + 1].x2 = x2 - 13;
      segs[Segment_count + 1].y2 = y2 - 8;

      segs[Segment_count + 2].x1 = x2;
      segs[Segment_count + 2].y1 = y2;
      segs[Segment_count + 2].x2 = x2 - 13;
      segs[Segment_count + 2].y2 = y2 + 8;
    }
    else
    {
      segs[Segment_count + 1].x1 = x2;
      segs[Segment_count + 1].y1 = y2;
      segs[Segment_count + 1].x2 = x2 + 13;
      segs[Segment_count + 1].y2 = y2 - 8;

      segs[Segment_count + 2].x1 = x2;
      segs[Segment_count + 2].y1 = y2;
      segs[Segment_count + 2].x2 = x2 + 13;
      segs[Segment_count + 2].y2 = y2 + 8;
    }
  }
  else
  {
    angle = atan2 ((double)(abs (y2 - y1)) , (double)(abs (x2 - x1)));

    xdelta = (int) (cos (.52 - angle) * 15);

    xdelta *= -1;

    ydelta = (int) (sin (.52 - angle) * 15);

    ydelta *= -1;

    xdelta2 = (int) (sin (1.05 - angle) * 15);

    ydelta2 = (int) (cos (1.05 - angle) * 15);


    if (((x2 - x1) < 0) && ((y2 - y1) > 0))
    {
      ydelta *= -1;
      ydelta2 *= -1;
      xdelta *= -1;
      xdelta2 *= -1;
    }
    else if (((x2 - x1) < 0) && ((y2 - y1) < 0))
    {
      xdelta *= -1;
      xdelta2 *= -1;
    }
    else if (((x2 - x1) > 0) && ((y2 - y1) > 0))
    {
      ydelta *= -1;
      ydelta2 *= -1;
    }

    segs[Segment_count + 1].x1 = x2;
    segs[Segment_count + 1].y1 = y2;
    segs[Segment_count + 1].x2 = x2 + xdelta;
    segs[Segment_count + 1].y2 = y2 + ydelta;

    segs[Segment_count + 2].x1 = x2;
    segs[Segment_count + 2].y1 = y2;
    segs[Segment_count + 2].x2 = x2 - xdelta2;
    segs[Segment_count + 2].y2 = y2 + ydelta2;
  }

  Segment_count += 3;
}

/*-----------------------------------------------------------------------*/

int Poke_arrow_endpoint (int anchor_x,
                         int anchor_y,
                         int *x_pos,
                         int *y_pos)
{
  int x_max, y_max, x, y;
  int done;
  int old_x, old_y;
  char t_str[256];

  /* change root and child from int to Window for ANSI */
  Window root, child;
  /* change flags from int to unsigned int for ANSI */
  unsigned int flags;
  int root_x, root_y;
  int win_x, win_y;

  Window form_window;

  XEvent event;
  int grab;
  int not_initial_draw = 0;

  FIf_get_window (work_form, &form_window);

  FIf_get_size (work_form, &x_max, &y_max);

  old_x = 0;
  old_y = 0;

  /*
  XSetPlaneMask (display, xfb_GC, hilite_plane);
  XSetSubwindowMode (display, xfb_GC, IncludeInferiors);
  */
  if (!curs)
  {
    CreateBlankCursor (display, form_window);
  }

  grab = XGrabPointer (display, form_window, True,
      (unsigned int)(PointerMotionMask | PointerMotionHintMask),
      GrabModeAsync, GrabModeAsync, form_window, curs, CurrentTime);

  done = !(grab == GrabSuccess);

  while (done == 0)
  {
    XNextEvent (display, &event);

    if (event.type == MotionNotify)
    {
      /*** Remove all from queue ***/
      while (XCheckMaskEvent (display, PointerMotionMask, &event));
      {
        XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &win_x, &win_y, &flags);
      }
    }
    else if (event.type == ButtonPress)
    {
      if (event.xbutton.button == Button2)
      {
        XQueryPointer (display, form_window, &root, &child,
            &root_x, &root_y, &x, &y, &flags);

        if ((win_x >= 0) && (win_x < x_max) &&
            (win_y >= 0) && (win_y < y_max))
        {
          *x_pos = x;
          *y_pos = y;

          done = 2; /* success */
        }
      }
      else if (event.xbutton.button == Button3)
      {
        done = 1; /* User aborted command */
      }
    }

    while (XCheckMaskEvent (display, ExposureMask, &event))
    {
	  /* add 2nd arg for ANSI */
      FI_process_event (&event, 0);
    }

    {
      XQueryPointer (display, form_window, &root, &child,
          &root_x, &root_y, &x, &y, &flags);
      /* Cursor inside window */
      if ((x >= 0) && (x < x_max) &&  (y >= 0) && (y < y_max))
      {
        if ((x != old_x) || (y != old_y))
        {
          if (not_initial_draw)
          {
            Draw_dynamic_arrow (form_window, anchor_x, anchor_y, old_x, 
                old_y);
          }
          not_initial_draw = 1;

          old_x = x;
          old_y = y;

          Draw_dynamic_arrow (form_window, anchor_x, anchor_y, x, y);

          XDrawSegments(display, form_window, dyn_GC, segs, Segment_count);
          Segment_count = 0;
          XFlush (display);

          UMSGetByNum (t_str, FB_I_XY, "%d%d", x, y);
          FIfld_set_text (Message_form, 44, 0, 0, t_str, 0);
        }
      }
    }
  }

  /* Erase existing lines */

  Draw_dynamic_arrow (form_window, anchor_x, anchor_y, x, y);

  XDrawSegments(display, form_window, dyn_GC, segs, Segment_count);
  Segment_count = 0;
  XFlush (display);

  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  while (XCheckMaskEvent (display, ButtonPressMask | ButtonReleaseMask, &event))
  {
    /* Eat all button related events */
  }

  if (grab == GrabSuccess)
  {
    XUngrabPointer (display, CurrentTime);
  }

  return (done);
}

/*--------------------------------------------------------------------*/

void Clean_up_lines (void)
{
  int x;
  int xsize, ysize;

  for (x = 0; x < Total_gadgets; x++)
  {
    if (seq_list[x].hilite_flag == 1)
    {
      FIg_hilite (work_form, seq_list[x].gadget);
    }
    else
    {
      FIg_unhilite (work_form, seq_list[x].gadget);
    }

    if (seq_list[x].display_flag == 1)
    {
      FIg_display (work_form, seq_list[x].gadget);
    }
    else
    {
      FIg_erase (work_form, seq_list[x].gadget);
    }
  }

  FIf_get_size (work_form, &xsize, &ysize);
  FIf_paint_area (work_form, 0, 0, xsize, ysize);
}


/*--------------------------------------------------------------------*/

void Refresh_lines (void)
{
  int x;

  for (x = 0; x < Total_gadgets; x++)
  {
    if (seq_list[x].to_gadget > 0)
    {
      Paint_arrow (x);
    }
    FIg_draw_a_label (seq_list[x].gadget);
  }

  if ((seq_list[1000].xlo[0] != 0) && (seq_list[1000].ylo[0] != 0))
  {
    Paint_arrow (1000);
  }

  XFlush (display);
}


/*--------------------------------------------------------------------*/

void Determine_current_sequences(void)
{
  int form_xsize, form_ysize;
  int status, x, type;
  int attr;
  int num_gadgets, gadget_array[1000];

  Total_gadgets = 0;
  num_displayed_gadgets = 0;

  FIf_get_size (work_form, &form_xsize, &form_ysize);

  FIf_gadgets_inside_area (work_form, 0, 0, form_xsize, form_ysize,
               &num_gadgets, gadget_array);

  for (x = 0; x < num_gadgets; x++)
  {
    FIg_get_type (work_form, gadget_array[x], &type);

    seq_list[Total_gadgets].gadget = gadget_array[x];

    FIg_get_next_in_seq (work_form, gadget_array[x],
        &seq_list[Total_gadgets].to_gadget);

    if (seq_list[Total_gadgets].to_gadget > 0)
    {

      status = FIg_get_type (work_form,
          seq_list[Total_gadgets].to_gadget,
          &type);

      if ((status != FI_SUCCESS) ||
          (type == FI_GROUP) ||
          (type == FI_TEXT) ||
          (type == FI_SYM) ||
          (type == FI_RECT) ||
          (type == FI_LINE) ||
          (type == FI_BEZEL) ||
          (type == FI_GAUGE))
      {
        seq_list[Total_gadgets].to_gadget = 0;
        FIg_set_next_in_seq (work_form, gadget_array[x], 0);
      }
    }

    FIg_get_attr (work_form, gadget_array[x], &attr);

    if (attr & FI_NOT_DISPLAYED)
    {
      seq_list[Total_gadgets].display_flag = 0;
    }
    else
    {
      seq_list[Total_gadgets].display_flag = 1;
    }

    if (attr & FI_HILITED)
    {
      seq_list[Total_gadgets].hilite_flag = 1;
    }
    else
    {
      seq_list[Total_gadgets].hilite_flag = 0;
    }
    Total_gadgets++;
  }
}

/*--------------------------------------------------------------------*/

void Display_current_sequences(void)
{
  int from_xpos, from_ypos, from_xsize, from_ysize;
  int to_xpos, to_ypos, to_xsize, to_ysize;
  int x1, y1, x2, y2, x;
  int xpos, ypos, xsize, ysize;

  for (x = 0; x < Total_gadgets; x++)
  {
    if (seq_list[x].to_gadget > 0)
    {
      FIg_unhilite (work_form, seq_list[x].gadget);
      FIg_unhilite (work_form, seq_list[x].to_gadget);
      FIg_display (work_form, seq_list[x].gadget);
      FIg_display (work_form, seq_list[x].to_gadget);

      FIg_get_location (work_form, seq_list[x].gadget,
          &from_xpos, &from_ypos);

      FIg_get_location (work_form, seq_list[x].to_gadget,
          &to_xpos, &to_ypos);

      FIg_get_size (work_form, seq_list[x].gadget,
          &from_xsize, &from_ysize);

      FIg_get_size (work_form, seq_list[x].to_gadget,
          &to_xsize, &to_ysize);

      x1 = from_xpos + (from_xsize / 2);
      y1 = from_ypos + (from_ysize / 2);
      x2 = to_xpos + (to_xsize / 2);
      y2 = to_ypos + (to_ysize / 2);

      Draw_arrow (FI_YELLOW, x1, y1, x2, y2, x);
    }

    FIf_get_size (work_form, &xsize, &ysize);
    FIf_get_location (work_form, &xpos, &ypos);

    Refresh_lines ();
  }

  for (x = 0; x < Total_gadgets; x++)
  {
    if (seq_list[x].to_gadget > 0)
    {
      FIg_draw_a_label (seq_list[x].gadget);
      FIg_draw_a_label (seq_list[x].to_gadget);
    }
  }
}

/*--------------------------------------------------------------------*/
#ifdef NEEDED
static void Insure_only_one_sequence (int start_gadget,
                                      int connect_gadget)
{
  int x, z;
  int seq_array[1000];
  int seq_array_count;
  int current_link;
  int link_found;

  /***************************************************************/
  /* */
  /* First remove all links to the connect_gadget except for the */
  /* start_gadget. */
  /* */
  /***************************************************************/

  for (x = 0; x < Total_gadgets; x++)
  {
    if ((seq_list[x].to_gadget == connect_gadget) &&
        (seq_list[x].gadget != start_gadget))
    {
      seq_list[x].line_color = FI_LT_GREY;
      Paint_arrow (x);

      FIg_set_next_in_seq (work_form, seq_list[x].gadget, 0);
      seq_list[x].to_gadget = 0;
    }
  }

  seq_array_count = 1;
  seq_array[0] = start_gadget;

  /*************************************************/
  /* */
  /* Figure out back links to start gadget, if any */
  /* */
  /*************************************************/

  current_link = start_gadget;
  link_found = 1;
  while (link_found != 0)
  {
    link_found = 0;

    for (x = 0; x < Total_gadgets; x++)
    {
      if (seq_list[x].to_gadget == current_link)
      {
        seq_array[seq_array_count++] = seq_list[x].gadget;
        current_link = seq_list[x].gadget;
        link_found = 1;
        x = Total_gadgets;
      }
    }
  }

  /******************************************************/
  /* */
  /* Figure out forward links from start gadget, if any */
  /* */
  /******************************************************/

  current_link = start_gadget;
  link_found = 1;

  while (link_found != 0)
  {
    link_found = 0;

    for (x = 0; x < Total_gadgets; x++)
    {
      if ((seq_list[x].gadget == current_link) &&
          (seq_list[x].to_gadget > 0))
      {
        seq_array[seq_array_count++] = seq_list[x].gadget;
        current_link = seq_list[x].to_gadget;
        link_found = 1;
        x = Total_gadgets;
      }
    }
  }

  /**********************************************************************/
  /* */
  /* Now go through all Total_gadgets and delete any connections that */
  /* are not contained in seq_array. */
  /* */
  /**********************************************************************/

  for (z = 0; z < Total_gadgets; z++)
  {
    if (seq_list[z].to_gadget > 0)
    {
      link_found = 0;

      for (x = 0; x < seq_array_count; x++)
      {
        if (seq_array[x] == seq_list[z].gadget)
        {
          link_found = 1;
          x = seq_array_count;
        }
      }

      if (link_found == 0)
      {
        seq_list[z].line_color = FI_LT_GREY;
        Paint_arrow (z);

        FIg_set_next_in_seq (work_form, seq_list[z].gadget, 0);
        seq_list[z].to_gadget = 0;
      }
    }
  }
}
#endif

/*--------------------------------------------------------------------*/

void Paint_arrow (int label)
{
  Window window;
  int fgcolor, bgcolor;
  int (*my_translate_color)();

  FIf_get_window (work_form, &window);

  FI_get_env (FI_TRANSLATE_COLOR, &my_translate_color);

  bgcolor = (*my_translate_color)( 0, FI_LT_GREY);
  XSetBackground (display, xfb_GC, bgcolor);
  XSetPlaneMask (display, xfb_GC, AllPlanes);

  fgcolor = (*my_translate_color)( 0, seq_list[label].line_color);
  XSetForeground (display, xfb_GC, fgcolor);
  XSetSubwindowMode (display, xfb_GC, IncludeInferiors);

  XSetLineAttributes (display, xfb_GC, 0, LineSolid, CapButt, JoinRound);

  segs[0].x1 = seq_list[label].xlo[0];
  segs[0].y1 = seq_list[label].ylo[0];
  segs[0].x2 = seq_list[label].xhi[0];
  segs[0].y2 = seq_list[label].yhi[0];

  segs[1].x1 = seq_list[label].xlo[1];
  segs[1].y1 = seq_list[label].ylo[1];
  segs[1].x2 = seq_list[label].xhi[1];
  segs[1].y2 = seq_list[label].yhi[1];

  segs[2].x1 = seq_list[label].xlo[2];
  segs[2].y1 = seq_list[label].ylo[2];
  segs[2].x2 = seq_list[label].xhi[2];
  segs[2].y2 = seq_list[label].yhi[2];

  XDrawSegments(display, window, xfb_GC, segs, 3);
  Segment_count = 0;
  XFlush (display);
}

/*--------------------------------------------------------------------*/


/*************************************************************************/
/* */
/* execute_create_sequence() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_create_sequence(void)
{
  char t_str[256];
  int status;
  int seq_gadget, seq2_gadget;
  int not_finished, continue_inner_loop;
  int xsize, ysize, xpos, ypos;
  Window window;		/* change from in to Window for ANSI */
  int display_flag, hilite_flag;
  int gadget_type;
  int accept_x, accept_y, mode;
  int x1, y1, x2, y2, x;
  int from_xpos, from_ypos, from_xsize, from_ysize;
  int to_xpos, to_ypos, to_xsize, to_ysize;
  int gadget_index = 0;
  int line_accepted;
  XEvent event;

  if (work_form == NULL)
  {
    kill_create_sequence();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_CRESEQ, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    UMSGetByNum (t_str, FB_I_DISPCURSEQ, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    Determine_current_sequences();

    Display_current_sequences ();

    FIf_set_builder_mode_on ((struct FIform_obj *)work_form);

    not_finished = 1;
    FIf_get_window (work_form, &window);

    while (not_finished)
    {
      mode = 0; /* make operator enter data point */

      UMSGetByNum (t_str, FB_I_SELSTARTGDT, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Select_gadget (&seq_gadget, &xsize, &ysize, &display_flag,
          &hilite_flag, &accept_x, &accept_y, mode);

      if (status == 2) /* Success */
      {
        FIg_get_type (work_form, seq_gadget, &gadget_type);

        if ((gadget_type == FI_SYM) ||
            (gadget_type == FI_LINE) ||
            (gadget_type == FI_TEXT) ||
            (gadget_type == FI_RECT) ||
            (gadget_type == FI_BEZEL) ||
            (gadget_type == FI_GAUGE))
        {
          UMSGetByNum (t_str, FB_E_NOTFORSEQ, 0);
          FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

          FIg_unhilite (work_form, seq_gadget);
        }
        else
        {
          continue_inner_loop = 1;

          while (continue_inner_loop)
          {
            UMSGetByNum (t_str, FB_P_POKNXTSEQ, 0);
            FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

            FIg_get_location (work_form, seq_gadget, 
                &from_xpos, &from_ypos);

            FIg_get_size (work_form, seq_gadget,
                &from_xsize, &from_ysize);

            x1 = from_xpos + (from_xsize / 2);
            y1 = from_ypos + (from_ysize / 2);

            status = Poke_arrow_endpoint (x1, y1, &x2, &y2);

            if (status == 2) /* success */
            {
              mode = 1; /* Don't let the operator enter data point */
              accept_x = x2;
              accept_y = y2;

              status = Select_gadget (&seq2_gadget, &xsize, &ysize,
                  &display_flag, &hilite_flag,
                  &accept_x, &accept_y, mode);

              FIfld_set_text (Message_form, 22, 0, 0, "", 0);

              if (status == 2)
              {
                FIg_get_type (work_form, seq2_gadget, &gadget_type);

                if ((gadget_type == FI_SYM) ||
                    (gadget_type == FI_LINE) ||
                    (gadget_type == FI_TEXT) ||
                    (gadget_type == FI_RECT) ||
                    (gadget_type == FI_BEZEL) ||
                    (gadget_type == FI_GAUGE))
                {
                  UMSGetByNum (t_str, FB_E_NOTFORSEQ, 0);
                  FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

                  FIg_unhilite (work_form, seq2_gadget);
                }
                else if (seq_gadget == seq2_gadget)
                {
                  FIfld_set_text (Message_form, 22, 0, 0,
                    "Gadget cannot be sequenced to itself", 0);
                }
                else
                {
                  FIg_get_location (work_form, seq2_gadget,
                    &to_xpos, &to_ypos);

                  FIg_get_size (work_form, seq2_gadget,
                    &to_xsize, &to_ysize);
                
                  x2 = to_xpos + (to_xsize / 2);
                  y2 = to_ypos + (to_ysize / 2);
                
                  for (x = 0; x < Total_gadgets; x++)
                  {
                    if (seq_list[x].gadget == seq_gadget)
                    {
                      gadget_index = x;
                      break;
                    }
                  }
                
                  line_accepted = 1;
                
                  if (seq_list[gadget_index].to_gadget > 0)
                  {
                    Draw_arrow (FI_GREEN, x1, y1, x2, y2, 1000);
                
                    seq_list[gadget_index].line_color = FI_RED;
                    Paint_arrow (gadget_index);
                    Paint_arrow (1000);
                
                    UMSGetByNum (t_str, FB_P_ACCREJ, 0);
                    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
                
                    status = Poke_plain_point (window, &xpos, &ypos);
                
                    if (status == 2) /* Success */
                    {
                      seq_list[gadget_index].line_color = FI_LT_GREY;
                      Paint_arrow (gadget_index);
                
                      seq_list[gadget_index].line_color = FI_YELLOW;
                      for (x = 0; x < 3; x++)
                      {
                        seq_list[gadget_index].xlo[x] =
                            seq_list[1000].xlo[x];
                        seq_list[gadget_index].ylo[x] =
                            seq_list[1000].ylo[x];
                        seq_list[gadget_index].xhi[x] =
                            seq_list[1000].xhi[x];
                        seq_list[gadget_index].yhi[x] =
                            seq_list[1000].yhi[x];
                      }
                      Paint_arrow (gadget_index);
                
                      seq_list[1000].xlo[0] = 0;
                      seq_list[1000].ylo[0] = 0;
                
                      line_accepted = 1;
                    }
                    else /* Rejected */
                    {
                      seq_list[1000].line_color = FI_LT_GREY;
                      Paint_arrow (1000);
                      seq_list[1000].xlo[0] = 0;
                      seq_list[1000].ylo[0] = 0;
                
                      seq_list[gadget_index].line_color = FI_YELLOW;
                      Paint_arrow (gadget_index);
                
                      line_accepted = 0;
                    }
                
                    FIf_get_size (work_form, &xsize, &ysize);
                    FIf_paint_area (work_form, 0, 0, xsize, ysize);
                
                    /* wait for event */
/*
                    XMaskEvent (display, ExposureMask, &event);
                    FI_process_event (&event);
*/                
                    while (XCheckMaskEvent (display, ExposureMask, &event))
                    {
					  /* added 2nd arg for ANSI */
                      FI_process_event (&event, 0);
                    }
                
                    if (line_accepted == 0)
                    {
                      Refresh_lines();
                    }
                  }
                  else
                  {
                    Draw_arrow (FI_YELLOW, x1, y1, x2, y2, gadget_index);
                    Paint_arrow (gadget_index);
                  }
                
                  if (line_accepted == 1)
                  {
                    FIg_set_next_in_seq (work_form, seq_gadget, 
                        seq2_gadget);
                    seq_list[gadget_index].to_gadget = seq2_gadget;
                
                    Refresh_lines();

                    /*
                    Insure_only_one_sequence (seq_gadget, seq2_gadget);
                    */
                    seq_gadget = seq2_gadget;
                  }
                }
              }
            }
            else
            {
              continue_inner_loop = 0;

              FIg_unhilite (work_form, seq_gadget);
            }
          }
        }
      }
      else
      {
        not_finished = 0;
      }
    }

    kill_create_sequence();

    Clean_up_lines();
  }
}
