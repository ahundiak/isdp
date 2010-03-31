/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
class implementation EMSptgralp;

#include "EMS.h"
method EMarea( IGRlong   *msg; 
               IGRdouble *area )
{
  *msg = EMS_I_Degenerate;
  *area = 0.0;

  return( OM_S_SUCCESS );
}

end implementation EMSptgralp;

