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
 | Routine: EMget_undercons()                                                |
 |                                                                           |  
 | This routine finds the first candidate constraint that emanates from an   |
 | underconstrained part.                                                    |
 |                                                                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/

int EMget_undercons(num_level, level_list, constr_list, pconstr_grid)
IGRint	       num_level;	/* # of search levels IN */
IGRint	       level_list[];	/* list of search levels IN */
CANDIDATE_CONSTR constr_list[]; /* list of candidate cnstrs IN */
struct GRid    *pconstr_grid;	/* the constr from underconstained part OUT */
{
  IGRint first_constr, last_constr, constr_counter, lvl_counter;
  
  for (lvl_counter = num_level; lvl_counter > 0; lvl_counter--)
  {
    first_constr = level_list[lvl_counter - 1];
    last_constr  = level_list[lvl_counter] - 1;
    
    for (constr_counter = first_constr; constr_counter <= last_constr;
                                                             constr_counter++)
      if (constr_list[constr_counter].from_part_kind & FROM_UNDER_CONSTR)
      {
        *pconstr_grid = constr_list[constr_counter].constr_grid;
        return(EMS_S_Success);          
      }    
  } 
  (*pconstr_grid).objid = NULL_OBJID;
  return(EMS_F_Fail);  
}

end implementation EMconstr;
