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
 | Routine: EMfind_level()                                                   |
 |                                                                           |  
 | This routine determines the search level at which the given constraint    |
 | was encountered.                                                          |
 |                                                                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/

int EMfind_level(constr_grid, num_level, level_list, 
                  constr_list, pconstr_level, pconstr_pos)
struct GRid    constr_grid;     /*  The given constr grid */
IGRint	       num_level;	/* # of search levels IN */
IGRint	       level_list[];	/* list of search levels IN */
CANDIDATE_CONSTR constr_list[]; /* list of candidate cnstrs IN */
IGRint	       *pconstr_level;	/* search level of constr OUT */
IGRint	       *pconstr_pos;	/* position in constr list OUT */

{
  IGRint first_constr, last_constr, constr_counter, lvl_counter;
  
  for (lvl_counter = num_level; lvl_counter > 0; lvl_counter--)
  {
    first_constr = level_list[lvl_counter - 1];
    last_constr  = level_list[lvl_counter] - 1;
    
    for (constr_counter = first_constr; constr_counter <= last_constr; 
                                                                    constr_counter++)
    {
      if ((constr_grid.objid == constr_list[constr_counter].constr_grid.objid) &&
          (constr_grid.osnum == constr_list[constr_counter].constr_grid.osnum))
      {
        *pconstr_pos = constr_counter;
        *pconstr_level = lvl_counter - 1;
        return(EMS_S_Success);
      }
    }
  } 

  *pconstr_pos = NULL_CONSTR_POS;
  *pconstr_level = NULL_LEVEL;

  return(EMS_F_Fail);  
}

end implementation EMconstr;
