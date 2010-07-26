/* #######################    APOGEE COMPILED   ######################## */



/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRchar_pos_info
 
     Abstract:
                This routine returns the position information of the
           specified char.  If the position information of the current char
           is known and the index of the current char is less than the index
           of specified char, this routine moves forward from the current char
           to the specified char updating the position information;  otherwise
           it moves from the beginning of the text string to the specified
           char.
-----
%SC%

  VALUE = GRchar_pos_info(msg,text_string,index,info_flag,
                          text_attr,font_info,disp_attr,cc_info)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ----------------------------------------
    *msg          IGRlong           completion code
    *text_string  IGRuchar          entire text string
    index         IGRshort          index of char to return position
                                    info about
    info_flag     IGRint            TRUE if struct GRcc_info is initialized,
                                    FALSE otherwise
    *text_attr    struct IGRestx    text specific attributes
    *font_info    struct vfont_entry info about the text string's active font
    *disp_attr    struct IGRdisplay display attributes
    *cc_info      struct GRcc_info  current char info
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *cc_info       struct GRcc_info  info about the specified char

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
        DEK  09/09/88 : Added display attributes.
        SCW  07/21/92 : Ansi conversion
        WBC  06/01/93 : Initialized members of the just_info struct to take
                        care of UMRs reported by Purify.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine returns the position information of the
specified char.  If the position information of the current char
is known and the index of the current char is less than the index
of specified char, this routine moves forward from the current char
to the specified char updating the position information;  otherwise
it moves from the beginning of the text string to the specified char.
----*/
/*EH*/

#include "grimport.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gotextdef.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "gotext.h"
#include "dpdef.h"
#include "FSOutl.h"

#ifdef NEVER_DEF
#include "dpgraphics.h"
#endif

#define  BEGIN_FIELD  0
#define  END_FIELD    1
#define  DISP_CHAR    2
#define  LF_CHAR      3

#define FIELD_FIXED_LENGTH 0x2

#argsused
IGRint GRchar_pos_info(msg,text_string,index,info_flag,
                       text_attr,font_info,disp_attr,cc_info)

IGRlong             *msg;         /* completion code                         */
IGRuchar            *text_string; /* entire text string                      */
IGRshort            index;        /* index of char to return position info   */
                                  /* about                                   */
IGRint              info_flag;    /* TRUE if struct GRcc_info is initialized,*/
                                  /* FALSE otherwise                         */
struct IGRestx      *text_attr;   /* text specific attributes                */
struct vfont_entry  *font_info;   /* info about the text string's active font*/
struct IGRdisplay   *disp_attr;   /* display attributes                      */
struct GRcc_info    *cc_info;     /* current char info                       */

{
    extern IGRshort GRfwd_esc_seq();     /* move forward over             */
                                         /* an escape sequence            */
    extern IGRint   GRkern_pair_value();

    struct just_info just_info;          /* justification information     */
    struct extents   unjust_extents;     /* unjustified extents of string */
    IGRboolean       multi_mode;         /* skip single or multiple       */
                                         /* escape sequence?              */
    IGRlong          temp_msg;           /* return message                */
    IGRdouble        x_coord, y_coord;   /* x and y coordinates of the    */
                                         /* end of the text sub-string    */
    IGRdouble        kern_value;         /* kerning pair value            */
    IGRshort         i;                  /* index counter                 */
    IGRshort         num_chars;          /* number of consecutive         */
                                         /* non-escape characters         */
    IGRshort         prev_char;          /* type of previous char         */
    IGRshort         begin_field[257];   /* indices of beginning of fields*/
    IGRuchar         start_delim;        /* original field depth          */
    IGRuchar         fixed_length_delim; /* depth of the outermost fixed  */
                                         /* length field                  */
    IGRuchar         justified_delim;    /* depth of the outermost        */
                                         /* justified field               */
    IGRuchar         *swapped_string;    /* pointer to 'swapped' chars    */


    prev_char = 0;
    /*
     * if struct GRcc_info has not been initialized or the current char index
     * is is greater than specified char index, initialize struct GRcc_info 
     * with values at the beginning of the text string (cannot move backward
     * in a text string because of escape sequences)
     */

    if ((!info_flag) ||
        (cc_info->cur_char_index > index))
    {
        info_flag = FALSE;
        cc_info->text_attr = *text_attr;
        cc_info->disp_attr = *disp_attr;
        cc_info->font_info = *font_info;
        cc_info->cur_line = 1;
        cc_info->cur_user_pos = 1;
        cc_info->cur_char_index = 0;
        cc_info->flags = 0;
        cc_info->field_delim = 0;
        cc_info->wk_origin[0] = 0.0;
        cc_info->wk_origin[1] = 0.0;
        cc_info->base_line = 0.0;
        cc_info->line_just_move = 0.0;
        cc_info->prev_font = -1;
        cc_info->kern_value = 0.0;

        /*
         * find the vertical stroke start move of the text string; if the
         * text string's length is greater than zero use the vertical stroke
         * start move in the text string (if it has one); otherwise need to
         * justify a dummy string with one char in it that has the same
         * attributes as the text string and use its vertical stroke start
         * move - this is necessary since an empty text string would have a
         * vertical stroke start move of zero, which is not correct for a
         * text string that has a non-base vertical justification
         */

        if (text_attr->text_length)
        {
            GRvertical_ss_move(&temp_msg,text_string,&text_attr->text_length,
                               text_attr->height,&cc_info->ss_v_move);
        }
        else
        {
            IGRuchar temp_string[2];

            /*
             *  use two chars in case the current font is a 16-bit font
             */

            temp_string[0] = BLANK;
            temp_string[1] = BLANK;
            text_attr->text_length = 2;

            GRtx_extents(&temp_msg,temp_string,&text_attr->text_length,
                         font_info,disp_attr,text_attr->char_spac,
                         text_attr->line_spac,text_attr->width,
                         text_attr->height,text_attr->font,0,0,
                         &unjust_extents);

            GRvertical_just_mv(&temp_msg,text_attr->just,text_attr->height,
                               &unjust_extents,&cc_info->ss_v_move);

            /*
             * scale the move value using text height; also must negate the
             * move since stroke start vertical moves and "regular" vertical
             * moves move in opposite directions
             */

            cc_info->ss_v_move *= -(text_attr->height);
            text_attr->text_length = 0;
        }
    }
    else
    {
        begin_field[cc_info->field_delim] = cc_info->field_position;

        if (cc_info->cur_char_index < index)
        {
            /*
             * a character has been inserted; must substract the kerning pair
             * value of the characters that were previously adjacent to the
             * current position; if the current position is between two
             * displayable characters and the current font has kerning pair
             * mode turned on, find the kerning pair value of the adjacent
             * characters and add it to the working origin
             */

            cc_info->wk_origin[0] -= cc_info->kern_value;
            cc_info->kern_value = 0.0;

            if ((cc_info->flags & PREV_CHAR_DISP) &&
                (text_string[cc_info->cur_char_index] != ESC))
            {
                GRkern_pair_value(&temp_msg,
                                  &text_string[cc_info->cur_char_index + ((cc_info->font_info.flags & SIXTEEN_BIT) ? -2 : -1)],
                                  cc_info->font_info.fontid,
                                  (cc_info->font_info.flags & SIXTEEN_BIT),
                                   &kern_value);

                if ((temp_msg & 1) &&
                    kern_value)
                {
                    cc_info->kern_value = ((cc_info->text_attr.width /
                                           (cc_info->font_info.bodysize -
                                            cc_info->font_info.descent)) *
                                            kern_value);

                    cc_info->wk_origin[0] += cc_info->kern_value;
                }
            }
        }
    }

    i = cc_info->cur_char_index;

    if (i < index)
    {
        start_delim = cc_info->field_delim;
        fixed_length_delim = 1;
        justified_delim = 1;
        multi_mode = FALSE;

        while (i < index)
        {
            /*
             *  find the number of consecutive non-escape characters
             */

            GRfind_esc_char(&temp_msg,&text_string[i],index - i,
                            cc_info->font_info.flags,&num_chars);

            if (num_chars)
            {
                if (!(cc_info->font_info.flags & SIXTEEN_BIT))
                {
                    /*
                     *  find the length of this seven bit text sub-string;
                     *  update the working origin of the text string 
                     *  according to the sub-string length, text width,
                     *  font body size and character spacing
                     */
#ifdef NEVER_DEF
		{
		    Display	*display;
		    int		window;
		    GC		gc;
		
                    FSXGetTextVect(display,window,gc,cc_info->font_info.fontid,&text_string[i],
                                  (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
		}
#else		
                    FSGetTextVect(cc_info->font_info.fontid,&text_string[i],
                                  (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
#endif
                }
                else   /* characters are sixteen bit */
                {
                    /* 
                     *  swap the bytes in the string that is send to Font
                     *  Server because it expects unsigned shorts if a
                     *  sixteen bit font
                     */

                    swapped_string = (IGRuchar *)om$malloc(size = (num_chars * 2));

                    GRswap_bytes(&temp_msg,&text_string[i],
                                 (num_chars * 2),swapped_string);

                    /*
                     *  find the length of this text sub-string; update the 
                     *  working origin of the text string according to the 
                     *  sub-string length, text width, font body size and 
                     *  character spacing
                     */

#ifdef NEVER_DEF
		{
		    Display	*display;
		    int		window;
		    GC		gc;

		    FSXGetTextVect(display,window,gc,cc_info->font_info.fontid,swapped_string,
                                 (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
		}
#else
		    FSGetTextVect(cc_info->font_info.fontid,swapped_string,
                                 (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
#endif
                    om$dealloc (ptr = swapped_string);
                }

                cc_info->wk_origin[0] += ((cc_info->text_attr.width /
                                          (cc_info->font_info.bodysize -
                                           cc_info->font_info.descent)) *
                                          x_coord) +
                                         cc_info->text_attr.width *
                                         (cc_info->text_attr.char_spac - 1.0) *
                                         num_chars;

                i += num_chars * (((cc_info->font_info.flags & SIXTEEN_BIT) >> 3) + 1);;

                if (temp_msg == ESCAPE_TYPE)
                {
                    /*
                     * the last character in the sub-string is an escape (two
                     * consecutive escape chars); only the first one was
                     * included in num_chars since we only want the width of
                     * one, so we need to increment past the second escape char
                     */

                    ++i;
                    cc_info->flags &= ~PREV_CHAR_DISP;
                }
                else
                {
                    /*
                     * since this flag is used to decide if it's necessary to
                     * search for a kerning pair, an escape character is not
                     * considered a displayable character because the calls to
                     * Font Server that send in a text string will never have
                     * an escape character in the middle of the string - the
                     * string is always broken at escape characters - so
                     * kerning (pairs) will not apply to escape characters
                     */

                    cc_info->flags |= PREV_CHAR_DISP;
                }

                cc_info->cur_user_pos += num_chars;
                prev_char = DISP_CHAR;
            }
            else  /* at an escape sequence */
            {
                /*
                 *  go process escape sequence, calculate working origin,
                 *  change esc x and y scales if necessary
                 */

                ++i;    /* skip the escape character */

                /* initializing the structures just_info and unjust extents
                 * to take care of UMRs reported by Purify; the values returned
                 * are relative to the beginning of the escape sequence that
                 * is processed, i.e. the returned values are NOT relative to
                 * the beginning of the text string
                 */

                just_info.num_lines = 1;
                just_info.just_esc_pos = 0;
                just_info.cur_line_left = just_info.cur_line_right = 0.0;

                unjust_extents.right = unjust_extents.left = 0.0;
                unjust_extents.bottom = -(cc_info->text_attr.height / 
                                          (cc_info->font_info.bodysize - cc_info->font_info.descent)) *
                                           cc_info->font_info.descent;
                unjust_extents.base = 0.0;
                unjust_extents.top = cc_info->text_attr.height - unjust_extents.bottom;
                unjust_extents.cap = cc_info->text_attr.height;

                GResc_handler(&temp_msg,text_string,i,&cc_info->text_attr,
                              cc_info->wk_origin,&cc_info->base_line,
                              &cc_info->font_info,&cc_info->prev_font,
                              &cc_info->disp_attr,&just_info,
                              &unjust_extents,&num_chars);

                /*
                 *  update the linefeed justification move value if moving
                 *  past a linefeed escape sequence
                 */

                if (text_string[i] == LINEFEED)
                {
                    ++cc_info->cur_line;
                    cc_info->cur_user_pos = 1;
                    cc_info->line_just_move = 0.0;
                    prev_char = LF_CHAR;
                }
                else if ((text_string[i] == 'H') ||
                         (text_string[i] == 'J'))
                {
                    OM_BLOCK_MOVE(&text_string[i + 1],
                                  &cc_info->line_just_move,8);
                    cc_info->line_just_move *= cc_info->text_attr.width;
                }
                else if (text_string[i] == 'F')
                {
                    ++cc_info->field_delim;
                    begin_field[cc_info->field_delim] = i - 1;
                    cc_info->field_position = i - 1;
                    prev_char = BEGIN_FIELD;

                    /*
                     * if the current field is fixed length and it is not
                     * nested in another fixed length field, set the flags bit
                     * indicating we're in a fixed length field and record
                     * which field delimiter begins the outermost fixed length
                     * field
                     */

                    if ((text_string[i + 2] & FIELD_FIXED_LENGTH) &&
                        !(cc_info->flags & FIXED_LENGTH_FIELD))
                    {
                        cc_info->flags |= FIXED_LENGTH_FIELD;
                        fixed_length_delim = cc_info->field_delim;
                    }
                }
                else if (text_string[i] == 'E')
                {
                    /*
                     * if moving out of the outermost fixed length field,
                     * clear the fixed length field bit
                     */

                    if ((cc_info->flags & FIXED_LENGTH_FIELD) &&
                        (fixed_length_delim == cc_info->field_delim))
                    {
                        cc_info->flags &= ~FIXED_LENGTH_FIELD;
                    }

                    /*
                     * if moving out of the outermost justified field,
                     * clear the justified field bit
                     */

                    if ((cc_info->flags & JUSTIFIED_FIELD) &&
                        (justified_delim == cc_info->field_delim))
                    {
                        cc_info->flags &= ~JUSTIFIED_FIELD;
                    }
                    --cc_info->field_delim;
                    cc_info->field_position = begin_field[cc_info->field_delim];
                    prev_char = END_FIELD;

                    /*
                     * if not in a field anymore, reset start_delim to 0 since
                     * the original start_delim value does not apply now that
                     * we have moved outside all fields we were originally
                     * nested in
                     */

                    if (!cc_info->field_delim)
                    {
                        start_delim = 0;
                    }
                }
                else if (text_string[i] == 'm')  /* justified field */
                {
                    /*
                     * we are in a justified field; if it is not nested
                     * in another justified field, set the flags bit
                     * indicating we're in a justified field and record
                     * which field delimiter begins the outermost justified
                     * field
                     */

                    if (!(cc_info->flags & JUSTIFIED_FIELD))
                    {
                        cc_info->flags |= JUSTIFIED_FIELD;
                        justified_delim = cc_info->field_delim;
                    }
                }
                i += num_chars;   /* incrementing past the escape sequence */
                cc_info->flags &= ~PREV_CHAR_DISP; /* char is not displayable*/
            }
        }     /* end "while (i < index)" */
        cc_info->cur_char_index = i;

        /*
         * if we did not start at the beginning of the text string and the
         * current index is within a field and we are not nested as deep as
         * where we began in the string, the index of the beginning of the
         * current field must be found; must start at the beginning of the
         * string and move to the current index to find this information
         */

        if ((info_flag) &&
            (cc_info->field_delim) &&
            (cc_info->field_delim < start_delim))
        {
            GRchar_pos_info(&temp_msg,text_string,cc_info->cur_char_index,
                            FALSE,text_attr,font_info,disp_attr,cc_info);
        }

        /*
         * set the empty field bit if current position in in an empty field;
         * clear it otherwise
         */

        if ((prev_char == BEGIN_FIELD) &&
            (text_string[i] == ESC) &&
            (text_string[i + 1] == 'E'))
        {
            cc_info->flags |= EMPTY_FIELD;
        }
        else  /* current position is not in an empty field */
        {
            cc_info->flags &= ~EMPTY_FIELD;
        }

        /*
         * if the current position is between two displayable chars and the
         * current font has kerning pair mode turned on, find the kerning pair
         * value of the chars adjacent to the current position and ajust the
         * working origin
         */

        cc_info->flags |= KERNING_PAIRS;
        cc_info->kern_value = 0.0;

        if ((cc_info->flags & PREV_CHAR_DISP) &&
            (cc_info->cur_char_index < text_attr->text_length) &&
            (text_string[cc_info->cur_char_index] != ESC))
        {
            GRkern_pair_value(&temp_msg,
                              &text_string[cc_info->cur_char_index + ((cc_info->font_info.flags & SIXTEEN_BIT) ? -2 : -1)],
                              cc_info->font_info.fontid,
                              (cc_info->font_info.flags & SIXTEEN_BIT),
                               &kern_value);

            if ((temp_msg & 1) &&
                kern_value)
            {
                cc_info->kern_value = ((cc_info->text_attr.width /
                                        (cc_info->font_info.bodysize -
                                         cc_info->font_info.descent)) *
                                        kern_value);

                cc_info->wk_origin[0] += cc_info->kern_value;
            }
            else if (temp_msg == MSINARG)
            {
                cc_info->flags &= ~KERNING_PAIRS;
            }
        }
    }  /* end if (i < index) */

    return(TRUE);
}
