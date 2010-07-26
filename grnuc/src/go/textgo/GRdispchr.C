/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME: GRdisplay_chars
 
     Abstract: 
        This routine determines what sub-string to display given a text string,
        a description of where to display from and to, the number of chars
        inserted into or deleted from the text string (not including
        justification move escape sequences), the current char info and a
        structure describing the sub-string that was erased.
-----
%SC%

     VALUE =  GRdisplay_chars(msg,text_string,text_length,display_from,
                              display_to,cc_index,display_index,chars_eol,
                              font_flags,flags,kern_value,text_info)
-----
%EN%
 
     ON ENTRY:

        NAME         DATA TYPE                   DESCRIPTION
     ----------   ---------------    -----------------------------------
     *msg           IGRlong          completion code
     *text_string   IGRuchar         text string to edit
     *text_length   IGRshort         length of the editted text string
     display_from   IGRint           description of where to display from
     display_to     IGRint           description of where to display to
     *cc_index      IGRshort         current char index
     *display_index IGRshort         index of char to begin display from
     *chars_eol     IGRshort         #chars from current char to the
                                     end of the current line (only
                                     applicable if display_to = END_CUR_LINE
     font_flags     IGRint           initial type of font
     *text_info     struct IGResintx text specific information about
                                     the sub-string to erase
     flags          short unsigned   flags member of the GRcc_info struct
                                     at the position of the char to display
     kern_value     IGRdouble        kerning pair value of the char to be
                                     displayed and the char that precedes it

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *text_info   struct IGResintx text specific information about
                                   the sub-string to erase

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES INVOKED: 

-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
        
        WBC  07/20/88 : Design date.
        WBC  07/20/88 : Creation date.
        WBC  11/14/89 : Added arguments flags and kern_value so that
                        the horizontal justification move could be
                        adjusted if a kerning pair is at the current
                        position.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine determines what sub-string to display given a text
string, a description of where to display from and to, the number
of chars inserted into or deleted from the text string (not
including justification move escape sequences), the current char
info and a structure describing the sub-string that was erased.
----*/
/*EH*/

#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "gotextdef.h"
#include "gotext.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "dp.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "ex.h"
#include "exmacros.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"

IGRint GRdisplay_chars(msg,text_string,text_length,display_from,display_to,
                       cc_index,display_index,chars_eol,font_flags,
                       flags,kern_value,text_info)

IGRlong          *msg;             /* informational message                  */
IGRuchar         *text_string;     /* editted text string                    */
IGRshort         *text_length;     /* length of the editted text string      */
IGRint           display_from;     /* description of where to display from   */
IGRint           display_to;       /* description of where to display to     */
IGRshort         *cc_index;        /* current char index                     */
IGRshort         *display_index;   /* index of char to begin display from    */
IGRshort         *chars_eol;       /* #chars from current char to the end of */
                                   /* the current line (only applicable if   */
                                   /* display_to = END_CUR_LINE              */
IGRint           font_flags;       /* initial font type                      */
short unsigned   flags;            /* flags member of the GRcc_info struct   */
                                   /* at the position of the char to display */
IGRdouble        kern_value;       /* kerning pair value of the char to be   */
                                   /* displayed and the char that precedes it*/
struct IGResintx *text_info;       /* text specific information              */

{
    IGRshort         beg_disp_index; /* index to begin displaying from       */
    IGRdouble        just_move;

    *msg = MSSUCC;
    beg_disp_index = 0;

    /*
     *  find the position in the text string to display from, the text
     *  attributes at that position and calculate and initalize the
     *  justification moves for the first char to display if necessary
     */

    switch (display_from)
    {
        case CURRENT_CHAR:
        case PREV_EDIT_CHAR:

            text_info->text_string = (IGRchar *)&text_string[*display_index];
            beg_disp_index = *display_index;
            kern_value = -kern_value;  /* negate previous kern value */

            if (flags & KERNING_PAIRS)
            {
                /*
                 * if the current char and the char that precedes it are 
                 * displayable, find their kerning pair value
                 */

                if ((flags & PREV_CHAR_DISP) &&
                    (text_string[*display_index] != ESC))
                {
                    extern IGRint   GRkern_pair_value();

                    struct vfont_entry font_info;
                    IGRdouble          current_kern_value;  /* kerning pair value */
                    IGRlong            temp_msg;

                    font$get_info(msg = &temp_msg,
                                  font_num = &text_info->estx->font,
                                  font_info = &font_info);

                    GRkern_pair_value(&temp_msg,
                                      &text_string[*display_index + ((font_info.flags & SIXTEEN_BIT) ? -2 : -1)],
                                      font_info.fontid,
                                      (font_info.flags & SIXTEEN_BIT),
                                       &current_kern_value);

                    kern_value += ((text_info->estx->width /
                                    (font_info.bodysize - font_info.descent)) *
                                    current_kern_value);
                }

                if (kern_value)
                {
                    IGRdouble    just_move;

                    /*
                     * the horizontal justification move must be adjusted to
                     * take into account the kerning pair; extract the current
                     * horizontal move value from text_info, add the kerning
                     * pair value and then insert the move value back into
                     * text_info
                     */

                    OM_BLOCK_MOVE(&text_info->just_moves[12],&just_move,8);
                    just_move += kern_value / text_info->estx->width;
                    OM_BLOCK_MOVE(&just_move,&text_info->just_moves[12],8);
                }
            }

            break;

        case BEGIN_CUR_LINE:
        case BEGIN_PREV_LINE:

            if (text_info->flags == 0x1)
            {
                text_info->text_string = 
                                   (IGRchar *)&text_string[*display_index];
                beg_disp_index = *display_index;

                /*
                 * need to find the line justification move of the first line
                 * being displayed
                 */

                GRline_just_move(msg,text_string,text_length,display_index,
                                 text_info->estx->width,font_flags,&just_move);

                just_move /= text_info->estx->width;
                OM_BLOCK_MOVE(&just_move,&text_info->just_moves[12],8);
            }
            else    /* display from the beginning of the string */
            {
                text_info->text_string = (IGRchar *)text_string;
                beg_disp_index = 0;
            }
            break;

        case BEGIN_STRING:

            text_info->text_string = (IGRchar *)text_string;
            beg_disp_index = 0;
            break;

        default:

#ifdef DEBUG
            printf("GRdisplay_chars: unknown erase_from type\n");
#endif
            break;
    }   /* end switch (*erase_from) */

    /*
     *  find the length of the text sub-string to display; the length of the
     *  sub-string to display is found by subtracting the index for the
     *  beginning of the sub-string from the index for the end of the
     *  sub-string
     */

    switch (display_to)
    {
        case END_CUR_LINE:

            text_info->estx->text_length =  (*cc_index - beg_disp_index) + *chars_eol;
            break;

        case END_STRING:

            text_info->estx->text_length = *text_length - beg_disp_index;
            break;

        case PREV_CHAR:

            text_info->estx->text_length = *cc_index - beg_disp_index;
            break;

        default:

#ifdef DEBUG
            printf("GRdisplay_chars: unknown erase_to type\n");
#endif
            break;
    }   /* end switch (*erase_to) */
    return(TRUE);
}
