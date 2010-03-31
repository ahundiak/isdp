/*
  ABSTRACT

  Given an array of 'ptvars', this function finds the geometry that is common
  to ALL of them in the list and returns it as 'geomid'. On not finding one 
  fitting this criterion, it returns a NULL_OBJID. Obviously, atleast two
  ptvars are necessary for this function to be meaningful.


  CAVEATS
 
  This function is based on the assumption that all ptvars will have at most
  2 geometries attached to them. If an input ptvar has more than 2 geometries
  associated with it an arbitrary set of 2 out of them is chosen to drive
  the algorithm.
*/

class implementation SKptvar;

#include <alloca.h>
#include "OMmacros.h"

#define FIRST  0
#define SECOND 1

void SKgetcommgeom (num_ptvars, ptvars, os, geomobj)
IGRint num_ptvars;
GRobjid *ptvars;
GRspacenum os;
GRobjid *geomobj;
{
  IGRboolean found=FALSE;
  IGRint i, j, k, stat_func=TRUE, num_first_vargeoms, num_vargeoms;
  IGRlong msg_loc=EMS_S_Success;
  GRobjid vargeoms[2], first_vargeoms[2];

  *geomobj = NULL_OBJID;

  EMerr_hndlr (num_ptvars < 2, msg_loc, EMS_E_InvalidArg, wrapup);

  first_vargeoms[FIRST] = first_vargeoms[SECOND] = NULL_OBJID;
  SKgetptvargeoms (&msg_loc, ptvars[FIRST], os, 2, 
   &num_first_vargeoms, first_vargeoms);

  for (i=1; i<num_ptvars; i++)
  {
    vargeoms[FIRST] = vargeoms[SECOND] = NULL_OBJID;
    SKgetptvargeoms (&msg_loc, ptvars[i], os, 2, 
     &num_vargeoms, vargeoms);

    if (!IF_NULL_OBJID (*geomobj))
    {
      for (j=0, found=FALSE; j<num_vargeoms && !found; j++)
        if (vargeoms[j] == *geomobj)
          found = TRUE;

      EMerr_hndlr (!found, msg_loc, EMS_I_NotFound, wrapup);
    }
    else
    {
      for (j=0, found=FALSE; j<num_first_vargeoms && !found; j++)
        for (k=0; k<num_vargeoms && !found; k++)
          if (first_vargeoms[j] == vargeoms[k])
          {
            found = TRUE;
            *geomobj = first_vargeoms[j];
          }

      EMerr_hndlr (!found, msg_loc, EMS_I_NotFound, wrapup);
    }  
  }
  
wrapup:
  EMWRAPUP (msg_loc, stat_func, "SKgetcommgeom");
  return;
}

end implementation SKptvar;
