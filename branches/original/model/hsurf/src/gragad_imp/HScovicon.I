
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
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"

#include "hsmsg.h"

#include "igetypedef.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "exdef.h"
#include "exmacros.h"

#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"


/*----------------------------
 *  for functions
 *     HSactivate_window
 *     HSset_status
 */
 
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*-------------------------------
 *  for functions
 *     HSrepaint
 *     display_colortable
 */
 
#include "HSpr_display.h"

/*--------------------------------*/


/*--- covicon -------------------------------------------------------*/

method covicon(	IGRlong			*msg; 
		struct IGEdit_range	*range )

/*
NAME
	HSgragad.covicon

DESCRIPTION
	This method handles uncover events for a window

PARAMETERS
	msg (OUT) - return status
	range (IN) - the range, in dits, that was uncovered

GLOBALS USED
	active_window
	tiling_parms

RETURN VALUES
	OM_S_SUCCESS - if successful

HISTORY
	xx/xx/xx    Unknown Programmer
	   Creation Date
	02/24/92    S.P. Rogers
	   Added prologue comment and check of image_buffer_valid flag
*/

	{
	IGRlong		  		status = OM_S_SUCCESS;
	IGRboolean	 		flag = FALSE;
#ifdef X11
	IGRint				var_list[2];
	struct win_var_list		win_list[2];
	IGRlong				ret_msg, error_val, ret_bytes;
#endif

	*msg = MSSUCC;

	/* set tiler status to OK */
	HSset_status( HSSTAT_OK );

#ifdef X11
	/* kludge to set flag bit to active when uncollapsing windows on sun */
	ME.IGEgragad->gragad.flags |= IS_ACTIVE;

	/* set flags to reflect changed values :  0x00000010 = WIN_NOTMAPPED */
	var_list[0] = WIN_IS_ACTIVE | 0x00000010;
	var_list[1] = WIN_IS_ACTIVE | 0x00000010;

	/* set up the window prameters for changing flags */
	win_list[0].var = WINDOW_FLAGS;
	win_list[0].var_ptr = (char *)var_list;
	win_list[0].num_bytes = 2 * sizeof(int);
	win_list[0].bytes_returned = &ret_bytes;
	win_list[1].var = END_PARAM;

	ige$inq_set_window( msg = &ret_msg,
			    inq0_set1 = 1,
			    osnum = OM_Gw_current_OS,
			    window_objid = sender_id,
			    which_error = &error_val,
			    var_list = win_list);	
#endif

	/* make sure 'active_window' points to my information */
	HSactivate_window( me->gragad.gpipe_id );
	
	if (tiling_parms.status != HSSTAT_OK)
		{
		HScheck_status();
		goto wrapup;
		}

	if( (active_window->type & HShardware_ZB_MASK) ||
	    (ME.IGEgragad->gragad.flags & GRID_ON) ||
	    (!active_window->image_buffer_valid) )
		{
			
		/*
		 * Must re-tile when the grid is on because there may
		 * garbage in part or all of the image buffer (resulting
		 * from the screen-read when initializing the buffer).
		 */

		status = om$send(
				mode		= OM_e_wrt_object,
				msg		= message IGEgragad.DPupdate(msg,NULL,&flag),
				senderid	= my_id,
				targetid	= my_id);
				
		if( !(1 & status) )
			{
			printf( "HSgragad.covicon > error sending to IGEgragad update.\n" );
			om$report_error(sts = status );
			*msg = MSFAIL;
			}
		}
	else
		{
		enum GRdpmode	mode;
		
		ex$message(	msgnumb	= HS_I_DispInProg,
				field	= ERROR_FIELD );

		mode = GRbd;
		HSrepaint_shading_window( ME.IGEgragad->gragad.gpipe_id, range );
		HSredraw_coordinate_system( my_id, mode, NULL, NULL );

		status = OM_S_SUCCESS;

		ex$message(	msgnumb	= HS_I_DispComplete,
				field	= ERROR_FIELD );

		WLflush( ME.IGEgadget->win_no );
		}

wrapup:
	return( status );
	}

end implementation HSgragad;
