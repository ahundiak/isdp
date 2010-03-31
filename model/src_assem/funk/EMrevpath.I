
class implementation EMconstr;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "assemconstr.h"

from EMinstance import EMupdatebasis;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Routine: EMreverse_path()                                                 |
 |                                                                           |  
 | This routine propogates the causality of the newly added constraint       |
 | to underconstrained portion of the assembly along a previously determined |
 | path.                                                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/

int EMreverse_path(constr_path_len, constr_path, constr_list, first_direction)
IGRint         constr_path_len; /* # of constraints in the path */
IGRint         constr_path[];   /* The path to the underconstr assembly */
CANDIDATE_CONSTR constr_list[]; /* list of candidate cnstrs */
IGRboolean first_direction;     /* is it 1st search direction */
{
  struct GRid curr_constr, part_grid;
  IGRlong msg_loc, stat_OM, status;
  int constr_pos, constr_counter;
    
  status = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  for (constr_counter = 0; constr_counter < constr_path_len; constr_counter++)
  {
    constr_pos = constr_path[constr_counter];
    curr_constr = constr_list[constr_pos].constr_grid;

    stat_OM = om$send (msg = message EMconstr.EMreverse_direction (&msg_loc), 
                       senderid = NULL_OBJID,
                       targetid = curr_constr.objid,
                       targetos = curr_constr.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);

    stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, TRUE, &part_grid),
                       senderid = NULL_OBJID,
                       targetid = curr_constr.objid,
                       targetos = curr_constr.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);

    stat_OM = om$send (msg = message EMinstance.EMupdatebasis (&msg_loc),
                       senderid = NULL_OBJID,
                       targetid = part_grid.objid,
                       targetos = part_grid.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);
  }
  if (first_direction)
  {
    curr_constr = constr_list[0].constr_grid;

    stat_OM = om$send (msg = message EMconstr.EMgetpart 
                       (&msg_loc, TRUE,&part_grid),
                       senderid = NULL_OBJID,
                       targetid = curr_constr.objid,
                       targetos = curr_constr.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);

    stat_OM = om$send (msg = message EMinstance.EMupdatebasis (&msg_loc),
                       senderid = NULL_OBJID,
                       targetid = part_grid.objid,
                       targetos = part_grid.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);
  }


ret_end:
  EMWRAPUP (status, status, "EMreverse_path");
  return (status);
}

end implementation EMconstr;
