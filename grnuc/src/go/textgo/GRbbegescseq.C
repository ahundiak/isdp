/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRbwd_beg_esc_seq
 
     Abstract:
                This routine moves forward from the beginning of a text string
                searching for  an occurrence of one or more escape sequences.
                It will also check for a specified number one character past
                the escape character if desired.  The index of the escape
                character beginning the last encountered specified escape
                sequence before the specified index will be returned along with
                a TRUE return value.  If none of the specified escape sequences
                can be found, FALSE will be returned.
-----
%SC%

  VALUE = GRbwd_beg_esc_seq(msg,text_string,num_chars,esc_chars,
                            esc_nums,end_index,font_flags,beg_esc)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ----------------------------------------
    *msg          IGRlong           completion code
    *text_string  IGRuchar          entire text string
    *num_chars    IGRshort          number of characters to be searched for
                                    following the escape character
    *esc_chars    IGRchar           array of characters to be searched for
                                    following the escape character
    *esc_nums[]   IGRchar           An array of pointers to numbers to be
                                    compared to the numbers after the
                                    corresponding esc_chars; a NULL pointer
                                    must be sent if no number comparisons
                                    are desired. If at least one number is
                                    to be compared, an array the same size
                                    as the esc_chars array must be sent.
                                    NULL pointers must be in positions where
                                    a number comparison isn't desired.
    *end_index    IGRshort          position in text string to search to
    font_flags    IGRint            indicates the text string's initial
                                    font type
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
    *beg_esc      IGRshort          index of escape character in the text
                                    string that begins the specified escape
                                    sequence
   VALUE (IGRlong) =    MSSUCC    - if successful
-----
%MD%

     MODULES INVOKED:    GRfwd_esc_seq:  move forward over escape sequence(s)

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:    The pointer to esc_nums must be NULL if no number comparisons
               are desired.  If at least one number comparison is to be made,
               an array of pointers to numbers the same size as the esc_chars
               array must be sent.  NULL pointers must be in the array at
               positions where number comparisons are not desired.
-----

%CH%
     CHANGE HISTORY:
        
        WBC  02/13/86 : Design date.
        WBC  02/13/86 : Creation date.
        WBC  08/22/88 : Updated to move forward from the beginning of the
                        string to the specified index (instead of moving
                        backward through the string).
        WBC  01/03/89 : Added the font_flags argument to support
                        8-bit fonts.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
----------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
----------------------------------------------------------------------
   This routine moves forward from the beginning of a text string
searching for  an occurrence of one or more escape sequences.
It will also check for a specified number one character past
the escape character if desired.  The index of the escape
character beginning the last encountered specified escape
sequence before the specified index will be returned along with
a TRUE return value.  If none of the specified escape sequences
can be found, FALSE will be returned.
----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "fontdef.h"
#include "font.h"
#include "gotextdef.h"
#include "msdef.h"
#include "OMmacros.h"
#include "fontmacros.h"

IGRshort GRbwd_beg_esc_seq(msg,text_string,num_chars,esc_chars,
                           esc_nums,end_index,font_flags,beg_esc)

IGRlong             *msg;          /* completion code                        */
IGRuchar            *text_string;  /* entire text string                     */
IGRshort            *num_chars;    /* number of characters to be searched for*/
                                   /* following the escape character         */
IGRchar             *esc_chars;    /* array of characters to be searched for */
                                   /* following the escape character         */
IGRchar             *esc_nums[];   /* An array of pointers to numbers to     */
                                   /* be compared to the numbers after the   */
                                   /* corresponding esc_chars; a NULL pointer*/
                                   /* must be sent if no number comparisons  */
                                   /* are desired. If at least one number is */
                                   /* to be compared, an array the same size */
                                   /* as the esc_chars array must be sent.   */
                                   /* NULL pointers must be in positions     */
                                   /* where a number comparison isn't        */
                                   /* desired.                               */
IGRshort            *end_index;    /* position in text string to search to   */
IGRint              font_flags;    /* indicates the text string's initial    */
                                   /* font type                              */
IGRshort            *beg_esc;      /* index of escape character in the text  */
                                   /* string that begins the specified escape*/
                                   /* sequence                               */
{
    extern IGRshort  GRfwd_esc_seq();/* move forward over an escape sequence */

    struct vfont_entry font_info;  /* current font information               */
    IGRboolean       value;        /* functional return value                */
    IGRboolean       multi_mode;   /* go past one or several escape sequences*/
    IGRshort         i,j;          /* index counters                         */
    IGRshort         esc_seq_chars;/* number of characters in the escape seq */
    IGRshort         s_hold;       /* used to store a short from the string  */
    IGRlong          temp_msg;     /* temporary return message               */
    IGRint           prev_font_flags; /* previous font type (before the last */
                                      /* change font escape sequence         */

    *msg = MSSUCC;
    i = 0;
    value = FALSE;
    multi_mode = FALSE;  /* go past one escape sequence at a time */
    prev_font_flags = font_flags;

    /*
     * search text string for specified escape sequence(s); if one is found,
     * save its position and keep searching forward until the end_index is
     * reached
     */

    while (i < *end_index)
    {
        if (text_string[i] == ESC)
        {
            /*
             *  Is this a specified escape sequence?
             */

            for (j = 0; j < *num_chars; ++j)
            {
                if (text_string[i + 1] == esc_chars[j])
                {
                    /*
                     *  Correct type of escape sequence has been found; is a
                     *  number comparison desired?  If not, return the index
                     *  of the ESC character and a TRUE status.
                     */

                    if (esc_nums && esc_nums[j])
                    {
                        /*
                         *  A number comparison has been requested; must
                         *  compare the correct type of numbers.  If the user
                         *  specified number and the number in the text string
                         *  are equal, return the index of the ESC character
                         *  and a TRUE status.  Otherwise move forward over
                         *  the escape sequence and continue the search.
                         */

                        if ((esc_chars[j] == 'F') ||
                            (esc_chars[j] == 'w') ||
                            (esc_chars[j] == 'M') ||
                            (esc_chars[j] == 'm'))
                        {
                            if ((IGRuchar)text_string[i + 2] == (IGRuchar)*(esc_nums[j]))
                            {
                                *beg_esc = i;
                                value = TRUE;
                                break;
                            }
                        }
                        else if ((esc_chars[j] == 'f') ||
                                 (esc_chars[j] == 'c'))
                        {
                            if ((IGRushort)text_string[i + 2] == (IGRushort)*(esc_nums[j]))
                            {
                                *beg_esc = i;
                                value = TRUE;
                                break;
                            }
                        }
                        else if ((esc_chars[j] == 'h') ||
                                 (esc_chars[j] == 'v') ||
                                 (esc_chars[j] == 's') ||
                                 (esc_chars[j] == 'x') ||
                                 (esc_chars[j] == 'y'))
                        {
                            if ((IGRdouble)text_string[i + 2] == (IGRdouble)*(esc_nums[j]))
                            {
                                *beg_esc = i;
                                value = TRUE;
                                break;
                            }
                        }
                        else  /* unknown escape sequence */
                        {
                            *msg = MSINARG;
                            break;
                        }
                    }
                    else  /* number comparison not requested */
                    {
                        *beg_esc = i;
                        value = TRUE;
                        break;
                    }
                }  /* end if correct ESC sequence */
            }  /* end for loop */

            if (GRfwd_esc_seq(&temp_msg,text_string,end_index,&multi_mode,
                              &i,&esc_seq_chars))
            {
                /*
                 * if this is a change font or pop font escape sequence,
                 * must find the font type (7, 8 or 16 bit)
                 */

                if (text_string[i + 1] == 'f')
                {
                    OM_BLOCK_MOVE(&(text_string[i + 2]),&s_hold,2);

                    font$get_info(msg = &temp_msg,
                                  font_num = &s_hold,
                                  font_info = &font_info);

                    prev_font_flags = font_flags;
                    font_flags = font_info.flags;
                }
                else if ((text_string[i + 1] == 'p') &&
                         (text_string[i + 2] & POP_FONT))
                {
                    font_flags = prev_font_flags;
                }

                i += esc_seq_chars;  /* move past esacpe sequence */
            }
            else  /* either an ESC ESC or an ESC LINEFEED */
            {
                i += 2;
            }
        }
        else  /* move forward over regular character and continue */
        {
            if (font_flags & SIXTEEN_BIT)
            {
                i += 2;
            }
            else
            {
                ++i;
            }
        }
    }  /* end "while (i < *end_index)" */
    return(value);
}
