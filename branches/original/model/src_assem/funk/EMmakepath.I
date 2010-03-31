class implementation EMconstr;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "assemconstr.h"

from EMinstance import EMget_reversible_constr;


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Routine: EMmake_path()                                                    |
 |                                                                           |  
 | This routine finds the path from the contraint that emanates from an      |
 | underconstrained part to the newly added constraint.                      |
 |                                                                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/

int EMmake_path(constr_level, level_list,  constr_pos, constr_list, 
                first_direction, pconstr_path_len, constr_path)
IGRint	       constr_level;	/* search level of constr IN */
IGRint	       level_list[];	/* list of search levels IN */
IGRint	       constr_pos;	/* position in constr list IN */
CANDIDATE_CONSTR constr_list[]; /* list of candidate cnstrs IN */
IGRboolean     first_direction;  /* is it 1st search direction */	 
IGRint         *pconstr_path_len; /* # of cosntraints in the path OUT */
IGRint         constr_path[];          /* The path to the underconstr assembly OUT */
{
  IGRint first_constr, last_constr, constr_counter, lvl_counter, counter;
  struct GRid curr_constr;  /*  The current constr grid */
  struct GRid next_lvl_constr;        
  IGRlong msg_loc, stat_OM, status;
  struct GRid part_grid_1, part_grid_2;        
  IGRint num_reversible_constr;
  struct GRid reversible_constr[MAX_INCIDENT_CONSTR];
  IGRboolean found_nxt_constr;
  int level_limit;

  status = EMS_S_Success;
      
  curr_constr = constr_list[constr_pos].constr_grid;
  
  (*pconstr_path_len) = 0;
  

  if (constr_pos > 0)
  {
    constr_path[(*pconstr_path_len)] = constr_pos;
  
    (*pconstr_path_len)++;
  }

  
  found_nxt_constr = FALSE;
  
  if (first_direction)
    level_limit = 1;
  else
    level_limit = 0;
    
  for (lvl_counter = constr_level; lvl_counter > level_limit; lvl_counter--)
  {
    first_constr = level_list[lvl_counter - 1];
    last_constr  = level_list[lvl_counter] - 1;

    constr_counter = first_constr;
    
    while ((constr_counter <= last_constr) && (!found_nxt_constr))  
    {
      next_lvl_constr = constr_list[constr_counter].constr_grid;

      stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, FALSE, 
                                                            &part_grid_1), 
                         targetid = next_lvl_constr.objid,
                         senderid = NULL_OBJID,
                         targetos = next_lvl_constr.osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);

      stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, TRUE, 
                                                            &part_grid_2), 
                         targetid = curr_constr.objid,
                         senderid = NULL_OBJID,
                         targetos = curr_constr.osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);
      
      if ((part_grid_1.objid == part_grid_2.objid) &&
          (part_grid_1.osnum == part_grid_2.osnum))
      {
        stat_OM = om$send (msg = 
                           message EMinstance.EMget_reversible_constr(&msg_loc, 
                            next_lvl_constr, 
                            &num_reversible_constr, reversible_constr), 
                            senderid = NULL_OBJID,
                            targetid = part_grid_1.objid,
                            targetos = part_grid_1.osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);

        for (counter = 0; counter < num_reversible_constr; counter++)
        {
          if ((reversible_constr[counter].objid == curr_constr.objid) &&
              (reversible_constr[counter].osnum == curr_constr.osnum))
          {
            constr_path[(*pconstr_path_len)] = constr_counter;
            (*pconstr_path_len)++;
            curr_constr = next_lvl_constr;
            found_nxt_constr = TRUE;
            break;
          }
        }          
      }
      constr_counter++;
    }
    if (!found_nxt_constr)
    {
      EMerr_hndlr (TRUE, status, EMS_E_Fail, ret_end); 
    }
    else
      found_nxt_constr = FALSE;
  }
ret_end:
  EMWRAPUP (status, status, "EMmake_path");
  return (status);
}

end implementation EMconstr;
