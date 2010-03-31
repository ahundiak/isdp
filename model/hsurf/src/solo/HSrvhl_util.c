#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "vedef.h"
#include "veerr.h"
#include "bserr.h"
#include "wl.h"

static struct IGRbsp_curve	*temp_curve;
static struct GRvg_construct	cons_args;
static struct IGRdisplay	vis_attr;
static struct IGRdisplay	hid_attr;
static struct GRmd_env		HSmaster_env;
static char			first_time = TRUE;

/*---HSoutput_span--------------------------------------------------------*/

/*
DESCRIPTION
	This function creates the required graphic objects to represent a visible/
	hidden span of an edge.

	The objects that can be created are:

		GR3dpoint   - point object
	        GR3dlinestr - line string object
		GRbcsubbc   - general curve object

HISTORY
	S.P. Rogers  10/09/87  Creation Date
	Mike Lanier  09/28/90  Copied and modified for vector/raster output
*/

void HSoutput_span( curve, us, ue, xyzs, xyze, visibility )

struct IGRbsp_curve	*curve;
double			us, ue;
double			xyzs[3], xyze[3];
int			visibility;


	{
	IGRlong			sts;
	IGRlong			rc1, cons_msg;
	IGRboolean		tst_planar = FALSE;
/*	int			sizbuf, nret, msg;*/

/*
fprintf( stderr, "HSoutput_span: \n" );
fprintf( stderr, "   start, stop -- %f %f\n", us, ue );
fprintf( stderr, "   start_xyz ---- %f %f %f\n", xyzs[0], xyzs[1], xyzs[2] );
fprintf( stderr, "   end_xyz ------ %f %f %f\n", xyze[0], xyze[1], xyze[2] );
fprintf( stderr, "   visibility --- %d\n", visibility );
fprintf( stderr, "   color -------- %d\n", element_parms.color );
*/
	if( first_time )
		{
		first_time = FALSE;

		temp_curve = (struct IGRbsp_curve *)malloc(sizeof(struct IGRbsp_curve));
		
		/*			
		sizbuf = sizeof( struct GRmd_env );

		gr$get_module_env(
 			msg    = &msg,
			sizbuf = &sizbuf,
			buffer = &HSmaster_env,
			nret   = &nret );
		*/
			
		cons_args.msg        = &cons_msg;
		cons_args.env_info   = &HSmaster_env;
		cons_args.newflag    = FALSE;
		cons_args.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
		cons_args.class_attr = NULL;
		cons_args.name       = NULL;

		vis_attr.weight = element_parms.visible_weight;
		vis_attr.style = 0;

		hid_attr.weight = element_parms.visible_weight / 2;
		hid_attr.style = 5;
		}

	HSget_temp_curve_storage( 
		temp_curve, 
		curve );
		
	if( visibility == VISIBLE )
		{
		vis_attr.color = ((element_parms.color-15)/tiling_parms.number_shades)+1;
		cons_args.display    = &vis_attr;
		cons_args.level      = 100;
		}
	else
		{
		hid_attr.color = ((element_parms.color-15)/tiling_parms.number_shades)+1;
		cons_args.display    = &hid_attr;
		cons_args.level      = 101;
		}
		
	
	/* split out span into temporary curve */

	sts = BSactivsplt(	&rc1,
				curve,
				&us,
				&ue,
				temp_curve,
				&tst_planar );

/*				
dump_curve( curve );
dump_curve( temp_curve );
*/

	BS_STSCHK( sts, "HSoutput_span: BSactivsplt - bad sts" );
	BS_ERRCHK( rc1, "HSoutput_span: BSactivsplt failed" );

	if( rc1 != BSSUCC ) return;


	cons_args.geometry = (char *)temp_curve;

	if( temp_curve->order == 2 )
		{
		/*
		object_class_id = (temp_curve->num_poles == 2) ?
					OPP_GR3dlineseg_class_id : OPP_GR3dlinestr_class_id;
		*/
	
		if ( temp_curve->rational )
			{
				
			/* Rational linestring => unweight the poles so */
			/* the geometry will be posted correctly.	 */
			
			BSunwght_p( 
				&rc1, 
				temp_curve->poles, 
				temp_curve->weights,
				&temp_curve->num_poles, 
				temp_curve->poles );

			BS_ERRCHK( rc1, "HSoutput_span: BSunwght_p failed" );

			temp_curve->rational = FALSE;
			}  /* end: if ( temp_curve->rational ) */
		}
/*	else
		object_class_id = OPP_GRbcsubbc_class_id;*/

	/* construct object for this span */

	/*
	sts = om$construct(
			msg     = message GRvg.GRconstruct( &cons_args ),
			osnum   = HSmaster_env.md_id.osnum,
			classid = object_class_id,
	 		p_objid = &new_object );

	OM_ERRCHK( sts, "HSoutput_span: om$construct failed" );
	*/
	
	HSdraw_curve( temp_curve );
	}


struct HStemp_curve_info
	{
	double	*poles, *knots, *weights;
	int	num_poles, num_knots, num_weights;
	};
	
static struct HStemp_curve_info	HStemp_curve_mem = { NULL, NULL, NULL, 0, 0, 0 };


/*---- HSget_temp_curve_storage -------------------------------------------*/

/*
DESCRIPTION
	This function returns temporary space for the poles, knots and weights
	of a curve.
	
HISTORY
	S.P. Rogers  09/29/87  Creation Date
*/


static HSget_temp_curve_storage( curve, sc )

struct IGRbsp_curve *curve, *sc;
	
	{
	/* check the space that is already allocated to see if it is big enough */

	if( sc->num_poles > HStemp_curve_mem.num_poles )
		{
		if( HStemp_curve_mem.poles ) free( (IGRchar *)HStemp_curve_mem.poles );
		HStemp_curve_mem.num_poles = sc->num_poles;
		HStemp_curve_mem.poles = 
			(IGRdouble *)malloc( HStemp_curve_mem.num_poles * 3 * sizeof(IGRdouble));
		}

	if( sc->num_knots > HStemp_curve_mem.num_knots )
		{
		if( HStemp_curve_mem.knots ) free( (IGRchar *)HStemp_curve_mem.knots );
		HStemp_curve_mem.num_knots = sc->num_knots;
		HStemp_curve_mem.knots = 
			(IGRdouble *)malloc( HStemp_curve_mem.num_knots * sizeof(IGRdouble) );
		}
	
	if( sc->rational )
		{
		if( sc->num_poles > HStemp_curve_mem.num_weights )
			{
			if( HStemp_curve_mem.weights ) free( (IGRchar *)HStemp_curve_mem.weights );
			HStemp_curve_mem.num_weights = sc->num_poles;
			HStemp_curve_mem.weights = 
				(IGRdouble *)malloc( HStemp_curve_mem.num_weights * sizeof(IGRdouble) );
			}
		}

	memcpy( curve, sc, sizeof( struct IGRbsp_curve ) );

	curve->poles	= HStemp_curve_mem.poles;
	curve->knots	= HStemp_curve_mem.knots;
	curve->weights  = HStemp_curve_mem.weights;

	memcpy( curve->poles, sc->poles, sc->num_poles * 3 * sizeof( double ) );
	memcpy( curve->knots, sc->knots, sc->num_knots * sizeof( double ) );

	if( sc->rational )
	memcpy( curve->weights, sc->weights, sc->num_poles * sizeof( double ) );
	}
	

/*---dump_curve--------------------------------------------------------*/

static dump_curve( curve )

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

/*---HSdraw_curve-----------------------------------------------*/

static	HSdraw_curve( curve )

struct IGRbsp_curve	*curve;

	{
	BSrc	rc;
	double	xyz[3];
	int	i;

	if( cons_args.display->style == 0 )
		WLset_active_symbology( active_window->win_no,
		                        element_parms.color,
		                        0,
		                        0,
		                        cons_args.display->weight,
		                        WL_SYMB_CHANGE_COLOR | WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT );
	else
		WLset_active_symbology( active_window->win_no,
		                        element_parms.color,
		                        5,
		                        0,
		                        cons_args.display->weight,
		                        WL_SYMB_CHANGE_COLOR | WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT );

dump_curve( curve );
	{	
	int	*v;
	
	v = (int *)malloc( sizeof( int ) * (curve->num_poles + 2) );

	for( i=1; i<=curve->num_poles; i++ )
		{
		BScveval( curve,
			  curve->knots[i],
			  0,
			  xyz,
			  &rc );
			  
		transform_points( 0, 1, xyz, 0 );
		
		v[i*2  ] = (int)xyz[0];
		v[i*2+1] = (int)xyz[1];		
		}
		
	WLIxor_linestring( active_window->win_no,
			   ALUcopy,
			   v,
			   curve->num_poles,
			   VERT_LONG );
	}
		
	WLflush( active_window->win_no );
	}
