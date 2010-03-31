
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

class implementation VEinstance;

#include <stdio.h>

#include "OMerrordef.h"

#include "msdef.h"
#include "dpdef.h"
#include "dp.h"

#include "vewinmacros.h"
                                                    
/* prototype files */
#include "VEpr_gragad.h"

method VEconstruct( IGRlong *msg )

/*
NAME
	VEgragad.VEconstruct

DESCRIPTION
	Construct method for Visible Edges Instance data objects
	This method loads default instance data.

PARAMETERS
	msg (OUT) - status return

GLOBALS USED
	none

HISTORY
	02/08/90    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong             which_error;
	IGRlong             ret_bytes;
	struct VEbatch_info batch_info;
	struct var_list     var_list[2];

	*msg = MSSUCC;

	var_list[0].var            = VE_BATCH_INFO;
	var_list[0].var_ptr        = (IGRchar *) &batch_info;
	var_list[0].num_bytes      = sizeof( struct VEbatch_info );
	var_list[0].bytes_returned = &ret_bytes;
	var_list[1].var            = END_PARAM;

	/* get default instance data and copy it into my instance data */
	VEget_default_instance( msg, &which_error, var_list );

	ve$set_window_instance_data( msg         = msg,
	                             win_id      = my_id,
	                             win_os      = OM_Gw_current_OS,
	                             which_error = &which_error,
	                             var_list    = var_list );

	return( OM_S_SUCCESS );

	}  /* VEconstruct */

end implementation VEinstance;
