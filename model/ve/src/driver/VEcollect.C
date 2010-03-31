
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

#define CHECK_RETURN_CODES 1

#define DEBUG_SORT         0

#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"

#include "msdef.h"
#include "msmacros.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "bs.h"

#include "gr.h"
#include "growner.h"

#include "grgs.h"
#include "grgsmacros.h"

#include "go.h"
#include "dpstruct.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"
#include "vemsg.h"

/* prototype files */
#include "VEpr_driver.h"
#include "VEpr_utilimp.h"
#include "VEpr_utilfnc.h"


/* External - global variables */
extern struct VEexecution_parms  VEexec_parms;
extern struct VEexecution_status VEexec_status;
extern struct VEsort_record      **VEbuckets;

/* static prototypes */

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static IGRint VEcount_bucket_entries __(( struct VEsort_record *bucket ));

#if defined(__cplusplus)
}
#endif

#undef __

#if DEBUG_SORT

/*--- VEcount_bucket_entries -----------------------------------------------------------*/

static IGRint VEcount_bucket_entries( bucket )

	struct VEsort_record *bucket;

/*
NAME
	VEcount_bucket_entries

KEYWORD
	debug

DESCRIPTION
	This function counts the number of sort records in a bucket
	if sort records (i.e, a binary tree).

PARAMETERS
	bucket (IN) - the bucket whose entries are to be counted

RETURN VALUES
	It returns the number of sort records in a bucket

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
	02/12/92    S.P. Rogers
	   Added prologue comment
*/

	{
	if ( bucket )
	   return( 1 + 
	           VEcount_bucket_entries( bucket->left ) +
	           VEcount_bucket_entries( bucket->right ) );
	else
	   return( 0 );
	
	}  /* VEcount_bucket_entries */
#endif


/*---- VEcollect_elements -------------------------------------------*/

void VEcollect_elements( struct GRid      *co_grid,
			 OM_S_CHANSELECT  *gschansel,
			 struct GRmd_env  *batch_env,
			 IGRboolean       batch_copy )

/*
NAME
	VEcollect_elements

DESCRIPTION
	Collect and sort all of the elements specified by the user.  The objects
	should be in a graphics set that is connected to a channel declared in a
	command object.  This is the channel that is passed in to this function.

PARAMETERS
	co_grid (IN) - the command object who has the graphics set channel
	gschansel (IN) - channel selector for graphics set channel
	batch_env (IN) - module environment of invisible os for batch submission
	batch_copy (IN) - if TRUE, we are collecting for a batch job submission

GLOBALS USED
	VEexec_parms
	VEbuckets
	
HISTORY
	S.P. Rogers  05/15/87  Creation Date
*/

	{
	IGRlong          sts;
	IGRlong          msg;
	IGRint           num_ret;
	IGRint           i;
	IGRint           object_count;
	struct GRid      fence_grid;
	struct GRobj_env obj_info;
	IGRchar          temp_string[60];

	ex$message( msgnumb = ((batch_copy) ? VE_I_CopyToBgFile : VE_I_ClassAndSort),
                    buff = temp_string );
	VEinit_heartbeat( temp_string );

	VEinit_sort( batch_copy );

	/* get the fence object's id */
	fence_grid.objid = NULL_OBJID;
	fence_grid.osnum = 0;
	gr$gsget_fence( msg = &msg, fence_id = &fence_grid );

	if ( VEexec_parms.VEbatch )
	   {
	   /* we are in batch mode => collect elements from directory structure */
	   VEcollect_elements_in_batch( &fence_grid );
	   }
	else
	   {
	   /* find out how many objects were located */
	   sts = gr$gsinqcount( msg          = &msg,
	                        count        = &object_count,
	                        senderid     = co_grid->objid,
	                        senderos     = co_grid->osnum,
	                        p_chanselect = gschansel );

               OM_ERRCHK( sts, "VEcollect_elements: gr$gsinqcount OM error" );
	       MSG_ERRCHK( msg, "VEcollect_elements: gr$gsinqcount failed" );

#if DEBUG_LOCATE
	   fprintf( stderr, "Objects on channel:  %d\n\n", object_count );
	   fprintf( stderr, "The located objects are:\n\n" );
#endif

	   /* get each located object individually and classify it */
	   for ( i = 0; i < object_count; i++ )
	      {
	      VEupdate_heartbeat();
	      sts = gr$gsget_objects( msg          = &msg,
	                              array        = &obj_info,
	                              size         = sizeof( struct GRobj_env ),
	                              count        = &num_ret,
	                              from_obj     = i,
	                              to_obj       = i,
	                              senderid     = co_grid->objid,
	                              senderos     = co_grid->osnum,
	                              p_chanselect = gschansel );

                 OM_ERRCHK( sts, "VEcollect_elements: gr$gsget_objects OM error" );
   	         MSG_ERRCHK( msg, "VEcollect_elements: gr$gsget_objects failed" );

	      if ( (1 & msg & sts) )
 	         {
	         VEclassify_located_object( &obj_info.obj_id, NULL,
	                                    obj_info.mod_env.md_env.matrix,
	                                    obj_info.mod_env.md_env.matrix_type,
	                                    &obj_info.mod_env,
	                                    batch_env, batch_copy, &fence_grid, -1 );
	         }

	      }  /* end: for */

	   /* empty the located object channel */
	   gr$gsempty( msg          = &msg,
	               senderid     = co_grid->objid,
	               senderos     = co_grid->osnum,
	               p_chanselect = gschansel );
	            
	      MSG_ERRCHK( msg, "VEcollect_elements: gr$gsempty failed" );

	   }  /* end: else */

#if DEBUG_SORT
	{
	IGRint count;

	fprintf( stderr, "Bucket Sort Stats\n\n" );
	for ( i = 0; i < NUM_SORTING_BUCKETS; i++ )
	   {
	   count = VEcount_bucket_entries( VEbuckets[i] );
	   if ( count != 0 )
	      fprintf( stderr, "Bucket: %d Elements: %d\n", i , count );
	   }

	fprintf( stderr, "\nTOUCHED CENTER LINE:  " );
	if ( VEexec_status.VEtouched_center_line )
	   fprintf( stderr, "TRUE\n" );
	else
	   fprintf( stderr, "FALSE\n" );

	fprintf( stderr, "\nTOTAL PROCESSABLE ELEMENTS: %d\n", VEexec_status.VEtotal_elems );
	}
#endif

	if ( batch_copy )
	   {
	   /* free the sort records in the bucket sort structure */
	   /* because they are not needed any more               */
	   for ( i = 0; i < NUM_SORTING_BUCKETS; i++ )
	      if ( VEbuckets[i] )
	         VEfree_sort_record_tree( &VEbuckets[i] );
	   }

	}  /* VEcollect_elements */
