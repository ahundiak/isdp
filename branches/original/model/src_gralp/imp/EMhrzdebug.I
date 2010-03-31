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
    16 Sep 91   Jack    Removed the reference to me->z as it no longer
                        exists.
*/


/* 
 * Earlier defined at Root 
 */
method debug()
{
  int  sts;
  
  sts = OM_S_SUCCESS;

  sts = om$send( msg = message EMSgraloop.debug(), 
                  mode = OM_e_wrt_message, 
                  targetid = my_id );
  return( sts );
};


end implementation EMShorizon;
