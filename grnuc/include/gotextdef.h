/*
 * Include file for text objects (#defines only)
 */

#ifndef gotextdef_include
#define gotextdef_include

#define  TEXT_BUF_SIZE  200
#define  LINEFEED       0xa
#define  ESC            0x1b
#define  DEL            0x7f
#define  FRACTION_KEY   0x01

/*
 * text justifications
 */

#define  LEFT_BOTTOM    0
#define  LEFT_BASE      1
#define  LEFT_CENTER    2
#define  LEFT_CAP       3
#define  LEFT_TOP       4

#define  CENTER_BOTTOM  5
#define  CENTER_BASE    6
#define  CENTER_CENTER  7
#define  CENTER_CAP     8
#define  CENTER_TOP     9

#define  RIGHT_BOTTOM   10
#define  RIGHT_BASE     11
#define  RIGHT_CENTER   12
#define  RIGHT_CAP      13
#define  RIGHT_TOP      14

/*
 * #defines for the Active_flags member of the structure GRdpb_text_symb in
 * grdpb.h
 */

#define  GRFILLED_TEXT  0x1

#define  issixteen(c) ((c > 0x7f) ? 1 : 0)

/* 
 * view independent flag (currently used in dpb Active_flags and
 * text specific attributes);
 * empty text flag (currently used in text specific attributes)
 */

#define  VI_FLAG         0x01
#define  EMPTY_TEXT_FLAG 0x02

/*
 * bitmask definitions for the method GRchgtextattr
 */

#define GRTEXT_FONT     0x1    /* text font              */
#define GRTEXT_JUST     0x2    /* text justification     */
#define GRTEXT_LN_SP    0x4    /* text line spacing      */
#define GRTEXT_CHAR_SP  0x8    /* text character spacing */
#define GRTEXT_HEIGHT   0x10   /* text height            */
#define GRTEXT_WIDTH    0x20   /* text width             */

/*
 *  types of edit actions
 */

#define INSERT_CHAR  0
#define INSERT_LF    1
#define DELETE_CHAR  2
#define DELETE_LF    3

/*
 *  positions to erase from
 */

#define CURRENT_CHAR     0
#define PREV_EDIT_CHAR   1
#define BEGIN_CUR_LINE   2
#define BEGIN_PREV_LINE  3
#define BEGIN_STRING     4

/*
 *  positions to erase to
 */

#define END_CUR_LINE  0
#define END_STRING    1
#define PREV_CHAR     2

/*
 * types of fields
 */

#define NO_FLD           0x0
#define MV_REF_PT_FLD    0x1
#define JUSTIFIED_FLD    0x2
#define FIXED_LENGTH_FLD 0x4

/*
 * bitmask definitions for the flags member of struct GRcc_info (in gotext.h)
 */

#define FIXED_LENGTH_FIELD 0x1
#define JUSTIFIED_FIELD    0x2
#define EMPTY_FIELD        0x4
#define PREV_CHAR_DISP     0x8  /* previous character is displayable   */
#define KERNING_PAIRS      0x10 /* current font may have kerning pairs */
                                /* mode on - otherwise it's off        */

/*
 * #defines for the attribute byte of the "pop" escape sequence
 */

#define POP_FONT 0x1

/*
 * #defines for the co$place_text macro
 */

#define GRTX_DISPLAY      0x1    /* display the text               */
#define GRTX_EMPTY        0x2    /* empty text                     */

/*
 * text flags for the fuction GRtext_along_curve
 */

#define GRTX_REV_SIDE     0x1 /* the text should be on the reverse side of the
                               curve (use cap instead of base justification) */
#endif
