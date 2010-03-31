/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/*
 * OVERVIEW
 *
 * NOTES
 */

class implementation Root;

/* Includes */

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"

#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "EMSprop.h"


#include "PWminimum.h"

/* Imports */

from EMSloop  import  EMgetrange, EMget_props;

void pwGetLpRange 
(
  PWobjid   loopobj,
  PWosnum   loopos,
  PWrange2d range 
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message EMSloop.EMgetrange (&OMmsg, (double *)range),
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);
  return ;
}

/*
 * QUERY
 */

PWboolean pwIsLpNatural 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* loop properties */
  unsigned short loop_props=0;

  OMsts = om$send (msg = message EMSloop.EMget_props (&OMmsg, &loop_props), 
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return (PWboolean) ((loop_props & EMLP_NATURAL) ? TRUE : FALSE);
}


PWboolean pwIsLpSplit 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* loop properties */
  unsigned short loop_props=0;

  OMsts = om$send (msg = message EMSloop.EMget_props (&OMmsg, &loop_props), 
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return (PWboolean) ((loop_props & EMLP_SPLIT) ? TRUE : FALSE);
}


PWboolean pwIsLpOpen 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* loop properties */
  unsigned short loop_props=0;

  OMsts = om$send (msg = message EMSloop.EMget_props (&OMmsg, &loop_props), 
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return (PWboolean) ((loop_props & EMLP_OPEN) ? TRUE : FALSE);
}


PWboolean pwIsLpFace 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* loop properties */
  unsigned short loop_props=0;

  OMsts = om$send (msg = message EMSloop.EMget_props (&OMmsg, &loop_props), 
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return (PWboolean) ((loop_props & EMLP_PLOOP) ? TRUE : FALSE);
}


PWboolean pwIsLpOuter 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* loop properties */
  unsigned short loop_props=0;

  OMsts = om$send (msg = message EMSloop.EMget_props (&OMmsg, &loop_props), 
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return (PWboolean) ((loop_props & EMLP_EXTERNAL) ? TRUE : FALSE);
}


PWboolean pwIsLpNew 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* loop properties */
  unsigned short loop_props=0;

  OMsts = om$send (msg = message EMSloop.EMget_props (&OMmsg, &loop_props), 
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return (PWboolean) ((loop_props & EMLP_NEW) ? TRUE : FALSE);
}


PWboolean pwIsLpActive 
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* loop properties */
  unsigned short loop_props=0;

  OMsts = om$send (msg = message EMSloop.EMget_props (&OMmsg, &loop_props), 
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return (PWboolean) ((loop_props & EMLP_ACTIVE) ? TRUE : FALSE);
}

PWboolean pwIsLpRev
(
  PWobjid loopobj,
  PWosnum loopos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* loop properties */
  unsigned short loop_props=0;

  OMsts = om$send (msg = message EMSloop.EMget_props (&OMmsg, &loop_props),
                   senderid = loopobj,
                   targetid = loopobj,
                   targetos = loopos);

  return (PWboolean) ((loop_props & EMLP_REVERSED) ? TRUE : FALSE);
}

end implementation Root;
