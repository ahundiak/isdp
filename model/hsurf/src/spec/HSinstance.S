
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

class specification HSinstance (2:0) of Root;

/*
DESCRIPTION
	Class that contains the window specific data for Shading

HISTORY
	S.P. Rogers  02/10/90  Creation Date
*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "dp.h"

instance HSinstance
	{
	variable IGRint                       expansion[0];
	IGRuint                               disp_flags;
	IGRuchar                              shading_style;
	channel { (many_to_many, initial=1) } to_gragad;
	};


override debug;

message HSconstruct( IGRlong *msg );

/*
DESCRIPTION
	Construct method for HSinstance objects.  This method
	loads default instance data into the object.
*/

message	HSinquire( IGRlong         *msg;
	           IGRlong         *which_error;
	           struct var_list *var_list );

/*
DESCRIPTION
	Provides the ability to inquire the instance data.
	See documentation on the hs$get_window_instance_data() macro
	in hswinmacros.h.
*/

message	HSset( IGRlong         *msg;
	       IGRlong         *which_error;
	       struct var_list *var_list );

/*
DESCRIPTION
	Provides the ability to set the instance data.
	See documentation on the hs$set_window_instance_data() macro
	in hswinmacros.h.
*/


end specification HSinstance;
