/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRjust_string
 
     Abstract:  This routine returns the justified top, bottom, right, left,
                cap, and base extents of a text string.  It also inserts
                the necessary justification moves into the text string.
                The text buffer will be enlarged if necessary.
-----
%SC%

     VALUE =  GRjust_string(msg,text_string,text_length,text_buf_size,
                             font_info,disp_attr,text_symb,num_positions,
                             positions,text_extents)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                   DESCRIPTION
     ----------   ------------     -------------------------------------
     **text_string  IGRchar        text string
     *text_length   IGRshort       number of bytes in text string
     *text_buf_size IGRshort       # bytes allocated for the text string
     *font_info     struct vfont_entry     font information
     *disp_attr     struct IGRdisplay      display attributes
     *text_symb     struct GRdpb_text_symb text symbology
     num_positions  IGRint         # of positions in text string to update
     *positions[]   IGRshort       array of positions in text string to
                                   update when the size of the text string
                                   is changed; a NULL pointer may be passed
                                   in if an update isn't desired
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -------------------------------------
     *msg         IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
     **text_string IGRuchar       text string with necessary
                                  justification moves inserted
                                  (or deleted)
     *text_length  IGRshort       number of bytes in the justified
                                  text string
     *text_buf_size IGRshort      # bytes allocated for the text string
     *positions[]   IGRshort       array of positions in text string to
                                   update when the size of the text string
                                   is changed; a NULL pointer may be passed
                                   in if an update isn't desired
     *text_extents struct extents justified extents of the text string

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES INVOKED: 
                      FSGetTextVect
                      GRfind_esc_char
                      GResc_handler
                      GRjust_horizontal
                      GRjust_vertical
                      GRjust_extents
-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
        
        DEK  09/09/85 : Design date.
        DEK  02/17/86 : Creation date.
        WBC  07/11/86 : Modified to return addl_info
        WBC  11/06/87 : Modified to work with the font server
        DEK  09/09/88 : Display attributes added.
	DLB  10/01/91 : Fixed syntax error possibly caused by SUN port??
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine returns the justified top, bottom, right, left, cap,
and base extents of a text string.  It also inserts (or removes)
the necessary justification moves in the text string.
----*/
/*EH*/

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
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

#ifdef NEVER_DEF
#include "dpgraphics.h"
#endif


#define  JUST_ESC_SIZE   10

IGRboolean GRjust_string(msg,text_string,text_length,text_buf_size,
                         font_info,disp_attr,text_symb,num_positions,
                         positions,text_extents)

IGRlong              *msg;           /* completion code                      */
IGRuchar             **text_string;  /* text string                          */
IGRshort             *text_length;   /* number of bytes in the text string   */
IGRshort             *text_buf_size; /* # bytes allocated for the text string*/
struct vfont_entry   *font_info;     /* font information                     */
struct IGRdisplay    *disp_attr;     /* display attributes                   */
struct GRdpb_text_symb *text_symb;   /* text symbology                       */
IGRint               num_positions;  /* # of positions in string to update   */
IGRshort             *positions[];   /* array of positions in text string to */
                                     /* update when the size of the text     */
                                     /* string is changed; a NULL pointer may*/
                                     /* be passed in if an update isn't      */
                                     /* desired                              */
struct extents       *text_extents;  /* justified extents of the text string */

{
    extern IGRshort     GRfind_esc_char();  /* finds next esc. seq. in string*/
    extern IGRboolean   GResc_handler();    /* processes escape sequences    */
    extern IGRboolean   GRjust_horizontal();/* horizontally justifies line   */
    extern IGRboolean   GRjust_vertical();  /* vertically justifies string   */
    extern IGRboolean   GRjust_extents();   /* justifies extents of string   */
    extern IGRboolean   GRswap_bytes();

    struct just_info    just_info;          /* justification information     */
    struct IGRestx      text_attr;          /* text specific attributes      */
    struct vfont_entry  cur_font_info;      /* current font information      */
    struct IGRdisplay   cur_disp_attr;      /* current display attributes    */
    struct extents      unjust_extents;     /* unjustified extents of string */
       IGRlong             temp_msg;           /* return code                   */
    IGRshort            num_chars;          /* number of consecutive         */
                                            /* non-escape characters         */
    IGRshort            prev_length;        /* length of text string before  */
                                            /* adjustments for justification */
    IGRint              i;                  /* index counter                 */
    IGRdouble           x_coord, y_coord;   /* x and y coordinates of the    */
                                            /* end of the text sub-string    */
    IGRdouble           s_white_right;      /* white space to the right of   */
                                            /* rightmost char in text string */
    IGRdouble           l_white_right;      /* white space to the right of   */
                                            /* rightmost char in current line*/
    IGRdouble           last_char_space;    /* char space to right of the    */
                                            /* last displayable char on the  */
                                            /* current line                  */
    IGRdouble           wk_origin[2];       /* current working origin        */
    IGRdouble           base_line;          /* current base line             */
    IGRdouble           text_width;         /* text width at the beginning   */
                                            /* of the current line           */
    IGRuchar            *last_char;         /* pointer to the last char.     */
    IGRuchar            *swapped_string;    /* pointer to 'swapped' chars    */
    IGRuchar            hi;                 /* hi byte of 'short' character  */
    IGRuchar            lo;                 /* lo byte of 'short' character  */
    CharId              swapped_char;       /* 'swapped' character           */
    IGRshort            prev_font;          /* font previously used in string*/
    IGRshort            tmp_short;

    /*
     * initialization
     */

    *msg = MSSUCC;

    if (*text_length)
    {
        just_info.num_lines = 1;
        just_info.just_esc_pos = 0;
        just_info.cur_line_left = 0.0;
        just_info.cur_line_right = 0.0;

        wk_origin[0] = 0.0;
        wk_origin[1] = 0.0;
        base_line = 0.0;
        prev_font = -1;              /* no previous font */

        text_attr.font = text_symb->Active_font;
        text_attr.just = text_symb->Active_just;
        text_attr.width = text_symb->Active_width;
        text_attr.height = text_symb->Active_height;
        text_attr.char_spac = text_symb->Active_charspac;
        text_attr.line_spac = text_symb->Active_linespac;

        text_width = text_attr.width;

        cur_font_info = *font_info;
        cur_disp_attr = *disp_attr;

        unjust_extents.right = 0.0;
        unjust_extents.left = 0.0;
        unjust_extents.bottom = -(text_attr.height / 
                                  (cur_font_info.bodysize - cur_font_info.descent)) *
                                 cur_font_info.descent;
        unjust_extents.base = 0.0;
        unjust_extents.top = text_attr.height - unjust_extents.bottom;
        unjust_extents.cap = text_attr.height;

        l_white_right = 0.0;
        s_white_right = 0.0;
        last_char_space = 0.0;
        i = 0;

        while (i < *text_length)
        {
            /*
             *  find the number of consecutive non-escape characters
             */

            GRfind_esc_char(&temp_msg,&((*text_string)[i]),
                            (IGRshort)*text_length - i,cur_font_info.flags,
                            &num_chars);

            if (num_chars)
            {
                if (!(cur_font_info.flags & SIXTEEN_BIT))
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

                    FSXGetTextVect(display,window,gc,cur_font_info.fontid,&((*text_string)[i]),
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
                     *  Server because it expects unsigned shorts if a
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
		    Display	*display;
		    int		window;
		    GC		gc;

                    FSXGetTextVect(display,window,gc,cur_font_info.fontid,swapped_string,
                                 (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
		   }
#else
                    FSGetTextVect(cur_font_info.fontid,swapped_string,
                                 (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
#endif
                    om$dealloc (ptr = swapped_string);
                }

/************************************************************************
Dave Brann 10/01/91 - Following line was missing open paren. Diff is:
from:
		      text_attr.width *
to
		      (text_attr.width *
************************************************************************/

                wk_origin[0] += ((text_attr.width /
                                            (cur_font_info.bodysize -
                                             cur_font_info.descent)) *
                                          x_coord) +
                                          (text_attr.width *
                                          (text_attr.char_spac - 1.0) *
                                          (num_chars - 1)) + last_char_space;

                i += num_chars * (((cur_font_info.flags & SIXTEEN_BIT) >> 3) + 1);;

                if (temp_msg == ESCAPE_TYPE)
                {
                    /*
                     * the last character in the sub-string is an escape (two
                     * consecutive escape chars); only the first one was
                     * included in num_chars since we only want the width of
                     * one, so we need to increment past the second escape char
                     */

                    ++i;
                }

                last_char = &((*text_string)[i - (((cur_font_info.flags & SIXTEEN_BIT) >> 3) +1)]);
                last_char_space = text_attr.width *
                                  (text_attr.char_spac - 1.0);
            }
            else
            {
                /*
                 *  go process escape sequence, calculate working origin,
                 *  change esc x and y scales if necessary; the index i will
                 *  be incremented past the escape sequence (it will also be
                 *  adjusted if the size of the text string changes)
                 */

                ++i;

                if ((*text_string)[i] == LINEFEED)
                {
                    prev_length = *text_length;
                    just_info.cur_line_right -= l_white_right;
                    last_char_space = 0.0;

                    /*
                     *  must increase the text buffer size if it isn't large
                     *  enough to hold an additional justification esc seq;
                     *  check text length so that it does not exceed the
                     *  maximum number an unsigned short can hold
                     */

                    tmp_short = *text_length + JUST_ESC_SIZE;

                    if (tmp_short >= 0)
                    {
                        if (tmp_short > *text_buf_size)
                        {
                            tmp_short = *text_buf_size + JUST_ESC_SIZE + TEXT_BUF_SIZE;
                            if (tmp_short >= 0)
                            {
                                *text_buf_size = tmp_short;

                                *text_string = (IGRuchar *)om$realloc(
                                            ptr = (IGRchar *) *text_string,
                                            size = (OMuint)*text_buf_size);
                            }
                            else
                            {
                                *msg = MSFAIL;
                                goto FINISH;
                            }
                        }
                    }
                    else
                    {
                        *msg = MSFAIL;
                        goto FINISH;
                    }

                    GRjust_horizontal(&temp_msg,*text_string,text_length,
                                      text_symb->Active_just,
                                      text_width,&just_info,
                                      num_positions,positions);

                    i += *text_length - prev_length;
                    l_white_right = 0.0;
                    text_width = text_attr.width;
                }
                GResc_handler(&temp_msg,*text_string,i,&text_attr,wk_origin,
                              &base_line,&cur_font_info,&prev_font,
                              &cur_disp_attr,&just_info,
                              &unjust_extents,&num_chars);

                i += num_chars;   /* incrementing past the escape sequence */
                last_char = NULL;
            }

            /*
             *  calculating just_info for justification moves
             */

            if (wk_origin[0] > just_info.cur_line_right)
            {
                just_info.cur_line_right = wk_origin[0];

                if (last_char)
                {
                    if (cur_font_info.flags & SIXTEEN_BIT)
                    {
                       hi = *last_char;
                       last_char++;
                       lo = *last_char;
                       --last_char;

                       swapped_char = (CharId) ((lo << 8) + hi);
                    }
                    else
                    {
                       swapped_char = (CharId) *last_char;
                    }

                    GRchar_white_space(&temp_msg,swapped_char,
                                       &cur_font_info,NULL,
                                       &l_white_right);

                    l_white_right *= (text_attr.width /
                                      (cur_font_info.bodysize -
                                       cur_font_info.descent));
                }
                else
                {
                    l_white_right = 0.0;
                }
            }

            if (wk_origin[0] < just_info.cur_line_left)
            {
                just_info.cur_line_left = wk_origin[0];
            }

            /*
             * update extents of text string
             */

            if (wk_origin[0] > unjust_extents.right)
            {
                unjust_extents.right = wk_origin[0];

                if (last_char)
                {
                    if (cur_font_info.flags & SIXTEEN_BIT)
                    {
                       hi = *last_char;
                       last_char++;
                       lo = *last_char;
                       --last_char;

                       swapped_char = (CharId) ((lo << 8) + hi);
                    }
                    else
                    {
                       swapped_char = (CharId) *last_char;
                    }

                    GRchar_white_space(&temp_msg,swapped_char,
                                       &cur_font_info,NULL,
                                       &s_white_right);

                    s_white_right *= text_attr.width /
                                     (cur_font_info.bodysize -
                                      cur_font_info.descent);
                }
                else
                {
                    s_white_right = 0.0;
                }
            }
   
            if (wk_origin[0] < unjust_extents.left)
            {
                unjust_extents.left = wk_origin[0];
            }
        }     /* end "while i < *text_length" */

        /*
         *  remove white space from edge of text extents and current
         *  line length if necessary
         */

        unjust_extents.right -= s_white_right;
        just_info.cur_line_right -= l_white_right;

        /*
         *  insert, delete or adjust the vertical and horizontal escape
         *  sequences in the text string necessary for justification;
         *  may have to increase the size of the text string buffer to
         *  accomodate up to two more justifiaction move escape sequences;
         *  check text length so that it does not exceed the
         *  maximum number an unsigned short can hold
         */

        tmp_short = *text_length + (2 * JUST_ESC_SIZE);

        if (tmp_short >= 0)
        {
            if (tmp_short > *text_buf_size)
            {
                tmp_short = *text_buf_size + (2 * JUST_ESC_SIZE);

                if (tmp_short >= 0)
                {
                    *text_buf_size = tmp_short;

                    *text_string = (IGRuchar *)om$realloc(
                                              ptr = (IGRchar *) *text_string,
                                              size = (OMuint)*text_buf_size);
                }
                else
                {
                    *msg = MSFAIL;
                    goto FINISH;
                }
            }
        }
        else
        {
            *msg = MSFAIL;
            goto FINISH;
        }

        GRjust_horizontal(&temp_msg,*text_string,text_length,
                          text_symb->Active_just,
                          text_width,&just_info,
                          num_positions,positions);

        GRjust_vertical(&temp_msg,*text_string,text_length,
                        text_symb->Active_just,text_symb->Active_height,
                        &unjust_extents,num_positions,positions);

        GRjust_extents(&temp_msg,text_symb->Active_just,just_info.num_lines,
                       &unjust_extents,text_extents);
    }
    else   /* empty text string */
    {
        text_extents->left = 0.0;
        text_extents->right = 0.0;
        text_extents->top = 0.0;
        text_extents->cap = 0.0;
        text_extents->base = 0.0;
        text_extents->bottom = 0.0;
    }

FINISH:
    return(TRUE);
}
