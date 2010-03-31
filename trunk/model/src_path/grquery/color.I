
class implementation Root;


#include "OMminimum.h"
#include "OMprimitives.h"

#ifndef BASE_EMS
#include "wl.h"
#endif
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igecolor.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/objaccess.h"
#include "PWapi/clsid.h"

/* Imported methods */

from IGEcolor2  import read_clr_tbl;


PWresult pwGetColorMapSize(
  short *size,
  PWosnum osnum
)
{
  
  int sts;
  PWobjid col_id;
  PWresult result=PW_K_Success;

  *size = 0;

  col_id = omObjOfClass (omClassidFromName ("IGEcolor2", osnum), osnum);
  OnErrorState (col_id == PW_K_NullObjid, result,
   SetError (PW_K_Pathway, PW_K_NotFound), wrapup);

  sts = om$send( msg = message IGEcolor2.read_clr_tbl(size, (void *)NULL, 0),
                 targetid = col_id, targetos = osnum, senderid = col_id);
  OnErrorState (0 == *size, result,
   SetError (PW_K_Pathway, PW_K_Internal), wrapup);

//Do not check the sts, it returns FALSE when asking for size and
//TRUE while getting the map, as in the following function  
  

wrapup:
  PW_Wrapup (result, "pwGetColorMapSize");
  return (result);
}


PWresult pwGetColorMap(
  struct IGEvlt *rgb_val, 
  short *num_colors,
  PWosnum osnum
)
{
  int sts;
  PWobjid col_id;
  PWresult result=PW_K_Success;

  col_id = omObjOfClass (omClassidFromName ("IGEcolor2", osnum), osnum);
  OnErrorState (col_id == PW_K_NullObjid, result,
   SetError (PW_K_Pathway, PW_K_NotFound), wrapup);

  sts = om$send( msg = message IGEcolor2.read_clr_tbl(num_colors, (void *)rgb_val, 0),
                 targetid = col_id, targetos = osnum, senderid = col_id);
  OnErrorState (!(1&sts), result,
   SetError (PW_K_Pathway, PW_K_Internal), wrapup);

    /* do the RGB mapping in the calling routine   */

wrapup:
  PW_Wrapup (result, "pwGetColorMap");
  return (result);

}

end implementation Root;
