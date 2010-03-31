class implementation EMSedge;

#include "EMSprop.h"
#include "PWminimum.h"


/*
 * SETTING FUNCTIONS 
 */

void pwSetEdOpen
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg, 
                                 (IGRushort) EMED_OPEN, 
                                 (IGRshort) EMS_O_ON),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwSetEdRev
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg,
                                 (IGRushort) EMED_REVERSED,
                                 (IGRshort) EMS_O_ON),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwUnsetEdRev
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg,
                                 (IGRushort) EMED_REVERSED,
                                 (IGRshort) EMS_O_OFF),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}


void pwSetEdRevConn
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg, 
                                 (IGRushort) EMED_REVERSE_CONNECT, 
                                 (IGRshort) EMS_O_ON),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwSetEdDegen
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg, 
                                 (IGRushort) EMED_DEGENERATE, 
                                 (IGRshort) EMS_O_ON),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwSetEdIso
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg, 
                                 (IGRushort) EMED_ISO, 
                                 (IGRshort) EMS_O_ON),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwUnsetEdIso
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg,
                                 (IGRushort) EMED_ISO,
                                 (IGRshort) EMS_O_OFF),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwSetEdSubordinate
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg, 
                                 (IGRushort) EMED_SUBORDINATE, 
                                 (IGRshort) EMS_O_ON),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwSetEdClosedXYZ
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg, 
                                 (IGRushort) EMED_XYZ_CLOSED, 
                                 (IGRshort) EMS_O_ON),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwSetEdSeam
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg, 
                                 (IGRushort) EMED_SEAM, 
                                 (IGRshort) EMS_O_ON),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwSetEdXYZ
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg,
                                 (IGRushort) EMED_XYZ,
                                 (IGRshort) EMS_O_ON),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwSetEdNatural
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg,
                                 (IGRushort) EMED_NATURAL,
                                 (IGRshort) EMS_O_ON),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwSetEdCvType
(
  PWobjid  edobj,
  PWosnum  edos,
  int      cvtype
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSedge.EMset_type (&OMmsg, (IGRuchar)cvtype),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );
  return ;
}

void pwSetEdCompatible
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg,
                                 (IGRushort) EMED_COMPATIBLE,
                                 (IGRshort) EMS_O_ON),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwSetEdTangent
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg,
                                 (IGRushort) EMED_TANGENT,
                                 (IGRshort) EMS_O_ON),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}


void pwUnsetEdSubordinate
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg, 
                                 (IGRushort) EMED_SUBORDINATE, 
                                 (IGRshort) EMS_O_OFF),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}

void pwUnsetEdSeam
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  OMsts = om$send (msg = message EMSedge.EMset_props (&OMmsg, 
                                 (IGRushort) EMED_SEAM, 
                                 (IGRshort) EMS_O_OFF),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return ;
}
end implementation EMSedge;
