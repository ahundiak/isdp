
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $
*/


/*
	This file defines and implements the following commands:

	   Toggle Shading Cull Mode

		   "Toggle Shading Cull Mode", HSTgShClMd, HStoggle, 7

*/

class              HStoggle
super_class        CEO
command_string     HSM_M_TogCullMode,7,HSTgShClMd
product_name       "$MODEL"
start_state        start

state_table

#define CULL_MODE    7

#include "hsmsg.h"

implementation

#define CULL_MODE    7

#define CHECK_RETURN_CODES 0

#include "DIdef.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "igrtypedef.h"

#include "OMerrordef.h"

#include "msdef.h"
#include "msmacros.h"

#include "igecolmacros.h"

#include "hsdef.h"
#include "hsurferrpriv.h"
#include "hsmsg.h"

#include "hsmacdef.h"
#include "hsmacros.h"
#include "hswinmacros.h"

extern OMuword OPP_HSgragad_class_id;


state start
   on CMD_TYPE = CULL_MODE
      do message_key HSM_M_TogCullMode
      do toggle_cull_mode
      state terminate

/*--- toggle_cull_mode -------------------------------------------------*/

action toggle_cull_mode

/*
DESCRIPTION
	This action toggles the culling mode between CULL and DONT CULL.
*/

	{
	IGRint cull_mode;

	hs$get_cull_mode( cull_mode = &cull_mode );

	if ( cull_mode == HS_CULL_YES )
	   {
	   cull_mode = HS_CULL_NO;
	   ex$message( msgnumb = HS_I_CullingDisabled );
	   }
	else
	   {
	   cull_mode = HS_CULL_YES;
	   ex$message( msgnumb = HS_I_CullingEnabled );
	   }

	hs$set_cull_mode( cull_mode = cull_mode );
	}  /* toggle_cull_mode */
