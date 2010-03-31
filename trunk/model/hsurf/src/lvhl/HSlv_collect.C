
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#define CHECK_RETURN_CODES 0


#define DEBUG_LOCATE	0

#include <stdio.h>
#include <stdlib.h>
#include <FI.h>
#include "wl.h"

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMtypes.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "growner.h"
#include "godef.h"
#include "dpstruct.h"
#include "msdef.h"
#include "msmacros.h"
#include "bs.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hsurferrpriv.h"
#include "hsurf.h"
#include "hswinmacros.h"
#include "hsmessage.h"
#include "hskyoptypes.h"
#include "hsanimate.h"

#include "HSrle.h"
#include "HSsara.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"
#include "HStl_global.h"
#include "HSlvhl.h"
#include "HSpvhl.h"
#include "HSplot.h"

#include "HSpr_lvhl.h"

/*--------------------------
 *  for functions
 *     HSset_hidden_line_display_mode
 *     HSset_processing_mode
 *     HSset_pvhl_z
 */
 
#include "HSpr_tiler_f.h"


/*------------------------------
 *  for function
 *     HSupdate_heartbeat
 */

#include "HSpr_co_func.h"

/*-------------------------------*/


static void	HSlvhl_stub() {}
static void	HSlvhl_copy_text_stub(OM_S_OBJID text_id, 
					 OMuword text_os, 
				       IGRdouble *matrix, 
					IGRshort matrix_type, 
				 struct GRmd_env *master_env) {}
				 
static IGRint	HSlvhl_always_TRUE(IGRshort object_os, 
				 IGRboolean is_symbol) { return( TRUE ); }

static struct xhatch_node_info	*xhatch_top, *xhatch_curr;
static struct object_node_info	*xobj;

/*---HSlvhl_collect_elements-------------------------------------------*/

/*
NAME
	HSlvhl_collect_elements
	
DESCRIPTION
	Collect element from the Process Detail Display, Create Visible
	Edges or Pseudo Process Detail Display event generator and pass
	on to the classify for processing within the tiler.
	
	Special pre-processing is done for the Pseudo case in that the
	objects are organized within structure that group them according
	to the xhatch element(s)
	
PARAMETERS
	co_grid
	window
	gschansel
	resolution		: Resolution of the output, Medium or Low
	display_hidden_lines	: Whether to display the hidden edges or not
	copy_text		: In CVE mode, whether to copy the text to
				  the text layer or not
	output_3d		: If the CVE is to be 3D or 2D
	process_wireframe	: Ignore non surfaces or not
	clip_to_fence		: Honor an existing fence
	output_soo		: Output is in the form of overrides or curves.
	visible_layer		: For CVE, the layer on which to place the
				  visible edges
	hidden_layer		: For CVE, the layer on which to place the
				  hidden edges
	text_layer		: For CVE, the layer to which to copy the
				  text objects
	delete_overrides	: Delete existing (manual) overrides or not.
	turn_ref_files_off	:
	pseudo			: In 2D VHL mode or not
	
HISTORY
	??/??/??	M. Lanier
		Created
		
	06/04/92	M. Lanier
		Added 2D VHL mode
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRboolean HSlvhl_collect_elements( struct GRid *co_grid,
					    struct GRid *window,
					OM_S_CHANSELECT *gschansel,
					  unsigned char resolution,
					     IGRboolean display_hidden_lines,
					     IGRboolean copy_text,
					     IGRboolean output_3d,
					     IGRboolean process_wireframe,
					     IGRboolean clip_to_fence,
					     IGRboolean output_soos,
					 unsigned short visible_layer,
					 unsigned short hidden_layer,
					 unsigned short text_layer,
					     IGRboolean delete_overrides,
					     IGRboolean turn_ref_files_off,
					     IGRboolean pseudo,
					  unsigned char process_tangent )
#else
	IGRboolean HSlvhl_collect_elements( 
			co_grid, 
			window, 
			gschansel, 
			resolution,
			display_hidden_lines,
			copy_text,
			output_3d,
			process_wireframe,
			clip_to_fence,
			output_soos,
			visible_layer,
			hidden_layer,
			text_layer,
			delete_overrides,
			turn_ref_files_off,
			pseudo,
			process_tangent )
	
	struct GRid	*co_grid;
	struct GRid	*window;
	OM_S_CHANSELECT	*gschansel;
	unsigned char	resolution;
	IGRboolean	display_hidden_lines;
	IGRboolean	copy_text;
	IGRboolean	output_3d;
	IGRboolean	process_wireframe;
	IGRboolean	clip_to_fence;
	IGRboolean	output_soos;
	unsigned short	visible_layer;
	unsigned short	hidden_layer;
	unsigned short	text_layer;
	IGRboolean	delete_overrides;
	IGRboolean      turn_ref_files_off;
	IGRboolean	pseudo;
	unsigned char	process_tangent;
#endif

	{
	IGRlong			sts;
	IGRlong			msg;
	IGRint			num_ret;
	IGRint			i;
	IGRint			object_count;
	struct GRid		fence_grid;
	struct GRobj_env	obj_info;
	IGRboolean		stat;

	void (*text_copy_function)( OM_S_OBJID text_id, 
				       OMuword text_os, 
				     IGRdouble *matrix, 
				      IGRshort matrix_type, 
			       struct GRmd_env *master_env );
			       
	void			(*curve_proc_function1)();
	void			(*curve_proc_function2)();
	
	IGRint (*object_preprocessor)(IGRshort object_os, 
				    IGRboolean is_symbol);
				    
	IGRboolean		a_ref_file_was_turned_off = FALSE;
		

	/* 
	 * get the fence object's id 
	 */

	fence_grid.objid = NULL_OBJID;
	fence_grid.osnum = 0;
	
	gr$gsget_fence( msg = &msg, 
		   fence_id = &fence_grid );

	/* 
	 * find out how many objects were located 
	 */
	 
	sts = gr$gsinqcount( msg = &msg,
			   count = &object_count,
			senderid = co_grid->objid,
			senderos = co_grid->osnum,
		    p_chanselect = gschansel );

	OM_ERRCHK( sts, "HSlvhl_collect_elements: gr$gsinqcount OM error" );
	MSG_ERRCHK( msg, "HSlvhl_collect_elements: gr$gsinqcount failed" );

#	if DEBUG_LOCATE
		fprintf( stderr, "Objects on channel:  %d\n\n", object_count );
		fprintf( stderr, "The located objects are:\n\n" );
#	endif

	/* 
	 * get each located object individually and classify it 
	 */

	stat = TRUE;
	
	HSset_processing_mode( HS_PMODE_LVHL_SURFACE );
	HSinit_activated_completed();
	HSset_hidden_line_display_mode( display_hidden_lines );

	HSlvhl_init_curve_pool();
		
	/*
	 *  Initialize the window for lvhl display.  If an error occurs
	 *  Immediatly return
	 */
	 
	if( !(stat = HSlvhl_init_display_object( window, resolution, clip_to_fence )) ) goto wrapup;


	/*
	 *  If the flag has been set to copy text, then set the copy text function
	 *  to HSlvhl_copy_text, else set it to HSlvhl_stub
	 */
	 	
	text_copy_function = copy_text ? HSlvhl_copy_text : HSlvhl_copy_text_stub;

	if( process_wireframe )
		{
		curve_proc_function1 = HSupdate_activated_completed;
		curve_proc_function2 = HSlvhl_display_curve;
		}
	else
		{
		curve_proc_function1 = HSlvhl_stub;
		curve_proc_function2 = HSlvhl_stub;
		}

	/*
	 *  store the output layer information
	 */
	 
	HSlvhl.visible_layer = visible_layer;
	HSlvhl.hidden_layer = hidden_layer;
	HSlvhl.text_layer = text_layer;
	

	/*
	 *  Set the output_2d value in HSlvhl to !output_3d
	 */
	 
	HSlvhl.output_2d = !output_3d;
	HSlvhl.process_tangent = process_tangent;
	HSlvhl.delete_user_overrides = delete_overrides;

	/*
	 *  Set the function pointer for HSlvhl.output_span.  Also
	 *  set the object preprocessor.
	 */
	 
	if( HSlvhl.output_soos = output_soos )
		{
		HSlvhl.output_span = HSlvhl_output_soo_span;
                HSset_curve_type_to_curve( TRUE );
		object_preprocessor = HSlvhl_build_os_info_list;
		}
	else
		{
                HSset_curve_type_to_curve( FALSE );
		HSlvhl.output_span = HSlvhl_output_curve_span;
		object_preprocessor = HSlvhl_always_TRUE;
		}

	/*
	 *  Initialize the os_info functions
	 */
	 
	HSlvhl_init_os_info();

	xhatch_top = NULL;
	if( pseudo )
		{
		HSset_active_z_range( 0.0, 1024.0 );
		HSpvhl_init_xhatch_object_node_pool();
					
		/*
		 *  Collect the objects and build them into a xhatch structure
		 */

		for( i=0; i<object_count; i++ )
			{
			sts = gr$gsget_objects( msg = &msg,
					      array = &obj_info,
					       size = sizeof( struct GRobj_env ),
					      count = &num_ret,
					   from_obj = i,
					     to_obj = i,
					   senderid = co_grid->objid,
					   senderos = co_grid->osnum,
				       p_chanselect = gschansel );

			OM_ERRCHK( sts, "HSlvhl_collect_elements: gr$gsget_objects OM error" );
			MSG_ERRCHK( msg, "HSlvhl_collect_elements: gr$gsget_objects failed" );

			if( (1 & msg & sts) )
				{
				HSpvhl_build_xhatch_node( &obj_info, &xhatch_top ); 
				}
			}

		/*
		 *  Process the objects,
		 *  First pass
		 */
		 
		tiling_parms.processing_mode |= HS_PMODE_PVHL_SURFACE;
		
		xhatch_curr = xhatch_top;
		while( xhatch_curr != NULL )
			{
			if( !xhatch_curr->xhatch_object )
				{

				/*
				 *  This is not a xhatch object, but send it anyway
				 *  so that it will get counted
				 */
				 
				memcpy( &HSlvhl.md_env, &xhatch_curr->id.mod_env, sizeof( struct GRmd_env ) );

				HSclassify_located_object( 
						&xhatch_curr->id.obj_id, 
						(struct GRmd_env *)&xhatch_curr->id.mod_env.md_id, 
						xhatch_curr->id.mod_env.md_env.matrix,
						&xhatch_curr->id.mod_env.md_env.matrix_type,
						&fence_grid,
						FALSE,
						object_preprocessor,
						HSlvhl_stub,
						curve_proc_function1,
						HSlvhl_copy_text_stub,
						NULL,
						(turn_ref_files_off) ? &a_ref_file_was_turned_off : NULL );
				}
			else
				{
					
				/*
				 *  Send the solid boundary loop
				 */

				HSset_pvhl_z( xhatch_curr->level );
						 
				memcpy( &HSlvhl.md_env, &xhatch_curr->id.mod_env, sizeof( struct GRmd_env ) );

				tiling_parms.processing_mode |= (HS_PMODE_PVHL_OBJECT_BEGIN | HS_PMODE_PVHL_NEW_LOOP);

				if( xhatch_curr->holes == NULL )
					tiling_parms.processing_mode |= HS_PMODE_PVHL_OBJECT_END;

				HSclassify_located_object( 
						&xhatch_curr->id.obj_id, 
						(struct GRmd_env *)&xhatch_curr->id.mod_env.md_id, 
						xhatch_curr->id.mod_env.md_env.matrix,
						&xhatch_curr->id.mod_env.md_env.matrix_type,
						&fence_grid,
						FALSE,
						object_preprocessor,
						HSlvhl_stub,
						curve_proc_function2,
						HSlvhl_copy_text_stub,
						NULL,
						(turn_ref_files_off) ? &a_ref_file_was_turned_off : NULL );

				/*
				 *  Send the holes
				 */
			 
				xobj = xhatch_curr->holes;
				while( xobj != NULL )
					{			
					tiling_parms.processing_mode |= HS_PMODE_PVHL_NEW_LOOP;

					/*
					 *  For the last loop, send the end flag
					 */
					 				
					if( xobj->next == NULL )
						tiling_parms.processing_mode |= HS_PMODE_PVHL_OBJECT_END;

					memcpy( &HSlvhl.md_env, &xhatch_curr->id.mod_env, sizeof( struct GRmd_env ) );

					HSclassify_located_object( 
							&xobj->id,
							(struct GRmd_env *)&xhatch_curr->id.mod_env.md_id, 
							xhatch_curr->id.mod_env.md_env.matrix,
							&xhatch_curr->id.mod_env.md_env.matrix_type,
							&fence_grid,
							FALSE,
							object_preprocessor,
							HSlvhl_stub,
							curve_proc_function2,
							HSlvhl_copy_text_stub,
							NULL,
							(turn_ref_files_off) ? &a_ref_file_was_turned_off : NULL );

					xobj = xobj->next;
					}

				/*
				 *  Send the lines, just to be counted
				 */
			 
				xobj = xhatch_curr->lines;
				while( xobj != NULL )
					{
					memcpy( &HSlvhl.md_env, &xhatch_curr->id.mod_env, sizeof( struct GRmd_env ) );

					HSclassify_located_object( 
							&xobj->id,
							(struct GRmd_env *)&xhatch_curr->id.mod_env.md_id, 
							xhatch_curr->id.mod_env.md_env.matrix,
							&xhatch_curr->id.mod_env.md_env.matrix_type,
							&fence_grid,
							FALSE,
							object_preprocessor,
							HSlvhl_stub,
							curve_proc_function1,
							HSlvhl_copy_text_stub,
							NULL,
							(turn_ref_files_off) ? &a_ref_file_was_turned_off : NULL );

					xobj = xobj->next;
					}
				}

			xhatch_curr = xhatch_curr->next;
			}
				
		/*
		 *  Now the 2nd pass
		 */
			 
		HSset_processing_mode( HS_PMODE_LVHL_EDGES );
		 
		object_preprocessor = HSlvhl_always_TRUE;

		HSlvhl_create_soos_for_os();

		tiling_parms.processing_mode &= ~HS_PMODE_PVHL_SURFACE;
		tiling_parms.processing_mode |=  HS_PMODE_PVHL_EDGES;
			
		xhatch_curr = xhatch_top;
		while( xhatch_curr != NULL )
			{

			/*
			 *  Send the solid boundary loop
			 */
			 
			HSset_pvhl_z( xhatch_curr->level );

			memcpy( &HSlvhl.md_env, &xhatch_curr->id.mod_env, sizeof( struct GRmd_env ) );

			HSclassify_located_object( 
					&xhatch_curr->id.obj_id, 
					(struct GRmd_env *)&xhatch_curr->id.mod_env.md_id, 
					xhatch_curr->id.mod_env.md_env.matrix,
					&xhatch_curr->id.mod_env.md_env.matrix_type,
					&fence_grid,
					FALSE,
					object_preprocessor,
					HSlvhl_stub,
					curve_proc_function2,
					HSlvhl_copy_text_stub,
					NULL,
					(turn_ref_files_off) ? &a_ref_file_was_turned_off : NULL );


			/*
			 *  Send the holes
			 */
			 
			xobj = xhatch_curr->holes;
			while( xobj != NULL )
				{

				/*
				 *  For the last loop, send the end flag
				 */

				memcpy( &HSlvhl.md_env, &xhatch_curr->id.mod_env, sizeof( struct GRmd_env ) );

				HSclassify_located_object( 
						&xobj->id,
						(struct GRmd_env *)&xhatch_curr->id.mod_env.md_id, 
						xhatch_curr->id.mod_env.md_env.matrix,
						&xhatch_curr->id.mod_env.md_env.matrix_type,
						&fence_grid,
						FALSE,
						object_preprocessor,
						HSlvhl_stub,
						( xobj->level == xhatch_curr->level ) ? curve_proc_function2 : curve_proc_function1,
						HSlvhl_copy_text_stub,
						NULL,
						(turn_ref_files_off) ? &a_ref_file_was_turned_off : NULL );

				xobj = xobj->next;
				}

			/*
			 *  Send the lines, just to be counted
			 */
			 
			xobj = xhatch_curr->lines;
			while( xobj != NULL )
				{
				memcpy( &HSlvhl.md_env, &xhatch_curr->id.mod_env, sizeof( struct GRmd_env ) );

				HSclassify_located_object( 
						&xobj->id,
						(struct GRmd_env *)&xhatch_curr->id.mod_env.md_id, 
						xhatch_curr->id.mod_env.md_env.matrix,
						&xhatch_curr->id.mod_env.md_env.matrix_type,
						&fence_grid,
						FALSE,
						object_preprocessor,
						HSlvhl_stub,
						( xobj->level == xhatch_curr->level ) ? curve_proc_function2 : curve_proc_function1,
						/*curve_proc_function2,*/
						HSlvhl_copy_text_stub,
						NULL,
						(turn_ref_files_off) ? &a_ref_file_was_turned_off : NULL );

				xobj = xobj->next;
				}

			xhatch_curr = xhatch_curr->next;
			}

		tiling_parms.processing_mode &= ~HS_PMODE_PVHL_EDGES;
		}
	else
		{
		for( i=0; i<object_count; i++ )
			{
			HSupdate_heartbeat();

			sts = gr$gsget_objects( msg = &msg,
					      array = &obj_info,
					       size = sizeof( struct GRobj_env ),
					      count = &num_ret,
					   from_obj = i,
					     to_obj = i,
					   senderid = co_grid->objid,
					   senderos = co_grid->osnum,
				       p_chanselect = gschansel );

			OM_ERRCHK( sts, "HSlvhl_collect_elements: gr$gsget_objects OM error" );
			MSG_ERRCHK( msg, "HSlvhl_collect_elements: gr$gsget_objects failed" );

			if( (1 & msg & sts) )
				{
					
				/*
				 *  save the module environment information for the object
				 */
			 
				memcpy( &HSlvhl.md_env, &obj_info.mod_env, sizeof( struct GRmd_env ) );
			
				HSclassify_located_object( 
					&obj_info.obj_id, 
					(struct GRmd_env *)&obj_info.mod_env.md_id, 
					obj_info.mod_env.md_env.matrix,
					&obj_info.mod_env.md_env.matrix_type,
					&fence_grid,
					FALSE,
					object_preprocessor,
					HSlvhl_display_surface,
					curve_proc_function1,
					HSlvhl_copy_text_stub,
					NULL,
					(turn_ref_files_off) ? &a_ref_file_was_turned_off : NULL );
				}
			
			if( IGEstop() ) goto fini;
			}

		HSset_processing_mode( HS_PMODE_LVHL_EDGES );
		 
		object_preprocessor = HSlvhl_always_TRUE;

		HSlvhl_create_soos_for_os();

		for( i=0; i<object_count; i++ )
			{
			HSupdate_heartbeat();

			sts = gr$gsget_objects( msg = &msg,
					      array = &obj_info,
					       size = sizeof( struct GRobj_env ),
					      count = &num_ret,
					   from_obj = i,
					     to_obj = i,
					   senderid = co_grid->objid,
					   senderos = co_grid->osnum,
				       p_chanselect = gschansel );

			OM_ERRCHK( sts, "HSlvhl_collect_elements: gr$gsget_objects OM error" );
			MSG_ERRCHK( msg, "HSlvhl_collect_elements: gr$gsget_objects failed" );

			if( (1 & msg & sts) )
				{
			
				/*
				 *  save the module environment information for the object
				 */
			 
				memcpy( &HSlvhl.md_env, &obj_info.mod_env, sizeof( struct GRmd_env ) );
				
				HSclassify_located_object( 
					&obj_info.obj_id, 
					(struct GRmd_env *)&obj_info.mod_env.md_id, 
					obj_info.mod_env.md_env.matrix,
					&obj_info.mod_env.md_env.matrix_type,
					&fence_grid,
					FALSE,
					object_preprocessor,
					HSlvhl_display_surface,
					curve_proc_function2,
					text_copy_function,
					NULL,
					NULL );
				}
			
			if( IGEstop() ) goto fini;
			}
		}

fini:

	/*
	 *  Finish up: Put the generated curves in the RTREE and
	 *  free memory allocated for this processing
	 */
	 
	/*
	 *  If we are not in output soo mode, then add the generated 
	 *  curves to the rtree
	 */
	 
	if( !output_soos )
		HSlvhl_add_curves_to_rtree();


	HSset_processing_mode( HS_PMODE_SHADING );

	HSlvhl_fini_display_object();
	HSlvhl_reset_curve_pool();
	HSlvhl_free_zbuffer_memory( 255 );
	HSlvhl_free_os_info();

	IGEresetstop();
	
	/* convert shading window to wireframe to be consistent */
	/* with high-res VHL                                    */
	hs$convert_shading_window_to_wireframe(
					msg = &msg,
					win_os = window->osnum,
					win_id = window->objid,
					update = FALSE,
					display_message = FALSE );


	if ( a_ref_file_was_turned_off )
		{
		/* update the window because the display of a ref. file */
	        /* was turned off to be consistent with high-res VHL    */
		dp$gen_update(
			msg = &msg,
			osnum = window->osnum,
			objid = window->objid );
		}

wrapup:

	/* 
	 * empty the located object channel
	 */
	 
	gr$gsempty( msg = &msg ,
	       senderid = co_grid->objid,
	       senderos = co_grid->osnum,
	   p_chanselect = gschansel );

	MSG_ERRCHK( msg, "HSlvhl_collect_elements: gr$gsempty failed" );

	{
	int	na, nc;
	HSget_num_activated_completed( &na, &nc );
	if( na == 0 || nc == 0 )
		stat = FALSE;
	}
	
	return( stat );
	}


/*---- HSare_there_read_only_ref_files -------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRboolean HSare_there_read_only_ref_files( struct GRid *co_grid,
						OM_S_CHANSELECT *gschansel )
#else
	IGRboolean HSare_there_read_only_ref_files( co_grid, gschansel )

	struct GRid      *co_grid;
	OM_S_CHANSELECT  *gschansel;
#endif

/*
DESCRIPTION
	This function searches the channel of located objects to see if there
	is a read-only reference file.  If there is, TRUE is returned otherwise
	FALSE is returned.

HISTORY
	S.P. Rogers  11/13/91  Creation Date
*/

	{
	IGRlong          sts;
	IGRlong          msg;
	IGRint           num_ret;
	IGRint           ii;
	IGRint           object_count;
	struct GRobj_env obj_info;

	/* find out how many objects were located */
	sts = gr$gsinqcount( msg          = &msg,
	                     count        = &object_count,
	                     senderid     = co_grid->objid,
	                     senderos     = co_grid->osnum,
	                     p_chanselect = gschansel );

	/* get each located object individually and see if it is from a read-only object space */
	for ( ii = 0; ii < object_count; ii++ )
	   {
	   sts = gr$gsget_objects( msg          = &msg,
	                           array        = &obj_info,
	                           size         = sizeof( struct GRobj_env ),
	                           count        = &num_ret,
	                           from_obj     = ii,
	                           to_obj       = ii,
	                           senderid     = co_grid->objid,
	                           senderos     = co_grid->osnum,
	                           p_chanselect = gschansel );

	   if ( (1 & msg & sts) )
	      {
	      if ( HSis_os_read_only( obj_info.obj_id.osnum ) )
	         return( TRUE );
	      }

	   }  /* end: for */

	return( FALSE );

	}  /* HSare_there_read_only_ref_files */

