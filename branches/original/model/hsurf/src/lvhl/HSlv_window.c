
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:39 $
$Locker:  $

HISTORY

        Sudha   07/27/93        Modified for BSprototypes ansification

*/

/*		Apogee compliant		*/

#include <stdio.h>
#include <stdlib.h>

#include <FI.h>
#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "growner.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "dp.h"
#include "godef.h"

#include "ma.h"
#include "mainvmx.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hsmath.h"
#include "hsdef.h"
#include "hsmacdef.h"
#include "hsurf.h"

#include "HSlvhl.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"
#include "HSplot.h"

#include "HSpr_lvhl.h"

/*-----------------------
 *  for functions
 *     HSactivate_window
 *     HSset_ele_clip_range
 *     HSset_element_color
 *     HSset_maximum_z
 *     HSset_rendering_mode
 *     HSsetup_shading_window
 *     add_vertex_to_loop
 *     clip_and_shade
 *     end_facet_loop
 *     process_facet
 */
 
#include "HSpr_tiler_f.h"

/*----------------------------
 *  for functions
 *     HScontinue_pline_vedge
 *     HSstart_pline_vedge
 *     HStrap_vedge
 */
 
#include "HSpr_display.h"

/*---------------------------
 *  for functions
 *     HSget_top_range
 */
 
#include "HSpr_driver.h"


/*---------------------------*/

 


/*
 *  Prototype declaration for static functions
 */


#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HSlv_window.c */
static void HSstub __((void));
static void HSlvhl_init_paint __((IGRint *color));
static void HSset_lvhl_routines __((void));

#if defined(__cplusplus)
}
#endif


#undef __


/*
extern void	HSstart_pline_vedge();
extern void	HScontinue_pline_vedge();
extern void	HStrap_vedge();
extern void	clip_and_shade();
extern void	add_vertex_to_loop(IGRdouble x, 
			    IGRdouble y, 
			    IGRdouble z, 
			    IGRdouble w, 
			   IGRboolean e, 
			    IGRdouble nx, 
			    IGRdouble ny, 
			    IGRdouble nz, 
			    IGRdouble u, 
			    IGRdouble v);
extern void	end_facet_loop();
extern void	process_facet();
*/

static void	HSstub()	{}


/*---HSlvhl_init_paint-------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HSlvhl_init_paint( IGRint *color )
#else
	static void	HSlvhl_init_paint( color )

	IGRint		*color;
#endif

	{
	HSset_element_color( *color );
	}
	
/*---HSset_lvhl_routines------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HSset_lvhl_routines(void)
#else
	static void	HSset_lvhl_routines()
#endif

/*
 * DESCRIPTION:
 *	HSset_lvhl_routines sets the default function pointers in the active window
 *	to lvhl functions
 */

	{
 	active_window->init_paint[0] = HSlvhl_init_paint;
	active_window->init_window[0] = HSstub;
	active_window->start_polyline[0] = HSstart_pline_vedge;
	active_window->continue_polyline[0] = HScontinue_pline_vedge;
	active_window->rasterizer[0] = HStrap_vedge;
	active_window->draw_point[0] = HSstub;
	active_window->painter[0] = HSstub;

	active_window->prepare_facet[0] = clip_and_shade;
	active_window->add_vertex[0] = add_vertex_to_loop;
	active_window->end_loop[0] = end_facet_loop;

	active_window->process_facet = process_facet;
	}
		
/*---HSlvhl_init_window-----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	int HSlvhl_init_window( int pipe_no, 
				int win_no,
		   struct DPgra_gad *gragad,
				int xdits,
				int ydits )
#else
	int	HSlvhl_init_window( pipe_no, win_no, gragad, xdits, ydits )

	int			pipe_no, win_no;
	struct DPgra_gad	*gragad;
	int			xdits, ydits;
#endif

	{
	struct HS_light_source	global_lights[MAX_LIGHTS];
	struct HS_light_source	ambient_light;
	
	IGRlong		msg;
	IGRshort	dim;  /* Sun Fix - S.P. Rogers 10/31/91 */
	IGRint		row, col;
	IGRdouble	*top_range, dummy_range[6];

	
        HSactivate_window( pipe_no );
	active_window->type = HShardware_1MPX | HShardware_LB_HSURF_ROP | HShardware_ZB_NONE | HShardware_CP_NONE;
	WLget_window_base_context( win_no, &active_window->context_no );

		
	HSset_rendering_mode( 0 );

	HSset_maximum_z( (double)(0x00ffffff) );
	
	/*
	 *  This will initialize HSURF for shading this scene.  Because we are overriding
	 *  the init_window function pointer, HSURF will not talk to a window.
	 */

	HSactivate_window( pipe_no );
	HSset_lvhl_routines();
		
	top_range = dummy_range;	 
	if( !HSget_top_range(top_range) )
		top_range = NULL;

	global_lights[0].flags = 0;
	global_lights[1].flags = 0;
	global_lights[2].flags = 0;
	global_lights[3].flags = 0;
	global_lights[4].flags = 0;
	global_lights[5].flags = 0;
	global_lights[6].flags = 0;
	global_lights[7].flags = 0;
	ambient_light.flags = 0;
	
	HSsetup_shading_window(
			gragad->wld_to_view, gragad->vw_volume,
			gragad->eye_pt, gragad->vrp,
			gragad->vpn, gragad->vup,
			pipe_no, win_no,
			(int)0, (int)0,
			xdits,
			ydits,
			top_range,
			gragad->dit_clip_range,
			gragad->wld_to_viewport,
			gragad->rotation,
			global_lights,
			&ambient_light,
			100.0,
			100.0,
			gragad->vvol_viewport_scale,
			0.0, 0.0, 0.0,
			FALSE,
			FALSE,
			FALSE,
			FALSE );

	/* 
	 * Transformation matrix ... use the world to view matrix
	 * which has no scaling and negate Z's
	 */
	 
	for( row=0; row<3; row++ )
		for( col=0; col<4; col++ )
			HSlvhl.t_matrix[row][col] = gragad->wld_to_view[row][col];

	for( col=0; col<4; col++ )
		HSlvhl.t_matrix[2][col] = -HSlvhl.t_matrix[2][col];

	HSlvhl.t_matrix[3][0] = 0.0;
	HSlvhl.t_matrix[3][1] = 0.0;
	HSlvhl.t_matrix[3][2] = 0.0;
	HSlvhl.t_matrix[3][3] = 1.0;

	/* Inverse matrix. */
	
	dim = 4;
	MAinvmx( &msg, &dim, (IGRdouble *)HSlvhl.t_matrix, (IGRdouble *)HSlvhl.i_matrix );
			
	
	HSactivate_window( pipe_no );
	active_window->x_dits = xdits;
	active_window->y_dits = ydits;

	HSset_ele_clip_range( gragad->dit_clip_range );
	
	return(0);
	}
