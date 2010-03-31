/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/

class implementation Root;

#define  CHECK_RETURN_CODES 1

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "igetypedef.h"
#include "igrtypedef.h"

#include "bs.h"
#include "bsparameters.h"

#include "emsedgedef.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

#include "go.h"

/* prototype files */
#include "VEpr_utilimp.h"
#include "VEpr_utilfnc.h"

#include "bsalloccv.h"
#include "bsgmcvprop.h"
#include "bscv_copy.h"
#include "bsxtractpar.h"

from EMSedge import EMget_props_type;

/*--- VEget_edge_geom_type -------------------------------------------*/

IGRshort VEget_edge_geom_type(	OM_S_OBJID edge_id,
				OMuword    osnum,
				IGRboolean standalone_curve )

/*
NAME
	VEset_edge_geom_type

DESCRIPTION
	This function gets the geometric edge type for an
	edge.

PARAMETERS
	edge_id (IN) - the object id of the edge whose
	               geometric type is to be gotten
	osnum (IN) - the object space number of the edge
	standalone_curve (IN) - TRUE, if the edge is a standalone curve

GLOBALS USED
	none

HISTORY
	10/13/92    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong  msg;
	IGRuchar etype;
	IGRshort btype;

	etype = EMfreeform_curve;
	if ( standalone_curve )
	   {
	   EFget_the_edge_type_for_an_object( edge_id, osnum, 0, &etype );
	   }
	else
	   {
	   om$send( msg      = message EMSedge.EMget_props_type( &msg, NULL, &etype ),
	            targetid = edge_id,
	            targetos = osnum,
	            senderid = NULL_OBJID );
	   }

	/* map EMS edge type to BS edge type */
	switch ( etype )
	   {
	   case EMcircular_arc :
	      btype = BSCIRC_ARC; break;

	   case EMcircle :
	      btype = BSCIRCLE; break;

	   case EMelliptical_arc :
	      btype = BSELLIP_ARC; break;

	   case EMellipse :
	      btype = BSELLIPSE; break;

	   case EMinfinite_line :
	      btype = BSINF_LINE; break;

	   case EMlinesegment :
	      btype = BSLINE; break;

	   case EMlinestring :
	   case EMorthogonal_linestring :
	   case EMorthogonal_polygon :
	   case EMplanar_linestring :
	   case EMpolygon :
	      btype = BS3DLINESTR; break;

	   case EMpoint :
	      btype = BSPOINT; break;

	   default :
	      btype = BSGEN_BSP_CV; break;

	   }  /* end: switch */

	return( btype );
	}  /* VEset_edge_geom_type */


/*--- VEcreate_2d_curve ----------------------------------------------*/

void VEcreate_2d_curve( edge )

	struct VEedge_header *edge;

/*
NAME
	VEcreate_2d_curve

DESCRIPTION
	This function creates the 2D geometric curve required
	for performing curve/curve intersections.

PARAMETERS
	edge (IN) - the edge whose 2D geometric curve is to be
                    created

GLOBALS USED
	none

HISTORY
	10/14/92    S.P. Rogers
	   Creation Date
*/

	{
	IGRint                  ii;
	BSrc                    rc;
        IGRdouble               dot_tol;
	struct BSgeom_bsp_curve *curve3d, *curve2d;

	if ( edge->gm_curve2d )
	   return;  /* this edge already has a 2D geometric curve */

	curve3d = edge->gm_curve3d;

	curve2d = VEalloc_geom_curve( curve3d->bspcv->order, curve3d->bspcv->num_poles,
                                      curve3d->bspcv->rational, 0 );

	if ( ! curve2d )
	   return;

	edge->gm_curve2d = curve2d;

	BScv_copy( &rc, curve3d->bspcv, curve2d->bspcv );
	   
	/* project the 2d curve to z = 0 */
	for ( ii = 0; ii < curve2d->bspcv->num_poles; ii++ )
	   curve2d->bspcv->poles[ii*3 + 2] = 0.0;

	/* fill in geometric properties, if not present yet */
	if ( ! curve3d->geom_prop )
	   BSgmcvprop( curve3d, &rc );

        BSxtractpar( &rc, BSTOLORTHOVEC, &dot_tol );

	/* Determine the type of the 2D curve */
	/* The planar indicator for the 2D curve is set to FALSE, for  */
	/* most cases to assure a good intersection from curve/curve   */
	/* intersection.  If it is known that the curve is still       */
	/* planar after projection, than the planar bit is left alone. */
	switch ( curve3d->type )
	   {
	   case BSCIRCLE :
	      if ( fabs( curve3d->vec1[2] ) == 1.0 )
	         {
	         curve2d->type = BSCIRCLE;
	         }
	      else if ( fabs( curve3d->vec1[2] ) <= dot_tol )
	         {
	         /* circle degenerates to a line so call it a general Bspline */
	         curve2d->type = BSGEN_BSP_CV;
	         curve2d->bspcv->planar = FALSE;
	         }
	      else
	         {
	         curve2d->type = BSELLIPSE;
	         }
	      break;

	   case BSCIRC_ARC :
	      if ( fabs( curve3d->vec1[2] ) == 1.0 )
	         {
	         curve2d->type = BSCIRC_ARC;
	         }
	      else if ( fabs( curve3d->vec1[2] ) <= dot_tol )
	         {
	         /* circular arc degenerates to a line */
	         curve2d->type = BSGEN_BSP_CV;
	         curve2d->bspcv->planar = FALSE;
	         }
	      else
	         {
	         curve2d->type = BSELLIP_ARC;
	         }
	      break;

	   case BSPARAB_ARC : case BSHYPER_ARC : case BSELLIP_ARC : case BSELLIPSE :
	      /* be safe and call these all general curves */
	      curve2d->type = BSGEN_BSP_CV;
	      curve2d->bspcv->planar = FALSE;
	      break;

	   case BSLINE :
	      if ( (curve3d->pt1[0] == curve3d->pt2[0]) &&
	           (curve3d->pt1[1] == curve3d->pt2[1]) )
	         {
	         /* line degenerates to a point */
	         curve2d->type = BSPOINT;
	         }
	      else
	         {
	         curve2d->type = curve3d->type;
	         }
	      break;

	   case BS3DLINESTR :
	      curve2d->type = curve3d->type;
	      curve2d->bspcv->planar = FALSE;
	      break;

	   case BSGEN_BSP_CV :
	      curve2d->type = curve3d->type;
	      curve2d->bspcv->planar = FALSE;
	      break;

	   default :
	      curve2d->type = curve3d->type;
	      break;
	   }  /* end: switch */

	}  /* VEcreate_2d_curve */


/*--- VEset_split_curve_geom_type -----------------------------------*/

void VEset_split_curve_geom_type( parent_gmcurve, child_gmcurve )

	struct BSgeom_bsp_curve *parent_gmcurve;
	struct BSgeom_bsp_curve *child_gmcurve;

/*
NAME
	VEset_split_curve_geom_type

DESCRIPTION
	This function determines the geometric type of a curve
	split from another curve.

PARAMTERS
	parent_gmcurve (IN) - the parent geometric curve
	child_gmcurve (IN) - the child curve split from the parent

GLOBALS USED
	none

HISTORY
	10/15/92    S.P. Rogers
	   Creation Date
*/

	{

	switch ( parent_gmcurve->type )
	   {
	   case BSCIRCLE :
	      child_gmcurve->type = BSCIRC_ARC;
	      break;

	   case BSELLIPSE :
	      child_gmcurve->type = BSELLIP_ARC;
	      break;

	   case BS3DLINESTR :
	      if ( child_gmcurve->bspcv->num_poles == 2 )
	         {
	         child_gmcurve->type = BSLINE;
	         }
	      else
	         {
	         child_gmcurve->type = BS3DLINESTR;
	         }
	      break;

	   default :
	      child_gmcurve->type = parent_gmcurve->type;
	      break;
	   }  /* end: switch */

	}  /* VEset_split_curve_geom_type */


end implementation Root;

