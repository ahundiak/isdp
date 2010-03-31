class implementation NMfeaturelp;

#include "nmdef.h"

method NMprop(IGRlong *EMmsg; unsigned char options, *nmprops)
{
 *EMmsg = EMS_S_Success;
	
 if(options & NMprop_Get) *nmprops = ME.NMfeaturelp->nmprops;
 if(options & NMprop_SetOn) ME.NMfeaturelp->nmprops |= *nmprops;
 if(options & NMprop_SetOff) ME.NMfeaturelp->nmprops &= ~(*nmprops);
 return(OM_S_SUCCESS);
}

end implementation NMfeaturelp;
