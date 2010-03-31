class implementation HStoggle;



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



#define _start 0

method toggle_cull_mode ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
	quit:
  return OM_S_SUCCESS;
}

end implementation HStoggle;
