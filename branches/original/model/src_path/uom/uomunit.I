class implementation Root;


#include <stdio.h>
#include <string.h>
#include "OMminimum.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/uomunit.h"
#include "PWapi/objaccess.h"
#include "PWapi/clsid.h"

from UOMsuper import get_distance_units;

PWboolean pwIsMetric
(
  PWosnum osnum
)
{  
  char units[PW_K_MaxStringLen];
  PWboolean is_metric=TRUE;
  PWresult result=PW_K_Success;

  result = uomGetUnits (osnum, units);
  OnErrorCode (result, wrapup);

  if (!strcmp (units, "in") || 
      !strcmp (units, "inches") || 
      !strcmp (units, "inch"))
    is_metric = FALSE;

wrapup:
  PW_Wrapup (result, "pwIsMetric");
  return (is_metric);
}


PWresult uomGetUnits
( 
  PWosnum osnum,
  char units[]
)
{
	PWresult status;

	OM_S_OBJID uomid;

    	uomid = omObjOfClass (omClassidFromName ("UOMsuper", osnum), osnum);

	status  = om$send( msg = message UOMsuper.get_distance_units(units),
			  senderid = NULL_OBJID,
			  targetid = uomid,
			  targetos = osnum);

	return(status);
}		
end implementation Root;
