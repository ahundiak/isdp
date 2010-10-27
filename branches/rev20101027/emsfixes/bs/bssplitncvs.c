/*****************************************************************************

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSsplitncvs

Abstract
    Given a curve, number of parameters and an array of parameters,
    this routine split the curve into pieces at these parameters.

Synopsis
    void BSsplitncvs(ndeg,npoles,ndim,poles,knots,num_pars,pars,
                     npoltab,poltab,knottab,rc)

    IGRint                ndeg;
    IGRint                npoles;
    IGRint                ndim;
    IGRdouble             *poles;
    IGRdouble             *knots;
    IGRint                num_pars;
    IGRdouble             *pars;
    IGRint                **npoltab;
    IGRdouble             ***poltab;
    IGRdouble             ***knottab;
    BSrc                  *rc;

Description
    Input:
      ndeg - degree of input curve
      npoles - number of poles of input curve
      ndim - dimension of poles (include weights)
      poles(npoles,ndim) - array of poles
      knots(npoles + ndeg + 1) - array of knots
      num_pars - number of parameters the curve will be split.
      pars(num_pars) - array of parameters 

    Input/Output:
 
    Output:
     npoltab(num_pars+1) - number of poles for all splited curve
     poletab(npoltab[i],num_pars+1) - array of poles for splited curve
     knottab(npoltab[i]+ndeg+1,num_pars+1) - array of knots for splited
                         curve. 
     *rc        Possible return codes include:

    Algorithm:

Return Values
    NA

Notes
    The parameter in array pars() should not be either knots[0] or
    knots[npoles]. The output number of splited curve is num_pars+1.

    How to free the output arguments:
       if (npoltab)
         BSdealloc((char *) npoltab);
       if (poltab)
       {
         if (poltab[0])
           BSdealloc((char *) poltab[0]);
         BSdealloc((char *) poltab);
       }
  
    !! Do not need free knottab.!!
    Since poletab[i],knottab[i],i=0,num_pars+1 are allocated togather.
    So when we free poltab and poltab[0] we already freed knottab and 
    knottab[i].

Index
    lg

Keywords
    curve,split,parameters.

History
    Vivian Y. Hsu   03/23/98  : Creation date.
******************************************************************************
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
#endif

#include <math.h>

void BSsplitncvs(
                
IGRint                ndeg,
IGRint                npoles,
IGRint                ndim,
IGRdouble             *poles,
IGRdouble             *knots,
IGRint                num_pars,
IGRdouble             *pars,
IGRint                **npoltab,
IGRdouble             ***poltab,
IGRdouble             ***knottab,
BSrc                  *rc)

{

#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsfndspnarr.h"
#include "bsinsertmkt.h"
#include "bsgetmult.h"
#endif 

  IGRdouble   *u = NULL;
  IGRdouble   *outpoles = NULL;
  IGRdouble   *outknots = NULL;
  IGRdouble   prec;
  IGRint      *pmul = NULL;
  IGRint      *mul = NULL;
  IGRint      *span = NULL;
  IGRint      nu,i,j,n,nd,pole_ind,knot_ind;
  IGRint      sz_u,sz_outpoles,sz_outknots,num_knots;
  IGRint      npole1,npol1;
  IGRint      sz_poltab,sz_knottab;
  IGRshort    ord;
  IGRlong     npol;
  IGRint      u_num;
  IGRchar     *big_space = NULL;
  IGRchar     *big_space1 = NULL;
  IGRchar     *big_space2 = NULL;
  IGRchar     *big_space3 = NULL;
  IGRdouble   par_tol = 1.0e-12;
 
  *rc = BSSUCC;
  ord = ndeg + 1;
  npole1 = npoles - 1;

  prec = (knots[npoles] - knots[0]) * 1.0e-14;

  /* Allocate space for kts and mul */
  
  sz_u = npoles + num_pars * ord;
  u = (IGRdouble *)BSstackalloc((unsigned)(sz_u * sizeof(IGRdouble)));
  if (!u)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  big_space = BSstackalloc((unsigned)(sz_u + (num_pars + 1) * 2) * 
              sizeof(IGRint));
  if (!big_space)
  {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }
  mul = (IGRint *)big_space;
  pmul = (IGRint *)mul + npoles;
  span = (IGRint *)pmul + num_pars;

  /* Find interial knots and multiplicity of input curve */
  /* It includes the knots[0] and knots[npoles] */

/*
  BSgetmult(rc,&ord,&npole1,knots,&nu,u,mul);
  if (BSERROR(*rc))
    goto wrapup;
*/

  nu = 1;
  u[0] = knots[0];
  mul[0] = 1;


  for(i=0; i< ord + npole1 ; i++)
  {
    if(fabs(knots[i] - knots[i+1]) > par_tol )
    {
      nu += 1;
      u[nu-1] = knots[i+1];
      mul[nu-1] = 1;
    }
    else
    {
      mul[nu-1] += 1;
    }
  }


  /* Compare array kts with mul to input array pars */

  for (i = 0; i < num_pars; ++i)
  {
    for (j = 1; j < nu - 1; ++j)
    {
      if (fabs(pars[i] - u[j]) < prec)
      {
        pmul[i] = ord - mul[j];
        break;
      }
      else if (pars[i] < u[j])
      {
        pmul[i] = ord;
        break;
      }
    }
  }

  /* Allocate space for outpoles and outknots */
 
  n = 0;
  for (i= 0; i < num_pars; ++i)
    n += pmul[i];

  u_num = n;
  sz_outpoles = (n + npoles) * ndim;
  sz_outknots = n + npoles + ord;

  big_space1 = BSstackalloc((unsigned)(sz_outpoles + sz_outknots)
              * sizeof(IGRdouble));
  if (!big_space1)
  { 
    *rc = BSNOSTKMEMORY;
    goto wrapup;
  }

  outpoles = (IGRdouble *)big_space1;
  outknots = (IGRdouble *)outpoles + sz_outpoles;

  /* Insert pars with multiplicity pmul to curve */
 
  n = 0;
  for (i = 0; i < num_pars; ++i)
  {
    for (j = 0; j < pmul[i]; ++j)
    {
      u[n] = pars[i];
      n++;
    }
  }

  BSinsertmkt(ndeg+1,ndim,npoles,poles,knots,u_num,u,
                outpoles,outknots,rc);
  if (BSERROR(*rc))
    goto wrapup;

  npol = u_num + npoles;
  npol1 = npol - 1;

  /* Find span indices for knots with multiplicity of order */

/*
  BSgetmult(rc,&ord,&npol1,outknots,&nu,u,mul);
  if (BSERROR(*rc))
    goto wrapup;
*/

  nu = 1;
  u[0] = outknots[0];
  mul[0] = 1;


  for(i=0; i< ord + npol1 ; i++)
  {
    if(fabs(outknots[i] - outknots[i+1]) > par_tol )
    {
      nu += 1;
      u[nu-1] = outknots[i+1];
      mul[nu-1] = 1;
    }
    else
    {
      mul[nu-1] += 1;
    }
  }


  n= 0;

  /* since u include the knots[0] and knots[npol], we start from
     second and stop at second to last */

  for (j = 1; j < nu; ++j)
  {
    if (mul[j] == ord)
    {
      for (i = ord; i < npol+ord; ++i)
      { 
        if (fabs(u[j] - outknots[i]) < prec)
        {
          span[n] = i;
          n++;
          break;
        }
      }
    }
  }


  /* Now output splited curves */
  /* Allocate space for npoltab, poltab,knottab */

  *npoltab = (IGRint *)BSmalloc((unsigned)((num_pars + 1) * 
                     sizeof(IGRint)));
  if (!(*npoltab))
  {
    *rc = BSNOMEMORY;
    goto wrapup;
  }
  big_space2 = BSmalloc((unsigned)((num_pars + 1) * 2 * 
                     sizeof(IGRdouble *)));
  if (!big_space2)
  {
    *rc = BSNOMEMORY;
    goto wrapup;
  }

  *poltab = (IGRdouble **)big_space2;
  *knottab = (IGRdouble **)(*poltab) + num_pars + 1;
  sz_poltab = sz_outpoles + num_pars * ndim;
  sz_knottab = sz_outknots + num_pars * ord;

  big_space3 = BSmalloc((unsigned)((sz_poltab + sz_knottab) * 
                     sizeof(IGRdouble)));
  if (!big_space3)
  {
    *rc = BSNOMEMORY;
    goto wrapup;
  }

  (*poltab)[0] = (IGRdouble *)big_space3;
  (*knottab)[0] = (IGRdouble *)(*poltab)[0] + sz_poltab;

  /* push num_pars + 1 curves to poltab,knottab */

  pole_ind = 0;  
  knot_ind = 0;
  for (i = 0; i <= num_pars; ++i)
  {
    (*npoltab)[i] = span[i] - pole_ind;
    
    for (nd = 0; nd < ndim; ++nd)
    {
      BSMEMCPY((*npoltab)[i] * sizeof(IGRdouble),
                &outpoles[pole_ind + nd * npol],
                &((*poltab)[i][nd * (*npoltab)[i]]));
    }
    num_knots = (*npoltab)[i] + ord;
    BSMEMCPY(num_knots * sizeof(IGRdouble),
             &outknots[knot_ind],(*knottab)[i]);
    pole_ind = span[i];
    knot_ind += (*npoltab)[i];
    if (i < num_pars)
    {
      (*poltab)[i + 1] = (IGRdouble *)(*poltab)[i] + (*npoltab)[i]*ndim;
      (*knottab)[i + 1] = (IGRdouble *)(*knottab)[i] + num_knots;
    }
  }

wrapup:
  if (u)
    BSstackdealloc((char *) u);
  if (big_space)
    BSstackdealloc((char *) big_space);
  if (big_space1)
    BSstackdealloc((char *) big_space1);
  
  if (BSERROR (*rc))
    BSdbgrc (*rc, "BSsplitncvs");
  return;
}
