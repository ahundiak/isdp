/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME: GRerase_chars
 
     Abstract: 
        This routine determines what sub-string to erase given a text string,
        type of action (i.e. insert linefeed, insert char, delete linefeed,
        delete char) and the text's justification.
-----
%SC%

     VALUE =  GRerase_chars(msg,text_string,tx_attr,font_info,disp_attr,action,
                            lf_mask,field_type,del_char_index,cc_info,
                            text_info,cur_disp_attr,erase_from,erase_to,
                            erase_index,chars_eol,flags,kern_value)
-----
%EN%
 
     ON ENTRY:

        NAME            DATA TYPE                DESCRIPTION
     ----------      ---------------  -----------------------------------
     *msg            IGRlong          completion code
     *text_string    IGRuchar         text string to edit
     *tx_attr        struct IGRestx   text string's text attributes
     *font_info      struct vfont_entry  font information
     *disp_attr      struct IGRdisplay display attributes
     action          IGRint           action affecting the text string
                                      - INSERT_CHAR: insertion of a char
                                      - INSERT_LF: insertion of a linefeed
                                        or a vertical move
                                      - DELETE_CHAR: deletion of a char
                                      - DELETE_LF: deletion of a linefeed
                                        or a vertical move
     lf_mask         IGRint           if action is INSERT_LF or DELETE_LF,
                                      this mask indicates if the linefeed
                                      (or vertical move) moves up, down
                                      or both (if both a positiove and
                                      negative value vertical moves are
                                      deleted, could be both)
                                      - UP_MOVE: a linefeed with a negative
                                        line spacing or a non-negative
                                        vertical move
                                      - DOWN_MOVE: a linefeed with a
                                        non-negative line spacing or a
                                        negative vertical move
     field_type      IGRint           the type of field (if any) the chars
                                      are being inserted into or deleted
                                      from:
                                      - NO_FLD: not in a field
                                      - MV_REF_PT_FLD: in a field that
                                        has a dependent move to field
                                        reference point escape sequence
                                      - JUSTIFIED_FLD: in a justified field
                                      _ FIXED_LENGTH_FLD: in a fixed length
                                                          field
     *del_char_index IGRshort         the index of the char to delete if
                                      the specified action is DELETE_CHAR
                                      or DELETE_LF; otherwise a NULL pointer
     *cc_info        struct GRcc_info info about the cur char in text string
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                   DESCRIPTION
     ----------     ------------      -----------------------------------
     *text_info     struct IGResintx  text specific information about
                                      the sub-string to erase
     *cur_disp_attr struct IGRdisplay display attributes at beginning of
                                      the sub-string to erase
     *erase_from    IGRint            description of where to erase from
     *erase_to      IGRint            description of where to erase to
     *erase_index   IGRshort          index erasing beins at
     *chars_eol     IGRshort          # of chars from the current char
                                      to the end of the current line
                                      (only applicable if erase_from
                                      = END_CUR_LINE)
     *flags         short unsigned    flags member of the GRcc_info struct
                                      at the position of the char to erase
     *kern_value    IGRdouble         kerning pair value of the char to be
                                      erased and the char that precedes it

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
        
        WBC  07/14/88 : Design date.
        WBC  07/14/88 : Creation date.
        DEK  09/09/88 : Added display attributes.
        WBC  09/16/88 : Added argument cur_disp_attr.
        WBC  11/15/89 : Added arguments flags and kern_value so that
                        the horizontal justification move could be
                        adjusted if a kerning pair is at the current
                        position.
        SCW  07/21/92 : Ansi conversion

-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine determines what sub-string to erase given a text
string, type of action (i.e. insert linefeed, insert char, delete
linefeed, delete char) and the text's justification.
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
#include "grdpbdef.h"
#include "grdpb.h"

#define  UP_MOVE    0x1
#define  DOWN_MOVE  0x2

IGRint GRerase_chars(msg,text_string,tx_attr,font_info,disp_attr,action,
                     lf_mask,field_type,del_char_index,cc_info,text_info,
                     cur_disp_attr,erase_from,erase_to,erase_index,chars_eol,
                     flags,kern_value)

IGRlong            *msg;           /* informational message                  */
IGRuchar           *text_string;   /* text string to edit                    */
struct IGRestx     *tx_attr;       /* text string's text attributes          */
struct vfont_entry *font_info;     /* font information                       */
struct IGRdisplay  *disp_attr;     /* display attributes                     */
IGRint             action;         /* action affecting the text string       */
                                   /*  - INSERT_CHAR: insertion of a char    */
                                   /*  - INSERT_LF: insertion of a linefeed  */
                                   /*  - DELETE_CHAR: deletion of a char     */
                                   /*  - DELETE_LF: deletion of a linefeed   */
IGRint             lf_mask;        /* if action is INSERT_LF or DELETE_LF,   */
                                   /* this mask indicates if the linefeed    */
                                   /* (or vertical move) moves up, down or   */
                                   /* both (if both a positive and negative  */
                                   /* value vertical moves are deleted,      */
                                   /* could be both)                         */
                                   /* - UP_MOVE: a linefeed with a           */
                                   /* negative line spacing or a non-negative*/
                                   /* vertical move                          */
                                   /* - DOWN_MOVE: a linefeed with a         */
                                   /* non- negativeline spacing or a         */
                                   /* negative vertical move                 */
IGRint             field_type;     /* indicates whether the current position */
                                   /* is in a field and if so, what type of  */
                                   /* field                                  */
IGRshort           *del_char_index;/* the index of the char to delete if the */
                                   /* specified action is DELETE_CHAR or     */
                                   /* DELETE_LF; otherwise a NULL pointer    */
struct GRcc_info   *cc_info;       /* info about the cur char in text string */
struct IGResintx   *text_info;     /* text specific information              */
struct IGRdisplay  *cur_disp_attr; /* display attributes at beginning of     */
                                   /* the sub-string to erase                */
IGRint             *erase_from;    /* description of where to erase from     */
IGRint             *erase_to;      /* description of where to erase to       */
IGRshort           *erase_index;   /* index erasing beins at                 */
IGRshort           *chars_eol;     /* # of chars from the current char to    */
                                   /* the end of the current line (only      */
                                   /* applicable if erase_from =END_CUR_LINE)*/
short unsigned     *flags;         /* flags member of the GRcc_info struct   */
                                   /* at the position of the char to erase   */
IGRdouble          *kern_value;    /* kerning pair value of the char to be   */
                                   /* erased and the char that precedes it   */

{
    extern IGRboolean  GRbwd_beg_esc_seq();
    extern IGRint      GRkern_pair_value();

    IGRchar            esc_char;    /* character to be searched for          */
    IGRshort           num_chars;   /* number of characters to search for    */
    IGRshort           lf_esc_index;/* index of a linefeed escape sequence   */
    IGRlong            temp_msg;
    IGRdouble          just_move;   /* justification move to the from_char   */
    struct GRcc_info   tmp_cc_info; /* info about the cur char in text string*/

    *msg = MSSUCC;
    *flags = 0;
    *kern_value = 0.0;

    if (!(cc_info->field_delim) ||
        (!field_type) ||
        (field_type & JUSTIFIED_FLD))
    {
        /*
         * not in a fixed length field and not followed by a move to field
         * reference point escape sequence; using the action and text
         * justification determine what sub-string to erase
         */

        switch (tx_attr->just)
        {
            case LEFT_BOTTOM:
            case LEFT_BASE:

                switch (action)
                {
                    case INSERT_CHAR:

                        /*
                         * if there is a horizontal justification move for the
                         * current line, must erase from the beginning of the
                         * line; otherwise erase from the current char
                         */

                        if (cc_info->line_just_move)
                        {
                            *erase_from = BEGIN_CUR_LINE;
                        }
                        else
                        {
                            *erase_from = CURRENT_CHAR;
                        }
                        *erase_to = END_CUR_LINE;
                        break;

                    case INSERT_LF:

                        if (lf_mask & DOWN_MOVE)
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_CUR_LINE;
                        }
                        else  /* must be an UP_MOVE */
                        {
                            if (cc_info->line_just_move)
                            {
                                *erase_from = BEGIN_CUR_LINE;
                            }
                            else
                            {
                                *erase_from = CURRENT_CHAR;
                            }
                            *erase_to = END_STRING;
                        }
                        break;

                    case DELETE_CHAR:

                        /*
                         * if there is a horizontal justification move for the
                         * current line, must erase from the beginning of the
                         * line; otherwise erase from the previous editable
                         * char
                         */

                        if (cc_info->line_just_move)
                        {
                            *erase_from = BEGIN_CUR_LINE;
                        }
                        else
                        {
                            *erase_from = PREV_EDIT_CHAR;
                        }
                        *erase_to = END_CUR_LINE;
                        break;

                    case DELETE_LF:

                        if (lf_mask & DOWN_MOVE)
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_CUR_LINE;
                        }
                        else  /* must be an UP_MOVE */
                        {
                            *erase_from = PREV_EDIT_CHAR;
                            *erase_to = END_STRING;
                        }
                        break;

                    default:    /* unknown action */
#ifdef DEBUG
                        printf("GRerase_chars: unknown action\n");
#endif
                        break;
                }
                break;

            case LEFT_CENTER:

                switch (action)
                {
                    case INSERT_CHAR:

                        /*
                         * if there is a horizontal justification move for the
                         * current line, must erase from the beginning of the
                         * line; otherwise erase from the current char
                         */

                        if (cc_info->line_just_move)
                        {
                            *erase_from = BEGIN_CUR_LINE;
                        }
                        else
                        {
                            *erase_from = CURRENT_CHAR;
                        }
                        *erase_to = END_CUR_LINE;
                        break;

                    case INSERT_LF:

                        *erase_from = BEGIN_STRING;
                        *erase_to = END_STRING;
                        break;

                    case DELETE_CHAR:

                        /*
                         * if there is a horizontal justification move for the
                         * current line, must erase from the beginning of the
                         * line; otherwise erase from the previous editable
                         * char
                         */

                        if (cc_info->line_just_move)
                        {
                            *erase_from = BEGIN_CUR_LINE;
                        }
                        else
                        {
                            *erase_from = PREV_EDIT_CHAR;
                        }
                        *erase_to = END_CUR_LINE;
                        break;

                    case DELETE_LF:

                        *erase_from = BEGIN_STRING;
                        *erase_to = END_STRING;
                        break;

                    default:    /* unknown action */

#ifdef DEBUG
                        printf("GRerase_chars: unknown action\n");
#endif
                        break;
                }
                break;

            case LEFT_CAP:
            case LEFT_TOP:

                switch (action)
                {
                    case INSERT_CHAR:

                        /*
                         * if there is a horizontal justification move for the
                         * current line, must erase from the beginning of the
                         * line; otherwise erase from the current char
                         */

                        if (cc_info->line_just_move)
                        {
                            *erase_from = BEGIN_CUR_LINE;
                        }
                        else
                        {
                            *erase_from = CURRENT_CHAR;
                        }
                        *erase_to = END_CUR_LINE;
                        break;

                    case INSERT_LF:

                        if ((lf_mask & UP_MOVE) &&
                            (lf_mask & DOWN_MOVE))
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_STRING;
                        }
                        else if (lf_mask & UP_MOVE)
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_CUR_LINE;
                        }
                        else  /* must be a DOWN_MOVE */
                        {
                            /*
                             * if there is a horizontal justification move for
                             * the current line, must erase from the beginning
                             * of the line; otherwise erase from the current
                             * char
                             */

                            if (cc_info->line_just_move)
                            {
                                *erase_from = BEGIN_CUR_LINE;
                            }
                            else
                            {
                                *erase_from = CURRENT_CHAR;
                            }
                            *erase_to = END_STRING;
                        }

                        break;

                    case DELETE_CHAR:

                        /*
                         * if there is a horizontal justification move for the
                         * current line, must erase from the beginning of the
                         * line; otherwise erase from the previous editable
                         * char
                         */

                        if (cc_info->line_just_move)
                        {
                            *erase_from = BEGIN_CUR_LINE;
                        }
                        else
                        {
                            *erase_from = PREV_EDIT_CHAR;
                        }
                        *erase_to = END_CUR_LINE;
                        break;

                    case DELETE_LF:

                        if ((lf_mask & UP_MOVE) &&
                            (lf_mask & DOWN_MOVE))
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_STRING;
                        }
                        else if (lf_mask & UP_MOVE)
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_CUR_LINE;
                        }
                        else  /* must be a DOWN_MOVE */
                        {
                            /*
                             * if there is a horizontal justification move for
                             * the current line, must erase from the beginning
                             * of the line; otherwise erase from the previous
                             * editable char
                             */

                            if (cc_info->line_just_move)
                            {
                                *erase_from = BEGIN_CUR_LINE;
                            }
                            else
                            {
                                *erase_from = PREV_EDIT_CHAR;
                            }
                            *erase_to = END_STRING;
                        }

                        break;

                    default:    /* unknown action */

#ifdef DEBUG
                        printf("GRerase_chars: unknown action\n");]
#endif
                        break;
                }
                break;

            case CENTER_BOTTOM:
            case CENTER_BASE:

                switch (action)
                {
                    case INSERT_CHAR:

                        *erase_from = BEGIN_CUR_LINE;
                        *erase_to = END_CUR_LINE;
                        break;

                    case INSERT_LF:

                        if (lf_mask & DOWN_MOVE)
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_CUR_LINE;
                        }
                        else  /* must be an UP_MOVE */
                        {
                            *erase_from = BEGIN_CUR_LINE;
                            *erase_to = END_STRING;
                        }
                        break;

                    case DELETE_CHAR:

                        *erase_from = BEGIN_CUR_LINE;
                        *erase_to = END_CUR_LINE;
                        break;

                    case DELETE_LF:

                        if (lf_mask & DOWN_MOVE)
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_CUR_LINE;
                        }
                        else  /* must be an UP_MOVE */
                        {
                            *erase_from = BEGIN_CUR_LINE;
                            *erase_to = END_STRING;
                        }
                        break;

                    default:    /* unknown action */

#ifdef DEBUG
                        printf("GRerase_chars: unknown action\n");
#endif
                        break;
                }
                break;

            case CENTER_CENTER:

                switch (action)
                {
                    case INSERT_CHAR:

                        *erase_from = BEGIN_CUR_LINE;
                        *erase_to = END_CUR_LINE;
                        break;

                    case INSERT_LF:

                        *erase_from = BEGIN_STRING;
                        *erase_to = END_STRING;
                        break;

                    case DELETE_CHAR:

                        *erase_from = BEGIN_CUR_LINE;
                        *erase_to = END_CUR_LINE;
                        break;

                    case DELETE_LF:

                        *erase_from = BEGIN_STRING;
                        *erase_to = END_STRING;
                        break;

                    default:    /* unknown action */

#ifdef DEBUG
                        printf("GRerase_chars: unknown action\n");
#endif
                        break;
                }
                break;

            case CENTER_CAP:
            case CENTER_TOP:

                switch (action)
                {
                    case INSERT_CHAR:

                        *erase_from = BEGIN_CUR_LINE;
                        *erase_to = END_CUR_LINE;
                        break;

                    case INSERT_LF:

                        if ((lf_mask & UP_MOVE) &&
                            (lf_mask & DOWN_MOVE))
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_STRING;
                        }
                        else if (lf_mask & UP_MOVE)
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_CUR_LINE;
                        }
                        else  /* must be a DOWN_MOVE */
                        {
                            *erase_from = BEGIN_CUR_LINE;
                            *erase_to = END_STRING;
                        }
                        break;

                    case DELETE_CHAR:

                        *erase_from = BEGIN_CUR_LINE;
                        *erase_to = END_CUR_LINE;
                        break;

                    case DELETE_LF:

                        if ((lf_mask & UP_MOVE) &&
                            (lf_mask & DOWN_MOVE))
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_STRING;
                        }
                        else if (lf_mask & UP_MOVE)
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_CUR_LINE;
                        }
                        else  /* must be a DOWN_MOVE */
                        {
                            *erase_from = BEGIN_PREV_LINE;
                            *erase_to = END_STRING;
                        }
                        break;

                    default:    /* unknown action */

#ifdef DEBUG
                        printf("GRerase_chars: unknown action\n");
#endif
                        break;
                }
                break;

            case RIGHT_BOTTOM:
            case RIGHT_BASE:

                switch (action)
                {
                    case INSERT_CHAR:

                        *erase_from = BEGIN_CUR_LINE;
                        *erase_to = END_CUR_LINE;
                        break;

                    case INSERT_LF:

                        if (lf_mask & DOWN_MOVE)
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_CUR_LINE;
                        }
                        else  /* must be an UP_MOVE */
                        {
                            *erase_from = BEGIN_CUR_LINE;
                            *erase_to = END_STRING;
                        }
                        break;

                    case DELETE_CHAR:

                        *erase_from = BEGIN_CUR_LINE;
                        *erase_to = END_CUR_LINE;
                        break;

                    case DELETE_LF:

                        if (lf_mask & DOWN_MOVE)
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_CUR_LINE;
                        }
                        else  /* must be an UP_MOVE */
                        {
                            *erase_from = BEGIN_CUR_LINE;
                            *erase_to = END_STRING;
                        }
                        break;

                    default:    /* unknown action */

#ifdef DEBUG
                        printf("GRerase_chars: unknown action\n");
#endif
                        break;
                }
                break;

            case RIGHT_CENTER:

                switch (action)
                {
                    case INSERT_CHAR:

                        *erase_from = BEGIN_CUR_LINE;
                        *erase_to = END_CUR_LINE;
                        break;

                    case INSERT_LF:

                        *erase_from = BEGIN_STRING;
                        *erase_to = END_STRING;
                        break;

                    case DELETE_CHAR:

                        *erase_from = BEGIN_CUR_LINE;
                        *erase_to = END_CUR_LINE;
                        break;

                    case DELETE_LF:

                        *erase_from = BEGIN_STRING;
                        *erase_to = END_STRING;
                        break;

                    default:    /* unknown action */

#ifdef DEBUG
                        printf("GRerase_chars: unknown action\n");
#endif
                        break;
                }
                break;

            case RIGHT_CAP:
            case RIGHT_TOP:

                switch (action)
                {
                    case INSERT_CHAR:

                        *erase_from = BEGIN_CUR_LINE;
                        *erase_to = END_CUR_LINE;
                        break;

                    case INSERT_LF:

                        if ((lf_mask & UP_MOVE) &&
                            (lf_mask & DOWN_MOVE))
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_STRING;
                        }
                        else if (lf_mask & UP_MOVE)
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_CUR_LINE;
                        }
                        else  /* must be a DOWN_MOVE */
                        {
                            *erase_from = BEGIN_CUR_LINE;
                            *erase_to = END_STRING;
                        }
                        break;

                    case DELETE_CHAR:

                        *erase_from = BEGIN_CUR_LINE;
                        *erase_to = END_CUR_LINE;
                        break;

                    case DELETE_LF:

                        if ((lf_mask & UP_MOVE) &&
                            (lf_mask & DOWN_MOVE))
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_STRING;
                        }
                        else if (lf_mask & UP_MOVE)
                        {
                            *erase_from = BEGIN_STRING;
                            *erase_to = END_CUR_LINE;
                        }
                        else  /* must be a DOWN_MOVE */
                        {
                            *erase_from = BEGIN_PREV_LINE;
                            *erase_to = END_STRING;
                        }
                        break;

                    default:    /* unknown action */

#ifdef DEBUG
                        printf("GRerase_chars: unknown action\n");
#endif
                        break;
                }
                break;

            default:    /* unknown justification */

#ifdef DEBUG
                printf("GRerase_chars: unknown justification\n");
#endif
                break;
        }  /* end switch */

        if (field_type & MV_REF_PT_FLD)
        {
            /*
             * if the current position is in a field that is referenced by a
             * move to field reference point escape sequence, must erase from
             * the normal position to the end of string in case the appearance
             * of the chars following the move to field reference point escape
             * sequence has changed
             */

            *erase_to = END_STRING;
        }

        if (field_type & JUSTIFIED_FLD)
        {
            /*
             * if the current position is followed on the current line by a
             * justified field, must erase from the beginning of the current
             * line instead of the current or previous char since the char
             * being removed may cause the justified field to shift, which in
             * turn may cause a line justification move to be inserted in front
             * of the current line, so the entire line would need to be erased
             */

            if ((*erase_from == CURRENT_CHAR) ||
                (*erase_from == PREV_EDIT_CHAR))
            {
                *erase_from = BEGIN_CUR_LINE;
            }
        }
    }
    else
    {
        /*
         * current position is either in a fixed length field or followed by
         * a move to field reference point escape sequence; must erase the
         * entire string since the fields involved may span several lines
         */

        *erase_from = BEGIN_STRING;
        *erase_to = END_STRING;
    }

    /*
     *  find the position in the text string to display from, the text
     *  attributes at that position and calculate and initalize the
     *  justification moves for the first char to display if necessary
     */

    switch (*erase_from)
    {
        case CURRENT_CHAR:

            text_info->text_string = 
                             (IGRchar *)&text_string[cc_info->cur_char_index];
            *erase_index = cc_info->cur_char_index;
            *(text_info->estx) = cc_info->text_attr;
            text_info->prev_font = cc_info->prev_font;
            *cur_disp_attr = cc_info->disp_attr;
            text_info->flags = 0x1;  /* use the justification moves */
            *flags = cc_info->flags;
            *kern_value = cc_info->kern_value;

            just_move = (-cc_info->ss_v_move - cc_info->wk_origin[1]) /
                        cc_info->text_attr.height;
            OM_BLOCK_MOVE(&just_move,&text_info->just_moves[2],8);

            just_move = (cc_info->line_just_move + cc_info->wk_origin[0]) /
                        cc_info->text_attr.width;
            OM_BLOCK_MOVE(&just_move,&text_info->just_moves[12],8);
            break;

        case PREV_EDIT_CHAR:

            text_info->text_string = (IGRchar *)&text_string[*del_char_index];
            *erase_index = *del_char_index;
            tmp_cc_info = *cc_info;

            /*
             *  find the char info of the first char to erase
             */

            GRchar_pos_info(&temp_msg,text_string,*del_char_index,
                            FALSE,tx_attr,font_info,disp_attr,&tmp_cc_info);

            *(text_info->estx) = tmp_cc_info.text_attr;
            text_info->prev_font = tmp_cc_info.prev_font;
            *cur_disp_attr = tmp_cc_info.disp_attr;
            text_info->flags = 0x1;  /* use the justification moves */
            *flags = tmp_cc_info.flags;
            *kern_value = tmp_cc_info.kern_value;

            just_move = (-tmp_cc_info.ss_v_move - tmp_cc_info.wk_origin[1]) /
                        tmp_cc_info.text_attr.height;
            OM_BLOCK_MOVE(&just_move,&text_info->just_moves[2],8);

            just_move = (tmp_cc_info.line_just_move + tmp_cc_info.wk_origin[0]) /
                        tmp_cc_info.text_attr.width;
            OM_BLOCK_MOVE(&just_move,&text_info->just_moves[12],8);
            break;

        case BEGIN_CUR_LINE:

            if (cc_info->cur_line == 1)
            {
                /*
                 *  the beginning of the current line (the first line) is the
                 *  beginning of the text string; erase from the beginning of
                 *  the text string
                 */

                text_info->text_string = (IGRchar *)text_string;
                *erase_index = 0;
                *(text_info->estx) = *tx_attr;
                text_info->prev_font = -1;
                *cur_disp_attr = *disp_attr;
                text_info->flags = 0;  /* do not use the justification moves */
            }
            else   /* not the first line of text */
            {
                /*
                 *  must find the index of the first char on the current line,
                 *  which follows the previous linefeed escape sequence and
                 *  its justification move escape (if it has a move esc seq)
                 */

                num_chars = 1;
                esc_char = LINEFEED;  /* find previous linefeed escape seq */

                if (GRbwd_beg_esc_seq(&temp_msg,text_string,&num_chars,
                                      &esc_char,NULL,&cc_info->cur_char_index,
                                      font_info->flags,&lf_esc_index))
                {
                    /*
                     *  determine if a linefeed justification move escape
                     *  sequence follows the linefeed escape sequence
                     *  
                     */

                    if ((lf_esc_index + 2 < cc_info->cur_char_index) &&
                        (text_string[lf_esc_index + 2] == ESC) &&
                        (text_string[lf_esc_index + 3] == 'H'))
                    {
                        *erase_index = lf_esc_index + 12;
                    }
                    else
                    {
                        *erase_index = lf_esc_index + 2;
                    }
                    text_info->text_string = 
                                       (IGRchar *)&text_string[*erase_index];
                    tmp_cc_info = *cc_info;

                    /*
                     *  find the char info of the first char to erase
                     */

                    GRchar_pos_info(&temp_msg,text_string,*erase_index,
                                    FALSE,tx_attr,font_info,disp_attr,
                                    &tmp_cc_info);

                    *(text_info->estx) = tmp_cc_info.text_attr;
                    text_info->prev_font = tmp_cc_info.prev_font;
                    *cur_disp_attr = tmp_cc_info.disp_attr;
                    text_info->flags = 0x1;  /* use the justification moves */

                    just_move = (-tmp_cc_info.ss_v_move - tmp_cc_info.wk_origin[1]) /
                                tmp_cc_info.text_attr.height;
                    OM_BLOCK_MOVE(&just_move,&text_info->just_moves[2],8);

                    just_move = tmp_cc_info.line_just_move / tmp_cc_info.text_attr.width;
                    OM_BLOCK_MOVE(&just_move,&text_info->just_moves[12],8);
                }
                else
                {
#ifdef DEBUG
                    printf("GRescape_chars: GRbwd_beg_esc_seq failed\n");
#endif
                }
            }
            break;

        case BEGIN_PREV_LINE:

            if (cc_info->cur_line == 2)
            {
                /*
                 *  the beginning of the previous line (the first line) is the
                 *  beginning of the text string; erase from the beginning of
                 *  the text string
                 */

                text_info->text_string = (IGRchar *)text_string;
                *erase_index = 0;
                *(text_info->estx) = *tx_attr;
                text_info->prev_font = -1;
                *cur_disp_attr = *disp_attr;
                text_info->flags = 0;  /* do not use the justification moves */
            }
            else   /* not the second line of text */
            {
                /*
                 *  must find the index of the first char on the previous line,
                 */

                num_chars = 1;
                esc_char = LINEFEED;  /* find previous linefeed escape seq */

                if (GRbwd_beg_esc_seq(&temp_msg,text_string,&num_chars,
                                      &esc_char,NULL,&cc_info->cur_char_index,
                                      font_info->flags,erase_index))
                {
                    if (GRbwd_beg_esc_seq(&temp_msg,text_string,&num_chars,
                                          &esc_char,NULL,erase_index,
                                          font_info->flags,&lf_esc_index))
                    {
                        /*
                         *  determine if a linefeed justification move escape
                         *  sequence follows the linefeed escape sequence
                         *  
                         */

                        if ((lf_esc_index + 2 < cc_info->cur_char_index) &&
                            (text_string[lf_esc_index + 2] == ESC) &&
                            (text_string[lf_esc_index + 3] == 'H'))
                        {
                            *erase_index = lf_esc_index + 12;
                        }
                        else
                        {
                            *erase_index = lf_esc_index + 2;
                        }
                        text_info->text_string = 
                                         (IGRchar *)&text_string[*erase_index];
                        tmp_cc_info = *cc_info;

                        /*
                         *  find the char info of the first char to erase
                         */

                        GRchar_pos_info(&temp_msg,text_string,*erase_index,
                                        FALSE,tx_attr,font_info,disp_attr,
                                        &tmp_cc_info);

                        *(text_info->estx) = tmp_cc_info.text_attr;
                        text_info->prev_font = tmp_cc_info.prev_font;
                        *cur_disp_attr = tmp_cc_info.disp_attr;
                        text_info->flags = 0x1;  /* use the justification moves */

                        just_move = (-tmp_cc_info.ss_v_move - tmp_cc_info.wk_origin[1]) /
                                    tmp_cc_info.text_attr.height;
                        OM_BLOCK_MOVE(&just_move,&text_info->just_moves[2],8);

                        just_move = tmp_cc_info.line_just_move / tmp_cc_info.text_attr.width;
                        OM_BLOCK_MOVE(&just_move,&text_info->just_moves[12],8);
                    }
                    else
                    {
#ifdef DEBUG
                        printf("GRescape_chars: GRbwd_lf_esc_index_seq failed\n");
#endif
                    }
                }
                else
                {
#ifdef DEBUG
                    printf("GRescape_chars: GRbwd_lf_esc_index_seq failed\n");
#endif
                }
            }
            break;

        case BEGIN_STRING:

            text_info->text_string = (IGRchar *)text_string;
            *erase_index = 0;
            *(text_info->estx) = *tx_attr;
            text_info->prev_font = -1;
            *cur_disp_attr = *disp_attr;
            text_info->flags = 0;  /* do not use the justification moves */
            break;

        default:

#ifdef DEBUG
            printf("GRerase_chars: unknown erase_from type\n");
#endif
            break;
    }   /* end switch (*erase_from) */

    /*
     *  find the length of the text sub-string to erase; the length of the
     *  sub-string to erase is found by subtracting the index for the beginning
     *  of the sub-string from the index for the end of the sub-string
     */

    switch (*erase_to)
    {
        case END_CUR_LINE:

            GRtext_eol(&temp_msg,text_string,&tx_attr->text_length,
                       &cc_info->cur_char_index,chars_eol);
            text_info->estx->text_length = (cc_info->cur_char_index + *chars_eol) - *erase_index;
            break;

        case END_STRING:

            text_info->estx->text_length = tx_attr->text_length - *erase_index;
            break;

        case PREV_CHAR:

            text_info->estx->text_length = cc_info->cur_char_index - *erase_index;
            break;

        default:

#ifdef DEBUG
            printf("GRerase_chars: unknown erase_to type\n");
#endif
            break;
    }   /* end switch (*erase_to) */
    return(TRUE);
}
