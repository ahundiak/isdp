class implementation EMconstr;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "nddef.h"
#include <alloca.h>


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMreverse_direction                                              |
 |                                                                           |
 | This message reverses the direction of the constraint.                    |
 |                                                                           |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 +---------------------------------------------------------------------------*/

method EMreverse_direction (IGRlong *msg)
{

  IGRlong status, stat_OM, msg_loc;
  struct GRid from_part, to_part, null_grid, my_grid;
  FEATURE_ID feature_tmp;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;  

  OM_BLOCK_MOVE(&(me->feature_two), &feature_tmp, sizeof (FEATURE_ID));
  
  OM_BLOCK_MOVE(&(me->feature_one), &(me->feature_two), sizeof (FEATURE_ID));
  
  OM_BLOCK_MOVE(&feature_tmp, &(me->feature_one), sizeof (FEATURE_ID));

  stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, FALSE,&from_part), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, TRUE, &to_part), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message NDnode.NDdisconnect(1, &from_part), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM), status, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message NDnode.NDdisconnect(1, &my_grid), 
                     targetid = to_part.objid,
                     targetos = to_part.osnum);
  EMerr_hndlr (EMSerror (stat_OM), status, EMS_E_Fail, ret_end);

  null_grid.objid = NULL_OBJID;

  status = om$send(msg = message NDnode.NDconnect(1, &my_grid, null_grid, ND_NEW),
                     targetid = from_part.objid,
                     targetos = from_part.osnum);
  EMerr_hndlr (EMSerror (stat_OM), status, EMS_E_Fail, ret_end);

  status = om$send(msg = message NDnode.NDconnect(1, &to_part, null_grid, ND_NEW),
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM), status, EMS_E_Fail, ret_end);


ret_end:
  EMWRAPUP (status, *msg, "EMreverse_direction");
  return (status);

}

end implementation EMconstr;
