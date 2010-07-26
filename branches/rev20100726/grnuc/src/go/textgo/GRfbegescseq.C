/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRfwd_beg_esc_seq
 
     Abstract:
                This routine moves forward in a text string searching for 
                an occurrence of one or more escape sequences.  It will
                also check for a specified number one character past the
                escape character if desired.  The index of the escape character
                beginning the first encountered specified escape sequence will
                be returned along with a TRUE return value.  If none of the
                specified escape sequences can be found, FALSE will be
                returned.
-----
%SC%

  VALUE = GRfwd_beg_esc_seq(msg,text_string,text_length,num_chars,esc_chars,
                            esc_nums,start_index,prev_font,current_font,
                            font_info,beg_esc)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ----------------------------------------
    *msg          IGRlong           completion code
    *text_string  IGRuchar          entire text string
    *text_length  IGRshort          length of text string
    *num_chars    IGRshort          number of characters to be searched for
                                    following the escape character
    *esc_chars    IGRchar           array of characters to be searched for
                                    following the escape character
    *esc_nums[]   IGRuchar          An array of pointers to numbers to be
                                    compared to the numbers after the
                                    corresponding esc_chars; a NULL pointer
                                    must be sent if no number comparisons
                                    are desired. If at least one number is
                                    to be compared, an array the same size
                                    as the esc_chars array must be sent.
                                    NULL pointers must be in positions where
                                    a number comparison isn't desired.
    *start_index  IGRshort          position in text string to begin search
    *prev_font    IGRshort          previous font at start_index
    *current_font IGRshort          current font at start_index
    *font_info    struct vfont_enrty font information at start_index
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
    *prev_font    IGRshort          previous font at beg_esc
    *current_font IGRshort          current font at beg_esc
    *font_info    struct vfont_enrty font information at beg_esc
    *beg_esc      IGRshort          index of escape character in the text
                                    string that begins the specified escape
                                    sequence
   VALUE (IGRlong) =    MSSUCC    - if successful
-----
%MD%

     MODULES INVOKED:    GRfwd_esc_seq:  move forward past escape sequence(s)

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
        
        WBC  02/06/86 : Design date.
        WBC  02/06/86 : Creation date.
        DEK  06/10/88 : Included 16-bit characters.
        WBC  01/03/89 : Added the font_info argument to support
                        8-bit fonts.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
----------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
----------------------------------------------------------------------
    This routine finds the index of the escape character that begins
the first escape sequence encountered that was specified in esc_chars.
----*/
/*EH*/

#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "msdef.h"
#include "grimport.h"
#include "OMmacros.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"

IGRshort GRfwd_beg_esc_seq(msg,text_string,text_length,num_chars,esc_chars,
                           esc_nums,start_index,prev_font,current_font,
                           font_info,beg_esc)

IGRlong             *msg;          /* completion code                        */
IGRuchar            *text_string;  /* entire text string                     */
IGRshort            *text_length;  /* length of text string                  */
IGRshort            *num_chars;    /* number of characters to be searched for*/
                                   /* following the escape character         */
IGRchar             *esc_chars;    /* array of characters to be searched for */
                                   /* following the escape character         */
IGRuchar            *esc_nums[];   /* An array of pointers to numbers to     */
                                   /* be compared to the numbers after the   */
                                   /* corresponding esc_chars; a NULL pointer*/
                                   /* must be sent if no number comparisons  */
                                   /* are desired. If at least one number is */
                                   /* to be compared, an array the same size */
                                   /* as the esc_chars array must be sent.   */
                                   /* NULL pointers must be in positions     */
                                   /* where a number comparison isn't        */
                                   /* desired.                               */
IGRshort            *start_index;  /* position in text string to begin search*/
IGRshort            *prev_font;    /* previous font at current position      */
IGRshort            *current_font; /* font at current position               */
struct vfont_entry  *font_info;    /* font information at current position   */
IGRshort            *beg_esc;      /* index of escape character in the text  */
                                   /* string that begins the specified escape*/
                                   /* sequence                               */
{
    extern IGRshort  GRfwd_esc_seq(); /* move forward past escape sequence(s)*/

    struct vfont_entry cur_font_info; /* current font information            */
    struct vfont_entry prev_font_info;/* current font information            */
    IGRboolean       value;        /* functional return value                */
    IGRboolean       multi_mode;   /* go past one or several escape sequences*/
    IGRboolean       have_prev_info;/* if previous font information is known */
    IGRshort         i,j;          /* index counters                         */
    IGRshort         esc_seq_chars;/* number of characters in the escape seq */
    IGRshort         temp_prev_font;
    IGRlong          temp_msg;     /* temporary return message               */
    IGRshort         temp_cur_font;/* storage font 'current' font            */

    *msg = MSSUCC;
    i = *start_index;
    value = FALSE;
    multi_mode = 0;  /* go past one escape sequence at a time */
    cur_font_info = *font_info;
    temp_prev_font = *prev_font;
    temp_cur_font = *current_font;
    have_prev_info = FALSE;

    /*
     *  search text string for specified escape sequence(s) until one is found
     *  or the end of the string is reached
     */

    while ((i + 1 < *text_length) && !value)
    {
        if (text_string[i] == ESC)  /* beginning of an escape sequence? */
        {
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
                         *  and a TRUE status.  Otherwise skip the escape
                         *  sequence and continue the search.
                         */

                        if ((esc_chars[j] == 'F') ||
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
                        else if (esc_chars[j] == 'f')
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

            if (!value)
            {
                /*
                 *  this escape sequence did not match any of the specified
                 *  one(s); skip over it and continue
                 */

                if (GRfwd_esc_seq(&temp_msg,text_string,text_length,
                                  &multi_mode,&i,&esc_seq_chars))
                {
                    /*
                     * if this is a change font escape sequence, must find the
                     * font type (7, 8 or 16 bit)
                     */

                    if (text_string[i + 1] == 'f')
                    {
                        temp_prev_font = temp_cur_font;
                        prev_font_info = cur_font_info;
                        have_prev_info = TRUE;

                        OM_BLOCK_MOVE(&(text_string[i + 2]),&temp_cur_font,2);

                        font$get_info(msg = &temp_msg,
                                      font_num = &temp_cur_font,
                                      font_info = &cur_font_info);
                    }
                    else if ((text_string[i + 1] == 'p') &&
                             (text_string[i + 2] & POP_FONT))
                    {

                        if (have_prev_info)
                        {
                            temp_cur_font = temp_prev_font;
                            cur_font_info = prev_font_info;
                        }
                        else if (temp_prev_font != -1)
                        {
                            font$get_info(msg = &temp_msg,
                                          font_num = &temp_prev_font,
                                          font_info = &cur_font_info);

                            temp_cur_font = temp_prev_font;
                            prev_font_info = cur_font_info;
                            have_prev_info = TRUE;
                        }
                    }

                    i += esc_seq_chars;
                }
                else
                {
                    i += 2; /* skip over the two consecutive escapes */
                }
            }
        }
        else  /* skip regular character and continue */
        {
            if (cur_font_info.flags & SIXTEEN_BIT)
            {
                i += 2;
            }
            else
            {
                ++i;
            }
        }
    }

    if (value)
    {
        *font_info = cur_font_info;
        *prev_font = temp_prev_font;
        *current_font = temp_cur_font;
    }

    return(value);
}
