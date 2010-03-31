
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:39 $
$Locker:  $
*/

class implementation Root;

#define	CHECK_RETURN_CODES	1

#include <stdio.h>
#include <stdlib.h>
#include <FI.h>

#include "wl.h"

#ifndef ENV5
#define MAX_WINDOW   40
#endif

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "growner.h"
#include "dpstruct.h"
#include "madef.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "pidef.h"
#include "plotmacros.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsurferrpriv.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hsmsg.h"

#include "DEso.h"
#include "DEglob.h"
#include "DEsomacros.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"
#include "HSlvhl.h"

#include "HSplot.h"

%safe
#include "HSpr_lvhl.h"
%endsafe

/*---------------------------
 *  for functions
 *     HSget_workstation_info
 *     HSset_clip_mode
 *     HSset_ele_clip_range
 *     HSset_shade_config
 *     HSset_window_object_info
 */
 
#include "HSpr_tiler_f.h"

/*-------------------------------*/

%safe
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

/* HSlv_display.I */
static void HStransform __((IGRdouble point[3 ], IGRdouble matrix[4 ][4 ]));
static int HSlvhl_get_fence_range __((struct GRid *window, IGRdouble *fence_range));
static void HSlvhl_sort_the_soos __((void));
static void HSget_attachment_range __((struct GRid *elem, IGRmatrix matrix, IGRshort *matrix_type, IGRdouble *ref_range));

#if defined(__cplusplus)
}
#endif


#undef __


%endsafe

from GRgraphics import GRdisyourself; 
from GRvg	import GRgenabsg;
from GRvg	import GRgetrang;
from GRvg	import GRgetsymb;
from GRvg	import GRgetprops;
from GRvg	import GRchgprops;
from DEso	import DEget;

#define	if_bad( status )	if ( !( (status) & 1 ) )

extern OMuword OPP_GRsmhdr_class_id;
extern void	HStile_object();

#define	DEBUG	0

%safe
static struct DP_information 	sp_info;
static IGRboolean		scaled;
static IGRint			original_dep_range[4];
static IGRint			original_gpipe_id;
static struct gragad_inst	gragad_stuff;

static struct DP_information 	ddd_sp_info = {0};  /* must be separate from sp_info   */
static struct gragad_inst	ddd_gragad_stuff;   /* used by LHVL for its processing */
%endsafe


/*--- HSsetup_ddd_sp_info ---------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSsetup_ddd_sp_info( OM_S_OBJID win_id,
					    OMuword win_os )
#else
	static void HSsetup_ddd_sp_info( win_id, win_os )

	OM_S_OBJID win_id;
	OMuword    win_os;
#endif

/*
NAME
	HSsetup_ddd_sp_info (static)

DESCRIPTION
	This function sets up the DP_information structure,
	ddd_sp_info, for use by the 'display_edge" option on
	HSremove_VEso_on_edge.

PARAMETERS
	win_id (IN) - the object id of the window that the
	              display is going to take place in
	win_os (IN) - the object space number of the window

GLOBALS USED
	ddd_sp_info (static)
	ddd_gragad_stuff (static)

HISTORY
	02/17/92    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong            msg;
	IGRlong            which_error;
	IGRlong            ret_bytes;
	struct var_list    var_list[2];

	if ( ddd_sp_info.view_objid != win_id )
		{
		var_list[0].var            = GRAGAD_INST_STRUCT;
		var_list[0].var_ptr        = (IGRchar *) &ddd_gragad_stuff;
		var_list[0].num_bytes      = sizeof( struct gragad_inst );
		var_list[0].bytes_returned = &ret_bytes;

		var_list[1].var            = END_PARAM;

		dp$inq_set_gragad( msg          = &msg,
		                   inq0_set1    = 0,
				   osnum        = win_os,
	        	           gragad_objid = win_id,
				   which_error  = &which_error,
		                   var_list     = var_list );

		ddd_sp_info.gragad = &ddd_gragad_stuff.gragad;
		ddd_sp_info.win_no = ddd_gragad_stuff.win_no;
		ddd_sp_info.is_update = FALSE;
		ddd_sp_info.is_fit = FALSE;
		ddd_sp_info.is_hidden_line = FALSE;
		ddd_sp_info.hline_info = NULL;
		ddd_sp_info.view_objid = win_id;
		ddd_sp_info.view_osnum = win_os;
		}

	}  /* HSsetup_ddd_sp_info */


/*---HStransform---------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HStransform( IGRdouble point[3],
				 IGRdouble matrix[4][4] )
#else
	static void HStransform( point, matrix )

	IGRdouble	point[3];
	IGRdouble	matrix[4][4];
#endif

/*
NAME
	HStransform (static)

DESCRIPTION
	This function transforms a point given a matrix

PARAMETERS
	point (IN/OUT) - the point to transform
	matrix (IN) - the matrix to transform with

GLOBALS USED
	none

HISTORY
	xx/xx/91   Mike Lanier
	   Creation Date
*/

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

#if defined(__STDC__) || defined(__cplusplus)
	static int HSlvhl_get_fence_range( struct GRid *window,
					     IGRdouble *fence_range )
#else
	static int	HSlvhl_get_fence_range( window, fence_range )

	struct GRid	*window;
	IGRdouble	*fence_range;
#endif

/*
NAME
	HSlvhl_get_fence_range (static)

DESCRIPTION
	This function gets the range of the fence in a given window

PARAMETERS
	window (IN) - the GRid of the window in question
	fence_range (OUT) - array for fence range

GLOBALS USED
	HSlvhl.clipping_planes

RETURN VALUES
	TRUE - if the fence was in the window in question
	FALSE - if the fence was not in the window
 
HISTORY
	xx/xx/91    Mike Lanier
	   Creation Date
*/

	{
	IGRlong			msg, sts;
	struct GRmd_env		module;
	IGRdouble		world[6];
	IGRdouble		view[6];
	IGRlong			sizbuf, nret;
	struct GRid		fence;
	struct GRid		fence_window;
	struct IGRcv_prism	*prism;

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
			IGRdouble	xprism[12], pmatrix[4][4];
			IGRint		i;
		
			memcpy( pmatrix, prism->matrix, sizeof(IGRdouble) * 16 );
			for( i=0; i<12; i++ ) xprism[i] = prism->curve.poles[i];
		
			HStransform( &xprism[0], pmatrix );
			HStransform( &xprism[0], gragad_stuff.gragad.wld_to_viewport );

			HStransform( &xprism[3], pmatrix );
			HStransform( &xprism[3], gragad_stuff.gragad.wld_to_viewport );
		
			HStransform( &xprism[6], pmatrix );
			HStransform( &xprism[6], gragad_stuff.gragad.wld_to_viewport );
		
			HStransform( &xprism[9], pmatrix );
			HStransform( &xprism[9], gragad_stuff.gragad.wld_to_viewport );
		
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

			memcpy( fence_range, fence_clip_range, sizeof( IGRdouble ) * 6 );
			
			VEassign_clipping_planes_from_range( HSlvhl.clipping_planes, fence_range );
			
			return( TRUE );
			}
		}
	else
		{
		return( FALSE );
		}
	}
	
/*---HSlvhl_init_display_object-----------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRboolean HSlvhl_init_display_object( struct GRid *window_id,
					     unsigned char resolution,
						IGRboolean clip_to_fence )
#else
	IGRboolean HSlvhl_init_display_object( window_id, resolution, clip_to_fence )

	struct GRid	*window_id;
	unsigned char	resolution;
	IGRboolean	clip_to_fence;
#endif

/*
NAME
	HSlvhl_init_display_object

DESCRIPTION
	This function performs some of the initializations required to
	run LVHL.  It intializes the active_window structure maintained
	by the tiler, makes sure a Zbuffer is allocated for the window
	and adjusts the transformation matrices in the window to
	achieve the correct resolution.
	
PARAMETERS
	window_id (IN) - the GRid of the window that LVHL is being run in
	resolution (IN) - the resolution at which LVHL is being run
	clip_to_fence (IN) - flag indicating whether LVHL should clip to a
	                     fence if it is in the window

GLOBALS USED
	HSlvhl
	original_dep_range (static)
	original_gpipe_id (static)
	gragad_stuff (static)
	sp_info (static)

RETURN VALUES
	TRUE - if the initialization succeeded
	FALSE - if there was a failure

HISTORY
	xx/xx/91   Mike Lanier
	   Creation Date
*/

	{
	struct var_list		info[3];
	IGRint			which_error;
	IGRlong			bytes_returned, status, msg;
	IGRchar			buf0[100], buf1[100];
	IGRint			xdits_scale, ydits_scale;
	IGRdouble		fence_range[6];
	IGRint			Mpx, num_vs, main_memory, xdits, ydits;

	
	/*
	 *  put the window objid/osnum in the tiler memory
	 */
	 
	HSset_window_object_info( window_id );
			
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
			osnum		= tiling_parms.window_os,
			gragad_objid	= tiling_parms.window_id,
			which_error	= &which_error,
			var_list	= info );

	/*
	 *  If the resolution is not LOW then we will be scaling the
	 *  data.  Save the original dep_range, we will need to reset
	 *  it in the instance data later
	 */

	HSlvhl.resolution = resolution;
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

	HMget_workstation_info( &Mpx, &num_vs, &main_memory, &xdits, &ydits );

 	if( HSlvhl_allocate_zbuffer_memory(
			255,
			&gragad_stuff.min_x_dep, &gragad_stuff.max_x_dep,
			&gragad_stuff.min_y_dep, &gragad_stuff.max_y_dep,
			scaled ? 4/Mpx : 1,
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
					osnum		= tiling_parms.window_os,
					gragad_objid	= tiling_parms.window_id,
					which_error	= &which_error,
					calc_info	= TRUE,
					var_list	= info );

			/*
			 *  Get the gragad instance data again since the
			 *  'calc_info' option above caused it to change.
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
					osnum		= tiling_parms.window_os,
					gragad_objid	= tiling_parms.window_id,
					which_error	= &which_error,
					var_list	= info );

			}


		/*
		 *  initialize the lvhl window
		 */
		 
		HSlvhl_init_window(
			255,
			gragad_stuff.win_no,
			&gragad_stuff.gragad,
			xdits_scale, ydits_scale );

		if( clip_to_fence )
			{
			if( HSlvhl_get_fence_range( window_id, fence_range ) )
				{
				memcpy( gragad_stuff.gragad.dit_clip_range, 
					fence_range, 
					sizeof( IGRdouble ) * 6 );
	
				HSset_clip_mode( TRUE );
				}
			else
				{
				VEassign_clipping_planes_from_range( HSlvhl.clipping_planes, gragad_stuff.gragad.dit_clip_range );
				}
			}
		else
			{
			VEassign_clipping_planes_from_range( HSlvhl.clipping_planes, gragad_stuff.gragad.dit_clip_range );
			}

		gragad_stuff.gragad.gpipe_id = 255;
	
		sp_info.gragad = &gragad_stuff.gragad;
		sp_info.win_no = gragad_stuff.win_no;
		sp_info.is_update = FALSE;
		sp_info.is_fit = FALSE;
		sp_info.is_hidden_line = TRUE;
		sp_info.hline_info = NULL;
		sp_info.hl_tiler = HStile_object;
		sp_info.view_objid = tiling_parms.window_id;
		sp_info.view_osnum = tiling_parms.window_os;
		
		/*
		 *  Get the symbology information
		 */
		 
		gr$get_hidden_edge_sym( buffer = &HSlvhl.hidden_symbology );
		gr$get_visible_edge_sym( buffer = &HSlvhl.visible_symbology );
		
		/*
		 *  Initialize the active z
		 */
		 
		HSlvhl_set_active_z( gragad_stuff.gragad.act_z );
		
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

#if defined(__STDC__) || defined(__cplusplus)
	void HSlvhl_fini_display_object(void)
#else
	void HSlvhl_fini_display_object()
#endif


/*
NAME
	HSlvhl_fini_display_object

DESCRIPTION
	This function performs some of the cleanup required
	after running LVHL by reseting the transformation
	matrices in the window

PARAMETERS
	none

GLOBALS USED
	original_dep_range (static)
	original_gpipe_id (static)

HISTORY
	xx/xx/91    Mike Lanier
	   Creation Date
*/

	{
	struct var_list	info[3];
	IGRint		which_error;
	IGRlong		bytes_returned, msg, status;

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
				osnum		= tiling_parms.window_os,
				gragad_objid	= tiling_parms.window_id,
				which_error	= &which_error,
				calc_info	= TRUE,
				var_list	= info );

		}
	}

		
/*---HSlvhl_sort_the_soos----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HSlvhl_sort_the_soos(void)
#else
	static void	HSlvhl_sort_the_soos()
#endif

/*
NAME
	HSlvhl_sort_the_soos (static)

DESCRIPTION
	This function sorts the SOs that are in the the lvhl
	global structure, HSlvhl.  It also removes all automatic
	SOs from the global structure.

PARAMETERS
	none

GLOBALS USED
	HSlvhl

HISTORY
	xx/xx/91   Mike Lanier
	   Creation Date
*/

	{
	struct IGRdisplay	t_attr;
	double			t_parms[2];
	int			i, j, swap;
	
	if( HSlvhl.p_count > 1 )
		{
		swap = 1;
		while( swap )
			{
			swap = 0;
			for( i=0, j=0; i<(HSlvhl.p_count-1); i++, j+=2 )
				{
				
				/*
				 *  Sort by min u.  Also shove all non-manual hidden
				 *  and invisible so's to the bottom
				 */

				if( HSlvhl.p_parms[j] > HSlvhl.p_parms[j+2] ||
				    !(HSlvhl.p_types[i] & (DE_SOE | DE_VIS)) )
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
		
	/*
	 *  Shorten the list by eliminating all non-manual hidden and
	 *  invisible so's, which are at the bottom of the list
	 */
	 
	for( i=0, j=0; i<HSlvhl.p_count; i++ )
		if( HSlvhl.p_types[i] & (DE_SOE | DE_VIS) ) j++;
		
	HSlvhl.p_count = j;
	}


/*---HSlvhl_dump_the_soos----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSlvhl_dump_the_soos(void)
#else
	void	HSlvhl_dump_the_soos()
#endif

/*
NAME
	HSlvhl_dump_the_soos

KEYWORD
	debug

DESCRIPTION
	Print the SOs that are in the global lvhl strucuture, HSlvhl,
	to standard error.

PARAMETERS
	none

GLOBALS USED
	HSlvhl

HISTORY
	xx/xx/91    Mike Lanier
	   Creation Date
*/

	{
	int	i, j;
	char	buff[70];

	if( HSlvhl.p_count <= 0 ) return;

	fprintf( stderr, "\nSoo's for the edge\n\n" );
	fprintf( stderr, " start    end   color style weight type\n" );
	fprintf( stderr, "------- ------- ----- ----- ------ ----\n" );	
	for( i=0, j=0; i<HSlvhl.p_count; i++, j+=2 )
		{
		fprintf( stderr, "%7.4f %7.4f %5d %5d %6d ",
			HSlvhl.p_parms[j], HSlvhl.p_parms[j+1],
			HSlvhl.p_attr[i].color, 
			HSlvhl.p_attr[i].style,
			HSlvhl.p_attr[i].weight );

		buff[0] = 0;
		if( HSlvhl.p_types[i] & DE_DELETED ) sprintf( buff, "%s DE_DELETED ", buff );
		if( HSlvhl.p_types[i] & DE_SOE     ) sprintf( buff, "%s DE_SOE     ", buff );
		if( HSlvhl.p_types[i] & DE_OVERLAP ) sprintf( buff, "%s DE_OVERLAP ", buff );
		if( HSlvhl.p_types[i] & DE_INVIS   ) sprintf( buff, "%s DE_INVIS   ", buff );
		if( HSlvhl.p_types[i] & DE_HIDDEN  ) sprintf( buff, "%s DE_HIDDEN  ", buff );
		if( HSlvhl.p_types[i] & DE_VIS     ) sprintf( buff, "%s DE_VIS     ", buff );
		
		fprintf( stderr, "%s\n", buff );
		}

	fprintf( stderr, "\n\n" );
	}

/*---HSremove_VEso_on_edge--------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRboolean HSremove_VEso_on_edge( GRobjid object_id,
				       GRspacenum object_os,
					  GRobjid window_id,
				       GRspacenum window_os,
				  struct GRmd_env *edge_env,
				  struct GRmd_env *master_env,
					   double us,
					   double ue,
				       IGRboolean delete_user_overrides,
				       IGRboolean display_edge )
#else
	IGRboolean HSremove_VEso_on_edge( object_id,
				    object_os,
				    window_id,
				    window_os,
				    edge_env,
				    master_env,
				    us, ue,
				    delete_user_overrides,
				    display_edge )

	GRobjid		object_id;
	GRspacenum	object_os;
	GRobjid		window_id;
	GRspacenum	window_os;
	struct GRmd_env	*edge_env;
	struct GRmd_env	*master_env;
	double		us, ue;
	IGRboolean	delete_user_overrides;
	IGRboolean	display_edge;
#endif

/*
NAME
	HSremove_VEso_on_edge

DESCRIPTION
	Remove the VEso's on the specified edge within the given u range.
	If us and ue are both equal to -1, then SOs on the entire curve are removed.

PARAMETERS
	object_id (IN) - the object id of the curve whose SOs are to be removed
	object_os (IN) - the object space number of the curve whose SOs are to be removed
	window_id (IN) - the object id of the window that the SOs belong to
	window_os (IN) - the object space number of the window that the SOs belong to
	edge_env (IN) - the module environment of the curve whose SOs are to be removed
	master_env (IN) - the module environment of the master file
	us (IN) - the start of the range to remove
	ue (IN) - the end of the range to remove
	delete_user_overrides (IN) - if TRUE, user-defined SOs will be removed along with
	                             the automatic ones place by PDD
	display_edge (IN) - if TRUE, the edge will be erased and re-displayed in the window
	                    in which the SOs are being removed

RETURN VALUES
	TRUE is returned if any SOs were removed

GLOBALS USED
	none

HISTORY
	xx/xx/91    Mike Lanier
	   Creation Date
	02/72/92    S.P. Rogers
	   Added 'display_edge' functionality
*/
 
	{
	struct GRid		msc_GRid, window;
	IGRshort		properties;
	IGRlong 		msg, status;
	IGRint			*p_types;
	IGRdouble		*p_parms;
	struct IGRdisplay	*p_attr;
	struct GRsymbology	symbology;
	IGRint			p_count, i, j;
	IGRint			sel_flag;
	IGRboolean              no_range, removed_one = FALSE;
	enum GRdpmode           dpmode;
	long                    sts;

	msc_GRid.objid = object_id;
	msc_GRid.osnum = object_os;
	
	window.objid = window_id;
	window.osnum = window_os;

	no_range = (us == -1.0) && (ue == -1.0);

	/*
	 *  Get the properties word to make sure this edge has overrides
	 */
	 
	status = om$send( msg = message GRvg.GRgetprops( &msg, &properties ),
		     senderid = NULL_OBJID,
		     targetid = object_id,
		     targetos = object_os );
		     
	OM_ERRCHK( status, "failed to GRgetprops\n" );
	if( !(1 & status & msg) ) return( FALSE );

	if( (properties & DEHAS_OVERRIDE) && (DEsos) )
		{

		status = om$send( msg = message GRvg.GRgetsymb( &msg, &symbology ),
			     senderid = NULL_OBJID,
			     targetid = object_id,
			     targetos = object_os );
		     
		/*
		 *  Collect the SOs
		 */

		sel_flag = (delete_user_overrides) ? 0 : 1;

		status = om$send( 	mode = OM_e_wrt_message,
					msg = message DEso.DEget( 
							&msg,
							&p_types,
							&p_parms,
							&p_count,
							&p_attr,
							&symbology.display_attr,
							object_id,
							window_id,
							&edge_env->md_env.matrix_type,
							edge_env->md_env.matrix,
							sel_flag, TRUE ),
			     senderid = NULL_OBJID,
			     targetid = DEsos[object_os],
			     targetos = master_env->md_id.osnum );

		/*
		 *  If the edge has automatic SOs, then clip them
		 */

		if( (1 & status & msg) && (p_count > 0) )
			{
			if ( display_edge )
				{
				/* erase edge while its SOs are still on it */
				HSsetup_ddd_sp_info( window.objid, window.osnum );
				dpmode = GRbe;
				om$send( msg = message GRgraphics.GRdisyourself( &msg,
										 &edge_env->md_env.matrix_type,
										 edge_env->md_env.matrix,
										 &dpmode,
										 NULL, &ddd_sp_info, NULL ),
					targetid = object_id,
					targetos = object_os,
					senderid = NULL_OBJID );
				}
				
			for( i=0, j=0; i<p_count; i++, j+=2 )
				{
					
				/*
				 *  If the VEso overlaps the u region, clip it
				 */
				 
				if( (no_range) || (p_parms[j] < ue && p_parms[j+1] > us) )
					{
						
					/*
					 *  Remove the original VEso
					 */

					removed_one = TRUE;
					status = de$delete_override( msg = &msg,
								    type = p_types[i],
							       symbology = &p_attr[i],
								      u1 = p_parms[j],
								      u2 = p_parms[j+1],
								 go_grid = &msc_GRid,
							     window_grid = &window,
								  module = edge_env );

					if ( ! no_range )
						{
						/*
						 *  If the left edge of the original VEso is left of the left edges of
						 *  the u range, then output a new VEso from the left edge of the
						 *  original VEso to the left edge of the u range.
						 */
					 
						if( p_parms[j] < us )
							{
							status = de$place_override( msg = &msg,
										   type = p_types[i],
									      symbology = &p_attr[i],
										     u1 = p_parms[j],
										     u2 = us,
										go_grid = &msc_GRid,
									    window_grid = &window,
										 module = edge_env,
									   interference = 0 );
							}
						
						/*
						 *  If the right edge of the original VEso is right of the right edge of
						 *  the u range, then output a new VEso from the right edge of the
						 *  u range to the right edge of the original VEso.
						 */
					 
						if( p_parms[j+1] > ue )
							{
							status = de$place_override( msg = &msg,
										   type = p_types[i],
									      symbology = &p_attr[i],
										     u1 = ue,
										     u2 = p_parms[j+1],
										go_grid = &msc_GRid,
									    window_grid = &window,
										 module = edge_env,
									   interference = 0 );
							}
						}
					}
				}

			if ( display_edge )
				{
				/* redraw edge now that SOs are gone */
				dpmode = GRbd;
				om$send( msg = message GRgraphics.GRdisyourself( &msg,
										&edge_env->md_env.matrix_type,
										edge_env->md_env.matrix,
										&dpmode,
										NULL, &ddd_sp_info, NULL ),
					targetid = object_id,
					targetos = object_os,
					senderid = NULL_OBJID );
				}
			}

		}

	return( removed_one );
	}

/*---HSget_manual_soos_on_edge--------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_manual_soos_on_edge( GRobjid object_id,
				     GRspacenum object_os,
				      IGRmatrix matrix,
				       IGRshort *matrix_type,
				struct GRmd_env *master_env,
			      struct IGRdisplay *edge_attr )
#else
	void HSget_manual_soos_on_edge( object_id,
					object_os,
					matrix,
					matrix_type,
					master_env,
					edge_attr )

	GRobjid			object_id;
	GRspacenum		object_os;
	IGRshort		*matrix_type; 
	IGRmatrix		matrix;
	struct GRmd_env		*master_env;
	struct IGRdisplay	*edge_attr;
#endif

/*
NAME
	HSget_manual_soos_on_edge

DESCRIPTION
	This function gets the manual symbology overrides that are
	present on an edge/msc.  The are stored in the HSlvhl structure.

PARAMETERS
	object_id (IN) - the object id of the edge/msc with the SOs
	object_os (IN) - the object space number of the edge/msc with the SOs
	matrix_type (IN) - the matrix type of 'matrix'
	matrix (IN) - the module environment matrix for the edge
	master_env (IN) - the module environment of the master file
	edge_attr (IN) - the IGRdisplay structure for the edge

GLOBALS USED
	DEsos
	HSlvhl
	tiling_parms.window_id (must be set for this function to work)

HISTORY
	xx/xx/91    Mike Lanier
	   Creation Date
*/

	{
	IGRshort		properties;
	IGRlong 		msg, status;
	long                    sts;

	HSlvhl.p_count = 0;
	
	/*
	 *  Check for a somewhat valid id
	 */

	if( object_id == NULL_OBJID ) return;
	
	/*
	 *  get the properties word for the edge so we can check and
	 *  see if it has overrides
	 */
	 
	status = om$send( msg = message GRvg.GRgetprops( &msg, &properties ),
		     senderid = NULL_OBJID,
		     targetid = object_id,
		     targetos = object_os );
		     
	OM_ERRCHK( status, "failed to GRgetprops\n" );
	if( !(1 & status & msg) ) return;

	if( (properties & DEHAS_OVERRIDE) && (DEsos) )
		{
			
		/*
		 *  Get all the manual overrides for the edge, and store them
		 *  in the HSlvhl structure
		 */
		 
		status = om$send( 	mode = OM_e_wrt_message,
					msg = message DEso.DEget( 
							&msg,
							&HSlvhl.p_types,
							&HSlvhl.p_parms,
							&HSlvhl.p_count,
							&HSlvhl.p_attr,
							edge_attr,
							object_id,
							tiling_parms.window_id,
							matrix_type,
							matrix,
							2, TRUE ),
			     senderid = NULL_OBJID,
			     targetid = DEsos[object_os],
			     targetos = master_env->md_id.osnum );

                if ( !( 1 & status & msg) )
                        {
                        HSlvhl.p_count = 0;
                        }

		/*
		 *  Sort the so's by min u.  This makes processing later easier
		 */
		 

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

/*---HSdump_soos_on_edge--------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSdump_soos_on_edge(  GRobjid object_id,
				GRspacenum object_os,
				 IGRmatrix matrix,
				  IGRshort *matrix_type,
			   struct GRmd_env *master_env,
			 struct IGRdisplay *edge_attr )
#else
	void HSdump_soos_on_edge( object_id,
				  object_os,
				  matrix,
				  matrix_type,
				  master_env,
				  edge_attr )
	
	GRobjid			object_id;
	GRspacenum		object_os;
	IGRshort		*matrix_type; 
	IGRmatrix		matrix;
	struct GRmd_env		*master_env;
	struct IGRdisplay	*edge_attr;
#endif

/*
NAME
	HSdump_soos_on_edge

DESCRIPTION
	This function dumps all of the manual overrides that are
	present on an edge/msc.  The are stored in the HSlvhl structure.

PARAMETERS
	object_id (IN) - the object id of the edge/msc with the SOs
	object_os (IN) - the object space number of the edge/msc with the SOs
	matrix_type (IN) - the matrix type of 'matrix'
	matrix (IN) - the module environment matrix for the edge
	master_env (IN) - the module environment of the master file
	edge_attr (IN) - the IGRdisplay structure for the edge

GLOBALS USED
	DEsos
	HSlvhl
	tiling_parms.window_id (must be set for this function to work)

HISTORY
	xx/xx/91    Mike Lanier
	   Creation Date
*/

	{
	IGRshort		properties;
	IGRlong 		msg, status, sts;

	HSlvhl.p_count = 0;
	
	/*
	 *  get the properties work for the edge so we can check and
	 *  see if it has overrides
	 */
	 
	status = om$send( msg = message GRvg.GRgetprops( &msg, &properties ),
		     senderid = NULL_OBJID,
		     targetid = object_id,
		     targetos = object_os );
		     
	OM_ERRCHK( status, "failed to GRgetprops\n" );
	if( !(1 & status & msg) ) return;

	if( (properties & DEHAS_OVERRIDE) && (DEsos) )
		{
			
		/*
		 *  Get all the manual overrides for the edge, and store them
		 *  in the HSlvhl structure
		 */

		status = om$send( 	mode = OM_e_wrt_message,
					msg = message DEso.DEget( 
							&msg,
							&HSlvhl.p_types,
							&HSlvhl.p_parms,
							&HSlvhl.p_count,
							&HSlvhl.p_attr,
							edge_attr,
							object_id,
							tiling_parms.window_id,
							matrix_type,
							matrix,
							0, /* return automatic and manual soo's */
							TRUE ),
			     senderid = NULL_OBJID,
			     targetid = DEsos[object_os],
			     targetos = master_env->md_id.osnum );

                if ( !( 1 & status & msg) )
                        {
                        HSlvhl.p_count = 0;
                        }

		/*
		 *  Sort the so's by min u.  This makes processing later easier
		 */
		 
		HSlvhl_dump_the_soos();
		}
	else
		{
		HSlvhl.p_count = 0;
		}
	}

/*---HSget_attachment_range------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSget_attachment_range( struct GRid *elem,
					      IGRmatrix matrix,
					       IGRshort *matrix_type,
					      IGRdouble *ref_range )
#else
	static void	HSget_attachment_range(
				elem,
				matrix,
				matrix_type,
				ref_range )
		
	struct GRid		*elem;
	IGRmatrix		matrix;
	IGRshort		*matrix_type;
	IGRdouble		*ref_range;
#endif

/*
DESCRIPTION
	This function gets the view-aligned dit range of a
	reference file.

PARAMETERS
	elem (IN) - the GRid of the reference file
	matrix (IN) - module environment matrix of 'elem'
	matrix_type (IN) - the type of 'matrix'
	ref_range (OUT) - the view-aligned dit range

GLOBALS USED
	gragad_stuff.gragad.dit_clip_range (must be set)

HISTORY
	xx/xx/91    Mike Lanier
	   Creation Date
*/

	{
	IGRlong		msg;
		

	GRgetrefrange(  &msg,
			&elem->osnum,	
			matrix_type,
			matrix,
			gragad_stuff.gragad.dit_clip_range,
			gragad_stuff.gragad.wld_to_viewport,
			ref_range );
	}


/*---HSlvhl_display_surface----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSlvhl_display_surface( struct GRid *object,
					IGRshort *matrix_type,
				       IGRmatrix matrix,
				 struct GRmd_env *master_env,
					  IGRint complex,
			      struct HSplot_info *info )
#else
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
#endif

/*
NAME
	HSlvhl_display_surface

DESCRIPTION
	This function sends a GRdisyourself message to a surface.

PARAMETERS
	object (IN) - the GRid of the surface
	matrix_type (IN) - the type of 'matrix'
	matrix (IN) - the module environment matrix for the surface
	master_env (IN) - the master file's module environment
	complex (IN) - flag indicating whether the object is really a composite

GLOBALS USED
	gragad_stuff (must be set)
	tiling_parms.window_id (must be set)
	sp_info (static) (must be set)

HISTORY
	xx/xx/91   Mike Lanier
	   Creation Date
*/

	{
	IGRlong 	msg, sts;
	enum GRdpmode	mode;
	IGRdouble	ref_range[6];
	OMuword		elem_classid;
        IGRint		old_levels[32], rf_levels[32];
        struct DP_information 	*sp_info_ptr;
	
	om$get_classid( osnum = object->osnum,
		      objid = object->objid,
		  p_classid = &elem_classid );

	if( (HSlvhl.output_soos) &&
		(om$is_ancestry_valid( 
			subclassid = elem_classid,
		      superclassid = OPP_GRsmhdr_class_id ) == OM_S_SUCCESS) )
		return;  /* don't process symbols in PDD */

	mode = GRbd;

	/*
	 *  Set the clip range for the object.  If the object
	 *  space is not the master, get the range from the attachment
	 *  space.
	 */
	 
	if( object->osnum > 2 )
		{
		HSget_attachment_range( object, matrix, matrix_type, ref_range );
		HSset_ele_clip_range( ref_range );
		HSset_clip_mode( TRUE );
		}
	else
		{
		HSset_ele_clip_range( gragad_stuff.gragad.dit_clip_range );
		}

	/*
	 *  Process the object, if its not a surface, were 
	 *  in trouble. As long as the next to the last argument to
	 *  HSclassify_located_object, in HSls_collect.C, is
	 *  HSlvhl_display_curve, and not HSlvhl_display_object,
	 *  were OK
	 */
	 
        if( object->osnum != 2 )
           {
           VEgetreflevels( &msg, matrix_type, matrix, &object->osnum, rf_levels );
           sp_info_ptr = &sp_info;
           DPset_levels( old_levels, rf_levels, sp_info_ptr );
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
		  senderid = tiling_parms.window_id,
		  targetid = object->objid,
		  targetos = object->osnum );

        if( object->osnum != 2 )
           {
           DPreset_levels( old_levels, sp_info_ptr );
           }
		
	if (!(sts & 1))
		{
		om$report_error(sts = sts);
		}
	}

/*---HSlvhl_display_curve----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSlvhl_display_curve( struct GRid *object,
				      IGRshort *matrix_type,
				     IGRmatrix matrix,
			       struct GRmd_env *obj_env,
			    struct HSplot_info *info )
#else
	void HSlvhl_display_curve( object,
				   matrix_type,
				   matrix,
				   obj_env )

	struct GRid	*object; 
	IGRshort	*matrix_type; 
	IGRmatrix	matrix;
	struct GRmd_env	*obj_env;
#endif

/*
NAME
	HSlvhl_display_surface

DESCRIPTION
	This function sends a GRdisyourself message to a surface.

PARAMETERS
	object (IN) - the GRid of the curve
	matrix_type (IN) - the type of 'matrix'
	matrix (IN) - the module environment matrix for the curve
	master_env (IN) - the master file's module environment

GLOBALS USED
	HSlvhl.edge_id, HSlvhl.edge_os (modified)
	gragad_stuff (must be set)
	tiling_parms.window_id (must be set)
	sp_info (static) (must be set)

HISTORY
	xx/xx/91   Mike Lanier
	   Creation Date
*/

	{
	IGRlong 		msg, status, sts;
	IGRint			sizbuf, nret;
	enum GRdpmode		mode;
	IGRchar			*absgeom;
	IGRdouble		range[6];
	struct GRsymbology	symbology;
	IGRboolean		world = TRUE;
	IGRshort		properties;
	IGRdouble		ref_range[6];	
	struct GRmd_env		master_env;

	HSlvhl.edge_id = object->objid;
	HSlvhl.edge_os = object->osnum;

	/*
	 *  Set the clip range for the object.  If the object
	 *  space is not the master, get the range from the attachment
	 *  space.
	 */
	 
	if( object->osnum > 2 )
		{
		HSget_attachment_range( object, matrix, matrix_type, ref_range );
		HSset_ele_clip_range( ref_range );
		HSset_clip_mode( TRUE );
		}
	else
		{
		HSset_ele_clip_range( gragad_stuff.gragad.dit_clip_range );
		}


	status = om$send( msg = message GRvg.GRgetprops( &msg, &properties ),
		     senderid = NULL_OBJID,
		     targetid = object->objid,
		     targetos = object->osnum );

	OM_ERRCHK( status, "failed to GRgetprops\n" );
	if_bad(status & msg) goto wrap_up;
	
	if ( properties & GRIS_VE_CURVE ) return;  /* curve is the result of previous CVE processing */

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

	/*
	 *  If the mode is output soos,
	 *  before processing the curve, remove any existing 
	 *  hidden and/or invisible soo's
	 */
	 
	if( HSlvhl.output_soos )
		{
		sizbuf = sizeof( struct GRmd_env );	
		gr$get_module_env(
			   msg = &msg,
			sizbuf = &sizbuf,
			buffer = &master_env,
			  nret = &nret );

		HSremove_VEso_on_edge(
			object->objid,
			object->osnum,
			(GRobjid)tiling_parms.window_id,
			tiling_parms.window_os,
			&HSlvhl.md_env,
			&master_env,
			(double)0.0,
			(double)1.0,
			HSlvhl.delete_user_overrides,
			FALSE );
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
		  senderid = tiling_parms.window_id,
		  targetid = object->objid,
		  targetos = object->osnum );
		
	if (!(sts & 1))
		{
		om$report_error(sts = sts);
		}
		
wrap_up:;
	}
	

end implementation Root;

