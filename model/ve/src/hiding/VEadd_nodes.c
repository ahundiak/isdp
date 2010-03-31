
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

#include <stdio.h>
#include <math.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"

#include "igrdp.h"
#include "dpstruct.h"

#include "vedef.h"
#include "ve.h"

/* prototype files */
#include "VEpr_hiding.h"
#include "VEpr_utilfnc.h"


/*--- VEinsert_temp_node ---------------------------------------*/

void VEinsert_temp_node( parm, edge, knot_tol )

	IGRdouble		parm;
	struct VEedge_header	*edge;
	IGRdouble               knot_tol;

/*
NAME
	VEinsert_temp_node

DESCRIPTION
	Adds an "UNKNOWN | UNKNOWN" node to the temp_list of an edge at
	a given parameter, unless another node already occupies that
	parameter or it is inside an overlap region.

PARAMETERS
	parm (IN) - the parameter at which to add the UNKNOWN/UNKNOWN
	            node
	edge (IN) - the edge whose temp list is to get the new node
	knot_tol (IN) - the knot tolerance to use when adding the
	                new node

GLOBALS USED
	none

HISTORY
	xx/xx/xx    Unknown Parameter
	   Creation Date
*/

	{
	struct VEtemp_node *this_node;
	struct VEtemp_node *prev_node;

	if (! ((edge->status & TOTALLY_OVERLAPPED) ||
	       (edge->status & TOTALLY_INVISIBLE)    ))
	   {
	   prev_node = edge->temp_list;
	   this_node = prev_node->next;

	   /* Add a node BETWEEN nodes only; do NOT add one on */
	   /* top of an existing node (within tolerance).      */
	   while ( this_node )
	      {
	      if ( ((prev_node->u + knot_tol) < parm) &&
	           ((this_node->u - knot_tol) > parm) )
	         {
	         if ( prev_node->next_visib != OVERLAPPED )
	            {
		    prev_node->next = VEalloc_temp_node( parm );
	            prev_node->next->next = this_node;
	            }

	         break;
	         }
	      else
	         {
	         prev_node = this_node;
	         this_node = prev_node->next;
	         }

	      } /* end: while */

	   } /* end: if edge is not totally overlapped */

	}  /* VEinsert_temp_node */


/*--- VEremove_nested_overlaps -------------------------------*/

void VEremove_nested_overlaps( edge )

	struct VEedge_header *edge;
	
/*
NAME
	VEremove_nested_overlaps

DESCRIPTION
	This function removes any nodes that are nested inside
	overlap spans on an edge's temp list.

PARAMETERS
	edge (IN) - the edge whose nested overlaps are to be
	            removed

GLOBALS USED
	none

HISTORY
	xx/xx/xx    Unknown Programmer
	   Creation Date
*/

	{
	IGRint             overlap_nest_level;
	struct VEtemp_node *this_node;
	struct VEtemp_node *prev_node;

	this_node = edge->temp_list;
	while ( this_node )
	   {
	   /* Skip to start of outermost overlap region */
	   while ( this_node )
	      {
	      if ( this_node->next_visib != OVERLAPPED )
	         this_node = this_node->next;
	      else
	         break;
	      }

	   if ( this_node )
	      {
	      prev_node = this_node;
	      this_node = this_node->next;
	      overlap_nest_level = 1;

	      /* Look for corresponding end; delete nodes in between */
	      while ( (this_node) && (overlap_nest_level > 0) )
	         {
	         if ( this_node->prev_visib == OVERLAPPED )
	            overlap_nest_level--;
	         if ( this_node->next_visib == OVERLAPPED )
	            overlap_nest_level++;

	         if ( overlap_nest_level > 0 )
	            {
	            prev_node->next = this_node->next;
	            VEfree_temp_node( this_node );
	            this_node = prev_node->next;
	            }
	         }
	      }
	   }

	}  /* VEremove_nested_overlaps */


/*--- VEinsert_overlap_temp_node -------------------------------*/

void VEinsert_overlap_temp_node( IGRdouble           parm,
				 IGRshort            p_visib, 
				 IGRshort            n_visib,
				 IGRdouble           knot_tol,
				 struct VEtemp_node  **p_node, 
				 struct VEtemp_node  **t_node )

/*
NAME
	VEinsert_overlap_temp_node

DESCRIPTION
	This function inserts a temp node representing one end of
	an overlap region into an edge's temp list.

PARAMETERS
	parm (IN) - the parameter of the node
	p_visib (IN) - the prev_visib value of the node
	n_visib (IN) - the next_visib value of the node
	knot_tol (IN) - the knot tolerance to use
	p_node (IN/OUT) - pointer to node previous to the one inserted
	t_node (IN/OUT) - pointer to the inserted node

GLOBALS USED
	none

HISTORY
	xx/xx/xx    Unknown Programmer
	   Creation Date
*/

	{
	struct VEtemp_node *temp_node;

	while ( *t_node )
	   {
	   if ( ((*t_node)->u - knot_tol) > parm )
	      {
	      /* Unique node to be added BEFORE "t_node" */
	      temp_node = VEalloc_temp_node( parm );
	      (*p_node)->next = temp_node;
	      temp_node->next = *t_node;
	      *t_node = temp_node;

	      temp_node->prev_visib = p_visib;
	      temp_node->next_visib = n_visib;
	      break;
	      }
	   else if ( fabs( (*t_node)->u - parm ) < knot_tol )
	      {
	      /* Node to be added ON TOP OF "t_node" (same parameter): */
              if ( ( (!(*p_node)) && ((*t_node)->prev_visib == OVERLAPPED) ) || 
                   ( (!(*t_node)->next) && ((*t_node)->next_visib == OVERLAPPED) ) )
                 {
                 /* beginning or end of the temp list */
	         (*t_node)->prev_visib = p_visib;
	         (*t_node)->next_visib = n_visib;
                 }
	      else if ( ((p_visib == OVERLAPPED) && ((*t_node)->next_visib == OVERLAPPED)) ||
	                ((n_visib == OVERLAPPED) && ((*t_node)->prev_visib == OVERLAPPED)) )
	         {
	         /* Starting an overlap region at the end of an existing one */
	         /* (or vice-versa), so just delete what would have          */
	         /* become the OVERLAPPED | OVERLAPPED node.                 */
	         (*p_node)->next = (*t_node)->next;
	         VEfree_temp_node( *t_node );
	         *t_node = (*p_node)->next;
	         }
	      else if ( ((*t_node)->prev_visib != OVERLAPPED) &&
	                ((*t_node)->next_visib != OVERLAPPED) )
	         {
	         /* Overwrite if an UNKNOWN | UNKNOWN node. */
	         (*t_node)->prev_visib = p_visib;
	         (*t_node)->next_visib = n_visib;
	         }
	      else
	         {
	         /* Add node if nesting overlap regions; will be resolved */
	         /* by the calling routine.                               */
	         temp_node       = VEalloc_temp_node( parm );
	         temp_node->next = (*t_node)->next;
	         (*t_node)->next = temp_node;
	         *t_node         = temp_node;

	         temp_node->prev_visib = p_visib;
	         temp_node->next_visib = n_visib;
	         }

	      break;
	      }
	   else
	      {
	      *p_node = *t_node;
	      *t_node = (*t_node)->next;
	      }

	   } /* while */

	}  /* VEinsert_overlap_temp_node */


/*--- VEadd_overlap_region -------------------------------------*/

void VEadd_overlap_region( IGRdouble             parm0, 
			   IGRdouble             parm1,
			   struct VEedge_header  *edge,
			   IGRshort              visib_type,
			   IGRdouble             knot_tol )

/*
NAME
	VEadd_overlap_region

DESCRIPTION
	This function adds an overlapped region to an edge's temp-list.

PARAMETERS
	parm0 (IN) - start parameter of overlapped region
	parm1 (IN) - end parameter of overlapped region
	edge (IN) - the edge to add the overlapped region to
	visib_type (IN) - the visibility of the outside of the
	                  overlapped region
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	none

HISTORY
	xx/xx/xx    Unknown Programmer
	   Creation Date
*/

	{
	IGRdouble          temp;
	struct VEtemp_node *this_node;
	struct VEtemp_node *prev_node;

	if (! (edge->status & TOTALLY_OVERLAPPED) )
	   {
	   /* Small overlap regions should be treated as intersections */
	   if ( fabs( parm0 - parm1 ) < knot_tol )
	      {
	      if ( visib_type == UNKNOWN )
	         VEinsert_temp_node( parm0, edge, knot_tol );
	      return;
	      }

	   if ( edge->status & TOTALLY_INVISIBLE )
	      visib_type = VISIBLE;			/* Saves doing point projects */

	   /* Order the two parameters defining the overlap region */
	   if ( parm0 > parm1 )
	      {
	      temp = parm1;
	      parm1 = parm0;
	      parm0 = temp;
	      }

	   prev_node = NULL;
	   this_node = edge->temp_list;
	   VEinsert_overlap_temp_node( parm0, visib_type, OVERLAPPED, knot_tol,
	                               &prev_node, &this_node);
	   VEinsert_overlap_temp_node( parm1, OVERLAPPED, visib_type, knot_tol,
	                               &prev_node, &this_node);

	   /* Remove all nodes within outermost overlap regions. */
	   VEremove_nested_overlaps( edge );
      
	   /* Set the edge's "totally overlapped" status */
	   prev_node = edge->temp_list;
	   this_node = prev_node->next;
	   if ( this_node->next == NULL )
	      {
	      if ( prev_node->next_visib == OVERLAPPED )
	         edge->status |= TOTALLY_OVERLAPPED;
	      }
	   }

	}  /* VEadd_overlap_region */
