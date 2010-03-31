
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/


#define  CHECK_RETURN_CODES 1


#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "bs.h"

#include "igrdp.h"
#include "dpstruct.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

#include "go.h"

/* prototype files */
#include "VEpr_marking.h"
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

#include "bscv_copy.h"

/* External Variables */
extern struct VEexecution_status VEexec_status;


/*---- VEmark_curve_or_point -----------------------------------------------*/

struct VEedge_header *VEmark_curve_or_point( struct VEelement_header *element,
					     struct IGRbsp_curve     *curve,
					     IGRshort                type,
					     IGRint                  edge_id )

/*
NAME
	VEmark_curve_or_point

DESCRIPTION
	Mark the edges of a standalone curve or point (i.e., create an edge
	that represents the curve)

PARAMETERS
	element (IN) - the element that owns the curve
	curve (IN) - the geometry of the curve or point
	type (IN) - the type of object, CURVE or POINT
	edge_id (IN) - the object id of the curve or point object

RETURN VALUES
	A pointer to the edge representing the curve/point is returned.

GLOBALS USED
	none

HISTORY
	09/29/87    S.P. Rogers
	   Creation Date
*/

	{
	BSrc                  rc;
	struct VEedge_header  *edge;


	edge = VEalloc_edge_header();
	if ( ! edge )
	   return( NULL );
	
	edge->gm_curve3d = VEalloc_geom_curve( curve->order, curve->num_poles,
	                                       curve->rational, curve->num_boundaries );
	               
	if ( ! edge->gm_curve3d )
	  {
	  VEfree_edge_header( edge );
	  return( NULL );
	  }

	BScv_copy( &rc, curve, edge->gm_curve3d->bspcv );

	   BS_ERRCHK( rc, "VEmark_curve: BScv_copy failed" );

	edge->edge_id = edge_id;
	edge->type    = ( type == CURVE ) ? STANDALONE : SINGLE_POINT;
	edge->status  = 0;

	edge->gm_curve3d->type = VEget_edge_geom_type( edge->edge_id, element->env->osnum, TRUE );
	edge->gm_curve3d->geom_prop = FALSE;
	edge->gm_curve3d->bscv_flag = TRUE;

	edge->visib_list = VEconstruct_visib_list( edge->gm_curve3d->bspcv, VISIBLE );

	return( edge );
	
	}  /* VEmark_curve_or_point */

