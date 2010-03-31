
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation HSgragad;

/*#include "hsurf_import.h"*/
#include "igrtypedef.h"
#include "stdlib.h"

#include "stdio.h"
#include "dpgraphics.h"
#include "wl.h"

method DPgriddraw( IGRlong *msg; struct DPdit_range *range )

/*
DESCRIPTION
	This method is overridden to make sure the grids are drawn
	with an INDEXED VLT on an EDGE II.

HISTORY
	S.P. Rogers  Creation Date  10/17/90
*/

	{

	om$send( mode = OM_e_wrt_message,
	         msg  = message IGEgragad.DPgriddraw( msg, range ),
	         targetid = my_id );

	return( OM_S_SUCCESS );

	}  /* DPgriddraw */

end implementation HSgragad;
