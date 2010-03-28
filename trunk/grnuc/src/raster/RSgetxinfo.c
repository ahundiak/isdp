#ifdef X11

#include <X11/Xlib.h>
#include <X11/Xutil.h>

#define EXNUC 1

#ifdef EXNUC
extern Display *EXdisplay;
extern Window  EX_win[];
extern int     EX_scr[];
extern GC      EXgc[];
extern int     EXscreen;
extern Colormap EXcolormap[];
#else
#ifdef SCANNER
extern Display *display;
extern int    screen;
extern GC     gc;
extern Colormap colormap;
#endif
#endif


int     RSgetxinfo(xdisplay,win_no,xwin_no,scr_no,xgc,col_map)

Display **xdisplay;
int     win_no;
Window  *xwin_no;
int     *scr_no;
GC      *xgc;
Colormap *col_map;

{
  short ok = 0;
  unsigned long val;

#ifdef EXNUC

  if (xdisplay)
  {
    *xdisplay = EXdisplay;
  }

  if (xwin_no)
  {
    *xwin_no = EX_win[win_no];
  }

  if (xgc)
  {
    *xgc = EXgc[EX_scr[win_no]];
  }

  if (scr_no)
  {
    *scr_no = EX_scr[win_no];
  }

  if (col_map)
  {
    *col_map = EXcolormap[0];
  }
  
#else
#ifdef SCANNER
  if (xdisplay)
  {
    *xdisplay = display;
  }

  if (xwin_no)
  {  
    *xwin_no = win_no;    
  }

  if (xgc)
  {
    *xgc = gc;
  }

  if (scr_no)
  {
    *scr_no = screen;
  }

  if (col_map)
  {
    *col_map = colormap;
  }
#endif
#endif

  return(1);
}
#endif

#ifdef EXNUC
void sync_on()
{
  XSynchronize(EXdisplay, 1);
}

void sync_off()
{
  XSynchronize(EXdisplay, 0);
}
#endif
