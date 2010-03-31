
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

#define  CHECK_RETURN_CODES 1

#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"

#include "igr.h"
#include "igrdp.h"

#include "bs.h"
#include "bsparameters.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

#include "go.h"
#include "dpstruct.h"

/* prototype files */
#include "VEpr_driver.h"
#include "VEpr_utilimp.h"
#include "VEpr_utilfnc.h"

/* External Global Variables  */
extern struct VEsort_record      **VEbuckets;
extern struct VEwindow_info      VEwin_info;
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

static void VEtraverse_tree __((
				struct VEsort_record    **tree,
				struct VEelement_header **active_elems ));

static void VEtraverse_tree_above_center __(( 
				struct VEsort_record    **tree,
				struct VEelement_header **active_elems ));

static void VEtraverse_tree_below_center __(( 
				struct VEsort_record    **tree,
				struct VEelement_header **active_elems ));

static void VEabort_processing __((
				struct VEelement_header **active_list ));

static void VEremove_all_elements_from_active_list __((
				struct VEelement_header *active_list ));

#if defined(__cplusplus)
}
#endif

#undef __


/*--- VEtraverse_tree ---------------------------------------------------*/

static void VEtraverse_tree( tree, active_elems )

	struct VEsort_record    **tree;
	struct VEelement_header **active_elems;
	
/*
NAME
	VEtraverse_tree (static)

DESCRIPTION
	Drive the marking and hiding processes of Vector Hidden Line by
	traversing a binary tree structure of elements.
	
PARAMETERS
	tree (IN/OUT) - the sort tree to traverse
	active_elems (IN/OUT) - the active element list

GLOBALS USED
	VEexec_status

HISTORY
	03/06/87    S.P. Rogers
	   Creation Date
*/

	{
	if ( *tree )
	   {
	   VEtraverse_tree( &((*tree)->left), active_elems );
	   if ( VEexec_status.VEabort ) return;
	   
	   VEactivate_element( (*tree), active_elems );
	   if ( VEexec_status.VEabort ) return;

	   VEtraverse_tree( &((*tree)->right), active_elems );
	   
	   /* free this node in the binary tree */
	   free( (IGRchar *) (*tree) );
	   *tree = NULL;

	   }  /* end: if ( *tree ) */

	}  /* VEtraverse_tree */


/*--- VEtraverse_tree_above_center -------------------------------------------------*/

static void VEtraverse_tree_above_center( tree, active_elems )

/*
NAME
	VEtraverse_tree_above_center (static)

DESCRIPTION
	Drive the marking and hiding processes of Vector Hidden Line by
	traversing a binary tree structure of elements
	
	This routine is an extension of VEtraverse_tree().  It performs
	the first pass tree traversal, selecting only those objects that are
	completely above the center line.
	
PARAMETERS
	tree (IN/OUT) - the sort tree to traverse
	active_elems (IN/OUT) - the active element list

GLOBALS USED
	VEexec_status
	VEwin_info

HISTORY
	03/06/87    S.P. Rogers
	   Creation Date
*/

	struct VEsort_record    **tree;
	struct VEelement_header **active_elems;
	
	{
	if ( *tree )
	   {
	   VEtraverse_tree_above_center( &((*tree)->left), active_elems );
	   if ( VEexec_status.VEabort ) return;

	   if ( (*tree)->range[1] > VEwin_info.VEy_middle )
	      {
	      VEactivate_element( (*tree), active_elems );
	      if ( VEexec_status.VEabort ) return;

	      VEtraverse_tree_above_center( &((*tree)->right), active_elems );
			
	      if ( (*tree)->left == NULL && (*tree)->right == NULL )
	         {
	         free( (IGRchar *) (*tree) );
	         *tree = NULL;
	         }
	      else
	         {
	         (*tree)->range[4] = (*tree)->range[1] - 1.0;
	         }
	      }
	   else
	      {
	      VEtraverse_tree_above_center( &((*tree)->right), active_elems );
	      }

	   }  /* end: if ( *tree ) */

	}  /* VEtraverse_tree_above_center */
	

/*--- VEtraverse_tree_below_center ---------------------------------------------------*/

static void VEtraverse_tree_below_center( tree, active_elems )

/*
NAME
	VEtraverse_tree_below_center (static)

DESCRIPTION
	Drive the marking and hiding processes of Vector Hidden Line by
	traversing a binary tree structure of elements
	
	This routine does the second pass of the tree traversal.  It activates
	all the objects below the center line, and deletes the nodes that 
	VEtraverse_tree_above_center() did not.
	
PARAMETERS
	tree (IN/OUT) - the sort tree to traverse
	active_elems (IN/OUT) - the active element list

GLOBALS USED
	VEexec_status

HISTORY
	03/06/87    S.P. Rogers
	   Creation Date
*/

	struct VEsort_record    **tree;
	struct VEelement_header **active_elems;
	
	{
	if ( *tree )
	   {
	   VEtraverse_tree_below_center( &((*tree)->left), active_elems );
	   if ( VEexec_status.VEabort ) return;
	   
	   if ( (*tree)->range[4] >= (*tree)->range[1] )
	      {
	      VEactivate_element( (*tree), active_elems );
	      if ( VEexec_status.VEabort ) return;
	      }

	   VEtraverse_tree_below_center( &((*tree)->right), active_elems );
	   
	   /* free this node in the binary tree */
	   free( (IGRchar *) (*tree) );
	   *tree = NULL;

	   }  /* end: if ( *tree ) */

	}  /* VEtraverse_tree_below_center */


/*--- VEabort_processing --------------------------------------------------*/

static void VEabort_processing( active_list )

	struct VEelement_header **active_list;
	
/*
NAME
	VEabort_processing (static)

DESCRIPTION
	This function performs the processing required to abort VE processing
	if the user hits the stop sign.  It outputs all finished elements
	from the active list and frees everything from the sort structure

PARAMETERS
	active_list (IN/OUT) - active element list

GLOBALS USED
	VEbuckets

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRint                  bucket;
	struct VEedge_header    *this_edge;
	struct VEedge_header    *next_edge;
	struct VEelement_header *this_elem;
	struct VEelement_header *next_elem;
	
		
	VEissue_abort_message();
	
	/* reset the stop sign => This is done so the update of */
	/* the window if reference files were turned off works  */
	IGEresetstop();

	/* traverse active list and remove finished elements */
	VEremove_finished_elements( active_list );
	
	/* free all of the sort records */
	for ( bucket = 0; bucket < NUM_SORTING_BUCKETS; bucket++ )
	  {
	  if ( VEbuckets[bucket] )
	     VEfree_sort_record_tree( &VEbuckets[bucket] );
	  }  /* end: for */

	/* free the remaining active elements */
	this_elem = *active_list;
	while ( this_elem )
	   {
	   next_elem = this_elem->next;
	   this_edge = this_elem->edges;
	   while ( this_edge )
	      {
	      next_edge = this_edge->next;
	      VEfree_visib_node_list( this_edge->visib_list );
	      VEfree_temp_node_list( this_edge->temp_list );
	      VEfree_edge_header( this_edge );
	      this_edge = next_edge;
	      }  /* end: while */

	   VEfree_element_header( this_elem );
	   this_elem = next_elem;
	   }  /* end: while */

	*active_list = NULL;
	
	}  /* VEabort_processing */


/*--- VEremove_all_elements_from_active_list -----------------------------------------*/

static void VEremove_all_elements_from_active_list( active_list )

	struct VEelement_header *active_list;

/*
NAME
	VEremove_all_elements_from_active_list (static)

DESCRIPTION
	This function removes and creates curves for all the elements
	that are on the active list.

PARAMETERS
	active_list (IN/OUT) - the active list

GLOBALS USED
	none

HISTORY
	xx/xx/xx   S.P. Rogers
	   Creation Date
*/

	{
	struct VEelement_header *this_elem, *next_elem;

	while ( active_list )
	   {
	   this_elem = active_list;
	   active_list = active_list->next;

	   if ( this_elem->type == SOLID_HEADER )
	      {
	      next_elem = this_elem->next_in_solid;
	      VEfree_element_header( this_elem );
	      this_elem = next_elem;
	      }

	   while ( this_elem )
	      {
	      next_elem = this_elem->next_in_solid;
	      VEestablish_curves( this_elem );
	      this_elem = next_elem;
	      }
	   }

	}  /* VEremove_all_elements_from_active_list */


/*--- VEprocess_elements -------------------------------------------------------------*/

void VEprocess_elements()

	
/*
NAME
	VEprocess_elements

DESCRIPTION
	Vector Hidden Line driver.  Activate and process all of the located
	elements by traversing through the bucket sort structure.

PARAMETERS
	none

GLOBALS USED
	VEexec_status
	VEbuckets

HISTORY
	S.P. Rogers  01/20/87  Creation Date
*/

	{
	IGRint                  bucket;
	struct VEelement_header *active_elems;
	
	/* If none of the elements crossed the center line of the window, */
	/* process those above the line first and then process the ones   */
	/* below it.  Otherwise, process them all at the same time.       */
	if ( ! VEexec_status.VEtouched_center_line )
	   {
	   /* process all of the elements above the center line */
	   active_elems = NULL;
	   for ( bucket = 0; bucket < NUM_SORTING_BUCKETS && !VEexec_status.VEabort; bucket++ )
	      {
	      if ( VEbuckets[bucket] )
	         VEtraverse_tree_above_center( &VEbuckets[bucket], &active_elems );
	      }
			   
	   if ( VEexec_status.VEabort )
	      {
	      VEabort_processing( &active_elems );
	      return;
	      }
	         
	   /* establish curves for the elements that are still on the active list */
	   VEremove_all_elements_from_active_list( active_elems );
	   
	   /* process all of the elements below the center line */
	   active_elems = NULL;
	   for ( bucket = 0; bucket < NUM_SORTING_BUCKETS && !VEexec_status.VEabort; bucket++ )
	      {
	      if ( VEbuckets[bucket] )
	         VEtraverse_tree_below_center( &VEbuckets[bucket], &active_elems );
	      }
			   
	   if ( VEexec_status.VEabort )
	      {
	      VEabort_processing( &active_elems );
	      return;
	      }

	   /* establish curves for the elements that are still on the active list */
	   VEremove_all_elements_from_active_list( active_elems );
	   }
	else
	   {
	   active_elems = NULL;
	   for ( bucket = 0; bucket < NUM_SORTING_BUCKETS && !VEexec_status.VEabort; bucket++ )
	      {
	      if ( VEbuckets[bucket] )
	         VEtraverse_tree( &VEbuckets[bucket], &active_elems );
	      }
	   
	   if ( VEexec_status.VEabort )
	      {
	      VEabort_processing( &active_elems );
	      return;
	      }

	   /* establish curves for the elements that are still on the active list */
	   VEremove_all_elements_from_active_list( active_elems );
	   }  /* end: else */

	}  /* VEprocess_elements */

