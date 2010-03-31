/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "emsmacros.h"

method EMgetrange (
	IGRlong		*EMmsg;
	IGRdouble	*range)

/*
 History  RC  05/2/87	Creation Date
*/

{
  *EMmsg = EMS_S_Success;

  range[0] = ME.EMSloop->range[0];
  range[1] = ME.EMSloop->range[1];
  range[2] = ME.EMSloop->range[2];
  range[3] = ME.EMSloop->range[3];

  return (OM_S_SUCCESS);
}

end implementation EMSloop;
