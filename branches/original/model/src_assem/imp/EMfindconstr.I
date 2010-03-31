
class implementation EMconstr;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "assemconstr.h"

from EMinstance import EMget_reversible_constr;

int Is_0_level;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMfind_overconstr                                                 |
 |                                                                           |
 | This message tries to find a path to underconstrained assembly. If such   |
 | a path cannot be found, it identifies the subset of assembly which is     |
 | overconstrained.                                                          | 
 |                                                                           |
 | Input:   IGRboolean first_direction Is it the first search direction.     |
 |                                                                           |
 | Output:  IGRlong *msg                Return code, MSSUC or MSFAIL for now |
 |          IGRint  *pnum_level	        # of search levels                   |
 |          IGRint  level_list[]	list of search levels                |
 |          IGRint  *pnum_constr	# of candidate constrs               |
 |          CANDIDATE_CONSTR constr_list[] list of candidate cnstrs          |
 |          IGRboolean *pisunderconstr TRUE if path to underconstrained assem|
 |                                                                           |
 +---------------------------------------------------------------------------*/

method EMfind_overconstr (
		   IGRlong             *msg;    	/* The return message OUT */
		   IGRboolean	       first_direction; /* is it 1st search direction */
                   IGRint	       *pnum_level;	/* # of search levels OUT */
                   IGRint	       level_list[];	/* list of search levels OUT */
                   IGRint              *pnum_constr;	/* # of candidate constrs OUT */
                   CANDIDATE_CONSTR    constr_list[];   /* list of candidate cnstrs OUT */
		   IGRboolean	       *pisunderconstr) /* TRUE if path to underconstrained assem*/
{
  IGRlong msg_loc, stat_OM;
  IGRboolean is_visited;
  IGRint current_level;
  IGRint first_constr, last_constr, constr_counter, counter;
  struct GRid part_grid;
  IGRint num_reversible_constr;
  struct GRid reversible_constr[MAX_INCIDENT_CONSTR];

  *pisunderconstr = FALSE;
    
  *pnum_level = 1;

  current_level = 0;
  if (first_direction)
     Is_0_level = TRUE;

  level_list[0] = *pnum_constr;  
    
  constr_list[(*pnum_constr)].constr_grid.objid = my_id;
  constr_list[(*pnum_constr)].constr_grid.osnum = OM_Gw_current_OS;  
  constr_list[(*pnum_constr)].from_part_kind = 0;    
  (*pnum_constr)++;

  stat_OM = OM_E_ABORT;  
  if ((*pnum_constr) >= MAX_CANDIDATE_CONSTR)
      EMerr_hndlr (EMSerror (EMS_F_Fail), *msg, EMS_F_Fail, ret_end);      

  level_list[1] = (*pnum_constr);

  stat_OM = om$send (msg = message EMconstr.EMmark_visited (&msg_loc, TRUE),
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  while (level_list[current_level] < level_list[current_level + 1])
  {
    first_constr = level_list[current_level];
    last_constr  = level_list[current_level + 1] - 1;
    
    for (constr_counter = first_constr; constr_counter <= last_constr; constr_counter++)
    {
      if ((current_level == 0) && (first_direction))
        stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, TRUE, 
            &part_grid), targetid = constr_list[constr_counter].constr_grid.objid,
                         targetos = constr_list[constr_counter].constr_grid.osnum);
      else
        stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, FALSE, 
            &part_grid), targetid = constr_list[constr_counter].constr_grid.objid,
                         targetos = constr_list[constr_counter].constr_grid.osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      
      if (part_grid.objid == NULL_OBJID)
      {
        num_reversible_constr = 0;
        constr_list[constr_counter].from_part_kind | = FROM_GROUND;
      }
      else
      {
        stat_OM = om$send (msg = message EMinstance.EMget_reversible_constr (&msg_loc, 
                           constr_list[constr_counter].constr_grid, 
                           &num_reversible_constr, reversible_constr), 
                            targetid = part_grid.objid,
                            targetos = part_grid.osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
        if (num_reversible_constr == 0)
        {
          constr_list[constr_counter].from_part_kind | = FROM_UNDER_CONSTR;
 	  *pisunderconstr = TRUE;
        }
      }  
      for (counter = 0; counter < num_reversible_constr; counter++)
      {
        stat_OM = om$send (
                    msg = message EMconstr.EMis_constr_visited (&msg_loc, &is_visited),
                    targetid = reversible_constr[counter].objid,
                    targetos = reversible_constr[counter].osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        if (! is_visited)
        {
          constr_list[(*pnum_constr)].constr_grid = reversible_constr[counter];
          constr_list[(*pnum_constr)].from_part_kind = 0;          
          (*pnum_constr)++;
        
          stat_OM = om$send (msg = message EMconstr.EMmark_visited (&msg_loc, TRUE),
                            targetid = reversible_constr[counter].objid,
                            targetos = reversible_constr[counter].osnum);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        
          if ((*pnum_constr) >= MAX_CANDIDATE_CONSTR)
            EMerr_hndlr (EMSerror (EMS_F_Fail), *msg, EMS_F_Fail, ret_end);      

        }
      }
    }
  
    ++current_level;
    Is_0_level = FALSE;
    
    if ((current_level + 1) >= MAX_SEARCH_LEVEL)
    {
        EMerr_hndlr (EMSerror (EMS_F_Fail), *msg, EMS_F_Fail, ret_end);      
    }
    level_list[current_level + 1] = (*pnum_constr);
  
  } 

  *pnum_level = current_level;
  Is_0_level = FALSE;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

ret_end:

  EMWRAPUP (*msg, stat_OM, "EMoverconstr");
  return (stat_OM);
}

end implementation EMconstr;
