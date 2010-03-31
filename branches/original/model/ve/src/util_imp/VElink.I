
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/

class implementation Root;

#define  CHECK_RETURN_CODES 1

#include <stdio.h>

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

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
%safe
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

/* protoypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void VElink_two_edges __((	struct VEedge_header    *real_edge,
					struct VEedge_header    *dummy_edge,
					struct VEelement_header *real_elem,
					struct VEelement_header *dummy_elem,
					IGRboolean              real_elem_planar,
					IGRboolean              dummy_elem_planar ));

#if defined(__cplusplus)
extern "C" }
#endif

#undef __
%endsafe

from EMSboundary import EMgetsurface_info;

/*---- VElink_two_edges ---------------------------------------------*/

static void VElink_two_edges(	struct VEedge_header    *real_edge,
				struct VEedge_header    *dummy_edge,
				struct VEelement_header *real_elem,
				struct VEelement_header *dummy_elem,
				IGRboolean              real_elem_planar,
				IGRboolean              dummy_elem_planar )

/*
NAME
	VElink_two_edges (static)

DESCRIPTION
	This function links a real edge and its corresponding dummy edge
	together.  The shared_edge pointers are assigned so that the
	real shared edge points to the dummy shared edge and vice versa.
	It also puts a TOTALLY_OVERLAPPED visibility list on the dummy edge.

PARAMETERS
	real_edge (IN) - the real edge to link
	dummy_edge (IN) - the dummy edge to link
	real_elem (IN) - the element that owns the real edge
	dummy_elem (IN) - the element that owns the dummy edge
	real_elem_planar (IN) - TRUE, if the real element is planar
	dummy_elem_planar (IN) - TRUE, if the dummy element is planar

GLOBALS USED
	none

HISTORY
	10/05/87    S.P. Rogers
	   Creation Date
*/


	{
	real_edge->shared_edge = dummy_edge;
	real_edge->shared_elem = dummy_elem;
	dummy_edge->shared_edge = real_edge;
	dummy_edge->shared_elem = real_elem;

	/* put a totally overlapped visib_list on the dummy edge */
	dummy_edge->visib_list = VEconstruct_visib_list( real_edge->gm_curve3d->bspcv, OVERLAPPED );
	dummy_edge->status |= TOTALLY_OVERLAPPED;

	/* copy some of the status flags from real edge to dummy edge */
	dummy_edge->status |= ( real_edge->status & (EDGE_CLASSIFICATION |
	                                             DEBUG_EDGE |
	                                             SPLIT_FROM_PLANAR_PARENT |
	                                             USING_DUMMY_GEOMETRY |
	                                             EDGE_IS_TANGENT) );

	/* fix planar bit of real edge */
	if ( real_elem_planar || dummy_elem_planar )
	   real_edge->gm_curve3d->bspcv->planar = TRUE;

	}  /* VElink_two_edges */


/*--- VEfind_other_shared_edge --------------------------------------------------------*/

IGRboolean VEfind_other_shared_edge( edge_id_to_find, edge_ptr, elem, prev_ptr, cur_ptr )

	IGRint                  edge_id_to_find;
	struct VEedge_header    *edge_ptr;
	struct VEelement_header *elem;
	struct VEedge_header    **prev_ptr;
	struct VEedge_header    **cur_ptr;

/*
NAME
	VEfind_other_shared_edge (static)

DESCRIPTION
	Given a 'edge_id' and a pointer to the element, 'elem',  that contains
	the edge, this function finds the edge with id 'edge_id'.  If it is
	given an 'edge_ptr', it uses it to locate the edge instead of the
	'edge_id' because several edges could have the same 'edge_id' due to
	splitting and classifying.

PARAMETERS
	edge_id_to_find (IN) - the id of the edge to find
	edge_ptr (IN) - a pointer to the edge to find
	elem (IN) - the element that contains the edge to find
	prev_ptr (OUT) - the edge previous to the one that is to be found
	cur_ptr (OUT) - the edge that is found

GLOBALS USED
	none

RETURN VALUES
	TRUE - if the edge was found
	FALSE - if the edge was not found

HISTORY
	09/05/90    S.P. Rogers
	   Creation Date (extracted from VElink_shared_edges())
*/

	{
	struct VEedge_header *this_edge, *prev_edge;

	/* find the real edge in the elem's edge list */
	prev_edge = NULL;
	this_edge = elem->edges;
	while ( this_edge )
	   {
	   if ( edge_ptr )
	      {
	      /* searching by pointer instead of id */
	      if ( edge_ptr == this_edge )
	         break;
	      }
	   else if ( this_edge->edge_id == edge_id_to_find ) 
	      break;

	   prev_edge = this_edge;
	   this_edge = this_edge->next;
	   }
	   
	if ( this_edge == NULL )
	   return( FALSE );

	*cur_ptr = this_edge;
	*prev_ptr = prev_edge;

	return( TRUE );
	}  /* VEfind_other_shared_edge */


/*--- VEfind_edge --------------------------------------------------------------*/

#if defined(__STDC__)
IGRboolean VEfind_edge( IGRint                  edge_id_to_find,
			IGRshort                osnum,
			IGRshort                attach_id,
			struct VEedge_header    *edge_ptr,
			struct VEelement_header *elem_list,
			struct VEelement_header **elem_ptr,
			struct VEedge_header    **prev_ptr,
			struct VEedge_header    **cur_ptr )
#else
IGRboolean VEfind_edge( edge_id_to_find, osnum, attach_id, edge_ptr, elem_list,
	                elem_ptr, prev_ptr, cur_ptr )

	IGRint                  edge_id_to_find;
	IGRshort                osnum;
	IGRshort                attach_id;
	struct VEedge_header    *edge_ptr;
	struct VEelement_header *elem_list;
	struct VEelement_header **elem_ptr;
	struct VEedge_header    **prev_ptr;
	struct VEedge_header    **cur_ptr;
#endif

/*
NAME
	VEfind_edge (static)

DESCRIPTION
	Given a edge id, object space number, attachment id and a list of
	elements, this function finds the element that owns the edge with id
	'edge_id' and the edge itself.  If it is given an 'edge_ptr', it uses
	it to locate the edge instead of the 'edge_id' because several edges
	could have the same 'edge_id' due to splitting and classifying.

PARAMETERS
	edge_id_to_find (IN) - the id of the edge to find
	osnum (IN) - the object space number of the edge to find
	attach_id (IN) - the attachment id of the edge to find
	edge_ptr (IN) - a pointer to the edge to find
	elem_list (IN) - list of elements in which to search for the edge
	elem_ptr (OUT) - element that owns the edge that is found
	prev_ptr (OUT) - the edge previous to the one that is to be found
	cur_ptr (OUT) - the edge that is found

GLOBALS USED
	none

RETURN VALUES
	TRUE - if the edge was found
	FALSE - if the edge was not found

HISTORY
	09/05/90    S.P. Rogers
	   Creation Date (extracted from VElink_shared_edges())
*/

	{
	IGRlong                 sts;
	IGRlong                 msg;
	IGRboolean              found;
	OM_S_OBJID              elem_id_to_find;
	struct VEelement_header *elem;
	struct VEelement_header *next_elem;
	struct VEedge_header    *this_edge, *prev_edge;


	/* get the object id of the element that owns edge */
	sts = om$send( mode     = OM_e_wrt_object,
	               msg      = message EMSboundary.EMgetsurface_info( &msg,
	                                                                 &elem_id_to_find,
	                                                                 NULL ),
	               senderid = NULL_OBJID,
	               targetid = edge_id_to_find,
	               targetos = osnum );
		       
	   OM_ERRCHK( sts, "VEfind_edge:  EMgetsurface_info send failed" );
	   MSG_ERRCHK( msg, "VEfind_edge:  EMgetsurface_info failed" );

	/* find the element on the elem_list */
	elem = elem_list;
	found = FALSE;
	while ( (!found) && elem )
	   {
	   next_elem = elem->next;  /* next element in active list */
	   while ( (!found) && elem )
	      {
	      if ( ( elem->objid == elem_id_to_find ) &&
	           ( elem->env->attach_id == attach_id ) )
	         found = TRUE;
	      else
	         elem = elem->next_in_solid;
	      }
	   if ( ! found )
	      elem = next_elem;
	   }
	   
	if ( elem == NULL )
	   return( FALSE );

	/* find the real edge in the elem's edge list */
	prev_edge = NULL;
	this_edge = elem->edges;
	while ( this_edge )
	   {
	   if ( edge_ptr )
	      {
	      /* searching by pointer instead of id */
	      if ( edge_ptr == this_edge )
	         break;
	      }
	   else if ( this_edge->edge_id == edge_id_to_find ) 
	      break;

	   prev_edge = this_edge;
	   this_edge = this_edge->next;
	   }
	   
	if ( this_edge == NULL )
	   return( FALSE );

	*elem_ptr = elem;
	*cur_ptr = this_edge;
	*prev_ptr = prev_edge;
	return( TRUE );
	}  /* VEfind_edge */


/*---- VElink_shared_edges ---------------------------------------------*/

void VElink_shared_edges( dummy_elem, elem_list, missing_link )

	struct VEelement_header *dummy_elem;
	struct VEelement_header *elem_list;
	IGRboolean              *missing_link;
	
/*
NAME
	VElink_shared_edges

DESCRIPTION
	This function searches an element's edge list for dummy shared edges
	and links them to their corresponding real edges.  The real edge is
	located by finding the objid of the element to which it belongs and
	by using the edge id stored in the num_sh_spans field of the dummy's
	edge header.

PARAMETERS
	dummy_elem (IN) - the element whose dummy edges are to be linked
	                  to their corresponding real edge
	elem_list (IN) - the list of elements to search for the real edges
	missing_link (OUT) - TRUE, if the real edge wasn't found for a dummy
	                     edge

GLOBALS USED
	none

HISTORY
	09/23/87    S.P. Rogers
	   Creation Date
	03/26/92    S.P. Rogers
	   Fixed problem with creating extra dummies for split-up real edges
	   where the extra dummies would be put in the wrong edge list
*/

	{
	IGRboolean               found;
	IGRlong                  edge_id_to_find;
	struct VEelement_header  *real_elem;
	struct VEedge_header     *this_real_edge;
	struct VEedge_header     *prev_real_edge;
	struct VEedge_header     *this_edge;
	struct VEedge_header     *prev_edge;
	struct VEedge_header     *temp_edge;
	

	*missing_link = FALSE;

	this_edge = dummy_elem->edges;
	prev_edge = NULL;
	while ( this_edge )
	   {
	   if ( this_edge->gm_curve3d == NULL )
	      {
	      /* this_edge is a dummy shared edge, so find its corresponding */
	      /* real edge and link them together                            */
	      edge_id_to_find = this_edge->num_sh_spans;
	      this_edge->num_sh_spans = 0;
	
	      found = VEfind_edge( (IGRint)edge_id_to_find, dummy_elem->env->osnum, dummy_elem->env->attach_id,
	                           (struct VEedge_header *) NULL, elem_list,
	                           &real_elem, &prev_real_edge, &this_real_edge );

	      if ( ! found )
	         {
	         /* The other edge wasn't found => remove dummy edge from edge list */
	         *missing_link = TRUE;
	         if ( prev_edge == NULL )
	            dummy_elem->edges = this_edge->next;
	         else
	            prev_edge->next = this_edge->next;

	         temp_edge = this_edge;
	         this_edge = this_edge->next;
	         VEfree_edge_header( temp_edge );
	         }
	      else
	         {
	         /* link up edges */
	         VElink_two_edges( this_real_edge, this_edge, real_elem, dummy_elem,
	                           real_elem->geom.gmsurf->bspsf->planar, dummy_elem->geom.gmsurf->bspsf->planar );

	         /* Continue looking at edges following the real edge. If */
	         /* there are edges with the same edge_id, create dummy   */
	         /* edge headers for them in the dummy's edge list and    */
	         /* link them together.                                   */
	         this_real_edge = this_real_edge->next;
	         while ( (this_real_edge) && (this_real_edge->edge_id == edge_id_to_find) )
	            {
	            /* create a new dummy edge header */
	            temp_edge = VEalloc_edge_header();
	            temp_edge->edge_id = this_edge->edge_id;
	            temp_edge->type = this_edge->type;
	            temp_edge->iso_parm = this_edge->iso_parm;
	            temp_edge->status = WAS_A_DUMMY;

	            VElink_two_edges( this_real_edge, temp_edge, real_elem, dummy_elem,
	                              real_elem->geom.gmsurf->bspsf->planar, dummy_elem->geom.gmsurf->bspsf->planar );

	            /* insert new edge into dummy element's edge list */
	            temp_edge->next = this_edge->next;
	            this_edge->next = temp_edge;
	            prev_edge = this_edge;
	            this_edge = temp_edge;
	
	            this_real_edge = this_real_edge->next;
	            }  /* end: while ( real_edge->edge_id == edge_id_to_find ) */


	         prev_edge = this_edge;
	         this_edge = this_edge->next;

	         }  /* end: real edge was found */

	      }  /* end: if ( this_edge->gm_curve3d == NULL ) */
	   else
	      {
	      /* edge wasn't a dummy */
	      prev_edge = this_edge;
	      this_edge = this_edge->next;
	      }

	   }  /* end: while ( this_edge ) */
	   
	}  /* VElink_shared_edges */


/*--- VEcreate_dummies_for_split_pieces ------------------------------------------*/

void VEcreate_dummies_for_split_pieces( split_elem, split_list, dummy_ptr, dummy_elem )

	struct VEelement_header *split_elem;
	struct VEedge_header    *split_list;
	struct VEedge_header    *dummy_ptr;
	struct VEelement_header *dummy_elem;

/*
NAME
	VEcreate_dummies_for_split_pieces

DESCRIPTION
	This function takes a list of edges split from a real shared edge,
	a pointer to its corresponding dummy, and a pointer to the element
	that contains the dummy edge, and replaces the dummy edge with a list
	of dummies corresponding to the list of split edges.  If 'split_list'
	is NULL, then the effect of this function is to delete the edge
	pointed to by 'dummy_ptr'.

PARAMETERS
	split_elem (IN) - element whose real shared edge was split
	split_list (IN) - the list of split edges
	dummy_ptr (IN) - pointer to the dummy edge for the real edge that
	                 was split
	dummy_elem (IN) - element that owns the dummy edge

GLOBALS USED
	none

HISTORY
	09/05/90    S.P. Rogers
	   Creation Date
*/

	{
	struct VEedge_header    *dummy_head, *dummy_tail;
	struct VEedge_header    *this_edge, *new_edge;
	struct VEedge_header    *prev_dummy_edge, *dummy_edge;

	/* find the the old dummy edge in dummy_elem's edge list */
	if ( ! VEfind_other_shared_edge( dummy_ptr->edge_id, dummy_ptr, dummy_elem,
	                                 &prev_dummy_edge, &dummy_edge ) )
	   return;

	dummy_head = dummy_tail = NULL;

	/* construct a dummy edge for each split piece */
	this_edge = split_list;
	while ( this_edge )
	   {
	   new_edge = VEalloc_edge_header();
	   *new_edge = *dummy_edge;
	   new_edge->num_sh_spans = 0;
	   VElink_two_edges( this_edge, new_edge, split_elem, dummy_elem,
	                     split_elem->geom.gmsurf->bspsf->planar, dummy_elem->geom.gmsurf->bspsf->planar );

	   if ( dummy_head == NULL )
	      dummy_head = new_edge;
	   else
	      dummy_tail->next = new_edge;
	   dummy_tail = new_edge;

	   this_edge = this_edge->next;
	   }

	if ( dummy_head )
	   {
	   /* replace old dummy with new list of dummies */
	   if ( prev_dummy_edge == NULL )
 	      dummy_elem->edges = dummy_head;
	   else
	      prev_dummy_edge->next = dummy_head;

	   dummy_tail->next = dummy_edge->next;
	   }
	else
	   {
	   /* delete dummy */
	   if ( prev_dummy_edge == NULL )
	      dummy_elem->edges = dummy_edge->next;
	   else
	      prev_dummy_edge->next = dummy_edge->next;
	   }


	/* free the old dummy edge */
	VEfree_visib_node_list( dummy_edge->visib_list );
	VEfree_edge_header( dummy_edge );

	}  /*  VEcreate_dummies_for_split_pieces */

end implementation Root;

