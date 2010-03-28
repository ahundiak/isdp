/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:  GRtext_fieldbox

     Abstract: 
                This function gets the position of the beginning of
     the field, calls a display function to calculate the two points
     needed to draw a vertical line in front of the field, and then
     displays the line by buffer.  The method also gets the position
     of the end of the field, calls a display function to calculate
     the two points needed to draw a vertical line after the field,
     and then displays the line by buffer. The two vertical lines are
     "connected" by two horizontal lines. Any linefeeds or vertical
     moves are interpreted and the field box is adjusted accordingly.
     Any change scale or change font is also incorporated into the
     size of the field box.
-----
%SC%    

    VALUE =  GRtext_fieldbox(msg,text_string,text_attr,font_info,disp_attr,
                             begin_field,draw_mode,lbs_geom,view_ind)
-----
%EN%
     ON ENTRY:

        NAME         DATA TYPE                      DESCRIPTION
     ----------      ------------   ------------------------------------
     *text_string    IGRuchar        text string
     *text_attr      struct IGRestx  element specific attr of text
     *font_info      struct vfont_entry font information
     *disp_attr      struct IGRdisplay display attributes
     *begin_field    IGRshort        position (index) where field begins
     *draw_mode      enum GRdpmode   mode to display in
     *lbs_geom       struct IGRlbsys local bounded system
     view_ind        IGRint          TRUE if the text string is view
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

     MODULES AND METHODS INVOKED:  dp$build_dis_buffer
                                   dp$display
                                   gr$get_active_display
                                   dp$get_char_under
                                   om$malloc
                                   GRfwd_esc_seq
                                   GRvg.GRgetgeom
                                   MA2ptdis
                                   MAsubvc
                                   MAptonvc
                                   MAaddvc
                                   OM_BLOCK_MOVE
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  Begin field position is the position in the text string
             where the field begins. This will be the ESC in the
             set field escape sequence. 
-----
%CH%

     CHANGE HISTORY:
        
        DEK  03/30/87: Design date.
        DEK  04/01/87: Creation date.
        DEK  04/21/87: Added capability for nested fields, change
                       font, and change scale.
        DEK  04/18/88: Changed so field box will begin at set field
                       (not first displayable character in field) 
                       and end at end field (not last displayable
                       character in field).
        DEK  09/09/88: Added display attributes.
        SCW  07/21/92: Ansi conversion
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

  This method gets the position of the beginning of the field, calls 
a display function to calculate the two points needed to draw a 
vertical line in front of the field, and then displays the line by 
buffer.  The method also gets the position of the end of the field, 
calls a display function to calculate the two points needed to draw 
a vertical line after the field, and then displays the line by buffer. 
The two vertical lines are "connected" by two horizontal lines. Any 
linefeeds or vertical moves are interpreted and the field box is 
adjusted accordingly. Any change scale or change font is also 
incorporated into the size of the field box.

----*/
/*EH*/

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

#define  BEGIN_FIELD_LENGTH      4
#define  JUSTIFIED_FIELD_LENGTH 19

IGRint GRtext_fieldbox(msg,text_string,text_attr,font_info,disp_attr,
                       begin_field,draw_mode,lbs_geom,view_ind)

IGRlong              *msg;            /* return code                         */
IGRuchar             *text_string;    /* text string                         */
struct    IGRestx    *text_attr;      /* element specific attr of text       */
struct vfont_entry   *font_info;      /* font information                    */
struct IGRdisplay    *disp_attr;      /* display attributes                  */
IGRshort             *begin_field;    /* position (index) where field begins */
enum GRdpmode        *draw_mode;      /* mode to display in                  */
struct IGRlbsys      *lbs_geom;       /* local bounded system                */
IGRint               view_ind;        /* TRUE if the text string is view     */
                                      /* independent, FALSE otherwise        */

{
    IGRboolean multi_mode;             /* TRUE-skip over mult esc seq      */
    IGRboolean first_line;             /* TRUE-on first line of string     */
    IGRboolean have_disp_char;         /* 'line' has displayable char      */
    IGRshort   elem_type;              /* polyline element type            */
    IGRshort   disp_position;          /* position of displayable char     */
    IGRshort   i;                      /* loop counter                     */
    IGRshort   correct_field;          /* correct end field esc seq?       */
    IGRshort   num_chars;              /* num chars moved over             */
    IGRshort   start_field;            /* first "displayable" char in      */
                                       /* the specified field              */
    IGRint     view_ind_type;          /* type of view independence        */
    IGRdouble  pt[6];                  /* points in vertical line          */
    IGRdouble  pt2[6];                 /* points in vertical line          */
    IGRdouble  horiz_pt[6];            /* points for horizontal line       */
    IGRdouble  distance;               /* distance of vertical line        */
    IGRdouble  save_distance;          /* distance of longest vert line    */
    IGRdouble  vector[3];              /* vector of vertical line          */
    IGRdouble  top_pt[6];              /* calculated "top" point           */
    IGRdouble  vert_pt[6];             /* points for vertical line         */
    IGRdouble  just_move;              /* justification move               */
    IGRpoint   view_ind_point;         /* point view independent about     */
    IGRlong    nbytes_in_buffer;       /* size of IGRdisplay               */
    IGRlong    nbytes_transferred;     /* num bytes transferred            */
    struct DPele_header buffer;        /* buffer to contain polyline
                                          structure used in underline      */
    struct IGRdisplay   dis_att;       /* displayable attributes           */
    struct IGRpolyline  polyline;      /* polyline structure               */
    struct IGResintx    text_info;     /* text information                 */
    struct GRcc_info    fld_char_info; /* text specific info about chars   */
                                       /* within the specified field       */
    GRspacenum          cur_mod_osnum; /* current module object space num  */

    *msg = MSSUCC;                     /* initialize to success            */
    elem_type = IGRPY;                 /* set type to polyline             */
    first_line = TRUE;
    have_disp_char = FALSE;
    correct_field = 0;
    view_ind_type = 0;
    polyline.num_points = 2;

    ex$get_cur_mod(osnum = &cur_mod_osnum);

    /*
     * move starting index past the begin field escape sequence
     */

    start_field = *begin_field +  BEGIN_FIELD_LENGTH;

    /*
     * if the specified field is justified, skip the field justification moves
     */

    if ((text_string[start_field] == ESC) &&
        (text_string[start_field + 1] == 'm'))
    {
        start_field += JUSTIFIED_FIELD_LENGTH;
    }

    /*
     *  find the attributes and working origin of the char that begins 
     *  the specified field
     */

    GRchar_pos_info(msg,text_string,start_field,FALSE,
                    text_attr,font_info,disp_attr,&fld_char_info);

    /*
     * set up text information for display function
     */

    text_info.font_id = cur_mod_osnum;
    text_info.estx = &fld_char_info.text_attr;
    text_info.flags = 0x1;
    text_info.just_moves[0] = ESC;
    text_info.just_moves[1] = 'h';
    text_info.just_moves[10] = ESC;
    text_info.just_moves[11] = 'v';
    text_info.text_string = (IGRchar *)&(text_string[start_field]);

    /*
     *  must calculate the horizontal and vertical
     *  moves to get to the begin field char
     */

    just_move = (fld_char_info.line_just_move + fld_char_info.wk_origin[0]) /
                fld_char_info.text_attr.width;
    OM_BLOCK_MOVE(&just_move,&text_info.just_moves[2],8);

    just_move = (fld_char_info.ss_v_move + fld_char_info.wk_origin[1]) /
                fld_char_info.text_attr.height;
    OM_BLOCK_MOVE(&just_move,&text_info.just_moves[12],8);

    /*
     * get the attributes used to display the horizontal
     * and vertical lines
     */

    nbytes_in_buffer = sizeof(dis_att);

    gr$get_active_display(msg = msg,
                          sizbuf = &nbytes_in_buffer,
                          buffer = &dis_att,
                          nret = &nbytes_transferred);

    dis_att.weight = 0;   /* always make field box of weight zero */

    /*
     * calculate the two points that determine a vertical line
     * at the beginning of the field
     */

    dp$get_char_under(msg = msg,
                      lbsys = lbs_geom,
                      txt_ele = &text_info,
                      osnum = cur_mod_osnum,
                      which_char = 0,
                      which_point = 1,
                      horizontal = FALSE,
                      point1 = pt,
                      point2 = &pt[3]);

    /*
     * save the distance of the vertical line in front of the field and
     * the top point in case there is no displayable character in the
     * first line
     */

    MA2ptdis(msg,pt,&pt[3],&save_distance);

    horiz_pt[0] = pt[3];
    horiz_pt[1] = pt[4];
    horiz_pt[2] = pt[5];

    /*
     * search string for vertical move, set field, end of field, linefeed,
     * change scale (y), or change font
     */

    for (i = start_field; i < text_attr->text_length; ++i)
    {
        if (text_string[i] == ESC)
        {
            if ((text_string[i + 1] == 'v') ||
                (text_string[i + 1] == 'M') ||
                (text_string[i + 1] == 'm') ||
                (text_string[i + 1] == LINEFEED))
            {
                /*
                 * vertical move of some sort
                 */

                if (have_disp_char)
                {
                    /*
                     * calculate the two points that determine a vertical
                     * line before a particular character in a text string
                     */

                    /*
                     *  find the attributes and working origin of the
                     *  specified char
                     */

                    GRchar_pos_info(msg,text_string,i,TRUE,
                                    text_attr,font_info,disp_attr,
                                    &fld_char_info);

                    /*
                     *  must calculate the horizontal and vertical
                     *  moves to get to the begin field char
                     */

                    just_move = (fld_char_info.line_just_move + fld_char_info.wk_origin[0]) /
                                fld_char_info.text_attr.width;
                    OM_BLOCK_MOVE(&just_move,&text_info.just_moves[2],8);

                    just_move = (fld_char_info.ss_v_move + fld_char_info.wk_origin[1]) /
                                fld_char_info.text_attr.height;
                    OM_BLOCK_MOVE(&just_move,&text_info.just_moves[12],8);

                    dp$get_char_under(msg = msg,
                                      lbsys = lbs_geom,
                                      txt_ele = &text_info,
                                      osnum = cur_mod_osnum,
                                      which_char = 0,
                                      which_point = 1,
                                      horizontal = FALSE,
                                      point1 = pt2,
                                      point2 = &pt2[3]);

                    /*
                     * set up polyline to draw the lower horizontal line
                     */

                    horiz_pt[0] = pt[0];
                    horiz_pt[1] = pt[1];
                    horiz_pt[2] = pt[2];
                    horiz_pt[3] = pt2[0];
                    horiz_pt[4] = pt2[1];
                    horiz_pt[5] = pt2[2];

                    polyline.points = &horiz_pt[0];
      
                    /*
                     * build the buffer used in displaying the horizontal line
                     */

                    dp$build_dis_buffer(buffer = &buffer,
                                        type = elem_type,
                                        display_att = &dis_att,
                                        geometry = &polyline);

                    /*
                     * display the bottom horizontal line; if the text is
                     * view independent, must initialize info for display
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
                     * set up the polyline to draw the upper horizontal line
                     * but first see if the points  at the beginning and
                     * end of this line are "tall" enough
                     */

                    MA2ptdis(msg,pt,&pt[3],&distance);
      
                    if (save_distance > distance)
                    {
                       /*
                        * calculate top point needed at front of line
                        */

                       MAsubvc(msg,&pt[3],pt,vector);

                       MAptonvc(msg,vector,&save_distance,top_pt);

                       MAaddvc(msg,top_pt,pt,top_pt);

                       horiz_pt[0] = top_pt[0];
                       horiz_pt[1] = top_pt[1];
                       horiz_pt[2] = top_pt[2];
                    }
                    else
                    {
                       horiz_pt[0] = pt[3];
                       horiz_pt[1] = pt[4];
                       horiz_pt[2] = pt[5];
                    }

                    MA2ptdis(msg,pt2,&pt2[3],&distance);
      
                    if (save_distance > distance)
                    {
                       /*
                        * calculate top point needed at end of line
                        */

                       MAsubvc(msg,&pt2[3],pt2,vector);

                       MAptonvc(msg,vector,&save_distance,&top_pt[3]);

                       MAaddvc(msg,&top_pt[3],pt2,&top_pt[3]);

                       horiz_pt[3] = top_pt[3];
                       horiz_pt[4] = top_pt[4];
                       horiz_pt[5] = top_pt[5];
                    }
                    else
                    {
                       horiz_pt[3] = pt2[3];
                       horiz_pt[4] = pt2[4];
                       horiz_pt[5] = pt2[5];
                    }

                    polyline.points = &horiz_pt[0];

                    /*
                     * build the buffer used in displaying the horizontal line
                     */

                    dp$build_dis_buffer(buffer = &buffer,
                                        type = elem_type,
                                        display_att = &dis_att,
                                        geometry = &polyline);

                    /*
                     * display the top horizontal line; if the text is
                     * view independent, must initialize info for display
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
                }

                /*
                 * if this is the first line in the field, draw the
                 * vertical line in front of the field
                 */

                if (first_line)
                {
                    vert_pt[0] = pt[0];
                    vert_pt[1] = pt[1];
                    vert_pt[2] = pt[2];
                    vert_pt[3] = horiz_pt[0];
                    vert_pt[4] = horiz_pt[1];
                    vert_pt[5] = horiz_pt[2];

                    polyline.points = &vert_pt[0];

                    /*
                     * build the buffer used in displaying the vertical line
                     */

                    dp$build_dis_buffer(buffer = &buffer,
                                        type = elem_type,
                                        display_att = &dis_att,
                                        geometry = &polyline);

                    /*
                     * display the front vertical line; if the text is
                     * view independent, must initialize info for display
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
                }

                /*
                 * calculate the actual character position of the
                 * next character in the field
                 */
     
                multi_mode = FALSE;
                disp_position = i;

                GRfwd_esc_seq(msg,text_string,
                              &text_attr->text_length,&multi_mode,
                              &disp_position,&num_chars);

                disp_position += num_chars;

                /*
                 * if the current char is a linefeed escape sequence, must
                 * move past it and its horizontal justification move (if it
                 * has one) to get to the first char on the next line
                 */

                if ((text_string[disp_position] == ESC) &&
                    (text_string[disp_position + 1] == LINEFEED))
                {
                    disp_position += 2;

                    if ((text_string[disp_position] == ESC) &&
                        (text_string[disp_position + 1] == 'H'))
                    {
                        disp_position += 10;
                    }
                }

                /*
                 * calculate the two points that determine a vertical line
                 * before a particular character in a text string
                 */

                /*
                 *  find the attributes and working origin of the
                 *  specified char
                 */

                GRchar_pos_info(msg,text_string,disp_position,TRUE,
                                text_attr,font_info,disp_attr,
                                &fld_char_info);

                /*
                 *  must calculate the horizontal and vertical
                 *  moves to get to the begin field char
                 */

                just_move = (fld_char_info.line_just_move + fld_char_info.wk_origin[0]) /
                            fld_char_info.text_attr.width;
                OM_BLOCK_MOVE(&just_move,&text_info.just_moves[2],8);

                just_move = (fld_char_info.ss_v_move + fld_char_info.wk_origin[1]) /
                            fld_char_info.text_attr.height;
                OM_BLOCK_MOVE(&just_move,&text_info.just_moves[12],8);

                dp$get_char_under(msg = msg,
                                  lbsys = lbs_geom,
                                  txt_ele = &text_info,
                                  osnum = cur_mod_osnum,
                                  which_char = 0,
                                  which_point = 1,
                                  horizontal = FALSE,
                                  point1 = pt,
                                  point2 = &pt[3]);
                /*
                 * save the distance of the vertical line in front of
                 * the new line
                 */

                MA2ptdis(msg,pt,&pt[3],&save_distance);

                first_line = FALSE;
                have_disp_char = FALSE;

                if (text_string[i + 1] == LINEFEED)
                {
                    ++i;
                }
                else if (text_string[i + 1] == 'v')
                {
                    i += 9;
                }
                else if (text_string[i + 1] == 'M')
                {
                    i += 19;
                }
                else if (text_string[i + 1] == 'm')
                {
                    i += 18;
                }
            }
            else if ((text_string[i + 1] == 'y') ||
                     (text_string[i + 1] == 's') ||
                     (text_string[i + 1] == 'f') ||
                     ((text_string[i + 1] == 'p') && 
                      (text_string[i + 2] & POP_FONT)))
            {
                /*
                 * scale changed in y direction or font has changed
                 */

                multi_mode = FALSE;
                disp_position = i;

                GRfwd_esc_seq(msg,text_string,
                              &text_attr->text_length,&multi_mode,
                              &disp_position,&num_chars);

                disp_position += num_chars;

                /*
                 *  find the attributes and working origin of the
                 *  specified char
                 */

                GRchar_pos_info(msg,text_string,disp_position,TRUE,
                                text_attr,font_info,disp_attr,&fld_char_info);

                /*
                 *  must calculate the horizontal and vertical
                 *  moves to get to the begin field char
                 */

                just_move = (fld_char_info.line_just_move + fld_char_info.wk_origin[0]) /
                            fld_char_info.text_attr.width;
                OM_BLOCK_MOVE(&just_move,&text_info.just_moves[2],8);

                just_move = (fld_char_info.ss_v_move + fld_char_info.wk_origin[1]) /
                            fld_char_info.text_attr.height;
                OM_BLOCK_MOVE(&just_move,&text_info.just_moves[12],8);

                dp$get_char_under(msg = msg,
                                  lbsys = lbs_geom,
                                  txt_ele = &text_info,
                                  osnum = cur_mod_osnum,
                                  which_char = 0,
                                  which_point = 1,
                                  horizontal = FALSE,
                                  point1 = pt2,
                                  point2 = &pt2[3]);

                MA2ptdis(msg,pt2,&pt2[3],&distance);

                if (distance > save_distance)
                {
                    save_distance = distance;
                }
                i += num_chars - 1;
            }
            else if ((text_string[i + 1] == 'E') &&
                     (correct_field == 0))                    /* end field */
            {
                /*
                 * calculate the two points that determine a vertical
                 * line before a particular character in a textstring
                 */

                /*
                 *  find the attributes and working origin of the
                 *  specified char
                 */

                GRchar_pos_info(msg,text_string,i,TRUE,
                                text_attr,font_info,disp_attr,&fld_char_info);

                /*
                 *  must calculate the horizontal and vertical
                 *  moves to get to the begin field char
                 */

                just_move = (fld_char_info.line_just_move + fld_char_info.wk_origin[0]) /
                            fld_char_info.text_attr.width;
                OM_BLOCK_MOVE(&just_move,&text_info.just_moves[2],8);

                just_move = (fld_char_info.ss_v_move + fld_char_info.wk_origin[1]) /
                            fld_char_info.text_attr.height;
                OM_BLOCK_MOVE(&just_move,&text_info.just_moves[12],8);

                dp$get_char_under(msg = msg,
                                  lbsys = lbs_geom,
                                  txt_ele = &text_info,
                                  osnum = cur_mod_osnum,
                                  which_char = 0,
                                  which_point = 1,
                                  horizontal = FALSE,
                                  point1 = pt2,
                                  point2 = &pt2[3]);

                /*
                 * set up polyline to draw the lower horizontal line
                 */

                horiz_pt[0] = pt[0];
                horiz_pt[1] = pt[1];
                horiz_pt[2] = pt[2];
                horiz_pt[3] = pt2[0];
                horiz_pt[4] = pt2[1];
                horiz_pt[5] = pt2[2];

                polyline.points = &horiz_pt[0];

                /*
                 * build the buffer used in displaying the horizontal line
                 */

                dp$build_dis_buffer(buffer = &buffer,
                                    type = elem_type,
                                    display_att = &dis_att,
                                    geometry = &polyline);

                /*
                 * display the bottom horizontal line; if the text is
                 * view independent, must initialize info for display
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
                 * set up the polyline to draw the upper horizontal line
                 * but first see if the points  at the beginning and
                 * end of this line are "tall" enough
                 */

                MA2ptdis(msg,pt,&pt[3],&distance);

                if (save_distance > distance)
                {
                    /*
                     * calculate top point needed at front of line
                     */

                    MAsubvc(msg,&pt[3],pt,vector);

                    MAptonvc(msg,vector,&save_distance,top_pt);

                    MAaddvc(msg,top_pt,pt,top_pt);

                    horiz_pt[0] = top_pt[0];
                    horiz_pt[1] = top_pt[1];
                    horiz_pt[2] = top_pt[2];
                }
                else
                {
                    horiz_pt[0] = pt[3];
                    horiz_pt[1] = pt[4];
                    horiz_pt[2] = pt[5];
                }

                MA2ptdis(msg,pt2,&pt2[3],&distance);

                if (save_distance > distance)
                {
                    /*
                     * calculate top point needed at end of line
                     */

                    MAsubvc(msg,&pt2[3],pt2,vector);

                    MAptonvc(msg,vector,&save_distance,&top_pt[3]);

                    MAaddvc(msg,&top_pt[3],pt2,&top_pt[3]);

                    horiz_pt[3] = top_pt[3];
                    horiz_pt[4] = top_pt[4];
                    horiz_pt[5] = top_pt[5];
                }
                else
                {
                    horiz_pt[3] = pt2[3];
                    horiz_pt[4] = pt2[4];
                    horiz_pt[5] = pt2[5];
                }

                polyline.points = &horiz_pt[0];

                /*
                 * build the buffer used in displaying the horizontal line
                 */

                dp$build_dis_buffer(buffer = &buffer,
                                    type = elem_type,
                                    display_att = &dis_att,
                                    geometry = &polyline);

                /*
                 * display the top horizontal line; if the text is
                 * view independent, must initialize info for display
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
                 * if this is the first line in the field, draw the
                 * vertical line in front of the field
                 */

                if (first_line)
                {
                    vert_pt[0] = pt[0];
                    vert_pt[1] = pt[1];
                    vert_pt[2] = pt[2];
                    vert_pt[3] = horiz_pt[0];
                    vert_pt[4] = horiz_pt[1];
                    vert_pt[5] = horiz_pt[2];

                    polyline.points = &vert_pt[0];

                    /*
                     * build the buffer used in displaying the vertical line
                     */

                    dp$build_dis_buffer(buffer = &buffer,
                                        type = elem_type,
                                        display_att = &dis_att,
                                        geometry = &polyline);

                    /*
                     * display the front vertical line; if the text is
                     * view independent, must initialize info for display
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
                }

                /*
                 * set up polyline to draw the vertical line at
                 * the end of the field
                 */

                vert_pt[0] = pt2[0];
                vert_pt[1] = pt2[1];
                vert_pt[2] = pt2[2];
                vert_pt[3] = horiz_pt[3];
                vert_pt[4] = horiz_pt[4];
                vert_pt[5] = horiz_pt[5];

                polyline.points = &vert_pt[0];

                /*
                 * build the buffer used in displaying the vertical line
                 */

                dp$build_dis_buffer(buffer = &buffer,
                                    type = elem_type,
                                    display_att = &dis_att,
                                    geometry = &polyline);

                /*
                 * display the vertical line at the end of the field;
                 * if the text is view independent, must initialize info
                 * for display
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

                first_line = FALSE;
                i = text_attr->text_length;
            }
            else if (text_string[i + 1] == 'E')  
            {
                                                      /* nested end field */
                --correct_field;
                ++i;
            }
            else if (text_string[i + 1] == 'F')
            {
                                                      /* nested set field */
                ++correct_field;
                i += 3;
            }
            else if (text_string[i + 1] == ESC)
            {
                /*
                 * ESC ESC is a displayable character; increment over it
                 */

                ++i;
                have_disp_char = TRUE;
            }
            else                  /* other escape sequence - skip over it */
            {
                multi_mode = FALSE;

                GRfwd_esc_seq(msg,text_string,
                              &text_attr->text_length,&multi_mode,
                              &i,&num_chars);

                i += (num_chars - 1);
            }
        }                                   /* text_string[i] is not ESC */
        else
        {                          /* displayable character */
            have_disp_char = TRUE;
        }
    }
    return (TRUE);
}
