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

#include "PWapi/lsgetprops.h"

PWboolean pwIsLsNatural 
(
  PWobjid lsobj,
  PWosnum lsos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  unsigned short lsprops=0;

  OMsts = om$send (msg = message EMSloopset.EMget_props (&OMmsg, &lsprops),
                   senderid = lsobj,
                   targetid = lsobj,
                   targetos = lsos);

  return (PWboolean) (lsprops & EMLS_NATURAL) ? TRUE : FALSE;
}

PWboolean pwIsLsSplit
(
  PWobjid lsobj,
  PWosnum lsos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  unsigned short lsprops=0;

  OMsts = om$send (msg = message EMSloopset.EMget_props (&OMmsg, &lsprops),
                   senderid = lsobj,
                   targetid = lsobj,
                   targetos = lsos);

  return (PWboolean) (lsprops & EMLS_SPLIT) ? TRUE : FALSE;
}

PWboolean pwIsLsXyz
(
  PWobjid lsobj,
  PWosnum lsos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  unsigned short lsprops=0;

  OMsts = om$send (msg = message EMSloopset.EMget_props (&OMmsg, &lsprops),
                   senderid = lsobj,
                   targetid = lsobj,
                   targetos = lsos);

  return (PWboolean) (lsprops & EMLS_XYZ) ? TRUE : FALSE;
}

end implementation EMSloopset;
