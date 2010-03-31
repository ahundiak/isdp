
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <alloca.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "bs.h"
#include "bsparameters.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_utilfnc.h"
#include "VEpr_hiding.h"

#include "bsarclen.h"
#include "bsactivsplt.h"
#include "bscvkttol2.h"
#include "bscveval.h"
#include "bsprptoncv.h"
#include "bsptsdlcv.h"
#include "bststcvfln.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static IGRboolean VEget_gap_param __((	struct IGRbsp_curve  *curve,
					IGRdouble            base_par,
					IGRdouble            dir_par,
					IGRdouble            *gap_param ));

static void VEgap_span __(( 		struct VEedge_header *edge,
					struct IGRbsp_curve  *curve,
					IGRdouble            knot_tol,
					IGRboolean           gap_left,
					IGRboolean           gap_right,
					IGRdouble            span_start,
					IGRdouble            span_end ));

#if defined(__cplusplus)
}
#endif

#undef __

/* Extern Global Variables */
extern struct VEexecution_parms  VEexec_parms;
extern struct VEtolerance_info   VEtolerances;


/*--- VEmark_degenerate_spans ------------------------------------------------------*/

void VEmark_degenerate_spans( curve, visib_list, temp_curve )

	struct IGRbsp_curve *curve;
	struct VEvisib_node *visib_list;
	struct IGRbsp_curve *temp_curve;

/*
NAME
	VEmark_degenerate_spans

DESCRIPTION
	This function loops through the visibility list of an edge marking all
	spans that collapse to a point as degenerate.  If the two end points
	of the span are equal, then the span is split out from the curve and
	BStstcvfln() is called to see the span collapses to a point.  If any
	failures in the math routines occur, the span is also called
	degenerate.

PARAMETERS
	curve (IN) - the curve whose degenerate spans are to be marked
	visib_list (IN/OUT) - the visibility list of the curve whose
	                      degenerate spans are to be marked
	temp_curve (IN) - temporary curve storage that is at least as large
	                  as the curve passed in

GLOBALS USED
	VEtolerances

HISTORY
	08/24/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    rc;
	IGRshort   is_line;
	IGRboolean tst_planar = FALSE;
	IGRint     ii;
	IGRdouble  dist_sq;
	IGRdouble  dist_tol_sq;
	IGRdouble  start_pt[3];
	IGRdouble  end_pt[3];
	IGRdouble  *z_poles;

	/* zero out the Z poles of the curve */
	z_poles = (IGRdouble *) alloca( curve->num_poles * sizeof( IGRdouble ) );
	for ( ii = 0; ii < curve->num_poles; ii++ )
	   {
	   z_poles[ii] = curve->poles[ii*3+2];
	   curve->poles[ii*3+2] = 0.0;
	   }

	dist_tol_sq = VEtolerances.VEsystem_base_tol * VEtolerances.VEsystem_base_tol;

	/* loop through all spans of this edge marking */
	/* spans that collape to a point as degenerate */
	while ( visib_list->next )
	   {
           BScveval( curve, visib_list->u, 0, (IGRpoint *)start_pt, &rc );

              BS_ERRCHK( rc, "VEmark_degenerate_spans:  BScveval failed" );

           BScveval( curve, visib_list->next->u, 0, (IGRpoint *)end_pt, &rc );

              BS_ERRCHK( rc, "VEmark_degenerate_spans:  BScveval failed" );

	   dist_sq = (start_pt[0] - end_pt[0]) * (start_pt[0] - end_pt[0]) +
	             (start_pt[1] - end_pt[1]) * (start_pt[1] - end_pt[1]);

	   if ( dist_sq <= dist_tol_sq )
	      {
	      /* start and end point are within tolerance => split this region out       */
	      /* into a temporary curve and see if the whole span degenerates to a point */

	      BSactivsplt( &rc, curve,
	                   &visib_list->u, &visib_list->next->u,
	                   temp_curve, &tst_planar );

	      if ( rc == BSSUCC )
	         {
	         /* see if the curve can be represented as a 2 point linestring */
	         BStstcvfln( temp_curve,
	                     &is_line, start_pt, end_pt, &rc );

	         if ( rc == BSSUCC )
	            {
	            if ( is_line == 2 )
	               {
	               /* curve degenerated to a point => don't output anything */
	               visib_list->visib = DEGENERATE_SPAN;
	               }
	            }
	         else
	            {
	            visib_list->visib = DEGENERATE_SPAN;
	            }
	         }
	      else
	         {
	         visib_list->visib = DEGENERATE_SPAN;
	         }
	      }  /* end: start and end point within tolerance */

	   visib_list = visib_list->next;
	   }

	/* restore the Z poles of the curve */
	for ( ii = 0; ii < curve->num_poles; ii++ )
	   curve->poles[ii*3+2] = z_poles[ii];

	}  /* VEmark_degenerate_spans */


/*---- VEget_gap_param -----------------------------------------------------------*/

static IGRboolean VEget_gap_param( curve, base_par, dir_par, gap_param )

	struct IGRbsp_curve *curve;
	IGRdouble           base_par;
	IGRdouble           dir_par;
	IGRdouble           *gap_param;

/*
NAME
	VEget_gap_param (static)

DESCRIPTION
	Given a curve, a base parameter, and a direction parameter, this
	function calculates a parameter on the curve that is the "gapping
	distance" away from the base parameter in the direction of the
	direction parameter.

PARAMETERS
	curve (IN) - the curve whose parameter is to be gapped
	base_par (IN) - the parameter to gap
	dir_par (IN) - a parameter indicating the direction to gap
	gap_param (OUT) - the gapped parameter value

GLOBALS USED
	VEexec_parms

RETURN VALUES
	TRUE - if the gapping was successful
	FALSE, if the gapping failed

NOTES
	Gapping distance is a model space distance that is accessed through the 
	global variable: VEexec_parms.VEgapping_distance.

HISTORY
	08/24/89    S.P. Rogers
	   Creation Date
*/

	{
	BSrc       rc;
	IGRpoint   dir_pt;
	IGRpoint   gap_pt;
	IGRboolean on_curve;
  
	      
	/* get the direction point */
	BScveval( curve, dir_par, 0, (IGRpoint *)dir_pt, &rc );

	   BS_ERRCHK( rc, "VEget_gap_param: BScveval failed" );

	if ( rc == BSSUCC )
	   {
	   BSptsdlcv( &rc, curve, &base_par, dir_pt,
	              &VEexec_parms.VEgapping_distance, gap_pt );

	      BS_ERRCHK( rc, "VEget_gap_param: BSptsdlcv failed" );

	   if ( rc != BSSUCC )
	      return( FALSE );

	   BSprptoncv( &rc, curve, gap_pt, gap_param, &on_curve );

	      BS_ERRCHK( rc, "VEget_gap_param: BSprptoncv failed" );

	   if (rc != BSSUCC)
	     return( FALSE );
	   else
	      return( on_curve );
	   }
	else
	   return( FALSE );

	}  /* VEget_gap_param */


/*--- VEgap_span --------------------------------------------------------------*/

static void VEgap_span(	struct VEedge_header *edge,
			struct IGRbsp_curve  *curve,
			IGRdouble            knot_tol,
			IGRboolean           gap_left,
			IGRboolean           gap_right,
			IGRdouble            span_start,
			IGRdouble            span_end )

/*
NAME
	VEgap_span (static)

DESCRIPTION
	This function applies to gaps to the left side, right side or both
	sides of a span.  It calculates new parameters on the curve that
	represent the gapping distance and puts overlaps on the temp list of
	the edge to represent the gaps.

PARAMETERS
	edge (IN) - the edge whose span is to be gapped
	curve (IN) - the curve geometry for the edge
	knot_tol (IN) - the knot tolerance for the curve
	gap_left (IN) - if TRUE, gap the left edge of the span
	gap_right (IN) - if TRUE, gap the right edge of the span
	span_start (IN) - the left edge of the span
	span_end (IN) - the right edge of the span

GLOBALS USED
	VEexec_parms

HISTORY
	08/24/89    S.P. Rogers
	   Creation Date
	07/13/90    S.P. Rogers
	   Changed to add overlap region to edge's temp list
*/

	{
	IGRlong   rc;
	IGRlong   sts;
	IGRdouble mid;
	IGRdouble arc_len;
	IGRdouble gap_param;

	/* check the arc length of this span to make sure */
	/* it is long enough to gap                       */
	mid = (span_start + span_end) / 2.0;
	(void) BSarclen( &rc, (IGRboolean *)&sts, curve, &span_start, &span_end, &mid, &arc_len );

	if ( rc == BSSUCC )
	   {
	   if ( gap_left )
	      arc_len -= VEexec_parms.VEgapping_distance;

	   if ( gap_right )
	      arc_len -= VEexec_parms.VEgapping_distance;
	   }
	else
	   arc_len = 0.0;

	if ( arc_len <= 0.0 )
	   {
	   /* arc len is not long enough to gap => make entire span overlapped */ 
	   VEadd_overlap_region( span_start, span_end, edge, UNKNOWN, knot_tol );
	   return;
	   }

	if ( gap_left )
	   {
	   /* gap the left side of this span */
	   if ( VEget_gap_param( curve, span_start, span_start + 10 * knot_tol, &gap_param ) )
	      VEadd_overlap_region( span_start, gap_param, edge, UNKNOWN, knot_tol );
	   }  /* end: if ( gap_left ) */

	if ( gap_right )
	   {
	   /* gap the right side of this span */
	   if ( VEget_gap_param( curve, span_end, span_end - 10 * knot_tol, &gap_param ) )
	      VEadd_overlap_region( gap_param, span_end, edge, UNKNOWN, knot_tol );
	   }  /* end: if ( gap_right ) */

	}  /* VEgap_span */


/*--- VEgap_edge ---------------------------------------------------------------*/

void VEgap_edge( struct VEedge_header *edge,
		 IGRboolean           creating_hidden_edges )

/*
NAME
	VEgap_edge

DESCRIPTION
	This function gaps the visiblity transitions of an edge by adding
	small overlapped regions where the gaps should be.  The degenerate
	visibility spans of the edge should be flagged as degenerate before
	this function is called.  The function to find and mark degenerate
	spans is:  VEmark_degenerate_spans().

PARAMETERS
	edge (IN) - the edge to gap
	creating_hidden_edges (IN) - TRUE, if hidden edges are being output

GLOBALS USED
	none

HISTORY
	07/13/90    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong             rc;
	IGRshort            prev_visib, last_visib, next_visib;
	IGRboolean          gap_left, gap_right;
	IGRint              ii;
	IGRdouble           knot_tol;
	IGRdouble           span_start, span_end;
	IGRdouble           *z_poles;
	struct IGRbsp_curve *curve;
	struct VEvisib_node *first_non_degen, *last_non_degen;
	struct VEvisib_node *temp_span;
	struct VEvisib_node *cur_node;

	curve = edge->gm_curve3d->bspcv;

	/* zero out the Z poles of the curve */
	z_poles = (IGRdouble *) alloca( curve->num_poles * sizeof( IGRdouble ) );
	for ( ii = 0; ii < curve->num_poles; ii++ )
	   {
	   z_poles[ii] = curve->poles[ii*3+2];
	   curve->poles[ii*3+2] = 0.0;
	   }

	/* put a temp-list on the edge */
	edge->temp_list = VEalloc_temp_node( curve->knots[curve->order - 1] );
	edge->temp_list->next = VEalloc_temp_node( curve->knots[curve->num_knots - curve->order] );
	
	/* get the knot tolerance for this curve (used for gapping calculations) */
	BScvkttol2( curve->order, curve->knots, curve->num_poles,
	            curve->poles, curve->weights, &knot_tol, &rc );

	/* determine the first and last non-degenerate spans of the edge */
	first_non_degen = edge->visib_list;
	while ( first_non_degen->visib == DEGENERATE_SPAN )
	   first_non_degen = first_non_degen->next;

	last_non_degen = temp_span = first_non_degen;
	while ( temp_span->next )
	   {
	   if ( temp_span->visib != DEGENERATE_SPAN )
	      last_non_degen = temp_span;
	   temp_span = temp_span->next;
	   }

	/* set up prev and last visib variables to be used for gapping */
	if ( curve->phy_closed )
	   {
	   prev_visib = last_non_degen->visib;
	   last_visib = first_non_degen->visib;
	   }
	else
	   {
	   last_visib = last_non_degen->visib;
	   prev_visib = first_non_degen->visib;
	   }

  	/* loop through all of the spans of this edge */
	cur_node = edge->visib_list;
	while ( cur_node->next )
	   {
	   /* skip over degenerate spans */
	   while ( (cur_node->next) && (cur_node->visib == DEGENERATE_SPAN) )
	      cur_node = cur_node->next;

	   if ( ! cur_node->next )
	      break;

	   span_start = cur_node->u;
	   span_end   = cur_node->next->u;

	   /* find visibility of the next non-degenerate span */
	   next_visib = last_visib;
	   temp_span = cur_node->next;
	   while( temp_span->next )
	      {
	      if ( temp_span->visib != DEGENERATE_SPAN )
	         {
	         next_visib = temp_span->visib;
	         break;
	         }
	      temp_span = temp_span->next;
	      }

	   if ( (cur_node->visib == VISIBLE) ||
	        ( (cur_node->visib == HIDDEN) && (creating_hidden_edges) ) )
	      {
	      /* see if this span should be gapped based on the visibilities */
	      /* of the previous and next non-degenerate spans               */
	      gap_left = (prev_visib != cur_node->visib);
	      gap_right = (next_visib != cur_node->visib);

	      if ( gap_left || gap_right )
	         {
	         VEgap_span( edge, curve, knot_tol,
	                     gap_left, gap_right, span_start, span_end );
	         }
	      }

	   prev_visib = cur_node->visib;
	   cur_node = cur_node->next;
	   }  /* end: while */

	/* merge OVERLAPPED spans on temp-list into visib-list */
	VEmerge_visibs( edge );

	/* restore the Z poles of the curve */
	for ( ii = 0; ii < curve->num_poles; ii++ )
	   curve->poles[ii*3+2] = z_poles[ii];

	}  /* VEgap_edge */
