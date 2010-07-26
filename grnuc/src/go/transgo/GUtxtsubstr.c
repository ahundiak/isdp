#include "grimport.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "gotextdef.h"
#include "msdef.h"
#include "dpdef.h"
#include "fontdef.h"
#include "font.h"
#include "transdef.h"
#include "FSOutl.h"

#ifdef NEVER_DEF
#include "dpgraphics.h"
#endif

/* ARGSUSED */
IGRboolean GUget_text_substring ( msg, text_string, text_length, fontinfo,
				  convert, font_type, flags, num_chars )

IGRlong             *msg;                /* completion code                  */
IGRuchar    	    *text_string;        /* text string                      */
IGRshort            *text_length;        /* length of text string (in bytes) */
struct vfont_entry  *fontinfo;		 /* the font info                    */
IGRboolean          *convert;            /* TRUE if converting to IGDS, FALSE*/
                                         /* if creating a plotting meta file */
IGRint              font_type;           /* type of font (char or fraction   */
IGRint              *flags;              /* bit 3:  0 if 7 or 8 bit          */
                                         /*         character code           */
                                         /*         1 if 16 bit character    */
                                         /*         code                     */
                                         /* bits 4-31: reserved for later use*/
IGRshort            *num_chars;          /* number of consecutive non-escape */
                                         /* characters                       */
{

    IGRuchar 		*strptr;
    IGRshort         	i;               /* index counter                    */
    IGRdouble		x_coord;
    IGRdouble		y_coord;
/*  OutlCharInfo        char_info; */    /* information about a character    */

#ifdef NEVER_DEF
    Display 		*display;
    int			window;
    GC			gc;
#endif

    /*
     *  Initializations.
     */
     
    *msg = MSSUCC;
    *flags = 0;
    strptr = text_string;

    /*
     *  find the number of bytes required to represent each character;
     *  search the text string for the first encountered escape character
     *  blank, or an invalid (undefined) character for that font.
     *	For an invalid character its x_coord and y_coord is = 0.
     */

    if ( !(fontinfo->flags & SIXTEEN_BIT) )   /* 7 or 8 bit character code */
    {
        for ( *num_chars = 0; *num_chars < *text_length; (*num_chars)++ )
        {
            if ( *strptr == ESC )
            {
		*msg = GUESCAPE_TYPE;
            	break;
            }
/*  don't break up string at blanks
	    else if (*convert && *strptr == BLANK && font_type != FRACTION_FONT)
	    {
*/
                /*
                 * if the blank character has any strokes in it (it is
                 * not just "blank"), move past it so it will be included
                 * in the text string
                 */
/*  don't break up string at blanks (goes with above commented out code)
                FSGetOutlCharInfo( fontinfo->fontid, (CharId)*strptr,
                                   &char_info);

                if ((char_info.xMax == 0.0) &&
                    (char_info.yMax == 0.0) &&
                    (char_info.yMin == 0.0))
                {
                    *msg = GUBLANK_TYPE;
                    break;
                }
	    } */

#ifdef NEVER_DEF
	    FSXGetTextVect ( display,window,gc,fontinfo->fontid,
			    strptr, 1, 0.0, 0.0,&x_coord, &y_coord);
#else
	    FSGetTextVect ( fontinfo->fontid, strptr, 1, 0.0, 0.0, 
			    &x_coord, &y_coord);
#endif
	    if ((!x_coord) && (!y_coord))
	    {
		*msg = GUINVALID_TYPE;
		break;
	    }
	    strptr++;
        }

        *flags &= ~(SIXTEEN_BIT);
    }
    else   /* 16 bit character code => 2 bytes per character */
    {
	/*
	 *  At this time we do not search for BLANKS in 16 bit
	 *  fonts.  This is because we only support KANJI which
	 *  is a mono-space font (all chars are the same size),
	 *  therefore there is no need to strip blanks out of
	 *  a 16 bit text string.  In the future, if other 16 bit
	 *  fonts are supported that are not mono-space, it will
	 *  be necessary to add code to strip out the blanks.
	 */
	 
        i = 0;
        *num_chars = 0;

        while ( i < *text_length && strptr[i] != ESC )
        {
           ++(*num_chars);
           i += 2;
        }

   	if ( strptr[i] == ESC )
   	{
   	    *msg = GUESCAPE_TYPE;
	}
	
        *flags |= SIXTEEN_BIT;
    }
    
    return ( TRUE );
}
