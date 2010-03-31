class implementation NMpartedge;

#include "nmdef.h"

method NMprop(IGRlong *EMmsg; unsigned char options, *nmprops)
{
 *EMmsg = EMS_S_Success;
	
 if(options & NMprop_Get) *nmprops = ME.NMpartedge->nmprops;
 if(options & NMprop_SetOn) ME.NMpartedge->nmprops |= *nmprops;
 if(options & NMprop_SetOff) ME.NMpartedge->nmprops &= ~(*nmprops);
 return(OM_S_SUCCESS);
}

end implementation NMpartedge;
