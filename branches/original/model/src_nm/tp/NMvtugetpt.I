class implementation NMvertex_use;

#include "OMmacros.h"
#include "godef.h"

method NMpoint(IGRlong *EMmsg; IGRdouble *point; IGRboolean get)
{
 *EMmsg = EMS_S_Success;

 if(get)
  OM_BLOCK_MOVE(ME.NMvertex_use->point, point, 2*sizeof(IGRdouble));
 else
  OM_BLOCK_MOVE(point, ME.NMvertex_use->point, 2*sizeof(IGRdouble));

 return(OM_S_SUCCESS);
}

end implementation NMvertex_use;
