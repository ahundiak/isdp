#ifndef cenline13_include
#define cenline13_include 1

/*
typedef IGRdouble IGRpoint[3]	;
typedef IGRpoint  IGRvector	;
typedef IGRdouble IGRmatrix[16]	;
typedef unsigned int OMuint	;*/
/*----------------------------------------------------------------------------*/
#define MAX_TMPS_COUNT	3
#define MAX_FEET_COUNT	7
/* -- Template names.
   -- */
#define TARGET_CRV	"curve"		/* Template 0: target curve	*/
#define PROJCT_PNT	"projc"		/* Template 1: point to project	*/

/* -- Feet names.
   -- */
#define AX1LEFT		"axis1"	/* Foot 0 */
#define AX1RIGH		"axis2"	/* Foot 1 */
#define AX2LEFT		"axis3"	/* Foot 2 */
#define AX2RIGH		"axis4"	/* Foot 3 */
#define CROSBR1		"lseg1"	/* Foot 4 */
#define CROSBR2		"lseg2"	/* Foot 5 */
#define CENTRPT		"centr"	/* Foot 6 */

/* -- Curves types & sub types as defined in draft/go/include/godef.h
#define GRCURVE		0
#define	GRSC		0
#define	GRLN		6
#define	GRCN		7
   -- */

/* -- Internal data for macro:
		- axes_mode : how to compute axes:
			CNL_VIEW : use view vector from placement time.
			CNL_PROJ : use projection of aligment point onto curve.
		- a) x- and y- vectors of view at placement time.
		  b) co-ordinates of projection onto curve of placement point.
   -- */
#define CNL_VIEW 0
#define CNL_PROJ 1
struct cenline_data {
	char		axes_mode ;
	struct {
			IGRvector	x, y	; /* CNL_VIEW */
	} view ;
	IGRpoint	align_pt	; /* CNL_PROJ */
} ;

/* -- Name of ci macro.
   -- */
#define MACRO_NAME	"cenline"

/* -- Name of common variable to cenline.u and COcenline.u.
   -- */
#define MACRO_DATA	macro_data
#define DATA_NAME	"macro_data"
struct cenline_data MACRO_DATA ;

#define EPSILON 1.E-10

#endif /* cenline13_include */
