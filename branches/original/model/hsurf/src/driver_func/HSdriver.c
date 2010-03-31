
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

#include <stdio.h>
#include <tools.h>
#include <alloca.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igewindow.h"
#include "igrdef.h"
#include "igrdp.h"
#include "igr.h"
#include "gr.h"
#include "dp.h"
#include "dpstruct.h"

#include "hsmacdef.h"
#include "hstiler.h"
#include "hslight.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "hsmath.h"
#include "HSlvhl.h"
#include "DEso.h"

/******/
#include "HSfem_spt.h"
/******/

#include "HSe2_mesher.h"
#include "HSpr_driver.h"

#define DEBUG		0

/*---HSreset_transformation_matrix--------------------------------------------*/

void	HSreset_transformation_matrix( IGRint window_no,
				    IGRdouble world_to_view[4][4],
				    IGRdouble world_to_viewport[4][4],
				    IGRdouble r_matrix[4][4],
				    IGRdouble post_rotation[4][4],
				    IGRdouble vw_vol[6],
				    IGRdouble eye_pt[3],
				    IGRdouble vrp[3],
				    IGRdouble vpn[3],
				    IGRdouble vup[3],
				       IGRint x_dits,
				       IGRint y_dits )

/*
NAME
	HSreset_transformation_matrix

DESCRIPTION
	Change the HSURF transformation information for a window.  The function was
	designed to support the matrix change that occurs during an update when
	view independent elements are encountered.

PARAMETERS
	window_no (IN) - the window number of the window to reset
	world_to_view (IN) - the new world to view matrix
	world_to_viewport (IN) - the new world to viewport matrix
	r_matrix (IN) - the new rotation matrix
	post_rotation (IN) - the new post rotation matrix
	vw_vol (IN) - the new view volume
	eye_pt (IN) - the new eye point
	vrp (IN) - the new view reference point
	vpn (IN) - the new view plane normal
	vup (IN) - the new view up vector
	x_dits (IN) - the new x size of the window in dits
	y_dits (IN) - the new y size of the window in dits

GLOBALS USED
	active_window - changed to point to data for 'window_no'

HISTORY
	xx/xx/xx    Unknown Programmer
	   Creation Date
	01/14/92    S.P. Rogers
	   Added support for EdgeII (parameter list changes) and prologue comment
*/

	{
	IGRdouble *trans_matrix;
	IGRdouble local_matrix[4][4];

	HSactivate_window( window_no );
	if( active_window == NULL ) return;

	trans_matrix = (active_window->perspective) ?
	                (IGRdouble *) world_to_view : (IGRdouble *) world_to_viewport;

#if defined( ENV5 )
	if ( active_window->type & HShardware_LB_GPIPE )
		   HSsetGPmatrix( trans_matrix );
#endif
	
	HSconvert_transformation_matrix( trans_matrix, local_matrix );
	HSset_active_transformation( local_matrix );
	HSconvert_rotation_matrix( r_matrix, local_matrix );
	HSset_active_rotation( local_matrix );

	HSset_active_perspective_scales( post_rotation[0][0], post_rotation[1][1], post_rotation[3][2] );

#if defined( ENV5 )
	if ( active_window->type & HShardware_LB_EG )
	   {
	   HSsetup_EG_window( world_to_view, vw_vol, eye_pt, vrp, vpn, vup, x_dits, y_dits, FALSE );
	   }
#endif
	}

/*-- HSrepaint_shading_window -----------------------------------------------*/

void	HSrepaint_shading_window( IGRint window_no, struct IGEdit_range *range )

/*
NAME
	HSrepaint_shading_window

DESCRIPTION
	Activates the given window and repaints it using whatever is currently in
	its image buffer.

PARAMETERS
	window_no (IN) - the window number of the window to repaint

GLOBALS USED
	active_window - set to point to data for 'window_no'

HISTORY
	04/28/86    S.A. Rapa
	   Created
*/

	{
 	HSactivate_window( window_no );
#	if INTEL
	HSrepaint( range );
#	else
	HSrepaint( NULL );
#	endif
	}

static double			*boundary = NULL;
static int			boundary_size = 0;


/*---HSshade_object----------------------------------------------------------*/

void	HSshade_object(	IGRint mode,
			IGRint pipe_no,
			IGRint type,
			  char *geometry,
			  char *ele_spec_att,
		     IGRdouble *clip_range,
		     IGRdouble *range,
		     IGRdouble *u_range,
		     IGRdouble *v_range,
			IGRint acc_mode,
   	        	IGRint accuracy,
		     IGRdouble win_cht,
		     IGRdouble basis_tol,
		     IGRdouble dis_tol,
			IGRint color,
			IGRint options,
		    IGRboolean ele_style,
		    IGRboolean part_of_solid,
		    IGRboolean dont_cull,
		     IGRdouble *text_buffer,
			IGRint coords_returned,
			struct HS_element_rendering_parms *render_parms,
			IGRint *min_x )

/*
NAME
	HSshade_object

DESCRIPTION
	This function starts the shading process.  It sends the object
	to the appropriate tiler.

PARAMETERS
	mode (IN) - tiler mode flag
	pipe_no (IN) - gragad in which to display the object
	type (IN) - element type
	geometry (IN) - element geometry
	ele_spec_att (IN) - element specific attributes
	clip_range (IN) - element clip range in dits
	range (IN) - element world coordinate range
	u_range (N) -  element solid U range (only used for surfaces)
	v_range (IN) - element solid V range (only used for surfaces)
	acc_mode (IN) -	tolerancing accuracy mode
	accuracy (IN) -	element tolerancing accuracy
	win_cht (IN) - window-based chord height tolerance
	basis_tol (IN) - parametric basis tolerance
	dis_tol (IN) - world-coordinate distance tolerance
	color (IN) - LOGICAL color of element
	options (IN) - element display options
	ele_style (IN) - element style flag
	part_of_solid (IN) - element solid membership flag (only used for surfaces)
	dont_cull (IN) - cull mode flag (only used for surfaces)
	text_buffer (IN) - buffer of text strokes (only used for text)
	coords_returned (IN) - text buffer count (only used for text)
	render_parms (IN) - element rendering parms
	min_x (OUT) - element minimum X in viewing coords (only returned if mode is FIND_ITS_MIN_X)

GLOBALS USED
	active_window - set to point to data for 'pipe_no' and referenced
	tiling_parms.status - set to reflect status of shading operation
	tiling_parms.processing_mode - referenced

HISTORY
	02/15/90    C.M. Jablonski
	   Created.
	09/14/90    S.P. Rogers
	   Moved tolerancing code into the tilers for ease of micro-coding
	05/16/91    R. Druzynski
	   Added code for "new" FEM structure
	o1/15/92    S.P. Rogers
	   Changed IGRFE case to use alloca instead of malloc
	01/23/92	M. Lanier
		Added code in the IGRBC case, that process manual soo's for
		RHL and LVHL display.
        07/22/93   J D Underwood
                Added call to set cull mode to cull none.  Fem had tiles that
                were being culled and only solids should be culled.  Will make
                call in beginning and solids that should be changed will change
                in their code.		
*/
	{
	struct IGRbsp_surface	*srf;
	struct IGRbsp_curve	*curve;
	struct IGResfct		*fem;
	struct IGRpointset	*ptset;
	IGRint			num_upoints, num_vpoints;
	IGRdouble		*upoints = NULL;
	IGRdouble		*vpoints = NULL;
	IGRint			index;
	IGRdouble		quads;
	IGRint			i, j, k;

	HSactivate_window( pipe_no );
	if (tiling_parms.status != HSSTAT_OK) goto wrapup;

        if ( ! ( tiling_parms.processing_mode & HS_PMODE_FEEDBACK ) )
        {
           /* enable bit planes for drawing */
           WLset_drawing_mode( active_window->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );
        }

        /*** set culling flag to default of culling off ***/
        HSset_element_cull_flag( HS_CULL_NONE  );

	/* send the object to the appropriate tiler */
	switch( type )
		{
		case IGRPY:
			HSpline_tiler(	pipe_no,
					geometry,
					color,
					options,
					TRUE,
					clip_range );
			break;

		case IGRBC:
			curve = (struct IGRbsp_curve *)geometry;

			/*
			 *  If there are no manual soo's send the entire curve
			 *  without boundaries
			 */

			if( HSlvhl.p_count > 0 )
				{
				/*
				 *  Allocate memory for the soo boundary buffer.  put all
				 *  soo boundary points in the buffer and send to the
				 *  tiler to plot the original curve with the boundary
				 *  spans out.
				 */

				if( HSlvhl.p_count > boundary_size )
					{
					if( boundary != NULL ) free( boundary );
					boundary = (double *)malloc( sizeof( double ) * ((2 * HSlvhl.p_count) + 2) );
					boundary_size = HSlvhl.p_count;
					}
					
				if( !(HSlvhl.p_parms[0] == 0.0 &&
				      HSlvhl.p_parms[1] == 1.0) )
					{

					/*
					 *  Build a boundary that turns off only the soo regions
					 *  of the curve.
					 */

					for( i=0, j=0, k=0; i<HSlvhl.p_count; i++ )
						{
						boundary[j++] = HSlvhl.p_parms[k++];
						boundary[j++] = HSlvhl.p_parms[k++];
						}

					curve->num_boundaries = HSlvhl.p_count;
					curve->bdrys = boundary;

#					if DEBUG
						fprintf( stderr, "original\n" );
						for( i=0, j=0; i<curve->num_boundaries; i++, j+=2 )
							fprintf( stderr, "%3d %f %f\n", i, boundary[j], boundary[j+1] );
#					endif

					HSbcurve_tiler(	pipe_no,
							geometry,
							color,
							options,
							TRUE,
							acc_mode,
							accuracy,
							win_cht,
							clip_range );
					}

				/*
				 *  If we are doing LVHL, then the soo spans dont have
				 *  to be sent to the tiler.
				 */

				if( tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES ||
				    tiling_parms.processing_mode & HS_PMODE_LVHL_SURFACE )
					{

					/*
					 *  If we are outputting curves, create curves
					 *  for each soo span
					 */

					if( !HSlvhl.output_soos )
						{
						for( i=0, j=0; i<HSlvhl.p_count; i++, j += 2 )
							{

							/*
							 *  If the soo is DE_HIDDEN, place it on the
							 *  hidden layer, if it is DE_INVIS, ignore it
							 *  else place it on the visible layer
							 */

							if( HSlvhl.p_types[i] & DE_HIDDEN )
								HSlvhl_create_curve( geometry,
										     HSlvhl.p_parms[j], HSlvhl.p_parms[j+1],
										     HSlvhl.p_attr[i].color,
										     HSlvhl.p_attr[i].weight,
										     HSlvhl.p_attr[i].style,
										     HSlvhl.hidden_layer );

							else if( !(HSlvhl.p_types[i] & DE_INVIS) )
								HSlvhl_create_curve( geometry,
										     HSlvhl.p_parms[j], HSlvhl.p_parms[j+1],
										     HSlvhl.p_attr[i].color,
										     HSlvhl.p_attr[i].weight,
										     HSlvhl.p_attr[i].style,
										     HSlvhl.visible_layer );
							}
						}
					}
				else
					{
					for( i=0, k=0; i<HSlvhl.p_count; i++ )
						{

						j = 0;
						curve->num_boundaries = 0;

						/*
						 *  If the soo does not start at the startpoint 
						 *  of the curve place a boundary from the 
						 *  startpoint of the curve to the start of the 
						 *  soo.
						 */

						if( HSlvhl.p_parms[k] != 0.0 )
							{
							boundary[j++] = 0.0;
							boundary[j++] = HSlvhl.p_parms[k++];
							curve->num_boundaries++;
							}
						else
							k++;

						/*
						 *  If the soo does not end at the end point of 
						 *  the curve, place a boundary from the end
						 *  of the soo to the endpoint of the curve
						 */

						if( HSlvhl.p_parms[k] != 1.0 )
							{
							boundary[j++] = HSlvhl.p_parms[k++];
							boundary[j++] = 1.0;
							curve->num_boundaries++;
							}
						else
							k++;

						/*
						 *  Plot the curve with the ith soo's attributes,
						 *  if there is at least one boundary.
						 *
						 *  If the soo is DE_INVIS and it's color is 0xffff, which
						 *  I assume to mean the invisible soo is off, don't call
						 *  the tiler.  This will leave a hole in the curve, which
						 *  is what we want.
						 */

						if( !(HSlvhl.p_types[i] & DE_INVIS && HSlvhl.p_attr[i].color == 0xffff) )
						if( tiling_parms.processing_mode & HS_PMODE_DISPLAY_HIDDEN_LINES || !(HSlvhl.p_types[i] & DE_HIDDEN) )
						{
							element_parms.hidden_color = HSlvhl.p_attr[i].color;
	
							/*tiling_parms.processing_mode |=  HS_PMODE_DONT_ZBUFFER;*/

#							if DEBUG
							fprintf( stderr, "soo #%1d\n", i );
							for( l=0, j=0; l<curve->num_boundaries; l++, j+=2 )
								fprintf( stderr, "%3d %f %f\n", l, boundary[j], boundary[j+1] );
#							endif

							HSset_element_weights( HSlvhl.p_attr[i].weight, HSlvhl.p_attr[i].weight );
							HSset_line_style( HSlvhl.p_attr[i].style, HSlvhl.p_attr[i].style );

							HSbcurve_tiler(	pipe_no,
									geometry,
									HSlvhl.p_attr[i].color,
	 								options,
									TRUE,
									acc_mode,
									accuracy,
									win_cht,
									clip_range );

							/*tiling_parms.processing_mode &= ~HS_PMODE_DONT_ZBUFFER;*/
							}
						}
					}
				}
			else
				{
				curve->num_boundaries = 0;
				curve->bdrys = NULL;

				HSbcurve_tiler(	pipe_no,
						geometry,
						color,
						options,
						TRUE,
						acc_mode,
						accuracy,
						win_cht,
						clip_range );
				}
			break;

		case IGRBS:
			if (mode == SHADE_IT)
				{
				HSbsurf_tiler(	pipe_no,
						geometry,
						range,
						color,
						options,
						ele_style,
						render_parms,
						part_of_solid,
						win_cht * active_window->wv_scale,
						basis_tol,
						dis_tol,
						dont_cull,
						acc_mode,
						accuracy,
						win_cht,
						u_range,
						v_range,
						clip_range );
				}
			else if (mode == RENDER_IT)
				{
				HSrender_tiler(	pipe_no,
						geometry,
						range,
						part_of_solid,
						win_cht * active_window->wv_scale,
						basis_tol,
						dis_tol,
						render_parms,
						dont_cull,
						acc_mode,
						accuracy,
						win_cht,
						u_range,
						v_range,
						clip_range );
				}
			else if (mode == FIND_ITS_MIN_X)
				{
				*min_x = HSget_minimum_x(
						pipe_no,
						geometry,
						range,
						part_of_solid,
						win_cht * active_window->wv_scale,
						basis_tol,
						render_parms,
						acc_mode,
						accuracy,
						win_cht,
						u_range, v_range,
						clip_range );
				}
			break;

		case IGRPS:
			ptset = (struct IGRpointset *)geometry;
			HSpoint_tiler(	pipe_no,
					ptset->num_points,
					ptset->points,
					color,
					options,
					range,
					clip_range,
					FALSE );
			break;

		case IGRLB:
			HStext_tiler( 	pipe_no,
					coords_returned,
					text_buffer,
					color,
					options,
					clip_range );
			break;

		case IGRFE:

			/*
			 * Create mesh of sampling points, then tile it.
			 */

			if ( !(active_window->type & (HShardware_LB_HSURF_ROP | HShardware_LB_HSURF)))
                        {
                           /* only supported with our software code not opengl eg etc; */
			   break;
                        }

			srf = (struct IGRbsp_surface *)geometry;
			fem = (struct IGResfct *)ele_spec_att;
			num_upoints = num_vpoints = fem->n_mid + 2;
			upoints = (IGRdouble *)alloca(num_upoints * sizeof(IGRdouble));
			vpoints = (IGRdouble *)alloca(num_upoints * sizeof(IGRdouble));

			if ((upoints) && (vpoints))
				{
				quads = (IGRdouble)(fem->n_mid + 1);
				for (index = 0; index < num_upoints; index++)
					upoints[index] = vpoints[index] = (IGRdouble)index / quads;

				/* If we're in delete mode, AREA_FILL tiler is used */
				HSset_element_rendering_parms( render_parms );

				HSfem_tiler(	pipe_no,
						srf,
						num_upoints, num_vpoints,
						upoints, vpoints,
						range,
						color,
						options,
						win_cht * active_window->wv_scale,
						fem,
						clip_range );
				}
			else
				HSset_status( HSSTAT_ALLOC_ERROR );
			break;

		case IGRFM:

			/*
			 * Take given mesh and tile it.
			 */

			HSfem_tilerII(	pipe_no,
					(struct HSfem_tri_mesh *)ele_spec_att,
					clip_range,
					color,
					options,
					win_cht * active_window->wv_scale );
			break;
		}
wrapup:;
        HSreset_element_parms();

	}
