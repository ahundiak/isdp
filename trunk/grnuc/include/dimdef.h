#ifndef dimdef_include

#define dimdef_include

/* - Current Version Number - */

#define CURRENT_VERSION		200	/* 2.0.0 */

#define MAX_DIM_ROOTS		10

#define DIM_ROOT_PLAN		0
#define DIM_ROOT_ENV		1
#define DIM_ROOT_SENV		1
#define DIM_ROOT_LOC		2

/* - Component Mask - */

#define DIM_TEXT		0
#define DIM_ORI_TERM		1
#define DIM_MEA_TERM		2
#define DIM_ORI_PROJ		3
#define DIM_MEA_PROJ		4
#define DIM_LEADER		5
#define DIM_LINE1		6
#define DIM_LINE2		7
#define DIM_LINE3		8
#define DIM_LINE4		9
#define DIM_ULINE		10
#define DIM_BOX			11
#define DIM_BALLOON		12

/** satish - added for NAVSEA **/
#define DIM_TEXT2		13

#define MAX_COMP_INDEX		24

/* - Graphic Object Index, in addition to masks - */

#define DIM_NO_INDEX		-1

/* - Parameter Data Types - */

#define DM_ENV_PARAM		0
#define DM_LOC_PARAM		1
#define DM_MISC_PARAM		2
#define DM_SENV_PARAM		3
#define DM_GLOB_PARAM		4
#define DM_WELD_PARAM		5

#define MAX_PARAM_TYPE		5

/* - Break Point Position - */

#define BRK_RIGHT		1	/* 001 */
#define BRK_CENTER		2	/* 010 */
#define BRK_LEFT		4	/* 100 */
#define BRK_ALT_CENTER		8

/* _ Bit Masks for measurement axis and trak direction - */

#define DM_MEA_AXIS		0x0001
#define DM_TRAK_DIR		0x0002
#define DM_ORIG_DIR		0x0004
#define DM_MEAS_DIR		0x0008

/* - Bit Masks for coordinate dimension - */

#define DM_TRAK_ZONE1		0x0004
#define DM_TRAK_ZONE2		0x0008
#define DM_TRAK_LOCK		0x0010
#define DM_TRAK_CTRL_DIM	0x0020

/* - Dimensioning Graphic Component Types - */

#define DM_LINE			0
#define DM_TEXT			1
#define DM_ARC			2
#define DM_LINE_STR		3
#define DM_CIRCLE		4
#define DM_POLYGON		5

#define DM_MAX_GO_TYPES		6

/* - Dimension Types - */

#define LINEAR_DIMENSION	0x0001
#define COORDINATE_DIMENSION	0x0002
#define ANGULAR_DIMENSION	0x0004
#define RADIAL_DIMENSION	0x0008

#define SYMM_DIAM		0x0100
#define SING_PARA		0x0200
#define CIRC_DIAM		0x0400
#define LINR_DIAM		0x0800
#define RADL_DIAM		0x1000

#define STACKED_COMPLEX		0x010000
#define STRINGED_COMPLEX	0x020000
#define IS_COMPLEX_DIMENSION	0x030000

#define STACKED_LINEAR		0
#define STRINGED_LINEAR		1
#define SYMMETRICAL_DIAMETER	2
#define SINGLE_PARALLEL		3
#define CIRCULAR_DIAMETER	4
#define LINEAR_DIAMETER		5
#define STACKED_ANGULAR		6
#define STRINGED_ANGULAR	7
#define RADIAL			8
#define RADIAL_DIAMETER		9
#define COORDINATE		10
#define CENTER_LINE		11
#define SINGLE_ARC_LENGTH	12
#define SINGLE_ARC_ANGLE	13
#define CHAMFER			14
#define TEXT_WITH_LEADER	20
#define TEXT_WITH_BALLOON	21
#define LEADER_LINE		22
#define FEATURE_CONTROL_FRAME	23
#define DATUM_FRAME		24
#define WELD			25
#define SURF			26

/* - Terminator Types - */

#define TER_TYPE_HOLLOW_ARROW	0
#define TER_TYPE_FILLED_ARROW	1
#define TER_TYPE_OPEN_ARROW	2
#define TER_TYPE_SLASH		3
#define TER_TYPE_BACK_SLASH	4
#define TER_TYPE_BLANK		5
#define TER_TYPE_DOT		6
#define TER_TYPE_CIRCLE		7

#define MAX_TER_TYPE		8

#define DATUM_TER_TYPE_NORMAL	0
#define DATUM_TER_TYPE_ANCHOR	1

/* - Symbol Types - */

#define SYM_TYPE_ANGULAR	0
#define SYM_TYPE_DIAMETER	1
#define SYM_TYPE_PLUS_MINUS	2

#define MAX_SYM_TYPE		3

/* - Standard Types - */

#define DIM_STAN_ANS		0
#define DIM_STAN_ISO		1
#define DIM_STAN_BSI		2
#define DIM_STAN_JIS		3
#define DIM_STAN_DIN		4

#define MAX_STD_TYPE		5

/* - Type of modifications - */

#define DIM_MOD_TXT_OFFS	0
#define DIM_MOD_DIM_LINE	1
#define DIM_MOD_PROJ_LINE	2
#define DIM_MOD_TER_LOC		3
#define DIM_MOD_BREAK_PT	4
#define DIM_MOD_LEADER_PT	5

/* - projection line display - */

#define PROJ_DISP_ORI		1
#define PROJ_DISP_MEA		2

/* - terminator display - */

#define TER_DISP_ORI		1
#define TER_DISP_MEA		2

/* - Terminator Location - */

#define TER_LOCA_INTERNAL	0
#define TER_LOCA_EXTERNAL	1

/* - Dim Line Connect - */

#define LIN_DISP_OFF		0
#define LIN_DISP_ON		1

/* - Text Position - */

#define TXT_POSN_ABOVE		0
#define TXT_POSN_EMBEDDED	1

/* - Text Orientation - */

#define TXT_ORIE_HORIZONTAL	0
#define TXT_ORIE_VERTICAL	1
#define TXT_ORIE_PARALLEL	2
#define TXT_ORIE_PERPENDICULAR	3

/* - Tolerance Mode - */

#define TOLE_MODE_OFF		0
#define TOLE_MODE_UP_LOW	1
#define TOLE_MODE_MIDDLE	2
#define TOLE_MODE_LIMITS	3
#define TOLE_MODE_BOX		4
#define TOLE_MODE_REF		5

/* - Symbol Position - */

#define SYM_POSN_BEFORE		0
#define SYM_POSN_AFTER		1
#define SYM_POSN_NONE		2

/* - Dual Mode - */

#define DUAL_MODE_OFF		0
#define DUAL_MODE_ON		1

/* - Dual Display - */

#define DUAL_DISP_ABOVE		0
#define DUAL_DISP_SLASH		1

/* - Prefix and Suffix Display - */

#define DISP_OFF		0
#define DISP_ON			1

/* - Dimension Value - */

#define MOD_COMP_STATIC		0
#define MOD_COMP_DYNAMIC	1

/* - Measurement Units - */

#define PRI_UNITS		0
#define SEC_UNITS		1

#define MEA_UNIT_FEET_INCHES	0
#define MEA_UNIT_METERS		1
#define MEA_UNIT_MM		2
#define MEA_UNIT_INCHES		3

#define MAX_MEA_UNIT		4

#define ANG_UNIT_DEG_MIN_SEC	0
#define ANG_UNIT_RAD		1
#define ANG_UNIT_DEG		2

#define ANG_ROFF_UNIT_DEG	0
#define ANG_ROFF_UNIT_MIN	1
#define ANG_ROFF_UNIT_SEC	2

/* - Decimal / Fraction Mode - */

#define DECIMAL_MODE		0
#define FRACTION_MODE		1

#define DECI_ACC10		10
#define DECI_ACC1		0
#define DECI_ACC_1		1
#define DECI_ACC_2		2
#define DECI_ACC_3		3
#define DECI_ACC_4		4
#define DECI_ACC_5		5
#define DECI_ACC_6		6
#define DECI_ACC_7		7

#define FRAC_ACC_1		0
#define FRAC_ACC_2		1
#define FRAC_ACC_4		2
#define FRAC_ACC_8		3
#define FRAC_ACC_16		4
#define FRAC_ACC_32		5
#define FRAC_ACC_64		6

/* - Annotations - */

#define	ANNOT_JUST_BOTTOM	0
#define ANNOT_JUST_CENTER	1
#define ANNOT_JUST_ABOVE	2
#define ANNOT_JUST_UNDER	3

/* - Balloon types - */

#define BLN_TYPE_CIRCLE		0
#define BLN_TYPE_TRIANGLE	1
#define BLN_TYPE_SQUARE		2
#define BLN_TYPE_POLYGON	3
#define BLN_TYPE_ELLIPSE	4
#define BLN_TYPE_INV_TRIANGLE	5
#define BLN_TYPE_RECTANGLE	6
#define BLN_TYPE_ONE_LINE_TEXT	7
#define BLN_TYPE_SPLIT_CIRCLE	8
#define BLN_TYPE_SPLIT_TRIANGLE	9
#define BLN_TYPE_SPLIT_SQUARE	10
#define BLN_TYPE_SPLIT_POLYGON	11
#define BLN_TYPE_SPLIT_ELLIPSE	12
#define BLN_TYPE_SPLIT_INV_TRIANGLE	13
#define BLN_TYPE_SPLIT_RECTANGLE	14
#define BLN_TYPE_TWO_LINES_TEXT	15

/** - ballon stack parameters **/
#define HORIZ_STK 1
#define VERT_STK 2

#define DEFAULT_DIR 1
#define REVERSE_DIR 2

#define ON_EDGE 1
#define INSIDE_OBJECT 2

#define UPPER_TEXT 0
#define LOWER_TEXT 1

/* - Active layer - */

#define DM_ACTIVE_LAYER			5000
#define DM_ACTIVE_LAYER_MIN_OFFSET	3976
#define DM_ACTIVE_LAYER_MAX_OFFSET	6024

/* - Dimension States - */

#define DIM_IN_PLACEMENT	0x0001
#define DIM_IN_EDIT		0x0002
#define DIM_IN_MODIFY		0x0004
#define DIM_NEEDS_UPDATE	0x0008
#define GRDELETE_PENDING	0x0010
#define DIM_TEXT_NEEDS_UPDATE	0x0020

/* - Dimension Geometry Types - */

#define DIM_DRIVING		0x0001
#define DIM_IMPLICIT		0x0002
#define DIM_DIRECTED		0x0004
#define DIM_INTERMEDIATE	0x0008
#define DIM_DETACHED		0x0010
#define DIM_REFERENCE		0x0020
#define DIM_BY_NAME		0x0040
#define DIM_IMPORTED		0x0080

#define BIT_AND		0
#define BIT_OR		1
#define BIT_XOR		2
#define BIT_SET		3
#define BIT_CLEAR	4

/*- Standard gap values - */

#define CHARACTER_PITCH		1.00000
#define LINE_SPACING		1.00000
#define TEXT_CLEARANCE_GAP	0.35000
#define PREFIX_SUFFIX_GAP	0.70000
#define SYMBOL_GAP		0.60000
#define DUAL_MODE_VERT_GAP	0.50000
#define HOR_TOLERANCE_GAP	0.50000
#define VERT_TOLERANCE_GAP	0.35000
#define VERT_LIMITS_GAP		0.20000
#define HOR_BOX_GAP		0.35000
#define VER_BOX_GAP		0.10000

/*- Dimension Type Masks -*/

#define STACKED_LINEAR_MASK		0x0000001
#define STRINGED_LINEAR_MASK		0x0000002
#define SYMMETRICAL_DIAMETER_MASK	0x0000004
#define SINGLE_PARALLEL_MASK		0x0000008
#define LINEAR_DIAMETER_MASK		0x0000020
#define COORDINATE_MASK			0x0000400

#define LINEAR_MASK			0x000042f

#define CIRCULAR_DIAMETER_MASK		0x0000010

#define STACKED_ANGULAR_MASK		0x0000040
#define STRINGED_ANGULAR_MASK		0x0000080
#define SINGLE_ARC_LENGTH_MASK		0x0001000
#define SINGLE_ARC_ANGLE_MASK		0x0002000

#define ANGULAR_MASK			0x00030c0

#define RADIAL_RADIUS_MASK		0x0000100
#define RADIAL_DIAMETER_MASK		0x0000200

#define RADIAL_MASK			0x0000300

#define CENTER_LINE_MASK		0x0000800

#define CHAMFER_MASK			0x0004000

#define TEXT_WITH_LEADER_MASK		0x0100000
#define TEXT_WITH_BALLOON_MASK		0x0200000
#define LEADER_LINE_MASK		0x0400000
#define FEATURE_CONTROL_FRAME_MASK	0x0800000
#define DATUM_FRAME_MASK		0x1000000
#define WELD_MASK			0x2000000

#define ANNOTATION_MASK			0x3f00000

#define DIM_ALL				0xfffffff

/* - Dimension Class Mask */

#define DIM_CLASS	0x0001
#define ANNOT_CLASS	0x0002
#define CENLINE_CLASS	0x0004

/* - Dimensiong Modes - */

#define MODELING_MODE	0
#define DETAILING_MODE	1

/* - Reference Type - */

#define REF_TYPE_PARENS		0
#define REF_TYPE_SUFFIX		1
#define REF_TYPE_SUBFIX		2

/* - Dimension Display - */

#define DEFAULT_DISPLAY		0
#define DISPLAY_ALL		1
#define DISPLAY_PARALLEL	2

#define DIM_DISPLAY_OFF			0x0001
#define DIM_PLANE_ROTATED_BY_90		0x0002
#define DIM_PLANE_ROTATED_BY_180	0x0004
#define DIM_PLANE_ROTATED_BY_270	0x0008
#define DIM_IS_DIFFERENT		0x0010
#define DIM_COMP_NOT_IN_RTREE		0x0020
#define DIM_LAYER_OFF			0x0040
#define DIM_AUTO_SCALED			0x0080
#define DIM_PLANE_ROTATED		0x000e

/* - Mask for DMgive_structure - type - arg */

#define	ORIG_INFO	0x00100000
#define	MEAS_INFO	0x00200000

/* Selection Graphic object types */

#define POINT_TYPE		1
#define LINE_TYPE		2
#define ARC_TYPE		3
#define CIRC_ARC_TYPE		4
#define TEXT_TYPE		5

/* Angular dimension measurement direction*/

#define CLOCK_DIR	1
#define ANTI_CLOCK_DIR  2

#define NO_ACTION       0x0000
#define COMPUTE_DIM     0x0001
#define PARTIAL_UPDATE  0x0002
#define UPDATE_BOX      0x0004
#define INS_LF		0x0008
#define INS_CHAR	0x0010
#define DEL_LF		0x0020
#define DEL_CHAR	0x0040

#define BLN_CREATE              0x0100
#define BLN_DELETE              0x0200
#define BLN_ADJ_TXT_WIDT        0x0400
#define BLN_TXT_SIZE_ERR        0x0800

/*- DMinquire_hilite - return status */

#define LOCKED_TO_SRC_DIR0_T	0x0001 /* Tangent to src_dir0 */
#define LOCKED_TO_SRC_DIR0_N	0x0002 /* Normal to src_dir0 */
#define LOCKED_TO_SRC_DIR0	0x0003

#define LOCKED_TO_SRC_DIR1	0x0010 /* Parallel to src_dir1 */

#define LOCKED_TO_SRC_DIR	0x0013

#define LOCKED_TO_AXIS_VERTICAL	0x0100 /* Parallel to vertical axis*/
#define LOCKED_TO_AXIS_HORIZ	0x0200 /* Parallel to horizantal axis*/
#define LOCKED_TO_AXIS		0x0300

#define LOCKED_TO_AXIS_SRC_DIR	0x0313

#define LOCKED_TO_CENTER_H	0x1000 /* Parallel to horizantal cross_hair */
#define	LOCKED_TO_CENTER_V	0x2000 /* Parallel to vertical cross_hair */
#define LOCKED_TO_CENTER	0x3000

/* Value types for the text with leader macro */

#define DIM_DISTANCE		0		
#define DIM_ANGLE 		1
#endif
