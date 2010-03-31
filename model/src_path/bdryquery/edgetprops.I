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

from EMSedge import EMget_props, EMget_props_type, EMisdegentol;

PWboolean pwIsEdOpen
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  /* edge properties */
  unsigned short edprops=0;

  OMsts = om$send (msg = message EMSedge.EMget_props (&OMmsg, &edprops),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return (PWboolean) ((edprops & EMED_OPEN) ? TRUE : FALSE);
}

PWboolean pwIsEdRev
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* edge properties */
  unsigned short edprops=0;

  OMsts = om$send (msg = message EMSedge.EMget_props (&OMmsg, &edprops),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return (PWboolean) ((edprops & EMED_REVERSED) ? TRUE : FALSE);
}

PWboolean pwIsEdRevConn
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  /* edge properties */
  unsigned short edprops=0;

  OMsts = om$send (msg = message EMSedge.EMget_props (&OMmsg, &edprops),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return (PWboolean) ((edprops & EMED_REVERSE_CONNECT) ? TRUE : FALSE);
}

PWboolean pwIsEdDegen
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  /* edge properties */
  unsigned short edprops=0;

  OMsts = om$send (msg = message EMSedge.EMget_props (&OMmsg, &edprops),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return (PWboolean) ((edprops & EMED_DEGENERATE) ? TRUE : FALSE);
}


PWboolean pwIsEdIso
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  /* edge properties */
  unsigned short edprops=0;

  OMsts = om$send (msg = message EMSedge.EMget_props (&OMmsg, &edprops),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return (PWboolean) ((edprops & EMED_ISO) ? TRUE : FALSE);
}


PWboolean pwIsEdSubordinate
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  /* edge properties */
  unsigned short edprops=0;

  OMsts = om$send (msg = message EMSedge.EMget_props (&OMmsg, &edprops),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return (PWboolean) ((edprops & EMED_SUBORDINATE) ? TRUE : FALSE);
}


PWboolean pwIsEdClosedXYZ
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  /* edge properties */
  unsigned short edprops=0;

  OMsts = om$send (msg = message EMSedge.EMget_props (&OMmsg, &edprops),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return (PWboolean) ((edprops & EMED_XYZ_CLOSED) ? TRUE : FALSE);
}


PWboolean pwIsEdSeam
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
 
  /* edge properties */
  unsigned short edprops=0;

  OMsts = om$send (msg = message EMSedge.EMget_props (&OMmsg, &edprops),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return (PWboolean) ((edprops & EMED_SEAM) ? TRUE : FALSE);
}

PWboolean pwIsEdXYZ
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* edge properties */
  unsigned short edprops=0;

  OMsts = om$send (msg = message EMSedge.EMget_props (&OMmsg, &edprops),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return (PWboolean) ((edprops & EMED_XYZ) ? TRUE : FALSE);
}


PWboolean pwIsEdNatural
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* edge properties */
  unsigned short edprops=0;

  OMsts = om$send (msg = message EMSedge.EMget_props (&OMmsg, &edprops),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );

  return (PWboolean) ((edprops & EMED_NATURAL) ? TRUE : FALSE);
}

int pwGetEdCvType
(
  PWobjid  edobj,
  PWosnum  edos
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* curve type */
  unsigned char cvtype=0;

  OMsts = om$send (msg = message EMSedge.EMget_props_type (&OMmsg, 
                                 (unsigned short *) NULL, &cvtype),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );
  return (int) cvtype;
}

PWboolean pwIsEdDegenTol
(
  PWobjid  edobj,
  PWosnum  edos,
  double   lentol
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS;
  
  PWboolean is_degen=FALSE;

  OMsts = om$send (msg = message EMSedge.EMisdegentol (NULL, lentol, 
                                 &is_degen),
                   senderid = edobj,
                   targetid = edobj,
                   targetos = edos );
  return is_degen;
}


end implementation Root;
