/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE  NAME:  GRtext_cursor

     Abstract: 
                This function gets the displayable position in the
     text string, calls a display function to calculate the two
     points needed to draw an underline, a vertical line in front
     of the character, or a vertical line after the character and 
     then displays the line by buffer.
-----
%SC%    

    VALUE =  GRtext_cursor(msg,text_string,cc_info,text_attr,
                           lbs_geom,draw_mode,line_mode,view_ind)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -------------------------------------
     *text_string IGRuchar         text string
     *cc_info     struct GRcc_info information about char at which
                                   the cursor is to be displayed
     *text_attr   struct IGRestx   element specific attr of text
     *lbs_geom    struct IGRlbsys  local bounded system geom. of string
     *draw_mode   enum GRdpmode    how to draw line
     *line_mode   IGRshort         which line to draw
                                   0 = horizontal
                                   1 = vertical before
                                   2 = vertical after
     view_ind     IGRint           TRUE if the text string is view
                                   independent, FALSE otherwise
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg          IGRlong         completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
                                      due to allocation problems
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules: 

     Methods:  none.
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.
-----
%CH%

     CHANGE HISTORY:
        
        DKM     10/27/86: Design date.
        DKM     10/27/86: Creation date.
        WBC     06/13/88: Converted from a method to a function.
        SCW     07/21/92: Ansi conversion
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
       This function gets the displayable position in the
text string, calls a display function to calculate the two
points needed to draw an underline, and then displays the
line by buffer.
        
----*/
/*EH*/

class implementation GRtext;

#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dpstruct.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "fontdef.h"
#include "font.h"
#include "gotextdef.h"
#include "gotext.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "ex.h"
#include "exmacros.h"
#include "fontdef.h"
#include "grdpbdef.h"
#include "grdpb.h"

#define CURSOR_SCALE_FACT  0.25

from GRfm import GRfm_retdata;

IGRint GRtext_cursor(msg,text_string,cc_info,text_attr,
                     lbs_geom,draw_mode,line_mode,view_ind)

IGRlong             *msg;           /* completion code                      */
IGRuchar            *text_string;   /* text string                          */
struct GRcc_info    *cc_info;       /* information about char at which the  */
                                    /* cursor is to be displayed            */
struct    IGRestx   *text_attr;     /* element specific attr of text        */
struct    IGRlbsys  *lbs_geom;      /* local bounded system geom. of string */
enum      GRdpmode  *draw_mode;     /* how to draw line                     */
IGRshort            *line_mode;     /* which line to draw:                  */
                                    /*  0 = horizontal                      */
                                    /*  1 = vertical before                 */
                                    /*  2 = vertical after                  */
IGRint              view_ind;       /* TRUE if the text string is view      */
                                    /* independent, FALSE otherwise         */

{
    IGRdouble  pt[6];                  /* points in underline               */
    IGRdouble  scale;
    IGRdouble  just_move;              /* justification move to cursor char */
    IGRpoint   view_ind_point;         /* point view independent about      */
    IGRlong    nbytes_in_buffer;       /* size of IGRdisplay                */
    IGRlong    nbytes_transferred;     /* size of IGRdisplay ??             */
    IGRint     which_line;             /* horizontal or vertical line       */
    IGRint     horizontal;             /* horizontal or vertical line       */
    IGRint     view_ind_type;          /* type of view independence         */
    IGRshort   s_hold;                 /* used to store a short from        */
                                       /* the text string                   */
    struct DPele_header buffer;        /* buffer to contain polyline        */
                                       /* structure used in underline       */
    struct IGRdisplay   dis_att;       /* displayable attributes            */
    struct IGRpolyline  polyline;      /* polyline structure                */
    struct IGResintx    text_info;     /* text information                  */
    struct IGRestx      tx_attr;       /* text specific attributes          */
    struct GRid         fontmgr_obj;   /* font manager object               */
    struct vfont_entry  temp_font_info;/* font information                  */
    OM_S_OBJID          cur_mod_id;    /* current module id                 */
    GRspacenum          cur_mod_osnum; /* current module object space num   */

    *msg = MSSUCC;                     /* initialize to success          */
    horizontal = 0;
    view_ind_type = 0;
    which_line = 0;

    ex$get_cur_mod(id = &cur_mod_id,
                   osnum = &cur_mod_osnum);

    text_info.estx = &tx_attr;   /* memory for the text specific attributes */

    text_info.font_id = cur_mod_osnum;
    tx_attr = cc_info->text_attr;

    text_info.estx->text_length = 1;

    /*
     * set the text string to a blank char since the justification moves
     * already move to the position the cursor should be displayed; that is,
     * dp$get_char_under doesn't need to move past any chars, it is already at
     * the cursor position; the blank char doesn't have any special meaning,
     * any 7 bit char could be used
     */

    text_info.text_string = " ";

    text_info.flags = 0x1;     /* use just_moves */

    /*
     *  calculate moves to the char where the cursor is to be displayed
     */

    text_info.just_moves[0] = ESC;    /* horizontal move escape sequence */
    text_info.just_moves[1] = 'h';
    text_info.just_moves[10] = ESC;   /* vertical move escape sequence   */
    text_info.just_moves[11] = 'v';

    just_move = (cc_info->line_just_move + cc_info->wk_origin[0]) /
                cc_info->text_attr.width;
    OM_BLOCK_MOVE(&just_move,&(text_info.just_moves[2]),8);

    just_move = (cc_info->ss_v_move + cc_info->wk_origin[1]) /
                cc_info->text_attr.height;
    OM_BLOCK_MOVE(&just_move,&(text_info.just_moves[12]),8);

    /* 
     * set up which line to draw
     */

    if (*line_mode == 0)          /* horizontal line */
    {
       horizontal = TRUE;
       which_line = 1;
    }
    else if (*line_mode == 1)     /* vertical line before */
    {
       horizontal = FALSE;
       which_line = 1;
    }
    else if (*line_mode == 2)     /* vertical line after */
    {
       horizontal = FALSE;
       which_line = 2;
    }

    /*
     * calculate the two points that determine the line
     * of a particular displayable character in a text string;
     * Kludge: display routine begins with index 1 instead of 0
     */

    dp$get_char_under(msg = msg,
                      lbsys = lbs_geom,
                      txt_ele = &text_info,
                      osnum = cur_mod_osnum,
                      which_char = 0,
                      which_point = which_line,
                      horizontal = horizontal,
                      point1 = pt,
                      point2 = &pt[3]);

    if (! horizontal)
    {
        scale = CURSOR_SCALE_FACT;
        GR2ptlsext(msg,pt,&pt[3],&scale,pt,&pt[3]);
    }
    polyline.num_points = 2;
    polyline.points = pt;

    /*
     * get the attributes to display the underline with
     */

    nbytes_in_buffer = sizeof(dis_att);

    gr$get_active_display(msg = msg,
                          sizbuf = &nbytes_in_buffer,
                          buffer = &dis_att,
                          nret = &nbytes_transferred);

    dis_att.weight = 2;
    dis_att.style = 0;  /* display a solid line */

    /*
     * build the buffer used in displaying the underline
     */

    dp$build_dis_buffer(buffer = &buffer,
                        type = IGRPY,
                        display_att = &dis_att,
                        geometry = &polyline);

    /*
     * display the underline; if the text is view independent, must initialize
     * info for display
     */

    if (view_ind)
    {
       view_ind_type = ROTATION_IND;
       view_ind_point[0] = lbs_geom->matrix[3];
       view_ind_point[1] = lbs_geom->matrix[7];
       view_ind_point[2] = lbs_geom->matrix[11];
    }

    dp$display(msg = msg,
               mode = *draw_mode,
               buffer = &buffer,
               view_ind = view_ind,
               view_ind_type = view_ind_type,
               view_ind_point = view_ind_point);

    /*
     *  display informative message in the error field if actual position
     *  is at a non-displayable escape sequence
     */

    if (cc_info->flags & EMPTY_FIELD)
    {
        ex$message(msgnumb = GR_I_EmpFld);
    }
    else if ((cc_info->cur_char_index < text_attr->text_length) &&
             (text_string[0] == ESC) &&
             (text_string[1] != LINEFEED) &&
             (text_string[1] != ESC))
    {
        switch (text_string[1])
        {
            case 'F':    /* begin field escape sequence */

                ex$message(msgnumb = GR_I_BeginField);
                break;

            case 'E':    /* end field escape sequence */

                ex$message(msgnumb = GR_I_EndField);
                break;

            case 'h':    /* horizontal move escape sequence */

                ex$message(msgnumb = GR_I_HorizontalMove);
                break;

            case 'v':    /* vertical move escape sequence */

                ex$message(msgnumb = GR_I_VerticalMove);
                break;

            case 'f':    /* change font escape sequence */

                /*
                 * if changing to a fraction font, don't display the change
                 * font informational message since the user isn't suppose
                 * to be aware change font and pop font esc sequences
                 * enclose fraction char(s)
                 */

                ex$get_super(mod_id = cur_mod_id,
                             mod_osnum = cur_mod_osnum,
                             super_name = FONTMGR_NO_NAME,
                             create = TRUE,
                             super_class = "GRfm",
                             super_id = &fontmgr_obj.objid,
                             super_osnum = &fontmgr_obj.osnum);

                OM_BLOCK_MOVE(&(text_string[2]),
                              &s_hold,2);

                om$send(mode = OM_e_wrt_object,
                        msg = message GRfm.GRfm_retdata
                                       (msg,&s_hold,
                                        &temp_font_info),
                        senderid = NULL_OBJID,
                        targetid = fontmgr_obj.objid,
                        targetos = cur_mod_osnum);

                if (!(temp_font_info.flags & FRACTION_FONT))
                {
                    ex$message(msgnumb = GR_I_ChngFnt);
                }
                break;

            case 's':    /* change x and y scale escape sequence */

                ex$message(msgnumb = GR_I_ChngXYScale);
                break;

            case 'x':    /* change x scale escape sequence */

                ex$message(msgnumb = GR_I_ChngXScale);
                break;

            case 'y':    /* change y scale escape sequence */

                ex$message(msgnumb = GR_I_ChngYScale);
                break;

            case 'M':    /* move to field reference point escape sequence */

                ex$message(msgnumb = GR_I_MvFldRefPt);
                break;

            case 'p':    /* pop font escape sequence */

                if (text_string[2] & POP_FONT)
                {
                   ex$message(msgnumb = GR_I_PopFont);
                }

                break;

            case 'w':    /* change weight escape sequence */

                ex$message(msgnumb = GR_I_ChngWght);
                break;

            case 'C':    /* change character spacing escape sequence */

                ex$message(msgnumb = GR_I_ChngChrSp);
                break;

            default:    /* unknown escape sequence */

                ex$message(field = ERROR_FIELD,
                           in_buff = "");
                break;
        }
    }
    else   /* clear error field */
    {
        ex$message(field = ERROR_FIELD,
                   in_buff = "");
    }
    return(TRUE);
}
end implementation GRtext;
