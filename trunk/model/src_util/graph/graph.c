/*
  DESCRIPTION

    This executable is used to plot polylines on a graph in a an EnvironV
    window. Two arguments may be specified on the command line. The first
    is the name of option prefixed by a "-" and the second is the name
    of the file that contains the polyline info (besides other control
    info). The option names are defined in emsdef.h.

  NOTES

    The format of the file should be as follows. Only those entities that
    are found double-tabbed are entries in the file; the rest of the text
    is only explanation.

    Repeats as many times as number of polylines
    NumPtsInPoly is an "int" and Xpt and Ypt are doubles
    The value if Delimiter is an int less than 0.
    {
    		NumPtsInPoly
		Xpt1 Ypt1
		Xpt2 Ypt2
		.... ....
    }
		Delimiter

    Window text information and it's extents are given. The names can contain
    more than one word separated by spaces.
    		Window Name
    		X-axis Label
    		Y-axis Label
    		WinExt[XMIN] WinExt[YMIN] WinExt[XMAX] WinExt[YMAX]

  HISTORY

    DHM  :  Long ago  :  Creation
    SS   :  08/28/89  :  Modified the format to be more flexible
    SCW  :  08/13/94  :  Added X11 for Intel Solaris port
*/

    
#include <stdio.h>
#include <math.h>
#include <tools.h>
#include <ctype.h>
#include "graphics.h"

#ifdef X11
#include "X11/Xlib.h"
#include "X11/Xutil.h"
#endif

#ifdef CLIX
#include <sdl.h>
#endif

#define X 0
#define Y 1

#define XMIN 0
#define YMIN 1
#define XMAX 2
#define YMAX 3

#define X1 0
#define Y1 1
#define X2 2
#define Y2 3

#define MAXLEN_NAME	40
#define AXIS_OFFSET	40
#define NUMPTS_SIZE	10
#define NUMPTS_INCR	5
#define PTS_SIZE	100
#define PTS_INCR	50

typedef double pt2d[2];

static int plotgraph();

main (argc, argv)
int argc;
char *argv[];
{
  char window_name[MAXLEN_NAME], xstring[MAXLEN_NAME], ystring[MAXLEN_NAME]; 
  char *cptr;
  short done, uvmode, tempdisp;
  int i, lim, *iptr, extent[4], w_no, stat_func, tempnum;
  int numpts_size, pts_size, blksize;
  int numpoly, totnumpts, loc_numpts, numptsmem[NUMPTS_SIZE], *numpts;
  double *dptr, ptsmem[PTS_SIZE*2], *pts, x, y;
  double bxmin, bymin, bxmax, bymax, range[4];
  pt2d *ptsptr;
  FILE *infile;
#ifdef X11
  XEvent xevent;
  XExposeEvent *expose_event;
  XClientMessageEvent *client_message_event;
  Atom   del_win_atom;
  extern Display *xdisplay;
  extern Window xwindow;
#else
  int cur_event_mask;
#endif


  extern void EMclear_scrn(), EMexit_graph();
  extern int EMinit_graph();
  extern char *strrchr();

  pts = NULL;
  numpts = NULL;

  if (argc != 3)
    {
    fprintf (stderr, "Usage: graph -optname filename\n");
    goto ret_end;
    }

  /*
   * Initialize local parameters
   */

  uvmode = FALSE;
  tempdisp = FALSE;
  if (strcmp (argv[1], "-uv") == MATCH)
    {
    uvmode = TRUE;
    }
  else if (strcmp (argv[1], "-lawcvt") == MATCH)
    {
    tempdisp = TRUE;
    }

  /*
   * Open the file for reading.
   */

  infile = fopen (argv[2], "r");
  if (!infile)
    {
    fprintf (stderr, "Cannot open file - %s\n", argv[2]);
    goto ret_end;
    }

  /*
   * Read in the polylines. Keep track of the range of the total set of
   * polylines.
   */
  
  range[XMIN] = MAXDOUBLE;
  range[YMIN] = MAXDOUBLE;
  range[XMAX] = -MAXDOUBLE;
  range[YMAX] = -MAXDOUBLE;
  numpoly = 0;
  totnumpts = 0;

  numpts = numptsmem;
  numpts_size = NUMPTS_SIZE;
  pts = ptsmem;
  pts_size = PTS_SIZE;

  done = FALSE;
  while (!done)
    {
    if (fscanf (infile, "%d", &loc_numpts) == EOF || loc_numpts < 0)
      {
      fgetc (infile);
      break;
      }

    if (numpoly+1 > numpts_size)
      {
      numpts_size += NUMPTS_INCR;
      blksize = numpts_size * sizeof (int);

      if (numpts == numptsmem)
        {
        iptr = (int *) malloc (blksize);
        if (iptr)
          for (i=0; i<numpoly; i++)
            iptr[i] = numpts[i];
        numpts = iptr;
        }
      else
        numpts = (int *) realloc (numpts, blksize);
      if (!numpts)
        {
        fprintf (stderr, "No dynamic memory - %d\n", blksize);
        goto ret_end;
        }
      }

    if (totnumpts+loc_numpts > pts_size)
      {
      tempnum = totnumpts+loc_numpts - PTS_SIZE;
      pts_size = PTS_SIZE + 
                 (tempnum / PTS_INCR + (tempnum % PTS_INCR ? 1 : 0)) *
                 PTS_INCR;
      blksize = pts_size * 2 * sizeof (double);

      if (pts == ptsmem)
        {
        dptr = (double *) malloc (blksize);
        lim = totnumpts + totnumpts;
        if (dptr)
          for (i=0; i<lim; i++)
            dptr[i] = pts[i];
        pts = dptr;
        }
      else
        pts = (double *) realloc (pts, blksize);
      if (!pts)
        {
        fprintf (stderr, "No dynamic memory - %d\n", blksize);
        goto ret_end;
        }
      }

    numpts[numpoly] = loc_numpts;
    ptsptr = (pt2d *) &pts[totnumpts * 2];
    numpoly++;
    totnumpts += loc_numpts;
    for (i=0; i<loc_numpts; i++)
      if (fscanf (infile, "%lf %lf", &x, &y) == EOF)
        {
        fprintf (stderr, "File %s in error\n", argv[2]);
        goto ret_end;
        }
      else
        {
        if (x < range[XMIN])
          range[XMIN] = x;
        if (x > range[XMAX])
          range[XMAX] = x;
        if (y < range[YMIN])
          range[YMIN] = y;
        if (y > range[YMAX])
          range[YMAX] = y;
        ptsptr[i][X] = x;
        ptsptr[i][Y] = y;
        }
    }
  
  /*
   * If the option indicates that the uv-space of a surface is being
   * graphed, then make the range the unit square.
   */

  if (uvmode)
    {
    range[XMIN] = range[YMIN] = 0.0;
    range[XMAX] = range[YMAX] = 1.0;
    }

  /*
   * Scan for the window name and the coordinate strings. If none found
   * used default names.
   */

  if (!fgets (window_name, MAXLEN_NAME, infile))
    {
    if (uvmode)
      strcpy (window_name, "UV-plot");
    else
      strcpy (window_name, "Graph");
    }
  else
    {
    /* remove '\n' from string that fgets() puts there */
    if ( cptr = strrchr( window_name, '\n' ) )
       cptr[0] = '\0';
    }

  if (!fgets (xstring, MAXLEN_NAME, infile))
    {
    if (uvmode)
      strcpy (xstring, "U-axis");
    else
      strcpy (xstring, "X-axis");
    }
  else
    {
    /* remove '\n' from string that fgets() puts there */
    if ( cptr = strrchr( xstring, '\n' ) )
       cptr[0] = '\0';
    }

  if (!fgets (ystring, MAXLEN_NAME, infile))
    {
    if (uvmode)
      strcpy (ystring, "V-axis");
    else
      strcpy (ystring, "Y-axis");
    }
  else
    {
    /* remove '\n' from string that fgets() puts there */
    if ( cptr = strrchr( ystring, '\n' ) )
       cptr[0] = '\0';
    }

  /*
   * Scan for the the extents of my window. If any of the extent values
   * are negative or are absent, take the respective defaults.
   */

  if (fscanf (infile, "%d %d %d %d", &extent[XMIN], &extent[YMIN],
      &extent[XMAX], &extent[YMAX]) == EOF)
    {
    extent[XMIN] = XLEFT;
    extent[YMIN] = YTOP;
    extent[XMAX] = XRIGHT;
    extent[YMAX] = YBOTTOM;
    }
  else
    {
    if (extent[XMIN] < 0)
      extent[XMIN] = XLEFT;
    if (extent[YMIN] < 0)
      extent[YMIN] = YTOP;
    if (extent[XMAX] < 0)
      extent[XMAX] = XRIGHT;
    if (extent[YMAX] < 0)
      extent[YMAX] = YBOTTOM;
    }
  fclose (infile);

  /*
   * Set the extents of the plotting zone (the view). This is the region
   * contained within the axes. These are set in window coordinates.
   */

  bxmin = AXIS_OFFSET;
  bymin = AXIS_OFFSET;
  bxmax = (extent[XMAX]-extent[XMIN]) - AXIS_OFFSET;
  bymax = (extent[YMAX]-extent[YMIN]) - AXIS_OFFSET;
  if (bxmax <= AXIS_OFFSET || bymax <= AXIS_OFFSET)
    {
    fprintf (stderr, "Bad extents specified in file %s\n", argv[2]);
    goto ret_end;
    }


  /*
   * All the data has been collected. Set up the window and call the function
   * to plot the graph.
   */

#ifdef X11
  stat_func = EMinit_graph (window_name, extent, &w_no,
               uvmode ? COLOR_MODE : NULL, argc, argv);
#else
  stat_func = EMinit_graph (window_name, extent, &w_no,
               uvmode ? COLOR_MODE : NULL);
  if (!stat_func)
    {
    fprintf (stderr, "Failure to construct window\n");
    goto ret_end;
    }
#endif

  stat_func = plotgraph (extent, bxmin, bymin, bxmax, bymax, w_no, range, 
               numpoly, numpts, pts, xstring, ystring, argv[1]);
  if (!stat_func)
    {
    fprintf (stderr, "Failure to draw graph\n");
    goto ret_end;
    }
  if (tempdisp)
    {
    sleep (2);
    goto ret_end;
    }

  /*
   * Process any icon data buttons that are hit on the 
   * window.
   */

#ifdef X11
  del_win_atom = XInternAtom( xdisplay, "WM_DELETE_WINDOW", False );
  XSetWMProtocols( xdisplay, xwindow, &del_win_atom, 1 );
#endif
  while (TRUE)
    {
#ifdef X11
    XNextEvent(xdisplay, &xevent);
    switch (xevent.type)
    {
    case Expose: 
	expose_event = (XExposeEvent *)&xevent;
	if ( expose_event->count == 0 )
		{
		EMclear_scrn ();
	    	stat_func = plotgraph (extent, bxmin, bymin, bxmax, bymax, w_no,
			range, numpoly, numpts, pts, xstring, ystring, argv[1]);
		}
        break;
    case DestroyNotify:
	fprintf(stderr, "DestroyNotify event\n");
    	goto ret_end;
    case ClientMessage:
	client_message_event = (XClientMessageEvent *)&xevent;
	if (client_message_event->data.l[0] == del_win_atom)
		{
		goto ret_end;
		}
	break;
    default: break;
    }
  
#else
    Wait_for_events (DELETE_EVENT | REFRESH_EVENT, &cur_event_mask);
    switch (cur_event_mask)
      {
      case REFRESH_EVENT:
        EMclear_scrn ();
        stat_func = plotgraph (extent, bxmin, bymin, bxmax, bymax, w_no,
                     range, numpoly, numpts, pts, xstring, ystring, argv[1]);
        Clear_refresh_data ();
        break;

      case DELETE_EVENT:
        Clear_delete_data ();
        goto ret_end;
      }
#endif
    }


ret_end:
  if (numpts && numpts != numptsmem)
    free(numpts);
  if (pts && pts != ptsmem)
    free(pts);
  EMexit_graph();
}


static int plotgraph (extent, bxmin, bymin, bxmax, bymax, w_no,
                      range, numpoly, numpts, pts, xstring, ystring, optstr)
int extent[];
double bxmin, bymin, bxmax, bymax;
int w_no;
double range[];
int numpoly;
int *numpts;
double *pts;
char *xstring, *ystring, *optstr;
{
  char x_str[MAXLEN_NAME], y_str[MAXLEN_NAME], factstr[MAXLEN_NAME];
  short stat_func, uvmode, ptdisp;
  int i, j, k, ptinx;
  int x_numdiv, y_numdiv;
  double x_vincr, y_vincr, x_wincr, y_wincr;
  double x_viewfact, y_viewfact;
  double x_viewlen, y_viewlen, x_worldlen, y_worldlen;
  double x_vscalmin, x_vscalmax, y_vscalmin, y_vscalmax;
  double x_wscalmin, x_wscalmax, y_wscalmin, y_wscalmax;
  double xval[2], yval[2], x_factor, y_factor;
  double lptsmem[PTS_SIZE*2], *lpts, lrng[4];
  extern void EMdraw_linestring();
  extern int EMscaler(), EMdisp_graph();

  lpts = NULL;

  uvmode = FALSE;
  ptdisp = TRUE;
  if (strcmp (optstr, "-uv") == MATCH)
    {
    ptdisp = FALSE;
    uvmode = TRUE;
    }
  else if (strncmp (optstr, "-lawcv", 6) == MATCH)
    {
    ptdisp = FALSE;
    }

  /*
   * Get the scale in the x direction and y direction. If the range in
   * any direction is degenerate, take appropriate action.
   */

  if (fabs (range[XMIN] - range[XMAX]) > MINDOUBLE)
    {    
    xval[0] = range[XMIN];
    xval[1] = range[XMAX];
    stat_func = EMscaler (2, xval, DOUBLE, 10,
                 &x_wscalmin, &x_wincr, &x_factor, &x_numdiv);
    if (!stat_func)
      goto ret_end;
    x_wscalmax = x_wscalmin + (x_wincr * x_numdiv);
    }
  else
    {
    x_wscalmin = range[XMIN] - 1;
    x_wscalmax = range[XMAX] + 1;
    x_wincr = 1.0;
    x_factor = 1.0;
    x_numdiv = 2;
    }

  if (fabs (range[YMIN] - range[YMAX]) > MINDOUBLE)
    {
    yval[0] = range[YMIN];
    yval[1] = range[YMAX];
    stat_func = EMscaler (2, yval, DOUBLE, 10,
                 &y_wscalmin, &y_wincr, &y_factor, &y_numdiv);
    if (!stat_func)
      goto ret_end;
    y_wscalmax = y_wscalmin + (y_wincr * y_numdiv);
    }
  else
    {
    y_wscalmin = range[YMIN] - 1;
    y_wscalmax = range[YMAX] + 1;
    y_wincr = 1.0;
    y_factor = 1.0;
    y_numdiv = 2;
    }

  /*
   * Compute the view factor conversion between world and view and obtain the
   * scale's minimum and maximum values in view-coordinates. Also obtain
   * the increment in view-coordinates.
   */

  x_worldlen = x_wscalmax - x_wscalmin;
  y_worldlen = y_wscalmax - y_wscalmin;

  x_viewlen = (extent[XMAX] - bxmin) - (extent[XMIN] + bxmin);
  y_viewlen = (extent[YMAX] - bymin) - (extent[YMIN] + bymin);

  x_viewfact = x_viewlen / x_worldlen;
  y_viewfact = y_viewlen / y_worldlen;

  x_vscalmin = bxmin;
  x_vscalmax = (x_wscalmax - x_wscalmin) * x_viewfact + bxmin;
  y_vscalmin = bymin;
  y_vscalmax = (y_wscalmax - y_wscalmin) * y_viewfact + bymin;

  x_vincr = x_wincr * x_viewfact;
  y_vincr = y_wincr * y_viewfact;

  /*
   * Obtain the string for the X and the Y axes with the scale factors
   * (if any) figured in.
   */

  strcpy(x_str, xstring);
  if (x_factor != 1.0)
    {
    sprintf(factstr, " (X %lg)", x_factor);
    strcat(x_str, factstr);
    }

  strcpy(y_str, ystring);
  if (y_factor != 1.0)
    {
    sprintf(factstr, "  (X %lg)", y_factor);
    strcat(y_str, factstr);
    }

  /*
   * Call the function to display the graph
   */

  stat_func = EMdisp_graph (x_vscalmin, x_vscalmax, y_vscalmin, y_vscalmax,
               x_vincr, y_vincr, x_wscalmin, y_wscalmin, x_wincr, y_wincr,
               x_str, y_str, bxmin, bymin, bxmax, bymax);
  if (!stat_func)
    goto ret_end;
  if (x_wscalmin < 0.0)
    {
    lrng[X1] = lrng[X2] = bxmin - x_wscalmin * x_viewfact;
    lrng[Y1] = bymin;
    lrng[Y2] = bymax;
#ifdef X11
    EMset_linestyle (LineOnOffDash);
#else
    EMset_linestyle (DASHED_STYLE);
#endif
    EMdraw_linestring (lrng, 2, FALSE);
    EMdisplay_wno();
#ifdef X11
    EMset_linestyle (LineSolid);
#else
    EMset_linestyle (SOLID_STYLE);
#endif
    }
  if (y_wscalmin < 0.0)
    {
    lrng[X1] = bxmin;
    lrng[X2] = bxmax;
    lrng[Y1] = lrng[Y2] = bymin - y_wscalmin * y_viewfact;

#ifdef X11
    EMset_linestyle (LineOnOffDash);
#else
    EMset_linestyle (DASHED_STYLE);
#endif
    EMdraw_linestring (lrng, 2, FALSE);
    EMdisplay_wno();
#ifdef X11
    EMset_linestyle (LineSolid);
#else
    EMset_linestyle (SOLID_STYLE);
#endif
    }

  /*
   * Perform any special processing for various
   * options.
   */

  if (uvmode)
    {
    for (i=0; i<=2; i+=2)
      lrng[i] = bxmin + (range[i] / x_factor - x_wscalmin) * x_viewfact;
    for (i=1; i<=3; i+=2)
      lrng[i] = bymin + (range[i] / y_factor - y_wscalmin) * y_viewfact;

    EMset_color (BACKGR);
    EMdisp_box (lrng[XMIN], lrng[YMIN], lrng[XMAX], lrng[YMAX]);

#ifdef X11
    EMset_linestyle (LineOnOffDash);
#else
    EMset_linestyle (DASHED_STYLE);
#endif
    EMset_color (FOREGR);
    EMdisp_box (lrng[XMIN], lrng[YMIN], lrng[XMAX], lrng[YMAX]);

#ifdef X11
    EMset_linestyle (LineSolid);
#else
    EMset_linestyle (SOLID_STYLE);
#endif
    EMset_color (BLUE);
    }

  /*
   * Draw the polylines in the window.
   */

  ptinx = 0;
  for (i=0; i<numpoly; i++)
    {
    if (numpts[i] > PTS_SIZE)
      {
      if (!(lpts = (double *) malloc (numpts[i] * 2 * sizeof (double))))
        {
        stat_func = FALSE;
        goto ret_end;
        }
      }
    else
      lpts = lptsmem;

    for (j=0, k=0; j<numpts[i]; j++, k+=2)
      {
      lpts[k] = bxmin + (pts[ptinx++] / x_factor - x_wscalmin) * x_viewfact;
      lpts[k+1] = bymin + (pts[ptinx++] / y_factor - y_wscalmin) * y_viewfact;
      }
    EMdraw_linestring (lpts, numpts[i], ptdisp ? TRUE : FALSE);
    EMdisplay_wno();

    if (lpts != lptsmem)
      free (lpts);
    lpts = NULL;
    }

  /*
   * Post process for any special options that might
   * have been specified.
   */

  if (uvmode)
    EMset_color (FOREGR);

ret_end:
  if (lpts && lpts != lptsmem)
    free (lpts);
  return (stat_func);
}
