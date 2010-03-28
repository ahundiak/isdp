/*
Name
        pidef.h

Description
        This file contains various #defines used in the Plot Interface code.

History
        mrm     03/12/89    creation
*/

#ifndef PIDEF_INCLUDE
#define PIDEF_INCLUDE

/*
 *  Form labels
 */

#define PI_SUBMIT_FORM          1
#define PI_QUEUE_FORM           2
#define PI_CREATE_FORM          3
#define PI_CREATE_IGM_FORM      4
#define PI_SUBMIT_LOCAL_FORM    5

/*
 *  Return Codes
 */

#define PI_F_FAIL           0x00000
#define PI_S_SUCCESS        0x00001
#define PI_W_NULLNAME       0x00002
#define PI_I_NAMETRUNC      0x00003
#define PI_F_NOQUEUE        0x00004
#define PI_W_UNKUNITS       0x00006
#define PI_W_RESCALE        0x0000a
#define PI_F_QSTAT          0x00008
#define PI_F_NOWINDOW       0x0000c
#define PI_F_BADWINDOW      0x00010
#define PI_F_NORASFILE      0x00020
#define PI_F_CANTOPENFILE   0x00040

/*
 *  Metafile formats
 */

#define PI_IGDS_FILE        0
#define PI_IGM_FILE         1
#define PI_UNKNOWN_FILE     2

/*
 *  InterPlot types
 */

#define PI_NO_INTERPLOT     0
#define PI_NQS_INTERPLOT    1
#define PI_IRCS_INTERPLOT   2

/*
 *  most recently changed value
 */

#define PI_X_SIZE           0
#define PI_Y_SIZE           1
#define PI_SCALE            2

/*
 *  run modes
 */

#define PI_STANDALONE       0
#define PI_GRAPHICS         1

/*
 *  mail flags
 */

#define PI_MAIL_BEGIN       0x001
#define PI_MAIL_END         0x002

/*
 *  Queue types
 */

#define PI_PIPE_QUEUE       0
#define PI_DEVICE_QUEUE     1

/*
 *  Create Plot flags
 */

#define PI_HAVE_WINDOW          0x001
#define PI_HAVE_FENCE           0x002
#define PI_CREATE_IGDS          0x004
#define PI_CREATE_IGM           0x008
#define PI_TOGGLE_WINDOW        0x040
#define PI_TOGGLE_FENCE         0x080

/*
 *  misc
 */

#ifndef TRUE
#define TRUE    1
#endif

#ifndef FALSE
#define FALSE   0
#endif

#ifndef NULL
#define NULL    0
#endif

#endif /* PIDEF_INCLUDE */
