
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES	1

#include <stdio.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"

#include "bs.h"
#include "bsparameters.h"

#include "msdef.h"
#include "gr.h"

#include "igrdp.h"
#include "godef.h"
#include "go.h"

#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
   
#include "ve_timing.h"
#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_utilimp.h"
#include "bscveval.h"
#include "bsprptonsf.h"

#if TIMING
extern IGRdouble  VEtime_ptloc;
extern IGRint     VEcount_ptloc;
extern struct tms VEs_time;
extern struct tms VEe_time;
#endif

extern IGRboolean                VEuse_classification_alg;

from EMSedge     import EMendpts;
from EMSloopset  import EMpt_location;

/*-- VEfind_edge_that_endpoint_touches --------------------------------------*/

static void VEfind_edge_that_endpoint_touches(
	IGRdouble               *uv_pt,
	struct VEelement_header *element )

/*
NAME
	VEfind_edge_that_endpoint_touches (static)

DESCRIPTION
	This function takes the endpoint of a parting line, uv_pt, determines
	which edge in the loopset of an element it touches and sets the 
	TRIMMED_A_PARTING_LINE bit in the edge's status field.

PARAMETERS
	uv_pt (IN) - the UV value of the parting line endpoint
	element (IN) - the element whose edges are to be searched

GLOBALS USED
	none

HISTORY
	04/10/92  S.P. Rogers
	   Creation Date
*/
	
	{
	IGRlong               sts, msg;
	struct EMSptloc_info  loc;
	struct EMSpartolbasis partol;
	struct VEedge_header  *real_edge;
	struct VEedge_header  *this_edge;

	loc.options = EMS_PTLOC_CLOSEST_EDGE;

	partol.tol      = 0.000001;
	partol.is_valid = TRUE;
	
	/* send EMpt_location to the loopset for this surface */
#if TIMING
	times( &VEs_time );
#endif
		    
	sts = om$send( msg          = message EMSloopset.EMpt_location( &msg,
		       	                                                uv_pt,
		       	                                                &loc,
		       	                                                &partol ),
		       senderid     = NULL_OBJID,
		       targetid     = element->loopset_id,
	               targetos     = element->env->osnum );
		       
#if TIMING
	times( &VEe_time );

	VEcount_ptloc++;
	VEtime_ptloc += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                    (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif

	   OM_ERRCHK( sts, "VEadd_split_points_to_edge: EMSloopset.EMpt_location send failed" );
	   MSG_ERRCHK( msg, "VEadd_split_points_to_edge: EMSloopset.EMpt_location failed" );
	   
	if ( (loc.location == EMS_L_ONEDGE) || (loc.location == EMS_L_ONVRTX) )
	   {
	   /* end point was on an edge/vertex */
	   this_edge = element->edges;
	   while ( this_edge )
	      {
	      if ( this_edge->edge_id == loc.edge[0].edge_id )
	         {
	         if ( this_edge->gm_curve3d )
	            real_edge = this_edge;
	         else
	            real_edge = this_edge->shared_edge;

	         real_edge->status |= TRIMMED_A_PARTING_LINE;
	         break;
	         }

	      this_edge = this_edge->next;

	      }  /* end: while ( this_edge ) */

	   }  /* end: endpoint on an edge */

	}   /* VEfind_edge_that_endpoint_touches */


/*--- VEset_trimmed_a_parting_line_bits -------------------------------*/

void VEdetermine_edges_that_trim_parting_lines( elem )

	struct VEelement_header *elem;

/*
NAME
	VEdetermine_edges_that_trim_parting_lines

DESCRIPTION
	Given an element, this function finds which edges the endpoints of the 
	parting lines touch and sets the TRIMMED_A_PARTING_LINE bit in their
	status field.

PARAMETERS
	elem (IN) - the element whose edges are to have their
	            TRIMMED_A_PARTING_LINE bit set

GLOBALS USED
	VEuse_classifcation_alg  - referenced to determine if classification
	                           should be done

HISTORY
	04/10/92    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong                 sts, msg, rc;
	IGRboolean              on_surf;
	IGRdouble               beg_pt[2], end_pt[2];
	IGRdouble               xyz[3];
	struct VEelement_header *first_elem;
	struct VEedge_header    *this_edge;

	if ( elem->type == SOLID_HEADER )
	   {
	   if ( VEuse_classification_alg )
	      {
	      /* don't need to do this for classified solids because their */
	      /* edges will be split at parting line endpoints as part of  */
	      /* the classification process                                */
	      return;
	      }
	   elem = elem->next_in_solid;  /* skip solid header */
	   }

	/* loop over all elements */
	first_elem = elem;
	while ( elem )
	   {
	   /* loop over all the edges for this element */
	   this_edge = elem->edges;
	   while ( this_edge )
	      {
	      if ( this_edge->type == HORIZON_EDGE )
	         {
	         /* get beginning and ending points of the parting line in UV space */
	         sts = om$send( msg      = message EMSedge.EMendpts( &msg, beg_pt, end_pt,
	                                                             NULL, NULL, NULL ),
	                        senderid = NULL_OBJID,
	                        targetid = this_edge->edge_id,
	                        targetos = first_elem->env->osnum );

	         /* mark the edges that touch the beginning and ending points */
	         if ( (1 & sts & msg) )
	            {
	            VEfind_edge_that_endpoint_touches( beg_pt, first_elem );
	            VEfind_edge_that_endpoint_touches( end_pt, first_elem );
	            }

	         }  /* end: if */
	      else if ( this_edge->type == HORIZON_CURVE )
	         {
	         /* map endpoints of curve to surface */
	         BScveval( this_edge->gm_curve3d->bspcv, 0.0, 0, (IGRpoint *)xyz, &rc );
	         if ( rc == BSSUCC )
	            {
	            BSprptonsf( &rc, elem->geom.gmsurf->bspsf, xyz, &beg_pt[0], &beg_pt[1], &on_surf );
	            if ( rc == BSSUCC )
	               {
	               VEfind_edge_that_endpoint_touches( beg_pt, first_elem );
	               }
	            }

	         BScveval( this_edge->gm_curve3d->bspcv, 1.0, 0, (IGRpoint *)xyz, &rc );
	         if ( rc == BSSUCC )
	            {
	            BSprptonsf( &rc, elem->geom.gmsurf->bspsf, xyz, &end_pt[0], &end_pt[1], &on_surf );
	            if ( rc == BSSUCC )
	               {
	               VEfind_edge_that_endpoint_touches( end_pt, first_elem );
	               }
	            }

                 }

	      this_edge = this_edge->next;
	      }  /* end: while ( this_edge ) */

	   elem = elem->next_in_solid;
	   }  /* end: while ( elem ) */

	}  /* VEdetermine_edges_that_trim_parting_lines */

end implementation Root;
