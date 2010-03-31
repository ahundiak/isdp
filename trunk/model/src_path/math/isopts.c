#include <math.h>
#include "bsvalues.h"

#include "PWminimum.h"
#include "PWgmdata.h"

#include "PWapi/isopts.h"

PWboolean pwIsUvPtsIso
(
  int num_uvpts,
  PWpoint2d *p_uvpts,
  double uvtol,
  int *isodir
)
{
  int i=0;
  PWboolean iso=TRUE;
  double max_u=MINDOUBLE, min_u=MAXDOUBLE;
  double max_v=MINDOUBLE, min_v=MAXDOUBLE;

  for (i=0; i<num_uvpts; i++)
  {
     if(p_uvpts[i][U] > max_u) max_u = p_uvpts[i][U];
     if(p_uvpts[i][U] < min_u) min_u = p_uvpts[i][U];
     
     if(p_uvpts[i][V] > max_v) max_v = p_uvpts[i][V];
     if(p_uvpts[i][V] < min_v) min_v = p_uvpts[i][V];
  }

  if (fabs(max_u - min_u)<= uvtol)
  {
    *isodir = U;
    return TRUE;
  }
  else if (fabs(max_v - min_v)<=uvtol)
  {
    *isodir = V;
    return TRUE;
  }
  else
  {
    return FALSE;
  }
}

