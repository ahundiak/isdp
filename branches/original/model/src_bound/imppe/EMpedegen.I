/*
  OVERVIEW

    This method returns TRUE if the edge is degenrate against a  given
    UV tolerance. The underlying fact here is not to classify the edge
    as degenerate depending on the  degenerate  bit  set on it, as one
    does not know which tolerance was used to  set the  bit.  So,  the
    system must be flexible enough to use it's own tolerances  for the
    geometry checks. This method provides such a flexibility.

*/

class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "EMSbnd.h"

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
  
    06/05/95     Sanjay     Creation
*/

method EMisdegentol
(
  struct EMSpartedinfo *partinfo;
  IGRdouble            lentol;
  IGRboolean           *is_degen
)
{
  IGRlong         OMsts=OM_S_SUCCESS;
  OM_S_CHANSELECT to_edge;


  /* 
   * If a NULL pointer was passed for bnd, it means I have to send down my
   * geometry. If the pointer is non NULL then it means that somebody up
   * there is trying hard to reach its geometry and I need to help by acting
   * as a passon.
   */
  OMsts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edge);
  if(!(1&OMsts)) goto wrapup;

  if (partinfo)
    OMsts = om$send (msg = message EMSedge.EMisdegentol (partinfo, lentol, 
                                   is_degen),
                     p_chanselect = &to_edge);
  else
  {
    struct EMSpartedinfo my_info;

    EMput_partinfo (my_info);
    OMsts = om$send (msg = message EMSedge.EMisdegentol (&my_info, lentol, 
                                   is_degen),
                     p_chanselect = &to_edge);
  }    

wrapup:

  EMWRAPUP(OMsts,OMsts,"EMSpartedge.EMisdegentol")
  return (OMsts);
}

end implementation EMSpartedge;
