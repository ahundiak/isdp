#include "FImin.h"
#include "FIread.h"
#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/* DISPLAY */

/* This function draw the bezel and then the gadgets on the form */

void _FI_f_paint (struct FIform_obj *form)
{
  /* Display window and gadgets */

  Window window = form->Xwindow;
  int Xscreen = form->Xscreen;

  int xlo = form->xlo;
  int ylo = form->ylo;
  int xhi = form->xhi;
  int yhi = form->yhi;

  int width = form->xhi - form->xlo;
  int height = form->yhi - form->ylo;

  /* CHUNN rework these if's */

  if (	( form->attr_mask & FI_NO_BEZEL )	||
	( form->attr_mask & FI_LINE_BORDER )	 )
    {
      XSetForeground ( _FI_display, _FI_gc,
		 FI_translate_color ( form->Xscreen, form->bgcolor ));

      XFillRectangle ( _FI_display, form->Xwindow, _FI_gc, 0, 0,
						 width, height );
    }

  if (	( ! ( form->attr_mask & FI_NO_BEZEL ))	||
	( form->attr_mask & FI_LINE_BORDER )	 )
    {
	     /* draw line around the form */

      XGCValues gc_values;

      gc_values.foreground = FI_translate_color ( Xscreen, FI_WHITE );
      gc_values.line_width = 3;

      XChangeGC ( _FI_display, _FI_gc,
	 (unsigned long) ( GCForeground | GCLineWidth ), &gc_values );

      _FI_rect_draw_box ( window, 0, 0, width, height );
    }

  if (	( ! ( form->attr_mask & FI_NO_BEZEL ))	 	&&
	( ! ( form->attr_mask & FI_LINE_BORDER ))	 )
    {
      _FI_draw_bezel ( window, 1, 1, xhi - xlo, yhi - ylo,
		FORM_BEZEL_WIDTH,
		FI_translate_color ( form->Xscreen, FI_GLINT ),
		FI_translate_color ( form->Xscreen, form->bgcolor ),
		FI_translate_color ( form->Xscreen, FI_SHADOW ),
		FI_translate_color ( form->Xscreen, FI_EDGE ), SQUARE );
    }

  _FI_g_display ( (struct FIgadget_obj *)form->group, window );

  /** X11-6/15/90-REDUNDANT because the above routine flushes
  XFlush ( _FI_display );
  ***********************************************************/

  if ( form->window_event_routine )
    {
      form->window_event_routine ( form->form_label, FI_DISPLAY, form );
    }
}


void _FI_f_modify_window (struct FIform_obj *form)
{
  XWindowChanges win_chgs;

  if ( form->Xwindow != None )
    {
	/*** Needed to stack a ConfigureNotify event on the queue  ***/
	/*** so the original event would not override this call.   ***/

      win_chgs.x = form->xlo;
      win_chgs.y = form->ylo;
      win_chgs.width = form->xhi - form->xlo;
      win_chgs.height = form->yhi - form->ylo;

     /** A dynamic form might have a zero width or height **/

      if ( ! win_chgs.width || ! win_chgs.height )
	{
	  return;
        }

      FI_configure_window ( _FI_display, form->Xwindow,
	 (unsigned int) ( CWX | CWY | CWWidth | CWHeight ), &win_chgs );
    }
}


void _FI_f_set_window_attr (Window window,
                            int    Xscreen)
{
  Pixmap cursor_map, cursorM_map;
  Cursor cursor;
  XColor foreground, background;

#define cursor_width 32
#define cursor_height 32
#define cursor_x_hot 1
#define cursor_y_hot 1

  /** Old way ******************************************************/

	/***********************************************/
	/* sml:10-01-93	Fix TR 249302117               */
	/*   Use this pattern now to handle            */
	/*   machines (such as personal Iris) that     */
	/*   have limited colors.                      */
	/***********************************************/

/* change to unsigned ** static char cursor_bits[] =*/
static unsigned char cursor_bits[] =
{
 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x00,
 0x7c, 0x00, 0x00, 0x00, 0xfc, 0x01, 0x00, 0x00, 0xf8, 0x07, 0x00, 0x00,
 0xf8, 0x1f, 0x00, 0x00, 0xf0, 0x7f, 0x00, 0x00, 0xf0, 0xff, 0x01, 0x00,
 0xe0, 0xff, 0x07, 0x00, 0xe0, 0xff, 0x1f, 0x00, 0xc0, 0xff, 0x7f, 0x00,
 0xc0, 0xff, 0xff, 0x01, 0x80, 0xff, 0xff, 0x07, 0x80, 0xff, 0xff, 0x1f,
 0x00, 0xff, 0xff, 0x7f, 0x00, 0xff, 0x00, 0x00, 0x00, 0xfe, 0x00, 0x00,
 0x00, 0xfe, 0x00, 0x00, 0x00, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0x00, 0x00,
 0x00, 0xf8, 0x00, 0x00, 0x00, 0xf8, 0x00, 0x00, 0x00, 0xf0, 0x00, 0x00,
 0x00, 0xf0, 0x00, 0x00, 0x00, 0xe0, 0x00, 0x00, 0x00, 0xe0, 0x00, 0x00,
 0x00, 0xc0, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};
/*  **************************************************************/

  /** KLUDGED WAY--The 0's and 1's are inverted **/
/*  static unsigned char cursor_bits[]= dmb:09/28/92:ANSI*/
/*  static char cursor_bits[]= dmb:10/15/92:Exp */

	/***********************************************/
	/* sml:10-01-93	Don't do this now              */
	/***********************************************/

/***********************************************************
  static unsigned char cursor_bits[]=
    {
	0xff, 0xff, 0xff, 0xff, 0xf9, 0xff, 0xff, 0xff,
	0xe1, 0xff, 0xff, 0xff, 0x83, 0xff, 0xff, 0xff,
	0x03, 0xfe, 0xff, 0xff, 0x07, 0xf8, 0xff, 0xff,
	0x07, 0xe0, 0xff, 0xff, 0x0f, 0x80, 0xff, 0xff,
	0x0f, 0x00, 0xfe, 0xff, 0x1f, 0x00, 0xf8, 0xff,
	0x1f, 0x00, 0xe0, 0xff, 0x3f, 0x00, 0x80, 0xff,
	0x3f, 0x00, 0x00, 0xfe, 0x7f, 0x00, 0x00, 0xf8,
	0x7f, 0x00, 0x00, 0xe0, 0xff, 0x00, 0x00, 0x80,
	0xff, 0x00, 0xff, 0xff, 0xff, 0x01, 0xff, 0xff,
	0xff, 0x01, 0xff, 0xff, 0xff, 0x03, 0xff, 0xff,
	0xff, 0x03, 0xff, 0xff, 0xff, 0x07, 0xff, 0xff,
	0xff, 0x07, 0xff, 0xff, 0xff, 0x0f, 0xff, 0xff,
	0xff, 0x0f, 0xff, 0xff, 0xff, 0x1f, 0xff, 0xff,
	0xff, 0x1f, 0xff, 0xff, 0xff, 0x3f, 0xff, 0xff,
	0xff, 0x3f, 0xff, 0xff, 0xff, 0x7f, 0xff, 0xff,
	0xff, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    };
********************************************************/
#define cursorM_width 32
#define cursorM_height 32
/*  static unsigned char cursorM_bits[]= dmb:09/28/92:ANSI */
/*  static char cursorM_bits[]= dmb:10/15/92:Exp */
  static unsigned char cursorM_bits[]=
    {
	0x07, 0x00, 0x00, 0x00, 0x1f, 0x00, 0x00, 0x00,
	0x7f, 0x00, 0x00, 0x00, 0xfe, 0x01, 0x00, 0x00,
	0xfe, 0x07, 0x00, 0x00, 0xfc, 0x1f, 0x00, 0x00,
	0xfc, 0x7f, 0x00, 0x00, 0xf8, 0xff, 0x01, 0x00,
	0xf8, 0xff, 0x07, 0x00, 0xf0, 0xff, 0x1f, 0x00,
	0xf0, 0xff, 0x7f, 0x00, 0xe0, 0xff, 0xff, 0x01,
	0xe0, 0xff, 0xff, 0x07, 0xc0, 0xff, 0xff, 0x1f,
	0xc0, 0xff, 0xff, 0x7f, 0x80, 0xff, 0xff, 0xff,
	0x80, 0xff, 0xff, 0x7f, 0x00, 0xff, 0x01, 0x00,
	0x00, 0xff, 0x01, 0x00, 0x00, 0xfe, 0x01, 0x00,
	0x00, 0xfe, 0x01, 0x00, 0x00, 0xfc, 0x01, 0x00,
	0x00, 0xfc, 0x01, 0x00, 0x00, 0xf8, 0x01, 0x00,
	0x00, 0xf8, 0x01, 0x00, 0x00, 0xf0, 0x01, 0x00,
	0x00, 0xf0, 0x01, 0x00, 0x00, 0xe0, 0x01, 0x00,
	0x00, 0xe0, 0x01, 0x00, 0x00, 0xc0, 0x01, 0x00,
	0x00, 0xc0, 0x01, 0x00, 0x00, 0x80, 0x00, 0x00
    };

  /* X11-4/13/90-Create the cursor */

  cursor_map = XCreateBitmapFromData ( _FI_display, window,
			(char *)cursor_bits, cursor_width, cursor_height );

  /* X11-4/13/90-Create the MASK */

  cursorM_map = XCreateBitmapFromData ( _FI_display, window,
			 (char *)cursorM_bits, cursorM_width, cursorM_height );

  XParseColor ( _FI_display, DefaultColormap ( _FI_display, Xscreen ),
					 "white", &foreground );

  XParseColor ( _FI_display, DefaultColormap ( _FI_display, Xscreen ),
					 "black", &background );

  cursor = XCreatePixmapCursor ( _FI_display, cursor_map, cursorM_map,
		 &foreground, &background, cursor_x_hot, cursor_y_hot );

  XDefineCursor ( _FI_display, window, cursor );

  XFreePixmap ( _FI_display, cursor_map );
  XFreePixmap ( _FI_display, cursorM_map );

		/** Does nothing unless FEI modified **/
  FI_set_window_attr ( window );
}


/* MEMORY */

int _FI_f_load_form (struct FIform_obj *form,
                     int               *num_gadgets,
                     int               *form_version)
{
  int version;
  char header[8];
  int	xx;
  int	sts;
  int	xscreen;
  short dummy_short;

  _FI_read_bytes ( 8, header );
  if ( strncmp ( &header[2], "FIform", 6 ))
    {
      return ( FI_INVALID_FORMAT );
    }

	/*** If the version is less then 3, then	***/
	/***  it is an old format that is not readable	***/
	/***  by I/FORMS.				***/

/*  *form_version = version = (int)_FI_read_short (); */
  dummy_short = _FI_read_short ();
  *form_version = version = (int)dummy_short;

  if ( version < 3 )
    {
      return ( FI_INVALID_VERSION );
    }
  else if ( version > FI_CURRENT_FORM_VERSION )	/*** JAJ:10-02-90 ***/
    {
printf("form version:  %d\n", version);
      return ( FI_INVALID_NEWER_FORM_VERSION );
    }

  form->person = _FI_reada_string ();
  form->creation_date = _FI_read_int ();

  form->attr_mask = _FI_read_int ();

  form->level = _FI_read_int ();

  form->xlo = _FI_read_short ();
  form->ylo = _FI_read_short ();
  form->xhi = _FI_read_short ();
  form->yhi = _FI_read_short ();

	/* Set orig xlo and ylo */

  form->orig_xlo = form->xlo;
  form->orig_ylo = form->ylo;

  form->orig_xsize = _FI_read_short ();
  form->orig_ysize = _FI_read_short ();

  form->screen_width = _FI_read_short ();
  form->screen_height = _FI_read_short ();

  form->collapse_icon_xpos = _FI_read_short ();
  form->collapse_icon_ypos = _FI_read_short ();

  /***************************************
   if ( form->collapse_icon_xpos != -1 )
   form->collapse_pos_not_set = FALSE;
  ***************************************/
  /* Changed this to force collapse pos to be loaded. GMD 1/21/91 */

  form->collapse_pos_not_set = TRUE;

  form->bgcolor = _FI_read_char ();

  form->collapse_icon_index = _FI_read_char ();
  form->collapse_icon_file = _FI_reada_string ();


  form->screen = _FI_read_char ();

	  /*** JAJ:02/12/92 ***/
  if ( version <= 5 )
    {
	/*** These are valid only for forms of version <= 5 ***/
#define FI_LEFT_SCREEN		0
#define FI_CURRENT_SCREEN	1
#define FI_RIGHT_SCREEN		2
#define FI_BACK_SCREEN		3

      if ( form->screen == FI_CURRENT_SCREEN )
	{
	  form->screen = FI_CURRENT_SCRN;
	}
      else
	{
	  form->screen = FI_DEFAULT_SCRN;
	}
    }
  else
    {
	/*** At this point, the form's stored "screen" value 	***/
	/*** is either 0-n, indicating a hardcoded screen	***/
	/*** value, or FI_DEFAULT_SCRN, or FI_CURRENT_SCRN	***/

      /* dmb:09/11/92:Note: This comparison requires signed chars */
      if ( form->screen >= 0 )
	{
          form->Xscreen = form->screen;
	  form->screen = FI_HARDCODED_SCRN;
	}
    }

  if ( form->screen == FI_DEFAULT_SCRN )
    {
      form->Xscreen = DefaultScreen ( _FI_display );
    }
  else if ( form->screen == FI_CURRENT_SCRN )
    {
      sts = _FI_get_active_screen ( & xscreen );
      if ( ! sts )
	{
	  form->Xscreen = xscreen;
	}
      else
	{
	  form->Xscreen = DefaultScreen ( _FI_display );
	}
    }

    form->num_desc = _FI_read_short ();

    if ( form->num_desc )
    {
       form->description = (char **) calloc ( (int) form->num_desc,
						 sizeof ( char *));

       for ( xx = 0; xx < form->num_desc; xx++ )
       {
	  form->description[xx]= _FI_reada_string ();
       }
    }

  if ( version == 3 )
    {
     /* future bytes */

      _FI_read_double ();
      _FI_read_double ();
      _FI_read_double ();
      _FI_read_double ();
      _FI_read_double ();

      form->seq_label = (int) _FI_read_short ();

      if ( form->seq_label == 14648 )
	{
	  form->seq_label = -1;
        }
    }
  else if ( version == 4 )
    {
	/* 2 byte hook */

      _FI_read_short ();

      form->seq_label = (int) _FI_read_short ();
    }
  else	/*** form version >= 5 ***/
    {
      form->seq_label = _FI_read_int ();	/*** JAJ:09/29/90 ***/
    }

  *num_gadgets = _FI_read_short ();

  return ( FI_SUCCESS );
}


int _FI_f_load_gadgets (struct FIform_obj *form,
                        int    form_version)
{
  struct FIgadget_obj *gadget;
  int type;
  int label;
  short gadget_version;

  while (( type = (int) _FI_read_short ()) != FI_END_OF_FILE )
    {
      gadget_version = _FI_read_short ();

      if ( form_version >= 5 )	/*** JAJ:09/29/90 ***/
	{
	  label = _FI_read_int ();
        }
      else
        {
	  label = (int) _FI_read_short ();
        }

      if ( type == FI_GROUP )
	{
		/* Load group and add to the form group */

	  _FI_group_load ( form, label, FI_FORM_GROUP, form_version );
	}
      else if ( ! _FI_g_new ( form, type, label, &gadget ) )
	{
	  _FI_g_load ( gadget, form_version, gadget_version );
        }
    }

  return ( FI_SUCCESS );
}


/* ARGSUSED */
void _FI_f_adjust_location (int screen,
                            short *xlo,
                            short *ylo,
                            short *xhi,
                            short *yhi)
{
  int xsize = ( *xhi - *xlo );
  int ysize = ( *yhi - *ylo );

  if ( *xlo < 0 )
    {
      *xlo = 0;
    }

  if ( *ylo < 0 )
    {
      *ylo = 0;
    }

  if (( *xlo + xsize ) > FI_current_screen_width )
    {
	*xlo = MAX ( 0, FI_current_screen_width - xsize );
    }

  if (( *ylo + ysize ) > FI_current_screen_height )
    {
	*ylo = MAX ( 0, FI_current_screen_height - ysize );
    }

  *xhi = *xlo + xsize;
  *yhi = *ylo + ysize;
}


/* This function returns the next available ( not in use ) */
/* NEGATIVE gadget label for the form. */

int _FI_f_get_next_neg_label (struct FIform_obj *form,
                              int               *next_label)
{
  for ( *next_label = form->begin_neg_label ;
	_FI_grp_is_label_used_within_group ( form->group, *next_label );
						( *next_label ) -- )
      ;

  form->begin_neg_label = *next_label;

  return ( FI_SUCCESS );
}


int _FI_Xwindow_to_index (Window win)
{
  int ii;

  for ( ii = 0; ii < MAX_WINDOW; ii++ )
    {
      if ( win == _FI_index_to_Xwindow[ii] )
	{
	  return ( ii );
        }
    }

  return ( -1 );
}
