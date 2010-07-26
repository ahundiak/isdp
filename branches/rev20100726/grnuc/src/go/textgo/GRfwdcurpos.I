/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRfwd_cursor_position
 
     Abstract:
               This routine determines the index of next valid cursor position.
-----
%SC%

  VALUE = GRfwd_cursor_position(msg,text_string,text_length,start_index,
                                prev_font,current_font,font_flags,
                                cursor_index)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ----------------------------------------
    *msg          IGRlong            completion code
    *text_string  IGRuchar           entire text string
    text_length   IGRshort           length of te text string
    start_index   IGRshort           index of current char
    *prev_font    IGRshort           previously used font at start_index
    *current_font IGRshort           current font at start_index
    *font_flags   IGRint             info about the current font
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *prev_font     IGRshort        previously used font at cursor_index
   *current_font  IGRshort        current font at cursor_index
   *font_flags    IGRint          info about the current font
   *cursor_index  IGRshort        index of next valid cursor position

   VALUE (IGRlong) =    MSSUCC    - if successful
-----
%MD%

     MODULES INVOKED:

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES: 
-----

%CH%
     CHANGE HISTORY:
        
        WBC  08/16/88 : Design date.
        WBC  08/16/88 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine determines the index of next valid cursor position.
----*/
/*EH*/

class implementation GRtext;

#include "grimport.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gotextdef.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "exmacros.h"
#include "fontmacros.h"

#define  NON_EDITABLE 1

#define  SS_ESC_SEQ   0
#define  ESC_SEQUENCE 1
#define  BEGIN_FIELD  2

from GRfm import GRfm_retdata;


#argsused
IGRint GRfwd_cursor_position(msg,text_string,text_length,start_index,
                             prev_font,current_font,font_flags,
                             cursor_index)

IGRlong             *msg;          /* completion code                        */
IGRuchar            *text_string;  /* entire text string                     */
IGRshort            text_length;   /* length of the text string              */
IGRshort            start_index;   /* index of current char                  */
IGRshort            *prev_font;    /* previously used font at start_index    */
IGRshort            *current_font; /* current font at start_index            */
IGRint              *font_flags;   /* info about the current font            */
IGRshort            *cursor_index; /* index of next valid cursor position    */

{
    extern IGRshort    GRfwd_esc_seq();    /* move forward over             */
                                           /* an escape sequence            */

    IGRlong            temp_msg;
    IGRshort           prev_char;          /* type of previous scan char    */
    IGRshort           num_esc_chars;      /* number of characters in       */
                                           /* the escape sequence(s)        */
    IGRshort           s_hold;             /* used to store a short from    */
                                           /* the text string               */
       IGRboolean         multi_mode;         /* skip single or multiple       */
                                           /* escape sequence?              */
    struct vfont_entry font_info;          /* font information              */

    if (start_index < text_length)
    {
        font_info.flags = *font_flags;
        *cursor_index = start_index;
        prev_char = ESC_SEQUENCE;
        multi_mode = FALSE;

        /*
         * if start_index is at a non-displayable escape sequence (ESC ESC and
         * ESC LINEFEED are considered displayable), the next valid cursor
         * position is either the next editable char, the next editable empty
         * field or the char following the stroke start escape sequence(s),
         * whichever is encountered first
         */

        while (GRfwd_esc_seq(&temp_msg,text_string,&text_length,
                             &multi_mode,cursor_index,&num_esc_chars))
        {
            if ((text_string[*cursor_index + 1] == 'j') ||
                (text_string[*cursor_index + 1] == 'J'))
            {
                prev_char = SS_ESC_SEQ;
            }
            else if (prev_char == SS_ESC_SEQ)
            {
                /*
                 * have moved past stroke start move(s); current char is
                 * first valid cursor position in the text string
                 */

                break;
            }
            else if (text_string[*cursor_index + 1] == 'F')
            {
                if (text_string[*cursor_index + 3] & NON_EDITABLE)
                {
                    /*
                     * no valid cursor positions in a non-editable field; move
                     * past it
                     */

                    GRget_field_len(&temp_msg,text_string,&text_length,
                                    cursor_index,*prev_font,*current_font,
                                    font_info.flags,&num_esc_chars);
                }
                else
                {
                    prev_char = BEGIN_FIELD;
                }
            }
            else if (text_string[*cursor_index + 1] == 'E')
            {
                /*
                 * if an end field escape sequence is seperated
                 * from its begin field escape sequence only
                 * by non-field escape sequences, the current
                 * position is in an empty field which is a valid
                 * cursor position
                 */

                if (prev_char == BEGIN_FIELD)
                {
                    break;
                }
            }
            else if (text_string[*cursor_index + 1] == 'f')  /* change font */
            {
                /*
                 * if changing to a fraction font, special movement is
                 * required; we want to make fractions appear as if they are
                 * chars in the current text font (i.e. mask the presence of
                 * the change font and pop font esc sequences for the fraction)
                 */

                OM_BLOCK_MOVE(&(text_string[*cursor_index + 2]),
                              &s_hold,2);

                font$get_info(msg = &temp_msg,
                              font_num = &s_hold,
                              font_info = &font_info);

                if (font_info.flags & FRACTION_FONT)
                {
                    if (*cursor_index == start_index)
                    {
                        /*
                         * starting position is a change font esc seq to a
                         * fraction font; if only one fraction is between the
                         * change font and pop font esc sequences, move past
                         * the pop font esc seq; otherwise move between the
                         * first and second fractions
                         */

                        if ((text_string[*cursor_index + 5] == ESC) &&
                            (text_string[*cursor_index + 6] == 'p') &&
                            (text_string[*cursor_index + 7] & POP_FONT))
                        {
                            *cursor_index += 8;
                        }
                        else
                        {
                            *cursor_index += 5;
                            *prev_font = *current_font;
                            *current_font = s_hold;
                            *font_flags = font_info.flags;
                        }
                        break;
                    }
                    else
                    {
                        /*
                         * have moved to a change font esc seq to a fraction
                         * font; do not want to move into the esc seq
                         */

                        break;
                    }
                }
                else
                {
                    *prev_font = *current_font;
                    *current_font = s_hold;
                    *font_flags = font_info.flags;
                }
            }
            else if ((text_string[*cursor_index + 1] == 'p') &&
                     (text_string[*cursor_index + 2] & POP_FONT)) /* pop font*/
            {
                *current_font = *prev_font;

                font$get_info(msg = &temp_msg,
                              font_num = current_font,
                              font_info = &font_info);

                *font_flags = font_info.flags;
            }
            *cursor_index += num_esc_chars;
        }

        /*
         * if the current char is a displayable char, move past it to the next
         * valid cursor position
         */

        if (*cursor_index == start_index)
        {
            if (text_string[*cursor_index] == ESC)
            {
                if (text_string[*cursor_index + 1] == LINEFEED)
                {
                    /*
                     * the current char is a linefeed; move past it and its
                     * horizontal justification move if it has one
                     */

                    if ((text_length > *cursor_index + 11) &&
                        (text_string[*cursor_index + 2] == ESC) &&
                        (text_string[*cursor_index + 3] == 'H'))
                    {
                        *cursor_index += 12;
                    }
                    else  /* no horizontal justification move */
                    {
                        *cursor_index += 2;
                    }
                }
                else  /* displayable esc char (two consecutive esape chars) */
                {
                    *cursor_index += 2;
                }
            }
            else  /* current char is a "regular" displayable char */
            {
                if (font_info.flags & SIXTEEN_BIT)
                {
                    *cursor_index += 2;
                }
                else
                {
                    ++(*cursor_index);
                }
            }

            /*
             * if the current position is at a pop font esc sequence and the
             * current font is a fraction font, move past the pop font so it
             * will appear fractions are from the active text font
             */

            if ((font_info.flags & FRACTION_FONT) &&
                (text_length > (*cursor_index + 2)) &&
                (text_string[*cursor_index] == ESC) &&
                (text_string[*cursor_index + 1] == 'p') &&
                (text_string[*cursor_index + 2] & POP_FONT))
            {
                *cursor_index += 3;
            }
        }
    }  /* end "if (start_index < text_length)" */
    return(TRUE);
}
end implementation GRtext;
