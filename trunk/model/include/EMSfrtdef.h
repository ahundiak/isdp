/*
 * This file contains definitions for the class EMSfrt
 */

# ifndef EMSfrtdef_include
# define EMSfrtdef_include

/*
 * Graphics data properties
 */
# define EMGD_UPTODATE      0x1     /* Graphics data is up to date with */
                                    /* respect to current boundaries.   */
                                    /* If this bit is off, the surface  */
                                    /* must be redisplayed before any   */
                                    /* operation can beperformed.       */
# define EMGD_NONNATURAL    0x2     /* Graphics data represents less    */
                                    /* than the entire area of the      */
                                    /* surface.                         */
# define EMGD_TRIMMED       0x4     /* Graphics data is up to date with */
                                    /* respect to boundaries currently  */
                                    /* being displayed. On the next     */
                                    /* display request, retrim the rule */
                                    /* lines.                           */
# define EMGD_ALTDISPLAY    0x8     /* This face possesses its own      */
                                    /* display attributes.              */

/*
 * Graphics loop properties
 */
#define  EMGL_HOLD_UPDATE   0x01    /* NC request to hold update and    */
                                    /* display                          */
#define  EMGL_UPTODATE      0x02    /* Graphics loop is up to date with */
                                    /* respect to current boundaries.   */
#define  EMGL_NO_DISPLAY    0x04    /* Display, locate, keypoint, and   */
                                    /* plot are turned off              */


/*
 * Graphics data & Graphic loop properties reset options
 */
# define EMS_O_OUTOFDATE    0x01
# define EMS_O_RETRIM       0x02
# define EMS_GL_OUTOFDATE   0x04
# define EMS_GL_HOLD        0x08

/*
 * Standard rule line table display buffer size in bytes
 */
# define RLT_BUFFER_SIZE        24000
# define DBL_RLT_BUFFER_SIZE    3000

/*
 * Standard clip point buffer size in number of elements
 */
# define EMS_CLIP_BUFF_SIZE     40

# endif
