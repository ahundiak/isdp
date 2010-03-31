
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

#define  CHECK_RETURN_CODES 1

#include <stdio.h>
#include <string.h>
#include <alloca.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "bs.h"

#include "gr.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

#include "go.h"
#include "dpstruct.h"

/* prototype files */
#include "VEpr_driver.h"
#include "VEpr_marking.h"
#include "VEpr_hiding.h"
#include "VEpr_utilimp.h"
#include "VEpr_utilfnc.h"

/* External - global variables  */
extern struct VEexecution_parms  VEexec_parms;
extern struct VEexecution_status VEexec_status;
extern struct VEresults_info     VEoutput_data;

/* static file prototypes */
#if defined(__)
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void VEremove_tangent_edges __((struct VEelement_header *elem));

#if defined(__cplusplus)
}
#endif

#undef __


/*--- VEdelete_element_due_to_abort ---------------------------------*/

void VEdelete_element_due_to_abort( element )

	struct VEelement_header *element;

/*
NAME
	VEdelete_element_due_to_abort

DESCRIPTION
	This function deletes an element by freeing all the element
	headers, edge headers, temp nodes, and visib nodes.  It is
	designed to be used when the user hits the stop button to
	abort processing prematurely

PARAMETERS
	element (IN) - the element that is to be deleted

GLOBALS USED
	none

NOTES
	The element that is passed in is returned to the free
	pool and is no longer valid when this function returns.

HISTORY
	11/13/91    S.P. Rogers
	   Creation Date
	02/20/92    S.P. Rogers
	   Added prologue comment
*/

	{
	struct VEelement_header *next_elem;
	struct VEedge_header    *this_edge, *next_edge;

	/* the user has requested that VE abort processing */
	/* free everything for this element */
	while ( element )
	   {
	   this_edge = element->edges;
	   while ( this_edge )
	      {
	      next_edge = this_edge->next;
	      VEfree_visib_node_list( this_edge->visib_list );
	      VEfree_edge_header( this_edge );
	      this_edge = next_edge;
	      }
	   next_elem = element->next_in_solid;
	   VEfree_element_header( element );
	   element = next_elem;
	   }

	}  /* VEdelete_element_due_to_abort */


/*--- VEremove_tangent_edges --------------------------------------*/

static void VEremove_tangent_edges( elem )

struct VEelement_header *elem;

/*
NAME
	VEremove_tangent_edges (static)

DESCRIPTION
	This function removes the tangent edges from an element's
	edge list.

PARAMETERS
	elem (IN) - the element whose tangent edges are to be removed

GLOBALS USED
	none

HISTORY
	10/05/92    S.P. Rogers
	   Creation Date
*/

	{
	struct VEedge_header *prev_edge, *this_edge, *temp_edge;

	prev_edge = NULL;
	this_edge = elem->edges;
	while ( this_edge )
	   {
	   if ( this_edge->status & EDGE_IS_TANGENT )
	      {
	      if ( prev_edge )
	         prev_edge->next = this_edge->next;
	      else
	         elem->edges = this_edge->next;

	      temp_edge = this_edge;
	      this_edge = this_edge->next;
	      VEfree_visib_node_list( temp_edge->visib_list );
	      VEfree_edge_header( temp_edge );
	      }
	   else
	      {
	      prev_edge = this_edge;
	      this_edge = this_edge->next;
	      }

	   }  /* end: while */

	}  /* VEremove_tangent_edges */


/*---- VEactivate_element --------------------------------------------------------*/

void VEactivate_element( sort_rec, active_elems )

	struct VEsort_record    *sort_rec;
	struct VEelement_header **active_elems;
	
/*
NAME
	VEactivate_element

DESCRIPTION
	Activate an element, i.e., get its geometry, mark its edges and
	insert it into the active list comparing it to any other element
	whose range it overlaps.
	
PARAMETERS
	sort_rec (IN) - the sort record for the element to be activated
	active_elems (IN/OUT) - active list of elements

GLOBALS USED
	VEexec_parms
	VEexec_status
	VEoutput_data

HISTORY
	09/22/87    S.P. Rogers
	   Creation Date
	02/20/92    S.P. Rogers
	   Added prologue comment and changed parameters on call to
	   VEset_edge_ranges()
*/

	{
	IGRboolean              sts;
	IGRboolean              was_clipped;
	IGRboolean              missing_link;
	IGRint                  ii;
	struct VEelement_header *new_elem;
	struct VEelement_header *elem_list, *elem_list_tail;
	struct GRid             *comp_ids;
	struct GRid             elem_grid;
	IGRint                  comp_count;
	


	elem_list = elem_list_tail = NULL;

	/* save xmin of this element in case the user */
	/* requests that we stop processing           */
	VEexec_status.VEabort_xmin = sort_rec->range[0];

	elem_grid.objid = sort_rec->objid;
	elem_grid.osnum = sort_rec->env->osnum;
	if ( sort_rec->flags & SORT_REC_FROM_SOLID )
	   {
	   if ( ! VEexec_parms.VEcopying )
	      {
	      /* construct header for solid */
	      elem_list = elem_list_tail = VEalloc_element_header();
	      elem_list->objid = sort_rec->objid;
	      elem_list->env = sort_rec->env;
	      memcpy( elem_list->range, sort_rec->range, sizeof( IGRdouble ) * 6 );
	      elem_list->geom.gmsurf = NULL;
	      elem_list->edges = NULL;
	      elem_list->type = SOLID_HEADER;
	      elem_list->next_in_solid = NULL;
	      }

	   comp_count = 0;
	   VEget_components( &elem_grid, &comp_count, NULL );
	   comp_ids = (struct GRid *) alloca( comp_count * sizeof( struct GRid ) );
	   VEget_components( &elem_grid, &comp_count, comp_ids );
	   }
	else
	   {
	   comp_count = 1;
	   comp_ids = &elem_grid;
	   }

	for ( ii = 0; ii < comp_count; ii++ )
	   {
	   if ( IGEstop() )
	      {
	      VEexec_status.VEabort = TRUE;
	      VEdelete_element_due_to_abort( elem_list );
	      return;
	      }

	   VEupdate_num_activated();
	   was_clipped = missing_link = FALSE;
	
	   /* copy information from sort record to element header */
	   new_elem = VEalloc_element_header();

	   if ( new_elem == NULL )
	      continue;   /* couldn't allocate an element header */
	      
	   new_elem->objid     = comp_ids[ii].objid;
	   new_elem->parent_id = sort_rec->parent_id;
	   new_elem->type      = sort_rec->type;
	   new_elem->env       = sort_rec->env;
	   if ( sort_rec->flags & SORT_REC_FROM_SOLID )
	      new_elem->flags |= ELEM_FROM_SOLID;

	   /* get the abstract geometry of the element */
	   VEget_element_geometry( new_elem, new_elem->env );

	   if ( new_elem->geom.curve == NULL )
	      {
	      /* couldn't get the element's geometry => get rid of it */
	      VEfree_element_header( new_elem );
	      VEupdate_num_finished();
	      continue;
	      }

	   /* get range of the element */
	   if ( sort_rec->flags & SORT_REC_FROM_SOLID )
	      {
	      VEget_range( (new_elem->geom.gmsurf->bspsf->u_num_poles * new_elem->geom.gmsurf->bspsf->v_num_poles),
	                   new_elem->geom.gmsurf->bspsf->poles, new_elem->geom.gmsurf->bspsf->weights,
	                   new_elem->range, FALSE );
	      }
	   else
	      {
	      memcpy( new_elem->range, sort_rec->range, sizeof( IGRdouble ) * 6 );
	      }
	         
	   /* mark the element's edges */
	   if ( new_elem->type == SURFACE )
	      {
	      /* the element is a surface */

	      /* reduce the surface, if possible */
	      VEsurface_reduction( new_elem );
	      
	      /* mark the edges of the surface */
	      VEmark_surface_edges( new_elem );

	      /* mark the cross_hatching for the surface */
	      VEmark_surface_cross_hatching( new_elem );

	      /* link any dummy shared edges to their corresponding real edges */
	      if ( ! VEexec_parms.VEcopying )
	         VElink_shared_edges( new_elem,
	                              ((sort_rec->flags & SORT_REC_FROM_SOLID) ? elem_list : *active_elems),
	                              &missing_link );
	      }
	   else
	      {
	      /* mark curve/point edges */
	      new_elem->edges = VEmark_curve_or_point( new_elem, new_elem->geom.curve, new_elem->type, new_elem->objid );

	      VEmark_wireframe_cross_hatching( new_elem );
  	      }

	   /* clip the edges in X, Y and against the far Z plane */
	   sts = VEclip_curve( &(new_elem->edges), new_elem->env->clip_planes, &was_clipped );
	            
	      BS_STSCHK( sts, "VEmain: VEclip_curve failed" );

	   /* set edge ranges and throw out edges which collapse to points */
	   VEset_edge_ranges( new_elem );

	   if ( (new_elem->edges == NULL) && ( ! was_clipped ) )
	      {
	      /* all edges were thrown out because they collapsed */
	      /* to a point => get rid of element                 */
	      VEfree_element_header( new_elem );
	      VEupdate_num_finished();
	      continue;
	      }

	   if ( ! VEoutput_data.output_curves )
	      VEdelete_soos_from_edges( new_elem );

	   VEupdate_element_range( new_elem, was_clipped, missing_link );

	   /* Remove the tangent edges from this element's edge list now  */
	   /* They aren't needed for processing any more if they are not  */
	   /* going to be displayed.  The are kept this long to make sure */
	   /* the range of the element is set properly in                 */
	   /* VEupdate_element_range().                                   */
	   if ( ! VEexec_parms.VEprocess_tangent_edges )
	      VEremove_tangent_edges( new_elem );

	   if ( (VEexec_parms.VEcopying) || (new_elem->flags & HAS_CROSS_HATCHING) )
	      {
	      /* no need to put on the active list if we're are only copying */
	      VEestablish_curves( new_elem );
	      }
	   else
	      {
	      new_elem->next_in_solid = NULL;
	      if ( elem_list == NULL )
	         {
	         elem_list = elem_list_tail = new_elem;
	         }
	      else
	         {
	         elem_list_tail->next_in_solid = new_elem;
	         elem_list_tail = new_elem;
	         }
	      }

	   }  /* end: for ( ii ... ) */

	if ( elem_list )
	   {
	   if ( elem_list->type == SOLID_HEADER )
	      {
	      VEclassify_edges_of_solid( elem_list );
	      if ( VEexec_status.VEabort )
	         {
	         VEdelete_element_due_to_abort( elem_list );
	         return;
	         }
	      }

	   /* mark the edges that trimmed parting lines so */
	   /* they will be properly self-hidden            */
	   VEdetermine_edges_that_trim_parting_lines( elem_list );

	   VEself_hide( elem_list, VEexec_parms.VEhiding );
	   if ( VEexec_status.VEabort )
	      {
	      VEdelete_element_due_to_abort( elem_list );
	      return;
	      }

	   VEinsert_into_active_list( elem_list, sort_rec->range[0], active_elems );
	   }

	}  /* VEactivate_element */
