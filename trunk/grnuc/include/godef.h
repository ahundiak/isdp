/*
 * Include file for Graphics Objects
 */

#ifndef godef_include
#define godef_include

/*
 * This include file is dependent on the following files:
 *
 * madef.h
 *
 */

#include "DIdef.h"    /* DI_PATH_MAX */

#define GRCLNAME_SIZE 8

#define GRNAME_SIZE DI_PATH_MAX         /* directory path size         */
#define GRFILENAME_SIZE 14              /* Maximum filename size       */

#define GRDGNLIMITS_MIN_I -2147483647   /*                             */
#define GRDGNLIMITS_MAX_I  2147483647   /* minimum and maximum values  */
#define GRDGNLIMITS_MIN_D -2147483647.0 /* allowed in design space     */
#define GRDGNLIMITS_MAX_D  2147483647.0 /*                             */

                        /* object types */

#define GRCURVE   0                     /* general curve               */
#define GRSURFACE 1                     /* general surface             */
#define GRCURVEPRISM 2                  /* curve prism                 */
#define GRLBSYS   3                     /* local bounded system        */

                        /* subtypes     */

#define GRSC     0                      /* B-spline sub curve          */
#define GREC     1                      /* extended B-spline curve     */
#define GRCC     2                      /* composite B-spline curve    */
#define GRSS     3                      /* B-spline sub surface        */
#define GRES     4                      /* extended B-spline surface   */
#define GRCS     5                      /* composite B-spline surface  */
#define GRLN     6                      /* linear geometry             */
#define GRCN     7                      /* conic geometry              */


/* 
 * defines for GRgraphics properties bits
 */

#define GR_RIGID_RELATIONSHIP   0X1     /* object has rigid owner       */
#define GRIS_PLANAR             0x2     /* object is planar             */
#define GRIS_READ_ONLY          0x4     /* object is read only          */
#define GRIS_NEW                0x8     /* object is new                */
#define GRIS_MODIFIED           0x10    /* object has been modified     */
#define GRIS_LOCATABLE          0x20    /* object is locatable          */
#define GRIS_DISPLAYABLE        0x40    /* object is displayable        */
#define GRFILLED_DISPLAY        0x80    /* display as filled object     */
#define GRNOT_IN_RTREE          0X100   /* object is not in R-tree      */
#define GRIS_VIEW_INDEP         0X200   /* object is displayed as
                                         * view rotation independent    */
#define GRIS_SCALE_INDEP        0x400   /* object is displayed as
                                         * view scale independent       */
#define DEHAS_OVERRIDE          0x800   /* object has symbology override*/
#define GRIS_ASSOCIATIVE          0x1000 /* object is associative */
#define GRHAS_EXTERNAL_CONSTRAINT 0x2000 /* object also has external
                                          * constraints.                */
#define GRIS_VE_CURVE           0x4000  /* object is a VE curve         */
#define GRIS_POST220_OBJECT	0x8000  /* This object has been contructed in 
					   a post 2.2.0 version*/
/*
 * B-spline curve instance properties
 */

#define GRIS_PERIODIC           0x2
#define GRIS_NON_UNIFORM        0x4
#define GRIS_RATIONAL           0x8
#define GRIS_PHY_CLOSED         0x10

#define GRIS_POLYDIS            0x1             /* B-spline display     */
#define GRIS_CURVEDIS           0x2             /* properties           */


/* 
 * The following #defines are for clipping options bit masks
 */

#define GR_CLIP_OVL_IN   0X1    /* Treat overlap objects as inside      */
#define GR_CLIP_OVL_OUT  0X2    /* Treat overlap objects as outside     */
#define GR_CLIP_RTPRISM  0X4    /* Clip using IGRrt_prism               */
#define GR_CLIP_NORGCK   0X8    /* skip curve/prism range check         */
#define GR_CLIP_NODEL    0X10   /* Do not delete original object        */
#define GR_CLIP_RIGID    0X20   /* call GRrigidconn method              */
#define GR_CLIP_FLEXCONN 0x40   /* call GRflexconn method with flag = 1 */
#define GR_CLIP_CONSTR_ALL_PIECES 0X80 /* construct all clip pieces     */
#define GR_CLIP_FORPLOT  0x100  /* clip requested for plotting          */

/*
 *
 *  The following macros are used to declare and initialize the 
 *  structures to be used for the internal representation of 
 *  geometries.  They are included here for commands to use
 *  without having to include the complete macro include file
 *  needed by graphic objects.
 *
 */

#define GRls_declare(a,b)                                       \
        struct IGRbsp_curve a;                                  \
        IGRdouble b[10]

#define GRls_init(a,b)                                          \
        (a).poles = b;                                          \
        (a).knots = &b[6]

#define GRconic_declare(a,b)                                    \
        struct IGRbsp_curve a;                                  \
        IGRdouble b[MAELPOLE_SIZE * 4 + MAELKNOT_SIZE]

#define GRconic_init(a,b)                                       \
        (a).poles = b;                                          \
        (a).knots = &b[3 * MAELPOLE_SIZE];                      \
        (a).weights = &a.knots[MAELKNOT_SIZE]



/*
 *      The following #defines are to be used to notify the 
 *      listeners connected on the notification channel of
 *      what sort of operation has occurred to the graphics
 *      object.
 */

#define GR_GEOM_MODIFIED        0x1
#define GR_GEOM_XFORMED         0x2
#define GR_COPIED               0x4
#define GR_ATTR_MODIFIED        0x8
#define GR_DISPLAYED            0x20
#define GR_CLIPPED              0x40
#define GR_GEOM_POSTED          0x80
#define GR_DELETED              0x100
#define GR_LOCATED              0x200
#define GR_CHANNEL_USED         0x400
#define GR_RTREE_MANIPULATION   0x800
#define GR_CHANGED              0x1000          /* used when id changed */
#define GR_REFFILE_DETACHED     0x2000          /* one of the object's parents
                                                 * has been disconnected
                                                 * because the reference file
                                                 * in which the parent resides
                                                 * has been detached
                                                 */

/*
 *  The following defines are used to define the result from the locate
 *  processing method.
 *  If bit zero is clear then it signifies that there is not a result.
 *  If bit one is clear then it signifies that the object was processed
 *  but did pass all checks.
 */

#  define GR_LC_NORESULT          0x0
#  define GR_LC_PROCESSED         0x1
#  define GR_LC_HIT               (0x2 | 0x1)
#  define GR_LC_INSIDE            (0x4 | 0x2 | 0x1)
#  define GR_LC_OUTSIDE           (0x8 | 0x2 | 0x1)
#  define GR_LC_OVERLAP           (0x10 | 0x2 | 0x1)

/*
 *  #define are used when setting up the initial path for locate.
 */

#  define GR_LC_INITIAL_POSITION    -1

/* 
 * #define for prism type used by prism methods.
 */

#define GRCURVE_PRISM  1
#define GRRIGHT_PRISM  0

#endif
