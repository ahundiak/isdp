/*		Apogee compliant		*/

#include "hsurf_import.h"
#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "gpipe.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "hsmath.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "hsdef.h"
#include "hsmacdef.h"
#include "HSlvhl_info.h"


extern void	HSstart_pline_vedge();
extern void	HScontinue_pline_vedge();
extern void	HStrap_vedge();
extern void	clip_and_shade();
extern void	add_vertex_to_loop();
extern void	end_facet_loop();
extern void	process_facet();

/*---HSstub-----------------------------------------------------------------*/

static void	HSstub()	
	{
	}

/*---HSlvhl_init_paint-------------------------------------------------------------------*/

static void	HSlvhl_init_paint( color, request_code )

IGRint		*color;
IGRint		*request_code;

	{
	HSset_element_color( get_color_index( color ) );
	}
	
/*---HSset_lvhl_routines------------------------------------------------------*/

static void	HSset_lvhl_routines()

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
		
/*---HSinit_lvhl_window-----------------------------------------------------*/

int	HSinit_lvhl_window( pipe_no, win_no, gragad, post_rotation, lvhl_info )

int			pipe_no, win_no;
struct DPgra_gad	*gragad;
double			post_rotation[4][4];
struct HSlvhl_info	*lvhl_info;

	{
	IGRdouble	*top_range, dummy_range[6];
	IGRdouble	*tmatrix;
	IGRboolean	is_persp;
	IGRdouble	x_scale, y_scale, z_scale;


	if( gragad->flags & IS_PERSP )
		{
		is_persp = TRUE;
		tmatrix = (IGRdouble *)gragad->wld_to_view;

		x_scale = post_rotation[0][0];
		y_scale = post_rotation[1][1];
		z_scale = post_rotation[3][2];
		}
	else
		{
		is_persp = FALSE;
		tmatrix = (IGRdouble *)gragad->wld_to_viewport;
		}

	active_window->type = 
		HShardware_1MPX | HShardware_GB_ROP | HShardware_ZB_NONE | HShardware_CP_NONE;
		
	HSset_rendering_mode( 0 );
	HSset_clip_mode( FALSE );

	HSset_maximum_z( (double)(0x00ffffff) );
	
	tiling_parms.processing_mode &= ~HS_PMODE_RHL_SHOW_HIDDEN;

	/*
	 *  This will initialize HSURF for shading this scene.  Because we are overriding
	 *  the init_window function pointer, HSURF will not talk to a window.
	 */

	top_range = dummy_range;	 
	if( !HSget_top_range(top_range) )
		top_range = NULL;

	HSset_lvhl_routines();
	
	HSsetup_shading_window(
			NULL, NULL, NULL, NULL, NULL, NULL,
			pipe_no, win_no,
			(int)0, (int)0,
			lvhl_info->xdits,
			lvhl_info->ydits,
			NULL, /*top_range,*/
			gragad->dit_clip_range,
			tmatrix,
			gragad->rotation,
			NULL,
			NULL,
			100.0,
			100.0,
			gragad->vvol_viewport_scale,
			post_rotation[0][0],
			post_rotation[1][1],
			post_rotation[3][2],
			is_persp,
			FALSE,
			FALSE,
			FALSE );

	HSactivate_window( pipe_no );
	active_window->x_dits = lvhl_info->xdits;
	active_window->y_dits = lvhl_info->ydits;

	HSset_ele_clip_range( gragad->dit_clip_range );
	return(0);
	}
