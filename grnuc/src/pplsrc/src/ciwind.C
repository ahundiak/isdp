/*
 * to write results in a window
 */
#include <stdio.h>
#include <exdef.h>
#include <exmacros.h>

#include <wl.h>
#include <cm.h>

#define ITALICS   "/usr/ip32/resrc/rfont/nonie.i.12"
#define TEXT_FONT "/usr/ip32/resrc/rfont/nonie.r.12"

/* size of the window */
#define XMIN 50
#define YMIN 100
#define XMAX 950
#define YMAX 800

#define HLINE 30

static WLuint32 CIwin_no;       /* window # */
static int CIfont_descr;        /* font descriptor */

int CIcreate_wind( title )
char *title;
{
  int border_width;
  int screen_type;
  WLuint16 screen;
  struct WLbounds bounds;
  WLuint32 context_no;
 
/* Get active logical screen */
  WLget_active_screen( &screen, &screen_type );

/* Get active screen context */
  CMget_active_context( screen, &context_no );

/* Create the window */
  bounds.x = XMIN;
  bounds.y = YMIN;
  bounds.width = XMAX - XMIN;
  bounds.height = YMAX - YMIN;
  border_width = 5;
  WLcreate_window( screen, title, &bounds, border_width,
                   context_no, &CIwin_no );

#ifdef ENV5
  {
/* Get EnvironV hardware window number */
    struct WLnative_info native_info;

    WLget_native_info( CIwin_no, context_no, &native_info );

/* disable all icons  */
    Set_win_modify_icon  ( native_info.base_win, 0 );
    Set_win_bottom_icon  ( native_info.base_win, 0 );
    Set_win_top_icon     ( native_info.base_win, 0 );
    Set_win_delete_icon  ( native_info.base_win, 0 );
    Set_win_collapse_icon( native_info.base_win, 0 );
    Set_win_repaint_icon ( native_info.base_win, 0 );
  }
#endif

/* get the text fonts */
  /* Load_symbol_file(ITALICS, &CIfont_descr); */

/* Display window */
  WLdisplay_window( CIwin_no );

/* Set foreground color to green */
  {
    WLcolorref green;
    int change_mask = WL_SYMB_CHANGE_COLOR;

    WLpack_index_colorref( 4, &green, 0 );
    WLset_active_symbology( CIwin_no, green, 0, 0, 0, change_mask );
  }

  return 1;
}

int CIwrite_wind( nl, txt )
int nl;      /* no of the line */
char *txt;   /* text to be displayed */
{
  int xl = HLINE * nl;
  static int last_w, cur_w;

  if ( nl == 0 )
    last_w = 0;
  cur_w = xl / ( YMAX - YMIN - HLINE );

  if ( cur_w != last_w ) {
    char s[600];
    int size = 600, rep;

    last_w = cur_w;
    UI_prompt( "enter [CR] to continue/ RESET to exit" );
    do {
      ex$wait_for_input( response = &rep, buffer = s, byte = &size );
      if ( rep == RESET ) {
        WLdelete_window( CIwin_no );
        return 0;
      }
    } while ( rep != STRING );

    WLclear_window( CIwin_no );  
  }  

  xl = xl % ( YMAX - YMIN - HLINE );
  WLdraw_text( CIwin_no, 30, xl+10, txt, strlen( txt ) );
  WLflush( CIwin_no );

  return 1;
}

int CIescape_win()
{
  int size = 600, rep;
  char s[600];

 /* waits for an event to come back to menu */
  UI_prompt( "type RESET to come back to menu" );
  do {
    ex$wait_for_input ( response = &rep, buffer = s, byte = &size);
  } while ( rep != RESET );

  WLdelete_window( CIwin_no );

  return 1;
}
