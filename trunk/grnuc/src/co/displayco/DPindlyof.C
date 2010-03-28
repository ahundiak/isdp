/* #######################    APOGEE COMPILED   ######################## */
#include "OMtypes.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "layer.h"
#include "grmessage.h"
#include "msmacros.h"

#include "DPindlyof.h"   /* defining prototype file */

IGRint DPproc_mask_of (msg,elig_mask,ind_ly)

IGRlong *msg;
IGRlong *elig_mask;
struct GRindlayer *ind_ly;
{
IGRlong shift_ly;
IGRshort ind, index;
IGRlong count;

*msg = MSSUCC;

count = 0;
for (ind = 0; ind < 32; ind++)
{
    shift_ly = elig_mask[ind];
    for (index = 0; index < 32; index++)
    {
	if ( 1 & shift_ly)
	{
           ex$message( msgnumb = GR_I_LayOn,
                       buff = ind_ly[count].elig );
	}
	else
	{
           ex$message( msgnumb = GR_I_LayOff,
                       buff = ind_ly[count].elig );
	}
	shift_ly >>= 1;
	count++;
    }
}
return(1);
}


