/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRblock_text
 
     Abstract:  This routine takes a paragraph of text and creates a block
                of text - each line the same length except the last line.
                Character spacing and the spacing between words are adjusted
                on each line of text so the line is the specified length.
                The size of the characters is not altered.  The text is
                wrapped at blank characters when necessary.
-----
%SC%

     VALUE =  GRblock_text(msg,text_string,text_attr,lbsys
                           line_length,autowrap,word_space_factor)
-----
%EN%
 
     ON ENTRY:

        NAME           DATA TYPE                    DESCRIPTION
     -------------     --------------- -------------------------------------
     **text_string     IGRchar         text string
     *text_attr        struct IGRestx  text attributes
     *lbsys            struct IGRlbsys local bounded system of the text
     line_length       IGRdouble       desired length of the lines of text
     autowrap          IGRint          flag for autowrap: TRUE = autowrap
     word_space_factor IGRdouble       factor used to determine the amount
                                       of additional space on a line that is
                                       to be made up by word spacing (e.g a
                                       word spacing of 0.9 would imply
                                       ninety percent of the additional
                                       length would be word spacing while
                                       the remaining 10 percent would be
                                       character spacing); valid values are:
                                       0.0 >= word_space_factor <= 1.0
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------    -------------------------------------
     *msg         IGRlong          Completion code
                                     - MSSUCC if successful
                                     - MSFAIL (severe) if failure
     **text_string IGRchar         text string with necessary
                                   character spacing moves inserted
     text_attr     struct IGRlbsys number of bytes in the blocked
                                   text string (the text_length member
                                   of the structure is changed)

     VALUE (IGRint) = TRUE            - if successful
                      FALSE           - if failure
-----
%MD%

     MODULES INVOKED: 
                      FSGetTextVect
                      GRfind_esc_char
                      GResc_handler
                      GRswap_bytes
                      GRfwd_esc_seq
                      MAptsxform
                      MA2ptdis
-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
        
        WBC  07/21/89 : Design date.
        WBC  07/21/89 : Creation date.
        SCW  07/21/92 : Ansi conversion
        WBC  06/01/93 : Initialized members of the just_info struct to take
                        care of UMRs reported by Purify.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
    This routine takes a paragraph of text and creates a block of
text - each line the same length except the last line.  Character
spacing and the spacing between words are adjusted on each line of
text so the line is the specified length.  The size of the
characters is not altered.  The text is wrapped at blank characters
when necessary.
----*/
/*EH*/

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
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
#include "FS.h"
#include "FSOutl.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "dpdef.h"
#include "fontmacros.h"


#ifdef NEVER_DEF
#include "dpgraphics.h"
#endif


IGRint GRblock_text(msg,text_string,text_attr,lbsys,line_length,
                    autowrap,word_space_factor)

IGRlong              *msg;             /* completion code                    */
IGRuchar             **text_string;    /* text string                        */
struct IGRestx       *text_attr;       /* text attributes                    */
struct IGRlbsys      *lbsys;           /* text element's local bounded system*/
IGRdouble            line_length;      /* desired length of the lines of text*/
IGRint               autowrap;         /* flag for autowrap: TRUE = autowrap */
IGRdouble            word_space_factor;/* word spacing factor                */

{
    extern IGRboolean   GResc_handler();    /* processes escape sequences    */
    extern IGRboolean   GRswap_bytes();
    extern IGRshort     GRfind_esc_char();  /* finds next esc. seq. in string*/
    extern IGRshort     GRfwd_esc_seq();
    extern IGRboolean   MAptsxform();
    extern IGRboolean   MA2ptdis();

    struct just_info    just_info;          /* justification information     */
    struct IGRestx      cur_text_attr;      /* text specific attributes      */
    struct vfont_entry  cur_font_info;      /* current font information      */
    struct IGRdisplay   cur_disp_attr;      /* current display attributes    */
    struct extents      unjust_extents;     /* unjustified extents of string */
    IGRlong             temp_msg;           /* return code                   */
    IGRlong             num_points;         /* number of points to transform */
    IGRshort            num_chars;          /* number of consecutive         */
                                            /* non-escape characters         */
    IGRshort            begin_cur_line;     /* index of beginning of line    */
    IGRshort            begin_cur_word;     /* index of beginning of word    */
    IGRint              i, ii, j;           /* index counters                */
    IGRint              status;             /* return status                 */
    IGRint              text_buf_size;      /* # of bytes of memory allocated*/
                                            /* for the text string           */
    IGRint              word_separators;    /* number of word separators in  */
                                            /* the current line              */
    IGRint              offset;             /* offset from current position  */
    IGRdouble           x_coord, y_coord;   /* x and y coordinates of the    */
                                            /* end of the text sub-string    */
    IGRdouble           wk_origin[2];       /* current working origin        */
    IGRdouble           tmp_x_wk_origin;    /* temp x working origin         */
    IGRdouble           cur_line_length;    /* length of the current line not*/
                                            /* including last char spacing   */
    IGRdouble           cur_line_char_space;/* current line's width if each  */
                                            /* char was the active width     */
    IGRdouble           cur_line_last_cw;   /* current line's last char width*/
    IGRdouble           cur_line_last_ws;   /* current line's last white     */
                                            /* space                         */
    IGRdouble           prev_word_cs;       /* previous word's char spacing  */
    IGRdouble           base_line;          /* current base line             */
    IGRdouble           char_spacing_width; /* the additional width of a line*/
                                            /* if its character spacing were */
                                            /* increased by 1                */
    IGRdouble           white_cs_width;     /* width of white space chars if */
                                            /* they were each active width   */
    IGRdouble           char_spacing;       /* char spacing to insert into   */
                                            /* the text string               */
    IGRdouble           white_space;        /* width of consecutive blank    */
                                            /* (space) characters            */
    IGRdouble           last_char_width;    /* text width at the last char   */
                                            /* in the current word           */
    IGRdouble           char_space_percent; /* percent of the additional     */
                                            /* length to be supplied by the  */
                                            /* character spacing             */
    IGRdouble           addl_length;        /* additional length necessary to*/
                                            /* to make the current line the  */
                                            /* specified length              */
    IGRdouble           word_sep_width;     /* cumulative text widths at word*/
                                            /* separators position for the   */
                                            /* current line                  */
    IGRdouble           l_white_right;      /* white space to the left of a  */
                                            /* character                     */
    IGRdouble           x_scale;            /* scale from the local bounded  */
                                            /* system matrix                 */
    IGRdouble           points[6];          /* used to find the scale        */
    IGRuchar            *swapped_string;    /* pointer to 'swapped' chars    */
    CharId              last_char;          /* last char in a word           */
    IGRshort            prev_font;          /* font previously used in string*/
    IGRshort            *separator_array;
    IGRshort            array_size;
    IGRboolean          white_space_flag;
    IGRboolean          not_eol;            /* end of line flag              */
    IGRboolean          not_eos;            /* end of string flag            */
    IGRboolean          process_escape;
    IGRboolean          multi_mode;
    IGRboolean          consecutive_lf;

    /*
     * initialization
     */

    *msg = MSSUCC;
    wk_origin[0] = wk_origin[1] = 0.0;
    cur_text_attr = *text_attr;
    text_buf_size = text_attr->text_length;
    word_separators = 0;
    array_size = 50;
    white_cs_width = 0.0;
    cur_line_last_ws = 0.0;
    begin_cur_word = 0;
    cur_line_char_space = 0.0;
    white_space = 0.0;
    separator_array = (IGRshort *)om$malloc(size = (sizeof(IGRshort) * array_size));

    /*
     * get information about the text string's font
     */

    status = font$get_info(msg = &temp_msg,
                           font_num = &cur_text_attr.font,
                           font_info = &cur_font_info);

    if (! status && !(temp_msg & 1))
    {
        *msg = MSFAIL;
        return(FALSE);
    }

    /*
     * find the x scale of the local bounded system matrix; apply this scale
     * to the text's original text width
     */

    points[0] = 0.0;
    points[1] = 0.0;
    points[2] = 0.0;
    points[3] = 1.0;
    points[4] = 0.0;
    points[5] = 0.0;

    num_points = 2;

    MAptsxform(&temp_msg,&num_points,lbsys->matrix,points,points);
    MA2ptdis(&temp_msg,points,&points[3],&x_scale);

    cur_text_attr.width *= x_scale;

    /*
     * increment past any leading stroke start justification escape sequences
     */

    for (i = 0; (i < text_attr->text_length) && ((*text_string)[i] == ESC) && 
                (((*text_string)[i + 1] == 'J') || ((*text_string)[i + 1] == 'j')); i += 10);

    char_spacing_width = 0.0;
    cur_line_length = 0.0;
    word_sep_width = 0.0;
    last_char_width = 0.0;
    begin_cur_line = i;
    white_space_flag = TRUE;
    prev_word_cs = 0.0;
    cur_line_last_cw = 0.0;
    consecutive_lf = FALSE;
    not_eos = TRUE;

    while (not_eos)
    {
        not_eol = TRUE;

        while ((not_eol) &&
               (i < text_attr->text_length))
        {
            j = i;

            /*
             * find out if there are any consecutive blank (space) chars
             */

            for (num_chars = 0; ((*text_string)[j] == BLANK) &&
                                (j < text_attr->text_length); ++j, ++num_chars);

            if (!num_chars)
            {
                /*
                 * no blank chars were found; move past consecutive
                 * displayable chars, stopping at the first encountered
                 * blank or escape sequence
                 */

                while ((j < text_attr->text_length) &&
		       ((*text_string)[j] != ESC) &&
                       ((*text_string)[j] != BLANK) )
                {
                    if (! (cur_font_info.flags & SIXTEEN_BIT))
                    {
                        ++j;
                    }
                    else  /* sixteen bit character */
                    {
                        j += 2;
                    }
                    ++num_chars;
                }

                if (((*text_string)[i] == ESC) &&
                    ((*text_string)[i + 1] == ESC))
                {
                    /*
                     * two consecutive escape characters; only want to find
                     * the width of one
                     */

                    j += 2;
                    ++num_chars;
                }

                if (num_chars)
                {
                    /*
                     * find the white space of the last char on the line
                     */

                    if (! (cur_font_info.flags & SIXTEEN_BIT))
                    {
                        last_char = (CharId) (*text_string)[j - 1];
                    }
                    else  /* sixteen bit character */
                    {
                        last_char = (CharId) (((*text_string)[j - 2] << 8) +
                                              ((*text_string)[j - 1]));
                    }

                    GRchar_white_space(&temp_msg,last_char,
                                       &cur_font_info,NULL,&l_white_right);

                    l_white_right *= (cur_text_attr.width /
                                     (cur_font_info.bodysize -
                                      cur_font_info.descent));

                    if (white_space_flag)
                    {
                        /*
                         * if the white space flag had been set, must now
                         * be at the beginning of a word
                         */

                        begin_cur_word = i;
                        white_space_flag = FALSE;
                    }
                }
            }
            else  /* one or more consecutive blank chars found */
            {
                if (!white_space_flag)
                {
                    /*
                     * currently at a word separator (a blank) or at the
                     * end of the text string; save the position of the
                     * word separator
                     */

                    if (word_separators >= array_size)
                    {
                        array_size += 100;
                        separator_array = (IGRshort *)om$realloc(
                                              ptr = (IGRchar *)separator_array,
                                              size = (sizeof(IGRshort) 
                                                             * array_size));
                    }

                    separator_array[word_separators] = i;
                    word_sep_width += cur_text_attr.width;
                    ++word_separators;

                    /*
                     * we're at the end of a word, save the current line
                     * length
                     */

                    prev_word_cs = last_char_width * (text_attr->char_spac - 1.0);
                    cur_line_last_ws = l_white_right;
                    cur_line_length = wk_origin[0] - prev_word_cs - cur_line_last_ws;
                    cur_line_char_space = char_spacing_width - last_char_width;
                    cur_line_last_cw = last_char_width;
                    white_cs_width = 0.0;
                }
                white_cs_width += num_chars * cur_text_attr.width;
                white_space_flag = TRUE;
            }

            if (num_chars)
            {
                if (!(cur_font_info.flags & SIXTEEN_BIT))
                {
                    /*
                     * find the length of this seven or eight bit text
                     * sub-string; update the working origin of the text string
                     * according to the sub-string length, text width,
                     * font body size and character spacing
                     */
#ifdef NEVER_DEF
		{
		 Display         *display;
		 int             window;
		 GC              gc;

                 FSXGetTextVect(display, window, gc, cur_font_info.fontid,&(text_string[i]),
                               (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
		}
#else
                    FSGetTextVect(cur_font_info.fontid,&((*text_string)[i]),
                                  (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
#endif
                }
                else   /* characters are sixteen bit */
                {
                    /* 
                     *  swap the bytes in the string that is send to Font
                     *  Server because it expects ushorts if a
                     *  sixteen bit font
                     */

                    swapped_string = (IGRuchar *)om$malloc(size = (num_chars * 2));

                    GRswap_bytes(&temp_msg,&((*text_string)[i]),
                                 (num_chars * 2),swapped_string);

                    /*
                     *  find the length of this text sub-string; update the 
                     *  working origin of the text string according to the 
                     *  sub-string length, text width, font body size and 
                     *  character spacing
                     */

#ifdef NEVER_DEF
		{
		 Display         *display;
		 int             window;
		 GC              gc;

                 FSXGetTextVect(display, window, gc, cur_font_info.fontid,swapped_string,
                               (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
		}
#else
                    FSGetTextVect(cur_font_info.fontid,swapped_string,
                                  (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
#endif
                    om$dealloc(ptr = swapped_string);
                }

                wk_origin[0] += ((cur_text_attr.width /
                                            (cur_font_info.bodysize -
                                             cur_font_info.descent)) *
                                          x_coord) +
                                 (cur_text_attr.width *
                                  (text_attr->char_spac - 1.0) * num_chars);

                if (autowrap && white_space_flag)
                {
                    white_space = wk_origin[0] - cur_line_length - prev_word_cs - cur_line_last_ws;
                }
                char_spacing_width += num_chars * cur_text_attr.width;
                last_char_width = cur_text_attr.width;
                i = j;
            }
            else  /* process escape sequence */
            {
                process_escape = TRUE;

                if (autowrap)
                {
                    /*
                     * if this is a linefeed, replace it with a blank character
                     * since linefeeds will be inserted at the appropriate
                     * position determined by the specified line length - the
                     * blank is needed to seperate the words that the linefeed
                     * had seperated; if consecutive linefeeds are found,
                     * remove only the first one
                     */

                    if ((*text_string)[j + 1] == LINEFEED)
                    {
                        if ((j + 3 < text_attr->text_length) &&
                            ((*text_string)[j + 2] == ESC) &&
                            ((*text_string)[j + 3] == 'H'))
                        {
                            /*
                             * remove the linefeed and its justification
                             * escape sequence
                             */

                            num_chars = 12;
                        }
                        else  /* no justification esc seq */
                        {
                            num_chars = 2;
                        }

                        ii = j + num_chars;

                        /*
                         * if there are any consecutive linefeeds, skip past
                         * them and set a flag so the current line will be
                         * treated as the last line of a paragraph
                         */

                        consecutive_lf = FALSE;

                        while ((ii + 2 < text_attr->text_length) &&
                               ((*text_string)[ii] == ESC) &&
                               ((*text_string)[ii + 1] == LINEFEED))
                        {
                            ii += 2;
                            consecutive_lf = TRUE;

                            if ((ii + 2 < text_attr->text_length) &&
                                ((*text_string)[ii] == ESC) &&
                                ((*text_string)[ii + 1] == 'H'))
                            {
                                ii += 10;
                            }
                        }

                        if (consecutive_lf)
                        {
                            offset = 0;
                        }
                        else
                        {
                            offset = 1;
                            (*text_string)[j] = BLANK;
                        }

                        OM_BLOCK_MOVE(&((*text_string)[j + num_chars]),
                                      &((*text_string)[j + offset]),
                                      (IGRint)(text_attr->text_length - (j + num_chars)));

                        text_attr->text_length -= (num_chars - offset);

                        if (consecutive_lf)
                        {
                            /*
                             * currently at the end of a line since we want to
                             * start a new paragraph; increment past the
                             * consecutive escape sequences; make the current
                             * line length equal to the specified line length
                             * so the additional line length will be 0 since
                             * the current line is the last line of a paragraph
                             * and it shouldn't be expanded
                             */

                            not_eol = FALSE;
                            i = ii - num_chars;
                            cur_line_length = line_length;
                        }

                        process_escape = FALSE;
                    }
                    else if ((*text_string)[j + 1] == 'C')
                    {
                        /*
                         * remove any change character spacing escape sequences
                         */

                        OM_BLOCK_MOVE(&((*text_string)[j + 10]),
                                      &((*text_string)[j]),
                                      (IGRint)(text_attr->text_length - (j + 10)));

                        text_attr->text_length -= 10;
                        process_escape = FALSE;
                    }
                }
                else  /* autowrap is not on */
                {
                    if ((*text_string)[j + 1] == LINEFEED)
                    {
                        not_eol = FALSE;
                        process_escape = FALSE;

                        /*
                         * if the white space flag is not set, we want to use
                         * the current length as the length of the line,
                         * otherwise use cur_line_length which does not include
                         * the length of the white space that ends this line
                         */

                        if (!white_space_flag)
                        {
                            prev_word_cs = last_char_width * (text_attr->char_spac - 1.0);
                            cur_line_last_ws = l_white_right;
                            cur_line_length = wk_origin[0] - prev_word_cs - cur_line_last_ws;
                            cur_line_char_space = char_spacing_width - last_char_width;
                            cur_line_last_cw = last_char_width;
                        }
                        else
                        {
                            /*
                             * since we're not including the blanks at the end
                             * of the line, need to subtract the last word
                             * separator width and decrement the number of
                             * word separators
                             */

                            word_sep_width -= cur_text_attr.width;
                            --word_separators;
                        }

                        /*
                         * if the linefeed escape sequence is followed by
                         * a linefeed justification move, skip past it
                         */

                        if ((j + 2 < text_attr->text_length) &&
                            ((*text_string)[j + 2] == ESC) &&
                            ((*text_string)[j + 3] == 'H'))
                        {
                            i = j + 12;
                        }
                        else  /* only a linefeed */
                        {
                            i = j + 2;
                        }
                    }
                }

                if (process_escape)
                {
                    /*
                     * go process escape sequence, calculate working origin,
                     * change esc x and y scales if necessary; the index i
                     * will be incremented past the escape sequence (it will
                     * also be adjusted if the size of the text string changes)
                     */

                    ++i;
                    tmp_x_wk_origin = wk_origin[0];

                    /* initializing the structures just_info and unjust extents
                     * to take care of UMRs reported by Purify; the values
                     * returned are relative to the beginning of the escape
                     * sequence that is processed, i.e. the returned values
                     * are NOT relative to the beginning of the text string
                     */

                    just_info.num_lines = 1;
                    just_info.just_esc_pos = 0;
                    just_info.cur_line_left = just_info.cur_line_right = 0.0;

                    unjust_extents.right = unjust_extents.left = 0.0;
                    unjust_extents.bottom = -(cur_text_attr.height / 
                                              (cur_font_info.bodysize - cur_font_info.descent)) *
                                               cur_font_info.descent;
                    unjust_extents.base = 0.0;
                    unjust_extents.top = cur_text_attr.height - unjust_extents.bottom;
                    unjust_extents.cap = cur_text_attr.height;

                    GResc_handler(&temp_msg,*text_string,i,&cur_text_attr,
                                  wk_origin,&base_line,&cur_font_info,
                                  &prev_font,&cur_disp_attr,&just_info,
                                  &unjust_extents,&num_chars);

                    i += num_chars;  /* incrementing past escape sequence */
                    last_char_width = 0.0;

                    /*
                     * if the escape sequence changed the working origin in the
                     * x direction, do not want to substract the white space
                     * from the last displayable char
                     */

                    if (wk_origin[0] != tmp_x_wk_origin)
                    {
                        l_white_right = 0.0;
                    }
                }
            }

            if (autowrap)
            {
                /*
                 * if the cumulative length of the current line is
                 * greater than the specified length, must wrap the text at
                 * beginning of the current word (begin a new line of text) and
                 * expand the current line to be the specified length by
                 * inserting a change character spacing escape sequence at the
                 * beginning of the current line
                 */

                if ((!white_space_flag) &&
                    (cur_line_length) &&
                    ((wk_origin[0] - (last_char_width *
                     (text_attr->char_spac - 1.0))) > line_length))
                {
                    not_eol = FALSE;
                }
            }
            else if (i >= text_attr->text_length)
            {
                not_eol = FALSE;
                prev_word_cs = last_char_width * (text_attr->char_spac - 1.0);
                cur_line_last_ws = l_white_right;
                cur_line_length = wk_origin[0] - prev_word_cs - cur_line_last_ws;
                cur_line_char_space = char_spacing_width - last_char_width;
                cur_line_last_cw = last_char_width;
            }
        }

        if ((i < text_attr->text_length) ||
            (!not_eol))
        {
            addl_length = line_length - cur_line_length;

            if (!autowrap &&
                (i >= text_attr->text_length) &&
                (addl_length >= 0.0))
            {
                not_eos = FALSE;
                addl_length = 0.0;
                word_separators = 0;
            }
        }
        else
        {
            /*
             * at the end of the text string; the last line of text is not
             * expanded
             */

            addl_length = 0.0;
            word_separators = 0;
            not_eos = FALSE;
        }

        if (autowrap)
        {
            /*
             * word separators must be decremented by 1 since the last "word
             * separator" is not a word separator but the end of the current
             * line; also need to substract the char width associated with
             * the last word separators
             */

            --word_separators;
            word_sep_width -= cur_line_last_cw;
        }

        if ((word_separators) ||
            (cur_line_length <= line_length))
        {
            /*
             * insert horizontal moves between words on the line to
             * increase the length of the line the specified percent
             * of the length necessary to make the line the specified
             * length (the remainer of the additional length will be
             * supplied by character spacing)
             */

            char_spacing = ((addl_length * word_space_factor) /
                            word_separators) /
                            (word_sep_width / word_separators);

            if ((word_separators > 0) &&
                (char_spacing))
            {
                for (j = word_separators - 1; j >= 0; --j)
                {
                    if (text_attr->text_length + 10 > text_buf_size)
                    {
                        text_buf_size = text_attr->text_length + 10 + TEXT_BUF_SIZE;

                        *text_string = (IGRuchar *)om$realloc(
                                                 ptr = (IGRchar *) *text_string,
                                                 size = text_buf_size);
                    }

                    OM_BLOCK_MOVE(&((*text_string)[separator_array[j]]),
                                  &((*text_string)[separator_array[j] + 10]),
                                  (IGRint)(text_attr->text_length - separator_array[j]));

                    (*text_string)[separator_array[j]] = ESC;
                    (*text_string)[separator_array[j] + 1] = 'h';

                    OM_BLOCK_MOVE(&char_spacing,
                                  &((*text_string)[separator_array[j] + 2]),8);
                    text_attr->text_length += 10;
                    begin_cur_word += 10;
                    i += 10;
                }
            }

            /*
             * insert a character spacing escape sequence at the beginning
             * of the current line to increase the line's length; this
             * additional length plus that of the word spacing will make
             * the line the specified length
             */

            if (text_attr->text_length + 10 > text_buf_size)
            {
                text_buf_size = text_attr->text_length + 10 + TEXT_BUF_SIZE;

                *text_string = (IGRuchar *)om$realloc(
                                          ptr = (IGRchar *) *text_string,
                                          size = text_buf_size);
            }

            OM_BLOCK_MOVE(&((*text_string)[begin_cur_line]),
                          &((*text_string)[begin_cur_line + 10]),
                          (IGRint)(text_attr->text_length - begin_cur_line));

            /*
             * if there are one or more word separators (more than one
             * "word") on this line, the additional length to be added
             * to this line will be split between character spacing and
             * word spacing; if there's only one "word" on this line,
             * all the additional length will be supplied by character
             * spacing
             */

            if (word_separators > 0)
            {
                char_space_percent = 1.0 - word_space_factor;
            }
            else
            {
                char_space_percent = 1.0;
            }

            /*
             * the character spacing for the current line is determined
             * by the ratio:  length the current line is shorter than the
             * specified length to the length of the cumulative text widths
             * on the current line (character spacing is only applied 
             * between characters so the width of the last character on the
             * line must be subtracted); 1.0 must be added to char_spacing
             * since character spacing = 1.0 is equivalent to an
             * inter-character spacing of 0
             */

            if (cur_line_char_space)
            {
                char_spacing = ((addl_length * char_space_percent) /
                                cur_line_char_space) + text_attr->char_spac;
            }
            else  /* no word separators */
            {
                char_spacing = text_attr->char_spac;
            }

            (*text_string)[begin_cur_line] = ESC;
            (*text_string)[begin_cur_line + 1] = 'C';
            OM_BLOCK_MOVE(&char_spacing,
                          &((*text_string)[begin_cur_line + 2]),8);
            text_attr->text_length += 10;
            begin_cur_word += 10;
            i += 10;

            /*
             * at the end of the current line
             */

            if (autowrap)
            {
                if (not_eos)
                {
                    if (!consecutive_lf)
                    {
                        if (text_attr->text_length + 2 > text_buf_size)
                        {
                            text_buf_size = text_attr->text_length + 2 + TEXT_BUF_SIZE;

                            *text_string = (IGRuchar *)om$realloc(
                                                ptr = (IGRchar *) *text_string,
                                                size = text_buf_size);
                        }

                        if (white_space_flag)
                        {
                            /*
                             * if currently at some white space chars, must
                             * move past them to the beginning of the next word
                             */

                            multi_mode = FALSE;

                            while ((white_space_flag) &&
                                   (i < text_attr->text_length))
                            {
                                if ((*text_string)[i] == BLANK)
                                {
                                    ++i;
                                }
                                else if ((*text_string)[i] == ESC)
                                         
                                {
                                    if (((*text_string)[i + 1] == LINEFEED) ||
                                        ((*text_string)[i + 1] == 'H'))
                                    {
                                        /*
                                         * remove the linefeed escape sequence or
                                         * its justification move
                                         */

                                        if ((*text_string)[i + 1] == LINEFEED)
                                        {
                                            num_chars = 2;  /* # of chars to remove */
                                        }
                                        else  /* linefeed justification escape sequence */
                                        {
                                            num_chars = 12;  /* # of chars to remove */
                                        }

                                        OM_BLOCK_MOVE(&((*text_string)[i + num_chars]),
                                                      &((*text_string)[i]),
                                                      (IGRint)(text_attr->text_length - i - num_chars));
                                    }
                                    else
                                    {
                                        /*
                                         * go process escape sequence,
                                         * calculate working origin, change esc
                                         * x and y scales if necessary; the
                                         * index i will be incremented past the
                                         * escape sequence (it will also be
                                         * adjusted if the size of the text
                                         * string changes)
                                         */

                                        ++i;

                                        /* initializing the structures
                                         * just_info and unjust extents to
                                         * take care of UMRs reported by
                                         * Purify; the values returned are
                                         * relative to the beginning of the
                                         * escape sequence that is processed,
                                         * i.e. the returned values are NOT
                                         * relative to the beginning of the
                                         * text string
                                         */

                                        just_info.num_lines = 1;
                                        just_info.just_esc_pos = 0;
                                        just_info.cur_line_left = just_info.cur_line_right = 0.0;

                                        unjust_extents.right = unjust_extents.left = 0.0;
                                        unjust_extents.bottom = -(cur_text_attr.height / 
                                                                 (cur_font_info.bodysize - cur_font_info.descent)) *
                                                                  cur_font_info.descent;
                                        unjust_extents.base = 0.0;
                                        unjust_extents.top = cur_text_attr.height - unjust_extents.bottom;
                                        unjust_extents.cap = cur_text_attr.height;

                                        GResc_handler(&temp_msg,*text_string,i,
                                                      &cur_text_attr,wk_origin,
                                                      &base_line,&cur_font_info,
                                                      &prev_font,&cur_disp_attr,
                                                      &just_info,&unjust_extents,
                                                      &num_chars);

                                        i += num_chars;  /* incrementing past escape sequence */
                                    }
                                }
                                else
                                {
                                    white_space_flag = FALSE;
                                }
                            }

                            begin_cur_line = begin_cur_word = i;
                            wk_origin[0] = cur_line_length = prev_word_cs = white_space = 0;
                        }

                        /*
                         * wrap the text (insert a linefeed) at the beginning
                         * of the current word since the current word makes
                         * the line longer than the specified length
                         */

                        OM_BLOCK_MOVE(&((*text_string)[begin_cur_word]),
                                      &((*text_string)[begin_cur_word + 2]),
                                      (IGRint)(text_attr->text_length - begin_cur_word));

                        (*text_string)[begin_cur_word] = ESC;
                        (*text_string)[begin_cur_word + 1] = LINEFEED;
                        text_attr->text_length += 2;
                        wk_origin[0] -= cur_line_length + prev_word_cs + cur_line_last_ws + white_space;
                        char_spacing_width -= cur_line_char_space + cur_line_last_cw + white_cs_width;
                        begin_cur_line = begin_cur_word += 2;
                        i += 2;
                    }
                    else  /* consecutive linefeed chars */
                    {
                        consecutive_lf = FALSE;
                        wk_origin[0] = 0.0;
                        cur_line_length = 0.0;
                        cur_line_char_space = 0.0;
                        begin_cur_line = i;
                        char_spacing_width = 0.0;
                        white_space_flag = TRUE;
                    }
                }
            }
            else  /* no autowrap */
            {
                wk_origin[0] = 0.0;
                cur_line_length = 0.0;
                cur_line_char_space = 0.0;
                begin_cur_line = i;
                char_spacing_width = 0.0;
                white_space_flag = TRUE;
            }
            word_separators = 0;
            word_sep_width = 0.0;
        }
        else
        {
            /*
             * current word is longer than specified line length
             */

            *msg = MSINARG;
            return(FALSE);
        }
    }     /* end "while not_eos" */

    return(TRUE);
}
