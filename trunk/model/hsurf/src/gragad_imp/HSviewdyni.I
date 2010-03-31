
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

/*		Apogee compliant		*/

class implementation HSviewdyn;

#include <stdlib.h>
#include <stdio.h>

#include "wl.h"

#include "igrtypedef.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "ex.h"
#include "lcdef.h"
#include "lc.h"
#include "msdef.h"
#include "msmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "grmessage.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "referr.h"
#include "OMindex.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "hsmsg.h"
#include "hsmacdef.h"
#include "HStl_window.h"

#include "hstiler.h"
#include "HSe2_mesher.h"
#include "HStl_element.h"
#include "HSpr_driver.h"

method GRviewdyn_set_up(IGRlong *msg; IGRdouble stroke_scale_factor)

{

   IGRint status = TRUE;
   WLuint16 lscreen_no;

   status = om$send( mode = OM_e_wrt_message,
		 msg=message GRviewdyn.GRviewdyn_set_up( msg, stroke_scale_factor ),
		 senderid = my_id, targetid = my_id );

	if (!(1 & status))
	{
		*msg = MSFAIL;
		goto wrapup;
	}

        WLget_window_screen( me->win_no, &lscreen_no );
	HSenable_feedback( lscreen_no, me->win_no, ME.IGEgragad->gragad.gpipe_id,
	                   ME.IGEgragad->gragad.vvol_viewport_scale, me->shading_style );
	
wrapup:
	if(!(*msg & 1))
	{
		status = FALSE;
	}

	return(status);
}

method GRviewdyn_reset(IGRlong *msg)

{
   IGRint	status = TRUE;
#if defined( ENV5 )
   IGRint GPIPE_id;
#endif

/* Delete fb gpipe */

	HSdisable_feedback();

#if defined( ENV5 )
        if ( HSusing_GPIPE( ME.IGEgragad->gragad.gpipe_id ) )
        {
           DLget_GPIPE_data( ME.IGEgragad->gragad.gpipe_id, &GPIPE_id );
           GPDelete( GPIPE_id );
        }
#endif

	return(status);
}

end implementation HSviewdyn;

