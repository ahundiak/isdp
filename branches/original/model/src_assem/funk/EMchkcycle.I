
class implementation EMconstr;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "assemconstr.h"
#include "ndmacros.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Routine: EMchk_cycle()                                                  |
 |                                                                           |  
 | This routine checks for the formation of a cycle during propogation of the|
 | causality of the newly added constraint.                                  |
 |                                                                           |
 +---------------------------------------------------------------------------*/

int EMchk_cycle(constr_path_len, constr_path, constr_list, pcycle_formed)
IGRint         constr_path_len; /* # of constraints in the path */
IGRint         constr_path[];   /* The path to the underconstr assembly */
CANDIDATE_CONSTR constr_list[]; /* list of candidate cnstrs */
IGRboolean *pcycle_formed;      /* TRUE if a cycle formed */
{
  struct GRid curr_constr, part_one, part_two;
  IGRlong msg_loc, stat_OM, status;
  int constr_pos;
  int num_sc, *sc_size, **sc;    
  struct GRid *node_list;  
  status = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  *pcycle_formed = FALSE;

  curr_constr = constr_list[0].constr_grid;

  stat_OM = om$send (msg = message EMconstr.EMgetpart 
                     (&msg_loc, FALSE, &part_one),
                     senderid = NULL_OBJID,
                     targetid = curr_constr.objid,
                     targetos = curr_constr.osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);

  if (constr_path_len > 0)
  {
    constr_pos = constr_path[0];
    curr_constr = constr_list[constr_pos].constr_grid;

    stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, TRUE, &part_two),
                     senderid = NULL_OBJID,
                     targetid = curr_constr.objid,
                     targetos = curr_constr.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);
  }
  else
  {
    curr_constr = constr_list[0].constr_grid;
  
    stat_OM = om$send (msg = message EMconstr.EMgetpart 
                       (&msg_loc, TRUE, &part_two),
                       senderid = NULL_OBJID,
                       targetid = curr_constr.objid,
                       targetos = curr_constr.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);
  }

  if (part_one.objid != NULL_OBJID)
  {
    status = EQfind_all_sc(part_one, &num_sc, &sc_size, &sc, &node_list);
    EMerr_hndlr (EMSerror(status), status, EMS_E_Fail, ret_end);
  
    if (num_sc)
      *pcycle_formed = TRUE;
  
    EQfree_sc_mem();
  }    

ret_end:
  EMWRAPUP (status, status, "EMchk_cycle");
  return (status);
}

end implementation EMconstr;
