/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSsfpllgcln

Abstract
    Given all intersection curves found from Bezier patch, this routine
    removes duplicated intersection curve, returns merged 3D curves and
    2D composite curves.

Synopsis

void BSsfpllgcln(
IGRint npoleu,
IGRint npolev,
IGRint ndegu,
IGRint ndegv,
IGRdouble *surface,
IGRdouble *uknots,
IGRdouble *vknots,
IGRint nsegment,
IGRint *ndeg2bag,
IGRint *irat2bag,
IGRdouble **cv2lgdbag,
IGRdouble *uvstart,
IGRdouble *uvend,
IGRint *ndeg3bag,
IGRint *irat3bag,
IGRdouble **cv3lgdbag,
IGRdouble *ptstart,
IGRdouble *ptend,
IGRint *pindexu,
IGRint *pindexv,
IGRdouble prec,
IGRdouble *xyminmax,
IGRint *nbranch,
IGRint **ncvsbrch,
IGRint ***ndeg2tab,
IGRint ***irat2tab,
IGRdouble ****cv2lgd,
IGRint ***ndeg3tab,
IGRint ***irat3tab,
IGRdouble ****cv3lgd,
BSrc *rc)

Description
    Input :

npoleu: Number of poles in $u$ of the B-spline surface.
npolev: Number of poles in $v$ of the B-spline surface.
ndegu: Degree in $u$ of the B-spline surface.
ndegv: Degree in $v$ of the B-spline surface.
iratp: Says if the surface is pure rational or not.
surface(npoleu,npolev,2+iratp): The surface.
uknots(npoleu+ndegu+1): The knot vector along $u$.
vknots(npolev+ndegv+1): The knot vector along $v$.
nsegment: The total number of curves found.
ndeg2bag(nsegment): The degree of the parametric curves
in Legendre basis
irat2bag(nsegment): 0,non-rational. 1, rational in $u$.
2, rational in $v$. 3 rational in $u,v$.
**cv2lgdbag[nsegment](0:ndegtab(),2+?)}
The coefficients of
the parametric curves in Legendre basis.
uvstart(2,m): being the start parameters of the $(u,v)$ curve.
uvend(2,m): being the end parameters of the $(u,v)$ curve.
ndeg3bag(nsegment): The degree of the space curves
in Legendre basis.
irat3bag(nsegment): 0, polynomial. 1, pure rational.
**cv3lgdbag[nsegment](0:ndegtab(),2+irat3tab() )}
The coefficients of
the space curves in Legendre basis.
ptstart(2,m): being the start parameters of the $(u,v)$ curve.
ptend(2,m): being the end parameters of the $(u,v)$ curve.
uknotbez(2,nintcvs): Starting and ending
$u$ parameters for the Bézier patch where the
intersection curve is located.
vknotbez(2,nintcvs): Starting and ending
$v$ parameters for the Bézier patch where the
intersection curve is located.
prec: The tolerance.
1, Second time intersection with \fortran{prec / 1000}.
xyminmax(2,2): Box in x,y set to NULL if no box.

Output

nbranch: The number of intersection curves.
ncvsbrch(nbranch): The number of curves in each group (Legendre arcs)
ndeg2dtab(ncvsbrch();nbranch): (Triple pointer)
The degree of the parametric curves
in Legendre basis
irat2dtab(ncvsbrch();nbranch): (Triple pointer)
0,non-rational. 1, rational in $u$.
2, rational in $v$. 3 rational in $u,v$.
cv2dlgd[0:ndegtab(),ndim;ndegtab(ncvsbrch();ngroups)]:(Quadruple pointer)
The coefficients of
the parametric curves in Legendre basis. \fortran{ndim = 2}
if \fortran{rattab() = 0}, \fortran{ndim = 3: if \fortran{rattab{: =1,2}.
\fortran{ndim = 4: if \fortran{rattab{: = 3}.
ndeg3dtab(ncvsbrch();nbranch): (Triple pointer)
The degree of the space curves
in Legendre basis.
irat3dtab(ncvsbrch();nbranch): (Triple pointer) 0,polynomial
non-rational. 1, pure rational.
cv3dlgd[0:ndegtab(),2+irat3dtab();ndegtab(ncvsbrch();ngroups)]}
(Quadruple pointer)
The coefficients of the space curves in Legendre basis.

Return Values
    If successful then a message BSSUCC, is returned, else an appropriate 
    error message is returned.

Notes
    

Index
    lg

Keywords

History
    Vivian Y. Hsu          01/20/1998  : Creation Data.
                                         Modified from last part of code
                                         of BSsfplintlg.
   JJ Malosse 12 August 1999: Deep reshaffle.
JJ Malosse 27 December 1999: Added an argument to know if the process is
partial.
JJ Malosse 14 February 2000: Changed BSlnkcvgrph to 2 eps (loops)
JJ Malosse 17 February 2000: Changed argument from I/O to input only.
JJ Malosse 28 March 2000: Handled curves in boxes.
JJ Malosse 25 September 2000: Handle self intersections at corner.
JJ Malosse 27 October 2000: Cuts when curve on boundary and not iso.
JJ Malosse 06 November 2000: Define explicitly loop (get bigger array).
JJ Malosse 06 December 2000: Handles true isolated points at the middle.
JJ Malosse 16 December 2000: Handles of self intersections.
JJ Malosse 18 December 2000: Fix bugs w.r.t. the parameters.
	Vivian Y. Hsu 01/09/01 : Changed if to else if in determine for u,v knots line.
	                         Because it either be u knot line or v knot line.
						     It cannot be both only if it is a point, 
							 then we should not count it twice.

***************************************************************************
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bs.h"
#include "bsmalloc.h"
#include "bsstackalloc.h"
#include "bsmemory.h"
#include "bsstk.h"
#include "bsplpchlgd.h"
#endif

#include <math.h>
#define BSVOID
#define KEEP 100000
#define REMOVE 20000
#define BSMAXDEG 127
  

/* Renormalisation of u,v.   */

/*
    Input :

ndeg: Degree of the parametric curve.
iratp: Says if the curve has a denominator.
uknots(2): Start and end u knot for the Bézier surface.
vknots(2): Start and end v knot for the Bézier surface.

Input/Output

uvstart(2); The $(u,v)$ at start.
uvend(2); The $(u,v)$ at end.
*uvlgd(0:ndeg,ndim):
The coefficients of
the parametric curve in Legendre basis.

*/

void renorm2dBSsfpllgcln(
IGRint ndeg,
IGRint irat,
IGRdouble uknotd,
IGRdouble uknotf,
IGRdouble vknotd,
IGRdouble vknotf,
IGRdouble *uvstart,
IGRdouble *uvend,
IGRdouble *uvlgd,
IGRdouble *uvstartren,
IGRdouble *uvendren,
IGRdouble *uvlgdren)
{

IGRdouble a1,b1,a2,b2;
IGRint j;

a1 = (uknotd + uknotf) / 2.0;
b1 = (uknotf - uknotd) / 2.0;
a2 = (vknotd + vknotf) / 2.0;
b2 = (vknotf - vknotd) / 2.0;

/*  To avoid numerical noise  if isoparametric curve    */

if (ndeg == 1 && irat == 0 && uvlgd[1] == 0.0 &&
                  uvlgd[2] == 0.0 && uvlgd[3] == 1.0)
if (uvlgd[0] == -1.0 || uvlgd[0] == 1.0)
{
  if (uvlgd[0] == -1.0)
    uvlgdren[0] = uknotd;
   else
    uvlgdren[0] = uknotf;
  uvlgdren[1] = uvlgd[1];
  uvlgdren[2] = a2;
  uvlgdren[3] = b2;
  goto wrapup;
}
if (ndeg == 1 && irat == 0 && uvlgd[3] == 0.0 &&
                  uvlgd[0] == 0.0 && uvlgd[1] == 1.0)
if (uvlgd[2] == -1.0 || uvlgd[2] == 1.0)
{
  if (uvlgd[2] == -1.0)
    uvlgdren[2] = vknotd;
   else
    uvlgdren[2] = vknotf;
  uvlgdren[0] = a1;
  uvlgdren[1] = b1;
  uvlgdren[3] = uvlgd[3];
  goto wrapup;
}

for (j = 0; j <= ndeg; ++j)
{
  uvlgdren[j] = uvlgd[j] * b1;
  uvlgdren[ndeg + 1 + j] = uvlgd[ndeg + 1 + j] * b2;
}

if (irat == 0)
{
  uvlgdren[0] += a1;
  uvlgdren[ndeg + 1] += a2;
}
else if (irat == 1)
{
  for (j = 0; j <= ndeg; ++j)
    uvlgdren[j] += a1 * uvlgd[2 * (ndeg + 1) + j];
  uvlgdren[ndeg + 1] += a2;
  for (j = 0; j <= ndeg; ++j)
    uvlgdren[2 * (ndeg + 1) +j] = uvlgd[2 * (ndeg + 1) + j];
}
else if (irat == 2)
{
  uvlgdren[0] += a1;           
  for (j = 0; j <= ndeg; ++j)
    uvlgdren[ndeg + 1 + j] += a2 * uvlgd[2 * (ndeg + 1) + j];
  for (j = 0; j <= ndeg; ++j)
    uvlgdren[2 * (ndeg + 1) +j] = uvlgd[2 * (ndeg + 1) + j];
}
else if (irat == 3)
{
  for (j = 0; j <= ndeg; ++j)
    uvlgdren[j] += a1 * uvlgd[2 * (ndeg + 1) + j];
    for (j = 0; j <= ndeg; ++j)
      uvlgdren[ndeg + 1 + j] += a2 * uvlgd[3 * (ndeg + 1) + j];
  for (j = 0; j <= ndeg; ++j)
    uvlgdren[2 * (ndeg + 1) +j] = uvlgd[2 * (ndeg + 1) + j];
  for (j = 0; j <= ndeg; ++j)
    uvlgdren[3 * (ndeg + 1) +j] = uvlgd[3 * (ndeg + 1) + j];
}

wrapup:

uvstartren[0] = a1 + b1 * uvstart[0];
uvstartren[1] = a2 + b2 * uvstart[1];
uvendren[0] = a1 + b1 * uvend[0];
uvendren[1] = a2 + b2 * uvend[1];

return;

}

void BSsfpllgcln(
IGRint npoleu,
IGRint npolev,
IGRint ndegu,
IGRint ndegv,
IGRdouble *surface,
IGRdouble *uknots,
IGRdouble *vknots,
IGRint nsegment,
IGRint *ndeg2bag,
IGRint *irat2bag,
IGRdouble **cv2lgdbag,
IGRdouble *uvstart,
IGRdouble *uvend,
IGRint *ndeg3bag,
IGRint *irat3bag,
IGRdouble **cv3lgdbag,
IGRdouble *ptstart,
IGRdouble *ptend,
IGRint *pindexu,
IGRint *pindexv,
IGRdouble prec,
IGRdouble *xyminmax,
IGRint *nbranch,
IGRint **ncvsbrch,
IGRint ***ndeg2tab,
IGRint ***irat2tab,
IGRdouble ****cv2lgd,
IGRint ***ndeg3tab,
IGRint ***irat3tab,
IGRdouble ****cv3lgd,
BSrc *rc)

{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bstrans2.h"
#include "bsunwght_p.h"
#include "bsptsoldtnw.h"
#include "bsspntbzpch.h"
#include "bslnkcvgrph.h"
#include "bsgraphsort.h"
#include "bsmergncvdo.h"
#include "bscvtstclsd.h"
#include "bsrmdbbdry.h"
#include "bschklgcvpt.h"
#include "bsidentcvlg.h"
#include "bsrevpolyn.h"
#include "bsallfinlgd.h"
#include "bsoutputcvs.h"
#include "bscutuvdcv.h"
#include "bschkconti.h"
#include "bsdistwpwp.h"
#include "bsdistptpt.h"
#include "bsconstprcv.h"
#include "bslnk2dsfpl.h"
#include "bsalllgdcvs.h"
#include "bsfrelgdcvs.h"
#include "bsallbspcvs.h"
#include "bsfrebspcvs.h"
#include "bscpylgdcvs.h"
#include "bscpybspcvs.h"
#endif 

IGRdouble *uvlgd = NULL;
IGRdouble *uvlgdren = NULL;
IGRdouble du,dv,d1,d2;
IGRdouble *pntdegen = NULL;
IGRint *iptt = NULL;
IGRint *idegen = NULL;
IGRdouble bidon;
IGRdouble *ptdeb = NULL;
IGRdouble *ptfin = NULL;
IGRdouble *uvdeb = NULL;
IGRdouble *uvfin = NULL;
IGRint *pindexun = NULL;
IGRint *pindexvn = NULL;
  IGRint            num_degn;
IGRint ind1,i,j,k,m,n,nd,N,T;
IGRint isou,isov;
IGRint ndeg2,irat2,ndeg3;
  IGRint            **index = NULL;
IGRint nseg,ndeg,irat,ndim2,ndim3,ii,jj,ipt;
IGRboolean iok;
IGRdouble uvminmax[4];
  IGRboolean        **irev = NULL;
  IGRchar           *big_space1 = NULL;
  IGRchar           *iwrkarea = NULL;
  IGRint            *isocv = NULL;
  IGRint            *itypcv = NULL;
  IGRint            *ikeep = NULL;
  IGRdouble         *uv = NULL;
  IGRint            count,remove_num;
  BSrc              rc1 = BSSUCC;
IGRint *nb1 = NULL;
IGRint *nb2 = NULL;
  IGRint            *istartend1 = NULL,*istartend2 = NULL;
  IGRint            start;
  struct IGRbsp_curve  *cv = NULL;
  IGRboolean        rcw;
  IGRint            coefmax,nsol;
IGRdouble **cv2lgdren = NULL;
IGRdouble *uvstartren = NULL;
IGRdouble *uvendren = NULL;
IGRdouble uknotd,uknotf,vknotd,vknotf;
IGRdouble zerotol = 1.e-14;

  *rc = BSSUCC;
  rc1 = BSSUCC;
  *nbranch = 0;

  rcw = FALSE; /* rc of OUTOFDESN,WARN */

  nsol = nsegment;
  coefmax = 4 * (BSMAXDEG + 1);


  /* Start from here, input is nsol, lgd_cvs and mod_cvs,iptt,
     uknots,vknots */

  /* find and remove redudent iso curves */
  
isocv = (IGRint *)BSstackalloc((unsigned) (nsol * sizeof(IGRint)));
if (!isocv)
{
  *rc =  BSNOSTKMEMORY;
  goto wrapup;
}
  
itypcv = (IGRint *)BSstackalloc((unsigned) (nsol * sizeof(IGRint)));
if (!itypcv)
{
  *rc =  BSNOSTKMEMORY;
  goto wrapup;
}
  
  
ikeep = (IGRint *)BSstackalloc((unsigned) (nsol * sizeof(IGRint)));
if (!ikeep)
{
  *rc =  BSNOSTKMEMORY;
  goto wrapup;
}
  
uv = (IGRdouble *) BSstackalloc((unsigned) (nsol * 3 * sizeof(IGRdouble)));
if (!uv)
{
    *rc = BSNOSTKMEMORY;
    goto wrapup;
}
    
count = 0;  
remove_num = 0;

iptt = (IGRint *)BSstackalloc((unsigned) (nsol * sizeof(IGRint)));
if (!iptt)
{
  *rc = BSNOSTKMEMORY;
  goto wrapup;
}

uvstartren = (IGRdouble *)BSstackalloc((unsigned)(2*nsol*sizeof(IGRdouble)));
if (!uvstartren)
{
    *rc = BSNOSTKMEMORY;
    goto wrapup;
}

uvendren = (IGRdouble *) BSstackalloc((unsigned)(2 * nsol * sizeof(IGRdouble)));
if (!uvendren)
{
    *rc = BSNOSTKMEMORY;
    goto wrapup;
}

cv2lgdren = (IGRdouble **) BSstackalloc((unsigned)(nsol * sizeof(IGRdouble *)));
if (!cv2lgdren)
{
    *rc = BSNOSTKMEMORY;
    goto wrapup;
}

T = 0;
for (n=0;n<nsol;n++)
  T += ndeg2bag[n] + 1;

T = 4*T;

*cv2lgdren = (IGRdouble *) BSstackalloc((unsigned)(T * sizeof(IGRdouble)));
if (!*cv2lgdren)
{
    *rc = BSNOSTKMEMORY;
    goto wrapup;
}

for (n = 0; n < nsol; ++n)
{
  ndeg2 = ndeg2bag[n];
  irat2 = irat2bag[n];
  uvlgd = cv2lgdbag[n];
  uvlgdren = cv2lgdren[n];

/*  Extract the boundaries   */

  BSbndcvindx(ndegu,&uknots[1],pindexu[n],&uknotd,&uknotf);
  BSbndcvindx(ndegv,&vknots[1],pindexv[n],&vknotd,&vknotf);

  renorm2dBSsfpllgcln(ndeg2,irat2,uknotd,uknotf,vknotd,vknotf
       ,&uvstart[2*n],&uvend[2*n],uvlgd
       ,&uvstartren[2*n],&uvendren[2*n],uvlgdren);
  if (n != nsol-1) cv2lgdren[n+1] = cv2lgdren[n] + 4 * (ndeg2+1);
    /* temporary these case are not handled */

  if (ndeg2 == 0)
  {
      if (uvlgdren[0] == uknots[0] || uvlgdren[0] == uknots[npoleu] ||
          uvlgdren[1] == vknots[0] || uvlgdren[0] == vknots[npolev])
      {
        isocv[count] = n;
        itypcv[count] = 2;  /* iso point */ 
        ikeep[count] = KEEP;
        uv[3 * count] = uvlgdren[0];
        uv[3 * count + 1] = uvlgdren[1];
        count++;
      }
      else
      {
        ikeep[count] = KEEP;
        for (i=1;i<npoleu;i++)
        if (uvlgdren[0] == uknots[i])
          ikeep[count] = REMOVE;
        for (i=1;i<npolev;i++)
        if (uvlgdren[1] == vknots[i])
          ikeep[count] = REMOVE;

        isocv[count] = n;
        itypcv[count] = 2;  /* iso point */ 
        uv[3 * count] = uvlgdren[0];
        uv[3 * count + 1] = uvlgdren[1];
        if (ikeep[count] == REMOVE)
          remove_num++;
        count++;
      }
  }

  if (ndeg2 == 1 &&irat2 == 0)
  {
      if (uvlgdren[1] == 0 && (uvlgdren[0] == uknotd || uvlgdren[0] == uknotf) )
      {
        isocv[count] = n;
        itypcv[count] = 0;  /* u knots line */ 
        ikeep[count] = 0;
        uv[3 * count] = uvlgdren[0];
        uv[3 * count + 1] = uvlgdren[2];
        uv[3 * count + 2] = uvlgdren[3];
        count++;
      }
  	  /* Change for if to else if. Because either be u knot line or v knot line.
	  It cannot be both only if it is a point, then we should not count it twice */

      else if (uvlgdren[3] == 0 && (uvlgdren[2] == vknotd || uvlgdren[2] == vknotf) )
      {
        isocv[count] = n;
        itypcv[count] = 1;  /* v knots line */
        ikeep[count] = 0;
        uv[3 * count] = uvlgdren[2];
        uv[3 * count + 1] = uvlgdren[0];
        uv[3 * count + 2] = uvlgdren[1];
        count++;          

      }
  }
}


/* Find  redudent iso points  */


for (i = 0; i < count; ++i)
if (ikeep[i] == KEEP)
if (itypcv[i] == 2)
{
  for (j = i + 1; j < count; ++j)
  {
    if (ikeep[j] == KEEP && itypcv[j] == itypcv[i] &&
            uv[3 * j] == uv[3 * i] && uv[3 * j + 1] == uv[3 * i + 1])
    {
       ikeep[j] = REMOVE;
       remove_num++;
    }
  }
}



  /* find  redudent iso curves */


for (i = 0; i < count; ++i)
if (ikeep[i] == 0)
{
  ikeep[i] = KEEP;
  for (j = i + 1; j < count; ++j)
  {
    if (ikeep[j] == 0 && itypcv[j] == itypcv[i] &&
            uv[3 * j] == uv[3 * i] && uv[3 * j + 1] == uv[3 * i + 1] &&
            uv[3 * j + 2] == uv[3 * i + 2])
    {
       ikeep[j] = REMOVE;
       remove_num++;
    }
  }
}

/*   Find curves on the seam   */

for (i = 0; i < count; ++i)
if (ikeep[i] == KEEP)
if ((uv[3*i] == uknots[0] && itypcv[i] == 0) ||
    (uv[3*i] == vknots[0] && itypcv[i] == 1))
for (j = 0; j < count; ++j)
if ((uv[3*j] == uknots[npoleu] && itypcv[j] == 0) ||
    (uv[3*j] == vknots[npolev] && itypcv[j] == 1))
if (ikeep[j] == KEEP && itypcv[j] == itypcv[i] &&
         uv[3 * j + 1] == uv[3 * i + 1] && uv[3 * j + 2] == uv[3 * i + 2])
{
  n = isocv[i];
  m = isocv[j];
  if (ndeg3bag[n] == ndeg3bag[m] && irat3bag[n] == irat3bag[m])
  {
    ndeg = ndeg3bag[n];
    irat = irat3bag[n];
    iok = TRUE;
    if (irat)
    for (k=0;k<=ndeg;k++)
    if (ABS(cv3lgdbag[n][k+2*(ndeg+1)] - cv3lgdbag[m][k+2*(ndeg+1)]) > zerotol)
    {
      iok = FALSE;
      break;
    }
    if (iok)
    {
      bidon = 0.0;
      for (k=0;k<2*(ndeg+1);k++)
        bidon = bidon + ABS(cv3lgdbag[n][k] - cv3lgdbag[m][k]);
      if (bidon <= prec)
      {
        ikeep[j] = REMOVE;
        remove_num++;
      }
    }  
  }
}

  /* remove redudent iso curves */

n = nsol - remove_num;
ii = 0;
for (i = 0; i < nsol; ++i)
{
  iptt[ii] = i;
  ii++;
  for (j = 0; j < count; ++j)
  {
    if ( isocv[j] == i && ikeep[j] == REMOVE)
    {
      ii--;
      break;
    }
  }
}
nsol -= remove_num;

if (nsol == 0)
{
  *nbranch = 0;
  goto wrapup;
}

pntdegen = (IGRdouble *)BSstackalloc((unsigned) (2 * nsol * sizeof(IGRdouble)));
if (!pntdegen)
{
  *rc = BSNOSTKMEMORY;
  goto wrapup;
}

/*  We set up the next address: nsol+1   */

irev = (IGRboolean **)BSstackalloc((unsigned)(2*(nsol+1)*sizeof(IGRboolean *)));
if (!irev)
{
  *rc = BSNOSTKMEMORY;
  goto wrapup;
}

/*  For loops, nsol is increased + 1. We set up the next address: nsol+1   */

*irev = (IGRboolean *)BSstackalloc((unsigned)(3*(nsol+1)*sizeof(IGRboolean)));
if (!*irev)
{
  *rc = BSNOSTKMEMORY;
  goto wrapup;
}

/*  We set up the next address: nsol+1   */

index = (IGRint **)BSstackalloc((unsigned)(2*(nsol+1)*sizeof(IGRint *)));
if (!index)
{
  *rc = BSNOSTKMEMORY;
  goto wrapup;
}

/*  We set up the next address: nsol+1   */

*index = (IGRint *)BSstackalloc((unsigned)(3*(nsol+1)*sizeof(IGRint)));
if (!*index)
{
  *rc = BSNOSTKMEMORY;
  goto wrapup;
}

/*  We set up the next address: nsol+1   */

idegen = (IGRint *)BSstackalloc((unsigned)(2 * (nsol+1) * sizeof(IGRboolean)));
if (!idegen)
{
  *rc = BSNOSTKMEMORY;
  goto wrapup;
}

  /* find degenerated intersection curve and compute the
     degenerate point */

num_degn = 0;
for (i = 0; i < nsol; ++i)
{
  ii = iptt[i];
  BSchklgcvpt(ndeg3bag[ii],2,irat3bag[ii],cv3lgdbag[ii],prec,&idegen[i]
              ,&pntdegen[2*i]);
  if (BSERROR(*rc)) goto wrapup;

    if (idegen[i]) num_degn++;
}

  /* remove degenerate point if it is a extremity point of 
     anther intersection */
     
num_degn = 0;
remove_num = 0;
for (i = 0; i < nsol; ++i)
if (idegen[i])
{
  for (j = 0; j < nsol; ++j)
  if (!idegen[j])
  {
    jj = iptt[j];
    d1 = 0;
    d2 = 0;
    for (nd = 0; nd < 2;nd++)
    {
      bidon = ptstart[nd+2*jj] - pntdegen[nd+2*i];
      d1 += bidon * bidon;
      bidon = ptend[nd+2*jj] - pntdegen[nd+2*i];
      d2 += bidon * bidon;
    }
    if (d1 < prec*prec || d2 < prec*prec)
    {
            /* idegen[i] = 2 means removing this degenerate point */

            idegen[i] = 2;
            remove_num++;
            break;
    }
  }
  num_degn++;
}

/*  Remove degenerate curves belonging to other curves   */

ipt = 0;
for (ii = 0; ii < nsol; ++ii)
{
  if (idegen[ii] != 2)
  {
     iptt[ipt] = iptt[ii];
     ipt++;
  }
}
nsol = ipt;

  /* find curve graph */

iwrkarea = BSstackalloc((unsigned)(4 * nsol * sizeof(IGRint)));
if (!iwrkarea)
{
    *rc = BSNOSTKMEMORY;
    goto wrapup;
}
  nb1 = (IGRint *)iwrkarea;
  nb2 = (IGRint *)&iwrkarea[nsol * sizeof(IGRint)];
  istartend1 = (IGRint *)&iwrkarea[2 * nsol * sizeof(IGRint)];
  istartend2 = (IGRint *)&iwrkarea[3 * nsol * sizeof(IGRint)];

  ptdeb = (IGRdouble *) BSstackalloc((unsigned)(2 * nsol * sizeof(IGRdouble)));
  if (!ptdeb)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  ptfin = (IGRdouble *) BSstackalloc((unsigned)(2 * nsol * sizeof(IGRdouble)));
  if (!ptfin)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

uvdeb = (IGRdouble *) BSstackalloc((unsigned)(2 * nsol * sizeof(IGRdouble)));
if (!uvdeb)
{
    *rc = BSNOSTKMEMORY;
    goto wrapup;
}

uvfin = (IGRdouble *) BSstackalloc((unsigned)(2 * nsol * sizeof(IGRdouble)));
if (!uvfin)
{
    *rc = BSNOSTKMEMORY;
    goto wrapup;
}


for (i=0;i<nsol;i++)
for (nd=0;nd<2;nd++)
{
   ptdeb[nd+2*i] = ptstart[nd+iptt[i]*2];
   ptfin[nd+2*i] = ptend[nd+iptt[i]*2];
}

for (i=0;i<nsol;i++)
for (nd=0;nd<2;nd++)
{
   uvdeb[nd+2*i] = uvstartren[nd+iptt[i]*2];
   uvfin[nd+2*i] = uvendren[nd+iptt[i]*2];
}

uvminmax[0] = uknots[0];
uvminmax[1] = uknots[npoleu];
uvminmax[2] = vknots[0];
uvminmax[3] = vknots[npolev];

BSlnkcvgrph(2,nsol,ptdeb,ptfin,2.0*prec,nb1,nb2,istartend1,istartend2,rc);
/* Try to salvage in 2 dimensions (u,v) if not unique   */
rc1 = *rc;
if (BSERROR(*rc)) goto suite2d;

/* Make some extra cuts if needed   */

du = (uknots[npoleu] - uknots[0])/10.0;
dv = (vknots[npolev] - vknots[0])/10.0;

BScutuvdcv(nsol,du,dv,uvdeb,uvfin,nb1,nb2);

/*  Check continuity   */

BSchkconti(nsol,nb1,nb2,uvdeb,uvfin,uvminmax,2,ptdeb,ptfin,xyminmax,rc);
if (BSERROR(*rc)) goto suite2d;

goto normal;

suite2d:
/*  Try to recover with the parametric curves   */

pindexun = (IGRint *) BSstackalloc((unsigned)(nsol * sizeof(IGRint)));
if (!pindexun)
{
    *rc = BSNOSTKMEMORY;
    goto wrapup;
}

pindexvn = (IGRint *) BSstackalloc((unsigned)(nsol * sizeof(IGRint)));
if (!pindexvn)
{
    *rc = BSNOSTKMEMORY;
    goto wrapup;
}

for (i=0;i<nsol;i++)
{
   pindexun[i] = pindexu[iptt[i]];
   pindexvn[i] = pindexv[iptt[i]];
}

BSlnk2dsfpl(npoleu,npolev,ndegu,ndegv,surface,uknots,vknots,nsol
           ,uvdeb,uvfin,pindexun,pindexvn,prec,nb1,nb2
           ,istartend1,istartend2,rc);
/*  Look for consistency   */
if (*rc == BSINOTUNIQUE && rc1 == BSINOTUNIQUE) *rc = BSSUCC;
/* We have a self intersection */
if (*rc == BSNOTSSLINE && rc1 == BSINOTUNIQUE)
{
  *rc = BSSUCC;
  goto normal;
}
/* Case of error try again the standard one  */

if (BSERROR(*rc))
{
  BSlnkcvgrph(2,nsol,ptdeb,ptfin,2.0*prec,nb1,nb2,istartend1,istartend2,rc);
  if (*rc == BSINOTUNIQUE) *rc = BSSUCC;
  if (BSERROR(*rc)) goto wrapup;
  goto normal;
}

/* Make some extra cuts if needed   */

du = (uknots[npoleu] - uknots[0])/10.0;
dv = (vknots[npolev] - vknots[0])/10.0;

BScutuvdcv(nsol,du,dv,uvdeb,uvfin,nb1,nb2);

uvminmax[0] = uknots[0];
uvminmax[1] = uknots[npoleu];
uvminmax[2] = vknots[0];
uvminmax[3] = vknots[npolev];

/*  Check continuity   */

BSchkconti(nsol,nb1,nb2,uvdeb,uvfin,uvminmax,2,ptdeb,ptfin,xyminmax,rc);
if (*rc == BSNOTCONTINUOUS)
{
  *rc = BSINCONSISTENT;
  goto wrapup;
}

normal:

/*  Before sorting the graph, do not connect at corners of the surface   */

for (n=0;n<nsol;n++)
{
  iok = isou = isov = 0;
  if (uvdeb[2*n] == uvminmax[0] || uvdeb[2*n] == uvminmax[1]) isou = 1;
  if (uvdeb[1+2*n] == uvminmax[2] || uvdeb[1+2*n] == uvminmax[3]) isov = 1;
  if (isou == 1 && isov == 1) iok = 1;
  if (isou == 1 && nb1[n] >= 0)
  {
    m = nb1[n];
    if (uvdeb[2*n] != uvfin[2*n] || uvdeb[2*m] != uvfin[2*m]) iok = 1;
  }
  if (isov == 1 && nb1[n] >= 0)
  {
    m = nb1[n];
    if (uvdeb[1+2*n] != uvfin[1+2*n] || uvdeb[1+2*m] != uvfin[1+2*m]) iok = 1;
  }
  if (iok)
  {
/*  Keep the link commutative   */
    if (nb1[n] >= 0)
    {
      m = nb1[n];
      if (istartend1[n] == 1)
        nb2[m] = -1;
      else
        nb1[m] = -1;
    }
    nb1[n] = -1;
  }

  iok = isou = isov = 0;
  if (uvfin[2*n] == uvminmax[0] || uvfin[2*n] == uvminmax[1]) isou = 1;
  if (uvfin[1+2*n] == uvminmax[2] || uvfin[1+2*n] == uvminmax[3]) isov = 1;
  if (isou == 1 && isov == 1) iok = 1;
  if (isou == 1 && nb2[n] >= 0)
  {
    m = nb2[n];
    if (uvdeb[2*n] != uvfin[2*n] || uvdeb[2*m] != uvfin[2*m]) iok = 1;
  }
  if (isov == 1 && nb2[n] >= 0)
  {
    m = nb2[n];
    if (uvdeb[1+2*n] != uvfin[1+2*n] || uvdeb[1+2*m] != uvfin[1+2*m]) iok = 1;
  }
  if (iok)
  {
/*  Keep the link commutative   */
    if (nb2[n] >= 0)
    {
      m = nb2[n];
      if (istartend2[n] == 1) 
        nb2[m] = -1;
      else
        nb1[m] = -1;
    }
    nb2[n] = -1;
  }
}

BSgraphsort(nsol,nb1,nb2,istartend1,istartend2,nbranch,ncvsbrch,index,irev,rc);
  if (BSERROR(*rc) && rc[0] != BSFAIL)
    goto wrapup;

/*  Allocate the final result  */

BSallfinlgd(ndeg2bag,irat2bag,ndeg3bag,irat3bag,*nbranch,*ncvsbrch,iptt,index
           ,ndeg2tab,irat2tab,cv2lgd,ndeg3tab,irat3tab,cv3lgd,rc);
if (BSERROR(*rc)) goto wrapup;

  /* merge the Legendre series to make a composite curve */

  ind1 = 0;
  count = 0;
  start = 0;
for (N=0;N<*nbranch;N++)
{
  for (n=0;n<(*ncvsbrch)[N];n++)
  {
    m = iptt[index[N][n]];
    (*ndeg2tab)[N][n] = ndeg2bag[m];
    (*irat2tab)[N][n] = irat2bag[m];
    (*ndeg3tab)[N][n] = ndeg3bag[m];
    (*irat3tab)[N][n] = irat3bag[m];
  }
/*  Special handling of loops   */

  nseg = (*ncvsbrch)[N];
  if (nseg > 1 && iptt[index[N][0]] == iptt[index[N][nseg-1]])
    nseg = nseg - 1;

  for (n=0;n<nseg;n++)
  {
    m = iptt[index[N][n]];
    ndim2 = 2;
    if (irat2bag[m] == 1 || irat2bag[m] == 2) ndim2=3;
    if (irat2bag[m] == 3) ndim2=4;
    ndim3 = 2 + irat3bag[m];
    ndeg2 = (*ndeg2tab)[N][n];
    ndeg3 = (*ndeg3tab)[N][n];

    if (!irev[N][n])
    {
      BSMEMCPY(ndim2*(ndeg2+1)*sizeof(IGRdouble),cv2lgdren[m],(*cv2lgd)[N][n]);
      BSMEMCPY(ndim3*(ndeg3+1)*sizeof(IGRdouble),cv3lgdbag[m],(*cv3lgd)[N][n]);
    }
    else
    {
      BSrevpolyn(ndeg2,ndim2,cv2lgdren[m],(*cv2lgd)[N][n]);
      BSrevpolyn(ndeg3,ndim3,cv3lgdbag[m],(*cv3lgd)[N][n]);
    }

/* ndim3+1: Needed for the final result   */
    if (n != (*ncvsbrch)[N]-1)
    {
      (*cv2lgd)[N][n+1] = (*cv2lgd)[N][n] + ndim2*(ndeg2+1);
      (*cv3lgd)[N][n+1] = (*cv3lgd)[N][n] + (ndim3+1)*(ndeg3+1);
    }
  }

/*  Set up last curve if loop  */

  if (nseg == (*ncvsbrch)[N] -1)
  {
    (*cv2lgd)[N][nseg] = (*cv2lgd)[N][0];
    (*cv3lgd)[N][nseg] = (*cv3lgd)[N][0];
  }

/*  Set up new addresses   */

  if (N != *nbranch-1)
  {
    (*cv2lgd)[N+1] = (*cv2lgd)[N] + (*ncvsbrch)[N];
    (*irat2tab)[N+1] = (*irat2tab)[N] + (*ncvsbrch)[N];
    (*ndeg2tab)[N+1] = (*ndeg2tab)[N] + (*ncvsbrch)[N];
    (*cv3lgd)[N+1] = (*cv3lgd)[N] + (*ncvsbrch)[N];
    (*irat3tab)[N+1] = (*irat3tab)[N] + (*ncvsbrch)[N];
    (*ndeg3tab)[N+1] = (*ndeg3tab)[N] + (*ncvsbrch)[N];
    n = nseg-1;
    (*cv2lgd)[N+1][0] = (*cv2lgd)[N][n] + ndim2*(ndeg2+1);
    (*cv3lgd)[N+1][0] = (*cv3lgd)[N][n] + (ndim3+1)*(ndeg3+1);
 }
}
  
wrapup:
  if (cv)
  {
    BSstkfreecv(&rc1,cv);
    if (BSERROR(rc1) && BSOKAY(*rc))
      *rc = rc1;
    cv = NULL;
  }

  if (pntdegen)
  {
    BSstackdealloc((char *) pntdegen);
    pntdegen = NULL;
  }
  if (ikeep)
  {
    BSstackdealloc((char *) ikeep);
    ikeep = NULL;
  }
  if (itypcv)
  {
    BSstackdealloc((char *) itypcv);
    itypcv = NULL;
  }
  if (isocv)
  {
    BSstackdealloc((char *) isocv);
    isocv = NULL;
  }
  if (uv)
  {
    BSstackdealloc((char *) uv);
    uv = NULL;
  }
  if (idegen)
  {
    BSstackdealloc((char *) idegen);
    idegen = NULL;
  }
  if (index)
  {
    if (*index) BSstackdealloc((char *) *index);
    BSstackdealloc((char *) index);
    index = NULL;
  }
  if (irev)
  {
    if (*irev) BSstackdealloc((char *) *irev);
    BSstackdealloc((char *) irev);
    irev = NULL;
  }

  if (big_space1)
  {
    BSstackdealloc((char *) big_space1);
    big_space1 = NULL;
  }
  if (iwrkarea)
  {
    BSstackdealloc((char *) iwrkarea);
    iwrkarea = NULL;
  }
  if (iptt)
  {
    BSstackdealloc((char *) iptt);
    iptt = NULL;
  }
if (pindexvn)
{
  BSstackdealloc((char *) pindexvn);
  pindexvn = NULL;
}
if (pindexun)
{
  BSstackdealloc((char *) pindexun);
  pindexun = NULL;
}
  if (uvfin)
  {
    BSstackdealloc((char *) uvfin);
    uvfin = NULL;
  }
  if (uvdeb)
  {
    BSstackdealloc((char *) uvdeb);
    uvdeb = NULL;
  }
  if (ptfin)
  {
    BSstackdealloc((char *) ptfin);
    ptfin = NULL;
  }
  if (ptdeb)
  {
    BSstackdealloc((char *) ptdeb);
    ptdeb = NULL;
  }
  if (uvendren)
  {
    BSstackdealloc((char *) uvendren);
    uvendren = NULL;
  }
  if (uvstartren)
  {
    BSstackdealloc((char *) uvstartren);
    uvstartren = NULL;
  }

if (cv2lgdren)
{
  if (*cv2lgdren) BSstackdealloc((char *) *cv2lgdren);
    BSstackdealloc((char *) cv2lgdren);
    cv2lgdren = NULL;
}

  if(BSERROR(*rc))
    BSdbgrc(*rc,"BSsfpllgcln");
  return;
}
