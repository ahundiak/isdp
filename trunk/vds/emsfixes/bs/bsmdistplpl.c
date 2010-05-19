/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSmdistplpl

Abstract
    Find the minumum distance between a plane and a plane.

Synopsis
    void  BSmdistplpl(plane1,plane2,num,planeuv1,planeuv2,planept1,planept2,dist,rc)

    struct IGRbsp_surface *plane1
    struct IGRbsp_surface *plane2
    IGRint                *num
    IGRdouble             planeuv1[2][2]
    IGRdouble             planeuv2[2][2]
    IGRpoint              planept1[2]
                          planept2[2]
    IGRdouble             *dist
    BSrc                  *rc

Description
    This routine inputs two planes.  It outputs the number of points
at minimum distance(num), the parameters(planeuv1 and planeuv2), the points 
on each surface(planept1 and planept2) and the minimum distance.

Return Values
    A return code BSSUCC is returned if everything was successful, and an
error return code is returned if an error occurrs.

Notes
    The number of minimum distanct points will usually be 1, unless there is an intersection
    with an overlap, then there will be 2.

Index
    md

Keywords

History
    S.G. Catron  03/15/00  : Creation date.
JJ Malosse 21 April 2000: Declared a long.
*****************************************************************************
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bserr.h"
#include "bsmalloc.h"
#include "bsparameters.h"
#endif
#include <math.h>
#define  BSVOID

static void ptBSmdistplpl(struct IGRbsp_surface *plane1, struct IGRbsp_surface *plane2,
                          IGRdouble *dist, IGRdouble planeuv1[2], IGRdouble planeuv2[2],
                          IGRpoint planept1, IGRpoint planept2, IGRpoint corners[5], BSpair cornerpars[5],
                          BSrc *rc )
{
#ifndef DONOTSPROTO
#include "bssfeval.h"
#include "bsmdarrptsf.h"
#endif 
   IGRboolean ret_uvs=TRUE,
              ret_pts=TRUE,
              ret_dist=TRUE,
              ret_all_on_surf=FALSE,
              all_on_surf;
   IGRpoint sf_pts[4];
   IGRint nd=0, ind, i, num=4;
   IGRdouble u, v, uu, vv, dist_tol, uvs[4][2],
             dists[4];

   
   *rc = BSSUCC;

   BSEXTRACTPAR(rc,BSTOLLENVEC,dist_tol);

   u = plane1->u_knots[plane1->u_order-1];
   v = plane1->v_knots[plane1->v_order-1];
   uu = plane1->u_knots[plane1->u_num_poles];
   vv = plane1->v_knots[plane1->v_num_poles];

   /* get the corners */
   cornerpars[0][0] = cornerpars[4][0] = u;
   cornerpars[0][1] = cornerpars[4][1] = v;
   if( plane1->rational)
   {
      for(i=0; i< 3; i++)
      {
         corners[0][i] = corners[4][i] = plane1->poles[i]/plane1->weights[0];
         corners[1][i] = plane1->poles[3+i]/plane1->weights[1];
         corners[2][i] = plane1->poles[9+i]/plane1->weights[3];
         corners[3][i] = plane1->poles[6+i]/plane1->weights[2];	          
      }
   }
   else
   {
      for(i=0; i< 3; i++)
      {
         corners[0][i] = corners[4][i] = plane1->poles[i];
         corners[1][i] = plane1->poles[3+i];
         corners[2][i] = plane1->poles[9+i];
         corners[3][i] = plane1->poles[6+i];
      }
   }   
   cornerpars[1][0] = uu;
   cornerpars[1][1] = v;
   cornerpars[2][0] = uu;
   cornerpars[2][1] = vv;
   cornerpars[3][0] = u;
   cornerpars[3][1] = vv;
   
   BSmdarrptsf(num, corners, plane2, dist_tol, ret_uvs, ret_pts, ret_dist,
              ret_all_on_surf, uvs, sf_pts, dists, &all_on_surf, rc);
   if(BSERROR(*rc))
      goto wrapup;
   
   ind = 0;
   for(i=0; i< 4; i++)
      if(dists[i] < dists[ind] )
         ind = i;

   /* if *dist == -1 , it means this is the first time */
   if( *dist < 0  || dists[ind] < *dist)
   {
      *dist = dists[ind];
      planeuv1[0] = cornerpars[ind][0];
      planeuv1[1] = cornerpars[ind][1];   
      planeuv2[0] = uvs[ind][0];
      planeuv2[1] = uvs[ind][1];   
      planept1[0] = corners[ind][0];
      planept1[1] = corners[ind][1];
      planept1[2] = corners[ind][2];
      planept2[0] = sf_pts[ind][0];
      planept2[1] = sf_pts[ind][1];
      planept2[2] = sf_pts[ind][2];
   }

   wrapup:
return;
}

   
void  BSmdistplpl(
struct IGRbsp_surface *plane1,
struct IGRbsp_surface *plane2,
IGRint                *num,
IGRdouble             planeuv1[2][2],
IGRdouble             planeuv2[2][2],
IGRpoint              planept1[2],
IGRpoint              planept2[2],
IGRdouble             *dist,
BSrc                  *rc )
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsplplintop.h"
#include "bsdlsegs2.h"
#include "bsbx2.h"
#include "bsbxint.h"
#endif 
   IGRpoint  corners1[5], corners2[5], pt1, pt2, *pts=NULL,
             min1, max1, min2, max2;
   IGRdouble  mindist, off=0.0, p1, p2, dist_tol;
   BSpair cornerpars1[5], cornerpars2[5];
   IGRboolean off_opt=FALSE, n1=FALSE, intersect;
   BSpair *par1=NULL, *par2=NULL;
   IGRint i,j,k, limit;
   IGRlong ibidon;
   *rc = BSSUCC;
   *num = 0;

   BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol );

   if( plane1->u_num_poles > 2 || plane1->v_num_poles > 2 || !plane1->planar ||
       plane2->u_num_poles > 2 || plane2->v_num_poles > 2 || !plane2->planar )
   {
      *rc = BSINARG;
      goto wrapup;
   }       
   /* first call routine, to see if plane boxes intersect */
   ibidon=4;
   (void)BSbx2( rc, &ibidon, (IGRpoint *) plane1->poles, plane1->weights, min1,
                max1 );
   if (BSERROR(*rc))
     goto wrapup;
   (void)BSbx2( rc, &ibidon, (IGRpoint *) plane2->poles, plane2->weights, min2,
                max2 );
   if (BSERROR(*rc))
     goto wrapup;
   intersect = BSbxint(rc, min1, max1, min2, max2 );
   if (BSERROR(*rc))
     goto wrapup;
   
   if( intersect )
   {
      BSplplintop( plane1, plane2, off_opt, n1, n1, off, off, num, &pts,
                   &par1, &par2, rc );
      if(BSERROR(*rc))
      {
         if( *rc == BSCOINCIDENT)
            *rc = BSSUCC;
         else
            goto wrapup;
      }
      else if ( *num > 0 )
      {
         limit = MIN(*num, 2 );
         *num = 0;
         for(i=0; i< limit; i++)
         {
            for(k=0; k<3; k++)
            {
               planept1[i][k] = pts[i][k];
               planept2[i][k] = pts[i][k];
            }
            planeuv1[i][0] = par1[i][0];
            planeuv1[i][1] = par1[i][1];
            planeuv2[i][0] = par2[i][0];
            planeuv2[i][1] = par2[i][1];
            *num+=1;
         }
         if (pts)
            BSdealloc((char *)pts);
         if (par1)
            BSdealloc((char *)par1);
         if (par2)
            BSdealloc((char *)par2);
         *dist = 0;
         goto wrapup;
      }
   }      

   /*  if no intersection points, then there is only one output point  */

   *dist = -1.0;
   ptBSmdistplpl(plane1, plane2, dist, planeuv1[0], planeuv2[0], planept1[0], planept2[0], corners1, cornerpars1, rc );
   if(BSERROR(*rc))
      goto wrapup;

   ptBSmdistplpl(plane2, plane1, dist, planeuv2[0], planeuv1[0], planept2[0], planept1[0], corners2, cornerpars2, rc );
   if(BSERROR(*rc))
      goto wrapup;

   /* now find minimum distance edge/edge */
   for(i=0; i< 4; i++)
   {
      for(j=0; j< 4; j++)
      {
         BSdlsegs2( corners1[i], corners1[i+1], corners2[j], corners2[j+1], &mindist,
                    pt1, pt2, &p1, &p2, rc );
         if(BSERROR(*rc))
            goto wrapup;
         if( mindist < *dist )
         {
            *dist = mindist;
            planept1[0][0] = pt1[0];
            planept1[0][1] = pt1[1];
            planept1[0][2] = pt1[2];	    	    
            planept2[0][0] = pt2[0];
            planept2[0][1] = pt2[1];
            planept2[0][2] = pt2[2];
            if( i == 0 || i == 2 )
            {	    	    
               planeuv1[0][0] = p1;
               planeuv1[0][1] = cornerpars1[i][1];
            }
            else
            {
               planeuv1[0][0] = cornerpars1[i][0];
               planeuv1[0][1] = p1;
            }               
            if( j == 0 || j == 2 )
            {	    	    
               planeuv2[0][0] = p2;
               planeuv2[0][1] = cornerpars2[j][1];
            }
            else
            {
               planeuv2[0][0] = cornerpars2[j][0];
               planeuv2[0][1] = p2;
            }               
         }         
      }
   }
   *num = 1;
      
   wrapup:
   
   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSmdistplpl");
   return;
   }
}

