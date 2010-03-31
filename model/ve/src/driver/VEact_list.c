
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "bs.h"
#include "bsparameters.h"

#include "gr.h"
#include "go.h"

#include "dpstruct.h"

#include "ve.h"
#include "vedef.h"

/* prototype files */
#include "VEpr_driver.h"
#include "VEpr_utilfnc.h"
#include "VEpr_hiding.h"
#include "VEpr_utilimp.h"

#define SORT_TOL 1e-4


static IGRshort criteria_masks[5] = { Z_IN_FRONT | TOTAL_OVERLAP,
                                      Z_IN_FRONT | SOME_OVERLAP,
                                      Z_OVERLAP  | TOTAL_OVERLAP,
                                      Z_OVERLAP  | SOME_OVERLAP,
                                      Z_BEHIND };

static IGRboolean criteria_met[5];


/* External Globlal Variables */
extern struct VEexecution_parms  VEexec_parms;
extern struct VEexecution_status VEexec_status;

/* static prototypes */

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void VEdetermine_sorting_classification __((	
					struct VEelement_header *this_elem,
					struct VEelement_header *new_elem ));

static IGRboolean VEsorting_comparison_function __(( 
					struct VEelement_header *elem0,
					struct VEelement_header *elem1 ));

static void VEremove_edgeless_elements __((
					struct VEelement_header **active_list ));

static void VEdelete_from_active_list __((
				 	struct VEelement_header *prev,
					struct VEelement_header **cur,
					struct VEelement_header **list ));

static void VEcompare_elements __((
					struct VEelement_header *dom_elem,
					struct VEelement_header *pass_elem ));

static void VEremove_finished_surfaces_from_solid __((
					struct VEelement_header *solid,
					IGRdouble               sort_xmin ));

#if defined(__cplusplus)
}
#endif

#undef __

/*--- VEdetermine_sorting_classification ----------------------------------*/

static void VEdetermine_sorting_classification( this_elem, new_elem )

	struct VEelement_header *this_elem;
	struct VEelement_header *new_elem;
	
/*
NAME
	VEdetermine_sorting_classification (static)

DESCRIPTION
	This function determines the sorting classification between an
	element in the active list and an element being inserted into
	the active list.  The classification is based on whether 'this_elem'
	is IN_FRONT, OVERLAPS, or BEHIND 'new_elem' in z and whether
	'this_elem' totally overlaps the range of 'new_elem' in x and y.

PARAMETERS
	this_elem (IN/OUT) - an element already in the active list
	new_elem (IN) - the new element being inserted into the active list

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	    Creation Date
*/

	{
	IGRint ii;

	/* Classify the Z-extents of this_elem and new_elem */
	if ( this_elem->range[ZMIN] < new_elem->range[ZMIN] )
	   {
	   if ( this_elem->range[ZMAX] < new_elem->range[ZMIN] )
	      this_elem->flags |= Z_IN_FRONT;
	   else
	      this_elem->flags |= Z_OVERLAP;
	   }
	else
	   {
	   if ( new_elem->range[ZMAX] < this_elem->range[ZMIN] )
	      this_elem->flags |= Z_BEHIND;
	   else
	      this_elem->flags |= Z_OVERLAP;
	   }
	   
	/* classify the coverage area */
	if ( (this_elem->range[XMIN] < new_elem->range[XMIN]) &&
	     (this_elem->range[XMAX] > new_elem->range[XMAX]) &&
	     (this_elem->range[YMIN] < new_elem->range[YMIN]) &&
	     (this_elem->range[YMAX] > new_elem->range[YMAX]) )
	   this_elem->flags |= TOTAL_OVERLAP;
	else
	   this_elem->flags |= SOME_OVERLAP;
	
	for ( ii = 1; ii < 5; ii++ )
	   {
	   if ( (this_elem->flags & criteria_masks[ii]) == criteria_masks[ii] )
	      {
	      criteria_met[ii] = TRUE;
	      break;
	      }
	   }

	}  /* VEdetermine_sorting_classification */
	

/*--- VEsorting_comparision_function ----------------------------------*/

static IGRboolean VEsorting_comparison_function( elem0, elem1 )

	struct VEelement_header *elem0;
	struct VEelement_header *elem1;
	
/*
NAME
	VEsorting_comparison_function (static)

DESCRIPTION
	This function returns TRUE if elem0 is "less than" elem1.  That is,
	if elem0 should be inserted before elem1.  The comparison is
	currently based on the XY range box area of the element.  If the area
	of the range box is larger, the element is said to be less than the
	other element.

PARAMETERS
	elem0 (IN) - the first element
	elem1 (IN) - the second element

RETURN VALUES
	TRUE, if elem0 is "less than" elem1
	FALSE, otherwise

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	    Creation Date
*/

	{
	IGRdouble area0, area1;
	
	area0 = (elem0->range[XMAX] - elem0->range[XMIN]) *
	        (elem0->range[YMAX] - elem0->range[YMIN]);

	area1 = (elem1->range[XMAX] - elem1->range[XMIN]) *
	        (elem1->range[YMAX] - elem1->range[YMIN]);
	
	if ( area0 >= area1 )
	   return( TRUE );
	else
	   return( FALSE );

	}  /* VEsorting_comparison_function */
	

/*--- VEremove_edgeless_elements -------------------------------------*/

static void VEremove_edgeless_elements( active_list )

	struct VEelement_header **active_list;
	
/*
NAME
	VEremove_edgeless_elements (static)

DESCRIPTION
	This function removes all elements from the the active list
	that no longer have any edges.

PARAMETERS
	active_list (IN/OUT) - the active list to check

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	struct VEelement_header *prev;
	struct VEelement_header *cur;
	struct VEelement_header *temp;
	
	prev = NULL;
	cur = *active_list;
	
	while ( cur )
	   {
	   if ( (cur->type != SOLID_HEADER) && (cur->edges == NULL) )
	      {
	      temp = cur;
	      
	      if ( prev == NULL )
	         {
	         *active_list = cur->next;
	         cur = *active_list;
	         }
	      else
	         {
	         prev->next = cur->next;
	         cur = cur->next;
	         }

	      VEfree_element_header( temp );
	      VEupdate_num_finished();

	      }  /* end: if ( cur->edges == NULL ) */
	   else
	      {
	      prev = cur;
	      cur = cur->next;
	      }

	   }  /* end: while */
	      
	}  /* VEremove_edgeless_elements */
	      	

/*--- VEdelete_from_active_list -------------------------------------*/

static void VEdelete_from_active_list( prev, cur, list )

	struct VEelement_header *prev;
	struct VEelement_header **cur;
	struct VEelement_header **list;

/*
NAME
	VEdelete_from_active_list (static)

DESCRIPTION
	This function deletes an element from the active element
	list and establish the output curves for the element.

PARAMETERS
	prev (IN/OUT) - the element before the one to be deleted
	cur (IN/OUT) - the element to be deleted
	list (IN/OUT) - the head of the active list

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	struct VEelement_header *temp_elem, *next_elem;

	temp_elem = *cur;

	if ( prev == NULL )
	   {
	   *list = (*cur)->next;
	   *cur  = *list;
	   }
	else
	   {
	   prev->next = (*cur)->next;
	   *cur = (*cur)->next;
	   }

	if ( temp_elem->type == SOLID_HEADER )
	   temp_elem = temp_elem->next_in_solid;

	while ( temp_elem )
	   {
	   next_elem = temp_elem->next_in_solid;
	   VEestablish_curves( temp_elem );
	   temp_elem = next_elem;
	   }
	
	}  /* VEdelete_from_active_list */


/*--- VEcompare_elements ---------------------------------------------------*/

static void VEcompare_elements( dom_elem, pass_elem )

	struct VEelement_header *dom_elem;
	struct VEelement_header *pass_elem;

/*
NAME
	VEcompare_elements (static)

DESCRIPTION
	This function compares two elements by calling VEcomp_surfs() for each
	pair of their components.

PARAMETERS
	dom_elem (IN) - the dominant element
	pass_elem (IN) - the passive element

GLOBALS USED
	VEexec_status

HISTORY
	08/xx/90    S.P. Rogers
	   Creation Date
*/

	{
	struct VEelement_header *this_dom_elem, *this_pass_elem;

	if ( dom_elem->type == SOLID_HEADER )
	   dom_elem = dom_elem->next_in_solid;

	if ( pass_elem->type == SOLID_HEADER )
	   pass_elem = pass_elem->next_in_solid;

	this_dom_elem = dom_elem;
	while ( this_dom_elem )
	   {
	   this_pass_elem = pass_elem;
	   while ( this_pass_elem )
	      {
	      VEcomp_surfs( this_dom_elem, this_pass_elem, VEexec_parms.VEhiding, FALSE );
	      this_pass_elem = this_pass_elem->next_in_solid;
	      if ( VEexec_status.VEabort )
	         break;
	      }
	   if ( VEexec_status.VEabort )
	      break;
	   this_dom_elem = this_dom_elem->next_in_solid;
	   }

	if ( ! VEexec_status.VEabort )
	   {
	   /* Determine the visibility of the edges using point projections */
	   VEset_visibilities_mult_proj( dom_elem, pass_elem, FALSE, VEexec_parms.VEhiding );
	   VEset_visibilities_mult_proj( pass_elem, dom_elem, FALSE, VEexec_parms.VEhiding );
	   }

	}  /* VEcompare_elements */


/*--- VEremove_finished_surfaces_from_solid --------------------------------------*/

static void VEremove_finished_surfaces_from_solid( solid, sort_xmin )

	struct VEelement_header *solid;
	IGRdouble               sort_xmin;

/*
NAME
	VEremove_finished_surface_from_solid (static)

DESCRIPTION
	This function removes surfaces from a solid whose XMAX is less
	than the XMIN of the element being added to the active list.

PARAMETERS
	solid (IN) - the solid to check
	sort_xmin (IN) - the current sorting xmin

GLOBALS USED
	none

HISTORY
	S.P. Rogers  09/07/90  Creation Date.
*/

	{
	struct VEelement_header *prev_elem, *this_elem, *temp_elem;

	if ( solid->type != SOLID_HEADER )
	   return;

	prev_elem = solid;
	this_elem = solid->next_in_solid;
	while ( this_elem )
	   {
	   if ( sort_xmin > (this_elem->range[XMAX] + SORT_TOL) )
	      {
	      temp_elem = this_elem;
	      prev_elem->next_in_solid = this_elem = this_elem->next_in_solid;
	      VEestablish_curves( temp_elem );
	      }
	   else
	      {
	      prev_elem = this_elem;
	      this_elem = this_elem->next_in_solid;
	      }
	   }  /* end: while */

	}  /* VEremove_finished_surfaces_from_solid */


/*--- VEinsert_into_active_list -----------------------------------*/

void VEinsert_into_active_list( new_elem, sort_xmin, active_list )

	struct VEelement_header *new_elem;
	IGRdouble               sort_xmin;
	struct VEelement_header **active_list;

/*
NAME
	VEinsert_into_active_list

DESCRIPTION
	Insert a new element into the active element list and remove the
	elements that should no longer be active.

PARAMETERS
	new_elem (IN) - the new element to insert
	sort_xmin (IN) - the sorting xmin of the element (not necessarily
	                 what is currently in new_elem->range[0])
	active_list (IN/OUT) - the active list to insert the element in

NOTES
	This function makes the assumption that the elements arrive
	sorted by minimum x

GLOBALS USED
	VEexec_status

HISTORY
	06/05/87    S.P. Rogers
	    Creation Date
*/

	{
	IGRboolean              inserted;
	IGRboolean              stop_comparing;
	IGRint                  ii;
	IGRdouble               *new_range;
	IGRdouble               *this_range;
	struct VEelement_header *prev_elem;
	struct VEelement_header *this_elem;
		

	inserted = FALSE;
	stop_comparing = FALSE;
	new_range = new_elem->range;

	for ( ii = 1; ii < 5; ii++ )
	   criteria_met[ii] = FALSE;
	   
	prev_elem = NULL;
	this_elem  = *active_list;
	/* Look at all the elements on the active list and:  insert new_elem */
	/* into its appropriate place, remove any elements that should be    */
	/* deactivated based on new_elem's XMIN, classify the elements that  */
	/* overlap new_elem in XY space, and compare the elements that meet  */
	/* the highest classification with new_elem.                         */
	while ( this_elem )
	   {
	   if ( (! inserted) && (VEsorting_comparison_function( new_elem, this_elem )) )
	      {
	      /* new_elem should be inserted before this_elem */
	      if ( prev_elem == NULL )
	         *active_list = new_elem;
	      else
	         prev_elem->next = new_elem;

	      prev_elem = new_elem;
	      new_elem->next = this_elem;

	      inserted = TRUE;
	      }  /* insert new_elem before this_elem */

	   this_range = this_elem->range;
	   if ( sort_xmin > (this_range[XMAX] + SORT_TOL) )
	      {
	      /* remove this_elem from active_list */
	      VEdelete_from_active_list( prev_elem, &this_elem, active_list );
	      }
	   else
	      {
	      /* remove any surfaces from this_elem that are out of range */
	      VEremove_finished_surfaces_from_solid( this_elem, sort_xmin );

	      if ( (this_elem->type == SOLID_HEADER) && (!this_elem->next_in_solid) )
	         {
	         /* all surfaces from this solid are gone => remove it from the active list */
	         VEdelete_from_active_list( prev_elem, &this_elem, active_list );
	         }
	      else
	         {
	         /* clear this_elem's classification bits */
	         this_elem->flags &= ~CLASSIFICATION_BITS;

	         if ( (! stop_comparing) &&
	              (new_range[XMIN] <= (this_range[XMAX] + SORT_TOL) ) &&
	              (new_range[XMAX] >= (this_range[XMIN] - SORT_TOL) ) &&
	              (new_range[YMIN] <= (this_range[YMAX] + SORT_TOL) ) &&
	              (new_range[YMAX] >= (this_range[YMIN] - SORT_TOL) ) )
	            {
	            /* XY range boxes overlap => classify this_elem w.r.t. new_elem and  */
	            /* compare it with any elements that meet the highest classification */
	            VEdetermine_sorting_classification( this_elem, new_elem );
	            
	            if ( (this_elem->flags & criteria_masks[0]) == criteria_masks[0] )
	               {
	               VEcompare_elements( new_elem, this_elem );

	               if ( VEexec_status.VEabort )
	                  {
	                  if ( ! inserted )
	                     {
	                     /* delete the new element because it hasn't been inserted yet */
	                     VEdelete_element_due_to_abort( new_elem );
	                     }
	                  return;
	                  }

	               if ( ! VEexec_parms.VEhiding )
	                  {
	                  /* we are running GPE so we can remove any edges */
	                  /* that have become totally overlapped.          */
	                  VEremove_totally_overlapped_edges( this_elem );

	                  VEremove_totally_overlapped_edges( new_elem );
	                  if ( (new_elem->type != SOLID_HEADER) && (new_elem->edges == NULL) )
	                     {
	                     /* all of new_elem's edges have become totally overlapped => */
	                     /* continue with the insertion process but don't compare     */
	                     /* new_elem with any more surfaces                           */
	                     stop_comparing = TRUE;
	                     }

	                  }  /* end: if ( ! VEexec_parms.VEhiding ) */

	               }  /* end: if elements should be compared */

	            }  /* end: XY range boxes overlap */
	            
	         prev_elem = this_elem;
	         this_elem = this_elem->next;
	         }

	      }

	   }  /* end: while */

	if (! inserted)
	   {
	   /* new_elem should be inserted at the end of the active list */
	   if ( prev_elem == NULL )
	      *active_list = new_elem;
	   else
	      prev_elem->next = new_elem;

	   new_elem->next = NULL;
	   }

	/* Perform the remaining passes through the active list comparing   */
	/* those elements that meet the classification for the current pass */
	for ( ii = 1; ( (ii < 5) && (!stop_comparing) ); ii++ )
	   {
	   if ( criteria_met[ii] )
	      {
	      this_elem = *active_list;
	      while ( (this_elem) && (! stop_comparing) )
	         {
	         if ( (this_elem->flags & criteria_masks[ii]) == criteria_masks[ii] )
	            {
	            VEcompare_elements( new_elem, this_elem );

	            if ( VEexec_status.VEabort )
	               return;

	            if ( ! VEexec_parms.VEhiding )
	               {
	               /* we are running GPE so we can remove any edges */
	               /* that have become totally overlapped.          */
	               VEremove_totally_overlapped_edges( this_elem );

	               VEremove_totally_overlapped_edges( new_elem );
	               if ( (new_elem->type != SOLID_HEADER) && (new_elem->edges == NULL) )
	                  {
	                  /* all of new_elem's edges have become totally */
	                  /* overlapped => stop comparing                */
	                  stop_comparing = TRUE;
	                  }

	               }  /* end: if ( ! VEexec_parms.VEhiding ) */

	            }  /* end: if elements should be compared */

	         this_elem = this_elem->next;
	         }  /* end: while */

	      }  /* end: if ( criteria_met[i] ) */
	      
	   }  /* end: for */
	      
	/* If we are running GPE, remove any elements that have no edges    */
	/* from the active list because they can't contribute to the output */
	if ( ! VEexec_parms.VEhiding )
	   VEremove_edgeless_elements( active_list );
	
	}  /* VEinsert_into_active_list */

	
/*--- VEremove_finished_elements -----------------------------------*/

void VEremove_finished_elements( active_list )

	struct VEelement_header **active_list;

/*
NAME
	VEremove_finished_elements

DESCRIPTION
	Remove all finished elements from the active list in order to
	abort processing prematurely.  

PARAMETERS
	active_list (IN/OUT) - the active list

GLOBALS USED
	VEexec_status

HISTORY
	10/26/87    S.P. Rogers
	   Creation Date
*/

	{
	struct VEelement_header *prev;
	struct VEelement_header *cur;

	prev = NULL;
	cur  = *active_list;

	/* An element is finished if its XMAX is less than the next */
	/* element's XMIN.                                          */
	while ( cur )
	   {
	   if ( VEexec_status.VEabort_xmin > (cur->range[XMAX] + SORT_TOL) )
	      VEdelete_from_active_list( prev, &cur, active_list );
	   else
	      {
	      prev = cur;
	      cur  = cur->next;
	      }
	   }

	}  /* VEremove_finished_elements */
