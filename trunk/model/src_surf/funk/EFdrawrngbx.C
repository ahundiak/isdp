/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"

/*
DESCRIPTION:

This function just draws the range box.

HISTORY:

SAM	06/01/88	Creation.
*/

void EFdraw_range_box(range)
GRrange range;
{
  IGRlong               bytes_in, bytes_out, msg;
  IGRlong               sts, ECdisplayPointSetByBuffer(); 
  IGRpoint              dog[2];
  struct GRmd_env       ModuleInfo;
  struct IGRdisplay     ActiveDisplay;
  IGRpoint corners[8];

 corners[0][0] = range[0];
 corners[0][1] = range[1];
 corners[0][2] = range[2];

 corners[1][0] = range[3];
 corners[1][1] = range[1];
 corners[1][2] = range[2];

 corners[2][0] = range[3];
 corners[2][1] = range[4];
 corners[2][2] = range[2];

 corners[3][0] = range[0];
 corners[3][1] = range[4];
 corners[3][2] = range[2];

 corners[4][0] = range[0];
 corners[4][1] = range[1];
 corners[4][2] = range[5];

 corners[5][0] = range[3];
 corners[5][1] = range[1];
 corners[5][2] = range[5];

 corners[6][0] = range[3];
 corners[6][1] = range[4];
 corners[6][2] = range[5];

 corners[7][0] = range[0];
 corners[7][1] = range[4];
 corners[7][2] = range[5];

  bytes_in = sizeof(ActiveDisplay);
  gr$get_active_display(msg = &msg, sizbuf = &bytes_in,
    buffer = &ActiveDisplay, nret = &bytes_out);

  bytes_in = sizeof(ModuleInfo);
  gr$get_module_env(msg = &msg, sizbuf = &bytes_in,
   buffer = &ModuleInfo, nret = &bytes_out);

  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 4, corners[0], TRUE); 
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 4, corners[4], TRUE); 
  dog[0][0] = corners[0][0];
  dog[0][1] = corners[0][1];
  dog[0][2] = corners[0][2];
  dog[1][0] = corners[3][0];
  dog[1][1] = corners[3][1];
  dog[1][2] = corners[3][2];
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 2, dog, TRUE); 
  dog[0][0] = corners[7][0];
  dog[0][1] = corners[7][1];
  dog[0][2] = corners[7][2];
  dog[1][0] = corners[4][0];
  dog[1][1] = corners[4][1];
  dog[1][2] = corners[4][2];
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 2, dog, TRUE); 

  dog[0][0] = corners[0][0];
  dog[0][1] = corners[0][1];
  dog[0][2] = corners[0][2];
  dog[1][0] = corners[4][0];
  dog[1][1] = corners[4][1];
  dog[1][2] = corners[4][2];
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 2, dog, TRUE); 
  dog[0][0] = corners[1][0];
  dog[0][1] = corners[1][1];
  dog[0][2] = corners[1][2];
  dog[1][0] = corners[5][0];
  dog[1][1] = corners[5][1];
  dog[1][2] = corners[5][2];
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 2, dog, TRUE); 
  dog[0][0] = corners[2][0];
  dog[0][1] = corners[2][1];
  dog[0][2] = corners[2][2];
  dog[1][0] = corners[6][0];
  dog[1][1] = corners[6][1];
  dog[1][2] = corners[6][2];
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 2, dog, TRUE); 
  dog[0][0] = corners[3][0];
  dog[0][1] = corners[3][1];
  dog[0][2] = corners[3][2];
  dog[1][0] = corners[7][0];
  dog[1][1] = corners[7][1];
  dog[1][2] = corners[7][2];
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay,
         ModuleInfo, OM_GO_TransOS_0, 2, dog, TRUE); 

}
