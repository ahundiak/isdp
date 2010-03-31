/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $

HISTORY

        Sudha   07/27/93        Modified for BSprototypes ansification
*/

#define DEBUG_C		0

#include <stdio.h>
#include <stdlib.h>

#if defined( ENV5 )
#include <gpipe.h>
#endif

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "dpstruct.h"

#include "bstypes.h"
#include "bscvarreval.h"

#include "hsdef.h"
#include "hstiler.h"
#include "hslight.h"
#include "hsmacdef.h"
#include "hsmath.h"
#include "hsvhl.h"
#include "hsdisplay.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*------------------------------
 *  for functions 
 *     HSclose_old_line
 *     HScreate_2nd_order_curve
 *     HScreate_pline
 *     HSpaint
 */
 
#include "HSpr_display.h"

/*------------------------------
 *  for functions
 *     HSsave_edgeII_polyline
 *     HSsave_surface
 */
 
#include "HSpr_driver.h"

#ifdef	TRUE
#undef	TRUE
#endif
#ifdef	FALSE
#undef	FALSE
#endif
#define	FALSE			0
#define	TRUE			~FALSE

#define	KNOT_TOL		0.0000000005	/* tolerances for find_sharp_knots  */
					    	/* and compute_knots                */

/* Defines for stack space memory allocation.  The   */
/* values for these defines were EMPIRICALLY derived */
/* from allocation data obtained by shading several  */
/* test files.  It is hoped that the space will be   */
/* sufficient for the majority of curves and thus    */
/* reduce the number of calls we make to malloc().   */
#define CV_POINTS_SPACE		200	/* doubles */
#define SEGMENT_STARTS_SPACE	52	/* ints */
#define VISIBLE_PTS_SPACE	50	/* doubles */

/* The following macro is used to get memory when space has been     */
/* reserved on the stack that will handle the majority of the cases. */
/* The parameters are:                                               */
/*                                                                   */
/*   need - the number of elements needed                            */
/*   have - the number of elements in the stack space                */
/*   bytes_per - number of bytes per element                         */
/*   addr - address of the beginning of the stack space              */
/*                                                                   */
/* If enough space is available in the stack, a pointer to it is     */
/* returned, otherwise malloc is called to get the required space.   */
/* The caller is responsible for freeing malloced space.  The caller */
/* should free if the address that is returned is not equal to       */
/* 'addr' that is passed in.                                         */
#define GET_MEMORY( need, have, bytes_per, addr )      \
 	                                               \
	(((need) > (have)) ?                           \
	    (char *) malloc( (need) * (bytes_per) ) :  \
	    (char *) (addr));                          \


extern double			curr_u;
extern char			curve_visibility;
extern struct	HSedge_header	*curr_edge;

#ifdef RUN_X
        extern  Display *EXdisplay;
        extern  GC      EXgc[];
        extern  int     EX_scr[];
#endif


/*---HSsort_curve_boundaries---------------------------------------------*/

static void HSsort_curve_boundaries( IGRint num_bounds, 
				  IGRdouble *bounds )

	{
	register IGRint	i, j;
	IGRdouble	temp;

	num_bounds *= 2;

	for( i=0; i<(num_bounds - 2); i += 2 )
		for( j=(i + 2); j<num_bounds; j += 2 )
			if( bounds[i] > bounds[j] )
				{
				temp = bounds[i];  
				bounds[i] = bounds[j];  
				bounds[j] = temp;
				
				temp = bounds[i + 1];
				bounds[i + 1] = bounds[j + 1];
				bounds[j + 1] = temp;
				}
	}
	

/*---impose_boundaries-----------------------------------------------------*/

static void HSimpose_curve_boundaries( IGRint num_bounds, 
				    IGRdouble *bounds, 
				    IGRdouble *param_points,
			   register IGRdouble *newpoints, 
				       IGRint *num_segs, 
				       IGRint *seg_starts )

	{
	IGRint			newpoints_index;
	IGRint			*seg_start_ptr;
	register IGRdouble	*current_param_ptr;
	IGRdouble		start_param=0;
	IGRdouble		end_param;
	IGRint			bndnum;

	*num_segs = 0;
	newpoints_index = 0;
	current_param_ptr = param_points;
	seg_start_ptr = seg_starts;

	/*
	 * First visible segment starts at end of first boundary
	 * (if 1st boundary starts at 0) or U = 0.0.
	 */

	if( bounds[0] < KNOT_TOL )
		bndnum = 2;
	else
		{
		bndnum = 0;
		start_param = 0.0;
		}

	while( bndnum < (2 * num_bounds) )
		{ 
		if( bndnum != 0 )
			start_param = bounds[bndnum - 1];	/* end of prev bound	*/

		(*num_segs)++;
		
		*seg_start_ptr++ = newpoints_index;

		while( *current_param_ptr <= (start_param + KNOT_TOL) )
			current_param_ptr++;
			
		newpoints[newpoints_index++] = start_param;
		end_param = bounds[bndnum];		/* start of this bound	*/
		
		while( *current_param_ptr < (end_param - KNOT_TOL) )
			newpoints[newpoints_index++] = *current_param_ptr++;
			
		newpoints[newpoints_index++] = end_param;

		bndnum += 2;
		}

	/*
	 * Create segment ending at U = 1.0 if no boundary includes 1.0
	 */

	start_param = bounds[2 * num_bounds - 1];
	
	if( start_param < (1.0 - KNOT_TOL) )
		{
		(*num_segs)++;
		*seg_start_ptr++ = newpoints_index;

		while( *current_param_ptr <= (start_param + KNOT_TOL) )
			current_param_ptr++;
			
		newpoints[newpoints_index++] = start_param;
		
		while( *current_param_ptr < (1.0 - KNOT_TOL) )
			newpoints[newpoints_index++] = *current_param_ptr++;
			
		newpoints[newpoints_index++] = 1.0;
		}

	*seg_start_ptr = newpoints_index;
	return;
	}

/*---HSgenerate_curve_lines-------------------------------------------*/

static void HSgenerate_curve_lines( IGRint num_points, 
				  IGRpoint cvpoints[] )

	{
	IGRint		cnt;
	IGRdouble	*w;

	w = cvpoints[num_points];
	
	for( cnt=0; cnt<num_points; cnt++ ) {
		if (active_window->type & HShardware_LB_EG)
			HSadd_tri_vertex(	cvpoints[cnt][0], 
						cvpoints[cnt][1],
						cvpoints[cnt][2], 
						w[cnt],
						FALSE,
						0.0,
						0.0,
						0.0,
						0.0,
						0.0 );
		else
			add_vertex_to_loop(	cvpoints[cnt][0], 
						cvpoints[cnt][1],
						cvpoints[cnt][2], 
						w[cnt],
						FALSE,
						0.0,
						0.0,
						0.0,
						0.0,
						0.0 );
	}

	(*active_window->prepare_facet[active_window->active_zbuffer])();
	}


#if DEBUG_C
/*---HSdump_pline--------------------------------------------------------*/

static void	HSdump_pline( pline )

struct IGRpolyline	*pline;

	{
	int	i, j;
	
	fprintf( stderr, "\n\nPline Definition:\n" );

	for( i=0, j=0; i<pline->num_points; i++, j += 3 )
		fprintf( stderr, "   %3d %17.8lf %17.8lf %17.8lf\n",
			i, pline->points[j], pline->points[j+1], pline->points[j+2] );
			
	fprintf( stderr, "\n\n" );
	}
	
/*---HSdump_curve--------------------------------------------------------*/

static void	HSdump_curve( curve )

struct IGRbsp_curve	*curve;

	{
	IGRint	ui, index;

	fprintf( stderr, "\n\nCurve Definition:\n");
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


/*---HSset_curve_parms-----------------------------------------------------*/

static void HSset_curve_parms( IGRint color, 
			       IGRint options, 
			   IGRboolean paint)

	{
	/* Set active tiling parameters. */
	HSset_element_facet_type( POLYLINE );

	/* Initialize paint routine. */
	if( paint && !(tiling_parms.processing_mode & HS_PMODE_FEEDBACK) ) 
		(*active_window->init_paint[active_window->active_zbuffer])( &color, &options );
	}


/*---HScurve_tiler-----------------------------------------------------------*/

static void HScurve_tiler( struct IGRbsp_curve *curve, 
					IGRint num_points, 
				     IGRdouble *points, 
				    IGRboolean paint )

	{
	IGRlong		rc;			 /* return code	*/
	IGRpoint	*cvpoints = NULL,	 /* array of curve points */
			st_cvpoints[CV_POINTS_SPACE];
	IGRdouble	*visible_points = NULL,	 /* U points not inside a boundary  */
			st_visible_points[VISIBLE_PTS_SPACE];
	IGRint		num_segments;
	IGRint		segnum;
	IGRint	 	*segment_starts = NULL,
			st_segment_starts[SEGMENT_STARTS_SPACE];
	IGRint	 	this_seg_start;
	IGRdouble	*curve_weights;
	IGRboolean	free_vis_pts = FALSE;
	

 

	/*
	 * This is to circumvent a bug in BScvarreval and BScveval0 where 
	 * non-rational curves are assumed to have weights = 0.
	 */

	curve_weights = curve->weights;
	
	if( !(curve->rational) ) curve->weights = NULL;

#	if DEBUG_C
	HSdump_curve( curve );
#	endif

	segment_starts = (IGRint *) GET_MEMORY( (curve->num_boundaries + 2), SEGMENT_STARTS_SPACE,
						sizeof(IGRint), st_segment_starts );
	
	if( !segment_starts )
		{
		HSset_status( HSSTAT_ALLOC_ERROR );
		}
	else
		{

		/*
		 * Allocate cvpoints (to hold points & w's, in that order)
		 */

		cvpoints = (IGRpoint *) GET_MEMORY( (num_points*4), CV_POINTS_SPACE,
						    sizeof(IGRdouble), st_cvpoints );
						    
		if( !cvpoints )
			{
			HSset_status( HSSTAT_ALLOC_ERROR );
			goto wrapup;
			}

#		if DEBUG_C
			{
			IGRint		index;

			fprintf( stderr, "\nList of grid points:\n" );
		
			for( index=0; index<num_points; index++ )
				fprintf( stderr, "%17.9lf \n", points[index] );
			}
#		endif

		/*
		 * Add boundary points to the 'points' array & also remove 
		 * parameters which are invisible (i.e. within a boundary)
		 */

		if( curve->num_boundaries == 0 )
			{
			visible_points = points;
			num_segments = 1;
			segment_starts[0] = 0;
			segment_starts[1] = num_points; 
			}
		else
			{
			HSsort_curve_boundaries(  curve->num_boundaries,
	   					  curve->bdrys  );

			free_vis_pts = TRUE;
			visible_points = (IGRdouble *) GET_MEMORY( (num_points + (2 * curve->num_boundaries)),
								   VISIBLE_PTS_SPACE,
								   sizeof(IGRdouble),
								   st_visible_points );

			if( !visible_points )
				{
				HSset_status( HSSTAT_ALLOC_ERROR );
				goto wrapup;
				}
			else
				HSimpose_curve_boundaries(
					curve->num_boundaries,
					curve->bdrys,
					points,
					visible_points,
					&num_segments,
					segment_starts );

#			if DEBUG_C
				{
				int b;

				fprintf( stderr, "\nVisible points:\n" );

				for( b=0; b<segment_starts[num_segments]; b++ )
					fprintf( stderr, "\n%17.9lf", visible_points[b] );

				fprintf( stderr, "\n" );
				fprintf( stderr, "\nSegments:\n" );
	
				for( b=0; b<=num_segments; b++ )
				fprintf( stderr, "\n%13d", segment_starts[b] );
			
				fprintf( stderr, "\n" );
				}
#			endif
			}

		/*
		 * For each visible segment of parameters, get their corresponding
		 * curve coordinates and generate line strings.
		 */

		for( segnum=0; segnum<num_segments; segnum++ )
			{
			this_seg_start = segment_starts[segnum];
			num_points = segment_starts[segnum + 1] - this_seg_start;

			BScvarreval(	&rc, 
					curve, 
					visible_points + this_seg_start,
					num_points, 
					0, 
					(IGRdouble *)cvpoints);

			if( rc != 0 )
				{
				HSset_status( rc );
				goto wrapup;
				}

#			if DEBUG_C
				{
				int	b;
				
				fprintf( stderr, "\nafter call ...\n" );
				
				for( b=0; b<num_points; b++ )
					fprintf( stderr, "\n(%lf, %lf, %lf)",
						cvpoints[b][0], cvpoints[b][1],cvpoints[b][2] );
					
				fprintf( stderr, "\n" );
				}
#			endif
                        
			/*
			 * Create the 2nd order LVHL curve.
			 */
                         
				if( tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES )
					HScreate_2nd_order_curve( 
						num_points, 
						cvpoints, 
						curve, 
						visible_points[this_seg_start],
						visible_points[this_seg_start+num_points-1] );

			/*
			 * Create polygons out of array of curve points.
			 */

			if ( active_window->making_triangles )
				{
#if defined( ENV5 )
				HSsend_polyline_to_EG( num_points, cvpoints );
#elif defined( OPENGL )
				HSsend_polyline_to_OPENGL( num_points, cvpoints );
#elif defined( XGL )
				HSsend_polyline_to_XGL( num_points, cvpoints );
#endif
				}
			else
				{
				transform_points( active_window->perspective,
						  num_points, 
						  (IGRdouble *)cvpoints, 
						  num_points );
				
				HSgenerate_curve_lines( num_points, cvpoints );
				}

			if( tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES )
				HSclose_old_line();
			}
		}


	if (paint && !(tiling_parms.processing_mode & HS_PMODE_FEEDBACK)) HSpaint( 0 );

wrapup:
	/* 
	 * Deallocate memory used
	 */

	if ( (free_vis_pts) && (visible_points) && (visible_points != st_visible_points) )
		free( (char *)visible_points );
	if ( (segment_starts) && (segment_starts != st_segment_starts) )
		free( (char *)segment_starts );
	if ( (cvpoints) && (cvpoints != st_cvpoints) )
		free( (char *)cvpoints );

	/*
	 * This is to circumvent a bug in BScvarreval and BScveval0 where they
	 * assume non-rational curves have weights = 0.
	 */

	curve->weights = curve_weights;
	}


/*---HSbcurve_tiler--------------------------------------------------------*/

/*
NAME
   HSbcurve_tiler
   
KEYWORD
   Tiler
   Curve
   Bspline Curve
   Nurb Curve
   
DESCRIPTION
   TILER entrypoint for bspline curve objects.
   
ARGUMENTS
   pipe_no: (IN):
   curve: (IN):
   color: (IN):
   options: (IN):
   paint: (IN):
   acc_mode: (IN):
   accuracy: (IN):
   win_cht: (IN):
   clip_range: (IN): 
   
HISTORY
   ??/??/??      S. Rapa, M. Lanier
      Created
*/

void HSbcurve_tiler( IGRint pipe_no,
        struct IGRbsp_curve *curve,
                     IGRint color,
                     IGRint options,
                 IGRboolean paint,
                     IGRint acc_mode,
                     IGRint accuracy,
                  IGRdouble win_cht,
                  IGRdouble *clip_range )

   {
#  if defined( ENV5 )
   int         attributeIndex[10];
   GPattribute attributeBundle[10];
   int         bundleSize;
   IGRboolean  use_ASAP1;
   IGRint      status, index;
   IGRint      nsharp;
   IGRint      vlt_index;
   WLcolorref  color_ref;
#  endif

   IGRint      num_upoints;
   IGRdouble   *upoints = NULL;		 /* array of parametric points	*/

	
   HSactivate_window( pipe_no );
   if (tiling_parms.status != HSSTAT_OK) goto wrapup;

		
#  if defined( ENV5 )
   use_ASAP1 = ( (active_window->type & HShardware_LB_GPIPE) &&
                 !(tiling_parms.processing_mode & HS_PMODE_FEEDBACK) &&
                 !(tiling_parms.processing_mode & HS_PMODE_DEXEL) &&
                 !(options & HS_BST_DELETE) );
#  endif

   if( clip_range != NULL )
      HSset_ele_clip_range( clip_range );

#  if defined( ENV5 )
   if( !use_ASAP1 )
#  endif
   HSset_curve_parms( color, options, paint );
			
   /* tolerance the curve */
   
   if( acc_mode != HS_ACCURACY_MODE_WINDOW )
      {
      add_pts_between_knots(
            curve->order,
            curve->num_poles + curve->order,
            curve->knots,
            accuracy,
            &num_upoints,
            &upoints );

      if( tiling_parms.status != HSSTAT_OK ) goto wrapup;
      }
   else
      {
      get_curve_sampling_points(
            curve,
            win_cht,
            &num_upoints,
            &upoints );

      if (tiling_parms.status != HSSTAT_OK) goto wrapup;
      }

#  if defined( ENV5 )
   if( use_ASAP1 )
      {
      nsharp = 0;
      for( index = curve->order; index <= curve->num_poles; index++ )
         {
         if( FABS( curve->knots[index] - curve->knots[index - 1] ) > KNOT_TOL )
            {
            nsharp++;
            }
         }

      accuracy = ((num_upoints - 1)/nsharp) - 1;
	
      GPBsplineTol(
            active_window->gpipe_id, 
            (double)2.0 / active_window->wv_scale, 
            (double)2.0 );
				
      GPBsplineMaxPnts( active_window->gpipe_id, (accuracy + 2) );

      vlt_index = get_color_index( &color );
      WLpack_index_colorref( color, &color_ref, FALSE );
      WLset_active_symbology( active_window->win_no, color_ref, 0, 0xFFFF, 1, WL_SYMB_CHANGE_COLOR );
      WLactivate_symbology( active_window->win_no, FALSE, FALSE );
	
      attributeIndex[0] = 0;
      attributeBundle[0].flags = 0;
      attributeBundle[0].color = vlt_index;
      attributeBundle[0].lstyle = 0;
      attributeBundle[0].wgt = 0;
      attributeBundle[0].blend = 0;
	
      bundleSize = 1;

      status = GPBsplineCurve( 
                     active_window->gpipe_id,
                     curve->order,
                     curve->num_poles,
                     curve->poles,
                     curve->knots,
                     curve->weights,
                     curve->rational,
                     curve->num_boundaries,
                     curve->bdrys,
                     vlt_index,
                     NULL,/*attributeIndex,*/
                     attributeBundle,
                     bundleSize,
                     options );

      if (!status) HSset_status( status );
      if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK)) HSpaint( 0 );

      /*
       *  Reset the MaxPnts for wireframe display
       */
			 
      GPBsplineMaxPnts( active_window->gpipe_id, 100 );
      }
   else
#  endif

   if (!(tiling_parms.processing_mode & HS_PMODE_DEXEL))
      {

      /*
       * If in feedback mode, save the display parameters.
       */

      if (tiling_parms.processing_mode & HS_PMODE_FEEDBACK) 
         HSsave_surface( color, options, 0, NULL );
   
      HScurve_tiler(
            curve,
            num_upoints,
            upoints,
            paint );
      }

wrapup:

   if( upoints ) free( upoints );
   }



/*---HSset_pline_parms-----------------------------------------------------*/

static void HSset_pline_parms( IGRint color, 
			       IGRint options, 
			   IGRboolean paint)

	{
	/* Set active tiling parameters. */
	HSset_element_facet_type( POLYLINE );


	/* Initialize paint routine. */
	if( paint && !(tiling_parms.processing_mode & HS_PMODE_FEEDBACK) ) 
		(*active_window->init_paint[active_window->active_zbuffer])( &color, &options );
	}

/*---HSinternal_pline_tiler-----------------------------------------------------------*/

static void HSinternal_pline_tiler( struct IGRpolyline *pline, 
					    IGRboolean paint)					       

	{
	IGRpoint	*cvpoints = NULL,	 /* array of curve points */
			st_cvpoints[CV_POINTS_SPACE];

#	if DEBUG_C
		{
		IGRint ii;

		fprintf( stderr, "\nList of polyline points:\n" );

		for( ii=0; ii<pline->num_points; ii++ )
			fprintf( stderr, "%17.9lf %17.9lf %17.9lf \n",
				 pline->points[3*ii],
				 pline->points[3*ii+1],
				 pline->points[3*ii+2] );
		}
#	endif


	/*
	 * Create polygons out of array of curve points.
	 */

	if ( active_window->making_triangles )
		{
#if defined( ENV5 )
		HSsend_polyline_to_EG( pline->num_points, (IGRpoint *)pline->points );
#elif defined( OPENGL )
		HSsend_polyline_to_OPENGL( pline->num_points, (IGRpoint *)pline->points );
#elif defined( XGL )
		HSsend_polyline_to_XGL( pline->num_points, (IGRpoint *)pline->points );
#endif
		}
	else
		{
		/*
		 * Allocate cvpoints (to hold points & w's, in that order)
		 */

		cvpoints = (IGRpoint *) GET_MEMORY( (pline->num_points*4), CV_POINTS_SPACE,
						    sizeof(IGRdouble), st_cvpoints ); 

		if( !cvpoints )
			{
			HSset_status( HSSTAT_ALLOC_ERROR );
			goto wrapup;
			}

		/*
		 * Assign values to cvpoints.
		 */

		memcpy( cvpoints, pline->points, (pline->num_points*sizeof(IGRpoint)) );


		transform_points(	active_window->perspective,
					pline->num_points, 
					(IGRdouble *)cvpoints, 
					pline->num_points );
				
		HSgenerate_curve_lines( pline->num_points, cvpoints );

		if ( (cvpoints) && (cvpoints != st_cvpoints) )
			free( (char *)cvpoints );
		}

wrapup:

	if( paint && !(tiling_parms.processing_mode & HS_PMODE_FEEDBACK) ) HSpaint( 0 );

	}

/*---HSpline_tiler--------------------------------------------------------*/

/*
NAME
   HSpline_tiler
   
KEYWORDS
   Polyline
   Tiler
   
DESCRIPTION
   TILER entrypoint for polyline objects
   
ARGUMENTS
   pipe_no: (IN):
   pline: (IN):
   color: (IN):
   options: (IN):
   paint: (IN):
   clip_range: (IN): 
   
HISTORY
   ??/??/?/   S. Rapa, M. Lanier
      Created
*/

void HSpline_tiler( IGRint pipe_no,
        struct IGRpolyline *pline,
                    IGRint color,
                    IGRint options,
                IGRboolean paint,
                 IGRdouble *clip_range )

   {
#  if defined( ENV5 )
   IGRint       status;
   WLcolorref   color_ref;
#  endif

   IGRint      vlt_index = 0;

#  if DEBUG_C
   HSdump_pline( pline );
#  endif

   static IGRboolean making_triangles;

   HSactivate_window( pipe_no );
   if (tiling_parms.status != HSSTAT_OK) goto wrapup;

   if( clip_range != NULL )
      HSset_ele_clip_range( clip_range );

#  if defined( ENV5 )
   if ((active_window->type & HShardware_LB_GPIPE) &&
       !(tiling_parms.processing_mode & HS_PMODE_FEEDBACK) &&
       !(tiling_parms.processing_mode & HS_PMODE_DEXEL) &&
       !(options & HS_BST_DELETE))
      {
      WLpack_index_colorref( color, &color_ref, FALSE );
      WLset_active_symbology( active_window->win_no, color_ref, 0, 0xFFFF, 1, WL_SYMB_CHANGE_COLOR );
      WLactivate_symbology( active_window->win_no, FALSE, FALSE );

      status = GPLinestr3D(
                     active_window->gpipe_id,
                     pline->points,
                     pline->num_points,
                     vlt_index,
                     options);

      if (!status) HSset_status( status );
      if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK)) HSpaint( 0 );
      }
   else
#  endif

   if (!(tiling_parms.processing_mode & HS_PMODE_DEXEL))
      {
      HSset_pline_parms( color, options, paint );
			
      /* If in feedback mode, save the display parameters. */
      
      if (tiling_parms.processing_mode & HS_PMODE_FEEDBACK) 
         HSsave_surface( color, options, 0, NULL );
	   
      if( tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES )
         HScreate_pline( pline );
                        
      /* if on edgeII or XGL, then disable pline through dlist */

#     if defined (ENV5) || defined (XGL)
      making_triangles = active_window->making_triangles;
      active_window->making_triangles = FALSE;
#     endif

      HSinternal_pline_tiler( pline, paint );

#     if defined (ENV5) || defined (XGL)
      active_window->making_triangles = making_triangles;
#     endif
      }
wrapup:;

   if( tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES )
      HSclose_old_line();
   }
