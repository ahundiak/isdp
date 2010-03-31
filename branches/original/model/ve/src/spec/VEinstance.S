
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/

class specification VEinstance (2:0) of Root;

/*
DESCRIPTION
	Class that contains the window specific data for Visible Edges

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

#include "vedef.h"
#include "ve.h"
#include "ve_inst.h"

instance VEinstance
	{
        IGRint            num_batch_jobs;                   /* number of outstanding batch jobs      */
        variable struct VEjob_info job_info[0];             /* information on outstanding batch jobs */

	channel { (many_to_many, initial=1) } to_gragad;
	};


override debug;

message VEconstruct( IGRlong *msg );

/*
DESCRIPTION
	Construct method for VEinstance objects.  This method
	loads default instance data into the object.
*/

message	VEinquire( IGRlong         *msg;
	           IGRlong         *which_error;
	           struct var_list *var_list );

/*
DESCRIPTION
	Provides the ability to inquire the instance data.
	See documentation on the ve$get_window_instance_data() macro
	in vewinmacros.h.
*/

message	VEset( IGRlong         *msg;
	       IGRlong         *which_error;
	       struct var_list *var_list );

/*
DESCRIPTION
	Provides the ability to set the instance data.
	See documentation on the ve$set_window_instance_data() macro
	in vewinmacros.h.
*/


end specification VEinstance;
