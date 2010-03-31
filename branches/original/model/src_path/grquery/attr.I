class implementation Root;

#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "gocmacros.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "EMSmsgdef.h"

#include "PWapi/attr.h"

from GRvg import GRgetsymb;

/*
  DESCRIPTION

  The following function obtains the color, weight and line-style of the
  graphics object. 


  BUGS
 
  HISTORY

  SAM  :  12/03/96  :  Creation
*/

PWresult pwGetSymbology
(
  PWobjid                 objid, 
  PWosnum                 os,
  struct GRsymbology     *p_symb
)
{
  /* status stuff */

  long                    OMsts = OM_S_SUCCESS, OMmsg = EMS_S_Success;
  unsigned                int retval = PW_K_Success;

  OnErrorState(!p_symb, retval, SetError(0, PW_K_Internal), wrapup);

  OMsts = om$send(msg = message GRvg.GRgetsymb(&OMmsg, p_symb),
		  targetid = objid,
		  targetos = os,
		  senderid = objid);
  OnErrorState(!(1&OMsts&OMmsg), retval, SetError(0, PW_K_Internal), wrapup);

wrapup:

  return retval;
}

end implementation Root;

