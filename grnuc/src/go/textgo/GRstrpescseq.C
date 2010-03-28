/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRstrip_esc_sequences
 
     Abstract:  This routine strips escape sequences from a text string.
-----
%SC%

     VALUE =  GRstrip_esc_sequences(msg,prev_font,current_font,
                                    font_flags,text_string,text_length)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                   DESCRIPTION
     ----------   ------------     -------------------------------------
     prev_font    IGRshort         previous font at start of text string
     current_font IGRshort         font used at the start of text string
     font_flags   IGRint           font information about current_font
     *text_string IGRuchar         text string to strip escape sequences
                                   from
     *text_length IGRshort         number of bytes in the unstripped
                                   text string
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   -----------    -------------------------------------
     *msg         IGRlong        Completion code
                                    - MSSUCC if successful

     *text_string IGRuchar       text string without escape sequences
     *text_length IGRshort       number of bytes in the stripped
                                 text string

     VALUE (IGRboolean) = TRUE            - always successful
-----
%MD%

     MODULES INVOKED: 
-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
        
        WBC  07/06/88 : Design date.
        WBC  07/06/88 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
    This routine strips escape sequences from a text string.
A linefeed escape sequence will be replaced with a linefeed
character and two consecutive escape characters will be replaced
by one escape character.
----*/
/*EH*/

#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "OMmacros.h"
#include "gotextdef.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"

IGRint GRstrip_esc_sequences(msg,prev_font,current_font,font_flags,
                             text_string,text_length)

IGRlong           *msg;          /* completion code                          */
IGRshort          prev_font;     /* previous font at start of text string    */
IGRshort          current_font;  /* font used at the start of text string    */
IGRint            font_flags;    /* font information about current_font      */
IGRuchar          *text_string;  /* text string possibly containing esc seqs */
IGRshort          *text_length;  /* number of bytes in the unstripped string */

{
    struct vfont_entry   font_info;
    IGRboolean           multi_mode;
    extern IGRshort      GRfwd_esc_seq();
    IGRshort             i;
    IGRshort             num_chars;

    *msg = MSSUCC;
    multi_mode = FALSE;
    i = 0;
    font_info.flags = font_flags;

    /*
     *  if a non-displayable escape sequence is found, copy over it with the
     *  remainder of the text string; if a displayable escape sequence is
     *  found, copy over only the escape character and leave the displayable
     *  character
     */

    while (i < *text_length)
    {
        if (GRfwd_esc_seq(msg,text_string,text_length,&multi_mode,
                          &i,&num_chars))
        {
            /*
             * if changing (or popping) to a different font, find the
             * font_flags of the new font
             */

            if (text_string[i + 1] == 'f')
            {
                prev_font = current_font;

                OM_BLOCK_MOVE(&text_string[i + 2],&current_font,2);

                font$get_info(msg = msg,
                              font_num = &current_font,
                              font_info = &font_info);
            }
            else if ((text_string[i + 1] == 'p') &&
                     (text_string[i + 2] & POP_FONT))
            {
                if (prev_font != -1)
                {
                    current_font = prev_font;

                    font$get_info(msg = msg,
                                  font_num = &current_font,
                                  font_info = &font_info);
                }
            }

            *text_length -= num_chars;

            OM_BLOCK_MOVE(&text_string[i + num_chars],&text_string[i],
                          (IGRint)(*text_length - i));
        }
        else   /* displayable character */
        {
            if (text_string[i] == ESC)   /* ESC ESC or ESC LINEFEED */
            {
                --(*text_length);

                OM_BLOCK_MOVE(&text_string[i + 1],&text_string[i],
                              (IGRint)(*text_length - i));

                ++i;
            }
            else if (font_info.flags & SIXTEEN_BIT)
            {
                i += 2;
            }
            else  /* seven or eight bit text */
            {
                ++i;
            }
        }
    }
    return(TRUE);
}
