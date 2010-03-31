/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method adds output to the regular output of a debug send to
    the EMSshobjmgr (the superclass).

  HISTORY

    SS  :  06/28/89  :  Creation
*/

class implementation EMSshovflow;

#include "EMS.h"
#include <stdio.h>

method debug ()
{
  fprintf (stderr, "vfunc_identifier: %d\n", ME.EMSshovflow->vfunc_identifier);
  
  return (om$send (mode = OM_e_wrt_message,
          msg = message EMSshobjmgr.debug(), targetid = my_id));
}

end implementation EMSshovflow;
