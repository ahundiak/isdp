/*
  OVERVIEW

    This method returns TRUE if the edge is degenrate against a  given
    UV tolerance. The underlying fact here is not to classify the edge
    as degenerate depending on the  degenerate  bit  set on it, as one
    does not know which tolerance was used to  set the  bit.  So,  the
    system must be flexible enough to use it's own tolerances  for the
    geometry checks. This method provides such a flexibility.

*/

class implementation EMSptedge;

#include "EMS.h"
#include "OMmacros.h"

/*
  DESCRIPTION

    Returns TRUE (in is_degen field)  if this edge is degenerate as compared
    to input lentol.

  ARGUMENTS

    partinfo  - I - Partedge info, if it is known. Otherwise passin NULL.
    lentol    - I - The tolerance against which the edge geometry should be
                    tested to define the degenracy (UV tolerance of the surface)
    is_degen  - O - TRUE if the edge is degenrate otherwise FALSE

  RETURN CODE

    OM_S_SUCCESS - If success
    EMS_E_Fail   - If any failure

  NOTES

    None

  HISTORY

    06/05/95      Sanjay     Creation
*/

method EMisdegentol 
(
  struct EMSpartedinfo *partinfo;
  IGRdouble            lentol;
  IGRboolean           *is_degen
)
{
  *is_degen = TRUE;
  return OM_S_SUCCESS;
}

end implementation EMSptedge;
