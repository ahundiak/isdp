/* ###################   APOGEE COMPILED   ################## */
class implementation EMShorizon;

#include <stdio.h>
#include "bs.h"
#include "bsparameters.h"

/*
History

    10 Jul 90   AIC     Creation Date
    03 Oct 90   AIC     Added support for "best hit" display.
    11 Nov 90   AIC     Removed "best hit" display, added edge-based
                        rule lines.
    26 Nov 90   AIC     Support horizon edge display on/off switch.
    01 May 91   Jack    Modified for 2.0.1 Horizon Loops.

Notes
    I think this method will go away as its main purpose is to 
    set me->z which no longer exists. -Jack

*/

method EMset_orientation(int        *z_index;
                          IGRvector   vector)

{

  long  sts = OM_S_SUCCESS;
/*
  if(vector)
  {
    long rc;
    void BSnorvec();

    me->z[0] = vector[0];
    me->z[1] = vector[1];
    me->z[2] = vector[2];
    BSnorvec(&rc, me->z);
  }
  else if(z_index) sts = OM_E_NOTIMPL;
  else sts = OM_E_INVARG;

  EMWRAPUP(sts, sts, "EMShorizon.EMset_orientation")
*/
  return sts;
};


end implementation EMShorizon;
