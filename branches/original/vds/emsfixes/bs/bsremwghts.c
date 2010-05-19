/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSftnrsftsf (ORIGINAL)
    BSrmsfwghts (New Name)

Abstract
    Given an input surface (in_sf), this removes the weights if they are all equal,
    from the input surface.

Synopsis
    IGRint BSrmsfwghts(in_sf, rc)

    IGRbsp_surface    *in_sf;
    BSrc              *rc;

Description

    Input:
      in_sf  : initial surface (rational or not)

    Output:
      rc     : BSSUCC  succes.

Return Values
  none

Notes

Index

Keywords

History
    Vivian W.Ye   05/22/87    : Creation Date.
    Hans Frosch   10/27/99      Stripped down version for GSCAD to remove superfluous weights.
                                (All weights are equal.)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*
#ifdef DONOTSPROTO
#include "ubspmp.h"
#endif
*/

#ifdef NT
/* #include "ubspm.h" */
#else
#include "bs.h"
#include "bsmalloc.h"
#include "bsstackalloc.h"
#include "bsparameters.h"
#endif

#define  BSVOID

IGRint   BSrmsfwghts(
struct IGRbsp_surface     *in_sf,
BSrc                      *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bssfkttol2.h"
#endif

  IGRint                i,j,nbpol, conv = 0;
  IGRboolean            same_weights;
  IGRdouble             knot_tol,zero_tol,toler;

  *rc = BSSUCC;

  if ( ! in_sf->rational)
    goto wrapup;

  BSEXTRACTPAR(rc, BSTOLCLOSETOZERO, zero_tol);
  BSEXTRACTPAR(rc, BSTOLCHRDHT, toler);

  BSsfkttol2 ( in_sf->u_order, in_sf->v_order, in_sf->u_knots, in_sf->v_knots,
               in_sf->u_num_poles, in_sf->v_num_poles, in_sf->poles, in_sf->weights, &knot_tol, rc);
  if (BSERROR(*rc))
    goto wrapup;

  if (in_sf->rational)
  {
    same_weights = TRUE;

    /* Set rational bit to FALSE if all the weights are identical */

    nbpol = in_sf->u_num_poles * in_sf->v_num_poles;
    for (i = 0; i < (nbpol - 1); ++i)
    {
      if (ABS(in_sf->weights[i + 1] - in_sf->weights[i]) > zero_tol)
      {
        same_weights = FALSE;
        break;
      }
    }
    if (same_weights)
    {
      for (i = 0; i < nbpol ; ++i)
        for (j = 0; j < 3; ++j)
          in_sf->poles[3 * i + j] /= in_sf->weights[i];

      in_sf->rational = FALSE;
      if (in_sf->weights)
      {
        /*BSdealloc((char *)in_sf->weights);*/
        in_sf->weights = NULL;
      }
      conv = 1;
    }
  }

wrapup:

  if (BSERROR(*rc))
    BSdbgrc(*rc,"BSrmsfwghts");
  return conv;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSftnrcvtcv (ORIGINAL)
    BSrmcvwghts (New Name)

Abstract
    Given an input curve (in_cv), this removes the weights if they are all equal,
    from the input curve.

Synopsis
    IGRint BSrmcvwghts(in_cv, rc)

    IGRbsp_curve    *in_cv;
    BSrc            *rc;

Description

    Input:
      in_cv  : initial curve (rational or not)

    Output:
      rc     : BSSUCC  succes.

Return Values
    If successful,BSSUCC is returned as a completion code message.

Notes

Index

Keywords

History
    Vivian W.Ye   05/07/87    : Creation Date.
    Hans Frosch   10/27/99      Stripped down version for GSCAD to remove superfluous weights.
                                (All weights are equal.)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

/* check to see if this curve has weights all the same */
static void chkwtsBSftnrcvtcv(
struct IGRbsp_curve *curve,
IGRdouble           zero_tol,
IGRboolean          *allsame,
BSrc                *rc)
{
   IGRint i;
   IGRdouble *ptr;

   *rc = BSSUCC;

   *allsame = TRUE;
   ptr = curve->weights;
   for (i = 0; i < curve->num_poles - 1; ++i)
   {
     if (ABS(*(ptr+1) - *ptr) > zero_tol)
     {
       *allsame = FALSE;
       break;
     }
     ptr++;
   }
   return;
}

IGRint BSrmcvwghts(
struct IGRbsp_curve     *in_cv,
BSrc                    *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bscvkttol2.h"
#endif

  IGRint                i,j, conv = 0;
  IGRboolean            same_weights;
  IGRdouble             knot_tol,zero_tol;
  IGRdouble             *ptr, *wptr;

  *rc = BSSUCC;

  if ( ! in_cv->rational)
    goto wrapup;

  BScvkttol2(in_cv->order, in_cv->knots, in_cv->num_poles, in_cv->poles,
             in_cv->weights,& knot_tol, rc);
  if (BSERROR(*rc))
    goto wrapup;

  BSEXTRACTPAR(rc, BSTOLCLOSETOZERO, zero_tol);

  /* Set rational bit to FALSE if all the weights are identical
     or if curve is of order 2                                 */

  if (in_cv->rational)
  {
    if (in_cv->order == 2)
      same_weights = TRUE;
    else
    {
      chkwtsBSftnrcvtcv (in_cv, zero_tol, &same_weights, rc);
      if(BSERROR(*rc))
        goto wrapup;
    }

    if (same_weights)
    {
      ptr  = in_cv->poles;
      wptr = in_cv->weights;
      for (i = 0; i < in_cv->num_poles; ++i)
      {
        for(j=0; j< 3; j++)
        {
          *ptr = *ptr / *wptr;
          ptr++;
        }
        wptr++;
      }
      in_cv->rational = FALSE;
      if (in_cv->weights)
      {
        /*BSdealloc((char *) in_cv->weights);*/
        in_cv->weights = NULL;
      }
      conv = 1;
    }
  }

wrapup:

  if(BSERROR(*rc))
    BSdbgrc(*rc,"BSrmcvwghts");
  return conv;
}
