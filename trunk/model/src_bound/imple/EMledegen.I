/*
  OVERVIEW

    This method returns TRUE if the edge is degenrate against a  given 
    UV tolerance. The underlying fact here is not to classify the edge
    as degenerate depending on the  degenerate  bit  set on it, as one
    does not know which tolerance was used to  set the  bit.  So,  the 
    system must be flexible enough to use it's own tolerances  for the
    geometry checks. This method provides such a flexibility.

*/

class implementation EMSlinedge;

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
#include "PWgmdata.h"
#include "PWapi/mdstptgm.h"
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
 
    06/05/95     Sanjay     Creation

*/


method EMisdegentol
(
  struct EMSpartedinfo  *partinfo;
  IGRdouble             lentol;
  IGRboolean            *is_degen 
)
{
  IGRlong      OMsts=OM_S_SUCCESS;
 
  IGRint       num_pts=0, inx=0, inx1=0, inx2=0, size=0; 
  double       pt1[2], pt2[2], par1=0, par2=0;
  IGRdouble    *p_pts=NULL, cumdist=0;

  *is_degen = TRUE;
  size      = 2 * sizeof (IGRdouble);

  if (partinfo)
  {
    if (partinfo->edbdry[0].span_inx + partinfo->edbdry[0].param < 
        partinfo->edbdry[1].span_inx + partinfo->edbdry[1].param)
    {
      inx1 = partinfo->edbdry[0].span_inx;
      par1 = partinfo->edbdry[0].param;
      inx2 = partinfo->edbdry[1].span_inx;
      par2 = partinfo->edbdry[1].param;
    }
    else
    {
      inx1 = partinfo->edbdry[1].span_inx;
      par1 = partinfo->edbdry[1].param;
      inx2 = partinfo->edbdry[0].span_inx;
      par2 = partinfo->edbdry[0].param;
    }

    num_pts = inx2 - inx1;
    p_pts = num_pts ? &ME.EMSlinedge->points[(inx1+1)*2] : NULL;
  }
  else
  { 
    num_pts = ME.EMSlinedge->num_points;
    p_pts   = ME.EMSlinedge->points;
  }

  for (inx=0; inx<num_pts-1; inx++)
  {
    memcpy (pt1, &p_pts[inx*2], size);
    memcpy (pt2, &p_pts[(inx+1)*2], size);

    cumdist += pwDistPtPt2d (pt1, pt2);
    if (cumdist > lentol)
    {
      *is_degen = FALSE;
      goto wrapup;
    }
  }

  if (partinfo) 
  {
    IGRint     i,nseg=0;
    IGRdouble  *p_tpts=NULL;

    p_tpts = ME.EMSlinedge->points;
    inx = inx1*2;

    for (nseg=0; nseg < (num_pts ? 2 : 1); nseg++)
    {
      for (i=0; i<2; i++)
        pt1[i] = p_tpts[inx+i] + (nseg? par2:par1) * 
                 (p_tpts[inx+2+i] - p_tpts[inx+i]);

      inx = inx2 * 2;

      if (!num_pts)
      {
        for (i=0; i<2; i++)
          pt2[i] = p_tpts[inx+i] + par2 * (p_tpts[inx+2+i] - p_tpts[inx+i]);
      }
      else
      {
        memcpy (pt2, nseg ? &p_pts[(num_pts-1)*2] : p_pts, size);
      }
  
      cumdist += pwDistPtPt2d (pt1, pt2);
      if (cumdist > lentol)
      {
        *is_degen = FALSE;
        break;
      }
    }
  }

wrapup :

  return OMsts;
}

end implementation EMSlinedge;
    
