/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSmdistcvsf

Abstract
    Find the minumum distance between a curve and a surface.

Synopsis
    void  BSmdistcvsf(curve,surf,num,part,paruv,cpt,sfpt,dist,rc)

    struct IGRbsp_curve   *curve
    struct IGRbsp_surface *surf
    IGRint                *num
    IGRdouble             **part
    IGRdouble             **paruv
    IGRpoint              **cpt,
                          **sfpt
    IGRdouble             *dist
    BSrc                  *rc

Description
    This routine inputs a curve and a surface.  It outputs the number of points
at minimum distance(num), the parameters(part) and points on the curve(cpt),
the parameters(paruv) and points on the surface(sfpt), and the minimum distance.

Return Values
    A return code BSSUCC is returned if everything was successful, and an
error return code is returned if an error occurrs.

Notes
    More than one point is output only if there is an intersection between the
curve and the surface and there are more than one intersection points.

Index
    md

Keywords

History
    S.G. Catron  11/20/86  : Creation date.
    Y.S. Sheng   03/03/87  : Replace BScvkttol with BScvkttol2.
    S.G. Catron  06/01/87  : Replace BSsfkttol with BSsfkttol2.
    S.G. Catron  06/16/87  : Modified code greatly to make more efficient.
    S.G. Catron  06/23/87  : If BSlnnorcvsf doesn't find solution, then we 
                             call new routine BSmdstcsgtc. Also if BSlnn2cvs 
                             doesn't find solution, then we call new routine
                             BSmdstccgtc.
    S.G. Catron  06/25/87  : Call routine for finding neigboring parameters.
                             Also call BSmdstptarr to find closest points in
                             array.
    S.G. Catron  07/13/87  : Added check for num_poles > order and only check
                             cusps if so.  Also added call to BSmdstptcv if
                             mulp1=FALSE, mulp2=TRUE and mulp3=TRUE.
    S.G. Catron  07/13/87  : Added check after calling BSlnnorcvsf to see if
                             *rc = BSFAIL, then do iteration.  Also have to find
                             knot tolerances whether num_poles > order or not.
    C.S.SAMUELS  08/11/87  : Replaced call to BSsfnodpts with BSsfnodptsm.
    S.G. Catron  08/11/87  : Allocate both *umul and *vmul if either direction
                             has a higher number of poles than order.
    S.G. Catron  01/29/88  : Fixed lint errors.
    S.G. Catron  06/09/89  : Changed the calculations of the insertion
                             values.  It was inserting too many values
                             for some cases.  Added special code for
                             order 2, and if the average pole distance
                             is less than a chord height tolerance.
    D. Breden    12/16/89  : Initialize boundaries in static curve.
    S.G. Catron  09/16/92  : I added some code for calculating the insert-
                             ion values.  The problem is when you have
                             a large plane and much smaller curve, 
                             more nodes is needed.  I reviewed code in
                             BSmdistcvcv and made similar changes here.
    S.G. Catron  01/04/95  : I added code in calculating the insertion
                             values for the surface.  There was a problem
                             with large surfaces having so many node
                             values that it could not allocate the point
                             array. Now, it checks to see if insert value
                             is too large.
    Vivian Y.Hsu 06/04/99  : VDS reported TR. When the curve (line )
                             sits on the surface (plane). BScv_sf_int 
                             return num_int = 0.BSlnnorcvsf failed. 
                             BSmdstcsgtc returns distance which is not
                             a normal projection from the curve to
                             surface. I replaced BSmdstcsgtc by calling
                             BSmdptbssf to find minimum distance from
                             sampling points on the curve to the surface.

    Vivian Y. Hsu 02/14/2000 Replace BScv_sf_int by BScvsfintrg because it returns 
                             solution of overlap when the input surface is planar.

    S.G. Catron   04/12/2000 Added a call to special case code for line/plane -
                             BSmdistlnpl.
	Vivian Hsu    11/01/2000 Added a kludge when numvals1 * num_pts > 10000000, we call
							 BSmdptbssf loop over numvals1 to speed up.

*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bserr.h"
#include "bsstackalloc.h"
#include "bsmalloc.h"
#include "bsstk.h"
#include "bsparameters.h"
#include "bsvalues.h"
#endif
#include <math.h>
#define  BSVOID 

static void helperBSmdistcvsf(
   IGRdouble  *knots,
   IGRshort   order,
   IGRlong    num_poles,
   IGRboolean phy_closed,
   IGRdouble  ng[2],
   IGRint     num_pars,
   IGRdouble  tol,
   IGRint     *stop,
   IGRdouble  *pars,
   BSrc       *rc)
   {

      IGRdouble delta;
      IGRint i;
 
      *rc = BSSUCC;

      *stop = num_pars;
      if( phy_closed && ng[0] > ng[1])
      {
         delta = (knots[num_poles] - ng[0] + ng[1])/
                 (num_pars -1);
         pars[0] = ng[0];
         for(i=1; i< num_pars -1; i++)
         {
            if(( pars[i-1] + delta) > knots[num_poles])
            {
               *stop = i;
               if( fabs(pars[i-1] - knots[num_poles] ) < tol )
               {
                  pars[i-1] = knots[num_poles];
               }
               pars[i] = (knots[order -1] + delta ) -
                          (knots[num_poles] - pars[i-1] );
            }
            else
            {
               pars[i] = pars[i-1] + delta;
            }
         }
      }
      else
      {            
         delta = (ng[1] - ng[0]) / (num_pars -1);
         pars[0] = ng[0];
         for(i=1; i< num_pars -1; i++)
         {
            pars[i] = pars[i-1] + delta;
         }
      }
      pars[num_pars -1] = ng[1];

      return;
   }  /* end of static routine */


void BSmdistcvsf(
struct IGRbsp_curve   *curve,
struct IGRbsp_surface *surf,
IGRint                *num,
IGRdouble             **part,
IGRdouble             **paruv,
IGRpoint              **cpt,
IGRpoint              **sfpt,
IGRdouble             *dist,
BSrc                  *rc )
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsdistptpt.h"
#include "bscvnodpts.h"
#include "bssfnodptsm.h"
#include "bsfndcvcsp.h"
#include "bsfndsfcsp.h"
#include "bsmdstptarr.h"
#include "bststsfdegn.h"
#include "bsfndneighb.h"
#include "bsptnorpch.h"
#include "bststcvdegn.h"
#include "bsmdstcsgtc.h"
#include "bsmdstccgtc.h"
#include "bsmdstptcv.h"
#include "bscvkttol2.h"
#include "bssfkttol2.h"
#include "bslnnorcvsf.h"
#include "bscvsfintrg.h"
#include "bsmdistptsf.h"
#include "bslnn2cvs.h"
#include "bsconstprcv.h"
#include "bsavgdispts.h"
#include "bsavgdisarr.h"
#include "bscvarreval.h"
#include "bsmdptbssf.h"
#endif 

   /* IGRdouble neig3[2];*/
   IGRdouble *umul=NULL,*vmul=NULL,
             dist1,neig1[2],neig2[2],
             *ndvals1=NULL,*ndvals2=NULL,
             *ndvals3=NULL,p1,p2,p3,
             *tmul=NULL,cvknot_tol,
             sfknot_tol,avgdist, avgu, avgv;
   IGRint    insert,ind1,ind2,ind3,
             numu,numv,num_pts,num_kts,
             max,insert1,insert2,
             insert3,numvals1,numvals2,
             numvals3,i,j, div, top,nd;
   IGRpoint  *points1=NULL,*points2=NULL,
             bpoint,pole1[2];
   IGRdouble knot1[4],dist_tol, chrdht_tol;
   IGRdouble  points[33];
   IGRdouble pars1[11],ptmin[3],uvmin[2],mdist;
   IGRint    num_derv = 0, num_pars,stop;
   struct IGRbsp_curve line1,*cv=NULL;
   IGRboolean mulp1,mulp2,mulp3,tst_plan,degen,
              udeg,unp,vdeg,vnp;
   IGRshort opt;
   IGRint      nump, nover = 0,numo,num_int = 0;
   IGRpoint    *overpts1 = NULL,
			   *overpts2 = NULL,
			   *xpoints1 = NULL,
			   *xpoints2 = NULL;
   IGRdouble   *tover1 = NULL, *tover2 = NULL;
   IGRdouble   urng[2], vrng[2], trng[2];
   IGRdouble   *par1=NULL,*par2 = NULL, linepar[2], planeuv[2][2];
   IGRpoint    lnpt[2], planept[2];
   BSpair      *uvpar1 = NULL, *uvpar2 = NULL,*uvover1 = NULL,*uvover2 = NULL;
   IGRboolean  duplicate,allocpts,allocov;
	IGRdouble  dsup = MAXDOUBLE;            


   *rc = BSSUCC;

   *num = 0;

   if( curve->num_poles == 2 && surf->u_num_poles == 2 && surf->v_num_poles == 2 && surf->planar )
   {
      BSmdistlnpl(curve, surf, num, linepar, planeuv, lnpt, planept, dist, rc);
      if(BSERROR(*rc))
         goto wrapup;
      *sfpt = (IGRpoint *)BSmalloc((unsigned)( *num * sizeof(IGRpoint )));
      if(! *sfpt)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *cpt = (IGRpoint *)BSmalloc((unsigned)( *num * sizeof(IGRpoint )));
      if(! *cpt)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *paruv = (IGRdouble *)BSmalloc((unsigned)( *num*2 * sizeof(IGRdouble)));
      if(! *paruv)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *part = (IGRdouble *)BSmalloc((unsigned)( *num * sizeof(IGRdouble )));
      if(! *part )
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      for(j=0; j< *num; j++)
      {
         for(i=0; i<3; i++)
         {
            (*cpt)[j][i] = lnpt[j][i];
            (*sfpt)[j][i] = planept[j][i];
         }
         (*part)[j] = linepar[j];
         (*paruv)[j*2+0] = planeuv[j][0];
         (*paruv)[j*2+1] = planeuv[j][1];      
      }
      goto wrapup;
   }         
     
   BStstcvdegn(curve,&degen,rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   if( degen)
   {

      /* curve is degenerate, so just find minimum distance from point to  
         surface  */

      *sfpt = (IGRpoint *)BSmalloc((unsigned)( 1 * sizeof(IGRpoint )));
      if(! *sfpt)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *cpt = (IGRpoint *)BSmalloc((unsigned)( 1 * sizeof(IGRpoint )));
      if(! *cpt)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *paruv = (IGRdouble *)BSmalloc((unsigned)( 2 * sizeof(IGRdouble)));
      if(! *paruv)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *part = (IGRdouble *)BSmalloc((unsigned)( 1 * sizeof(IGRdouble )));
      if(! *part )
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      (void)BSmdistptsf(rc,surf,&curve->poles[0],&(*paruv)[0],&(*paruv)[1],
                        (*sfpt)[0],dist);
      if(BSERROR(*rc))
      {
         goto wrapup;
      }
      for(i=0; i<3; i++)
      {
         (*cpt)[0][i] = curve->poles[i];
      }
      (*part)[0] = curve->knots[curve->order -1];
      *num = 1;
      goto wrapup;
   }

   /* first call BScv_sf_int, to see if curve and surface intersect, which 
      will be points on minimum distance. Replace BScv_sf_int by BScvsfintrg
	  which returns overlap solution 

   (void)BScv_sf_int(rc,curve,surf,num,(IGRdouble **)cpt,part,&paru,&parv);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   */

   nump = 0;
   numo = 0;
   trng[0] = curve->knots[curve->order -1];
   trng[1] = curve->knots[curve->num_poles ];
   urng[0] = surf->u_knots[surf->u_order -1];
   urng[1] = surf->u_knots[surf->u_num_poles];
   vrng[0] = surf->v_knots[surf->v_order -1];
   vrng[1] = surf->v_knots[surf->v_num_poles];
   duplicate = TRUE;

   (void)BScvsfintrg(curve, surf, trng, urng, vrng, nump, xpoints1, par1, uvpar1, 
               numo, overpts1, tover1, uvover1, duplicate, &num_int, &nover, 
               &allocpts, &allocov, &xpoints2, &par2, &uvpar2,
               &overpts2, &tover2, &uvover2, rc);
   if(BSERROR(*rc))
      goto wrapup;

   if( num_int > 0 || nover > 0 )
   {
	  /* Output the intersection points and start, end points of the overlap */

	  *num = num_int + 2 * nover;
      *cpt = (IGRpoint *)BSmalloc((unsigned)( *num * sizeof(IGRpoint )));
      if(! *cpt)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *part = (IGRdouble *)BSmalloc((unsigned)( *num * sizeof(IGRdouble )));
      if(! *part )
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *sfpt = (IGRpoint *)BSmalloc((unsigned)( *num * sizeof(IGRpoint )));
      if(! *sfpt)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *paruv = (IGRdouble *)BSmalloc((unsigned)( *num *2 * sizeof(IGRdouble)));
      if(! *paruv)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }

      for(i=0; i< num_int; i++)
      {
         for(j=0; j<3; j++)
         {
			(*cpt)[i][j] = xpoints2[i][j];
            (*sfpt)[i][j] = (*cpt)[i][j];
         }
         (*paruv)[i*2] = uvpar2[i][0];
         (*paruv)[i*2+1] = uvpar2[i][1];
		 (*part)[i] = par2[i];
      }

      for(i=0; i< 2 * nover; i++)
      {
         for(j=0; j<3; j++)
         {
			(*cpt)[num_int + i][j] = overpts2[i][j];
            (*sfpt)[num_int + i][j] = (*cpt)[num_int + i][j];
         }
         (*paruv)[(num_int + i)*2] = uvover2[i][0];
         (*paruv)[(num_int + i)*2+1] = uvover2[i][1];
		 (*part)[num_int + i] = tover2[i];
      }


      *dist = 0;
      goto wrapup;
   }      

   /*  if no intersection points, then there is only one output point  */

   *sfpt = (IGRpoint *)BSmalloc((unsigned)( 1 * sizeof(IGRpoint )));
   if(! *sfpt)
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }
   *cpt = (IGRpoint *)BSmalloc((unsigned)( 1 * sizeof(IGRpoint )));
   if(! *cpt)
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }
   *paruv = (IGRdouble *)BSmalloc((unsigned)( 2 * sizeof(IGRdouble)));
   if(! *paruv)
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }
   *part = (IGRdouble *)BSmalloc((unsigned)( 1 * sizeof(IGRdouble )));
   if(! *part )
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }

   BSEXTRACTPAR(rc,BSTOLLENVEC,dist_tol);

   /*  make up a net of points for the surface and curve, and find the two
       points closest together   */

   insert = 2;
   ind1 = ( curve->num_poles + curve->order - 1 ) * ( insert + 1 );
   ind2 = ( surf->u_num_poles + surf->u_order - 1 ) * ( insert + 1 );
   ind3 = ( surf->v_num_poles + surf->v_order - 1 ) * ( insert + 1 );
   i = ind1;         /* i will be maximum of ind1, ind2 and ind3  */
   if( i < ind2 )
      i = ind2;

   if( i < ind3 )
      i = ind3;

   if( ind1 == i )
     insert1 = 2;
   else
      insert1 = i / ( curve->num_poles + curve->order - 1 ) - 1;

   if( ind2 == i || ind3 == i)
   {
      /* S.G. Catron 1/4/95 the surface node points could not be 
         allocated because of insertion value bing too large .
         So, check insert(problem due to large number of poles) */
      if( i > 500 )
      {
         insert = 1;
         ind2 = ( surf->u_num_poles + surf->u_order - 1 ) * ( insert +1);
         ind3 = ( surf->v_num_poles + surf->v_order - 1 ) * ( insert +1);
         i = MAX(ind2, ind3 );
      }
      if( i > 500 )
      {
         insert = 0;
         ind2 = ( surf->u_num_poles + surf->u_order - 1 ) * ( insert +1);
         ind3 = ( surf->v_num_poles + surf->v_order - 1 ) * ( insert +1);
         i = MAX(ind2, ind3 );
      }
   }
   if( ind2 == i )
   {
      insert2 = insert;
   }
   else
      insert2 = i / ( surf->u_num_poles + surf->u_order - 1 ) - 1;

   if( ind3 == i )
   {
      insert3 = insert;
   }
   else
      insert3 = i / ( surf->v_num_poles + surf->v_order - 1 ) - 1;

   if( curve->order == 2 && ((insert1 < 6 && curve->num_poles < 10) ||
                              (insert1 > 10 ) ) )
      /* if insert is too great or too small compared to it's number of
         poles, set to 6(which is a guess) */
      insert1 = 6;

   if( surf->u_order == 2 && ((insert2 < 6 && surf->u_num_poles < 10) ||
                              (insert2 > 10 ) ) )
      /* if insert is too great or too small compared to it's number of
         poles, set to 6(which is a guess) */
      insert2 = 6;

   if( surf->v_order == 2 && ((insert3 < 6 && surf->v_num_poles < 10) ||
                              (insert3 > 10 ) ) )
      /* if insert is too great or too small compared to it's number of
         poles, set to 6(which is a guess) */
      insert3 = 6;

   BSavgdispts(curve->num_poles, curve->poles, curve->weights, &avgdist,
               rc);
   if(BSERROR(*rc))
      goto wrapup;
   BSavgdisarr(surf->u_num_poles, surf->v_num_poles, 
               (IGRpoint *)surf->poles, surf->weights, &avgu, &avgv, rc);
   if(BSERROR(*rc))
      goto wrapup;

   BSEXTRACTPAR(rc,BSTOLCHRDHT,chrdht_tol);

   if( avgdist < 100 * chrdht_tol )
   {
      if( avgdist < 10 * chrdht_tol )
         insert1 = 0;
      else
         insert1 = 1;
   }
 
   if( avgu < 100 * chrdht_tol )
   {
      if( avgu < 10 * chrdht_tol )
         insert2 = 0;
      else
         insert2 = 1;
   }

   if( avgv < 100 * chrdht_tol )
   {
      if( avgv < 10 * chrdht_tol )
         insert3 = 0;
      else
         insert3 = 1;
   }

   /* when curve or surface is alot bigger than the other, more nodes
      is needed in the bigger one */
   if( curve->order == 2 )
   {
      div = (IGRint)(avgdist / ((avgu+avgv)/2)) ;
      if( div > 5  && curve->num_poles < 50)
      {
         top = div / 2;
         top = MIN(top, 5);
         insert1 += top;
      }
   }

   if( surf->u_order == 2 )
   {
      div = (IGRint)(avgu / avgdist);
      if( div > 5  &&  surf->u_num_poles < 50)
      {
         top = div / 2;
         top = MIN(top, 5);
         insert2 += top;
      }
   }
   if( surf->v_order == 2 )
   {
      div = (IGRint)(avgv / avgdist);
      if( div > 5  &&  surf->v_num_poles < 50)
      {
         top = div / 2;
         top = MIN(top, 5);
         insert3 += top;
      }
   }


   /*  Allocate space for ndvals arrays    */
   i = (curve->num_poles - 1) * (insert1 + 1 ) + 1;
   ndvals1 = (IGRdouble *)BSstackalloc((unsigned)( i *sizeof(IGRdouble)));
   if( !ndvals1 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }
   points1 = (IGRpoint *)BSstackalloc((unsigned)(3*i* sizeof(IGRdouble)));
   if( !points1 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }

   i = (surf->u_num_poles - 1) * (insert2 + 1 ) + 3;
   ndvals2 = (IGRdouble *)BSstackalloc((unsigned)(i * sizeof(IGRdouble)));
   if( !ndvals2 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }
   j = (surf->v_num_poles - 1) * (insert3 + 1 ) + 3;
   ndvals3 = (IGRdouble *)BSstackalloc((unsigned)( j *sizeof(IGRdouble)));
   if( !ndvals3 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }
   points2 = (IGRpoint *)BSstackalloc((unsigned)(3 * i * j *
                 sizeof(IGRdouble)));
   if( !points2 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }

   BScvnodpts(curve,insert1,&numvals1,ndvals1,(IGRdouble *)points1,rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   BSsfnodptsm(surf,insert2,insert3,&numvals2,&numvals3,ndvals2,ndvals3,
               &num_pts, (IGRdouble *)points2,rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }

   /* This is a kludge when the num_pts is bigger than 1,000,000 */

   if (numvals1 * num_pts > 10000000)
   {
	    *dist = MAXDOUBLE;
		for (i = 0; i < numvals1; ++i)
		{
			BSmdptbssf(surf,1,points1[i],dist_tol,*dist,
                         &mdist,uvmin,ptmin,rc);
            if (BSERROR(*rc))
				goto wrapup;
            if (mdist < *dist)
            {
                *dist = mdist;
				(*part)[0] = ndvals1[i];
                (*paruv)[0] = uvmin[0];
                (*paruv)[1] = uvmin[1];
                for (nd = 0; nd < 3; ++nd)
                {
                  (*cpt)[0][nd] = points1[i][nd];            
                  (*sfpt)[0][nd] = ptmin[nd];
                }
				*num = 1;
                if (*dist < dist_tol)
                  goto wrapup;
			}
		}
	}	
    else
    {
		BSmdstptarr(numvals1,points1,num_pts,points2,&ind1,&ind2,dist,rc);
		if(BSERROR(*rc))
		{
			goto wrapup;
		}
		ind3 = ind2 % numvals2;  /* u index  */
		ind2 = ind2/numvals2;   /* vindex  */

		/* set the parameters and points of the two points closest together  */

		(*part)[0] = ndvals1[ind1];
		(*paruv)[0] = ndvals2[ind3];
		(*paruv)[1] = ndvals3[ind2];
		for(i=0; i< 3; i++)
		{
			(*cpt)[0][i] = points1[ind1][i];
			(*sfpt)[0][i] = points2[ind2 * numvals2 + ind3][i];
		}
		if (*dist < dist_tol )
		{
			*num = 1;
			goto wrapup;
		}
   }



   if(!curve->rational)
   {
      curve->weights = NULL;
   }
   BScvkttol2(curve->order, curve->knots, curve->num_poles,curve->poles,
            curve->weights,&cvknot_tol,rc);
   if(BSERROR(*rc))
      goto wrapup;

   mulp1 = FALSE;
   if( curve->num_poles > curve->order )
   {
      tmul = (IGRdouble  *)BSstackalloc((unsigned)((curve->num_poles - 
                              curve->order +1) * sizeof(IGRdouble )));
      if(!tmul)
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }

      /* find out if the parameters found are on knots of multiplicity order -1  */
 
      BSfndcvcsp(curve,&max,tmul,rc);
      if(BSERROR(*rc))
      {
         goto wrapup;
      }
      for(i=0; i< max; i++)
      {
         if(fabs((*part)[0] - tmul[i]) < cvknot_tol)
         {
            mulp1 = TRUE;
            break;
         }
      }   
   }
   mulp2 = FALSE;
   mulp3 = FALSE;
   if(!surf->rational)
   {
      surf->weights = NULL;
   }
   BSsfkttol2(surf->u_order,surf->v_order,surf->u_knots,surf->v_knots,
              surf->u_num_poles,surf->v_num_poles,surf->poles,surf->weights,
              &sfknot_tol,rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   if( surf->u_num_poles > surf->u_order ||
       surf->v_num_poles > surf->v_order)
   {
      umul = (IGRdouble  *)BSstackalloc((unsigned)((surf->u_num_poles - 
                      surf->u_order +1 ) * sizeof(IGRdouble )));
      if(!umul)
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      vmul = (IGRdouble  *)BSstackalloc((unsigned)((surf->v_num_poles -
                           surf->v_order +1 )* sizeof(IGRdouble )));
      if(!vmul)
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      BSfndsfcsp(surf,&numu,umul,&numv,vmul,rc);
      if(BSERROR(*rc))
      {
         goto wrapup;
      }
      for(i=0; i< numu ; i++)
      {
         if(fabs((*paruv)[0] - umul[i]) < sfknot_tol)
         {
            mulp2 = TRUE;
            break;
         }
      }   
      for(i=0; i< numv ; i++)
      {
         if(fabs((*paruv)[1] - vmul[i]) < sfknot_tol)
         {
            mulp3 = TRUE;
            break;
         }
      }   
   }

   if( !curve->phy_closed && !mulp1 )
   {
      if( fabs((*part)[0] - curve->knots[curve->order -1]) < cvknot_tol ||
          fabs((*part)[0] - curve->knots[curve->num_poles]) < cvknot_tol )
      {
         mulp1 = TRUE;
      }
   }
   if( !surf->u_phy_closed && !mulp2 )
   {
      if( fabs((*paruv)[0] - surf->u_knots[surf->u_order -1]) < sfknot_tol ||
          fabs((*paruv)[0] - surf->u_knots[surf->u_num_poles]) < sfknot_tol )
      {
         mulp2 = TRUE;
      }
   }
   if( !surf->v_phy_closed && !mulp3 )
   {
      if( fabs((*paruv)[1] - surf->v_knots[surf->v_order -1]) < sfknot_tol ||
          fabs((*paruv)[1] - surf->v_knots[surf->v_num_poles]) < sfknot_tol )
      {
         mulp3 = TRUE;
      }
   }
   BStstsfdegn(surf,&udeg,&unp,&vdeg,&vnp,rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }

   if( mulp2)
   {
      if( udeg && (*paruv)[0] == surf->u_knots[surf->u_order -1] )
      {
         mulp2 = FALSE;
      }
      else
      {
         if( unp && (*paruv)[0] == surf->u_knots[surf->u_num_poles] )
         {
            mulp2 = FALSE;
         }
      }
   }
   if( mulp3)
   {
      if( vdeg && (*paruv)[1] == surf->v_knots[surf->v_order -1] )
      {
         mulp3 = FALSE;
      }
      else
      {
         if( vnp && (*paruv)[1] == surf->v_knots[surf->v_num_poles] )
         {
            mulp3 = FALSE;
         }
      }
   }


   if(!mulp1 && !mulp2 && !mulp3 )
   {

      /* not on any knots of multiplicity order -1  */
      /* see if there is a line normal between the curve and surface  */

      line1.poles = &pole1[0][0];
      line1.knots = &knot1[0];
      line1.weights = NULL;
      line1.bdrys = NULL;

      BSlnnorcvsf(curve,(*part)[0],surf,(*paruv)[0],(*paruv)[1],
                  &p1,&p2,&p3,&line1,rc);
      if(BSERROR(*rc))
      {
         if( *rc == BSNOSOLUTION  || *rc == BSFAIL)
         {

            *rc = BSSUCC;


            /* find neigboring parameters of **part, *paruv[0] and *paruv[1]  */

            BSfndneighb((*part)[0],numvals1,ndvals1,ind1,cvknot_tol,
                        curve->phy_closed,neig1,rc);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }

/* Replace these code by sampling points on curve and find
   minimum distance from these points to surface 

            BSfndneighb((*paruv)[0],numvals2,ndvals2,ind3,sfknot_tol,
                        surf->u_phy_closed,neig2,rc);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            BSfndneighb((*paruv)[1],numvals3,ndvals3,ind2,sfknot_tol,
                        surf->v_phy_closed,neig3,rc);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }

            BSmdstcsgtc(curve,surf,neig1,neig2,neig3,cvknot_tol,sfknot_tol,
                        &(*part)[0],&(*paruv)[0],&(*paruv)[1],(*cpt)[0],
                        (*sfpt)[0],dist,rc);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
*/

            num_pars = 11;
            helperBSmdistcvsf(curve->knots,curve->order,curve->num_poles,
                 curve->phy_closed,neig1,num_pars,cvknot_tol,&stop,pars1,rc);
            if(BSERROR(*rc))
              goto wrapup;

            BScvarreval(rc,curve,pars1,stop,num_derv,points);
            if(BSERROR(*rc))
              goto wrapup;

            for (i = 0; i < 11; ++i)
            {
              BSmdptbssf(surf,1,&points[3 * i],dist_tol,*dist,
                         &mdist,uvmin,ptmin,rc);
              if (BSERROR(*rc))
                goto wrapup;
              if (mdist < *dist)
              {
                *num = 1;
                *dist = mdist;
		(*part)[0] = pars1[i];
                (*paruv)[0] = uvmin[0];
                (*paruv)[1] = uvmin[1];
                for (nd = 0; nd < 3; ++nd)
                {
                  (*cpt)[0][nd] = points[3 * i + nd];            
                  (*sfpt)[0][nd] = ptmin[nd];
                }
                if (*dist < dist_tol)
                  goto wrapup;
             }
           }
         }
      }
      else
      {
         dist1 = BSdistptpt(rc,&line1.poles[0],&line1.poles[3]);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         if( dist1 < *dist)
         {
            *dist = dist1;
            (*part)[0] = p1;
            (*paruv)[0] = p2;
            (*paruv)[1] = p3;
            for(i=0; i<3; i++) 
            {
               (*cpt)[0][i] = line1.poles[i];
               (*sfpt)[0][i] = line1.poles[i+3];
            }
            *num = 1;
         }
         else
         {
            *num = 1;
         }
      }
   }
   else
   {
      if( mulp1 && !mulp2 && !mulp3 )
      {
         BSptnorpch((*cpt)[0],surf,(*paruv),&num_pts,&dist1,&p2,&p3,bpoint,
                    rc);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
         if( num_pts > 0 )
         {
            if( dist1 < *dist )
            {
               *dist = dist1;
               (*paruv)[0] = p2;
               (*paruv)[1] = p3;
               for(i=0; i<3; i++)
               {
                  (*sfpt)[0][i] = bpoint[i];
               }
               *num = 1;
            }
            else
            {
               *num = 1;
            }
         }
         else
         {
            *num = 1;
         }
      }
      else
      {
         if(  (mulp2 && !mulp3) || (!mulp2 && mulp3 ) )
         {
            num_pts = MAX(surf->u_num_poles, surf->v_num_poles);
            num_kts = MAX(surf->u_num_knots, surf->v_num_knots);
            BSstkallocv(rc,cv,num_pts,surf->rational,num_kts,NULL);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            tst_plan = FALSE;
            if(mulp2 )
            {

               /* extract the u curve */

               opt = 1;
               (void)BSconstprcv(rc,surf,&opt,&(*paruv)[0],&tst_plan,cv);
               if(BSERROR(*rc))
               {
                  goto wrapup;
               }
               if( mulp1 )
               {
           
                  /* if *cpt is a cusp point(or endpoint), then just find 
                     minimum distance from point to extracted u curve */

                  BSmdstptcv(cv,(*cpt)[0],&(*paruv)[1],(*sfpt)[0],dist,rc);
                  if(BSOKAY(*rc))
                  {
                     *num = 1;
                  }
               }
               else
               {

                  /* mulp1 = FALSE  */

                  line1.poles = &pole1[0][0];
                  line1.knots = &knot1[0];
                  line1.weights = NULL;
                  line1.bdrys = NULL;

                  (void)BSlnn2cvs(rc,curve,cv,(*cpt)[0],(*sfpt)[0],&line1,&p1,&p3);
                  if(BSERROR(*rc))
                  {
                     if( *rc == BSNOSOLUTION || *rc == BSFAIL)
                     {

                        /* since BSlnn2cvs could not find a solution, then 
                           find a neighborhood around each parameter and
                           look for minimum distance  */

                        *num = 1;
                        *rc = BSSUCC;

                        BSfndneighb((*part)[0],numvals1,ndvals1,ind1,cvknot_tol,
                                     curve->phy_closed,neig1,rc);
                        if(BSERROR(*rc))
                        {
                           goto wrapup;
                        }
                        BSfndneighb((*paruv)[1],numvals3,ndvals3,ind2,
                                    sfknot_tol,cv->phy_closed,neig2,rc);
                        if(BSERROR(*rc))
                        {
                           goto wrapup;
                        }
 
                        BSmdstccgtc(curve,cv,neig1,neig2,cvknot_tol,sfknot_tol,
                                    &(*part)[0],&(*paruv)[1],(*cpt)[0],
                                    (*sfpt)[0],dist,rc);
                        if(BSERROR(*rc))
                        {
                           goto wrapup;
                        }
                        *num =1 ;
                     }
                  }
                  else
                  {

                     /* BSlnn2cvs found a normal line, so find it's distance
                        and if distance is less than previous found distance,
                        update output  */

                     dist1 =  BSdistptpt(rc,&line1.poles[0],&line1.poles[3]);
                     if(BSERROR(*rc))
                     {
                        goto wrapup;
                     }
                     if(dist1 < *dist )
                     {
                        *dist = dist1;
                        *num = 1;             
                        for(i=0; i<3;i++)
                        {
                           (*cpt)[0][i] = line1.poles[i];
                           (*sfpt)[0][i] = line1.poles[i+3];
                        }
                        (*part)[0] = p1;
                        (*paruv)[1] = p3;
                     }
                     else
                     {

                        /* else previous distance was closer, so exit with
                           output */

                        *num = 1;
                     }
                  }
               }
            }
            else
            {

               /* mulp2 = FALSE, so mulp3 = TRUE  */
               /* find v curve on surface */

               opt = 2;
               (void)BSconstprcv(rc,surf,&opt,&(*paruv)[1],&tst_plan,cv);
               if(BSERROR(*rc))
               {
                  goto wrapup;
               }
               if( mulp1)
               {

                  /* since *cpt was a cusp point(or endpoint), then 
                     just find minimum distance from *cpt to v curve */

                  BSmdstptcv(cv,(*cpt)[0],&(*paruv)[0],(*sfpt)[0],dist,rc);
                  if(BSOKAY(*rc))
                  {
                     *num = 1;
                  }
               }
               else
               {

                  line1.poles = &pole1[0][0];
                  line1.knots = &knot1[0];
                  line1.weights = NULL;
                  line1.bdrys = NULL;

                  (void)BSlnn2cvs(rc,curve,cv,(*cpt)[0],(*sfpt)[0],&line1,&p1,&p2);
                  if(BSERROR(*rc))
                  {
                     if( *rc == BSNOSOLUTION || *rc == BSFAIL)
                     {

                        /* since BSlnn2cvs could not find a solution, then 
                           find a neighborhood around each parameter and
                           look for minimum distance  */
                     
                        *num = 1;
                        *rc = BSSUCC;

                        BSfndneighb((*part)[0],numvals1,ndvals1,ind1,cvknot_tol,
                                   curve->phy_closed,neig1,rc);
                        if(BSERROR(*rc))
                        {
                           goto wrapup;
                        }

                        BSfndneighb((*paruv)[0],numvals2,ndvals2,ind3,
                                    sfknot_tol,cv->phy_closed,neig2,rc);
                        if(BSERROR(*rc))
                        {
                           goto wrapup;
                        }
                        BSmdstccgtc(curve,cv,neig1,neig2,cvknot_tol,sfknot_tol,
                                    &(*part)[0],&(*paruv)[0],(*cpt)[0],
                                    (*sfpt)[0],dist,rc);
                        if(BSERROR(*rc))
                        {
                           goto wrapup;
                        }
                        *num =1 ;
                     }
                  }
                  else
                  {

                     /* BSlnn2cvs found a normal line, so find it's distance
                        and if distance is less than previous found distance,
                        update output  */

                     dist1 =  BSdistptpt(rc,&line1.poles[0],&line1.poles[3]);
                     if(BSERROR(*rc))
                     {
                        goto wrapup;
                     }
                     if(dist1 < *dist )
                     {
                        *dist = dist1;
                        *num = 1;             
                        for(i=0; i<3;i++)
                        {
                           (*cpt)[0][i] = line1.poles[i];
                           (*sfpt)[0][i] = line1.poles[i+3];
                        }
                        (*part)[0] = p1;
                        (*paruv)[0] = p2;
                     }
                     else
                     {
                        /* output data already found */
                        *num = 1;
                     }
                  }
               }
            }
         }
         else
         {
            if( !mulp1 && mulp2 && mulp3 )
            {
               BSmdstptcv(curve,(*sfpt)[0],&(*part)[0],(*cpt)[0],dist,rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }
            else
            {

               /* output data already found */
               *num = 1;
            }
         }
      }
   }

   wrapup:
   if( cv)
   {
      BSstkfreecv(rc,cv);
   }
   if( vmul)
   {
      BSstackdealloc((char*)vmul);
   }
   if( umul)
   {
      BSstackdealloc((char *)umul);
   }
   if(tmul)
   {
      BSstackdealloc((char *)tmul);
   }
   if(points2)
   {
      BSstackdealloc((char *)points2);
   }
   if(points1)
   {
      BSstackdealloc((char *)points1);
   }
   if(ndvals3)
   {
      BSstackdealloc((char *)ndvals3);
   }
   if(ndvals2)
   {
      BSstackdealloc((char *)ndvals2);
   }
   if(ndvals1)
   {
      BSstackdealloc((char *)ndvals1);
   }

   /* Free intersection and overlap solution returned from BScvsfintrg */

   if (num_int > 0)
   {
	   if (xpoints2)
		   BSdealloc((char *) xpoints2);
	   if (par2)
		   BSdealloc((char *) par2);
	   if (uvpar2)
		   BSdealloc((char *) uvpar2);
   }
   if (nover > 0)
   {
	   if (overpts2)
		   BSdealloc((char *) overpts2);
	   if (tover2)
		   BSdealloc((char *) tover2);
	   if (uvover2)
		   BSdealloc((char *) uvover2);
   }
  
   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSmdistcvsf");
   return;
   }
}
