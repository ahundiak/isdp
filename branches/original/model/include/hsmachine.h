
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsmachine_include
#define hsmachine_include 1

/*
This file contains defines for machine specific values
used by HSURF
*/

/* Generic defines for machine type */
#define GS		0
#define GXGZ		1
#define TURQ		2
#define EDGEII_TRC	3

/* Number of planes available on machine */
/* These defines are used by the HSctbl2 */
/* object to determine machine type      */
#define MONOCHROME_NUM_PLANES	2
#define GS_NUM_PLANES		5
#define GXGZ_NUM_PLANES		9
#define TURQ_NUM_PLANES		8
#define EDGEII_TRC_NUM_PLANES	9

/* Number of colors available to HSURF */
#define GS_COLOR_SLOTS		12
#define GXGZ_COLOR_SLOTS	240
#define TURQ_COLOR_SLOTS	112
#define EDGEII_TRC_COLOR_SLOTS	240

/* Default color/shade configurations */
#define DEFAULT_GS_HALF_COLORS	4
#define DEFAULT_GS_HALF_SHADES	3
#define DEFAULT_GS_DIR_COLORS	1
#define DEFAULT_GS_DIR_SHADES	12

#define DEFAULT_GXGZ_HALF_COLORS	20
#define DEFAULT_GXGZ_HALF_SHADES	12
#define DEFAULT_GXGZ_DIR_COLORS		3
#define DEFAULT_GXGZ_DIR_SHADES		80

#define DEFAULT_TURQ_HALF_COLORS	14
#define DEFAULT_TURQ_HALF_SHADES	8
#define DEFAULT_TURQ_DIR_COLORS		2
#define DEFAULT_TURQ_DIR_SHADES		56

#define DEFAULT_EDGEII_TRC_COLORS	240
#define DEFAULT_EDGEII_TRC_SHADES	1

/* Color/shade configuration limits */
#define GS_HALF_MIN_COLORS	1
#define GS_HALF_MAX_COLORS	6
#define GS_HALF_MIN_SHADES	2
#define GS_HALF_MAX_SHADES	12
#define GS_DIR_MIN_COLORS	1
#define GS_DIR_MAX_COLORS	12
#define GS_DIR_MIN_SHADES	1
#define GS_DIR_MAX_SHADES	12

#define GXGZ_HALF_MIN_COLORS	14
#define GXGZ_HALF_MAX_COLORS	120
#define GXGZ_HALF_MIN_SHADES	2
#define GXGZ_HALF_MAX_SHADES	17
#define GXGZ_DIR_MIN_COLORS	1
#define GXGZ_DIR_MAX_COLORS	240
#define GXGZ_DIR_MIN_SHADES	1
#define GXGZ_DIR_MAX_SHADES	240

#define TURQ_HALF_MIN_COLORS	6
#define TURQ_HALF_MAX_COLORS	56
#define TURQ_HALF_MIN_SHADES	2
#define TURQ_HALF_MAX_SHADES	17
#define TURQ_DIR_MIN_COLORS	1
#define TURQ_DIR_MAX_COLORS	112
#define TURQ_DIR_MIN_SHADES	1
#define TURQ_DIR_MAX_SHADES	112

#define EDGEII_TRC_MIN_COLORS	1
#define EDGEII_TRC_MAX_COLORS	240
#define EDGEII_TRC_MIN_SHADES	1
#define EDGEII_TRC_MAX_SHADES	240

#endif
