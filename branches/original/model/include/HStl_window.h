
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:57 $
$Locker:  $
*/

/*
History
   4/4/94   M. Lanier
      Added xgl_context_3D, type Xgl_object, to the active window
      structure
*/

#ifndef HStl_window_include
#define HStl_window_include 1

/*
 * HStl_window.h contains definitions of window-specific tiler variables.
 */

#include "wl.h"
#include "hslight.h"

/*
 * Window hardware type flags.
 *
 *    MPX - pixel size of screen
 *    LB -- Graphics Library
 *    ZB -- Locked Zbuffer
 *    CB -- CoProcessor
 */

#define	HShardware_MPX_MASK		0x000000FF
#define	HShardware_1MPX			0x00000001
#define	HShardware_2MPX			0x00000002
#define	HShardware_4MPX			0x00000004

#define HShardware_LB_MASK		0x0000FF00
#define HShardware_LB_HSURF_ROP		0x00000100
#define HShardware_LB_HSURF		0x00000200
#define HShardware_LB_GPIPE		0x00000400
#define HShardware_LB_EG		0x00000800
#define HShardware_LB_OPENGL		0x00001000
#define HShardware_LB_XGL		0x00002000

#define HShardware_ZB_MASK		0x000F0000
#define HShardware_ZB_NONE		0x00000000
#define HShardware_ZB_16		0x00010000
#define HShardware_ZB_24		0x00020000
#define HShardware_ZB_32		0x00040000

#define HShardware_CP_MASK		0x00F00000
#define HShardware_CP_NONE		0x00000000
#define HShardware_CP_ASAP1		0x00100000
#define HShardware_CP_ASAP2		0x00200000


/*
 * Window buffer type definitions.
 */

#define HSzbuf			unsigned long		/* z-buffer element		*/
#define HScbuf			unsigned char		/* image buffer element		*/


/*
 * Window buffer element default values.
 */

#define	HS_BACKGROUND_Z		0x7fffffff		/* maximum z-buffer depth	*/
#define	HS_BACKGROUND_COLOR	0			/* background color		*/
#define HS_BIT_PLANE_MASK	0xFF			/* plane enable mask		*/



/*
 * Window-specific tiler parameters
 */

struct HS_window_parms
	{
	IGRint			pipe_no;		/* unique geometry pipeline id	*/
	IGRint			gpipe_id;		/* unique geometry pipeline id	*/
	IGRint			persp_pipe_no;		/* temp. perspective pipe	*/
	IGRint			ortho_pipe_no;		/* temp. orthogonal pipe	*/
	WLuint32		win_no;			/* logical window               */
        WLhwin_no               hwin_no;                /* hardware window number       */
	IGRint			vs_no;			/* virtual screen window on     */
        WLuint32                context_no;             /* WL context number for window */
#       if defined (XGL)
        Xgl_object              xgl_context_3D;         /* XGL viewing context number   */
#       endif
	IGRint			EG_vc_no;		/* EG viewing context number	*/
	IGRint			org_x, org_y;		/* viewport origin in window	*/
	IGRint			x_dits, y_dits;		/* viewport extent in window	*/

	IGRboolean		grid_on;		/* grid display flag		*/
	IGRdouble		rotate_matrix[3][3];	/* world-to-view rotation	*/
	IGRdouble		transform_matrix[4][4];	/* world-to-viewport transform	*/
	IGRdouble		wv_scale;		/* world-to-viewport scale	*/
	IGRboolean		perspective;		/* parallel/perspective flag	*/
	IGRdouble		persp_x_scale;		/* non-uniform scaling (persp.)	*/
	IGRdouble		persp_y_scale;		/* non-uniform scaling (persp.)	*/
	IGRdouble		persp_z_scale;		/* non-uniform scaling (persp.)	*/

	IGRdouble		dit_clip_range[6];	/* clip range in dits		*/
	IGRdouble		z_min, z_max;		/* z-range use in parallel proj	*/
	IGRdouble		zscale;			/* zscale factor		*/
	IGRboolean		depth_cue_on;		/* doing depth cueing		*/
	IGRdouble		depth_cue_base;		/* depth cue parameters		*/
	IGRdouble		depth_cue_delta;

	IGRint			num_lights;		/* number of light souces (0-8)	*/
	struct HS_light_source	light_sources[MAX_LIGHTS];/* light sources		*/

	IGRint			shading_style;		/* window shading style		*/

	IGRint			x_min, y_min;	        /* paint region low		*/
	IGRint			x_max, y_max;	        /* paint region high		*/
	IGRint			x_min_us, y_min_us;	/* paint region low, unsuppor	*/
	IGRint			x_max_us, y_max_us;	/* paint region high, unsuppor	*/
	IGRint			x_min_rl, y_min_rl;     /* edges silhouette region low  */
	IGRint			x_max_rl, y_max_rl;     /* edges silhouette region high */	
	IGRint			zbuf_size;	        /* bytes in z buffer 		*/
	IGRint			cbuf_size;	        /* bytes in image buffer 	*/
	HSzbuf			*zbuf;		        /* base address of z buffer	*/
	HScbuf			*cbuf;		        /* base address of image buffer	*/

	IGRint			num_bytes;		/* number bytes in win buffers	*/
	IGRint			num_pixels;		/* number of pixels in window	*/
	IGRint			type;			/* window hardware type		*/
	IGRboolean		initialized;		/* win buffers initialized flg	*/
        IGRboolean              making_triangles;       /* TRUE, if making triangles    */
        IGRboolean              using_ramps;            /* TRUE, if using ramps         */
	IGRboolean		initialized_for_edge2;	/* fct ptrs init for edge2 flg	*/
	IGRboolean		user_notified;		/* z-range warning status flag	*/

        WLuint32                saved_win_context;      /* context number to be restored in window  */

	IGRint		paint_delay[2];
	IGRboolean	ignore_locked_zbuffer;
	IGRboolean	unsupported_zbuffer_allocated;
	IGRboolean      image_buffer_valid;
	IGRint		active_zbuffer;			/* 0 is normal, 1 for non supp	*/
	void		(*init_window[2])();		/* window init function pointer	*/
	void		(*init_paint[2])();		/* paint init function pointer	*/
	void		(*start_polyline[2])();		/* polyline start function ptr	*/
	void		(*continue_polyline[2])();	/* polyline cont function ptr	*/
	void		(*draw_point[2])();		/* point drawing function ptr	*/
	void		(*rasterizer[2])();		/* rasterizing function pointer	*/
	void		(*painter[2])();		/* painting function pointer	*/
	void		(*silhouetter[2])();		/* silhouetting function ptr	*/
	void		(*prepare_facet[2])();		/* prepare to process facet	*/
	void		(*process_facet)();		/* polygon processor pointer	*/
	int		(*process_mesh)();		/* mesh processor pointer	*/
	void		(*polybuster)();		/* polybusting function pointer	*/
	
#	if defined(__STDC__) || defined(__cplusplus)
		void	(*add_vertex[2])( IGRdouble,		/* facet-building function ptr	*/
					  IGRdouble,
					  IGRdouble,
					  IGRdouble,
					 IGRboolean,
					  IGRdouble,
					  IGRdouble,
					  IGRdouble,
					  IGRdouble,
					  IGRdouble );
#	else
		void	(*add_vertex[2])();		/* facet-building function ptr	*/
#	endif

	void		(*end_loop[2])();		/* loop-ending function pointer	*/
        struct WLraster_data image;                     /* image structure for cb of entire shading window */
                                                        /* has entire image; used to cut down on WLcreate_raster_data*/
                                                        /* calls 9/14/93 JDU */

	struct HS_window_parms	*next;			/* next pointer			*/
	};

extern struct HS_window_parms	*active_window;

#endif
