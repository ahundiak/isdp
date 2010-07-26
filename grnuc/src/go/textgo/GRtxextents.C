/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRtx_extents
 
     Abstract:  This routine returns the top, bottom, right, left,
                cap, and base extents of a text string.
-----
%SC%

     VALUE =  GRtx_extents(msg,text_string,text_length,font_info,
                           disp_attr,char_spacing,line_spacing,text_width,
                           text_height,font,start_char,end_char,text_extents)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                   DESCRIPTION
     ----------   ------------     -------------------------------------
     *text_string IGRuchar         text string
     *text_length IGRshort         number of bytes in text string
     *font_info   struct vfont_entry font information
     *disp_attr   struct IGRdisplay display attributes
     char_spacing IGRdouble        character spacing
     line_spacing IGRdouble        line spacing
     text_width   IGRdouble        text width
     text_height  IGRdouble        text height
     font         IGRshort         font
     start_char   IGRshort         position to start calculating extents
     end_char     IGRshort         position to stop calculating extents
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -------------------------------------
     *msg         IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
     *text_extents struct extents justified extents of the text string

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES INVOKED: 
                      FSGetTextVect
                      GRfind_esc_char
                      GResc_handler
-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
        
        DEK  09/09/85 : Design date.
        DEK  02/17/86 : Creation date.
        WBC  07/11/86 : Modified to return addl_info
        WBC  11/18/87 : Modified to work with the font server
        DEK  05/04/88 : Added font to accomodate fractions.
        DEK  09/09/88 : Display attributes added.
        DEK  12/02/88 : Start and end characters added.
        SCW  07/21/92 : Ansi conversion
        WBC  06/01/93 : Initialized members of the just_info struct to take
                        care of UMRs reported by Purify.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine returns the top, bottom, right, left, cap,
and base extents of a text string.
----*/
/*EH*/

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
#include "FS.h"
#include "FSOutl.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "OMprimitives.h"
#include "grimport.h"
#include "dpdef.h"

#ifdef NEVER_DEF
#include "dpgraphics.h"
#endif


IGRboolean GRtx_extents(msg,text_string,text_length,font_info,disp_attr,
                        char_spacing,line_spacing,text_width,text_height,
                        font,start_char,end_char,text_extents)

IGRlong              *msg;         /* completion code                      */
IGRuchar             *text_string; /* text string                          */
IGRshort             *text_length; /* number of bytes in the text string   */
struct vfont_entry   *font_info;   /* font information                     */
struct IGRdisplay    *disp_attr;   /* display attributes                   */
IGRdouble            char_spacing; /* character spacing                    */
IGRdouble            line_spacing; /* line spacing                         */
IGRdouble            text_width;   /* text width                           */
IGRdouble            text_height;  /* text height                          */
IGRshort             font;         /* font                                 */
IGRshort             start_char;   /* position to start calculating extents*/
IGRshort             end_char;     /* position to stop calculating extents */
struct extents       *text_extents;/* justified extents of the text string */

{
    extern IGRboolean   GResc_handler();    /* processes escape sequences    */
    extern IGRshort     GRfind_esc_char();  /* finds next escape character   */
    extern IGRboolean   GRchar_white_space();
    extern IGRboolean   GRswap_bytes();

    struct just_info    just_info;          /* justification information     */
       IGRlong             temp_msg;           /* return code                   */
    IGRshort            num_chars;          /* number of consecutive         */
                                            /* non-escape characters         */
                                               /* adjustments for justification */
    IGRint              i;                  /* index counter                 */
    IGRdouble           x_coord, y_coord;   /* x and y coordinates of the    */
                                            /* end of the text sub-string    */
    IGRdouble           white_right;        /* white space to the right of   */
                                            /* rightmost char in text string */
    IGRuchar            *last_char;         /* pointer to the last char.     */
    IGRuchar            *swapped_string;    /* pointer to 'swapped' chars    */
    IGRuchar            hi;                 /* hi byte of 'short' character  */
    IGRuchar            lo;                 /* lo byte of 'short' character  */
    CharId              swapped_char;       /* 'swapped' character           */
    struct IGRestx      text_attr;          /* text specific attributes      */
    IGRdouble           wk_origin[2];       /* working origin of text string */
    IGRdouble           base_line;          /* base line of text string      */
    IGRshort            prev_font;          /* font previously used in string*/
    struct vfont_entry  loc_font_info;      /* font information              */
    struct IGRdisplay   loc_disp_attr;      /* display attributes            */
    IGRdouble           field_wk_origin[2]; /* working origin at start char  */

    /*
     * initialization
     */

    *msg = MSSUCC;

    if (*text_length)
    {
        text_attr.font = font;              /* current font */
        text_attr.width = text_width;       /* current text width */
        text_attr.height = text_height;     /* current text height */
        text_attr.char_spac = char_spacing; /* current character spacing */
        text_attr.line_spac = line_spacing; /* current line spacing */

        wk_origin[0] = 0.0;           /* initialize working origin to zero */
        wk_origin[1] = 0.0;
        base_line = 0.0;

        prev_font = -1;                    /* no previous font */
        loc_font_info = *font_info;        /* current font information */
        loc_disp_attr = *disp_attr;        /* current display attributes */
        white_right = 0.0;

        text_extents->right = 0.0;
        text_extents->left = 0.0;
        text_extents->bottom = -(text_attr.height / 
                                (loc_font_info.bodysize - loc_font_info.descent)) *
                                 loc_font_info.descent;
        text_extents->base = 0.0;
        text_extents->cap = text_attr.height;
        text_extents->top = text_attr.height - text_extents->bottom;

        /*
         * cycle through string until start position is reached,
         * updating the working origin with each character
         */

        i = 0;

        while (i < start_char)
        {
           /*
            * find the number of consecutive non-escape characters
            */

           GRfind_esc_char(&temp_msg,&(text_string[i]),
                           (IGRshort)*text_length - i,loc_font_info.flags,
                           &num_chars);

           if (num_chars)
           {
              if (!(loc_font_info.flags & SIXTEEN_BIT))
              {
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

                 FSXGetTextVect(display, window, gc, loc_font_info.fontid,&(text_string[i]),
                               (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
		}
#else
                 FSGetTextVect(loc_font_info.fontid,&(text_string[i]),
                               (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
#endif
              }
              else       /* characters are sixteen bit */
              {
                 /* 
                  *  swap the bytes in the string that is send to Font
                  *  Server because it expects unsigned shorts if a
                  *  sixteen bit font
                  */

                 swapped_string = (IGRuchar *)om$malloc(size = (num_chars * 2));

                 GRswap_bytes(msg,&(text_string[i]),(num_chars * 2),
                              swapped_string);

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

                 FSXGetTextVect(display, window, gc, loc_font_info.fontid,swapped_string,
                               (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
		}
#else
                 FSGetTextVect(loc_font_info.fontid,swapped_string,
                               (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
#endif

                 om$dealloc (ptr = swapped_string);
              }

              wk_origin[0] += (text_attr.width / (loc_font_info.bodysize
                              - loc_font_info.descent) * x_coord) + 
                              (text_attr.width * (text_attr.char_spac - 
                              1.0) * (num_chars - 1));

              i += num_chars * (((loc_font_info.flags & SIXTEEN_BIT) >> 3) + 1);

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
           }
           else
           {
              /*
               * go process esc sequence, calculating working origin
               */

              ++i;
              just_info.num_lines = 1;
              just_info.just_esc_pos = 0;
              just_info.cur_line_left = just_info.cur_line_right = 0.0;

              GResc_handler(&temp_msg,text_string,i,&text_attr,wk_origin,
                            &base_line,&loc_font_info,&prev_font,
                            &loc_disp_attr,&just_info,
                            text_extents,&num_chars);

              i += num_chars;
           }
        }

        field_wk_origin[0] = wk_origin[0];
        field_wk_origin[1] = wk_origin[1];

        text_extents->right = wk_origin[0];
        text_extents->left = wk_origin[0];
        text_extents->bottom = wk_origin[1] - ((text_attr.height / 
                                (loc_font_info.bodysize - loc_font_info.descent)) *
                                 loc_font_info.descent);
        text_extents->base = wk_origin[1];
        text_extents->cap = wk_origin[1] + text_attr.height;
        text_extents->top = wk_origin[1] + text_attr.height 
                            + ((text_attr.height / (loc_font_info.bodysize -
                            loc_font_info.descent)) * loc_font_info.descent);

        i = start_char;

        while (i <= end_char)
        {
            /*
             *  find the number of consecutive non-escape characters
             */

            GRfind_esc_char(&temp_msg,&(text_string[i]),
                            (IGRshort)*text_length - i,loc_font_info.flags,
                            &num_chars);

            if (num_chars)
            {
                if (!(loc_font_info.flags & SIXTEEN_BIT))
                {
                    /*
                     *  find the length of this text seven bit sub-string; 
                     *  update the working origin of the text string according
                     *  to the sub-string length, text width, font body 
                     *  size and character spacing
                     */

#ifdef NEVER_DEF
		{
		 Display         *display;
		 int             window;
		 GC              gc;

                 FSXGetTextVect(display, window, gc, loc_font_info.fontid,&(text_string[i]),
                               (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
		}
#else
                    FSGetTextVect(loc_font_info.fontid,&(text_string[i]),
                                 (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
#endif
                }
                else       /* characters are sixteen bit */
                {
                    /* 
                     *  swap the bytes in the string that is send to Font
                     *  Server because it expects unsigned shorts if a
                     *  sixteen bit font
                     */

                    swapped_string = (IGRuchar *)om$malloc(size = (num_chars * 2));

                    GRswap_bytes(&temp_msg,&(text_string[i]),(num_chars * 2),
                                 swapped_string);

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

                 FSXGetTextVect(display, window, gc, loc_font_info.fontid,swapped_string,
                               (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
		}
#else
                    FSGetTextVect(loc_font_info.fontid,swapped_string,
                                 (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);

#endif
                    om$dealloc (ptr = swapped_string);
                }

                wk_origin[0] += ((text_attr.width /
                                 (loc_font_info.bodysize - 
                                 loc_font_info.descent)) *
                                 x_coord) + text_attr.width *
                                 (text_attr.char_spac - 1.0) *
                                 (num_chars - 1);

                i += num_chars * (((loc_font_info.flags & SIXTEEN_BIT) >> 3) + 1);

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

                last_char = &(text_string[i - (((loc_font_info.flags & SIXTEEN_BIT) >> 3) + 1)]);
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
                just_info.num_lines = 1;
                just_info.just_esc_pos = 0;
                just_info.cur_line_left = just_info.cur_line_right = 0.0;

                GResc_handler(&temp_msg,text_string,i,&text_attr,wk_origin,
                              &base_line,&loc_font_info,&prev_font,
                              &loc_disp_attr,&just_info,
                              text_extents,&num_chars);

                i += num_chars;   /* incrementing past the escape sequence */
                last_char = NULL;
            }

            /*
             * update extents of text string
             */

            if (wk_origin[0] > text_extents->right)
            {
                text_extents->right = wk_origin[0];

                if (last_char)
                {
                    if (loc_font_info.flags & SIXTEEN_BIT)
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
                                       &loc_font_info,NULL,&white_right);

                    white_right *= text_attr.width / 
                                   (loc_font_info.bodysize -
                                    loc_font_info.descent);
                }
                else
                {
                    white_right = 0.0;
                }
            }
   
            if (wk_origin[0] < text_extents->left)
            {
                text_extents->left = wk_origin[0];
            }
        }     /* end "while i < *text_length" */

        /*
         *  remove white space from edge of text extents if necessary
         */

        text_extents->right -= white_right;

        /* 
         * adjust extents of string to be relative to start character
         */

        text_extents->left -= field_wk_origin[0];
        text_extents->right -= field_wk_origin[0];
        text_extents->top -= field_wk_origin[1];
        text_extents->cap -= field_wk_origin[1];
        text_extents->base -= field_wk_origin[1];
        text_extents->bottom -= field_wk_origin[1];
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
    return(TRUE);
}
