
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

 
#define CHECK_RETURN_CODES 1

#define DEBUG_LOCATE 0

#include <stdio.h>
#include <stdlib.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"

#include "wl.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "dpstruct.h"

#include "gr.h"
#include "growner.h"

#include "bs.h"

#include "grgs.h"
#include "grgsmacros.h"

#include "msdef.h"

#include "hsurferrpriv.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "hstiler.h"
#include "HSfem_spt.h"

#include "HSpr_render.h"

/*--------------------------------
 *  for function
 *     HSget_z_span_of_range
 */
 
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*-------------------------------
 *  for function
 *     HSget_top_range
 */
 
#include "HSpr_driver.h"
   
/*------------------------------*/

/*---- HRcollect_elements -------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRcollect_elements( struct GRid *co_grid,
			     OM_S_CHANSELECT *gschansel,
			struct HRbucket_info *bucket_info,
				      IGRint *master_layers )
#else
	void HRcollect_elements( co_grid, gschansel, bucket_info, master_layers )

	struct GRid          *co_grid;
	OM_S_CHANSELECT      *gschansel;
	struct HRbucket_info *bucket_info;
	IGRint               *master_layers;
#endif

/*
DESCRIPTION
	Collect and sort all of the elements specified by the user.  The objects
	should be in a graphics set that is connected to a channel declared in a
	command object.  This is the channel that is passed in to this function.

HISTORY
	S.P. Rogers  07/07/89  Creation Date
*/

	{
	IGRlong          sts;
	IGRlong          msg;
	IGRint           num_ret;
	IGRint           i;
	IGRint           object_count;
	IGRdouble        fit_range[6], z_min, z_max;
	IGRboolean       near_z_clip_possible;
	struct GRobj_env obj_info;

	for ( i = 0; i < bucket_info->num_buckets; i++ )
	   bucket_info->buckets[i] = NULL;

	/* determine if any of the surfaces can possibly be near Z clipped by */
	/* comparing the fast fit range with the window's display depths      */
	HSget_top_range( fit_range );
	HSget_z_span_of_range( fit_range, &z_min, &z_max );
	near_z_clip_possible = (z_min < active_window->dit_clip_range[2]);
	
	/* find out how many objects were located */
	sts = gr$gsinqcount( msg          = &msg,
	                     count        = &object_count,
	                     senderid     = co_grid->objid,
	                     senderos     = co_grid->osnum,
	                     p_chanselect = gschansel );

            OM_ERRCHK( sts, "HRcollect_elements: gr$gsinqcount OM error" );
	    MSG_ERRCHK( msg, "HRcollect_elements: gr$gsinqcount failed" );

#if DEBUG_LOCATE
	fprintf( stderr, "Objects on channel:  %d\n\n", object_count );
	fprintf( stderr, "The located objects are:\n\n" );
#endif

	/* get each located object individually and classify it */
	for ( i = 0; i < object_count; i++ )
	   {
	   sts = gr$gsget_objects( msg          = &msg,
	                           array        = &obj_info,
	                           size         = sizeof( struct GRobj_env ),
	                           count        = &num_ret,
	                           from_obj     = i,
	                           to_obj       = i,
	                           senderid     = co_grid->objid,
	                           senderos     = co_grid->osnum,
	                           p_chanselect = gschansel );

              OM_ERRCHK( sts, "HRcollect_elements: gr$gsget_objects OM error" );
    	      MSG_ERRCHK( msg, "HRcollect_elements: gr$gsget_objects failed" );

	   if ( (1 & msg & sts) )
	      {
	      HRclassify_located_object( &obj_info.obj_id,
	                                 obj_info.mod_env.md_env.matrix,
	                                 obj_info.mod_env.md_env.matrix_type,
	                                 master_layers, near_z_clip_possible );
	      }

	   }  /* end: for */

	/* empty the located object channel */
	gr$gsempty( msg          = &msg,
	            senderid     = co_grid->objid,
	            senderos     = co_grid->osnum,
	            p_chanselect = gschansel );
	            
	   MSG_ERRCHK( msg, "HRcollect_elements: gr$gsempty failed" );

	}  /* HRcollect_elements */
