/* $Revision: 1.1 $ */
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#ifndef x_var
  Display *dba_display, *display;
  int dba_screen_num, screen;

  GC dba_gc, dba_drag_gc;
  Colormap dba_colormap;

  Visual *dba_default_visual, *visual;
  XVisualInfo *dba_vinfo;
#else
  extern Display *dba_display, *display;
  extern int dba_screen_num, screen;

  extern GC dba_gc, dba_drag_gc;
  extern Colormap dba_colormap;

  extern Visual *dba_default_visual, *visual;
  extern XVisualInfo *dba_vinfo;
#endif
