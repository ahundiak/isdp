class implementation EMSedge;

#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/edmod.h"
#include "PWapi/edprops.h"
#include "objconn.h"

void pwEdRev
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSedge.EMreverse (&OMmsg),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );
  return;
}

pwMakeCommEdgeConn
(
 PWosnum    osnum,
 PWboolean  orient1,
 PWboolean  orient2,
 PWobjid    edobj1,
 PWobjid    edobj2
)
{
  PWresult PWsts=PW_K_Success;
  OM_S_CHANSELECT  to_common_edge;

  EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);

  PWsts = omConnectObjectAtIndex (edobj1, osnum, &to_common_edge, 0, edobj2, 
                                  osnum, &to_common_edge, 0);
  if (IsError (PWsts))
    return PWsts;

  if (orient1 == orient2)
  {
    pwSetEdRevConn (edobj1, osnum);
    pwSetEdRevConn (edobj2, osnum);
  }

  return PWsts;
}

end implementation EMSedge;
