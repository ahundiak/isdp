
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/


#define CHECK_RETURN_CODES 1

#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "bs.h"
#include "bsisfprtlns.h"
#include "bsparameters.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

#include "go.h"

/* prototype files */
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

#include "bsalloccv.h"
#include "bsactivsplt.h"
#include "bscv_copy.h"

/*----- VEcurve_split ----------------------------------------*/

struct IGRbsp_curve *VEcurve_split( parent_curve, start_u, end_u )

	struct IGRbsp_curve *parent_curve;
	IGRdouble           start_u;
	IGRdouble           end_u;

/*
NAME
	VEcurve_split

DESCRIPTION
	This function takes a curve, a start parameter and an end
	parameter and splits out the portion of the curve between
	the start and end parameter.

PARAMETERS
	parent_curve (IN) - the curve to split from
	start_u (IN) - the starting parameter of the split piece
	end_u (IN) - the ending parameter of the split piece

GLOBALS USED
	none

RETURN VALUES
	A pointer to the split curve is returned.  If the split
	failed, NULL is returned.

HISTORY
	09/17/87    S.P. Rogers
	   Creation Date.
*/


	{
	IGRlong              rc;
	IGRboolean           tst_planar = TRUE;
	struct IGRbsp_curve  temp_curve;
	struct IGRbsp_curve  *new_curve;


	VEget_temp_curve_storage( &temp_curve,
	                          parent_curve->num_poles,
	                          parent_curve->num_knots,
	                          parent_curve->rational );
	   
	/* split out the span into temporary space */
	BSactivsplt( &rc, parent_curve, &start_u, &end_u, &temp_curve, &tst_planar );

	if ( rc != BSSUCC )
	   {
	   /* split failed */
	   return( NULL );
	   }
	   
	/* allocate space for output curve and copy split piece into it */
	BSalloccv( temp_curve.order,
	           temp_curve.num_poles,
	           temp_curve.rational,
	           0,
	   	   &new_curve,
	           &rc );
	   	      
	if ( rc != BSSUCC )
	   {
	   /* allocation failed */
	   return( NULL );
	   }

	BScv_copy( &rc, &temp_curve, new_curve );
	   
	   BS_ERRCHK( rc, "VEcurve_split: BScv_copy failed" );
	   
	return( new_curve );

	}  /* VEcurve_split */


/*----- VEgeom_curve_split ----------------------------------------*/

struct BSgeom_bsp_curve *VEgeom_curve_split( parent_curve, start_u, end_u )

	struct BSgeom_bsp_curve *parent_curve;
	IGRdouble               start_u;
	IGRdouble               end_u;
	
/*
NAME
	VEgeom_curve_split

DESCRIPTION
	This function takes a curve, a start parameter and an end
	parameter and splits out the portion of the curve between
	the start and end parameter.

PARAMETERS
	parent_curve (IN) - the geometric curve to split from
	start_u (IN) - the starting parameter of the split piece
	end_u (IN) - the ending parameter of the split piece

GLOBALS USED
	none

RETURN VALUES
	A pointer to the split curve is returned.  If the split
	failed, NULL is returned.

HISTORY
	09/17/87    S.P. Rogers
	   Creation Date.
*/

	{
	IGRlong                  rc;
	IGRboolean               tst_planar = TRUE;
	struct IGRbsp_curve      temp_curve;
	struct BSgeom_bsp_curve  *new_curve;


	VEget_temp_curve_storage( &temp_curve,
	                          parent_curve->bspcv->num_poles,
	                          parent_curve->bspcv->num_knots,
	                          parent_curve->bspcv->rational );
	   
	/* split out the span into temporary space */
	BSactivsplt( &rc, parent_curve->bspcv, &start_u, &end_u, &temp_curve, &tst_planar );

	if ( rc != BSSUCC )
	   {
	   /* split failed */
	   return( NULL );
	   }
	   
	new_curve = VEalloc_geom_curve( temp_curve.order, temp_curve.num_poles,
	                                temp_curve.rational, 0 );

	if ( ! new_curve )
	   return( NULL );

	BScv_copy( &rc, &temp_curve, new_curve->bspcv );
	   
	   BS_ERRCHK( rc, "VEgeom_curve_split: BScv_copy failed" );
	   
	VEset_split_curve_geom_type( parent_curve, new_curve );

	return( new_curve );

	}  /* VEgeom_curve_split */


/*----- VEedge_split -------------------------------------------------------*/

struct VEedge_header *VEedge_split( parent_edge, u_start, u_end )

	struct VEedge_header *parent_edge;
	IGRdouble            u_start;
	IGRdouble            u_end;
	
/*
NAME
	VEedge_split

DESCRIPTION
	This function splits an edge between a starting and ending parameter.
	The edge that is returned has its visibility list initialized
	to VISIBLE and inherits the same status field bits as its parent.

PARAMETERS
	parent_edge (IN) - the edge to split
	u_start (IN) - the starting parameter of the split piece
	u_end (IN) - the ending parameter of the split piece

RETURN VALUES
	A pointer to the split edge is returned. A NULL pointer is returned
	if the split could not be performed.
	
GLOBALS USED
	none

HISTORY
	10/28/87    S.P. Rogers
	   Creation Date
*/

	{
	struct VEedge_header    *edge;
	struct BSgeom_bsp_curve *gmcurve;

	/* split out poriton of curve definition */
	gmcurve = VEgeom_curve_split( parent_edge->gm_curve3d, u_start, u_end );
	
	if ( ! gmcurve )
	   {
	   /* split failed => return NULL */
	   return( NULL );
	   }
	   
	edge               = VEalloc_edge_header();
	edge->gm_curve3d   = gmcurve;
	edge->type         = parent_edge->type;
	edge->edge_id      = parent_edge->edge_id;
	edge->iso_parm     = parent_edge->iso_parm;
	edge->num_sh_spans = 0;
	edge->status       = parent_edge->status;

	if ( parent_edge->gm_curve3d->bspcv->planar )
	   edge->status |= SPLIT_FROM_PLANAR_PARENT;
	
	edge->visib_list = VEconstruct_visib_list( gmcurve->bspcv, VISIBLE );
	
	return( edge );
	
	}  /* VEedge_split */
	
	
/*----- VEsplit_out_temp_list_overlaps ----------------------------------------*/

void VEsplit_out_temp_list_overlaps( edge, head, tail )

	struct VEedge_header *edge;
	struct VEedge_header **head;
	struct VEedge_header **tail;

/*
NAME
	VEsplit_out_temp_list_overlaps

DESCRIPTION
	This function takes an edge that has OVERLAPPED spans in its temp
	list and splits it into several edges with no OVERLAPPED spans.  The
	edges are returned as a linked list whose beginning is pointed to by
	'head' and whose end is pointed to by 'tail'.

PARAMETERS
	edge (IN) - the edge whose temp list overlaps are to be split out
	head (OUT) - pointer to the head of the resulting list
	tail (OUT) - pointer to the tail of the resulting list

NOTES
	The edge header that is passed into the function is returned
	to the free pool of edge headers and is therefore invalid
	when this function returns.
	       
GLOBALS USED
	none

HISTORY
	09/10/88    S.P. Rogers
	   Creation Date.
*/

	{
	struct VEedge_header    *new_edge;
	struct VEtemp_node      *end_node;
	struct VEtemp_node      *start_node;
	struct VEtemp_node      *cur_node;
	struct VEtemp_node      *temp_node;
	struct BSgeom_bsp_curve *gmcurve;


	*head = *tail = NULL;
	cur_node = edge->temp_list;
	   
	/* skip over leading overlapped span */
	if ( cur_node->next_visib == OVERLAPPED )
	   {
	   temp_node = cur_node;
	   cur_node = cur_node->next;
	   VEfree_temp_node( temp_node );
	   }
	   
	/* loop through temp node list splitting out OVERLAPPED segments */
	while ( cur_node != NULL )
	   {
	   if ( cur_node->next == NULL )
	      {
	      /* temp list ended with an OVERLAPPED span so we are done */
	      VEfree_temp_node( cur_node );
	      break;
	      }

	   start_node = cur_node;
	   
	   /* skip to the beginning of the next OVERLAPPED span */
	   while ( (cur_node->next != NULL) && (cur_node->next_visib != OVERLAPPED) )
	      {
	      cur_node = cur_node->next;
	      }

	   end_node       = cur_node;
	   cur_node       = cur_node->next;
	   end_node->next = NULL;
	   
	   start_node->prev_visib = UNKNOWN;
	   end_node->next_visib   = UNKNOWN;
	   
	   /* create and initialize edge header for this segment */
	   gmcurve = VEgeom_curve_split( edge->gm_curve3d, start_node->u, end_node->u );
	   if ( gmcurve != NULL )
	      {
	      /* the curve split succeeded */
	      new_edge = VEalloc_edge_header();
	      new_edge->gm_curve3d    = gmcurve;
	      new_edge->type          = edge->type;
	      new_edge->iso_parm      = edge->iso_parm;
	      new_edge->sh_spans      = edge->sh_spans;
	      new_edge->num_sh_spans  = 0;
	      new_edge->shared_edge   = edge->shared_edge;
	      new_edge->shared_elem   = edge->shared_elem;
	      new_edge->edge_id       = edge->edge_id;
	      new_edge->status        = edge->status;

	      /* make sure the temp list for this edge reflects the */
	      /* parameterization of the curve that was split out   */
	      start_node->u = gmcurve->bspcv->knots[ gmcurve->bspcv->order - 1 ];
	      end_node->u   = gmcurve->bspcv->knots[ gmcurve->bspcv->num_knots - gmcurve->bspcv->order ];
	      new_edge->temp_list = start_node;

	      /* construct a visib list for the new edge */
	      new_edge->visib_list = VEconstruct_visib_list( gmcurve->bspcv, VISIBLE );

	      /* update the range of the new edge */
	      VEfind_curve_range( gmcurve->bspcv, new_edge->range );
	   
	      /* add new edge to list */
	      if ( *tail == NULL )
	         *head = new_edge;
	      else
	         (*tail)->next = new_edge;

	      *tail = new_edge;
	      }  /* end:  if ( gmcurve != NULL ) */
	   else
	      {
	      /* splitting the curve failed => skip this piece */
	      /* free the temp node list for this piece        */
	      VEfree_temp_node_list( start_node );
	      }  /* end: else */
	      
	   }  /* end:  while ( cur_node != NULL ) */

	/* free the edge header passed in and its visibility list */
	VEfree_visib_node_list( edge->visib_list );
	VEfree_edge_header( edge );

	}  /* VEsplit_out_temp_list_overlaps */


/*--- VEsplit_out_hidden_pieces --------------------------------------------*/

void VEsplit_out_hidden_pieces( edge, visib_head, visib_tail, hidden_head, hidden_tail )

	struct VEedge_header *edge;
	struct VEedge_header **visib_head, **visib_tail;
	struct VEedge_header **hidden_head, **hidden_tail;

/*
NAME
	VEsplit_out_hidden_pieces

DESCRIPTION
	This function takes an edge that and breaks it into two lists of
	edges.  One containing the VISIBLE pieces and one containing the
	HIDDEN/OVERLAPPED pieces.  These two lists are returned via pointers
	to the heads and tails.

PARAMETERS
	edge (IN) - the edge to be split into visible and hidden/overlapped
	            pieces
	visib_head (OUT) - pointer to the head of the list of visible pieces
	visib_tail (OUT) - pointer to the tail of the list of visible pieces
	hidden_head (OUT) - pointer to the head of the list of hidden pieces
	hidden_tail (OUT) - pointer to the tail of the list of hidden pieces

NOTES
	The edge header that is passed into the function is returned
	to the free pool of edge headers and is therefore invalid
	when this function returns.
	       
GLOBALS USED
	none

HISTORY
	09/07/90    S.P. Rogers
	   Creation Date.
*/

	{
	IGRshort                this_visib;
	struct VEedge_header    *new_edge;
	struct VEvisib_node     *end_node;
	struct VEvisib_node     *start_node;
	struct VEvisib_node     *cur_node, *prev_node;
	struct BSgeom_bsp_curve *gmcurve;


	*visib_head = *visib_tail = *hidden_head = *hidden_tail = NULL;
	cur_node = edge->visib_list;

	/* loop through temp node list splitting out segments */
	while ( cur_node->next )
	   {
	   start_node = cur_node;
	   this_visib = cur_node->visib;
		   
	   prev_node = start_node;
	   while ( cur_node->next )
	      {
	      if ( (this_visib == VISIBLE) && (cur_node->visib != VISIBLE) )
	         break;  /* change from VISIBLE to non VISIBLE */
	      else if ( (this_visib != VISIBLE) && (cur_node->visib == VISIBLE) )
	         break;  /* change from non VISIBLE to VISIBLE */
	      else
	         {
	         prev_node = cur_node;
	         cur_node = cur_node->next;
	         }
	      }

	   if ( cur_node->next )
	      {
	      /* duplicate cur_node because we aren't at the end of the visib list */
	      prev_node->next = end_node = VEalloc_visib_node( cur_node->u );
	      end_node->visib = this_visib;
	      end_node->next = NULL;
	      }
	   else
	      end_node = cur_node;  /* use cur_node because we're at end of visib list */
	   
	   /* create and initialize edge header for this segment */
	   gmcurve = VEgeom_curve_split( edge->gm_curve3d, start_node->u, end_node->u );
	   if ( gmcurve )
	      {
	      /* the curve split succeeded */
	      new_edge = VEalloc_edge_header();
	      new_edge->gm_curve3d    = gmcurve;
	      new_edge->type          = edge->type;
	      new_edge->iso_parm      = edge->iso_parm;
	      new_edge->sh_spans      = NULL;
	      new_edge->num_sh_spans  = 0;
	      new_edge->shared_edge   = NULL;
	      new_edge->edge_id       = edge->edge_id;
	      new_edge->status        = edge->status;

	      /* make sure the temp list for this edge reflects the */
	      /* parameterization of the curve that was split out   */
	      start_node->u = gmcurve->bspcv->knots[ gmcurve->bspcv->order - 1 ];
	      end_node->u   = gmcurve->bspcv->knots[ gmcurve->bspcv->num_knots - gmcurve->bspcv->order ];
	      new_edge->temp_list = NULL;
	      new_edge->visib_list = start_node;

	      /* update the range of the new edge */
	      VEfind_curve_range( gmcurve->bspcv, new_edge->range );
	   
	      /* add new edge to list */
	      if ( this_visib == VISIBLE )
	         {
	         if ( *visib_tail == NULL )
	            *visib_head = new_edge;
	         else
	            (*visib_tail)->next = new_edge;
	         *visib_tail = new_edge;
	         }
	      else
	         {
	         if ( *hidden_tail == NULL )
	            *hidden_head = new_edge;
	         else
	            (*hidden_tail)->next = new_edge;
	         *hidden_tail = new_edge;
	         }

	      }  /* end:  if ( gmcurve != NULL ) */
	   else
	      {
	      /* splitting the curve failed => skip this piece */
	      /* free the temp node list for this piece        */
	      VEfree_visib_node_list( start_node );
	      }  /* end: else */
	      
	   }  /* end:  while ( cur_node != NULL ) */

	/* free the edge header passed in (its visib list */
	/* was consumed during the splitting process)     */
	VEfree_edge_header( edge );
	
	}  /* VEsplit_out_hidden_pieces */
