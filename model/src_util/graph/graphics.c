/*
                G R A P H I C S   L I B R A R Y

    This file contains some specialised graphics routines written
    to facilitate the display and the user-interface for any program.
    The functions make use of calls to the 'libtools.a'-library to do 
    their job. Some functions are simply intended to be abstractions of the 
    'libtools.a' functions so that changing a device or using some other
    display-software, would need changes to be made only in this file.

  HISTORY

    SS  :  Long ago  :  Creation
    DHM :  Long ago  :  Added some functions and modified some
    SS  :  08/28/89  :  Modified some more functions.
*/

#include <stdio.h>
#include <math.h>
#ifndef X11
#include <tools.h>
#endif
#ifdef CLIX
#include <sdl.h>
#endif
#include <ctype.h>
#include <values.h> 
#include "graphics.h"

#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#endif

#ifndef X11 
static int w_no = NULL;
static int vs_no;
static char keyin_buff[MAX_KEYIN];
static char keybrd_buff[MAX_KEYBRD];
#endif
static int xright, ytop, xleft, ybottom;

#ifdef X11
Display *xdisplay;
Window xwindow;
static int xscreen;
static XSizeHints xhint;
static GC xgc;

static XColor vlt[] =
  {
    {BACKGR,  4*4369,  5*4369,  6*4369, DoRed | DoGreen | DoBlue,  0},
    { BLACK,  	   0,  	    0,       0, DoRed | DoGreen | DoBlue,  0},
    {  BLUE,       0, 11*4369, 14*4369, DoRed | DoGreen | DoBlue,  0}, 
    { GREEN,       0, 10*4369,       0, DoRed | DoGreen | DoBlue,  0},
    {   RED, 12*4369,       0,       0, DoRed | DoGreen | DoBlue,  0}, 
    {  PINK, 10*4369,       0, 10*4369, DoRed | DoGreen | DoBlue,  0},
    {YELLOW, 15*4369, 15*4369,       0, DoRed | DoGreen | DoBlue,  0},
    { WHITE, 15*4369, 15*4369, 15*4369, DoRed | DoGreen | DoBlue,  0}, 
    {FOREGR, 15*4369, 15*4369, 15*4369, DoRed | DoGreen | DoBlue,  0},
  };
#else
static struct vlt_slot vlt[] =
  {
    {BACKGR,  4*4369,  5*4369,  6*4369 },
    { BLACK,  	   0,  	    0,       0 },
    {  BLUE,       0, 11*4369, 14*4369 }, 
    { GREEN,       0, 10*4369,       0 },
    {   RED, 12*4369,       0,       0 }, 
    {  PINK, 10*4369,       0, 10*4369 },
    {YELLOW, 15*4369, 15*4369,       0 },
    { WHITE, 15*4369, 15*4369, 15*4369 }, 
    {FOREGR, 15*4369, 15*4369, 15*4369 },
  };
#endif


/*
  Function to generate the graphics window and to initialize in
  preparation of graphics functions.
*/

#ifdef X11
void EMinit_graph (name, extents, out_wno, options, argc, argv)
#else
void EMinit_graph (name, extents, out_wno, options)
#endif
  char *name;
  int *extents, *out_wno;
  unsigned short options;
#ifdef X11
  int argc;
  char *argv[];
#endif
{
  char window[80];
#ifdef X11
  XFontStruct *font_info;
  unsigned long border_width;
  char xwin_name[30];
  int num_cmaps;
  Colormap *installed_cmaps;
  Colormap cmap;
  int      max;
#endif
#ifdef X11
  strcpy(xwin_name,"UV_plot");
#endif

  if (name == NULL)
    strcpy (window, "Window");
  else
    strcpy (window, name);

  if (extents == NULL)
    {
    xleft = XLEFT;
    ytop = YTOP;
    xright= XRIGHT;
    ybottom = YBOTTOM;
    }
  else
    {
    xleft = extents[0];
    ytop = extents[1];
    xright = extents[2];
    ybottom = extents[3];
    }

#ifdef X11
  xdisplay = XOpenDisplay("");
  xscreen = DefaultScreen(xdisplay);

  xhint.x = xleft;
  xhint.y = ytop;
  xhint.width = xright - xleft + 1;
  xhint.height = ybottom - ytop + 1;
  xhint. flags = PPosition | PSize;

  border_width = 5;			
  xwindow = XCreateSimpleWindow(xdisplay, RootWindow(xdisplay, xscreen),
		xhint.x, xhint.y, xhint.width, xhint.height,  border_width,
		0, 1);
  max = MaxCmapsOfScreen(ScreenOfDisplay(xdisplay,xscreen)); 
  if (max > 1)
  {
     cmap = XCreateColormap(xdisplay,xwindow,DefaultVisual(xdisplay,xscreen),
			    AllocNone);
  }
  else
  {
  installed_cmaps = XListInstalledColormaps( xdisplay, xwindow, &num_cmaps );
  if ( installed_cmaps && num_cmaps )
     {
     cmap = installed_cmaps[0];
     XFree( (char *)installed_cmaps );
     }
  else
     cmap = DefaultColormap( xdisplay, xscreen );
  }

  store_colors( cmap );

  XSetWindowBackground( xdisplay, xwindow, vlt[BLACK].pixel );
  XSetWindowColormap( xdisplay, xwindow, cmap );

  XSetStandardProperties(xdisplay, xwindow, xwin_name, xwin_name, None, argv,
		argc, &xhint);

  load_font(xdisplay, &font_info);
  xgc = XCreateGC(xdisplay, xwindow, 0, 0);
  XSetFont(xdisplay, xgc, font_info->fid);
  XSelectInput(xdisplay, xwindow, ExposureMask|StructureNotifyMask);
  XMapWindow(xdisplay, xwindow);
  *out_wno = xwindow;

#else
  Enter_tools ();
  Inq_displayed_vs (&vs_no);
  Create_win (vs_no, window, xleft, ytop, xright, ybottom, &w_no);

  if (options & COLOR_MODE)
    Loadvlt (vs_no, vlt, MAX_COLORS);

  if (options & INPUT_MODE)
    {
    Set_message_mode (4);
    Set_keyin_buffer (keyin_buff, MAX_KEYIN);
    Set_keyboard_buffer (keybrd_buff, MAX_KEYBRD);
    Enable_events (BUTTON_EVENT | KEYIN_EVENT | KEYBOARD_EVENT);
    }
  else
    {
    Set_win_sys_icon (w_no, REFRESH_ICON_VALUE, 0);
    Set_win_sys_icon (w_no, MODIFY_ICON_VALUE, 0);
    Update_win_icon (w_no);
    Enable_events (DELETE_EVENT | REFRESH_EVENT);
    }

  Display_win (w_no);
  *out_wno = w_no;

#endif
}


/*
  Function to be invoked while exiting graphics from the routine
*/

EMexit_graph()
{
#ifdef X11
 if (xdisplay)
 {
   XUnmapWindow(xdisplay, xwindow);
   XFreeGC(xdisplay, xgc);
   XDestroyWindow(xdisplay, xwindow);
   XCloseDisplay(xdisplay);
 }
   exit(1);
#else
   Exit_tools();
#endif
}


/*
   Function to obtain a character input from the keyboard. The value of
   the function returned is the character sought.
*/

char EMget_char (prompt)
char prompt[];
{
#ifndef X11 		/* Not used */
  int cur_event_mask, char_count;

  Display_message (BOTT_LEFT, CENTERED, prompt);
  Wait_for_events (KEYBOARD_EVENT, &cur_event_mask);
  Get_keyboard_data (&char_count);
  Clear_message (BOTT_LEFT);
  return (keybrd_buff[0]);
#endif
}



/*
  Function to obtain a digitized point (mouse data-point) in
  view coordinates. The function returns a character which is the NULL
  character unless the point has been digitized with the rightmost
  button. In that case it is 'q' on a single-click or a 'Q' on a
  double-click.
*/

char EMget_xy (prompt, x, y)
char prompt[];
double *x, *y;
{
#ifndef X11		/* Not used */
  char key;
  int cur_event_mask;
  int w, xi, yi, butt, tran, time;

  Display_message (BOTT_LEFT, CENTERED, prompt);
  Wait_for_events (BUTTON_EVENT, &cur_event_mask);
  do 
    Get_button_data (&w, &xi, &yi, &butt, &tran, &time);
  while (w != w_no);

  *x = xi;
  *y = (ybottom - ytop) - yi;
  key = NULL;
  if (butt & 2) 
    {
    key = 'q';
    if (tran == DOUBLE_CLICK)
      key = 'Q';
    }
  Clear_message (BOTT_LEFT);
  return (key);
#endif
}


/*
  Function to obtain a string from the keyboard. The value returned by
  the function is the length of the string.
*/

int EMget_string (prompt, str)
char prompt[], str[];
{
#ifndef X11		/* Not used */
  int cur_event_mask, char_count;

  Display_message (BOTT_LEFT, CENTERED, prompt);
  Process_keyin (BOTT_RIGHT, LEFTJUST, "");
  Wait_for_events (KEYIN_EVENT, &cur_event_mask);
  Get_keyin_data (&char_count);
  keyin_buff[char_count] = NULL;
  strcpy (str, keyin_buff);
  Clear_message (BOTT_LEFT);
  Clear_message (BOTT_RIGHT);
  return (strlen (str));
#endif
}



/*
  Function to obtain an integer from the keyboard
*/

int EMget_inum (prompt)
char prompt[];
{
#ifndef X11		/* Not used */
  char str[40];
  int cur_event_mask, char_count, inum;

  Display_message (BOTT_LEFT, CENTERED, prompt);
  Process_keyin (BOTT_RIGHT, LEFTJUST, "");
  Wait_for_events (KEYIN_EVENT, &cur_event_mask);
  Get_keyin_data (&char_count);
  keyin_buff[char_count] = NULL;
  strcpy (str, keyin_buff);
  Clear_message (BOTT_LEFT);
  Clear_message (BOTT_RIGHT);
  sscanf (str, "%d", &inum);
  return (inum);
#endif
}



/*
  Function to return a double from the keyboard
*/

double EMget_dnum (prompt)
char prompt[];
{
#ifndef X11		/* Not used */
  char str[40];
  int cur_event_mask, char_count;
  double dnum;

  Display_message (BOTT_LEFT, CENTERED, prompt);
  Process_keyin (BOTT_RIGHT, LEFTJUST, "");
  Wait_for_events (KEYIN_EVENT, &cur_event_mask);
  Get_keyin_data (&char_count);
  keyin_buff[char_count] = NULL;
  strcpy (str, keyin_buff);
  Clear_message (BOTT_LEFT);
  Clear_message (BOTT_RIGHT);
  sscanf (str, "%lf", &dnum);
  return (dnum);
#endif
}



/*
  Function obtains a keystroke without waitng for the
  carriage return.
*/

char EMget_keystroke ()
{
#ifndef X11		/* Not used */
  int cur_event_mask, char_count;

  Display_message (TOP_RIGHT, CENTERED, "Press a key");
  Wait_for_events (KEYBOARD_EVENT, &cur_event_mask);
  Get_keyboard_data (&char_count);
  Clear_message (TOP_RIGHT);
  return (keybrd_buff[0]);
#endif
}



/*
  Functions to issue a message and/or a status string and to clear
  the same.
*/

void EMmessage (str)
char str[];
{
#ifndef X11		/* Not used */
  Display_message (TOP_LEFT, CENTERED, str);
#endif
}

void EMdemessage ()
{
#ifndef X11		/* Not used */
    Clear_message (TOP_LEFT);
#endif
}

void EMstatus (str)
char str[];
{
#ifndef X11		/* Not used */
  Display_message (TOP_RIGHT, CENTERED, str);
#endif
}

void EMdestatus ()
{
#ifndef X11		/* Not used */
  Clear_message (TOP_RIGHT);
#endif
}


/*
  Changes the active linestyle. All vectors drawn after this call will
  have this line-style.
*/

void EMset_linestyle (style)
int style;
{
#ifdef X11
  XGCValues gc_values;
#endif

#ifdef X11
  gc_values.line_style = style;
  XChangeGC(xdisplay, xgc, GCLineStyle, &gc_values);
#else
  linestyle (w_no, style);
#endif
}


/*
  Sets the foreground color. This color is used to draw the vectors. 
*/

void EMset_color (color)
int color;
{
#ifdef X11
  XSetForeground(xdisplay, xgc, vlt[color].pixel);
#else
  fgcolor (w_no, color);
#endif
}


/*
  Prompts the user for new color and sets the color. This color is then used
  to draw the vectors.
*/

void EMprompt_color ()
{
#ifndef X11		/* Not used */
  int color_inx, i;
  char key_str[10];

  EMmessage ("Blue,Green,Red,Pink,Yellow,White,Black,ERASE");

  start:
  EMget_string ("Keyin atleast first three letters of color", key_str);
  EMdestatus();

  for (i=0; i<strlen (key_str); i++)
    key_str[i] = toupper (key_str[i]);

  if (!strncmp (key_str, "BLU", 3))
    color_inx = BLUE;
  else if (!strncmp (key_str, "GRE", 3))
    color_inx = GREEN;
  else if (!strncmp (key_str, "RED", 3))
    color_inx = RED;
  else if (!strncmp (key_str, "PIN", 3))
    color_inx = PINK;
  else if (!strncmp (key_str, "YEL", 3))
    color_inx = YELLOW;
  else if (!strncmp (key_str, "WHI", 3))
    color_inx = WHITE;
  else if (!strncmp (key_str, "BLA", 3))
    color_inx = BLACK;
  else if (!strncmp (key_str, "ERA", 3))
    color_inx = BACKGR;
  else
    {
    EMstatus ("Invalid option selected");
    goto start;
    }
  EMset_color (color_inx);
  EMdemessage();
#endif
}


/*
  Moves to the position specified by x, y.
  That is, draws a dark vector to that location.
*/

void EMmove_vec (x, y)
double x, y;
{
#ifndef X11		/* Not used in X */
   int xi = x, yi = (ybottom - ytop) - (int) y;

   move (w_no, xi, yi);
#endif
}


/*
  Draws a vector with current linestyle, weight and color to the location
  specifed in view-coordinates.
*/

void EMdraw_vec (x, y)
double x, y;
{
#ifndef X11		/* Not used in X */
    int xi = x; int yi = (ybottom - ytop) - (int) y;

    draw (w_no, xi, yi);
#endif
}

/*
  Display a cross of a certain dimension (size), at the position specified by
  x and y.
*/

void EMdisp_cross (x, y, size)
double x, y;
int size;
{
  int xi = x, yi = (ybottom - ytop) - (int) y;
#ifdef X11
  XSegment xseg[2];
#endif

#ifdef X11
  xseg[0].x1 = xi-size; xseg[0].y1 = yi-size;
  xseg[0].x2 = xi+size; xseg[0].y2 = yi+size;
  xseg[1].x1 = xi+size; xseg[1].y1 = yi-size;
  xseg[1].x2 = xi-size; xseg[1].y2 = yi+size;
  XDrawSegments(xdisplay, xwindow, xgc, xseg, 2);
  XSync(xdisplay, 0);
#else
  move (w_no, xi-size, yi-size);
  draw (w_no, xi+size, yi+size);
  move (w_no, xi+size, yi-size);
  draw (w_no, xi-size, yi+size);
  move (w_no, xi, yi);
  flushbuffer (w_no);
#endif
}


/*
  Draws a solid linestring to the location specifed.  Eventually, this will
  call linestring().
*/

void EMdraw_linestring (pts, numpts, drawpt)
double pts[];
int numpts;
short drawpt;
{
  int i, j;
#ifdef X11
  int x1, y1, x2, y2;
#endif

#ifndef X11
  hidecursor (w_no);
#endif

  if (drawpt)
    EMdisp_cross (pts[0], pts[1], 1);
#ifndef X11
  else
    EMmove_vec (pts[0], pts[1]);
#endif

#ifdef X11
  for (i=1, j=2; i<numpts; i++, j+=2)
  {
    x1 = (int)(pts[j-2]);
    y1 = (ybottom - ytop) - (int)(pts[j-1]);
    x2 = (int)(pts[j]);
    y2 = (ybottom - ytop) - (int)(pts[j+1]);
    XDrawLine(xdisplay, xwindow, xgc, x1, y1, x2, y2);

    if (drawpt)
      EMdisp_cross (pts[j], pts[j+1], 1);
  }
      
#else
  for (i=1, j=2; i<numpts; i++, j+=2)
    {
    EMdraw_vec (pts[j], pts[j+1]);
    if (drawpt)
      EMdisp_cross (pts[j], pts[j+1], 1);
    }
#endif

#ifndef X11
  showcursor (w_no);
#endif

  return;
}


/*
  Draws the given set of points as 'points' with a weight as specified.
*/

void EMdraw_ptstring (pts, numpts, drawpt)
double (*pts)[2];
int numpts;
short drawpt;
{
  int i, xi, yi;
#ifdef X11
   XGCValues val;
   int       temp_weight;
   int       off;
#endif

#ifdef X11
  XGetGCValues(xdisplay,xgc,GCLineWidth,&val);

  temp_weight = val.line_width ;
  if  ( temp_weight == 0)
      temp_weight = 1;
  if (temp_weight > 30 ) temp_weight =32;
  if (temp_weight % 2)
      off = temp_weight / 2;
  else
      off = temp_weight / 2 -1;
#endif


  for (i=0; i<numpts; i++)
    {
    xi = pts[i][0];
    yi = (ybottom - ytop) - (int) pts[i][1];
#ifdef X11
    XFillRectangle(xdisplay, xwindow,
                   xgc, xi - off, yi - off, temp_weight,temp_weight);
#else
    pnt (w_no, xi, yi);
#endif
    }
}


/*
  Displays a box using the given corner points.
*/

void EMdisp_box (xmin, ymin, xmax, ymax)
double xmin, ymin, xmax, ymax;
{
  int xi1 = xmin, yi1 = (ybottom - ytop) - (int) ymin;
  int xi2 = xmax, yi2 = (ybottom - ytop) - (int) ymax;

#ifdef X11
  XDrawLine(xdisplay, xwindow, xgc, xi1, yi1, xi1, yi2);
  XDrawLine(xdisplay, xwindow, xgc, xi1, yi2, xi2, yi2);
  XDrawLine(xdisplay, xwindow, xgc, xi2, yi2, xi2, yi1);
  XDrawLine(xdisplay, xwindow, xgc, xi2, yi1, xi1, yi1);
#else
  hidecursor (w_no);
  move (w_no, xi1, yi1);
  draw (w_no, xi1, yi2);
  draw (w_no, xi2, yi2);
  draw (w_no, xi2, yi1);
  draw (w_no, xi1, yi1);
  showcursor (w_no);
#endif
#ifdef X11
  XSync(xdisplay, 0);
#else
  flushbuffer (w_no);
#endif
}


/*
  Dumps out the buffer of bytes to be sent to the graphics device.
*/

void EMdisplay_wno()
{
#ifdef X11
   XSync(xdisplay, 0);
#else
   flushbuffer (w_no);
#endif
}


/*
  Function to clear the screen
*/

void EMclear_scrn()
{
#ifndef X11		/* To prevent flickering of screen in X */
    Erase_win (w_no);
    flushbuffer (w_no);
#endif
}



/*
  DESCRIPTION

    This function takes in one-dimansional data of any simple type
    (char, short, int, float or double) and given the maximum number
    of divisions allowable, decides a scale for the data. It returns
    the starting value of the scale, the increment value per division,
    the number of divisions and the scale factor that may be used
    to display the numbers.

  BUGS

    If the data spans from less than 1 to greater than or equal to 1000,
    a good scale-factor cannot be found.

  HISTORY

    SS  :  08/25/88  :  Creation
*/

int EMscaler (num, invals, valtype, maxnumdiv, 
              scale_start, scale_incr, scale_factor, scale_numdiv)
int num;
char *invals;
short valtype;
int maxnumdiv;
double *scale_start, *scale_incr;
double *scale_factor;
int *scale_numdiv;
{
  short stat_func, found;
  char *char_vals;
  short *short_vals;
  int i, *int_vals, tempint;
  double valmem[MAXVALS], *vals, tempval;
  double minval, maxval, incr, testincr;

  stat_func = TRUE;
  vals = NULL;
  
  /*
   * Obtain the values into a double-array
   */

  if (valtype == DOUBLE)
    vals = ( double * ) invals;
  else 
    {
    if (num > MAXVALS)
      vals = (double *) malloc (num * sizeof (double));
    else
      vals = valmem;

    if (!vals)
      {
      stat_func = FALSE;
      goto ret_end;
      }

    if (valtype == CHAR)
      {
      char_vals = invals;
      for (i=0; i<num; i++)
        vals[i] = char_vals[i];
      }
    else if (valtype == SHORT)
      {
      short_vals = ( short * ) invals;
      for (i=0; i<num; i++)
        vals[i] = short_vals[i];
      }
    else if (valtype == INT)
      {
      int_vals = ( int * ) invals;
      for (i=0; i<num; i++)
        vals[i] = int_vals[i];
      }
    else
      {
      stat_func = FALSE;
      goto ret_end;
      }
    }

  /*
   * Obtain the minimum and maximum.
   */

  minval = MAXDOUBLE;
  maxval = -MAXDOUBLE;
  for (i=0; i<num; i++)
    {
    if (vals[i] < minval)
      minval = vals[i];
    if (vals[i] > maxval)
      maxval = vals[i];
    }

  /*
   * Determine any factors of ten that need to be applied to the
   * data in order to get significant digits down to a maximum of
   * three places. If the data spans from less than 1 to greater
   * than or equal to 1000, a good scale-factor cannot be found.
   */

  *scale_factor = 1.0;
  if (maxval >= 1000.0)
    while ((maxval / *scale_factor) >= 1000.0)
      *scale_factor *= 10.0;
  else if (maxval <= 1.0 && maxval > MINDOUBLE)
    while ((maxval / *scale_factor) <= 1.0)
      *scale_factor /= 10.0;
  else if (minval < 1.0 && minval > 0.001)
    while ((minval / *scale_factor) < 1.0)
      *scale_factor /= 10.0;
  

  /*
   * Obtain the raw increment value for the scale based on the
   * maximum number of divisions possible. The minimum, maximum and
   * the increment values are the scaled values.
   */

  maxval /= *scale_factor;
  minval /= *scale_factor;
  incr = (maxval - minval) / maxnumdiv;

  /*
   * Find the number out of the set:
   * {1, 2, 5, 10, any multiple of 10 upto 100, any multiple of 100 upto 1000}
   * to which the incr is closest from the upper side.
   */

  found = FALSE;
  for (testincr=1000; testincr>100; testincr-=100)
    if (testincr-100 < incr)
      {
      found = TRUE;
      break;
      }

  if (!found)
    {
    for (testincr=100; testincr>10; testincr-=10)
      if (testincr-10 < incr)
        {
        found = TRUE;
        break;
        }
    
    if (!found)
      {
      if (10 - 5 < incr)
        testincr = 10;
      else if (5 - 2 < incr)
        testincr = 5;
      else if (2 - 1 < incr)
        testincr = 2;
      else 
        testincr = 1;
      }
    }
  *scale_incr = testincr;

  /*
   * Having determined the start of the scale, determine it's
   * starting value.
   */

  tempint = minval / *scale_incr;
  if (minval < 0.0)
    tempint -= (abs ((int) minval) % (int) *scale_incr) ? 1 : 0;
  minval = tempint * *scale_incr;
  *scale_start = minval;

  /*
   * Determine the number of divisions on the scale
   */

  tempval = *scale_start;
  *scale_numdiv = 0;
  while (tempval <= maxval)
    {
    (*scale_numdiv)++;
    tempval += *scale_incr;
    }

ret_end:
  if (vals && vals != ( double * ) invals && vals != valmem)
    free (vals);
  return (stat_func);

}


/*
  DESCRIPTION

    Given various input, this function will plot the axes, ie, the raw
    graph in preparation of plotting for the real graph.

  HISTORY

    DHM  :  Long ago  :  Creation
*/

int EMdisp_graph (xvmin, xvmax, yvmin, yvmax, xvincr, yvincr,
                  xwmin, ywmin, xwincr, ywincr,
                  xstring, ystring,
                  bxmin, bymin, bxmax, bymax)
double xvmin, xvmax, yvmin, yvmax, xvincr, yvincr;
double xwmin, ywmin, xwincr, ywincr;
char xstring[], ystring[];
double bxmin, bymin, bxmax, bymax;
{
  char *ingrhome, *getenv(), fontfile[50];

  int x1 = bxmin, y1 = (ybottom - ytop) - (int) bymin;
  int x2 = bxmax, y2 = (ybottom - ytop) - (int) bymax;
#ifndef X11
  int font_descr, screen_no, plane_mask;
#endif
  int i, x, y;
  int xw;
  float  yw;
  int yv1, yv2;
  char buff[20];

#ifndef X11
  hidecursor (w_no);
#endif

  /*
   * Draw the x and y coordinate lines.
   */

#ifdef X11
  XSetForeground(xdisplay, xgc, vlt[FOREGR].pixel);
  XDrawLine(xdisplay, xwindow, xgc, x1, y2, x1, y1);
  XDrawLine(xdisplay, xwindow, xgc, x1, y1, x2, y1);
#else
  move (w_no, x1, y2);
  draw (w_no, x1, y1);
  draw (w_no, x2, y1);
#endif

  /*
   * Draw the x and y string label for the
   * coordinate system.
   */


#ifdef X11
  XSetPlaneMask(xdisplay, xgc, AllPlanes);
#else
  fgcolor (w_no, 0xffffffff);
  if ((ingrhome = getenv ("INGRHOME")) == NULL)
    font_descr = NULL;
  else
  {
    strcpy (fontfile, ingrhome);
    strcat (fontfile, "/resrc/rfont/drake.10");
    Load_symbol_file (fontfile, &font_descr);
  }
  inquire_vs (vs_no, &screen_no, &plane_mask);
  enableplane (w_no, plane_mask);
#endif

  x = (x2 - x1) / 2;
  y = y1 + 25;
#ifdef X11
  XDrawString(xdisplay, xwindow, xgc, x, y, xstring, strlen(xstring));
#else
  drawsymbols (w_no, font_descr, x, y, xstring, strlen(xstring));
#endif

  x = x1;
  y = y2 - 25;
#ifdef X11
  XDrawString(xdisplay, xwindow, xgc, x, y, ystring, strlen(ystring));
#else
  drawsymbols (w_no, font_descr, x, y, ystring, strlen(ystring));
#endif

  EMdisplay_wno();

  /*
   * Draw the scale numbers for the x and y
   * coordinate system.
   */

  xw = xwmin;
  for (i = xvmin; i <= xvmax; i+=xvincr)
    {
    sprintf(buff, "%d", xw);
    x = i;
    y = y1 + 10;
#ifdef X11
    XDrawString(xdisplay, xwindow, xgc, x, y, buff, strlen(buff));
#else
    drawsymbols (w_no, font_descr, x, y, buff, strlen(buff));
#endif
    xw += xwincr;
    }

  yv1 = (ybottom - ytop) - (int) yvmin;
  yv2 = (ybottom - ytop) - (int) yvmax;
  yw = ywmin;
  for (i = yv1; i >= yv2; i-=yvincr)
    {
    sprintf(buff, "%.1f", yw);
    x = x1 - 30;
    y = i;
#ifdef X11
    XDrawString(xdisplay, xwindow, xgc, x, y, buff, strlen(buff));
#else
    drawsymbols (w_no, font_descr, x, y, buff, strlen(buff));
#endif
    yw += ywincr;
    }

#ifndef X11
  showcursor (w_no);
#endif
  EMdisplay_wno();

  return (TRUE);
}

#ifdef X11
load_font(xdisplay, font_info)
  Display *xdisplay;
  XFontStruct **font_info;
{
  char *font_name="8x13bold";

  /* Load font and get font information structure */
  if ((*font_info = XLoadQueryFont(xdisplay, font_name)) == NULL)
  {
    (void) fprintf(stderr, "graph: Cannot open 8x13bold font\n");
    exit(-1);
  }
}

store_colors( cmap )

	Colormap cmap;
{
    int i, j, stat;
    double min_dist, this_dist, red_dist, green_dist, blue_dist;
    XColor color_defs[14];

    /* get the RGB values of the fixed colors (slots 1 - 14) */
    for ( i = 0; i < 14; i++ )
	color_defs[i].pixel = i + 1;
    stat = XQueryColors( xdisplay, cmap, color_defs, 14 );

    if ( stat )
	{
	/* get closest match of colors in the first 14 colors */
	/* for the colors we want                             */
	for ( i = 0; i < MAX_COLORS; i++ )
		{
		min_dist = 65535.0 * 65535.0 * 65535.0;
		for ( j = 0; j < 14; j++ )
			{
			red_dist = (double)vlt[i].red - (double)color_defs[j].red;
			green_dist = (double)vlt[i].green - (double)color_defs[j].green;
			blue_dist = (double)vlt[i].blue - (double)color_defs[j].blue;
			this_dist = red_dist*red_dist + green_dist*green_dist + blue_dist*blue_dist;
		        if ( this_dist < min_dist )
				{
				vlt[i].pixel = color_defs[j].pixel;
				min_dist = this_dist;
				}
			}
		}
	}
    else
	{
	/* couldn't query colors so allocate them */
	for (i=0; i < MAX_COLORS; i++)
		{
		XAllocColor( xdisplay, cmap, &vlt[i] );
		}
	}
}
#endif
