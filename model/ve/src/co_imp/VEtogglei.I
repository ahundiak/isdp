class implementation VEtoggle;



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


#define _start 0

method toggle_reduction_mode ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
	quit:
  return OM_S_SUCCESS;
}

end implementation VEtoggle;
