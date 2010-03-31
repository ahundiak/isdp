/*
  OVERVIEW

    This method returns TRUE if the edge is degenrate against a  given 
    UV tolerance. The underlying fact here is not to classify the edge
    as degenerate depending on the  degenerate  bit  set on it, as one
    does not know which tolerance was used to  set the  bit.  So,  the 
    system must be flexible enough to use it's own tolerances  for the
    geometry checks. This method provides such a flexibility.

*/

class implementation EMSbsedge;

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
#incluee "alloca.h"

#include "PWminimum.h"
#include "PWapi/degengm.h"
#include "PWapi/bsputil.h"

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

  *is_degen = TRUE;

  if (partinfo)
  {
    struct IGRbsp_curve cv;
  
    memset (&cv, 0, sizeof (struct IGRbsp_curve));

    om$send (msg = message EMSedge.EMgetbcgeom (&msg, 0, 1, 
     ME.EMSedge->ed_props & EMED_REVERSED, partinfo, &cv, NULL, NULL),
     targetid = my_id);

    if (cv.weights)
      pwUnweightPoles (cv.num_poles, (PWpoint *) cv.poles, cv.weights,
       (PWpoint *) cv.poles);

    *is_degen = pwIsDegenPy (cv.num_poles, (PWpoint *) cv.poles, lentol);

    if (cv.poles)
      free (cv.poles);
    if (cv.weights)
      free (cv.weights);
    if (cv.knots)
      free (cv.knots);
  }
  else
  {
    IGRint     num_poles=0;
    IGRdouble  *p_poles=NULL, *p_wts=NULL;
    PWpoint2d  *p_unwtpoles=NULL;

    num_poles = ME.EMSbsedge->num_poles; 
    p_poles   = &ME.EMSbsedge->packed_doubles[0];
    p_wts     = ME.EMSbsedge->bs_props & EMBS_RATIONAL ? 
                 &ME.EMSbsedge->packed_doubles[2*num_poles] : NULL;

    if (p_wts)
    {
      p_unwtpoles = (PWpoint2d *) alloca (num_poles * sizeof (PWpoint2d));
      pwUnweightPoles2d (num_poles, (PWpoint2d *) p_poles, p_wts,
       (PWpoint2d *) p_unwtpoles);
    }
    else
    {
      p_unwtpoles = (PWpoint2d *) p_poles;
    }

    *is_degen = pwIsDegenPy2d (num_poles, (PWpoint2d *) p_unwtpoles, lentol);
  }

  return OMsts;
}

end implementation EMSbsedge;
    
