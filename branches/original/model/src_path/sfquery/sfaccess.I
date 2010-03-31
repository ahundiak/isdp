/*
 * FOR Project PATHWAY
 *     Shrirang : Creation
 */

/*
 * OVERVIEW
 *     This file consists of OMuse functions related to Surface
 *     data access. 
 *
 * NOTES
 *     The function in this file access the EMSsubbs instance data, it
 *     primarily tells whether the surface is ACTIVE or not.
 */

class implementation Root;

/* Includes */

#include <math.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"

#include "EMSmsgdef.h"

#include "PWminimum.h"
#include"PWerror.h"

#include "EMSssprops.h"

/* Imports */

from EMSsubbs import EMget_props;
from GRvg import GRgetprops;

PWresult pwIsSurfaceActive
(
  PWobjid                 sfobj, 
  PWosnum                 os,
  short                   *isActive
)
{
  IGRuchar ssprops;

  long  OMsts = OM_S_SUCCESS, OMmsg = EMS_S_Success;

  *isActive = FALSE;

  OMsts = om$send (msg = message EMSsubbs.EMget_props(&OMmsg, &ssprops),
                   senderid = sfobj,
                   targetid = sfobj,
                   targetos = os);
  if (!(1&OMsts&OMmsg))
    return (SetError(0,PW_K_InvalidArg));

  *isActive = ssprops & EMSIS_INACTIVE ? FALSE : TRUE;
  
  return PW_K_Success;
}


PWresult pwIsSurfaceDisplayable
(
  PWobjid                 sfobj, 
  PWosnum                 os,
  short                   *isDisplayable
)
{
  short gprops;
  long  OMsts = OM_S_SUCCESS, OMmsg = EMS_S_Success;
  
  *isDisplayable = FALSE;

  OMsts = om$send(msg = message GRvg.GRgetprops(&OMmsg, &gprops),
		  targetid = sfobj,
		  targetos = os,
		  senderid = sfobj);
  if (!(1&OMsts&OMmsg))
     return (SetError(0,PW_K_InvalidArg));

  *isDisplayable = gprops & GRIS_DISPLAYABLE ? TRUE : FALSE;
  
  return PW_K_Success;
}

end implementation Root;




