/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES 1
#define DEBUG 0

#include <stdio.h>
#include <bsvalues.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "DIdef.h"
#include "igrdp.h"
#include "igr.h"
#include "gr.h"
#include "dp.h"
#include "dpstruct.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "DEso.h"

#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSsfparms.h"

#include "emsinterdef.h"
#include "emsdef.h"
#include "emsinter.h"
#include "emssfdef.h"
#include "emssfint.h"
#include "ems.h"

#include "hsurferrpriv.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsvhl.h"

#include "hstiler.h"
#include "hslight.h"

#include "HStl_global.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "HSlvhl.h" 

#include "bstypes.h"
#include "bsisfprtlns.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsmalloc.h"

#include "vedef.h"
#include "HSplot_def.h"

#include "EMSasnuc.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"

/* Prototypes */
#include "matypemx.h"
#include "bsxtractpar.h"
#include "bssfpartrg.h"
#include "bsptlnplan.h"
#include "bsprtlngmsf.h"
#include "bspl_cv_int.h"
#include "bsfreecv.h"
#include "bsfndsfcsp.h"
#include "bsconstprcv.h"
#include "bschrdlkts.h"
#include "bschangepar.h"
#include "bsalloccv.h"

#include "HSe2_mesher.h"
#include "HSpr_driver.h"

#include "FI.h"
#include "wl.h"
#include "ve.h"
#include "hskyoptypes.h"
#include "VEpr_utilfnc.h"
#include "hsanimate.h"
#include "HSsara.h"
#include "growner.h"
#include "HSplot.h"
#include "hsdisplay.h"
#include "HSfem_spt.h"
#include "HSpr_tiler_f.h"
#include "HSpr_hplot.h"
#include "HSpr_lvhl.h"
#include "HSpr_co_func.h"
/*#include "EMStpmacros.h"*/

#define	BETTER_CROSS_TOL	1e-3

%safe
extern void EMpypoint_free (struct EMSpypoint *pypts, IGRint num_nodes);

extern int HSis_curve_type_equal_curve( void );

extern IGRint GRdpb_get (IGRint *msg, IGRint parameter,
          IGRint *sizbuf, IGRchar *buffer, IGRint *nret);
	  
/*
 *  Prototype declaration for static functions
 */

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HSgetedges.I */
static void dump_curve __((struct IGRbsp_curve *curve));

struct IGRbsp_curve *HSconstruct_iso_edge __((struct IGRbsp_surface *surf, 
							     IGRint par_option, 
							  IGRdouble parm));
							  
static void HSsort_the_u_list __((IGRdouble *ulist, 
				     IGRint ulist_size));
				     
static void HSadd_clip_points_to_list __((int xy));

static void HStile_edge __((struct IGRbsp_curve *curve, 
					    int options, 
					    int pipe_no, 
					    int color, 
					    int acc_mode, 
					    int accuracy, 
					 double win_cht, 
					 double *clip_range));
					 
static void HSlvhl_trim_polyline __((IGRint *file_id, 
			struct IGRbsp_curve *curve, 
			 struct IGRpolyline *polyline, 
				    GRobjid loopset_id, 
				 GRspacenum loopset_os, 
					int options, 
					int pipe_no, 
					int color, 
					int acc_mode, 
					int accuracy, 
				     double win_cht, 
				     double *clip_range));

static void HSget_sharp_knots __((struct IGRbsp_surface *surf, 
						 IGRint *num_u, 
						 IGRint *num_v, 
					      IGRdouble **sharp_u_knots, 
					      IGRdouble **sharp_v_knots));

static void HScreate_horizon_edges __((IGRint *file_id, 
			struct IGRbsp_surface *surf, 
				    IGRdouble *z_vector, 
				      GRobjid loopset_id, 
				   GRspacenum loopset_os, 
					  int options, 
					  int pipe_no, 
					  int color, 
					  int acc_mode, 
					  int accuracy, 
				       double win_cht, 
				       double *clip_range, 
				   IGRboolean perspective, 
				    IGRdouble *eye_pt));

#if defined(__cplusplus)
}
#endif


#undef __


%endsafe


from EMSboundary	import EMget_edges;
from EMSsubbs		import EMget_graphics_edges;
from EMSedge		import EMget_props, EMget_bcxyz_geom;
from EMSloopset 	import EMlsparttrim;
from EMSsurface		import EMputLsIfNotThere;
from GRvg		import GRgetsymb, GRgenabsg;
from EMSsurface		import EMget_params;

#if DEBUG
/*---dump_curve--------------------------------------------------------*/

static void	dump_curve( curve )

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
	
/*---HSconstruct_iso_edge---------------------------------------------------*/

/*
DESCRIPTION
	This routine generates the curve definition for an isocurve on a 
	surface (i.e., surface edge, sharp edge, or mesh line).

HISTORY
	S.P. Rogers  09/16/87  Creation Date
	M. Lanier    09/31/91  Stole from ve
*/

#if defined(__STDC__) || defined(__cplusplus)
	struct IGRbsp_curve *HSconstruct_iso_edge( struct IGRbsp_surface *surf,
								  IGRint par_option,
							       IGRdouble parm )
#else
	struct IGRbsp_curve	*HSconstruct_iso_edge( surf, par_option, parm )

	struct IGRbsp_surface  *surf;       /* pointer to surface definition                */
	IGRint                 par_option;  /* 1 => constant u curve, 2 => constant v curve */
	IGRdouble              parm;        /* constant parameter                           */
#endif

	{
	IGRlong			rc;
	IGRint			order;
	IGRint			num_poles;
	IGRboolean		tst_planar = TRUE;
	struct IGRbsp_curve	*edge;
	IGRshort		s_par_option;


	if( par_option == CONST_U_POLY )
		{
		order = surf->v_order;
		num_poles = surf->v_num_poles;
		}
	else
		{
		order = surf->u_order;
		num_poles = surf->u_num_poles;
		}

	/* 
	 *  allocate and construct iso-curve definition 
	 */

	BSalloccv( order, num_poles, surf->rational, 0, &edge, &rc );

	BS_ERRCHK( rc, "HSconstruct_iso_edge:  BSalloccv failed" );

	if( rc != BSSUCC )
		{
		edge = NULL;
		return( NULL );
		}

	s_par_option = par_option;
	BSconstprcv( &rc, surf, &s_par_option, &parm, &tst_planar, edge );

	BS_ERRCHK( rc, "HSconstruct_iso_edge:  BSconstprcv failed" );

	if ( rc != BSSUCC )
		{
		BSfreecv( &rc, edge );
		return( NULL );
		}

	edge->bdrys = NULL;

	return( edge );
	}
	     
/*---HSgenerate_natural_edges-----------------------------------------------*/

/*
DESCRIPTION
	Generate the natural edges for a surface

HISTORY
	S.P. Rogers  09/16/87  Creation Date
	M. Lanier    09/31/91  Stole from VE for LVHL
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSgenerate_natural_edges( IGRint *file_id,
			   struct IGRbsp_surface *surf,
			     struct GRmdenv_info *mdenv,
					     int options,
					     int pipe_no,
					     int color,
					     int acc_mode,
					     int accuracy,
					  double win_cht,
					  double *clip_range )
#else
	void	HSgenerate_natural_edges( file_id,
					  surf,
					  mdenv,
					  options,
					  pipe_no,
					  color,
					  acc_mode,
					  accuracy,
					  win_cht,
					  clip_range )

	IGRint			*file_id;
	struct IGRbsp_surface	*surf;
	struct GRmdenv_info	*mdenv;
	int			options;
	int			pipe_no;
	int			color;
	int			acc_mode;
	int			accuracy;
	double			win_cht;
	double			*clip_range;
#endif

	{
	IGRdouble		min_u, max_u, min_v, max_v;
	IGRlong			rc;
	struct IGRbsp_curve	*edge;

	/* 
	 *  set the knot values of the surface edges 
	 */
	 
	min_u = surf->u_knots[ surf->u_order - 1 ];
	max_u = surf->u_knots[ surf->u_num_knots - surf->u_order ];
	min_v = surf->v_knots[ surf->v_order - 1 ];
	max_v = surf->v_knots[ surf->v_num_knots - surf->v_order ];
	
	if( !surf->u_phy_closed )
		{
			
		/* 
		 * generate surface edges in constant u 
		 */
		 
		edge = HSconstruct_iso_edge( surf, CONST_U_POLY, min_u );

		if( file_id == NULL )
			{
			HSbcurve_tiler(
				pipe_no,
				edge,
				color,
				options,
				TRUE,
				acc_mode,
				accuracy,
				win_cht,
				clip_range );
			}
		else
			{
			HPwrite_draw_range(
				file_id,
				NURB_EDGE,
				(int)99,
				NULL );
			
			HPwrite_curve_info(
				file_id,
				edge,
				3,
				NULL );
			}

		BSfreecv( &rc, edge );


		edge = HSconstruct_iso_edge( surf, CONST_U_POLY, max_u );

		if( file_id == NULL )
			{
			HSbcurve_tiler(
				pipe_no,
				edge,
				color,
				options,
				TRUE,
				acc_mode,
				accuracy,
				win_cht,
				clip_range );
			}
		else
			{
			HPwrite_draw_range(
				file_id,
				NURB_EDGE,
				(int)99,
				NULL );
			
			HPwrite_curve_info(
				file_id,
				edge,
				3,
				NULL );
			}

		BSfreecv( &rc, edge );
		}


	if( !surf->v_phy_closed )
		{

		/* 
		 * generate surface edges in constant v 
		 */
		 
		edge = HSconstruct_iso_edge( surf, CONST_V_POLY, min_v );

		if( file_id == NULL )
			{
			HSbcurve_tiler(
				pipe_no,
				edge,
				color,
				options,
				TRUE,
				acc_mode,
				accuracy,
				win_cht,
				clip_range );
			}
		else
			{
			HPwrite_draw_range(
				file_id,
				NURB_EDGE,
				(int)99,
				NULL );
			
			HPwrite_curve_info(
				file_id,
				edge,
				3,
				NULL );			
			}
			
		BSfreecv( &rc, edge );


		edge = HSconstruct_iso_edge( surf, CONST_V_POLY, max_v );

		if( file_id == NULL )
			{
			HSbcurve_tiler(
				pipe_no,
				edge,
				color,
				options,
				TRUE,
				acc_mode,
				accuracy,
				win_cht,
				clip_range );
			}
		else
			{
			HPwrite_draw_range(
				file_id,
				NURB_EDGE,
				(int)99,
				NULL );
			
			HPwrite_curve_info(
				file_id,
				edge,
				3,
				NULL );
			}

		BSfreecv( &rc, edge );
		}
	}

%safe	
static double	*tpoles = NULL, *spoles = NULL;
static double	*int_points = NULL, *int_parms = NULL;
static double	*start_params = NULL, *end_params = NULL;

struct HScurve_clip_memory_info
	{
	IGRint		max_poles;
	IGRdouble	*int_points;
	IGRdouble	*int_params;
	IGRdouble	*start_params;
	IGRdouble	*end_params;
	};
	
static struct HScurve_clip_memory_info	HScurve_clip_memory = { 0, NULL, NULL, NULL, NULL };
%endsafe

/*---HSget_curve_clip_memory ------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_curve_clip_memory( IGRint max_poles,
				   IGRdouble **int_points,
				   IGRdouble **int_params,
				   IGRdouble **start_params,
				   IGRdouble **end_params )
#else
	void HSget_curve_clip_memory( max_poles, int_points, int_params, start_params, end_params )

	IGRint		max_poles;
	IGRdouble	**int_points;
	IGRdouble	**int_params;
	IGRdouble	**start_params;
	IGRdouble	**end_params;
#endif
	
	{
	if( max_poles > HScurve_clip_memory.max_poles )
		{
		if( HScurve_clip_memory.max_poles > 0 )
			{
			free( (IGRchar *) HScurve_clip_memory.int_points );
			free( (IGRchar *) HScurve_clip_memory.int_params );
			free( (IGRchar *) HScurve_clip_memory.start_params );
			free( (IGRchar *) HScurve_clip_memory.end_params );
			}
	      
		HScurve_clip_memory.max_poles    = max_poles;
	   
		HScurve_clip_memory.int_points   = (IGRdouble *)malloc( max_poles * sizeof( IGRpoint ) );
		HScurve_clip_memory.int_params   = (IGRdouble *)malloc( (2 + max_poles) * sizeof( IGRdouble ) );
		HScurve_clip_memory.start_params = (IGRdouble *)malloc( max_poles * sizeof( IGRdouble ) );
		HScurve_clip_memory.end_params   = (IGRdouble *)malloc( max_poles * sizeof( IGRdouble ) );
		}

	*int_points   = HScurve_clip_memory.int_points;
	*int_params   = HScurve_clip_memory.int_params;
	*start_params = HScurve_clip_memory.start_params;
	*end_params   = HScurve_clip_memory.end_params;	
	}  /* HSget_curve_clip_memory */

/*---HSsort_the_u_list------------------------------------*/

static void	HSsort_the_u_list( ulist, ulist_size )

/*
 *  Sort the list of u values in increasing order.
 */
 
IGRdouble	*ulist;
IGRint		ulist_size;

	{
	IGRdouble	*a, *b;
	IGRdouble	t;
	IGRint		swaps, i, ncomps;

	/*
	 *  If the number of entries in the ulist is not more
	 *  than 1, then there is no need to perform a swap.
	 *  Also, the number of iterations in the sort is one 
	 *  less than the size of the list.  
	 */
	 	
	swaps = (ulist_size > 1);
	ncomps = ulist_size - 1;
	
	while( swaps )
		{
		swaps = FALSE;
		a = ulist;
		b = a+1;
		
		for( i=0; i<ncomps; i++ )
			{
				
			/*
			 *  If the current entry is greater than the next, then
			 *  swap then and set the swap flag to true
			 */
			 
			if( *a > *b )
				{
				t = *a;
				*a = *b;
				*b = t;
				swaps = TRUE;
				}
				
			/*
			 *  Move to the next entry
			 */
			 
			a++;
			b++;
			}
		}
	}


static int	num_int, total_int, num_segs_in_plane;

/*---HSadd_clip_points_to_list---------------------------------------------------_*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HSadd_clip_points_to_list( int xy )
#else
	static void	HSadd_clip_points_to_list( xy )

	int	xy;
#endif

	{		
	IGRdouble	*cp, *lp;
	IGRint		i, j;

#	if DEBUG
	fprintf( stderr, "HSadd_clip points_to_list: %d %d\n", num_int, xy );
#	endif

	if( num_int > 0 )
		{

		lp = cp = &int_parms[total_int];
		
		for( i=0, j=0; i<num_int; i++, j+=3 )
			{
#			if DEBUG
			fprintf( stderr, "   %3d: %10.4f %10.4f %10.4f: %10.4f: ",
				i, int_points[j], int_points[j+1], int_points[j+2], int_parms[i+total_int] );
#			endif

			if( int_points[j+xy] >= HSlvhl.clipping_planes[xy  ].point[xy] &&
			    int_points[j+xy] <= HSlvhl.clipping_planes[xy+3].point[xy] )
				{
				*lp++ = *cp;
				total_int++;

#				if DEBUG
				fprintf( stderr, "accepted\n" );
#				endif
				}
			else
				{
#				if DEBUG
				fprintf( stderr, "rejected\n" );
#				endif
				}
				
			cp++;
			}
		}
	}		

/*---HSclip_and_remove_SOs--------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSclip_and_remove_SOs( struct IGRbsp_curve *curve,
						   GRobjid msc_id,
						GRspacenum msc_os,
					   struct GRmd_env *msc_env,
					   struct GRmd_env *master_env )
#else
	void	HSclip_and_remove_SOs( curve,
				 msc_id,
				 msc_os,
		                 msc_env,
				 master_env )

	struct IGRbsp_curve	*curve;
	GRobjid			msc_id;
	GRspacenum		msc_os;
	struct GRmd_env		*msc_env;
	struct GRmd_env		*master_env;
#endif

	{
	int		status;
	int		i, j;
	BSrc		rc;

	tpoles = (double *)malloc( sizeof(double) * curve->num_poles * 3 );
	
	memcpy( tpoles, curve->poles, sizeof(double) * curve->num_poles * 3 );
	
	transform_points( 0, (int)curve->num_poles, tpoles, 0 );

	spoles = curve->poles;
	curve->poles = tpoles;
	
	HSget_curve_clip_memory( (IGRint)curve->num_poles, &int_points, &int_parms, &start_params, &end_params );

	total_int = 0;

	/*
	 *  Check to see if the first point of the curve is in or out.  If
	 *  in put it at the top of the intersection list
	 */

#	if DEBUG
	fprintf( stderr, "clipping_planes: %f %f - %f %f\n",
		HSlvhl.clipping_planes[0].point[0],
		HSlvhl.clipping_planes[1].point[1],
		HSlvhl.clipping_planes[3].point[0],
		HSlvhl.clipping_planes[4].point[1] );
#	endif
	 
	if( curve->poles[0] >= HSlvhl.clipping_planes[0].point[0] &&
	    curve->poles[0] <= HSlvhl.clipping_planes[3].point[0] &&
	    curve->poles[1] >= HSlvhl.clipping_planes[1].point[1] &&
	    curve->poles[1] <= HSlvhl.clipping_planes[4].point[1] )
		{
		int_parms[total_int++] = curve->knots[curve->order-1];
		}
		
	/*
	 *  Get Clip points at xmin
	 */
	 	
	status = BSpl_cv_int(
			&rc,
			curve,
			HSlvhl.clipping_planes[0].point,
			HSlvhl.clipping_planes[0].normal,
			&num_int,
			int_points,
			&int_parms[total_int],
			&num_segs_in_plane,
			start_params,
			end_params );

	HSadd_clip_points_to_list( 1 );
	
	/*
	 *  Get Clip points at ymin
	 */

	status = BSpl_cv_int(
			&rc,
			curve,
			HSlvhl.clipping_planes[1].point,
			HSlvhl.clipping_planes[1].normal,
			&num_int,
			int_points,
			&int_parms[total_int],
			&num_segs_in_plane,
			start_params,
			end_params );

	HSadd_clip_points_to_list( 0 );
	
	/*
	 *  Get Clip points at xmax
	 */
	
	status = BSpl_cv_int(
			&rc,
			curve,
			HSlvhl.clipping_planes[3].point,
			HSlvhl.clipping_planes[3].normal,
			&num_int,
			int_points,
			&int_parms[total_int],
			&num_segs_in_plane,
			start_params,
			end_params );
			

	HSadd_clip_points_to_list( 1 );
	
	/*
	 *  Get Clip points at ymax
	 */
	
	status = BSpl_cv_int(
			&rc,
			curve,
			HSlvhl.clipping_planes[4].point,
			HSlvhl.clipping_planes[4].normal,
			&num_int,
			int_points,
			&int_parms[total_int],
			&num_segs_in_plane,
			start_params,
			end_params );
			
	HSadd_clip_points_to_list( 0 );
	
	j = (curve->num_poles-1) * 3;

	if( curve->poles[j]   >= HSlvhl.clipping_planes[0].point[0] &&
	    curve->poles[j]   <= HSlvhl.clipping_planes[3].point[0] &&
	    curve->poles[j+1] >= HSlvhl.clipping_planes[1].point[1] &&
	    curve->poles[j+1] <= HSlvhl.clipping_planes[4].point[1] )
		{
		int_parms[total_int++] = curve->knots[curve->num_knots-curve->order];
		}
		
	/*
	 *  If there is an intersection sort the list and clip the VEso's
	 */

	if( total_int > 0 )
		{
		HSsort_the_u_list( int_parms, total_int );

		for( i=0; i<total_int; i+=2 )
			{
			HSremove_VEso_on_edge( msc_id,
					       msc_os,
					       tiling_parms.window_id,
					       tiling_parms.window_os,
					       msc_env,
					       master_env,
					       int_parms[i],
					       int_parms[i+1],
					       HSlvhl.delete_user_overrides,
					       FALSE );
			}
		}
			
	curve->poles = spoles;
	free( tpoles );
	}

%safe
static double			*boundary = NULL;
static int			boundary_size = 0;
%endsafe

/*---HStile_edge-----------------------------------------------_*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HStile_edge( struct IGRbsp_curve *curve,
						     int options,
						     int pipe_no,
						     int color,
						     int acc_mode,
						     int accuracy,
						  double win_cht,
						  double *clip_range )
#else
	static void	HStile_edge(
				curve,
				options,
				pipe_no,
				color,
				acc_mode,
				accuracy,
				win_cht,
				clip_range )

	struct IGRbsp_curve	*curve;
	int			options;
	int			pipe_no;
	int			color;
	int			acc_mode;
	int			accuracy;
	double			win_cht;
	double			*clip_range;
#endif

	{
	IGRint	i, j, k;

         if (HSlvhl.p_count > 0)
            {
            	
            /* Allocate memory for the soo boundary buffer.  put all soo
             * boundary points in the buffer and send to the tiler to plot
             * the original curve with the boundary spans out. */

            if (HSlvhl.p_count > boundary_size)
               {
               if (boundary != NULL)
                  free (boundary);
               boundary = (double *) malloc (sizeof (double) * ((2 * HSlvhl.p_count) + 2));
               boundary_size = HSlvhl.p_count;
               }

            if (!(HSlvhl.p_parms[0] == 0.0 &&
                  HSlvhl.p_parms[1] == 1.0))
               {

               /* Build a boundary that turns off only the soo regions of the
                * curve. */

               for (i = 0, j = 0, k = 0; i < HSlvhl.p_count; i++)
                  {
                  boundary[j++] = HSlvhl.p_parms[k++];
                  boundary[j++] = HSlvhl.p_parms[k++];
                  }

               curve->num_boundaries = HSlvhl.p_count;
               curve->bdrys = boundary;

#              if DEBUG
               fprintf (stderr, "original\n");
               for (i = 0, j = 0; i < curve->num_boundaries; i++, j += 2)
                  fprintf (stderr, "%3d %f %f\n", i, boundary[j], boundary[j + 1]);
#              endif

               HSbcurve_tiler (pipe_no,
                               curve,
                               color,
                               options,
                               TRUE,
                               acc_mode,
                               accuracy,
                               win_cht,
                               clip_range);
               }

            /* If we are doing LVHL, then the soo spans dont have to be sent
             * to the tiler. */

            if (tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES ||
                tiling_parms.processing_mode & HS_PMODE_LVHL_SURFACE)
               {

               /* If we are outputting curves, create curves for each soo
                * span */

               if (!HSlvhl.output_soos)
                  {
                  for (i = 0, j = 0; i < HSlvhl.p_count; i++, j += 2)
                     {

                     /* If the soo is DE_HIDDEN, place it on the hidden
                      * layer, if it is DE_INVIS, ignore it else place it on
                      * the visible layer */

                     if (HSlvhl.p_types[i] & DE_HIDDEN)
                        HSlvhl_create_curve (curve,
                                   HSlvhl.p_parms[j], HSlvhl.p_parms[j + 1],
                                             HSlvhl.p_attr[i].color,
                                             HSlvhl.p_attr[i].weight,
                                             HSlvhl.p_attr[i].style,
                                             HSlvhl.hidden_layer);

                     else if (!(HSlvhl.p_types[i] & DE_INVIS))
                        {
                        HSlvhl_create_curve (curve,
                                             HSlvhl.p_parms[j],
                                             HSlvhl.p_parms[j+1],
                                             HSlvhl.p_attr[i].color,
                                             HSlvhl.p_attr[i].weight,
                                             HSlvhl.p_attr[i].style,
                                             HSlvhl.visible_layer);
                        }
                     }
                  }
               }
            else
               {
               for (i = 0, k = 0; i < HSlvhl.p_count; i++)
                  {

                  j = 0;
                  curve->num_boundaries = 0;

                  /* If the soo does not start at the startpoint of the curve
                   * place a boundary from the startpoint of the curve to the
                   * start of the soo. */

                  if (HSlvhl.p_parms[k] != 0.0)
                     {
                     boundary[j++] = 0.0;
                     boundary[j++] = HSlvhl.p_parms[k++];
                     curve->num_boundaries++;
                     }
                  else
                     k++;

                  /* If the soo does not end at the end point of the curve,
                   * place a boundary from the end of the soo to the endpoint
                   * of the curve */

                  if (HSlvhl.p_parms[k] != 1.0)
                     {
                     boundary[j++] = HSlvhl.p_parms[k++];
                     boundary[j++] = 1.0;
                     curve->num_boundaries++;
                     }
                  else
                     k++;

                  /* Plot the curve with the ith soo's attributes, if there
                   * is at least one boundary.
                   * 
                   * If the soo is DE_INVIS and it's color is 0xffff, which I
                   * assume to mean the invisible soo is off, don't call the
                   * tiler.  This will leave a hole in the curve, which is
                   * what we want. */

                  if (!(HSlvhl.p_types[i] & DE_INVIS && HSlvhl.p_attr[i].color == 0xffff))
                     if (tiling_parms.processing_mode & HS_PMODE_DISPLAY_HIDDEN_LINES || !(HSlvhl.p_types[i] & DE_HIDDEN))
                        {
                        element_parms.hidden_color = HSlvhl.p_attr[i].color;

                        /* tiling_parms.processing_mode |=
                         * HS_PMODE_DONT_ZBUFFER; */

#							if DEBUG
                        fprintf (stderr, "soo #%1d\n", i);
                        for (l = 0, j = 0; l < curve->num_boundaries; l++, j += 2)
                           fprintf (stderr, "%3d %f %f\n", l, boundary[j], boundary[j + 1]);
#							endif

                        HSset_element_weights (HSlvhl.p_attr[i].weight, HSlvhl.p_attr[i].weight);
                        HSset_line_style (HSlvhl.p_attr[i].style, HSlvhl.p_attr[i].style);

                        HSbcurve_tiler (pipe_no,
                                        curve,
                                        HSlvhl.p_attr[i].color,
                                        options,
                                        TRUE,
                                        acc_mode,
                                        accuracy,
                                        win_cht,
                                        clip_range);

                        /* tiling_parms.processing_mode &=
                         * ~HS_PMODE_DONT_ZBUFFER; */
                        }
                  }
               }
            }
         else
            {
            curve->num_boundaries = 0;
            curve->bdrys = NULL;

            HSbcurve_tiler (pipe_no,
                            curve,
                            color,
                            options,
                            TRUE,
                            acc_mode,
                            accuracy,
                            win_cht,
                            clip_range);
            }
	
	}

/*---HSprocess_edge---------------------------------------*/

/*
 *  Process the edge of a surface
 */
 
static int HSprocess_edge( IGRint *file_id,
			  GRobjid edge_id,
		       GRspacenum edge_os,
	    struct IGRbsp_surface *surf,
		  struct GRmd_env *master_env,
	      struct GRmdenv_info *mdenv_info,
			      int options,
			      int pipe_no,
			      int color,
			      int acc_mode,
			      int accuracy,
			   double win_cht,
			   double *clip_range,
			      int mode,
		       IGRboolean horizon_curve )

	{
	IGRlong			msg, sts, status;
	unsigned short		props;
	struct IGRbsp_curve	curve, *curve_ptr;
	OM_S_OBJID		msc_id;
	int			i;
	struct GRsymbology	symbology;
	struct GRid 		msc_GRid;
	IGRdouble               knot_value, knot_spacing;

	HSlvhl.p_count = 0;
	HSlvhl.edge_id = edge_id;
	HSlvhl.edge_os = edge_os;
	curve_ptr = NULL;

	msg = EMS_S_Success;
	sts = OM_S_SUCCESS;
	props = 0;

	/*
	 *  Start by getting the edges properties word
	 */

	if ( horizon_curve )
		{
		props = 0;
		}
	else
		{
		sts = om$send( msg = message EMSedge.EMget_props( &msg, &props ),
			  senderid = edge_id,
			  targetos = edge_os,
			  targetid = edge_id );
		  
		OM_ERRCHK( sts, "HSprocess_edge: EMget_props send failed" );
		MSG_ERRCHK( msg, "HSprocess_edge: EMget_props send failed" );
		}

	/*
	 *  Ignore any submoridnate edge
	 */
	 	
	if( !(props & EMED_SUBORDINATE) )
		{
		msg = EMS_S_Success;
		sts = OM_S_SUCCESS;

		/*
		 *  get the geometry of the edge
		 */

		if( !((mode == HS_GET_EDGES_MODE_DELETE_VESO) || 
		      (mode == HS_GET_EDGES_MODE_DUMP_SO)) )
			{
			if ( horizon_curve )
				{
				/* horizon curves are always in the master file */
				/* don't free curve_ptr because it's a pointer to the */
				/* abstract geometry cache                            */
				sts = om$send( msg = message GRvg.GRgenabsg(
									&msg,
									&master_env->md_env.matrix_type,
									master_env->md_env.matrix,
									(IGRchar **) &curve_ptr ),
					  senderid = edge_id,
					  targetos = edge_os,
					  targetid = edge_id );

				OM_ERRCHK( sts, "HSprocess_edge: GRvg.GRgenabsg send failed" );
				MSG_ERRCHK( msg, "HSprocess_edge: GRvg.GRgenabsg send failed" );
	
				if ( ! (1 & sts & msg) )
					return( sts );	/* couldn't get edge geometry */
				}
			else
				{
				curve.poles = NULL;
				curve.weights = NULL;
				curve.knots = NULL;

				sts = om$send( msg = message EMSedge.EMget_bcxyz_geom( 
									&msg,
									&master_env->md_env,
									NULL,
									surf,
									0,
									0x7fffffff,
									FALSE,
									NULL,
									&curve ),
					  senderid = edge_id,
					  targetos = edge_os,
					  targetid = edge_id );

				OM_ERRCHK( sts, "HSprocess_edge: EMget_bcxyz_geom send failed" );
				MSG_ERRCHK( msg, "HSprocess_edge: EMget_bcxyz_geom send failed" );
	
				if ( ! (1 & sts & msg) )
					return( sts );	/* couldn't get edge geometry */

				if ( (curve.order == 2) && (!curve.rational) && (curve.non_uniform) )
					{
					/* make sure all order 2, non-rational curves have */
					/* a uniform knot vector because that is what the  */
					/* model space counterparts will have and we want  */
					/* the curve geometry to match that of the msc     */
					knot_spacing = 1.0 / (curve.num_poles - 1);
					for ( i = 2, knot_value = knot_spacing;
					      i < curve.num_poles;
					      i++, knot_value += knot_spacing )
						{
						curve.knots[i] = knot_value;
						}
	 				}

				curve_ptr = &curve;
				}
			}


		/*
		 *  If the edge has a valid model space counterpart, 
		 *  remove the VEso. Then collect the manual so's
		 */

		HSget_model_space_counterpart( FALSE, edge_id, edge_os, mdenv_info, &msc_id );

		if( msc_id != NULL_OBJID )
			{

			msc_GRid.objid = msc_id;
			msc_GRid.osnum = edge_os;

			/*
			 *  Only remove the existing VEso's if the mode is not Create
			 *  Shaded Plotfile and we are outputting VEso's
			 */
			 
			status = om$send( msg = message GRvg.GRgetsymb( &msg, &symbology ),
				     senderid = NULL_OBJID,
				     targetid = msc_id,
				     targetos = edge_os );

			if( mode == HS_GET_EDGES_MODE_DUMP_SO )
				{
					
				/*
				 *  The "get edges" mode is "dump".  Call function to display
				 *  the so's on the edges
				 */
				 
				HSprocess_soos_on_surface_edge( &msc_GRid,
								&HSlvhl.md_env.md_env.matrix_type,
							 	HSlvhl.md_env.md_env.matrix );
						    				
				return( sts );
				}
			else
				{
				if( mode == HS_GET_EDGES_MODE_LVHL && HSlvhl.output_soos )
					{
						
					/*
					 *  The "get edges" mode is "LVHL" and we're outputting SOs
					 */
					 
					HSclip_and_remove_SOs( curve_ptr,
							       msc_id,
							       edge_os,
							       &HSlvhl.md_env,
							       master_env );
					}
				else if( mode == HS_GET_EDGES_MODE_DELETE_VESO )
					{
						
					/*
					 *  The "get edges" mode is "delete".  Remove all the VEso's
					 *  for the edge.  And since that is all we want to do, 
					 *  return now.
					 */
					 
					HSprocess_soos_on_surface_edge( &msc_GRid,
									&HSlvhl.md_env.md_env.matrix_type,
								 	HSlvhl.md_env.md_env.matrix );

					return( sts );
					}
			 		
				HSget_manual_soos_on_edge( msc_id, 
							   edge_os,
							   mdenv_info->matrix,
							  &mdenv_info->matrix_type,
							  (struct GRmd_env *) &master_env->md_env,
							  &symbology.display_attr );
				}
			}

		/*
		 *  file_id will not be NULL if we are creating a Shaded Plot
		 */

		if( mode & (HS_GET_EDGES_MODE_RHL | HS_GET_EDGES_MODE_LVHL) )
			{
				
			/*
			 *  The "get edges" mode is either "rhl" or "lvhl".  Call the
			 *  tiler to process the edge
			 */
			 
			HStile_edge(
				curve_ptr,
				options,
				pipe_no,
				color,
				acc_mode,
				accuracy,
				win_cht,
				clip_range );
			}

		else
		if( mode == HS_GET_EDGES_MODE_PLOTTING )
			{
				
			/*
			 *  The "get edges" mode is "plotting".  Write the curve
			 *  into the shaded plotfile and then, if there are any, write
			 *  the manual so's also
			 */
			 
			HPwrite_draw_range(
				file_id,
				NURB_EDGE,
				(int)99,
				NULL );
			
			HPwrite_curve_info(
				file_id,
				curve_ptr,
				3,
				(HSlvhl.p_count > 0) );

			if( HSlvhl.p_count > 0 )
				{
				status = HPwrite_curve_soo( 
						file_id, 
						HSlvhl.p_parms,
						HSlvhl.p_attr, 
						HSlvhl.p_count,
                                                HSlvhl.p_types );
 		
				for( i=0; i<HSlvhl.p_count; i++ )
					HPwrite_line_style( file_id, HSlvhl.p_attr[i].style );
				}

			}
		}
		
	if ( curve_ptr == &curve )
		{
		/* free memory allocated by EMget_bcxyz_geom method */
		if ( curve.poles ) free( (IGRchar *) curve.poles );
		if ( curve.knots ) free( (IGRchar *) curve.knots );
		if ( curve.weights ) free( (IGRchar *) curve.weights );
		}
				
	return( sts );
	}
	

/*---HSlvhl_trim_polyline----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSlvhl_trim_polyline( IGRint *file_id,
			     struct IGRbsp_curve *curve,
			      struct IGRpolyline *polyline,
					 GRobjid loopset_id,
				      GRspacenum loopset_os,
					     int options,
					     int pipe_no,
					     int color,
					     int acc_mode,
					     int accuracy,
					  double win_cht,
					  double *clip_range )
#else
	static void	HSlvhl_trim_polyline(
					file_id,
					curve,
					polyline,
					loopset_id,
					loopset_os,
					options,
					pipe_no,
					color,
					acc_mode,
					accuracy,
					win_cht,
					clip_range  )
	
	IGRint			*file_id;
	struct IGRbsp_curve	*curve;
	struct IGRpolyline	*polyline;
	GRobjid			loopset_id;
	GRspacenum		loopset_os;
	int			options;
	int			pipe_no;
	int			color;
	int			acc_mode;
	int			accuracy;
	double			win_cht;
	double			*clip_range;
#endif

	{
	unsigned short        trim_options;
	IGRlong               sts;
	IGRlong               msg;
	IGRint                num_bdrys;
	IGRint                span_num;
	IGRdouble             u0, u1;
	IGRdouble             u_start;
	IGRdouble             u_end;
	IGRdouble             *knots;
	struct EMSdataselect  uv_data;
	struct EMSpypoint     *this_point;
	struct EMSpypoint     *next_point;
	struct EMSpypoint     *bdrys;
	struct EMSpartolbasis partol;
        struct EMSsfintedpar  *int_info;
        struct EMSsfintedpar  *this_info;
	IGRshort              mattyp;
	IGRmatrix             mat;


	/* 
	 * To save time, I'm not calculating the parametric tolerance
	 * used by the trim method.  In the future, a field should be
	 * added to the element header that contains this tolerance
	 * so it will only have to be calculated once.
	 */
	
	mattyp = 2;
	mat[0]  = mat[5]  = mat[10] = mat[15] = 1.0;
	mat[1]  = mat[2]  = mat[3]  = mat[4]  = mat[6]  = mat[7]  = 0.0;
	mat[8]  = mat[9]  = mat[11] = mat[12] = mat[13] = mat[14] = 0.0;
	
	partol.tol      = 1e-8;
	partol.is_valid = TRUE;
	partol.in_world = TRUE;
	partol.mattyp   = &mattyp;
	partol.mat      = mat;

	uv_data.datatype  = EMSdata_poly2d;
	uv_data.data.poly = polyline;


	/* 
	 * have the trimming methods interpret boundaries (edges) as area
	 * i.e., If the polyline that is being trimmed lies on a seam or
	 * boundary, it is treated as being in the area of the surface
	 */
	 
	trim_options = EMS_INTER_BDRYISAREA;

	/* trim the polyline */

	num_bdrys = 0;
        bdrys = NULL;
        int_info = NULL;

	sts = om$send( mode = OM_e_wrt_object,
			msg = message EMSloopset.EMlsparttrim(
							&msg,
							&uv_data,
							&partol,
							trim_options,
							&num_bdrys,
							&bdrys,
							&int_info ),
		   senderid = NULL_OBJID,
		   targetid = loopset_id,
		   targetos = loopset_os );
	
	OM_ERRCHK( sts, "HSlvhl_trim_polyline: EMSloopset.EMlsparttrim send failed" );
	MSG_ERRCHK( msg, "HSlvhl_trim_polyline: EMSsubbs.EMpassloop failed" );


#	if DEBUG
		{
		struct EMSpypoint *temp;

		fprintf( stderr, "\n\n\nTrim info:\n\n" );
		temp = bdrys;
		while( temp != NULL )
			{
			fprintf( stderr, "span_inx, param, u, v: %d %lf %lf %lf\n",
				temp->span_inx, temp->param, temp->point[0], temp->point[1] );

			temp = temp->next;
			}
		}
#	endif
	
	/* 
	 * (num_bdrys == 0) => edge was entirely in a hole region 
	 */
	 
	if( num_bdrys != 0 )
		{
		this_point = bdrys;
        	this_info = int_info;
		while( this_point != NULL && this_point->props != EMS_PYPT_EMPTY )
			{
			next_point = this_point->next;

			/* 
			 * the input polyline is a general polyline so the
			 * edge's clip parameters will have to be interpolated
			 */
					 
			knots = curve->knots;
			span_num = this_point->span_inx;
			u0 = knots[ span_num + 1];
			u1 = knots[ span_num + 2];
			u_start = u0 + (u1 - u0) * this_point->param;
	
			span_num = next_point->span_inx;
			u0 = knots[ span_num + 1];
			u1 = knots[ span_num + 2];
			u_end = u0 + (u1 - u0) * next_point->param;

			/* 
			 * create and initialize edge header for the visible segment 
			 */
			 
			if( u_start == 0.0 && u_end == 1.0 )
				{
				if( file_id == NULL )
					{
					HSbcurve_tiler(
						pipe_no,
						curve,
						color,
						options,
						TRUE,
						acc_mode,
						accuracy,
						win_cht,
						clip_range );
					}
				else
					{
					HPwrite_draw_range(
						file_id,
						NURB_EDGE,
						(int)99,
						NULL );
			
					HPwrite_curve_info(
						file_id,
						curve,
						3,
						NULL );
					}
				}
			else
				{
				HSlvhl_split_and_tile_curve(
					file_id,
					curve,
					u_start, u_end,
					options,
					pipe_no,
					color,
					acc_mode,
					accuracy,
					win_cht,
					clip_range );
				}

			this_point = next_point->next;
			this_info = this_info->next;
			}

		/* free trim info */

		EMpypoint_free( bdrys, NULL );

		EMsfintedpar_free( int_info, NULL );
		}
	}



/*---HSget_sharp_knots----------------------------------------------------------*/

/*
DESCRIPTION
	This function finds the knot values where a surface has cusp lines.
	The memory used to store the sharp knots is obtained from a special
	memory management function and is not supposed to be freed.

HISTORY
	S.P. Rogers  09/18/87  Creation Date
*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HSget_sharp_knots( struct IGRbsp_surface *surf,
							  IGRint *num_u,
							  IGRint *num_v,
						       IGRdouble **sharp_u_knots,
						       IGRdouble **sharp_v_knots )
#else
	static void	HSget_sharp_knots( surf, num_u, num_v, sharp_u_knots, sharp_v_knots )

	struct IGRbsp_surface *surf;
	IGRint                *num_u;
	IGRint                *num_v;
	IGRdouble             **sharp_u_knots;
	IGRdouble             **sharp_v_knots;
#endif

	{
	IGRlong		rc;
	IGRdouble	old_cross_tol;
	IGRint		sharp_u_size;
	IGRint		sharp_v_size;
	IGRdouble	*sharp_u_buffer;
	IGRdouble	*sharp_v_buffer;


	(*num_u) = (*num_v) = 0;

	sharp_u_size = surf->u_num_poles - surf->u_order + 1;
	sharp_v_size = surf->v_num_poles - surf->v_order + 1;

	/* 
	 *  get storage for knots 
	 */
	 
	VEget_sharp_knot_storage( 
			sharp_u_size, 
			sharp_v_size,
			&sharp_u_buffer, 
			&sharp_v_buffer );

	/* 
	 *  change cross_tol to a realistic value, so only 
	 *  true cusps will be found 
	 */
	 
	BSxtractpar( &rc, BSTOLCOLLINVEC, &old_cross_tol );
	BSchangepar( &rc, BSTOLCOLLINVEC, BETTER_CROSS_TOL );
	BSchangepar( &rc, BSTOLSQCOLLINVEC, BETTER_CROSS_TOL * BETTER_CROSS_TOL );
	
	/* 
	 *  find the sharp knots (cusps on surface) 
	 */
	 
	BSfndsfcsp( surf, num_u, sharp_u_buffer, num_v, sharp_v_buffer, &rc );

	BS_ERRCHK( rc, "HSget_sharp_knots: BSfndsfcsp failed" );

	/* 
	 *  restore cross_tol 
	 */
	 
	BSchangepar( &rc, BSTOLCOLLINVEC, old_cross_tol );
	BSchangepar( &rc, BSTOLSQCOLLINVEC, old_cross_tol * old_cross_tol );

	*sharp_u_knots = sharp_u_buffer;
	*sharp_v_knots = sharp_v_buffer;
	}

/*---HScreate_sharp_edges-----------------------------------------*/

/*
DESCRIPTION
	Generate the sharp edges and mesh lines for a surface

HISTORY
	S.P. Rogers  09/15/87  Creation Date
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HScreate_sharp_edges( IGRint *file_id,
		       struct IGRbsp_surface *surf,
				     GRobjid loopset_id,
				  GRspacenum loopset_os,
					 int options,
					 int pipe_no,
					 int color,
					 int acc_mode,
					 int accuracy,
				      double win_cht,
				      double *clip_range )
#else
	void	HScreate_sharp_edges( file_id,
				      surf,
				      loopset_id,
				      loopset_os,
				      options,
				      pipe_no,
				      color,
				      acc_mode,
				      accuracy,
				      win_cht,
				      clip_range )

	IGRint			*file_id;
	struct IGRbsp_surface	*surf;
	GRobjid			loopset_id;
	GRspacenum		loopset_os;
	int			options;
	int			pipe_no;
	int			color;
	int			acc_mode;
	int			accuracy;
	double			win_cht;
	double			*clip_range;
#endif


	{
	IGRint			ii;
	IGRint			num_u_sharp;
	IGRint			num_v_sharp;
	IGRdouble		min_u, max_u, min_v, max_v;
	IGRdouble		parm;
	IGRdouble		*sharp_u_knots;
	IGRdouble		*sharp_v_knots;
	IGRdouble		points[4];

	struct IGRpolyline	polyline;
	struct IGRbsp_curve	*new_edge;

	/* 
	 * set up polyline structure for trimming 2 point polylines 
	 */

	polyline.num_points = 2;
	polyline.points = points;

	/* 
	 *  set the knot values of the surface edges 
	 */

	min_u = surf->u_knots[ surf->u_order - 1 ];
	max_u = surf->u_knots[ surf->u_num_knots - surf->u_order ];
	min_v = surf->v_knots[ surf->v_order - 1 ];
	max_v = surf->v_knots[ surf->v_num_knots - surf->v_order ];
	

	num_u_sharp = 0;
	num_v_sharp = 0;
	
	if( !surf->planar )
		{
		HSget_sharp_knots( 
			surf, 
			&num_u_sharp, 
			&num_v_sharp,
			&sharp_u_knots, 
			&sharp_v_knots );
			
		/* 
		 * look at sharp edges that are constant in u 
		 */
		 
		for( ii=0; ii<num_u_sharp; ii++ )
			{
			parm = sharp_u_knots[ii];
			
			/* 
			 * create edge header for sharp edge 
			 */

			new_edge = HSconstruct_iso_edge( 
						surf, 
						CONST_U_POLY, 
						parm );

			if( new_edge )
				{
				if( surf->num_boundaries > 0 )
					{
						
					/* 
					 * define 2 point polyline for edge 
					 */
					 
					points[0] = parm; points[1] = min_v;
					points[2] = parm; points[3] = max_v;

					polyline.num_points = 2;
					polyline.points = (IGRdouble *)points;
					
					HSlvhl_trim_polyline( 
							file_id,
							new_edge,
							&polyline,
							loopset_id,
							loopset_os,
							options,
							pipe_no,
							color,
							acc_mode,
							accuracy,
							win_cht,
							clip_range  );
					}
				else
					{
					if( file_id == NULL )
						{
						HSbcurve_tiler(
							pipe_no,
							new_edge,
							color,
							options,
							TRUE,
							acc_mode,
							accuracy,
							win_cht,
							clip_range );
						}
					else
						{
						HPwrite_draw_range(
							file_id,
							NURB_EDGE,
							(int)99,
							NULL );
			
						HPwrite_curve_info(
							file_id,
							new_edge,
							3,
							NULL );
						}
					}
				}
			}

		/* 
		 * look at sharp edges that are constant in v 
		 */
		 
		for( ii=0; ii<num_v_sharp; ii++ )
			{
			parm = sharp_v_knots[ii];
			
			/* 
			 * create edge header for sharp edge 
			 */

			new_edge = HSconstruct_iso_edge( 
						surf, 
						CONST_V_POLY, 
						parm );

			if( new_edge )
				{
				if( surf->num_boundaries > 0 )
					{
						
					/* 
					 * define 2 point polyline for edge 
					 */
					 
					points[0] = min_u; points[1] = parm;
					points[2] = max_u; points[3] = parm;

					polyline.num_points = 2;
					polyline.points = (IGRdouble *)points;
					
					HSlvhl_trim_polyline( 
							file_id,
							new_edge,
							&polyline,
							loopset_id,
							loopset_os,
							options,
							pipe_no,
							color,
							acc_mode,
							accuracy,
							win_cht,
							clip_range  );
					}
				else
					{
					if( file_id == NULL )
						{
						HSbcurve_tiler(
							pipe_no,
							new_edge,
							color,
							options,
							TRUE,
							acc_mode,
							accuracy,
							win_cht,
							clip_range );
						}
					else
						{
						HPwrite_draw_range(
							file_id,
							NURB_EDGE,
							(int)99,
							NULL );
				
						HPwrite_curve_info(
							file_id,
							new_edge,
							3,
							NULL );
						}
					}
				}
			}
		}
	}

/*---HScreate_horizon_edges-----------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HScreate_horizon_edges( IGRint *file_id,
			     struct IGRbsp_surface *surf,
					 IGRdouble *z_vector,
					   GRobjid loopset_id,
					GRspacenum loopset_os,
					       int options,
					       int pipe_no,
					       int color,
					       int acc_mode,
					       int accuracy,
					    double win_cht,
					    double *clip_range,
					IGRboolean perspective,
					 IGRdouble *eye_pt )
#else
	static void	HScreate_horizon_edges( 
					file_id,
					surf,
					z_vector,
					loopset_id,
					loopset_os,
					options,
					pipe_no,
					color,
					acc_mode,
					accuracy,
					win_cht,
					clip_range,
					perspective,
					eye_pt )
	
	IGRint			*file_id;
	struct IGRbsp_surface	*surf;
	IGRdouble		*z_vector;
	GRobjid			loopset_id;
	GRspacenum		loopset_os;
	int			options;
	int			pipe_no;
	int			color;
	int			acc_mode;
	int			accuracy;
	double			win_cht;
	double			*clip_range;
	IGRboolean		perspective;
	IGRdouble		*eye_pt;
#endif

	{
	BSrc			rc;
	IGRdouble		u_range[2], v_range[2];
	IGRdouble		normal[3];
	IGRint			num_groups, i;
	IGRint			code;
	struct BSpartgrp	*groups;
	struct BSpartgrp	*temp_group;
	struct IGRbsp_curve	curve;
	struct IGRpolyline	polyline;

	IGRshort	cvscode;
	IGRint		*numint;
	IGRint		*num_pts;
	IGRpoint	**pts;
	BSpair		**uvpars;
	struct BSgeom_bsp_surf	BSsurf;
	struct BSgeom_bsp_curve	*xyz_cvs;
	struct BSgeom_bsp_curve	*uv_cvs;

	u_range[0] = surf->u_knots[ surf->u_order - 1 ];
	u_range[1] = surf->u_knots[ surf->u_num_knots - surf->u_order ];
	v_range[0] = surf->v_knots[ surf->v_order - 1 ];
	v_range[1] = surf->v_knots[ surf->v_num_knots - surf->v_order ];

	num_groups = 0;

	/* 
	 * find the parting lines for this surface 
	 */

	if( perspective )
		{
		BSsurf.bounded = TRUE;
		BSsurf.urange[0] = 0.0;
		BSsurf.urange[1] = 1.0;
		BSsurf.vrange[0] = 0.0;
		BSsurf.vrange[1] = 1.0;
                BSsurf.type =  BSGEN_BSP_SF;	
		BSsurf.bspsf = surf;

		cvscode = 0;	  /* Since cvscode =0 no xyz_cvs or uv_cvs are 
                                    allocated or returned                   */
		numint = NULL;
		num_pts = NULL;
		pts = NULL;
		uvpars = NULL;
		xyz_cvs = NULL;
		uv_cvs = NULL;
	
		BSprtlngmsf(
			&BSsurf,
			0,
			&cvscode,
			eye_pt,
			z_vector,
			0.0,
			&num_groups,
			&numint,
			&num_pts,
			&pts,
			&uvpars,
			&xyz_cvs,
			&uv_cvs,
			&rc );
	
		BS_ERRCHK( rc, "HScreate_horizon_edges: BSprtlngmsf failed" );
		}
	else
		{
		BSsfpartrg(
			surf,
			z_vector,
			u_range,
			v_range,
			1,
			&num_groups,
			&groups,
			&rc );
	
		BS_ERRCHK( rc, "HScreate_horizon_edges: BSsfpartrg failed" );
		}
		
	if( rc == BSSUCC )
		{
			
		/*
		 *  process each group as a separate edge 
		 */
		 
		for( i=0; i<num_groups; i++ )
			{

			 
			

			/*
			 *  Places poles and num poles in the curve structure
			 */
			 
			if( perspective )
				{
				curve.num_poles = num_pts[i];
				curve.poles = (IGRdouble *)pts[i];
				}
			else
				{
				curve.num_poles = groups->num;
				curve.poles = (IGRdouble *)groups->pts;
				}			 
			
			/*
			 * allocate memory for knots 
			 */

			curve.num_knots = curve.num_poles + 2;
			curve.knots = (IGRdouble *)malloc( curve.num_knots * sizeof( IGRdouble ) );

			curve.order          = 2;
			curve.periodic       = FALSE;
			curve.non_uniform    = TRUE;
			curve.rational       = FALSE;
			curve.weights        = NULL;
			curve.planar         = FALSE;
			curve.phy_closed     = FALSE;
			curve.num_boundaries = 0;
			curve.bdrys          = NULL;
			/* 
			 * space knots with respect to arc length between poles 
			 */
			 
			BSchrdlkts(
				&rc,
				&curve.num_poles,
				curve.poles,
				&curve.order,
				&curve.periodic,
				curve.knots );

			BS_ERRCHK( rc, "HScreate_horizon_edges: BSchrdlkts failed" );

			/* 
			 * check the planarity of the horizon line 
			 */
			 
			BSptlnplan(
				curve.num_poles,
				curve.rational,
				(IGRpoint *) curve.poles,
				curve.weights,
				&code,
				normal,
				&rc );

			BS_ERRCHK( rc, "HScreate_horizon_edge: BSptlnplan failed" );

			switch( code )
				{
				case 1:
				case 2:
				case 4:
				
					/* 
					 *  parting line collapses to a point, 
					 *  line or is non-planar 
					 */
					 
					curve.planar = FALSE;
					break;
	            
				case 3 :

					/* 
					 *  parting line is planar 
					 */
					 
					curve.planar = TRUE;
					break;

				}
	         
			if( surf->num_boundaries > 0 )
				{

				/* 
				 * trim the parting line 
				 */

				if( perspective )
					{
					polyline.num_points = num_pts[i];
					polyline.points = (IGRdouble *)uvpars[i];
					}
				else
					{
					polyline.num_points = groups->num;
					polyline.points = (IGRdouble *)groups->par;
					}
					
				HSlvhl_trim_polyline( 
						file_id,
						&curve,
						&polyline,
						loopset_id,
						loopset_os,
						options,
						pipe_no,
						color,
						acc_mode,
						accuracy,
						win_cht,
						clip_range  );
				}
			else
				{
				if( file_id == NULL )
					{
					HSbcurve_tiler(
						pipe_no,
						&curve,
						color,
						options,
						TRUE,
						acc_mode,
						accuracy,
						win_cht,
						clip_range );
					}
				else
					{
					HPwrite_draw_range(
						file_id,
						NURB_EDGE,
						(int)99,
						NULL );
			
					HPwrite_curve_info(
						file_id,
						&curve,
						3,
						NULL );
					}
				}
			if( curve.knots != NULL )
				free( curve.knots );

			if ( !perspective )
				{
				temp_group = groups;
				groups = groups->next;

				/* 
			   	  * free uv array in group header 
				*/
				free( (IGRchar *)temp_group->par );
	      
				/* 
			 	  * free parting group header 
				*/
				free( (IGRchar *)temp_group );
				}
			}

		if( perspective )
			{
			if( num_pts ) free( (char *)num_pts );
			if( numint )  free( (char *)numint );
				
			if( uvpars )
				{
				for( i=0; i<num_groups; i++ )
					if( uvpars[i] )
						free( (char *)uvpars[i] );
							
				free( (char *)uvpars );
				}

			if( pts )
				{
				for( i=0; i<num_groups; i++ )
					if( pts[i] )
						free( (char *)pts[i] );
							
				free( (char *)pts );
				}
			}
		}
	}

/*---HSget_surface_edges----------------------------------*/

/* Given a surface (surface_id, surface_os: surface object is and object
 *   space number, surf: the surface geometry and mdenv_info: the surface
 *   module environment information) collect the edges and process them.
 *   If we are in RHL mode, or creating a shaded plotfile (file_id will
 *   not be NULL), and edges don't exist, call functions to create (but
 *   not place in the environment) edge geometry for display.  If an edge
 *   already exist, collect any soos that might exist.
 */

HSget_surface_edges( IGRint *file_id,
		    GRobjid surface_id,
		 GRspacenum surface_os,
      struct IGRbsp_surface *surf,
	struct GRmdenv_info *mdenv_info,
			int options,
			int pipe_no,
			int color,
			int acc_mode,
			int accuracy,
		     double win_cht,
		     double clip_range[6],
		  IGRdouble rotation_matrix[4][4],
		     IGRint mode,
		 IGRboolean perspective,
		  IGRdouble *eye_pt )

	{
	struct GRid	*edges = NULL;
	struct GRid	*gralp_edges = NULL;
	struct GRid	*horiz_edges = NULL;
	struct GRid	*cusp_edges = NULL;

	IGRint		num_edges = 0;
	IGRint		num_gralp_edges = 0;
	IGRint		num_horiz_edges = 0;
	IGRint		num_cusp_edges = 0;
	IGRshort	get_graphics_edges_options;

	struct GRid	*edge;
	IGRlong		msg, sts;
	IGRint		i;
	struct GRmd_env	md_env, saved_md_env;
	IGRint		sizbuf, nret;

	IGRboolean	     loopset_created;
	OM_S_CHANSELECT      loopset_chan;
	OM_S_OBJECT_LINKAGE  loopset_linkage[1];
	IGRint               loopset_count;
	IGRint               edge_id_size;

	IGRshort	      rot_mat_type;
	struct EMSobject_info parents[2];
	IGRint                num_parents = 2;
	IGRlong               rc;
	IGRdouble	      z_vector[3];
	IGRlong	              opt;
	IGRboolean	      horizon_curves;
	
	z_vector[0] = rotation_matrix[2][0];
	z_vector[1] = rotation_matrix[2][1];
	z_vector[2] = rotation_matrix[2][2];

	/* 
	 *  This flag will tell the tiler that the object it is working on
	 *  is a surface edge
	 */
	 
	tiling_parms.processing_mode |= HS_PMODE_EDGE_OBJECT;

	/*
	 *  get the master module environment
	 */
	 
	sizbuf = sizeof( struct GRmd_env );	
	gr$get_module_env(
		   msg = (IGRint *) &msg,
		sizbuf = &sizbuf,
		buffer = (char *) &md_env,
		  nret = &nret );
		
	msg = EMS_S_Success;
	sts = OM_S_SUCCESS;

	
	/*
	 *  Get the loopset object.  If the object module environment is valid
	 *  call the new function EMputLsIfNotThere which will get the loopset
	 *  object for the surface.  If the loopset does not exist, it will
	 *  create it before returning it.
	 */

	loopset_count = 0;
	if( mdenv_info != NULL )
		{
		loopset_linkage[0].osnum = surface_os;
		sts = om$send( msg = message EMSsurface.EMputLsIfNotThere(
								&msg,
								mdenv_info,
								NULL,
								&loopset_linkage[0].S_objid,
								0,
								&loopset_created ),
			  senderid = NULL_OBJID,
			  targetid = surface_id,
			  targetos = surface_os );

		/*
		 *  If the call succeeded, then I set the loopset_count to 1
		 */

		if( (1 & sts & msg ) )
			loopset_count = 1;
		}

	/*
	 *  If the previous attempt to get the loopset object failed, for 
	 *  whatever reason, try and get it the old way.  This will not create
	 *  it if it does not exist
	 */

	if( loopset_count <= 0 )
		{
		om$make_chanselect( channame     = "EMSsubbs.to_loopset",
		                    p_chanselect = &loopset_chan );

		/* 
		 *  Check EMSsubbs.to_loopset channel of surface, to see if a loopset
		 *  object exists.  If not, then this is a primitive surface with no
		 *  boundaries, and, therefore, no shared edges. 
		 */

		sts = om$get_channel_objects( objid = surface_id,
					      osnum = surface_os,
				       p_chanselect = &loopset_chan,
					       list = loopset_linkage,
					       size = 1,
					      count = (OMuint *)&loopset_count );

		OM_ERRCHK( sts, "HSgetedges:  om$get_channel_objects for loopset failed" );
		}

	edge_id_size = 0;
	num_edges = 0;
	edges = NULL;

	/*
	 *  If the loopset exist, call EMget_edges to get the edges, else, if in
	 *  RHL or CreHE mode, manually create the edges
	 */

	if( loopset_count > 0 )
		{
			
		/*
		 *  Collect the edges from the loopset
		 */

		if( mode == HS_GET_EDGES_MODE_LVHL )
			opt = (HSlvhl.process_tangent) ? EMS_OPT_NONDEG_NONTANSEAM : EMS_OPT_NONTAN_NONDEG;
		else
			opt = EMS_OPT_NONDEG_NONTANSEAM;

		sts = om$send( msg = message EMSboundary.EMget_edges( &msg,
								      MAXINT,
								      opt,
								      &edges,
								      &edge_id_size,
								      &num_edges ),
			  senderid = NULL_OBJID,
			  targetid = loopset_linkage[0].S_objid,
			  targetos = loopset_linkage[0].osnum );
		
		OM_ERRCHK( sts,  "HSgetedges: EMget_edges send failed" );

		/*
		 *  Process the edges
		 */

		if( num_edges > 0 )
			{
			edge = edges;
			for( i=0; i<num_edges; i++ )
				{
				HSprocess_edge( file_id,
						edge->objid, 
						edge->osnum,
						surf, 
						&md_env,
						mdenv_info,
						options,
						pipe_no,
						color,
						acc_mode,
						accuracy,
						win_cht,
						clip_range,
						mode,
						FALSE );
					
				edge++;
				}
			
			if( edges != NULL ) om$dealloc( ptr = edges );  /* allocated w/ om$malloc */
			}
		}
	else
		{

		/*
		 *  If we are in RHL mode, create the geometry
		 *  for the natural edges.  This will not place edges in
		 *  the object space.
		 */

		if( mode == HS_GET_EDGES_MODE_RHL )
			HSgenerate_natural_edges( file_id,
						  surf, 
						  &md_env.md_env,
						  options,
						  pipe_no,
						  color,
						  acc_mode,
						  accuracy,
						  win_cht,
						  clip_range );
		}

	/*
	 *  If the object module environment is valid, call EMget_graphics_edges
	 *  to, if necessary, create the graphics edges for the surface and collect
	 *  them
	 */

	if( mdenv_info != NULL && !perspective )
		{
			
		/*
		 *  get the graphics edges for the surface.  Don't get the graphic
		 *  loop edges at this time
		 */
		 
		/* 
		 * get a reference plane for this environment 
		 */

		MAtypemx( &rc, (IGRdouble *) rotation_matrix, &rot_mat_type );
		
		memcpy( &parents[0].env.md_env, mdenv_info, sizeof( struct GRmdenv_info ) );
		ex$get_modid( mod_osnum = surface_os, mod_id = &parents[0].env.md_id.objid );
		parents[0].env.md_id.osnum = surface_os;

		if ((! HSis_os_read_only( surface_os )) || ( ! HSis_curve_type_equal_curve()))
			{
			ems$get_reference_plane_for_given_orientation( msg          = &msg,
			                                               env_info     = &parents[0].env,
			                                               refpln_mxtyp = &rot_mat_type,
		        	                                       refpln_mx    =  rotation_matrix,
		                	                               pln_GRid     = &parents[0].grid );

			}
		else
			{
			/* read only environment => see if ref. plane exists in it already */

			ems$get_reference_plane_for_given_orientation( msg          = &msg,
								       /*options      = EMS_OPT_DO_NOT_CREATE,*/
			                                               env_info     = &parents[0].env,
			                                               refpln_mxtyp = &rot_mat_type,
		        	                                       refpln_mx    = rotation_matrix,
		                	                               pln_GRid     = &parents[0].grid );

			if ( parents[0].grid.objid == NULL_OBJID )
				{
				/* couldn't find ref plane in envrionment -> create */
				/* one in the master file                           */
				memcpy( &parents[0].env, &md_env, sizeof( struct GRmd_env ) );
				ems$get_reference_plane_for_given_orientation( msg          = &msg,
				                                               env_info     = &parents[0].env,
				                                               refpln_mxtyp = &rot_mat_type,
		        		                                       refpln_mx    = rotation_matrix,
		                		                               pln_GRid     = &parents[0].grid );
				}
			}

		parents[1].grid.objid = surface_id;
		parents[1].grid.osnum = surface_os;
		
		memcpy( &parents[1].env.md_env, mdenv_info, sizeof( struct GRmdenv_info ) );
		
		parents[1].env.md_id.objid = parents[0].env.md_id.objid;
		parents[1].env.md_id.osnum = surface_os;

		get_graphics_edges_options = EMS_OPT_HORIZON | EMS_OPT_CUSP;
		if ( (mode == HS_GET_EDGES_MODE_RHL) ||
		     (mode == HS_GET_EDGES_MODE_LVHL) ||
		     (mode == HS_GET_EDGES_MODE_PLOTTING) )
			{
			/* only create edges if getting edges for RHL, LVHL, or PLOTTING */
			get_graphics_edges_options |= EMS_OPT_CREATE;
			}

                if (HSis_curve_type_equal_curve())
                  get_graphics_edges_options |= EMS_OPT_CREATE_HRZ_CVS;
                else
                  get_graphics_edges_options &= ~EMS_OPT_CREATE_HRZ_CVS;

		sts = om$send( msg = message EMSsubbs.EMget_graphics_edges( 
							&msg,
							&num_parents, parents,
							get_graphics_edges_options,
							&num_gralp_edges,
							&num_horiz_edges,
							&num_cusp_edges,
							&gralp_edges,
							&horiz_edges,
							&cusp_edges ),
			  senderid = NULL_OBJID,
			  targetid = surface_id,
			  targetos = surface_os );
			  
		OM_ERRCHK( sts, "HSgetedges: EMget_graphics_edges send failed" );
		MSG_ERRCHK( msg, "HSgetedges: EMget_graphics_edges send failed" );

		horizon_curves = (msg == EMS_I_Success);

		/*
		 *  Process the graphic loop edges
		 */
		 
		if( num_gralp_edges > 0 )
			{
			edge = gralp_edges;
			for( i=0; i<num_gralp_edges; i++ )
				{
				HSprocess_edge( file_id,
						edge->objid, 
						edge->osnum,
						surf, 
						&md_env,
						mdenv_info,
						options,
						pipe_no,
						color,
						acc_mode,
						accuracy,
						win_cht,
						clip_range,
						mode,
	                                        FALSE );
					
				edge++;
				}
			}

		/*
		 *  process the horizon edges
		 */


		if( num_horiz_edges > 0 )
			{
			if ( horizon_curves )
				{
				/* save surface's module environment and substitute the master */
				/* environment because horizon curves are in the master file   */
				memcpy( &saved_md_env, &HSlvhl.md_env, sizeof( struct GRmd_env ) );
				memcpy( &HSlvhl.md_env, &md_env, sizeof( struct GRmd_env ) );
				}

			edge = horiz_edges;
			for( i=0; i<num_horiz_edges; i++ )
				{
				HSprocess_edge( file_id,
						edge->objid, 
						edge->osnum,
						surf, 
						&md_env,
						mdenv_info,
						options,
						pipe_no,
						color,
						acc_mode,
						accuracy,
						win_cht,
						clip_range,
						mode,
						horizon_curves );
					
				edge++;
				}

			if ( horizon_curves )
				{
				/* restore surface's module environment */
				memcpy( &HSlvhl.md_env, &saved_md_env, sizeof( struct GRmd_env ) );
				}
			}
		
		/*
		 *  process the cusp edges
		 */
		 
 		if( num_cusp_edges > 0 )
			{
			edge = cusp_edges;
			for( i=0; i<num_cusp_edges; i++ )
				{
				HSprocess_edge( file_id,
						edge->objid, 
						edge->osnum,
						surf, 
						&md_env,
						mdenv_info,
						options,
						pipe_no,
						color,
						acc_mode,
						accuracy,
						win_cht,
						clip_range,
						mode,
						FALSE );
					
				edge++;
				}
			}

		/*
		 *  clean up
		 */
		 		
		if( gralp_edges != NULL ) om$dealloc( ptr = gralp_edges );  /* allocated w/ om$malloc */
		if( horiz_edges != NULL ) om$dealloc( ptr = horiz_edges );  /* allocated w/ om$malloc */
		if( cusp_edges != NULL ) om$dealloc( ptr = cusp_edges );  /* allocated w/ om$malloc */
		}
	else
		{
			
		/*
		 *  If we are in RHL or CreHE mode, create the edge geometry
		 *  for the horizon and cusp (sharp) edges.  No curve will
		 *  be place in the object space
		 */

		if ( (mode == HS_GET_EDGES_MODE_RHL) ||
		     (mode == HS_GET_EDGES_MODE_PLOTTING) )
			{
			HScreate_horizon_edges( file_id,
						surf,
						z_vector,
						loopset_linkage[0].S_objid,
						loopset_linkage[0].osnum,
						options,
						pipe_no,
						color,
						acc_mode,
						accuracy,
						win_cht,
						clip_range,
						perspective,
						eye_pt );

			HScreate_sharp_edges( file_id,
					      surf,
					      loopset_linkage[0].S_objid,
					      loopset_linkage[0].osnum,
					      options,
					      pipe_no,
					      color,
					      acc_mode,
					      accuracy,
					      win_cht,
					      clip_range );
			}
		}
		
	tiling_parms.processing_mode &= ~HS_PMODE_EDGE_OBJECT;
	
	return( 1 );
	}

end implementation Root;





