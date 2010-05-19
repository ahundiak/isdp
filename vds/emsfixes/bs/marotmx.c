/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    MArotmx
Abstract
    This routine takes an axis of rotation defined by a
vector, and an angle of rotation and builds a matrix
which accomplishes the rotation about the axis.

Synopsis
    IGRboolean MArotmx(messg,n,theta,t)

    IGRlong   *messg
    IGRvector   n
    IGRdouble *theta
    IGRdouble *t

Description
    This routine inputs a vector defining an axis of rotation(n) and
an angle of rotation(theta, in radians).  It finds the rotation matrix 
about the axis(t).

Return Values
    MSSUCC is returned if all is successful.

Notes
    The vector defining the axis of rotation is a
non-zero vector in the direction of the axis of rotation.
    The matrix produced is a 3-d homogeneous matrix
ie it has 16 entries.

Index
    ma

Keywords

History
    RDH            01/08/85  : Creation date.
    S.G. Catron    06/15/89  : Changed header to new format.
    S.G. Catron    04/25/00  : Modified to call BSnorvec instead of MAunitvc and use sin(), cos()
                               instead of MAsincos.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "ma.h"
#include "bstypes.h" 
#include "msdef.h"
#endif

#include <math.h>

IGRboolean MArotmx(
IGRlong   *messg,          
IGRvector   n,               
IGRdouble *theta,            
IGRdouble *t)                
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#endif 
  MAvector  m;                                  /* unit vector of n          */

  IGRdouble n1sq,n2sq,n3sq;                    /* unit vector entries squared*/
  IGRdouble c,s;                                /* cosine and sine of theta  */
  IGRdouble c1;                                 /* one minus cosine          */

  BSrc rc;
  
  *messg = MSSUCC;
  m[0] = n[0];
  m[1] = n[1];
  m[2] = n[2];    

  if( BSnorvec(&rc,m) )                     /* make m = m/||m||          */
    {
      s = sin (*theta );
      c = cos (*theta );
      n1sq = m[0] * m[0];                   /* auxiliary constants?????  */
      n2sq = m[1] * m[1];
      n3sq = m[2] * m[2];
      c1 = 1.0 - c;
                                                /* calculate entries of t    */
      t[0] = n1sq + (1.0 - n1sq) * c;
      t[1] = m[0] * m[1] * c1 - m[2] * s;
      t[2] = m[0] * m[2] * c1 + m[1] * s;
      t[3] = 0.0;
      t[4] = m[0] * m[1] * c1 + m[2] * s;
      t[5] = n2sq + (1.0 - n2sq) * c;
      t[6] = m[1] * m[2] * c1 - m[0] * s;
      t[7] = 0.0;
      t[8] = m[0] * m[2] * c1 - m[1] * s;
      t[9] = m[1] * m[2] * c1 + m[0] * s;
      t[10]= n3sq + (1.0 - n3sq) * c;
      t[11]= 0.0;
      t[12]= 0.0;
      t[13]= 0.0;
      t[14]= 0.0;
      t[15]= 1.0;
    }
  else
    {
      *messg = MASDGENRAT;
    }

  if(!(*messg & 1))
      BSdbgrc(*messg,"MArotmx");
  return( *messg == MSSUCC );

}/* This has been an R.D.H. production!!! */
