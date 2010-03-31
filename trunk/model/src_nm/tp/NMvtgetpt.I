class implementation NMvertex;

#include "OMmacros.h"
#include "godef.h"

method NMpoint(IGRlong *EMmsg; IGRdouble *point; IGRboolean get)
{
 *EMmsg = EMS_S_Success;

 if(get)
  OM_BLOCK_MOVE(ME.GR3dpoint->point, point, 3*sizeof(IGRdouble));
 else
  OM_BLOCK_MOVE(point, ME.GR3dpoint->point, 3*sizeof(IGRdouble));

 return(OM_S_SUCCESS);
}

end implementation NMvertex;
