#ifndef  gotext_include
#define  gotext_include

/* this include file is dependent on font.h, igrtypedef.h and igrdp.h */

enum  font_type   {seven,eight,sixteen};

struct extents                              /* extents of text string     */
{
   IGRdouble      top;
   IGRdouble      cap;
   IGRdouble      right;
   IGRdouble      bottom;
   IGRdouble      base;
   IGRdouble      left;
};

struct just_info                     /* extents info of text string         */
{
   IGRint         num_lines;         /* number of lines of text element     */
   IGRint         just_esc_pos;      /* position after last linefeed        */
   IGRdouble      cur_line_left;     /* left extent of the current line     */
   IGRdouble      cur_line_right;    /* right extent of the current line    */
};

struct just_pts
{
   IGRpoint        left_bottom;
   IGRpoint        left_base;
   IGRpoint        left_center;
   IGRpoint        left_cap;
   IGRpoint        left_top;
   IGRpoint        center_bottom;
   IGRpoint        center_base;
   IGRpoint        center_center;
   IGRpoint        center_cap;
   IGRpoint        center_top;
   IGRpoint        right_bottom;
   IGRpoint        right_base;
   IGRpoint        right_center;
   IGRpoint        right_cap;
   IGRpoint        right_top;
};

struct  GRcc_info
{
    struct IGRestx     text_attr;      /* text attributes at current char    */
    struct IGRdisplay  disp_attr;      /* display attributes at current char */
    struct vfont_entry font_info;      /* font information at current char   */
    IGRshort           cur_line;       /* line current char is on            */
    IGRshort           cur_user_pos;   /* current user position              */
    IGRshort           cur_char_index; /* index of current char              */
    short   unsigned   flags;          /* informational bitmask              */
    IGRuchar	       field_delim;    /* depth the current char is nested in*/
                                       /* fields                             */
    IGRshort           field_position; /* index of the beginning of the      */
                                       /* innermost field current char is in */
    IGRdouble          wk_origin[2];   /* working origin of the current char */
    IGRdouble          kern_value;     /* kerning pair value of prev_char and*/
                                       /* the current char                   */
    IGRdouble          base_line;      /* base line at the current char      */
    IGRdouble          ss_v_move;      /* stroke start vertical move         */
    IGRdouble          line_just_move; /* horizontal justification move for  */
                                       /* the current line                   */
    IGRshort           prev_font;      /* font used previously in text string*/
};

#endif
