#include "FImin.h"
#include "FIread.h"

#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


int _FI_draw_text (Window   window,
                   Font     font_id,
                   char    *text,
                   int      length,
                   int      xpos,
                   int      ypos,
                   int      font_height,
                   int     *nx,
                   int     *ny,
                   int      font_type)
{
  char *verbose = 0;
  int status;
  int screen;
  Form text_form;
  int window_index;

  extern char *getenv();

  /* dmb:09/27/91:typecast */
  if ((font_id == 0) || (font_id == (Font)-1))  /* Invalid font  GMD 4/9/91 */
    {
      return ( FI_SUCCESS );   /* Need to change this    GMD 8/15/91  */
    }

  /* GMD 4/20/92   Need to figure out what screen to display this on */
  /*               by first figuring out what form is associated     */
  /*               with the specified window.                        */

  verbose = getenv( "OMVERBOSE_WARNING" );

  window_index = _FI_Xwindow_to_index (window);

  if (window_index > MAX_WINDOW)
    {
    if( verbose )
      fprintf (stderr, "_FI_draw_text: window_index > MAX_WINDOW\n");

    verbose = 0;
    return (FI_SUCCESS);
    } 

  text_form = (Form)FI_forms[window_index];

  if (!text_form)
    {
    if( verbose )
      fprintf (stderr, "_FI_draw_text: text_form is NULL\n");

    verbose = 0;
    return (FI_SUCCESS);
    }

  screen = ((struct FIform_obj *)text_form)->Xscreen;

  if ( font_type == FI_RASTER_8_BIT_FONT_TYPE )    /* 8 bit .snf */
    {
      XSetFont ( _FI_display, _FI_gc, font_id );

      XDrawString ( _FI_display, window, _FI_gc, xpos,
			ypos + font_height, text, length );
    }
  else if ( font_type == FI_FS_8_BIT_FONT_TYPE )   /* 8 bit Fontserver */
    {
      double next_x;
      double next_y;	
	
	/*** Copy the _FI_gc into a temporary _FI_text_gc	***/
	/*** variable, because the FSX calls corrupt the GC	***/
	/*** passed into it.					***/
/* dmb,gmd:01/07/92:Added GCBackground.*/

      XCopyGC ( _FI_display, _FI_gc, GCForeground | GCBackground,
        _FI_text_gc );

      status = FSXDrawText (_FI_display, screen,
                                window, _FI_text_gc, font_id, text, length,
				(double)xpos,
			        (double)(ypos + font_height), 
				&next_x, &next_y );

      if ( status )
	{
	  fprintf ( stderr, "FSDrawText error = %d\n", status );
	}

      *nx = next_x;
      *ny = next_y;		
    }
  else   /* FI_FS_7_OR_16_BIT_FONT_TYPE - 16 bit Fontserver */
    {
      double next_x;
      double next_y;
      int font_id_8bit, x, dummy, dummy2;
	  Font dummy1;
      int bodysize = 20;
		
	/***********************************/
	/* Find the closest mono821b font  */
	/* to the size of the 16 bit font. */
	/***********************************/

      for ( x = 0; x < _FI_next_font; x++ )
	{
	  if ( _FI_fonts[x].font_id == font_id )
	    {
	      bodysize = (int) _FI_fonts[x].bodysize;

	      break;
	    }
	}

      if ( !_FI_font_available ( "mono821b", bodysize,
				(Font *) &font_id_8bit, &font_type /*&dummy*/ ) )
	{  
	  status = FI_load_font ( "mono821b", bodysize, &dummy,
						&dummy1, &dummy2 );

	  _FI_font_available ( "mono821b", bodysize,
				(Font *) &font_id_8bit, &font_type /*&dummy*/ );
	}		   	

	/*** 12/07/89 Calculate the byte length of string ***/
                                              /* 16stuff.c */

      length = _FI_locate_16bit_start_byte ( length, text );

      if ( length < 0 )	
	{
         length = 0;
	}

	/*********************************************************/
	/*  All the credit for the SSdrawText routine goes to    */
	/*  Mark Sullivan of Intergraph Japan.  It allows you to */
	/*  send a string of mixed 7 and 16 bit characters, and  */
	/*  it is smart enough to print them out correctly.      */
	/*                                                       */
	/*  One minor restriction is that both the 8 bit font    */
	/*  and the 16 bit font must be fontserver fonts.        */
	/*********************************************************/

      if ( length )
	{
          status = _FI_16DrawText ( window, font_id_8bit, font_id,
					(unsigned char *) text, length, 
				     (double)xpos, 
	                             (double)(ypos + font_height), 
				     &next_x, &next_y,
					FI_FS_7_OR_16_BIT_FONT_TYPE, font_type,
                                       screen );

	  if ( status )
	    {
	      fprintf ( stderr, "ERROR FSdrawText = %d\n", status );
	    }

	  *nx = next_x;
	  *ny = next_y;		
	}
  }

    verbose = 0;
  return ( FI_SUCCESS );
}
