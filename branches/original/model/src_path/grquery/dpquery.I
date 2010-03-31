class implementation GRgraphics;

#include <stdio.h>

#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/dpquery.h"
#include "PWapi/clsid.h"


from GRdpb import GRget;


PWresult pwGetDpbParam
(
  PWosnum osnum,
  int param,
  char *buffer
)

{
  int rc=OM_S_SUCCESS;
  PWresult status=OM_S_SUCCESS;
  PWobjid grdpb=PW_K_NullObjid;

  grdpb = omObjOfClass (omClassidFromName ("GRdpb", osnum), osnum);

  status = om$send( msg = message GRdpb.GRget(&rc,
					      param, 
					      buffer),
                        senderid = NULL_OBJID,
                        targetid = grdpb,
                        targetos = osnum);
   return(status);
}

end implementation GRgraphics;
