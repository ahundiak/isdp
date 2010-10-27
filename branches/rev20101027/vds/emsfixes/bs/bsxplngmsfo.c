/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSxplngmsfo

Abstract
    This routine intersects a planar surface (bounded or infinite) with
    another surface each given in BSgeom_bsp_surf structure format.
    Caller should give the order (korder) for the output intersection 
    curve and tolerance (prec).
Synopsis
    void BSxplngmsfo(pln, gmsf, korder,prec,lgd_flag,  numgrps, numint, 
                     intcvs, lgd_cvs, ptcode, numpts, intpts, pln_code, 
                     plnpars, gmsf_code, gmsfpars, rc)

    struct 
     BSgeom_bsp_surf     (input) *pln............planar surface structure
    struct 
     BSgeom_bsp_surf     (input) *gmsf...........geometric surface structure
    IGRint               (input) korder..........order of output interse-
                                                 ction curve (only for
                                                 curves returned from
                                                 BSsfplintlg)

    IGRdouble            (input) prec............tolerance (only used by
                                                 BSsfplintlg)

    IGRboolean           (output) *lgd_flag......flag indicating if inter-
                                                  section curves were found
                                                  with Legendre polynomials
                                                     TRUE : Legendre
                                                     FALSE: otherwise
    IGRint               (output) *numgrps.......number of groups of 
                                                  intersections
    IGRint               (output) **numint.......array of number of inter-
                                                  sections per group
    struct 
      BSgeom_bsp_curve   (output) **intcvs.......pointer to array of structures
                                                  for intersection curves
                                                  in model space 
    struct 
      BSBScmplgd_cv        (output) **lgd_cvs.....Legendre intersection curves
    IGRboolean           (output) *ptcode........flag indicating if intpts
                                                  and associated parameters
                                                  are returned.
                                                    FALSE: not returned
                                                    TRUE : returned
    IGRint               (output) **numpts........number of intersection points
                                                    per intersection curve
                                                    (if ptcode = TRUE)
    IGRpoint             (output) ***intpts......array of pointers to arrays
                                                    of intersection points
                                                    (if ptcode = TRUE)
    IGRboolean           (output) *pln_code......flag indicating if plnpars
                                                    are returned.
    BSpair               (output) ***plnpars.....array of pointers to arrays
                                                    of uv parameters for pln
                                                    (if pln is not infinite
                                                     and ptcode = TRUE)
    IGRboolean           (output) *gmsf_code.....flag indicating if gmsfpars
                                                    are returned.
    BSpair               (output) ***gmsfpars....array of pointers to arrays
                                                    of uv parameters for gmsf
                                                    (if gmsf is not infinite
                                                    and ptcode = TRUE)
    BSrc                 (output) *rc............return code
    
Description
    Given a planar surface (pln) and another surface (gmsf), the order of
    output intersection curve (korder) and tolerance (prec),this routine
    calculates the intersection of these 2 surfaces returning the number of
    groups of intersection curves (numgrps), an array of the number of 
    intersection curves per group (numint), and an array of intersection
    curves (intcvs).   Also returned is a flag (ptcode) indicating if 
    number of intersection points (numpts) per curve and intersection points 
    (intpts) are calculated and returned.  Flags are also returned indicating
    if uv parameters of intpts on pln and gmsf are returned (pln_code, 
    gmsf_code).  If ptcode = TRUE, parameters are returned only for bounded 
    surface(s).  A flag is output indicating if the intersection was calculated
    using Legendre polynomials or not (lgd_flag) and the Legendre curves
    (lgd_cvs) if lgd_flag = TRUE.

Return Values
    BSSUCC  if successful
    BSNOMEMORY if memory can not be allocated
    BSCOINCIDENT if surfaces are coincident
    BSNONPLANAR if pln is not planar

Notes
    Memory for all output is allocated inside this routine.

    If pln is bounded and gmsf is a bounded planar surface and the infinite
    planes containing pln and gmsf are coincident, BSCOINCIDENT is returned
    ignoring point or boundary segment intersections is pln and gmsf are
    touching.

    If intcvs exists, the BSgeom_bsp_curve structures returned will always 
    contain the B-spline representation of the intersection curve and, if 
    available, geometric properties defining the curve (i.e. circle, ellipse, 
    arc, etc...).

    If the intersection was found by calling BSsf_pl_int of BSsur_surrg, 
    only intpts with associated plnpars (if bounded plane) and gmsfpars
    (if bounded gmsf) are returned. The pointer to intcvs will be NULL.

    If plnpars and/or gmsfpars are returned, they are parameters on the
    bounded B-spline surfaces.

Index
    em

Keywords

History
    Vivian W.Ye   04/07/93   : Creation date.
                               Copied from BSxplngmsf and added two
                               input arguments " korder,prec".
    S. C. Wood    05/13/93   : Deallocate lgd_cvs at wrapup if *numgrps=0.
                               Fix for TR#9306382.
    Vivian W.Ye   03/17/94   : Fixed a memory crash by moving that 
                               deallocation of numtrmcvs from top to
                               after deallocation of t3cvs.
    S. C. Wood    06/08/94   : If BSsfplintlg returns rc = 35, deallocate
                               output from BSsfplintlg if it exists.
    Vivian W.Ye   08/10/94   : If rc = BSINCONSISTENT from BSsfplintlg,
                               set it back to BSSUCC then go on.
    S. C. Wood    08/15/94   : If BSxconepln returns rc= BSINCONSISTENT, 
                               reset it to BSSUCC and call BSsfplintlg.
    Vivian Y.Hsu  01/25/95   : Changed structure of lgd_cvs.
    S. C. Wood    09/05/95   : If *rc=BSNOTYETSUPPORTED, call BSsfplinglg.
                               Fix for TR#9526684.
    Vivian Y.Hsu  03/14/97   : If intersection curve has been trimed, 
                               we cannot use lgd_cvs any more. 
                               Set lgd_flag = FALSE. Otherwise, we should 
                               keep lgd_cvs and output it.
                               Fix for TR9700195.

*/

#define BSVOID
#include "bserr.h"
#include "bsdefs.h"
#include "bssfsf_int2.h"
#include "bsgeom_cvsf.h"
#include "bsstackalloc.h"
#include "bsmalloc.h"
#include "bsparameters.h"
#include "bsmemory.h"
#include "bsplpchlgd.h"

#define MAXNUM_QUADINT 20
#define MAXSIZE 100

void BSxplngmsfo(
struct
  BSgeom_bsp_surf  *pln,
 struct   BSgeom_bsp_surf        *gmsf,
IGRint korder,
IGRdouble prec,
IGRboolean         *lgd_flag,
IGRint             *numgrps,
IGRint             **numint,
struct
  BSgeom_bsp_curve **intcvs,
struct
  BScmplgd_cv        **lgd_cvs,
IGRboolean         *ptcode,
IGRint             **numpts,
IGRpoint           ***intpts,
IGRboolean         *pln_code,
BSpair             ***plnpars,
IGRboolean         *gmsf_code,
BSpair             ***gmsfpars,
BSrc               *rc)  
{
#include "bsdbgrc.h"
#include "bsxsfrevpln.h"
#include "bsxsfprjpln.h"
#include "bsxsphpln.h"
#include "bsxcylpln.h"
#include "bsxconepln.h"
#include "bsx2pln.h"
#include "bsallgeomsf.h"
#include "bssf_pl_int.h"
#include "bsgmsfprop.h"
#include "bssfplintlg.h"
#include "bslsqptlnpl.h"
#include "bsalloccv.h"
#include "bssur_surrg.h"
#include "bststcvdegn.h"
#include "bstrgmcvtsf.h"
#include "bsfreecv.h"
#include "bsfrecmpcvs.h"
#include "bscveval.h"
#include "bsdistptpts.h"

   IGRshort          cvscode;
   IGRint            i, k, j, npts, option, code, offset, cnt, totcvs;
   IGRint            *tnumint=NULL, tnumint2[MAXSIZE], tnumgrps, tnumgrps3, 
                     *numtrmcvs=NULL, numtrmcvs2[MAXSIZE];
   IGRdouble         err, dum_tol1, dum_tol2, dist_tol;
   IGRvector         **tans = NULL;
   IGRboolean        inf_plane1 = FALSE, good_pln1 = FALSE, good_pln2 = FALSE;
   IGRboolean        degen, tan_flag, call_sur_surrg, call_sfplintlg, trim_pln;
   IGRboolean        alloc_tintcvs=FALSE, alloc_tnumint=FALSE,
                     alloc_numtrmcvs=FALSE;
   IGRdouble         *uvlgd = NULL;
   IGRint            *rat2tab = NULL;
   IGRint            *ndeg2tab = NULL;
   struct
    BSgeom_bsp_surf  *new_pln = NULL, *new_gmsf = NULL, tnew_pln;
   struct
    BSgeom_bsp_curve *tintcvs=NULL, tintcvs2[MAXSIZE], **t3cvs=NULL;
   struct 
    IGRbsp_curve     **bsp_cvs = NULL;
   struct
    IGRbsp_surface   *pln_bs = NULL, *gmsf_bs = NULL;
   BSrc              rc1=BSSUCC, rc2=BSSUCC;
   IGRint            n;
   IGRdouble         par,d;
   IGRpoint          pt_old,pt_new;

   *rc = BSSUCC;

   /* Initialize final output pointers */
   *numgrps = 0;
   if (*intcvs)
      *intcvs = NULL;
   if (*numint)
      *numint = NULL;
   if (*numpts)
      *numpts = NULL;
   if (*intpts)
      *intpts = NULL;
   if (*plnpars)
      *plnpars = NULL;
   if (*gmsfpars)
      *gmsfpars = NULL;

   /* Initialize codes to FALSE */
   *ptcode = FALSE;
   *pln_code = FALSE;
   *gmsf_code = FALSE;
   *lgd_flag = FALSE;
   call_sur_surrg = FALSE;
   call_sfplintlg = FALSE;
   trim_pln = FALSE;

   BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);

   /* Set temporary pointer to pointer to B-spline of pln and gmsf */
   pln_bs = pln->bspsf;
   gmsf_bs = gmsf->bspsf;

   /* If pln->type != BSINF_PLANE and != BSGEN_BSP_SF, call BSgmsfprop
      if geom_sf->geom_prop = FALSE  (same for gmsf). */
   if (pln->type != BSINF_PLANE && pln->type != BSGEN_BSP_SF)
   {
      if (!pln->geom_prop)
      {
         BSgmsfprop(pln, rc);
         if (BSERROR(*rc) && *rc != BSNOTYETSUPPORTED)
            goto wrapup;

         if (*rc == BSNOTYETSUPPORTED)
            *rc = BSSUCC;
      }
   }

   if (gmsf->type != BSINF_PLANE && gmsf->type != BSGEN_BSP_SF)
   {
      if (!gmsf->geom_prop)
      {
         BSgmsfprop(gmsf, rc);
         if (BSERROR(*rc) && *rc != BSNOTYETSUPPORTED)
            goto wrapup;

         if (*rc == BSNOTYETSUPPORTED)
            *rc = BSSUCC;
      }
   }

   /* Set boolean indicating if pln is infinite or bounded and fill in
      new_pln structure appropriately. */

   if (pln->type == BSRECT_PLANE)
   {
      good_pln1 = TRUE;
      new_pln = pln;
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
        
         inf_plane1 = TRUE;   
         good_pln1 = TRUE;
         new_pln = pln;
         new_pln->bspsf = NULL;
      }
      else
      {
         if (pln_bs->planar)
         {
            /* Calculate and set properties of temporary plane (new_pln) */
            new_pln = pln;
            new_pln->geom_prop = TRUE;

            /* Call BSlsqptlnpl to get point and normal vector for pln */
            npts = pln_bs->u_num_poles * pln_bs->v_num_poles;
            option = 3;
            BSlsqptlnpl(npts, pln_bs->poles, pln_bs->weights, option, &code, 
                        new_pln->pt1, new_pln->vec1, &err, rc);
            if (BSERROR(*rc))
               goto wrapup;

            if (code != 3 && err > (10*dist_tol))
            {
               *rc = BSNONPLANAR;
               goto wrapup;
            }

            if (!pln->bounded)
            {
               inf_plane1 = TRUE;
               good_pln1 = TRUE;
            }
         }
      }
   }   /* end if (pln->type == BSRECT_PLANE) */


   /* Set boolean indicating if gmsf is infinite or bounded plane and fill in
      new_gmsf structure. */

   if (gmsf->type == BSRECT_PLANE)
   {
      good_pln2 = TRUE;
      new_gmsf = gmsf;
   }
   else
   {
      if (gmsf->type == BSINF_PLANE)
      {
         if (!gmsf->geom_prop)
         {
            /* If gmsf is inf. plane, geometric properties MUST be given*/
            *rc = BSINARG;
            goto wrapup;
         }
   
         good_pln2 = TRUE;
         new_gmsf = gmsf;
         new_gmsf->bspsf = NULL;
      }
      else
      {
         new_gmsf = gmsf;
         if (gmsf_bs->planar)
         {
            if (!gmsf->bounded)
            {
               good_pln2 = TRUE;
	
               new_gmsf->geom_prop = TRUE;
               /* Call BSlsqptlnpl to get point and normal vector for pln */
               npts = gmsf_bs->u_num_poles * gmsf_bs->v_num_poles;
               option = 3;
               BSlsqptlnpl(npts, gmsf_bs->poles, gmsf_bs->weights, option, 
                           &code, new_gmsf->pt1, new_gmsf->vec1, &err, rc);
               if (BSERROR(*rc))
                  goto wrapup;

               if (code != 3 && err > (10*dist_tol))
               {
                  *rc = BSNONPLANAR;
                  goto wrapup;
               }
            }
         }
      }
   }   /* end if (sf1->type == BSRECT_PLANE) */



   /* Call appropriate routine for intersection */
   if (good_pln1 && good_pln2)
   {
      /*****************/
      /* PLANE / PLANE */
      /*****************/
      BSx2pln(new_pln, new_gmsf, numgrps, numint, intcvs, rc);
      if (BSERROR(*rc) && *rc != BSNOTYETSUPPORTED)
         goto wrapup;
   }
   else
   {
      if (good_pln1 && (new_gmsf->type == BSSPHERE || 
                        new_gmsf->type == BSPART_SPHERE))
      {
         /******************/
         /* SPHERE / PLANE */
         /******************/
         BSxsphpln(new_gmsf, new_pln, numgrps, numint, intcvs, rc);
         if (BSERROR(*rc) && *rc != BSNOTYETSUPPORTED)
            goto wrapup;
      }
      else
      {
         if (good_pln1 && (new_gmsf->type == BSFULL_CYL || 
                           new_gmsf->type == BSPART_CYL))
         {
            /********************/
            /* CYLINDER / PLANE */
            /********************/
            BSxcylpln(new_gmsf, new_pln, numgrps, numint, intcvs, rc);
            if (BSERROR(*rc) && *rc != BSNOTYETSUPPORTED)
               goto wrapup;
         }
         else
         {
            if (good_pln1 && (new_gmsf->type == BSFULL_CONE || 
                              new_gmsf->type == BSPART_CONE))
            {
               /****************/
               /* CONE / PLANE */	
               /****************/
               BSxconepln(new_gmsf, new_pln, numgrps, numint, intcvs, rc);
               if (BSERROR(*rc) && *rc != BSNOTYETSUPPORTED)
               {
                  if (*rc != BSINCONSISTENT)
                     goto wrapup;
                  else
                  {
                     if (inf_plane1 || new_pln->type == BSRECT_PLANE)
                        call_sfplintlg = TRUE;
                     else
                        call_sur_surrg = TRUE;
                  }
               }
            }
            else
            {
               if (new_gmsf->type == BSSF_OF_PROJ && good_pln1)
               {
                  /************************/	
                  /* SF. OF PROJ. / PLANE */
                  /************************/	
                  BSxsfprjpln(new_gmsf, new_pln, numgrps, numint, intcvs, rc);
                  if (BSERROR(*rc) && *rc != BSNOTYETSUPPORTED)
                        goto wrapup;
               }
               else
               {
                  if (good_pln1 && (new_gmsf->type == BSSF_OF_REV || 
                      new_gmsf->type == BSTORUS || 
                      new_gmsf->type == BSPART_TORUS))
                  {
                     /***********************/
                     /* SF. OF REV. / PLANE */
                     /***********************/

                     if (new_gmsf->type == BSTORUS || 
                         new_gmsf->type == BSPART_TORUS)
                     {
                        /* Set up new_gmsf as BSSF_OF_REV instead of torus.
                           Properties will be calculated inside BSxsfrevpln*/
                        new_gmsf->type = BSSF_OF_REV;
                        new_gmsf->geom_prop = FALSE;
                        new_gmsf->sfgen_cv = NULL;
                     }

                     BSxsfrevpln(new_gmsf, new_pln, numgrps, numint, intcvs, 
                                 rc);
                     if (BSERROR(*rc))
                     {
                        if (*rc != BSNOTYETSUPPORTED)
                           goto wrapup;
                        else
                        {
                           if (inf_plane1 || new_pln->type == BSRECT_PLANE)
                              call_sfplintlg = TRUE;
                           else
                              call_sur_surrg = TRUE;
                        }
                     }
                  }
                  else
                  {
                     if (inf_plane1 || new_pln->type == BSRECT_PLANE)
                     {
                        /***************************/
                        /* GEN. SURF. / INF. PLANE */
                        /***************************/

                        call_sfplintlg = TRUE;
                     }
                     else
                     {
                        /******************************/
                        /* GEN. SURF. / BOUNDED PLANE */
                        /******************************/

                        call_sur_surrg = TRUE;
                     }

                  }   /* end if (new_gmsf->type == BSSF_OF_REV) */

               }   /* end if (new_gmsf->type == BSSF_OF_PROJ) */

            }   /* end if (new_gmsf->type == BSFULL_CONE ...) */

         }   /* end if (new_gmsf->type == BSFULL_CYL ...) */

      }   /* end if (new_gmsf->type == BSSPHERE ...) */

   }   /* end if (good_pln1 && good_pln2)*/

   if (call_sfplintlg || *rc == BSNOTYETSUPPORTED)
   {
      if (*rc == BSNOTYETSUPPORTED)
         *rc = BSSUCC;

      *numgrps = 0;
      cvscode = 3;
      if (new_pln->type == BSRECT_PLANE)
      {
         /* Set infinite plane information into new_pln. Note: new_pln->pt1
            and new_pln->vec1 are same for rectangular and infinite planes */
         trim_pln = TRUE;
         tnew_pln.type = BSINF_PLANE;
         tnew_pln.geom_prop = TRUE;
         tnew_pln.bounded = FALSE;   
         for (i = 0; i < 3; ++i)
         {
             tnew_pln.pt1[i] = new_pln->pt1[i];
             tnew_pln.vec1[i] = new_pln->vec1[i];
         }
         BSsfplintlg(tnew_pln.pt1, tnew_pln.vec1, new_gmsf->bspsf, cvscode, 
                    korder, prec, &tnumgrps, lgd_cvs, &bsp_cvs,rc);
      }
      else
      {
         BSsfplintlg(new_pln->pt1, new_pln->vec1, new_gmsf->bspsf, cvscode, 
                    korder, prec, &tnumgrps, lgd_cvs, &bsp_cvs,rc);
      }
      if (BSERROR(*rc) && *rc != BSOUTOFDESN && *rc != BSNOMEMORY &&
          *rc != BSNOSTKMEMORY && *rc != BSWARN && *rc != BSINCONSISTENT)
         goto wrapup;

      if (*rc == BSSUCC)
      {
         *rc = BSSUCC;
         *lgd_flag = TRUE;
         if (tnumgrps > 0)
         {
            if (trim_pln)	
            {
               if (tnumgrps > MAXSIZE)
               {
                  tintcvs = (struct BSgeom_bsp_curve *) BSmalloc((unsigned) 
                               tnumgrps * sizeof(struct BSgeom_bsp_curve));
                  if (! (tintcvs))
                  {
                     *rc = BSNOMEMORY;
                     goto wrapup;
                  }
                  alloc_tintcvs=TRUE;

                  tnumint = (IGRint *)BSmalloc((unsigned) tnumgrps * 
                                sizeof(IGRint));
                  if (! tnumint)
                  {
                     *rc = BSNOMEMORY;
                     goto wrapup;
                  }
                  alloc_tnumint=TRUE;
               }
               else
               {
                  tintcvs = tintcvs2;
                  tnumint = tnumint2;
               }
 
               for (i = 0; i < tnumgrps; ++i)
               {
                   tnumint[i] = 1;	
                   tintcvs[i].bspcv = NULL;
                   tintcvs[i].array1 = NULL;
   
                   tintcvs[i].geom_prop = 0;
                   tintcvs[i].bscv_flag = 1;
                   BStstcvdegn(bsp_cvs[i],&degen,rc);
                   if (BSERROR(*rc))
                      goto wrapup;
                   if (degen)
                      tintcvs[i].type = 0;
                   else
                      tintcvs[i].type = 8;       
                   tintcvs[i].bspcv = bsp_cvs[i];
               }

               if (tnumgrps > MAXSIZE)
               {
                  numtrmcvs = (IGRint *)BSstackalloc((unsigned) 
                                 tnumgrps * sizeof (IGRint));
                  if (!numtrmcvs)
                  {
                     *rc = BSNOSTKMEMORY;
                     goto wrapup;
                  }
                  alloc_numtrmcvs = TRUE;
               }
               else
               {
                  numtrmcvs = numtrmcvs2;
               }

               t3cvs = (struct BSgeom_bsp_curve **)BSstackalloc((unsigned) 
                         tnumgrps * sizeof (struct BSgeom_bsp_curve *));
               if (!t3cvs)
               {
                  *rc = BSNOSTKMEMORY;
                  goto wrapup;
               }

               for (i = 0; i < tnumgrps; ++i)
                   t3cvs[i] = NULL;

               tnumgrps3 = 0;
               totcvs = 0;
               for (i = 0; i < tnumgrps; ++i)
               {
                  BStrgmcvtsf(&(tintcvs[i]), new_pln, &(numtrmcvs[i]), 
                              &(t3cvs[i]), rc);
                  if (BSERROR(*rc))
                     goto wrapup;

                  ++tnumgrps3;
                  totcvs += numtrmcvs[i];

                  /* If intersection curve has been trimed, we cannot
                     use lgd_cvs any more. Set lgd_flag = FALSE.
                     Otherwise, we should keep lgd_cvs and output it.
                     Fix for TR9700195. Vivian Hsu 3/13/97. */

                  
                  if (numtrmcvs[i] == 0 || numtrmcvs[i] > 1 )
                    *lgd_flag = FALSE; 
                  else if (numtrmcvs[i] == 1)
                  {
                    if (tintcvs[i].bspcv->num_poles != 
                        t3cvs[i][0].bspcv->num_poles)
                      *lgd_flag = FALSE;
                    else
                    {
                      par = tintcvs[i].bspcv->knots[0];
                      BScveval(tintcvs[i].bspcv,par,0,(IGRpoint *)pt_old,rc);
                      if (BSERROR(*rc))
                        goto wrapup;
                      par = t3cvs[i][0].bspcv->knots[0];
                      BScveval(t3cvs[i][0].bspcv,par,0,(IGRpoint *)pt_new,rc);
                      if (BSERROR(*rc))
                        goto wrapup;                       
                      d = BSdistptpts(rc,pt_old,pt_new);
                      if (d > dist_tol * dist_tol)
                        *lgd_flag = FALSE;
                      else
                      {
                        n = tintcvs[i].bspcv->num_poles;
                        par = tintcvs[i].bspcv->knots[n];
                        BScveval(tintcvs[i].bspcv,par,0,(IGRpoint *)pt_old,rc);
                        if (BSERROR(*rc))
                          goto wrapup;
                        n = t3cvs[i][0].bspcv->num_poles;
                        par = t3cvs[i][0].bspcv->knots[n];
                        BScveval(t3cvs[i][0].bspcv,par,0,(IGRpoint *)pt_new,rc);
                        if (BSERROR(*rc))
                          goto wrapup;                       
                        d = BSdistptpts(rc,pt_old,pt_new);
                        if (d > dist_tol * dist_tol)
                          *lgd_flag = FALSE;

                      }
                    }
                  }
               }

               /* Copy t3cvs into final output */

               *numgrps = totcvs;
               if (totcvs == 0)
                  goto wrapup;

               *numint = (IGRint *)BSmalloc((unsigned) totcvs * 
                            sizeof(IGRint));
               if (! *numint)
               {
                  *rc = BSNOMEMORY;
                  goto wrapup;
               }

               *intcvs = (struct BSgeom_bsp_curve *)BSmalloc(totcvs * sizeof
                             (struct BSgeom_bsp_curve));
               if (! *intcvs)
               {
                  *rc = BSNOMEMORY;
                  goto wrapup;
               }
  
               cnt = 0;
               offset = 0;
               for (i = 0; i < tnumgrps3; ++i)
               {
                   for (j = 0; j < numtrmcvs[i]; ++j)
                   {
                      (*intcvs)[cnt].bspcv = NULL;
                      (*intcvs)[cnt].array1 = NULL;
                      (*numint)[cnt] = 1;
                      ++cnt;
                   }   
   
                   BSMEMCPY((numtrmcvs[i]*sizeof (struct BSgeom_bsp_curve)),
                             (IGRchar *)t3cvs[i], 
                             (IGRchar *)&(intcvs[0][offset]));
 
                   for (j = 0; j < numtrmcvs[i]; ++j)
                   {
                      t3cvs[i][j].bspcv = NULL;
                      t3cvs[i][j].array1 = NULL;
                   }
 
                   offset += numtrmcvs[i];
   
               }


               /* free memory bsp_cvs returned from BSsfplintlg */
               /* free memory lgd_cvs if lgd_flag = FALSE */  

               if (bsp_cvs)
               {
                  for (i = tnumgrps-1; i >= 0; --i)
                  {
                     if (bsp_cvs[i])
                     {
                        (void)BSfreecv(rc, bsp_cvs[i]);
                        if (BSERROR(*rc))
                           goto wrapup;
                        bsp_cvs[i]=NULL;
                        tintcvs[i].bspcv=NULL;
                    }
                  }               
                  BSdealloc((char *) bsp_cvs);
                  bsp_cvs=NULL;
               }

               if (*lgd_cvs && !lgd_flag)
               {
                  BSfrecmpcvs(*lgd_cvs,rc);
                  if (BSERROR(*rc))
                    goto wrapup;
                  *lgd_cvs = NULL;

                  
               }   /* end if (*lgd_cvs) */

            }
            else
            {
               *numgrps = tnumgrps;
               *intcvs = (struct BSgeom_bsp_curve *) BSmalloc((unsigned) 
                            *numgrps * sizeof(struct BSgeom_bsp_curve));
               if (! (*intcvs))
               {
                  *rc = BSNOMEMORY;
                  goto wrapup;
               }

               *numint = (IGRint *)BSmalloc((unsigned) *numgrps * 
                            sizeof(IGRint));
               if (! *numint)
               {
                  *rc = BSNOMEMORY;
                  goto wrapup;
               }
 
               for (i = 0; i < *numgrps; ++i)
               {
                   (*numint)[i] = 1;	
                   (*intcvs)[i].bspcv = NULL;
                   (*intcvs)[i].array1 = NULL;

                   (*intcvs)[i].geom_prop = 0;
                   (*intcvs)[i].bscv_flag = 1;
                   BStstcvdegn(bsp_cvs[i],&degen,rc);
                   if (BSERROR(*rc))
                      goto wrapup;
                   if (degen)
                      (*intcvs)[i].type = 0;
                   else
                      (*intcvs)[i].type = 8;       
                   (*intcvs)[i].bspcv = bsp_cvs[i];
   
               }
            }   /* end if (trim_pln) */
         }   /* end if (tnumgrps > 0) */
      } 
      else
      {
         /* rc = BSOUTOFDESN or BSNOMEMORY or BSNOSTKMEMORY or BSWARN -- 
            Call BSsf_pl_int */
         *rc = BSSUCC;

         /* Set lgd_flag = FALSE and free memory (bsp_cvs, lgd_cvs)
            returned from BSsfplintlg */
         *lgd_flag = FALSE;

         if (bsp_cvs)
         {
            for (i = tnumgrps-1; i >= 0; --i)
            {
               if (bsp_cvs[i])
               {
                  (void)BSfreecv(rc, bsp_cvs[i]);
                  if (BSERROR(*rc))
                     goto wrapup;
                  bsp_cvs[i]=NULL;
               }
            }               
            BSdealloc((char *) bsp_cvs);
            bsp_cvs=NULL;
         }

         if (*lgd_cvs)
         {
            BSfrecmpcvs(*lgd_cvs,rc);
            if (BSERROR(*rc))
              goto wrapup;
            *lgd_cvs = NULL;

         }   /* end if (*lgd_cvs) */

         if (!trim_pln)
         {
            tan_flag = FALSE;
            BSsf_pl_int(new_pln->pt1, new_pln->vec1, new_gmsf->bspsf, tan_flag,
                        numgrps, numpts, intpts, &tans, gmsfpars, rc);
            if (BSERROR(*rc))
               goto wrapup;

            *ptcode = TRUE;
            *gmsf_code = TRUE;

            if (*numgrps > 0)
            {
               *numint = (IGRint *)BSmalloc((unsigned)*numgrps * sizeof 
                            (IGRint));
               if (! *numint)
               {
                  *rc = BSNOMEMORY;
                  goto wrapup;
               }
       
               for (i = 0; i < *numgrps; ++i)
                   (*numint)[i] = 1;	
            }   /* end if (*numgrps > 0) */

         }
         else
         {
            call_sur_surrg = TRUE;
         }   /* end if (!trim_pln) */

      }   /* end if (*rc == BSSUCC) */

   }   /* end if (call_sfplintlg) */

   if (call_sur_surrg)
   {
      /*********************/
      /* GENENERAL SURFACE */
      /*********************/

      if (trim_pln)
         trim_pln = FALSE;

      (void)BSsur_surrg(rc, new_pln->bspsf, new_gmsf->bspsf, &dum_tol1, 
                        &dum_tol2, new_pln->urange, new_pln->vrange,
                        new_gmsf->urange, new_gmsf->vrange, numgrps, numpts, 
                        intpts, plnpars, gmsfpars);
      if (BSERROR(*rc))
         goto wrapup;

      *ptcode = TRUE;
      *gmsf_code = TRUE;
      *pln_code = TRUE;

      if (*numgrps > 0)
      {
         *numint = (IGRint *)BSmalloc((unsigned) *numgrps * sizeof (IGRint));
         if (! *numint)
         {
            *rc = BSNOMEMORY;
            goto wrapup;
         }

         for (i = 0; i < *numgrps; ++i)
             (*numint)[i] = 1;

      }
   }   /* end if (call_sur_surrg) */

   wrapup:

   if (t3cvs)
   {
      i = tnumgrps - 1;
      while ( i >= 0)
      {
         if (t3cvs[i])
         {
            k = numtrmcvs[i] - 1;
            while (k >= 0)
            {
               if (t3cvs[i][k].array1)
               {
                  BSdealloc((char *) t3cvs[i][k].array1);
                  t3cvs[i][k].array1 = NULL;          
               }
               if (t3cvs[i][k].bspcv)
               {
                  (void)BSfreecv(&rc2, t3cvs[i][k].bspcv);
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

   if (tintcvs)
   {
      for (i = 0; i < tnumgrps; ++i)
      {
          if (tintcvs[i].bspcv)
          {
             (void)BSfreecv(&rc1, tintcvs[i].bspcv);
             if (BSERROR(rc1) && BSOKAY(*rc))
                *rc = rc1;
             rc1 = BSSUCC; 
          }
      }
      if (alloc_tintcvs)
      {
         BSdealloc((char *) tintcvs);
         tintcvs = NULL;
      }
   }

   if (alloc_tnumint && tnumint)
   {
      BSdealloc((char *) tnumint);
      tnumint = NULL;
   }
   if (alloc_numtrmcvs)
   {
      BSstackdealloc((char *) numtrmcvs);
      numtrmcvs = NULL;
   }


   if (*numgrps == 0)
   {
      if (*numpts)
      {
         BSdealloc((char *) *numpts);
         *numpts = NULL;
      }

      if (*gmsfpars)
      {
         BSdealloc((char *) *gmsfpars);
         *gmsfpars = NULL;
      }

      if (*plnpars)
      {
         BSdealloc((char *) *plnpars);
         *plnpars = NULL;
      }

      if (*numint)
      {
         BSdealloc((char *) *numint);
         *numint = NULL;
      }

      if (*intcvs)
      {
         BSdealloc((char *) *intcvs);
         *intcvs = NULL;
      }

      rc2 = BSSUCC;
      if (*lgd_cvs)
      {
         BSfrecmpcvs(*lgd_cvs,&rc2);
         if (BSERROR(rc2) && BSOKAY(*rc))
            *rc = rc2;
         rc2 = BSSUCC;
         *lgd_cvs = NULL;

      }   /* end if (*lgd_cvs) */
   }   /* end if (*numgrps == 0) */
 
   /* Deallocate temporary ptrs */
   if (*rc == BSINCONSISTENT)
   {
      if (bsp_cvs)
      {
         for (i = tnumgrps-1; i >= 0; --i)
         {
            if (bsp_cvs[i])
            {
               (void)BSfreecv(&rc2, bsp_cvs[i]);
               if (BSERROR(rc2) && BSOKAY(*rc))
                  *rc = rc2;
               rc2 = BSSUCC;
               bsp_cvs[i]=NULL;
            }
         }               
         BSdealloc((char *) bsp_cvs);
         bsp_cvs=NULL;
      }
   }
   else
   {   
      if (bsp_cvs)
         BSdealloc((char *) bsp_cvs);
   }

   if (uvlgd)
     BSdealloc((char *) uvlgd);
   if (rat2tab)
     BSdealloc((char *) rat2tab);
   if (ndeg2tab)
     BSdealloc((char *) ndeg2tab);

   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSxplngmsfo");
   return;
   }
}   
