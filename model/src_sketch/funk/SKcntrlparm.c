#include "igrtypedef.h"

IGRint    _vg_iter_limit = 30;
IGRdouble _vg_iter_tol = 0.0001;
IGRdouble _vg_dist_tol = 0.000001;
IGRdouble _vg_angle_tol = 0.001;

void SKgetiterpar (iterlim, itertol)
IGRint *iterlim;
IGRdouble *itertol;
{
  if (iterlim)
    *iterlim = _vg_iter_limit;
  if (itertol)
    *itertol = _vg_iter_tol;
  return;
}

void SKsetiterpar (iterlim, itertol)
IGRint *iterlim;
IGRdouble *itertol;
{
  if (iterlim)
    _vg_iter_limit = *iterlim;
  if (itertol)
    _vg_iter_tol = *itertol;
  return;
}

void SKgettol (distol, angtol)
IGRdouble *distol, *angtol;
{
  if (distol)
    *distol = _vg_dist_tol;
  if (angtol)
    *angtol = _vg_angle_tol;
  return;
}

void SKsettol (distol, angtol)
IGRdouble *distol, *angtol;
{
  if (distol)
    _vg_dist_tol = *distol;
  if (angtol)
    _vg_angle_tol = *angtol;
  return;
}
