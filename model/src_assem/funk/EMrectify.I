class implementation EMconstr;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "ASmessages.h"
#include "msmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "assemconstr.h"
#include "assemdef.h"
#include "assemmacros.h"

#include "ECcmd.h"
#include "ECmsg.h"

from EMinstance import EMupdatebasis;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Routine: EMrectify_asm()                                                  |
 |                                                                           |  
 | This routine propogates the causality of the newly added constraint to    |
 | underconstrained assembly.                                                |
 |                                                                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/

int EMrectify_asm(msg, num_level, level_list, constr_list, first_direction)
IGRlong *msg;                   /* return condition */
IGRint	       num_level;	/* # of search levels IN */
IGRint	       level_list[];	/* list of search levels IN */
CANDIDATE_CONSTR constr_list[]; /* list of candidate cnstrs IN */
IGRboolean first_direction;     /* is it 1st search direction */
{
  IGRlong status;
  struct GRid    last_constr;    /* the constr from underconstained part  */
  IGRint constr_level, constr_pos;
  IGRint constr_path_len;                   /* # of cosntraints in the path */
  IGRint constr_path[MAX_CANDIDATE_CONSTR]; /* The path to the underconstr assembly*/
  IGRboolean cycle_formed;

  *msg = EMS_S_Success;
    
  status = EMget_undercons(num_level, level_list, constr_list, &last_constr);
  EMerr_hndlr (EMSerror (status), status, EMS_E_Fail, ret_end);

  status =  EMfind_level(last_constr, num_level, level_list, constr_list, 
                         &constr_level, &constr_pos);
  EMerr_hndlr (EMSerror (status), status, EMS_E_Fail, ret_end);

  status =  EMmake_path(constr_level, level_list,  constr_pos, constr_list, 
                        first_direction, &constr_path_len, constr_path);
  EMerr_hndlr (EMSerror (status), status, EMS_E_Fail, ret_end);

  status =  EMreverse_path(constr_path_len, constr_path, 
                           constr_list, first_direction);
  EMerr_hndlr (EMSerror (status), status, EMS_E_Fail, ret_end);

  status =  EMchk_cycle(constr_path_len, constr_path, constr_list, &cycle_formed);
  EMerr_hndlr (EMSerror (status), status, EMS_E_Fail, ret_end);

  if (cycle_formed)
  {
    ex$message(msgnumb = EMS_S_CycleAssy);      

    status =  EMreset_path(constr_path_len, constr_path, constr_list);
    EMerr_hndlr (EMSerror (status), status, EMS_E_Fail, ret_end);

    *msg = ASM_E_STRONGCOMP;
  }

ret_end:
  EMWRAPUP (status, status, "EMrectify_asm");
  return (status);

}

end implementation EMconstr;
