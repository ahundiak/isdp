/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSx2sf_prj

Abstract
    This routine intersects two surfaces of projection returning intersection
    curves in BSgeom_bsp_curve structure format.

Synopsis
    BSx2sf_prj(sf1, sf2, num_grps, num_int_cvs, int_cvs, rc)

    struct BSgeom_bsp_surf   *sf1...........structure for 1st sf of proj
    struct BSgeom_bsp_surf   *sf2...........structure for 2nd sf of proj
    IGRint                   *num_grps......number of groups of intersection
                                            curves
    IGRint                   **num_int_cvs..pointer to array of number of
                                            intersection curves per group
    struct BSgeom_bsp_curve  **int_cvs......pointer to array of structures
                                            containing geometric properties of
                                            resulting intersection curves.
    BSrc                     *rc............return code

Description
    This routine inputs 2 surfaces of projection (sf1, sf2) in BSgeom_bsp_surf
    structure format and returns the number of groups of intersection curves
    (num_grps), an array of the number of intersection curves per group
    (num_int_cvs) and an array of structures (int_cvs) of resulting inter-
    section curves.

Return Values
    BSSUCC is returned if all is successful.
    BSCOINCIDENT if sf1 and sf2 are coincident surfaces.
    BSNOTYETSUPPORTED if intersection case is not currently supported.

Notes
    Memory for num_int_cvs and int_cvs is allocated in this routine.

Index
    em

Keywords

History
    S.C. Wood     01/14/91  : Creation date
    S.C. Wood     03/12/91  : Initialize array1 in BSgeom_bsp_curve structures
                              and deallocate if existing.
    S.C. Wood     04/03/91  : Use sf_proj->gencv_ind instead of sf_proj->
                              reg_constr to check if u or v is generating
                              curve to adapt to change in bsgeom_cvsf.h
    P.R. Slubicki 03/04/92  : Use BSmalloc() and BSdealloc() for processing
                              the memory for t4cvs[*].
    S.G. Catron   05/09/00  : VDS TR179901376. There were 3 changes I made.  First in testing
                              if parallel or not, we need to use the correct tolerance.
                              Second, find a good plane point, so when we project
                              we have less round off.  Thirdly, we average the
                              projection vectors from each surface to set the plane
                              vector.
    S.G. Catron   06/15/00  : Same problem as above, but with a slightly different data
                              case. If the generating curve is a good ways from the actual
                              intersection, and our projection vectors are not the same,
                              when we project to the plane we will still get some round off.
                              I modified to use the well chosen plane point to find the
                              associated parameters on the surfaces and find a new psuedo
                              generating curve for both.  When we project these curves to
                              the plane they should be relatively close.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h"
#endif

#ifdef NT
#include "ubspm.h"
#else
#include "bstypes.h"
#include "bserr.h"
#include "bsvalues.h"
#include "bsparameters.h"
#include "bsmalloc.h"
#include "bsstackalloc.h"
#include "bsstk.h"
#include "bsdefs.h"
#include "bsgeom_cvsf.h"
#include "bsconic.h"
#include "bsmemory.h"
#endif
#define  BSVOID

#include <math.h>
#define MAXNUM 100

/* This routine finds the best guess for a plane point, so our plane is located near the intersection */
/**
   Find the corners of each surface.  Project these onto a line defined by sf1->pt1 and
   the average projection vector.  Using these projected distances along the line, find
   a min/max for each surface.   Now find the overlap and average, to get the point,
   which is our pln_pt.
**/

static void planeptBSx2sf_prj(struct  BSgeom_bsp_surf    *sf1, struct  BSgeom_bsp_surf    *sf2,
                              IGRvector pln_nvec, IGRpoint pln_pt, BSrc *rc )
{
#ifndef DONOTSPROTO
#include "bsproj0.h"
#include "bssfeval.h"
#include "bsdotp.h"
#include "bsmkvec.h"
#endif
IGRpoint Corners1[4], Corners2[4], line[2];
struct IGRbsp_surface *sfptr;
IGRint num_deriv=0, i, num1, num2;
IGRdouble min_par1, min_par2, max_par1, max_par2, min, max, ht;
IGRvector vec;

   *rc = BSSUCC;

   sfptr = sf1->bspsf;
   BSsfeval(sfptr, sfptr->u_knots[sfptr->u_order -1], sfptr->v_knots[sfptr->v_order-1],
         num_deriv, &(Corners1[0]), rc);
   if (BSERROR(*rc))
      goto wrapup;
   num1 = 1;
   if(! sfptr->v_phy_closed )
   {
      BSsfeval(sfptr, sfptr->u_knots[sfptr->u_order -1], sfptr->v_knots[sfptr->v_num_poles],
               num_deriv, &(Corners1[num1]), rc);
      if (BSERROR(*rc))
         goto wrapup;
      num1 += 1;
   }
   if( ! sfptr->u_phy_closed )
   {
      BSsfeval(sfptr, sfptr->u_knots[sfptr->u_num_poles], sfptr->v_knots[sfptr->v_order-1],
               num_deriv, &(Corners1[num1]), rc);
      if (BSERROR(*rc))
         goto wrapup;
      num1 += 1;
   }
   if( !sfptr->u_phy_closed  && !sfptr->v_phy_closed)
   {
      BSsfeval(sfptr, sfptr->u_knots[sfptr->u_num_poles], sfptr->v_knots[sfptr->v_num_poles],
               num_deriv, &(Corners1[num1]), rc);
      if (BSERROR(*rc))
         goto wrapup;
      num1 += 1;
   }

   sfptr = sf2->bspsf;
   BSsfeval(sfptr, sfptr->u_knots[sfptr->u_order -1], sfptr->v_knots[sfptr->v_order-1],
            num_deriv, &(Corners2[0]), rc);
   if (BSERROR(*rc))
      goto wrapup;
   num2 = 1;
   if(! sfptr->v_phy_closed )
   {
      BSsfeval(sfptr, sfptr->u_knots[sfptr->u_order -1], sfptr->v_knots[sfptr->v_num_poles],
               num_deriv, &(Corners2[num2]), rc);
      if (BSERROR(*rc))
         goto wrapup;
      num2 += 1;
   }
   if(! sfptr->u_phy_closed )
   {
      BSsfeval(sfptr, sfptr->u_knots[sfptr->u_num_poles], sfptr->v_knots[sfptr->v_order-1],
               num_deriv, &(Corners2[num2]), rc);
      if (BSERROR(*rc))
         goto wrapup;
      num2 += 1;
   }
   if( !sfptr->u_phy_closed && !sfptr->v_phy_closed )
   {
      BSsfeval(sfptr, sfptr->u_knots[sfptr->u_num_poles], sfptr->v_knots[sfptr->v_num_poles],
               num_deriv, &(Corners2[num2]), rc);
      if (BSERROR(*rc))
         goto wrapup;
      num2 += 1;
   }

   for(i=0; i< 3; i++)
   {
      line[0][i] = sf1->pt1[i];
      line[1][i] = sf1->pt1[i] + pln_nvec[i];
   }

   /* find the min and max points on the line for surface 1 */
   (void)BSmkvec(rc, vec, sf1->pt1, Corners1[0] );
   if(BSERROR(*rc)) goto wrapup;
   ht = BSdotp(rc, vec, pln_nvec );
   if(BSERROR(*rc)) goto wrapup;
   min_par1 = max_par1 = ht;

   for (i = 1; i < num1; i++)
   {
      (void)BSmkvec(rc, vec, sf1->pt1, Corners1[i]);
      if(BSERROR(*rc)) goto wrapup;
      ht = BSdotp(rc, vec, pln_nvec );
      if(BSERROR(*rc)) goto wrapup;
      if (ht > max_par1)
         max_par1 = ht;
      else if (ht < min_par1)
         min_par1 = ht;
   }

   /* find the min and max points on the line for surface 2 */
   (void)BSmkvec(rc, vec, sf1->pt1, Corners2[0]);
   if(BSERROR(*rc)) goto wrapup;
   ht = BSdotp(rc, vec, pln_nvec );
   if(BSERROR(*rc)) goto wrapup;

   min_par2 = max_par2 = ht;
   for (i = 1; i < num2; i++)
   {
      (void)BSmkvec(rc, vec, sf1->pt1 , Corners2[i]);
      if(BSERROR(*rc)) goto wrapup;
      ht = BSdotp(rc, vec, pln_nvec );
      if(BSERROR(*rc)) goto wrapup;
      if (ht > max_par2)
         max_par2 = ht;
      else if (ht < min_par2)
         min_par2 = ht;
   }

   /* now find the intersection between the 2 min/max */
   min = min_par1;
   if( min_par1 < min_par2 )
      min = min_par2;
   max = max_par1;
   if( max_par1 > max_par2 )
      max = max_par2;

   /* if min > max, then our 2 surface are probably disjoint, but since we're not sure
      our projection curves are planar, we better continue */

   /* find the average point between min and max */
   pln_pt[0]  = ( (sf1->pt1[0] + pln_nvec[0] * min)  +
                 (sf1->pt1[0] + pln_nvec[0] * max) )  * 0.5;
   pln_pt[1]  = ( (sf1->pt1[1] + pln_nvec[1] * min)  +
                 (sf1->pt1[1] + pln_nvec[1] * max) )  * 0.5;
   pln_pt[2]  = ( (sf1->pt1[2] + pln_nvec[2] * min)  +
                 (sf1->pt1[2] + pln_nvec[2] * max) )  * 0.5;

wrapup:
return;
}



void BSx2sf_prj(
struct
  BSgeom_bsp_surf    *sf1,
struct
  BSgeom_bsp_surf    *sf2,
IGRint               *num_grps,
IGRint               **num_int_cvs,
struct
  BSgeom_bsp_curve   **int_cvs,
BSrc                 *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bssfprjprop.h"
#include "bscvcvint.h"
#include "bstrgmcvtsf.h"
#include "bsalloccv.h"
#include "bssfeval.h"
#include "bsconstprcv.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bsnorvec.h"
#include "bsstallcvfl.h"
#include "bsstfrecvfl.h"
#include "bsfreecv.h"
#include "bsactivsplt.h"
#include "bsprj_cv_pl.h"
#include "bslenvec.h"
#include "bscrossp.h"
#include "bsmdistptsf.h"
#endif

   IGRint            i, j, k, num_deriv;
   IGRint            num_in_ints, num_in_overs, n_int, n_over;
   IGRint            numcvs2, *numcvs3 = NULL, *numcvs4 = NULL;
   IGRint            numcvs3_2[MAXNUM], numcvs4_2[MAXNUM];
   IGRint            tnumgrps3, tnumgrps4, tmp_totcvs, totcvs, cnt, offset;
   IGRshort          opt, opt2, order2=2;
   IGRdouble         dist_sqtol, dot_tol;
   IGRdouble         int_par1[MAXNUM], int_par2[MAXNUM];
   IGRdouble         over_par1[2*MAXNUM], over_par2[2*MAXNUM];
   IGRdouble         *a_int_par1 = NULL, *a_int_par2 = NULL;
   IGRdouble         *a_over_par1 = NULL, *a_over_par2 = NULL;
   IGRdouble         sq_distAC, sq_distAD, sq_distBC, sq_distBD;
   IGRdouble         dotAC, dotAD, dotBC, dotBD, dotCX, dotDX;
   IGRdouble         dotp1, dotp2, dotp3;
   IGRdouble         upar, vpar, par;
   IGRpoint          pln_pt, A, B, C, D, X;
   IGRpoint          int_pts[MAXNUM], over_pts[2*MAXNUM];
   IGRpoint          *a_int_pts = NULL, *a_over_pts = NULL;
   IGRvector         pln_nvec, cross, tprjvec2;
   IGRvector         vecAC, vecAD, vecBC, vecBD, vecCX, vecDX;
   IGRboolean        parallel;
   IGRboolean        rem_dup, out_int_alloc = FALSE, out_over_alloc = FALSE;
   IGRboolean        *trimmed_sf1 = NULL, *trimmed_sf2 = NULL;
   IGRboolean        trimmed_sf1_2[MAXNUM], trimmed_sf2_2[MAXNUM];
   IGRboolean        *new_trimmed_sf2 = NULL, new_trimmed_sf2_2[MAXNUM];
   IGRboolean        alloc_numcvs3 = FALSE, alloc_numcvs4 = FALSE;
   IGRboolean        alloc_trimmed_sf1 = FALSE, alloc_trimmed_sf2 = FALSE;
   IGRboolean        alloc_new_trimmed_sf2 = FALSE;
   IGRboolean        tst_plan=TRUE, opp;
   struct
    IGRbsp_curve     *tcv = NULL, *ttcv=NULL;
   struct
    BSgeom_bsp_curve *t2cvs = NULL;
   struct
    BSgeom_bsp_curve **t3cvs = NULL,  **t4cvs = NULL;
   struct
    IGRbsp_curve     *tcv1 = NULL, *tcv2 = NULL;
   struct
    IGRbsp_curve     *prj_cv1 = NULL, *prj_cv2 = NULL;
   BSrc              rc1 = BSSUCC, tmprc = BSSUCC;
   IGRdouble ang, dist_tol, len;
   IGRdouble dist;
   IGRpoint base;
   IGRint num_knots1, num_knots2, num_poles2=2;

   BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol );
   dist_sqtol = dist_tol * dist_tol;

   BSEXTRACTPAR(rc, BSTOLORTHOVEC, dot_tol);

   *num_grps = 0;
   *int_cvs = NULL;
   *num_int_cvs = NULL;
   numcvs2 = 0;
   tnumgrps3 = 0;
   tnumgrps4 = 0;
   tmp_totcvs = 0;
   totcvs = 0;

   /* If geometric properties are not given, call BSsfprjprop fill in these
      properties based on the B-spline surface structure. */
   if (!sf1->geom_prop)
   {
      BSsfprjprop(sf1, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }

   if (!sf2->geom_prop)
   {
      BSsfprjprop(sf2, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }

   /* Determine if projection vectors of sf1 and sf2 are parallel */
   /* find the angle between the 2 vectors */
   (void)BScrossp(rc, sf1->vec1, sf2->vec1, cross );
   if(BSERROR(*rc))
      goto wrapup;
   parallel=FALSE;
   ang = asin( MIN (1.0, BSlenvec(rc, cross ) ) );
   if( ang * MIN(sf1->len1, sf2->len1 ) < dist_tol )
      parallel = TRUE;

   if (parallel)
   {
      /***********************************/
      /* Projection vectors are parallel */
      /***********************************/

      /* Define a plane to project generating curves onto.
         Let's try to find a plane near the actual intersection.
         This will help to prevent roundoff in projection. */

      /* use the average vector as the plane normal */
      /* find out if our projection vectors are in the same direction */
      opp = FALSE;
      if( BSdotp(rc, sf1->vec1, sf2->vec1 ) < 0 )
         opp = TRUE;
      len = 0.0;
      if( opp)
      {
         for(i=0; i< 3; i++)
         {
            pln_nvec[i] = (sf1->vec1[i] - sf2->vec1[i]) * 0.5;
            len += pln_nvec[i] * pln_nvec[i];
         }
      }
      else
      {
         for(i=0; i< 3; i++)
         {
            pln_nvec[i] = (sf1->vec1[i] + sf2->vec1[i]) * 0.5;
            len += pln_nvec[i] * pln_nvec[i];
         }
      }
      /* normalize */
      len = sqrt(len);
      for (i = 0; i < 3; ++i)
          pln_nvec[i] /= len;

      /* this finds our plane point near the intersection */
      planeptBSx2sf_prj(sf1, sf2, pln_nvec, pln_pt, rc );
      if(BSERROR(*rc))
      {
         if(*rc == BSNOSOLUTION )
            *rc = BSSUCC;
         goto wrapup;
      }

      /* instead of projecting the generating curve, which maybe far away
         from the actual intersection...let's find the constant parameter
         curve at pln_pt, which will be like our new generating curve */
      tcv1 = sf1->sfgen_cv;
      tcv2 = sf2->sfgen_cv;

      (void)BSmdistptsf(rc,sf1->bspsf,pln_pt,&upar,&vpar,base,&dist);
      if(BSERROR(*rc))
         goto wrapup;
      if (sf1->gencv_ind == 0)
      {
         par = vpar;
         opt = 2;
      }
      else
      {
         par = upar;
         opt = 1;
      }
      BSalloccv(tcv1->order, tcv1->num_poles, tcv1->rational, tcv1->num_boundaries, &tcv, rc);
      if (BSERROR(*rc))
         goto wrapup;
      (void) BSconstprcv(rc, sf1->bspsf, &opt, &par, &tst_plan, tcv);
      if (BSERROR(*rc))
         goto wrapup;

      (void)BSmdistptsf(rc,sf2->bspsf,pln_pt,&upar,&vpar,base,&dist);
      if(BSERROR(*rc))
         goto wrapup;
      if (sf2->gencv_ind == 0)
      {
         opt2 = 2;
         par = vpar;
      }
      else
      {
         opt2 = 1;
         par = upar;
      }
      BSalloccv(tcv2->order, tcv2->num_poles, tcv2->rational,
                tcv2->num_boundaries, &ttcv, rc);
      if (BSERROR(*rc))
         goto wrapup;
      (void) BSconstprcv(rc, sf2->bspsf, &opt2, &par, &tst_plan, ttcv);
      if (BSERROR(*rc))
         goto wrapup;

      prj_cv1 = (struct IGRbsp_curve *)BSstackalloc((unsigned)
                  (sizeof (struct IGRbsp_curve)));
      if (!prj_cv1)
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }

      prj_cv2 = (struct IGRbsp_curve *)BSstackalloc((unsigned)
                  (sizeof (struct IGRbsp_curve)));
      if (!prj_cv2)
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }

      num_knots1 = tcv1->num_poles + tcv1->order;
      num_knots2 = tcv2->num_poles + tcv2->order;

      (void)BSstallcvfl(tcv1->num_poles, tcv1->rational, num_knots1,
                        prj_cv1, rc);

      (void)BSstallcvfl(tcv2->num_poles, tcv2->rational, num_knots2,
                        prj_cv2, rc);

      (void)BSprj_cv_pl(rc, tcv, pln_pt, pln_nvec, sf1->vec1, prj_cv1);
      if (BSERROR(*rc))
         goto wrapup;

      if ( !opp)
      {
         for (i = 0; i < 3; ++i)
             tprjvec2[i] = sf2->vec1[i];
      }
      else
      {
         for (i = 0; i < 3; ++i)
             tprjvec2[i] = -sf2->vec1[i];
      }

      (void)BSprj_cv_pl(rc, ttcv, pln_pt, pln_nvec, tprjvec2, prj_cv2);
      if (BSERROR(*rc))
         goto wrapup;

      /* Call BScvcvint to intersect prj_cv1 and prj_cv2 to return intersections
         and overlaps. */
      rem_dup = TRUE;
      num_in_ints = MAXNUM;
      num_in_overs = MAXNUM;
      BScvcvint(prj_cv1, prj_cv2, rem_dup, num_in_ints, num_in_overs, int_pts,
                int_par1, int_par2, over_pts, over_par1, over_par2, &n_int,
                &n_over, &out_int_alloc, &out_over_alloc, &a_int_pts,
                &a_int_par1, &a_int_par2, &a_over_pts, &a_over_par1,
                &a_over_par2, rc);
      if (BSERROR(*rc))
         goto wrapup;

      if (n_over == 0 && n_int == 0)
      {
         *num_grps = 0;
         goto wrapup;
      }

      /* Allocate memory for t2cvs -- maxinum number = n_int + n_over */
      t2cvs = (struct BSgeom_bsp_curve *)BSstackalloc((n_int + n_over) * sizeof
                (struct BSgeom_bsp_curve));
      if (! t2cvs)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }

      for (i = 0; i < (n_int + n_over); ++i)
      {
          t2cvs[i].bspcv = NULL;
          t2cvs[i].array1 = NULL;
      }

      if ((n_int + n_over) > MAXNUM)
      {
         trimmed_sf1 = (IGRboolean *)BSstackalloc((n_int + n_over) * sizeof
                           (IGRboolean));
         if (! trimmed_sf1)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_trimmed_sf1 = TRUE;

         trimmed_sf2 = (IGRboolean *)BSstackalloc((n_int + n_over) * sizeof
                           (IGRboolean));
         if (! trimmed_sf2)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_trimmed_sf2 = TRUE;
      }
      else
      {
         trimmed_sf1 = trimmed_sf1_2;
         trimmed_sf2 = trimmed_sf2_2;
      }

      /* If generating curve of either sf1 or sf2 is non-planar and
         BScvcvint returns overlaps, return rc = BSNOTYETSUPPORTED */
      if ((!sf1->sfgen_cv->planar || !tcv2->planar) && n_over > 0)
      {
         *rc = BSNOTYETSUPPORTED;
         goto wrapup;
      }

      /*********************************************/
      /* Determine if sf1 and sf2 actually overlap */
      /*********************************************/
      if (sf1->sfgen_cv->planar && tcv2->planar)
      {
         for (i = 0; i < n_over; ++i)
         {
             /* Determine point on sf1->sfgen_cv and on curve opposite
                sf1->sfgen_cv corresponding to start of overlap.  Do the same
                for sf2. */
             num_deriv = 0;
             if (sf1->gencv_ind == 0)
             {
                /* u = generating curve */
                vpar = sf1->bspsf->v_knots[sf1->bspsf->v_order - 1];
                BSsfeval(sf1->bspsf, over_par1[i*2], vpar, num_deriv,
                         (IGRpoint *)A, rc);
                if (BSERROR(*rc))
                   goto wrapup;

                vpar = sf1->bspsf->v_knots[sf1->bspsf->v_num_poles];
                BSsfeval(sf1->bspsf, over_par1[i*2], vpar, num_deriv,
                         (IGRpoint *)B, rc);
                if (BSERROR(*rc))
                   goto wrapup;
             }
             else
             {
                /* v = generating curve */
                upar = sf1->bspsf->u_knots[sf1->bspsf->u_order - 1];
                BSsfeval(sf1->bspsf, over_par1[i*2], upar, num_deriv,
                         (IGRpoint *)A, rc);
                if (BSERROR(*rc))
                   goto wrapup;

                upar = sf1->bspsf->u_knots[sf1->bspsf->u_num_poles];
                BSsfeval(sf1->bspsf, over_par1[i*2], upar, num_deriv,
                         (IGRpoint *)B, rc);
                if (BSERROR(*rc))
                   goto wrapup;
             }

             if (sf2->gencv_ind == 0)
             {
                /* u = generating curve */
                vpar = sf2->bspsf->v_knots[sf2->bspsf->v_order - 1];
                BSsfeval(sf2->bspsf, over_par2[i*2], vpar, num_deriv,
                         (IGRpoint *)C, rc);
                if (BSERROR(*rc))
                   goto wrapup;

                vpar = sf2->bspsf->v_knots[sf2->bspsf->v_num_poles];
                BSsfeval(sf2->bspsf, over_par2[i*2], vpar, num_deriv,
                         (IGRpoint *)D, rc);
                if (BSERROR(*rc))
                   goto wrapup;
             }
             else
             {
                /* v = generating curve */
                upar = sf2->bspsf->u_knots[sf2->bspsf->u_order - 1];
                BSsfeval(sf2->bspsf, over_par2[i*2], upar, num_deriv,
                         (IGRpoint *)C, rc);
                if (BSERROR(*rc))
                   goto wrapup;

                upar = sf2->bspsf->u_knots[sf2->bspsf->u_num_poles];
                BSsfeval(sf2->bspsf, over_par2[i*2], upar, num_deriv,
                         (IGRpoint *)D, rc);
                if (BSERROR(*rc))
                   goto wrapup;
             }

             /* Determine if sf1 and sf2 intersect (touch), overlap, or are
                disjoint*/
             sq_distAC = BSdistptpts(rc, A, C);
             if (BSERROR(*rc))
                goto wrapup;

             sq_distAD = BSdistptpts(rc, A, D);
             if (BSERROR(*rc))
                goto wrapup;

             sq_distBC = BSdistptpts(rc, B, C);
             if (BSERROR(*rc))
                goto wrapup;

             sq_distBD = BSdistptpts(rc, B, D);
             if (BSERROR(*rc))
                goto wrapup;

             if (sq_distAC <= dist_sqtol || sq_distBC <= dist_sqtol)
             {
                /* sf2 touches sf1 along sf1->sfgen_cv or opposite
                   sf1->sfgen_cv at C.  Determine if coincident or intersection
                   depending on position of D or B (or A). */

                for (j = 0; j < 3; ++j)
                {
                    vecAD[j] = D[j] - A[j];
                    vecBD[j] = D[j] - B[j];
                }

                dotAD = BSdotp(rc, sf1->vec1, vecAD);
                if (BSERROR(*rc))
                   goto wrapup;

                dotBD = BSdotp(rc, sf1->vec1, vecBD);
                if (BSERROR(*rc))
                   goto wrapup;

                if (dotAD > dot_tol && dotBD < dot_tol)
                {
                   /* D is between A and B -- coincident surfaces */
                   tmprc = BSCOINCIDENT;
                }
                else
                {
                   if (sq_distAC <= dist_sqtol)
                   {
                      for (j = 0; j < 3; ++j)
                          X[j] = B[j];
                   }
                   else
                   {
                      for (j = 0; j < 3; ++j)
                          X[j] = A[j];
                   }

                   /* Check if X (A or B) is between C and D */
                   for (j = 0; j < 3; ++j)
                   {
                       vecCX[j] = X[j] - C[j];
                       vecDX[j] = X[j] - D[j];
                   }
                   dotCX = BSdotp(rc, sf1->vec1, vecCX);
                   if (BSERROR(*rc))
                      goto wrapup;

                   dotDX = BSdotp(rc, sf1->vec1, vecDX);
                   if (BSERROR(*rc))
                      goto wrapup;

                   if (dotCX > dot_tol && dotDX < dot_tol)
                   {
                      /* X (A or B) is between C and D -- coincident
                         surfaces */
                      tmprc = BSCOINCIDENT;
                   }
                   else
                   {
                      /* surfaces touch along an edge */
                      if (sq_distAC <= dist_sqtol)
                      {
                         /* intersection is along sf1->sfgen_cv */
                         BSalloccv(sf1->sfgen_cv->order, sf1->sfgen_cv->
                                   num_poles, sf1->sfgen_cv->rational,
                                   sf1->sfgen_cv->num_boundaries,
                                   &(t2cvs[numcvs2].bspcv), rc);
                         if (BSERROR(*rc))
                            goto wrapup;

                         (void)BSactivsplt(rc, sf1->sfgen_cv,&(over_par1[i*2]),
                                    &(over_par1[i*2+1]), t2cvs[numcvs2].bspcv,
                                    &tst_plan);
                         if (BSERROR(*rc))
                            goto wrapup;

                         t2cvs[numcvs2].geom_prop = FALSE;
                         t2cvs[numcvs2].bscv_flag = TRUE;
                         t2cvs[numcvs2].type = BSGEN_BSP_CV;

                         trimmed_sf1[numcvs2] = TRUE;
                         trimmed_sf2[numcvs2] = TRUE;

                         ++numcvs2;
                      }
                      else
                      {
                         /* sq_distBC <= dist_sqtol -- intersection is along
                            curve opposite of sf1->sfgen_cv. */

                         BSalloccv(sf1->sfgen_cv->order, sf1->sfgen_cv->
                                   num_poles, sf1->sfgen_cv->rational,
                                   sf1->sfgen_cv->num_boundaries,
                                   &(t2cvs[numcvs2].bspcv), rc);
                         if (BSERROR(*rc))
                            goto wrapup;

                         if (sf1->gencv_ind == 0)
                         {
                            /* constant v parameter */
                            par = sf1->bspsf->v_knots[sf1->bspsf->v_num_poles];
                         }
                         else
                         {
                            /* constant u parameter */
                            par = sf1->bspsf->u_knots[sf1->bspsf->u_num_poles];
                         }

                         (void) BSconstprcv(rc, sf1->bspsf, &opt, &par,
                                            &tst_plan, tcv);
                         if (BSERROR(*rc))
                            goto wrapup;

                         (void)BSactivsplt(rc,tcv,&(over_par1[i*2]),
                                     &(over_par1[i*2+1]), t2cvs[numcvs2].bspcv,
                                     &tst_plan);
                         if (BSERROR(*rc))
                            goto wrapup;

                         t2cvs[numcvs2].geom_prop = FALSE;
                         t2cvs[numcvs2].bscv_flag = TRUE;
                         t2cvs[numcvs2].type = BSGEN_BSP_CV;

                         trimmed_sf1[numcvs2] = TRUE;
                         trimmed_sf2[numcvs2] = TRUE;

                         ++numcvs2;
                      }   /* end if (sq_distAC <= dist_sqtol) */
                   }   /* end if (dotCB > dot_tol && dotDB < dot_tol) */
                }   /* end if (dotAD > dot_tol && dotBD < dot_tol) */
             }
             else
             {
                if (sq_distAD <= dist_sqtol || sq_distBD <= dist_sqtol)
                {
                   /* sf2 touches sf1 along sf1->sfgen_cv or opposite
                      sf1->sfgen_cv at D.  Determine if coincident or inter-
                      section depending on position of C or B (or A). */

                   for (j = 0; j < 3; ++j)
                   {
                       vecAC[j] = C[j] - A[j];
                       vecBC[j] = C[j] - B[j];
                   }

                   dotAC = BSdotp(rc, sf1->vec1, vecAC);
                   if (BSERROR(*rc))
                      goto wrapup;

                   dotBC = BSdotp(rc, sf1->vec1, vecBC);
                   if (BSERROR(*rc))
                      goto wrapup;

                   if (dotAC > dot_tol && dotBC < dot_tol)
                   {
                      /* C is between A and B -- coincident surfaces */
                      tmprc = BSCOINCIDENT;
                   }
                   else
                   {
                      if (sq_distAD <= dist_sqtol)
                      {
                         for (j = 0; j < 3; ++j)
                             X[j] = B[j];
                      }
                      else
                      {
                         for (j = 0; j < 3; ++j)
                             X[j] = A[j];
                      }

                      /* Check if X (A or B) is between C and D */
                      for (j = 0; j < 3; ++j)
                      {
                          vecCX[j] = X[j] - C[j];
                          vecDX[j] = X[j] - D[j];
                      }
                      dotCX = BSdotp(rc, sf1->vec1, vecCX);
                      if (BSERROR(*rc))
                         goto wrapup;

                      dotDX = BSdotp(rc, sf1->vec1, vecDX);
                      if (BSERROR(*rc))
                         goto wrapup;

                      if (dotCX > dot_tol && dotDX < dot_tol)
                      {
                         /* X (A or B) is between C and D -- coincident
                            surfaces */
                         tmprc = BSCOINCIDENT;
                      }
                      else
                      {
                         /* surfaces touch along an edge */
                         if (sq_distAD <= dist_sqtol)
                         {
                            /* intersection is along sf1->sfgen_cv */
                            BSalloccv(sf1->sfgen_cv->order, sf1->sfgen_cv->
                                      num_poles, sf1->sfgen_cv->rational,
                                      sf1->sfgen_cv->num_boundaries,
                                      &(t2cvs[numcvs2].bspcv), rc);
                            if (BSERROR(*rc))
                               goto wrapup;

                            (void)BSactivsplt(rc, sf1->sfgen_cv,
                                     &(over_par1[i*2]), &(over_par1[i*2+1]),
                                     t2cvs[numcvs2].bspcv, &tst_plan);
                            if (BSERROR(*rc))
                               goto wrapup;

                            t2cvs[numcvs2].geom_prop = FALSE;
                            t2cvs[numcvs2].bscv_flag = TRUE;
                            t2cvs[numcvs2].type = BSGEN_BSP_CV;

                            trimmed_sf1[numcvs2] = TRUE;
                            trimmed_sf2[numcvs2] = TRUE;

                            ++numcvs2;
                         }
                         else
                         {
                            /* sq_distBD <= dist_sqtol -- intersection is along
                               curve opposite of sf1->sfgen_cv. */

                            BSalloccv(sf1->sfgen_cv->order, sf1->sfgen_cv->
                                      num_poles, sf1->sfgen_cv->rational,
                                      sf1->sfgen_cv->num_boundaries,
                                      &(t2cvs[numcvs2].bspcv), rc);
                            if (BSERROR(*rc))
                               goto wrapup;

                            if (sf1->gencv_ind == 0)
                            {
                               /* constant v parameter */
                               par = sf1->bspsf->v_knots[sf1->bspsf->
                                       v_num_poles];
                            }
                            else
                            {
                               /* constant u parameter */
                               par = sf1->bspsf->u_knots[sf1->bspsf->
                                       u_num_poles];
                            }

                            (void) BSconstprcv(rc, sf1->bspsf, &opt, &par,
                                               &tst_plan, tcv);
                            if (BSERROR(*rc))
                               goto wrapup;

                            (void)BSactivsplt(rc,tcv,&(over_par1[i*2]),
                                    &(over_par1[i*2+1]), t2cvs[numcvs2].bspcv,
                                    &tst_plan);
                            if (BSERROR(*rc))
                               goto wrapup;

                            t2cvs[numcvs2].geom_prop = FALSE;
                            t2cvs[numcvs2].bscv_flag = TRUE;
                            t2cvs[numcvs2].type = BSGEN_BSP_CV;

                            trimmed_sf1[numcvs2] = TRUE;
                            trimmed_sf2[numcvs2] = TRUE;

                            ++numcvs2;

                         }   /* end if (sq_distAD <= dist_sqtol) */

                      }   /* end if (dotCX > dot_tol && dotDX < dot_tol) */

                   }   /* end if (dotAC > dot_tol && dotBC < dot_tol) */
                }
                else
                {
                   /* Determine if disjoint or coincident without touching
                      edges*/
                   for (j = 0; j < 3; ++j)
                   {
                       vecAD[j] = D[j] - A[j];
                       vecBD[j] = D[j] - B[j];
                       vecAC[j] = C[j] - A[j];
                       vecBC[j] = C[j] - B[j];
                   }

                   dotAD = BSdotp(rc, sf1->vec1, vecAD);
                   if (BSERROR(*rc))
                      goto wrapup;

                   dotBD = BSdotp(rc, sf1->vec1, vecBD);
                   if (BSERROR(*rc))
                      goto wrapup;

                   dotAC = BSdotp(rc, sf1->vec1, vecAC);
                   if (BSERROR(*rc))
                      goto wrapup;

                   dotBC = BSdotp(rc, sf1->vec1, vecBC);
                   if (BSERROR(*rc))
                      goto wrapup;

                   if ((dotAD > dot_tol && dotBD < dot_tol) ||
                       (dotAC > dot_tol && dotBC < dot_tol) ||
                       (dotAD > dot_tol && dotAC < dot_tol) ||
                       (dotBD > dot_tol && dotBC < dot_tol))
                   {
                      /* sf1 and sf2 are coincident */

                      tmprc = BSCOINCIDENT;
                   }

                }   /* end if (sq_distAD <= dist_sqtol ||
                               sq_distBD <= dist_sqtol) */

             }   /* end if (sq_distAC <= dist_sqtol ||
                            sq_distBC <= dist_sqtol) */

          }   /* end for (i = 0; i < n_over,  ++i) */
      }   /* end if (sf1->sfgen_cv->planar && tcv2->planar) */


      /***********************************************/
      /* Determine if sf1 and sf2 actually intersect */
      /***********************************************/

      for (i = 0; i < n_int; ++i)
      {
         /* Determine point on sf1->sfgen_cv and curve opposite sf1->sfgen_cv
            corresponding to start of intersection.  Do the same for sf2. */
         num_deriv = 0;
         if (sf1->gencv_ind == 0)
         {
            /* u = generating curve */
            vpar = sf1->bspsf->v_knots[sf1->bspsf->v_order - 1];
            BSsfeval(sf1->bspsf, int_par1[i], vpar, num_deriv, (IGRpoint *)A,
                     rc);
            if (BSERROR(*rc))
               goto wrapup;

            vpar = sf1->bspsf->v_knots[sf1->bspsf->v_num_poles];
            BSsfeval(sf1->bspsf, int_par1[i], vpar, num_deriv, (IGRpoint *)B,
                     rc);
            if (BSERROR(*rc))
               goto wrapup;
         }
         else
         {
            /* v = generating curve */
            upar = sf1->bspsf->u_knots[sf1->bspsf->u_order - 1];
            BSsfeval(sf1->bspsf, upar, int_par1[i], num_deriv, (IGRpoint *)A,
                     rc);
            if (BSERROR(*rc))
               goto wrapup;

            upar = sf1->bspsf->u_knots[sf1->bspsf->u_num_poles];
            BSsfeval(sf1->bspsf, upar, int_par1[i], num_deriv, (IGRpoint *)B,
                     rc);
            if (BSERROR(*rc))
               goto wrapup;
         }

         if (sf2->gencv_ind == 0)
         {
            /* u = generating curve */
            vpar = sf2->bspsf->v_knots[sf2->bspsf->v_order - 1];
            BSsfeval(sf2->bspsf, int_par2[i], vpar, num_deriv, (IGRpoint *)C,
                     rc);
            if (BSERROR(*rc))
               goto wrapup;

            vpar = sf2->bspsf->v_knots[sf2->bspsf->v_num_poles];
            BSsfeval(sf2->bspsf, int_par2[i], vpar, num_deriv, (IGRpoint *)D,
                     rc);
            if (BSERROR(*rc))
               goto wrapup;
         }
         else
         {
            /* v = generating curve */
            upar = sf2->bspsf->u_knots[sf2->bspsf->u_order - 1];
            BSsfeval(sf2->bspsf, upar, int_par2[i], num_deriv, (IGRpoint *)C,
                     rc);
            if (BSERROR(*rc))
               goto wrapup;

            upar = sf2->bspsf->u_knots[sf2->bspsf->u_num_poles];
            BSsfeval(sf2->bspsf, upar, int_par2[i], num_deriv, (IGRpoint *)D,
                     rc);
            if (BSERROR(*rc))
               goto wrapup;
         }

         for (j = 0; j < 3; ++j)
         {
             vecAC[j] = C[j] - A[j];
             vecAD[j] = D[j] - A[j];
             vecBC[j] = C[j] - B[j];
             vecBD[j] = D[j] - B[j];
         }

         sq_distAC = BSdistptpts(rc, C, A);
         if (BSERROR(*rc))
            goto wrapup;

         if (sq_distAC > dist_sqtol)
         {
            (void)BSnorvec(rc, vecAC);
            if (BSERROR(*rc))
               goto wrapup;
         }

         sq_distAD = BSdistptpts(rc, D, A);
         if (BSERROR(*rc))
            goto wrapup;

         if (sq_distAD > dist_sqtol)
         {
            (void)BSnorvec(rc, vecAD);
            if (BSERROR(*rc))
              goto wrapup;
         }

         sq_distBC = BSdistptpts(rc, C, B);
         if (BSERROR(*rc))
            goto wrapup;

         if (sq_distBC > dist_sqtol)
         {
            (void)BSnorvec(rc, vecBC);
            if (BSERROR(*rc))
               goto wrapup;
         }

         sq_distBD = BSdistptpts(rc, D, B);
         if (BSERROR(*rc))
            goto wrapup;

         if (sq_distBD > dist_sqtol)
         {
            (void)BSnorvec(rc, vecBD);
            if (BSERROR(*rc))
               goto wrapup;
         }

         /* Initialize for apogee warning */
         dotp1 = -99.0;
         dotp2 = -99.0;
         dotp3 = -99.0;

         if (sq_distAC > dist_sqtol && sq_distAD > dist_sqtol)
         {
            dotp1 = BSdotp(rc, vecAC, vecAD);
            if (BSERROR(*rc))
               goto wrapup;
         }

         if (sq_distAC > dist_sqtol && sq_distBC > dist_sqtol)
         {
            dotp2 = BSdotp(rc, vecAC, vecBC);
            if (BSERROR(*rc))
               goto wrapup;
         }

         if (sq_distAC > dist_sqtol && sq_distBD > dist_sqtol)
         {
            dotp3 = BSdotp(rc, vecAC, vecBD);
            if (BSERROR(*rc))
               goto wrapup;
         }

         if (ABS(1-dotp1) < dot_tol && ABS(1-dotp2) < dot_tol &&
             ABS(1-dotp3) < dot_tol && sq_distAC > dist_sqtol &&
             sq_distAD > dist_sqtol && sq_distBC > dist_sqtol &&
             sq_distBD > dist_sqtol)
         {
            /* sf1 and sf2 are disjoint */
         }
         else
         {
            /* Generate bounded line(projection direction) on sf1 at intersection */
            if (sf1->gencv_ind == 0)
               opt2 = 1;
            else
               opt2 = 2;
            BSalloccv(order2, num_poles2, sf1->bspsf->rational, 0,
                      &(t2cvs[numcvs2].bspcv), rc);
            if (BSERROR(*rc))
               goto wrapup;

            (void)BSconstprcv(rc, sf1->bspsf, &opt2, &(int_par1[i]), &tst_plan,
                              t2cvs[numcvs2].bspcv);
            if (BSERROR(*rc))
               goto wrapup;

            t2cvs[numcvs2].geom_prop = FALSE;
            t2cvs[numcvs2].bscv_flag = TRUE;
            t2cvs[numcvs2].type = BSGEN_BSP_CV;

            trimmed_sf1[numcvs2] = TRUE;
            trimmed_sf2[numcvs2] = FALSE;

            ++numcvs2;

         }
      }   /* end for (i = 0; i < n_int; ++i) */

      if (numcvs2 == 0)
      {
         *rc = tmprc;
      }

   }
   else
   {
       *rc = BSNOTYETSUPPORTED;
       numcvs2 = 0;
   }   /* end if (parallel) */

   /* Trim t2cvs with respect to both surfaces. */
   if (numcvs2 == 0)
   {
      *num_grps = 0;
      goto wrapup;
   }
   else
   {
      if (numcvs2 > MAXNUM)
      {
         numcvs3 = (IGRint *)BSstackalloc((unsigned)numcvs2 * sizeof(IGRint));
         if (!numcvs3)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_numcvs3 = TRUE;

         new_trimmed_sf2 = (IGRboolean *)BSstackalloc((unsigned)
                               numcvs2 * sizeof(IGRboolean));
         if (!new_trimmed_sf2)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_new_trimmed_sf2 = TRUE;
      }
      else
      {
         numcvs3 = numcvs3_2;
         new_trimmed_sf2 = new_trimmed_sf2_2;
      }

      t3cvs = (struct BSgeom_bsp_curve **)BSstackalloc((unsigned) numcvs2 *
                      sizeof (struct BSgeom_bsp_curve *));
      if (!t3cvs)
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }

      for (i = 0; i < numcvs2; ++i)
      {
          t3cvs[i] = NULL;
          new_trimmed_sf2[i] = FALSE;
      }

      /* Call BStrgmcvtsf to trim t2cvs with sf1 */
      tmp_totcvs = 0;
      cnt = 0;
      tnumgrps3 = 0;
      for (i = 0; i < numcvs2; ++i)
      {
         if (!trimmed_sf1[i])
         {
            numcvs3[cnt] = 0;
            BStrgmcvtsf(&(t2cvs[i]), sf1, &(numcvs3[cnt]), &(t3cvs[cnt]),rc);
            if (BSERROR(*rc))
               goto wrapup;
         }
         else
         {
            /* Copy t2cvs[i] into t3cvs[cnt] */
            t3cvs[cnt] = (struct BSgeom_bsp_curve *)BSstackalloc((unsigned)
                            sizeof (struct BSgeom_bsp_curve));
            if (!t3cvs[cnt])
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }

            BSMEMCPY(sizeof (struct BSgeom_bsp_curve), (IGRchar *)&(t2cvs[i]),
                     (IGRchar *)t3cvs[cnt]);
            t2cvs[i].bspcv = NULL;
            t2cvs[i].array1 = NULL;

            numcvs3[cnt] = 1;

         }

         if (numcvs3[cnt] > 0)
         {
            new_trimmed_sf2[cnt] = trimmed_sf2[i];
            tmp_totcvs += numcvs3[cnt];
            ++cnt;
            ++tnumgrps3;
         }
      }   /* end i loop */

      if (tmp_totcvs == 0)
      {
         *num_grps = 0;
         goto wrapup;
      }
      else
      {
         /* Trim w.r.t. sf2. */

         if (tmp_totcvs > MAXNUM)
         {
            numcvs4 = (IGRint *)BSstackalloc((unsigned)tmp_totcvs *
                           sizeof(IGRint));
            if (!numcvs4)
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            alloc_numcvs4 = TRUE;
         }
         else
         {
            numcvs4 = numcvs4_2;
         }

         t4cvs = (struct BSgeom_bsp_curve **)BSstackalloc((unsigned)
                         tmp_totcvs * sizeof (struct BSgeom_bsp_curve *));
         if (!t4cvs)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }

         for (i = 0; i < tmp_totcvs; ++i)
             t4cvs[i] = NULL;

         /* Call BStrgmcvtsf for each t1cvs */
         totcvs = 0;
         cnt = 0;
         tnumgrps4 = 0;
         for (i = 0; i < tnumgrps3; ++i)
         {
            for (j = 0; j < numcvs3[i]; ++j)
            {
               if (!new_trimmed_sf2[cnt])
               {
                  numcvs4[cnt] = 0;
                  BStrgmcvtsf(&(t3cvs[i][j]), sf2, &(numcvs4[cnt]),
                              &(t4cvs[cnt]), rc);
                  if (BSERROR(*rc))
                     goto wrapup;
               }
               else
               {
                  /* Copy t3cvs[i][j] into t4cvs[cnt] */
                  t4cvs[cnt] = (struct BSgeom_bsp_curve *)BSmalloc
                               ((unsigned) (sizeof (struct BSgeom_bsp_curve)));
                  if (!t4cvs[cnt])
                  {
                     *rc = BSNOSTKMEMORY;
                     goto wrapup;
                  }

                  BSMEMCPY(sizeof (struct BSgeom_bsp_curve),
                           (IGRchar *)&(t3cvs[i][j]), (IGRchar *)t4cvs[cnt]);
                  for (j = 0; j < numcvs3[i]; ++j)
                  {
                      t3cvs[i][j].bspcv = NULL;
                      t3cvs[i][j].array1 = NULL;
                  }
                  numcvs4[cnt] = numcvs3[i];

               }

               if (numcvs4[cnt] > 0)
               {
                  totcvs += numcvs4[cnt];
                  ++cnt;
                  ++tnumgrps4;
               }
            }
         }   /* end i loop */

         /* Copy t4cvs into final output int_cvs */

         if (totcvs == 0)
         {
            *num_grps = 0;
            goto wrapup;
         }
         else
         {
            /* Allocate memory for output */
            *num_int_cvs = (IGRint *)BSmalloc(totcvs * sizeof (IGRint));
            if (! *num_int_cvs)
            {
               *rc = BSNOMEMORY;
               goto wrapup;
            }

            *int_cvs = (struct BSgeom_bsp_curve *)BSmalloc(totcvs * sizeof
                               (struct BSgeom_bsp_curve));
            if (! *int_cvs)
            {
               *rc = BSNOMEMORY;
               goto wrapup;
            }

            cnt = 0;
            offset = 0;
            for (i = 0; i < tnumgrps4; ++i)
            {
                for (j = 0; j < numcvs4[i]; ++j)
                {
                   (*int_cvs)[cnt].bspcv = NULL;
                   (*int_cvs)[cnt].array1 = NULL;
                   (*num_int_cvs)[cnt] = 1;
                   ++cnt;
                }

                BSMEMCPY((numcvs4[i] * sizeof (struct BSgeom_bsp_curve)),
                          (IGRchar *)t4cvs[i],
                          (IGRchar *)&(int_cvs[0][offset]));

                for (j = 0; j < numcvs4[i]; ++j)
                {
                   t4cvs[i][j].bspcv = NULL;
                   t4cvs[i][j].array1 = NULL;
                }

                offset += numcvs4[i];

            }
            *num_grps = totcvs;

         }   /* end if (totcvs == 0) */

      }   /* end if (tmp_totcvs == 0) */

   }

   wrapup:

   /* If num_grps == 0, deallocate all final output */
   if (*num_grps == 0)
   {
      if (*num_int_cvs)
      {
         BSdealloc((char *) *num_int_cvs);
         *num_int_cvs = NULL;
      }

      if (*int_cvs)
      {
         BSdealloc((char *) *int_cvs);
         *int_cvs = NULL;
      }
   }

   if (out_int_alloc)
   {
      if (a_int_pts)
      {
         BSdealloc((char *) a_int_pts);
         a_int_pts = NULL;
      }

      if (a_int_par1)
      {
         BSdealloc((char *) a_int_par1);
         a_int_par1 = NULL;
      }

      if (a_int_par2)
      {
         BSdealloc((char *) a_int_par2);
         a_int_par2 = NULL;
      }
   }

   if (out_over_alloc)
   {
      if (a_over_pts)
      {
         BSdealloc((char *) a_over_pts);
         a_over_pts = NULL;
      }

      if (a_over_par1)
      {
         BSdealloc((char *) a_over_par1);
         a_over_par1 = NULL;
      }

      if (a_over_par2)
      {
         BSdealloc((char *) a_over_par2);
         a_over_par2 = NULL;
      }
   }

   if (t4cvs)
   {
      i = totcvs - 1;
      while ( i >= 0)
      {
         if (t4cvs[i])
         {
            k = numcvs4[i] - 1;
            while (k >= 0)
            {
               if (t4cvs[i][k].array1)
               {
                  BSdealloc((char *) t4cvs[i][k].array1);
                  t4cvs[i][k].array1 = NULL;
               }

               if (t4cvs[i][k].bspcv)
               {
                  (void)BSfreecv(&rc1, t4cvs[i][k].bspcv);
                  if (BSERROR(rc1) && BSOKAY(*rc))
                     *rc = rc1;
                  t4cvs[i][k].bspcv = NULL;
                  rc1 = BSSUCC;
               }
               --k;
            }
            BSdealloc((char *) t4cvs[i]);
            t4cvs[i] = NULL;
         }
         --i;
      }
      BSstackdealloc((char *) t4cvs);
      t4cvs = NULL;
   }

   if (numcvs4 && alloc_numcvs4)
   {
      BSstackdealloc((char *) numcvs4);
      numcvs4 = NULL;
   }

   if (t3cvs)
   {
      i = tmp_totcvs - 1;
      while ( i >= 0)
      {
         if (t3cvs[i])
         {
            k = numcvs3[i] - 1;
            while (k >= 0)
            {
               if (t3cvs[i][k].array1)
               {
                  BSdealloc((char *) t3cvs[i][k].array1);
                  t3cvs[i][k].array1 = NULL;
               }

               if (t3cvs[i][k].bspcv)
               {
                  (void)BSfreecv(&rc1, t3cvs[i][k].bspcv);
                  if (BSERROR(rc1) && BSOKAY(*rc))
                     *rc = rc1;
                  t3cvs[i][k].bspcv = NULL;
                  rc1 = BSSUCC;
               }
               --k;
            }
            BSstackdealloc((char *) t3cvs[i]);
            t3cvs[i] = NULL;
         }
         --i;
      }
      BSstackdealloc((char *) t3cvs);
      t3cvs = NULL;
   }

   if (new_trimmed_sf2 && alloc_new_trimmed_sf2)
   {
      BSstackdealloc((char *) new_trimmed_sf2);
      new_trimmed_sf2 = NULL;
   }

   if (numcvs3 && alloc_numcvs3)
   {
      BSstackdealloc((char *) numcvs3);
      numcvs3 = NULL;
   }

   if (tcv)
   {
      (void)BSfreecv(&rc1, tcv);
      if (BSERROR(rc1) && BSOKAY(*rc))
         *rc = rc1;
      tcv = NULL;
      rc1 = BSSUCC;
   }
   if (ttcv)
   {
      (void)BSfreecv(&rc1, ttcv);
      if (BSERROR(rc1) && BSOKAY(*rc))
         *rc = rc1;
      ttcv = NULL;
      rc1 = BSSUCC;
   }
   if (t2cvs)
   {
      i = numcvs2 - 1;
      while (i >= 0)
      {
         if (t2cvs[i].array1)
         {
            BSdealloc((char *) t2cvs[i].array1);
            t2cvs[i].array1 = NULL;
         }

         if (t2cvs[i].bspcv)
         {
            (void)BSfreecv(&rc1, t2cvs[i].bspcv);
            if (BSERROR(rc1) && BSOKAY(*rc))
               *rc = rc1;
            t2cvs[i].bspcv = NULL;
            rc1 = BSSUCC;
         }
         --i;
      }
      BSstackdealloc((char *) t2cvs);
      t2cvs = NULL;
   }

   if (trimmed_sf2 && alloc_trimmed_sf2)
   {
      BSstackdealloc((char *) trimmed_sf2);
      trimmed_sf2 = NULL;

   }

   if (trimmed_sf1 && alloc_trimmed_sf1)
   {
      BSstackdealloc((char *) trimmed_sf1);
      trimmed_sf1 = NULL;

   }

   if (prj_cv2)
   {
      (void) BSstfrecvfl(&rc1, prj_cv2);
      if (BSERROR(rc1) && BSOKAY(*rc))
         *rc = rc1;
      BSstackdealloc((char *)prj_cv2);
      prj_cv2 = NULL;
      rc1 = BSSUCC;
   }

   if (prj_cv1)
   {
      (void) BSstfrecvfl(&rc1, prj_cv1);
      if (BSERROR(rc1) && BSOKAY(*rc))
         *rc = rc1;
      BSstackdealloc((char *)prj_cv1);
      prj_cv1 = NULL;
      rc1 = BSSUCC;
   }




   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSx2sf_prj");
   return;
   }
}
