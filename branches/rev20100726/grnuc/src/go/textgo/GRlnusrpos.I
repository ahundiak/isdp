/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRline_user_position
 
     Abstract:
               This routine determines the index of the valid cursor position
               at the specified line and user position.  If the specified line
               and user position are not at a valid cursor position (i.e. they
               don't exist in this string or they are in a non-editable field),
               a flag determines if the valid cursor index before or after the
               the specified line and user position is returned.
-----
%SC%

  VALUE = GRline_user_position(msg,text_string,text_length,before,
                               start_line_num,start_user_pos,start_index,
                               init_font_flags,font_flags,prev_font,
                               current_font,line_num,user_pos,cursor_index)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ----------------------------------------
    *msg            IGRlong           completion code
    *text_string    IGRuchar          entire text string
    text_length     IGRshort          length of the text string
    before          IGRint            flag to indicate which cursor index to
                                      return if the requested position is
                                      not valid :
                                      TRUE - position before specified one
                                      FALSE - position after specified one
    start_line_num  IGRshort          current line number
    start_user_pos  IGRshort          current user position
    start_index     IGRshort          current index
    init_font_flags IGRint            indicates the text string's initial
                                      font type
    font_flags      IGRint            indicates the font type at the current
                                      index (start_index)
    prev_font       IGRshort          previous font at current index
    current_font    IGRshort          current font at current index
    *line_num       IGRshort          line number to move to
    *user_pos       IGRshort          user position to move to
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *line_num      IGRshort        line number moved to
   *user_pos      IGRshort        user position moved to
   *cursor_index  IGRshort        index of the valid cursor position at the
                                  line and user position moved to

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
           1)  The current position must be a valid cursor position.
           2)  If the current position is not known, initialize
               start_line_num = 1, start_user_pos = 1, start_index = 0.
-----

%CH%
     CHANGE HISTORY:
        
        WBC  08/18/88 : Design date.
        WBC  08/18/88 : Creation date.
        WBC  01/04/89 : Added the font_flags argument to support
                        8-bit fonts.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This routine determines the index of the valid cursor position
at the specified line and user position.  If the specified line
and user position are not at a valid cursor position (i.e. they
don't exist in this string or they are in a non-editable field),
a flag determines if the valid cursor index before or after the
the specified line and user position is returned.
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
#include "fontmacros.h"

#define NON_EDITABLE  1

#argsused
IGRint GRline_user_position(msg,text_string,text_length,before,
                            start_line_num,start_user_pos,start_index,
                            init_font_flags,font_flags,prev_font,current_font,
                            line_num,user_pos,cursor_index)

IGRlong             *msg;           /* completion code                       */
IGRuchar            *text_string;   /* entire text string                    */
IGRshort            text_length;    /* length of the text string             */
IGRint              before;         /* flag to indicate which cursor index to*/
                                    /* return if the requested position is   */
                                    /* not valid :                           */
                                    /* TRUE - position before specified one  */
                                    /* FALSE - position after specified one  */
IGRshort            start_line_num; /* current line number                   */
IGRshort            start_user_pos; /* current user position                 */
IGRshort            start_index;    /* current index                         */
IGRint              init_font_flags;/* indicates the text string's initial   */
                                    /* font type                             */
IGRint              font_flags;     /* indicates the font type at the current*/
                                    /* index (start_index)                   */
IGRshort            prev_font;      /* previous font at current index        */
IGRshort            current_font;   /* current font at current index         */
IGRshort            *line_num;      /* line number                           */
IGRshort            *user_pos;      /* user position                         */
IGRshort            *cursor_index;  /* index of valid cursor position        */

{
    extern IGRshort    GRfwd_esc_seq();    /* move forward over              */
                                           /* an escape sequence             */
    IGRlong            temp_msg;
    IGRshort           num_esc_chars;      /* number of characters in        */
                                           /* the escape sequence(s)         */
    IGRshort           temp_line_num;
    IGRshort           temp_user_pos;
    IGRshort           temp_index;
    IGRshort           s_hold;             /* used to store a short from     */
                                           /* the text string                */
    IGRchar            esc_char[1];        /* escape char to search for      */
    IGRboolean         multi_mode;         /* skip single or multiple        */
                                           /* escape sequence?               */
    IGRuchar           non_editable_delim; /* depth nested in a non-editable */
                                           /* field (depth of 0 indicates    */
                                           /* we're not in a non-editable    */
                                           /* field)                         */
    struct vfont_entry font_info;          /* font information               */

    multi_mode = FALSE;
    temp_line_num = 0;
    temp_user_pos = 0;

    /*
     * if the current position is after the position to move to, must start
     * at the beginning of the string since we can only move forward in the
     * text string
     */

    if ((start_line_num > *line_num) ||
        ((start_line_num == *line_num) &&
         (start_user_pos > *user_pos)))
    {
        start_line_num = 1;
        start_user_pos = 1;
        start_index = 0;
        font_flags = init_font_flags;
    }
    non_editable_delim = 0;

    /*
     * move past any stroke start move escape sequences since they are not
     * valid cursor positions
     */

    while ((start_index < text_length) &&
           (text_string[start_index] == ESC) &&
           ((text_string[start_index + 1] == 'j') ||
            (text_string[start_index + 1] == 'J')))
    {
        start_index += 10;
    }

    /*
     * move to the specified line and user position if it's a valid position;
     * if not, move to the valid position immediately before or after the
     * specified line and user position depending on the flag
     */

    while ((start_index < text_length) &&
           ((start_line_num < *line_num) ||
            ((start_line_num == *line_num) && (start_user_pos < *user_pos)) ||
            ((!before) && (non_editable_delim))))
    {
        if (GRfwd_esc_seq(&temp_msg,text_string,&text_length,
                          &multi_mode,&start_index,&num_esc_chars))
        {
            if (text_string[start_index + 1] == 'F')
            {
                if (non_editable_delim)
                {
                    /*
                     * if moving through a non-editable field, increment the
                     * non-editable field delimiter so we will know how deeply
                     * nested we are in the non-editable field
                     */

                    ++non_editable_delim;
                }
                else if (text_string[start_index + 3] & NON_EDITABLE)
                {
                    /*
                     * save the position values before moving into the
                     * non-editable field in case the current position
                     * is the desired position
                     */

                    temp_line_num = start_line_num;
                    temp_user_pos = start_user_pos;
                    temp_index = start_index;
                    non_editable_delim = 1;
                }
            }
            else if (text_string[start_index + 1] == 'E')
            {
                /*
                 * if in a non-editable field, decrement the non-editable
                 * field delimiter counter so we will know when we have
                 * moved out of the non-editable field
                 */

                if (non_editable_delim)
                {
                    --non_editable_delim;
                }
            }
            else if (text_string[start_index + 1] == 'f')
            {
                OM_BLOCK_MOVE(&(text_string[start_index + 2]),&s_hold,2);

                font$get_info(msg = &temp_msg,
                              font_num = &s_hold,
                              font_info = &font_info);

                prev_font = current_font;
                current_font = s_hold;
                font_flags = font_info.flags;
            }
            else if (text_string[start_index + 1] == 'p' &&
                     text_string[start_index + 2] & POP_FONT)
            {
                if (prev_font != -1)
                {
                    current_font = prev_font;

                    font$get_info(msg = &temp_msg,
                                  font_num = &current_font,
                                  font_info = &font_info);

                    font_flags = font_info.flags;
                }
            }

            start_index += num_esc_chars;
        }
        else  /* at a displayable char */
        {
            if (text_string[start_index] == ESC)
            {
                if (text_string[start_index + 1] == LINEFEED)
                {
                    /*
                     * if not in a non-editable field and the current line is
                     * the specified line, this is the best approximation
                     * of the specified position we can get; exit
                     */

                    if ((!non_editable_delim) &&
                        (*line_num == start_line_num))
                    {
                        break;
                    }

                    /*
                     * move past the linefeed escape sequence and its
                     * horizontal justification move if it has one
                     */

                    if ((text_length > start_index + 11) &&
                        (text_string[start_index + 2] == ESC) &&
                        (text_string[start_index + 3] == 'H'))
                    {
                        start_index += 12;
                    }
                    else  /* no horizontal justification move */
                    {
                        start_index += 2;
                    }
                    ++start_line_num;
                    start_user_pos = 1;
                }
                else  /* displayable esc char (two consecutive esape chars) */
                {
                    start_index += 2;
                    ++start_user_pos;
                }
            }
            else  /* current char is a "regular" displayable char */
            {
                if (font_flags & SIXTEEN_BIT)
                {
                    /*
                     * have sixteen bit character
                     */

                    start_index += 2;
                }
                else       /* seven or eight bit character */
                {
                    ++start_index;
                }

                ++start_user_pos;
            }
        }
    }  /* end "while" loop */

    /*
     * if the before flag is TRUE and we have moved past the specified position
     * (because of a non-editable field), return the values saved before going
     * into the non-editable field
     */

    if ((before) &&
        (non_editable_delim))
    {
        *line_num = temp_line_num;
        *user_pos = temp_user_pos;
        *cursor_index = temp_index;
    }
    else
    {
        *line_num = start_line_num;
        *user_pos = start_user_pos;
        *cursor_index = start_index;
    }

    /*
     * if currently at a pop font esc sequence, must find out if the previous
     * change font esc sequence changed to a fraction font; if so, must move
     * past the pop font esc sequence since fractions should appear to be
     * chars from the active text font to the user (don't want them to know
     * fractions are enclosed in change font and pop font esc sequences)
     */

    if ((text_string[*cursor_index] == ESC) &&
        (text_string[*cursor_index + 1] == 'p') &&
        (text_string[*cursor_index + 2] & POP_FONT))
    {
        num_esc_chars = 1;
        esc_char[0] = 'f';

        if (GRbwd_beg_esc_seq(&temp_msg,text_string,&num_esc_chars,esc_char,
                              NULL,cursor_index,init_font_flags,&temp_index))
        {
            OM_BLOCK_MOVE(&(text_string[temp_index + 2]),&s_hold,2);

            font$get_info(msg = &temp_msg,
                          font_num = &s_hold,
                          font_info = &font_info);

            if (font_info.flags & FRACTION_FONT)
            {
                *cursor_index += 3;  /* move past the pop font esc sequence */
            }
        }
    }
    return(TRUE);
}
end implementation GRtext;
