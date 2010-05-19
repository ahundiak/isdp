/*
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSsfintroff

Abstract
    This routine offsets the interior poles of a B-spline surface by giving
an offset distance

Synopsis
    void BSsfintroff(surf, d, off_surf, rc)

    struct IGRbsp_surface *surf
    IGRdouble  d
    struct IGRbsp_surface *off_surf
    BSrc       *rc
   
Description
    This routine inputs a B-spline surface and an offset distance and
offsets the interior poles of the surface.The result surface is the
output off_surf.    

Return Values
    This routine returns a successful completion message of BSSUCC if it
succeeds, otherwise an error message of BSFAIL(or other error message)
is returned.

Notes
    The caller needs to allocate the memory for off_surf before calling
this routine. The size of each element for off_surf is the same as in
surf.

Index
    em

Keywords

History
    Y. S. Sheng 10/02/86 : Creation date.
    Y. S. Sheng 10/23/87 : Replace BSpl_pl_pl with BSint3offpl.
    Y. S. Sheng 02/06/88 : Modifify cross_sqtol to be 100 times greater.
                           Normalized vectors before calling BScrossp.
    S.G. Catron 06/10/92 : Removed error check after BSnorvec.
    S.G. Catron 03/31/93 : In the section where it's collinear in one
                           direction and not in the other, we need to 
                           check for degeneracy.  For example, only if 
                           cross1 and cross2 are non-zero are the 
                           triangles coplanar.
    C.S. Kirby  11/28/95 : Remove multiplication of cross_sqtol by 100.
    Vivian Y. Hsu 02/17/98: Remove the above kludge. Let cross_sqtol
                            = 100 * cross_sqtol.
*/

#define  BSVOID
#include "bsdefs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsconic.h"

#define  POLE(i,j,k)  surf->poles[((i) * surf->u_num_poles + (j)) * 3 + (k)]
#define  WEIGHT(i,j)  surf->weights[(i) * surf->u_num_poles + (j)]

void BSsfintroff(
struct IGRbsp_surface *surf,
IGRdouble        d,
struct IGRbsp_surface *off_surf,
BSrc             *rc)
{
#include "bsdbgrc.h"
#include "bsmkvec.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bscollin.h"
#include "bsint3offpl.h"
#include "bslenvecsq.h"
    IGRboolean status;
    IGRboolean u_collin,v_collin;
    IGRint     n_p,m_p,num_norm;
    IGRint     i,j,k;
    IGRpoint   p[3],q[3];
    IGRpoint   r1,r2,r3,r4;
    IGRpoint   pnt,pnt1,pnt2,pnt3,pnt4;
    IGRvector  norm,dummy1,dummy2,dummy3;
    IGRvector  vec1,vec2,vec3,vec4;
    IGRvector  cross1,cross2,cross3,cross4;
    IGRvector  test12,test23,test34,test41;
    IGRdouble  zero_tol,zero_sqtol,cross_sqtol;
    IGRdouble  mag12,mag23,mag34,mag41;

    status = TRUE;
    *rc = BSSUCC;

    BSEXTRACTPAR(rc,BSTOLCLOSETOZERO,zero_tol);

    zero_sqtol = zero_tol * zero_tol;

    BSEXTRACTPAR(rc,BSTOLSQCOLLINVEC,cross_sqtol);

    cross_sqtol *= 100;

    n_p = surf->u_num_poles;
    m_p = surf->v_num_poles;

    for(i=1; i <= m_p -2; i++)
    {
        for(j=1; j <= n_p -2; j++)
        {

            if(surf->rational)
            {
                for(k=0; k < 3; k++)
                {
                    p[0][k] = POLE(i,j-1,k) / WEIGHT(i,j-1);
                    p[1][k] = POLE(i,j,k) / WEIGHT(i,j);
                    p[2][k] = POLE(i,j+1,k) / WEIGHT(i,j+1);
                }
            }
            else
            {
                for(k=0; k < 3; k++)
                {
                    p[0][k] = POLE(i,j-1,k);
                    p[1][k] = POLE(i,j,k);
                    p[2][k] = POLE(i,j+1,k);
                }
            }


            if(surf->rational)
            {
                for(k=0; k < 3; k++)
                {
                    q[0][k] = POLE(i-1,j,k) / WEIGHT(i-1,j);
                    q[1][k] = POLE(i,j,k) / WEIGHT(i,j);
                    q[2][k] = POLE(i+1,j,k) / WEIGHT(i+1,j);
                }
            }
            else
            {
                for(k=0; k < 3; k++)
                {
                    q[0][k] = POLE(i-1,j,k);
                    q[1][k] = POLE(i,j,k);
                    q[2][k] = POLE(i+1,j,k);
                }
            }


            /** find the unit normal for four triangle planes **/

            status = BSmkvec(rc, vec1, p[1], p[2]);
            if(! status) goto wrapup;

            status = BSmkvec(rc, vec2, q[1], q[2]);
            if(! status) goto wrapup;

            status = BSmkvec(rc, vec3, p[0], p[1]);
            if(! status) goto wrapup;

            status = BSmkvec(rc, vec4, q[0], q[1]);
            if(! status) goto wrapup;

            status = BSnorvec(rc,vec1);

            status = BSnorvec(rc,vec2);

/******* removed error check 06/10/92 , p[0] = p[1] and q[0] = q[1] ****/
            status = BSnorvec(rc,vec3);

            status = BSnorvec(rc,vec4);

            status = BScrossp(rc, vec1, vec2, cross1);
            if(! status) goto wrapup;

            status = BScrossp(rc, vec1, vec4, cross2);
            if(! status) goto wrapup;

            status = BScrossp(rc, vec3, vec4, cross3);
            if(! status) goto wrapup;

            status = BScrossp(rc, vec3, vec2, cross4);
            if(! status) goto wrapup;

            /** normalize the four normal vectors **/

            status = BSnorvec(rc,cross1);

            status = BSnorvec(rc,cross2);

            status = BSnorvec(rc,cross3);

            status = BSnorvec(rc,cross4);

            /** check if the adjacent triangles are coplanar **/

            status = BScrossp(rc,cross1,cross2,test12);
            if(! status) goto wrapup;

            status = BScrossp(rc,cross2,cross3,test23);
            if(! status) goto wrapup;

            status = BScrossp(rc,cross3,cross4,test34);
            if(! status) goto wrapup;

            status = BScrossp(rc,cross4,cross1,test41);
            if(! status) goto wrapup;


            /** calculate the magnitude for test12 ... test41 **/

            mag12 = BSlenvecsq(rc,test12);
            mag23 = BSlenvecsq(rc,test23);
            mag34 = BSlenvecsq(rc,test34);
            mag41 = BSlenvecsq(rc,test41);

            /** find the four points on the four triangle planes **/
          
            for(k=0; k < 3; k++)
            {
                r1[k] = p[1][k] + d * cross1[k];
                r2[k] = p[1][k] + d * cross2[k];
                r3[k] = p[1][k] + d * cross3[k];
                r4[k] = p[1][k] + d * cross4[k];
            }

            u_collin = BScollin(rc, p[0], p[1], p[2]);
            if(BSERROR(*rc)) goto wrapup;

            v_collin = BScollin(rc, q[0], q[1], q[2]);
            if(BSERROR(*rc)) goto wrapup;
            

            if(! u_collin)
            {
                 if(! v_collin)
                 {
                     if((mag12 > cross_sqtol)&&(mag23 > cross_sqtol)&&(mag34 >
                        cross_sqtol)&&(mag41 > cross_sqtol))
                     {
                         num_norm = 3;
                         BSint3offpl(num_norm, cross1,cross2,cross3, r3,d,
                              vec1, p[1], pnt1, rc);
                         if(BSERROR(*rc)) goto wrapup;

                         BSint3offpl(num_norm, cross2,cross3,cross4, r4,d,
                              vec4, p[1], pnt2, rc);
                         if(BSERROR(*rc)) goto wrapup;

                         BSint3offpl(num_norm, cross3,cross4,cross1, r1,d,
                              vec3, p[1], pnt3, rc);
                         if(BSERROR(*rc)) goto wrapup;

                         BSint3offpl(num_norm, cross4,cross1,cross2, r2,d,
                              vec2, p[1], pnt4, rc);
                         if(BSERROR(*rc)) goto wrapup;
                        
                         for(k=0; k < 3; k++)
                         {
                            off_surf->poles[(i * surf->u_num_poles + j) * 3 + k]
                            = (pnt1[k] + pnt2[k] + pnt3[k] + pnt4[k]) / 4;
                         }

                     }
                     else if((mag12 < cross_sqtol) && (mag23 > cross_sqtol) &&
                           (mag34 > cross_sqtol) && (mag41 > cross_sqtol))
                     {
                         num_norm = 3;
                         BSint3offpl(num_norm, cross3,cross4,cross2, r2,d,
                              vec3, p[1], pnt, rc);
                         if(BSERROR(*rc)) goto wrapup;

                         for(k=0; k < 3; k++)
                         {
                             off_surf->poles[(i * surf->u_num_poles + j) * 
                                                 3 + k]
                             = pnt[k];
                         }
                     }                            
                     else if((mag23 < cross_sqtol) && (mag34 > cross_sqtol) &&
                           (mag41 > cross_sqtol) && (mag12 > cross_sqtol))
                     {
                         num_norm = 3;

                         BSint3offpl(num_norm, cross4,cross1,cross2, r2, d,
                              vec2, p[1], pnt, rc);
                         if(BSERROR(*rc)) goto wrapup;

                         for(k=0; k < 3; k++)
                         {
                             off_surf->poles[(i * surf->u_num_poles + j) * 
                                                 3 + k]
                             = pnt[k];
                         }
                     }                            
                     else if((mag34 < cross_sqtol) && (mag41 > cross_sqtol) &&
                           (mag12 > cross_sqtol) && (mag23 > cross_sqtol))
                     {
                         num_norm = 3;

                         BSint3offpl(num_norm, cross1,cross2,cross3, r3,d,
                              vec1, p[1], pnt, rc);
                         if(BSERROR(*rc)) goto wrapup;


                         for(k=0; k < 3; k++)
                         {
                             off_surf->poles[(i * surf->u_num_poles + j) * 
                                                 3 + k]
                             = pnt[k];
                         }
                     }                            
                     else if((mag41 < cross_sqtol) && (mag12 > cross_sqtol) &&
                           (mag23 > cross_sqtol) && (mag34 > cross_sqtol))
                     {
                         num_norm = 3;

                         BSint3offpl(num_norm, cross2,cross3,cross4, r4,d,
                              vec4, p[1], pnt, rc);
                         if(BSERROR(*rc)) goto wrapup;

                         for(k=0; k < 3; k++)
                         {
                             off_surf->poles[(i * surf->u_num_poles + j) * 
                                                 3 + k]
                             = pnt[k];
                         }
                     }                            
                     else
                     {
                         /** the four triangles are coplanar **/

                         for(k=0; k < 3; k++)
                         {
                             off_surf->poles[(i * surf->u_num_poles + j) * 
                                                 3 + k]
                             = p[1][k] + d * cross1[k];
                         }                         
                     }
                 }
                 else
                 {
                     /** if collinear in v direction **/

                     status = BScrossp(rc,cross2,cross3,norm);
                     if(! status) goto wrapup;
                     /**  03/31/93  changed to add check of mag23...
                          only if cross2 and cross3 are non-zero are the
                          triangles coplanar **/
                     if(BSlenvecsq(rc,norm) < cross_sqtol && 
                         mag23 >  cross_sqtol)
                     {
                         /** four triangles are coplanar, so we can
                             use any normal **/
                         for(k=0; k < 3; k++)
                         {
                            off_surf->poles[(i * surf->u_num_poles + j) * 3 + k]
                            = p[1][k] + d * cross2[k];
                         }
                     }
                     else
                     {           
                         num_norm = 2;
                         if( mag23 > cross_sqtol )
                             BSint3offpl(num_norm, cross2,cross3,dummy1, 
                                dummy2,d,dummy3, p[1], pnt, rc);
                         else
                             BSint3offpl(num_norm, cross1,cross4,dummy1, 
                                dummy2,d,dummy3, p[1], pnt, rc);
                         if(BSERROR(*rc)) goto wrapup;

                         for(k=0; k < 3; k++)
                         {
                            off_surf->poles[(i * surf->u_num_poles + j) * 3 + k]
                            = pnt[k];
                         }
                     }
                 }
             }
             else
             {    
                 /** the three poles in u direction are collinear **/

                 if(! v_collin)
                 {
                     status = BScrossp(rc,cross1,cross2,norm);
                     if(! status) goto wrapup;

                     /**  03/31/93  changed to add check of mag12...
                          only if cross1 and cross2 are non-zero are the
                          triangles coplanar **/
                     if(BSlenvecsq(rc,norm) < cross_sqtol &&
                         mag12 >  cross_sqtol)
                     {
                         /** four triangles are coplanar, so we can
                             use any normal **/
                         for(k=0; k < 3; k++)
                         {
                            off_surf->poles[(i * surf->u_num_poles + j) * 3 + k]
                            = p[1][k] + d * cross2[k];
                         }
                     }
                     else
                     {
                         num_norm = 2;
                         if( mag12 > cross_sqtol )
                            BSint3offpl(num_norm, cross1,cross2,dummy1, 
                                 dummy2,d,dummy3, p[1], pnt, rc);
                         else
                            BSint3offpl(num_norm, cross3,cross4,dummy1, 
                                dummy2,d,dummy3, p[1], pnt, rc);
                         if(BSERROR(*rc)) goto wrapup;

                         for(k=0; k < 3; k++)
                         {
                            off_surf->poles[(i * surf->u_num_poles + j) * 3 + k]
                            = pnt[k];
                         }
                     }
                 }
                 else
                 {
                     /** both u and v directions are collinear **/

                     if(BSlenvecsq(rc,cross1) < zero_sqtol)
                     {
                         for(k=0; k < 3; k++)
                         {
                            off_surf->poles[(i * surf->u_num_poles + j) * 3 + k]
                            = off_surf->poles[(i * surf->u_num_poles + j-1
                               ) * 3 + k];
                         }
                     }                              
                     else
                     {
                         for(k=0; k < 3; k++)
                         {
                            off_surf->poles[(i * surf->u_num_poles + j) * 3 + k]
                            = p[1][k] + d * cross1[k];
                         }
                     }
                 } 
            }
            if(surf->rational)
            {
                for(k=0; k < 3; k++)
                {
                    off_surf->poles[(i * surf->u_num_poles + j) * 3 + k]
                    *= WEIGHT(i,j);
                }
            }
        }  /** end of j loop **/
    }  /** end of i loop **/
    wrapup:
      {
      if(BSERROR(*rc))
          BSdbgrc(*rc,"BSsfintroff");
      return;
      }
}                                                                         
