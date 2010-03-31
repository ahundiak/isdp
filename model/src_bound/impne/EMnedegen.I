/*
  OVERVIEW

    This method returns TRUE if the edge is degenrate against a  given 
    UV tolerance. The underlying fact here is not to classify the edge
    as degenerate depending on the  degenerate  bit  set on it, as one
    does not know which tolerance was used to  set the  bit.  So,  the 
    system must be flexible enough to use it's own tolerances  for the
    geometry checks. This method provides such a flexibility.

*/

class implementation EMSnatedge;

#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdef.h"
#include "EMS.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emserr.h"
#incluee "EMSbnddef.h"
#incluee "EMSbnd.h"
#incluee "EMSprop.h"

#include "PWminimum.h"
#include "PWapi/degengm.h"

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

    06/05/95     Sanjay       Creation 
*/

method EMisdegentol
(
  struct EMSpartedinfo  *partinfo;
  IGRdouble             lentol;
  IGRboolean            *is_degen 
)
{
  IGRlong OMsts=OM_S_SUCCESS, msg=EMS_S_Success; 
  struct IGRpolyline poly;
  IGRdouble pts[4];

  poly.num_points = 0;
  poly.points = &pts[0];

  OMsts = om$send (msg = message EMSedge.EMgetpygeom (&msg, 0, 1, 
                                 ME.EMSedge->ed_props & EMED_REVERSED, 
                                 partinfo, &poly, NULL, NULL),
                   targetid = my_id);
  EMerr_hndlr (!(1&OMsts&msg), OMsts, EMS_E_Fail, wrapup);

  *is_degen = pwIsDegenPy2d (poly.num_points, (PWpoint2d *) poly.points, 
                             lentol);
wrapup :

  return OMsts;
}

end implementation EMSnatedge;
    
