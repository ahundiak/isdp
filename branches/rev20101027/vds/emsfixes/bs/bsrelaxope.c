/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSrelaxope

Abstract
    This function accepts two vectors and returns their cross product.

Synopsis
void BSrelaxope(
IGRdouble *xmpntj2,
IGRdouble *xmpntj1,
IGRdouble *xmpntj,
IGRdouble *xnorm,
IGRdouble *xppntj2,
IGRdouble *xppntj1,
IGRdouble prec,
IGRdouble *xppntj,
BSrc   *rc)

Description
    See pseudo code.

Return Values
    BSSUCC is returned if all is successful.

Notes

Index
    ot

Keywords

History
   JJ Malosse 11 February 1999.

*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
# include "bstypes.h"
# include "bserr.h"
#endif

#include <math.h>

void BSrelaxope(
IGRdouble *xmpntj2,
IGRdouble *xmpntj1,
IGRdouble *xmpntj,
IGRdouble *xnorm,
IGRdouble *xppntj2,
IGRdouble *xppntj1,
IGRdouble prec,
IGRdouble *xppntj,
BSrc   *rc)
{
#ifndef DONOTSPROTO
  #include "bscrossp.h"
#endif

IGRdouble x,d,a12,a22,alpha12,alpha22,prec2;
IGRdouble a1[3],a2[3],alpha1[3],alpha2[3],a[2],vect[3];
IGRint nd;
IGRboolean status;

*rc = BSSUCC;

for (nd=0;nd<3;nd++)
   a1[nd] = xmpntj[nd] - xmpntj1[nd];

for (nd=0;nd<3;nd++)
   a2[nd] = xmpntj1[nd] - xmpntj2[nd];

for (nd=0;nd<2;nd++)
   a[nd] = xppntj1[nd] - xppntj2[nd];

/*   Computation of alpha1 and alpha2   */

x = 0.0;
for (nd=0;nd<3;nd++)
   x = x + a1[nd] * xnorm[nd];

for (nd=0;nd<3;nd++)
   alpha1[nd] = a1[nd] - x * xnorm[nd];

x = 0.0;
for (nd=0;nd<3;nd++)
   x = x + a2[nd] * xnorm[nd];

for (nd=0;nd<3;nd++)
   alpha2[nd] = a2[nd] - x * xnorm[nd];

a12 = 0.0;
for (nd=0;nd<3;nd++)
   a12 = a12 + a1[nd] * a1[nd];

prec2 = prec * prec;
a22 = 0.0;
for (nd=0;nd<3;nd++)
   a22 = a22 + a2[nd] * a2[nd];

if (a22 <= prec2)
{
   *rc = BSINARG;
   goto wrapup;
}

alpha12 = 0.0;
for (nd=0;nd<3;nd++)
   alpha12 = alpha12 + alpha1[nd] * alpha1[nd];

if (alpha12 <= prec2)
{
   *rc = BSINARG;
   goto wrapup;
}

alpha22 = 0.0;
for (nd=0;nd<3;nd++)
   alpha22 = alpha22 + alpha2[nd] * alpha2[nd];

if (alpha22 <= prec2)
{
   *rc = BSINARG;
   goto wrapup;
}

d = a22 * alpha12 * alpha22;
d = a12/d;
d = sqrt(d);

x = 0.0;
for (nd=0;nd<3;nd++)
   x = x + alpha1[nd] * alpha2[nd];

x = x * d;

for (nd=0;nd<2;nd++)
   xppntj[nd] = x * a[nd];

status = BScrossp(rc,alpha1,alpha2,vect);
if (*rc != BSSUCC) goto wrapup;

x = 0.0;
for (nd=0;nd<3;nd++)
   x = x + vect[nd] * xnorm[nd];

x = x * d;
xppntj[0] = xppntj[0] + xppntj1[0] + x * a[1];
xppntj[1] = xppntj[1] + xppntj1[1] - x * a[0];

wrapup:
if(BSERROR(*rc)) BSdbgrc(*rc,"BSrelaxope");
    return;

}
