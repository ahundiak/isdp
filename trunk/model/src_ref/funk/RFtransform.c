#include "igrtypedef.h"
#include "bserr.h"
#include "mainvmx.h"
#include "matypemx.h"
#include "madef.h"
#include "maoptsxfo.h"

IGRlong RFtransform
(
  IGRmatrix matrix,
  IGRshort mattyp,
  IGRshort inverse,
  IGRvector xvec,
  IGRvector yvec,
  IGRvector zvec,
  IGRpoint origin
)
{
  IGRshort dim=4, rotmxtyp=MAIDMX, invmxtyp=MAIDMX;
  IGRlong one=1;
  IGRmatrix rotmx, invmx;
  IGRvector tmpvec;
  IGRpoint tmppt;
  BSrc rc;

  if (mattyp != MAIDMX)
  {
    if(inverse)
    {
      MAinvmx( &rc, &dim, matrix, invmx);
      MAtypemx( &rc, invmx, &invmxtyp);
    }
    else
    {
      memcpy(invmx, matrix, sizeof(IGRmatrix));
      invmxtyp = mattyp;
    }

    memcpy(rotmx, invmx, sizeof(IGRmatrix));

    rotmx[3] = 0.0;
    rotmx[7] = 0.0;
    rotmx[11] = 0.0;
    rotmx[15] = 1.0;
    MAtypemx( &rc, rotmx, &rotmxtyp);

    if(xvec)
    {
      MAoptsxform( &rc, &one, &rotmxtyp, rotmx, xvec, tmpvec);
      if (!(1&rc)) goto wrapup;
      memcpy(xvec, tmpvec, sizeof(IGRvector));
    }

    if(yvec)
    {
      MAoptsxform( &rc, &one, &rotmxtyp, rotmx, yvec, tmpvec);
      if (!(1&rc)) goto wrapup;
      memcpy(yvec, tmpvec, sizeof(IGRvector));
    }

    if(zvec)
    {
      MAoptsxform( &rc, &one, &rotmxtyp, rotmx, zvec, tmpvec);
      if (!(1&rc)) goto wrapup;
      memcpy(zvec, tmpvec, sizeof(IGRvector));
    }

    if(origin)
    {
      MAoptsxform( &rc, &one, &invmxtyp, invmx, origin, tmppt);
      if (!(1&rc)) goto wrapup;
      memcpy(origin, tmppt, sizeof(IGRpoint));
    }
  }
wrapup:

  if(!(1&rc)) return(0);

  return(1);
}
   
IGRlong RFinverse_pts
(
  IGRmatrix matrix,
  int num_pts,
  IGRpoint *ptvals
)
{
    IGRshort dim=4, invmxtyp=MAIDMX;
    IGRmatrix invmx;
    BSrc rc;
 
    MAinvmx( &rc, &dim, matrix, invmx);
    if (!(1&rc)) goto wrapup;
 
    MAtypemx( &rc, invmx, &invmxtyp);
    if (!(1&rc)) goto wrapup;
 
    MAoptsxform ( &rc, (IGRlong *)&num_pts, &invmxtyp, invmx,
                  (IGRdouble *)ptvals[0],(IGRdouble *)ptvals[0]);
    if (!(1&rc)) goto wrapup;
wrapup:
  if(!(1&rc)) return(0);

  return(1);
}
