#ifndef SSdef_include
#define SSdef_include

/*
 * This file contains the typedefs and constant defs for the
 * SmartMouse of EMS.
 * Dependencies: igrtypedef.h
 *               igetypedef.h
 *               bsvalues.h - included here if not by reference code
 *               igr.h
 *               igrdp.h
 *               dpstruct.h
 */

#ifndef bsvalues_include
#include "bsvalues.h"     /* required for for M_PI */
#endif

/* 
 *  settings for gr$get_ss_lock and gr$put_ss_lock
 */
#define SS_IS_OFF  (0x0)
#define SS_IS_ON   (0x1)

/*
 * Size of the list of objects
 */
#define SS_MAX_OBJECTS  5     /* was originally 10; reduced 9/24/93 SRH */

/*
 * maximun number of classes eligible for Rtree search for ALL applications
 */
#define SS_MAX_CLASS_IDS (7)


/*
 * Maximum number of key points per SSobject
 */
#define SS_MAX_KEYPOINTS 6

/*
 * Actions for SSHasMoved
 */
#define SSON         0 /* Turn the SmartMouse ON          */
#define SSCHECK      1 /* Check if the mouse has moved    */
#define SSOFF        2 /* Turn the SmartMouse OFF         */

/*
 * Types of objects we deal with
 */
#define SSLINE          0
#define SSPOINT         1
#define SSARC           2
#define SSCIRCLE        3
#define SSBSCURVE       4
#define SSCOORDSYS      5
#define SSUNKNOWN       1023  /* unknown to this application */
#define SSINQUIRE       1024  /* unknown - up to the command to determine */

/*
 * Types of "New" elements (for type arg of ss$set_new_element)
 */
#define SSNEW_LINE          0
#define SSNEW_POINT         1
#define SSNEW_ARC_CENTER    2
#define SSNEW_CIRCLE        3
/*
 * Types of constraints we deal with
 * IMPORTANT: SSONELEMENT should always have the lowest value.
 */
#define SSNONE          -1
#define SSONELEMENT      0 
#define SSCENTER         1
#define SSINTERSECT      2
#define SSFIRSTPOINT     3
#define SSLASTPOINT      4
#define SSKEYPOINT       5
#define SSHORIZONTAL     6
#define SSVERTICAL       7
#define SSPERPENDICULAR  8
#define SSPARALLEL       9
#define SSTANGENT       10
#define SSMIDPOINT      11
#define SSONXELEMENT    12
#define SSXINTERSECT    13
#define SSHVERTICAL     14
#define SSVHORIZONTAL   15
#define SSONHORIZONTAL  16
#define SSONVERTICAL    17
#define SSONXHORIZONTAL 18
#define SSONXVERTICAL   19
#define SSXTANGENT      20
#define SSCARDINAL90    21
#define SSCARDINAL180   22
#define SSCARDINAL270   23

/*
 * Maximum number of constraints we want to look at; must be one more than the
 * hightest contraint index (above) (since indices start with 0).
 */
#define SS_MAX_CONSTRAINT_TYPES 24

/*
 * Type of masks
 */
#define SSVALID         1
#define SSINVALID       2

/*
 * Maximum length (including terminal NULL) of text displayed with constraint
 */
#define SS_MAX_CONSTR_STRING 30

/*
 * For SSConstraintMask support (SSOptions form)
 */
#define SSACTIVENONE        0x00000000
#define SSACTIVEHORIZONTAL  0x00000001
#define SSACTIVEVERTICAL    0x00000002
#define SSACTIVEONELE       0x00000004
#define SSACTIVETANGENT     0x00000008
#define SSACTIVEPARALLEL    0x00000010
#define SSACTIVEPERPEND     0x00000020
#define SSACTIVEINTERSECT   0x00000040
#define SSACTIVEKEYPOINT    0x00000080
#define SSACTIVEONEXELE     0x00000100  /* the co-linear case         */
#define SSTEXTDISPLAYED     0x80000000  /* constraing text displayed  */
#define SSACTIVEALL         0x7FFFFFFF  /* all constaints active      */

/* 
 * Gadgets lables for GRSmSketch form 
 */
#define SSF_GR_CHECK_X     ( 7)
#define SSF_G_CHECK        ( 1)
#define SSF_G_X            ( 4)

/* not in any group */
#define SSF_TEXT_TITLE     (11)
#define SSF_G_ON_OFF       (12)
#define SSF_G_TEXT_ON_OFF  (13)
#define SSF_G_HORIZ        (31)
#define SSF_G_VERT         (32)
#define SSF_G_ON_ELE       (33)
#define SSF_G_KEY_PT       (34)
#define SSF_G_TANGENT      (35)
#define SSF_G_PARALLEL     (36)
#define SSF_G_PERPEND      (37)
#define SSF_G_ISECT        (41)

#define SSF_GR_SET_CLEAR   (44)
#define SSF_G_CLEAR_ALL    (42)
#define SSF_G_SELECT_ALL   (43)

/*
 * Mask bits for SSDisplayMode
 */
#define SSDISPLAY_TEXT     ( 1)

/*
 * flag setting for SSListKeyptActive ()
 */
#define SSSET_KEYPT         (1)
#define SSUNSET_KEYPT       (2)
#define SSTOGGLE_KEYPT      (3)

/*
 * KEYPOINTS:
 */

/* Mask bit fields */
#define SSKP_ORIGIN    ( 0X00000001 )
#define SSKP_ENDPT1    ( 0X00000001 )  /* same as origin */
#define SSKP_ENDPT2    ( 0X00000002 )
#define SSKP_CENTER    ( 0X00000004 )
#define SSKP_MIDPT     ( 0X00000008 )
#define SSKP_QUADPT1   ( 0X00000010 )
#define SSKP_QUADPT2   ( 0X00000020 )
#define SSKP_QUADPT3   ( 0X00000040 )
#define SSKP_QUADPT4   ( 0X00000080 )

/* element specific indices for various SS types */
/* points */
#define SSPOINT_ORIGIN            (0)
#define SSPOINT_NBR_KP            (1)

/* lines */
#define SSLINE_ENDPT1             (0)
#define SSLINE_MIDPT              (1)
#define SSLINE_ENDPT2             (2)
#define SSLINE_NBR_KP             (3)

/* arcs */
#define SSARC_ENDPT1              (0)
#define SSARC_CENTER              (1)
#define SSARC_ENDPT2              (2)
#define SSARC_MIDPT               (3)
#define SSARC_NBR_KP              (4)

/* circles */
#define SSCIRCLE_CENTER           (0)
#define SSCIRCLE_NBR_KP_RP_OFF    (1)
#define SSCIRCLE_QUADPT1          (1)
#define SSCIRCLE_QUADPT2          (2)
#define SSCIRCLE_QUADPT3          (3)
#define SSCIRCLE_QUADPT4          (4)
#define SSCIRCLE_NBR_KP_RP_ON     (5)

/* b-spline curves */
#define SSBSCURVE_ENDPT1          (0)
#define SSBSCURVE_ENDPT2          (1)
#define SSBSCURVE_MIDPT           (2)
#define SSBSCURVE_NBR_KP          (3)


/* flag values for ss$add_to_list() */
#define SS_NOACTION               (0)
#define SS_NEWEST                 (1)

/* sweep angle tolerance in degrees (edit this to change tolerance) */
#define SSARC_LOCK_ANGLE_TOLERANCE  (5.0) /* degrees */

/* sweep angle tolerance in radians */
#define SSARC_TOLERANCE_RADIANS  ((SSARC_LOCK_ANGLE_TOLERANCE/180.0) * M_PI)

/* 
 * Tolerance checks for arc locking on quadrant points
 * for new SS_ARC elements. (see SSChkObjects.I)
 */
#define IS_NEAR_90(a)  ( a >= ((M_PI/2.0) - SSARC_TOLERANCE_RADIANS) && \
                         a <= ((M_PI/2.0) + SSARC_TOLERANCE_RADIANS) )

#define IS_NEAR_180(a) ( a >= ( M_PI - SSARC_TOLERANCE_RADIANS) && \
                         a <= ( M_PI + SSARC_TOLERANCE_RADIANS) )

#define IS_NEAR_270(a) ( a >= ((M_PI*1.5) - SSARC_TOLERANCE_RADIANS) && \
                         a <= ((M_PI*1.5) + SSARC_TOLERANCE_RADIANS) )

#define IS_NEAR_360(a) ( ( a >= ((2*M_PI) - SSARC_TOLERANCE_RADIANS) && \
                           a <=  (2*M_PI) )                          || \
                         ( a <=  SSARC_TOLERANCE_RADIANS           && \
                           a >=  0.0 ) )

/* tolerance for perpendicular/parallel/horizontal/vertical */
#define SSANGLE_TOLERANCE_RADIANS ( 0.0436332312998 )


/* error handling macro */
#define SSerr_hndlr(Sts,Msg,ErrCode,Label) \
  if (!(Sts & 1))                          \
  {                                        \
    Msg = ErrCode;                         \
    goto Label;                            \
  }

#endif
