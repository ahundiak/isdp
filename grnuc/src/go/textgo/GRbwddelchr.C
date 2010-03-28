/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRbwd_del_char
 
     Abstract:
                This routine moves forward in a text string searching for 
                the last occurrence of a  character that may be deleted before
                the specified index.  If one is found, it's position in the
                text string and a TRUE value is returned.  Otherwise, FALSE
                will be returned.
-----
%SC%

  VALUE = GRbwd_del_char(msg,text_string,end_index,font,font_info,
                         prev_font,char_index)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ----------------------------------------
    *msg            IGRlong          completion code
    *text_string    IGRuchar         entire text string
    *end_index      IGRshort         position in text string to search to
    *font           IGRshort         indicates the text string's initial
                                     font
    *font_info      struct vfont_entry info about the initial font
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *font          IGRshort        indicates the font at char_index
   *font_info     struct vfont_entry info about the font at char_index
   *prev_font     IGRshort        indicates the previous font at char_index
   *char_index    IGRshort        index of first encountered char to delete

   VALUE (IGRlong) =    MSSUCC    - if successful
-----
%MD%

     MODULES INVOKED:    GRfwd_esc_seq:      move forward over escape
                                             sequence
-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:   If a begin or end field escape sequence is found between the
              char to delete and the char at the specified index, the search
              will end and FALSE will be returned since it's not allowed to
              delete a char that's not in the same field the end position is
              in.  FALSE will also be returned if no deleteable char is found.
-----

%CH%
     CHANGE HISTORY:
        
        WBC  06/17/88 : Design date.
        WBC  06/17/88 : Creation date.
        WBC  08/22/88 : Updated to search forward in the string.
        WBC  01/03/89 : Added the font_flags arguments to support
                        8-bit fonts.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
----------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
----------------------------------------------------------------------
   This routine moves forward in a text string searching for 
the last occurrence of a  character that may be deleted before
the specified index.  If one is found, it's position in the
text string and a TRUE value is returned.  Otherwise, FALSE
will be returned.
----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "msdef.h"
#include "OMmacros.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"

IGRboolean GRbwd_del_char(msg,text_string,end_index,font,font_info,
                          prev_font,char_index)

IGRlong             *msg;          /* completion code                        */
IGRuchar            *text_string;  /* entire text string                     */
IGRshort            *end_index;    /* position in text string to search to   */
IGRshort            *font;         /* indicates the current font             */
struct vfont_entry  *font_info;    /* info about the current font            */
IGRshort            *prev_font;    /* indicates the previous font            */
IGRshort            *char_index;   /* index of the first deleteable char     */
                                   /* that precedes the char at end_index    */

{
    extern IGRshort  GRfwd_esc_seq();/* move forward over an escape sequence */

    IGRboolean       value;        /* functional return value                */
    IGRboolean       multi_mode;   /* go past one or several escape sequences*/
    IGRshort         i;            /* index counter                          */
    IGRshort         esc_seq_chars;/* number of characters in the escape seq */
    IGRshort         temp_font;
    IGRshort         temp_prev_font;
    struct vfont_entry  temp_font_info;

    *msg = MSSUCC;
    i = 0;
    value = FALSE;
    multi_mode = FALSE;  /* go past each escape sequence */
    temp_font = *font;
    temp_prev_font = *prev_font;
    temp_font_info = *font_info;

    while (i < *end_index)
    {
        /*
         *  if a displayable char is found (which includes escape and linefeed
         *  escape sequences), save the index of the char
         */

        if (GRfwd_esc_seq(msg,text_string,end_index,
                          &multi_mode,&i,&esc_seq_chars))
        {
            if ((text_string[i + 1] == 'F') ||
                (text_string[i + 1] == 'E'))
            {
                /*
                 * if a begin or end field escape sequence is between the last
                 * displayable char and the char at the end_index, the chars
                 * are not in the same field so the last displayable char is
                 * not deleteable
                 */

                value = FALSE;
            }
            else if (text_string[i + 1] == 'f')
            {
                /*
                 * a change font escape sequence; must find the
                 * font type
                 */

                temp_prev_font = temp_font;
                OM_BLOCK_MOVE(&(text_string[i + 2]),&temp_font,2);

                font$get_info(msg = msg,
                              font_num = &temp_font,
                              font_info = &temp_font_info);
            }
            else if ((text_string[i + 1] == 'p') &&
                     (text_string[i + 2] & POP_FONT))
            {
                temp_font = temp_prev_font;

                font$get_info(msg = msg,
                              font_num = &temp_font,
                              font_info = &temp_font_info);
            }

            i += esc_seq_chars;
        }
        else   /* a displayable char */
        {
            *char_index = i;
            *font = temp_font;
            *prev_font = temp_prev_font;
            *font_info = temp_font_info;
            value = TRUE;

            if ((text_string[i] == ESC) ||
                (temp_font_info.flags & SIXTEEN_BIT))
            {
                i += 2;  /* ESC ESC, ESC LINEFEED or 16-bit char */
            }
            else  /* 7 or 8 bit char */
            {
                ++i;
            }
        }
    }
    return(value);
}
