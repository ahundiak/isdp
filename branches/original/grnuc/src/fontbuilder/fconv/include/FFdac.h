/*
$Log: FFdac.h,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:46  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:00  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:00  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:52:07  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:25  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:42:27  tim
 * COMMENT : added Log variable
 * 
*/ 

#ifndef CXdac_include
#define CXdac_include

#define MAX_SLOTS 512
#define COLORTBLSIZE     16                /* size of Publisher colortable */
#define SIXTEENBITS      16
#define KFACT            17                /* kludge factor: 0-15 to 0-255 */
#define ROP               4
#define IFB               8

struct dac_vars {
               int      vlt_offset;   /* 0,    16    */
               int      all_planes;   /* 0x1f, 0x1ff */
               int      hilite;       /* 0x10, 0x100 */
               int      no_hilite;    /* 0x0f, 0x0ff */
               int      shades;       /* 16,   256   */
               int      dac_size;     /* 4,    8     */
               int      vlt_slots;    /* 32,   512   */
        struct vlt_slot vlt[MAX_SLOTS];         
        };

#endif

