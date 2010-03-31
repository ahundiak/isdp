
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

class implementation Root;


/*
 *  NOTE****
 * 
 *     I copied this version of this code to obsolete because there are
 *  some functions here that I've delete from the active copy, that calls
 *  the tiler directly.  I don't need them anymore, but I don't want to
 *  loose them either
 */
 
#define	CHECK_RETURN_CODES	1

#include <stdio.h>
#include <tools.h>
#include <FI.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "dpstruct.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dp.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsurferrpriv.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hsmsg.h"
#include "HStl_global.h"
#include "DEso.h"
#include "DEglob.h"
#include "HSlvhl.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "plotdef.h"
#include "plotmacros.h"

from IGEgragad	import DPcal;
from GRgraphics import GRdisyourself; 
from GRvg	import GRgenabsg;
from GRvg	import GRgetrang;
from GRvg	import GRgetsymb;
from GRvg	import GRgetprops;
from GRvg	import GRchgprops;
from DEso	import DEget;

#define	if_bad( status )	if ( !( (status) & 1 ) )

extern void	HStile_object();

#define	DEBUG	0

%safe
static struct DP_information 	sp_info;
static struct GRid		window;
static IGRboolean		scaled;
static IGRint			original_dep_range[4];
static IGRint			original_gpipe_id;
static struct gragad_inst	gragad_stuff;
%endsafe


/*---transform---------------------------------------------------------*/

static	transform( point, matrix )

IGRdouble	point[3];
IGRdouble	matrix[4][4];

	{
	IGRdouble	new_x, new_y, new_z;
	
	new_x = (matrix[0][0] * point[0]) + (matrix[0][1] * point[1]) +
		(matrix[0][2] * point[2]) + (matrix[0][3]);
	new_y = (matrix[1][0] * point[0]) + (matrix[1][1] * point[1]) +
		(matrix[1][2] * point[2]) + (matrix[1][3]);
	new_z = (matrix[2][0] * point[0]) + (matrix[2][1] * point[1]) + 
		(matrix[2][2] * point[2]) + (matrix[2][3]);
		
	point[0] = new_x;
	point[1] = new_y;
	point[2] = new_z;
	}
	
/*---HSlvhl_get_fence_range-----------------------------------------------------------*/

static int	HSlvhl_get_fence_range( window, fence_range )

struct GRid	*window;
IGRdouble	*fence_range;

	{
	IGRlong			msg, sts;
	struct GRmd_env		module;
	IGRdouble		world[6];
	IGRdouble		view[6];
	IGRlong			sizbuf, nret;
	struct GRid		fence;
	struct GRid		fence_window;
	struct IGRcv_prism	*prism;
	IGRint			i, j;

	sizbuf = sizeof( struct GRmd_env );
	
	sts = gr$get_module_env( msg = &msg,
			      sizbuf = &sizbuf,
			      buffer = &module,
			        nret = &nret );

	plot$get_fence_range( msg = &msg,
			   module = &module,
			    fence = &fence,
			   window = &fence_window,
			    world = world,
			     view = view,
			  cvprism = &prism );
			  
	if( msg == MSSUCC )
		{
		if( window->objid != fence_window.objid ||
		    window->osnum != fence_window.osnum )
			{
			return( FALSE );
			}
		else
			{
			IGRdouble	fence_clip_range[6];
			IGRdouble	xprism[12];
			IGRint		i;
		
			for( i=0; i<12; i++ ) xprism[i] = prism->curve.poles[i];
		
			transform( &xprism[0], prism->matrix );
			transform( &xprism[0], gragad_stuff.gragad.wld_to_viewport );

			transform( &xprism[3], prism->matrix );
			transform( &xprism[3], gragad_stuff.gragad.wld_to_viewport );
		
			transform( &xprism[6], prism->matrix );
			transform( &xprism[6], gragad_stuff.gragad.wld_to_viewport );
		
			transform( &xprism[9], prism->matrix );
			transform( &xprism[9], gragad_stuff.gragad.wld_to_viewport );
		
			fence_clip_range[0] = xprism[0];
			fence_clip_range[1] = xprism[1];
			fence_clip_range[2] = xprism[2];

			fence_clip_range[3] = xprism[0];
			fence_clip_range[4] = xprism[1];
			fence_clip_range[5] = xprism[2];

			if( xprism[3] < fence_clip_range[0] ) fence_clip_range[0] = xprism[3];
			if( xprism[4] < fence_clip_range[1] ) fence_clip_range[1] = xprism[4];
			if( xprism[5] < fence_clip_range[2] ) fence_clip_range[2] = xprism[5];
				
			if( xprism[3] > fence_clip_range[3] ) fence_clip_range[3] = xprism[3];
			if( xprism[4] > fence_clip_range[4] ) fence_clip_range[4] = xprism[4];
			if( xprism[5] > fence_clip_range[5] ) fence_clip_range[5] = xprism[5];
				
			if( xprism[6] < fence_clip_range[0] ) fence_clip_range[0] = xprism[6];
			if( xprism[7] < fence_clip_range[1] ) fence_clip_range[1] = xprism[7];
			if( xprism[8] < fence_clip_range[2] ) fence_clip_range[2] = xprism[8];
				
			if( xprism[6] > fence_clip_range[3] ) fence_clip_range[3] = xprism[6];
			if( xprism[7] > fence_clip_range[4] ) fence_clip_range[4] = xprism[7];
			if( xprism[8] > fence_clip_range[5] ) fence_clip_range[5] = xprism[8];
					
			if( xprism[9]  < fence_clip_range[0] ) fence_clip_range[0] = xprism[9];
			if( xprism[10] < fence_clip_range[1] ) fence_clip_range[1] = xprism[10];
			if( xprism[11] < fence_clip_range[2] ) fence_clip_range[2] = xprism[11];
				
			if( xprism[9]  > fence_clip_range[3] ) fence_clip_range[3] = xprism[9];
			if( xprism[10] > fence_clip_range[4] ) fence_clip_range[4] = xprism[10];
			if( xprism[11] > fence_clip_range[5] ) fence_clip_range[5] = xprism[11];
				
			fence_clip_range[2] = gragad_stuff.gragad.dit_clip_range[2];
			fence_clip_range[5] = gragad_stuff.gragad.dit_clip_range[5];

fprintf( stderr, "fence\n" );
fprintf( stderr, "  %f %f %f\n", 
	fence_clip_range[0], fence_clip_range[1], fence_clip_range[2] );
fprintf( stderr, "  %f %f %f\n", 
	fence_clip_range[3], fence_clip_range[4], fence_clip_range[5] );
fprintf( stderr, "window\n" );
fprintf( stderr, "  %f %f %f\n", 
	gragad_stuff.gragad.dit_clip_range[0], 
	gragad_stuff.gragad.dit_clip_range[1], 
	gragad_stuff.gragad.dit_clip_range[2] );
fprintf( stderr, "  %f %f %f\n", 
	gragad_stuff.gragad.dit_clip_range[3], 
	gragad_stuff.gragad.dit_clip_range[4], 
	gragad_stuff.gragad.dit_clip_range[5] );

			memcpy( fence_range, fence_clip_range, sizeof( IGRdouble ) * 6 );
			
			return( TRUE );
			}
		}
	else
		{
		return( FALSE );
		}
	}

/*---HSlvhl_init_display_object-----------------------------------*/

IGRboolean HSlvhl_init_display_object( window_id, resolution, clip_to_fence )

struct GRid	*window_id;
unsigned char	resolution;
IGRboolean	clip_to_fence;

	{
	struct var_list		info[3];
	IGRint			bytes_returned, which_error;
	IGRlong			sts, status, msg;
	IGRchar			buf0[24], buf1[24];	
	IGRint			xdits_scale, ydits_scale;
	IGRint			num_colors, num_shades, dith_mode;
	IGRdouble		fence_range[6];
	
	
	/*
	 *  put the window objid/osnum in the tiler memory
	 */
	 
	HSset_window_object_info( window_id );
	
	window.objid = window_id->objid;
	window.osnum = window_id->osnum;
	
	/*
	 *  Initialize the hidden soo processor so that we can
	 *  delete hidden soos from the curves.
	 */
	 
	HSinit_convert_delete_hidden_symbology( &window, (int)1 );
	
		
	/*
	 *  Get the gragad instance data
	 */

	info[0].var		= GRAGAD_INST_STRUCT;
	info[0].var_ptr		= (char *)&gragad_stuff;
	info[0].num_bytes	= sizeof( struct gragad_inst );
	info[0].bytes_returned	= &bytes_returned;

	info[1].var		= END_PARAM;
	info[1].var_ptr		= NULL;
	info[1].num_bytes	= 0;
	info[1].bytes_returned	= NULL;

	status = dp$inq_set_gragad(
			msg		= &msg,
			inq0_set1	= 0,
			osnum		= window.osnum,
			gragad_objid	= window.objid,
			which_error	= &which_error,
			var_list	= info );

	/*
	 *  If the resolution is not LOW then we will be scaling the
	 *  data.  Save the original dep_range, we will need to reset
	 *  it in the instance data later
	 */
	 
	if( scaled = ( resolution == HS_VHL_LOW_RES ) ? FALSE : TRUE )
		{
		original_dep_range[0] = gragad_stuff.min_x_dep;
		original_dep_range[1] = gragad_stuff.min_y_dep;
		original_dep_range[2] = gragad_stuff.max_x_dep;
		original_dep_range[3] = gragad_stuff.max_y_dep;
		
		original_gpipe_id = gragad_stuff.gragad.gpipe_id;
		}
	
	/*
	 *  Allocate zbuffer memory and initialize the window
	 */

 	if( HSlvhl_allocate_zbuffer_memory(
			255,
			&gragad_stuff.min_x_dep, &gragad_stuff.max_x_dep,
			&gragad_stuff.min_y_dep, &gragad_stuff.max_y_dep,
			scaled ? 4 : 1,
			&xdits_scale, &ydits_scale ) )
		{
		if( scaled )
			{

			/* 
			 *  Load the scaled dep range into the gragad
			 *  instance data
			 */

			info[0].var		= GRAGAD_INST_STRUCT;
			info[0].var_ptr		= (char *)&gragad_stuff;
			info[0].num_bytes	= sizeof( struct gragad_inst );
			info[0].bytes_returned	= &bytes_returned;
		
			info[1].var		= END_PARAM;
			info[1].var_ptr		= NULL;
			info[1].num_bytes	= 0;
			info[1].bytes_returned	= NULL;

			status = dp$inq_set_gragad(
					msg		= &msg,
					inq0_set1	= 1,
					osnum		= window.osnum,
					gragad_objid	= window.objid,
					which_error	= &which_error,
					var_list	= info );

			/*
			 *  call DPcal to recalculate the instance data
			 */
		 		 
			sts = om$send(
				msg      = message IGEgragad.DPcal( &msg ),
				senderid = window.objid,
				targetid = window.objid,
				targetos = window.osnum );

			OM_ERRCHK( sts, "HSlv_init_display: DPcal send failed" );
			MSG_ERRCHK( msg, "HSlv_init_display: DPcal send failed" );

			/*
			 *  Get the gragad instance data again since the
			 *  call to DPcal changed it.
			 */

			info[0].var		= GRAGAD_INST_STRUCT;
			info[0].var_ptr		= (char *)&gragad_stuff;
			info[0].num_bytes	= sizeof( struct gragad_inst );
			info[0].bytes_returned	= &bytes_returned;

			info[1].var		= END_PARAM;
			info[1].var_ptr		= NULL;
			info[1].num_bytes	= 0;
			info[1].bytes_returned	= NULL;

			status = dp$inq_set_gragad(
					msg		= &msg,
					inq0_set1	= 0,
					osnum		= window.osnum,
					gragad_objid	= window.objid,
					which_error	= &which_error,
					var_list	= info );

			}

		hs$get_config( num_colors = &num_colors, num_shades = &num_shades );
		hs$get_color_table_info( dither_mode = &dith_mode );

		HSset_shade_config( 
			255, 0, 
			num_colors, num_shades, 
			(dith_mode == HS_DITHER_HALFTONED) );
			
		/*
		 *  initialize the lvhl window
		 */
		 
		HSlvhl_init_window(
			255,
			gragad_stuff.win_no,
			&gragad_stuff.gragad,
			xdits_scale, ydits_scale );

		if( clip_to_fence )
		if( HSlvhl_get_fence_range( &window, fence_range ) )
			{
fprintf( stderr, "window_clip_range\n" );
fprintf( stderr, "   %f %f %f\n   %f %f %f\n",
	gragad_stuff.gragad.dit_clip_range[0],
	gragad_stuff.gragad.dit_clip_range[1],
	gragad_stuff.gragad.dit_clip_range[2],
	gragad_stuff.gragad.dit_clip_range[3],
	gragad_stuff.gragad.dit_clip_range[4],
	gragad_stuff.gragad.dit_clip_range[5] );
	
			memcpy( gragad_stuff.gragad.dit_clip_range, 
				fence_range, 
				sizeof( IGRdouble ) * 6 );
				
fprintf( stderr, "fence_clip_range\n" );
fprintf( stderr, "   %f %f %f\n   %f %f %f\n",
	gragad_stuff.gragad.dit_clip_range[0],
	gragad_stuff.gragad.dit_clip_range[1],
	gragad_stuff.gragad.dit_clip_range[2],
	gragad_stuff.gragad.dit_clip_range[3],
	gragad_stuff.gragad.dit_clip_range[4],
	gragad_stuff.gragad.dit_clip_range[5] );
	
			HSset_clip_mode( TRUE );
			}

		gragad_stuff.gragad.gpipe_id = 255;
	
		sp_info.gragad = &gragad_stuff.gragad;
		sp_info.win_no = gragad_stuff.win_no;
		sp_info.is_update = FALSE;
		sp_info.is_fit = FALSE;
		sp_info.is_hidden_line = TRUE;
		sp_info.hline_info = NULL;
		sp_info.hl_tiler = HStile_object;
		sp_info.view_objid = window.objid;
		sp_info.view_osnum = window.osnum;
		
		/*
		 *  Get the hidden symbology information
		 */
		 
		hs$get_hidden_symb( symb = &HSlvhl.hidden_symbology );
		
		return( TRUE );
		}
	else
		{
		ex$message( msgnumb=HS_E_LVHL_Memory, buff=buf0 );
		ex$message( msgnumb=HS_E_Error, buff=buf1 );

		status = FI_message_box(
			FI_CURRENT_SCREEN,
			-1, -1,
			buf1,
			FI_RED,
			"swiss742",
			36.0,
			buf0,
			FI_BLACK,
			"swiss742",
			18.0,
			FI_LEFT_JUSTIFIED,
			40 );
			
		return( FALSE );
		}
	}
	
/*---HSlvhl_fini_display_object-----------------------------------*/

void HSlvhl_fini_display_object()


	{
	struct var_list	info[3];
	IGRint		bytes_returned, which_error;
	IGRlong		sts, msg, status;

	if( scaled )
		{

		gragad_stuff.min_x_dep = original_dep_range[0];
		gragad_stuff.min_y_dep = original_dep_range[1];
		gragad_stuff.max_x_dep = original_dep_range[2];
		gragad_stuff.max_y_dep = original_dep_range[3];

		gragad_stuff.gragad.gpipe_id = original_gpipe_id;

		/* 
		 *  reset the dep values in the gragad
		 */

		info[0].var		= GRAGAD_INST_STRUCT;
		info[0].var_ptr		= (char *)&gragad_stuff;
		info[0].num_bytes	= sizeof( struct gragad_inst );
		info[0].bytes_returned	= &bytes_returned;
		
		info[1].var		= END_PARAM;
		info[1].var_ptr		= NULL;
		info[1].num_bytes	= 0;
		info[1].bytes_returned	= NULL;

		status = dp$inq_set_gragad(
				msg		= &msg,
				inq0_set1	= 1,
				osnum		= window.osnum,
				gragad_objid	= window.objid,
				which_error	= &which_error,
				var_list	= info );

		/*
		 *  call DPcal to recalculate the instance data
		 */
		 		 
		sts = om$send(
				msg      = message IGEgragad.DPcal( &msg ),
				senderid = window.objid,
				targetid = window.objid,
				targetos = window.osnum );

		OM_ERRCHK( sts, "HSlv_fini_display: DPcal send failed" );
		MSG_ERRCHK( msg, "HSlv_fini_display: DPcal send failed" );
		}
	}

#if DEBUG
/*---dump_surface--------------------------------------------------------*/

static void	dump_surface( surf )

struct IGRbsp_surface	*surf;		/* input - surface definition */

/*
 * Dumps out the surface definition to standard output. Debugging tool only.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

	{
	IGRint	vi, ui, index, point_cnt;

	fprintf( stderr, "\n\nSurface Definition:\n");
	fprintf( stderr, "  u_order       = %d\n", surf->u_order);
	fprintf( stderr, "  v_order       = %d\n", surf->v_order);
	fprintf( stderr, "  u_num_poles   = %d\n", surf->u_num_poles);
	fprintf( stderr, "  v_num_poles   = %d\n", surf->v_num_poles);
	fprintf( stderr, "  u_num_knots   = %d\n", surf->u_num_knots);
	fprintf( stderr, "  v_num_knots   = %d\n", surf->v_num_knots);
	fprintf( stderr, "  rational      = %d\n\n", surf->rational);

	if( surf->rational != 0 )
		{
		fprintf( stderr, "  Poles (v, u, x, y, z, w):\n" );
		
		for( vi=0; vi<surf->v_num_poles; vi++ )
			{
			for( ui=0; ui<surf->u_num_poles; ui++ )
				fprintf( stderr, "%5d %5d %13.5lf %13.5lf %13.5lf %13.5lf\n",
					vi, ui,
					surf->poles[((vi*surf->u_num_poles)+ui) * 3],
					surf->poles[((vi*surf->u_num_poles)+ui) * 3 + 1],
					surf->poles[((vi*surf->u_num_poles)+ui) * 3 + 2],
					surf->weights[(vi*surf->u_num_poles)+ui] );
					
			fprintf( stderr, "\n");
			}
		}
	else
		{
		fprintf( stderr, "  Poles (v, u, x, y, z):\n" );

		for( vi=0; vi<surf->v_num_poles; vi++ )
			{
			for( ui=0; ui<surf->u_num_poles; ui++ )
				fprintf( stderr, "%5d %5d %13.5lf %13.5lf %13.5lf\n",
						vi, ui,
						surf->poles[((vi*surf->u_num_poles)+ui) * 3],
						surf->poles[((vi*surf->u_num_poles)+ui) * 3 + 1],
						surf->poles[((vi*surf->u_num_poles)+ui) * 3 + 2]);
						
			fprintf( stderr, "\n");
			}
		}

	fprintf( stderr, "\n  U knots:\n");
	
	for( index=0; index<surf->u_num_knots; index++ )
		fprintf( stderr, "%17.9lf\n", surf->u_knots[index] );
		
	fprintf( stderr, "\n  V knots:\n");
	
	for( index=0; index<surf->v_num_knots; index++ )
		fprintf( stderr, "%17.9lf\n", surf->v_knots[index] );

	for( index=0; index<surf->num_boundaries; index++ )
		{
		fprintf( stderr, "\n  Boundary %d:\n", index );
		
		for( point_cnt=0; point_cnt<surf->bdrys[index].num_points; point_cnt++ )
			fprintf( stderr, "%17.9lf %17.9lf \n",
				surf->bdrys[index].points[2 * point_cnt],
				surf->bdrys[index].points[2 * point_cnt + 1]);
		}
	}

/*---dump_curve--------------------------------------------------------*/

static void	dump_curve( curve )

struct IGRbsp_curve	*curve;

	{
	IGRint	ui, index;

	fprintf( stderr, "\n\nCurve Definition: %x\n", curve);
	fprintf( stderr, "  order      = %d\n", curve->order);
	fprintf( stderr, "  num_poles  = %d\n", curve->num_poles);
	fprintf( stderr, "  num_knots  = %d\n", curve->num_knots);
	fprintf( stderr, "  rational   = %d\n\n", curve->rational);

	if( curve->rational != 0 )
		{
		fprintf( stderr, "  Poles (u, x, y, z, w):\n");
		
		for( ui=0; ui<curve->num_poles; ui++ )
			fprintf( stderr, "%5d %13.5lf %13.5lf %13.5lf %13.5lf\n",
					ui,
					curve->poles[(ui) * 3] / curve->weights[ui],
					curve->poles[(ui) * 3 + 1] / curve->weights[ui],
					curve->poles[(ui) * 3 + 2] / curve->weights[ui],
					curve->weights[ui] );
		}
	else
		{
		fprintf( stderr, "  Poles (u, x, y, z):\n");
		
		for( ui=0; ui<curve->num_poles; ui++ )
			fprintf( stderr, "%5d %13.5lf %13.5lf %13.5lf\n",
					ui,
					curve->poles[(ui) * 3],
					curve->poles[(ui) * 3 + 1],
					curve->poles[(ui) * 3 + 2] );
		}

	fprintf( stderr, "\n  knots:\n");
	
	for( index=0; index<curve->num_knots; index++ )
		fprintf( stderr, "%17.9lf\n", curve->knots[index] );
	}
#endif 

/*---HSlvhl_display_surface----------------------------------------*/

void HSlvhl_display_surface( object,
			     matrix_type,
			     matrix,
			     master_env,
			     complex )

struct GRid	*object; 
IGRshort	*matrix_type; 
IGRmatrix	matrix;
struct GRmd_env	*master_env;
IGRint		complex;


	{
	IGRlong 		msg, sts, status;
	enum GRdpmode		mode;
	IGRint			comp_count;
	IGRint			comps;
	struct GRid		*comp_ids;
	
	mode = GRbd;


	/*
	 *  If the mode is output soos,
	 *  before processing the surface, remove any existing 
	 *  hidden and/or invisible soo's.  This could be a curve,
	 *  but I know, at the moment, that'll never happen.
	 */

	if( HSlvhl.output_soos )
		{
		if( complex )
			{
			HSget_components( object, master_env, &comp_count, &comp_ids );
	
			for( comps = 0; comps<comp_count; comps++ )
				{
				HSprocess_soos_on_surface(
					&comp_ids[comps],
					matrix_type,
					matrix );
				}
		
			if( comp_ids ) free( (IGRchar *)comp_ids );
			}
		else
			{
			HSprocess_soos_on_surface(
				object,
				matrix_type,
				matrix );
			}
		}

	/*
	 *  Now process the object, if its not a surface, were 
	 *  in trouble. As long as the next to the last argument to
	 *  HSclassify_located_object, in HSls_collect.C, is
	 *  HSlvhl_display_curve, and not HSlvhl_display_object,
	 *  were OK
	 */
	 
	sts =om$send( mode = OM_e_wrt_object,
		       msg = message GRgraphics.GRdisyourself(
					&msg,
					matrix_type,
					matrix,
					&mode,
					0,
					&sp_info,
					NULL ),
		  senderid = window.objid,
		  targetid = object->objid,
		  targetos = object->osnum );
		
	if (!(sts & 1))
		{
		om$report_error(sts = sts);
		}
	}
		
	
/*---HSlvhl_display_surface_comp----------------------------------------*/

void HSlvhl_display_surface_comp( object,
				  matrix_type,
				  matrix )

struct GRid	*object; 
IGRshort	*matrix_type; 
IGRmatrix	matrix;

	{
	IGRlong 		msg, status;
	enum GRdpmode		mode;
	IGRchar			*absgeom;
	struct DPele_header	element;
	struct IGRdisplay	attributes;
	IGRdouble		range[6];
	struct GRsymbology	symbology;
	IGRboolean		world = TRUE;

	mode = GRbd;

	status = om$send( msg = message GRvg.GRgenabsg( 
						&msg, 
						matrix_type,
						matrix,
						&absgeom ),
		     senderid = NULL_OBJID,
		     targetid = object->objid,
		     targetos = object->osnum );
			
	OM_ERRCHK( status, "failed to GRgenabsg\n" );
	if_bad(status & msg) goto wrap_up;

	status = om$send( msg = message GRvg.GRgetrang(
						&msg,
						matrix_type,
						matrix,
						&world, range),
		     senderid = NULL_OBJID,
		     targetid = object->objid,
		     targetos = object->osnum );

	OM_ERRCHK( status, "failed to GRgetrang\n" );
	if_bad(status) goto wrap_up;


	status = om$send( msg = message GRvg.GRgetsymb( &msg, &symbology ),
		     senderid = NULL_OBJID,
		     targetid = object->objid,
		     targetos = object->osnum );

	OM_ERRCHK( status, "failed to GRgetsymb\n" );
	if_bad(status & msg) goto wrap_up;

	element.tag = object->objid;
	element.type = IGRBS;
	element.range = range;
	element.dis_att = &attributes;
	element.geometry.bspcurve = (struct IGRbsp_curve *)absgeom;
		
	attributes.color = symbology.display_attr.color;
	attributes.weight = symbology.display_attr.weight;
	attributes.style = symbology.display_attr.style;

	/*
	 *  If the mode is output soos,
	 *  before processing the surface, remove any existing 
	 *  hidden and/or invisible soo's
	 */
	 
	if( HSlvhl.output_soos )
		HSprocess_soos_on_surface(
			object,
			matrix_type,
			matrix );
		
	/*
	 *  Now, process the surface, have to save OM_Gw_current_OS
	 *  and set to object os.  reset when return
	 */

	HStile_object(
		&element,
		&mode,
		gragad_stuff.gragad.gpipe_id,
		&attributes,
		sp_info.gragad );

wrap_up:;
	}


/*---HSlvhl_sort_the_soos----------------------------------------*/

static void	HSlvhl_sort_the_soos()

	{
	struct IGRdisplay	t_attr;
	double			t_parms[2];
	int			i, j, swap;
	
	if( HSlvhl.p_count <= 1 ) return;
	
	swap = 1;
	while( swap )
		{
		swap = 0;
		for( i=0, j=0; i<(HSlvhl.p_count-1); i++, j+=2 )
			{
			if( HSlvhl.p_parms[j] > HSlvhl.p_parms[j+2] )
				{
				t_parms[0] = HSlvhl.p_parms[j];
				t_parms[1] = HSlvhl.p_parms[j+1];
				t_attr     = HSlvhl.p_attr[i];
				
				HSlvhl.p_parms[j]   = HSlvhl.p_parms[j+2];
				HSlvhl.p_parms[j+1] = HSlvhl.p_parms[j+3];
				HSlvhl.p_attr[i]    = HSlvhl.p_attr[i+1];
				
				HSlvhl.p_parms[j+2] = t_parms[0];
				HSlvhl.p_parms[j+3] = t_parms[1];
				HSlvhl.p_attr[i+1]  = t_attr;
				
				swap = 1;
				}
			}
		}	
	}

#if DEBUG
/*---HSlvhl_dump_the_soos----------------------------------------*/

static void	HSlvhl_dump_the_soos()

	{
	struct IGRdisplay	t_attr;
	double			t_parms[2];
	int			i, j;
	
	if( HSlvhl.p_count <= 0 ) return;

	fprintf( stderr, "\nSoo's for the edge\n\n" );
	fprintf( stderr, " start    end   color style weight\n" );
	fprintf( stderr, "------- ------- ----- ----- ------\n" );	
	for( i=0, j=0; i<HSlvhl.p_count; i++, j+=2 )
		{
		fprintf( stderr, "%7.4f %7.4f %5d %5d %6d\n",
			HSlvhl.p_parms[j], HSlvhl.p_parms[j+1],
			HSlvhl.p_attr[i].color, 
			HSlvhl.p_attr[i].style,
			HSlvhl.p_attr[i].weight );
		}
	fprintf( stderr, "\n\n" );
	}
#endif

/*---HSget_manual_soos_on_edge--------------------------------------*/

void HSget_manual_soos_on_edge( object_id,
				object_os,
				matrix,
				matrix_type,
				master_env )

GRobjid		object_id;
GRspacenum	object_os;
IGRshort	*matrix_type; 
IGRmatrix	matrix;
struct GRmd_env	*master_env;

	{
	static IGRshort		properties;
	IGRlong 		msg, status, sts;

	status = om$send( msg = message GRvg.GRgetprops( &msg, &properties ),
		     senderid = NULL_OBJID,
		     targetid = object_id,
		     targetos = object_os );

	OM_ERRCHK( status, "failed to GRgetprops\n" );
	if_bad(status & msg) return;

	if( properties & DEHAS_OVERRIDE )
		{
		status = om$send( 	mode = OM_e_wrt_message,
					msg = message DEso.DEget( 
							&msg,
							&HSlvhl.p_parms,
							&HSlvhl.p_count,
							&HSlvhl.p_attr,
							DE_SOE,
							object_id,
							tiling_parms.window_id,
							matrix_type,
							matrix ),
			     senderid = NULL_OBJID,
			     targetid = DEsos[object_os],
			     targetos = master_env->md_id.osnum );
			     
		HSlvhl_sort_the_soos();

#		if DEBUG
		HSlvhl_dump_the_soos();
#		endif
		}
	else
		{
		HSlvhl.p_count = 0;
		}
	}

/*---HSlvhl_display_curve----------------------------------------*/

void HSlvhl_display_curve( object,
			   matrix_type,
			   matrix,
			   master_env )

struct GRid	*object; 
IGRshort	*matrix_type; 
IGRmatrix	matrix;
struct GRmd_env	*master_env;

	{
	IGRlong 		msg, status, sts;
	enum GRdpmode		mode;
	IGRchar			*absgeom;
	struct DPele_header	element;
	struct IGRdisplay	attributes;
	IGRdouble		range[6];
	struct GRsymbology	symbology;
	IGRboolean		world = TRUE;
	IGRshort		properties, action, mask;
	
	status = om$send( msg = message GRvg.GRgetprops( &msg, &properties ),
		     senderid = NULL_OBJID,
		     targetid = object->objid,
		     targetos = object->osnum );

	OM_ERRCHK( status, "failed to GRgetprops\n" );
	if_bad(status & msg) goto wrap_up;
	
	if ( properties & GRIS_VE_CURVE ) return;  /* curve is the result of previous CHE processing */

	mode = GRbd;

	status = om$send( msg = message GRvg.GRgenabsg( 
						&msg, 
						matrix_type,
						matrix,
						&absgeom ),
		     senderid = NULL_OBJID,
		     targetid = object->objid,
		     targetos = object->osnum );
			
	OM_ERRCHK( status, "failed to GRgenabsg\n" );
	if_bad(status & msg) goto wrap_up;

	status = om$send( msg = message GRvg.GRgetrang(
						&msg,
						matrix_type,
						matrix,
						&world, range),
		     senderid = NULL_OBJID,
		     targetid = object->objid,
		     targetos = object->osnum );

	OM_ERRCHK( status, "failed to GRgetrang\n" );
	if_bad(status) goto wrap_up;


	status = om$send( msg = message GRvg.GRgetsymb( &msg, &symbology ),
		     senderid = NULL_OBJID,
		     targetid = object->objid,
		     targetos = object->osnum );

	OM_ERRCHK( status, "failed to GRgetsymb\n" );
	if_bad(status & msg) goto wrap_up;

	HSget_manual_soos_on_edge( object->objid, 
				   object->osnum, 
				   matrix, 
				   matrix_type, 
				   master_env );
	
	element.tag = object->objid;
	element.type = IGRBC;
	element.range = range;
	element.dis_att = &attributes;
	element.geometry.bspcurve = (struct IGRbsp_curve *)absgeom;
		
	attributes.color = symbology.display_attr.color;
	attributes.weight = symbology.display_attr.weight;
	attributes.style = symbology.display_attr.style;
		

	/*
	 *  If the mode is output soos,
	 *  before processing the curve, remove any existing 
	 *  hidden and/or invisible soo's
	 */
	 
	if( HSlvhl.output_soos )
		HSprocess_soos_on_curve(
			object,
			matrix_type,
			matrix );
		

	/*
	 *  Now, process the curve, have to save OM_Gw_current_OS
	 *  and set to object os.  reset when return
	 */
	 
	if( properties & DEHAS_OVERRIDE )
		{
		action = 0;
		mask = DEHAS_OVERRIDE;
		status = om$send( msg = message GRvg.GRchgprops( &msg, &action, &mask ),
			     senderid = NULL_OBJID,
			     targetid = object->objid,
			     targetos = object->osnum );
	
		OM_ERRCHK( status, "failed to GRchgprops: clear\n" );
		if_bad(status & msg) goto wrap_up;
		}
			
	sts =om$send( mode = OM_e_wrt_object,
		       msg = message GRgraphics.GRdisyourself(
					&msg,
					matrix_type,
					matrix,
					&mode,
					0,
					&sp_info,
					NULL ),
		  senderid = window.objid,
		  targetid = object->objid,
		  targetos = object->osnum );
		
	if (!(sts & 1))
		{
		om$report_error(sts = sts);
		}

	if( properties & DEHAS_OVERRIDE )
		{
		action = 1;
		mask = DEHAS_OVERRIDE;
		status = om$send( msg = message GRvg.GRchgprops( &msg, &action, &mask ),
			     senderid = NULL_OBJID,
			     targetid = object->objid,
			     targetos = object->osnum );

		OM_ERRCHK( status, "failed to GRchgprops: set\n" );
		if_bad(status & msg) goto wrap_up;
		}
		
wrap_up:;
	}

		
/*---HSlvhl_display_curve_comp----------------------------------------*/

void HSlvhl_display_curve_comp( object,
			        matrix_type,
			        matrix,
			        master_env )

struct GRid	*object; 
IGRshort	*matrix_type; 
IGRmatrix	matrix;
struct GRmd_env	*master_env;

	{
	IGRlong 		msg, status;
	enum GRdpmode		mode;
	IGRchar			*absgeom;
	struct DPele_header	element;
	struct IGRdisplay	attributes;
	IGRdouble		range[6];
	struct GRsymbology	symbology;
	IGRboolean		world = TRUE;
	IGRshort		properties;
	
	mode = GRbd;

	status = om$send( msg = message GRvg.GRgenabsg( 
						&msg, 
						matrix_type,
						matrix,
						&absgeom ),
		     senderid = NULL_OBJID,
		     targetid = object->objid,
		     targetos = object->osnum );
			
	OM_ERRCHK( status, "failed to GRgenabsg\n" );
	if_bad(status & msg) goto wrap_up;

	status = om$send( msg = message GRvg.GRgetrang(
						&msg,
						matrix_type,
						matrix,
						&world, range),
		     senderid = NULL_OBJID,
		     targetid = object->objid,
		     targetos = object->osnum );

	OM_ERRCHK( status, "failed to GRgetrang\n" );
	if_bad(status) goto wrap_up;


	status = om$send( msg = message GRvg.GRgetsymb( &msg, &symbology ),
		     senderid = NULL_OBJID,
		     targetid = object->objid,
		     targetos = object->osnum );

	OM_ERRCHK( status, "failed to GRgetsymb\n" );
	if_bad(status & msg) goto wrap_up;

	status = om$send( msg = message GRvg.GRgetprops( &msg, &properties ),
		     senderid = NULL_OBJID,
		     targetid = object->objid,
		     targetos = object->osnum );

	OM_ERRCHK( status, "failed to GRgetprops\n" );
	if_bad(status & msg) goto wrap_up;
	
	HSget_manual_soos_on_edge( object->objid,
				   object->osnum,
				   matrix, 
				   matrix_type, 
				   master_env );
	
	element.tag = object->objid;
	element.type = IGRBC;
	element.range = range;
	element.dis_att = &attributes;
	element.geometry.bspcurve = (struct IGRbsp_curve *)absgeom;
		
	attributes.color = symbology.display_attr.color;
	attributes.weight = symbology.display_attr.weight;
	attributes.style = symbology.display_attr.style;
		

	/*
	 *  If the mode is output soos,
	 *  before processing the curve, remove any existing 
	 *  hidden and/or invisible soo's
	 */
	 
	if( HSlvhl.output_soos )
		HSprocess_soos_on_curve(
			object,
			matrix_type,
			matrix );
		

	/*
	 *  Now, process the curve, have to save OM_Gw_current_OS
	 *  and set to object os.  reset when return
	 */
	 
	HStile_object(
		&element,
		&mode,
		gragad_stuff.gragad.gpipe_id,
		&attributes,
		sp_info.gragad );
		
wrap_up:;
	}


end implementation Root;

