class implementation GRvg;

#include <stdio.h>

#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/symb.h"

PWresult pwPutSymb
(
  PWobjid objid, 
  PWosnum osnum,  
  struct GRsymbology *Symb
)
{
  PWresult status;
  long LongRc;

  status = om$send( msg = message GRvg.GRputsymb(&LongRc, Symb),
                   senderid = NULL_OBJID,
                   targetid = objid,
                   targetos = osnum);
  return(status);
}

end implementation GRvg;
