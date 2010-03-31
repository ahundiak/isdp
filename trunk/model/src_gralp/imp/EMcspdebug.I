/* ###################   APOGEE COMPILED   ################## */
class implementation EMScusp;

/*
History

    AIC  08 Oct 1990 Genesis
    Jack 30 Apr 1991 Modified for 2.0.1 Horizon Loops.

*/

#include "emsedgedef.h"
#include "msdef.h"
#include "dperr.h"
#include "OMmacros.h"


/* earlier defined at Root */
method debug()
{
  int              sts;
  
  sts = OM_S_SUCCESS;

  sts = om$send( msg = message EMSgraloop.debug(), 
                 mode = OM_e_wrt_message, 
                 targetid = my_id );

  return( sts );

};


end implementation EMScusp;
