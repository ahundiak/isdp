class implementation EMconstr;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "emsdef.h"
#include "emserr.h"
#include "assemconstr.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Routine: EMunmark_constr()                                                |
 |                                                                           |  
 | This routine sets the "is_visited" flags to FALSE for the list of         |
 | candidate constraints generated during a BFS.                             |
 |                                                                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/

int EMunmark_constr(num_constr, constr_list)
IGRint num_constr; 		 /* # of candidate constrs */
CANDIDATE_CONSTR constr_list[];  /* list of candidate cnstrs */
{
  IGRint counter;
  IGRlong msg_loc, stat_OM, status;
    
  status = EMS_S_Success;
  
  for (counter = 0; counter < num_constr; counter++)
  {
    stat_OM = om$send (msg = message EMconstr.EMmark_visited (&msg_loc, FALSE),
                      senderid = NULL_OBJID,
                      targetid = constr_list[counter].constr_grid.objid,
                      targetos = constr_list[counter].constr_grid.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), status, EMS_E_Fail, ret_end);
  } 

ret_end:
  EMWRAPUP (status, status, "EMunmark_constr");
  return (status);

}

end implementation EMconstr;
