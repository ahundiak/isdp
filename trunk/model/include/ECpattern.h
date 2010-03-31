
#ifndef ECpattern_h
#define ECpattern_h
/* !!CAUTION: Do not change the #define values , the order is importent.
 */

#define LOC_REF_PLANE      1

#define LOC_PAT_FEATURE    2

#define LOC_DEP_FEATURE    3

#define LOC_REF_POINT      4

#define SEL_MAT_DIR_X      5

#define NUM_MAT_XOBJ       6

#define DIST_MAT_XDELTA    7

#define SEL_MAT_DIR_Y      8

#define NUM_MAT_YOBJ       9

#define DIST_MAT_YDELTA    10

#define LOC_RADIAL_CENPT   11

#define GET_RADIAL_DIR     12

#define NUM_RADIAL_OBJ     13

#define GET_RADIAL_ANGLE   14

#define CONSTRUCT_PATTERN  15


#define EMS_PAT_LOC_FEATURE     1    /* Identified for locate */
struct EMSdyn_pattern {
struct DPele_header arrow_buf;
IGRdouble ref_point[3],dittol;
IGRmatrix plane;
IGRvector vec;
IGRpoint center;
IGRint state;
};

#endif

