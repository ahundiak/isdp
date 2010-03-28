/*
$Log: FFicons.h,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:50  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:05  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:03  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:52:17  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:33  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:42:32  tim
 * COMMENT : added Log variable
 *
*/

#ifndef FFicon_include
#define FFicon_include

#define   SELECT_FONTS_SYM (16)
#define   SELECT_FONTS_GAD  (1)
#define   METRICS_SYM      (21)
#define   METRICS_GAD       (2)
#define   CREATE_CHAR_SYM   (5)
#define   CREATE_CHAR_GAD    (3)
#define   EDIT_CHAR_SYM     (6)
#define   EDIT_CHAR_GAD     (4)
#define   DELETE_CHAR_SYM   (8)
#define   DELETE_CHAR_GAD   (5)
#define   ADD_CHAR_SYM      (7)
#define   ADD_CHAR_GAD      (6)
#define   MERGE_CHAR_SYM    (7)
#define   MERGE_CHAR_GAD    (7)
#define   ZOOM_IN_SYM      (11)
#define   ZOOM_IN_GAD       (8)
#define   ZOOM_OUT_SYM     (12)
#define   ZOOM_OUT_GAD      (9)
#define   CENTER_SYM        (9)
#define   CENTER_GAD       (10)
#define   AREA_SYM         (10)
#define   AREA_GAD         (11)
#define   GRID_ON_OFF_SYM  (13)
#define   GRID_ON_OFF_GAD  (12)
#define   VIEW_SYM         "VIEW"
#define   VIEW_GAD         (13)
#define   SAVE_CHAR_SYM     (1)
#define   SAVE_CHAR_GAD    (14)
#define   FACE_SYM          (1)
#define   FACE_GAD         (15)

#define   QUIT_SYM         (75)
#define   QUIT_GAD        (100)
#define   SAVE_SYM         (74)
#define   SAVE_GAD        (101)

/* used in FSunitcnv() */
#define   SNAP_KEYPT_ON      (0x00000001)
#define   SNAP_KEYPT_OFF     (0xfffffffe)
#define   SNAP_PROJ_ON       (0x00000002)
#define   SNAP_PROJ_OFF      (0xfffffffd)
#define   GRID_ON            (0x00000004)
#define   GRID_OFF           (0xfffffffb)
#define   GRID_LOCK_ON       (0x00000008)
#define   GRID_LOCK_OFF      (0xfffffff7)
#define   FENCE_CNT_ATTR     (0x00000010)
#define   FENCE_CNT_INSIDE   (0x00000020)
#define   FENCE_CNT_OVERLAP  (0x00000040)
#define   FENCE_CNT_CLIP     (0x00000080)
#define   FENCE_CLEAR        (0xffffff0f)
#define   FENCE_DEFAULT      (0x00000020)

#endif /* FFicon_include */
