
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
#include "bsparameters.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_utilfnc.h"

#include "bsconstprcv.h"

/* External Variables */
extern struct VEexecution_status VEexec_status;

/*--- VEconstruct_visib_list -------------------------------------*/

struct VEvisib_node *VEconstruct_visib_list( struct IGRbsp_curve *curve,
					     IGRshort            visib )

/*
NAME
	VEconstruct_visib_list

DESCRIPTION
	This function constructs and returns the default visibility
	list for a curve.

PARAMETERS
	curve (IN) - the curve to construct the visib list for
	visib (IN) - the visibility to initialize the visib list with

RETURN VALUES
	A pointer to the head of the visib list is returned

GLOBALS USED
	none

HISTORY
	07/17/90    S.P. Rogers
	   Creation Date
*/

	{
	struct VEvisib_node *v_node;

	v_node         = VEalloc_visib_node( curve->knots[ curve->order - 1 ] );
	v_node->next   = VEalloc_visib_node( curve->knots[ curve->num_knots - curve->order ] );
	v_node->visib = v_node->next->visib = visib;

	return( v_node );
	
	}  /* VEconstruct_visib_list */


/*---- VEadd_edges_to_list -----------------------------------------------*/

void VEadd_edges_to_list( edges, head, tail )

	struct VEedge_header *edges;
	struct VEedge_header **head;
	struct VEedge_header **tail;

/*
NAME
	VEadd_edges_to_list

DESCRIPTION
	This function adds a list of edge headers to the end of a list
	of edge headers.

PARAMETERS
	edges (IN) - list of edges to add
	head (IN/OUT) - head of the list to add to
	tail (IN/OUT) - tail of the list to add to

GLOBALS USED
	none

HISTORY
	S.P. Rogers  09/18/87  Creation Date
*/

	{
	if ( edges )
	   {
	   if ( *head == NULL )
	      *head = *tail = edges;
	   else
	      (*tail)->next = edges;

	   while ( (*tail)->next != NULL )
	      (*tail) = (*tail)->next;

	   }  /* end: if ( edges ) */

	}  /* VEadd_edges_to_list */
	   

/*---- VEconstruct_iso_edge -------------------------------------------------------*/

struct VEedge_header *VEconstruct_iso_edge( struct IGRbsp_surface  *surf,
					    IGRint                 par_option_arg,
					    IGRdouble              parm,
					    IGRshort               edge_type )

/*
NAME
	VEconstruct_iso_edge

DESCRIPTION
	This routine allocates an edge header, initializes it and generates
	the curve definition for an isocurve on a surface (i.e., surface edge,
	sharp edge, or mesh line).  It also creates a visiblity list from
	start_parm to end_parm.

PARAMETERS
	surf (IN) - pointer to surface definition
	par_option (IN) - 1 -> constant u curve, 2 -> constant v curve
	parm (IN) - constant parameter
	edge_type (IN) - type of edge to be created

RETURN VALUES
	A pointer to the edge representing the iso-curve is returned.

GLOBALS USED
	none

HISTORY
        10/2/95     M Lanier
           Change argument par_option to par_option_arg and create local
           variable par_option as IGRshort.  This is because SUN and SGI
           compilers dont work if you (short *)&arg when arg is int and
           the function expects a short
	09/16/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong              rc;
	IGRint               order;
	IGRint               num_poles;
	IGRboolean           tst_planar = TRUE;
	struct VEedge_header *edge;
        IGRshort             par_option;


        par_option = par_option_arg;


	if ( par_option == CONST_U_POLY )
	   {
	   order = surf->v_order;
	   num_poles = surf->v_num_poles;
	   }
	else
	   {
	   order = surf->u_order;
	   num_poles = surf->u_num_poles;
	   }

	edge = VEalloc_edge_header();

	if ( ! edge )
	   return( NULL );

	edge->gm_curve3d = VEalloc_geom_curve( order, num_poles, surf->rational, 0 );

	if ( ! edge->gm_curve3d )
	   {
	   VEfree_edge_header( edge );
	   return( NULL );
	   }

	BSconstprcv( &rc, surf, (IGRshort *)&par_option, &parm, &tst_planar, 
						edge->gm_curve3d->bspcv );

	   BS_ERRCHK( rc, "VEconstruct_iso_edge:  BSconstprcv failed" );

	if ( rc != BSSUCC )
	   {
	   VEfree_edge_header( edge );  /* frees curve def. too */
	   return( NULL );
	   }

	edge->gm_curve3d->bspcv->bdrys = NULL;
	   
	edge->type    = edge_type;
	edge->edge_id = VEexec_status.VEunique_edge_id--;
	edge->status  = (par_option == CONST_U_POLY) ? CONSTANT_U_ISOCURVE : CONSTANT_V_ISOCURVE;
	edge->iso_parm = parm;

	edge->visib_list = VEconstruct_visib_list( edge->gm_curve3d->bspcv, VISIBLE );
	if ( ! edge->visib_list )
	   {
	   VEfree_edge_header( edge );  /* frees curve def. too */
	   return( NULL );
	   }

	return( edge );

	}  /* VEconstruct_iso_edge */


/*---- VEremove_totally_overlapped_edges -----------------------------------------*/

void VEremove_totally_overlapped_edges( element )

	struct VEelement_header *element;
	
/*
NAME
	VEremove_totally_overlapped_edges

DESCRIPTION
	This function removes all totally overlapped edges from an
	elements edge list.
	
PARAMETERS
	element (IN) - the element whose totally overlapped edges are
	               to be removed

GLOBALS USED
	none

HISTORY
	10/04/88    S.P. Rogers
	   Creation Date
*/

	{
	struct VEedge_header *prev_edge;
	struct VEedge_header *this_edge;
	
	prev_edge = NULL;
	this_edge = element->edges;
	while ( this_edge )
	   {
	   if ( this_edge->status & TOTALLY_OVERLAPPED )
	      {
	      /* remove edge from list and free it */
	      if ( prev_edge )
	         prev_edge->next = this_edge->next;
	      else
	         element->edges = this_edge->next;
	         
	      VEfree_visib_node_list( this_edge->visib_list );
	      VEfree_edge_header( this_edge );
	      }
	   else
	      {
	      prev_edge = this_edge;
	      }   

	   if ( prev_edge )
	      this_edge = prev_edge->next;
	   else
	      this_edge = element->edges;

	   }  /* end: while */
	   
	}  /* VEremove_totally_overlapped_edges */
