
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/

#include <stdio.h>
#include <math.h>
#include <string.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dpstruct.h"

#include "bs.h"
#include "bsparameters.h"

#include "vedef.h"
#include "ve.h"

/* prototype files */
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

#include "bsxtractpar.h"

/*-- VEset_edge_ranges -----------------------------------------------*/

void VEset_edge_ranges( element )

	struct VEelement_header *element;

/*
NAME
	VEset_edge_ranges

DESCRIPTION
	Removes edges which collapse to a point and computes all edges' XYZ
	range.  This function must be called AFTER all splitting of edges has
	been done.  Edge splitting includes clipping and trimming.

PARAMETERS
	element (IN/OUT) - the element whose edges are to have their range set

GLOBALS USED
	none

HISTORY
	08/11/87    S.A. Rapa
	   Creation Date
	02/20/92    S.P. Rogers
	   Added prologue comment and added code to try to create SOs
	   for edges that are removed
*/

	{
	BSrc                 rc;
	IGRdouble            xyz_tol;
	struct VEedge_header *this_edge, *next_edge;
	struct VEedge_header *head, *tail;

	BSxtractpar( &rc, BSTOLCHRDHT, &xyz_tol );

	head = tail = NULL;
	this_edge = element->edges;
	while ( this_edge )
	   {
	   next_edge = this_edge->next;
	   this_edge->next = NULL;

	   if ( this_edge->gm_curve3d )
	      {
	      VEfind_curve_range( this_edge->gm_curve3d->bspcv, this_edge->range );

	      if ((this_edge->type != SINGLE_POINT) &&
	          (fabs( this_edge->range[XMIN] - this_edge->range[XMAX] ) < xyz_tol) &&
	          (fabs( this_edge->range[YMIN] - this_edge->range[YMAX] ) < xyz_tol)   )
	         {
	         /* edge collapses to a point -> remove it */

	         /* put overlapped temp_list on edge and create SOs if needed */
	         this_edge->temp_list = VEalloc_temp_node( this_edge->visib_list->u );
	         this_edge->temp_list->next = VEalloc_temp_node( this_edge->visib_list->next->u );
	         this_edge->temp_list->next_visib =
	         this_edge->temp_list->next->prev_visib = OVERLAPPED;

	         VEcreate_overlapped_soos_for_edge( element, this_edge );

	         VEfree_temp_node_list( this_edge->temp_list );
	         VEfree_visib_node_list( this_edge->visib_list );
	         VEfree_edge_header( this_edge );
	         }
	      else
	         {
	         if ( head )
	            tail->next = this_edge;
	         else
	            head = this_edge;
	         tail = this_edge;
	         }
	      }
	   else
	      {
	      /* this_edge is a dummy edge => copy range from the real edge */
	      memcpy( this_edge->range, this_edge->shared_edge->range, sizeof(IGRdouble) * 6 );
	      if ( head )
	         tail->next = this_edge;
	      else
	         head = this_edge;
	      tail = this_edge;
	      }

	   this_edge = next_edge;
	   }

	element->edges = head;
	}  /* VEset_edge_ranges */
