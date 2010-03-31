class implementation EMSbsedge;

#include "OMminimum.h"
#include "OMmacros.h"

method EMpostgeom
(
  IGRchar *edgeom
)
{
  int size=0, cnt=0, inx=0;
  struct IGRbsp_curve *p_cv=NULL;
  double *p_ptr=NULL;

  p_cv = (struct IGRbsp_curve *) edgeom;

  ME.EMSedge->ed_props = 0;
 
  ME.EMSbsedge->num_poles = p_cv->num_poles; 
  ME.EMSbsedge->order = p_cv->order; 
  ME.EMSbsedge->bs_props = 0;
  if (p_cv->periodic) ME.EMSbsedge->bs_props |= EMBS_PERIODIC;
  if (p_cv->non_uniform) ME.EMSbsedge->bs_props |= EMBS_NON_UNIFORM;
  if (p_cv->rational) ME.EMSbsedge->bs_props |= EMBS_RATIONAL;
  if (p_cv->phy_closed) ME.EMSbsedge->bs_props |= EMED_XYZ_CLOSED;

  size = (p_cv->num_poles * (p_cv->rational ? 3 : 2)) +
         ((p_cv->non_uniform || p_cv->periodic) ? p_cv->num_knots : 0);
  OM_SET_DIMENSION (ME.EMSbsedge->packed_doubles, size);

  p_ptr = ME.EMSbsedge->packed_doubles;

  for (cnt=0; cnt<p_cv->num_poles; cnt++)
  {
    p_ptr [cnt*2] = p_cv->poles[cnt*3];
    p_ptr [cnt*2+1] = p_cv->poles[cnt*3+1];
  }

  inx = p_cv->num_poles*2;

  if (p_cv->rational)
  {
    OM_BLOCK_MOVE (p_cv->weights, &p_ptr[inx], p_cv->num_poles * 
                   sizeof (double));
    inx += p_cv->num_poles;
  }

  if (p_cv->non_uniform || p_cv->periodic)
  {
    OM_BLOCK_MOVE (p_cv->knots, &p_ptr[inx],  p_cv->num_knots *
                   sizeof (double));
  }

  return (OM_S_SUCCESS);
}

end implementation EMSbsedge;

