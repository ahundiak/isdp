
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation HSgragad;

/*#include "hsurf_import.h"*/
#include <stdlib.h>
#include "igrtypedef.h"

from IGEwinsup import pre_delete;

method delete( int flag )

	{ 
	IGRlong		status;
	IGRlong		msg;
	OMuint		count;
	OM_S_CHANSELECT	chandef;

	chandef.type = OM_e_name;
	chandef.u_sel.name = "IGEgragad.winsup";
	status = OM_S_SUCCESS;

	status = om$get_channel_count(
			objid = my_id, 
			p_chanselect = &chandef, 
			count = &count);

	if (!(status & 1))
		{
		om$report_error(sts = status);
		goto wrapup;
		}

	if (count) 
		{
		status = om$send(
				mode = OM_e_wrt_object, 
				msg = message IGEwinsup.pre_delete(&msg), 
				senderid = my_id, 
				p_chanselect = &chandef );

		/* protect against unknown objects */
		if (status == OM_E_NOSUCHCLASS ) status = OM_S_SUCCESS;

		if (!(status & 1))
			{
			om$report_error(sts = status);
			goto wrapup;
			}
		}

	/* delete window object */

	status = om$send(
			mode = OM_e_wrt_message, 
			msg = message Root.delete(1), 
			senderid = my_id, 
			targetid = my_id );

	if ( ! ( 1 & status ) )
		{
		om$report_error(sts = status );
		}

	HSdelete( ME.IGEgragad->gragad.gpipe_id );

wrapup:

	return ( status );
	}

end implementation HSgragad;
