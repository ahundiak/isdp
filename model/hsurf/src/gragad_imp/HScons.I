
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation HSinstance;

/*#include "hsurf_import.h"*/
#include "stdlib.h"
#include "igrtypedef.h"

#include "OMerrordef.h"

#include "msdef.h"
#include "hsdef.h"
#include "hsurf.h"

#include "dpdef.h"

method HSconstruct( IGRlong *msg )

/*
DESCRIPTION
	Construct method for Shading Instance data objects
	This method loads default instance data.

HISTORY
	S.P. Rogers  02/08/90 Creation Date
*/

	{
	IGRlong                        which_error;
	IGRlong                         ret_bytes;
	struct HStotal_window_instance total_instance;
	struct var_list                var_list[2];

	*msg = MSSUCC;

	/* get default instance data and copy into my instance data */
	var_list[0].var            = HS_TOTAL_INSTANCE;
	var_list[0].var_ptr        = (IGRchar *) &total_instance;
	var_list[0].num_bytes      = sizeof( struct HStotal_window_instance );
	var_list[0].bytes_returned = &ret_bytes;
	var_list[1].var            = END_PARAM;

	HSget_default_instance( msg, &which_error, var_list );

	me->disp_flags = total_instance.disp_flags;
	me->shading_style = total_instance.shading_style;

	return( OM_S_SUCCESS );

	}  /* HSconstruct */

end implementation HSinstance;
           
