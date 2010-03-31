
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation HSgragad;

#include <stdio.h>

#include "wl.h"

#include "OMminimum.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "igrdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "hsmsg.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "exdef.h"
#include "exmacros.h"

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"

#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"

/*--------------------------
 *  for functions
 *     HSactivate_window
 *     HSset_status
 */
 
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*---------------------------
 *  for functions
 *     HSrepaint
 *     display_colortable
 */
 
#include "HSpr_display.h"

/*---------------------------*/


/*---clipicon---------------------------------------------------------------*/

method clpicon(	IGRlong *msg; 
		IGRint *flag )

/*
NAME
	HSgragad.clpicon

DESCRIPTION
	This method handles the collapse/uncollapse events of a 
	window.

PARAMETERS
	msg (OUT) - return status
	flag (IN) - 0 => uncollapse, 1 => collapse

GLOBALS USED
	active_window
	tiling_parms

RETURN VALUES
	OM_S_SUCCESS - on success

HISTORY
	xx/xx/xx    Unknown Programmer
	02/24/92    S.P. Rogers
	   Added prologue comment and check of image_buffer_valid
	   flag
*/

	{
	IGRlong 			status;
	IGRboolean			upd_flag = FALSE;
	

	status = OM_S_SUCCESS;
	*msg = MSSUCC;

	/* set tiler status to OK */
	HSset_status( HSSTAT_OK );

	if( *flag == 0 )	/* UNCOLLAPSE */
		{
		me->gragad.flags |= IS_ACTIVE;

		HSactivate_window( me->gragad.gpipe_id );
		if (tiling_parms.status != HSSTAT_OK)
			{
			HScheck_status();
			goto wrapup;
			}

		if( (active_window->type & HShardware_ZB_MASK) || 
	            (me->gragad.flags & GRID_ON) || 
		    (active_window->zbuf == NULL) ||
		    (!active_window->image_buffer_valid) )
			{
				
			/*
			 * Must re-tile when the grid is on because there may
			 * garbage in part or all of the image buffer (resulting
			 * from the screen-read when initializing the buffer).
			 */

			status = om$send( mode     = OM_e_wrt_object,
					  msg      = message IGEgragad.DPupdate( msg, NULL, &upd_flag ),
					  senderid = my_id,
					  targetid = my_id);

			if( !(1 & status) )
				{
				om$report_error( sts = status );
				printf( "Error: collapse icon send to HSwn update\n" );
				}
			}
		else
			{
			enum GRdpmode	mode;

			ex$message( msgnumb = HS_I_DispInProg );

			mode = GRbd;
			HSrepaint_shading_window( me->gragad.gpipe_id, NULL );
			HSredraw_coordinate_system( my_id, mode, NULL, NULL );
			
			WLflush( me->win_no );

			ex$message( msgnumb = HS_I_DispComplete );
			}
		}
	else
		{
		/* COLLAPSE */
		
		me->gragad.flags &= ~IS_ACTIVE;
		}

wrapup:
	return (status);
	}
	
end implementation HSgragad;
