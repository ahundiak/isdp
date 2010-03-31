
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:41:59 $
$Locker:  $

HISTORY

	Sudha	07/28/93	Modified for BSprototype ansification

*/

#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"

#include "bs.h"
#include "bsparameters.h"
#include "bsxtractpar.h"
#include "bsprintbsps.h"
#include "bsprintbspc.h"

#include "vedef.h"
#include "ve.h"

/* prototype files */
#include "VEpr_debug.h"


/*-- VEdebug_surface --------------------------------------------------------*/

void VEdebug_surface( struct IGRbsp_surface *surf,
		      IGRboolean            flag )

/*
NAME
	VEdebug_surface

KEYWORD
	debug

DESCRIPTION
	Dump a Bspline surface definition to standard error

PARAMETERS
	surf (IN) - the surface to debug
	flag (IN) - if TRUE, the surface is dumped in math format

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

 {
  IGRchar       name;
  IGRint	vi, ui, index;
  IGRint        num_bounds;

  if ( flag )
     {
     num_bounds = surf->num_boundaries;
     surf->num_boundaries = 0;
     BSprintbsps( stderr, &name, surf, FALSE );
     surf->num_boundaries = num_bounds;
     }
  else
     {
     fprintf ( stderr, "  u_order       = %d\n", surf->u_order);
     fprintf ( stderr, "  v_order       = %d\n", surf->v_order);
     fprintf ( stderr, "  u_num_poles   = %d\n", surf->u_num_poles);
     fprintf ( stderr, "  v_num_poles   = %d\n", surf->v_num_poles);
     fprintf ( stderr, "  u_num_knots   = %d\n", surf->u_num_knots);
     fprintf ( stderr, "  v_num_knots   = %d\n", surf->v_num_knots);
     fprintf ( stderr, "  rational      = %d\n", surf->rational);
     fprintf ( stderr, "  planar        = %d\n", surf->planar);
     fprintf ( stderr, "  u_phy_closed  = %d\n", surf->u_phy_closed);
     fprintf ( stderr, "  v_phy_closed  = %d\n", surf->v_phy_closed);
     fprintf ( stderr, "  u_periodic    = %d\n", surf->u_periodic);
     fprintf ( stderr, "  v_periodic    = %d\n", surf->v_periodic);
     fprintf ( stderr, "  u_non_uniform = %d\n", surf->u_non_uniform);
     fprintf ( stderr, "  v_non_uniform = %d\n", surf->v_non_uniform);
     if (surf->num_boundaries != 0)
        {
        fprintf ( stderr, "  num_bounds    = %d\n", surf->num_boundaries );
        fprintf ( stderr, "  on_off        = %d\n", surf->on_off );
        }
     fprintf ( stderr, "  \n" );
 
     if (surf->rational != 0)
       {
       fprintf ( stderr, "  Poles (v, u, x, y, z, w):\n");
       for (vi = 0; vi < surf->v_num_poles; vi++)
         {
         for (ui = 0; ui < surf->u_num_poles; ui++)
            fprintf ( stderr, "%4d %4d %20.12lf %20.12lf %20.12lf %20.12lf\n",
                      vi, ui,
                      surf->poles[((vi*surf->u_num_poles)+ui) * 3] /
                        surf->weights[(vi*surf->u_num_poles)+ui],
                      surf->poles[((vi*surf->u_num_poles)+ui) * 3 + 1] /
                        surf->weights[(vi*surf->u_num_poles)+ui],
                      surf->poles[((vi*surf->u_num_poles)+ui) * 3 + 2] /
                        surf->weights[(vi*surf->u_num_poles)+ui],
                      surf->weights[(vi*surf->u_num_poles)+ui]);
         fprintf ( stderr, "\n");
         }
       }
     else
       {
       fprintf ( stderr, "  Poles (v, u, x, y, z):\n");
       for (vi = 0; vi < surf->v_num_poles; vi++)
         {
         for (ui = 0; ui < surf->u_num_poles; ui++)
            fprintf ( stderr, "%4d %4d %20.12lf %20.12lf %20.12lf\n",
                      vi, ui,
                      surf->poles[((vi*surf->u_num_poles)+ui) * 3],
                      surf->poles[((vi*surf->u_num_poles)+ui) * 3 + 1],
                      surf->poles[((vi*surf->u_num_poles)+ui) * 3 + 2]);
         fprintf ( stderr, "\n");
         }
       }

     fprintf ( stderr, "\n  U knots:\n");
     for (index = 0; index < surf->u_num_knots; index++)
       fprintf ( stderr, "%18.16lf\n", surf->u_knots[index]);
     fprintf ( stderr, "\n  V knots:\n");
     for (index = 0; index < surf->v_num_knots; index++)
       fprintf ( stderr, "%18.16lf\n", surf->v_knots[index]);
     }

 }


/*-- VEdebug_curve --------------------------------------------------------*/

void VEdebug_curve( struct IGRbsp_curve *curve,
		    IGRboolean            flag )

/*
NAME
	VEdebug_curve

KEYWORD
	debug

DESCRIPTION
	Dump a Bspline curve definition to standard error

PARAMETERS
	curve (IN) - the curve to debug
	flag (IN) - if TRUE, the curve is dumped in math format

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

{
  IGRchar       name;
  IGRint	ui, index;

  if ( flag )
     {
     BSprintbspc( stderr, &name, curve, FALSE );
     }
  else
     {
     fprintf ( stderr, "  order       = %d\n", curve->order);
     fprintf ( stderr, "  num_poles   = %d\n", curve->num_poles);
     fprintf ( stderr, "  num_knots   = %d\n", curve->num_knots);
     fprintf ( stderr, "  rational    = %d\n", curve->rational);
     fprintf ( stderr, "  planar      = %d\n", curve->planar);
     fprintf ( stderr, "  phy_closed  = %d\n", curve->phy_closed);
     fprintf ( stderr, "  periodic    = %d\n", curve->periodic);
     fprintf ( stderr, "  non_uniform = %d\n", curve->non_uniform);
     fprintf ( stderr, "  num_bounds  = %d\n\n", curve->num_boundaries );

     if (curve->rational != 0)
       {
       fprintf ( stderr, "  Poles (u, x, y, z, w):\n");
         for (ui = 0; ui < curve->num_poles; ui++)
            fprintf ( stderr, "%4d %20.12lf %20.12lf %20.12lf %20.12lf\n",
                      ui,
                      curve->poles[(ui) * 3] / curve->weights[ui],
                      curve->poles[(ui) * 3 + 1] / curve->weights[ui],
                      curve->poles[(ui) * 3 + 2] / curve->weights[ui],
                      curve->weights[ui]);
       }
     else
       {
       fprintf ( stderr, "  Poles (u, x, y, z):\n");
         for (ui = 0; ui < curve->num_poles; ui++)
            fprintf ( stderr, "%4d %20.12lf %20.12lf %20.12lf\n",
                      ui,
                      curve->poles[(ui) * 3],
                      curve->poles[(ui) * 3 + 1],
                      curve->poles[(ui) * 3 + 2]);
       }

     fprintf ( stderr, "\n  knots:\n");
     for (index = 0; index < curve->num_knots; index++)
       fprintf ( stderr, "%18.16lf\n", curve->knots[index]);
     }
}


/*--- VElog_cvcv_int_data ---------------------------------------------*/

void VElog_cvcv_int_data( curve0, curve1 )

	struct IGRbsp_curve *curve0;
	struct IGRbsp_curve *curve1;

/*
NAME
	VElog_cvcv_int_data

KEYWORD
	debug

DESCRIPTION
	This function writes the data required by the math group for
	a curve/curve intersection problem to standard error.

PARAMETERS
	curve0 (IN) - one of the curves to debug
	curve1 (IN) - the other curve to debug

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong rc;
	IGRdouble base_tol, dist_tol, dist_sqtol, cht, overlap_tol;

	BSxtractpar(&rc, BSTOLBASIS, &base_tol );
	BSxtractpar(&rc, BSTOLLENVEC, &dist_tol);
	BSxtractpar(&rc, BSTOLSQLENVEC, &dist_sqtol);
	BSxtractpar(&rc, BSTOLCHRDHT, &cht);
	BSxtractpar(&rc, BSTOLOVERLAP, &overlap_tol);

	fprintf( stderr, "\n********** Curve/Curve Intersection Data\n\n" );
	fprintf( stderr, "base_tol = %lf\n", base_tol );
	fprintf( stderr, "dist_tol = %lf, dist_sqtol = %lf\n", dist_tol, dist_sqtol );
	fprintf( stderr, "overlap_tol = %lf, cht = %lf\n", overlap_tol, cht );

	fprintf (stderr, "Curves:\n");
	VEdebug_curve( curve0, TRUE );
	fprintf (stderr, "\n");
	VEdebug_curve( curve1, TRUE );
	fprintf (stderr, "\n");

	}  /* VElog_cvcv_int_data */



/*--- VElog_cvslf_int_data ---------------------------------------------*/

void VElog_cvslf_int_data( curve )

	struct IGRbsp_curve *curve;

/*
NAME
	VElog_cvslf_int_data

KEYWORD
	debug

DESCRIPTION
	This function writes the data required by the math group for
	a curve self-intersection problem to standard error.

PARAMETERS
	curve (IN) - the curve to debug

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong rc;
	IGRdouble base_tol, dist_tol, dist_sqtol, cht, overlap_tol;

	BSxtractpar(&rc, BSTOLBASIS, &base_tol );
	BSxtractpar(&rc, BSTOLLENVEC, &dist_tol);
	BSxtractpar(&rc, BSTOLSQLENVEC, &dist_sqtol);
	BSxtractpar(&rc, BSTOLCHRDHT, &cht);
	BSxtractpar(&rc, BSTOLOVERLAP, &overlap_tol);

	fprintf( stderr, "\n********** Curve-Self Intersection Data\n\n" );
	fprintf( stderr, "base_tol = %lf\n", base_tol );
	fprintf( stderr, "dist_tol = %lf, dist_sqtol = %lf\n", dist_tol, dist_sqtol );
	fprintf( stderr, "overlap_tol = %lf, cht = %lf\n", overlap_tol, cht );

	VEdebug_curve( curve, TRUE );
	fprintf (stderr, "\n");
	}  /* VElog_cvslf_int_data */



/*--- VElog_pt_proj_data ---------------------------------------------*/

void VElog_pt_proj_data( point, vector, surface )

	IGRdouble             *point;
	IGRdouble             *vector;
	struct IGRbsp_surface *surface;

/*
NAME
	VElog_pt_proj_data

KEYWORD
	debug

DESCRIPTION
	This function writes the data required by the math group for
	a point projection problem to standard error.

PARAMETERS
	point (IN) - the projection point
	vector (IN) - the projection vector
	surface (IN) - the surface to project into

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong   rc;
	IGRdouble base_tol;
	IGRdouble cht;

	BSxtractpar(&rc, BSTOLBASIS, &base_tol );
	BSxtractpar(&rc, BSTOLCHRDHT, &cht);

	fprintf( stderr, "\n********** Point Projection Data\n\n" );
	
	fprintf( stderr, "Projection point:  %20.15lf %20.15lf %20.15lf\n",
	         point[0], point[1], point[2] );

	fprintf( stderr, "Vector:            %20.15lf %20.15lf %20.15lf\n",
	         vector[0], vector[1], vector[2] );
	         
	fprintf( stderr, "base_tol = %20.15lf\n", base_tol );
	fprintf( stderr, "Cht      = %20.15lf\n", cht );
	
	fprintf( stderr, "Surface:\n" );
	VEdebug_surface( surface, TRUE );

	}  /* VElog_pt_proj_data */


/*--- VElog_parting_line_data ---------------------------------------------*/

void VElog_parting_line_data( surf, u_range, v_range )

	struct IGRbsp_surface *surf;
	IGRdouble             *u_range;
	IGRdouble             *v_range;

/*
NAME
	VElog_parting_line_data

KEYWORD
	debug

DESCRIPTION
	This function writes the data required by the math group for
	a parting line problem to standard error.

PARAMETERS
	surf (IN) - the surface whose parting lines are calculated
	u_range (IN) - u range of the surface
	v_range (IN) - v range of the surface

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong rc;
	IGRdouble base_tol, cht;

	BSxtractpar(&rc, BSTOLBASIS, &base_tol );
	BSxtractpar(&rc, BSTOLCHRDHT, &cht);

	fprintf( stderr, "TOLERANCES:\n\n" );
	fprintf( stderr, "   base_tol = %lf\n", base_tol );
	fprintf( stderr, "   cht = %lf\n", cht );

	fprintf( stderr, "PARAMETERS:\n\n" );

	fprintf( stderr, "   Ind:      0\n" );
	fprintf( stderr, "   Vec:      NULL\n" );
	fprintf( stderr, "   U-Range:  %lf - %lf\n", u_range[0], u_range[1] );
	fprintf( stderr, "   V-Range:  %lf - %lf\n", v_range[0], v_range[1] );

	fprintf (stderr, "   Surface:\n\n");
	VEdebug_surface( surf, TRUE );

	}  /* VElog_parting_line_data */

