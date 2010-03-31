/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
     This function returns a plane definition such that the plane 
encompasses a 3D range box. The input for the plane is a point and a
normal.
     This is a temporary function untill the corresponding math function
is available.
     Space for poles,knots should be allocated by the caller in the input
structure plane.
     plane->poles : space for 4 points (3D)
     plane->u_knots : space for 4 doubles
     plane->v_knots : space for 4 doubles.


 HISTORY

	07/06/93	Sudha	Modified for BSprototypes ansification

*/

#include "bsdefs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "bsplane3pt.h"
#include "bspl_cv_int.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdistptpt.h"
#include "bscrossp.h"


void EMfinitepln(point,normal,min,max,plane,rc)

IGRpoint      		point;
IGRvector     		normal;
IGRdouble     		*min,*max;
struct IGRbsp_surface 	*plane;
IGRlong         	*rc;
{
   struct IGRbsp_curve curve;
   IGRpoint pole[2],int_points[2],plpoints[3],p1,p2;
   IGRdouble knot[4],u[2],a[2],b[2],uknots[4];             
   IGRint n_int,n_seg,npl,i,j,k;
   IGRvector vec,cross;
   IGRdouble dist,dist1,dist_tol;

   *rc = EMS_S_Success;
   npl = 0;
   
   (void)BSEXTRACTPAR(rc,BSTOLLENVEC,dist_tol);

   curve.poles = &pole[0][0];
   curve.knots = &knot[0];
   curve.num_knots = 4;
   curve.num_poles = 2;
   curve.knots[0] = 0;
   curve.knots[1] = 0;
   curve.knots[2] = 1;
   curve.knots[3] = 1;
   curve.rational = 0;
   curve.weights = NULL;
   curve.order = 2;
   curve.planar = FALSE;
   curve.phy_closed = FALSE;
   curve.periodic = FALSE;
   curve.num_boundaries = 0;


   /* now increase the size of the box  */

   for(i=0; i<3; i++)
   {
      vec[i] = (max[i] - min[i])/2;
      p1[i] = min[i] - vec[i];
      p2[i] = max[i] + vec[i];
   }

   /* now take each boundary of the box and intersect it with the plane, and
      when three intersection points have been found, then stop  */

   for(i=0; i<3; i++)
   {
      pole[0][i] = p1[i];
   }
   pole[1][0] = p2[0];
   pole[1][1] = p1[1];
   pole[1][2] = p1[2];
   (void)BSpl_cv_int(rc,&curve,point,normal,&n_int,(IGRdouble *)int_points,u,&n_seg,a,b);
   if(*rc != BSSUCC)
    {
      *rc = EMS_E_Fail;
      goto wrapup;
    }

   if( n_int > 0 )
   {
      for(j=0; j<3; j++)
      {
         plpoints[npl][j] = int_points[0][j];
      }
      npl += 1;
   }
   else
   {
      if( n_seg > 0 )
      {
         for(j=0; j< 3; j++)
         {
            plpoints[npl][j] = pole[0][j];
            plpoints[npl+1][j] = pole[1][j];
         }
         npl += 2;  
      }
   }
   pole[1][0] = p1[0];
   pole[1][1] = p2[1];
   (void)BSpl_cv_int(rc,&curve,point,normal,&n_int,(IGRdouble *)int_points,u,&n_seg,a,b);
   if(*rc != BSSUCC)
   {
      *rc = EMS_E_Fail;
      goto wrapup;
   }
   if( n_int > 0 )
   {
      for(j=0; j<3; j++)
      {
         plpoints[npl][j] = int_points[0][j];
      }
      npl += 1;
   }
   else
   {
      if( n_seg > 0 )
      {
         if( npl < 2 )
         {
            for(j=0; j< 3; j++)
            {
               plpoints[npl][j] = pole[0][j];
               plpoints[npl+1][j] = pole[1][j];
            }
            npl += 2;  
         }
         else
         {
            for(j=0; j< 3; j++)
            {
               plpoints[npl][j] = pole[0][j];
            }
            npl += 1;  
         }
      }
   }
   if( npl < 3 )
   {
      pole[1][1] = p1[1];
      pole[1][2] = p2[2];
      (void)BSpl_cv_int(rc,&curve,point,normal,&n_int,(IGRdouble *)int_points,u,&n_seg,a,b);
      if(*rc != BSSUCC)
      {
	 *rc = EMS_E_Fail;
         goto wrapup;
      }
      if( n_int > 0 )
      {
         for(j=0; j<3; j++)
         {
            plpoints[npl][j] = int_points[0][j];
         }
         npl += 1;
      }
      else
      {
         if( n_seg > 0 )
         {
            if( npl < 2 )
            {
               for(j=0; j< 3; j++)
               {
                  plpoints[npl][j] = pole[0][j];
                  plpoints[npl+1][j] = pole[1][j];
               }
               npl += 2;  
            }
            else
            {
               if( npl < 3 )
               {
                  for(j=0; j< 3; j++)
                  {
                     plpoints[npl][j] = pole[0][j];
                  }
                  npl += 1;  
               }
            }
         }
      }
      if( npl < 3 )
      {
         pole[0][0] = p2[0];
         pole[0][1] = p1[1];
         pole[0][2] = p2[2];
         (void)BSpl_cv_int(rc,&curve,point,normal,&n_int,(IGRdouble *)int_points,u,&n_seg,a,b);
         if(*rc != BSSUCC)
         {
	    *rc = EMS_E_Fail;
            goto wrapup;
         }
         if( n_int > 0 )
         {
            for(j=0; j<3; j++)
            {
               plpoints[npl][j] = int_points[0][j];
            }
            npl += 1;
         }
         else
         {
            if( n_seg > 0 )
            {
               if( npl < 2 )
               {
                  for(j=0; j< 3; j++)
                  {
                     plpoints[npl][j] = pole[0][j];
                     plpoints[npl+1][j] = pole[1][j];
                  }
                  npl += 2;  
               }
               else
               {
                  if( npl < 3 )
                  {
                     for(j=0; j< 3; j++)
                     {
                        plpoints[npl][j] = pole[0][j];
                     }
                     npl += 1;  
                  }
               }
            }
         }
         if( npl < 3 )
         {
            pole[0][0] = p1[0];
            pole[0][1] = p2[1];
            pole[0][2] = p2[2];
            (void)BSpl_cv_int(rc,&curve,point,normal,&n_int,(IGRdouble *)int_points,u,&n_seg,a,b);
            if(*rc != BSSUCC)
            {
	       *rc = EMS_E_Fail;
               goto wrapup;
            }
            if( n_int > 0 )
            {
               for(j=0; j<3; j++)
               {
                  plpoints[npl][j] = int_points[0][j];
               }
               npl += 1;
            }
            else
            {
               if( n_seg > 0 )
               {
                  if( npl < 2 )
                  {
                     for(j=0; j< 3; j++)
                     {
                        plpoints[npl][j] = pole[0][j];
                        plpoints[npl+1][j] = pole[1][j];
                     }
                     npl += 2;  
                  }
                  else
                  {
                     if( npl < 3 )
                     {
                        for(j=0; j< 3; j++)
                        {
                           plpoints[npl][j] = pole[0][j];
                        }
                        npl += 1;  
                     }
                  }
               }
            }
            if( npl < 3 )
            {
               pole[1][0] = p1[0];
               pole[1][1] = p2[1];
               pole[1][2] = p1[2];
               (void)BSpl_cv_int(rc,&curve,point,normal,&n_int,(IGRdouble *)int_points,u,
                                 &n_seg,a,b);
               if(*rc != BSSUCC)
               {
	    	  *rc = EMS_E_Fail;
                  goto wrapup;
               }
               if( n_int > 0 )
               {
                  for(j=0; j<3; j++)
                  {
                     plpoints[npl][j] = int_points[0][j];
                  }
                  npl += 1;
               }
               else
               {
                  if( n_seg > 0 )
                  {
                     if( npl < 2 )
                     {
                        for(j=0; j< 3; j++)
                        {
                           plpoints[npl][j] = pole[0][j];
                           plpoints[npl+1][j] = pole[1][j];
                        }
                        npl += 2;  
                     }
                     else
                     {
                        if( npl < 3 )
                        {
                           for(j=0; j< 3; j++)
                           {
                              plpoints[npl][j] = pole[0][j];
                           }
                           npl += 1;  
                        }
                     }
                  }
               }
               if( npl < 3 )
               {
                  pole[1][0] = p2[0];
                  pole[1][1] = p2[1];
                  pole[1][2] = p2[2];
                  (void)BSpl_cv_int(rc,&curve,point,normal,&n_int,(IGRdouble *)int_points,u,
                                   &n_seg,a,b);
                  if(*rc != BSSUCC)
                  {
		     *rc = EMS_E_Fail;
                     goto wrapup;
                  }
                  if( n_int > 0 )
                  {
                     for(j=0; j<3; j++)
                     {
                        plpoints[npl][j] = int_points[0][j];
                     }
                     npl += 1;
                  }
                  else
                  {
                     if( n_seg > 0 )
                     {
                        if( npl < 2 )
                        {
                           for(j=0; j< 3; j++)
                           {
                              plpoints[npl][j] = pole[0][j];
                              plpoints[npl+1][j] = pole[1][j];
                           }
                           npl += 2;  
                        }
                        else
                        {
                           if( npl < 3 )
                           {
                              for(j=0; j< 3; j++)
                              {
                                 plpoints[npl][j] = pole[0][j];
                              }
                              npl += 1;  
                           }
                        }
                     }
                  }
                  if( npl < 3 )
                  {
                     pole[0][0] = p2[0];
                     pole[0][1] = p1[1];
                     pole[0][2] = p2[2];
                     (void)BSpl_cv_int(rc,&curve,point,normal,&n_int,(IGRdouble *)int_points,u,
                                      &n_seg,a,b);
                     if(*rc != BSSUCC)
                     {
			*rc = EMS_E_Fail;
                        goto wrapup;
                     }
                     if( n_int > 0 )
                     {
                        for(j=0; j<3; j++)
                        {
                           plpoints[npl][j] = int_points[0][j];
                        }
                        npl += 1;
                     }
                     else
                     {
                        if( n_seg > 0 )
                        {
                           if( npl < 2 )
                           {
                              for(j=0; j< 3; j++)
                              {
                                 plpoints[npl][j] = pole[0][j];
                                 plpoints[npl+1][j] = pole[1][j];
                              }
                              npl += 2;  
                           }
                           else
                           {
                              if( npl < 3 )
                              {
                                 for(j=0; j< 3; j++)
                                 {
                                    plpoints[npl][j] = pole[0][j];
                                 }
                                 npl += 1;  
                              }
                           }
                        }
                     }
                     if( npl < 3 )
                     {
                        pole[0][0] = p2[0];
                        pole[0][1] = p2[1];
                        pole[0][2] = p1[2];
                        (void)BSpl_cv_int(rc,&curve,point,normal,&n_int,
                                           (IGRdouble *)int_points,u,&n_seg,a,b);
                        if(*rc != BSSUCC)
                        {
			   *rc = EMS_E_Fail;
                           goto wrapup;
                        }
                        if( n_int > 0 )
                        {
                           for(j=0; j<3; j++)
                           {
                              plpoints[npl][j] = int_points[0][j];
                           }
                           npl += 1;
                        }
                        else
                        {
                           if( n_seg > 0 )
                           {
                              if( npl < 2 )
                              {
                                 for(j=0; j< 3; j++)
                                 {
                                    plpoints[npl][j] = pole[0][j];
                                    plpoints[npl+1][j] = pole[1][j];
                                 }
                                 npl += 2;  
                              }
                              else
                              {
                                 if( npl < 3 )
                                 {
                                    for(j=0; j< 3; j++)
                                    {
                                       plpoints[npl][j] = pole[0][j];
                                    }
                                    npl += 1;  
                                 }
                              }
                           }
                        }
                        if( npl < 3 )
                        {
                           pole[1][0] = p1[0];
                           pole[1][1] = p2[1];
                           pole[1][2] = p1[2];
                           (void)BSpl_cv_int(rc,&curve,point,normal,&n_int,
                                              (IGRdouble *)int_points,u,&n_seg,a,b);
                           if(*rc != BSSUCC)
                           {
			      *rc = EMS_E_Fail;
                              goto wrapup;
                           }
                           if( n_int > 0 )
                           {
                              for(j=0; j<3; j++)
                              {
                                 plpoints[npl][j] = int_points[0][j];
                              }
                              npl += 1;
                           }
                           else
                           {
                              if( n_seg > 0 )
                              {
                                 if( npl < 2 )
                                 {
                                    for(j=0; j< 3; j++)
                                    {
                                       plpoints[npl][j] = pole[0][j];
                                       plpoints[npl+1][j] = pole[1][j];
                                    }
                                    npl += 2;  
                                 }
                                 else
                                 {
                                    if( npl < 3 )
                                    {
                                       for(j=0; j< 3; j++)
                                       {
                                          plpoints[npl][j] = pole[0][j];
                                       }
                                       npl += 1;  
                                    }
                                 }
                              }
                           }
                           if( npl < 3 )
                           {
                              pole[1][0] = p2[0];
                              pole[1][1] = p1[1];
                              pole[1][2] = p1[2];
                              (void)BSpl_cv_int(rc,&curve,point,normal,&n_int,
                                                 (IGRdouble *)int_points,u,&n_seg,a,b);
                              if(*rc != BSSUCC)
                              {
				 *rc = EMS_E_Fail;
                                 goto wrapup;
                              }
                              if( n_int > 0 )
                              {
                                 for(j=0; j<3; j++)
                                 {
                                    plpoints[npl][j] = int_points[0][j];
                                 }
                                 npl += 1;
                              }
                              else
                              {
                                 if( n_seg > 0 )
                                 {
                                    if( npl < 2 )
                                    {
                                       for(j=0; j< 3; j++)
                                       {
                                          plpoints[npl][j] = pole[0][j];
                                          plpoints[npl+1][j] = pole[1][j];
                                       }
                                       npl += 2;  
                                    }
                                    else
                                    {
                                       if( npl < 3 )
                                       {
                                          for(j=0; j< 3; j++)
                                          {
                                             plpoints[npl][j] = pole[0][j];
                                          }
                                          npl += 1;  
                                       }
                                    }
                                 }
                              }
                              if( npl < 3 )
                              {
                                 pole[0][0] = p2[0];
                                 pole[0][1] = p1[1];
                                 pole[0][2] = p2[2];
                                 (void)BSpl_cv_int(rc,&curve,point,normal,
                                                &n_int,(IGRdouble *)int_points,u,&n_seg,a,b);
                                 if(*rc != BSSUCC)
                                 {
				    *rc = EMS_E_Fail;
                                    goto wrapup;
                                 }
                                 if( n_int > 0 )
                                 {
                                    for(j=0; j<3; j++)
                                    {
                                       plpoints[npl][j] = int_points[0][j];
                                    }
                                    npl += 1;
                                 }
                                 else
                                 {
                                    if( n_seg > 0 )
                                    {
                                       if( npl < 2 )
                                       {
                                          for(j=0; j< 3; j++)
                                          {
                                             plpoints[npl][j] = pole[0][j];
                                             plpoints[npl+1][j] = pole[1][j];
                                          }
                                          npl += 2;  
                                       }
                                       else
                                       {
                                          if( npl < 3 )
                                          {
                                             for(j=0; j< 3; j++)
                                             {
                                                plpoints[npl][j] = pole[0][j];
                                             }
                                             npl += 1;  
                                          }
                                       }
                                    }
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }
   if( npl == 3 )
   {

      /* check to see if any two points are coincident, because if the
         surface is planar, then you will have points that are coincident  */

      dist = BSdistptpt(rc,plpoints[0],plpoints[1]);
      if(*rc != BSSUCC)
      {
	 *rc = EMS_E_Fail;
         goto wrapup;
      }

      dist1 = BSdistptpt(rc,plpoints[0],plpoints[2]);
      if(*rc != BSSUCC)
      {
	 *rc = EMS_E_Fail;
         goto wrapup;
      }

      if( dist < dist_tol  || dist1 < dist_tol)
      {
      
         /* our surface is planar, so we need to find three distinct points */

         (void)BSmkvec(rc,vec,plpoints[1],plpoints[2]);
         (void)BScrossp(rc,vec,normal,cross);
         (void)BSnorvec(rc,cross);
         dist = BSdistptpt(rc,plpoints[1],plpoints[2]);

         for(i=0; i<3; i++)
         {
            plpoints[0][i] = plpoints[1][i] + dist/2.0 * cross[i];
            plpoints[1][i] -= (dist/2.0 * cross[i]);
            plpoints[2][i] -= (dist/2.0 * cross[i]);
         }
      }         
      else
      {
         dist = BSdistptpt(rc,plpoints[1],plpoints[2]);

         if(dist < dist_tol )
         {
            (void)BSmkvec(rc,vec,plpoints[0],plpoints[2]);
            (void)BScrossp(rc,vec,normal,cross);
            (void)BSnorvec(rc,cross);
            dist = BSdistptpt(rc,plpoints[0],plpoints[2]);

            for(i=0; i<3; i++)
            {
               plpoints[1][i] = plpoints[0][i] + dist/2.0 * cross[i];
               plpoints[0][i] -= (dist/2.0 * cross[i]);
               plpoints[2][i] -= (dist/2.0 * cross[i]);
            }
         }         
      }        

  }
      /* create a surface for the plane  */

      (void)BSplane3pt(rc,plpoints[0],plpoints[1],plpoints[2],plane);

wrapup:
   if( (*rc != EMS_E_Fail) && (*rc != EMS_S_Success))
    {
      if(*rc != BSSUCC) *rc = EMS_E_Fail;
      else *rc = EMS_S_Success;
    }
}
