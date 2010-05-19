/*
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
  BSchkfxsf2

Abstract
  This routine checks a surface for pole multiplicities of order - 1. If any
exist, this routine attempts to replace the pole multiplicities with equivalent
knot multiplicities while retaining the shape of the surface.

Synopsis
  void BSchkfxsf2 (sf, outsf, rc)
    struct   IGRbsp_surface *sf;
    struct   IGRbsp_surface **outsf;
    BSrc     *rc;

Description
  Input:
    sf    - the surface to be checked for pole multiplicities.
    
  Output:
    outsf - the corrected version of the input surface.
    rc    - BSSUCC if routine execution is successful.

  Algorithm:
  
Return Values
    
Notes
  1) The memory for the output surface is allocated by this routine.

  2) Although I have attempted to generalize the algorithm as much as possible,
     this code will currently only work on input surfaces of K = 4 and L = 4.

Index
  em

Keywords

History
  P.R. Slubicki 10/05/92 : Creation date.
  Sherry Catron 10/28/92 : added code to handle pole multiplicities of
                           K - 2 and L - 2.
  D. Breden     08/27/94 : Modified routine to not check for any pole
                           multiplicities if one or more surface edges
                           are degenerate.
  S.G. Catron   10/08/99 : TR 8096 - This routine had a problem when the
                           the edge was degenerate.  At u=1, it was accessing
                           poles out of range trying to make a pole_vec.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bsparameters.h"
#include "bserr.h"
#include "bsmemory.h"
#include "bsvalues.h"
#include "bsstk.h"
#endif

#define BSVOID

#include <math.h>

void BSchkfxsf2 (
  struct   IGRbsp_surface *sf,
  struct   IGRbsp_surface **outsf,
  BSrc     *rc)
  {
#ifndef DONOTSPROTO
  #include "bsdbgrc.h"
  #include "bsadd_ukt2r.h"
  #include "bsadd_vkt2r.h"
  #include "bsallocsf.h"
  #include "bscvkttol2.h"
  #include "bsdistptpt.h"
  #include "bsfreesf.h"
  #include "bslenvec.h"
  #include "bsnorvec.h"
  #include "bssfkttol2.h"
  #include "bststsfdegn.h"
  #include "bssf_copy.h"
#endif 

  /* local variables */
  BSrc       rc2;
  IGRint     i, j, k, l, n;
  IGRint     K, L, N, N2, M, M2;
  IGRint     mul, m;
  IGRint     num_insertions, num_u_insertions, num_v_insertions;
  IGRint     num_row_insertions;
  IGRint     num_out_pls;
  IGRint     num_problem_u_poles, num_problem_v_poles;
  IGRint     increm;
  IGRint     first, second, third;
  IGRint     one, two, three;
  IGRint     prevfirst, last;
  IGRint     *pps, *max_pp;
  IGRint     *problem_u_poles = NULL, *problem_v_poles = NULL; 
  IGRint     *u_knot_insertion = NULL, *v_knot_insertion = NULL;
  IGRint     *u_pole_insertion = NULL, *v_pole_insertion = NULL;
  IGRint     *u_work = NULL, *v_work = NULL;
  IGRpoint   uwp[2];
  IGRpoint   base_pole;
  IGRvector  pole_vec, pole_vec1, pole_vec2;
  IGRdouble  u, v;
  IGRdouble  dist, dist1, dist2;
  IGRdouble  np_dist;
  IGRdouble  pole_dist;
  IGRdouble  knot_tol, basis_tol, basis_tol_100;
  IGRdouble  *pls, *wts;
  IGRboolean rational;
  IGRboolean problem_v_poles_exist;
  IGRboolean enough_memory = TRUE;
  IGRboolean us_degn=FALSE, ue_degn=FALSE, vs_degn=FALSE, ve_degn=FALSE;

  struct IGRbsp_surface *tsf = NULL, *usf = NULL;

  *rc = BSSUCC;

  K = (IGRint) sf->u_order;
  L = (IGRint) sf->v_order;
  N = (IGRint) sf->u_num_poles;
  M = (IGRint) sf->v_num_poles;

  /* Currently this code can only handle bicubic surfaces. */
  if (K != 4
   || L != 4)
    {
    *rc = BSINARG;
    goto wrapup;
    }

  BStstsfdegn(sf, &us_degn, &ue_degn, &vs_degn, &ve_degn, rc);
  if (BSERROR(*rc))
    goto wrapup;

  if (us_degn || ue_degn || vs_degn || ve_degn)
    {
    BSallocsf(sf->u_order,sf->v_order,sf->u_num_poles,
              sf->v_num_poles,sf->rational,0,outsf,rc);
    if(BSERROR(*rc))
      goto wrapup;

    (void)BSsf_copy(rc,sf,*outsf);
    goto wrapup;
    }

  BSsfkttol2 (sf->u_order, sf->v_order, sf->u_knots, sf->v_knots, 
              sf->u_num_poles, sf->v_num_poles, sf->poles, sf->weights,
              &knot_tol, rc);
  if (BSERROR(*rc))
    goto wrapup;

  BSEXTRACTPAR (rc, BSTOLBASIS, basis_tol);
  if (BSERROR(*rc))
    goto wrapup;

  basis_tol_100 = basis_tol * 100.0;
  rational = sf->rational;

  BSallocsf ((IGRshort) K, (IGRshort) L, (IGRlong) N, (IGRlong) M, rational,
             (IGRshort) 0, &tsf, rc);
  if (BSERROR (*rc))
    goto wrapup;

  tsf->u_order = (IGRshort) K;
  tsf->v_order = (IGRshort) L;
  tsf->u_periodic = sf->u_periodic;
  tsf->v_periodic = sf->v_periodic;
  tsf->u_non_uniform = sf->u_non_uniform;
  tsf->v_non_uniform = sf->v_non_uniform;
  tsf->rational = sf->rational;
  tsf->planar = sf->planar;
  tsf->u_phy_closed = sf->u_phy_closed;
  tsf->v_phy_closed = sf->v_phy_closed;
  tsf->pos_orient = sf->pos_orient;
  tsf->on_off = sf->on_off;

  BSMEMCPY ((IGRint) (N * M * sizeof(IGRpoint)), (IGRchar *) sf->poles,
            (IGRchar *) tsf->poles);

  if (rational)
    BSMEMCPY ((IGRint) (N * M * sizeof(IGRdouble)), (IGRchar *) sf->weights,
              (IGRchar *) tsf->weights);

  BSMEMCPY ((IGRint) ((K + N) * sizeof(IGRdouble)), (IGRchar *) sf->u_knots,
            (IGRchar *) tsf->u_knots);

  BSMEMCPY ((IGRint) ((L + M) * sizeof(IGRdouble)), (IGRchar *) sf->v_knots,
            (IGRchar *) tsf->v_knots);

  tsf->u_num_poles = (IGRlong) N;
  tsf->v_num_poles = (IGRlong) M;
  tsf->u_num_knots = sf->u_num_knots;
  tsf->v_num_knots = sf->v_num_knots;

  pls = tsf->poles;
  wts = tsf->weights;

  /* Preprocess and flag the problem poles in u. */
  u_work = (IGRint *) BSstackalloc ((2 * N * M + N) * sizeof(IGRint));
  if (!u_work)
    {
    *rc = BSNOSTKMEMORY;
    goto wrapup;
    }

  problem_u_poles = u_work;
  u_pole_insertion = problem_u_poles + N * M;
  u_knot_insertion = u_pole_insertion + N * M;

  for (i = 0; i < N; i++)
    u_knot_insertion[i] = 0;

  num_u_insertions = 0;
  num_problem_u_poles = 0;

  for (k = 0; k < M; k++)
    {
    mul = 1;

    for (i = k * N, l = 0; l < N - 1; i++, l++)
      {
      if (rational)
        {
        for (j = 0; j < 3; j++)
          {
          uwp[0][j] = pls[3 * i + j] / wts[i];
          uwp[1][j] = pls[3 * (i + 1) + j] / wts[i + 1];
          }

        pole_dist = BSdistptpt (rc, uwp[0], uwp[1]);
        } /* end if (rational) */
      
      else
        pole_dist = BSdistptpt (rc, &pls[3 * i], &pls[3 * (i + 1)]);

      if (pole_dist < basis_tol)
        mul++;
      
      else /* if (pole_dist >= basis_tol) */
        {
        if (mul >= K - 1)
          {
          if (l == mul - 1)
            /* The multiple poles start at u = 0. */
            problem_u_poles[num_problem_u_poles] = k * N + 1;

          else /* if (l > mul - 1) */
            {
            problem_u_poles[num_problem_u_poles] = i - mul / 2;

            n = l - mul / 2;

            if (!u_knot_insertion[n])
              {
              /* Determine the multiplicity of u already in the knot sequence.
               */
              u = tsf->u_knots[n + 2];
              m = 0;

              for (j = L; j < N; j++)
                if (fabs (tsf->u_knots[j] - u) < knot_tol)
                  m++;

                else if (m) 
                  break;

              num_u_insertions += ((K - 1) - m);
              u_knot_insertion[n] = (K - 1) - m;
              } /* end if (!u_knot_insertion[n]) */

            u_pole_insertion[num_problem_u_poles] = u_knot_insertion[n];
            } /* end else if (l > mul - 1) */

          num_problem_u_poles++;

          if (mul > K - 1)
            {
            if (l == mul - 1)
              {
              /* The multiple poles start at u = 0. */
              if (rational)
                for (j = 0; j < 3; j++)
                  pole_vec[j] = uwp[1][j] - uwp[0][j];

              else
                for (j = 0; j < 3; j++)
                  pole_vec[j] = pls[3 * (i + 1) + j] - pls[3 * i + j];

              np_dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);
              dist = 3 * np_dist;

              (void) BSnorvec (rc, pole_vec);
              if (BSERROR (*rc))
                goto wrapup;

              for (n = k * N + K - 1; n < k * N + mul; n++)
                {
                if (rational)
                  for (j = 0; j < 3; j++)
                    pls[3 * n + j] = pls[3 * n + j] / wts[n] +
                                     dist * pole_vec[j];
              
                else
                  for (j = 0; j < 3; j++)
                    pls[3 * n + j] += dist * pole_vec[j];

                dist += np_dist;
                } /* end for (n = k * N + K - 1; n < k * N + mul; n++) */
              
              } /* end if (l == mul - 1) */

            else /* if (l > mul - 1) */
              {
              if (rational)
                for (j = 0; j < 3; j++)
                  pole_vec[j] = pls[3 * (i - mul) + j] / wts[i - mul] -
                                pls[3 * (i - mul + 1) + j] / wts[i - mul + 1];

              else
                for (j = 0; j < 3; j++)
                  pole_vec[j] = pls[3 * (i - mul) + j] -
                                pls[3 * (i - mul + 1) + j];

              np_dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);
              dist = 3 * np_dist;

              (void) BSnorvec (rc, pole_vec);
              if (BSERROR (*rc))
                goto wrapup;

              num_out_pls = (mul - (K - 1)) / 2;

              for (n = i - mul + num_out_pls; n > i - mul; n--)
                {
                if (rational)
                  for (j = 0; j < 3; j++)
                    pls[3 * n + j] = pls[3 * n + j] / wts[n] +
                                     dist * pole_vec[j];
              
                else
                  for (j = 0; j < 3; j++)
                    pls[3 * n + j] += dist * pole_vec[j];

                dist += np_dist;
                } /* end for (n = i - mul + num_out_pls; n > i - mul; n--) */

              if (rational)
                for (j = 0; j < 3; j++)
                  pole_vec[j] = pls[3 * (i + 1) + j] / wts[i + 1] -
                                pls[3 * i + j] / wts[i];

              else
                for (j = 0; j < 3; j++)
                  pole_vec[j] = pls[3 * (i + 1) + j] - pls[3 * i + j];

              np_dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);
              dist = 3 * np_dist;

              (void) BSnorvec (rc, pole_vec);
              if (BSERROR (*rc))
                goto wrapup;

              if ((mul - (K - 1)) % 2)
                num_out_pls++;
              
              for (n = i - num_out_pls + 1; n < i + 1; n++)
                {
                if (rational)
                  for (j = 0; j < 3; j++)
                    pls[3 * n + j] = pls[3 * n + j] / wts[n] +
                                     dist * pole_vec[j];
              
                else
                  for (j = 0; j < 3; j++)
                    pls[3 * n + j] += dist * pole_vec[j];

                dist += np_dist;
                } /* end for (n = i - num_out_pls + 1; n < i + 1; n++) */
             
              } /* end else if (l > mul - 1) */

            } /* end if (mul > K - 1) */

          } /* end if (mul >= K - 1) */

        mul = 1;
        } /* end else if (pole_dist >= basis_tol) */

      } /* end for (i = k * N, l = 0; l < N - 1; i++, l++) */

    if (mul >= K - 1)
      {
      /* The multiple poles end at u = 1. */
      problem_u_poles[num_problem_u_poles++] = i - 1;

      /* 10/08/99 - added code here to not do anything if mul == M  */
      if (mul > K - 1 && mul < M)
        {
        if (rational)
          for (j = 0; j < 3; j++)
            pole_vec[j] = pls[3 * (k * N + N - mul - 1) + j] /
                          wts[k * N + N - mul - 1] -
                          pls[3 * (k * N + N - mul) + j] /
                          wts[k * N + N - mul];

        else
          for (j = 0; j < 3; j++)
            pole_vec[j] = pls[3 * (k * N + N - mul - 1) + j] -
                          pls[3 * (k * N + N - mul) + j];

        np_dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);
        dist = 3 * np_dist;

        (void) BSnorvec (rc, pole_vec);
          if (BSERROR (*rc))
            goto wrapup;

        for (l = k * N + N - 1 - (K - 1); l > k * N + N - mul - 1; l--)
          {
          if (rational)
            for (j = 0; j < 3; j++)
               pls[3 * l + j] = pls[3 * l + j] / wts[l] + dist * pole_vec[j];
              
          else
            for (j = 0; j < 3; j++)
              pls[3 * l + j] += dist * pole_vec[j];

          dist += np_dist;
          } /* end for */

        } /* end if (mul > K - 1) */

      } /* end if (mul >= K - 1) */
      
    } /* end for (k = 0; k < M; k++) */

  /* Preprocess the problem poles in v‚. */
  problem_v_poles_exist = FALSE;

  for (i = 0; i < N; i++)
    {
    mul = 1;

    for (k = 0; k < M - 1; k++)
      {
      if (rational)
        {
        for (j = 0; j < 3; j++)
          {
          uwp[0][j] = pls[3 * (k * N + i) + j] / wts[k * N + i];
          uwp[1][j] = pls[3 * ((k + 1) * N + i) + j] / wts[(k + 1) * N + i];
          }

        pole_dist = BSdistptpt (rc, uwp[0], uwp[1]);
        } /* end if (rational) */
      
      else
        pole_dist = BSdistptpt (rc, &pls[3 * (k * N + i)],
                               &pls[3 * ((k + 1) * N + i)]);

      if (pole_dist < basis_tol)
        mul++;

      else /* if (pole_dist >= basis_tol) */
        {
        if (mul >= L - 1)
          {
          problem_v_poles_exist = TRUE;
          
          if (mul > L - 1)
            {
            if (k == mul - 1)
              {
              /* The multiple poles start at v = 0. */
              if (rational)
                for (j = 0; j < 3; j++)
                  pole_vec[j] = uwp[1][j] - uwp[0][j];

              else
                for (j = 0; j < 3; j++)
                  pole_vec[j] = pls[3 * ((k + 1) * N + i) + j] - 
                                pls[3 * (k * N + i) + j];
   
              np_dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);
              dist = 3 * np_dist;

              (void) BSnorvec (rc, pole_vec);
              if (BSERROR (*rc))
                goto wrapup;

              for (l = N * (L - 1); l < N * mul; l += N)
                {
                if (rational)
                  for (j = 0; j < 3; j++)
                    pls[3 * (l + i) + j] = pls[3 * (l + i) + j] / wts[l + i] +
                                           dist * pole_vec[j];
              
                else
                  for (j = 0; j < 3; j++)
                    pls[3 * (l + i) + j] += dist * pole_vec[j];

                dist += np_dist;
                } /* end for (l = N * (L - 1); l < N * mul; l += N) */
              
              } /* end if (k == mul - 1) */

            else /* if (k > mul - 1) */
              {
              if (rational)
                for (j = 0; j < 3; j++)
                  pole_vec[j] = pls[3 * ((k - mul) * N + i) + j] /
                               wts[(k - mul) * N + i] -
                               pls[3 * ((k - mul + 1) * N + i) + j] /
                               wts[(k - mul + 1) * N + i];

              else
                for (j = 0; j < 3; j++)
                  pole_vec[j] = pls[3 * ((k - mul) * N + i) + j] -
                                pls[3 * ((k - mul + 1) * N + i) + j];

              np_dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);
              dist = 3 * np_dist;

              (void) BSnorvec (rc, pole_vec);
              if (BSERROR (*rc))
                goto wrapup;

              num_out_pls = (mul - (L - 1)) / 2;

              for (l = N * (k - mul + num_out_pls); l > N * (k - mul); l -= N)
                {
                if (rational)
                  for (j = 0; j < 3; j++)
                    pls[3 * (l + i) + j] = pls[3 * (l + i) + j] / wts[l + i] + 
                                           dist * pole_vec[j];
              
                else
                  for (j = 0; j < 3; j++)
                    pls[3 * (l + i) + j] += dist * pole_vec[j];

                dist += np_dist;
                } /* end for */

              if (rational)
                for (j = 0; j < 3; j++)
                  pole_vec[j] = pls[3 * ((k + 1) * N + i) + j] /
                                wts[(k + 1) * N + i] -
                                pls[3 * (k * N + i) + j] /
                                wts[k * N + i];

              else
                for (j = 0; j < 3; j++)
                  pole_vec[j] = pls[3 * ((k + 1) * N + i) + j] - 
                                pls[3 * (k * N + i) + j];

              np_dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);
              dist = 3 * np_dist;

              (void) BSnorvec (rc, pole_vec);
              if (BSERROR (*rc))
                goto wrapup;

              if ((mul - (L - 1)) % 2)
                num_out_pls++;
              
              for (l = N * (k - num_out_pls + 1); l < N * (k + 1); l += N)
                {
                if (rational)
                  for (j = 0; j < 3; j++)
                    pls[3 * (l + i) + j] = pls[3 * (l + i) + j] / wts[l + i] +
                                           dist * pole_vec[j];
              
                else
                  for (j = 0; j < 3; j++)
                    pls[3 * (l + i) + j] += dist * pole_vec[j];

                dist += np_dist;
                } /* end for */
             
              } /* end else if (k > mul - 1) */

            } /* end if (mul > L - 1) */
       
          } /* end if (mul >= L - 1) */
       
        mul = 1;
        } /* end else if (pole_dist >= basis_tol) */

      } /* end for (k = 0; k < M - 1; k++) */

    /* 10/08/99 - added code here to not do anything if mul == N  */
    if (mul >= L - 1 && mul < N)
      {
      /* The multiple poles end at v = 1. */
      problem_v_poles_exist = TRUE;

      if (mul > L - 1)
        {
        if (rational)
          for (j = 0; j < 3; j++)
            pole_vec[j] = pls[3 * (N * (M - mul - 1) + i) + j] /
                          wts[N * (M - mul - 1) + i] -
                          pls[3 * (N * (M - mul) + i) + j] /
                          wts[N * (M - mul) + i];

        else
          for (j = 0; j < 3; j++)
            pole_vec[j] = pls[3 * (N * (M - mul - 1) + i) + j] -
                          pls[3 * (N * (M - mul) + i) + j];

        np_dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);
        dist = 3 * np_dist;

        (void) BSnorvec (rc, pole_vec);
        if (BSERROR (*rc))
          goto wrapup;

        for (l = N * (M - 1 - (L - 1)); l > N * (M - mul - 1); l -= N)
          {
          if (rational)
            for (j = 0; j < 3; j++)
               pls[3 * (l + i) + j] = pls[3 * (l + i) + j] / wts[l + i] +
                                      dist * pole_vec[j];
              
          else
            for (j = 0; j < 3; j++)
              pls[3 * (l + i) + j] += dist * pole_vec[j];

          dist += np_dist;
          } /* end for */

        } /* end if (mul > K - 1) */

      } /* end if (mul >= K - 1) */

    } /* end for (i = 0; i < N; i++) */

  if (num_problem_u_poles)
    {
    /* Allocate an intermediate surface for the corrected problem poles in u. */
    BSallocsf ((IGRshort) K, (IGRshort) L,  (IGRlong) (N + num_u_insertions),
               (IGRlong) M, rational, (IGRshort) 0, &usf, rc);
    if (BSERROR (*rc))
      goto wrapup;

    usf->u_order = (IGRshort) K;
    usf->v_order = (IGRshort) L;
    usf->u_periodic = tsf->u_periodic;
    usf->v_periodic = tsf->v_periodic;
    usf->u_non_uniform = tsf->u_non_uniform;
    usf->v_non_uniform = tsf->v_non_uniform;
    usf->rational = tsf->rational;
    usf->planar = tsf->planar;
    usf->u_phy_closed = tsf->u_phy_closed;
    usf->v_phy_closed = tsf->v_phy_closed;
    usf->pos_orient = tsf->pos_orient;
    usf->on_off = tsf->on_off;

    BSMEMCPY ((IGRint) (N * M * sizeof(IGRpoint)), (IGRchar *) tsf->poles,
              (IGRchar *) usf->poles);

    if (rational)
      BSMEMCPY ((IGRint) (N * M * sizeof(IGRdouble)), (IGRchar *) tsf->weights,
                (IGRchar *) usf->weights);

    BSMEMCPY ((IGRint) ((K + N) * sizeof(IGRdouble)), (IGRchar *) tsf->u_knots,
              (IGRchar *) usf->u_knots);

    BSMEMCPY ((IGRint) ((L + M) * sizeof(IGRdouble)), (IGRchar *) tsf->v_knots,
              (IGRchar *) usf->v_knots);

    usf->u_num_poles = (IGRlong) N;
    usf->v_num_poles = (IGRlong) M;
    usf->u_num_knots = tsf->u_num_knots;
    usf->v_num_knots = tsf->v_num_knots;

    /* Fix the problem poles in u. */
    if (num_u_insertions)
      for (i = N - 3; i > 1; i--)
        if (u_knot_insertion[i])
          {
          (void) BSadd_ukt2r (rc, usf, &usf->u_knots[i + 2],
                              &u_knot_insertion[i], &enough_memory);
          if (BSERROR (*rc))
            goto wrapup;
          }

    /* Adjust the problem pole indices to reflect the knot insertions. */
    pps = problem_u_poles;
    max_pp = pps + num_problem_u_poles;

    for (k = 0; k < M && pps < max_pp; k++)
      for (i = 1; i < N - 1 && pps < max_pp; i++)
        if (*pps == k * N + i)
          {
          num_row_insertions = 0;
        
          for (j = 2; j < i; j++)
            num_row_insertions += u_knot_insertion[j];
            
          *pps += k * num_u_insertions + num_row_insertions;

          if (u_knot_insertion[i])
            (*pps)++;
          
          pps++;
          } /* end if (*pps == k * N + i) */

    N2 = usf->u_num_poles;

    pls = usf->poles;
    wts = usf->weights;

    for (i = 0; i < num_problem_u_poles; i++)
      {
      if (!((problem_u_poles[i] - 1) % N2))
        {
        /* The problem pole is on the left boundary. */
        if (rational)
          for (j = 0; j < 3; j++)
            {
            pls[3 * problem_u_poles[i] + j] /= wts[problem_u_poles[i]];
            pls[3 * (problem_u_poles[i] + 1) + j] /= wts[problem_u_poles[i] + 1];
            base_pole[j] = pls[3 * (problem_u_poles[i] + 1) + j];
            pole_vec[j]  = pls[3 * (problem_u_poles[i] + 2) + j] /
                           wts[problem_u_poles[i] + 2] -
                           base_pole[j];
            } /* end for (j = 0; j < 3; j++) */
          
        else
          for (j = 0; j < 3; j++)
            {
            base_pole[j] = pls[3 * (problem_u_poles[i] + 1) + j];
            pole_vec[j]  = pls[3 * (problem_u_poles[i] + 2) + j] - base_pole[j];
            }

        dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);

        (void) BSnorvec (rc, pole_vec);
        if (BSERROR (*rc))
          goto wrapup;

        for (j = 0; j < 3; j++)
          {
          pls[3 * problem_u_poles[i] + j] = base_pole[j] + dist * pole_vec[j];
          pls[3 * (problem_u_poles[i] + 1) + j] = base_pole[j] + 
                                                  2.0 * dist * pole_vec[j];
          }
        
        if (rational)
          for (j = 0; j < 3; j++)
            {
            pls[3 * problem_u_poles[i] + j] *= wts[problem_u_poles[i]];
            pls[3 * (problem_u_poles[i] + 1) + j] *= wts[problem_u_poles[i]+1];
            }
          
        } /* end if (!((problem_u_poles[i] - 1) % N2)) */

      else if (!((problem_u_poles[i] + 2) % N2))
        {
        /* The problem pole is on the right boundary. */
        if (rational)
          for (j = 0; j < 3; j++)
            {
            pls[3 * problem_u_poles[i] + j] /= wts[problem_u_poles[i]];
            pls[3 * (problem_u_poles[i] - 1) + j] /= wts[problem_u_poles[i]-1];
            base_pole[j] = pls[3 * (problem_u_poles[i] - 1) + j];
            pole_vec[j]  = pls[3 * (problem_u_poles[i] - 2) + j] /
                           wts[problem_u_poles[i] - 2] -
                           base_pole[j];
            } /* end for (j = 0; j < 3; j++) */
          
        else
          for (j = 0; j < 3; j++)
            {
            base_pole[j] = pls[3 * (problem_u_poles[i] - 1) + j];
            pole_vec[j]  = pls[3 * (problem_u_poles[i] - 2) + j] - base_pole[j];
            }

        (void) BSnorvec (rc, pole_vec);
        if (BSERROR (*rc))
          goto wrapup;

        dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);

        for (j = 0; j < 3; j++)
          {
          pls[3 * problem_u_poles[i] + j] = base_pole[j] + dist * pole_vec[j];
          pls[3 * (problem_u_poles[i] - 1) + j] = base_pole[j] +
                                                  2.0 * dist * pole_vec[j]; 
          }

        if (rational)
          for (j = 0; j < 3; j++)
            {
            pls[3 * problem_u_poles[i] + j] *= wts[problem_u_poles[i]];
            pls[3 * (problem_u_poles[i] - 1) + j] *= wts[problem_u_poles[i]-1];
            }
          
        } /* end else if (!((problem_u_poles[i] + 2) % N2)) */
  
      else
        {
        num_insertions = u_pole_insertion[i];
      
        if (num_insertions == 2)
          {
          if (rational)
            for (j = 0; j < 3; j++)
              {
              for (k = -2; k < 3; k++)
                pls[3 * (problem_u_poles[i] + k) + j] /=
                  wts[problem_u_poles[i] + k];
            
              base_pole[j] = pls[3 * problem_u_poles[i] + j];
              pole_vec1[j] = pls[3 * (problem_u_poles[i] + 3) + j] /
                             wts[problem_u_poles[i] + 3] - 
                             base_pole[j];
              pole_vec2[j] = pls[3 * (problem_u_poles[i] - 3) + j] /
                             wts[problem_u_poles[i] - 3] - 
                             base_pole[j];
              } /* end for (j = 0; j < 3; j++) */
          
          else /* if (!rational) */
            for (j = 0; j < 3; j++)
              {
              base_pole[j] = pls[3 * problem_u_poles[i] + j];
              pole_vec1[j] = pls[3 * (problem_u_poles[i] + 3) + j] -
                             base_pole[j];
              pole_vec2[j] = pls[3 * (problem_u_poles[i] - 3) + j] -
                             base_pole[j];
              } /* end for (j = 0; j < 3; j++) */

          (void) BSnorvec (rc, pole_vec1);
          if (BSERROR (*rc))
            goto wrapup;

          (void) BSnorvec (rc, pole_vec2);
          if (BSERROR (*rc))
            goto wrapup;

          dist1 = MAX (BSlenvec (rc, pole_vec1) * 0.01, basis_tol_100);
          dist2 = MAX (BSlenvec (rc, pole_vec2) * 0.01, basis_tol_100);

          for (j = 0; j < 3; j++)
            {
            pls[3 * (problem_u_poles[i] + 1) + j] = base_pole[j] +
                                                    dist1 * pole_vec1[j];
            pls[3 * (problem_u_poles[i] + 2) + j] = base_pole[j] +
                                                    2.0 * dist1 * pole_vec1[j];
            pls[3 * (problem_u_poles[i] - 1) + j] = base_pole[j] +
                                                    dist2 * pole_vec2[j];
            pls[3 * (problem_u_poles[i] - 2) + j] = base_pole[j] +
                                                    2.0 * dist2 * pole_vec2[j];
            } /* end for (j = 0; j < 3; j++) */

          if (rational)
            for (j = 0; j < 3; j++)
              for (k = -2; k < 3; k++)
                pls[3 * (problem_u_poles[i] + k) + j] *=
                  wts[problem_u_poles[i] + k];
          } /* end if (num_insertions == 2) */
      
        else if (num_insertions == 1)
          {
          if (rational)
            for (j = 0; j < 3; j++)
              {
              for (k = -2; k < 2; k++)
                pls[3 * (problem_u_poles[i] + k) + j] /=
                  wts[problem_u_poles[i] + k];
            
              base_pole[j] = pls[3 * problem_u_poles[i] + j];
              pole_vec1[j] = pls[3 * (problem_u_poles[i] + 2) + j] /
                             wts[problem_u_poles[i] + 2] - 
                             base_pole[j];
              pole_vec2[j] = pls[3 * (problem_u_poles[i] - 3) + j] /
                             wts[problem_u_poles[i] - 3] - 
                             base_pole[j];
              } /* end for (j = 0; j < 3; j++) */
          
          else /* if (!rational) */
            for (j = 0; j < 3; j++)
              {
              base_pole[j] = pls[3 * problem_u_poles[i] + j];
              pole_vec1[j] = pls[3 * (problem_u_poles[i] + 2) + j] -
                             base_pole[j];
              pole_vec2[j] = pls[3 * (problem_u_poles[i] - 3) + j] - 
                             base_pole[j];
              } /* end for (j = 0; j < 3; j++) */

          (void) BSnorvec (rc, pole_vec1);
          if (BSERROR (*rc))
            goto wrapup;

          (void) BSnorvec (rc, pole_vec2);
          if (BSERROR (*rc))
            goto wrapup;

          dist1 = MAX (BSlenvec (rc, pole_vec1) * 0.01, basis_tol_100);
          dist2 = MAX (BSlenvec (rc, pole_vec2) * 0.01, basis_tol_100);

          for (j = 0; j < 3; j++)
            {
            pls[3 * (problem_u_poles[i] + 1) + j] = base_pole[j] +
                                                    dist1 * pole_vec1[j];
            pls[3 * (problem_u_poles[i] - 1) + j] = base_pole[j] +
                                                    dist2 * pole_vec2[j];
            pls[3 * (problem_u_poles[i] - 2) + j] = base_pole[j] +
                                                    2.0 * dist2 * pole_vec2[j];
            } /* end for (j = 0; j < 3; j++) */

          if (rational)
            for (j = 0; j < 3; j++)
              for (k = -2; k < 2; k++)
                pls[3 * (problem_u_poles[i] + k) + j] *= 
                  wts[problem_u_poles[i] + k];
          } /* end else if (num_insertions == 1) */
      
        else /* if (num_insertions == 0) */
          {
          if (rational)
            for (j = 0; j < 3; j++)
              {
              for (k = -1; k < 2; k++)
                pls[3 * (problem_u_poles[i] + k) + j] /=
                  wts[problem_u_poles[i] + k];
            
              base_pole[j] = pls[3 * problem_u_poles[i] + j];
              pole_vec1[j] = pls[3 * (problem_u_poles[i] + 2) + j] /
                             wts[problem_u_poles[i] + 2] - 
                             base_pole[j];
              pole_vec2[j] = pls[3 * (problem_u_poles[i] - 2) + j] /
                             wts[problem_u_poles[i] - 2] - 
                             base_pole[j];
              } /* end for (j = 0; j < 3; j++) */
          
          else /* if (!rational) */
            for (j = 0; j < 3; j++)
              {
              base_pole[j] = pls[3 * problem_u_poles[i] + j];
              pole_vec1[j] = pls[3 * (problem_u_poles[i] + 2) + j] -
                             base_pole[j];
              pole_vec2[j] = pls[3 * (problem_u_poles[i] - 2) + j] -
                             base_pole[j];
              } /* end for (j = 0; j < 3; j++) */

          (void) BSnorvec (rc, pole_vec1);
          if (BSERROR (*rc))
            goto wrapup;

          (void) BSnorvec (rc, pole_vec2);
          if (BSERROR (*rc))
            goto wrapup;

          dist1 = MAX (BSlenvec (rc, pole_vec1) * 0.01, basis_tol_100);
          dist2 = MAX (BSlenvec (rc, pole_vec2) * 0.01, basis_tol_100);

          for (j = 0; j < 3; j++)
            {
            pls[3 * (problem_u_poles[i] + 1) + j] = base_pole[j] +
                                                    dist1 * pole_vec1[j];
            pls[3 * (problem_u_poles[i] - 1) + j] = base_pole[j] +
                                                    dist2 * pole_vec2[j];
            } /* end for (j = 0; j < 3; j++) */

          if (rational)
            for (j = 0; j < 3; j++)
              for (k = -1; k < 2; k++)
                pls[3 * (problem_u_poles[i] + k) + j] *=
                  wts[problem_u_poles[i] + k];
          } /* end else if (num_insertions == 0) */

        } /* end else */

      } /* end for (i = 0; i < num_problem_u_poles; i++) */

    } /* end if (num_problem_u_poles) */

  else /* if (!num_problem_u_poles) */
    {
    N2 = N;
    
    usf = tsf;
    tsf = NULL;

    pls = usf->poles;
    wts = usf->weights;
    } /* end else if (!num_problem_u_poles) */

  /* Flag the problem poles in v, if any exist. */
  num_problem_v_poles = 0;

  if (problem_v_poles_exist)
    {
    v_work = (IGRint *) BSstackalloc ((2 * N2 * M + M) * sizeof(IGRint));
    if (!v_work)
      {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
      }

    problem_v_poles = v_work;
    v_pole_insertion = problem_v_poles + N2 * M;
    v_knot_insertion = v_pole_insertion + N2 * M;

    for (i = 0; i < M; i++)
      v_knot_insertion[i] = 0;

    num_v_insertions = 0;

    for (i = 0; i < N2; i++)
      {
      mul = 1;

      for (k = 0; k < M - 1; k++)
        {
        if (rational)
          {
          for (j = 0; j < 3; j++)
            {
            uwp[0][j] = pls[3 * (k * N2 + i) + j] / wts[k * N2 + i];
            uwp[1][j] = pls[3 * ((k + 1) * N2 + i) + j] / wts[(k + 1) * N2 + i];
            }

          pole_dist = BSdistptpt (rc, uwp[0], uwp[1]);
          } /* end if (rational) */
      
        else
          pole_dist = BSdistptpt (rc, &pls[3 * (k * N2 + i)],
                                  &pls[3 * ((k + 1) * N2 + i)]);
  
        if (pole_dist < basis_tol)
          {
          mul++;

          if (mul == L - 1)
            {
            problem_v_poles[num_problem_v_poles] = k * N2 + i;

            if (k > 1
             && k < M - 2)
              {
              if (!v_knot_insertion[k])
                {
                /* Determine the multiplicity of v already in the knot sequence.
                 */
                v = usf->v_knots[k + 2];
                m = 0;

                for (j = L; j < M; j++)
                  if (fabs (usf->v_knots[j] - v) < knot_tol)
                    m++;

                  else if (m) 
                    break;

                num_v_insertions += ((L - 1) - m);
                v_knot_insertion[k] = (L - 1) - m;
                } /* end if (!v_knot_insertion[k]) */

              v_pole_insertion[num_problem_v_poles] = v_knot_insertion[k];
              } /* end if (k > 1 && k < M - 2) */

            num_problem_v_poles++;
            } /* end if (mul == L - 1) */

          } /* end if (pole_dist < basis_tol) */
      
        else
          mul = 1;
        } /* end for (k = 0; k < M - 1; k++) */

      } /* end for (i = 0; i < N2; i++) */

    BSallocsf ((IGRshort) K, (IGRshort) L, (IGRlong) N2, 
               (IGRlong) (M + num_v_insertions), rational, (IGRshort) 0, outsf,
               rc);
    if (BSERROR (*rc))
      goto wrapup;

    (*outsf)->u_order = (IGRshort) K;
    (*outsf)->v_order = (IGRshort) L;
    (*outsf)->u_periodic = usf->u_periodic;
    (*outsf)->v_periodic = usf->v_periodic;
    (*outsf)->u_non_uniform = usf->u_non_uniform;
    (*outsf)->v_non_uniform = usf->v_non_uniform;
    (*outsf)->rational = usf->rational;
    (*outsf)->planar = usf->planar;
    (*outsf)->u_phy_closed = usf->u_phy_closed;
    (*outsf)->v_phy_closed = usf->v_phy_closed;
    (*outsf)->pos_orient = usf->pos_orient;
    (*outsf)->on_off = usf->on_off;

    BSMEMCPY ((IGRint) (N2 * M * sizeof(IGRpoint)), (IGRchar *) usf->poles,
              (IGRchar *) (*outsf)->poles);

    if (rational)
      BSMEMCPY ((IGRint) (N2 * M * sizeof(IGRdouble)), (IGRchar *) usf->weights,
                (IGRchar *) (*outsf)->weights);

    BSMEMCPY ((IGRint) ((K + N2) * sizeof(IGRdouble)), (IGRchar *) usf->u_knots,
              (IGRchar *) (*outsf)->u_knots);
 
    BSMEMCPY ((IGRint) ((L + M) * sizeof(IGRdouble)), (IGRchar *) usf->v_knots,
              (IGRchar *) (*outsf)->v_knots);

    (*outsf)->u_num_poles = (IGRlong) N2;
    (*outsf)->v_num_poles = (IGRlong) M;
    (*outsf)->u_num_knots = usf->u_num_knots;
    (*outsf)->v_num_knots = usf->v_num_knots;

    pls = (*outsf)->poles;
    wts = (*outsf)->weights;

    /* Fix the problem poles in v. */
    if (num_v_insertions)
      for (i = M - 3; i > 1; i--)
        if (v_knot_insertion[i])
          {
          (void) BSadd_vkt2r (rc, *outsf, &(*outsf)->v_knots[i + 2],
                              &v_knot_insertion[i], &enough_memory);
          if (BSERROR (*rc))
            goto wrapup;
          }

    /* Adjust the problem pole indices to reflect the knot insertions. */
    pps = problem_v_poles;
    max_pp = pps + num_problem_v_poles;

    for (i = 0; i < N2 && pps < max_pp; i++)
      for (k = 1; k < M - 1 && pps < max_pp; k++)
        if (*pps == k * N2 + i)
          {
          num_row_insertions = 0;
        
          for (j = 2; j < k; j++)
            num_row_insertions += v_knot_insertion[j];
            
          *pps += num_row_insertions * N2;
 
          if (v_knot_insertion[k])
            *pps += N2;

          pps++;
          } /* end if (*pps == k * N + i) */

    M2 = (*outsf)->v_num_poles;

    for (i = 0; i < num_problem_v_poles; i++)
      {
      if (problem_v_poles[i] < 2 * N2)
        {
        /* The problem pole is on the left boundary. */
        if (rational)
          for (j = 0; j < 3; j++)
            {
            pls[3 * problem_v_poles[i] + j] /= wts[problem_v_poles[i]];
            pls[3 * (problem_v_poles[i] + N2) + j] /=
              wts[problem_v_poles[i] + N2];
            base_pole[j] = pls[3 * (problem_v_poles[i] + N2) + j];
            pole_vec[j]  = pls[3 * (problem_v_poles[i] + 2 * N2) + j] /
                           wts[problem_v_poles[i] + 2 * N2] -
                           base_pole[j];
            } /* end for (j = 0; j < 3; j++) */
          
        else
          for (j = 0; j < 3; j++)
            {
            base_pole[j] = pls[3 * (problem_v_poles[i] + N2) + j];
            pole_vec[j]  = pls[3 * (problem_v_poles[i] + 2 * N2) + j] -
                           base_pole[j];
            }

        dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);

        (void) BSnorvec (rc, pole_vec);
        if (BSERROR (*rc))
          goto wrapup;

        for (j = 0; j < 3; j++)
          {
          pls[3 * problem_v_poles[i] + j] = base_pole[j] + dist * pole_vec[j];
          pls[3 * (problem_v_poles[i] + N2) + j] = base_pole[j] + 
                                                   2.0 * dist * pole_vec[j];
          }
        
        if (rational)
          for (j = 0; j < 3; j++)
            {
            pls[3 * problem_v_poles[i] + j] *= wts[problem_v_poles[i]];
            pls[3 * (problem_v_poles[i] + N2) + j] *=
            wts[problem_v_poles[i] + N2];
            }
          
        } /* end if (problem_v_poles[i] < 2 * N2)) */

      else if (problem_v_poles[i] > N2 * (M2 - 2) - 1)
        {
        /* The problem pole is on the right boundary. */
        if (rational)
          for (j = 0; j < 3; j++)
            {
            pls[3 * problem_v_poles[i] + j] /= wts[problem_v_poles[i]];
            pls[3 * (problem_v_poles[i] - N2) + j] /=
              wts[problem_v_poles[i] - N2];
            base_pole[j] = pls[3 * (problem_v_poles[i] - N2) + j];
            pole_vec[j]  = pls[3 * (problem_v_poles[i] - 2 * N2) + j] /
                           wts[problem_v_poles[i] - 2 * N2] -
                           base_pole[j];
            } /* end for (j = 0; j < 3; j++) */
          
        else
          for (j = 0; j < 3; j++)
            {
            base_pole[j] = pls[3 * (problem_v_poles[i] - N2) + j];
            pole_vec[j]  = pls[3 * (problem_v_poles[i] - 2 * N2) + j] -
                           base_pole[j];
            }

        (void) BSnorvec (rc, pole_vec);
        if (BSERROR (*rc))
          goto wrapup;

        dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);

        for (j = 0; j < 3; j++)
          {
          pls[3 * problem_v_poles[i] + j] = base_pole[j] + dist * pole_vec[j];
          pls[3 * (problem_v_poles[i] - N2) + j] = base_pole[j] +
                                                   2.0 * dist * pole_vec[j]; 
          }

        if (rational)
          for (j = 0; j < 3; j++)
            {
            pls[3 * problem_v_poles[i] + j] *= wts[problem_v_poles[i]];
            pls[3 * (problem_v_poles[i] - N2) + j] *=
              wts[problem_v_poles[i] - N2];
            }
          
        } /* end else if (problem_v_poles[i] > N2 * (M2 - 2) - 1) */
  
      else
        {
        num_insertions = v_pole_insertion[i];
      
        if (num_insertions == 2)
          {
          if (rational)
            for (j = 0; j < 3; j++)
              {
              for (k = -2; k < 3; k++)
                pls[3 * (problem_v_poles[i] + k * N2) + j] /=
                  wts[problem_v_poles[i] + k * N2];
            
              base_pole[j] = pls[3 * problem_v_poles[i] + j];
              pole_vec1[j] = pls[3 * (problem_v_poles[i] + 3 * N2) + j] /
                             wts[problem_v_poles[i] + 3 * N2] - 
                             base_pole[j];
              pole_vec2[j] = pls[3 * (problem_v_poles[i] - 3 * N2) + j] /
                             wts[problem_v_poles[i] - 3 * N2] - 
                             base_pole[j];
              } /* end for (j = 0; j < 3; j++) */
          
          else /* if (!rational) */
            for (j = 0; j < 3; j++)
              {
              base_pole[j] = pls[3 * problem_v_poles[i] + j];
              pole_vec1[j] = pls[3 * (problem_v_poles[i] + 3 * N2) + j] -
                             base_pole[j];
              pole_vec2[j] = pls[3 * (problem_v_poles[i] - 3 * N2) + j] -
                             base_pole[j];
              } /* end for (j = 0; j < 3; j++) */

          (void) BSnorvec (rc, pole_vec1);
          if (BSERROR (*rc))
          goto wrapup;

          (void) BSnorvec (rc, pole_vec2);
          if (BSERROR (*rc))
            goto wrapup;

          dist1 = MAX (BSlenvec (rc, pole_vec1) * 0.01, basis_tol_100);
          dist2 = MAX (BSlenvec (rc, pole_vec2) * 0.01, basis_tol_100);

          for (j = 0; j < 3; j++)
            {
            pls[3 * (problem_v_poles[i] + N2) + j] = base_pole[j] +
                                                     dist1 * pole_vec1[j];
            pls[3 * (problem_v_poles[i] + 2 * N2) + j] = base_pole[j] +
                                                         2.0 * dist1 *
                                                         pole_vec1[j];
            pls[3 * (problem_v_poles[i] - N2) + j] = base_pole[j] +
                                                     dist2 * pole_vec2[j];
            pls[3 * (problem_v_poles[i] - 2 * N2) + j] = base_pole[j] +
                                                         2.0 * dist2 *
                                                         pole_vec2[j];
            } /* end for (j = 0; j < 3; j++) */

          if (rational)
            for (j = 0; j < 3; j++)
              for (k = -2; k < 3; k++)
                pls[3 * (problem_v_poles[i] + k * N2) + j] *=
                  wts[problem_v_poles[i] + k * N2];
          } /* end if (num_insertions == 2) */

        else if (num_insertions == 1)
          {
          if (rational)
            for (j = 0; j < 3; j++)
              {
              for (k = -2; k < 2; k++)
                pls[3 * (problem_v_poles[i] + k * N2) + j] /=
                  wts[problem_v_poles[i] + k * N2];
            
              base_pole[j] = pls[3 * problem_v_poles[i] + j];
              pole_vec1[j] = pls[3 * (problem_v_poles[i] + 2 * N2) + j] /
                             wts[problem_v_poles[i] + 2 * N2] - 
                             base_pole[j];
              pole_vec2[j] = pls[3 * (problem_v_poles[i] - 3 * N2) + j] /
                             wts[problem_v_poles[i] - 3 * N2] - 
                             base_pole[j];
              } /* end for (j = 0; j < 3; j++) */
          
          else /* if (!rational) */
            for (j = 0; j < 3; j++)
              {
              base_pole[j] = pls[3 * problem_v_poles[i] + j];
              pole_vec1[j] = pls[3 * (problem_v_poles[i] + 2 * N2) + j] -
                             base_pole[j];
              pole_vec2[j] = pls[3 * (problem_v_poles[i] - 3 * N2) + j] -
                             base_pole[j];
              } /* end for (j = 0; j < 3; j++) */

          (void) BSnorvec (rc, pole_vec1);
          if (BSERROR (*rc))
            goto wrapup;

          (void) BSnorvec (rc, pole_vec2);
          if (BSERROR (*rc))
            goto wrapup;

          dist1 = MAX (BSlenvec (rc, pole_vec1) * 0.01, basis_tol_100);
          dist2 = MAX (BSlenvec (rc, pole_vec2) * 0.01, basis_tol_100);
 
          for (j = 0; j < 3; j++)
            {
            pls[3 * (problem_v_poles[i] + N2) + j] = base_pole[j] +
                                                     dist1 * pole_vec1[j];
            pls[3 * (problem_v_poles[i] - N2) + j] = base_pole[j] +
                                                     dist2 * pole_vec2[j];
            pls[3 * (problem_v_poles[i] - 2 * N2) + j] = base_pole[j] +
                                                         2.0 * dist2 *
                                                         pole_vec2[j];
            } /* end for (j = 0; j < 3; j++) */

          if (rational)
            for (j = 0; j < 3; j++)
              for (k = -2; k < 2; k++)
                pls[3 * (problem_v_poles[i] + k * N2) + j] *=
                  wts[problem_v_poles[i] + k * N2];
          } /* end if (num_insertions == 1) */

        else /* if (num_insertions == 0) */
          {
          if (rational)
            for (j = 0; j < 3; j++)
              {
              for (k = -1; k < 2; k++)
                pls[3 * (problem_v_poles[i] + k * N2) + j] /=
                  wts[problem_v_poles[i] + k * N2];
            
              base_pole[j] = pls[3 * problem_v_poles[i] + j];
              pole_vec1[j] = pls[3 * (problem_v_poles[i] + 2 * N2) + j] /
                             wts[problem_v_poles[i] + 2 * N2] - 
                             base_pole[j];
              pole_vec2[j] = pls[3 * (problem_v_poles[i] - 2 * N2) + j] /
                             wts[problem_v_poles[i] - 2 * N2] - 
                             base_pole[j];
              } /* end for (j = 0; j < 3; j++) */
          
          else /* if (!rational) */
            for (j = 0; j < 3; j++)
              {
              base_pole[j] = pls[3 * problem_v_poles[i] + j];
              pole_vec1[j] = pls[3 * (problem_v_poles[i] + 2 * N2) + j] -
                             base_pole[j];
              pole_vec2[j] = pls[3 * (problem_v_poles[i] - 2 * N2) + j] -
                             base_pole[j];
              } /* end for (j = 0; j < 3; j++) */

          (void) BSnorvec (rc, pole_vec1);
          if (BSERROR (*rc))
            goto wrapup;

          (void) BSnorvec (rc, pole_vec2);
          if (BSERROR (*rc))
            goto wrapup;

          dist1 = MAX (BSlenvec (rc, pole_vec1) * 0.01, basis_tol_100);
          dist2 = MAX (BSlenvec (rc, pole_vec2) * 0.01, basis_tol_100);

          for (j = 0; j < 3; j++)
            {
            pls[3 * (problem_v_poles[i] + N2) + j] = base_pole[j] +
                                                     dist1 * pole_vec1[j];
            pls[3 * (problem_v_poles[i] - N2) + j] = base_pole[j] +
                                                     dist2 * pole_vec2[j];
            } /* end for (j = 0; j < 3; j++) */

          if (rational)
            for (j = 0; j < 3; j++)
              for (k = -1; k < 2; k++)
                pls[3 * (problem_v_poles[i] + k * N2) + j] *=
                  wts[problem_v_poles[i] + k * N2];
          } /* end if (num_insertions == 0) */
      
        } /* end else */

      } /* end for (i = 0; i < num_problem_v_poles; i++) */

    } /* end if (problem_v_poles_exist) */

  else /* if (!problem_v_poles_exist) */
    {
    *outsf = usf;
    usf = NULL;
    } /* end else if (!problem_v_poles_exist) */


  /* The following code was added on 10/28/92 by Sherry Catron. */

  /* Check for pole multiplicities of K - 2 in u. */
  pls = (*outsf)->poles;
  wts = (*outsf)->weights;

  N = (*outsf)->u_num_poles;
  M = (*outsf)->v_num_poles;

  prevfirst = 0;
  first = 0;
  second = N;
  third = N * 2;

  for (k = 0; k < M - 1; k++)
    {
    if (k == M - 2)
      {
      first = (M - 1) * N;
      second = (M - 2) * N;
      third = (M - 3) * N;
      }

    if (k == 1)
       prevfirst = 0;

    for (i = 0; i < N; i++, first++, second++, third++, prevfirst++)
      {
      one = first * 3;
      two = second * 3;

      if (rational)
        {
        for (j = 0; j < 3; j++)
          {
          uwp[0][j] = pls[one + j] / wts[first];
          uwp[1][j] = pls[two + j] / wts[second];
          }

        pole_dist = BSdistptpt (rc, uwp[0], uwp[1]);
        } /* end if (rational) */
      
      else
        pole_dist = BSdistptpt (rc, &pls[one], &pls[two]);

      if (pole_dist < basis_tol)
        {    
        three = third * 3;

        if (rational)
          for (j = 0; j < 3; j++)
            pole_vec[j] = pls[three+j] / wts[third] - uwp[1][j];

        else
          for (j = 0; j < 3; j++)
            pole_vec[j] = pls[three+j] - pls[two+j];

        dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);

        (void) BSnorvec (rc, pole_vec);
        if (BSERROR (*rc))
          goto wrapup;

        if (rational)
          for (j = 0; j < 3; j++)
            pls[two + j] = (uwp[1][j] + dist * pole_vec[j]) * wts[second];

        else
          for (j = 0; j < 3; j++)
            pls[two + j] += dist * pole_vec[j];

        if (k != 0
         && k != M - 2)
          {
          /* The degenerate poles are on a boundary - move both. */
          last = prevfirst * 3;

          if (rational)
            for (j = 0; j < 3; j++)
              pole_vec[j] = pls[last+j] / wts[prevfirst] - uwp[0][j];

          else
            for (j = 0; j < 3; j++)
              pole_vec[j] = pls[last+j] - pls[one+j];

          dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);

          (void) BSnorvec (rc, pole_vec);
          if (BSERROR (*rc))
            goto wrapup;

          if (rational)
            for (j = 0; j < 3; j++)
              pls[one+ j] = (uwp[0][j] - dist * pole_vec[j]) * wts[first];

          else
            for (j = 0; j < 3; j++)
              pls[one + j] -= dist * pole_vec[j];
          } /* end if (k != 0 && k != M - 2) */
          
        } /* end if (pole_dist < basis_tol) */
        
      } /* end for (i) */
      
    } /* end for (k) */

  /* Now check for pole multiplicities of L - 2 in v. */
  increm = N;
  prevfirst = 0;

  for (k = 0; k < N - 1; k++)
    {
    first = k;
    second = k + 1;
    third = k + 2;

    if (k == N - 2)
      {
      first = N - 1;
      second = N - 2;
      third = N - 3;
      }
    
    for (i = 0; i < M; i++, first += increm, second += increm,third += increm)
      {
      prevfirst = first - 1;
      one = first * 3;
      two = second * 3;

      if (rational)
        {
        for (j = 0; j < 3; j++)
          {
          uwp[0][j] = pls[one + j] / wts[first];
          uwp[1][j] = pls[two + j] / wts[second];
          }

        pole_dist = BSdistptpt (rc, uwp[0], uwp[1]);
        } /* end if (rational) */
      
      else
        pole_dist = BSdistptpt (rc, &pls[one], &pls[two]);

      if (pole_dist < basis_tol)
        {    
        three = third * 3;

        if (rational)
          for (j = 0; j < 3; j++)
            pole_vec[j] = pls[three+j] / wts[third] - uwp[1][j];

        else
          for (j = 0; j < 3; j++)
            pole_vec[j] = pls[three+j] - pls[two+j];

        dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);

        (void) BSnorvec (rc, pole_vec);
        if (BSERROR (*rc))
          goto wrapup;

        if (rational)
          for (j = 0; j < 3; j++)
            pls[two + j] = (uwp[1][j] + dist * pole_vec[j]) * wts[second];

        else
          for (j = 0; j < 3; j++)
            pls[two + j] += dist * pole_vec[j];

        if (k != 0
         && k != N - 2)
          {
          /* The degenerate poles are on a boundary - move both. */
          last = prevfirst * 3;

          if (rational)
            for (j = 0; j < 3; j++)
              pole_vec[j] = pls[last+j] / wts[prevfirst] - uwp[0][j];

          else
            for (j = 0; j < 3; j++)
              pole_vec[j] = pls[last+j] - pls[one+j];

          dist = MAX (BSlenvec (rc, pole_vec) * 0.01, basis_tol_100);

          (void) BSnorvec (rc, pole_vec);
          if (BSERROR (*rc))
            goto wrapup;

          if (rational)
            for (j = 0; j < 3; j++)
              pls[one+ j] = (uwp[0][j] - dist * pole_vec[j]) * wts[first];

          else
            for (j = 0; j < 3; j++)
              pls[one + j] -= dist * pole_vec[j];
          } /* end if (k != 0 && k != N - 2) */

        } /* end if (pole_dist < basis_tol) */

      } /* end for (i) */

    } /* end for (k) */

wrapup:

  if (v_work)
    BSstackdealloc ((char *) v_work);

  if (usf)
    (void) BSfreesf (&rc2, usf);

  if (u_work)
    BSstackdealloc ((char *) u_work);

  if (tsf)
    (void) BSfreesf (&rc2, tsf);

  if (BSERROR(*rc))
    BSdbgrc(*rc,"BSchkfxsf2");

  return;
  } /* end BSchkfxsf2() */

