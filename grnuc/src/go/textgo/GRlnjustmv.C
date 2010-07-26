/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRline_just_move
 
     Abstract:
                This routine moves backward in a text string searching for 
                the first occurrence of a linefeed escape sequence.  If one
                is found and it is followed by a linefeed justification move
                escape sequence, the length define by the justification moved
                will be returned.  This length is the justification move value
                multiplied by the text width at the justification esc sequence.
                If no linefeed justification escape sequence follows the
                linefeed escape sequence, zero will be returned as the
                justification move value.  If no linefeed escape sequence is
                found (current position is on the first line of the text
                string) and there is a horizontal stroke start escape sequence,
                its value will be returned as the justification move length.
                Otherwise a zero will be returned as the justification move
                value.
-----
%SC%

  VALUE = GRline_just_move(msg,text_string,text_length,start_index,
                           text_width,font_flags,line_just_move)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ----------------------------------------
    *msg          IGRlong           completion code
    *text_string  IGRuchar          entire text string
    *text_length  IGRshort          length of the text string (in bytes)
    *start_index  IGRshort          position in text string to begin search
    text_width    IGRdouble         text width at the start position
    font_flags    IGRint            indicates the text string's initial
                                    font type
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *line_just_move  IGRdouble     current line horizontal justification
                                  move value

   VALUE (IGRlong) =    MSSUCC    - if successful
-----
%MD%

     MODULES INVOKED:    GRbwd_beg_esc_seq:  find beginning of specified
                                             escape sequence(s)
-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
        
        WBC  07/15/88 : Design date.
        WBC  07/15/88 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
----------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
----------------------------------------------------------------------
   This routine moves backward in a text string searching for the
first occurrence of a linefeed escape sequence.  If one is found and
it is followed by a linefeed justification move escape sequence, the
justification move value will be returned.  If no linefeed
justification escape sequence follows the linefeed escape sequence,
zero will be returned as the justification move value.  If no linefeed
escape sequence is found (current position is on the first line of the
text string) and there is a horizontal stroke start escape sequence,
its value will be returned as the justification move value.
Otherwise a zero will be returned as the justification move value.
----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "msdef.h"
#include "OMmacros.h"

IGRint GRline_just_move(msg,text_string,text_length,start_index,
                        text_width,font_flags,line_just_move)

IGRlong             *msg;          /* completion code                        */
IGRuchar            *text_string;  /* entire text string                     */
IGRshort            *text_length;  /* length of the text string (in bytes)   */
IGRshort            *start_index;  /* position in text string to begin search*/
IGRdouble           text_width;    /* text width at the start position       */
IGRint              font_flags;    /* indicates the text string's initial    */
                                   /* font type                              */
IGRdouble           *line_just_move; /* previous linefeed justification move */

{
    extern IGRboolean GRbwd_beg_esc_seq();
                                   /* find beginning of specified escape seq */
    IGRchar          esc_chars[4]; /* characters to be searched for          */
    IGRshort         num_chars;    /* number of characters to search for     */
    IGRshort         beg_esc;      /* index of beginning of previous field   */
    IGRshort         index;
    IGRlong          temp_msg;     /* temporary return message               */
    IGRdouble        change_x_scale;

    *msg = MSSUCC;
    index = *start_index;
    num_chars = 4;
    esc_chars[0] = LINEFEED;  /* find previous linefeed escape sequence */
    esc_chars[1] = 'x';       /* find previous change text width        */
    esc_chars[2] = 's';       /* find previous change x and y scale     */
    esc_chars[3] = 'J';       /* find horizontal stroke start move      */
    *line_just_move = 0.0;

    if (index)
    {
        /*
         * index is not at the beginning of the text string; search backwards
         * through the text string for a linefeed escape sequence
         */

        while (GRbwd_beg_esc_seq(&temp_msg,text_string,&num_chars,esc_chars,
                                 NULL,&index,font_flags,&beg_esc))
        {
            if (text_string[beg_esc + 1] == LINEFEED)
            {
                /*
                 * determine if a linefeed justification move escape sequence
                 * follows the linefeed escape sequence
                 */

                if ((text_string[beg_esc + 2] == ESC) &&
                    (text_string[beg_esc + 3] == 'H'))
                {
                    OM_BLOCK_MOVE(&text_string[beg_esc + 4],line_just_move,8);
                    *line_just_move *= text_width;
                }
                break;
            }
            else if ((text_string[beg_esc + 1] == 'x') ||
                     (text_string[beg_esc + 1] == 's'))
            {
                OM_BLOCK_MOVE(&text_string[beg_esc + 2],&change_x_scale,8);
                text_width /= change_x_scale;
                index = beg_esc;
            }
            else  /* stroke start horizontal justification move */
            {
                OM_BLOCK_MOVE(&text_string[beg_esc + 2],line_just_move,8);
                *line_just_move *= text_width;
                break;
            }
        }
    }
    else
    {
        /*
         * the index is at the beginning of the text string; if this string has
         * a horizontal stroke start move, it is the line justification move
         */

        if ((*text_length > 9) &&
            (text_string[0] == ESC))
        {
            if (text_string[1] == 'J')
            {
                OM_BLOCK_MOVE(&text_string[2],line_just_move,8);
                *line_just_move *= text_width;
            }
            else if (text_string[1] == 'j')
            {
                if ((*text_length > 19) &&
                    (text_string[10] == ESC) &&
                    (text_string[11] == 'J'))
                {
                    OM_BLOCK_MOVE(&text_string[12],line_just_move,8);
                    *line_just_move *= text_width;
                }
            }
        }
    }
    return(TRUE);
}
