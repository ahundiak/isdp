
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

#include <stdio.h>
#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "HStl_element.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"

#include "HSpr_render.h"


/*
 *  Prototype declaration for static functions
 */


#if defined (__) 
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

/* HRreclaim.c */
static struct HRgeneric_sort_record *HRremove_min_trap __((
			struct HRgeneric_sort_record **tree));
			
static IGRboolean HRremove_traps_from_tree __((
			struct HRgeneric_sort_record **tree, 
		    struct HRspecial_rendering_parms *attr, 
					  IGRboolean *at_least_one_deleted));
					  
static IGRboolean HRfind_leaf_trap __((
			struct HRgeneric_sort_record *tree, 
			struct HRgeneric_sort_record **trap));
			
static IGRboolean HRfind_any_trap __((
			struct HRgeneric_sort_record *tree, 
			struct HRgeneric_sort_record **trap));
			
static struct HRsurface_record *HRremove_surface_from_list __((
			     struct HRsurface_record **list, 
		    struct HRspecial_rendering_parms *attr));
		    
static struct HRsurface_record *HRfind_and_remove_surface __((void));



#if defined(__cplusplus)
}
#endif


#undef __



/*--- HRremove_min_trap ----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HRgeneric_sort_record *HRremove_min_trap( struct HRgeneric_sort_record **tree )
#else
	static struct HRgeneric_sort_record *HRremove_min_trap( tree )

	struct HRgeneric_sort_record **tree;
#endif

/*
DESCRIPTION
	This function removes the minimum trapezoid from a binary tree of trapezoids.

HISTORY
	S.P. Rogers  10/05/89  Creation Date
*/

	{
	struct HRgeneric_sort_record *temp;

	if ( (*tree)->left == NULL )
	   {
	   temp = *tree;
	   *tree = (*tree)->right;
	   return( temp );
	   }
	else
	   return( HRremove_min_trap( &(*tree)->left ) );

	}  /* HRremove_min_trap */


/*--- HRremove_traps_from_tree ----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean HRremove_traps_from_tree( struct HRgeneric_sort_record **tree,
						struct HRspecial_rendering_parms *attr,
								      IGRboolean *at_least_one_deleted )
#else
	static IGRboolean HRremove_traps_from_tree( tree, attr, at_least_one_deleted )

	struct HRgeneric_sort_record     **tree;
	struct HRspecial_rendering_parms *attr;
	IGRboolean                       *at_least_one_deleted;
#endif

/*
DESCRIPTION
	This function removes all the trapezoids from a binary tree that belong to
	a given surface.  The surface is indicated by a pointer to its rendering
	attributes.  All trapezoids from the same surface should have the same pointer
	to the rendering attributes.  The alogirthm used to remove the trapezoids from
	the binary tree is a post-order traversal of the tree.

	If at least one trapezoid was deleted, *at_least_one_deleted is set to TRUE.
	It is set to FALSE if no trapezoids were deleted.  The calling function
	is responsible for setting *at_least_one_deleted to FALSE before calling this
	function because of the recursive nature of this function.

HISTORY
	S.P. Rogers  10/05/89  Creation Date
*/

	{
	struct HRgeneric_sort_record *free_node;
	struct HRgeneric_sort_record *min_node;

	if ( *tree )
	   {
	   HRremove_traps_from_tree( &(*tree)->left, attr, at_least_one_deleted );
	   HRremove_traps_from_tree( &(*tree)->right, attr, at_least_one_deleted );

	   if ( ((struct HRspan_trapezoid *)(*tree))->attr == attr )
	      {
	      /* remove node from tree and place on free list */
	      free_node = *tree;

	      if ( ((*tree)->left == NULL) && ((*tree)->right == NULL) )
	         *tree = NULL;
	      else if ( (*tree)->left == NULL )
	         *tree = (*tree)->right;
	      else if ( (*tree)->right == NULL )
	         *tree = (*tree)->left;
	      else
	         {
	         /* both subtrees are present => move smallest trap from */
	         /* the right subtree into the node's place              */
	         min_node = HRremove_min_trap( &(*tree)->right );
	         min_node->left = (*tree)->left;
	         min_node->right = (*tree)->right;
	         *tree = min_node;
	         }	
	     
	      HRfree_span_trap( (struct HRspan_trapezoid *)free_node );
	      *at_least_one_deleted = TRUE;
	      }  /* end: trapezoid should be removed */

	   }  /* end: if ( *tree ) */

	return(0);
	}  /* HRremove_traps_from_tree */


/*--- HRfind_leaf_trap -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean HRfind_leaf_trap( struct HRgeneric_sort_record *tree,
					    struct HRgeneric_sort_record **trap )
#else
	static IGRboolean HRfind_leaf_trap( tree, trap )

	struct HRgeneric_sort_record *tree;
	struct HRgeneric_sort_record **trap;
#endif

/*
DESCRIPTION
	This function looks for a leaf trapezoid in binary tree of trapezoids that doesn't belong
	to the surface currently being tiled.  If it finds one, trap is set to point to it
	and TRUE is returned.  If a trapezoid is not found, FALSE is returned.

HISTORY
	S.P. Rogers  10/11/89  Creation Date
*/

	{
	if ( tree )
	   {
	   if ( (tree->left == NULL) && (tree->right == NULL) )
	      {
	      if ( ((struct HRspan_trapezoid *)tree)->attr != &(rendering_globals.cur_surf->rend_parms) )
	         {
	         /* trapezoid doesn't belong to current surface */
	         *trap = tree;
	         return( TRUE );
	         }
	      }
	   else
	      return( HRfind_leaf_trap( tree->left, trap ) || HRfind_leaf_trap( tree->right, trap ) );
	   }
	else	     
	   return( FALSE );

	return(0);
	}  /* HRfind_leaf_trap */


/*--- HRfind_any_trap -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean HRfind_any_trap( struct HRgeneric_sort_record *tree,
					   struct HRgeneric_sort_record **trap )
#else
	static IGRboolean HRfind_any_trap( tree, trap )

	struct HRgeneric_sort_record *tree;
	struct HRgeneric_sort_record **trap;
#endif

/*
DESCRIPTION
	This function looks for a trapezoid in binary tree of trapezoids that doesn't belong
	to the surface currently being tiled.  If it finds one, trap is set to point to it
	and TRUE is returned.  If a trapezoid is not found, FALSE is returned.

HISTORY
	S.P. Rogers  10/11/89  Creation Date
*/

	{
	if ( tree )
	   {
	   if ( ((struct HRspan_trapezoid *)tree)->attr != &(rendering_globals.cur_surf->rend_parms) )
	      {
	      /* trapezoid doesn't belong to current surface */
	      *trap = tree;
	      return( TRUE );
	      }
	   else
	      return( HRfind_any_trap( tree->left, trap ) || HRfind_any_trap( tree->right, trap ) );
	   }
	else	     
	   return( FALSE );

	}  /* HRfind_any_trap */


/*--- HRremove_surface_from_list ------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HRsurface_record *HRremove_surface_from_list( struct HRsurface_record **list,
							   struct HRspecial_rendering_parms *attr )
#else
	static struct HRsurface_record *HRremove_surface_from_list( list, attr )

	struct HRsurface_record          **list;
	struct HRspecial_rendering_parms *attr;
#endif

/*
DESCRIPTION
	Given the linked list of surface headers in a surface bucket and a pointer to a 
	rendering attributes structure, remove the surface header that contains those rendering 
	attributes from the list and return a pointer to it.  If a surface containing the
	rendering attributes is not in the list, return NULL,

HISTORY
	S.P. Rogers  10/11/89  Creation Date
*/

	{
	struct HRsurface_record *prev_surf;
	struct HRsurface_record *this_surf;

	prev_surf = NULL;
	this_surf = *list;

	while ( this_surf )
	   {
	   if ( &(this_surf->rend_parms) == attr )
	      {
	      /* remove the surface */
	      if ( prev_surf )
	         prev_surf->next = this_surf->next;
	      else
	         *list = this_surf->next;
	      return( this_surf );
	      }
	   else
	      {
	      prev_surf = this_surf;
	      this_surf = this_surf->next;
	      }

	   }  /* end: while */

	return( NULL );

	}  /* HRremove_surface_from_list */
	

/*--- HRfind_and_remove_surface ---------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HRsurface_record *HRfind_and_remove_surface(void)
#else
	static struct HRsurface_record *HRfind_and_remove_surface()
#endif

/*
DESCRIPTION
	This function selects a surface that will have its non-active trapezoids removed and
	removes it from the bucket that it is in.  The surface is selected by the following
	algorithm:

	   Work backward from the last trapezoid bucket and find a trapezoid that is a leaf
	   node and doesn't belong to the surface that is currently being tiled.  The surface
	   that owns this trapezoid will then have its non-active trapezoids removed.
	   If a leaf trapezoid is not available, use any trapezoid that doesn't belong to the
	   surface currently being tiled.  If the only trapezoids available belong to the
	   surface currently being tiled, its non-active trapezoids will be removed.

	A pointer to the surface record that was removed is returned.

HISTORY
	S.P. Rogers  10/10/89  Creation Date
*/

	{
	IGRint                  i;
	IGRint                  last_non_empty_bucket;
	struct HRspan_trapezoid *trap;
	struct HRsurface_record *surf = NULL;

	/* starting from the last bucket and working backward find a leaf trapezoid */
	/* that doesn't belong to the surface currently being tiled                 */
	trap = NULL;
	last_non_empty_bucket = -1;
	for ( i = rendering_globals.surface_buckets.num_buckets - 1;
	      i > rendering_globals.scan_line;
	      i-- )
	   {
	   if ( rendering_globals.trap_buckets.buckets[i] )
	      {
	      if ( last_non_empty_bucket < 0 )
	         last_non_empty_bucket = i;
	      if ( HRfind_leaf_trap( rendering_globals.trap_buckets.buckets[i],
					(struct HRgeneric_sort_record **)&trap ) )
	         break;
	      }

	   }  /* end: for */

	if ( ! trap )
	   {
	   /* starting from the last bucket and working backward find any        */
	   /* trapezoid that doesn't belong to the surface currently being tiled */
	   for ( i = last_non_empty_bucket; i > rendering_globals.scan_line; i-- )
	      {
	      if ( rendering_globals.trap_buckets.buckets[i] )
	         {
	         if ( HRfind_any_trap( rendering_globals.trap_buckets.buckets[i], 
				(struct HRgeneric_sort_record **)&trap ) )
	            break;
	         }

	      }  /* end: for */

	   }  /* end: if ( ! trap ) */

	if ( trap )
	   {
	   /* a trapezoid that doesn't belong to the surface currently being tiled */
	   /* was found => find the surface that belongs to the selected trapezoid */
	   /* and remove it from its bucket list                                   */
	   for ( i = 0; i <= rendering_globals.scan_line; i++ )
	      {
	      surf = HRremove_surface_from_list( 
                   (struct HRsurface_record **)&rendering_globals.surface_buckets.buckets[i], 
			trap->attr );
	      if ( surf )
	         break;
	      }  /* end: for */
	   }
	else
	   {
	   /* no trapezoids belonging to surfaces other than the current surface being tiled */
	   /* were available for reclamation => we must remove its non-active trapezoids     */
	   surf = HRremove_surface_from_list( (struct HRsurface_record **)&rendering_globals.surface_buckets.buckets[rendering_globals.scan_line],
	                                      &rendering_globals.cur_surf->rend_parms );
	   }

	return( surf );

	}  /* HRfind_and_remove_surface */


/*--- HRreclaim_trapezoids ----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRreclaim_trapezoids(void)
#else
	void HRreclaim_trapezoids()
#endif

/*
DESCRIPTION
	This function returns trapezoids that have not been activated yet to the free list of
	trapezoids because memory us running out.  It removes the non-active trapezoids for
	a single surface per call.

HISTORY
	S.P. Rogers  10/10/89  Creation Date
*/

	{
	IGRint                  i;
	IGRint                  min_trap_reclaimed=0;
	IGRboolean              at_least_one_reclaimed;
	struct HRsurface_record *surf_rec;

	/* select a surface that will have its non-active trapezoids reclaimed */
	surf_rec = HRfind_and_remove_surface();

	if ( surf_rec )
	   {
	   /* remove the non-active trapezoids for the selected surface and place it in */
	   /* the surface bucket that corresponds to the minimum X of the reclaimed     */
	   /* trapezoids so it will be re-tiled when processing gets to that scan-line  */
	   for ( i = rendering_globals.surface_buckets.num_buckets - 1;
	         i > rendering_globals.scan_line;
	         i-- )
	      {
	      at_least_one_reclaimed = FALSE;
	      HRremove_traps_from_tree( &rendering_globals.trap_buckets.buckets[i],
	                                &surf_rec->rend_parms,
	                                &at_least_one_reclaimed );

	      if ( at_least_one_reclaimed )
	         min_trap_reclaimed = i;
	      }

	   if ( surf_rec == rendering_globals.cur_surf )
	      {
	      /* Removing trapezoids from surface that is currently being tiled => must re-sort    */
	      /* to the next scan-line because all trapezoids aren't available which means we      */
	      /* can't determine the minimum X of all the non-active trapezoids.  Also, set the    */
	      /* flag that indicates that the current surface had some of its trapezoids reclaimed.*/
	      /* The flag will be used by the polybuster to only generate trapezoids that activate */
	      /* on the current scan-line.                                                         */
	      rendering_globals.cur_traps_reclaimed = TRUE;
	      min_trap_reclaimed = rendering_globals.scan_line + 1;
	      }

	   HRbucket_sort_surface( surf_rec, min_trap_reclaimed );
	   }

	}  /* HRreclaim_trapezoids */


