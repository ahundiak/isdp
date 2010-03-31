/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/*
 * OVERVIEW
 *
 * NOTES
 */

class implementation EMSloop;

#include "PWminimum.h"

void pwSetLpNatural 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloop.EMset_props (&OMmsg, 
                                 (IGRushort) EMLP_NATURAL, 
                                 (IGRshort) EMS_O_ON),
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return ;
}

void pwUnsetLpNatural
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloop.EMset_props (&OMmsg,
                                 (IGRushort) EMLP_NATURAL,
                                 (IGRshort) EMS_O_OFF),
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return ;
}
 
void pwSetLpSplit 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloop.EMset_props (&OMmsg, 
                                 (IGRushort) EMLP_SPLIT, 
                                 (IGRshort) EMS_O_ON),
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return ;
}
 
void pwSetLpOpen 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloop.EMset_props (&OMmsg, 
                                 (IGRushort) EMLP_OPEN, 
                                 (IGRshort) EMS_O_ON),
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return ;
}
 
void pwSetLpFace 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloop.EMset_props (&OMmsg, 
                                 (IGRushort) EMLP_PLOOP, 
                                 (IGRshort) EMS_O_ON),
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return ;
}
 
void pwSetLpOuter 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloop.EMset_props (&OMmsg, 
                                 (IGRushort) EMLP_EXTERNAL, 
                                 (IGRshort) EMS_O_ON),
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return ;
}
 
void pwSetLpNew 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloop.EMset_props (&OMmsg, 
                                 (IGRushort) EMLP_NEW, 
                                 (IGRshort) EMS_O_ON),
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return ;
}
 
void pwSetLpActive 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloop.EMset_props (&OMmsg, 
                                 (IGRushort) EMLP_ACTIVE, 
                                 (IGRshort) EMS_O_ON),
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return ;
}

void pwSetLpRev
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloop.EMset_props (&OMmsg,
                                 (IGRushort) EMLP_REVERSED,
                                 (IGRshort) EMS_O_ON),
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return ;
}

void pwSetLpRange
(
  PWobjid   loopobj,
  PWosnum   loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloop.EMsetrange (&OMmsg),
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);
  
  return;
}


end implementation EMSloop;
