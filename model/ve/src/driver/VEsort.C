
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igr.h"

#include "msdef.h"
#include "msmacros.h"

#include "dpstruct.h"

#include "ve.h"
#include "vedef.h"
#include "vemessage.h"

/* prototype files */
#include "VEpr_driver.h"


/* External Global Varaibles */
extern struct VEsort_record      **VEbuckets;
extern struct VEwindow_info      VEwin_info;
extern struct VEexecution_status VEexec_status;

static IGRdouble  units_per_bucket;
static IGRboolean dup_found;


/*--- VEfree_sort_record_tree --------------------------------------------------*/

void VEfree_sort_record_tree( tree )

	struct VEsort_record **tree;
	
/*
NAME
	VEfree_sort_record_tree

DESCRIPTION
	Free a binary tree of sort records
	
PARAMETERS
	tree (IN/OUT) - the tree of sort records to free

GLOBALS USED
	none

HISTORY
	10/26/87    S.P. Rogers
	   Creation Date
*/

	{

	if ( *tree )
	   {
	   VEfree_sort_record_tree( &((*tree)->left) );
	   VEfree_sort_record_tree( &((*tree)->right) );
	   
	   free( (IGRchar *) *tree );
	   *tree = NULL;
	   }

	}  /* VEfree_sort_record_tree */


/*--- VEsort_by_min_x -------------------------------------------------------------*/

IGRboolean VEsort_by_min_x( sort_rec )

	struct VEsort_record *sort_rec;

/*
NAME
	VEsort_by_min_x

DESCRIPTION
	This function takes a sort record and sorts it into an array of
	buckets.  The key used to determine the bucket index is the XMIN of
	the element in relation to the X-range of the window.	The elements
	inside each bucket are sorted into a binary tree based on their XMIN.

PARAMETERS
	sort_rec (IN) - the sort record to add

GLOBALS USED
	VEwin_info
	VEbuckets

RETURN VALUES
	This function returns TRUE if the sort record was successfully added to
	the array of buckets.  Otherwise, FALSE is returned.

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRint               which_bucket;
	struct VEsort_record *probe;

	sort_rec->left = sort_rec->right = NULL;

	if ( (sort_rec->range[0] > VEwin_info.clip_range[3]) ||
	     (sort_rec->range[1] > VEwin_info.clip_range[4]) ||
	     (sort_rec->range[3] < VEwin_info.clip_range[0]) ||
	     (sort_rec->range[4] < VEwin_info.clip_range[1]) )
	   {
	   /* this element lies entirely outside of the clipping */
	   /* range => we should get rid of it now               */
	   free( (IGRchar *) sort_rec );
	   return( FALSE );
	   }
	else
	   {
	   /* element lies inside of the clipping range => insert in proper bucket */
           if ( (sort_rec->range[1] <= VEwin_info.VEy_middle) &&
                (sort_rec->range[4] >= VEwin_info.VEy_middle) )
	      VEexec_status.VEtouched_center_line = TRUE;

	   which_bucket = (sort_rec->range[0] - VEwin_info.clip_range[XMIN]) * units_per_bucket;
	   if ( which_bucket < 0 )
	       which_bucket = 0;

	   if ( VEbuckets[which_bucket] == NULL )
	      {
	      /* first element in bucket => insert it */
	      VEbuckets[which_bucket] = sort_rec;
	      return( TRUE );
	      }
	   else
	      {
	      /* do binary tree sort */
	      probe = VEbuckets[which_bucket];
	      while ( probe )
 	         {
	         if ( (probe->objid == sort_rec->objid) &&
	              (probe->env->osnum == sort_rec->env->osnum) &&
	              (probe->env->attach_id == sort_rec->env->attach_id) )
	            {
	            /* duplicate entry => get rid of it */
	            free( (IGRchar *) sort_rec );
	            probe = NULL;

	            if ( ! dup_found )
	               {
	               ex$message( msgnumb       = VE_E_RepeatGeom,
	                           field         = ERROR_FIELD,
	                           justification = CENTER_JUS );
	               sleep( 3 );
	               dup_found = TRUE;
	               }
	               
	            return( FALSE );
	            }
	         else if ( probe->range[0] < sort_rec->range[0] )
	            {
	            /* look down the right side */
	            if ( probe->right == NULL )
	               {
	               /* add as the right child */
	               probe->right = sort_rec;
	               probe = NULL;
	               return( TRUE );
	               }
	            else
	               {
	               /* continue down the right side */
	               probe = probe->right;
	               }
	            }
	         else
	            {
	            /* look down the left side */
	            if ( probe->left == NULL )
	               {
	               /* add as the left child */
	               probe->left = sort_rec;
	               probe = NULL;
	               return( TRUE );
	               }   
	            else
	               {
	               /* continue down the left side */
	               probe = probe->left;
	               }
	            }

	         } /* end while ( probe ) */

	      }  /* end: binary tree sort */

	   } /* end: element overlaps the window */

	return( FALSE );
	} /* VEsort_by_min_x */


/*--- VEsort_by_objid -------------------------------------------------------------*/

IGRboolean VEsort_by_objid( sort_rec )

	struct VEsort_record *sort_rec;

/*
NAME
	VEsort_by_objid

DESCRIPTION
	This function takes a sort record and sorts it into an array of
	buckets.  The bit pattern of the bucket index is:

	      xxxxxxyyy

	where xxxxxx is the low order 6 bits of the element's attachment id
	and yyy is the lower order 3 bits of the element's object id.  The
	elements inside each bucket are sorted into a binary tree based on
	the object id.

	This function is used so we can throw out duplicate elements when 
	submitting a batch job.

PARAMETERS
	sort_rec (IN) - the sort record to add

GLOBALS USED
	VEbuckets

RETURN VALUES
	This function returns TRUE if the sort record was successfully added
	to the array of buckets.  Otherwise, FALSE is returned.

HISTORY
	05/02/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRint               which_bucket;
	struct VEsort_record *probe;

	sort_rec->left = sort_rec->right = NULL;

	which_bucket = (sort_rec->objid & 0x0007) |
                       ((sort_rec->env->attach_id & 0x003F) << 3);

	if ( VEbuckets[which_bucket] == NULL )
	   {
	   /* first element in bucket => insert it */
	   VEbuckets[which_bucket] = sort_rec;
	   return( TRUE );
	   }
	else
	   {
	   /* do binary tree sort */
	   probe = VEbuckets[which_bucket];
	   while ( probe )
 	      {
	      if ( (probe->objid == sort_rec->objid) &&
	           (probe->env->osnum == sort_rec->env->osnum) &&
	           (probe->env->attach_id == sort_rec->env->attach_id) )
	         {
	         /* duplicate entry => get rid of it */
	         free( (IGRchar *) sort_rec );
	         probe = NULL;

	         if ( ! dup_found )
	            {
	            ex$message( msgnumb       = VE_E_RepeatGeom,
	                        field         = ERROR_FIELD,
	                        justification = CENTER_JUS );
	            sleep( 3 );
	            dup_found = TRUE;
	            }
	               
	         return( FALSE );
	         }
	      else if ( probe->objid < sort_rec->objid )
	         {
	         /* look down the right side */
	         if ( probe->right == NULL )
	            {
	            /* add as the right child */
	            probe->right = sort_rec;
	            probe = NULL;
	            return( TRUE );
	            }
	         else
	            {
	            /* continue down the right side */
	            probe = probe->right;
	            }
	         }
	      else
	         {
	         /* look down the left side */
	         if ( probe->left == NULL )
	            {
	            /* add as the left child */
	            probe->left = sort_rec;
	            probe = NULL;
	            return( TRUE );
	            }   
	         else
	            {
	            /* continue down the left side */
	            probe = probe->left;
	            }
	         }
	      } /* end while ( probe ) */

	   }  /* end: binary tree sort */

	return( FALSE );
	} /* VEsort_by_objid */


/*---- VEinit_sort -------------------------------------------------------------*/

void VEinit_sort( IGRboolean batch_copy )

/*
NAME
	VEinit_sort

DESCRIPTION
	Initialize the variables needed to sort the located elements.

PARAMETERS
	batch_copy (IN) - TRUE, if a batch job submission is being done

GLOBALS USED
	VEwin_info

HISTORY
	05/02/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRint bucket;
	
	dup_found = FALSE;

	if ( ! batch_copy )
	   {
	   VEexec_status.VEtouched_center_line = FALSE;

	   /* calculate the number of units per bucket */
	   units_per_bucket = (NUM_SORTING_BUCKETS - 0.01) /
	                      (VEwin_info.clip_range[XMAX] - VEwin_info.clip_range[XMIN]);
	   }

	/* initialize the bucket sort structure */
	for ( bucket = 0; bucket < NUM_SORTING_BUCKETS; bucket++ )
	   VEbuckets[ bucket ] = NULL;

	}  /* VEinit_sort */
