
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

/*		Apogee compliant		*/

class implementation HSgragad;

/*#include "hsurf_import.h"*/
#include <stdlib.h>
#include "igrtypedef.h"

method clear( IGRlong *msg)

	{	
	IGRlong status;

	status = OM_S_SUCCESS;

	/* should send message to GRwscvth2s method to convert */
	/* soft_win_no to hard ware window number  */ 

	ME.IGEgragad->gragad.flags &= ~IS_ACTIVE;

	*msg = MSSUCC;

	HSdelete( ME.IGEgragad->gragad.gpipe_id );

	return ( status );
	}

end implementation HSgragad;
