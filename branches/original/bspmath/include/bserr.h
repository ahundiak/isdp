/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bserr_include
# define bserr_include

/*
 * ^^^^^^^^^^^^^^ We would not like to redefine these things mistakenly.
 */

/*
 * errors
 */
#define BSFAIL          (-1)            /* failure                      */
#define BSINARG         (-2)            /* invalid input argument       */
#define BSOVF           (-3)            /* overflow or underflow        */
#define BSNEGSRT        (-4)            /* negative input to square root*/
#define BSZDIV          (-5)            /* divide by zero               */
#define BSDGENRAT       (-6)            /* degenerate case- error       */
#define BSNONPLANAR     (-7)            /* non planar                   */
#define BSEINFSOLUTION  (-8)            /* infinite solution            */

/*
 * severe errors
 */
#define BSSDGENRAT      (-9)            /* degenerate case- severe error*/
#define BSDDNE          (-10)           /* derivative does not exist    */
#define BSKNTI          (-11)           /* knot index could not be found*/
#define BSNOSOLUTION    (-12)           /* no solution could be determined*/
#define BSNOMEMORY      (-13)           /* no memory could be allocated */

/* 
 * information
 */
#define BSSUCC          (0)             /* successful completion        */
/* special note on BSSUCC:  if it is changed from 0, please remember to change
   the definitions of BSOKAY(X) and BSERROR(X) */
#define BSINFSOLUTION   (-14)           /* infinite number of solutions */
#define BSIDGENRAT      (-15)           /* degenerate case              */
#define BSINOTUNIQUE    (-16)           /* more solutions exist than the*/
                                        /* one located.                 */
/*
 * HERE ARE SOME NICE ERROR CODES WE THOUGHT UP OURSELVES:
 */

#define BSMINMAXBOX     (1)             /* min component larger than max
                                        * component in min-max box. Non-
                                        * fatal.  DPS: 10/14/85.         */
#define BSINVORD        (2)             /* invalid order, FATAL, indicates
                                          programmer error. RLW 10/16/85 */
#define BSNULL          (3)             /* expected pointer(s) NULL     */
                                        /* routine cannot continue      */
#define BSMAXIT         (4)             /* maximum iterations exceeded, WARNING
                                           some result is returned RLW  10/23*/
#define BSWARN          (5)             /* successful, but there is a        */
                                        /* possibility something is wrong    */
                                        /* JBK 30-OCT-85                     */
#define BSTOOMUCHTODO   (6)             /* just had to throw this one in! JBK*/

#define BSNOTCONTINUOUS (7)             /* curve or curves not continuous    */
                                        /* JBK 31-OCT-85                     */
#define BSINVLINE       (8)             /* Line is ill-defined; points too 
                                           close together. DPS: 11/4/85      */
#define BSINVARCLN      (9)             /* Given distance exceeds arc length
                                           of curve. DPS: 11/7/85            */
#define BSCENCNDEF      (10)            /* Center of curvature undefined at
                                           given point. DPS: 11/8/85         */
#define BSNEEDMORENUM   (11)            /* need more number to construct a
                                           linear spline, refer to algorithm
                                           BSlininter. HST 11/13/85          */
#define BSINVPRVALS     (12)            /* Invalid parameter values: must be
                                           distinct. DPS: 11/14/85           */
#define BSINVDIR        (13)            /* Invalid direction for projection:
                                           parallel to plane. DPS: 11/19/85  */
#define BSINVAXIS       (14)            /* Axis is ill-defined: determining
                                           points are too close. DPS:11/20/85*/
#define BSCIRCNDEF      (15)            /* Circle is not defined.DPS:11/25/85*/
#define BSCURVENOTEXT   (16)            /* Curve is not extendable           */
#define BSPTNOTFOUND    (17)            /* Point not found                   */
#define BSUNMATCHEDTYPES    (18)        /* The type of curve/surface input   */
                                        /* to this function does not agree   */
                                        /* with the type of the curve/surface*/
                                        /* as determined by this function or */
                                        /* the type of curve/surface created */
                                        /* this function is not what was     */
                                        /* expected -- J. B. King 13-Dec-85  */
#define BS1FAIL             (19)        /* BSnFAIL are for debugging purposes*/
#define BS2FAIL             (20)        /* only.  It would be nice if each   */
#define BS3FAIL             (21)        /* function had its own failure      */
#define BS4FAIL             (22)        /* code(s), but that is not the case.*/
#define BS5FAIL             (23)        /* BSnFAIL should not appear in      */
#define BS6FAIL             (24)        /* finished code. -- JBK 23-Dec-85   */
#define BSFCSTCLSTDTX       (25)        /* FoCuS Too CLoSe To DirecTriX      */
                                        /* BSparab2 -- JBK 30-Dec-85         */
#define BSINVNORMAL         (26)        /* Normal undefined. DPS : 1/2/86    */
#define BSINVPRNAME         (27)        /* An INValid PaRameter NAME was     */
                                        /* passed to BSextractpar or         */
                                        /* BSchangepar -- JBK 16-Jan-86      */
#define BSNOTSSLINE         (28)        /* Parameter points are not on the   */
                                        /* same side of the line (BSmaxext)  */
                                        /* -- JBK 20-Jan-86                  */
#define BSSFBNDRNOTFREED    (29)        /* Surface not freed because of      */
                                        /* inconsistency between number of   */
                                        /* boundaries and the boundaries     */
                                        /* pointer. -- JBK 10-Apr-86         */
#define BSSFWGHTNOTFREED    (30)        /* Surface not freed because of      */
                                        /* inconsistency between rationality */
                                        /* of surface and the weights        */
                                        /* pointer. -- JBK 10-Apr-86         */
#define BSCVBNDRNOTFREED    (31)        /* curve not freed because of        */
                                        /* inconsistency between number of   */
                                        /* boundaries and the boundaries     */
                                        /* pointer. -- JBK 10-Apr-86         */
#define BSCVWGHTNOTFREED    (32)        /* curve not freed because of        */
                                        /* inconsistency between rationality */
                                        /* of curve and the weights pointer. */
                                        /* -- JBK 10-Apr-86                  */
#define BSNOSTKMEMORY       (33)        /* like BSNOMEMORY, but means no     */
                                        /* memory could be allocated from the*/
                                        /* stack -- JBK 17-Apr-86            */
#define BSBADDIM            (34)        /* Bad dimension -- JBK 21-Apr-86    */
#define BSINCONSISTENT      (35)        /* Internal inconsistency -- JBK 23  */
                                        /* April 1986                        */
#define BSPAROUTOFBOUNDS    (36)        /* parameter value not within bounds */
                                        /* -- JBK 30 May 1986                */
#define BSBADTYPE           (37)        /* an unknown type has arisen -- JBK */
                                        /* 1 July 1986                       */
#define BSNOTCOMP           (38)        /* two curves or surfaces are not    */
                                        /* compatible for merging            */
#define BSALINE             (39)        /* input curve is a line and can't   */
                                        /* find the appropriate vectors      */
                                        /* SGC  SEPT 1986                    */
#define BSPHYCLOSED         (40)        /* surface or curve was phy_closed,  */
                                        /* thus inappropriate. PFS: 10/10/86 */
#define BSINVEXTDIR         (41)        /* attempting to extend a surface or */
                                        /* curve in the wrong direction.     */
                                        /* PFS: 10/10/86 */
#define BSINVOPTION         (42)        /* unexpected or invalid option.     */
                                        /* PFS: 10/13/86     */
#define BSNOINTERS          (43)        /* no intersections were found.      */
                                        /* PFS: 11/12/86     */
#define BSINVCHT            (44)        /* chord height tolerance too small  */
                                        /* for intersecting surfaces         */
                                        /* CSS: 02/27/87                     */
#define BSPARALLEL	    (45)	/* lines or planes were parallel     */
					/* PFS: 05/18/87		     */
#define BSCOINCIDENT        (46)        /* lines or planes were coincident   */
                                        /* CSS: 09/28/87                     */

#define BSNOTCONNECTED      (47)        /* the curves were not connected*/
                                        /* SC: 02/13/89                 */

#define BSNOTYETSUPPORTED   (48)        /* we do not support these      */
                                        /* arguments at this time       */
                                        /* SC: 05/24/89                 */
#define BSINVALIDWEIGHT     (49)        /* the weight is invalid        */
                                        /* either close to zero or      */
                                        /* negative                     */
                                        /* SC: 10/17/89                 */
#define BSOUTOFDESN         (50)        /* the algorithm is not         */
                                        /* designed for this case       */
                                        /* Vivian.Ye: 05/15/90          */
#define BSKNOTSNOCHG        (51)        /* due to degeneracy or multiple*/
                                        /* poles, knots were not changed*/
#define BS2NDDERVZERO       (52)        /* second derivative is zero    */
#define BSPARNOTFOUND       (53)        /* Parameter can not be found   */
#define BSFILLARCNOTFOUND   (54)        /* Fillet arc not found         */
#define BSNOTINCHT          (55)        /* Points are not within cht    */
#define BSDRUNK             (56)        /* Inconsistency of drunken man type of problem */

# ifndef bstypes_include
#   include "bstypes.h"   /* for the BSrc typedef */
# endif

/* BSERROR(rc) is TRUE if rc is not BSSUCC */
/* # define BSERROR(rc) (rc != BSSUCC) */
/* since BSSUCC is now zero ... */
# define BSERROR(rc) (rc)

/* BSOKAY(rc) is TRUE if rc is BSSUCC */
/* # define BSOKAY(rc) (rc == BSSUCC) */
/* since BSSUCC is now zero ... */
# define BSOKAY(rc) (!(rc))

# endif /* bserr_include */
