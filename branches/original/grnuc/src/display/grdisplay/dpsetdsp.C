
#include <stdio.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "igecolordef.h"
#include "igewinmacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpdls.h"

#include "wl.h"

/* prototype files */
#include "dpsetdsp.h"

void DPinq_style( IGRshort        index,
		  unsigned short  *style )
{
	WLget_defined_style( index, (WLuint16 *) style );
}

void DPdefine_style( short index,
		     unsigned short style )
{
	WLdefine_style( index, (WLuint16) style );
} /* DPdefine_style */

