
#ifndef EMpattern_h
#define EMpattern_h

#define MAX_FEATURE_PARENTS	20
#define  MAX_FS_PARENTS	20

#define FEATURE_PAR_REF_PLANE	        0
#define FEATURE_PAR_REF_POINT		1

/*	LINEAR PATTERN */

#define LINEAR_PAR_CURVE_ELEM		2
#define LINEAR_PAR_NUM_COPIES		3
#define LINEAR_PAR_ROTATION		4

/* 	MATRIX PATTERN */

#define MATRIX_PAR_X_DELTA		2
#define MATRIX_PAR_Y_DELTA		3
#define MATRIX_PAR_ROWS			4
#define MATRIX_PAR_COLS			5

/* 	POLAR PATTERN	*/

#define POLAR_PAR_CENTER		2
#define POLAR_PAR_SWEEP_ANGLE		3
#define POLAR_PAR_NUM_COPY		4

/* unused */
#define POLAR_PAR_START_ANGLE           5
#define DIMENSION_XDELTA 0
#define DIMENSION_YDELTA 1
#define DIMENSION_X_NUM   2
#define DIMENSION_Y_NUM   3

/* FEATURE PROPERTIES   */

#define BASE_FEATURE_INCLUDED          0x1
#define REF_DIR_X_NEG                  0x2
#define REF_DIR_Y_NEG                  0x4
#define NOT_A_FEATURE                  0x8

#define PT_POINT_TYPE     1
#define PT_CLOSED_CURVE   2
#define PT_OPEN_CURVE     3

#omdef fe$status(sts     = status,
                 msg     = NULL,
                 action  = CONTINUE,
                 value   = NULL)
if(!((sts) &0x00000001))
{
#if om$specified(msg)
	fprintf(stderr, (msg));
	fprintf(stderr, "\n");
#endif

	fprintf(stderr, "\nError at line %d of the file %s :\n",__LINE__,__FILE__);
	om$report_error ( sts = (sts) );

#if om$specified(action)
#if om$specified(value)
#if om$equal(action,RET_VALUE)
          return((value));
#else if om$equal(action,GOTO_VALUE)
          goto value;
#endif
#else if om$equal(action,RET_STATUS)
	  return(sts);
#endif
#endif
}
#endomdef

struct EMpat_attr
{
	struct GRas_pattern pattern;
	IGRint fea_props;
};

#endif
