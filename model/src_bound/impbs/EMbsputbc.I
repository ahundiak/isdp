/* ###################   APOGEE COMPILED   ################## */
/*
   ABSTRACT:

    The purpose of this method is to provide a flexible means of "posting"
    the edges geometry. The input is in a B-spline format. If the edge is
    internally represented as a line-string, the input is first
    converted to a compatible format (polyline) using the appropriate 
    chord-height tolerance. Thus geometry may be inserted into the existing
    geometry at any place. This method is intended to be the reverse of
    "EMgetbcgeom". But restrictions apply.

    This method is applicable only on those edges that fulfil the following
    criteria:
    i) It is not a part-edge or a natural-edge,
    ii) No part-edge is connected to it,
    iii) The geometry to be added will not cause the edge to cross the
         uv-domain fo the surface.

    Geometry may be inserted anywhere in the existing geometry by
    specifying the span ("from_spaninx") soon after which the insertion
    is to take place. If the reverse flag is set, "from_spaninx" applies
    to the reversed edge and the input geometry is inserted in the
    reverse order. The simplest way to think about this is to visual this
    method as a negation of the "get" method. If the "get" method
    were to actually remove from the edge, the geometry that it was 
    returning, then calling this method with the same arguments
    (from_spaninx and reverse) and the "got" geometry, would neutralize
    the effect.
 

    The following method for now ignores the span index since the bspline edge
    has only one span

   HISTORY:

   02/12/89 : rlw : Modified to check to ensure that the knot count is
                    correct.  If it is not then getbcgeom will return
                    corrupted geometry.

   06/04/93  Sudha  modified to include BSprototype header files

*/

class implementation EMSbsedge;

#include "EMS.h"
#include "OMmacros.h"
#include "bserr.h"
#include "emsmacros.h"
#include "bsrev_cv.h"

method EMputbcgeom (IGRlong *EMmsg; IGRint from_spaninx; 
                    IGRboolean reverse;
                    struct IGRbsp_curve *inbcgeom)
{
  
  IGRshort	i;
  IGRlong 	status;
  BSrc		rc;

  *EMmsg = EMS_S_Success;
  status = OM_S_SUCCESS;

  if ((inbcgeom->order + inbcgeom->num_poles) != inbcgeom->num_knots)
   {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
   }

  if ((!reverse && (ME.EMSedge->ed_props & EMED_REVERSED)) ||
      (reverse  && !(ME.EMSedge->ed_props & EMED_REVERSED)))
  {
    BSrev_cv (&rc, inbcgeom);
    EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);
  }

  ME.EMSbsedge->order = inbcgeom->order;
  ME.EMSbsedge->num_poles = inbcgeom->num_poles;
  ME.EMSbsedge->bs_props = 0;
  if (inbcgeom->periodic) ME.EMSbsedge->bs_props |= EMBS_PERIODIC;
  if (inbcgeom->non_uniform) ME.EMSbsedge->bs_props |= EMBS_NON_UNIFORM;
  if (inbcgeom->rational) ME.EMSbsedge->bs_props |= EMBS_RATIONAL;
  if (inbcgeom->phy_closed) ME.EMSedge->ed_props |= EMED_XYZ_CLOSED;

 {
  IGRlong	current_size, future_size;
  IGRdouble	*double_ptr;

  double_ptr = NULL;

  current_size = OM_DIMENSION_OF(ME.EMSbsedge->packed_doubles);
  future_size = (inbcgeom->num_poles)*(inbcgeom->rational ? 3 : 2) +
                ((inbcgeom->non_uniform || inbcgeom->periodic) ?
                 inbcgeom->num_knots : 0);  
  if (future_size > current_size)
    OM_SET_DIMENSION(ME.EMSbsedge->packed_doubles, future_size);

  double_ptr = &ME.EMSbsedge->packed_doubles[0];
  for (i=0 ; i<inbcgeom->num_poles; i++)
  {
    double_ptr[2*i] = inbcgeom->poles[3*i];
    double_ptr[2*i + 1] = inbcgeom->poles[3*i + 1];
  }

  double_ptr += inbcgeom->num_poles * 2;

/*
 * Fix the weights
 */

  if (inbcgeom->rational)
  {
   OM_BLOCK_MOVE (inbcgeom->weights, double_ptr, inbcgeom->num_poles *
                                                 sizeof (IGRdouble));
   double_ptr += inbcgeom->num_poles;
  }

/*
 *
 * Fix the knots
 */

  if (inbcgeom->non_uniform || inbcgeom->periodic)
   OM_BLOCK_MOVE (inbcgeom->knots, double_ptr, inbcgeom->num_knots *
                                               sizeof (IGRdouble));

 }
 
wrapup:
  EMWRAPUP ( *EMmsg, status,"In EMSbsedge:EMputbcgeom error");
  return (status);
}

end implementation EMSbsedge;
