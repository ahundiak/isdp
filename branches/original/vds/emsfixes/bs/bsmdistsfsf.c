/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSmdistsfsf

Abstract
    Find the minumum distance between a surface and a surface.

Synopsis
    void  BSmdistsfsf(surf1,surf2,num,paruv1,paruv2,sfpt1,sfpt2,dist,rc)

    struct IGRbsp_surface *surf1
    struct IGRbsp_surface *surf2
    IGRint                *num
    IGRdouble             **paruv1
    IGRdouble             **paruv2
    IGRpoint              **sfpt1
                          **sfpt2
    IGRdouble             *dist
    BSrc                  *rc

Description
    This routine inputs two surfaces.  It outputs the number of points
at minimum distance(num), the parameters(paruv1 and paruv2), the points 
on each surface(sfpt1 and sfpt2) and the minimum distance.

Return Values
    A return code BSSUCC is returned if everything was successful, and an
error return code is returned if an error occurrs.

Notes
    More than one point is output only if there is an intersection between the
surface and the surface and there are more than one intersection points.

Index
    md

Keywords

History
    S.G. Catron  11/25/86  : Creation date.
    S.G. Catron  06/01/87  : Changed call to BSsfkttol to BSsftktol2.
    S.G. Catron  06/25/87  : Rewrote to make more efficient.
    S.G. Catron  07/17/87  : Changed parameter in call to BSmdstssgtc.
                             (from (*paruv1)[1] to &(*paruv1)[1])
    C.S.SAMUELS  08/11/87  : Replace calls to BSsfnodpts with BSsfnodptsm.
    S.G. Catron  08/12/87  : Correct call to BSstkallocv.
    C.S.SAMUELS  09/11/87  : Replace call to BNsur_sur with BSsur_sur.
    S.G. Catron  06/09/89  : Changed the calculations of the insertion
                             values.  It was inserting too many values
                             for some cases.  Added special code for
                             order 2, and if the average pole distance
                             is less than a chord height tolerance.
    D. Breden    12/16/89  : Initialize boundaries in static curve.
    S.R. Meeth   10/10/90  : Fixed several incompatible operands in malloc.
    S.G. Catron  07/16/91  : After finding results from BSlnnorsfsf, it
                             was not writing over dist with new dist.
    S.G. Catron  03/23/00  : VDS problems with plane/plane - mdistsfsf.d20,21.
                             It does not find the exact/best solution.  We
                             need special case code for plane/plane.  Now,
                             calling new routine BSmdistplpl.
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
#endif
#include <math.h>
#define  BSVOID

void  BSmdistsfsf(
struct IGRbsp_surface *surf1,
struct IGRbsp_surface *surf2,
IGRint                *num,
IGRdouble             **paruv1,
IGRdouble             **paruv2,
IGRpoint              **sfpt1,
IGRpoint              **sfpt2,
IGRdouble             *dist,
BSrc                  *rc )
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsdistptpt.h"
#include "bssfnodptsm.h"
#include "bsssprcsoed.h"
#include "bslnnorcvsf.h"
#include "bsfndneighb.h"
#include "bsmdstptcv.h"
#include "bsmdstptarr.h"
#include "bsmdstssgtc.h"
#include "bssfkttol2.h"
#include "bsmsfsf1.h"
#include "bsmsfsf2.h"
#include "bsptnorpch.h"
#include "bslnnorsfsf.h"
#include "bssur_sur.h"
#include "bsconstprcv.h"
#include "bsavgdisarr.h"
#include "bsmdistplpl.h"
#endif 


   IGRdouble dist1,*ndvals1=NULL,*ndvals2=NULL,
             *ndvals3=NULL,*ndvals4=NULL,
             p1,p2,p3,p4, avgu1, avgv1,
             avgu2, avgv2,
             neig1[2],neig2[2],neig3[2],neig4[2],
             sfknot_tol1,sfknot_tol2,
             knots[4],chrdht_tol,dist_tol,
             planeuv1[2][2], planeuv2[2][2];
   IGRint    insert,ind1,ind2,ind3,ind4,
             insert1,insert2,insert3,
             insert4,numvals1,numvals2,
             numvals3,numvals4,i,j,k,
             numgrps,*num_pts,num_pts1,num_pts2;
   IGRshort  opt;
   IGRpoint  *points1=NULL,*points2=NULL,
             **pts,poles[2], planepts1[2], planepts2[2];
   BSpair    **par1,**par2;
   struct IGRbsp_curve line1,*cv=NULL;
   IGRboolean tst_plan=FALSE,mulp1,mulp2,mulp3,
              mulp4;
 
   *rc = BSSUCC;
   *num = 0;

   if( surf1->u_num_poles == 2 && surf1->v_num_poles == 2 && surf1->planar &&
       surf2->u_num_poles == 2 && surf2->v_num_poles == 2 && surf2->planar )
   {
      BSmdistplpl(surf1, surf2, num, planeuv1,planeuv2, planepts1, planepts2, dist, rc );
      if(BSERROR(*rc))
         goto wrapup;
      *sfpt1 = (IGRpoint *)BSmalloc((unsigned)(*num*sizeof(IGRpoint )));
      if(!sfpt1)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *sfpt2 = (IGRpoint *)BSmalloc((unsigned)(*num*sizeof(IGRpoint )));
      if(!sfpt2)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *paruv1 = (IGRdouble *)BSmalloc((unsigned)( *num * 2 * 
                                   sizeof(IGRdouble)));
      if(!paruv1)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *paruv2 = (IGRdouble *)BSmalloc((unsigned)(*num * 2 * 
                                               sizeof(IGRdouble)));
      if(!paruv2)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }

      for(i=0; i< *num; i++)
      {
         for(k=0; k<3; k++)
         {
            (*sfpt1)[i][k] = planepts1[i][k];
            (*sfpt2)[i][k] = planepts2[i][k];
         }
         (*paruv1)[i *2] = planeuv1[i][0];
         (*paruv1)[i *2+1] = planeuv1[i][1];
         (*paruv2)[i *2] = planeuv2[i][0];
         (*paruv2)[i *2+1] = planeuv2[i][1];
      }
      goto wrapup;
   }         
   BSEXTRACTPAR(rc,BSTOLCHRDHT,chrdht_tol);

   BSEXTRACTPAR(rc,BSTOLLENVEC,dist_tol);

   /* first call routine, to see if surfaces intersect, which 
      will be the points at minimum distance  */

   (void)BSsur_sur(rc,surf1,surf2,&chrdht_tol,&dist_tol,&numgrps,&num_pts,&pts,
                   &par1,&par2);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   if( numgrps > 0 )
   {
      *sfpt1 = (IGRpoint *)BSmalloc((unsigned)(2*numgrps*sizeof(IGRpoint )));
      if(!sfpt1)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *sfpt2 = (IGRpoint *)BSmalloc((unsigned)(2*numgrps*sizeof(IGRpoint )));
      if(!sfpt2)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *paruv1 = (IGRdouble *)BSmalloc((unsigned)( numgrps * 4 * 
                                   sizeof(IGRdouble)));
      if(!paruv1)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *paruv2 = (IGRdouble *)BSmalloc((unsigned)(numgrps * 4 * 
                                               sizeof(IGRdouble)));
      if(!paruv2)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
      *num = 0;
      for(i=0; i< numgrps; i++)
      {
         for(k=0; k<3; k++)
         {
            (*sfpt1)[*num][k] = pts[i][0][k];
            (*sfpt2)[*num][k] = pts[i][0][k];
            (*sfpt1)[*num+1][k] = pts[i][num_pts[i] -1][k];
            (*sfpt2)[*num+1][k] = pts[i][num_pts[i] -1][k];
         }
         (*paruv1)[*num *2] = par1[i][0][0];
         (*paruv1)[*num *2+1] = par1[i][0][1];
         (*paruv2)[*num *2] = par2[i][0][0];
         (*paruv2)[*num *2+1] = par2[i][0][1];
         *num += 1;
         (*paruv1)[*num *2] = par1[i][num_pts[i] -1][0];
         (*paruv1)[*num *2+1] = par1[i][num_pts[i] -1][1];
         (*paruv2)[*num *2] = par2[i][num_pts[i] -1][0];
         (*paruv2)[*num *2+1] = par2[i][num_pts[i] -1][1];
         *num +=1 ;
      }

      if (num_pts)
      {
         BSdealloc((char *)num_pts);
      }
      if (pts)
      {
         for (i=0;i < numgrps;i++)
         {
            if (pts[i])
            {
               BSdealloc((char *)pts[i]);
            }
         }
         BSdealloc((char *)pts);
      }
      if (par1)
      {
         for (i=0;i < numgrps;i++)
         {
            if (par1[i])
            {
               BSdealloc((char *)par1[i]);
            }
         }
         BSdealloc((char *)par1);
      }
      if (par2)
      {
         for (i=0;i < numgrps;i++)
         {
            if (par2[i])
            {
               BSdealloc((char *)par2[i]);
            }
         }
         BSdealloc((char *)par2);
      }
      *dist = 0;
      goto wrapup;
   }      

   /*  if no intersection points, then there is only one output point  */

   *sfpt1 = (IGRpoint *)BSmalloc((unsigned)( 1 * sizeof(IGRpoint )));
   if(!sfpt1)
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }
   *sfpt2 = (IGRpoint *)BSmalloc((unsigned)( 1 * sizeof(IGRpoint )));
   if(!sfpt2)
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }
   *paruv1 = (IGRdouble *)BSmalloc((unsigned)(  2 * sizeof(IGRdouble)));
   if(!paruv1)
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }
   *paruv2 = (IGRdouble *)BSmalloc((unsigned)(  2 * sizeof(IGRdouble)));
   if(!paruv2)
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }

   /*  make up a net of points for the surfaces, and find the two 
       points closest together   */

   insert = 2;
   ind1 = ( surf1->u_num_poles + surf1->u_order - 1 ) * ( insert + 1 );
   ind2 = ( surf1->v_num_poles + surf1->v_order - 1 ) * ( insert + 1 );
   ind3 = ( surf2->u_num_poles + surf2->u_order - 1 ) * ( insert + 1 );
   ind4 = ( surf2->v_num_poles + surf2->v_order - 1 ) * ( insert + 1 );
   i = MAX(ind1,ind2);
   i = MAX(i,ind3);
   i = MAX(i,ind4);
   if( ind1 == i )
   {
     insert1 = 2;
   }
   else
   {
      insert1 = i / ( surf1->u_num_poles + surf1->u_order - 1 ) - 1;
   }
   if( ind2 == i )
   {
     insert2 = 2;
   }
   else
   {
      insert2 = i / ( surf1->v_num_poles + surf1->v_order - 1 ) - 1;
   }
   if( ind3 == i )
   {
      insert3 = 2;
   }
   else
   {
      insert3 = i / ( surf2->u_num_poles + surf2->u_order - 1 ) - 1;
   }
   if( ind4 == i )
   {
      insert4 = 2;
   }
   else
   {
      insert4 = i / ( surf2->v_num_poles + surf2->v_order - 1 ) - 1;
   }
   if( surf1->u_order == 2 )
   {
      insert1 = MIN(insert1, 5 );
   }
   if( surf1->v_order == 2 )
   {
      insert2 = MIN(insert2, 5 );
   }
   if( surf2->u_order == 2 )
   {
      insert3 = MIN(insert3, 5 );
   }
   if( surf2->v_order == 2 )
   {
      insert4 = MIN(insert4, 5 );
   }
   BSavgdisarr(surf1->u_num_poles, surf1->v_num_poles, (IGRpoint *)surf1->poles,
               surf1->weights, &avgu1, &avgv1, rc);
   if(BSERROR(*rc))
      goto wrapup;

   BSavgdisarr(surf2->u_num_poles, surf2->v_num_poles, (IGRpoint *)surf2->poles,
               surf2->weights, &avgu2, &avgv2, rc);
   if(BSERROR(*rc))
      goto wrapup;

   BSEXTRACTPAR(rc,BSTOLCHRDHT,chrdht_tol);

   if( avgu1 < 100 * chrdht_tol )
   {
      if( avgu1 < 10 * chrdht_tol )
         insert1 = 0;
      else
         insert1 = 1;
   }
   if( avgv1 < 100 * chrdht_tol )
   {
      if( avgv1 < 10 * chrdht_tol )
         insert2 = 0;
      else
         insert2 = 1;
   }
   if( avgu2 < 100 * chrdht_tol )
   {
      if( avgu2 < 10 * chrdht_tol )
         insert3 = 0;
      else
         insert3 = 1;
   }
   if( avgv2 < 100 * chrdht_tol )
   {
      if( avgv2 < 10 * chrdht_tol )
         insert4 = 0;
      else
         insert4 = 1;
   }

   /*  Allocate space for ndvals arrays  */

   i = (surf1->u_num_poles - 1) * (insert1 + 1 ) + 3;
   ndvals1 = (IGRdouble *)BSstackalloc((unsigned)( i * sizeof(IGRdouble)));
   if( !ndvals1 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }
   j = (surf1->v_num_poles - 1) * (insert2 + 1 ) + 3;
   ndvals2 = (IGRdouble *)BSstackalloc((unsigned)( j * sizeof(IGRdouble)));
   if( !ndvals2 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }
   points1 = (IGRpoint *)BSstackalloc((unsigned)(3*i*j*sizeof(IGRdouble)));
   if( !points1 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }

   i = (surf2->u_num_poles - 1) * (insert3 + 1 ) + 3;
   ndvals3 = (IGRdouble *)BSstackalloc((unsigned)( i * sizeof(IGRdouble)));
   if( !ndvals3 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }
   j = (surf2->v_num_poles - 1) * (insert4 + 1 ) + 3;
   ndvals4 = (IGRdouble *)BSstackalloc((unsigned)( j * sizeof(IGRdouble)));
   if( !ndvals4 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }
   points2 = (IGRpoint *)BSstackalloc((unsigned)(3*i*j*sizeof(IGRdouble)));
   if( !points2 )
   {
      *rc = BSNOSTKMEMORY;
      goto wrapup;
   }

   BSsfnodptsm(surf1,insert1,insert2,&numvals1,&numvals2,ndvals1,ndvals2,
               &num_pts1,(IGRdouble *)points1,rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   BSsfnodptsm(surf2,insert3,insert4,&numvals3,&numvals4,ndvals3,ndvals4,
               &num_pts2,(IGRdouble *)points2,rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   BSmdstptarr(num_pts1,points1,num_pts2,points2,&ind1,&ind3,dist,rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   ind2 = ind1/ numvals1;
   ind1 = ind1 % numvals1;
   ind4 = ind3 / numvals3;   
   ind3 = ind3 % numvals3;

   /* set the parameters and points of the two points closest together   */

   (*paruv1)[0] = ndvals1[ind1];
   (*paruv1)[1] = ndvals2[ind2];
   (*paruv2)[0] = ndvals3[ind3];
   (*paruv2)[1] = ndvals4[ind4];
   for(i=0; i< 3; i++)
   {
      (*sfpt1)[0][i] = points1[ind2 * numvals1 + ind1][i];
      (*sfpt2)[0][i] = points2[ind4 * numvals3 + ind3][i];
   }

   BSssprcsoed(surf1,surf2,(*paruv1),(*paruv2),&mulp1,&mulp2,&mulp3,&mulp4,rc);
   if(BSERROR(*rc))
   {
      goto wrapup;
   }
   if(!mulp1  )
   {
      if( !mulp2 )
      {
         if(!mulp3)
         {
            if(!mulp4 )
            {

               /* see if there is a line normal between surface and surface  */
      
               line1.poles = &poles[0][0];
               line1.knots = &knots[0];
               line1.weights = NULL;
               line1.bdrys = NULL;
               BSlnnorsfsf(surf1,(*paruv1)[0],(*paruv1)[1],surf2,(*paruv2)[0],
                           (*paruv2)[1],&p1,&p2,&p3,&p4,&line1,rc);
               if(BSERROR(*rc))
               {
                  if( *rc == BSNOSOLUTION || *rc == BSFAIL)
                  {
                     *rc = BSSUCC;
                     BSsfkttol2(surf1->u_order,surf1->v_order,surf1->u_knots,
                                surf1->v_knots,surf1->u_num_poles,
                                surf1->v_num_poles,surf1->poles,surf1->weights,
                                &sfknot_tol1,rc);
                     if(BSERROR(*rc))
                     {
                        goto wrapup;
                     }
                     BSsfkttol2(surf2->u_order,surf2->v_order,surf2->u_knots,
                                surf2->v_knots,surf2->u_num_poles,
                                surf2->v_num_poles,surf2->poles,surf2->weights,
                                &sfknot_tol2,rc);
                     if(BSERROR(*rc))
                     {
                        goto wrapup;
                     }
                     BSfndneighb((*paruv1)[0],numvals1,ndvals1,ind1,sfknot_tol1,
                                  surf1->u_phy_closed,neig1,rc);
                     if(BSERROR(*rc))
                     {
                        goto wrapup;
                     }
                     BSfndneighb((*paruv1)[1],numvals2,ndvals2,ind2,sfknot_tol1,
                                  surf1->v_phy_closed,neig2,rc);
                     if(BSERROR(*rc))
                     {
                        goto wrapup;
                     }
                     BSfndneighb((*paruv2)[0],numvals3,ndvals3,ind3,sfknot_tol2,
                                  surf2->u_phy_closed,neig3,rc);
                     if(BSERROR(*rc))
                     {
                        goto wrapup;
                     }
                     BSfndneighb((*paruv2)[1],numvals4,ndvals4,ind4,sfknot_tol2,
                                  surf2->v_phy_closed,neig4,rc);
                     if(BSERROR(*rc))
                     {
                        goto wrapup;
                     }
 
                     BSmdstssgtc(surf1,surf2,neig1,neig2,neig3,neig4,
                                 sfknot_tol1,sfknot_tol2,&(*paruv1)[0], 
                                 &(*paruv1)[1],&(*paruv2)[0],&(*paruv2)[1],
                                 (*sfpt1)[0],(*sfpt2)[0],dist,rc);
                     if(BSOKAY(*rc))
                     {
                        *num = 1;
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
                  if( dist1 < *dist )
                  {
                     (*paruv1)[0] = p1;
                     (*paruv1)[1] = p2;
                     (*paruv2)[0] = p3;
                     (*paruv2)[1] = p4;
                     for(i=0; i< 3 ; i++)
                     {
                        (*sfpt1)[0][i] = line1.poles[i];
                        (*sfpt2)[0][i] = line1.poles[3+i];
                     }
                     *dist = dist1;
                     *num = 1;
                  }
                  else
                  {
                     *num = 1;
                  }
               }
            }
            else
            {           /* !mulp1, !mulp2, !mulp3 and mulp4 */

               opt = 2;               
               BSmsfsf1(surf2,surf1,opt,numvals3,ndvals3,ind3,numvals1,ndvals1,
                        ind1,numvals2,ndvals2,ind2,(*paruv2),(*paruv1),
                        (*sfpt2)[0],(*sfpt1)[0],dist,rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }
         }
         else
         {     /* mulp3 = TRUE */

            if(!mulp4 )
            {

               /* !mulp1, !mulp2, mulp3, and !mulp4 */

               opt = 1;               
               BSmsfsf1(surf2,surf1,opt,numvals4,ndvals4,ind4,numvals1,ndvals1,
                        ind1,numvals2,ndvals2,ind2,(*paruv2),(*paruv1),
                        (*sfpt2)[0],(*sfpt1)[0],dist,rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }
            else
            {               /* !mulp1, !mulp2, mulp3 and mulp4 */

               BSptnorpch((*sfpt2)[0],surf1,(*paruv1),num,dist,&(*paruv1)[0],
                          &(*paruv1)[1],(*sfpt1)[0],rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }
         }
      }
      else
      {

         /* mulp2 = TRUE   extract the v curve */

         opt = 2;
         if(mulp3 || mulp4  )
         {
            BSstkallocv(rc,cv,surf1->u_num_poles,surf1->rational,
                        surf1->u_num_knots,NULL);
            if(BSERROR(*rc))
            {
                goto wrapup;
            }
            (void)BSconstprcv(rc,surf1,&opt,&(*paruv1)[1],&tst_plan,cv);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
         if(!mulp3 )
         {
            if(!mulp4 )
            {

               /* !mulp1, mulp2, !mulp3, and !mulp4 */
            
               BSmsfsf1(surf1,surf2,opt,numvals1,ndvals1,ind1,numvals3,ndvals3,
                        ind3,numvals4,ndvals4,ind4,(*paruv1),(*paruv2),
                        (*sfpt1)[0],(*sfpt2)[0],dist,rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }
            else
            {     /* !mulp1, mulp2, !mulp3 and mulp4 */


               opt = 2;               
               BSmsfsf2(cv,surf2,opt,numvals1,ndvals1,ind1,numvals3,ndvals3,
                        ind3,&(*paruv1)[0],(*paruv2),(*sfpt1)[0],(*sfpt2)[0],
                        dist,rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }
         }
         else
         {      /* mulp3 = TRUE  */

            if(!mulp4 )
            {

               /* !mulp1, mulp2, mulp3, !mulp4 */

               opt = 1; 
               BSmsfsf2(cv,surf2,opt,numvals1,ndvals1,ind1,numvals4,ndvals4,
                        ind4,&(*paruv1)[0],(*paruv2),(*sfpt1)[0],(*sfpt2)[0],
                        dist,rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }
            else
            {     /* !mulp1, mulp2, mulp3 and mulp4  */

               BSmdstptcv(cv,(*sfpt2)[0],&(*paruv1)[0],(*sfpt1)[0],dist,rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }
         }
      }
   }
   else
   {      /* mulp1 = TRUE  */
      if(  !mulp2  )
      {
         opt = 1;         
         if( mulp3 || mulp4 )
         {
            BSstkallocv(rc,cv,surf1->v_num_poles,surf1->rational,
                        surf1->v_num_knots,NULL);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
            (void)BSconstprcv(rc,surf1,&opt,&(*paruv1)[0],&tst_plan,cv);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
         if( !mulp3 )
         {
            if(!mulp4 )
            {

               /* mulp1, !mulp2, !mulp3, and !mulp4 */
              
               BSmsfsf1(surf1,surf2,opt,numvals2,ndvals2,ind2,numvals3,ndvals3,
                        ind3,numvals4,ndvals4,ind4,(*paruv1),(*paruv2),
                        (*sfpt1)[0],(*sfpt2)[0],dist,rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }
            else
            {      /* mulp1, !mulp2, !mulp3 and mulp4  */

               opt = 2;              
               BSmsfsf2(cv,surf2,opt,numvals2,ndvals2,ind2,numvals3,ndvals3,
                        ind3,&(*paruv1)[1],(*paruv2),(*sfpt1)[0],(*sfpt2)[0],
                        dist,rc);
               if(BSOKAY(*rc))
               {
                  *num =1 ;
               }
            }
         }
         else
         {
            if( !mulp4)
            {

               /* mulp1, !mulp2, mulp3,  !mulp4 */

               opt = 1;
               BSmsfsf2(cv,surf2,opt,numvals2,ndvals2,ind2,numvals4,ndvals4,
                        ind4,&(*paruv1)[1],(*paruv2),(*sfpt1)[0],(*sfpt2)[0],
                        dist,rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }
            else
            {   /* mulp1 , !mulp2, mulp3, mulp4  */
   
               BSmdstptcv(cv,(*sfpt2)[0],&(*paruv1)[1],(*sfpt1)[0],dist,rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }
         }
      }
      else 
      {   /* mulp2 = TRUE */
         if( !mulp3 )
         {
            if(!mulp4 )
            {

               /* mulp1 , mulp2 , !mulp3, !mulp4  */
               BSptnorpch((*sfpt1)[0],surf2,(*paruv2),num,dist,&(*paruv2)[0],
                          &(*paruv2)[1],(*sfpt2)[0],rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }                        
            else
            {    /* mulp1, mulp2, !mulp3, mulp4 */
   
               BSstkallocv(rc,cv,surf2->u_num_poles,surf2->rational,
                           surf2->u_num_knots,NULL);
               if(BSERROR(*rc))
               {
                  goto wrapup;
               }
               opt = 2;  /* extract surf2 v constant curve  */
               (void)BSconstprcv(rc,surf2,&opt,&(*paruv2)[1],&tst_plan,cv);
               if(BSERROR(*rc))
               {
                  goto wrapup;
               }
               BSmdstptcv(cv,(*sfpt1)[0],&(*paruv2)[0],(*sfpt2)[0],dist,rc);
               if(BSOKAY(*rc))
               {
                  *num =1 ;
               }
            }
         }
         else
         {
            if(!mulp4 )
            {
 
               /* mulp1, mulp2, mulp3 and  !mulp4 */
               BSstkallocv(rc,cv,surf2->v_num_poles,surf2->rational,
                           surf2->v_num_knots,NULL);
               if(BSERROR(*rc))
               {
                  goto wrapup;
               }
               opt = 1;               /* extract the u curve */
               (void)BSconstprcv(rc,surf2,&opt,&(*paruv2)[0],&tst_plan,
                                 cv);
               if(BSERROR(*rc))
               {
                  goto wrapup;
               }
               BSmdstptcv(cv,(*sfpt1)[0],&(*paruv2)[1],(*sfpt2)[0],dist,rc);
               if(BSOKAY(*rc))
               {
                  *num = 1;
               }
            }
            else
            {   /* mulp1, mulp2, mulp3, and mulp4  */
               *num =1 ;
            }
         }
      }
   }
   wrapup:

   if( cv)
   {
      BSstkfreecv(rc,cv);
   }
   if(points2)
   {
      BSstackdealloc((char *)points2);
   }

   if(ndvals4)
   {
      BSstackdealloc((char *)ndvals4);
   }
   if(ndvals3)
   {
      BSstackdealloc((char *)ndvals3);
   }
   if(points1)
   {
      BSstackdealloc((char *)points1);
   }
   if(ndvals2)
   {
      BSstackdealloc((char *)ndvals2);
   }
   if(ndvals1)
   {
      BSstackdealloc((char *)ndvals1);
   }
   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSmdistsfsf");
   return;
   }
}
