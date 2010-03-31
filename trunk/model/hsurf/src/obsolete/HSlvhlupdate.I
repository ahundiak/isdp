/*		Apogee compliant		*/

class implementation HSgragad;

#include "hsurf_import.h"
#include <stdio.h>
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "ex.h"
#include "lcdef.h"
#include "lc.h"
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "grmessage.h"
#include "igewindef.h"
#include "igewinmacros.h"

#include <FI.h>
#include "HSlvhl_info.h"
#include "HStl_global.h"

/*---HSlvhl_update----------------------------------------------------_*/

method HSlvhl_update( IGRlong *msg; 
		      IGRchar *ilvhl_info )

	{
	IGRboolean		value;		/* math routine return code */
	IGRshort		matrix_type;
	IGRint			sts;		/* OM return status */
	IGRdouble		pt[24];		/* temporary variable */
	IGRshort		k, x, y , z, i, j ,ind;
	IGRshort		maxj;
	IGRdouble		min, max;
	IGRdouble		rng[6];		/* window range */
	IGRdouble		rng1[6];	/* skew range (small range) */
	IGRlong			num_pts = 8;	/* number of points */

	enum GRlocate_types	loc_type;
	struct GRlc_upd_loc	loc_parms;
	struct GRmd_env		mdenv;
	struct DP_information	dp_info;
	IGRlong			num_byte;
	IGRlong			byte_rcvd;
	IGRint			quiet_flag;

	extern IGRboolean	MAtypemx();
	extern IGRboolean	MAidmx();
	extern IGRboolean	MAoptsxform();
	extern void		HStile_object();

	IGRint			status;
	IGRchar			heartstring[40], buf0[125], buf1[10];
	struct HSlvhl_info	*lvhl_info;
	IGRboolean		layer_already_on;
	IGRdouble		post_rotation[4][4];
	struct var_list		var_list[2];
	IGRlong			msg1, error;
	static IGRint		pipe_no_save;
	

	sts = OM_S_SUCCESS; 

	if( ex$is_batch() || ige$SR_active() ) goto end1;
	if( !(me->gragad.flags & IS_ACTIVE) ) goto end1;

	ex$disp_flag( flag = &quiet_flag );
	if( quiet_flag ) goto end1;

	/*
	 * get 8 corner points of dit clip range
	 */
	 
	k = 0;
	for( z=0; z<2; z++)
		{
		for( y=0; y<2; y++ )
			{
			for( x=0; x<2; x++ )
				{
				pt[k++] = (x) ? me->max_x_dep : me->min_x_dep;
				pt[k++] = (y) ? me->max_y_dep : me->min_y_dep;
				pt[k++] = (z) ? me->gragad.dit_clip_range[5] :
						me->gragad.dit_clip_range[2];
				}
			}
		}

	/*
	 * transform 8 points to world coordinate system (wcs)
	 */
	 
	value = MAtypemx( msg, me->gragad.viewport_to_wld, &matrix_type );
	
	value = MAoptsxform(	msg, 
				&num_pts, 
				&matrix_type,
				me->gragad.viewport_to_wld,
				pt,
				pt );

	/*
	 * get view range (accumulate hi's and low's)
	 */

	for( j=0; j<3; j++ )	 /* for x,y,z coordinate */
		{
		min = max = pt[j];
		for( i=0, k=j; i<8; i++, k+=3 )
			{
			min = ( pt[k] < min ) ? pt[k] : min;
			max = ( pt[k] > max ) ? pt[k] : max;
		 	}
		 	
		rng[j] = min;
		rng[j+3] = max;
		}

	loc_parms.is_ortho = 1;

	/*
	 * if skew then get skew range  
	 */
	 
	if( !(me->gragad.flags & AXIS_WLD_ALIGN) )
		{
		loc_parms.is_ortho = 0;

		if( me->gragad.flags & IS_PERSP )
			{
			j = 12;
			maxj = 15;
			
			loc_parms.view_vector[0] = - me->gragad.rotation[2][0];
			loc_parms.view_vector[1] = - me->gragad.rotation[2][1];
			loc_parms.view_vector[2] = - me->gragad.rotation[2][2];
			}
		else
			{
			maxj = 3;
			j = 0;
			
			loc_parms.view_vector[0] = me->gragad.rotation[2][0];
			loc_parms.view_vector[1] = me->gragad.rotation[2][1];
			loc_parms.view_vector[2] = me->gragad.rotation[2][2];
			}
			
		ind = 0;
		while( j < maxj )	 /* for x,y,z coordinate */
			{
			min = max = pt[j];
			for( i=0, k=j; i<4; i++, k+=3 )
				{
				min = ( pt[k] < min ) ? pt[k] : min;
				max = ( pt[k] > max ) ? pt[k] : max;
				}
				
			rng1[ind] = min;
			rng1[ind+3] = max;
			
			j++;
			ind++;
			}
			
		memcpy( (char *)loc_parms.upd_range2, (char *)rng1, sizeof(IGRdouble)*6 );
		}
 
	memcpy( (char *)loc_parms.upd_range, (char *)rng, sizeof(IGRdouble)*6 );

	/* get dpb information */

	num_byte = sizeof( struct GRmd_env );
	
	gr$get_module_env( msg = msg, 
			sizbuf = &num_byte, 
			buffer = &mdenv, 
			  nret = &byte_rcvd);

	if( ! (1&(*msg)) ) goto wrapup0;


	ex$get_modid( mod_osnum = OM_Gw_current_OS,
			 mod_id = &mdenv.md_id.objid);

	mdenv.md_id.osnum = OM_Gw_current_OS;


	/* call locate */

	loc_type = GR_upd_loc;
	loc_parms.msg = *msg;
	loc_parms.mode = GRbd;
	loc_parms.alt_symb = 0;
	loc_parms.sp_info = &dp_info;

	lvhl_info = (struct HSlvhl_info *)ilvhl_info;

	/*
	 *  force the gpipe_id to 255, so that the tiler will not
	 *  destroy the existing window structure.  Instead it will create
	 *  a new one, just for this case
	 */
	 	
	pipe_no_save = me->gragad.gpipe_id;
	me->gragad.gpipe_id = 255;

	/* 
	 *  setup the dp information for the query
	 */
	 
	dp_info.gragad = &me->gragad;
	dp_info.win_no = me->win_no;
	dp_info.is_update = TRUE;
	dp_info.is_fit = FALSE;
	dp_info.is_hidden_line = TRUE;
	dp_info.hline_info = NULL;
	dp_info.hl_tiler = HStile_object;
	dp_info.view_objid = my_id;
	dp_info.view_osnum = OM_Gw_current_OS;
		
	HSinit_lvhl_timing();

	/*
	 *  attempt to allocate an lvhl zbuffer.  If ok, continue, else
	 *  display error box and exit
	 */
	 		
	if( HSallocate_lvhl_zbuffer_memory(
			me->gragad.gpipe_id,
			me->min_x_dep, me->max_x_dep,
			me->min_y_dep, me->max_y_dep,
			lvhl_info ) )
		{
			
		/*
		 *  get the post rotation matrix, only if we are in a perspective
		 *  window.  This will be used to initialize the lvhl window
		 */
		 
		if( me->gragad.flags & IS_PERSP )
			{
			/* can only get post rotation matrix from perspective views */
			var_list[0].var		   = POST_ROTATION;
			var_list[0].var_ptr	   = (IGRchar *) post_rotation;
			var_list[0].num_bytes	   = sizeof(IGRdouble)*16;
			var_list[0].bytes_returned = &byte_rcvd;
			var_list[1].var		   = END_PARAM;

			dp$inq_set_gragad(
				msg		= &msg1, 
				which_error	= &error,
				var_list	= var_list,
				gragad_objid	= my_id,
				osnum		= OM_Gw_current_OS );
			}

		/*
		 *  save the old dep range and load in the new one
		 */
		 
		lvhl_info->min_x_dep_sv = me->min_x_dep;
		lvhl_info->min_y_dep_sv = me->min_y_dep;
		lvhl_info->max_x_dep_sv = me->max_x_dep;
		lvhl_info->max_y_dep_sv = me->max_y_dep;

		me->min_x_dep = lvhl_info->min_x_dep;
		me->min_y_dep = lvhl_info->min_y_dep;
		me->max_x_dep = lvhl_info->max_x_dep;
		me->max_y_dep = lvhl_info->max_y_dep;

		/*
		 *  Must reset the gpipe_id or DPcal will memory fault
		 */
		 
		me->gragad.gpipe_id = pipe_no_save;		

		sts = om$send(
			mode     = OM_e_wrt_message,
			msg      = message IGEgragad.DPcal( msg ),
			targetid = my_id );

		me->gragad.gpipe_id = 255;

		/*
		 *  initialize the lvhl window
		 */
		 
		HSinit_lvhl_window(
			me->gragad.gpipe_id,
			me->win_no,
			&me->gragad,
			post_rotation,
			lvhl_info );

		/*
		 *  Send all the non-edge information into the
		 *  tiler to populate the zbuffer
		 */

		HSset_styled_raster_layers( 
			1021, 
			lvhl_info->visible_layer, 
			lvhl_info->hidden_layer );
		
		HSset_processing_mode( HS_PMODE_LVHL_SURFACE );
	
		sprintf( heartstring, "Process Surfaces" );
		HSinit_heartbeat( heartstring );

		sts = GRlcquery( msg, &mdenv, &loc_type, (IGRchar *)&loc_parms, NULL, NULL, NULL );
		
		/*
		 *  Get status on the edges layer and turn it on
		 *  if it is off.
		 */

		i = 1021;
		layer_already_on = me->gragad.levels[i >> 5] & (1 << (i % 32));
		
		if( !layer_already_on )
			me->gragad.levels[i >> 5] |= 1 << (i % 32);


		/*
		 *  Send the edge objects only, into the tyler to display
		 *  the results.  Init the curve pool
 		 */

		HSset_processing_mode( HS_PMODE_LVHL_EDGES );

		HSlvhl_init_curve_pool();

		sprintf( heartstring, "Create Edges" );
		HSinit_heartbeat( heartstring );

		/*
		 *  cycle through the objects and process the curves
		 */

		GRlcquery( msg, &mdenv, &loc_type, (IGRchar *)&loc_parms, NULL, NULL, NULL );

		/*
		 *  add the curves to the rtree, then deactivate lvhl mode
		 */

		HSlvhl_add_curves_to_rtree();
			
		HSset_processing_mode( HS_PMODE_SHADING );

		/*
		 *  If the edges layer was originally off, the turn it back off
		 */

		if( !layer_already_on )
			{
			i = 1021;
			me->gragad.levels[i >> 5] &= ~(1 << (i % 32));
			}

		/*
		 *  reload the original dep range and call DPcal to
		 *  reset the instance data.  Again, reset the pipe no
		 *  so DPcal will not memory fault.
		 */
		 
		me->min_x_dep = lvhl_info->min_x_dep_sv;
		me->min_y_dep = lvhl_info->min_y_dep_sv;
		me->max_x_dep = lvhl_info->max_x_dep_sv;
		me->max_y_dep = lvhl_info->max_y_dep_sv;

		me->gragad.gpipe_id = pipe_no_save;		
		sts = om$send(
			mode     = OM_e_wrt_message,
			msg      = message IGEgragad.DPcal( msg ),
			targetid = my_id );
			
		HSfree_lvhl_memory( me->gragad.gpipe_id );
		}
	else
		{
		sprintf( buf0, "Unable to allocate low resolution hidden line zbuffer memory" );

		sprintf( buf1, "LVHL Error" );

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
		}

	me->gragad.gpipe_id = pipe_no_save;
			
	HSfini_lvhl_timing();
wrapup0:
end1:
	return(sts);
	}
	
end implementation HSgragad;
