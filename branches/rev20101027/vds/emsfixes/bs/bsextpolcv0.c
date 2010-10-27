/*
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name 
  BSextpolcv0
 
Abstract
  This function performs a polynomial extrapolation on a curve by modifying its
poles and knots. 

Synopsis
  void BSextpolcv0 (cv_in, par_in, turn, cv_out, par_out, rc)
    struct     IGRbsp_curve *cv_in;
    IGRdouble  par_in;
    IGRboolean *turn;
    struct     IGRbsp_curve **cv_out;
    IGRdouble  *par_out;
    BSrc       *rc;

Description
  Input:
    cv_in   - the curve to be extended.
    par_in  - input parameter.

  Input/Output:
    turn    - input:  whether to check if curve extension turns back on itself
                      or self-intersects.
              output: whether curve extension turns back on itself or self-
                      intersects. This value is only valid if on input "turn"
                      is TRUE.

  Output:
    cv_out  - the extended curve.
    par_out - output parameter. This will be the same as "par_in" unless the
              input parameter was "limited" in order to "correct" negative
              weights, if the curve turned back on itself, or if the curve self-
              intersected.
    rc      - possible return codes include:
                BSSUCC.
                BSINARG.
                BSNOSTKMEMORY.
                BSOUTOFDESN.
                BSFAIL.

  Algorithm:
    This routine is a driver routine for the polynomial curve extension code
  developed by Jean-Luc Loschutz using the "blossoming" technique.
  
Return Values

Notes
  1) If the extended curve turns back on itself, then the turning point is found
     and the extended curve is recreated with the extension parameter set to the
     turning point. "Turn" must be set to TRUE upon input for the code to check
     for such a curve. The output will then be set as follows:
       "turn"    = TRUE,
       "par_out" = parameter at turning point.

  2) If the extended curve self-intersects, then the input curve is copied to
     the output curve. In other words, no extension is performed. "Turn" must be
     set to TRUE upon input for the code to check for such a curve. The output
     will then be set as follows:
       "turn"    = TRUE,
       "par_out" = start or end parameter of input curve, depending on "side"
                   of desired extension.

  3) If the extended curve turns back on itself, and the turning point is
     "inside" the input curve, then the output is the same as in #2.

Index
  md

Keywords

History        
  P.R. Slubicki 07/30/92: creation date.      
  P.R. Slubicki 11/09/92: added the argument "chg_wts".
  P.R. Slubicki 12/08/92: removed the argument "chg_wts". The end weights are
                          no longer changed to 1.0 in this routine.
  S.G. Catron   04/09/93: Added code to check for extensions turning
                          back on themselves.  If this happens, only
                          extend curve to point at which it does not loop
                          back. Added an argument for this that is 
                          input/output. On input if "turn" = TRUE, then 
                          curve is checked for turns.  If there is a turn,
                          then "turn" is set to TRUE for output(FALSE
                          otherwise).  TR 11925613
  D. Breden     07/02/93: Assure that output parameters of BSpl_cv_int()
                          are in ascending order.
  P.R. Slubicki 10/09/93: I added code to set *cv_out to NULL after freeing.
  P.R. Slubicki 10/20/93: If a turn is detected within the endpoints of the
                          original curve, I return a non-extended curve.
  P.R. Slubicki 10/29/93: While testing if a curve turns back on itself, I now
                          use "if (dist1 < 10.0 * cht)" instead of 
                          "if (dist1 < cht)".
  D. Breden     10/31/93: Reset rc to BSSUCC if BSfndcvturn fails with 
                          BSFAIL.
  S.G. Catron   01/23/95: added #undef for MAX_POLES
  S.G. Catron   08/31/95: When finding initial guess parameter for turn,
                          only use values which are on extended section.
  P.R. Slubicki 10/17/95: I changed the method of memory management for the 
                          BSpl_cv_int() output.
  P.R. Slubicki 10/18/95: a) I added code to handle the case in which the
                             extension curve self-intersects.
                          b) If the extension curve turns back on itself, and
                             the turning point is "inside" the input curve,
                             then I return the output described in note #3
                             above.
  P.R. Slubicki 10/25/95: I modified the above change (a) to allow the extension
                          curve to self-overlap, but not self-intersect.
  S.G. Catron   01/30/96 : After call to BScv_slfint, if nover, then set
                           par_out = parameter nearest extension end.
  Vivian Y.Hsu  02/26/98 : The above fixes break case where overlap is on
                           the other side of extension. Now we do this:
                           If n_over != 0 and the overlap is occured on
                           the extension end, then we set par_out = 
                           parameter nearest extendsion end.
                    
*/

#include "bstypes.h"
#include "bsdefs.h"
#include "bserr.h"
#include "bsmemory.h"
#include "bsparameters.h"
#include <math.h>
#include "bsmalloc.h"

#define LEFT      0
#define RIGHT     1
#undef  MAX_POLES
#define MAX_POLES 300
#define LENGTH    1.0e-10

void BSextpolcv0 (
  struct IGRbsp_curve *cv_in,
  IGRdouble           par_in,
  IGRboolean          *turn,
  struct IGRbsp_curve **cv_out,
  IGRdouble           *par_out,
  BSrc                *rc )

  {
  #include "bsdbgrc.h"
  #include "bsadd_kt2r.h"
  #include "bsalloccv.h"
  #include "bsbzur1pls.h"
  #include "bscv_copy.h"
  #include "bscv_slfint.h"
  #include "bscveval.h"
  #include "bscvkttol2.h"
  #include "bsdistptpt.h"
  #include "bsextpolcv1.h"
  #include "bsfndcvturn.h"
  #include "bsfreecv.h"
  #include "bslenvec.h"
  #include "bsnorkts.h"
  #include "bspl_cv_int.h"
  #include "bsstackalloc.h"
  /* Local variables */
  BSrc       rc2;
  IGRint     i;
  IGRint     order, num_poles;
  IGRint     num_k_insertions;
  IGRint     mul;
  IGRint     degree;
  IGRint     num_solns;
  IGRint     n_int, n_over, n_seg;
  IGRint     nd1 = 1;
  IGRlong    N;
  IGRshort   dim;
  IGRpoint   eval[2], point;
  IGRdouble  wt_tol = 0.002;
  IGRdouble  low_knot, high_knot;
  IGRdouble  new_knot;
  IGRdouble  epsilon, epsilon2;
  IGRdouble  interval[2];
  IGRdouble  *pls, *wts, *pwts;
  IGRdouble  *poles_wts;
  IGRdouble  *wt_func;
  IGRdouble  sol, solns[2];
  IGRdouble  ipar, cht, dist1, mdist;
  IGRdouble  knot, splitpar;
  IGRdouble  turnpar, knot_tol, len, swpar;
  IGRdouble  *pts, *uu, *a, *b;
  IGRdouble  *a_par = NULL, *b_par = NULL;
  IGRdouble  *c_over = NULL, *d_over = NULL, *e_over = NULL, *f_over = NULL;
  IGRdouble  *work_area = NULL, a_work_area[4 * MAX_POLES + MAX_ORDER];
  IGRdouble  *work_area2 = NULL, a_work_area2[6 * MAX_POLES];
  IGRboolean neg_wt;
  IGRboolean tturn, extend;
  
  *rc = BSSUCC;

  *par_out = par_in;

  order = (IGRint) cv_in->order;
  num_poles = (IGRint) cv_in->num_poles;

  if (order > MAX_ORDER)
    {
    *rc = BSINARG;
    goto wrapup;
    }

  BScvkttol2( cv_in->order, cv_in->knots, cv_in->num_poles, cv_in->poles, 
              cv_in->weights, &knot_tol, rc);
  if (BSERROR(*rc))
    goto wrapup;

  low_knot = cv_in->knots[order - 1];
  high_knot = cv_in->knots[num_poles];

  if (par_in > low_knot
   && par_in < high_knot)
    {
    *rc = BSINARG;
    goto wrapup;
    }
  /* set extend end */
  if( par_in > high_knot )
    extend = 1;
  else
    extend = 0;

  neg_wt = FALSE;

  BSalloccv ((IGRshort) order, num_poles, cv_in->rational, (IGRshort) 0,
             cv_out, rc);
  if (BSERROR (*rc))
    goto wrapup;

  if (cv_in->rational)
    {
    dim = 4;

    if (num_poles > MAX_POLES)
      {
      work_area = (IGRdouble *) BSstackalloc ((4 * num_poles + order) *
                                              sizeof(IGRdouble));
      if (!work_area)
        {
        *rc = BSNOSTKMEMORY;
        goto wrapup;
        }
        
      poles_wts = work_area;
      } /* end if (num_poles > MAX_POLES) */
      
    else
      poles_wts = a_work_area;
      
    wt_func = poles_wts + 4 * num_poles;

    pls = cv_in->poles;
    wts = cv_in->weights;    
    pwts = poles_wts;

    for (i = 0; i < num_poles; i++)
      {
      *pwts++ = *pls++;
      *pwts++ = *pls++;
      *pwts++ = *pls++;

      *pwts++ = *wts++;
      } /* end for (i = 0; i < num_poles; i++) */
      
    BSextpolcv1 (dim, order, num_poles, poles_wts, cv_in->knots, low_knot, 
                 high_knot, par_in, poles_wts, (*cv_out)->knots, rc);
    if (BSERROR (*rc))
      goto wrapup;

    pls = (*cv_out)->poles;
    pwts = poles_wts;
    wts = (*cv_out)->weights;    

    for (i = 0; i < num_poles; i++)
      {
      *pls++ = *pwts++;
      *pls++ = *pwts++;
      *pls++ = *pwts++;

      *wts = *pwts++;

      if (*wts++ < wt_tol)
        neg_wt = TRUE;
      } /* end for (i = 0; i < num_poles; i++) */

    if (!neg_wt)
      {
      (*cv_out)->order = (IGRshort) order;
      (*cv_out)->periodic = cv_in->periodic;
      (*cv_out)->non_uniform = TRUE;
      (*cv_out)->num_poles = num_poles;
      (*cv_out)->num_knots = order + num_poles;
      (*cv_out)->rational = cv_in->rational;
      (*cv_out)->planar = cv_in->planar;
      (*cv_out)->phy_closed = cv_in->phy_closed;
      (*cv_out)->num_boundaries = (IGRshort) 0;
      (*cv_out)->bdrys = NULL;
      } /* end if (!neg_wt) */

    else /* if (neg_wt) */
      {
      /* We first try to solve the negative weight problem by "limiting" the
       * extension parameter and recursively calling BSextpolcv0(). We do this
       * by solving the equation w(t) - epsilon = 0 and by using the solution,
       * transformed back to the original cv_in, as the restricted extension
       * parameter. If there is more than one solution to this equation, we take
       * the solution closest to the original endpoint of the cv_in. If there
       * are no solutions, we insert knots into the extended cv_in until all the
       * weights are positive or until we have inserted order - 1 knots. If this
       * fails, then we set *rc = BSOUTOFDESN and exit.
       */
      degree = order - 1;
      
      interval[0] = 0.0;
      interval[1] = 1.0;

      epsilon = 2 * wt_tol;

      if (extend)
        wts = (*cv_out)->weights + num_poles - order;    
        
      else
        wts = (*cv_out)->weights;

      for (i = 0; i < order; i++)
        wt_func[i] = *wts++ - epsilon;

      epsilon2 = epsilon / 10.0;

      BSbzur1pls (degree, wt_func, interval, epsilon2, &num_solns, solns, rc);
      if (BSERROR (*rc))
        goto wrapup;

      if (num_solns)
        {
        if (extend)
          {
          if (num_solns == 1
           || solns[0] < solns[1])
            sol = solns[0];
          
          else
            sol = solns[1];

          *par_out = cv_in->knots[num_poles - 1] +
                     sol * (par_in - cv_in->knots[num_poles - 1]);
          } /* end if (par_in > high_knot) */

        else /* if (par_in < low_knot) */
          {
          if (num_solns == 1
           || solns[0] > solns[1])
            sol = solns[0];
          
          else
            sol = solns[1];

          *par_out = cv_in->knots[order] + 
                     (1.0 - sol) * (par_in - cv_in->knots[order]);
          } /* end if (par_in < low_knot) */

        (void) BSfreecv (rc, *cv_out);
        *cv_out = NULL;
        if (BSERROR (*rc))
          goto wrapup;

        BSextpolcv0 (cv_in, *par_out, turn, cv_out, par_out, rc);
        goto wrapup;
        } /* end if (num_solns) */

      else /* if (!num_solns) */
        {
        (*cv_out)->order = (IGRshort) order;
        (*cv_out)->periodic = cv_in->periodic;
        (*cv_out)->non_uniform = TRUE;
        (*cv_out)->num_poles = num_poles;
        (*cv_out)->num_knots = order + num_poles;
        (*cv_out)->rational = cv_in->rational;
        (*cv_out)->planar = cv_in->planar;
        (*cv_out)->phy_closed = cv_in->phy_closed;
        (*cv_out)->num_boundaries = (IGRshort) 0;
        (*cv_out)->bdrys = NULL;

        num_k_insertions = 0;

        if (extend)
          new_knot = high_knot;
        
        else /* if (par_in < low_knot) */
          new_knot = low_knot;

        mul = 1;

        while (neg_wt
            && num_k_insertions < order - 1)
          {
          BSadd_kt2r (rc, *cv_out, &new_knot, &mul, FALSE);
          if (BSERROR (*rc))
            goto wrapup;

          num_poles++;
          num_k_insertions++;
          neg_wt = FALSE;

          wts = (*cv_out)->weights;    

          for (i = 0; i < num_poles; i++)
            if (*wts++ < wt_tol)
              {
              neg_wt = TRUE;
              break;
              }

          } /* end while (neg_wt && num_k_insertions < order - 1) */

        if (neg_wt)
          {
          *rc = BSOUTOFDESN;
          goto wrapup;
          }

        } /* end else if (!num_solns) */
        
      } /* end else if (neg_wt) */

    } /* end if (cv_in->rational) */
    
  else /* if (!cv_in->rational) */
    {
    dim = 3;

    BSextpolcv1 (dim, order, num_poles, cv_in->poles, cv_in->knots, low_knot, 
                 high_knot, par_in, (*cv_out)->poles, (*cv_out)->knots, rc);
    if (BSERROR (*rc))
      goto wrapup;

    (*cv_out)->order = (IGRshort) order;
    (*cv_out)->periodic = cv_in->periodic;
    (*cv_out)->non_uniform = TRUE;
    (*cv_out)->num_poles = num_poles;
    (*cv_out)->num_knots = order + num_poles;
    (*cv_out)->rational = cv_in->rational;
    (*cv_out)->planar = cv_in->planar;
    (*cv_out)->phy_closed = cv_in->phy_closed;
    (*cv_out)->num_boundaries = (IGRshort) 0;
    (*cv_out)->bdrys = NULL;
    } /* end else if (!cv_in->rational) */

  if (*turn)
    {
    /* Before returning curve, check to see if curve loops back on itself. */
    *turn = FALSE;

    BScveval (*cv_out, *par_out, nd1, eval, rc);
    if (BSERROR (*rc))
      goto wrapup;

    len = BSlenvec (rc, eval[1]);
    if (len <   LENGTH)
      goto wrapup;

    N = (*cv_out)->num_poles;

    if (N > MAX_POLES)
      {
      work_area2 = (IGRdouble *) BSstackalloc (6 * N * sizeof (IGRdouble));
      if (!work_area2)
        {
        *rc = BSNOSTKMEMORY;
        goto wrapup;
        }

      pts = work_area2;
      }

    else
      pts = a_work_area2;

    uu = pts + N * 3;
    a  = uu  + N;
    b  = a   + N;

    BSEXTRACTPAR (rc, BSTOLCHRDHT, cht);

    (void) BSpl_cv_int (rc, *cv_out, eval[0], eval[1], &n_int, pts, uu, &n_seg,
                        a, b);
    if (BSERROR(*rc))
      goto wrapup;  

    if (n_int == 2)
      {
      if (uu[0] > uu[1])
        {
        swpar = uu[0];
        uu[0] = uu[1];
        uu[1] = swpar;
        }

      /* Check if the points are within cht. */
      dist1 = BSdistptpt (rc, pts, &pts[3]);
      if (BSERROR (*rc))
        goto wrapup;

      if (dist1 < 10.0 * cht)
        {
        ipar = (uu[0] + uu[1]) / 2.0;

        if (!extend && ipar > low_knot)
          ipar = low_knot;

        else if (extend && ipar > high_knot)
          ipar = high_knot;

        BSfndcvturn (*cv_out, eval[1], ipar, &turnpar, point, rc);
        if (BSERROR (*rc))
          {
          if (*rc == BSFAIL)
            *rc = BSSUCC;

          goto wrapup;
          }

        /* Make sure turnpar is within uu[0] and uu[1]. */
        if (turnpar < uu[0]
         || turnpar > uu[1])
          goto wrapup;

        *turn = TRUE;

        if (turnpar < cv_in->knots[order - 1])
          turnpar += knot_tol;

        else
          turnpar -= knot_tol;

        tturn = FALSE;

        /* If "turnpar" is within the endpoints of "cv_in", copy "cv_in" to
         * "cv_out" and "par_in" to "par_out". Otherwise, attempt an extension
         * to "turnpar".
         */
        if (turnpar > low_knot
         && turnpar < high_knot)
          {
          (void) BScv_copy (rc, cv_in, *cv_out);
          if (BSERROR(*rc))
            goto wrapup;

          if (!extend)
            *par_out = low_knot;

          else
            *par_out = high_knot;
          }

        else
          {
          (void) BSfreecv (rc, *cv_out);
          *cv_out = NULL;
          if (BSERROR (*rc))
            goto wrapup;
        
          BSextpolcv0 (cv_in, turnpar, &tturn, cv_out, par_out, rc);
          if (BSERROR(*rc))
            goto wrapup;

          *par_out = turnpar;
          }

        } /* end if (dist1 < 10.0 * cht) */

      } /* end if (n_int == 2) */

    else if (n_int != 2)
      {
      /* Check if the extension curve self-intersects. If so, copy "cv_in" to
       * to "cv_out". Also, set "par_out" to the start or end parameter of 
       * "cv_in", depending on the "side" of the requested extension.
       */
      (void) BScv_slfint (&rc2, *cv_out, &n_int, &a_par, &b_par, &n_over, &c_over,
                          &d_over, &e_over, &f_over);
      if (BSOKAY (rc2))
        {
        if (n_over)
          {

            /* find the closest parameter to extend end of cv_in */

            if( extend )
            {
              knot = high_knot;

              /* If overlap is not on the extension side. exit */

              if ((c_over[0] < knot && d_over[0] < knot) &&
                  (e_over[0] < knot && f_over[0] < knot))
                goto wrapup;
            }
            else
            {
              knot = low_knot;
              /* If overlap is not on the extension side. exit */
              if ((c_over[0] > knot && d_over[0] > knot) &&
                  (e_over[0] > knot && f_over[0] > knot))
                goto wrapup;
            }
            splitpar = c_over[0];
            mdist = fabs(knot - c_over[0]);
            dist1 = fabs(knot - d_over[0]);
            if( dist1 < mdist )
            {
              mdist = dist1;
              splitpar = d_over[0];
            }
            dist1 = fabs(knot - e_over[0]);
            if( dist1 < mdist )
            {
              mdist = dist1;
              splitpar = e_over[0];
            }
            dist1 = fabs(knot - f_over[0]);
            if( dist1 < mdist )
            {
              mdist = dist1;
              splitpar = f_over[0];
            }
            *par_out = splitpar;
            *turn = 2;
          }
        else if( n_int )
          {
            (void) BScv_copy (rc, cv_in, *cv_out);
            if (BSERROR(*rc))
              goto wrapup;

            *turn = TRUE;

            if (!extend)
              *par_out = low_knot;

            else
              *par_out = high_knot;
          } /* end if (n_int) */
        
        } /* end if BSOKAY (rc2)) */

      } /* end else if (n_int != 2) */

    } /* end if (*turn) */

wrapup:

  if (a_par)
    BSdealloc ((char *) a_par);

  if (b_par)
    BSdealloc ((char *) b_par);

  if (c_over)
    BSdealloc ((char *) c_over);

  if (d_over)
    BSdealloc ((char *) d_over);

  if (e_over)
    BSdealloc ((char *) e_over);

  if (f_over)
    BSdealloc ((char *) f_over);

  if (work_area2)
    BSstackdealloc ((char *) work_area2);

  if (work_area)
    BSstackdealloc ((char *) work_area);

  if (BSERROR (*rc))
    BSdbgrc (*rc, "BSextpolcv0");

  return;
  } /* end BSextpolcv0() */
