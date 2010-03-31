class implementation EMSsurface;

#include "PWminimum.h"

#include "PWapi/orntsf.h"
#include "PWapi/sftype.h"

void pwRevNormalSf
(
  PWobjid  sfobj,
  PWosnum  os 
)
{
  long OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
  
  OMsts = om$send (msg = message EMSsurface.EMrevorient (&OMmsg),
                     targetid = sfobj, targetos = os, senderid = sfobj); 

  return;
}

end implementation EMSsurface;
