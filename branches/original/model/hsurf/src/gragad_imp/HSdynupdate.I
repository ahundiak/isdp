
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $


HISTORY

        Sudha   07/27/93        Modified for BSprototypes ansification


*/

class implementation HSviewdyn;

#include <stdio.h>

#include "wl.h"

#include "igrtypedef.h"
#include "exmacros.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "msdef.h"
#include "msmacros.h"
#include "hsmsg.h"
#include "hsmacros.h"

#include "bserr.h"
#include "bsparameters.h"
#include "bsxtractpar.h"
#include "bschangepar.h"

#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "ex.h"

#include "HStl_global.h"
#include "OMminimum.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_window.h"
#include "HStl_element.h"

/*--------------------------------
 *  for functions
 *     HSset_processing_mode
 */
 
#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

/*--------------------------------*/

/*---DPgen_update------------------------------------------------------------------*/

method DPgen_update(	IGRlong			*msg; 
			struct DPdit_range	*range; 
			IGRboolean		*update_all; 
			enum GRdpmode		mode; 
			IGRboolean		erase)

	{
	IGRint			sts;
	IGRlong			rc;
	IGRdouble		cht, shd_tol, win_cht;


	/*
	 *  Initialize a few things
	 */

	sts = OM_S_SUCCESS; 


	/*
	 * If possible, increase the cht to a window-based value.
	 */

	BSxtractpar (&rc, BSTOLCHRDHT, &cht);
	hs$get_shading_tolerance( tolerance = &shd_tol );
	HSget_window_based_cht(	&win_cht,
				ME.IGEgragad->gragad.gpipe_id,
				shd_tol * 1.2,
				ME.IGEgragad->gragad.dit_clip_range );
					
	if (win_cht > cht) BSchangepar (&rc, BSTOLCHRDHT, win_cht);


	/* view dynamics only does smooth or constant shading */
	HSset_processing_mode( HS_PMODE_SHADING );

	/*
	 *  Send a message to GRviewdyn to update the window.  HS has
	 *  overriden the message DPupd_app_init.  This will set the
	 *  dp_info for shading and initialize the window.
	 */
		 
	sts = om$send(	mode     = OM_e_wrt_message,
			msg      = message GRviewdyn.DPgen_update(
					msg,
					range,
					update_all,
					mode,
					erase ),
			targetid = my_id );
	

	/* If necessary, reset the cht. */
	if (win_cht > cht) BSchangepar (&rc, BSTOLCHRDHT, cht);

	return(sts);
	}

/*---DPupd_app_init------------------------------------------------------------------*/

method DPupd_app_init(	IGRlong			*msg; 
			struct DP_information	*dp_info )

	{
	IGRint			sts, status;
	void			HStile_object();
	IGRdouble		post_rotation[4][4];
	struct var_list		var_list[2];
	IGRlong			msg1, error;
	IGRlong			bytes_returned;
        IGRshort		prev_state;
	IGRuchar		far_depth_cue;

	sts = OM_S_SUCCESS; 

	/*
	 *  Set the dp_info structure for hsurf shading
	 */
	 
	dp_info->gragad = &ME.IGEgragad->gragad;
	dp_info->win_no = ME.IGEgadget->win_no;
	dp_info->is_update = TRUE;
	dp_info->is_fit = FALSE;
	dp_info->is_hidden_line = TRUE;
	dp_info->hline_info = NULL;
	dp_info->hl_tiler = HStile_object;


	if ( ME.IGEgragad->gragad.flags & IS_PERSP )
		{
		/* can only get post rotation matrix from perspective views */
		var_list[0].var		   = POST_ROTATION;
		var_list[0].var_ptr	   = (IGRchar *) post_rotation;
		var_list[0].num_bytes	   = sizeof(IGRdouble)*16;
		var_list[0].bytes_returned = &bytes_returned;
		var_list[1].var		   = END_PARAM;

		dp$inq_set_gragad(
			msg		= &msg1, 
			which_error	= &error,
			var_list	= var_list,
			gragad_objid	= my_id,
			osnum		= OM_Gw_current_OS );
		}

	hs$get_depth_cues( far_depth_cue = &far_depth_cue );

	status = HSinit_display( 0,
			 ME.IGEgadget->min_x_dep ,
			 ME.IGEgadget->min_y_dep ,
			 (ME.IGEgadget->max_x_dep - ME.IGEgadget->min_x_dep) + 1,
			 (ME.IGEgadget->max_y_dep - ME.IGEgadget->min_y_dep) + 1,
			 &ME.IGEgragad->gragad, 
			 255, far_depth_cue,
			 post_rotation );

	/*
	 *  Turn messages back on so any message from the tiler will be
	 *  displayed.
	 */
	 
	ms$onoff( msg       = msg, 
                  prevstate = &prev_state,
		  type      = MS_ON );

	return(sts);

	}

end implementation HSviewdyn;
