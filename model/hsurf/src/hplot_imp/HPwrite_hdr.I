
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation Root;



#include <stdio.h>
#include "wl.h"
#ifndef X11
#include <sdl.h>
#endif
#include <sys/types.h>
#include <sys/dirent.h>
#include "FI.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "hsurf.h"
#include "hsdef.h"
#include "hslight.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hswinmacros.h"
#include "hsmsg.h"
#include "ex.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "msdef.h"
#include "griomacros.h"
#include "exmacros.h"
#include "dpgraphics.h"
#include "HSplot.h"
#include "HSplot_str.h"
#include "HSplot_def.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

%safe
#include "HSpr_hplot.h"
%endsafe

#define		DEBUG		0

/*---transform---------------------------------------------------------*/

/*
NAME
	transform: static
	
KEYWORDS
	shaded plotting
	static
	
DESCRIPTION
	transform vertice in 'point' by 'matrix'
	
PARAMETERS
	point	:(IN/OUT): vertex to transform
	matrix	:(IN)    : transformation matrix
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	static	transform( IGRdouble point[3],
			   IGRdouble matrix[4][4] )
#else
	static	transform( point, matrix )

	IGRdouble	point[3];
	IGRdouble	matrix[4][4];
#endif

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
	
/*---HPwrite_header----------------------------------------------------------------------------*/

/*
NAME
	HPwrite_header
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	Collect information needed and write header information into
	the shaded plotfile
	
PARAMETERS
	info		:(IN) : shaded plotting global information
	first_write	:(IN) : See notes;
	
NOTES
	On 'first_write': On the first call to HPwrite_header, the
	entire plotfile header is written.  While the plotfile data is
	being written, the max line weight and active shading styles
	are accumulate, then before closing the shaded plotfile, this
	information is updated in the plotfile header.
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HPwrite_header( struct HSplot_info *info,
					   IGRint first_write )
#else
	IGRint HPwrite_header( info, first_write )

	struct HSplot_info	*info;
	IGRint			first_write;
#endif

	{
	IGRdouble		world_to_viewport_scale;
	IGRdouble		xsize, ysize;
	IGRlong			msg, status;
	IGRdouble		xform[4][4];
	IGRdouble		post_rotation[16];
	IGRdouble		uom_factor;
	OM_S_OBJID		mod_id;
	OMuword			mod_osnum;
	 
	struct var_list		var_list[3];
	struct gragad_inst	gragad_stuff;
	IGRlong			bytes_returned;
        IGRint                  which_error;
	struct HStotal_window_instance	total_instance;
	
	IGRdouble		fence_clip_range[6];
	
	IGRshort		fence_active;
	
	struct GRid		*window;
	
	/*----------*/

	/*
	 *  Get the active window id/os
	 */

	if( fence_active = ( !(info->dpb_flags & HS_PLOT_WINDOW_CONTENTS) && 
			      (info->con_flags & HP_CONTROL_FENCE_DEFINED) ) )
		window = &info->fence_window;
	else
		window = &info->window;


	/*
	 *  Get instance data from the window
	 */
	 		
	var_list[0].var			= GRAGAD_INST_STRUCT;
	var_list[0].var_ptr		= (char *)&gragad_stuff;
	var_list[0].num_bytes		= sizeof( struct gragad_inst );
	var_list[0].bytes_returned	= &bytes_returned;

	var_list[1].var			= POST_ROTATION;
	var_list[1].var_ptr		= (char *)post_rotation;
	var_list[1].num_bytes		= sizeof( IGRdouble ) * 16;
	var_list[1].bytes_returned	= &bytes_returned;

	var_list[2].var			= END_PARAM;
	var_list[2].var_ptr		= NULL;
	var_list[2].num_bytes		= 0;
	var_list[2].bytes_returned	= NULL;

	status = dp$inq_set_gragad( msg	= &msg,
			      inq0_set1 = 0,
				  osnum = window->osnum,
			   gragad_objid = window->objid,
			    which_error = &which_error,
			       var_list = var_list );

	var_list[0].var			= HS_TOTAL_INSTANCE;
	var_list[0].var_ptr		= (IGRchar *)&total_instance;
	var_list[0].num_bytes		= sizeof( struct HStotal_window_instance );
	var_list[0].bytes_returned	= &bytes_returned;

        HSactivate_window( gragad_stuff.gragad.gpipe_id );
	 
	hs$get_window_instance_data( msg = &msg,
				  win_id = window->objid,
				  win_os = window->osnum,
				var_list = var_list,
			     which_error = &which_error );

	/* 
	 *  Get scale factor
	 */

	ex$get_cur_mod( id = &mod_id, osnum = &mod_osnum );

	status = co$cvt_exp_to_wrk( msg	= &msg,
				  osnum = mod_osnum,
			      unit_type = "UOM_DISTANCE",
				  units = 1.0,
				  alias = "in",
				 result = &uom_factor );
				
	world_to_viewport_scale = gragad_stuff.gragad.vvol_viewport_scale;
	if( msg == MSSUCC ) world_to_viewport_scale /= uom_factor;

	/*
	 *  Get the transformation matrix
	 */
	 
	if( gragad_stuff.gragad.flags & IS_PERSP )
		{
		memcpy( xform, gragad_stuff.gragad.wld_to_view, 16*sizeof( IGRdouble ) );
		info->con_flags |=  HP_CONTROL_PERSPECTIVE;
		}
	else
		{
		memcpy( xform, gragad_stuff.gragad.wld_to_viewport, 16*sizeof( IGRdouble ) );
		info->con_flags &= ~HP_CONTROL_PERSPECTIVE;
		}


	/*
	 *  Compute the plot viewport
	 */

	if( fence_active )
		{
		IGRdouble	xprism[3], pmatrix[4][4];
		IGRint	i;

		memcpy( pmatrix, info->prism->matrix, 16 * sizeof( IGRdouble ) );
		
		fence_clip_range[0] = (double)(0x7fffffff);
		fence_clip_range[1] = (double)(0x7fffffff);
		fence_clip_range[2] = gragad_stuff.gragad.dit_clip_range[2];
		
		fence_clip_range[3] = -fence_clip_range[0];
		fence_clip_range[4] = -fence_clip_range[1];
		fence_clip_range[5] = gragad_stuff.gragad.dit_clip_range[5];

#		if DEBUG
		fprintf( stderr, "fence\n" );
		fprintf( stderr, "  %f %f %f\n", 
			fence_clip_range[0], fence_clip_range[1], fence_clip_range[2] );
		fprintf( stderr, "  %f %f %f\n", 
			fence_clip_range[3], fence_clip_range[4], fence_clip_range[5] );
#		endif

		for( i=0; i<info->prism->curve.num_poles; i++ ) 
			{
			xprism[0] = info->prism->curve.poles[(3*i)  ];
			xprism[1] = info->prism->curve.poles[(3*i)+1];
			xprism[2] = info->prism->curve.poles[(3*i)+2];

			transform( xprism, pmatrix );
			transform( xprism, gragad_stuff.gragad.wld_to_viewport );

			if( xprism[0] < fence_clip_range[0] ) fence_clip_range[0] = xprism[0];
			if( xprism[1] < fence_clip_range[1] ) fence_clip_range[1] = xprism[1];

			if( xprism[0] > fence_clip_range[3] ) fence_clip_range[3] = xprism[0];
			if( xprism[1] > fence_clip_range[4] ) fence_clip_range[4] = xprism[1];
			}

#		if DEBUG
		fprintf( stderr, "fence\n" );
		fprintf( stderr, "  %f %f %f\n", 
			fence_clip_range[0], fence_clip_range[1], fence_clip_range[2] );
		fprintf( stderr, "  %f %f %f\n", 
			fence_clip_range[3], fence_clip_range[4], fence_clip_range[5] );
#		endif

			
		/*
		 *  translate the matrix to the origin of the fence
		 */ 

		xform[0][3] -= fence_clip_range[0];
		xform[1][3] -= fence_clip_range[1];
		xform[2][3] -= fence_clip_range[2];
		
		/*
		 *  translate to fence origin
		 */
		 
		fence_clip_range[3] = fence_clip_range[3] - fence_clip_range[0];
		fence_clip_range[4] = fence_clip_range[4] - fence_clip_range[1];
		fence_clip_range[5] = fence_clip_range[5] - fence_clip_range[2];
		
		fence_clip_range[0] = 0.0;
		fence_clip_range[1] = 0.0;
		fence_clip_range[2] = 0.0;

		xsize = (fence_clip_range[3] - fence_clip_range[0]) / gragad_stuff.gragad.vvol_viewport_scale;
		ysize = (fence_clip_range[4] - fence_clip_range[1]) / gragad_stuff.gragad.vvol_viewport_scale;
		}
	else
		{
		xsize = (gragad_stuff.gragad.dit_clip_range[3] - gragad_stuff.gragad.dit_clip_range[0]) / gragad_stuff.gragad.vvol_viewport_scale;
		ysize = (gragad_stuff.gragad.dit_clip_range[4] - gragad_stuff.gragad.dit_clip_range[1]) / gragad_stuff.gragad.vvol_viewport_scale;
		}

	status = HPwrite_plotfile_header( info, &world_to_viewport_scale, &xsize, &ysize );
	if( status != OM_S_SUCCESS ) goto error_exit;
	
	if( !first_write ) goto success_exit;
	
	status = HPwrite_colortable( info );
	if( status != OM_S_SUCCESS ) goto error_exit;
	
	status = HPwrite_trans_grid( info );
	if( status != OM_S_SUCCESS ) goto error_exit;
	
	status = HPwrite_depth_cues( info );
	if( status != OM_S_SUCCESS ) goto error_exit;
	
	status = HPwrite_light_sources( info );
	if( status != OM_S_SUCCESS ) goto error_exit;

	if( fence_active )
		status = HPwrite_view_orientation_and_range( info, (IGRdouble *)xform, (IGRdouble *)fence_clip_range );	
	else
		status = HPwrite_view_orientation_and_range( info, (IGRdouble *)xform, (IGRdouble *)gragad_stuff.gragad.dit_clip_range );	
		
	if( status != OM_S_SUCCESS ) goto error_exit;
	    
	status = HPwrite_perspective_flag( info, gragad_stuff.gragad.flags & IS_PERSP );
	if( status != OM_S_SUCCESS ) goto error_exit;
	
	status = HPwrite_other_matrices( info,
					 (IGRdouble *)gragad_stuff.gragad.viewport_to_wld,
					 (IGRdouble *)gragad_stuff.gragad.rotation,
					(gragad_stuff.gragad.flags & IS_PERSP) ? post_rotation : NULL );
	if( status != OM_S_SUCCESS ) goto error_exit;

	status = HPwrite_hidden_symbology_parms( info );
	if( status != OM_S_SUCCESS ) goto error_exit;
	
	/*
	 *  Save the eye point in case we want to the surface horizon edges and 
	 *  the viewport is perspective
	 */
	 
	info->eye_pt[0] = gragad_stuff.gragad.eye_pt[0];
	info->eye_pt[1] = gragad_stuff.gragad.eye_pt[1];
	info->eye_pt[2] = gragad_stuff.gragad.eye_pt[2];

success_exit:	
	return ( OM_S_SUCCESS );

error_exit:
	return( status );
	}

end implementation Root;
