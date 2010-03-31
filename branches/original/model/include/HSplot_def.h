
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:57 $
$Locker:  $
*/

#ifndef HSplot_def_include
#define HSplot_def_include 1

/*
 *  Form ids
 */

#define HSplot_CREATE_FORM	0
#define HSplot_SUBMIT_FORM	1
#define HSplot_STATUS_FORM	2
#define HSplot_OPTION_FORM	3

/*
 *  Return Codes from CO routines
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

/*
 *  Units
 */
 
#define	UNIT_INCHES		0
#define UNIT_CENTIMETERS	1
#define	UNIT_FEET		2
#define UNIT_METERS		3

#define EXIT_COMMAND		4000
#define EXECUTE_COMMAND		4001
#define WINDOW_CONTENTS_COMMAND	4002
#define FENCE_CONTENTS_COMMAND	4003


#define SETUP_COMMAND			0
#define   SET_COLOR_TABLE_RGB			0
#define   SET_TRANSLUCENCY_GRID			5
#define   SET_DEPTH_CUE_INTENSITIES		6
#define   OLD_OLD_WINDOW_LIGHT_SOURCE		7
#define   OLD_OLD_GLOBAL_LIGHT_SOURCE		8
#define   SET_VIEW_ORIENTATION_RANGE		11
#define   OLD_OLD_AMBIENT_LIGHT_SOURCE		13
#define   SET_VIEW_IN_PARALLEL			16
#define   SET_VIEW_IN_PERSPECTIVE		17
#define   OLD_WINDOW_LIGHT_SOURCE		18
#define   OLD_GLOBAL_LIGHT_SOURCE		19
#define   OLD_AMBIENT_LIGHT_SOURCE		20
#define   SET_WINDOW_LIGHT_SOURCE		21
#define   SET_GLOBAL_LIGHT_SOURCE		22
#define   SET_AMBIENT_LIGHT_SOURCE		23
#define   SET_USER_LINE_STYLE			24
#define   SET_MIPMAP_HOME                       25

#define BASIC_ATTR_COMMAND		2
#define   SET_ACTIVE_FG_COLOR_INDEX		0
#define   SET_ACTIVE_FG_COLOR_RGB		4
#define   SET_ACTIVE_LINE_STYLE			8
#define   SET_ACTIVE_LINE_WIDTH			9
#define   SET_ACTIVE_RENDERING_MODE		13
#define   SET_ACTIVE_TRANSLUCENCY		14
#define   SET_ACTIVE_ROTATION_MATRIX		21
#define   SET_ACTIVE_POST_ROTATION_MATRIX	22
#define   SET_ACTIVE_TILING_TOLERANCE		23
#define   SET_ACTIVE_SHADING_ACCURACY		24
#define   SET_VIEWPORT_TO_WLD_MATRIX		25
#define   SET_HIDDEN_SYMBOLOGY			26
#define   SET_OBJECT_INFO			27
#define   SET_ACTIVE_PHONG_ATTRIBUTES		28
#define   SET_ACTIVE_MIPMAP			29

/*
 *  10-1-93: Create a new curve/edge tag.  Changing
 *           the soo structure for each (ML)
 */
 
#define PRIMITIVE_COMMAND		4
#define   oldNURB_CURVE				2
#define   NURB_SURFACE				6
#define   oldNURB_CURVE_WITH_RANGE		7
#define   NURB_SURFACE_WITH_RANGE		8
#define   oldNURB_EDGE				9
#define   NURB_CURVE				10
#define   NURB_CURVE_WITH_RANGE			11
#define   NURB_EDGE				12


/*
 *  rendering modes
 */
 
#define		HPmode_WIREFRAME		0
#define		HPmode_SMOOTH			1
#define		HPmode_CONSTANT			2
#define		HPmode_AREA_FILL		3
#define		HPmode_OLD_RASTER_EDGES		4
#define		HPmode_OLD_REV_RASTER_EDGES	5
#define		HPmode_PHONG			6
#define		HPmode_HIDDEN_EDGES		7
#define		HPmode_RASTER_EDGES		8
#define		HPmode_REV_RASTER_EDGES		9

/*
 *  Rasterfile data types
 */

#define         HPrasterfile_type_Undefined     0
#define         HPrasterfile_type_25            25
#define         HPrasterfile_type_27            27
#define         HPrasterfile_type_PS            0x0101

/* 
 *  plot submission flags 
 */
 
#define		KEEP_METAFILE           0x0001
#define		KEEP_RASTER_FILE        0x0002

/*
 *  other
 */
 
#define	HP_DEFAULT_LINE_WIDTH_CONSTANT	0.005
#define	HP_DEFAULT_MAX_LINE_WIDTH	16
#define	HP_DEFAULT_USER_LINE_WIDTH	16

/*
 *  con_flags mask
 */
 
#define HP_CONTROL_EXIT				0x80000000
#define HP_CONTROL_EXIT_AND_SAVE		0x40000000
#define HP_CONTROL_EXECUTE			0x20000000
#define HP_CONTROL_DONT_ERASE			0x10000000
#define HP_CONTROL_FENCE_DEFINED		0x08000000
#define HP_CONTROL_WINDOW_DEFINED		0x04000000
#define HP_CONTROL_SUBMIT_PLOTFILE		0x02000000
#define HP_CONTROL_SUBMIT_RASTERFILE		0x01000000
#define HP_CONTROL_SUBMIT_TEXTFILE		0x00800000
#define HP_CONTROL_WRITTEN_TO_PLOTFILE		0x00400000
#define HP_CONTROL_USE_DPB_DEFAULTS		0x00200000
#define	HP_CONTROL_FENCE_IN_SHADING_WINDOW	0x00100000
#define HP_CONTROL_WRITE_TO_PLOTFILE_ERROR	0x00080000
#define HP_CONTROL_PERSPECTIVE			0x00040000
#define	HP_CONTROL_FENCE_IN_PARALLEL_WINDOW	0x00020000
#define HP_CONTROL_ACTIVE_COLOR_RGB		0x00010000
#define HP_CONTROL_DEF_QUE_NOT_EXIST		0x00008000
#define HP_CONTROL_CREATE_FORM_DISPLAYED        0x00004000
#define HP_CONTROL_SUBMIT_FORM_DISPLAYED        0x00002000
#define HP_CONTROL_STATUS_FORM_DISPLAYED        0x00001000
#define HP_CONTROL_OPTION_FORM_DISPLAYED        0x00000800
#define HP_CONTROL_CREATE_FORM_DISABLED         0x00000400

/*
 *  Goes with the nurb curve flags defined in ems_plot_def.h
 */
 
#define		CV_HAS_SOO		0x0020

#endif
