#ifndef dimcomplex_include

#define dimcomplex_include

#define DIM_CPX_ORIG		3
#define DIM_CPX_MEAS		4
#define NO_CPX_DIM_ROOTS	5

#define STACKED_CPX		0
#define STRINGED_CPX		1
#define COORDINATE_CPX		2

#define CPX_OPPOSITE_FAR	-2
#define CPX_OPPOSITE_NEAR	-1
#define CPX_NEAR		 1
#define CPX_FAR			 2

/* - Actions for "insert_into_cpx" - */

#ifndef  NO_ACTION
#define NO_ACTION		0
#endif
#define ADJUST_TRAK_DIST	1
#define SWAP_TRAK_DIST		2

/* - Actions for "remove_from_cpx" - */

#define DELETE_ACTION		1
#define DROP_ACTION		2
#define CHG_MEAS_ACTION		3

/* - Actions for "set_trak_info" - */

#define XCH_TRAK_DIST		0
#define REP_TRAK_DIST		1
#define MIN_TRAK_DIST		2
#define ADD_TRAK_DIST		3
#define TOG_TRAK_DIR		4
#define CUR_TRAK_DIST		5

struct DMtrak_info
{
	IGRchar mea_trak;
	IGRdouble trak_dist;
};

#endif

