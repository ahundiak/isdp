
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/


#define CHECK_RETURN_CODES 1


#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "bs.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"
#include "vemem.h"

/* prototype files */
#include "VEpr_hiding.h"
#include "VEpr_utilfnc.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static IGRint VEcalc_bucket_index __((	IGRint                  num_poles0,
					IGRint                  num_poles1,
					IGRboolean              shared0,
					IGRboolean              shared1 ));
	
static void VEmark_intersections_in_overlaps __((
					IGRint                  num_int,
					IGRint                  num_over,
					IGRdouble               *par0,
					IGRdouble               *par1,
					IGRdouble               *over0,
					IGRdouble               *over1,
					IGRint                  *ints_to_keep ));

static void VEfind_intersection_node __((
					IGRint                  bucket_index,
					IGRint                  edge_id0,
					IGRint                  edge_id1,
					struct VEsaved_int_node **prev_node,
					struct VEsaved_int_node **node,
					IGRboolean              *reversed ));

#if defined(__cplusplus)
}
#endif

#undef __

/* External Global Variables */
extern struct VEint_manager     VEsaved_ints;
extern struct VEexecution_parms VEexec_parms;


/*--- VEcalc_bucket_index -------------------------------------------*/

static IGRint VEcalc_bucket_index( IGRint     num_poles0,
				   IGRint     num_poles1,
				   IGRboolean shared0,
				   IGRboolean shared1 )
	
/*
NAME
	VEcalc_bucket_index (static)

DESCRIPTION
	This function calculates the bucket index for a saved curve/curve
	intersection.

PARAMETERS
	num_poles0 (IN) - number of poles on curve0
	num_poles1 (IN) - number of poles on curve1
	shared0 - (IN) - TRUE, if edge0 is a shared edge
	shared1 - (IN) - TRUE, if edge1 is a shared edge

RETURN VALUES
	The bucket index for a saved curve/curve intersection is returned.

GLOBALS USED
	none

HISTORY
	10/14/88    S.P. Rogers
	   Creation Date
*/
	

	{
	IGRint key;
	IGRint index;
	
	key = ( num_poles0 - 1 ) * ( num_poles1 - 1 );
	if ( shared0 && shared1 )
	   key *= 3;
	   
	index = key - SAVED_INT_BASE;
	if ( index < 0 )
	   index = 0;
	else
	   {
	   index = (index / SAVED_INT_OFFSET) + 1;
	   if ( index >= NUM_INT_BUCKETS )
	      index = NUM_INT_BUCKETS - 1;
	   }
	   
	return( index );
	
	}  /* VEcalc_bucket_index */
	

/*--- VEmark_intersections_in_overlaps ------------------------------------*/

static void VEmark_intersections_in_overlaps( num_int, num_over,
                                              par0, par1, over0, over1, ints_to_keep )

	IGRint    num_int;
	IGRint    num_over;
	IGRdouble *par0;
	IGRdouble *par1;
	IGRdouble *over0;
	IGRdouble *over1;
	IGRint    *ints_to_keep;
	
/*
NAME
	VEmark_intersections_in_overlaps

DESCRIPTION
	This function marks intersection points that are contained inside the
	same overlapped region on both curves.  It marks them by making the
	parameter value of the intersection on curve0 (i.e, par0[i]) negative.
	It also returns the number of intersection points that are not in
	overlapped regions.
	
PARAMETERS
	num_int (IN) - the number of intersections
	num_over (IN) - the number of overlaps
	par0 (IN/OUT) - intersecton parameters for curve0
	par1 (IN) - intersecton parameters for curve1
	over0 (IN) - overlap parameters for curve0
	over1 (IN) - overlap parameters for curve1
	ints_to_keep (IN) - the number of intersections not in an overlapped
	                    region

GLOBALS USED
	none

HISTORY
	11/17/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRdouble  p0;
	IGRdouble  p1;
	IGRdouble  o0;
	IGRdouble  o1;
	IGRint     i;
	IGRint     j;
	IGRboolean inside;
	
	num_over *= 2;
	*ints_to_keep = 0;

	for ( i = 0; i < num_int; i++ )
	   {
	   p0 = par0[i];
	   p1 = par1[i];
	   for ( j = 0, inside = FALSE; j < num_over && !inside; j += 2 )
	      {
	      /* see if p0 is between over0[j] and over0[j+1] */
	      o0 = over0[j];
	      o1 = over0[j + 1];
	      if ( o0 < o1 )
	         inside = (p0 > o0) && (p0 < o1);
	      else
	         inside = (p0 > o1) && (p0 < o0);
	         
	      if ( inside )
	         {
	         /* see if p1 is between over1[j] and over1[j+1] */
	         o0 = over1[j];
	         o1 = over1[j + 1];
	         if ( o0 < o1 )
	            inside = (p1 > o0) && (p1 < o1);
	         else
	            inside = (p1 > o1) && (p1 < o0);
	         }

	      }  /* end: for */

	   if ( inside )
	      {
	      /* this intersection is inside the same overlap */
	      /* on both curves => mark it                    */
	      par0[i] = -par0[i];
	      }
	   else
	      {
	      /* this intersection is o.k. => keep it */
	      (*ints_to_keep)++;
	      }
	      
	   }  /* end: for */

	}  /* VEmark_intersections_in_overlaps */


/*--- VEsave_intersection_info --------------------------------------------*/

void VEsave_intersection_info( edge0, edge1, elem0, elem1,
	                       num_int, num_over, par0, par1, over0, over1 )

	struct VEedge_header    *edge0;
	struct VEedge_header    *edge1;
	struct VEelement_header *elem0;
	struct VEelement_header *elem1;
	IGRint                  num_int;
	IGRint                  num_over;
	IGRdouble               *par0;
	IGRdouble               *par1;
	IGRdouble               *over0;
	IGRdouble               *over1;

/*
NAME
	VEsave_intersection_info

DESCRIPTION
	This function saves curve/curve intersection data for two curves
	provided at least one of them is a shared edge.  The intersection data
	is saved under the "saved_cvcv_id's" of the real shared edge of a
	(real,dummy) pair.

PARAMETERS
	edge0 (IN) - one of the edges involved in the intersection
	edge1 (IN) - the other edge involved in the intersection
	elem0 (IN) - element that owns 'edge0'
	elem1 (IN) - element that owns 'edge1'
	num_int (IN) - number of intersections
	num_over (IN) - number of overlaps
	par0 (IN) - intersection parameters w.r.t. 'edge0'
	par1 (IN) - intersection parameters w.r.t. 'edge1'
	over0 (IN) - overlap parameters w.r.t. 'edge0'
	over1 (IN) - overlap parameters w.r.t. 'edge1'


GLOBALS USED
	VEexec_parms
	VEsaved_ints

HISTORY
	11/06/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRboolean              edge0_is_shared;
	IGRboolean              edge1_is_shared;
	IGRint                  bucket_index;
	IGRint                  i;
	IGRint                  ints_to_keep;
	IGRint                  keep_count;
	IGRint                  temp;
	IGRdouble               *ints;
	IGRdouble               *overs;
	struct VEedge_header    *real_edge0;
	struct VEedge_header    *real_edge1;
	struct VEsaved_int_node *int_node;
	

	/* save intersection data if at least one of the */
	/* two edges is a shared edge                    */
	edge0_is_shared = ( (edge0->status & (REAL_SHARED_EDGE | WAS_A_DUMMY)) &&
	                    (! (elem0->flags & ELEM_FROM_SOLID) ) );
	edge1_is_shared = ( (edge1->status & (REAL_SHARED_EDGE | WAS_A_DUMMY)) &&
	                    (! (elem1->flags & ELEM_FROM_SOLID) ) );
                            
	if (! (edge0_is_shared || edge1_is_shared) )
	   {
	   /* don't save intersection data */
	   return;
	   }

	/* get the real edges */
	if ( (edge0->shared_edge == NULL) || (edge0->status & REAL_SHARED_EDGE) )
	   real_edge0 = edge0;
	else
	   real_edge0 = edge0->shared_edge;

	if ( (edge1->shared_edge == NULL) || (edge1->status & REAL_SHARED_EDGE) )
	   real_edge1 = edge1;
	else
	   real_edge1 = edge1->shared_edge;

	/* get the bucket index */
	bucket_index = VEcalc_bucket_index( (IGRint)edge0->gm_curve3d->bspcv->num_poles,
		                            (IGRint)edge1->gm_curve3d->bspcv->num_poles,
		                            edge0_is_shared,
		                            edge1_is_shared );
		                            
	if ( ! VEexec_parms.VEhiding )
	   {
	   /* GPE w/ trace is being performed so we don't need */
	   /* to save the intersection points                  */
	   ints_to_keep = num_int = 0;
	   }
	else if ( num_over > 0 )
	   {
	   /* mark intersections that shouldn't be saved because */
	   /* they are in overlap regions                        */
	   VEmark_intersections_in_overlaps( num_int, num_over,
	                                     par0, par1, over0, over1, &ints_to_keep );
	   }
	else
	   {
	   ints_to_keep = num_int;
	   }
	   
	/* ints_to_keep is now the number of intersections that should be saved */
	int_node = VEalloc_saved_int_node( ints_to_keep, num_over, bucket_index );
	
	if ( int_node == NULL )
	   {
	   /* no more space to save intersection data => clean up intersections */
	   /* that are marked as inside overlap regions and return              */
	   for ( i = 0; i < num_int; i++ )
	      {
	      if ( par0[i] < 0.0 )
	         par0[i] = -par0[i];
	      }  /* end: for */
	   
	   return;
	   }  /* end: if ( int_node == NULL ) */
	   
	int_node->num_int  = ints_to_keep;
	int_node->num_over = num_over;
	
	if (edge0_is_shared && edge1_is_shared)
	   {
	   /* both edges are shared => there should be 3 more intersections */
	   int_node->ints_left = 3;
	   }
	else
	   {
	   /* only one edge was shared => there should be one more intersection */
	   int_node->ints_left = 1;
	   }
                            
	/* save edge id's */
	int_node->id0 = real_edge0->saved_cvcv_id;
	int_node->id1 = real_edge1->saved_cvcv_id;
	
	/* save intersection information */
	ints = int_node->buffer;
	for ( i = keep_count = 0; i < num_int; i++ )
	   {
	   if ( par0[i] >= 0.0 )
	      {
	      /* this is a good intersection => copy it into node */	
	      ints[keep_count]                = par0[i];
	      ints[keep_count + ints_to_keep] = par1[i];
	      keep_count++;
	      }
	   else
	      {
	      /* this intersection was marked that it */
	      /* was in an overlap => reset par0      */
	      par0[i] = -par0[i];
	      }
	   }  /* end: for */

	/* save overlap information */
	overs = &(int_node->buffer[ints_to_keep*2]);
	temp = num_over * 2;
	for ( i = 0; i < num_over * 2; i++ )
	   {
	   overs[i]        = over0[i];
	   overs[i + temp] = over1[i];
	   }

	/* add int_node to intersection list */
	int_node->next = VEsaved_ints.buckets[ bucket_index ];
	VEsaved_ints.buckets[ bucket_index ] = int_node;

	/* set edge flags to indicate that there is saved info for them */
	real_edge0->status |= HAS_SAVED_INT_DATA;
	real_edge1->status |= HAS_SAVED_INT_DATA;
		
	}  /* VEsave_intersection_info */
	


/*--- VEfind_intersection_node ------------------------------------------------*/

static void VEfind_intersection_node( bucket_index, edge_id0, edge_id1,
	                              prev_node, node, reversed )
	                        
	IGRint                  bucket_index;
	IGRint                  edge_id0;
	IGRint                  edge_id1;
	struct VEsaved_int_node **prev_node;
	struct VEsaved_int_node **node;
	IGRboolean              *reversed;
	
/*
NAME
	VEfind_intersection_node (static)

DESCRIPTION
	This function searches for the intersection node associated with
	edge_id0 and edge_id1 on the saved intersection list.  It returns a
	pointer to the node, a pointer to the previous node and a flag
	indicating whether the intersection data is stored in reverse order.
	
PARAMETERS
	bucket_index (IN) - the bucket index of the intersection to find
	edge_id0 (IN) - id of one of the edges involved in intersection
	edge_id1 (IN) - id of the other edge involved in intersection
	prev_node (OUT) - node previous to the found saved intersection node
	node (OUT) - the found saved intersection node, NULL if a saved
	             intersection wasn't found
	reversed (OUT) - TRUE, if edge_id0 corresponds to id1 in the saved
	                 intersection node

GLOBALS USED
	VEsaved_ints

HISTORY
	11/18/87    S.P. Rogers
	   Creation date
*/

	{
	struct VEsaved_int_node *int_node;

	/* search for intersection info on the saved intersection list */
	int_node = VEsaved_ints.buckets[ bucket_index ];
	*prev_node = NULL;
	while ( int_node != NULL )
	   {
	   if ( (edge_id0 == int_node->id0) && (edge_id1 == int_node->id1) )
	      {
	      *reversed = FALSE;
	      *node = int_node;
	      return;
	      }

	   if ( (edge_id0 == int_node->id1) && (edge_id1 == int_node->id0) )
	      {
	      *reversed = TRUE;
	      *node = int_node;
	      return;
	      }

	   *prev_node = int_node;
	   int_node = int_node->next;
	   }  /* end: while */
	  
	*node = NULL;

	}  /* VEfind_intersection_node */
	


/*--- VEretrieve_intersection_info --------------------------------------------*/

IGRboolean VEretrieve_intersection_info( edge0, edge1,
	                                 num_int, num_over, par0, par1, over0, over1 )

	struct VEedge_header *edge0;
	struct VEedge_header *edge1;
        IGRint               *num_int;
        IGRint               *num_over;
        IGRdouble            **par0;
        IGRdouble            **par1;
        IGRdouble            **over0;
        IGRdouble            **over1;


/*
NAME
	VEretrieve_intersection_info

DESCRIPTION
	This function searches a list of saved curve/curve intersection data
	for data resulting from a previous intersection of edge0 and edge1.
	One of the two edges must be a shared edge for the search to take
	place. If saved intersection data is found, TRUE is returned;
	otherwise FALSE is returned.
	
PARAMETERS
	edge0 (IN) - one of the edges involved in the intersection
	edge1 (IN) - the other edge involved in the intersection
	num_int (OUT) - the number of intersections
	num_over (OUT) - the number of overlaps
	par0 (OUT) - intersection parameters w.r.t. 'edge0'
	par1 (OUT) - intersection parameters w.r.t. 'edge1'
	over0 (OUT) - overlap parameters w.r.t. 'edge0'
	over1 (OUT) - overlap parameters w.r.t. 'edge1'

GLOBALS USED
	VEsaved_ints

HISTORY
	11/06/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRboolean              edge0_is_shared;
	IGRboolean              edge1_is_shared;
	IGRboolean              reversed;
	IGRint                  bucket_index;
	IGRdouble               *ints;
	IGRdouble               *overs;
	struct VEedge_header    *real_edge0;
	struct VEedge_header    *real_edge1;
	struct VEsaved_int_node *int_node;
	struct VEsaved_int_node *prev_node;
	

	edge0_is_shared = (edge0->status & (REAL_SHARED_EDGE | WAS_A_DUMMY) );
	edge1_is_shared = (edge1->status & (REAL_SHARED_EDGE | WAS_A_DUMMY) );
                            
	if (! (edge0_is_shared || edge1_is_shared) )
	   {
	   /* this pair of edges can't have intersections saved for them => don't search */
	   return( FALSE );
	   }

	/* get the real edges */
	if ( (edge0->shared_edge == NULL) || (edge0->status & REAL_SHARED_EDGE) )
	   real_edge0 = edge0;
	else
	   real_edge0 = edge0->shared_edge;

	if ( (edge1->shared_edge == NULL) || (edge1->status & REAL_SHARED_EDGE) )
	   real_edge1 = edge1;
	else
	   real_edge1 = edge1->shared_edge;


	if ( !( (real_edge0->status & HAS_SAVED_INT_DATA) &&
	        (real_edge1->status & HAS_SAVED_INT_DATA) ) )
	   {
	   /* both edges don't indicate that they have saved intersection data */
	   return( FALSE );
	   }
	   
	/* get the bucket index */
	bucket_index = VEcalc_bucket_index( (IGRint)edge0->gm_curve3d->bspcv->num_poles,
		                            (IGRint)edge1->gm_curve3d->bspcv->num_poles,
		                            edge0_is_shared,
		                            edge1_is_shared );
		                            
	/* search for intersection info on the saved intersection list */
	VEfind_intersection_node( bucket_index,
		                  real_edge0->saved_cvcv_id,
	                          real_edge1->saved_cvcv_id,
	                          &prev_node, &int_node, &reversed );
	   
	if ( int_node == NULL )
	   {
	   return( FALSE );  /* no saved intersection data */
	   }
	  
	/* indicate that the intersection data has been used */
	int_node->ints_left--;

	/* copy intersection data: NOTE since the array of intersections  */
	/* and overlaps is not freed when int_node is removed from the    */
	/* saved intersections list, it is o.k to make par0, par1, over0  */
	/* and over1 point into it                                        */
	*num_int = int_node->num_int;
	*num_over = int_node->num_over;
	
	ints  = int_node->buffer;
	overs = &(int_node->buffer[*num_int*2]);

	if ( *num_int == 0 )
	   {
	   *par0 = *par1 = NULL;
	   }
	else if ( reversed )
	   {
	   /* the intersection data was stored in reverse order */
	   *par1 = ints;
	   *par0 = &(ints[*num_int]);
	   }
	else
	   {
	   *par0 = ints;
	   *par1 = &(ints[*num_int]);
	   }

	if ( *num_over == 0 )
	   {
	   *over0 = *over1 = NULL;
	   }
	else if ( reversed )
	   {
	   /* the overlap data was stored in reverse order */
	   *over1 = overs;
	   *over0 = &(overs[*num_over*2]);
	   }
	else
	   {
	   *over0 = overs;
	   *over1 = &(overs[*num_over*2]);
	   }
	   
	/* remove the intersection data node from the list and free it, if */
	/* its ints_left field is now zero.                                */
	if ( int_node->ints_left == 0 )
	   {
	   if ( prev_node == NULL )
	      VEsaved_ints.buckets[ bucket_index ] = int_node->next;
	   else
	      prev_node->next = int_node->next;
	   
	   VEfree_saved_int_node( int_node );
	   }
	
	return( TRUE );
	
	}  /* VEretrieve_intersection_info */




/*--- VEremove_intersection_info ----------------------------------------------*/

void VEremove_intersection_info( IGRboolean           one_edge,
				 struct VEedge_header *edge0,
				 struct VEedge_header *edge1 )

/*
NAME
	VEremove_intersection_info

DESCRIPTION
	This function removes saved curve/curve intersection data from the
	saved intersection list.  If one_edge is TRUE, it removes all of the
	intersection data associated with edge0.  If one_edge is FALSE, it
	removes the single intersection data node associated with edge0
	and edge1.
	
PARAMETERS
	one_edge (IN) - if TRUE, remove all intersections associated with
	                'edge0'; if FALSE, remove single intersection data
	                associated with 'edge0' and 'edge1'
	edge0 (IN) - one of the edges involved in the intersection
	edge1 (IN) - the other edge involved in the intersection

GLOBALS USED
	VEsaved_ints

HISTORY
	11/11/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRboolean              reversed;
	IGRboolean              edge0_is_shared;
	IGRboolean              edge1_is_shared;
	IGRshort                id0;
	IGRint                  bucket_index;
	IGRint                  start_bucket;
	struct VEsaved_int_node *int_node;
	struct VEedge_header    *real_edge0;
	struct VEedge_header    *real_edge1;
	struct VEsaved_int_node *temp_node;
	struct VEsaved_int_node *prev_node;
	

	/* get the real edge for edge0 */
	if ( (edge0->shared_edge == NULL) || (edge0->status & REAL_SHARED_EDGE) )
	   real_edge0 = edge0;
	else
	   real_edge0 = edge0->shared_edge;

	if ( one_edge )
	   {
	   /* remove all intersection data associated with edge0 */
	   if ( !(real_edge0->status & HAS_SAVED_INT_DATA) ) return;
	   
	   start_bucket = VEcalc_bucket_index( (IGRint)edge0->gm_curve3d->bspcv->num_poles,
                                                2, FALSE, FALSE );
	   id0 = real_edge0->saved_cvcv_id;
	   for (  bucket_index = start_bucket; bucket_index < NUM_INT_BUCKETS; bucket_index++ )
	      {
	      int_node = VEsaved_ints.buckets[ bucket_index ];
	      prev_node = NULL;
	      while ( int_node != NULL )
	         {
	         if ( (id0 == int_node->id0) || (id0 == int_node->id1) )
	            {
	            /* remove node */
	            if ( prev_node == NULL )
	               VEsaved_ints.buckets[ bucket_index ] = int_node->next;
	            else
	               prev_node->next = int_node->next;
	   
	            temp_node = int_node;
	            int_node = int_node->next;
	            VEfree_saved_int_node( temp_node );
	            }
	         else
	            {
	            prev_node = int_node;
	            int_node = int_node->next;
	            }

   	         }  /* end: while */

	      }  /* end: for */
	   
	   }  /* end: if ( one_edge ) */
	else
	   {
	   /* remove intersection data associated with edge0 and edge1 */
	   /* get the real edge for edge1 */
	   if ( (edge1->shared_edge == NULL) || (edge1->status & REAL_SHARED_EDGE) )
	      real_edge1 = edge1;
	   else
	      real_edge1 = edge1->shared_edge;

	   if ( !( (real_edge0->status & HAS_SAVED_INT_DATA) && 
	           (real_edge1->status & HAS_SAVED_INT_DATA) ) )
	      {
	      /* both edges don't indicate that they have saved intersection data */
	      return;
	      }

	   edge0_is_shared = (edge0->status & (REAL_SHARED_EDGE | WAS_A_DUMMY) );
	   edge1_is_shared = (edge1->status & (REAL_SHARED_EDGE | WAS_A_DUMMY) );

	   /* get the bucket index */
	   bucket_index = VEcalc_bucket_index( (IGRint)edge0->gm_curve3d->bspcv->num_poles,
	  	                               (IGRint)edge1->gm_curve3d->bspcv->num_poles,
		                               edge0_is_shared,
		                               edge1_is_shared );
		                            
	   /* search for intersection info on the saved intersection list */
	   VEfind_intersection_node( bucket_index,
	                             real_edge0->saved_cvcv_id,
	                             real_edge1->saved_cvcv_id,
	                             &prev_node, &temp_node, &reversed );

	   if ( temp_node != NULL )
	      {
	      /* remove node */
	      if ( prev_node == NULL )
	         VEsaved_ints.buckets[ bucket_index ] = temp_node->next;
	      else
	         prev_node->next = temp_node->next;
	   
	      VEfree_saved_int_node( temp_node );
	      }

	   }  /* end: else */
	   
	}  /* VEremove_intersection_info */
