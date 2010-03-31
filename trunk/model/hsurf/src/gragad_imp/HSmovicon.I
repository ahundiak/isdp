
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

/*		Apogee compliant		*/

class implementation HSgragad;


#include <stdio.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

#include "HStl_window.h"

#include "igewindef.h"
#include "igewinmacros.h"

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"

#include "msdef.h"
#include "msmacros.h"

#include "hsmessage.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_global.h"
#include "HStl_element.h"

/*-----------------------------------
 *  for function
 *     HSinit_shading_window
 */
 
#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

/*----------------------------------
 *  for functions
 *     HSpix_count
 */
 
%safe
#include "HSpr_co_func.h"
%endsafe

/*----------------------------------*/

#define		MOVE_ONLY		0
#define		STRETCH_ONLY		1
#define		MOVE_AND_STRETCH	2
#define		COVER_UNCOVER		3


/*---HSput_it_back------------------------------------------------------------------*/

static	HSput_it_back(
   IGRint *my_id,
   IGRint xlo,
   IGRint ylo,
   IGRint xhi,
   IGRint yhi )


/*
NAME
	HSput_it_back (static)

DESCRIPTION
	This function restores a window to its original size if it cannot
	be stretched because memory for the Z and image buffers cannot
	be allocated.

PARAMETERS
	my_id (IN) - object id of window
	xlo (IN) - old xmin of window
	ylo (IN) - old ymin of window
	xhi (IN) - old xmax of window
	yhi (IN) - old ymax of window

GLOBALS USED
	none

HISTORY
	xx/xx/xx    Unknown Programmer
	   Creation Date
	02/24/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRlong		msg;
	IGRint		status;
	OM_S_CHANSELECT	chandef;
	IGRdouble	xmin, xmax, ymin, ymax;
	
	xmin = (IGRdouble)xlo;
	xmax = (IGRdouble)xhi;
	ymin = (IGRdouble)ylo;
	ymax = (IGRdouble)yhi;

	chandef.type = OM_e_name;
	chandef.u_sel.name = "to_parent";

	status = om$send(
			msg		= message IGEgadget.change_gadget_size(
						&msg,
						IGE_DEPENDENT,
						xmin, ymin,
						xmax, ymax ),
			senderid	= *my_id, 
			p_chanselect	= &chandef );

	return( status );

	}  /* HSput_it_back */

/*---HScan_we_resize--------------------------------------------------------------*/

static	IGRint	HScan_we_resize(
   IGRint new_xlo,
   IGRint new_ylo,
   IGRint new_xhi,
   IGRint new_yhi,
   IGRint *my_id,
   WLuint16 lscreen_no,
   IGRint win_no,
   IGRint gpipe_no,
   IGRint  shading_style )

/*
NAME
	HScan_we_resize (static)

DESCRIPTION
	This function tries to allocate the Z and image buffers necessary
	to stretch a shading window

PARAMETERS
	new_xlo (IN) - new minx of window
	new_ylo (IN) - new miny of window
	new_xhi (IN) - new maxx of window
	new_yhi (IN) - new maxy of window
	my_id (IN) - object id of the window
	lscreen_no (IN) - logical screen number of the window
	win_no (IN) - window number of the window
	gpipe_no (IN) - gpipe number of the window
	shading_style (IN) - shading style of the window

GLOBALS USED
	none

RETURN VALUES
	TRUE - if re-size succeeded
	FALSE - if re-size failed

HISTORY
	xx/xx/xx    Unknown Programmer
	   Creation Date
	02/24/92    S.P. Rogers
	   Added prologue comment
	04/13/92    S.P. Rogers
	   Removed call to HSpix_count() that put up an error box when too much
	   memory was requested and put a call to ex$message() instead.  The
	   Save/Restore processing involved with the error box in HSpix_count()
	   caused major problems (i.e., it consumed needed events from the
	   input queue) when cascading shading windows on the Sun.
*/


	{
	IGRlong		msg;
	IGRint		status;
	OM_S_CHANSELECT	chandef;
	IGRint		old_xlo, old_ylo;
	IGRint		old_xhi, old_yhi;
	IGRint		old_xdits, old_ydits;
	IGRint		new_xdits, new_ydits;
	IGRint		old_num_pixels;
	IGRint		new_num_pixels;
	
	status = TRUE;

	/*
	 *  Get the old and new extents of the window
	 */
	 
	chandef.type = OM_e_name;
	chandef.u_sel.name = "to_parent";

	status = om$send(
			msg		= message IGEgadget.dep_extents(
						&msg,
						&old_xlo, &old_ylo,
						&old_xhi, &old_yhi ),
			senderid	= *my_id, 
			p_chanselect	= &chandef );

	old_xdits = (old_xhi - old_xlo) + 1;
	old_ydits = (old_yhi - old_ylo) + 1;
				
	new_xdits = (new_xhi - new_xlo) + 1;
	new_ydits = (new_yhi - new_ylo) + 1;
	
	old_num_pixels = old_xdits * old_ydits;
	new_num_pixels = new_xdits * new_ydits;

	/*
	 *  If the resized window has a smaller or equal area than the old
	 *  the we know that we can do it because there is enough buffer already
	 *  to handle the job
	 */
	 
	if( old_num_pixels < new_num_pixels )
		{
		status = HSinit_shading_window( lscreen_no,
						win_no,
						gpipe_no,
						new_xdits,
						new_ydits,
						shading_style,
                                		*my_id,
						OM_Gw_current_OS );
				
		if( !status )
			{
			/* don't put up an error box here because it totally screws */
			/* up cascade if shading windows are involved               */
			ex$message( msgnumb = HS_E_TooMuchMem0,
				    field = ERROR_FIELD );
			sleep( 2 );

			HSput_it_back( my_id, old_xlo, old_ylo, old_xhi, old_yhi );
			}

		}

	/* want to do a gen_update if resizing window */
        if (status)
	{
		HSactivate_window( gpipe_no );
		active_window->image_buffer_valid = FALSE;		
	}

	return( status );

	}  /* HScan_we_resize */

/*---movicon-------------------------------------------------------------------*/

method movicon(	IGRlong		*msg;
		IGRint		*win_no;
		IGRint		*flag;
		IGRint		*minx;
		IGRint		*miny;
		IGRint		*maxx;
		IGRint		*maxy )
		
/*
NAME
	HSgragad.movicon

DESCRIPTION
	This method handles the move and/or streching of a shading
	window.

PARAMETERS
	msg (OUT) - return status
	win_no (IN) - the window number of the window
	flag (IN) - flag indicating, move, stretch or move and stretch
	minx (IN) - new minx of window
	miny (IN) - new miny of window
	maxx (IN) - new maxx of window
	maxy (IN) - new maxy of window

GLOBALS USED
	active_window
	tiling_parms

RETURN VALUES
	OM_S_SUCCESS - if successful

HISTORY
	xx/xx/xx    Unknown Programmer
	   Creation Date
	02/24/92    S.P. Rogers
	   Added prologue comment and changed to use window number from
	   instance data instead of one passed in as temporary fix for
	   X problem on the Sun
*/

	{
	IGRlong status;
        WLuint16 lscreen_no;

	status = OM_S_SUCCESS;

        WLget_window_screen( ME.IGEgadget->win_no, &lscreen_no );
		 
	switch( *flag )
		{
		case MOVE_ONLY:
		case COVER_UNCOVER:
			status = TRUE;
			break;
				
		case STRETCH_ONLY:
		case MOVE_AND_STRETCH:
			status = HScan_we_resize
					(
					*minx, *miny, *maxx, *maxy,
					(IGRint *)&my_id, 
					lscreen_no, ME.IGEgadget->win_no, 
					ME.IGEgragad->gragad.gpipe_id,
					ME.HSinstance->shading_style
					);
			break;
		};

	/*
	 *  If the operation is ok by hsurf, then complete
	 */

	if( status )
		{
		status = om$send(
			mode     = OM_e_wrt_message,
			msg      = message IGEgragad.movicon(
					msg,  win_no,  flag,
					minx, miny,
					maxx, maxy ),
			targetid = my_id );
		}

	status = OM_S_SUCCESS;

	return( status );
	}
	
end implementation HSgragad;
