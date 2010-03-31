
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsmacdef_include
#define hsmacdef_include 1

/* shading style options */
#define HS_STYLE_SMOOTH		0
#define HS_STYLE_CONSTANT	1
#define HS_STYLE_RASTER		2
#define HS_STYLE_FILLED_RASTER	3
#define HS_STYLE_AREAFILL	4
#define HS_STYLE_WIREFRAME	5

/* translucency options  */
#define HS_TRANS_OPAQUE        0
#define HS_TRANS_TRANSLUCENT   1

/* translucency grid options */
#define HS_GRID_NARROW  0
#define HS_GRID_WIDE    1

/* style, transparency, finish and reflectance mode options */
#define HS_MODE_ACTIVE  0
#define HS_MODE_ELEMENT 1

/* color calibration options */
#define	HS_COLOR_CAL_NO	      0
#define	HS_COLOR_CAL_YES      1

/* shade calculation mode options */
#define HS_SHADE_CALC_SYSTEM  0
#define HS_SHADE_CALC_USERS   1

/* color table display options */
#define HS_TABLE_DISPLAY_NO   0
#define HS_TABLE_DISPLAY_YES  1

/* dither options */
#define HS_DITHER_HALFTONED  0
#define HS_DITHER_DIRECT     1

/* light coord system options */
#define HS_LIGHT_SYS_VIEW      0
#define HS_LIGHT_SYS_DATABASE  1

/* shading accuracy mode options */
#define HS_ACCURACY_MODE_WINDOW   0
#define HS_ACCURACY_MODE_ACTIVE   1
#define HS_ACCURACY_MODE_ELEMENT  2

/* keep plot/raster file options */
#define HS_KEEP_FILE_YES 0
#define HS_KEEP_FILE_NO  1

/* FEM contour tile shading style options */
#define	HS_FEM_DIRECT	0
#define	HS_FEM_BLENDED	1

/* FEM contour tile mesh mode options */
#define	HS_FEM_MESH_OFF	0
#define	HS_FEM_MESH_ON	1

/* show hidden edges options */
#define HS_SHOW_HIDDEN_EDGES_YES 0
#define HS_SHOW_HIDDEN_EDGES_NO  1

/* culling options */
#define HS_CULL_YES 0
#define HS_CULL_NO  1

#endif
