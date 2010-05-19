/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSxsfprjpln

Abstract
    This routine intersects a surface of projection and a planar surface
    and returns the intersection curves in BSgeom_bsp_curve structure format.

Synopsis
    BSxsfprjpln(sf_prj, pln, num_grps, num_int_cvs, int_cvs, rc)

    struct BSgeom_bsp_surf   *sf_prj
    struct BSgeom_bsp_surf   *pln
    IGRint                   *num_grps
    IGRint                   **num_int_cvs
    struct BSgeom_bsp_curve  **int_cvs
    BSrc                     *rc

Description
   Input:
     *sf_prj........structure for surface of projection
     *pln...........structure for planar surface

   Input/Output:

   Output:
     *num_grps......number of groups of intersection curves
     **num_int_cvs..pointer to array of number of intersection curves per group
     **int_cvs......pointer to array of structures containing geometric
                     properties of resulting intersection curves.
     *rc............possible return codes:
                     BSSUCC         successful completion
                     BSCOINCIDENT   the 2 surfaces are coplanar.

   Algorithm:
     This routine inputs a surface of projection and a planar surface
     in BSgeom_bsp_surf structure format and returns the number of
     groups of intersection curves (num_grps), an array of the number of
     intersection curves per group (num_int_cvs) and an array of structures
     (int_cvs) of resulting intersection curves.

Return Values


Notes
    Memory for num_int_cvs and int_cvs is allocated in this routine.

Index
    md

Keywords

History
    S.C. Wood     10/18/90  : Creation date.
    S.C. Wood     11/15/90  : Changed reference from sf_prj->rt_orient to
                              sf_prj->reg_constr and pln->rt_orient to pln->
                              reg_constr to adapt to changes in BSgeom_cvsf.h.
                              Set tnumgrps3 = tnumgrps2 if intersection curves
                              are not trimmed with pln.
    S.C. Wood     12/05/90  : Corrected calculation of num_cvs2, num_cvs3,
                              tnumgrps2, and tnumgrps3.
    S.C. Wood     03/12/91  : Initialize and deallocate array1 in all
                              BSgeom_bsp_curve.
    S.C. Wood     11/06/91  : Check if sf_prj->bounded = TRUE before calling
                              BStrgmcvtsf to trim intersection curves against
                              sf_prj.   Modified header.
    S.C. Wood     11/26/91  : Corrected initialization of tcvs[i]->bspcv and
                              tcvs[i]->array1. Implement BSdbgrc.
    P.R. Slubicki 02/28/92  : I corrected some memory problems by now only
                              using BSmalloc() and BSdealloc() instead of
                              BSstackalloc() and BSstackdealloc() when proces-
                              sing memory for t2cvs[i] and t3cvs[i].
    S.C. Wood     05/04/92  : Set new_pln.bounded = pln->bounded if pln->type
                              == BSRECT_PLANE.  Check new_pln.bounded instead
                              of type of surface for trimming decisions.
    S.C. Wood     06/09/92  : If sf_prj is planar and parallel to new_pln,
                              and sf_prj projection vector is parallel to
                              new_pln normal, call BSbdlnplint to intersect
                              bounded line from start of generating curve along
                              length of projection vector with new_pln.
                              Previously, this line intersection was always
                              being done if sf_prj projection vector is
                              parallel to new_pln normal without regard to
                              positioning of sf_prj.
    S.C. Wood     12/10/92  : Modified to not call BStstcvfln which was
                              called when sf_prj was planar and linear
                              curve was expected.  If BStstcvfln returned
                              that the curve was linear, we constructed
                              a line (order = 2, npoles = 2).  Took all of
                              this out.
    S.G. Catron   03/03/93  : Initialize n_int = 0.
    S.C. Wood     04/05/93  : If pln is parallel to sf_proj->vec1 (proj.
                              vector), calculate a vector (V2) lying in pln
                              in direction of sf_prj->vec1 to insure that
                              (V2) is definitely in the plane; avoiding any
                              roundoff errors.  Fix for TR # 9304122.
    S.G. Catron   03/30/01  : TR 4842 - first the tolerance used in testing for
                              parallel did not take into consideration the
                              length of the geometry. Second, if parallel and the
                              intersection line crosses the seam, make the line
                              to be right on the seam.
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
#include "bsdefs.h"
#include "bsgeom_cvsf.h"
#include "bsconic.h"
#include "bsmemory.h"
#include "bsvalues.h"
#endif
#include <math.h>

#define  BSVOID

#define MAXNUM 100


/*************************************************************************/
static void genptcvBSxsfprjpln(
IGRpoint            pt,
struct
  BSgeom_bsp_curve  *int_cv,
BSrc                *rc)
{
#ifndef DONOTSPROTO
#include "bsptcvgen.h"
#endif

   IGRint      i;
   IGRshort    order;
   IGRboolean  rational;

   (*int_cv).geom_prop = 1;
   (*int_cv).type = BSPOINT;

   for (i = 0; i < 3; ++i)
   {
       (*int_cv).pt1[i] = pt[i];
   }

   order = 2;
   rational = FALSE;
   BSptcvgen(pt, order, rational, (*int_cv).bspcv, rc);
   if (BSERROR(*rc))
      goto wrapup;

   if ((*int_cv).bspcv)
      (*int_cv).bscv_flag = TRUE;

   wrapup:

   return;
}

/*************************************************************************/
static void genlineBSxsfprjpln(
struct IGRbsp_surface *prj_sf,
IGRpoint            pt1,
IGRpoint            pt2,
IGRvector           vec,
IGRdouble           len,
struct
  BSgeom_bsp_curve  *int_cv,
BSrc                *rc)
{
#ifndef DONOTSPROTO
#include "bslngen.h"
#include "bsmdptbssf.h"
#include "bssfeval.h"
#endif
   IGRint      i, type, one=1, deriv=0;
   IGRboolean  status;
   IGRdouble mdist, uvmin1[2], uvmin2[2], userdsup, basetol,
             precloc, u, umin, umax;
   IGRpoint pntbas;

   (*int_cv).geom_prop = 1;
   (*int_cv).type = BSLINE;

   /* if surface is closed, then check if points are near seam, because
      if they are, we could have 1 on 1 side of the seam and the other
      on the other side */
   if( prj_sf->u_phy_closed )
   {
      userdsup = 1.e308;
      BSEXTRACTPAR(rc, BSTOLBASIS, basetol);
      precloc = basetol/1.e6;
      BSmdptbssf(prj_sf,one,pt1,precloc,userdsup,&mdist,uvmin1,pntbas,rc);
      if (BSERROR(*rc))
        goto wrapup;
      BSmdptbssf(prj_sf,one,pt2,precloc,userdsup,&mdist,uvmin2,pntbas,rc);
      if (BSERROR(*rc))
        goto wrapup;
      umin = prj_sf->u_knots[prj_sf->u_order-1];
      umax = prj_sf->u_knots[prj_sf->u_num_poles];
      u = (umax - umin) * 0.1;
      if( (uvmin1[0] < u && uvmin2[0] > umax - u) ||
          (uvmin1[0] > umax - u && uvmin2[0] < u)  )
      {
         /* set the line points to be on the seam */
         uvmin1[0] = umin;
         BSsfeval(prj_sf, uvmin1[0], uvmin1[1], deriv, (IGRpoint *)pt1, rc);
         if (BSERROR(*rc))
            goto wrapup;
         uvmin2[0] = umin;
         BSsfeval(prj_sf, uvmin2[0], uvmin2[1], deriv, (IGRpoint *)pt2, rc);
         if (BSERROR(*rc))
            goto wrapup;
      }
   }

   for (i = 0; i < 3; ++i)
   {
       (*int_cv).pt1[i] = pt1[i];
       (*int_cv).pt2[i] = pt2[i];
       (*int_cv).vec1[i] = vec[i];
   }

   (*int_cv).len1 = len;

   status = BSlngen(rc, pt1, pt2, (*int_cv).bspcv, &type);
   if (BSERROR(*rc))
      goto wrapup;

   if ((*int_cv).bspcv)
      (*int_cv).bscv_flag = TRUE;

   status = !status;

   wrapup:

   return;
}


void BSxsfprjpln(
struct
  BSgeom_bsp_surf    *sf_prj,
struct
  BSgeom_bsp_surf    *pln,
IGRint               *num_grps,
IGRint               **num_int_cvs,
struct
  BSgeom_bsp_curve   **int_cvs,
BSrc                 *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsdistptpt.h"
#include "bspl_cv_int.h"
#include "bslngen.h"
#include "bsprj_cv_pl.h"
#include "bsfreecv.h"
#include "bsnorvec.h"
#include "bssfeval.h"
#include "bsdlsegs2.h"
#include "bscrossp.h"
#include "bsrecplprop.h"
#include "bssfprjprop.h"
#include "bssfnormal.h"
#include "bscvnormal.h"
#include "bsbdlnplint.h"
#include "bstrgmcvtsf.h"
#include "bststcvfln.h"
#include "bsalloccv.h"
#endif

   IGRint        i, j, k, n_int=0, n_int2, n_over, cnt, offset;
   IGRint        *num_cvs2 = NULL, num_cvs2_2[MAXNUM];
   IGRint        *num_cvs3 = NULL, num_cvs3_2[MAXNUM];
   IGRint        tmp_totcvs, totcvs;
   IGRint        *tnumint=NULL, tnumint2[MAXNUM];
   IGRint        tnumgrps, tnumgrps2, tnumgrps3;
   IGRint        deriv;
   IGRshort      order;
   IGRlong       cv_npoles = 0, ln_npoles = 0;
   IGRdouble     dist_tol, dist, len;
   IGRdouble     dotp, dotp2;
   IGRdouble     ln_len, lng;
   IGRdouble     *u_pars = NULL, u_pars2[MAXNUM];
   IGRdouble     *over_a = NULL, over_a2[MAXNUM];
   IGRdouble     *over_b = NULL, over_b2[MAXNUM];
   IGRdouble     upar, vpar, ang,min;
   IGRpoint      *int_pts = NULL, int_pts2[MAXNUM];
   IGRpoint      line[2], tpts[2], endpt;
   IGRvector     sf_prj_nor, cv_nor, tvec, V1, V2, cross;
   IGRboolean    alloc_int_pts = FALSE, alloc_u_pars = FALSE, parallel;
   IGRboolean    alloc_over_a = FALSE, alloc_over_b = FALSE;
   IGRboolean    alloc_tnumint = FALSE, alloc_tcvs = FALSE;
   IGRboolean    alloc_num_cvs2 = FALSE, alloc_num_cvs3 = FALSE;
   IGRboolean    status;
   struct
    BSgeom_bsp_curve *tcvs = NULL, tcvs2[MAXNUM];
   struct
    BSgeom_bsp_curve **t2cvs = NULL, **t3cvs = NULL;
   struct
    BSgeom_bsp_surf  new_pln;
   BSrc          rc1 = BSSUCC, rc2 = BSSUCC, rc3 = BSSUCC;

   *rc = BSSUCC;

   BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);

   /* Initialize variable to 0 */

   tmp_totcvs = 0;
   totcvs = 0;
   *num_grps = 0;
   tnumgrps = 0;
   tnumgrps2 = 0;
   tnumgrps3 = 0;

   /* If pln is rectangular and geometric properties are not given, call
      BSrecplprop fill in these properties based on the B-spline surface
      structure. */
   if (pln->type == BSRECT_PLANE)
   {
      /* pln is rectangular */
      if (!pln->geom_prop)
      {
         BSrecplprop(pln, rc);
         if (BSERROR(*rc))
            goto wrapup;
      }

      /* Set properties of temporary plane (new_pln) */
      new_pln.geom_prop = pln->geom_prop;
      new_pln.type = BSRECT_PLANE;
      new_pln.bounded = pln->bounded;

      new_pln.urange[0] = 0.0;
      new_pln.urange[1] = 1.0;
      new_pln.vrange[0] = 0.0;
      new_pln.vrange[1] = 1.0;

      if (new_pln.geom_prop)
      {
         new_pln.reg_constr = pln->reg_constr;
         for (i = 0; i < 3; ++i)
         {
            new_pln.pt1[i] = pln->pt1[i];
            new_pln.pt2[i] = pln->pt2[i];
            new_pln.pt3[i] = pln->pt3[i];
            new_pln.pt4[i] = pln->pt4[i];

            new_pln.vec1[i] = pln->vec1[i];
            new_pln.vec2[i] = pln->vec2[i];
            new_pln.vec3[i] = pln->vec3[i];
         }
         new_pln.len1 = pln->len1;
         new_pln.len2 = pln->len2;
      }

      if (pln->bspsf)
         new_pln.bspsf = pln->bspsf;

   }
   else
   {
      if (pln->type == BSINF_PLANE)
      {
         if (!pln->geom_prop)
         {
            /* If pln is inf. plane, geometric properties MUST be given*/
            *rc = BSINARG;
            goto wrapup;
         }

         /* Set properties of temporary plane (new_pln) */
         new_pln.geom_prop = TRUE;
         new_pln.type = BSINF_PLANE;
         new_pln.bounded = FALSE;

         new_pln.reg_constr = pln->reg_constr;
         for (i = 0; i < 3; ++i)
         {
            new_pln.pt1[i] = pln->pt1[i];
            new_pln.vec1[i] = pln->vec1[i];
         }
         new_pln.bspsf = NULL;
      }
      else
      {
         /*******************************************************************/
         /* pln is a planar surface but not a rectangular nor infinite plane*/
         /*******************************************************************/

         /* Calculate and set properties of temporary plane (new_pln) */
         new_pln.geom_prop = TRUE;
         new_pln.type = pln->type;
         new_pln.bounded = pln->bounded;
         if (new_pln.bounded)
         {
            new_pln.urange[0] = pln->urange[0];
            new_pln.urange[1] = pln->urange[1];
            new_pln.vrange[0] = pln->vrange[0];
            new_pln.vrange[1] = pln->vrange[1];
         }

         new_pln.reg_constr = TRUE;

         if (pln->bspsf)
            new_pln.bspsf = pln->bspsf;

         BSsfnormal(pln->bspsf, new_pln.vec1, rc);
         if (BSERROR(*rc))
            goto wrapup;

         upar = 0.0;
         vpar = 0.0;
         deriv = 0;
         BSsfeval(pln->bspsf, upar, vpar, deriv, (IGRpoint *)new_pln.pt1, rc);
         if (BSERROR(*rc))
            goto wrapup;

      }   /* end if (pln->type == BSINF_PLANE) */

   }   /* end if (pln->type == BSRECT_PLANE) */

   /* Call BSsfprjprop to fill in properties of sf_prj if sf_prj->geom_prop
      = FALSE */
   if (!sf_prj->geom_prop)
   {
      BSsfprjprop(sf_prj, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }

   cv_npoles = sf_prj->sfgen_cv->num_poles;


   /* If sf_prj is planar determine if pln is coincident to plane of sf_prj*/
   if (sf_prj->bspsf->planar)
   {
      BSsfnormal(sf_prj->bspsf, sf_prj_nor, rc);
      if (BSERROR(*rc))
         goto wrapup;

      dotp = BSdotp(rc, sf_prj_nor, new_pln.vec1);
      if (BSERROR(*rc))
          goto wrapup;

      if (ABS(ABS(dotp) - 1.0) <= dist_tol)
      {
         /* pln is parallel to plane of sf_prj -- check to see if coplanar*/

         for (k = 0; k < 3; ++k)
             tvec[k] = sf_prj->pt1[k] - new_pln.pt1[k];

         len = BSlenvec(rc, tvec);
         if (BSERROR(*rc))
            goto wrapup;

         if (len <= dist_tol)
         {
            *rc = BSCOINCIDENT;
            goto wrapup;
         }
         else
         {
            status = BSnorvec(rc, tvec);
            if (BSERROR(*rc))
               goto wrapup;

            dotp = BSdotp(rc, tvec, new_pln.vec1);
            if (BSERROR(*rc))
               goto wrapup;

            if (ABS(dotp) <= dist_tol)
            {
               *rc = BSCOINCIDENT;
               goto wrapup;
            }
            else
            {
               *num_grps = 0;
               goto wrapup;
            }
         }
      }
   }

   /*******************************************************************/
   /* Determine if pln is tangent to sf_prj or parallel to projection */
   /* vector of sf_prj which result in line or point intersection;    */
   /* otherwise the intersection is the projection of the generator   */
   /* curve onto the plane (clipped if necessary).                    */
   /*******************************************************************/

   /* Determine if projection vectors of sf1 and sf2 are parallel */
   /* find the angle between the 2 vectors */
   (void)BScrossp(rc, new_pln.vec1, sf_prj->vec1, cross );
   if(BSERROR(*rc))
      goto wrapup;
   parallel=FALSE;
   lng = BSlenvec(rc, cross );
   lng = MIN(lng, 1.0);
   ang = asin( lng );
   min = new_pln.type == -1 ? sf_prj->len1 : MIN(MIN(sf_prj->len1, new_pln.len1 ),new_pln.len2);
   if( fabs((ang-M_PI*0.5)) * min < dist_tol )
      parallel = TRUE;

   if (parallel)
   {
      /**************************************************************/
      /* pln is parallel to projection vector and tangent to sf_prj */
      /* Result will be point(s), line(s), or null.                 */
      /**************************************************************/

      /* Call BSpl_cv_int to intersect pln with sf_prj->sfgen_cv
         which will be the endpts of the intersection line (before
         clipping). */

      if (cv_npoles > MAXNUM)
      {
         int_pts = (IGRpoint *)BSstackalloc((unsigned)(cv_npoles * sizeof
                      (IGRpoint)));
         if(!int_pts)
         {
            status = FALSE;
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_int_pts = TRUE;

         u_pars = (IGRdouble *)BSstackalloc((unsigned)(cv_npoles * sizeof
                      (IGRdouble)));
         if(!u_pars)
         {
            status = FALSE;
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_u_pars = TRUE;

         over_a = (IGRdouble *)BSstackalloc((unsigned)(cv_npoles * sizeof
                      (IGRdouble)));
         if(!over_a)
         {
            status = FALSE;
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_over_a = TRUE;

         over_b = (IGRdouble *)BSstackalloc((unsigned)(cv_npoles * sizeof
                      (IGRdouble)));
         if(!over_b)
         {
            status = FALSE;
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_over_b = TRUE;
      }
      else
      {
         int_pts = int_pts2;
         u_pars = u_pars2;
         over_a = over_a2;
         over_b = over_b2;
      }

      n_int = 0;
      n_over = 0;
      status = BSpl_cv_int(rc, sf_prj->sfgen_cv, new_pln.pt1, new_pln.vec1,
                           &n_int, (IGRdouble *)int_pts, u_pars, &n_over,
                           over_a, over_b);
      if (BSERROR(*rc))
         goto wrapup;

      if (n_over > 0)
      {
         *rc = BSCOINCIDENT;
         goto wrapup;
      }
      else
      {
         if (n_int > 0)
         {

            /* Allocate memory for temporary storage of int. cvs (tcvs) */
            if (n_int > MAXNUM)
            {
               tnumint = (IGRint *)BSstackalloc(n_int * sizeof (IGRint));
               if (! tnumint)
               {
                  *rc = BSNOSTKMEMORY;
                  goto wrapup;
               }
               alloc_tnumint = TRUE;

               tcvs = (struct BSgeom_bsp_curve *)BSstackalloc(n_int * sizeof
                                  (struct BSgeom_bsp_curve));
               if (! tcvs)
               {
                  *rc = BSNOSTKMEMORY;
                  goto wrapup;
               }
               alloc_tcvs = TRUE;

               for (i = 0; i < n_int; ++i)
               {
                   tcvs[i].bspcv = NULL;
                   tcvs[i].array1 = NULL;
               }
            }
            else
            {
               tnumint = tnumint2;
               tcvs = tcvs2;

               for (i = 0; i < MAXNUM; ++i)
               {
                   tcvs[i].bspcv = NULL;
                   tcvs[i].array1 = NULL;
               }
            }

            /* Get vector lying in pln in direction of sf_prj projection
               vector.  Previously, using sf_prj projection vector but
               round off was occurring. */
            (void)BScrossp(rc, sf_prj->vec1, new_pln.vec1, V1);
            if (BSERROR(*rc))
               goto wrapup;

            (void)BSnorvec(rc, V1);
            if (BSERROR(*rc))
               goto wrapup;

            (void)BScrossp(rc, new_pln.vec1, V1, V2);
            if (BSERROR(*rc))
               goto wrapup;

            (void)BSnorvec(rc, V2);
            if (BSERROR(*rc))
               goto wrapup;

            if (!new_pln.bounded)
            {
               /* Infinite plane -- generate line intersection at each
                  int_pts*/

               tnumgrps = 0;
               for (i = 0; i < n_int; ++i)
               {
                   order = 2;
                   ln_npoles = 2;
                   BSalloccv(order, ln_npoles, 0, 0, &(tcvs[i].bspcv), rc);
                   if (BSERROR(*rc))
                      goto wrapup;

                   for (j = 0; j < 3; ++j)
                       endpt[j] = int_pts[i][j] + V2[j] * sf_prj->len1;

                   /* Call routine to fill in int_cv[i] */

                   dist = BSdistptpt(rc, int_pts[i], endpt);
                   if (BSERROR(*rc))
                      goto wrapup;

                   if (dist > dist_tol)
                   {
                      genlineBSxsfprjpln(sf_prj->bspsf, int_pts[i], endpt, V2, sf_prj->len1,
                                         &(tcvs[i]), rc);
                      if (BSERROR(*rc))
                         goto wrapup;
                   }
                   else
                   {
                      genptcvBSxsfprjpln(endpt, &(tcvs[i]), rc);
                      if (BSERROR(*rc))
                         goto wrapup;
                   }
                   tnumint[i] = 1;
                   ++tnumgrps;
               }

            }
            else
            {
               /* Bounded plane -- clip line at boundaries */

               tnumgrps = 0;
               for (i = 0; i < n_int; ++i)
               {
                  for (j = 0; j < 3; ++j)
                      endpt[j] = int_pts[i][j] + V2[j] * sf_prj->len1;

                  order = 2;
                  ln_npoles = 2;
                  BSalloccv(order, ln_npoles, 0, 0, &(tcvs[i].bspcv), rc);
                  if (BSERROR(*rc))
                     goto wrapup;

                  /* Call routine to fill in int_cv[i] */
                  ln_len = BSdistptpt(rc, int_pts[i], endpt);
                  if (BSERROR(*rc))
                     goto wrapup;


                  if (ln_len > dist_tol)
                  {
                     genlineBSxsfprjpln(sf_prj->bspsf, int_pts[i], endpt, V2, ln_len,
                                        &(tcvs[i]), rc);
                     if (BSERROR(*rc))
                        goto wrapup;
                  }
                  else
                  {
                     genptcvBSxsfprjpln(endpt, &(tcvs[i]), rc);
                     if (BSERROR(*rc))
                        goto wrapup;
                  }

                  tnumint[i] = 1;
                  ++tnumgrps;

               }   /* end i loop */

            }   /* end if (!new_pln.bounded) */

         }   /* end if (n_int > 0)  */

      }   /* end if (n_over > 0) */

   }
   else  /* parallel */
   {
      /************************************************************/
      /* pln is not tangent to sf_prj nor is it parallel to proj. */
      /* vector of sf_prj.   Result will be sf_prj->sfgen_cv      */
      /* projected onto pln (clipped if necessary).               */
      /************************************************************/


      /* If sf_prj->sfgen_cv is planar and parallel to new_pln, and
         sf_prj projection vector is parallel to new_pln normal, call
         BSbdlnplint to intersect bounded line from start of generating
         curve along length of projection vector with new_pln.  */

      if (sf_prj->sfgen_cv->planar)
      {
         (void)BScvnormal(rc, sf_prj->sfgen_cv, cv_nor);
         if (BSERROR(*rc))
            goto wrapup;

         dotp2 = BSdotp(rc, cv_nor, new_pln.vec1);
         if (BSERROR(*rc))
            goto wrapup;
         dotp = BSdotp(rc, new_pln.vec1, sf_prj->vec1);
         if (BSERROR(*rc))
            goto wrapup;

         if (ABS(ABS(dotp)-1.0) <= dist_tol && ABS(ABS(dotp2)-1.0) <= dist_tol)
         {
            for (k = 0; k < 3; ++k)
            {
               line[0][k] = sf_prj->pt1[k];
               line[1][k] = sf_prj->pt1[k] + sf_prj->vec1[k] * sf_prj->len1;
            }

            n_int2 = 0;
            BSbdlnplint(line, new_pln.pt1, new_pln.vec1, &n_int2, tpts, rc);
            if (BSERROR(*rc))
               goto wrapup;

            if (n_int2 == 0)
            {
               /* bounded projection line of sf_prj does not intersect
                  pln -- set num_grps = 0 and goto wrapup. */
               *num_grps = 0;
               goto wrapup;
            }
         }
      }

      /* Call BSprj_cv_pl to project sf_prj->sfgen_cv onto pln */

      /* Assign memory for temporary storage of int. cvs (tcvs) */
      tnumint = tnumint2;
      tcvs = tcvs2;
      for (i = 0; i < MAXNUM; ++i)
      {
         tcvs[i].bspcv = NULL;
         tcvs[i].array1 = NULL;
      }

      BSalloccv(sf_prj->sfgen_cv->order, sf_prj->sfgen_cv->num_poles,
                sf_prj->sfgen_cv->rational, 0, &(tcvs[0].bspcv), rc);
      if (BSERROR(*rc))
          goto wrapup;

      status = BSprj_cv_pl(rc, sf_prj->sfgen_cv, new_pln.pt1, new_pln.vec1,
                           sf_prj->vec1, tcvs[0].bspcv);
      if (BSERROR(*rc))
         goto wrapup;

      /* Fill in structure for tcvs[0]. */
      tcvs[0].geom_prop = 0;
      tcvs[0].bscv_flag = 1;
      tcvs[0].type = BSGEN_BSP_CV;

      tnumgrps = 1;
      tnumint[0] = 1;

      /* If sf_prj is planar, tcvs[0].bspcv will be a line.  Call BStstcvfln
         to test for overlaps of tcvs[0].bspcv. */
/*      if (sf_prj->bspsf->planar)
      {
         BStstcvfln(tcvs[0].bspcv, &is_line, stpt, endpt, rc);
         if (BSERROR(*rc))
            goto wrapup;

         if (is_line)
         {
            if (tcvs[0].bspcv)
            {
	       status = BSfreecv(rc, tcvs[0].bspcv);
               if (BSERROR(*rc))
                  goto wrapup;
               tcvs[0].bspcv = NULL;
            }
         }
         else
         {
            *rc = BSINARG;
            goto wrapup;
         }

         order = 2;
         npoles = 2;
         BSalloccv(order, npoles, 0, 0, &(tcvs[0].bspcv), rc);
         if (BSERROR(*rc))
            goto wrapup;


         dist = BSdistptpt(rc, stpt, endpt);
         if (BSERROR(*rc))
            goto wrapup;

         if (dist > dist_tol)
         {
            genlineBSxsfprjpln(stpt, endpt, sf_prj->vec1, sf_prj->len1,
                               &(tcvs[0]), rc);
            if (BSERROR(*rc))
               goto wrapup;
         }
         else
         {
            genptcvBSxsfprjpln(endpt, &(tcvs[0]), rc);
            if (BSERROR(*rc))
               goto wrapup;
         }

         if (BSERROR(*rc))
            goto wrapup;

      }
*/


   }   /* end if (ABS(dotp) <= dist_tol) */


   /************************************************************/
   /* Trim tcvs with respect to plane and sf_prj if necessary. */
   /************************************************************/

   /* Trim w.r.t. sf_prj if bounded */

   if (tnumgrps == 0)
   {
      *num_grps = 0;
      goto wrapup;
   }
   else
   {
      if (tnumgrps > MAXNUM)
      {
         num_cvs2 = (IGRint *)BSstackalloc((unsigned)tnumgrps *
                        sizeof(IGRint));
         if (!num_cvs2)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         alloc_num_cvs2 = TRUE;
      }
      else
      {
         num_cvs2 = num_cvs2_2;
      }

      t2cvs = (struct BSgeom_bsp_curve **)BSstackalloc((unsigned) tnumgrps *
                      sizeof (struct BSgeom_bsp_curve *));
      if (!t2cvs)
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }

      for (i = 0; i < tnumgrps; ++i)
          t2cvs[i] = NULL;

      if (sf_prj->bounded)
      {
         /* Call BStrgmcvtsf for each tcvs */
         tmp_totcvs = 0;
         cnt = 0;
         tnumgrps2 = 0;
         for (i = 0; i < tnumgrps; ++i)
         {
            num_cvs2[cnt] = 0;
            BStrgmcvtsf(&(tcvs[i]), sf_prj, &(num_cvs2[cnt]), &(t2cvs[cnt]),
                         rc);
            if (BSERROR(*rc))
               goto wrapup;

            if (num_cvs2[cnt] > 0)
            {
               tmp_totcvs += num_cvs2[cnt];
               ++cnt;
               ++tnumgrps2;
            }
         }   /* end i loop */

/*         tnumgrps2 = tnumgrps; */
      }
      else
      {
         /* Copy tcvs into t2cvs */
         tmp_totcvs = 0;
         for (i = 0; i < tnumgrps; ++i)
         {
            t2cvs[i] = (struct BSgeom_bsp_curve *)BSmalloc((unsigned)
                           sizeof (struct BSgeom_bsp_curve));
            if (!t2cvs[i])
            {
               *rc = BSNOMEMORY;
               goto wrapup;
            }

            BSMEMCPY(sizeof (struct BSgeom_bsp_curve), (IGRchar *)&(tcvs[i]),
                     (IGRchar *)t2cvs[i]);
            tcvs[i].bspcv = NULL;
            tcvs[i].array1 = NULL;

            num_cvs2[i] = 1;
         }
         tmp_totcvs = tnumgrps;
         tnumgrps2 = tnumgrps;

      }   /* end if (sf_prj->bounded) */


      if (tmp_totcvs == 0)
      {
         *num_grps = 0;
         goto wrapup;
      }
      else
      {
         /* Trim w.r.t. pln if bounded (rectangular plane). */

         if (tmp_totcvs > MAXNUM)
         {
            num_cvs3 = (IGRint *)BSstackalloc((unsigned)tmp_totcvs *
                           sizeof(IGRint));
            if (!num_cvs3)
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            alloc_num_cvs3 = TRUE;
         }
         else
         {
            num_cvs3 = num_cvs3_2;
         }

         t3cvs = (struct BSgeom_bsp_curve **)BSstackalloc((unsigned)
                         tmp_totcvs * sizeof (struct BSgeom_bsp_curve *));
         if (!t3cvs)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }

         for (i = 0; i < tmp_totcvs; ++i)
             t3cvs[i] = NULL;

         if (new_pln.bounded)
         {
            /* Call BStrgmcvtsf for each tcvs */
            totcvs = 0;
            cnt = 0;
            tnumgrps3 = 0;
            for (i = 0; i < tnumgrps2; ++i)
            {
               for (j = 0; j < num_cvs2[i]; ++j)
               {
                  num_cvs3[cnt] = 0;
                  BStrgmcvtsf(&(t2cvs[i][j]), pln, &(num_cvs3[cnt]),
                               &(t3cvs[cnt]), rc);
                  if (BSERROR(*rc))
                     goto wrapup;
                  if (num_cvs3[cnt] > 0)
                  {
                     totcvs += num_cvs3[cnt];
                     ++cnt;
                     ++tnumgrps3;
                  }
               }
            }   /* end i loop */
/*            tnumgrps3 = tmp_totcvs; */
         }
         else
         {
            /* Copy t2cvs into t3cvs */
            for (i = 0; i < tnumgrps2; ++i)
            {
               t3cvs[i] = (struct BSgeom_bsp_curve *)BSmalloc((unsigned)
                             (num_cvs2[i] * sizeof (struct BSgeom_bsp_curve)));
               if (!t3cvs[i])
               {
                  *rc = BSNOMEMORY;
                  goto wrapup;
               }

               BSMEMCPY((num_cvs2[i] * sizeof (struct BSgeom_bsp_curve)),
                        (IGRchar *)t2cvs[i], (IGRchar *)t3cvs[i]);
               for (j = 0; j < num_cvs2[i]; ++j)
               {
                   t2cvs[i][j].bspcv = NULL;
                   t2cvs[i][j].array1 = NULL;
               }
               num_cvs3[i] = num_cvs2[i];
            }
            totcvs = tmp_totcvs;
            tnumgrps3 = tnumgrps2;
         }


         /* Copy t3cvs into final output int_cvs */

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
            for (i = 0; i < tnumgrps3; ++i)
            {
                for (j = 0; j < num_cvs3[i]; ++j)
                {
                   (*int_cvs)[cnt].bspcv = NULL;
                   (*int_cvs)[cnt].array1 = NULL;
                   (*num_int_cvs)[cnt] = 1;
                   ++cnt;
                }

                BSMEMCPY((num_cvs3[i] * sizeof (struct BSgeom_bsp_curve)),
                  (IGRchar *)t3cvs[i], (IGRchar *)&(int_cvs[0][offset]));

                for (j = 0; j < num_cvs3[i]; ++j)
                {
                   t3cvs[i][j].bspcv = NULL;
                   t3cvs[i][j].array1 = NULL;
                }

                offset += num_cvs3[i];

            }
            *num_grps = totcvs;

         }   /* end if (totcvs == 0) */

      }   /* end if (tmp_totcvs == 0) */

   }   /* end if (tnumgrps == 0) */


   status = !status;


   wrapup:

   if (t3cvs)
   {
      i = tmp_totcvs - 1;
      while ( i >= 0)
      {
         if (t3cvs[i])
         {
            k = num_cvs3[i] - 1;
            while (k >= 0)
            {
               if (t3cvs[i][k].array1)
               {
                  BSdealloc((char *) t3cvs[i][k].array1);
                  t3cvs[i][k].array1 = NULL;
               }

               if (t3cvs[i][k].bspcv)
               {
                  status = BSfreecv(&rc2, t3cvs[i][k].bspcv);
                  if (BSERROR(rc2) && BSOKAY(*rc))
                     *rc = rc2;
                  t3cvs[i][k].bspcv = NULL;
               }
               --k;
            }
            BSdealloc((char *) t3cvs[i]);
            t3cvs[i] = NULL;
         }

         --i;
      }
      BSstackdealloc((char *) t3cvs);
      t3cvs = NULL;
   }

   if (tmp_totcvs > MAXNUM)
   {
      if (alloc_num_cvs3)
      {
         BSstackdealloc((char *) num_cvs3);
         num_cvs3 = NULL;
      }
   }

   if (t2cvs)
   {
      i = tnumgrps - 1;
      while ( i >= 0)
      {
         if (t2cvs[i])
         {
            k = num_cvs2[i] - 1;
            while (k >= 0)
            {
               if (t2cvs[i][k].array1)
               {
                  BSdealloc((char *) t2cvs[i][k].array1);
                  t2cvs[i][k].array1 = NULL;
               }
               if (t2cvs[i][k].bspcv)
               {
                  status = BSfreecv(&rc3, t2cvs[i][k].bspcv);
                  if (BSERROR(rc) && BSOKAY(*rc))
                     *rc = rc3;
                  t2cvs[i][k].bspcv = NULL;
               }
               --k;
            }
            BSdealloc((char *) t2cvs[i]);
            t2cvs[i] = NULL;
         }
         --i;
      }
      BSstackdealloc((char *) t2cvs);
      t2cvs = NULL;
   }

   if (tnumgrps > MAXNUM)
   {
      if (alloc_num_cvs2)
      {
         BSstackdealloc((char *) num_cvs2);
         num_cvs2 = NULL;
      }
   }

   if (n_int > MAXNUM)
   {
      if (alloc_tnumint)
      {
         BSstackdealloc((char *) tnumint);
         tnumint = NULL;
      }
   }

   if (tcvs)
   {
      i = tnumgrps - 1;
      while (i >= 0)
      {
         if (tcvs[i].bspcv)
         {
            status = BSfreecv(&rc1, tcvs[i].bspcv);
            if (BSERROR(rc1) && BSOKAY(*rc))
               *rc = rc1;
            tcvs[i].bspcv = NULL;
         }
         --i;
      }
      if (alloc_tcvs)
      {
         BSstackdealloc((char *) tcvs);
         tcvs = NULL;
      }
   }

   if (cv_npoles > MAXNUM)
   {
      if (alloc_over_b)
      {
         BSstackdealloc((char *) over_b);
         over_b = NULL;
      }

      if (alloc_over_a)
      {
         BSstackdealloc((char *) over_a);
         over_a = NULL;
      }

      if (alloc_u_pars)
      {
         BSstackdealloc((char *) u_pars);
         u_pars = NULL;
      }

      if (alloc_int_pts)
      {
         BSstackdealloc((char *) int_pts);
         int_pts = NULL;
      }
   }

   if (BSERROR(*rc))
      BSdbgrc(*rc, "BSxsfprjpln");

   return;

}
