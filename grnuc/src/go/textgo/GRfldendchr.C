/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRfield_end_char
 
     Abstract:
                This routine moves forward in a field searching for the last
                occurrence of an editable char in the field.  This does not
                include chars in fields that are nested inside the specified
                field.  If an editable char is found in the specified field,
                it's position in the text string and a TRUE value is returned.
                Otherwise, FALSE will be returned.
-----
%SC%

  VALUE = GRfield_end_char(msg,text_string,text_length,field_index,prev_font,
                           current_font,font_info,char_index)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ----------------------------------------
    *msg          IGRlong           completion code
    *text_string  IGRuchar          entire text string
    text_length   IGRshort          length of the text string (in bytes)
    field_index   IGRshort          index of the begin field escape sequence
    *current_font IGRshort          string's initial font
    *font_info    struct vfont_entry initial font information
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *prev_font     IGRshort          prev_font at char_index
   *current_font  IGRshort          font at char_index
   *font_info     struct vfont_entry font information at char_index
   *char_index    IGRshort        index of the last editable char in the
                                  field

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

     NOTES:
-----

%CH%
     CHANGE HISTORY:
        
        WBC  08/23/88 : Design date.
        WBC  08/23/88 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
----------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
----------------------------------------------------------------------
   This routine moves forward in a field searching for the last
occurrence of an editable char in the field.  This does not
include chars in fields that are nested inside the specified
field.  If an editable char is found in the specified field,
it's position in the text string and a TRUE value is returned.
Otherwise, FALSE will be returned.
----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "OMmacros.h"

IGRint GRfield_end_char(msg,text_string,text_length,field_index,prev_font,
                        current_font,font_info,char_index)

IGRlong             *msg;          /* completion code                        */
IGRuchar            *text_string;  /* entire text string                     */
IGRshort            text_length;   /* length of the text string (in bytes)   */
IGRshort            field_index;   /* index of the begin field escape seq    */
IGRshort            *prev_font;    /* previous font                          */
IGRshort            *current_font; /* current font                           */
struct vfont_entry  *font_info;    /* font information                       */
IGRshort            *char_index;   /* index of the last editable char in the */
                                   /* field                                  */

{
    extern IGRshort GRfwd_esc_seq();/* move forward over an escape sequence  */

    IGRboolean      value;          /* functional return value               */
    IGRboolean      multi_mode;     /* go past one or several escape seq     */
    IGRshort        end_field_index;
    IGRshort        num_chars;
    IGRshort        s_hold;         /* temp storage for font number (short)  */

    *msg = MSSUCC;
    value = FALSE;
    multi_mode = FALSE;  /* go past each escape sequence */
    *prev_font = *current_font;

    /*
     * find the index of the end of the specified field
     */

    GRget_field_len(msg,text_string,&text_length,&field_index,
                    *prev_font,*current_font,font_info->flags,&num_chars);

    end_field_index = field_index + num_chars;

    /*
     * increment field_index past the begin field escape sequence of the
     * specified field so search will begin inside the field
     */

    field_index += GRfwd_esc_seq(msg,text_string,&text_length,
                                 &multi_mode,&field_index,&num_chars);

    while (field_index < end_field_index)
    {
        /*
         *  if a displayable char is found (which includes escape and linefeed
         *  escape sequences), save the index of the char
         */

        if (GRfwd_esc_seq(msg,text_string,&text_length,
                          &multi_mode,&field_index,&num_chars))
        {
            if (text_string[field_index + 1] == 'F')
            {
                /*
                 * do not want editable chars from nested fields, so move
                 * past this field
                 */

                GRget_field_len(msg,text_string,&text_length,&field_index,
                                *prev_font,*current_font,font_info->flags,
                                &num_chars);
            }
            else if (text_string[field_index + 1] == 'f')
            {
                OM_BLOCK_MOVE(&(text_string[field_index + 2]),&s_hold,2);

                font$get_info(msg = msg,
                              font_num = &s_hold,
                              font_info = font_info);

                *prev_font = *current_font;
                *current_font = s_hold;
            }
            else if (text_string[field_index + 1] == 'p' && 
                     text_string[field_index + 2] & POP_FONT)
            {
                if (*prev_font != -1)
                {
                    current_font = prev_font;

                    font$get_info(msg = msg,
                                  font_num = current_font,
                                  font_info = font_info);
                }
            }

            field_index += num_chars;
        }
        else   /* a displayable char */
        {
            *char_index = field_index;
            value = TRUE;

            if ((text_string[field_index] == ESC) ||
                (font_info->flags & SIXTEEN_BIT))
            {
                field_index += 2;  /* ESC ESC, ESC LINEFEED, or 16 bit char */
            }
            else  /* regular 7 or 8 bit displayable char */
            {
                ++field_index;
            }
        }
    }
    return(value);
}
