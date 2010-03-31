/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
class implementation EMSptgralp;

#include "EMS.h"

method EMreverse( IGRlong *EMmsg )
{
  *EMmsg = EMS_I_OpenLoop;

  return( OM_S_SUCCESS );
}

end implementation EMSptgralp;
