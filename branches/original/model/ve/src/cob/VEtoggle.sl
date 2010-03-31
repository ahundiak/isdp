
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:41:59 $
$Locker:  $
*/

class              VEtoggle
super_class        CEO
command_string     VEM_M_TogHidLinEleRed,0,VETgHdLnRd
product_name       "$MODEL"
start_state        start

state_table

#include "vecmd.h"

implementation

#define CHECK_RETURN_CODES 0

#include <stdio.h>

#include "OMerrordef.h"

#include "msdef.h"
#include "msmacros.h"

#include "vedef.h"
#include "vedpbmacros.h"
#include "vemessage.h"

/* prototype files */
#include "VEpr_dpb.h"

state start
      message_key VEM_M_TogHidLinEleRed
         on ELSE
            do toggle_reduction_mode
            state terminate

/*--- toggle_reduction_mode -------------------------------------------------*/

action toggle_reduction_mode

/*
NAME
	VEtoggle.toggle_reduction_mode

DESCRIPTION
	This action toggles the reduction mode stored in
	the VEdpb.

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	12/06/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRuint ve_vhl_flags;

	ve$get_dpb_flags( flags = &ve_vhl_flags );
	ve_vhl_flags ^= VE_VHL_DATA_REDUCTION;
	
	if ( ve_vhl_flags & VE_VHL_DATA_REDUCTION )
	   {
	   ex$message( msgnumb = VE_I_RedEnabled );
	   }
	else
	   {
	   ex$message( msgnumb = VE_I_RedDisabled );
	   }

	ve$set_dpb_flags( flags = ve_vhl_flags );
	}  /* toggle_cull_mode */
