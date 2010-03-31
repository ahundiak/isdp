/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/*
 * OVERVIEW
 *
 * NOTES
 */

class implementation EMSloopset;

#include "PWminimum.h"

#include "PWapi/lssetprops.h"

void pwSetLsNatural 
(
  PWobjid lsobj,
  PWosnum lsos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloopset.EMset_props (&OMmsg, 
                                 (IGRushort) EMLS_NATURAL, 
                                 (IGRshort) EMS_O_ON),
                   senderid = lsobj,
                   targetid = lsobj,
                   targetos = lsos);

  return ;
}

void pwUnsetLsNatural 
(
  PWobjid lsobj,
  PWosnum lsos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloopset.EMset_props (&OMmsg, 
                                 (IGRushort) EMLS_NATURAL, 
                                 (IGRshort) EMS_O_OFF),
                   senderid = lsobj,
                   targetid = lsobj,
                   targetos = lsos);

  return ;
}

void pwSetLsSplit
(
  PWobjid lsobj,
  PWosnum lsos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloopset.EMset_props (&OMmsg,
                                 (IGRushort) EMLS_SPLIT,
                                 (IGRshort) EMS_O_ON),
                   senderid = lsobj,
                   targetid = lsobj,
                   targetos = lsos);

  return ;
}

void pwSetLsXyz
(
  PWobjid lsobj,
  PWosnum lsos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloopset.EMset_props (&OMmsg,
                                 (IGRushort) EMLS_XYZ,
                                 (IGRshort) EMS_O_ON),
                   senderid = lsobj,
                   targetid = lsobj,
                   targetos = lsos);

  return ;
}

end implementation EMSloopset;
