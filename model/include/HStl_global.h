
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:57 $
$Locker:  $
*/

#ifndef HStl_global_h_include
#define HStl_global_h_include 1

/*
 * HStl_global.h contains definitions for those variables that are global
 * to the tiler and below.
 */


/*
 * Tiler mode flag values.
 */

#define SHADE_IT		0
#define RENDER_IT		1
#define FIND_ITS_MIN_X		2

/*
 * Tiler status flag values.
 */

#define HSSTAT_OK		0
#define HSSTAT_ALLOC_ERROR	100
#define HSSTAT_BOUND_ERROR	200
#define HSSTAT_VIEW_DYN_LIMIT	300
#define HSSTAT_OUT_OF_RANGE	400
#define HSSTAT_DEG_SURFACE	-6
#define HSSTAT_MATH_ERROR	-2
#define HSSTAT_FEM_ERROR	-300
#define HSSTAT_EDGEII_FEM	-400

/*
 * Structure containing global tiler parameters.
 */

struct	HS_tiler_parms
	{
	IGRint		number_colors;		/* number of active colors	*/
	IGRint		number_shades;		/* number of active shades	*/
	IGRint		apparent_shades;	/* number of apparent shades	*/
        IGRint          apparent_shades_fem;    /* the number of apparent shades*/
                                                /* for fem when in ramp mode    */
        IGRint          start_slot_fem;         /* start slot:fem in ramp mode  */
	IGRint		base_color;		/* start index of color table	*/
	IGRint		status;			/* status flag			*/
	
	IGRint		x_offset, y_offset;	/* How much to offset paint	*/
	
	unsigned int	processing_mode;	/* what the tiler is doing	*/

	IGRdouble	maximum_z;		/* maximum z-buffer value	*/

	IGRchar		*(*zmalloc)();		/* points to the hsurf malloc	*/
	IGRchar		*(*zrealloc)();		/* points to the hsurf realloc	*/
	void		*(*zfree)();		/* points to the hsurf free	*/
	IGRboolean	region_update;		/* if updating in display region	*/
	IGRint		region_style;		/* type of shading style for display region	*/
	IGRint 		region_original_style;  /* original style of window */
	IGRint		dr_xmin;		/* display region min x value */
	IGRint		dr_ymin;		/* display region min y value */
	IGRint		dr_xmax;		/* display region max x value */
	IGRint		dr_ymax;		/* display region max y value */
	IGRint 		window_x_dits,window_y_dits; /*  dits of window supported by display region */
	IGRint		hardware_type;		/* hardware regardless of using ignore locked zbuff sup by dr*/

	unsigned int	window_id;		/* window object id		*/
	unsigned short	window_os;		/* window object space number	*/
	
	unsigned short	ambient[4];		/* red, green, blue and average intensity for the ambient light */
	};


extern struct HS_tiler_parms	tiling_parms;

/*
 *  Processing mode flags
 */

#define HS_PMODE_PROC_MODES		0x000000FF 
#define	HS_PMODE_WIREFRAME		0x00000001
#define	HS_PMODE_SHADING		0x00000002
#define	HS_PMODE_RHL_SURFACE		0x00000004
#define	HS_PMODE_RHL_EDGES		0x00000008
#define	HS_PMODE_LVHL_SURFACE		0x00000010
#define	HS_PMODE_LVHL_EDGES		0x00000020
#define	HS_PMODE_RHL_OLD		0x00000040
#define	HS_PMODE_RHL_SHOW_HIDDEN	0x00000080

#define	HS_PMODE_FEEDBACK		0x00000100
#define	HS_PMODE_FEEDBACK_FULL		0x00000200
#define	HS_PMODE_DEXEL			0x00000400
#define	HS_PMODE_CLIP			0x00000800
#define	HS_PMODE_SHADED_PLOT		0x00001000
#define	HS_PMODE_RENDER_IMAGE		0x00002000
#define	HS_PMODE_TEXTURE_MAP		0x00004000

#define	HS_PMODE_DIRECT			0x80000000
#define	HS_PMODE_IP32			0x40000000
#define	HS_PMODE_USE_EDGE2		0x20000000
#define	HS_PMODE_TRANS_1x1		0x10000000
#define HS_PMODE_DISPLAY_HIDDEN_LINES	0x08000000
#define HS_PMODE_EDGE_OBJECT		0x04000000
#define HS_PMODE_SWINE			0x02000000
#define	HS_PMODE_DONT_ZBUFFER		0x01000000

#define HS_PMODE_PVHL_SURFACE		0x00800000
#define HS_PMODE_PVHL_EDGES		0x00400000
#define HS_PMODE_PVHL_OBJECT_BEGIN	0x00200000
#define HS_PMODE_PVHL_OBJECT_END	0x00100000
#define HS_PMODE_PVHL_NEW_LOOP		0x00080000
#define HS_PMODE_CREATE_HRZ_CVS         0x00040000  /*create horizon curves/edges flag*/
#define HS_PMODE_PHONG_LIGHTS		0x00020000



#endif
