/* $Id: bsboxinvab.c,v 1.1.1.1 2001/01/04 21:07:26 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	emsfixes/bs/bsboxinvab.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: bsboxinvab.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:26  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1998/01/09  16:45:26  pinnacle
 * Created: emsfixes/bs/bsboxinvab.c by azuurhou for vds
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/09/98	adz		integration date
 ***************************************************************************/

/*****************************************************************************

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSboxinvab

Abstract
    Given a matrix {a,b}, We compute the inverse matrix.

Synopsis
    void BSboxinvab(base,qmat,rc)

    IGRdouble             *base,
    IGRdouble             *qmat,
    BSrc                  *rc,

Description
    Input:
      base[0:1,0:1] - (a1,a2)
                      (b1,b2)
                      The coefficients of {a,b}

    Output:
      qmat[0:1,0:1] - The transpose matrix of {e1,e2} expressed in the
                      basis {a,b}
      rc - BSINFSOLUTION, if the matrix is singular.

    Algorithm:

Return Values
    NA

Notes

Index
    md

Keywords

History
    Vivian Y. Hsu        06/20/1996 : Creation date.
    Vivian Y. Hsu        01/03/1997 : Check if the input matrix is
                                      singular.
    Vivian Y. Hsu        01/14/1997 : Use constants (#define) for 
                                      tolerance instead of variables.
    Vivian Y. Hsu        01/05/1998 : Compute inverse matrix directly to
                                      avoid numerical noise from computing
                                      a,b,c.
******************************************************************************
*/

#include <math.h>
#include "bs.h"
#define ZERO_TOL 1.0e-10
#define BAS_TOL 1.0e-6

void BSboxinvab(

IGRdouble             *base,
IGRdouble             *qmat,
BSrc                  *rc)

{

#include "bsdbgrc.h"
  IGRdouble          det;
/*
  IGRdouble          a,b,c;
  IGRdouble          ap,bp,cp,det;
  IGRint             i;
*/
  *rc = BSSUCC;


  /* Check if the input matrix is a singular matrix */

  det = base[0] * base[3] - base[1] * base[2];

  if (det == 0)
  {
    *rc = BSINFSOLUTION;
    goto wrapup;
  }

  qmat[0] = base[3] / det;
  qmat[2] = -base[1] / det;
  qmat[1] = -base[2] / det;
  qmat[3] = base[0] / det;
  
/*
  if ( fabs(det) < BAS_TOL ||
      (fabs(base[0]) < BAS_TOL && fabs(base[2]) < BAS_TOL) ||
      (fabs(base[1]) < BAS_TOL && fabs(base[3]) < BAS_TOL) )
  {
    *rc = BSINFSOLUTION;
    goto wrapup;
  }
*/

  /* Compute f1^2,f1f2,f2^2,f3^2 */
/*
  a = 0;
  b = 0;
  c = 0;
  for (i = 0; i < 2; ++i)
  {
    a += base[i] * base[i];
    b += base[i] * base[2 + i];
    c += base[2 + i] * base[2 + i];
  }

  det = a * c - b * b;

  if (fabs(det) < ZERO_TOL)
  {
    *rc = BSINFSOLUTION;
    goto wrapup;
  }
*/
  /* we now set up the inverse matrix */
/*
  ap = c / det;
  bp = -b / det;
  cp = a / det;

  for (i = 0; i < 2; ++i)
  {
    qmat[i] = ap * base[i] + bp * base[i + 2];     
    qmat[i + 2] = bp * base[i] + cp * base[i + 2];
  }
*/
wrapup:
  if (BSERROR (*rc))
    BSdbgrc (*rc, "BSboxinvab");

  return;
}
