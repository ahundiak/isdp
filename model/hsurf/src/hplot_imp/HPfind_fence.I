 
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation Root;
 
#include <stdio.h>
#include <FI.h>
#include "DIdef.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"

#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "msdef.h"
#include "pidef.h"
#include "plotmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "hsdef.h"
#include "HSplot_label.h"
#include "hsmsg.h"
#include "HSplot.h"
#include "HSplot_def.h"

#include "wl.h"
#include "HSpr_hplot.h"


/*---HPfind_fence-----------------------------------------------------------------*/

/*
NAME
	HPfind_fence
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	Look for a fence, and if it exist, verify that it is
	in a shading window
	
PARAMETERS
	info	:(IN) : shaded plotting global information
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HPfind_fence( struct HSplot_info *info )
#else
	void	HPfind_fence( info )

	struct HSplot_info	*info;
#endif

	{
	struct var_list		var_list[2];
	IGRlong			bytes_returned;
	IGRlong			which_error;
	IGRlong			msg, status;
	IGRchar			classname[OM_K_MAXCLASS_LEN];
	IGRint			flags;
	
	/*
	 *  Get fence and info about the fence
	 */
	 
	plot$get_fence_range( msg = &msg,
			   module = &info->module,
			    fence = &info->fence,
			   window = &info->fence_window,
			    world = &info->fence_range[0],
			     view = &info->fence_range[6],
			  cvprism = &info->prism );

	info->con_flags &= ~(HP_CONTROL_FENCE_DEFINED | 
			     HP_CONTROL_FENCE_IN_SHADING_WINDOW |
			     HP_CONTROL_FENCE_IN_PARALLEL_WINDOW);
	
	if( msg == MSSUCC )
		{
		info->con_flags |= HP_CONTROL_FENCE_DEFINED;

		om$get_classname( classname = classname,
				      objid = info->fence_window.objid,
				      osnum = info->fence_window.osnum );

		if( strcmp( classname, "HSgragad" ) == 0 )
			{
			info->con_flags |= HP_CONTROL_FENCE_IN_SHADING_WINDOW;
			
			var_list[0].var			= GRAGAD_FLAGS;
			var_list[0].var_ptr		= (char *)&flags;
			var_list[0].num_bytes		= sizeof( flags );
			var_list[0].bytes_returned	= &bytes_returned;

			var_list[1].var			= END_PARAM;
			var_list[1].var_ptr		= NULL;
			var_list[1].num_bytes		= 0;
			var_list[1].bytes_returned	= NULL;

			status = dp$inq_set_gragad( msg	= &msg,
					      inq0_set1 = 0,
						  osnum = info->fence_window.osnum,
					   gragad_objid = info->fence_window.objid,
					    which_error = &which_error,
					       var_list = var_list );
					       
			if( !(flags & IS_PERSP) )
				info->con_flags |= HP_CONTROL_FENCE_IN_PARALLEL_WINDOW;				
			}
		}
	}
			
end implementation Root;

