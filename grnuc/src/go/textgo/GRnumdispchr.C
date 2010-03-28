/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRnum_disp_char
 
     Abstract:

               This routine determines the number of displayable
            characters in a text string.
-----
%SC%

  VALUE = GRnum_disp_char(msg,text_string,text_length,current_font,
                          font_flags,num_disp_char)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   -------------------------------------
    *msg          IGRlong           completion code
    *text_string  IGRuchar          text string to examine
    *text_length  IGRshort          length of text string
    current_font  IGRshort          font that string was placed with
    font_flags    IGRint            indicates the text string's initial
                                    font type
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     --------------- -----------------------------------------
     *num_disp_char IGRshort        number of displayable characters in the
                                    text string

     VALUE (IGRlong) =    MSSUCC    - if successful
-----
%MD%

     MODULES INVOKED:   GRfwd_esc_seq

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        WBC  08/20/86 : Design date.
        WBC  08/20/86 : Creation date.
        DEK  06/13/88 : Included 16-bit characters.
        WBC  01/03/89 : Added the font_flags argument to support
                        8-bit fonts.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine determines the number of displayable characters in
a given text string.  Linefeeds and escape sequences themselves are
not displayable characters, but an escape character followed by
either another escape character or a linefeed is considered one
displayable character.
----*/
/*EH*/

#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "gotextdef.h"
#include "grimport.h"
#include "OMmacros.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"

IGRboolean GRnum_disp_char(msg,text_string,text_length,current_font,
                           font_flags,num_disp_char)

IGRlong             *msg;
IGRuchar            *text_string;
IGRshort            *text_length;
IGRshort            current_font;    /* current font in string              */
IGRint              font_flags;      /* indicates the text string's initial */
                                     /* font type                           */
IGRshort            *num_disp_char;
{

    extern IGRshort GRfwd_esc_seq(); /* moves pasr escape sequences          */

    struct vfont_entry  font_info;   /* current font information             */
    IGRshort i;                      /* index counter                        */
    IGRshort num_chars;              /* number of chars. moved past in the
                                        escape sequence(s)                   */
    IGRshort            s_hold;      /* stores a short from the string       */
    IGRboolean          multi_mode;  /* move past one or several escape seq. */
    IGRshort            prev_font;   /* previously used font in string       */

    *msg = MSSUCC;
    *num_disp_char = 0;
    multi_mode = TRUE;
    i = 0;
    prev_font = -1;

    while (i < *text_length)
    {
        if (font_flags & SIXTEEN_BIT)
        {
           i += 2;
           ++(*num_disp_char);
        }
        else
        {
           if (GRfwd_esc_seq(msg,text_string,text_length,&multi_mode,&i,&num_chars))
           {
               if (text_string[i + 1] == 'f')
               {
                  /*
                   * a change font escape sequence; must find the font type
                   */

                  OM_BLOCK_MOVE(&(text_string[i + 2]),&s_hold,2);

                  font$get_info(msg = msg,
                                font_num = &s_hold,
                                font_info = &font_info);

                  prev_font = current_font;
                  current_font = s_hold;

                  font_flags = font_info.flags;
               }
               else if (text_string[i + 1] == 'p' &&
                        text_string[i + 2] & POP_FONT)
               {
                  /*
                   * a pop font escape sequence; must find the font type
                   */

                  if (prev_font != -1)
                  {
                     current_font = prev_font;

                     font$get_info(msg = msg,
                                   font_num = &current_font,
                                   font_info = &font_info);

                     font_flags = font_info.flags;
                  }
               }

               i += num_chars;            /* increment past escape sequence */
           }
           else if (text_string[i] == ESC)
           {
               /*
                * an escape character followed by another escape
                * character or linefeed counts as one displayable character
                */

               ++(*num_disp_char);  /* counts as one displayable character */
               i += 2;
           }
           else
           {
               ++(*num_disp_char);
               ++i;
           }
        }
    }

    return(TRUE);
}
