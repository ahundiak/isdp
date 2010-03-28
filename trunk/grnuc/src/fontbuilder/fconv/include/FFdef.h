/*
$Log: FFdef.h,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:47  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:02  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:01  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:52:10  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:28  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:42:29  tim
 * COMMENT : added Log variable
 *
*/

#ifndef FFdef_include
#define FFdef_include

/* used in FSunitcnv() */
#define FF_POINT      0
#define FF_PICA       1
#define FF_INCH       2
#define FF_METER      3
#define FF_CENTIMETER 4
#define FF_MILLIMETER 5
#define FF_CICERO     6
#define FF_DIDOT      7
#define	FF_DIT        8
#define	FF_PIXEL      9
#define FF_ORUS      10
#define FF_PAGE      11

#define LEFTJ               (1)
#define RIGHTJ              (2)
#define CENTERJ             (4)
#define LINEJ               (8)
#define LEFTJ_HYPHENATE    (16)
#define RIGHTJ_HYPHENATE   (32)
#define CENTERJ_HYPHENATE  (64)
#define LINEJ_HYPHENATE   (128)

#define   GADGET_FONT  "/usr/ip32/resrc/fontserver/typeface/swiss742.tf"
#define   FONTSERVER_PATH  "/usr/ip32/resrc/fontserver/typeface"

#define BACKGROUND  (0)
#define BLACK       (0)
#define BLUE        (1)
#define L_GREEN	    (2)
#define L_BLUE	    (3)
#define RED         (4)
#define MAGENTA     (5)
#define YELLOW      (6)
#define WHITE       (7)
#define LABEL_COLOR (8)
#define HIGHLIGHT   (8)
#define L_GREY      (8)
#define M1_GREY     (9)
#define M2_GREY     (10)
#define D_GREY      (11)
#define D_GREEN	    (12)
#define D_BROWN	    (13)
#define ORANGE      (14)
#define FORGROUND   (15)


/*
 *   Bitstream standard macros and definitions
 *
 *   A NOTE ON BOOLEAN VALUES:
 *        FALSE/false is zero. TRUE/true is only guaranteed to be non-zero.
 *        These constants will work across the assignment (Ou) operator,
 *        but not across the equivalence (=) operator,
 *        due to truncation and sign extension.
 *        The only good test for TRUE/true (non-zero) is: if (expression)
 *        The only valid for FALSE/false (zero) is: if (! expression)
 *   REMEMBER to cast defined values when using them in return() statements.
 */

#define   FS_FILES    (0)
#define   AFM_FILES   (1)
#define   FLIB_FILES  (2)
#define   IGDS_FILES  (3)

#define   MN_XLO      (912)
#define   MN_YLO      (834)

#define   PUBLISHER_MAP       "Publisher characters  "
#define   PUBLISHER_CHARS       (0)

#define   BITSTREAM_MAP       "Bitstream characters  "
#define   BITSTREAM_CHARS       (1)

#define   ADOBE_MAP           "Adobe characters      "
#define   ADOBE_CHARS           (2)

#define   DEC_MAP             "Dec characters        "
#define   DEC_CHARS             (3)

#define   ISO_MAP             "ISO characters        "
#define   ISO_CHARS             (4)

#define   PI_MAP              "Pi & Symbol characters"
#define   PI_CHARS              (5)

#define   NUM_MAPS              (6)

#define   PROOF_ASCII (0)
#define   PROOF_FONT  (1)
#define   PROOF_KERNS (2)
#define   PROOF_TEXT  (4)

#define   INTERGRAPH_COPYRIGHT \
"(c) Copyright Intergraph Corp., 1987.                                         "
#define   FONT_VERSION "c2.3    "

#define   REPEAT_CODE  0x1	/*flag: bit 0 = 1 -> repeat coding set        */
#define   FS_REPEAT_CODE(flag)      (0x0001 & flag)

#define   X_EXTENTS  0x2	/*      bit 1 = 1 -> character x-extents      */
#define   FS_X_EXTENTS(flag)        ((0x0002 & flag) >> 1)

#define   Y_EXTENTS  0x4	/*      bit 2 = 1 -> character y-extents      */
#define   FS_Y_EXTENTS(flag)        ((0x0004 & flag) >> 2)

#define   EXTREME_POINTS  0x8	/*      bit 3 = 1 -> extreme pt addition      */
#define   FS_EXTREME_POINTS(flag)   ((0x0008 & flag) >> 3)

#define   KERN_PAIRS  0x10	/*      bit 4 = 1 -> kerning pair data        */
#define   FS_KERN_PAIRS(flag)       ((0x0010 & flag) >> 4)

#define   KERN_TRACK1  0x20	/*      bit 5 = 1 -> kerning track 1          */
#define   FS_KERN_TRACK1(flag)      ((0x0020 & flag) >> 5)

#define   KERN_TRACK2  0x40	/*      bit 6 = 1 -> kerning track 2          */
#define   FS_KERN_TRACK2(flag)      ((0x0040 & flag) >> 6)

#define   KERN_TRACK3  0x80	/*      bit 7 = 1 -> kerning track 3          */
#define   FS_KERN_TRACK3(flag)      ((0x0080 & flag) >> 7)

#define   PLAID_DATA  0x100	/*      bit 8 = 1 -> plaid data               */
#define   FS_PLAID_DATA(flag)       ((0x0100 & flag) >> 8)

#define   HIERARCHY_DATA  0x200	/*      bit 9 = 1 -> hierarchy data           */
#define   FS_HIERARCHY_DATA(flag)   ((0x0200 & flag) >> 9)

#define   CHAR_IDS  0x400	/*      bit 10 = 1 -> character IDs present   */
#define   FS_CHAR_IDS(flag)         ((0x0400 & flag) >> 10)

#define   CURVE_SIMPLIFY  0x800	/*      bit 11 = 1 -> no curve sumplification */
#define   FS_CURVE_SIMPLIFY(flag)   ((0x0800 & flag) >> 11)

#define   NO_POLYS        0x1   /*      bit 12 = 1 -> no fillable polygons    */
#define   FS_NO_POLYS(flag)         ((0x1000 & flag) >> 12)

#define   HORZ_VECT        (0x0000)
#define   VERT_VECT        (0x4000)
#define   SHORT_VECT       (0x8000)
#define   SHORT_ARC        (0xc000)
#define   LONG_VECT        (0xe000)
#define   LONG_ARC         (0xe100)
#define   CALL_CODE        (0xe200)
#define   END_CHAR         (0xe300)
#define   MOVE_TO          (0xf000)
#define   END_OUTL         (0xf100)
#define   NEW_ORIG         (0xf200)
#define   NEW_SCALE        (0xf300)
#define   DO_CHAR          (0xf400)
#define   MIN_MAX_X        (0xf500)
#define   EXTENT_X         (0x01000000)
#define   MIN_MAX_Y        (0xf600)
#define   EXTENT_Y         (0x02000000)
#define   HIER_HEAD        (0xf900)
#define   HIER_VALUE       (0x03000000)
#define   HIER_TYPE        (0xfe00)
#define   CALL_REPEAT      (0xe200)
#define   PLAID_ZONE_DATA  (0x04000000)
#define   P_15_16BIT_EDGE  (0xf700)
#define   P_255_16BIT_EDGE (0xfff0)
#define   P_15_32BIT_EDGE  (0xfa00)
#define   P_255_32BIT_EDGE (0xfff1)
#define   PLAID_X_ZONES    (0x00ff0000)
#define   PLAID_Y_ZONES    (0x0000ff00)
#define   PLAID_15_HIER    (0xf800)
#define   PLAID_255_HIER   (0xfff2)
#define   PLAID_P_FUNC_1   (0x0000)
#define   PLAID_P_FUNC_2   (0xf000)
#define   PLAID_F_FUNC_1   (0x4000)
#define   PLAID_F_FUNC_2   (0xf100)
#define   PLAID_T_FUNC_2   (0xf200)
#define   PLAID_C_FUNC_1   (0x8000)
#define   PLAID_C_FUNC_2   (0x9000)
#define   PLAID_O_ITEM     (0xc000)

#define   MAX_FONTS     (8)       /* maximum number of fonts loaded at once.   */
#define   MAX_OPENFILES (4)       /* maximum number of files open at one time  */

#endif /* FFdef_include */
