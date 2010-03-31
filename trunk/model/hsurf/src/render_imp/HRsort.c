
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

/* HRsort.c */
static void HRbucket_sort __((
			  struct HRgeneric_sort_record *sort_rec, 
						IGRint key1, 
				  struct HRbucket_info *bucket_info));
				  


#if defined(__cplusplus)
}
#endif


#undef __




/*--- HRbucket_sort -------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HRbucket_sort( struct HRgeneric_sort_record *sort_rec,
							 IGRint key1,
					   struct HRbucket_info *bucket_info )
#else
	static void HRbucket_sort( sort_rec, key1, bucket_info )

	struct HRgeneric_sort_record *sort_rec;
	IGRint                       key1;
	struct HRbucket_info         *bucket_info;
#endif

/*
DESCRIPTION

HISTORY
	S.P. Rogers 07/09/89  Creation Date
*/

	{
	IGRint                       which_bucket;
	struct HRgeneric_sort_record *probe;
	struct HRgeneric_sort_record **buckets;

	buckets = bucket_info->buckets;
	
	sort_rec->left = NULL;
	if (bucket_info->double_sort)
	   sort_rec->right = NULL;

	which_bucket = (key1 - bucket_info->min_key1) * bucket_info->units_per_bucket;
	if ( which_bucket < 0 )
	    which_bucket = 0;
	else if ( which_bucket > bucket_info->num_buckets )
	   which_bucket = bucket_info->num_buckets - 1;
	   
	if ( (buckets[which_bucket] == NULL) || (! bucket_info->double_sort) )
	   {
	   /* first element in bucket or a single sort => insert first in bucket */
	   sort_rec->left = buckets[which_bucket];
	   buckets[which_bucket] = sort_rec;
	   }
	else
	   {
	   /* do binary tree sort */
	   probe = buckets[which_bucket];
	   while ( probe )
	      {
	      if ( probe->key2 < sort_rec->key2 )
	         {
	         /* look down the right side */
	         if ( probe->right == NULL )
	            {
	            /* add as the right child */
	            probe->right = sort_rec;
	            probe = NULL;
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
	            }   
	         else
	            {
	            /* continue down the left side */
	            probe = probe->left;
	            }
	         }

	      } /* end while ( probe ) */

	   }  /* end: binary tree sort */

	} /* HRbucket_sort */


/*--- HRbucket_sort_surface ------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRbucket_sort_surface( struct HRsurface_record *surf_rec,
						     IGRint key1 )
#else
	void HRbucket_sort_surface( surf_rec, key1 )

	struct HRsurface_record *surf_rec;
	IGRint                  key1;
#endif

	{
	HRbucket_sort( (struct HRgeneric_sort_record *)surf_rec,
                                   key1, &rendering_globals.surface_buckets );
	}  /* HRbucket_sort_surface */


/*--- HRbucket_sort_trapezoid ------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRbucket_sort_trapezoid( struct HRspan_trapezoid *trap,
						       IGRint key1 )
#else
	void HRbucket_sort_trapezoid( trap, key1 )

	struct HRspan_trapezoid	*trap;
	IGRint              key1;
#endif
	
	{
	HRbucket_sort( (struct HRgeneric_sort_record *)trap, 
				key1, &rendering_globals.trap_buckets );
	}  /* HRbucket_sort_trapezoid */

