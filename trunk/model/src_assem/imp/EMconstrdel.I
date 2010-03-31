class implementation EMinstance;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "assemconstr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include <alloca.h>


/*---------------------------------------------------------------------------+
 |                                                                           |
 | ‚Method: EMconstr_deleted                                                 |
 |                                                                           |
 | This message is sent by the constraint to be deleted to Part instance     | 
 |                                                                           |
 | Input :  struct GRid deleted_constr  constraint to be deleted             |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |                                                                           |
 +---------------------------------------------------------------------------*/


method EMconstr_deleted(IGRlong *msg; struct GRid deleted_constr)
{
  IGRlong stat_OM, msg_loc;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send(msg = message NDnode.NDdisconnect(1, &deleted_constr), 
                   targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message EMinstance.EMupdatebasis( &msg_loc ),
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMconstr_deleted");
  return (stat_OM);
}

end implementation EMinstance;
