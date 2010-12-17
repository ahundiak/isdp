#include "FImin.h"

#include "FS.h"          /* dmb:01/11/93: Was FSX.h */
#include "FSFont.h"      /* dmb:01/11/93: Was FSXFont.h */
#include "FSTypes.h"     /* dmb:01/11/93: Was FSXTypes.h */
#include "FSBmap.h"      /* dmb:01/11/93: Was FSXBmap.h */
#include "FSOutl.h"      /* dmb:01/11/93: Was FSXOutl.h */
#include "FSTypeface.h"  /* dmb:01/11/93: Was FSXTypeface.h */
#include <X11/Xlib.h>
 
#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

#if defined(i386)
int FSXDrawChar (Display *display, int screen, Window window, GC gc,
	Font font_id, short ch, double xpos, double ypos, 
	double *next_x, double *next_y)
{
  return(0);
}
#endif
 
/***********************************************************************

	Doc: 

	Abstract: Draw text ( determinied by length ) with mixed 7 and
	          8 or 16 bit characters.
	
	Algorithm: When there is no aux. font, call FSDrawText, otherwise
	          draw character by character.

	Return Status: Returns whatever the Font Server sends back.

	Bugs:

	Notes: o Could be fixed to cut the strings inot sub-strings so
	         kerning pairs are displayed.

	Examples: 

	History: 16-MAR-89 MDS Genesis.

 **********************************************************************/
/* int            window;   ** Environ V window number in which to draw */
/* FontId         font;     ** Font id of the 7 bit font            */
/* FontId         fontAUX;  ** Font id of the 8 or 16 bit font      */
/* unsigned char *text;     ** Text to draw                         */
/* int            length;   ** Byte length of text                  */
/* Real64         x,y;      ** x,y position from which to start drawing */
/* Real64        *nx,*ny;   ** Returns the final x,y position       */
/* int            mode;     ** FI_FS_8_BIT_FONT_TYPE                */
/*                             FI_FS_7_OR_16_BIT_FONT_TYPE          */
/* int            screen;   ** GMD 2/20/92 */
/**********************************************************************/


int _FI_16DrawText(int             window,
                   FontId          font,
                   FontId          fontAUX,
                   unsigned char  *text,
                   int             length,
                   Real64          x,
                   Real64          y,
                   Real64         *nx,
                   Real64         *ny,
                   int             mode,
                   int             mode2,
                   int             screen)
{
	int		sts = 0; /* Return status		    */
	int		pos;     /* Index into string                */
	unsigned short	ch;     /* Character id			    */
	unsigned char	*ch_ptr;/* Pointer to characters	    */

      XFontStruct *font_info = (XFontStruct *) NULL; /* for X font metrics */

      if (mode2 == 0) /* if an X font, get font metrics */
        font_info = XQueryFont(_FI_display, font);

	
        XCopyGC(_FI_display, _FI_gc, GCForeground, _FI_text_gc);

	if( fontAUX == (FontId)NULL ) /* no 16-bit font specified */
	{
		/*
		 * If there is no aux. font, use normal Font Server call
		 */
		 
        /* sml:11-08-92       check if FS or X font */
        if ( mode2 == FI_FS_8_BIT_FONT_TYPE ) /* FS font */
        {
		sts = FSXDrawText (_FI_display, screen,
            window, _FI_text_gc, font,(char *) text,length,x,y,nx,ny);
		return(sts);
        }
        else /* X font */
        {
              sts = XSetFont ( _FI_display, _FI_gc, font ); 
              if (sts)
                return(sts);
              XDrawString ( _FI_display, window, _FI_gc, (int)x /*xpos*/,
                      (int) y /*ypos + font_height*/, (char *)text, length );
              if (sts)
                return(sts);
        }
        }
	else
	{
		pos = 0;
		while( pos < length )
		{
			/*
			 * Draw the specified length
			 */
			 
			if( sbitset(text[pos]) )
			{
				/*
				 * Sign bit is set
				 */

				if( mode == FI_FS_7_OR_16_BIT_FONT_TYPE	)
				{
					/*	sml:06-17-92	Don't do this anymore; XFS will
					 *					do swapping
					 * Byte swap for sixteen bit font
					 */
					 
					ch_ptr = (unsigned char *) &ch;
					/*
					ch_ptr[0] = text[pos+1];
					ch_ptr[1] = text[pos];
					*/
					ch_ptr[0] = text[pos];
					ch_ptr[1] = text[pos+1];
					sts = FSXDrawChar(_FI_display, 
                                                screen,
                                                window,
                                                _FI_text_gc, fontAUX,
						ch,x,y,&x,&y);
					if( sts != 0 )
					{
						return(sts);
					}
					pos+=2;
				}
				else
				{
					/*
					 * eight bit font
					 */
					 
/* dmb,jjm:04/14/93:Chasing the elusive 16-bit font display! */
					sts = FSXDrawChar(_FI_display,
                                                screen,
                                                window,
                                                _FI_text_gc, fontAUX,
						(short)text[pos],x,y,&x,&y);
					if( sts != 0 )
					{
						return(sts);
					}
					pos+=1;
				}
			}
			else
			{
				/*
				 * Seven bit character
				 */
				 
/* dmb,jjm:04/14/93:Chasing the elusive 16-bit font display! */
                        /* sml:11-06-92 add test for Fontserver font 
                                        vs X .snf font
                                        This is an issue now that we look for
                                        X fonts first
                        */
                        if ( mode == FI_FS_7_OR_16_BIT_FONT_TYPE )
                        /* Fontserver 7-bit font */
                        {
				sts = FSXDrawChar(_FI_display,
                                        screen,
                                        window, _FI_text_gc, font,
                                        (short)text[pos],x,y,&x,&y);
				if( sts != 0 )
				{
					return(sts);
				}
                        } /* end if a Fontserver 7-bit font */

                        else if ( mode2 == FI_RASTER_8_BIT_FONT_TYPE )   
                        /* have an X server 8-bit font */
                        {
                              char str[5];

                              sts = XSetFont ( _FI_display, _FI_gc, font ); 
                              if (sts)
                                return(sts);

                              str[0]=text[pos];
                              str[1]='\0';
                              sts = XDrawString ( _FI_display, window, _FI_gc,
								(int)x, (int)y, str, 1 );
                              if (sts)
                                return(sts);
                              x = x + (double)XTextWidth(font_info, str, 1);
                        }
				pos+=1;
			}
		}
		*nx=x;
		*ny=y;
		return(sts);		
	}
  return (FI_SUCCESS);
}

