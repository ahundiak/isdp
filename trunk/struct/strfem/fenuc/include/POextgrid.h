#ifndef PO_extgrid
#define PO_extgrid

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

/*****************************************************************************

   Doc: POextgrid.h

   Abstract: This file contains the commonly used POST externed grids.

   History:

	Date		Who		Why
	---------------------------------------------------------------------
	26 Dec 91	qxn		Born after Christmas
	21 Oct 93	qxn		added POthermal_grid for thermal
					results set
	
 ****************************************************************************/

extern struct GRid	POsman_grid, POman_grid, POdpb_grid, POthermal_grid;

#endif
