/* AAdef.h -- Application Accelerator (asapII) definitions */

#ifndef AAdef_dot_h
#define AAdef_dot_h 1

/* request codes */
#define AA_PRINT_STATISTICS	-1
#define AA_TOGGLE_DUMPS		-2
#define AA_BS_CHANGE_PAR	 1
#define AA_BSURF_TILER		 2
#define AA_BCURVE_TILER		 3
#define AA_TEXT_TILER		 4
#define AA_PLINE_TILER		 5
#define AA_POINT_TILER		 6
#define AA_ACTIVATE_WINDOW	 7
#define AA_INIT_SHD_WINDOW	 8
#define AA_SETUP_SHD_WINDOW	 9
#define AA_DEL_ACTIVE_WINDOW	10
#define AA_RESET_XFORM_MATRIX	11
#define AA_STROKE_XFORM_MATRIX	12
#define AA_STROKE_CURVE		13
#define AA_STROKE_SURFACE	14
#define AA_WIREFRAME_CLIP_RANGE	15
#define AA_STROKE_LINESTRING	16
#define AA_LVHL_INIT_WINDOW	17
#define AA_RENDERING_GLOBALS	18
#define AA_RENDER_TILER		19
#define AA_RENDER_MODE		20

/* answer codes */
#define AA_DISPLAY_POLYLINE		1
#define AA_DISPLAY_TRIMESH		2
#define AA_RENDERING_PARMS		3
#define AA_DISPLAY_WIREFRAME_LINESTRING	4
#define AA_CLIP_RANGE			5
#define AA_REPORT_ERROR			6
#define AA_DISPLAY_TRAPEZOID		7
#define AA_RENDER_TRAPEZOID		8

/* other */
#define on_boundary_of(x,type) (((int)(x)+sizeof(type)-1)&~(sizeof(type)-1))

#if TIMING
#define AAtimer(x) AA_timer(x)
#if i860 && !ASAPII_GLOBALS
extern void AA_timer (float *);
#endif
#else
#define AAtimer(x)
#endif

#endif
