
class implementation EMconstr;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "assemdef.h"
#include "assemconstr.h"
#include "malloc.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMprocess_constr_addition                                         |
 |                                                                           |
 | This method is called to process the addition of a assembly constraint.   |
 | The method implements the concept of the initial "master"/"slave"         |
 | labelling specified by the User.                                          |
 |                                                                           |
 | An attempt is made to preserve the intial causality of the                |
 | new constraint by looking for underconstrained assembly in the            |
 | direction of the causality of the constraint.                             |
 |                                                                           |
 | If none can be found, the causality of the constraint is reversed         |
 | and a search for underconstrained assembly is done in the opposite        |
 | direction.                                                                |
 |                                                                           |
 | if none can be found, the overconstrained assembly is highlighted.        |
 |                                                                           |
 |                                                                           |
 | Input:                  	                                             |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          IGRint *pnum_conflconstr  If overconstrained, the number of      |
 |                                     conflicting constrs                   |
 |          struct GRid **ppconflconstr_grid  If overconstrained, conflicting|
 |                                            constrs                        |
 |                                                                           |
 +---------------------------------------------------------------------------*/

method EMprocess_constr_addition (IGRlong *msg; IGRint *pnum_conflconstr;
                                  struct GRid **ppconflconstr_grid)     
{
  IGRlong msg_loc, stat_OM, status;
  IGRint num_level_1;		        /* # of search levels in first direction */
  IGRint level_list_1[MAX_SEARCH_LEVEL];/* list of search levels in 1st direction */
  IGRint num_level_2;			/* # of search levels in 2nd direction */
  IGRint level_list_2[MAX_SEARCH_LEVEL];/* list of search levels in 2nd direction */
  IGRint num_constr; 			/* # of candidate constrs */
  CANDIDATE_CONSTR constr_list[MAX_CANDIDATE_CONSTR];/* list of candidate cnstrs */
  IGRboolean isunderconstr_1, isunderconstr_2;
  IGRint counter;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  num_constr = 0;

  /* Initialise the output - 05/03/94 */
  *pnum_conflconstr = 0;
  *ppconflconstr_grid = NULL;

  stat_OM = om$send (msg = message EMconstr.EMfind_overconstr (&msg_loc, 
  TRUE, &num_level_1, level_list_1, &num_constr, constr_list, 
  &isunderconstr_1), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if ( ! isunderconstr_1)
  {
    stat_OM = om$send (msg = message EMconstr.EMfind_overconstr (&msg_loc,  
    FALSE,  &num_level_2, level_list_2, &num_constr, constr_list, &isunderconstr_2),
    targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    if (! isunderconstr_2)
    {
      struct GRid *pgrid;
      
      *ppconflconstr_grid = (struct GRid *) 
                            malloc (num_constr * sizeof (struct GRid));

      pgrid =  *ppconflconstr_grid;
      *pnum_conflconstr = 0;
      for (counter = 0; counter < num_constr; counter++)
      {
         if (counter != level_list_2[0])
         { 
           *pgrid = constr_list[counter].constr_grid;
           pgrid++;
           ++(*pnum_conflconstr); 
         }
      }    

      *msg = ASM_E_OVERCONSTRAINED;
    }
    else
    {
      status = EMrectify_asm(msg, num_level_2, level_list_2, 
                             constr_list, FALSE);
      EMerr_hndlr (EMSerror (status), *msg, EMS_E_Fail, ret_end); 
    }
  }
  else
  {
    status = EMrectify_asm(msg, num_level_1, level_list_1, constr_list, TRUE);
    EMerr_hndlr (EMSerror (status), *msg, EMS_E_Fail, ret_end); 
  }
    
ret_end:

  status = EMunmark_constr(num_constr, constr_list);
  EMerr_hndlr (EMSerror (status), *msg, EMS_E_Fail, ret_end);

  if ((*msg == ASM_E_OVERCONSTRAINED) ||(*msg == ASM_E_STRONGCOMP)) 
  {
    EMWRAPUP (status, stat_OM, "EMconstradd");
  }
  else
  {
    EMWRAPUP (*msg, stat_OM, "EMconstradd");
  }
  return (stat_OM);
}

end implementation EMconstr;
